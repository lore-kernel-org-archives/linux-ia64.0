From: Nick Pollitt <npollitt@sgi.com>
Date: Sat, 12 Jan 2002 02:23:59 +0000
Subject: [Linux-ia64] Help with Ingo scheduler on IA64
MIME-Version: 1
Content-Type: multipart/mixed; boundary="PNTmBPCT7hxwcZjr"
Message-Id: <marc-linux-ia64-105590698805816@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--PNTmBPCT7hxwcZjr
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

I'm trying to get Ingo's scheduler working on IA64 but I've hit a 
dead-end with the head.S code.  Ingo's patch removes init_tasks,
so I've modified the assembly in head.S to point at 
runqueues(cpu)->idle, I think - it dies very early in the boot, 
and I'm not familiar with ia64 assembly.

Other issues, I had to build offsets.h by hand, and I moved some
stuff from sched.c to sched.h.  Other than that, it's H6 + ia64.

Anyone have any feedback on getting this booting?

Thanks
Nick


On Fri, Jan 11, 2002 at 06:49:28PM +0100, Ingo Molnar wrote:
> 
> the -H6 patch is available:
> 
>     http://redhat.com/~mingo/O(1)-scheduler/sched-O1-2.5.2-pre11-H6.patch
>     http://redhat.com/~mingo/O(1)-scheduler/sched-O1-2.4.17-H6.patch
> 

-- 
Nick Pollitt                                   phone: 650.933.7406
Scalable Linux Project                           fax: 650.932.0317
Silicon Graphics, Inc.                       npollitt@engr.sgi.com

--PNTmBPCT7hxwcZjr
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="ingo-all.3.patch"

diff -X dontdiff -Nur origlinux/arch/i386/kernel/apic.c mylinux/arch/i386/kernel/apic.c
--- origlinux/arch/i386/kernel/apic.c	Fri Jan 11 14:39:21 2002
+++ mylinux/arch/i386/kernel/apic.c	Fri Jan 11 14:46:44 2002
@@ -785,8 +785,7 @@
 	 */
 
 	slice = clocks / (smp_num_cpus+1);
-	printk("cpu: %d, clocks: %d, slice: %d\n",
-		smp_processor_id(), clocks, slice);
+	printk("cpu: %d, clocks: %d, slice: %d\n", smp_processor_id(), clocks, slice);
 
 	/*
 	 * Wait for IRQ0's slice:
@@ -809,8 +808,7 @@
 
 	__setup_APIC_LVTT(clocks);
 
-	printk("CPU%d<T0:%d,T1:%d,D:%d,S:%d,C:%d>\n",
-			smp_processor_id(), t0, t1, delta, slice, clocks);
+	printk("CPU%d<T0:%d,T1:%d,D:%d,S:%d,C:%d>\n", smp_processor_id(), t0, t1, delta, slice, clocks);
 
 	__restore_flags(flags);
 }
diff -X dontdiff -Nur origlinux/arch/i386/kernel/nmi.c mylinux/arch/i386/kernel/nmi.c
--- origlinux/arch/i386/kernel/nmi.c	Fri Jan 11 14:39:21 2002
+++ mylinux/arch/i386/kernel/nmi.c	Fri Jan 11 14:46:44 2002
@@ -283,7 +283,7 @@
 			 * to get a message out.
 			 */
 			bust_spinlocks(1);
-			printk("NMI Watchdog detected LOCKUP on CPU%d, registers:\n", cpu);
+			printk("NMI Watchdog detected LOCKUP on CPU%d, eip %08lx, registers:\n", cpu, regs->eip);
 			show_registers(regs);
 			printk("console shuts up ...\n");
 			console_silent();
diff -X dontdiff -Nur origlinux/arch/i386/kernel/process.c mylinux/arch/i386/kernel/process.c
--- origlinux/arch/i386/kernel/process.c	Fri Jan 11 14:39:21 2002
+++ mylinux/arch/i386/kernel/process.c	Fri Jan 11 14:46:44 2002
@@ -123,15 +123,12 @@
 void cpu_idle (void)
 {
 	/* endless idle loop with no priority at all */
-	init_idle();
-	current->nice = 20;
-	current->counter = -100;
 
 	while (1) {
 		void (*idle)(void) = pm_idle;
 		if (!idle)
 			idle = default_idle;
-		while (!current->need_resched)
+		if (!current->need_resched)
 			idle();
 		schedule();
 		check_pgt_cache();
diff -X dontdiff -Nur origlinux/arch/i386/kernel/smp.c mylinux/arch/i386/kernel/smp.c
--- origlinux/arch/i386/kernel/smp.c	Fri Jan 11 14:39:21 2002
+++ mylinux/arch/i386/kernel/smp.c	Fri Jan 11 14:46:44 2002
@@ -105,7 +105,7 @@
 /* The 'big kernel lock' */
 spinlock_t kernel_flag __cacheline_aligned_in_smp = SPIN_LOCK_UNLOCKED;
 
-struct tlb_state cpu_tlbstate[NR_CPUS] = {[0 ... NR_CPUS-1] = { &init_mm, 0 }};
+struct tlb_state cpu_tlbstate[NR_CPUS] __cacheline_aligned = {[0 ... NR_CPUS-1] = { &init_mm, 0, }};
 
 /*
  * the following functions deal with sending IPIs between CPUs.
@@ -490,10 +490,20 @@
  * it goes straight through and wastes no time serializing
  * anything. Worst case is that we lose a reschedule ...
  */
-
 void smp_send_reschedule(int cpu)
 {
 	send_IPI_mask(1 << cpu, RESCHEDULE_VECTOR);
+}
+
+/*
+ * this function sends a reschedule IPI to all (other) CPUs.
+ * This should only be used if some 'global' task became runnable,
+ * such as a RT task, that must be handled now. The first CPU
+ * that manages to grab the task will run it.
+ */
+void smp_send_reschedule_all(void)
+{
+	send_IPI_allbutself(RESCHEDULE_VECTOR);
 }
 
 /*
diff -X dontdiff -Nur origlinux/arch/i386/kernel/smpboot.c mylinux/arch/i386/kernel/smpboot.c
--- origlinux/arch/i386/kernel/smpboot.c	Fri Jan 11 14:39:21 2002
+++ mylinux/arch/i386/kernel/smpboot.c	Fri Jan 11 14:46:44 2002
@@ -308,14 +308,14 @@
 			if (tsc_values[i] < avg)
 				realdelta = -realdelta;
 
-			printk("BIOS BUG: CPU#%d improperly initialized, has %ld usecs TSC skew! FIXED.\n",
-				i, realdelta);
+			printk("BIOS BUG: CPU#%d improperly initialized, has %ld usecs TSC skew! FIXED.\n", i, realdelta);
 		}
 
 		sum += delta;
 	}
 	if (!buggy)
 		printk("passed.\n");
+		;
 }
 
 static void __init synchronize_tsc_ap (void)
@@ -365,7 +365,7 @@
 	 * (This works even if the APIC is not enabled.)
 	 */
 	phys_id = GET_APIC_ID(apic_read(APIC_ID));
-	cpuid = current->processor;
+	cpuid = cpu();
 	if (test_and_set_bit(cpuid, &cpu_online_map)) {
 		printk("huh, phys CPU#%d, CPU#%d already present??\n",
 					phys_id, cpuid);
@@ -471,6 +471,8 @@
 	 */
 	local_flush_tlb();
 
+	init_idle();
+	printk("cpu %d has done init idle, doing cpu_idle().\n", cpu());
 	return cpu_idle();
 }
 
@@ -803,16 +805,13 @@
 	if (!idle)
 		panic("No idle process for CPU %d", cpu);
 
-	idle->processor = cpu;
-	idle->cpus_runnable = 1 << cpu; /* we schedule the first task manually */
+	idle->cpu = cpu;
 
 	map_cpu_to_boot_apicid(cpu, apicid);
 
 	idle->thread.eip = (unsigned long) start_secondary;
 
-	del_from_runqueue(idle);
 	unhash_process(idle);
-	init_tasks[cpu] = idle;
 
 	/* start_eip had better be page-aligned! */
 	start_eip = setup_trampoline();
@@ -1020,8 +1019,7 @@
 	map_cpu_to_boot_apicid(0, boot_cpu_apicid);
 
 	global_irq_holder = 0;
-	current->processor = 0;
-	init_idle();
+	current->cpu = 0;
 	smp_tune_scheduling();
 
 	/*
diff -X dontdiff -Nur origlinux/arch/i386/mm/fault.c mylinux/arch/i386/mm/fault.c
--- origlinux/arch/i386/mm/fault.c	Fri Jan 11 14:39:22 2002
+++ mylinux/arch/i386/mm/fault.c	Fri Jan 11 14:46:44 2002
@@ -86,8 +86,7 @@
 
 out_of_memory:
 	if (current->pid == 1) {
-		current->policy |= SCHED_YIELD;
-		schedule();
+		yield();
 		goto survive;
 	}
 	goto bad_area;
@@ -342,8 +341,7 @@
 out_of_memory:
 	up_read(&mm->mmap_sem);
 	if (tsk->pid == 1) {
-		tsk->policy |= SCHED_YIELD;
-		schedule();
+		yield();
 		down_read(&mm->mmap_sem);
 		goto survive;
 	}
diff -X dontdiff -Nur origlinux/arch/ia64/kernel/head.S mylinux/arch/ia64/kernel/head.S
--- origlinux/arch/ia64/kernel/head.S	Fri Jan 11 14:39:23 2002
+++ mylinux/arch/ia64/kernel/head.S	Fri Jan 11 14:41:18 2002
@@ -124,6 +124,7 @@
 #define isAP	p2	// are we an Application Processor?
 #define isBP	p3	// are we the Bootstrap Processor?
 
+
 #ifdef CONFIG_SMP
 	/*
 	 * Find the init_task for the currently booting CPU.  At poweron, and in
@@ -132,9 +133,14 @@
 	movl r3=cpucount
  	;;
 	ld4 r3=[r3]		// r3 <- smp_processor_id()
-	movl r2=init_tasks
+	movl r2=runqueues
+	movl r4=IA64_RUNQUEUE_SIZE
 	;;
-	shladd r2=r3,3,r2
+1:      add r2=r2,r4
+        ;;
+        br.cloop.sptk.many 1b
+        ;;
+        addl r2=IA64_RUNQUEUE_IDLE_OFFSET,r2
 	;;
 	ld8 r2=[r2]
 #else
diff -X dontdiff -Nur origlinux/arch/ia64/kernel/process.c mylinux/arch/ia64/kernel/process.c
--- origlinux/arch/ia64/kernel/process.c	Fri Jan 11 14:39:23 2002
+++ mylinux/arch/ia64/kernel/process.c	Fri Jan 11 14:37:23 2002
@@ -125,9 +125,6 @@
 cpu_idle (void *unused)
 {
 	/* endless idle loop with no priority at all */
-	init_idle();
-	current->nice = 20;
-	current->counter = -100;
 
 
 	while (1) {
@@ -136,7 +133,7 @@
 			min_xtp();
 #endif
 
-		while (!current->need_resched) {
+		if (!current->need_resched) {
 #ifdef CONFIG_IA64_SGI_SN
 			snidle();
 #endif
diff -X dontdiff -Nur origlinux/arch/ia64/kernel/setup.c mylinux/arch/ia64/kernel/setup.c
--- origlinux/arch/ia64/kernel/setup.c	Fri Jan 11 14:39:23 2002
+++ mylinux/arch/ia64/kernel/setup.c	Fri Jan 11 15:09:46 2002
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
diff -X dontdiff -Nur origlinux/arch/ia64/kernel/smp.c mylinux/arch/ia64/kernel/smp.c
--- origlinux/arch/ia64/kernel/smp.c	Fri Jan 11 14:39:23 2002
+++ mylinux/arch/ia64/kernel/smp.c	Fri Jan 11 14:37:23 2002
@@ -186,6 +186,12 @@
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
diff -X dontdiff -Nur origlinux/arch/ia64/kernel/smpboot.c mylinux/arch/ia64/kernel/smpboot.c
--- origlinux/arch/ia64/kernel/smpboot.c	Fri Jan 11 14:39:23 2002
+++ mylinux/arch/ia64/kernel/smpboot.c	Fri Jan 11 14:37:23 2002
@@ -23,6 +23,7 @@
 #include <linux/smp.h>
 #include <linux/smp_lock.h>
 #include <linux/spinlock.h>
+#include <linux/sched.h>
 
 #include <asm/atomic.h>
 #include <asm/bitops.h>
@@ -323,7 +324,7 @@
 	extern void perfmon_init_percpu(void);
 #endif
 
-	cpuid = smp_processor_id();
+	cpuid = cpu();
 	phys_id = hard_smp_processor_id();
 
 	if (test_and_set_bit(cpuid, &cpu_online_map)) {
@@ -416,13 +417,11 @@
 	if (!idle)
 		panic("No idle process for CPU %d", cpu);
 
-	task_set_cpu(idle, cpu);	/* we schedule the first task manually */
+	idle->cpu = cpu();
 
 	ia64_cpu_to_sapicid[cpu] = sapicid;
 
-	del_from_runqueue(idle);
 	unhash_process(idle);
-	init_tasks[cpu] = idle;
 
 	Dprintk("Sending wakeup vector %u to AP 0x%x/0x%x.\n", ap_wakeup_vector, cpu, sapicid);
 
@@ -481,7 +480,7 @@
 	printk("Boot processor id 0x%x/0x%x\n", 0, boot_cpu_id);
 
 	global_irq_holder = 0;
-	current->processor = 0;
+	current->cpu = 0;
 	init_idle();
 
 	/*
diff -X dontdiff -Nur origlinux/arch/ia64/mm/fault.c mylinux/arch/ia64/mm/fault.c
--- origlinux/arch/ia64/mm/fault.c	Fri Jan 11 14:39:24 2002
+++ mylinux/arch/ia64/mm/fault.c	Fri Jan 11 14:37:23 2002
@@ -194,8 +194,6 @@
   out_of_memory:
 	up_read(&mm->mmap_sem);
 	if (current->pid == 1) {
-		current->policy |= SCHED_YIELD;
-		schedule();
 		down_read(&mm->mmap_sem);
 		goto survive;
 	}
diff -X dontdiff -Nur origlinux/arch/ia64/tools/print_offsets.c mylinux/arch/ia64/tools/print_offsets.c
--- origlinux/arch/ia64/tools/print_offsets.c	Fri Jan 11 14:39:25 2002
+++ mylinux/arch/ia64/tools/print_offsets.c	Fri Jan 11 14:37:23 2002
@@ -50,11 +50,12 @@
     { "IA64_CPU_SIZE",			sizeof (struct cpuinfo_ia64) },
     { "SIGFRAME_SIZE",			sizeof (struct sigframe) },
     { "UNW_FRAME_INFO_SIZE",		sizeof (struct unw_frame_info) },
+    { "IA64_RUNQUEUE_SIZE",		sizeof (struct runqueue) },
     { "", 0 },			/* spacer */
     { "IA64_TASK_PTRACE_OFFSET",	offsetof (struct task_struct, ptrace) },
     { "IA64_TASK_SIGPENDING_OFFSET",	offsetof (struct task_struct, sigpending) },
     { "IA64_TASK_NEED_RESCHED_OFFSET",	offsetof (struct task_struct, need_resched) },
-    { "IA64_TASK_PROCESSOR_OFFSET",	offsetof (struct task_struct, processor) },
+    { "IA64_TASK_PROCESSOR_OFFSET",	offsetof (struct task_struct, cpu) },
     { "IA64_TASK_THREAD_OFFSET",	offsetof (struct task_struct, thread) },
     { "IA64_TASK_THREAD_KSP_OFFSET",	offsetof (struct task_struct, thread.ksp) },
 #ifdef CONFIG_PERFMON
@@ -62,6 +63,7 @@
 #endif
     { "IA64_TASK_PID_OFFSET",		offsetof (struct task_struct, pid) },
     { "IA64_TASK_MM_OFFSET",		offsetof (struct task_struct, mm) },
+    { "IA64_RUNQUEUE_IDLE_OFFSET",	offsetof (struct runqueue, idle) },
     { "IA64_PT_REGS_CR_IPSR_OFFSET",	offsetof (struct pt_regs, cr_ipsr) },
     { "IA64_PT_REGS_CR_IIP_OFFSET",	offsetof (struct pt_regs, cr_iip) },
     { "IA64_PT_REGS_CR_IFS_OFFSET",	offsetof (struct pt_regs, cr_ifs) },
diff -X dontdiff -Nur origlinux/drivers/block/loop.c mylinux/drivers/block/loop.c
--- origlinux/drivers/block/loop.c	Fri Jan 11 14:39:52 2002
+++ mylinux/drivers/block/loop.c	Fri Jan 11 14:46:44 2002
@@ -570,9 +570,6 @@
 	flush_signals(current);
 	spin_unlock_irq(&current->sigmask_lock);
 
-	current->policy = SCHED_OTHER;
-	current->nice = -20;
-
 	spin_lock_irq(&lo->lo_lock);
 	lo->lo_state = Lo_bound;
 	atomic_inc(&lo->lo_pending);
diff -X dontdiff -Nur origlinux/drivers/ide/ataraid.c mylinux/drivers/ide/ataraid.c
--- origlinux/drivers/ide/ataraid.c	Fri Jan 11 14:40:02 2002
+++ mylinux/drivers/ide/ataraid.c	Fri Jan 11 14:46:44 2002
@@ -121,11 +121,8 @@
 	void *ptr = NULL;
 	while (!ptr) {
 		ptr=kmalloc(sizeof(struct buffer_head),GFP_NOIO);
-		if (!ptr) {
-			__set_current_state(TASK_RUNNING);
-	                current->policy |= SCHED_YIELD;
-	                schedule();             
-		}
+		if (!ptr)
+			yield();
 	}
 	return ptr;
 }
@@ -137,11 +134,8 @@
 	void *ptr = NULL;
 	while (!ptr) {
 		ptr=kmalloc(sizeof(struct ataraid_bh_private),GFP_NOIO);
-		if (!ptr) {
-			__set_current_state(TASK_RUNNING);
-	                current->policy |= SCHED_YIELD;
-	                schedule();             
-		}
+		if (!ptr)
+			yield();
 	}
 	return ptr;
 }
diff -X dontdiff -Nur origlinux/drivers/md/md.c mylinux/drivers/md/md.c
--- origlinux/drivers/md/md.c	Fri Jan 11 14:40:09 2002
+++ mylinux/drivers/md/md.c	Fri Jan 11 14:46:44 2002
@@ -2930,8 +2930,6 @@
 	 * bdflush, otherwise bdflush will deadlock if there are too
 	 * many dirty RAID5 blocks.
 	 */
-	current->policy = SCHED_OTHER;
-	current->nice = -20;
 	md_unlock_kernel();
 
 	complete(thread->event);
@@ -3381,11 +3379,6 @@
 	       "(but not more than %d KB/sec) for reconstruction.\n",
 	       sysctl_speed_limit_max);
 
-	/*
-	 * Resync has low priority.
-	 */
-	current->nice = 19;
-
 	is_mddev_idle(mddev); /* this also initializes IO event counters */
 	for (m = 0; m < SYNC_MARKS; m++) {
 		mark[m] = jiffies;
@@ -3463,16 +3456,13 @@
 		currspeed = (j-mddev->resync_mark_cnt)/2/((jiffies-mddev->resync_mark)/HZ +1) +1;
 
 		if (currspeed > sysctl_speed_limit_min) {
-			current->nice = 19;
-
 			if ((currspeed > sysctl_speed_limit_max) ||
 					!is_mddev_idle(mddev)) {
 				current->state = TASK_INTERRUPTIBLE;
 				md_schedule_timeout(HZ/4);
 				goto repeat;
 			}
-		} else
-			current->nice = -20;
+		}
 	}
 	printk(KERN_INFO "md: md%d: sync done.\n",mdidx(mddev));
 	err = 0;
diff -X dontdiff -Nur origlinux/drivers/net/slip.c mylinux/drivers/net/slip.c
--- origlinux/drivers/net/slip.c	Fri Jan 11 14:40:21 2002
+++ mylinux/drivers/net/slip.c	Fri Jan 11 14:46:44 2002
@@ -1393,10 +1393,8 @@
 		/* First of all: check for active disciplines and hangup them.
 		 */
 		do {
-			if (busy) {
-				current->counter = 0;
-				schedule();
-			}
+			if (busy)
+				sys_sched_yield();
 
 			busy = 0;
 			local_bh_disable();
diff -X dontdiff -Nur origlinux/fs/binfmt_elf.c mylinux/fs/binfmt_elf.c
--- origlinux/fs/binfmt_elf.c	Fri Jan 11 14:40:54 2002
+++ mylinux/fs/binfmt_elf.c	Fri Jan 11 14:46:44 2002
@@ -1143,7 +1143,7 @@
 	psinfo.pr_state = i;
 	psinfo.pr_sname = (i < 0 || i > 5) ? '.' : "RSDZTD"[i];
 	psinfo.pr_zomb = psinfo.pr_sname == 'Z';
-	psinfo.pr_nice = current->nice;
+	psinfo.pr_nice = current->__nice;
 	psinfo.pr_flag = current->flags;
 	psinfo.pr_uid = NEW_TO_OLD_UID(current->uid);
 	psinfo.pr_gid = NEW_TO_OLD_GID(current->gid);
diff -X dontdiff -Nur origlinux/fs/buffer.c mylinux/fs/buffer.c
--- origlinux/fs/buffer.c	Fri Jan 11 14:40:54 2002
+++ mylinux/fs/buffer.c	Fri Jan 11 14:46:44 2002
@@ -725,9 +725,7 @@
 	wakeup_bdflush();
 	try_to_free_pages(zone, GFP_NOFS, 0);
 	run_task_queue(&tq_disk);
-	current->policy |= SCHED_YIELD;
-	__set_current_state(TASK_RUNNING);
-	schedule();
+	sys_sched_yield();
 }
 
 void init_buffer(struct buffer_head *bh, bh_end_io_t *handler, void *private)
diff -X dontdiff -Nur origlinux/fs/jbd/journal.c mylinux/fs/jbd/journal.c
--- origlinux/fs/jbd/journal.c	Fri Jan 11 14:40:58 2002
+++ mylinux/fs/jbd/journal.c	Fri Jan 11 14:46:44 2002
@@ -460,8 +460,7 @@
 			printk (KERN_NOTICE __FUNCTION__
 				": ENOMEM at get_unused_buffer_head, "
 				"trying again.\n");
-			current->policy |= SCHED_YIELD;
-			schedule();
+			yield();
 		}
 	} while (!new_bh);
 	/* keep subsequent assertions sane */
