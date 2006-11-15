From: Stephane Eranian <eranian@hpl.hp.com>
Date: Wed, 15 Nov 2006 22:23:34 +0000
Subject: [PATCH] ia64 add idle loop entry/exit notifier
Message-Id: <20061115222334.GE17238@frankl.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Tony,

Here is a patch which adds an idle notifier to IA-64. It clones
the one in X86-64. You can register a callback via the notifier
and you get called when:
	- entering the lowest level of the idle loop
	- exiting the lowest level of the idle loop, either normally
	  or to process an interrupt

Basically, you can monitor useful vs. useless work accomplished by the idle
thread on each processor.

The patch also cleans up the idle callback used by SGI to get their Altix
front panel LED blinking! Obviously, I could not verify that this works
but it certainly compiles ;->


Why do we need this?

As you can guess, this is related to perfmon. In system-wide mode, we want to
exclude useless kernel execution from being monitored. The way we do this in 
the existing perfmon v2.0 is too coarse: nothing executed by the idle thread
is captured. We do want monitoring to stop when entering the lowest level
of the idle loop but we want to monitor when the idle thread executes interrupt
handlers. Theoretically, if we go to PAL_HALT_LIGHT, the PMU stops. In practice,
it depends on which events are being measured. To work around this problem, we
created the update_pal_halt_status() hook to disable PAL_HALT_LIGHT when the PMU
is used. With the idle notifier, we could clean all of this up. I do this in the
v2.3 perfmon code base.

I would appreaciate any feedback on this patch.

changelog:
	- add a notifier to the idle loop to get called when entering/leaving the
	  lowest level of the idle loop
	- migrate SGI LED acitvity over to using the idle notifier

signed-off-by: stephane eranian <eranian@hpl.hp.com>

diff --exclude=.git -urNp linux-2.6.orig/arch/ia64/kernel/irq_ia64.c linux-2.6.base/arch/ia64/kernel/irq_ia64.c
--- linux-2.6.orig/arch/ia64/kernel/irq_ia64.c	2006-10-26 14:12:56.000000000 -0700
+++ linux-2.6.base/arch/ia64/kernel/irq_ia64.c	2006-10-26 15:22:38.000000000 -0700
@@ -39,6 +39,7 @@
 #include <asm/machvec.h>
 #include <asm/pgtable.h>
 #include <asm/system.h>
+#include <asm/idle.h>
 
 #ifdef CONFIG_PERFMON
 # include <asm/perfmon.h>
@@ -176,6 +177,7 @@ ia64_handle_irq (ia64_vector vector, str
 	 * 16 (without this, it would be ~240, which could easily lead
 	 * to kernel stack overflows).
 	 */
+	exit_idle();
 	irq_enter();
 	saved_tpr = ia64_getreg(_IA64_REG_CR_TPR);
 	ia64_srlz_d();
@@ -204,6 +206,7 @@ ia64_handle_irq (ia64_vector vector, str
 	 */
 	irq_exit();
 	set_irq_regs(old_regs);
+	enter_idle();
 }
 
 #ifdef CONFIG_HOTPLUG_CPU
@@ -218,7 +221,7 @@ void ia64_process_pending_intr(void)
 	extern unsigned int vectors_in_migration[NR_IRQS];
 
 	vector = ia64_get_ivr();
-
+	exit_idle();
 	 irq_enter();
 	 saved_tpr = ia64_getreg(_IA64_REG_CR_TPR);
 	 ia64_srlz_d();
@@ -255,6 +258,7 @@ void ia64_process_pending_intr(void)
 		vector = ia64_get_ivr();
 	}
 	irq_exit();
+	enter_idle();
 }
 #endif
 
diff --exclude=.git -urNp linux-2.6.orig/arch/ia64/kernel/process.c linux-2.6.base/arch/ia64/kernel/process.c
--- linux-2.6.orig/arch/ia64/kernel/process.c	2006-10-17 05:33:35.000000000 -0700
+++ linux-2.6.base/arch/ia64/kernel/process.c	2006-11-15 12:59:17.000000000 -0800
@@ -41,6 +41,7 @@
 #include <asm/uaccess.h>
 #include <asm/unwind.h>
 #include <asm/user.h>
+#include <asm/idle.h>
 
 #include "entry.h"
 
@@ -50,11 +51,39 @@
 
 #include "sigframe.h"
 
-void (*ia64_mark_idle)(int);
 static DEFINE_PER_CPU(unsigned int, cpu_idle_state);
 
 unsigned long boot_option_idle_override = 0;
 EXPORT_SYMBOL(boot_option_idle_override);
+static ATOMIC_NOTIFIER_HEAD(idle_notifier);
+
+void idle_notifier_register(struct notifier_block *n)
+{
+	atomic_notifier_chain_register(&idle_notifier, n);
+}
+EXPORT_SYMBOL_GPL(idle_notifier_register);
+
+void idle_notifier_unregister(struct notifier_block *n)
+{
+	atomic_notifier_chain_unregister(&idle_notifier, n);
+}
+EXPORT_SYMBOL(idle_notifier_unregister);
+
+static DEFINE_PER_CPU(volatile unsigned long, idle_state);
+
+void __enter_idle(void)
+{
+	__get_cpu_var(idle_state) = 1;
+	atomic_notifier_call_chain(&idle_notifier, IDLE_START, NULL);
+}
+
+void __exit_idle(void)
+{
+	/* needs to be atomic w.r.t. interrupts, not against other CPUs */
+	if (cmpxchg(&__get_cpu_var(idle_state), 1, 0) = 0)
+		return;
+	atomic_notifier_call_chain(&idle_notifier, IDLE_END, NULL);
+}
 
 void
 ia64_do_show_stack (struct unw_frame_info *info, void *arg)
