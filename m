From: Erich Focht <focht@ess.nec.de>
Date: Tue, 15 Jan 2002 17:53:30 +0000
Subject: Re: [Linux-ia64] Help with Ingo scheduler on IA64
Message-Id: <marc-linux-ia64-105590698805831@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805816@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805816@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

the appended patch almost does the job for IA64. On my BigSur 2.4.17 +
ia64 + Ingo's_O(1)_I0 + ia64add.patch dies silently somewhere after init
checked the filesystems, sometimes the last message beeing 
"INIT: Entering runlevel: 3" or "Mounting local filesystems:". When trying
to boot with the "emergency" option added, it dies right after I enter
the root password, but it doesn't always reach this point :-( 

Any ideas what I should try to get some more insight? 

Thanks,

Erich


diff -ur 2.4.17-ia64-kdb-o1/arch/ia64/kernel/process.c 2.4.17-ia64-kdb-O1-I0/arch/ia64/kernel/process.c
--- 2.4.17-ia64-kdb-o1/arch/ia64/kernel/process.c	Tue Jan 15 15:21:06 2002
+++ 2.4.17-ia64-kdb-O1-I0/arch/ia64/kernel/process.c	Tue Jan 15 15:32:24 2002
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
diff -ur 2.4.17-ia64-kdb-o1/arch/ia64/kernel/setup.c 2.4.17-ia64-kdb-O1-I0/arch/ia64/kernel/setup.c
--- 2.4.17-ia64-kdb-o1/arch/ia64/kernel/setup.c	Tue Jan 15 15:21:06 2002
+++ 2.4.17-ia64-kdb-O1-I0/arch/ia64/kernel/setup.c	Tue Jan 15 15:32:24 2002
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
diff -ur 2.4.17-ia64-kdb-o1/arch/ia64/kernel/smp.c 2.4.17-ia64-kdb-O1-I0/arch/ia64/kernel/smp.c
--- 2.4.17-ia64-kdb-o1/arch/ia64/kernel/smp.c	Tue Jan 15 15:24:09 2002
+++ 2.4.17-ia64-kdb-O1-I0/arch/ia64/kernel/smp.c	Tue Jan 15 15:32:24 2002
@@ -196,6 +196,12 @@
 }
 
 void
+smp_send_reschedule_all(void)
+{
+	send_IPI_all(IA64_IPI_RESCHEDULE);
+}
+
+void
 smp_flush_tlb_all (void)
 {
 	smp_call_function ((void (*)(void *))__flush_tlb_all,0,1,1);
diff -ur 2.4.17-ia64-kdb-o1/arch/ia64/kernel/smpboot.c 2.4.17-ia64-kdb-O1-I0/arch/ia64/kernel/smpboot.c
--- 2.4.17-ia64-kdb-o1/arch/ia64/kernel/smpboot.c	Tue Jan 15 15:21:06 2002
+++ 2.4.17-ia64-kdb-O1-I0/arch/ia64/kernel/smpboot.c	Tue Jan 15 15:32:24 2002
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
diff -ur 2.4.17-ia64-kdb-o1/arch/ia64/mm/fault.c 2.4.17-ia64-kdb-O1-I0/arch/ia64/mm/fault.c
--- 2.4.17-ia64-kdb-o1/arch/ia64/mm/fault.c	Fri Nov  9 23:26:17 2001
+++ 2.4.17-ia64-kdb-O1-I0/arch/ia64/mm/fault.c	Tue Jan 15 15:32:24 2002
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
diff -ur 2.4.17-ia64-kdb-o1/arch/ia64/tools/print_offsets.c 2.4.17-ia64-kdb-O1-I0/arch/ia64/tools/print_offsets.c
--- 2.4.17-ia64-kdb-o1/arch/ia64/tools/print_offsets.c	Fri Nov  9 23:26:17 2001
+++ 2.4.17-ia64-kdb-O1-I0/arch/ia64/tools/print_offsets.c	Tue Jan 15 15:32:24 2002
@@ -54,7 +54,7 @@
     { "IA64_TASK_PTRACE_OFFSET",	offsetof (struct task_struct, ptrace) },
     { "IA64_TASK_SIGPENDING_OFFSET",	offsetof (struct task_struct, sigpending) },
     { "IA64_TASK_NEED_RESCHED_OFFSET",	offsetof (struct task_struct, need_resched) },
-    { "IA64_TASK_PROCESSOR_OFFSET",	offsetof (struct task_struct, processor) },
+    { "IA64_TASK_PROCESSOR_OFFSET",	offsetof (struct task_struct, cpu) },
     { "IA64_TASK_THREAD_OFFSET",	offsetof (struct task_struct, thread) },
     { "IA64_TASK_THREAD_KSP_OFFSET",	offsetof (struct task_struct, thread.ksp) },
 #ifdef CONFIG_PERFMON
diff -ur 2.4.17-ia64-kdb-o1/include/asm-ia64/bitops.h 2.4.17-ia64-kdb-O1-I0/include/asm-ia64/bitops.h
--- 2.4.17-ia64-kdb-o1/include/asm-ia64/bitops.h	Tue Jan 15 15:21:08 2002
+++ 2.4.17-ia64-kdb-O1-I0/include/asm-ia64/bitops.h	Tue Jan 15 15:38:16 2002
@@ -368,6 +368,7 @@
 
 #ifdef __KERNEL__
 
+#define __clear_bit(nr, addr)        clear_bit(nr, addr)
 #define ext2_set_bit                 test_and_set_bit
 #define ext2_clear_bit               test_and_clear_bit
 #define ext2_test_bit                test_bit
diff -ur 2.4.17-ia64-kdb-o1/include/asm-ia64/mmu_context.h 2.4.17-ia64-kdb-O1-I0/include/asm-ia64/mmu_context.h
--- 2.4.17-ia64-kdb-o1/include/asm-ia64/mmu_context.h	Fri Nov  9 23:26:17 2001
+++ 2.4.17-ia64-kdb-O1-I0/include/asm-ia64/mmu_context.h	Tue Jan 15 15:39:29 2002
@@ -118,6 +118,27 @@
 	reload_context(next);
 }
 