@@ -1539,8 +1538,7 @@
 			last_warning = jiffies;
 		}
 		
-		current->policy |= SCHED_YIELD;
-		schedule();
+		yield();
 	}
 }
 
@@ -1598,8 +1596,7 @@
 			last_warning = jiffies;
 		}
 		while (ret == 0) {
-			current->policy |= SCHED_YIELD;
-			schedule();
+			yield();
 			ret = kmem_cache_alloc(journal_head_cache, GFP_NOFS);
 		}
 	}
diff -X dontdiff -Nur origlinux/fs/jbd/revoke.c mylinux/fs/jbd/revoke.c
--- origlinux/fs/jbd/revoke.c	Fri Jan 11 14:40:58 2002
+++ mylinux/fs/jbd/revoke.c	Fri Jan 11 14:46:44 2002
@@ -137,8 +137,7 @@
 	if (!journal_oom_retry)
 		return -ENOMEM;
 	jbd_debug(1, "ENOMEM in " __FUNCTION__ ", retrying.\n");
-	current->policy |= SCHED_YIELD;
-	schedule();
+	yield();
 	goto repeat;
 }
 
diff -X dontdiff -Nur origlinux/fs/jbd/transaction.c mylinux/fs/jbd/transaction.c
--- origlinux/fs/jbd/transaction.c	Fri Jan 11 14:40:58 2002
+++ mylinux/fs/jbd/transaction.c	Fri Jan 11 14:46:44 2002
@@ -1377,8 +1377,7 @@
 		do {
 			old_handle_count = transaction->t_handle_count;
 			set_current_state(TASK_RUNNING);
-			current->policy |= SCHED_YIELD;
-			schedule();
+			yield();
 		} while (old_handle_count != transaction->t_handle_count);
 	}
 
diff -X dontdiff -Nur origlinux/fs/jffs2/background.c mylinux/fs/jffs2/background.c
--- origlinux/fs/jffs2/background.c	Fri Jan 11 14:40:58 2002
+++ mylinux/fs/jffs2/background.c	Fri Jan 11 14:46:44 2002
@@ -106,9 +106,6 @@
 
         sprintf(current->comm, "jffs2_gcd_mtd%d", c->mtd->index);
 
-	/* FIXME in the 2.2 backport */
-	current->nice = 10;
-
 	for (;;) {
 		spin_lock_irq(&current->sigmask_lock);
 		siginitsetinv (&current->blocked, sigmask(SIGHUP) | sigmask(SIGKILL) | sigmask(SIGSTOP) | sigmask(SIGCONT));
diff -X dontdiff -Nur origlinux/fs/locks.c mylinux/fs/locks.c
--- origlinux/fs/locks.c	Fri Jan 11 14:40:59 2002
+++ mylinux/fs/locks.c	Fri Jan 11 14:46:44 2002
@@ -445,8 +445,7 @@
 			/* Let the blocked process remove waiter from the
 			 * block list when it gets scheduled.
 			 */
-			current->policy |= SCHED_YIELD;
-			schedule();
+			yield();
 		} else {
 			/* Remove waiter from the block list, because by the
 			 * time it wakes up blocker won't exist any more.
diff -X dontdiff -Nur origlinux/fs/nfs/pagelist.c mylinux/fs/nfs/pagelist.c
--- origlinux/fs/nfs/pagelist.c	Fri Jan 11 14:40:59 2002
+++ mylinux/fs/nfs/pagelist.c	Fri Jan 11 14:46:44 2002
@@ -96,8 +96,7 @@
 			continue;
 		if (signalled() && (server->flags & NFS_MOUNT_INTR))
 			return ERR_PTR(-ERESTARTSYS);
-		current->policy = SCHED_YIELD;
-		schedule();
+		yield();
 	}
 
 	/* Initialize the request struct. Initially, we assume a
diff -X dontdiff -Nur origlinux/fs/proc/array.c mylinux/fs/proc/array.c
--- origlinux/fs/proc/array.c	Fri Jan 11 14:41:03 2002
+++ mylinux/fs/proc/array.c	Fri Jan 11 14:46:44 2002
@@ -335,9 +335,12 @@
 
 	/* scale priority and nice values from timeslices to -20..20 */
 	/* to make it look like a "normal" Unix priority/nice value  */
-	priority = task->counter;
-	priority = 20 - (priority * 10 + DEF_COUNTER / 2) / DEF_COUNTER;
-	nice = task->nice;
+	priority = task->prio;
+	if (priority >= MAX_RT_PRIO)
+		priority -= MAX_RT_PRIO;
+	else
+		priority = priority-100;
+	nice = task->__nice;
 
 	read_lock(&tasklist_lock);
 	ppid = task->pid ? task->p_opptr->pid : 0;
@@ -387,7 +390,7 @@
 		task->nswap,
 		task->cnswap,
 		task->exit_signal,
-		task->processor);
+		task->cpu);
 	if(mm)
 		mmput(mm);
 	return res;
diff -X dontdiff -Nur origlinux/fs/proc/proc_misc.c mylinux/fs/proc/proc_misc.c
--- origlinux/fs/proc/proc_misc.c	Fri Jan 11 14:41:03 2002
+++ mylinux/fs/proc/proc_misc.c	Fri Jan 11 14:46:44 2002
@@ -85,11 +85,11 @@
 	a = avenrun[0] + (FIXED_1/200);
 	b = avenrun[1] + (FIXED_1/200);
 	c = avenrun[2] + (FIXED_1/200);
-	len = sprintf(page,"%d.%02d %d.%02d %d.%02d %d/%d %d\n",
+	len = sprintf(page,"%d.%02d %d.%02d %d.%02d %ld/%d %d\n",
 		LOAD_INT(a), LOAD_FRAC(a),
 		LOAD_INT(b), LOAD_FRAC(b),
 		LOAD_INT(c), LOAD_FRAC(c),
-		nr_running, nr_threads, last_pid);
+		nr_running(), nr_threads, last_pid);
 	return proc_calc_metrics(page, start, off, count, eof, len);
 }
 
@@ -101,7 +101,7 @@
 	int len;
 
 	uptime = jiffies;
-	idle = init_tasks[0]->times.tms_utime + init_tasks[0]->times.tms_stime;
+	idle = init_task.times.tms_utime + init_task.times.tms_stime;
 
 	/* The formula for the fraction parts really is ((t * 100) / HZ) % 100, but
 	   that would overflow about every five days at HZ == 100.
@@ -303,10 +303,10 @@
 	}
 
 	len += sprintf(page + len,
-		"\nctxt %u\n"
+		"\nctxt %lu\n"
 		"btime %lu\n"
 		"processes %lu\n",
-		kstat.context_swtch,
+		nr_context_switches(),
 		xtime.tv_sec - jif / HZ,
 		total_forks);
 
diff -X dontdiff -Nur origlinux/fs/reiserfs/buffer2.c mylinux/fs/reiserfs/buffer2.c
--- origlinux/fs/reiserfs/buffer2.c	Fri Jan 11 14:41:04 2002
+++ mylinux/fs/reiserfs/buffer2.c	Fri Jan 11 14:46:44 2002
@@ -33,8 +33,7 @@
 			buffer_journal_dirty(bh) ? ' ' : '!');
     }
     run_task_queue(&tq_disk);
-    current->policy |= SCHED_YIELD;
-    schedule();
+    yield();
   }
   if (repeat_counter > 30000000) {
     reiserfs_warning("vs-3051: done waiting, ignore vs-3050 messages for (%b)\n", bh) ;
@@ -52,11 +51,11 @@
 struct buffer_head  * reiserfs_bread (struct super_block *super, int n_block, int n_size) 
 {
     struct buffer_head  *result;
-    PROC_EXP( unsigned int ctx_switches = kstat.context_swtch );
+    PROC_EXP( unsigned int ctx_switches = nr_context_switches(); );
 
     result = bread (super -> s_dev, n_block, n_size);
     PROC_INFO_INC( super, breads );
-    PROC_EXP( if( kstat.context_swtch != ctx_switches ) 
+    PROC_EXP( if( nr_context_switches() != ctx_switches ) 
 	      PROC_INFO_INC( super, bread_miss ) );
     return result;
 }
diff -X dontdiff -Nur origlinux/fs/reiserfs/journal.c mylinux/fs/reiserfs/journal.c
--- origlinux/fs/reiserfs/journal.c	Fri Jan 11 14:41:04 2002
+++ mylinux/fs/reiserfs/journal.c	Fri Jan 11 14:46:44 2002
@@ -149,8 +149,7 @@
   }
   bn = allocate_bitmap_node(p_s_sb) ;
   if (!bn) {
-    current->policy |= SCHED_YIELD ;
-    schedule() ;
+    yield();
     goto repeat ;
   }
   return bn ;
diff -X dontdiff -Nur origlinux/fs/ufs/truncate.c mylinux/fs/ufs/truncate.c
--- origlinux/fs/ufs/truncate.c	Fri Jan 11 14:41:05 2002
+++ mylinux/fs/ufs/truncate.c	Fri Jan 11 14:46:44 2002
@@ -448,10 +448,7 @@
 		if (IS_SYNC(inode) && (inode->i_state & I_DIRTY))
 			ufs_sync_inode (inode);
 		run_task_queue(&tq_disk);
-		current->policy |= SCHED_YIELD;
-		schedule ();
-
-
+		yield();
 	}
 	offset = inode->i_size & uspi->s_fshift;
 	if (offset) {
diff -X dontdiff -Nur origlinux/include/asm-i386/bitops.h mylinux/include/asm-i386/bitops.h
--- origlinux/include/asm-i386/bitops.h	Fri Jan 11 14:41:12 2002
+++ mylinux/include/asm-i386/bitops.h	Fri Jan 11 14:46:44 2002
@@ -75,6 +75,14 @@
 		:"=m" (ADDR)
 		:"Ir" (nr));
 }
+
+static __inline__ void __clear_bit(int nr, volatile void * addr)
+{
+	__asm__ __volatile__(
+		"btrl %1,%0"
+		:"=m" (ADDR)
+		:"Ir" (nr));
+}
 #define smp_mb__before_clear_bit()	barrier()
 #define smp_mb__after_clear_bit()	barrier()
 
diff -X dontdiff -Nur origlinux/include/asm-i386/mmu_context.h mylinux/include/asm-i386/mmu_context.h
--- origlinux/include/asm-i386/mmu_context.h	Fri Jan 11 14:41:13 2002
+++ mylinux/include/asm-i386/mmu_context.h	Fri Jan 11 14:46:44 2002
@@ -7,6 +7,28 @@
 #include <asm/pgalloc.h>
 
 /*
+ * Every architecture must define this function. It's the fastest
+ * way of searching a 168-bit bitmap where the first 128 bits are
+ * unlikely to be set. It's guaranteed that at least one of the 168
+ * bits is cleared.
+ */
+#if MAX_RT_PRIO != 128 || MAX_PRIO != 168
+# error update this function.
+#endif
+
+static inline int sched_find_first_zero_bit(unsigned long *b)
+{
+	unsigned int rt;
+
+	rt = b[0] & b[1] & b[2] & b[3];
+	if (unlikely(rt != 0xffffffff))
+		return find_first_zero_bit(b, MAX_RT_PRIO);
+
+	if (b[4] != ~0)
+		return ffz(b[4]) + MAX_RT_PRIO;
+	return ffz(b[5]) + 32 + MAX_RT_PRIO;
+}
+/*
  * possibly do the LDT unload here?
  */
 #define destroy_context(mm)		do { } while(0)
diff -X dontdiff -Nur origlinux/include/asm-i386/pgalloc.h mylinux/include/asm-i386/pgalloc.h
--- origlinux/include/asm-i386/pgalloc.h	Fri Jan 11 14:41:13 2002
+++ mylinux/include/asm-i386/pgalloc.h	Fri Jan 11 14:46:44 2002
@@ -224,6 +224,7 @@
 {
 	struct mm_struct *active_mm;
 	int state;
+	char __cacheline_padding[24];
 };
 extern struct tlb_state cpu_tlbstate[NR_CPUS];
 
diff -X dontdiff -Nur origlinux/include/asm-i386/smp.h mylinux/include/asm-i386/smp.h
--- origlinux/include/asm-i386/smp.h	Fri Jan 11 14:41:13 2002
+++ mylinux/include/asm-i386/smp.h	Fri Jan 11 14:46:44 2002
@@ -63,6 +63,7 @@
 extern void smp_flush_tlb(void);
 extern void smp_message_irq(int cpl, void *dev_id, struct pt_regs *regs);
 extern void smp_send_reschedule(int cpu);
+extern void smp_send_reschedule_all(void);
 extern void smp_invalidate_rcv(void);		/* Process an NMI */
 extern void (*mtrr_hook) (void);
 extern void zap_low_mappings (void);
@@ -104,7 +105,7 @@
  * so this is correct in the x86 case.
  */
 
-#define smp_processor_id() (current->processor)
+#define smp_processor_id() (current->cpu)
 
 static __inline int hard_smp_processor_id(void)
 {
@@ -121,18 +122,6 @@
 #endif /* !__ASSEMBLY__ */
 
 #define NO_PROC_ID		0xFF		/* No processor magic marker */
-
-/*
- *	This magic constant controls our willingness to transfer
- *	a process across CPUs. Such a transfer incurs misses on the L1
- *	cache, and on a P6 or P5 with multiple L2 caches L2 hits. My
- *	gut feeling is this will vary by board in value. For a board
- *	with separate L2 cache it probably depends also on the RSS, and
- *	for a board with shared L2 cache it ought to decay fast as other
- *	processes are run.
- */
- 
-#define PROC_CHANGE_PENALTY	15		/* Schedule penalty */
 
 #endif
 #endif
diff -X dontdiff -Nur origlinux/include/asm-ia64/bitops.h mylinux/include/asm-ia64/bitops.h
--- origlinux/include/asm-ia64/bitops.h	Fri Jan 11 14:41:14 2002
+++ mylinux/include/asm-ia64/bitops.h	Fri Jan 11 15:29:34 2002
@@ -368,6 +368,7 @@
 
 #ifdef __KERNEL__
 
+#define __clear_bit(nr, addr)		clear_bit(nr, addr)
 #define ext2_set_bit                 test_and_set_bit
 #define ext2_clear_bit               test_and_clear_bit
 #define ext2_test_bit                test_bit
diff -X dontdiff -Nur origlinux/include/asm-ia64/mmu_context.h mylinux/include/asm-ia64/mmu_context.h
--- origlinux/include/asm-ia64/mmu_context.h	Fri Jan 11 14:41:14 2002
+++ mylinux/include/asm-ia64/mmu_context.h	Fri Jan 11 15:40:00 2002
@@ -118,6 +118,7 @@
 	reload_context(next);
 }
 
