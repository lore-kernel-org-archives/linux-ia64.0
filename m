From: Josh Poimboeuf <jpoimboe@kernel.org>
Date: Thu, 16 Feb 2023 18:41:57 +0000
Subject: [PATCH v2.1 04/24] arm64/cpu: Mark cpu_die() __noreturn
Message-Id: <20230216184157.4hup6y6mmspr2kll@treble>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1676358308.git.jpoimboe@kernel.org>
 <e47fc487980d5330e6059ac6e16416bec88cda0e.1676358308.git.jpoimboe@kernel.org>
 <14274f04-2991-95bd-c29b-07e86e8755c1@linaro.org>
 <Y+zZgZIP7RPIgyQf@FVFF77S0Q05N>
 <20230215194538.aiiris3uabnuvkkg@treble>
In-Reply-To: <20230215194538.aiiris3uabnuvkkg@treble>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mark Rutland <mark.rutland@arm.com>
Cc: Philippe =?utf-8?Q?Mathieu-Daud=C3=A9?= <philmd@linaro.org>, juri.lelli@redhat.com, dalias@libc.org, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, peterz@infradead.org, catalin.marinas@arm.com, dave.hansen@linux.intel.com, x86@kernel.org, jiaxun.yang@flygoat.com, linux-mips@vger.kernel.org, bsegall@google.com, jcmvbkbc@gmail.com, guoren@kernel.org, hpa@zytor.com, sparclinux@vger.kernel.org, kernel@xen0n.name, will@kernel.org, vschneid@redhat.com, f.fainelli@gmail.com, vincent.guittot@linaro.org, ysato@users.sourceforge.jp, chenhuacai@kernel.org, linux@armlinux.org.uk, linux-csky@vger.kernel.org, dietmar.eggemann@arm.com, mingo@redhat.com, bcm-kernel-feedback-list@broadcom.com, mgorman@suse.de, mattst88@gmail.com, linux-xtensa@linux-xtensa.org, paulmck@kernel.org, richard.henderson@linaro.org, npiggin@gmail.com, ink@jurassic.park.msu.ru, rostedt@goodmis.org, loongarch@lists.linux.dev, tglx@linutronix.de, linux-arm-kernel@lists.infradead.org, jgross@suse.com, chris@zankel.net, tsbogend@alpha.franken.de, bristot@redhat.com, linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, bp@alien8.de, linuxppc-dev@lists.ozlabs.org, davem@davemloft.net

cpu_die() doesn't return.  Annotate it as such.  By extension this also
makes arch_cpu_idle_dead() noreturn.

Acked-by: Mark Rutland <mark.rutland@arm.com>
Signed-off-by: Josh Poimboeuf <jpoimboe@kernel.org>
---
 arch/arm64/include/asm/smp.h | 2 +-
 arch/arm64/kernel/smp.c      | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/arm64/include/asm/smp.h b/arch/arm64/include/asm/smp.h
index fc55f5a57a06..5733a31bab08 100644
--- a/arch/arm64/include/asm/smp.h
+++ b/arch/arm64/include/asm/smp.h
@@ -100,7 +100,7 @@ static inline void arch_send_wakeup_ipi_mask(const struct cpumask *mask)
 extern int __cpu_disable(void);
 
 extern void __cpu_die(unsigned int cpu);
-extern void cpu_die(void);
+extern void __noreturn cpu_die(void);
 extern void cpu_die_early(void);
 
 static inline void cpu_park_loop(void)
diff --git a/arch/arm64/kernel/smp.c b/arch/arm64/kernel/smp.c
index 4e8327264255..d5d09a18b4f8 100644
--- a/arch/arm64/kernel/smp.c
+++ b/arch/arm64/kernel/smp.c
@@ -361,7 +361,7 @@ void __cpu_die(unsigned int cpu)
  * Called from the idle thread for the CPU which has been shutdown.
  *
  */
-void cpu_die(void)
+void __noreturn cpu_die(void)
 {
 	unsigned int cpu = smp_processor_id();
 	const struct cpu_operations *ops = get_cpu_ops(cpu);
-- 
2.39.1
