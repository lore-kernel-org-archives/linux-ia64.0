From: Erich Focht <focht@ess.nec.de>
Date: Tue, 22 Jan 2002 18:56:35 +0000
Subject: Re: [Linux-ia64] Ingo scheduler patch for IA64
Message-Id: <marc-linux-ia64-105590698805913@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I've put all the bits and pieces together and made a patch which seems to
be pretty stable. The patch applies to:
   2.4.17 + kdb_common + ia64 + kdb_ia64 + sched-01-2.4.17-J4.patch

I hope the task migration interrupt part is ok, I loaded the machine quite
a bit but /proc/interrupts never showed one occuring.

Best regards and thanks for the help,
Erich


diff -urN 2.4.17-ia64-kdb-j4/arch/ia64/kdb/kdba_bt.c 2.4.17-ia64-kdb-j4ia64/arch/ia64/kdb/kdba_bt.c
--- 2.4.17-ia64-kdb-j4/arch/ia64/kdb/kdba_bt.c	Tue Jan 15 15:24:09 2002
+++ 2.4.17-ia64-kdb-j4ia64/arch/ia64/kdb/kdba_bt.c	Tue Jan 22 12:09:55 2002
@@ -197,7 +197,7 @@
 	}
 #ifdef CONFIG_SMP
 	else if (task_has_cpu(p)) {
-		sw = kdb_sw[p->processor];
+		sw = kdb_sw[p->cpu];
 	}
 #endif
 	else {
diff -urN 2.4.17-ia64-kdb-j4/arch/ia64/kernel/entry.S 2.4.17-ia64-kdb-j4ia64/arch/ia64/kernel/entry.S
--- 2.4.17-ia64-kdb-j4/arch/ia64/kernel/entry.S	Tue Jan 15 15:21:06 2002
+++ 2.4.17-ia64-kdb-j4ia64/arch/ia64/kernel/entry.S	Tue Jan 22 11:54:28 2002
@@ -161,7 +161,8 @@
 	mov r8=r13			// return pointer to previously running task
 	mov r13=in0			// set "current" pointer
 	;;
-(p6)	ssm psr.i			// renable psr.i AFTER the ic bit is serialized
+//(p6)	ssm psr.i			// interrupt delivery should not be enabled
+					// with the new O(1) MQ scheduler
 	DO_LOAD_SWITCH_STACK
 
 #ifdef CONFIG_SMP
@@ -170,7 +171,8 @@
 	br.ret.sptk.many rp		// boogie on out in new context
 
 .map:
-	rsm psr.i | psr.ic
+	//rsm psr.i | psr.ic
+	rsm psr.ic
 	movl r25=PAGE_KERNEL
 	;;
 	srlz.d
diff -urN 2.4.17-ia64-kdb-j4/arch/ia64/kernel/irq_ia64.c 2.4.17-ia64-kdb-j4ia64/arch/ia64/kernel/irq_ia64.c
--- 2.4.17-ia64-kdb-j4/arch/ia64/kernel/irq_ia64.c	Fri Nov  9 23:26:17 2001
+++ 2.4.17-ia64-kdb-j4ia64/arch/ia64/kernel/irq_ia64.c	Tue Jan 22 19:51:47 2002
@@ -148,6 +148,14 @@
 	flags:		SA_INTERRUPT,
 	name:		"IPI"
 };
+
+extern void smp_task_migration_interrupt(int irq, void *dev_id, struct pt_regs *regs);
+
+static struct irqaction task_migration_irqaction = {
+	handler:	smp_task_migration_interrupt,
+	flags:		SA_INTERRUPT,
+	name:		"Task migration"
+};
 #endif
 
 void
@@ -172,6 +180,7 @@
 	register_percpu_irq(IA64_SPURIOUS_INT_VECTOR, NULL);
 #ifdef CONFIG_SMP
 	register_percpu_irq(IA64_IPI_VECTOR, &ipi_irqaction);
+	register_percpu_irq(IA64_TASK_MIGRATION, &task_migration_irqaction);
 #endif
 	platform_irq_init();
 }