+#define sched_find_first_zero_bit(bitmap)	ffz(bitmap)
 #define switch_mm(prev_mm,next_mm,next_task,cpu)	activate_mm(prev_mm, next_mm)
 
 # endif /* ! __ASSEMBLY__ */
diff -X dontdiff -Nur origlinux/include/asm-ia64/smp.h mylinux/include/asm-ia64/smp.h
--- origlinux/include/asm-ia64/smp.h	Fri Jan 11 14:41:14 2002
+++ mylinux/include/asm-ia64/smp.h	Fri Jan 11 15:37:41 2002
@@ -27,7 +27,7 @@
 #define SMP_IRQ_REDIRECTION	(1 << 0)
 #define SMP_IPI_REDIRECTION	(1 << 1)
 
-#define smp_processor_id()	(current->processor)
+#define smp_processor_id()	(current->cpu)
 
 extern struct smp_boot_data {
 	int cpu_count;
@@ -109,12 +109,6 @@
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
diff -X dontdiff -Nur origlinux/include/linux/kernel_stat.h mylinux/include/linux/kernel_stat.h
--- origlinux/include/linux/kernel_stat.h	Fri Jan 11 14:41:36 2002
+++ mylinux/include/linux/kernel_stat.h	Fri Jan 11 15:37:41 2002
@@ -32,10 +32,11 @@
 	unsigned int ipackets, opackets;
 	unsigned int ierrors, oerrors;
 	unsigned int collisions;
-	unsigned int context_swtch;
 };
 
 extern struct kernel_stat kstat;
+
+extern unsigned long nr_context_switches(void);
 
 #if !defined(CONFIG_ARCH_S390)
 /*
diff -X dontdiff -Nur origlinux/include/linux/list.h mylinux/include/linux/list.h
--- origlinux/include/linux/list.h	Fri Jan 11 14:41:36 2002
+++ mylinux/include/linux/list.h	Fri Jan 11 15:37:41 2002
@@ -19,6 +19,8 @@
 	struct list_head *next, *prev;
 };
 
+typedef struct list_head list_t;
+
 #define LIST_HEAD_INIT(name) { &(name), &(name) }
 
 #define LIST_HEAD(name) \
diff -X dontdiff -Nur origlinux/include/linux/sched.h mylinux/include/linux/sched.h
--- origlinux/include/linux/sched.h	Fri Jan 11 14:41:39 2002
+++ mylinux/include/linux/sched.h	Fri Jan 11 15:39:46 2002
@@ -6,6 +6,7 @@
 extern unsigned long event;
 
 #include <linux/config.h>
+#include <linux/compiler.h>
 #include <linux/binfmts.h>
 #include <linux/threads.h>
 #include <linux/kernel.h>
@@ -72,8 +73,9 @@
 #define CT_TO_SECS(x)	((x) / HZ)
 #define CT_TO_USECS(x)	(((x) % HZ) * 1000000/HZ)
 
-extern int nr_running, nr_threads;
+extern int nr_threads;
 extern int last_pid;
+extern unsigned long nr_running(void);
 
 #include <linux/fs.h>
 #include <linux/time.h>
@@ -116,12 +118,6 @@
 #define SCHED_FIFO		1
 #define SCHED_RR		2
 
-/*
- * This is an additional bit set when we want to
- * yield the CPU for one re-schedule..
- */
-#define SCHED_YIELD		0x10
-
 struct sched_param {
 	int sched_priority;
 };
@@ -139,7 +135,6 @@
  * a separate lock).
  */
 extern rwlock_t tasklist_lock;
-extern spinlock_t runqueue_lock;
 extern spinlock_t mmlist_lock;
 
 extern void sched_init(void);
@@ -150,6 +145,7 @@
 extern void update_process_times(int user);
 extern void update_one_process(struct task_struct *p, unsigned long user,
 			       unsigned long system, int cpu);
+extern void scheduler_tick(struct task_struct *p);
 
 #define	MAX_SCHEDULE_TIMEOUT	LONG_MAX
 extern signed long FASTCALL(schedule_timeout(signed long timeout));
@@ -278,6 +274,55 @@
 extern struct user_struct root_user;
 #define INIT_USER (&root_user)
 
+#define BITMAP_SIZE ((((MAX_PRIO+7)/8)+sizeof(long)-1)/sizeof(long))
+
+/*
+ * RT priorites go from 0 to 99, but internally we max
+ * them out at 128 to make it easier to search the
+ * scheduler bitmap.
+ */
+#define MAX_RT_PRIO     128
+/*
+ * The lower the priority of a process, the more likely it is
+ * to run. Priority of a process goes from 0 to 167. The 0-99
+ * priority range is allocated to RT tasks, the 128-167 range
+ * is for SCHED_OTHER tasks.
+ */
+#define MAX_PRIO        (MAX_RT_PRIO+40)
+#define DEF_USER_NICE   0
+
+typedef struct task_struct task_t;
+typedef struct prio_array prio_array_t;
+typedef struct runqueue runqueue_t;
+
+struct prio_array {
+        int nr_active;
+        spinlock_t *lock;
+        runqueue_t *rq;
+        unsigned long bitmap[BITMAP_SIZE];
+        list_t queue[MAX_PRIO];
+};
+
+/*
+ * This is the main, per-CPU runqueue data structure.
+ *
+ * Locking rule: those places that want to lock multiple runqueues
+ * (such as the load balancing or the process migration code), lock
+ * acquire operations must be ordered by the runqueue's cpu id.
+ *
+ * The RT event id is used to avoid calling into the the RT scheduler
+ * if there is a RT task active in an SMP system but there is no
+ * RT scheduling activity otherwise.
+ */
+struct runqueue {
+        spinlock_t lock;
+        unsigned long nr_running, nr_switches;
+        task_t *curr, *idle;
+        prio_array_t *active, *expired, arrays[2];
+        int prev_nr_running[NR_CPUS];
+} ____cacheline_aligned;
+
+
 struct task_struct {
 	/*
 	 * offsets of these are hardcoded elsewhere - touch with care
@@ -295,35 +340,51 @@
 
 	int lock_depth;		/* Lock depth */
 
-/*
- * offset 32 begins here on 32-bit platforms. We keep
- * all fields in a single cacheline that are needed for
- * the goodness() loop in schedule().
- */
-	long counter;
-	long nice;
-	unsigned long policy;
-	struct mm_struct *mm;
-	int processor;
 	/*
-	 * cpus_runnable is ~0 if the process is not running on any
-	 * CPU. It's (1 << cpu) if it's running on a CPU. This mask
-	 * is updated under the runqueue lock.
-	 *
-	 * To determine whether a process might run on a CPU, this
-	 * mask is AND-ed with cpus_allowed.
+	 * offset 32 begins here on 32-bit platforms.
 	 */
-	unsigned long cpus_runnable, cpus_allowed;
+	unsigned int cpu;
+	int prio;
+	long __nice;
+	list_t run_list;
+	prio_array_t *array;
+
+	unsigned int time_slice;
+	unsigned long sleep_timestamp, run_timestamp;
+
 	/*
-	 * (only the 'next' pointer fits into the cacheline, but
-	 * that's just fine.)
+	 * A task's four 'sleep history' entries.
+	 *
+	 * We track the last 4 seconds of time. (including the current second).
+	 *
+	 * A value of '0' means it has spent no time sleeping in that
+	 * particular past second. The maximum value of 'HZ' means that
+	 * the task spent all its time running in that particular second.
+	 *
+	 * 'hist_idx' points to the current second, which, unlike the other
+	 * 3 entries, is only partially complete. This means that a value of
+	 * '25' does not mean the task slept 25% of the time in the current
+	 * second, it means that it spent 25 timer ticks sleeping in the
+	 * current second.
+	 *
+	 * All this might look a bit complex, but it can be maintained very
+	 * small overhead and it gives very good statistics, based on which
+	 * the scheduler can decide whether a task is 'interactive' or a
+	 * 'CPU hog'. See sched.c for more details.
 	 */
-	struct list_head run_list;
-	unsigned long sleep_time;
+	#define SLEEP_HIST_SIZE 4
+
+	int hist_idx;
+	int hist[SLEEP_HIST_SIZE];
+
+	unsigned long policy;
+	unsigned long cpus_allowed;
 
 	struct task_struct *next_task, *prev_task;
-	struct mm_struct *active_mm;
+
+	struct mm_struct *mm, *active_mm;
 	struct list_head local_pages;
+
 	unsigned int allocation_order, nr_local_pages;
 
 /* task state */
@@ -446,10 +507,51 @@
  */
 #define _STK_LIM	(8*1024*1024)
 
-#define DEF_COUNTER	(10*HZ/100)	/* 100 ms time slice */
-#define MAX_COUNTER	(20*HZ/100)
-#define DEF_NICE	(0)
+/*
+ * Scales user-nice values [ -20 ... 0 ... 19 ]
+ * to static priority [ 24 ... 63 (MAX_PRIO-1) ]
+ *
+ * User-nice value of -20 == static priority 24, and
+ * user-nice value 19 == static priority 63. The lower
+ * the priority value, the higher the task's priority.
+ *
+ * Note that while static priority cannot go below 24,
+ * the priority of a process can go as low as 0.
+ */
+#define NICE_TO_PRIO(n)	(MAX_PRIO-1 + (n) - 19)
 
+#define DEF_PRIO NICE_TO_PRIO(DEF_USER_NICE)
+
+/*
+ * Default timeslice is 90 msecs, maximum is 150 msecs.
+ * Minimum timeslice is 30 msecs.
+ */
+#define MIN_TIMESLICE	( 30 * HZ / 1000)
+#define MAX_TIMESLICE	(150 * HZ / 1000)
+
+#define USER_PRIO(p) ((p)-MAX_RT_PRIO)
+#define MAX_USER_PRIO (USER_PRIO(MAX_PRIO))
+
+/*
+ * PRIO_TO_TIMESLICE scales priority values [ 100 ... 139  ]
+ * to initial time slice values [ MAX_TIMESLICE (150 msec) ... 2 ]
+ *
+ * The higher a process's priority, the bigger timeslices
+ * it gets during one round of execution. But even the lowest
+ * priority process gets MIN_TIMESLICE worth of execution time.
+ */
+#define PRIO_TO_TIMESLICE(p) \
+	((( (MAX_USER_PRIO-1-USER_PRIO(p))*(MAX_TIMESLICE-MIN_TIMESLICE) + \
+		MAX_USER_PRIO-1) / MAX_USER_PRIO) + MIN_TIMESLICE)
+
+#define RT_PRIO_TO_TIMESLICE(p) \
+	((( (MAX_RT_PRIO-(p)-1)*(MAX_TIMESLICE-MIN_TIMESLICE) + \
+			MAX_RT_PRIO-1) / MAX_RT_PRIO) + MIN_TIMESLICE)
+
+extern void set_cpus_allowed(task_t *p, unsigned long new_mask);
+extern void set_user_nice(task_t *p, long nice);
+asmlinkage long sys_sched_yield(void);
+#define yield() sys_sched_yield()
 
 /*
  * The default (Linux) execution domain.
@@ -468,14 +570,13 @@
     addr_limit:		KERNEL_DS,					\
     exec_domain:	&default_exec_domain,				\
     lock_depth:		-1,						\
-    counter:		DEF_COUNTER,					\
-    nice:		DEF_NICE,					\
+    __nice:		DEF_USER_NICE,					\
     policy:		SCHED_OTHER,					\
+    cpus_allowed:	-1,						\
     mm:			NULL,						\
     active_mm:		&init_mm,					\
-    cpus_runnable:	-1,						\
-    cpus_allowed:	-1,						\
     run_list:		LIST_HEAD_INIT(tsk.run_list),			\
+    time_slice:		PRIO_TO_TIMESLICE(DEF_PRIO),			\
     next_task:		&tsk,						\
     prev_task:		&tsk,						\
     p_opptr:		&tsk,						\
@@ -551,19 +652,6 @@
 	return p;
 }
 
-#define task_has_cpu(tsk) ((tsk)->cpus_runnable != ~0UL)
-
-static inline void task_set_cpu(struct task_struct *tsk, unsigned int cpu)
-{
-	tsk->processor = cpu;
-	tsk->cpus_runnable = 1UL << cpu;
-}
-
-static inline void task_release_cpu(struct task_struct *tsk)
-{
-	tsk->cpus_runnable = ~0UL;
-}
-
 /* per-UID process charging. */
 extern struct user_struct * alloc_uid(uid_t);
 extern void free_uid(struct user_struct *);
@@ -591,6 +679,7 @@
 extern long FASTCALL(interruptible_sleep_on_timeout(wait_queue_head_t *q,
 						    signed long timeout));
 extern int FASTCALL(wake_up_process(struct task_struct * tsk));
+extern void FASTCALL(wake_up_forked_process(struct task_struct * tsk));
 
 #define wake_up(x)			__wake_up((x),TASK_UNINTERRUPTIBLE | TASK_INTERRUPTIBLE, 1)
 #define wake_up_nr(x, nr)		__wake_up((x),TASK_UNINTERRUPTIBLE | TASK_INTERRUPTIBLE, nr)
@@ -785,6 +874,7 @@
 
 extern void reparent_to_init(void);
 extern void daemonize(void);
+extern task_t *child_reaper;
 
 extern int do_execve(char *, char **, char **, struct pt_regs *);
 extern int do_fork(unsigned long, unsigned long, struct pt_regs *, unsigned long);
@@ -793,6 +883,9 @@
 extern void FASTCALL(add_wait_queue_exclusive(wait_queue_head_t *q, wait_queue_t * wait));
 extern void FASTCALL(remove_wait_queue(wait_queue_head_t *q, wait_queue_t * wait));
 
+extern void wait_task_inactive(task_t * p);
+extern void kick_if_running(task_t * p);
+
 #define __wait_event(wq, condition) 					\
 do {									\
 	wait_queue_t __wait;						\
@@ -873,22 +966,8 @@
 #define next_thread(p) \
 	list_entry((p)->thread_group.next, struct task_struct, thread_group)
 
-static inline void del_from_runqueue(struct task_struct * p)
-{
-	nr_running--;
-	p->sleep_time = jiffies;
-	list_del(&p->run_list);
-	p->run_list.next = NULL;
-}
-
-static inline int task_on_runqueue(struct task_struct *p)
-{
-	return (p->run_list.next != NULL);
-}
-
 static inline void unhash_process(struct task_struct *p)
 {
-	if (task_on_runqueue(p)) BUG();
 	write_lock_irq(&tasklist_lock);
 	nr_threads--;
 	unhash_pid(p);
diff -X dontdiff -Nur origlinux/include/linux/smp.h mylinux/include/linux/smp.h
--- origlinux/include/linux/smp.h	Fri Jan 11 14:41:40 2002
+++ mylinux/include/linux/smp.h	Fri Jan 11 15:37:41 2002
@@ -77,6 +77,14 @@
 #define cpu_number_map(cpu)			0
 #define smp_call_function(func,info,retry,wait)	({ 0; })
 #define cpu_online_map				1
+static inline void smp_send_reschedule(int cpu) { }
+static inline void smp_send_reschedule_all(void) { }
 
 #endif
+
+/*
+ * Common definitions:
+ */
+#define cpu()					smp_processor_id()
+
 #endif
diff -X dontdiff -Nur origlinux/init/main.c mylinux/init/main.c
--- origlinux/init/main.c	Fri Jan 11 14:41:43 2002
+++ mylinux/init/main.c	Fri Jan 11 14:46:44 2002
@@ -507,18 +507,10 @@
 	/* Get other processors into their bootup holding patterns. */
 	smp_boot_cpus();
 	wait_init_idle = cpu_online_map;
-	clear_bit(current->processor, &wait_init_idle); /* Don't wait on me! */
+	clear_bit(cpu(), &wait_init_idle); /* Don't wait on me! */
 
 	smp_threads_ready=1;
 	smp_commence();
-
-	/* Wait for the other cpus to set up their idle processes */
-	printk("Waiting on wait_init_idle (map = 0x%lx)\n", wait_init_idle);
-	while (wait_init_idle) {
-		cpu_relax();
-		barrier();
-	}
-	printk("All processors have done init_idle\n");
 }
 
 #endif
@@ -534,9 +526,8 @@
 {
 	kernel_thread(init, NULL, CLONE_FS | CLONE_FILES | CLONE_SIGNAL);
 	unlock_kernel();
-	current->need_resched = 1;
- 	cpu_idle();
-} 
+	cpu_idle();
+}
 
 /*
  *	Activate the first processor.
@@ -617,14 +608,23 @@
 	ipc_init();
 #endif
 	check_bugs();
-	printk("POSIX conformance testing by UNIFIX\n");
 
-	/* 
-	 *	We count on the initial thread going ok 
-	 *	Like idlers init is an unlocked kernel thread, which will
-	 *	make syscalls (and thus be locked).
+	/*
+	 *      We count on the initial thread going ok
+	 *      Like idlers init is an unlocked kernel thread, which will
+	 *      make syscalls (and thus be locked).
 	 */
 	smp_init();
+
+	/*
+	 * Finally, we wait for all other CPU's, and initialize this
+	 * thread that will become the idle thread for the boot CPU.
+	 * After this, the scheduler is fully initialized, and we can
+	 * start creating and running new threads.
+	 */
+	init_idle();
+
+	/* Do the rest non-__init'ed, we're now alive */
 	rest_init();
 }
 