@@ -263,7 +292,6 @@ EXPORT_SYMBOL_GPL(cpu_idle_wait);
 void __attribute__((noreturn))
 cpu_idle (void)
 {
-	void (*mark_idle)(int) = ia64_mark_idle;
   	int cpu = smp_processor_id();
 
 	/* endless idle loop with no priority at all */
@@ -282,15 +310,13 @@ cpu_idle (void)
 				__get_cpu_var(cpu_idle_state) = 0;
 
 			rmb();
-			if (mark_idle)
-				(*mark_idle)(1);
 
 			idle = pm_idle;
 			if (!idle)
 				idle = default_idle;
+			__enter_idle();
 			(*idle)();
-			if (mark_idle)
-				(*mark_idle)(0);
+			__exit_idle();
 #ifdef CONFIG_SMP
 			normal_xtp();
 #endif
diff --exclude=.git -urNp linux-2.6.orig/arch/ia64/sn/kernel/idle.c linux-2.6.base/arch/ia64/sn/kernel/idle.c
--- linux-2.6.orig/arch/ia64/sn/kernel/idle.c	2006-10-17 05:33:35.000000000 -0700
+++ linux-2.6.base/arch/ia64/sn/kernel/idle.c	2006-11-02 06:01:20.000000000 -0800
@@ -5,12 +5,14 @@
  *
  * Copyright (c) 2001-2004 Silicon Graphics, Inc.  All rights reserved.
  */
-
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <asm/idle.h>
 #include <asm/sn/leds.h>
 
-void snidle(int state)
+int snidle(struct notifier_block *nb, unsigned long state, void *data)
 {
-	if (state) {
+	if (state = IDLE_START) {
 		if (pda->idle_flag = 0) {
 			/* 
 			 * Turn the activity LED off.
@@ -27,4 +29,5 @@ void snidle(int state)
 
 		pda->idle_flag = 0;
 	}
+	return NOTIFY_OK;
 }
diff --exclude=.git -urNp linux-2.6.orig/arch/ia64/sn/kernel/setup.c linux-2.6.base/arch/ia64/sn/kernel/setup.c
--- linux-2.6.orig/arch/ia64/sn/kernel/setup.c	2006-10-26 14:12:56.000000000 -0700
+++ linux-2.6.base/arch/ia64/sn/kernel/setup.c	2006-11-02 06:01:29.000000000 -0800
@@ -53,6 +53,7 @@
 #include "xtalk/xwidgetdev.h"
 #include "xtalk/hubdev.h"
 #include <asm/sn/klconfig.h>
+#include <asm/idle.h>
 
 
 DEFINE_PER_CPU(struct pda_s, pda_percpu);
@@ -63,8 +64,7 @@ extern void bte_init_node(nodepda_t *, c
 
 extern void sn_timer_init(void);
 extern unsigned long last_time_offset;
-extern void (*ia64_mark_idle) (int);
-extern void snidle(int);
+extern int snidle(struct notifier_block *nb, unsigned long state, void *data);
 extern unsigned long long (*ia64_printk_clock)(void);
 
 unsigned long sn_rtc_cycles_per_second;
@@ -123,6 +123,10 @@ struct screen_info sn_screen_info = {
 	.orig_video_points = 16
 };
 
+static struct notifier_block snidle_notifier= {
+	        .notifier_call = snidle
+};
+
 /*
  * This routine can only be used during init, since
  * smp_boot_data is an init data structure.
@@ -464,7 +468,7 @@ void __init sn_setup(char **cmdline_p)
 	 */
 	sn_init_pdas(cmdline_p);
 
-	ia64_mark_idle = &snidle;
+	idle_notifier_register(&snidle_notifier);
 
 	/*
 	 * For the bootcpu, we do this here. All other cpus will make the
diff --exclude=.git -urNp linux-2.6.orig/include/asm-ia64/idle.h linux-2.6.base/include/asm-ia64/idle.h
--- linux-2.6.orig/include/asm-ia64/idle.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.base/include/asm-ia64/idle.h	2006-11-15 13:42:48.000000000 -0800
@@ -0,0 +1,32 @@
+#ifndef _ASM_IA64_IDLE_H
+#define _ASM_IA64_IDLE_H 1
+
+#include <linux/irq.h>
+#include <asm/ptrace.h>
+
+#define IDLE_START 1
+#define IDLE_END 2
+
+struct notifier_block;
+void idle_notifier_register(struct notifier_block *n);
+void idle_notifier_unregister(struct notifier_block *n);
+
+void __exit_idle(void);
+void __enter_idle(void);
+
+/* Called from interrupts to signify back to idle */
+static inline void enter_idle(void)
+{
+	if (current->pid)
+		return;
+	__enter_idle();
+}
+
+/* Called from interrupts to signify idle end */
+static inline void exit_idle(void)
+{
+	if (current->pid)
+		return;
+	__exit_idle();
+}
+#endif