diff -urN 2.4.17-ia64-kdb-j4/arch/ia64/kernel/process.c 2.4.17-ia64-kdb-j4ia64/arch/ia64/kernel/process.c
--- 2.4.17-ia64-kdb-j4/arch/ia64/kernel/process.c	Tue Jan 15 15:21:06 2002
+++ 2.4.17-ia64-kdb-j4ia64/arch/ia64/kernel/process.c	Tue Jan 22 11:49:40 2002
@@ -125,9 +125,6 @@
 cpu_idle (void *unused)
 {
 	/* endless idle loop with no priority at all */
-	init_idle();
-	current->nice = 20;
-	current->counter = -100;
 
 
 	while (1) {
@@ -136,11 +133,10 @@
 			min_xtp();
 #endif
 
-		while (!current->need_resched) {
+		if (!current->need_resched) {
 #ifdef CONFIG_IA64_SGI_SN
 			snidle();
 #endif
-			continue;
 		}
 
 #ifdef CONFIG_IA64_SGI_SN
diff -urN 2.4.17-ia64-kdb-j4/arch/ia64/kernel/setup.c 2.4.17-ia64-kdb-j4ia64/arch/ia64/kernel/setup.c
--- 2.4.17-ia64-kdb-j4/arch/ia64/kernel/setup.c	Tue Jan 15 15:21:06 2002
+++ 2.4.17-ia64-kdb-j4ia64/arch/ia64/kernel/setup.c	Tue Jan 22 11:49:40 2002
@@ -375,10 +375,10 @@
 {
 #ifdef CONFIG_SMP
 #	define lpj	c->loops_per_jiffy
-#	define cpu	c->processor
+#	define cpum	c->processor
 #else
 #	define lpj	loops_per_jiffy
-#	define cpu	0
+#	define cpum	0
 #endif
 	char family[32], features[128], *cp;
 	struct cpuinfo_ia64 *c = v;
@@ -417,7 +417,7 @@
 		   "cpu MHz    : %lu.%06lu\n"
 		   "itc MHz    : %lu.%06lu\n"
 		   "BogoMIPS   : %lu.%02lu\n\n",
-		   cpu, c->vendor, family, c->model, c->revision, c->archrev,
+		   cpum, c->vendor, family, c->model, c->revision, c->archrev,
 		   features, c->ppn, c->number,
 		   c->proc_freq / 1000000, c->proc_freq % 1000000,
 		   c->itc_freq / 1000000, c->itc_freq % 1000000,
diff -urN 2.4.17-ia64-kdb-j4/arch/ia64/kernel/smp.c 2.4.17-ia64-kdb-j4ia64/arch/ia64/kernel/smp.c
--- 2.4.17-ia64-kdb-j4/arch/ia64/kernel/smp.c	Tue Jan 15 15:24:09 2002
+++ 2.4.17-ia64-kdb-j4ia64/arch/ia64/kernel/smp.c	Tue Jan 22 19:53:29 2002
@@ -196,6 +196,42 @@
 }
 
 void
+smp_send_reschedule_all(void)
+{
+	send_IPI_all(IA64_IPI_RESCHEDULE);
+}
+
+static spinlock_t migration_lock = SPIN_LOCK_UNLOCKED;
+static task_t *new_task;
+
+
+/*
+ * This function sends a 'task migration' IPI to another CPU.
+ * Must be called from syscall contexts, with interrupts *enabled*.
+ */
+void smp_migrate_task(int cpu, task_t *p)
+{
+	/*
+	 * The target CPU will unlock the migration spinlock:
+	 */
+	spin_lock(&migration_lock);
+	new_task = p;
+	platform_send_ipi(cpu, IA64_TASK_MIGRATION, IA64_IPI_DM_INT, 0);
+}
+
+/*
+ * Task migration callback.
+ */
+asmlinkage void smp_task_migration_interrupt(int irq, void *dev_id, struct pt_regs *regs)
+{
+	task_t *p;
+
+	p = new_task;
+	spin_unlock(&migration_lock);
+	sched_task_migrated(p);
+}
+
+void
 smp_flush_tlb_all (void)
 {
 	smp_call_function ((void (*)(void *))__flush_tlb_all,0,1,1);
diff -urN 2.4.17-ia64-kdb-j4/arch/ia64/kernel/smpboot.c 2.4.17-ia64-kdb-j4ia64/arch/ia64/kernel/smpboot.c
--- 2.4.17-ia64-kdb-j4/arch/ia64/kernel/smpboot.c	Tue Jan 15 15:21:06 2002
+++ 2.4.17-ia64-kdb-j4ia64/arch/ia64/kernel/smpboot.c	Tue Jan 22 11:49:40 2002
@@ -323,7 +323,7 @@
 	extern void perfmon_init_percpu(void);
 #endif
 
-	cpuid = smp_processor_id();
+	cpuid = cpu();
 	phys_id = hard_smp_processor_id();
 
 	if (test_and_set_bit(cpuid, &cpu_online_map)) {
@@ -380,6 +380,7 @@
 	while (!atomic_read(&smp_commenced))
 		;
 
+	init_idle();
 	Dprintk("CPU %d is starting idle.\n", smp_processor_id());
 	return cpu_idle();
 }
@@ -416,11 +417,10 @@
 	if (!idle)
 		panic("No idle process for CPU %d", cpu);
 
-	task_set_cpu(idle, cpu);	/* we schedule the first task manually */
+	idle->cpu = cpu;
 
 	ia64_cpu_to_sapicid[cpu] = sapicid;
 
-	del_from_runqueue(idle);
 	unhash_process(idle);
 	init_tasks[cpu] = idle;
 
@@ -481,8 +481,7 @@
 	printk("Boot processor id 0x%x/0x%x\n", 0, boot_cpu_id);
 
 	global_irq_holder = 0;
-	current->processor = 0;
-	init_idle();
+	current->cpu = 0;
 
 	/*
 	 * If SMP should be disabled, then really disable it!
diff -urN 2.4.17-ia64-kdb-j4/arch/ia64/mm/fault.c 2.4.17-ia64-kdb-j4ia64/arch/ia64/mm/fault.c
--- 2.4.17-ia64-kdb-j4/arch/ia64/mm/fault.c	Fri Nov  9 23:26:17 2001
+++ 2.4.17-ia64-kdb-j4ia64/arch/ia64/mm/fault.c	Tue Jan 22 11:49:40 2002
@@ -194,8 +194,7 @@
   out_of_memory:
 	up_read(&mm->mmap_sem);
 	if (current->pid = 1) {
-		current->policy |= SCHED_YIELD;
-		schedule();
+		yield();
 		down_read(&mm->mmap_sem);
 		goto survive;
 	}
diff -urN 2.4.17-ia64-kdb-j4/arch/ia64/tools/print_offsets.c 2.4.17-ia64-kdb-j4ia64/arch/ia64/tools/print_offsets.c
--- 2.4.17-ia64-kdb-j4/arch/ia64/tools/print_offsets.c	Fri Nov  9 23:26:17 2001
+++ 2.4.17-ia64-kdb-j4ia64/arch/ia64/tools/print_offsets.c	Tue Jan 22 11:49:40 2002
@@ -54,7 +54,7 @@
     { "IA64_TASK_PTRACE_OFFSET",	offsetof (struct task_struct, ptrace) },
     { "IA64_TASK_SIGPENDING_OFFSET",	offsetof (struct task_struct, sigpending) },
     { "IA64_TASK_NEED_RESCHED_OFFSET",	offsetof (struct task_struct, need_resched) },
-    { "IA64_TASK_PROCESSOR_OFFSET",	offsetof (struct task_struct, processor) },
+    { "IA64_TASK_PROCESSOR_OFFSET",	offsetof (struct task_struct, cpu) },
     { "IA64_TASK_THREAD_OFFSET",	offsetof (struct task_struct, thread) },
     { "IA64_TASK_THREAD_KSP_OFFSET",	offsetof (struct task_struct, thread.ksp) },
 #ifdef CONFIG_PERFMON
diff -urN 2.4.17-ia64-kdb-j4/include/asm-ia64/bitops.h 2.4.17-ia64-kdb-j4ia64/include/asm-ia64/bitops.h
--- 2.4.17-ia64-kdb-j4/include/asm-ia64/bitops.h	Tue Jan 15 15:21:08 2002
+++ 2.4.17-ia64-kdb-j4ia64/include/asm-ia64/bitops.h	Tue Jan 22 13:03:34 2002
@@ -368,6 +368,7 @@
 
 #ifdef __KERNEL__
 
+#define __clear_bit(nr, addr)        clear_bit(nr, addr)
 #define ext2_set_bit                 test_and_set_bit
 #define ext2_clear_bit               test_and_clear_bit
 #define ext2_test_bit                test_bit
diff -urN 2.4.17-ia64-kdb-j4/include/asm-ia64/hw_irq.h 2.4.17-ia64-kdb-j4ia64/include/asm-ia64/hw_irq.h
--- 2.4.17-ia64-kdb-j4/include/asm-ia64/hw_irq.h	Tue Jan 22 13:58:22 2002
+++ 2.4.17-ia64-kdb-j4ia64/include/asm-ia64/hw_irq.h	Tue Jan 22 19:47:56 2002
@@ -49,6 +49,7 @@
 #define IA64_PERFMON_VECTOR		0xee	/* performanc monitor interrupt vector */
 #define IA64_TIMER_VECTOR		0xef	/* use highest-prio group 15 interrupt for timer */
 #define	IA64_MCA_WAKEUP_VECTOR		0xf0	/* MCA wakeup (must be >MCA_RENDEZ_VECTOR) */
+#define IA64_TASK_MIGRATION		0xfb	/* task migration interrupt vector */
 #define IA64_IPI_RESCHEDULE		0xfd	/* SMP reschedule */
 #define IA64_IPI_VECTOR			0xfe	/* inter-processor interrupt vector */
 
diff -urN 2.4.17-ia64-kdb-j4/include/asm-ia64/mmu_context.h 2.4.17-ia64-kdb-j4ia64/include/asm-ia64/mmu_context.h
--- 2.4.17-ia64-kdb-j4/include/asm-ia64/mmu_context.h	Fri Nov  9 23:26:17 2001
+++ 2.4.17-ia64-kdb-j4ia64/include/asm-ia64/mmu_context.h	Tue Jan 22 13:58:22 2002
@@ -118,6 +118,27 @@
 	reload_context(next);
 }
 
+/*
+ * Every architecture must define this function. It's the fastest
+ * way of searching a 168-bit bitmap where the first 128 bits are
+ * unlikely to be set. It's guaranteed that at least one of the 168
+ * bits is cleared.
+ */
+#if MAX_RT_PRIO != 128 || MAX_PRIO <= 192
+/* # error update this function. */
+#endif
+
+static inline int sched_find_first_zero_bit(unsigned long *b)
+{
+	unsigned long rt;
+
+	rt = b[0] & b[1];
+	if (unlikely(rt != 0xffffffffffffffff))
+		return find_first_zero_bit(b, MAX_RT_PRIO);
+
+	return ffz(b[2]) + MAX_RT_PRIO;
+}
+
 #define switch_mm(prev_mm,next_mm,next_task,cpu)	activate_mm(prev_mm, next_mm)
 
 # endif /* ! __ASSEMBLY__ */
diff -urN 2.4.17-ia64-kdb-j4/include/asm-ia64/smp.h 2.4.17-ia64-kdb-j4ia64/include/asm-ia64/smp.h
--- 2.4.17-ia64-kdb-j4/include/asm-ia64/smp.h	Fri Nov  9 23:26:17 2001
+++ 2.4.17-ia64-kdb-j4ia64/include/asm-ia64/smp.h	Tue Jan 22 13:03:34 2002
@@ -27,7 +27,7 @@
 #define SMP_IRQ_REDIRECTION	(1 << 0)
 #define SMP_IPI_REDIRECTION	(1 << 1)
 
-#define smp_processor_id()	(current->processor)
+#define smp_processor_id()	(current->cpu)
 
 extern struct smp_boot_data {
 	int cpu_count;
@@ -48,6 +48,9 @@
 
 extern unsigned long ap_wakeup_vector;
 
+extern void smp_send_reschedule(int cpu);
+extern void smp_send_reschedule_all(void);
+
 /*
  * Function to map hard smp processor id to logical id.  Slow, so
  * don't use this in performance-critical code.
@@ -110,12 +113,6 @@
 
 #define NO_PROC_ID		0xffffffff	/* no processor magic marker */
 
-/*
- * Extra overhead to move a task from one cpu to another (due to TLB and cache misses).
- * Expressed in "negative nice value" units (larger number means higher priority/penalty).
- */
-#define PROC_CHANGE_PENALTY	20
-
 extern void __init init_smp_config (void);
 extern void smp_do_timer (struct pt_regs *regs);
 
diff -urN 2.4.17-ia64-kdb-j4/include/linux/smp.h 2.4.17-ia64-kdb-j4ia64/include/linux/smp.h
--- 2.4.17-ia64-kdb-j4/include/linux/smp.h	Tue Jan 22 11:44:45 2002
+++ 2.4.17-ia64-kdb-j4ia64/include/linux/smp.h	Tue Jan 22 13:03:34 2002
@@ -24,12 +24,6 @@
 extern void smp_send_stop(void);
 
 /*
- * sends a 'reschedule' event to another CPU:
- */
-extern void FASTCALL(smp_send_reschedule(int cpu));
-
-
-/*
  * Boot processor call to load the other CPU's
  */
 extern void smp_boot_cpus(void);
diff -urN 2.4.17-ia64-kdb-j4/kdb/kdbmain.c 2.4.17-ia64-kdb-j4ia64/kdb/kdbmain.c
--- 2.4.17-ia64-kdb-j4/kdb/kdbmain.c	Tue Jan 15 15:15:21 2002
+++ 2.4.17-ia64-kdb-j4ia64/kdb/kdbmain.c	Tue Jan 22 12:09:55 2002
@@ -2360,7 +2360,7 @@
 	for_each_task(p) {
 		kdb_printf("0x%p %08d %08d  %1.1d  %3.3d  %s  0x%p%c%s\n",
 			   (void *)p, p->pid, p->p_pptr->pid,
-			   task_has_cpu(p), p->processor,
+			   task_has_cpu(p), p->cpu,
 			   (p->state = 0)?"run ":(p->state>0)?"stop":"unrn",
 			   (void *)(&p->thread),
 			   (p = current) ? '*': ' ',
diff -urN 2.4.17-ia64-kdb-j4/kernel/printk.c 2.4.17-ia64-kdb-j4ia64/kernel/printk.c
--- 2.4.17-ia64-kdb-j4/kernel/printk.c	Tue Jan 22 11:44:45 2002
+++ 2.4.17-ia64-kdb-j4ia64/kernel/printk.c	Tue Jan 22 11:49:40 2002
@@ -25,6 +25,8 @@
 #include <linux/init.h>
 #include <linux/module.h>
 #include <linux/interrupt.h>			/* For in_interrupt() */
+#include <linux/config.h>
+#include <linux/delay.h>
 
 #include <asm/uaccess.h>
 
diff -urN 2.4.17-ia64-kdb-j4/kernel/sched.c 2.4.17-ia64-kdb-j4ia64/kernel/sched.c
--- 2.4.17-ia64-kdb-j4/kernel/sched.c	Tue Jan 22 11:44:45 2002
+++ 2.4.17-ia64-kdb-j4ia64/kernel/sched.c	Tue Jan 22 12:03:07 2002
@@ -93,6 +93,15 @@
 	p->array = array;
 }
 
+/* needed on IA64, arch/ia64/kernel/head.S relies on it (EF) */
+struct task_struct * init_tasks[NR_CPUS] __initdata = {&init_task, };
+
+/* needed in kdb (EF) */
+int task_has_cpu(task_t *p)
+{
+	return (p = task_rq(p)->curr);
+}
+
 /*
  * A task is 'heavily interactive' if it either has reached the
  * bottom 25% of the SCHED_OTHER priority range, or if it is below
@@ -287,7 +296,7 @@
 	spin_unlock_irq(&this_rq()->lock);
 }
 
-static inline void context_switch(task_t *prev, task_t *next)
+static inline void context_switch(task_t *prev, task_t *next, int dont_clear)
 {
 	struct mm_struct *mm = next->mm;
 	struct mm_struct *oldmm = prev->active_mm;
@@ -302,7 +311,8 @@
 		switch_mm(oldmm, mm, next, smp_processor_id());
 
 	if (!prev->mm) {
-		prev->active_mm = NULL;
+		if (!dont_clear)
+			prev->active_mm = NULL;
 		mmdrop(oldmm);
 	}
 
@@ -617,7 +627,7 @@
 	if (likely(prev != next)) {
 		rq->nr_switches++;
 		rq->curr = next;
-		context_switch(prev, next);
+		context_switch(prev, next, 0);
 		/*
 		 * The runqueue pointer might be from another CPU
 		 * if the new task was last running on a different
diff -urN 2.4.17-ia64-kdb-j4/kernel/timer.c 2.4.17-ia64-kdb-j4ia64/kernel/timer.c
--- 2.4.17-ia64-kdb-j4/kernel/timer.c	Tue Jan 22 11:44:45 2002
+++ 2.4.17-ia64-kdb-j4ia64/kernel/timer.c	Tue Jan 22 12:23:42 2002
@@ -585,17 +585,16 @@
 
 	update_one_process(p, user_tick, system, cpu);
 	if (p->pid) {
-		if (--p->counter <= 0) {
-			p->counter = 0;
-			p->need_resched = 1;
-		}
-		if (p->nice > 0)
+		if (p->__nice > 0)
 			kstat.per_cpu_nice[cpu] += user_tick;
 		else
 			kstat.per_cpu_user[cpu] += user_tick;
 		kstat.per_cpu_system[cpu] += system;
-	} else if (really_local_bh_count() || really_local_irq_count() > 1)
-		kstat.per_cpu_system[cpu] += system;
+	} else {
+		if (really_local_bh_count() || really_local_irq_count() > 1)
+			kstat.per_cpu_system[cpu] += system;
+	}
+	scheduler_tick(p);
 }
 
 /*


