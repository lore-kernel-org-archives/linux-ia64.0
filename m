From: Josh Poimboeuf <jpoimboe@kernel.org>
Date: Tue, 14 Feb 2023 07:05:37 +0000
Subject: [PATCH v2 03/24] arm/cpu: Make sure arch_cpu_idle_dead() doesn't return
Message-Id: <ed361403b8ee965f758fe491c47336dddcfb8fd5.1676358308.git.jpoimboe@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1676358308.git.jpoimboe@kernel.org>
In-Reply-To: <cover.1676358308.git.jpoimboe@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: jgross@suse.com, richard.henderson@linaro.org, ink@jurassic.park.msu.ru, mattst88@gmail.com, linux-alpha@vger.kernel.org, linux@armlinux.org.uk, linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, will@kernel.org, guoren@kernel.org, linux-csky@vger.kernel.org, linux-ia64@vger.kernel.org, chenhuacai@kernel.org, kernel@xen0n.name, loongarch@lists.linux.dev, f.fainelli@gmail.com, bcm-kernel-feedback-list@broadcom.com, tsbogend@alpha.franken.de, linux-mips@vger.kernel.org, jiaxun.yang@flygoat.com, mpe@ellerman.id.au, npiggin@gmail.com, christophe.leroy@csgroup.eu, linuxppc-dev@lists.ozlabs.org, ysato@users.sourceforge.jp, dalias@libc.org, linux-sh@vger.kernel.org, davem@davemloft.net, sparclinux@vger.kernel.org, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, dave.hansen@linux.intel.com, x86@kernel.org, hpa@zytor.com, chris@zankel.net, jcmvbkbc@gmail.com, linux-xtensa@linux-xtensa.org, peterz@infradead.org, juri.lelli@redhat.com, vincent.guittot@linaro.org, dietmar.eggemann@arm.com, rostedt@goodmis.org, bsegall@google.com, mgorman@suse.de, bristot@redhat.com, vschneid@redhat.com, paulmck@kernel.org

arch_cpu_idle_dead() doesn't return.  Make that more explicit with a
BUG().

BUG() is preferable to unreachable() because BUG() is a more explicit
failure mode and avoids undefined behavior like falling off the edge of
the function into whatever code happens to be next.

Signed-off-by: Josh Poimboeuf <jpoimboe@kernel.org>
---
 arch/arm/kernel/smp.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/arch/arm/kernel/smp.c b/arch/arm/kernel/smp.c
index 0b8c25763adc..adcd417c526b 100644
--- a/arch/arm/kernel/smp.c
+++ b/arch/arm/kernel/smp.c
@@ -382,6 +382,8 @@ void arch_cpu_idle_dead(void)
 		: "r" (task_stack_page(current) + THREAD_SIZE - 8),
 		  "r" (current)
 		: "r0");
+
+	BUG();
 }
 #endif /* CONFIG_HOTPLUG_CPU */
 
-- 
2.39.1
