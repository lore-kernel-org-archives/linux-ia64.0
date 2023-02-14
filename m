From: Josh Poimboeuf <jpoimboe@kernel.org>
Date: Tue, 14 Feb 2023 07:05:58 +0000
Subject: [PATCH v2 24/24] sched/idle: Mark arch_cpu_idle_dead() __noreturn
Message-Id: <60d527353da8c99d4cf13b6473131d46719ed16d.1676358308.git.jpoimboe@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1676358308.git.jpoimboe@kernel.org>
In-Reply-To: <cover.1676358308.git.jpoimboe@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: jgross@suse.com, richard.henderson@linaro.org, ink@jurassic.park.msu.ru, mattst88@gmail.com, linux-alpha@vger.kernel.org, linux@armlinux.org.uk, linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, will@kernel.org, guoren@kernel.org, linux-csky@vger.kernel.org, linux-ia64@vger.kernel.org, chenhuacai@kernel.org, kernel@xen0n.name, loongarch@lists.linux.dev, f.fainelli@gmail.com, bcm-kernel-feedback-list@broadcom.com, tsbogend@alpha.franken.de, linux-mips@vger.kernel.org, jiaxun.yang@flygoat.com, mpe@ellerman.id.au, npiggin@gmail.com, christophe.leroy@csgroup.eu, linuxppc-dev@lists.ozlabs.org, ysato@users.sourceforge.jp, dalias@libc.org, linux-sh@vger.kernel.org, davem@davemloft.net, sparclinux@vger.kernel.org, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, dave.hansen@linux.intel.com, x86@kernel.org, hpa@zytor.com, chris@zankel.net, jcmvbkbc@gmail.com, linux-xtensa@linux-xtensa.org, peterz@infradead.org, juri.lelli@redhat.com, vincent.guittot@linaro.org, dietmar.eggemann@arm.com, rostedt@goodmis.org, bsegall@google.com, mgorman@suse.de, bristot@redhat.com, vschneid@redhat.com, paulmck@kernel.org

Before commit 076cbf5d2163 ("x86/xen: don't let xen_pv_play_dead()
return"), in Xen, when a previously offlined CPU was brought back
online, it unexpectedly resumed execution where it left off in the
middle of the idle loop.

There were some hacks to make that work, but the behavior was surprising
as do_idle() doesn't expect an offlined CPU to return from the dead (in
arch_cpu_idle_dead()).

Now that Xen has been fixed, and the arch-specific implementations of
arch_cpu_idle_dead() also don't return, give it a __noreturn attribute.

This will cause the compiler to complain if an arch-specific
implementation might return.  It also improves code generation for both
caller and callee.

Also fixes the following warning:

  vmlinux.o: warning: objtool: do_idle+0x25f: unreachable instruction

Reported-by: Paul E. McKenney <paulmck@kernel.org>
Tested-by: Paul E. McKenney <paulmck@kernel.org>
Signed-off-by: Josh Poimboeuf <jpoimboe@kernel.org>
---
 arch/alpha/kernel/process.c     | 2 +-
 arch/arm/kernel/smp.c           | 2 +-
 arch/arm64/kernel/process.c     | 2 +-
 arch/csky/kernel/smp.c          | 2 +-
 arch/ia64/kernel/process.c      | 2 +-
 arch/loongarch/kernel/process.c | 2 +-
 arch/mips/kernel/process.c      | 2 +-
 arch/parisc/kernel/process.c    | 2 +-
 arch/powerpc/kernel/smp.c       | 2 +-
 arch/riscv/kernel/cpu-hotplug.c | 2 +-
 arch/s390/kernel/idle.c         | 2 +-
 arch/sh/kernel/idle.c           | 2 +-
 arch/sparc/kernel/process_64.c  | 2 +-
 arch/x86/kernel/process.c       | 2 +-
 arch/xtensa/kernel/smp.c        | 2 +-
 include/linux/cpu.h             | 2 +-
 kernel/sched/idle.c             | 2 +-
 tools/objtool/check.c           | 1 +
 18 files changed, 18 insertions(+), 17 deletions(-)

diff --git a/arch/alpha/kernel/process.c b/arch/alpha/kernel/process.c
index d0ff06eda8fa..9bae2fc4910f 100644
--- a/arch/alpha/kernel/process.c
+++ b/arch/alpha/kernel/process.c
@@ -60,7 +60,7 @@ void arch_cpu_idle(void)
 	wtint(0);
 }
 