+/*
+ * Every architecture must define this function. It's the fastest
+ * way of searching a 168-bit bitmap where the first 128 bits are
+ * unlikely to be set. It's guaranteed that at least one of the 168
+ * bits is cleared.
+ */
+#if MAX_RT_PRIO != 128 || MAX_PRIO != 173
+# error update this function.
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
diff -ur 2.4.17-ia64-kdb-o1/include/asm-ia64/smp.h 2.4.17-ia64-kdb-O1-I0/include/asm-ia64/smp.h
--- 2.4.17-ia64-kdb-o1/include/asm-ia64/smp.h	Fri Nov  9 23:26:17 2001
+++ 2.4.17-ia64-kdb-O1-I0/include/asm-ia64/smp.h	Tue Jan 15 15:38:16 2002
@@ -27,7 +27,7 @@
 #define SMP_IRQ_REDIRECTION	(1 << 0)
 #define SMP_IPI_REDIRECTION	(1 << 1)
 
-#define smp_processor_id()	(current->processor)
+#define smp_processor_id()	(current->cpu)
 
 extern struct smp_boot_data {
 	int cpu_count;
@@ -110,12 +110,6 @@
 
 #define NO_PROC_ID		0xffffffff	/* no processor magic marker */
 
-/*
- * Extra overhead to move a task from one cpu to another (due to TLB and cache misses).
- * Expressed in "negative nice value" units (larger number means higher priority/penalty).
- */
-#define PROC_CHANGE_PENALTY	20
-
 extern void __init init_smp_config (void);
 extern void smp_do_timer (struct pt_regs *regs);
 
diff -ur 2.4.17-ia64-kdb-o1/kdb/kdbmain.c 2.4.17-ia64-kdb-O1-I0/kdb/kdbmain.c
--- 2.4.17-ia64-kdb-o1/kdb/kdbmain.c	Tue Jan 15 15:15:21 2002
+++ 2.4.17-ia64-kdb-O1-I0/kdb/kdbmain.c	Tue Jan 15 16:29:01 2002
@@ -2349,6 +2349,7 @@
  * Remarks:
  */
 
+#define task_has_cpu(p) 1
 int
 kdb_ps(int argc, const char **argv, const char **envp, struct pt_regs *regs)
 {
@@ -2360,7 +2361,7 @@
 	for_each_task(p) {
 		kdb_printf("0x%p %08d %08d  %1.1d  %3.3d  %s  0x%p%c%s\n",
 			   (void *)p, p->pid, p->p_pptr->pid,
-			   task_has_cpu(p), p->processor,
+			   task_has_cpu(p), p->cpu,
 			   (p->state = 0)?"run ":(p->state>0)?"stop":"unrn",
 			   (void *)(&p->thread),
 			   (p = current) ? '*': ' ',
diff -ur 2.4.17-ia64-kdb-o1/kernel/printk.c 2.4.17-ia64-kdb-O1-I0/kernel/printk.c
--- 2.4.17-ia64-kdb-o1/kernel/printk.c	Tue Jan 15 15:30:56 2002
+++ 2.4.17-ia64-kdb-O1-I0/kernel/printk.c	Tue Jan 15 15:32:24 2002
@@ -25,6 +25,8 @@
 #include <linux/init.h>
 #include <linux/module.h>
 #include <linux/interrupt.h>			/* For in_interrupt() */
+#include <linux/config.h>
+#include <linux/delay.h>
 
 #include <asm/uaccess.h>
 
diff -ur 2.4.17-ia64-kdb-o1/kernel/sched.c 2.4.17-ia64-kdb-O1-I0/kernel/sched.c
--- 2.4.17-ia64-kdb-o1/kernel/sched.c	Tue Jan 15 15:30:56 2002
+++ 2.4.17-ia64-kdb-O1-I0/kernel/sched.c	Tue Jan 15 15:32:24 2002
@@ -75,6 +75,8 @@
 #define unlock_task_rq(rq,p,flags)				\
 	spin_unlock_irqrestore(&rq->lock, flags)
 
+struct task_struct * init_tasks[NR_CPUS] __initdata = {&init_task, };
+
 /*
  * Adding/removing a task to/from a priority array:
  */
diff -ur 2.4.17-ia64-kdb-o1/kernel/timer.c 2.4.17-ia64-kdb-O1-I0/kernel/timer.c
--- 2.4.17-ia64-kdb-o1/kernel/timer.c	Tue Jan 15 15:30:56 2002
+++ 2.4.17-ia64-kdb-O1-I0/kernel/timer.c	Tue Jan 15 15:32:24 2002
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