@@ -785,12 +785,9 @@
 		int i, pid;
 
 		pid = kernel_thread(do_linuxrc, "/linuxrc", SIGCHLD);
-		if (pid > 0) {
-			while (pid != wait(&i)) {
-				current->policy |= SCHED_YIELD;
-				schedule();
-			}
-		}
+		if (pid > 0)
+			while (pid != wait(&i))
+				yield();
 		if (MAJOR(real_root_dev) != RAMDISK_MAJOR
 		     || MINOR(real_root_dev) != 0) {
 			error = change_root(real_root_dev,"/initrd");
diff -X dontdiff -Nur origlinux/kernel/capability.c mylinux/kernel/capability.c
--- origlinux/kernel/capability.c	Fri Jan 11 14:41:43 2002
+++ mylinux/kernel/capability.c	Fri Jan 11 14:46:44 2002
@@ -8,6 +8,8 @@
 #include <linux/mm.h>
 #include <asm/uaccess.h>
 
+unsigned securebits = SECUREBITS_DEFAULT; /* systemwide security settings */
+
 kernel_cap_t cap_bset = CAP_INIT_EFF_SET;
 
 /* Note: never hold tasklist_lock while spinning for this one */
diff -X dontdiff -Nur origlinux/kernel/exit.c mylinux/kernel/exit.c
--- origlinux/kernel/exit.c	Fri Jan 11 14:41:43 2002
+++ mylinux/kernel/exit.c	Fri Jan 11 14:46:44 2002
@@ -27,49 +27,39 @@
 
 static void release_task(struct task_struct * p)
 {
-	if (p != current) {
+	unsigned long flags;
+
+	if (p == current)
+		BUG();
 #ifdef CONFIG_SMP
-		/*
-		 * Wait to make sure the process isn't on the
-		 * runqueue (active on some other CPU still)
-		 */
-		for (;;) {
-			task_lock(p);
-			if (!task_has_cpu(p))
-				break;
-			task_unlock(p);
-			do {
-				cpu_relax();
-				barrier();
-			} while (task_has_cpu(p));
-		}
-		task_unlock(p);
+	wait_task_inactive(p);
 #endif
-		atomic_dec(&p->user->processes);
-		free_uid(p->user);
-		unhash_process(p);
-
-		release_thread(p);
-		current->cmin_flt += p->min_flt + p->cmin_flt;
-		current->cmaj_flt += p->maj_flt + p->cmaj_flt;
-		current->cnswap += p->nswap + p->cnswap;
-		/*
-		 * Potentially available timeslices are retrieved
-		 * here - this way the parent does not get penalized
-		 * for creating too many processes.
-		 *
-		 * (this cannot be used to artificially 'generate'
-		 * timeslices, because any timeslice recovered here
-		 * was given away by the parent in the first place.)
-		 */
-		current->counter += p->counter;
-		if (current->counter >= MAX_COUNTER)
-			current->counter = MAX_COUNTER;
-		p->pid = 0;
-		free_task_struct(p);
-	} else {
-		printk("task releasing itself\n");
-	}
+	atomic_dec(&p->user->processes);
+	free_uid(p->user);
+	unhash_process(p);
+
+	release_thread(p);
+	current->cmin_flt += p->min_flt + p->cmin_flt;
+	current->cmaj_flt += p->maj_flt + p->cmaj_flt;
+	current->cnswap += p->nswap + p->cnswap;
+	/*
+	 * Potentially available timeslices are retrieved
+	 * here - this way the parent does not get penalized
+	 * for creating too many processes.
+	 *
+	 * (this cannot be used to artificially 'generate'
+	 * timeslices, because any timeslice recovered here
+	 * was given away by the parent in the first place.)
+	 */
+	__save_flags(flags);
+	__cli();
+	current->time_slice += p->time_slice;
+	if (current->time_slice > MAX_TIMESLICE)
+		current->time_slice = MAX_TIMESLICE;
+	__restore_flags(flags);
+
+	p->pid = 0;
+	free_task_struct(p);
 }
 
 /*
@@ -147,6 +137,79 @@
 	}
 	read_unlock(&tasklist_lock);
 	return retval;
+}
+
+/**
+ * reparent_to_init() - Reparent the calling kernel thread to the init task.
+ *
+ * If a kernel thread is launched as a result of a system call, or if
+ * it ever exits, it should generally reparent itself to init so that
+ * it is correctly cleaned up on exit.
+ *
+ * The various task state such as scheduling policy and priority may have
+ * been inherited from a user process, so we reset them to sane values here.
+ *
+ * NOTE that reparent_to_init() gives the caller full capabilities.
+ */
+void reparent_to_init(void)
+{
+	write_lock_irq(&tasklist_lock);
+
+	/* Reparent to init */
+	REMOVE_LINKS(current);
+	current->p_pptr = child_reaper;
+	current->p_opptr = child_reaper;
+	SET_LINKS(current);
+
+	/* Set the exit signal to SIGCHLD so we signal init on exit */
+	current->exit_signal = SIGCHLD;
+
+	current->ptrace = 0;
+	if ((current->policy == SCHED_OTHER) && (current->__nice < DEF_USER_NICE))
+		set_user_nice(current, DEF_USER_NICE);
+	/* cpus_allowed? */
+	/* rt_priority? */
+	/* signals? */
+	current->cap_effective = CAP_INIT_EFF_SET;
+	current->cap_inheritable = CAP_INIT_INH_SET;
+	current->cap_permitted = CAP_FULL_SET;
+	current->keep_capabilities = 0;
+	memcpy(current->rlim, init_task.rlim, sizeof(*(current->rlim)));
+	current->user = INIT_USER;
+
+	write_unlock_irq(&tasklist_lock);
+}
+
+/*
+ *	Put all the gunge required to become a kernel thread without
+ *	attached user resources in one place where it belongs.
+ */
+
+void daemonize(void)
+{
+	struct fs_struct *fs;
+
+
+	/*
+	 * If we were started as result of loading a module, close all of the
+	 * user space pages.  We don't need them, and if we didn't close them
+	 * they would be locked into memory.
+	 */
+	exit_mm(current);
+
+	current->session = 1;
+	current->pgrp = 1;
+	current->tty = NULL;
+
+	/* Become as one with the init task */
+
+	exit_fs(current);	/* current->fs->count--; */
+	fs = init_task.fs;
+	current->fs = fs;
+	atomic_inc(&fs->count);
+ 	exit_files(current);
+	current->files = init_task.files;
+	atomic_inc(&current->files->count);
 }
 
 /*
diff -X dontdiff -Nur origlinux/kernel/fork.c mylinux/kernel/fork.c
--- origlinux/kernel/fork.c	Fri Jan 11 14:41:43 2002
+++ mylinux/kernel/fork.c	Fri Jan 11 14:46:44 2002
@@ -28,7 +28,6 @@
 
 /* The idle threads do not count.. */
 int nr_threads;
-int nr_running;
 
 int max_threads;
 unsigned long total_forks;	/* Handle normal Linux uptimes. */
@@ -36,6 +35,8 @@
 
 struct task_struct *pidhash[PIDHASH_SZ];
 
+rwlock_t tasklist_lock __cacheline_aligned = RW_LOCK_UNLOCKED;  /* outer */
+
 void add_wait_queue(wait_queue_head_t *q, wait_queue_t * wait)
 {
 	unsigned long flags;
@@ -563,6 +564,7 @@
 	    struct pt_regs *regs, unsigned long stack_size)
 {
 	int retval;
+	unsigned long flags;
 	struct task_struct *p;
 	struct completion vfork;
 
@@ -611,8 +613,7 @@
 	copy_flags(clone_flags, p);
 	p->pid = get_pid(clone_flags);
 
-	p->run_list.next = NULL;
-	p->run_list.prev = NULL;
+	INIT_LIST_HEAD(&p->run_list);
 
 	p->p_cptr = NULL;
 	init_waitqueue_head(&p->wait_chldexit);
@@ -638,14 +639,16 @@
 #ifdef CONFIG_SMP
 	{
 		int i;
-		p->cpus_runnable = ~0UL;
-		p->processor = current->processor;
+
+		p->cpu = cpu();
+
 		/* ?? should we just memset this ?? */
 		for(i = 0; i < smp_num_cpus; i++)
 			p->per_cpu_utime[i] = p->per_cpu_stime[i] = 0;
 		spin_lock_init(&p->sigmask_lock);
 	}
 #endif
+	p->array = NULL;
 	p->lock_depth = -1;		/* -1 = no lock */
 	p->start_time = jiffies;
 
@@ -677,15 +680,28 @@
 	p->pdeath_signal = 0;
 
 	/*
-	 * "share" dynamic priority between parent and child, thus the
-	 * total amount of dynamic priorities in the system doesnt change,
-	 * more scheduling fairness. This is only important in the first
-	 * timeslice, on the long run the scheduling behaviour is unchanged.
+	 * Share the timeslice between parent and child, thus the
+	 * total amount of pending timeslices in the system doesnt change,
+	 * resulting in more scheduling fairness.
 	 */
-	p->counter = (current->counter + 1) >> 1;
-	current->counter >>= 1;
-	if (!current->counter)
-		current->need_resched = 1;
+	__save_flags(flags);
+	__cli();
+	if (!current->time_slice)
+		BUG();
+	p->time_slice = (current->time_slice + 1) >> 1;
+	current->time_slice >>= 1;
+	if (!current->time_slice) {
+		/*
+		 * This case is rare, it happens when the parent has only
+		 * a single jiffy left from its timeslice. Taking the
+		 * runqueue lock is not a problem.
+		 */
+		current->time_slice = 1;
+		scheduler_tick(current);
+	}
+        p->sleep_timestamp = p->run_timestamp = jiffies;
+	p->hist[0] = p->hist[1] = p->hist[2] = p->hist[3] = 0;
+	__restore_flags(flags);
 
 	/*
 	 * Ok, add it to the run-queues and make it
@@ -722,10 +738,23 @@
 	if (p->ptrace & PT_PTRACED)
 		send_sig(SIGSTOP, p, 1);
 
+#define RUN_CHILD_FIRST 1
+#if RUN_CHILD_FIRST
+	wake_up_forked_process(p);	/* do this last */
+#else
 	wake_up_process(p);		/* do this last */
+#endif
 	++total_forks;
 	if (clone_flags & CLONE_VFORK)
 		wait_for_completion(&vfork);
+#if RUN_CHILD_FIRST
+	else
+		/*
+		 * Let the child process run first, to avoid most of the
+		 * COW overhead when the child exec()s afterwards.
+		 */
+		current->need_resched = 1;
+#endif
 
 fork_out:
 	return retval;
diff -X dontdiff -Nur origlinux/kernel/ksyms.c mylinux/kernel/ksyms.c
--- origlinux/kernel/ksyms.c	Fri Jan 11 14:41:43 2002
+++ mylinux/kernel/ksyms.c	Fri Jan 11 14:46:44 2002
@@ -437,6 +437,9 @@
 EXPORT_SYMBOL(interruptible_sleep_on_timeout);
 EXPORT_SYMBOL(schedule);
 EXPORT_SYMBOL(schedule_timeout);
+EXPORT_SYMBOL(sys_sched_yield);
+EXPORT_SYMBOL(set_user_nice);
+EXPORT_SYMBOL(set_cpus_allowed);
 EXPORT_SYMBOL(jiffies);
 EXPORT_SYMBOL(xtime);
 EXPORT_SYMBOL(do_gettimeofday);
@@ -448,6 +451,7 @@
 
 EXPORT_SYMBOL(kstat);
 EXPORT_SYMBOL(nr_running);
+EXPORT_SYMBOL(nr_context_switches);
 
 /* misc */
 EXPORT_SYMBOL(panic);
diff -X dontdiff -Nur origlinux/kernel/printk.c mylinux/kernel/printk.c
--- origlinux/kernel/printk.c	Fri Jan 11 14:41:43 2002
+++ mylinux/kernel/printk.c	Fri Jan 11 14:49:33 2002
@@ -25,6 +25,7 @@
 #include <linux/init.h>
 #include <linux/module.h>
 #include <linux/interrupt.h>			/* For in_interrupt() */
+#include <linux/delay.h>
 
 #include <asm/uaccess.h>
 
diff -X dontdiff -Nur origlinux/kernel/ptrace.c mylinux/kernel/ptrace.c
--- origlinux/kernel/ptrace.c	Fri Jan 11 14:41:43 2002
+++ mylinux/kernel/ptrace.c	Fri Jan 11 14:46:44 2002
@@ -31,20 +31,7 @@
 		if (child->state != TASK_STOPPED)
 			return -ESRCH;
 #ifdef CONFIG_SMP
-		/* Make sure the child gets off its CPU.. */
-		for (;;) {
-			task_lock(child);
-			if (!task_has_cpu(child))
-				break;
-			task_unlock(child);
-			do {
-				if (child->state != TASK_STOPPED)
-					return -ESRCH;
-				barrier();
-				cpu_relax();
-			} while (task_has_cpu(child));
-		}
-		task_unlock(child);
+		wait_task_inactive(child);
 #endif		
 	}
 
diff -X dontdiff -Nur origlinux/kernel/sched.c mylinux/kernel/sched.c
--- origlinux/kernel/sched.c	Fri Jan 11 14:41:43 2002
+++ mylinux/kernel/sched.c	Fri Jan 11 15:36:13 2002
@@ -12,333 +12,328 @@
  *  1998-12-28  Implemented better SMP scheduling by Ingo Molnar
  */
 
-/*
- * 'sched.c' is the main kernel file. It contains scheduling primitives
- * (sleep_on, wakeup, schedule etc) as well as a number of simple system
- * call functions (type getpid()), which just extract a field from
- * current-task
- */
-
-#include <linux/config.h>
 #include <linux/mm.h>
+#include <linux/nmi.h>
 #include <linux/init.h>
+#include <asm/uaccess.h>
 #include <linux/smp_lock.h>
-#include <linux/nmi.h>
 #include <linux/interrupt.h>
-#include <linux/kernel_stat.h>
-#include <linux/completion.h>
-#include <linux/prefetch.h>
-#include <linux/compiler.h>
-
-#include <asm/uaccess.h>
 #include <asm/mmu_context.h>
 
-extern void timer_bh(void);
-extern void tqueue_bh(void);
-extern void immediate_bh(void);
+struct runqueue runqueues[NR_CPUS] __cacheline_aligned;
+
+#define cpu_rq(cpu)		(runqueues + (cpu))
+#define this_rq()		cpu_rq(smp_processor_id())
+#define task_rq(p)		cpu_rq((p)->cpu)
+#define cpu_curr(cpu)		(cpu_rq(cpu)->curr)
+#define rq_cpu(rq)		((rq) - runqueues)
+#define rt_task(p)		((p)->policy != SCHED_OTHER)
+
+
+#define lock_task_rq(rq,p,flags)				\
+do {								\
+repeat_lock_task:						\
+	rq = task_rq(p);					\
+	spin_lock_irqsave(&rq->lock, flags);			\
+	if (unlikely(rq_cpu(rq) != (p)->cpu)) {			\
+		spin_unlock_irqrestore(&rq->lock, flags);	\
+		goto repeat_lock_task;				\
+	}							\
+} while (0)
+
+#define unlock_task_rq(rq,p,flags)				\
+	spin_unlock_irqrestore(&rq->lock, flags)
 
 /*
- * scheduler variables
+ * Adding/removing a task to/from a priority array:
  */
+static inline void dequeue_task(struct task_struct *p, prio_array_t *array)
+{
+	array->nr_active--;
+	list_del_init(&p->run_list);
+	if (list_empty(array->queue + p->prio))
+		__set_bit(p->prio, array->bitmap);
+}
 
-unsigned securebits = SECUREBITS_DEFAULT; /* systemwide security settings */
-
-extern void mem_use(void);
+static inline void enqueue_task(struct task_struct *p, prio_array_t *array)
+{
+	list_add_tail(&p->run_list, array->queue + p->prio);
+	__clear_bit(p->prio, array->bitmap);
+	array->nr_active++;
+	p->array = array;
+}
 
 /*
- * Scheduling quanta.
+ * This is the per-process load estimator. Processes that generate
+ * more load than the system can handle get a priority penalty.
  *
- * NOTE! The unix "nice" value influences how long a process
- * gets. The nice value ranges from -20 to +19, where a -20
- * is a "high-priority" task, and a "+10" is a low-priority
- * task.
+ * The estimator uses a 4-entry load-history ringbuffer which is
+ * updated whenever a task is moved to/from the runqueue. The load
+ * estimate is also updated from the timer tick to get an accurate
+ * estimation of currently executing tasks as well.
  *
- * We want the time-slice to be around 50ms or so, so this
- * calculation depends on the value of HZ.
+ * The 4-entry p->hist[4] array holds the 'sleep history' of
+ * every task. Every entry holds the number of time ticks spent
+ * sleeping in the past 4 seconds. Three of the entries belong to
+ * one-one second in the past, the fourth entry belongs to the current
+ * second. (the p->hist_idx index is used in fact as a rotating index
+ * to reduce overhead.)
+ *
+ * The array elements are integers in the range of 0-HZ. If HZ is 100,
+ * then '100' means a process has spent 100% of it's time sleeping, in
+ * that particular second of time. '0' means the process has spent all
+ * its time on the runqueue - ie. it was a CPU hog in that second.
+ *
+ * For RAM usage and algorithmic overhead reasons we do not want a too
+ * big history buffer. It's also usually not interesting to the scheduler
+ * to know whether a task was idle or not 10 minutes ago. 'Recent behavior'
+ * is what matters, if a task was mostly sleeping recently then it's a
+ * 'good' interactive task. If it has spent most (or all) of its time
+ * running then it's a 'bad' CPU-hog that gets a priority penalty.
+ *
+ * The load estimator itself was written to be fast as well in every
+ * circumstance. Eg. if a task is context switching heavily then we do
+ * not call into the estimator, only about once per timer tick, on average.
  */
-#if HZ < 200
-#define TICK_SCALE(x)	((x) >> 2)
-#elif HZ < 400
-#define TICK_SCALE(x)	((x) >> 1)
-#elif HZ < 800
-#define TICK_SCALE(x)	(x)
-#elif HZ < 1600
-#define TICK_SCALE(x)	((x) << 1)
-#else
-#define TICK_SCALE(x)	((x) << 2)
-#endif
-
-#define NICE_TO_TICKS(nice)	(TICK_SCALE(20-(nice))+1)
-
 
 /*
- *	Init task must be ok at boot for the ix86 as we will check its signals
- *	via the SMP irq return path.
+ * The 'history index' goes forward in time, if one second passes then
+ * the index is increased by 1 via this function. We wrap around the
+ * index if it reaches 4. (The modulo is fast with the current
+ * SLEEP_HIST_SIZE of 4.)
  */
- 
-struct task_struct * init_tasks[NR_CPUS] = {&init_task, };
+static inline void new_second(task_t *p)
+{
+	p->hist_idx = (p->hist_idx + 1) % SLEEP_HIST_SIZE;
+}
 
 /*
- * The tasklist_lock protects the linked list of processes.
- *
- * The runqueue_lock locks the parts that actually access
- * and change the run-queues, and have to be interrupt-safe.
- *
- * If both locks are to be concurrently held, the runqueue_lock
- * nests inside the tasklist_lock.
- *
- * task->alloc_lock nests inside tasklist_lock.
+ * process load-history tick length. Right now it's 1 second:
  */
-spinlock_t runqueue_lock __cacheline_aligned = SPIN_LOCK_UNLOCKED;  /* inner */
-rwlock_t tasklist_lock __cacheline_aligned = RW_LOCK_UNLOCKED;	/* outer */
-
-static LIST_HEAD(runqueue_head);
+#define HHZ (HZ)
 
 /*
- * We align per-CPU scheduling data on cacheline boundaries,
- * to prevent cacheline ping-pong.
+ * This function clears the load-history entries when a task has spent
+ * more than 4 seconds running.
  */
-static union {
-	struct schedule_data {
-		struct task_struct * curr;
-		cycles_t last_schedule;
-	} schedule_data;
-	char __pad [SMP_CACHE_BYTES];
-} aligned_data [NR_CPUS] __cacheline_aligned = { {{&init_task,0}}};
-
-#define cpu_curr(cpu) aligned_data[(cpu)].schedule_data.curr
-#define last_schedule(cpu) aligned_data[(cpu)].schedule_data.last_schedule
-
-struct kernel_stat kstat;
-extern struct task_struct *child_reaper;
-
-#ifdef CONFIG_SMP
-
-#define idle_task(cpu) (init_tasks[cpu_number_map(cpu)])
-#define can_schedule(p,cpu) \
-	((p)->cpus_runnable & (p)->cpus_allowed & (1 << cpu))
-
-#else
-
-#define idle_task(cpu) (&init_task)
-#define can_schedule(p,cpu) (1)
-
-#endif
-
-void scheduling_functions_start_here(void) { }
+static inline void clear_hist(task_t *p)
+{
+	p->hist[0] = p->hist[1] = p->hist[2] = p->hist[3] = 0;
+}
 
 /*
- * This is the function that decides how desirable a process is..
- * You can weigh different processes against each other depending
- * on what CPU they've run on lately etc to try to handle cache
- * and TLB miss penalties.
- *
- * Return values:
- *	 -1000: never select this
- *	     0: out of time, recalculate counters (but it might still be
- *		selected)
- *	   +ve: "goodness" value (the larger, the better)
- *	 +1000: realtime process, select this.
+ * This function fills in the load-history entries with the maximum
+ * values when a task has spent more than 4 seconds sleeping.
  */
+static inline void fill_hist(task_t *p)
+{
+	p->hist[0] = p->hist[1] = p->hist[2] = p->hist[3] = HHZ;
+}
 
-static inline int goodness(struct task_struct * p, int this_cpu, struct mm_struct *this_mm)
+/*
+ * This function is called when a task goes sleeping, ie. when the task
+ * has potentially spent alot of time on the runqueue. p->run_timestamp
+ * is the time the task has started running, 'now' is the time when the
+ * task goes to sleep.
+ */
+static inline void update_sleep_avg_deactivate(task_t *p)
 {
-	int weight;
+	int idx;
+	unsigned long now = jiffies,
+			seconds_passed = now/HHZ - p->run_timestamp/HHZ;
 
 	/*
-	 * select the current process after every other
-	 * runnable process, but before the idle thread.
-	 * Also, dont trigger a counter recalculation.
+	 * Do we have to update the history entries becase a
+	 * 'new second' has been started? If a new second has
+	 * been started then we have to clear all the 'full'
+	 * seconds that have been passed during the time the
+	 * task was running, and the new current entry has
+	 * to be cleared as well.
+	 *
+	 * Otherwise we only have to update the sleep timestamp.
 	 */
-	weight = -1;
-	if (p->policy & SCHED_YIELD)
-		goto out;
+	if (unlikely(seconds_passed)) {
+		if (seconds_passed < SLEEP_HIST_SIZE)
+			for (idx = 0; idx < seconds_passed; idx++) {
+				new_second(p);
+				p->hist[p->hist_idx] = 0;
+			}
+		else
+			clear_hist(p);
+	}
+	p->sleep_timestamp = now;
+}
 
-	/*
-	 * Non-RT process - normal case first.
+/*
+ * This is called when a task gets runnable and gets moved to the runqueue.
+ * ie. when the task has potentially spent alot of time sleeping.
+ * p->sleep_timestamp is the time the task has started sleeping, 'now' is
+ * the time when we go to the runqueue.
+ */
+static inline void update_sleep_avg_activate(task_t *p, unsigned long now)
+{
+	int idx;
+	unsigned long sleep_ticks,
+			seconds_passed = now/HHZ - p->sleep_timestamp/HHZ;
+
+	/*
+	 * Do we have to update the history entries becase a
+	 * 'new second' has been started? This is slightly more
+	 * complex than the deactivate path, because in the deactivate
+	 * path history entries are simply cleared, but here we have
+	 * to add any potential time spent sleeping in the current
+	 * second. This value is 'sleep_ticks' - it can be anywhere
+	 * between 0 and HZ-1. (it cannot be HZ because that would mean
+	 * that the current second is over and we'd have to go to the
+	 * next history entry.) Another detail is that we might
+	 * have gone sleeping in this second, or in any previous second.
+	 *
+	 * Otherwise we only have to update the run timestamp and the
+	 * current history entry.
 	 */
-	if (p->policy == SCHED_OTHER) {
-		/*
-		 * Give the process a first-approximation goodness value
-		 * according to the number of clock-ticks it has left.
-		 *
-		 * Don't do any other calculations if the time slice is
-		 * over..
-		 */
-		weight = p->counter;
-		if (!weight)
-			goto out;
-			
-#ifdef CONFIG_SMP
-		/* Give a largish advantage to the same processor...   */
-		/* (this is equivalent to penalizing other processors) */
-		if (p->processor == this_cpu)
-			weight += PROC_CHANGE_PENALTY;
-#endif
+	if (unlikely(seconds_passed)) {
+		if (seconds_passed < SLEEP_HIST_SIZE) {
+			/*
+			 * Update the "last partially-slept" second's entry:
+			 */
+			p->hist[p->hist_idx] += HHZ - (p->sleep_timestamp % HHZ);
+			new_second(p);
 
-		/* .. and a slight advantage to the current MM */
-		if (p->mm == this_mm || !p->mm)
-			weight += 1;
-		weight += 20 - p->nice;
-		goto out;
-	}
+			/*
+			 * Clear any (optional) interim seconds that were
+			 * spent fully sleeping:
+			 */
+			for (idx = 1; idx < seconds_passed; idx++) {
+				new_second(p);
+				p->hist[p->hist_idx] = HHZ;
+			}
+		} else
+			/*
+			 * We slept more than 4 seconds, fill in the
+			 * history:
+			 */
+			fill_hist(p);
 
+		/* Clear the new current entry: */
+		p->hist[p->hist_idx] = 0;
+		sleep_ticks = now % HHZ;
+	} else
+		sleep_ticks = now - p->sleep_timestamp;
 	/*
-	 * Realtime process, select the first one on the
-	 * runqueue (taking priorities within processes
-	 * into account).
+	 * Update the current entry with the amount of
+	 * ticks the task spent sleeping:
 	 */
-	weight = 1000 + p->rt_priority;
-out:
-	return weight;
+	p->hist[p->hist_idx] += sleep_ticks;
+	p->run_timestamp = now;
 }
 
 /*
- * the 'goodness value' of replacing a process on a given CPU.
- * positive value means 'replace', zero or negative means 'dont'.
+ * Get the current 'load average' of the task.
+ *
+ * Naively one would divide the sum by 4. But in fact the current entry
+ * is just a partial history, so we have to divide by the actual portion
+ * we recorded, which is somewhere between 3.0 and 4.0 seconds.
  */
-static inline int preemption_goodness(struct task_struct * prev, struct task_struct * p, int cpu)
+static inline unsigned int get_run_avg(task_t *p, unsigned long new)
 {
-	return goodness(p, cpu, prev->active_mm) - goodness(prev, cpu, prev->active_mm);
+	return HHZ - (p->hist[0] + p->hist[1] + p->hist[2] +
+		p->hist[3]) * HHZ / ((SLEEP_HIST_SIZE-1)*HHZ + (new % HHZ));
 }
 
-/*
- * This is ugly, but reschedule_idle() is very timing-critical.
- * We are called with the runqueue spinlock held and we must
- * not claim the tasklist_lock.
- */
-static FASTCALL(void reschedule_idle(struct task_struct * p));
-
-static void reschedule_idle(struct task_struct * p)
+static inline void activate_task(task_t *p, runqueue_t *rq)
 {
-#ifdef CONFIG_SMP
-	int this_cpu = smp_processor_id();
-	struct task_struct *tsk, *target_tsk;
-	int cpu, best_cpu, i, max_prio;
-	cycles_t oldest_idle;
+	prio_array_t *array = rq->active;
+	unsigned long now = jiffies;
+	unsigned int penalty;
 
-	/*
-	 * shortcut if the woken up task's last CPU is
-	 * idle now.
-	 */
-	best_cpu = p->processor;
-	if (can_schedule(p, best_cpu)) {
-		tsk = idle_task(best_cpu);
-		if (cpu_curr(best_cpu) == tsk) {
-			int need_resched;
-send_now_idle:
-			/*
-			 * If need_resched == -1 then we can skip sending
-			 * the IPI altogether, tsk->need_resched is
-			 * actively watched by the idle thread.
-			 */
-			need_resched = tsk->need_resched;
-			tsk->need_resched = 1;
-			if ((best_cpu != this_cpu) && !need_resched)
-				smp_send_reschedule(best_cpu);
-			return;
-		}
-	}
+	if (likely(p->run_timestamp == now))
+		goto enqueue;
+	update_sleep_avg_activate(p, now);
 
 	/*
-	 * We know that the preferred CPU has a cache-affine current
-	 * process, lets try to find a new idle CPU for the woken-up
-	 * process. Select the least recently active idle CPU. (that
-	 * one will have the least active cache context.) Also find
-	 * the executing process which has the least priority.
-	 */
-	oldest_idle = (cycles_t) -1;
-	target_tsk = NULL;
-	max_prio = 0;
+	 * Give the process a priority penalty if it has not slept often
+	 * enough in the past. We scale the priority penalty according
+	 * to the current load of the runqueue, and the 'load history'
+	 * this process has. Eg. if the CPU has 3 processes running
+	 * right now then a process that has slept more than two-thirds
+	 * of the time is considered to be 'interactive'. The higher
+	 * the load of the CPUs is, the easier it is for a process to
+	 * get an non-interactivity penalty.
+	 *
+	 * the return value of get_run_avg() is an integer between 0 and HZ.
+	 * We scale this 'load value' to between 0 and MAX_USER_PRIO/3.
+	 * A task that generates 100% load gets the maximum penalty.
+	 */
+	penalty = MAX_USER_PRIO * get_run_avg(p, now) / (3 * HHZ);
+	if (!rt_task(p)) {
+		p->prio = NICE_TO_PRIO(p->__nice) + penalty;
+		if (p->prio > MAX_PRIO-1)
+			p->prio = MAX_PRIO-1;
+	}
+enqueue:
+	enqueue_task(p, array);
+	rq->nr_running++;
+}
 
-	for (i = 0; i < smp_num_cpus; i++) {
-		cpu = cpu_logical_map(i);
-		if (!can_schedule(p, cpu))
-			continue;
-		tsk = cpu_curr(cpu);
-		/*
-		 * We use the first available idle CPU. This creates
-		 * a priority list between idle CPUs, but this is not
-		 * a problem.
-		 */
-		if (tsk == idle_task(cpu)) {
-#if defined(__i386__) && defined(CONFIG_SMP)
-                        /*
-			 * Check if two siblings are idle in the same
-			 * physical package. Use them if found.
-			 */
-			if (smp_num_siblings == 2) {
-				if (cpu_curr(cpu_sibling_map[cpu]) == 
-			            idle_task(cpu_sibling_map[cpu])) {
-					oldest_idle = last_schedule(cpu);
-					target_tsk = tsk;
-					break;
-				}
-				
-                        }
-#endif		
-			if (last_schedule(cpu) < oldest_idle) {
-				oldest_idle = last_schedule(cpu);
-				target_tsk = tsk;
-			}
-		} else {
-			if (oldest_idle == -1ULL) {
-				int prio = preemption_goodness(tsk, p, cpu);
+static inline void deactivate_task(struct task_struct *p, runqueue_t *rq)
+{
+	rq->nr_running--;
+	dequeue_task(p, p->array);
+	p->array = NULL;
+	update_sleep_avg_deactivate(p);
+}
 
-				if (prio > max_prio) {
-					max_prio = prio;
-					target_tsk = tsk;
-				}
-			}
-		}
-	}
-	tsk = target_tsk;
-	if (tsk) {
-		if (oldest_idle != -1ULL) {
-			best_cpu = tsk->processor;
-			goto send_now_idle;
-		}
-		tsk->need_resched = 1;
-		if (tsk->processor != this_cpu)
-			smp_send_reschedule(tsk->processor);
-	}
-	return;
-		
+static inline void resched_task(task_t *p)
+{
+	int need_resched;
 
-#else /* UP */
-	int this_cpu = smp_processor_id();
-	struct task_struct *tsk;
-
-	tsk = cpu_curr(this_cpu);
-	if (preemption_goodness(tsk, p, this_cpu) > 0)
-		tsk->need_resched = 1;
-#endif
+	need_resched = p->need_resched;
+	wmb();
+	p->need_resched = 1;
+	if (!need_resched && (p->cpu != smp_processor_id()))
+		smp_send_reschedule(p->cpu);
 }
 
+#ifdef CONFIG_SMP
+
 /*
- * Careful!
- *
- * This has to add the process to the _beginning_ of the
- * run-queue, not the end. See the comment about "This is
- * subtle" in the scheduler proper..
+ * Wait for a process to unschedule. This is used by the exit() and
+ * ptrace() code.
  */
-static inline void add_to_runqueue(struct task_struct * p)
+void wait_task_inactive(task_t * p)
 {
-	list_add(&p->run_list, &runqueue_head);
-	nr_running++;
-}
+	unsigned long flags;
+	runqueue_t *rq;
 
-static inline void move_last_runqueue(struct task_struct * p)
-{
-	list_del(&p->run_list);
-	list_add_tail(&p->run_list, &runqueue_head);
+repeat:
+	rq = task_rq(p);
+	while (unlikely(rq->curr == p)) {
+		cpu_relax();
+		barrier();
+	}
+	lock_task_rq(rq, p, flags);
+	if (unlikely(rq->curr == p)) {
+		unlock_task_rq(rq, p, flags);
+		goto repeat;
+	}
+	unlock_task_rq(rq, p, flags);
 }
 
-static inline void move_first_runqueue(struct task_struct * p)
+/*
+ * Kick the remote CPU if the task is running currently,
+ * this code is used by the signal code to signal tasks
+ * which are in user-mode as quickly as possible.
+ *
+ * (Note that we do this lockless - if the task does anything
+ * while the message is in flight then it will notice the
+ * sigpending condition anyway.)
+ */
+void kick_if_running(task_t * p)
 {
-	list_del(&p->run_list);
-	list_add(&p->run_list, &runqueue_head);
+	if (p == task_rq(p)->curr)
+		resched_task(p);
 }
+#endif
 
 /*
  * Wake up a process. Put it on the run-queue if it's not
@@ -348,392 +343,470 @@
  * "current->state = TASK_RUNNING" to mark yourself runnable
  * without the overhead of this.
  */
-static inline int try_to_wake_up(struct task_struct * p, int synchronous)
+static int try_to_wake_up(task_t * p, int synchronous)
 {
 	unsigned long flags;
 	int success = 0;
+	runqueue_t *rq;
 
-	/*
-	 * We want the common case fall through straight, thus the goto.
-	 */
-	spin_lock_irqsave(&runqueue_lock, flags);
+	lock_task_rq(rq, p, flags);
 	p->state = TASK_RUNNING;
-	if (task_on_runqueue(p))
-		goto out;
-	add_to_runqueue(p);
-	if (!synchronous || !(p->cpus_allowed & (1 << smp_processor_id())))
-		reschedule_idle(p);
-	success = 1;
-out:
-	spin_unlock_irqrestore(&runqueue_lock, flags);
+	if (!p->array) {
+		activate_task(p, rq);
+		if ((rq->curr == rq->idle) || (p->prio < rq->curr->prio))
+			resched_task(rq->curr);
+		success = 1;
+	}
+	unlock_task_rq(rq, p, flags);
 	return success;
 }
 
-inline int wake_up_process(struct task_struct * p)
+inline int wake_up_process(task_t * p)
 {
 	return try_to_wake_up(p, 0);
 }
 
-static void process_timeout(unsigned long __data)
+void wake_up_forked_process(task_t * p)
 {
-	struct task_struct * p = (struct task_struct *) __data;
+	runqueue_t *rq = this_rq();
 
-	wake_up_process(p);
+	spin_lock_irq(&rq->lock);
+	p->state = TASK_RUNNING;
+	if (!rt_task(p)) {
+		p->prio += MAX_USER_PRIO/10;
+		if (p->prio > MAX_PRIO-1)
+			p->prio = MAX_PRIO-1;
+	}
+	activate_task(p, rq);
+	spin_unlock_irq(&rq->lock);
 }
 
-/**
- * schedule_timeout - sleep until timeout
- * @timeout: timeout value in jiffies
- *
- * Make the current task sleep until @timeout jiffies have
- * elapsed. The routine will return immediately unless
- * the current task state has been set (see set_current_state()).
- *
- * You can set the task state as follows -
- *
- * %TASK_UNINTERRUPTIBLE - at least @timeout jiffies are guaranteed to
- * pass before the routine returns. The routine will return 0
- *
- * %TASK_INTERRUPTIBLE - the routine may return early if a signal is
- * delivered to the current task. In this case the remaining time
- * in jiffies will be returned, or 0 if the timer expired in time
- *
- * The current task state is guaranteed to be TASK_RUNNING when this 
- * routine returns.
- *
- * Specifying a @timeout value of %MAX_SCHEDULE_TIMEOUT will schedule
- * the CPU away without a bound on the timeout. In this case the return
- * value will be %MAX_SCHEDULE_TIMEOUT.
- *
- * In all cases the return value is guaranteed to be non-negative.
- */
-signed long schedule_timeout(signed long timeout)
+asmlinkage void schedule_tail(task_t *prev)
 {
-	struct timer_list timer;
-	unsigned long expire;
+	spin_unlock_irq(&this_rq()->lock);
+}
 
-	switch (timeout)
-	{
-	case MAX_SCHEDULE_TIMEOUT:
-		/*
-		 * These two special cases are useful to be comfortable
-		 * in the caller. Nothing more. We could take
-		 * MAX_SCHEDULE_TIMEOUT from one of the negative value
-		 * but I' d like to return a valid offset (>=0) to allow
-		 * the caller to do everything it want with the retval.
-		 */
-		schedule();
-		goto out;
-	default:
-		/*
-		 * Another bit of PARANOID. Note that the retval will be
-		 * 0 since no piece of kernel is supposed to do a check
-		 * for a negative retval of schedule_timeout() (since it
-		 * should never happens anyway). You just have the printk()
-		 * that will tell you if something is gone wrong and where.
-		 */
-		if (timeout < 0)
-		{
-			printk(KERN_ERR "schedule_timeout: wrong timeout "
-			       "value %lx from %p\n", timeout,
-			       __builtin_return_address(0));
-			current->state = TASK_RUNNING;
-			goto out;
-		}
+static inline void context_switch(task_t *prev, task_t *next)
+{
+	struct mm_struct *mm = next->mm;
+	struct mm_struct *oldmm = prev->active_mm;
+
+	prepare_to_switch();
+
+	if (!mm) {
+		next->active_mm = oldmm;
+		atomic_inc(&oldmm->mm_count);
+		enter_lazy_tlb(oldmm, next, smp_processor_id());
+	} else
+		switch_mm(oldmm, mm, next, smp_processor_id());
+
+	if (!prev->mm) {
+		prev->active_mm = NULL;
+		mmdrop(oldmm);
 	}
 
-	expire = timeout + jiffies;
+	/*
+	 * Here we just switch the register state and the stack. There are
+	 * 3 processes affected by a context switch:
+	 *
+	 * prev ==> .... ==> (last => next)
+	 *
+	 * It's the 'much more previous' 'prev' that is on next's stack,
+	 * but prev is set to (the just run) 'last' process by switch_to().
+	 * This might sound slightly confusing but makes tons of sense.
+	 */
+	switch_to(prev, next, prev);
+}
+
+unsigned long nr_running(void)
+{
+	unsigned long i, sum = 0;
 
-	init_timer(&timer);
-	timer.expires = expire;
-	timer.data = (unsigned long) current;
-	timer.function = process_timeout;
+	for (i = 0; i < smp_num_cpus; i++)
+		sum += cpu_rq(i)->nr_running;
 
-	add_timer(&timer);
-	schedule();
-	del_timer_sync(&timer);
+	return sum;
+}
+
+unsigned long nr_context_switches(void)
+{
+	unsigned long i, sum = 0;
+
+	for (i = 0; i < smp_num_cpus; i++)
+		sum += cpu_rq(i)->nr_switches;
+
+	return sum;
+}
 
-	timeout = expire - jiffies;
+static inline unsigned long max_rq_len(void)
+{
+	unsigned long i, curr, max = 0;
 
- out:
-	return timeout < 0 ? 0 : timeout;
+	for (i = 0; i < smp_num_cpus; i++) {
+		curr = cpu_rq(i)->nr_running;
+		if (curr > max)
+			max = curr;
+	}
+	return max;
 }
 
 /*
- * schedule_tail() is getting called from the fork return path. This
- * cleans up all remaining scheduler things, without impacting the
- * common case.
+ * Current runqueue is empty, or rebalance tick: if there is an
+ * inbalance (current runqueue is too short) then pull from
+ * busiest runqueue(s).
+ *
+ * We call this with the current runqueue locked,
+ * irqs disabled.
  */
-static inline void __schedule_tail(struct task_struct *prev)
+static void load_balance(runqueue_t *this_rq, int idle)
 {
-#ifdef CONFIG_SMP
-	int policy;
+	int imbalance, nr_running, load, prev_max_load,
+		max_load, idx, i, this_cpu = smp_processor_id();
+	task_t *next = this_rq->idle, *tmp;
+	runqueue_t *busiest, *rq_src;
+	prio_array_t *array;
+	list_t *head, *curr;
 
 	/*
-	 * prev->policy can be written from here only before `prev'
-	 * can be scheduled (before setting prev->cpus_runnable to ~0UL).
-	 * Of course it must also be read before allowing prev
-	 * to be rescheduled, but since the write depends on the read
-	 * to complete, wmb() is enough. (the spin_lock() acquired
-	 * before setting cpus_runnable is not enough because the spin_lock()
-	 * common code semantics allows code outside the critical section
-	 * to enter inside the critical section)
+	 * We search all runqueues to find the most busy one.
+	 * We do this lockless to reduce cache-bouncing overhead,
+	 * we re-check the 'best' source CPU later on again, with
+	 * the lock held.
+	 *
+	 * We fend off statistical fluctuations in runqueue lengths by
+	 * saving the runqueue length during the previous load-balancing
+	 * operation and using the smaller one the current and saved lengths.
+	 * If a runqueue is long enough for a longer amount of time then
+	 * we recognize it and pull tasks from it.
+	 *
+	 * The 'current runqueue length' is a statistical maximum variable,
+	 * for that one we take the longer one - to avoid fluctuations in
+	 * the other direction. So for a load-balance to happen it needs
+	 * stable long runqueue on the target CPU and stable short runqueue
+	 * on the local runqueue.
+	 *
+	 * We make an exception if this CPU is about to become idle - in
+	 * that case we are less picky about moving a task across CPUs and
+	 * take what can be taken.
 	 */
-	policy = prev->policy;
-	prev->policy = policy & ~SCHED_YIELD;
-	wmb();
+	if (idle || (this_rq->nr_running > this_rq->prev_nr_running[this_cpu]))
+		nr_running = this_rq->nr_running;
+	else
+		nr_running = this_rq->prev_nr_running[this_cpu];
+	prev_max_load = 1000000000;
+
+	busiest = NULL;
+	max_load = 0;
+	for (i = 0; i < smp_num_cpus; i++) {
+		rq_src = cpu_rq(i);
+		if (idle || (rq_src->nr_running < this_rq->prev_nr_running[i]))
+			load = rq_src->nr_running;
+		else
+			load = this_rq->prev_nr_running[i];
+		this_rq->prev_nr_running[i] = rq_src->nr_running;
+
+		if ((load > max_load) && (load < prev_max_load) &&
+						(rq_src != this_rq)) {
+			busiest = rq_src;
+			max_load = load;
+		}
+	}
+
+	if (likely(!busiest))
+		return;
+
+	imbalance = (max_load - nr_running) / 2;
 
 	/*
-	 * fast path falls through. We have to clear cpus_runnable before
-	 * checking prev->state to avoid a wakeup race. Protect against
-	 * the task exiting early.
-	 */
-	task_lock(prev);
-	task_release_cpu(prev);
-	mb();
-	if (prev->state == TASK_RUNNING)
-		goto needs_resched;
+	 * It needs an at least ~25% imbalance to trigger balancing.
+	 *
+	 * prev_max_load makes sure that we do not try to balance
+	 * ad infinitum - certain tasks might be impossible to be
+	 * pulled into this runqueue.
+	 */
+	if (!idle && (imbalance < (max_load + 3)/4))
+		return;
+	prev_max_load = max_load;
 
-out_unlock:
-	task_unlock(prev);	/* Synchronise here with release_task() if prev is TASK_ZOMBIE */
-	return;
+	/*
+	 * Ok, lets do some actual balancing:
+	 */
 
+	if (rq_cpu(busiest) < this_cpu) {
+		spin_unlock(&this_rq->lock);
+		spin_lock(&busiest->lock);
+		spin_lock(&this_rq->lock);
+	} else
+		spin_lock(&busiest->lock);
 	/*
-	 * Slow path - we 'push' the previous process and
-	 * reschedule_idle() will attempt to find a new
-	 * processor for it. (but it might preempt the
-	 * current process as well.) We must take the runqueue
-	 * lock and re-check prev->state to be correct. It might
-	 * still happen that this process has a preemption
-	 * 'in progress' already - but this is not a problem and
-	 * might happen in other circumstances as well.
+	 * Make sure nothing changed since we checked the
+	 * runqueue length.
 	 */
-needs_resched:
-	{
-		unsigned long flags;
+	if (busiest->nr_running <= nr_running + 1)
+		goto out_unlock;
 
-		/*
-		 * Avoid taking the runqueue lock in cases where
-		 * no preemption-check is necessery:
-		 */
-		if ((prev == idle_task(smp_processor_id())) ||
-						(policy & SCHED_YIELD))
-			goto out_unlock;
+	/*
+	 * We first consider expired tasks. Those will likely not run
+	 * in the near future, thus switching CPUs has the least effect
+	 * on them.
+	 */
+	if (busiest->expired->nr_active)
+		array = busiest->expired;
+	else
+		array = busiest->active;
 
-		spin_lock_irqsave(&runqueue_lock, flags);
-		if ((prev->state == TASK_RUNNING) && !task_has_cpu(prev))
-			reschedule_idle(prev);
-		spin_unlock_irqrestore(&runqueue_lock, flags);
+new_array:
+	/*
+	 * Load-balancing does not affect RT tasks, so we start the
+	 * searching at priority 128.
+	 */
+	idx = MAX_RT_PRIO;
+skip_bitmap:
+	idx = find_next_zero_bit(array->bitmap, MAX_PRIO, idx);
+	if (idx == MAX_PRIO) {
+		if (array == busiest->expired) {
+			array = busiest->active;
+			goto new_array;
+		}
+		spin_unlock(&busiest->lock);
 		goto out_unlock;
 	}
-#else
-	prev->policy &= ~SCHED_YIELD;
-#endif /* CONFIG_SMP */
+
+	head = array->queue + idx;
+	curr = head->next;
+skip_queue:
+	tmp = list_entry(curr, task_t, run_list);
+	if ((tmp == busiest->curr) || !(tmp->cpus_allowed & (1 << this_cpu))) {
+		curr = curr->next;
+		if (curr != head)
+			goto skip_queue;
+		idx++;
+		goto skip_bitmap;
+	}
+	next = tmp;
+	/*
+	 * take the task out of the other runqueue and
+	 * put it into this one:
+	 */
+	dequeue_task(next, array);
+	busiest->nr_running--;
+	next->cpu = this_cpu;
+	this_rq->nr_running++;
+	enqueue_task(next, this_rq->active);
+	if (next->prio < current->prio)
+		current->need_resched = 1;
+	if (!idle && --imbalance) {
+		if (array == busiest->expired) {
+			array = busiest->active;
+			goto new_array;
+		}
+		spin_unlock(&busiest->lock);
+	}
+out_unlock:
+	spin_unlock(&busiest->lock);
 }
 
-asmlinkage void schedule_tail(struct task_struct *prev)
+/*
+ * One of the idle_cpu_tick() or the busy_cpu_tick() function will
+ * gets called every timer tick, on every CPU. Our balancing action
+ * frequency and balancing agressivity depends on whether the CPU is
+ * idle or not.
+ *
+ * busy-rebalance every 250 msecs. idle-rebalance every 1 msec. (or on
+ * systems with HZ=100, every 10 msecs.)
+ */
+#define BUSY_REBALANCE_TICK (HZ/4 ?: 1)
+#define IDLE_REBALANCE_TICK (HZ/1000 ?: 1)
+
+static inline void idle_tick(void)
 {
-	__schedule_tail(prev);
+	if ((jiffies % IDLE_REBALANCE_TICK) ||
+			likely(this_rq()->curr == NULL))
+		return;
+	spin_lock(&this_rq()->lock);
+	load_balance(this_rq(), 1);
+	spin_unlock(&this_rq()->lock);
 }
 
 /*
- *  'schedule()' is the scheduler function. It's a very simple and nice
- * scheduler: it's not perfect, but certainly works for most things.
- *
- * The goto is "interesting".
- *
- *   NOTE!!  Task 0 is the 'idle' task, which gets called when no other
- * tasks can run. It can not be killed, and it cannot sleep. The 'state'
- * information in task[0] is never used.
+ * Should we treat the task as interactive or not.
+ * A task is interactive if it has not exceeded 50%
+ * of the max CPU-hog penalty yet.
  */
-asmlinkage void schedule(void)
+static int task_interactive(task_t *p, unsigned long now)
 {
-	struct schedule_data * sched_data;
-	struct task_struct *prev, *next, *p;
-	struct list_head *tmp;
-	int this_cpu, c;
+	int penalty;
 
+	if (rt_task(p))
+		return 1;
+	penalty = MAX_USER_PRIO * get_run_avg(p, jiffies) / (3 * HHZ);
+	if (penalty <= MAX_USER_PRIO/6)
+		return 1;
+	return 0;
+}
 
-	spin_lock_prefetch(&runqueue_lock);
+/*
+ * This function gets called by the timer code, with HZ frequency.
+ * We call it with interrupts disabled.
+ */
+void scheduler_tick(task_t *p)
+{
+	unsigned long now = jiffies;
+	runqueue_t *rq = this_rq();
 
-	if (!current->active_mm) BUG();
-need_resched_back:
-	prev = current;
-	this_cpu = prev->processor;
+	if (p == rq->idle || !rq->idle)
+		return idle_tick();
+	/* Task might have expired already, but not scheduled off yet */
+	if (p->array != rq->active) {
+		p->need_resched = 1;
+		return;
+	}
+	/*
+	 * The task cannot change CPUs because it's the current task.
+	 */
+	spin_lock(&rq->lock);
+	if ((p->policy != SCHED_FIFO) && !--p->time_slice) {
+		p->need_resched = 1;
+		if (rt_task(p))
+			p->time_slice = RT_PRIO_TO_TIMESLICE(p->prio);
+		else
+			p->time_slice = PRIO_TO_TIMESLICE(p->prio);
 
-	if (unlikely(in_interrupt())) {
-		printk("Scheduling in interrupt\n");
-		BUG();
+		/*
+		 * Timeslice used up - discard any possible
+		 * priority penalty:
+		 */
+		dequeue_task(p, rq->active);
+		/*
+		 * Tasks that have nice values of -20 ... -15 are put
+		 * back into the active array. If they use up too much
+		 * CPU time then they'll get a priority penalty anyway
+		 * so this can not starve other processes accidentally.
+		 * Otherwise this is pretty handy for sysadmins ...
+		 */
+		if (task_interactive(p, now))
+			enqueue_task(p, rq->active);
+		else
+			enqueue_task(p, rq->expired);
+	} else {
+		/*
+		 * Deactivate + activate the task so that the
+		 * load estimator gets updated properly:
+		 */
+		if (!rt_task(p)) {
+			deactivate_task(p, rq);
+			activate_task(p, rq);
+		}
 	}
+	if (!(now % BUSY_REBALANCE_TICK))
+		load_balance(rq, 0);
+	spin_unlock(&rq->lock);
+}
 
-	release_kernel_lock(prev, this_cpu);
-
-	/*
-	 * 'sched_data' is protected by the fact that we can run
-	 * only one process per CPU.
-	 */
-	sched_data = & aligned_data[this_cpu].schedule_data;
+void scheduling_functions_start_here(void) { }
 
-	spin_lock_irq(&runqueue_lock);
+/*
+ * 'schedule()' is the main scheduler function.
+ */
+asmlinkage void schedule(void)
+{
+	task_t *prev, *next;
+	prio_array_t *array;
+	runqueue_t *rq;
+	list_t *queue;
+	int idx;
 
-	/* move an exhausted RR process to be last.. */
-	if (unlikely(prev->policy == SCHED_RR))
-		if (!prev->counter) {
-			prev->counter = NICE_TO_TICKS(prev->nice);
-			move_last_runqueue(prev);
-		}
+	if (unlikely(in_interrupt()))
+		BUG();
+need_resched_back:
+	prev = current;
+	release_kernel_lock(prev, smp_processor_id());
+	rq = this_rq();
+	spin_lock_irq(&rq->lock);
 
 	switch (prev->state) {
 		case TASK_INTERRUPTIBLE:
-			if (signal_pending(prev)) {
+			if (unlikely(signal_pending(prev))) {
 				prev->state = TASK_RUNNING;
 				break;
 			}
 		default:
-			del_from_runqueue(prev);
-		case TASK_RUNNING:;
+			deactivate_task(prev, rq);
+		case TASK_RUNNING:
 	}
-	prev->need_resched = 0;
-
-	/*
-	 * this is the scheduler proper:
-	 */
-
-repeat_schedule:
-	/*
-	 * Default process to select..
-	 */
-	next = idle_task(this_cpu);
-	c = -1000;
-	list_for_each(tmp, &runqueue_head) {
-		p = list_entry(tmp, struct task_struct, run_list);
-		if (can_schedule(p, this_cpu)) {
-			int weight = goodness(p, this_cpu, prev->active_mm);
-			if (weight > c)
-				c = weight, next = p;
-		}
+pick_next_task:
+	if (unlikely(!rq->nr_running)) {
+		load_balance(rq, 1);
+		if (rq->nr_running)
+			goto pick_next_task;
+		next = rq->idle;
+		goto switch_tasks;
 	}
 
-	/* Do we need to re-calculate counters? */
-	if (unlikely(!c)) {
-		struct task_struct *p;
-
-		spin_unlock_irq(&runqueue_lock);
-		read_lock(&tasklist_lock);
-		for_each_task(p)
-			p->counter = (p->counter >> 1) + NICE_TO_TICKS(p->nice);
-		read_unlock(&tasklist_lock);
-		spin_lock_irq(&runqueue_lock);
-		goto repeat_schedule;
-	}
-
-	/*
-	 * from this point on nothing can prevent us from
-	 * switching to the next task, save this fact in
-	 * sched_data.
-	 */
-	sched_data->curr = next;
-	task_set_cpu(next, this_cpu);
-	spin_unlock_irq(&runqueue_lock);
-
-	if (unlikely(prev == next)) {
-		/* We won't go through the normal tail, so do this by hand */
-		prev->policy &= ~SCHED_YIELD;
-		goto same_process;
+	array = rq->active;
+	if (unlikely(!array->nr_active)) {
+		/*
+		 * Switch the active and expired arrays.
+		 */
+		rq->active = rq->expired;
+		rq->expired = array;
+		array = rq->active;
 	}
 
-#ifdef CONFIG_SMP
- 	/*
- 	 * maintain the per-process 'last schedule' value.
- 	 * (this has to be recalculated even if we reschedule to
- 	 * the same process) Currently this is only used on SMP,
-	 * and it's approximate, so we do not have to maintain
-	 * it while holding the runqueue spinlock.
- 	 */
- 	sched_data->last_schedule = get_cycles();
-
-	/*
-	 * We drop the scheduler lock early (it's a global spinlock),
-	 * thus we have to lock the previous process from getting
-	 * rescheduled during switch_to().
-	 */
+	idx = sched_find_first_zero_bit(array->bitmap);
+	queue = array->queue + idx;
+	next = list_entry(queue->next, task_t, run_list);
 
-#endif /* CONFIG_SMP */
-
-	kstat.context_swtch++;
-	/*
-	 * there are 3 processes which are affected by a context switch:
-	 *
-	 * prev == .... ==> (last => next)
-	 *
-	 * It's the 'much more previous' 'prev' that is on next's stack,
-	 * but prev is set to (the just run) 'last' process by switch_to().
-	 * This might sound slightly confusing but makes tons of sense.
-	 */
-	prepare_to_switch();
-	{
-		struct mm_struct *mm = next->mm;
-		struct mm_struct *oldmm = prev->active_mm;
-		if (!mm) {
-			if (next->active_mm) BUG();
-			next->active_mm = oldmm;
-			atomic_inc(&oldmm->mm_count);
-			enter_lazy_tlb(oldmm, next, this_cpu);
-		} else {
-			if (next->active_mm != mm) BUG();
-			switch_mm(oldmm, mm, next, this_cpu);
-		}
+switch_tasks:
+	prev->need_resched = 0;
 
-		if (!prev->mm) {
-			prev->active_mm = NULL;
-			mmdrop(oldmm);
-		}
+	if (likely(prev != next)) {
+		rq->nr_switches++;
+		rq->curr = next;
+		next->cpu = prev->cpu;
+		context_switch(prev, next);
+		/*
+		 * The runqueue pointer might be from another CPU
+		 * if the new task was last running on a different
+		 * CPU - thus re-load it.
+		 */
+		barrier();
+		rq = this_rq();
 	}
+	spin_unlock_irq(&rq->lock);
 
-	/*
-	 * This just switches the register state and the
-	 * stack.
-	 */
-	switch_to(prev, next, prev);
-	__schedule_tail(prev);
-
-same_process:
 	reacquire_kernel_lock(current);
-	if (current->need_resched)
+	if (unlikely(current->need_resched))
 		goto need_resched_back;
 	return;
 }
 
 /*
- * The core wakeup function.  Non-exclusive wakeups (nr_exclusive == 0) just wake everything
- * up.  If it's an exclusive wakeup (nr_exclusive == small +ve number) then we wake all the
- * non-exclusive tasks and one exclusive task.
+ * The core wakeup function.  Non-exclusive wakeups (nr_exclusive == 0) just
+ * wake everything up.  If it's an exclusive wakeup (nr_exclusive == small +ve
+ * number) then we wake all the non-exclusive tasks and one exclusive task.
  *
  * There are circumstances in which we can try to wake a task which has already
- * started to run but is not in state TASK_RUNNING.  try_to_wake_up() returns zero
- * in this (rare) case, and we handle it by contonuing to scan the queue.
+ * started to run but is not in state TASK_RUNNING.  try_to_wake_up() returns
+ * zero in this (rare) case, and we handle it by continuing to scan the queue.
  */
 static inline void __wake_up_common (wait_queue_head_t *q, unsigned int mode,
 			 	     int nr_exclusive, const int sync)
 {
 	struct list_head *tmp;
-	struct task_struct *p;
+	task_t *p;
 
-	CHECK_MAGIC_WQHEAD(q);
-	WQ_CHECK_LIST_HEAD(&q->task_list);
-	
 	list_for_each(tmp,&q->task_list) {
 		unsigned int state;
-                wait_queue_t *curr = list_entry(tmp, wait_queue_t, task_list);
+		wait_queue_t *curr = list_entry(tmp, wait_queue_t, task_list);
 
-		CHECK_MAGIC(curr->__magic);
 		p = curr->task;
 		state = p->state;
-		if (state & mode) {
-			WQ_NOTE_WAKER(curr);
-			if (try_to_wake_up(p, sync) && (curr->flags&WQ_FLAG_EXCLUSIVE) && !--nr_exclusive)
-				break;
-		}
+		if ((state & mode) &&
+				try_to_wake_up(p, sync) &&
+				((curr->flags & WQ_FLAG_EXCLUSIVE) &&
+					!--nr_exclusive))
+			break;
 	}
 }
 
@@ -850,8 +923,95 @@
 	return timeout;
 }
 
+/*
+ * Change the current task's CPU affinity. Migrate the process to a
+ * proper CPU and schedule away if the current CPU is removed from
+ * the allowed bitmask.
+ */
+void set_cpus_allowed(task_t *p, unsigned long new_mask)
+{
+	runqueue_t *this_rq = this_rq(), *target_rq;
+	unsigned long this_mask = 1UL << smp_processor_id();
+	int target_cpu;
+
+	new_mask &= cpu_online_map;
+	if (!new_mask)
+		BUG();
+	p->cpus_allowed = new_mask;
+	/*
+	 * Can the task run on the current CPU? If not then
+	 * migrate the process off to a proper CPU.
+	 */
+	if (new_mask & this_mask)
+		return;
+	target_cpu = ffz(~new_mask);
+	target_rq = cpu_rq(target_cpu);
+	if (target_cpu < smp_processor_id()) {
+		spin_lock_irq(&target_rq->lock);
+		spin_lock(&this_rq->lock);
+	} else {
+		spin_lock_irq(&this_rq->lock);
+		spin_lock(&target_rq->lock);
+	}
+	dequeue_task(p, p->array);
+	this_rq->nr_running--;
+	target_rq->nr_running++;
+	enqueue_task(p, target_rq->active);
+	target_rq->curr->need_resched = 1;
+	spin_unlock(&target_rq->lock);
+
+	/*
+	 * The easiest solution is to context switch into
+	 * the idle thread - which will pick the best task
+	 * afterwards:
+	 */
+	this_rq->nr_switches++;
+	this_rq->curr = this_rq->idle;
+	this_rq->idle->need_resched = 1;
+	context_switch(current, this_rq->idle);
+	barrier();
+	spin_unlock_irq(&this_rq()->lock);
+}
+
 void scheduling_functions_end_here(void) { }
 
+void set_user_nice(task_t *p, long nice)
+{
+	unsigned long flags;
+	prio_array_t *array;
+	runqueue_t *rq;
+
+	if (p->__nice == nice)
+		return;
+	/*
+	 * We have to be careful, if called from sys_setpriority(),
+	 * the task might be in the middle of scheduling on another CPU.
+	 */
+	lock_task_rq(rq, p, flags);
+	if (rt_task(p)) {
+		p->__nice = nice;
+		goto out_unlock;
+	}
+	array = p->array;
+	if (array) {
+		dequeue_task(p, array);
+	}
+	p->__nice = nice;
+	p->prio = NICE_TO_PRIO(nice);
+	if (array) {
+		enqueue_task(p, array);
+		/*
+		 * If the task is runnable and lowered its priority,
+		 * or increased its priority then reschedule its CPU:
+		 */
+		if ((nice < p->__nice) ||
+				((p->__nice < nice) && (p == rq->curr)))
+			resched_task(rq->curr);
+	}
+out_unlock:
+	unlock_task_rq(rq, p, flags);
+}
+
 #ifndef __alpha__
 
 /*
@@ -862,7 +1022,7 @@
 
 asmlinkage long sys_nice(int increment)
 {
-	long newprio;
+	long nice;
 
 	/*
 	 *	Setpriority might change our priority at the same moment.
@@ -878,32 +1038,30 @@
 	if (increment > 40)
 		increment = 40;
 
-	newprio = current->nice + increment;
-	if (newprio < -20)
-		newprio = -20;
-	if (newprio > 19)
-		newprio = 19;
-	current->nice = newprio;
+	nice = current->__nice + increment;
+	if (nice < -20)
+		nice = -20;
+	if (nice > 19)
+		nice = 19;
+	set_user_nice(current, nice);
 	return 0;
 }
 
 #endif
 
-static inline struct task_struct *find_process_by_pid(pid_t pid)
+static inline task_t *find_process_by_pid(pid_t pid)
 {
-	struct task_struct *tsk = current;
-
-	if (pid)
-		tsk = find_task_by_pid(pid);
-	return tsk;
+	return pid ? find_task_by_pid(pid) : current;
 }
 
-static int setscheduler(pid_t pid, int policy, 
-			struct sched_param *param)
+static int setscheduler(pid_t pid, int policy, struct sched_param *param)
 {
 	struct sched_param lp;
-	struct task_struct *p;
+	prio_array_t *array;
+	unsigned long flags;
+	runqueue_t *rq;
 	int retval;
+	task_t *p;
 
 	retval = -EINVAL;
 	if (!param || pid < 0)
@@ -917,14 +1075,19 @@
 	 * We play safe to avoid deadlocks.
 	 */
 	read_lock_irq(&tasklist_lock);
-	spin_lock(&runqueue_lock);
 
 	p = find_process_by_pid(pid);
 
 	retval = -ESRCH;
 	if (!p)
-		goto out_unlock;
-			
+		goto out_unlock_tasklist;
+
+	/*
+	 * To be able to change p->policy safely, the apropriate
+	 * runqueue lock must be held.
+	 */
+	lock_task_rq(rq,p,flags);
+
 	if (policy < 0)
 		policy = p->policy;
 	else {
@@ -945,30 +1108,36 @@
 		goto out_unlock;
 
 	retval = -EPERM;
-	if ((policy == SCHED_FIFO || policy == SCHED_RR) && 
+	if ((policy == SCHED_FIFO || policy == SCHED_RR) &&
 	    !capable(CAP_SYS_NICE))
 		goto out_unlock;
 	if ((current->euid != p->euid) && (current->euid != p->uid) &&
 	    !capable(CAP_SYS_NICE))
 		goto out_unlock;
 
+	array = p->array;
+	if (array)
+		deactivate_task(p, task_rq(p));
 	retval = 0;
 	p->policy = policy;
 	p->rt_priority = lp.sched_priority;
-	if (task_on_runqueue(p))
-		move_first_runqueue(p);
-
-	current->need_resched = 1;
+	if (rt_task(p))
+		p->prio = 99-p->rt_priority;
+	else
+		p->prio = NICE_TO_PRIO(p->__nice);
+	if (array)
+		activate_task(p, task_rq(p));
 
 out_unlock:
-	spin_unlock(&runqueue_lock);
+	unlock_task_rq(rq,p,flags);
+out_unlock_tasklist:
 	read_unlock_irq(&tasklist_lock);
 
 out_nounlock:
 	return retval;
 }
 
-asmlinkage long sys_sched_setscheduler(pid_t pid, int policy, 
+asmlinkage long sys_sched_setscheduler(pid_t pid, int policy,
 				      struct sched_param *param)
 {
 	return setscheduler(pid, policy, param);
@@ -981,7 +1150,7 @@
 
 asmlinkage long sys_sched_getscheduler(pid_t pid)
 {
-	struct task_struct *p;
+	task_t *p;
 	int retval;
 
 	retval = -EINVAL;
@@ -992,7 +1161,7 @@
 	read_lock(&tasklist_lock);
 	p = find_process_by_pid(pid);
 	if (p)
-		retval = p->policy & ~SCHED_YIELD;
+		retval = p->policy;
 	read_unlock(&tasklist_lock);
 
 out_nounlock:
@@ -1001,7 +1170,7 @@
 
 asmlinkage long sys_sched_getparam(pid_t pid, struct sched_param *param)
 {
-	struct task_struct *p;
+	task_t *p;
 	struct sched_param lp;
 	int retval;
 
@@ -1032,42 +1201,28 @@
 
 asmlinkage long sys_sched_yield(void)
 {
+	runqueue_t *rq = this_rq();
+	prio_array_t *array;
+
 	/*
-	 * Trick. sched_yield() first counts the number of truly 
-	 * 'pending' runnable processes, then returns if it's
-	 * only the current processes. (This test does not have
-	 * to be atomic.) In threaded applications this optimization
-	 * gets triggered quite often.
+	 * Decrease the yielding task's priority by one, to avoid
+	 * livelocks. This priority loss is temporary, it's recovered
+	 * once the current timeslice expires.
+	 *
+	 * If priority is already MAX_PRIO-1 then we still
+	 * roundrobin the task within the runlist.
 	 */
+	spin_lock_irq(&rq->lock);
+	array = current->array;
+	dequeue_task(current, array);
+	if (likely(!rt_task(current)))
+		if (current->prio < MAX_PRIO-1)
+			current->prio++;
+	enqueue_task(current, array);
+	spin_unlock_irq(&rq->lock);
 
-	int nr_pending = nr_running;
-
-#if CONFIG_SMP
-	int i;
-
-	// Subtract non-idle processes running on other CPUs.
-	for (i = 0; i < smp_num_cpus; i++) {
-		int cpu = cpu_logical_map(i);
-		if (aligned_data[cpu].schedule_data.curr != idle_task(cpu))
-			nr_pending--;
-	}
-#else
-	// on UP this process is on the runqueue as well
-	nr_pending--;
-#endif
-	if (nr_pending) {
-		/*
-		 * This process can only be rescheduled by us,
-		 * so this is safe without any locking.
-		 */
-		if (current->policy == SCHED_OTHER)
-			current->policy |= SCHED_YIELD;
-		current->need_resched = 1;
+	schedule();
 
-		spin_lock_irq(&runqueue_lock);
-		move_last_runqueue(current);
-		spin_unlock_irq(&runqueue_lock);
-	}
 	return 0;
 }
 
@@ -1105,7 +1260,7 @@
 asmlinkage long sys_sched_rr_get_interval(pid_t pid, struct timespec *interval)
 {
 	struct timespec t;
-	struct task_struct *p;
+	task_t *p;
 	int retval = -EINVAL;
 
 	if (pid < 0)
@@ -1115,8 +1270,8 @@
 	read_lock(&tasklist_lock);
 	p = find_process_by_pid(pid);
 	if (p)
-		jiffies_to_timespec(p->policy & SCHED_FIFO ? 0 : NICE_TO_TICKS(p->nice),
-				    &t);
+		jiffies_to_timespec(p->policy & SCHED_FIFO ?
+					 0 : RT_PRIO_TO_TIMESLICE(p->prio), &t);
 	read_unlock(&tasklist_lock);
 	if (p)
 		retval = copy_to_user(interval, &t, sizeof(t)) ? -EFAULT : 0;
@@ -1124,7 +1279,7 @@
 	return retval;
 }
 
-static void show_task(struct task_struct * p)
+static void show_task(task_t * p)
 {
 	unsigned long free = 0;
 	int state;
@@ -1172,7 +1327,7 @@
 		printk(" (NOTLB)\n");
 
 	{
-		extern void show_trace_task(struct task_struct *tsk);
+		extern void show_trace_task(task_t *tsk);
 		show_trace_task(p);
 	}
 }
@@ -1194,7 +1349,7 @@
 
 void show_state(void)
 {
-	struct task_struct *p;
+	task_t *p;
 
 #if (BITS_PER_LONG == 32)
 	printk("\n"
@@ -1217,121 +1372,97 @@
 	read_unlock(&tasklist_lock);
 }
 
-/**
- * reparent_to_init() - Reparent the calling kernel thread to the init task.
- *
- * If a kernel thread is launched as a result of a system call, or if
- * it ever exits, it should generally reparent itself to init so that
- * it is correctly cleaned up on exit.
- *
- * The various task state such as scheduling policy and priority may have
- * been inherited fro a user process, so we reset them to sane values here.
- *
- * NOTE that reparent_to_init() gives the caller full capabilities.
- */
-void reparent_to_init(void)
-{
-	struct task_struct *this_task = current;
-
-	write_lock_irq(&tasklist_lock);
-
-	/* Reparent to init */
-	REMOVE_LINKS(this_task);
-	this_task->p_pptr = child_reaper;
-	this_task->p_opptr = child_reaper;
-	SET_LINKS(this_task);
-
-	/* Set the exit signal to SIGCHLD so we signal init on exit */
-	this_task->exit_signal = SIGCHLD;
-
-	/* We also take the runqueue_lock while altering task fields
-	 * which affect scheduling decisions */
-	spin_lock(&runqueue_lock);
-
-	this_task->ptrace = 0;
-	this_task->nice = DEF_NICE;
-	this_task->policy = SCHED_OTHER;
-	/* cpus_allowed? */
-	/* rt_priority? */
-	/* signals? */
-	this_task->cap_effective = CAP_INIT_EFF_SET;
-	this_task->cap_inheritable = CAP_INIT_INH_SET;
-	this_task->cap_permitted = CAP_FULL_SET;
-	this_task->keep_capabilities = 0;
-	memcpy(this_task->rlim, init_task.rlim, sizeof(*(this_task->rlim)));
-	this_task->user = INIT_USER;
+extern unsigned long wait_init_idle;
 
-	spin_unlock(&runqueue_lock);
-	write_unlock_irq(&tasklist_lock);
+static inline void double_rq_lock(runqueue_t *rq1, runqueue_t *rq2)
+{
+	if (rq1 == rq2)
+		spin_lock(&rq1->lock);
+	else {
+		if (rq_cpu(rq1) < rq_cpu(rq2)) {
+			spin_lock(&rq1->lock);
+			spin_lock(&rq2->lock);
+		} else {
+			spin_lock(&rq2->lock);
+			spin_lock(&rq1->lock);
+		}
+	}
 }
 
-/*
- *	Put all the gunge required to become a kernel thread without
- *	attached user resources in one place where it belongs.
- */
-
-void daemonize(void)
+static inline void double_rq_unlock(runqueue_t *rq1, runqueue_t *rq2)
 {
-	struct fs_struct *fs;
-
-
-	/*
-	 * If we were started as result of loading a module, close all of the
-	 * user space pages.  We don't need them, and if we didn't close them
-	 * they would be locked into memory.
-	 */
-	exit_mm(current);
-
-	current->session = 1;
-	current->pgrp = 1;
-	current->tty = NULL;
-
-	/* Become as one with the init task */
-
-	exit_fs(current);	/* current->fs->count--; */
-	fs = init_task.fs;
-	current->fs = fs;
-	atomic_inc(&fs->count);
- 	exit_files(current);
-	current->files = init_task.files;
-	atomic_inc(&current->files->count);
+	spin_unlock(&rq1->lock);
+	if (rq1 != rq2)
+		spin_unlock(&rq2->lock);
 }
 
-extern unsigned long wait_init_idle;
-
 void __init init_idle(void)
 {
-	struct schedule_data * sched_data;
-	sched_data = &aligned_data[smp_processor_id()].schedule_data;
+	runqueue_t *this_rq = this_rq(), *rq = current->array->rq;
+	unsigned long flags;
 
-	if (current != &init_task && task_on_runqueue(current)) {
-		printk("UGH! (%d:%d) was on the runqueue, removing.\n",
-			smp_processor_id(), current->pid);
-		del_from_runqueue(current);
+	__save_flags(flags);
+	__cli();
+	double_rq_lock(this_rq, rq);
+
+	this_rq->curr = this_rq->idle = current;
+	deactivate_task(current, rq);
+	current->array = NULL;
+	current->prio = MAX_PRIO;
+	current->state = TASK_RUNNING;
+	clear_bit(smp_processor_id(), &wait_init_idle);
+	double_rq_unlock(this_rq, rq);
+	while (wait_init_idle) {
+		cpu_relax();
+		barrier();
 	}
-	sched_data->curr = current;
-	sched_data->last_schedule = get_cycles();
-	clear_bit(current->processor, &wait_init_idle);
+	current->need_resched = 1;
+	__sti();
 }
 
-extern void init_timervecs (void);
+extern void init_timervecs(void);
+extern void timer_bh(void);
+extern void tqueue_bh(void);
+extern void immediate_bh(void);
 
 void __init sched_init(void)
 {
+	runqueue_t *rq;
+	int i, j, k;
+
+	for (i = 0; i < NR_CPUS; i++) {
+		runqueue_t *rq = cpu_rq(i);
+		prio_array_t *array;
+
+		rq->active = rq->arrays + 0;
+		rq->expired = rq->arrays + 1;
+		spin_lock_init(&rq->lock);
+
+		for (j = 0; j < 2; j++) {
+			array = rq->arrays + j;
+			array->rq = rq;
+			array->lock = &rq->lock;
+			for (k = 0; k < MAX_PRIO; k++) {
+				INIT_LIST_HEAD(array->queue + k);
+				__set_bit(k, array->bitmap);
+			}
+			// zero delimiter for bitsearch
+			__clear_bit(MAX_PRIO, array->bitmap);
+		}
+	}
 	/*
 	 * We have to do a little magic to get the first
 	 * process right in SMP mode.
 	 */
-	int cpu = smp_processor_id();
-	int nr;
+	rq = this_rq();
+	rq->curr = current;
+	rq->idle = NULL;
+	wake_up_process(current);
 
-	init_task.processor = cpu;
-
-	for(nr = 0; nr < PIDHASH_SZ; nr++)
-		pidhash[nr] = NULL;
+	for (i = 0; i < PIDHASH_SZ; i++)
+		pidhash[i] = NULL;
 
 	init_timervecs();
-
 	init_bh(TIMER_BH, timer_bh);
 	init_bh(TQUEUE_BH, tqueue_bh);
 	init_bh(IMMEDIATE_BH, immediate_bh);
@@ -1340,5 +1471,5 @@
 	 * The boot idle thread does lazy MMU switching as well:
 	 */
 	atomic_inc(&init_mm.mm_count);
-	enter_lazy_tlb(&init_mm, current, cpu);
+	enter_lazy_tlb(&init_mm, current, smp_processor_id());
 }
diff -X dontdiff -Nur origlinux/kernel/signal.c mylinux/kernel/signal.c
--- origlinux/kernel/signal.c	Fri Jan 11 14:41:43 2002
+++ mylinux/kernel/signal.c	Fri Jan 11 14:46:44 2002
@@ -478,12 +478,9 @@
 	 * process of changing - but no harm is done by that
 	 * other than doing an extra (lightweight) IPI interrupt.
 	 */
-	spin_lock(&runqueue_lock);
-	if (task_has_cpu(t) && t->processor != smp_processor_id())
-		smp_send_reschedule(t->processor);
-	spin_unlock(&runqueue_lock);
-#endif /* CONFIG_SMP */
-
+	if ((t->state == TASK_RUNNING) && (t->cpu != cpu()))
+		kick_if_running(t);
+#endif
 	if (t->state & TASK_INTERRUPTIBLE) {
 		wake_up_process(t);
 		return;
diff -X dontdiff -Nur origlinux/kernel/softirq.c mylinux/kernel/softirq.c
--- origlinux/kernel/softirq.c	Fri Jan 11 14:41:43 2002
+++ mylinux/kernel/softirq.c	Fri Jan 11 14:46:44 2002
@@ -261,10 +261,9 @@
 
 	while (test_and_set_bit(TASKLET_STATE_SCHED, &t->state)) {
 		current->state = TASK_RUNNING;
-		do {
-			current->policy |= SCHED_YIELD;
-			schedule();
-		} while (test_bit(TASKLET_STATE_SCHED, &t->state));
+		do
+			sys_sched_yield();
+		while (test_bit(TASKLET_STATE_SCHED, &t->state));
 	}
 	tasklet_unlock_wait(t);
 	clear_bit(TASKLET_STATE_SCHED, &t->state);
@@ -365,13 +364,13 @@
 	int cpu = cpu_logical_map(bind_cpu);
 
 	daemonize();
-	current->nice = 19;
+	set_user_nice(current, 19);
 	sigfillset(&current->blocked);
 
 	/* Migrate to the right CPU */
-	current->cpus_allowed = 1UL << cpu;
-	while (smp_processor_id() != cpu)
-		schedule();
+	set_cpus_allowed(current, 1UL << cpu);
+	if (cpu() != cpu)
+		BUG();
 
 	sprintf(current->comm, "ksoftirqd_CPU%d", bind_cpu);
 
@@ -405,10 +404,8 @@
 				  CLONE_FS | CLONE_FILES | CLONE_SIGNAL) < 0)
 			printk("spawn_ksoftirqd() failed for cpu %d\n", cpu);
 		else {
-			while (!ksoftirqd_task(cpu_logical_map(cpu))) {
-				current->policy |= SCHED_YIELD;
-				schedule();
-			}
+			while (!ksoftirqd_task(cpu_logical_map(cpu)))
+				sys_sched_yield();
 		}
 	}
 
diff -X dontdiff -Nur origlinux/kernel/sys.c mylinux/kernel/sys.c
--- origlinux/kernel/sys.c	Fri Jan 11 14:41:43 2002
+++ mylinux/kernel/sys.c	Fri Jan 11 14:46:44 2002
@@ -220,10 +220,10 @@
 		}
 		if (error == -ESRCH)
 			error = 0;
-		if (niceval < p->nice && !capable(CAP_SYS_NICE))
+		if (niceval < p->__nice && !capable(CAP_SYS_NICE))
 			error = -EACCES;
 		else
-			p->nice = niceval;
+			set_user_nice(p, niceval);
 	}
 	read_unlock(&tasklist_lock);
 
@@ -249,7 +249,7 @@
 		long niceval;
 		if (!proc_sel(p, which, who))
 			continue;
-		niceval = 20 - p->nice;
+		niceval = 20 - p->__nice;
 		if (niceval > retval)
 			retval = niceval;
 	}
diff -X dontdiff -Nur origlinux/kernel/timer.c mylinux/kernel/timer.c
--- origlinux/kernel/timer.c	Fri Jan 11 14:41:43 2002
+++ mylinux/kernel/timer.c	Fri Jan 11 16:54:43 2002
@@ -25,6 +25,8 @@
 
 #include <asm/uaccess.h>
 
+struct kernel_stat kstat;
+
 /*
  * Timekeeping variables
  */
@@ -583,17 +585,16 @@
 
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
+		if (bh_count(cpu) || irq_count(cpu) > 1)
+			kstat.per_cpu_system[cpu] += system;
+	}
+	scheduler_tick(p);
 }
 
 /*
@@ -795,6 +796,89 @@
 }
 
 #endif
+
+static void process_timeout(unsigned long __data)
+{
+	wake_up_process((task_t *)__data);
+}
+
+/**
+ * schedule_timeout - sleep until timeout
+ * @timeout: timeout value in jiffies
+ *
+ * Make the current task sleep until @timeout jiffies have
+ * elapsed. The routine will return immediately unless
+ * the current task state has been set (see set_current_state()).
+ *
+ * You can set the task state as follows -
+ *
+ * %TASK_UNINTERRUPTIBLE - at least @timeout jiffies are guaranteed to
+ * pass before the routine returns. The routine will return 0
+ *
+ * %TASK_INTERRUPTIBLE - the routine may return early if a signal is
+ * delivered to the current task. In this case the remaining time
+ * in jiffies will be returned, or 0 if the timer expired in time
+ *
+ * The current task state is guaranteed to be TASK_RUNNING when this 
+ * routine returns.
+ *
+ * Specifying a @timeout value of %MAX_SCHEDULE_TIMEOUT will schedule
+ * the CPU away without a bound on the timeout. In this case the return
+ * value will be %MAX_SCHEDULE_TIMEOUT.
+ *
+ * In all cases the return value is guaranteed to be non-negative.
+ */
+signed long schedule_timeout(signed long timeout)
+{
+	struct timer_list timer;
+	unsigned long expire;
+
+	switch (timeout)
+	{
+	case MAX_SCHEDULE_TIMEOUT:
+		/*
+		 * These two special cases are useful to be comfortable
+		 * in the caller. Nothing more. We could take
+		 * MAX_SCHEDULE_TIMEOUT from one of the negative value
+		 * but I' d like to return a valid offset (>=0) to allow
+		 * the caller to do everything it want with the retval.
+		 */
+		schedule();
+		goto out;
+	default:
+		/*
+		 * Another bit of PARANOID. Note that the retval will be
+		 * 0 since no piece of kernel is supposed to do a check
+		 * for a negative retval of schedule_timeout() (since it
+		 * should never happens anyway). You just have the printk()
+		 * that will tell you if something is gone wrong and where.
+		 */
+		if (timeout < 0)
+		{
+			printk(KERN_ERR "schedule_timeout: wrong timeout "
+			       "value %lx from %p\n", timeout,
+			       __builtin_return_address(0));
+			current->state = TASK_RUNNING;
+			goto out;
+		}
+	}
+
+	expire = timeout + jiffies;
+
+	init_timer(&timer);
+	timer.expires = expire;
+	timer.data = (unsigned long) current;
+	timer.function = process_timeout;
+
+	add_timer(&timer);
+	schedule();
+	del_timer_sync(&timer);
+
+	timeout = expire - jiffies;
+
+ out:
+	return timeout < 0 ? 0 : timeout;
+}
 
 /* Thread ID - the internal kernel "pid" */
 asmlinkage long sys_gettid(void)
diff -X dontdiff -Nur origlinux/mm/highmem.c mylinux/mm/highmem.c
--- origlinux/mm/highmem.c	Fri Jan 11 14:41:44 2002
+++ mylinux/mm/highmem.c	Fri Jan 11 14:46:44 2002
@@ -354,9 +354,7 @@
 	/* we need to wait I/O completion */
 	run_task_queue(&tq_disk);
 
-	current->policy |= SCHED_YIELD;
-	__set_current_state(TASK_RUNNING);
-	schedule();
+	yield();
 	goto repeat_alloc;
 }
 
@@ -392,9 +390,7 @@
 	/* we need to wait I/O completion */
 	run_task_queue(&tq_disk);
 
-	current->policy |= SCHED_YIELD;
-	__set_current_state(TASK_RUNNING);
-	schedule();
+	yield();
 	goto repeat_alloc;
 }
 
diff -X dontdiff -Nur origlinux/mm/oom_kill.c mylinux/mm/oom_kill.c
--- origlinux/mm/oom_kill.c	Fri Jan 11 14:41:44 2002
+++ mylinux/mm/oom_kill.c	Fri Jan 11 14:46:44 2002
@@ -82,7 +82,7 @@
 	 * Niced processes are most likely less important, so double
 	 * their badness points.
 	 */
-	if (p->nice > 0)
+	if (p->__nice > 0)
 		points *= 2;
 
 	/*
@@ -149,7 +149,7 @@
 	 * all the memory it needs. That way it should be able to
 	 * exit() and clear out its resources quickly...
 	 */
-	p->counter = 5 * HZ;
+	p->time_slice = 2 * MAX_TIMESLICE;
 	p->flags |= PF_MEMALLOC | PF_MEMDIE;
 
 	/* This process has hardware access, be more careful. */
@@ -188,8 +188,7 @@
 	 * killing itself before someone else gets the chance to ask
 	 * for more memory.
 	 */
-	current->policy |= SCHED_YIELD;
-	schedule();
+	yield();
 	return;
 }
 
diff -X dontdiff -Nur origlinux/mm/page_alloc.c mylinux/mm/page_alloc.c
--- origlinux/mm/page_alloc.c	Fri Jan 11 14:41:44 2002
+++ mylinux/mm/page_alloc.c	Fri Jan 11 14:46:44 2002
@@ -394,9 +394,7 @@
 		return NULL;
 
 	/* Yield for kswapd, and try again */
-	current->policy |= SCHED_YIELD;
-	__set_current_state(TASK_RUNNING);
-	schedule();
+	yield();
 	goto rebalance;
 }
 
diff -X dontdiff -Nur origlinux/net/ipv4/tcp_output.c mylinux/net/ipv4/tcp_output.c
--- origlinux/net/ipv4/tcp_output.c	Fri Jan 11 14:41:47 2002
+++ mylinux/net/ipv4/tcp_output.c	Fri Jan 11 14:46:44 2002
@@ -1009,8 +1009,7 @@
 			skb = alloc_skb(MAX_TCP_HEADER, GFP_KERNEL);
 			if (skb)
 				break;
-			current->policy |= SCHED_YIELD;
-			schedule();
+			yield();
 		}
 
 		/* Reserve space for headers and prepare control bits. */
diff -X dontdiff -Nur origlinux/net/sched/sch_generic.c mylinux/net/sched/sch_generic.c
--- origlinux/net/sched/sch_generic.c	Fri Jan 11 14:41:50 2002
+++ mylinux/net/sched/sch_generic.c	Fri Jan 11 14:46:44 2002
@@ -475,10 +475,8 @@
 
 	dev_watchdog_down(dev);
 
-	while (test_bit(__LINK_STATE_SCHED, &dev->state)) {
-		current->policy |= SCHED_YIELD;
-		schedule();
-	}
+	while (test_bit(__LINK_STATE_SCHED, &dev->state))
+		yield();
 
 	spin_unlock_wait(&dev->xmit_lock);
 }
diff -X dontdiff -Nur origlinux/net/socket.c mylinux/net/socket.c
--- origlinux/net/socket.c	Fri Jan 11 14:41:50 2002
+++ mylinux/net/socket.c	Fri Jan 11 14:46:44 2002
@@ -148,8 +148,7 @@
 	while (atomic_read(&net_family_lockct) != 0) {
 		spin_unlock(&net_family_lock);
 
-		current->policy |= SCHED_YIELD;
-		schedule();
+		yield();
 
 		spin_lock(&net_family_lock);
 	}
diff -X dontdiff -Nur origlinux/net/sunrpc/sched.c mylinux/net/sunrpc/sched.c
--- origlinux/net/sunrpc/sched.c	Fri Jan 11 14:41:50 2002
+++ mylinux/net/sunrpc/sched.c	Fri Jan 11 14:46:44 2002
@@ -772,8 +772,7 @@
 		}
 		if (flags & RPC_TASK_ASYNC)
 			return NULL;
-		current->policy |= SCHED_YIELD;
-		schedule();
+		yield();
 	} while (!signalled());
 
 	return NULL;
