From: Nick Pollitt <npollitt@engr.sgi.com>
Date: Thu, 17 Jan 2002 05:39:08 +0000
Subject: Re: [Linux-ia64] Help with Ingo scheduler on IA64
MIME-Version: 1
Content-Type: multipart/mixed; boundary="CE+1k2dSO48ffgeK"
Message-Id: <marc-linux-ia64-105590698805865@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805816@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805816@msgid-missing>
To: linux-ia64@vger.kernel.org

--CE+1k2dSO48ffgeK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

With this hack, I'm getting an SMP boot all the way to the
init script 'Checking for new Hardware  [OK]' before the
hang.  

This patch is against linux+ia64+ingoJ0.

Nick

On Wed, Jan 16, 2002 at 05:42:30PM -0800, David Mosberger wrote:
> In case you're still fighting with Ingo's scheduler on 2.4.xx, you
> might want to try the attached patch.  It's a gross hack to work
> around a race condition in set_cpus_allowed().  Without this hack, the
> kernel would almost always die as soon as it tried to migrate
> ksoftirqd_CPU1 from CPU 0 to CPU 1.  With the patch, it boots up to
> the point where the serial line driver gets initialized, which is
> progress, I suppose.
> 
> The fundamental problem is that current set_cpus_allowed() lets the
> same task run on two CPUs for a brief period of time.  This violates
> scheduling assumptions made by the kernel and hence results in race
> conditions.
> 
> 	--david

--CE+1k2dSO48ffgeK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="ia64-j0.patch"

diff -X /home/npollitt/dontdiff -Nur ingoj0.2/arch/ia64/kernel/process.c mylinux/arch/ia64/kernel/process.c
--- ingoj0.2/arch/ia64/kernel/process.c	Wed Jan 16 21:32:45 2002
+++ mylinux/arch/ia64/kernel/process.c	Wed Jan 16 19:43:00 2002
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
diff -X /home/npollitt/dontdiff -Nur ingoj0.2/arch/ia64/kernel/setup.c mylinux/arch/ia64/kernel/setup.c
--- ingoj0.2/arch/ia64/kernel/setup.c	Wed Jan 16 21:32:45 2002
+++ mylinux/arch/ia64/kernel/setup.c	Wed Jan 16 19:43:00 2002
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
diff -X /home/npollitt/dontdiff -Nur ingoj0.2/arch/ia64/kernel/smp.c mylinux/arch/ia64/kernel/smp.c
--- ingoj0.2/arch/ia64/kernel/smp.c	Fri Dec 21 09:41:53 2001
+++ mylinux/arch/ia64/kernel/smp.c	Wed Jan 16 21:21:19 2002
@@ -186,6 +186,29 @@
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
+	smp_send_reschedule(cpu);
+}
+
+void
 smp_flush_tlb_all (void)
 {
 	smp_call_function ((void (*)(void *))__flush_tlb_all,0,1,1);
diff -X /home/npollitt/dontdiff -Nur ingoj0.2/arch/ia64/kernel/smpboot.c mylinux/arch/ia64/kernel/smpboot.c
--- ingoj0.2/arch/ia64/kernel/smpboot.c	Wed Jan 16 21:32:45 2002
+++ mylinux/arch/ia64/kernel/smpboot.c	Wed Jan 16 19:43:00 2002
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
diff -X /home/npollitt/dontdiff -Nur ingoj0.2/arch/ia64/mm/fault.c mylinux/arch/ia64/mm/fault.c
--- ingoj0.2/arch/ia64/mm/fault.c	Fri Nov  9 14:26:17 2001
+++ mylinux/arch/ia64/mm/fault.c	Wed Jan 16 19:43:00 2002
@@ -194,8 +194,7 @@
   out_of_memory:
 	up_read(&mm->mmap_sem);
 	if (current->pid == 1) {
-		current->policy |= SCHED_YIELD;
-		schedule();
+		yield();
 		down_read(&mm->mmap_sem);
 		goto survive;
 	}
diff -X /home/npollitt/dontdiff -Nur ingoj0.2/arch/ia64/tools/print_offsets.c mylinux/arch/ia64/tools/print_offsets.c
--- ingoj0.2/arch/ia64/tools/print_offsets.c	Fri Nov  9 14:26:17 2001
+++ mylinux/arch/ia64/tools/print_offsets.c	Wed Jan 16 19:43:00 2002
@@ -54,7 +54,7 @@
     { "IA64_TASK_PTRACE_OFFSET",	offsetof (struct task_struct, ptrace) },
     { "IA64_TASK_SIGPENDING_OFFSET",	offsetof (struct task_struct, sigpending) },
     { "IA64_TASK_NEED_RESCHED_OFFSET",	offsetof (struct task_struct, need_resched) },
-    { "IA64_TASK_PROCESSOR_OFFSET",	offsetof (struct task_struct, processor) },
+    { "IA64_TASK_PROCESSOR_OFFSET",	offsetof (struct task_struct, cpu) },
     { "IA64_TASK_THREAD_OFFSET",	offsetof (struct task_struct, thread) },
     { "IA64_TASK_THREAD_KSP_OFFSET",	offsetof (struct task_struct, thread.ksp) },
 #ifdef CONFIG_PERFMON
diff -X /home/npollitt/dontdiff -Nur ingoj0.2/include/asm-ia64/bitops.h mylinux/include/asm-ia64/bitops.h
--- ingoj0.2/include/asm-ia64/bitops.h	Wed Jan 16 21:32:46 2002
+++ mylinux/include/asm-ia64/bitops.h	Wed Jan 16 19:43:37 2002
@@ -368,6 +368,7 @@
 
 #ifdef __KERNEL__
 
+#define __clear_bit(nr, addr)        clear_bit(nr, addr)
 #define ext2_set_bit                 test_and_set_bit
 #define ext2_clear_bit               test_and_clear_bit
 #define ext2_test_bit                test_bit
diff -X /home/npollitt/dontdiff -Nur ingoj0.2/include/asm-ia64/mmu_context.h mylinux/include/asm-ia64/mmu_context.h
--- ingoj0.2/include/asm-ia64/mmu_context.h	Fri Nov  9 14:26:17 2001
+++ mylinux/include/asm-ia64/mmu_context.h	Wed Jan 16 21:12:16 2002
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
diff -X /home/npollitt/dontdiff -Nur ingoj0.2/include/asm-ia64/smp.h mylinux/include/asm-ia64/smp.h
--- ingoj0.2/include/asm-ia64/smp.h	Fri Nov  9 14:26:17 2001
+++ mylinux/include/asm-ia64/smp.h	Wed Jan 16 21:00:07 2002
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
@@ -109,12 +112,6 @@
 }
 
 #define NO_PROC_ID		0xffffffff	/* no processor magic marker */