-void arch_cpu_idle_dead(void)
+void __noreturn arch_cpu_idle_dead(void)
 {
 	wtint(INT_MAX);
 	BUG();
diff --git a/arch/arm/kernel/smp.c b/arch/arm/kernel/smp.c
index adcd417c526b..c2daa0f2f784 100644
--- a/arch/arm/kernel/smp.c
+++ b/arch/arm/kernel/smp.c
@@ -320,7 +320,7 @@ void __cpu_die(unsigned int cpu)
  * of the other hotplug-cpu capable cores, so presumably coming
  * out of idle fixes this.
  */
-void arch_cpu_idle_dead(void)
+void __noreturn arch_cpu_idle_dead(void)
 {
 	unsigned int cpu = smp_processor_id();
 
diff --git a/arch/arm64/kernel/process.c b/arch/arm64/kernel/process.c
index 269ac1c25ae2..8d606bbb4a9a 100644
--- a/arch/arm64/kernel/process.c
+++ b/arch/arm64/kernel/process.c
@@ -69,7 +69,7 @@ void (*pm_power_off)(void);
 EXPORT_SYMBOL_GPL(pm_power_off);
 
 #ifdef CONFIG_HOTPLUG_CPU
-void arch_cpu_idle_dead(void)
+void __noreturn arch_cpu_idle_dead(void)
 {
        cpu_die();
 }
diff --git a/arch/csky/kernel/smp.c b/arch/csky/kernel/smp.c
index 0ec20efaf5fd..9c7a20b73ac6 100644
--- a/arch/csky/kernel/smp.c
+++ b/arch/csky/kernel/smp.c
@@ -300,7 +300,7 @@ void __cpu_die(unsigned int cpu)
 	pr_notice("CPU%u: shutdown\n", cpu);
 }
 
-void arch_cpu_idle_dead(void)
+void __noreturn arch_cpu_idle_dead(void)
 {
 	idle_task_exit();
 
diff --git a/arch/ia64/kernel/process.c b/arch/ia64/kernel/process.c
index 78f5794b2dde..9a5cd9fad3a9 100644
--- a/arch/ia64/kernel/process.c
+++ b/arch/ia64/kernel/process.c
@@ -225,7 +225,7 @@ static inline void __noreturn play_dead(void)
 }
 #endif /* CONFIG_HOTPLUG_CPU */
 
-void arch_cpu_idle_dead(void)
+void __noreturn arch_cpu_idle_dead(void)
 {
 	play_dead();
 }
diff --git a/arch/loongarch/kernel/process.c b/arch/loongarch/kernel/process.c
index edfd220a3737..ba70e94eb996 100644
--- a/arch/loongarch/kernel/process.c
+++ b/arch/loongarch/kernel/process.c
@@ -61,7 +61,7 @@ unsigned long boot_option_idle_override = IDLE_NO_OVERRIDE;
 EXPORT_SYMBOL(boot_option_idle_override);
 
 #ifdef CONFIG_HOTPLUG_CPU
-void arch_cpu_idle_dead(void)
+void __noreturn arch_cpu_idle_dead(void)
 {
 	play_dead();
 }
diff --git a/arch/mips/kernel/process.c b/arch/mips/kernel/process.c
index 093dbbd6b843..a3225912c862 100644
--- a/arch/mips/kernel/process.c
+++ b/arch/mips/kernel/process.c
@@ -40,7 +40,7 @@
 #include <asm/stacktrace.h>
 
 #ifdef CONFIG_HOTPLUG_CPU
-void arch_cpu_idle_dead(void)
+void __noreturn arch_cpu_idle_dead(void)
 {
 	play_dead();
 }
diff --git a/arch/parisc/kernel/process.c b/arch/parisc/kernel/process.c
index c064719b49b0..97c6f875bd0e 100644
--- a/arch/parisc/kernel/process.c
+++ b/arch/parisc/kernel/process.c
@@ -159,7 +159,7 @@ EXPORT_SYMBOL(running_on_qemu);
 /*
  * Called from the idle thread for the CPU which has been shutdown.
  */
-void arch_cpu_idle_dead(void)
+void __noreturn arch_cpu_idle_dead(void)
 {
 #ifdef CONFIG_HOTPLUG_CPU
 	idle_task_exit();
diff --git a/arch/powerpc/kernel/smp.c b/arch/powerpc/kernel/smp.c
index 6b90f10a6c81..f62e5e651bcd 100644
--- a/arch/powerpc/kernel/smp.c
+++ b/arch/powerpc/kernel/smp.c
@@ -1752,7 +1752,7 @@ void __cpu_die(unsigned int cpu)
 		smp_ops->cpu_die(cpu);
 }
 
-void arch_cpu_idle_dead(void)
+void __noreturn arch_cpu_idle_dead(void)
 {
 	/*
 	 * Disable on the down path. This will be re-enabled by
diff --git a/arch/riscv/kernel/cpu-hotplug.c b/arch/riscv/kernel/cpu-hotplug.c
index f7a832e3a1d1..59b80211c25f 100644
--- a/arch/riscv/kernel/cpu-hotplug.c
+++ b/arch/riscv/kernel/cpu-hotplug.c
@@ -71,7 +71,7 @@ void __cpu_die(unsigned int cpu)
 /*
  * Called from the idle thread for the CPU which has been shutdown.
  */
-void arch_cpu_idle_dead(void)
+void __noreturn arch_cpu_idle_dead(void)
 {
 	idle_task_exit();
 
diff --git a/arch/s390/kernel/idle.c b/arch/s390/kernel/idle.c
index b04fb418307c..45b5ee28dbe3 100644
--- a/arch/s390/kernel/idle.c
+++ b/arch/s390/kernel/idle.c
@@ -143,7 +143,7 @@ void arch_cpu_idle_exit(void)
 {
 }
 
-void arch_cpu_idle_dead(void)
+void __noreturn arch_cpu_idle_dead(void)
 {
 	cpu_die();
 }
diff --git a/arch/sh/kernel/idle.c b/arch/sh/kernel/idle.c
index 114f0c4abeac..d662503b0665 100644
--- a/arch/sh/kernel/idle.c
+++ b/arch/sh/kernel/idle.c
@@ -30,7 +30,7 @@ void default_idle(void)
 	clear_bl_bit();
 }
 
-void arch_cpu_idle_dead(void)
+void __noreturn arch_cpu_idle_dead(void)
 {
 	play_dead();
 }
diff --git a/arch/sparc/kernel/process_64.c b/arch/sparc/kernel/process_64.c
index 91c2b8124527..b51d8fb0ecdc 100644
--- a/arch/sparc/kernel/process_64.c
+++ b/arch/sparc/kernel/process_64.c
@@ -95,7 +95,7 @@ void arch_cpu_idle(void)
 }
 
 #ifdef CONFIG_HOTPLUG_CPU
-void arch_cpu_idle_dead(void)
+void __noreturn arch_cpu_idle_dead(void)
 {
 	sched_preempt_enable_no_resched();
 	cpu_play_dead();
diff --git a/arch/x86/kernel/process.c b/arch/x86/kernel/process.c
index 4433d13edd44..e52158263d30 100644
--- a/arch/x86/kernel/process.c
+++ b/arch/x86/kernel/process.c
@@ -727,7 +727,7 @@ void arch_cpu_idle_enter(void)
 	local_touch_nmi();
 }
 
-void arch_cpu_idle_dead(void)
+void __noreturn arch_cpu_idle_dead(void)
 {
 	play_dead();
 }
diff --git a/arch/xtensa/kernel/smp.c b/arch/xtensa/kernel/smp.c
index 7bad78495536..054bd64eab19 100644
--- a/arch/xtensa/kernel/smp.c
+++ b/arch/xtensa/kernel/smp.c
@@ -322,7 +322,7 @@ void __cpu_die(unsigned int cpu)
 	pr_err("CPU%u: unable to kill\n", cpu);
 }
 