@@ -1114,8 +1113,7 @@
 		__rpc_schedule();
 		if (all_tasks) {
 			dprintk("rpciod_killall: waiting for tasks to exit\n");
-			current->policy |= SCHED_YIELD;
-			schedule();
+			yield();
 		}
 	}
 
@@ -1185,8 +1183,7 @@
 	 * wait briefly before checking the process id.
 	 */
 	current->sigpending = 0;
-	current->policy |= SCHED_YIELD;
-	schedule();
+	yield();
 	/*
 	 * Display a message if we're going to wait longer.
 	 */
diff -X dontdiff -Nur origlinux/net/unix/af_unix.c mylinux/net/unix/af_unix.c
--- origlinux/net/unix/af_unix.c	Fri Jan 11 14:41:50 2002
+++ mylinux/net/unix/af_unix.c	Fri Jan 11 14:46:44 2002
@@ -564,10 +564,8 @@
 				      addr->hash)) {
 		write_unlock(&unix_table_lock);
 		/* Sanity yield. It is unusual case, but yet... */
-		if (!(ordernum&0xFF)) {
-			current->policy |= SCHED_YIELD;
-			schedule();
-		}
+		if (!(ordernum&0xFF))
+			yield();
 		goto retry;
 	}
 	addr->hash ^= sk->type;

--PNTmBPCT7hxwcZjr--