-
-/*
- * Extra overhead to move a task from one cpu to another (due to TLB and cache misses).
- * Expressed in "negative nice value" units (larger number means higher priority/penalty).
- */
-#define PROC_CHANGE_PENALTY	20
 
 extern void __init init_smp_config (void);
 extern void smp_do_timer (struct pt_regs *regs);
diff -X /home/npollitt/dontdiff -Nur ingoj0.2/include/linux/smp.h mylinux/include/linux/smp.h
--- ingoj0.2/include/linux/smp.h	Wed Jan 16 21:32:55 2002
+++ mylinux/include/linux/smp.h	Wed Jan 16 21:05:20 2002
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
diff -X /home/npollitt/dontdiff -Nur ingoj0.2/kernel/printk.c mylinux/kernel/printk.c
--- ingoj0.2/kernel/printk.c	Wed Jan 16 21:32:55 2002
+++ mylinux/kernel/printk.c	Wed Jan 16 19:43:02 2002
@@ -25,6 +25,8 @@
 #include <linux/init.h>
 #include <linux/module.h>
 #include <linux/interrupt.h>			/* For in_interrupt() */
+#include <linux/config.h>
+#include <linux/delay.h>
 
 #include <asm/uaccess.h>
 
diff -X /home/npollitt/dontdiff -Nur ingoj0.2/kernel/sched.c mylinux/kernel/sched.c
--- ingoj0.2/kernel/sched.c	Wed Jan 16 21:32:55 2002
+++ mylinux/kernel/sched.c	Wed Jan 16 20:48:06 2002
@@ -94,6 +94,8 @@
 	p->array = array;
 }
 
+struct task_struct * init_tasks[NR_CPUS] __initdata = {&init_task, };
+
 /*
  * A task is 'heavily interactive' if it has reached the
  * bottom 25% of the SCHED_OTHER priority range - in this
@@ -275,7 +277,7 @@
 	spin_unlock_irq(&this_rq()->lock);
 }
 
-static inline void context_switch(task_t *prev, task_t *next)
+static inline void context_switch(task_t *prev, task_t *next, int dont_clear)
 {
 	struct mm_struct *mm = next->mm;
 	struct mm_struct *oldmm = prev->active_mm;
@@ -290,7 +292,8 @@
 		switch_mm(oldmm, mm, next, smp_processor_id());
 
 	if (!prev->mm) {
-		prev->active_mm = NULL;
+		if (!dont_clear)
+			prev->active_mm = NULL;
 		mmdrop(oldmm);
 	}
 
@@ -614,7 +617,7 @@
 	if (likely(prev != next)) {
 		rq->nr_switches++;
 		rq->curr = next;
-		context_switch(prev, next);
+		context_switch(prev, next, 0);
 		/*
 		 * The runqueue pointer might be from another CPU
 		 * if the new task was last running on a different
diff -X /home/npollitt/dontdiff -Nur ingoj0.2/kernel/timer.c mylinux/kernel/timer.c
--- ingoj0.2/kernel/timer.c	Wed Jan 16 21:32:55 2002
+++ mylinux/kernel/timer.c	Wed Jan 16 20:42:10 2002
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
+	sched_tick(p);
 }
 
 /*

--CE+1k2dSO48ffgeK--