-void arch_cpu_idle_dead(void)
+void __noreturn arch_cpu_idle_dead(void)
 {
 	cpu_die();
 }
diff --git a/include/linux/cpu.h b/include/linux/cpu.h
index f83e4519c5f0..8582a7142623 100644
--- a/include/linux/cpu.h
+++ b/include/linux/cpu.h
@@ -182,7 +182,7 @@ void arch_cpu_idle(void);
 void arch_cpu_idle_prepare(void);
 void arch_cpu_idle_enter(void);
 void arch_cpu_idle_exit(void);
-void arch_cpu_idle_dead(void);
+void __noreturn arch_cpu_idle_dead(void);
 
 int cpu_report_state(int cpu);
 int cpu_check_up_prepare(int cpu);
diff --git a/kernel/sched/idle.c b/kernel/sched/idle.c
index 56e152f06d0f..342f58a329f5 100644
--- a/kernel/sched/idle.c
+++ b/kernel/sched/idle.c
@@ -75,7 +75,7 @@ static noinline int __cpuidle cpu_idle_poll(void)
 void __weak arch_cpu_idle_prepare(void) { }
 void __weak arch_cpu_idle_enter(void) { }
 void __weak arch_cpu_idle_exit(void) { }
-void __weak arch_cpu_idle_dead(void) { while (1); }
+void __weak __noreturn arch_cpu_idle_dead(void) { while (1); }
 void __weak arch_cpu_idle(void)
 {
 	cpu_idle_force_poll = 1;
diff --git a/tools/objtool/check.c b/tools/objtool/check.c
index f79baae3e338..4be38a40aaca 100644
--- a/tools/objtool/check.c
+++ b/tools/objtool/check.c
@@ -168,6 +168,7 @@ static bool __dead_end_function(struct objtool_file *file, struct symbol *func,
 		"__stack_chk_fail",
 		"__ubsan_handle_builtin_unreachable",
 		"arch_call_rest_init",
+		"arch_cpu_idle_dead",
 		"cpu_bringup_and_idle",
 		"cpu_startup_entry",
 		"do_exit",
-- 
2.39.1
