From: Erich Focht <efocht@ess.nec.de>
Date: Thu, 28 Feb 2002 18:44:42 +0000
Subject: [Linux-ia64] O(1) scheduler K3+ for IA64
Message-Id: <marc-linux-ia64-105590701905201@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

the latest scheduler from Ingo included in 2.5.6-pre1 includes
set_cpus_allowed() function working for all processes. Here is a port to
IA64, kernel 2.4.17. Please apply: 
  - kdb-v2.1-2.4.17-common-2
  - linux-2.4.17-ia64-011226.diff
  - kdb-v2.1-2.4.17-ia64-011226-1
  - sched-O1-2.4.17-K3.patch  from http://people.redhat.com/mingo/O(1)-scheduler/
  - the appended ia64 port with K3+ changes.

There is a small bugfix included (disable interrupts in
migration_task) and I changed the way how the migration tasks were
distributed across the CPUs. I hope this works for everybody...

Regards,
Erich

diff -urN 2.4.17-ia64-kdbv2.1-K3/arch/i386/kernel/i8259.c 2.4.17-ia64-kdbv2.1-k3y_al2/arch/i386/kernel/i8259.c
--- 2.4.17-ia64-kdbv2.1-K3/arch/i386/kernel/i8259.c	Fri Feb  8 12:02:06 2002
+++ 2.4.17-ia64-kdbv2.1-k3y_al2/arch/i386/kernel/i8259.c	Tue Sep 18 08:03:09 2001
@@ -79,7 +79,6 @@
  * through the ICC by us (IPIs)
  */
 #ifdef CONFIG_SMP
-BUILD_SMP_INTERRUPT(task_migration_interrupt,TASK_MIGRATION_VECTOR)
 BUILD_SMP_INTERRUPT(reschedule_interrupt,RESCHEDULE_VECTOR)
 BUILD_SMP_INTERRUPT(invalidate_interrupt,INVALIDATE_TLB_VECTOR)
 BUILD_SMP_INTERRUPT(call_function_interrupt,CALL_FUNCTION_VECTOR)
@@ -474,9 +473,6 @@
 	 */
 	set_intr_gate(RESCHEDULE_VECTOR, reschedule_interrupt);
 
-	/* IPI for task migration */
-	set_intr_gate(TASK_MIGRATION_VECTOR, task_migration_interrupt);
-
 	/* IPI for invalidation */
 	set_intr_gate(INVALIDATE_TLB_VECTOR, invalidate_interrupt);
 
diff -urN 2.4.17-ia64-kdbv2.1-K3/arch/i386/kernel/smp.c 2.4.17-ia64-kdbv2.1-k3y_al2/arch/i386/kernel/smp.c
--- 2.4.17-ia64-kdbv2.1-K3/arch/i386/kernel/smp.c	Fri Feb  8 12:02:06 2002
+++ 2.4.17-ia64-kdbv2.1-k3y_al2/arch/i386/kernel/smp.c	Thu Feb 28 19:28:16 2002
@@ -485,35 +485,6 @@
 	do_flush_tlb_all_local();
 }
 
-static spinlock_t migration_lock = SPIN_LOCK_UNLOCKED;
-static task_t *new_task;
-
-/*
- * This function sends a 'task migration' IPI to another CPU.
- * Must be called from syscall contexts, with interrupts *enabled*.
- */
-void smp_migrate_task(int cpu, task_t *p)
-{
-	/*
-	 * The target CPU will unlock the migration spinlock:
-	 */
-	spin_lock(&migration_lock);
-	new_task = p;
-	send_IPI_mask(1 << cpu, TASK_MIGRATION_VECTOR);
-}
-
-/*
- * Task migration callback.
- */
-asmlinkage void smp_task_migration_interrupt(void)
-{
-	task_t *p;
-
-	ack_APIC_irq();
-	p = new_task;
-	spin_unlock(&migration_lock);
-	sched_task_migrated(p);
-}
 /*
  * this function sends a 'reschedule' IPI to another CPU.
  * it goes straight through and wastes no time serializing
diff -urN 2.4.17-ia64-kdbv2.1-K3/arch/ia64/ia32/ia32_entry.S 2.4.17-ia64-kdbv2.1-k3y_al2/arch/ia64/ia32/ia32_entry.S
--- 2.4.17-ia64-kdbv2.1-K3/arch/ia64/ia32/ia32_entry.S	Mon Feb  4 12:41:37 2002
+++ 2.4.17-ia64-kdbv2.1-k3y_al2/arch/ia64/ia32/ia32_entry.S	Thu Feb 28 19:28:16 2002
@@ -37,7 +37,7 @@
 	mov loc1=r16				// save ar.pfs across do_fork
 	.body
 	zxt4 out1=in1				// newsp
-	mov out3=0				// stacksize
+	mov out3				// stacksize (compensates for 16-byte scratch area)
 	adds out2=IA64_SWITCH_STACK_SIZE+16,sp	// out2 = &regs
 	zxt4 out0=in0				// out0 = clone_flags
 	br.call.sptk.many rp=do_fork
diff -urN 2.4.17-ia64-kdbv2.1-K3/arch/ia64/kdb/kdba_bt.c 2.4.17-ia64-kdbv2.1-k3y_al2/arch/ia64/kdb/kdba_bt.c
--- 2.4.17-ia64-kdbv2.1-K3/arch/ia64/kdb/kdba_bt.c	Mon Feb  4 12:42:05 2002
+++ 2.4.17-ia64-kdbv2.1-k3y_al2/arch/ia64/kdb/kdba_bt.c	Thu Feb 28 19:28:16 2002
@@ -197,7 +197,7 @@
 	}
 #ifdef CONFIG_SMP
 	else if (task_has_cpu(p)) {
-		sw = kdb_sw[p->processor];
+		sw = kdb_sw[p->cpu];
 	}
 #endif
 	else {
diff -urN 2.4.17-ia64-kdbv2.1-K3/arch/ia64/kernel/entry.S 2.4.17-ia64-kdbv2.1-k3y_al2/arch/ia64/kernel/entry.S
--- 2.4.17-ia64-kdbv2.1-K3/arch/ia64/kernel/entry.S	Mon Feb  4 12:41:37 2002
+++ 2.4.17-ia64-kdbv2.1-k3y_al2/arch/ia64/kernel/entry.S	Thu Feb 28 19:28:16 2002
@@ -115,7 +115,7 @@
 	mov loc1=r16				// save ar.pfs across do_fork
 	.body
 	mov out1=in1
-	mov out3=0
+	mov out3				// stacksize (compensates for 16-byte scratch area)
 	adds out2=IA64_SWITCH_STACK_SIZE+16,sp	// out2 = &regs
 	mov out0=in0				// out0 = clone_flags
 	br.call.sptk.many rp=do_fork
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
diff -urN 2.4.17-ia64-kdbv2.1-K3/arch/ia64/kernel/irq_ia64.c 2.4.17-ia64-kdbv2.1-k3y_al2/arch/ia64/kernel/irq_ia64.c
--- 2.4.17-ia64-kdbv2.1-K3/arch/ia64/kernel/irq_ia64.c	Fri Nov  9 23:26:17 2001
+++ 2.4.17-ia64-kdbv2.1-k3y_al2/arch/ia64/kernel/irq_ia64.c	Thu Feb 28 19:28:16 2002
@@ -148,6 +148,7 @@
 	flags:		SA_INTERRUPT,
 	name:		"IPI"
 };
+
 #endif
 
 void
diff -urN 2.4.17-ia64-kdbv2.1-K3/arch/ia64/kernel/process.c 2.4.17-ia64-kdbv2.1-k3y_al2/arch/ia64/kernel/process.c
--- 2.4.17-ia64-kdbv2.1-K3/arch/ia64/kernel/process.c	Mon Feb  4 12:41:37 2002
+++ 2.4.17-ia64-kdbv2.1-k3y_al2/arch/ia64/kernel/process.c	Thu Feb 28 19:28:16 2002
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
@@ -258,7 +254,7 @@
 
 	if (user_mode(child_ptregs)) {
 		if (user_stack_base) {
-			child_ptregs->r12 = user_stack_base + user_stack_size;
+			child_ptregs->r12 = user_stack_base + user_stack_size - 16;
 			child_ptregs->ar_bspstore = user_stack_base;
 			child_ptregs->ar_rnat = 0;
 			child_ptregs->loadrs = 0;
diff -urN 2.4.17-ia64-kdbv2.1-K3/arch/ia64/kernel/setup.c 2.4.17-ia64-kdbv2.1-k3y_al2/arch/ia64/kernel/setup.c
--- 2.4.17-ia64-kdbv2.1-K3/arch/ia64/kernel/setup.c	Mon Feb  4 12:41:37 2002
+++ 2.4.17-ia64-kdbv2.1-k3y_al2/arch/ia64/kernel/setup.c	Thu Feb 28 19:28:16 2002
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
diff -urN 2.4.17-ia64-kdbv2.1-K3/arch/ia64/kernel/smp.c 2.4.17-ia64-kdbv2.1-k3y_al2/arch/ia64/kernel/smp.c
--- 2.4.17-ia64-kdbv2.1-K3/arch/ia64/kernel/smp.c	Mon Feb  4 12:42:05 2002
+++ 2.4.17-ia64-kdbv2.1-k3y_al2/arch/ia64/kernel/smp.c	Thu Feb 28 19:28:16 2002
@@ -200,6 +200,12 @@
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
diff -urN 2.4.17-ia64-kdbv2.1-K3/arch/ia64/kernel/smpboot.c 2.4.17-ia64-kdbv2.1-k3y_al2/arch/ia64/kernel/smpboot.c
--- 2.4.17-ia64-kdbv2.1-K3/arch/ia64/kernel/smpboot.c	Mon Feb  4 12:41:37 2002
+++ 2.4.17-ia64-kdbv2.1-k3y_al2/arch/ia64/kernel/smpboot.c	Thu Feb 28 19:28:16 2002
@@ -356,6 +356,7 @@
 	local_irq_enable();
 	calibrate_delay();
 	local_cpu_data->loops_per_jiffy = loops_per_jiffy;
+	ia64_disable_timer();
 	/*
 	 * Allow the master to continue.
 	 */
@@ -379,7 +380,8 @@
 	Dprintk("CPU %d is set to go.\n", smp_processor_id());
 	while (!atomic_read(&smp_commenced))
 		;
-
+	/* reenable timer interrupts */
+	ia64_cpu_local_tick();
 	Dprintk("CPU %d is starting idle.\n", smp_processor_id());
 	return cpu_idle();
 }
@@ -416,11 +418,10 @@
 	if (!idle)
 		panic("No idle process for CPU %d", cpu);
 
-	task_set_cpu(idle, cpu);	/* we schedule the first task manually */
+	init_idle(idle, cpu);
 
 	ia64_cpu_to_sapicid[cpu] = sapicid;
 
-	del_from_runqueue(idle);
 	unhash_process(idle);
 	init_tasks[cpu] = idle;
 
@@ -481,8 +482,7 @@
 	printk("Boot processor id 0x%x/0x%x\n", 0, boot_cpu_id);
 
 	global_irq_holder = 0;
-	current->processor = 0;
-	init_idle();
+	current->cpu = 0;
 
 	/*
 	 * If SMP should be disabled, then really disable it!
@@ -569,3 +569,9 @@
 		smp_num_cpus = 1;
 	}
 }
+
+/* Number of ticks we consider an idle tasks still cache-hot.
+ * For Itanium: with 1GB/s bandwidth we need 4ms to fill up 4MB L3 cache...
+ * So let's try 10 ticks.
+ */
+unsigned long cache_decay_ticks;
diff -urN 2.4.17-ia64-kdbv2.1-K3/arch/ia64/kernel/time.c 2.4.17-ia64-kdbv2.1-k3y_al2/arch/ia64/kernel/time.c
--- 2.4.17-ia64-kdbv2.1-K3/arch/ia64/kernel/time.c	Fri Nov  9 23:26:17 2001
+++ 2.4.17-ia64-kdbv2.1-k3y_al2/arch/ia64/kernel/time.c	Thu Feb 28 19:28:16 2002
@@ -209,7 +209,7 @@
 /*
  * Encapsulate access to the itm structure for SMP.
  */
-void __init
+void
 ia64_cpu_local_tick (void)
 {
 	int cpu = smp_processor_id();
@@ -298,3 +298,9 @@
 	efi_gettimeofday((struct timeval *) &xtime);
 	ia64_init_itm();
 }
+
+void __init ia64_disable_timer(void)
+{
+	ia64_set_itv(IA64_TIMER_VECTOR | IA64_TIMER_MASK);
+}
+
diff -urN 2.4.17-ia64-kdbv2.1-K3/arch/ia64/mm/fault.c 2.4.17-ia64-kdbv2.1-k3y_al2/arch/ia64/mm/fault.c
--- 2.4.17-ia64-kdbv2.1-K3/arch/ia64/mm/fault.c	Fri Nov  9 23:26:17 2001
+++ 2.4.17-ia64-kdbv2.1-k3y_al2/arch/ia64/mm/fault.c	Thu Feb 28 19:28:16 2002
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
diff -urN 2.4.17-ia64-kdbv2.1-K3/arch/ia64/mm/tlb.c 2.4.17-ia64-kdbv2.1-k3y_al2/arch/ia64/mm/tlb.c
--- 2.4.17-ia64-kdbv2.1-K3/arch/ia64/mm/tlb.c	Fri Nov  9 23:26:17 2001
+++ 2.4.17-ia64-kdbv2.1-k3y_al2/arch/ia64/mm/tlb.c	Thu Feb 28 19:28:16 2002
@@ -48,6 +48,7 @@
 {
 	unsigned long tsk_context, max_ctx = ia64_ctx.max_ctx;
 	struct task_struct *tsk;
+	int i;
 
 	if (ia64_ctx.next > max_ctx)
 		ia64_ctx.next = 300;	/* skip daemons */
@@ -76,7 +77,11 @@
 			ia64_ctx.limit = tsk_context;
 	}
 	read_unlock(&tasklist_lock);
-	flush_tlb_all();
+	//flush_tlb_all(); /* potential race condition with O(1) scheduler [EF] */
+	for (i=0; i<smp_num_cpus; i++)
+		cpu_data(i)->tlb_flush = 1;
+	__flush_tlb_all();
+	local_cpu_data->tlb_flush = 0;
 }
 
 static inline void
diff -urN 2.4.17-ia64-kdbv2.1-K3/arch/ia64/tools/print_offsets.c 2.4.17-ia64-kdbv2.1-k3y_al2/arch/ia64/tools/print_offsets.c
--- 2.4.17-ia64-kdbv2.1-K3/arch/ia64/tools/print_offsets.c	Fri Nov  9 23:26:17 2001
+++ 2.4.17-ia64-kdbv2.1-k3y_al2/arch/ia64/tools/print_offsets.c	Thu Feb 28 19:28:16 2002
@@ -54,7 +54,7 @@
     { "IA64_TASK_PTRACE_OFFSET",	offsetof (struct task_struct, ptrace) },
     { "IA64_TASK_SIGPENDING_OFFSET",	offsetof (struct task_struct, sigpending) },
     { "IA64_TASK_NEED_RESCHED_OFFSET",	offsetof (struct task_struct, need_resched) },
-    { "IA64_TASK_PROCESSOR_OFFSET",	offsetof (struct task_struct, processor) },
+    { "IA64_TASK_PROCESSOR_OFFSET",	offsetof (struct task_struct, cpu) },
     { "IA64_TASK_THREAD_OFFSET",	offsetof (struct task_struct, thread) },
     { "IA64_TASK_THREAD_KSP_OFFSET",	offsetof (struct task_struct, thread.ksp) },
 #ifdef CONFIG_PERFMON
diff -urN 2.4.17-ia64-kdbv2.1-K3/fs/pipe.c 2.4.17-ia64-kdbv2.1-k3y_al2/fs/pipe.c
--- 2.4.17-ia64-kdbv2.1-K3/fs/pipe.c	Sat Sep 29 03:03:48 2001
+++ 2.4.17-ia64-kdbv2.1-k3y_al2/fs/pipe.c	Thu Feb 28 19:28:16 2002
@@ -115,7 +115,7 @@
 		 * writers synchronously that there is more
 		 * room.
 		 */
-		wake_up_interruptible_sync(PIPE_WAIT(*inode));
+		wake_up_interruptible(PIPE_WAIT(*inode));
 		if (!PIPE_EMPTY(*inode))
 			BUG();
 		goto do_more_read;
@@ -213,7 +213,7 @@
 			 * is going to give up this CPU, so it doesnt have
 			 * to do idle reschedules.
 			 */
-			wake_up_interruptible_sync(PIPE_WAIT(*inode));
+			wake_up_interruptible(PIPE_WAIT(*inode));
 			PIPE_WAITING_WRITERS(*inode)++;
 			pipe_wait(inode);
 			PIPE_WAITING_WRITERS(*inode)--;
diff -urN 2.4.17-ia64-kdbv2.1-K3/include/asm-i386/hw_irq.h 2.4.17-ia64-kdbv2.1-k3y_al2/include/asm-i386/hw_irq.h
--- 2.4.17-ia64-kdbv2.1-K3/include/asm-i386/hw_irq.h	Fri Feb  8 12:02:06 2002
+++ 2.4.17-ia64-kdbv2.1-k3y_al2/include/asm-i386/hw_irq.h	Mon Feb  4 12:41:38 2002
@@ -41,8 +41,7 @@
 #define ERROR_APIC_VECTOR	0xfe
 #define INVALIDATE_TLB_VECTOR	0xfd
 #define RESCHEDULE_VECTOR	0xfc
-#define TASK_MIGRATION_VECTOR	0xfb
-#define CALL_FUNCTION_VECTOR	0xfa
+#define CALL_FUNCTION_VECTOR	0xfb
 
 /*
  * Local APIC timer IRQ vector is on a different priority level,
diff -urN 2.4.17-ia64-kdbv2.1-K3/include/asm-ia64/bitops.h 2.4.17-ia64-kdbv2.1-k3y_al2/include/asm-ia64/bitops.h
--- 2.4.17-ia64-kdbv2.1-K3/include/asm-ia64/bitops.h	Mon Feb  4 12:41:38 2002
+++ 2.4.17-ia64-kdbv2.1-k3y_al2/include/asm-ia64/bitops.h	Thu Feb 28 19:28:16 2002
@@ -280,6 +280,20 @@
 	return result;
 }
 
+/**
+ * __ffs - find first bit in a 64 bit long.
+ *
+ * Undefined if no bit exists, so code should check against 0 first.
+ */
+static inline unsigned long
+__ffs (unsigned long x)
+{
+	unsigned long result;
+
+	__asm__ ("popcnt %0=%1" : "=r" (result) : "r" (~x & (x - 1)));
+	return result;
+}
+
 #ifdef __KERNEL__
 
 /*
@@ -357,6 +371,8 @@
 	tmp = *p;
 found_first:
 	tmp |= ~0UL << size;
+	if (tmp = ~0UL)        /* Are any bits zero? */
+		return result + size; /* Nope. */
 found_middle:
 	return result + ffz(tmp);
 }
@@ -366,8 +382,52 @@
  */
 #define find_first_zero_bit(addr, size) find_next_zero_bit((addr), (size), 0)
 
+/*
+ * Find next bit in a bitmap reasonably efficiently..
+ */
+static inline int
+find_next_bit (void *addr, unsigned long size, unsigned long offset)
+{
+	unsigned long *p = ((unsigned long *) addr) + (offset >> 6);
+	unsigned long result = offset & ~63UL;
+	unsigned long tmp;
+
+	if (offset >= size)
+		return size;
+	size -= result;
+	offset &= 63UL;
+	if (offset) {
+		tmp = *(p++);
+		tmp &= ~0UL << offset;
+		if (size < 64)
+			goto found_first;
+		if (tmp)
+			goto found_middle;
+		size -= 64;
+		result += 64;
+	}
+	while (size & ~63UL) {
+		if ((tmp = *(p++)))
+			goto found_middle;
+		result += 64;
+		size -= 64;
+	}
+	if (!size)
+		return result;
+	tmp = *p;
+found_first:
+	tmp &= ~0UL >> (64-size);
+	if (tmp = 0UL)        /* Are any bits set? */
+		return result + size; /* Nope. */
+found_middle:
+	return result + __ffs(tmp);
+}
+
+#define find_first_bit(addr, size) find_next_bit((addr), (size), 0)
+
 #ifdef __KERNEL__
 
+#define __clear_bit(nr, addr)        clear_bit(nr, addr)
 #define ext2_set_bit                 test_and_set_bit
 #define ext2_clear_bit               test_and_clear_bit
 #define ext2_test_bit                test_bit
diff -urN 2.4.17-ia64-kdbv2.1-K3/include/asm-ia64/hw_irq.h 2.4.17-ia64-kdbv2.1-k3y_al2/include/asm-ia64/hw_irq.h
--- 2.4.17-ia64-kdbv2.1-K3/include/asm-ia64/hw_irq.h	Tue Jul 31 19:30:09 2001
+++ 2.4.17-ia64-kdbv2.1-k3y_al2/include/asm-ia64/hw_irq.h	Thu Feb 28 19:28:16 2002
@@ -65,6 +65,9 @@
         IA64_IPI_DM_EXTINT =    0x7,    /* pend an 8259-compatible interrupt. */
 };
 
+/* bit for masking and discarding timer interrupts on IA64 */
+#define IA64_TIMER_MASK         (1<<16)
+
 extern __u8 isa_irq_to_vector_map[16];
 #define isa_irq_to_vector(x)	isa_irq_to_vector_map[(x)]
 
diff -urN 2.4.17-ia64-kdbv2.1-K3/include/asm-ia64/mmu_context.h 2.4.17-ia64-kdbv2.1-k3y_al2/include/asm-ia64/mmu_context.h
--- 2.4.17-ia64-kdbv2.1-K3/include/asm-ia64/mmu_context.h	Fri Nov  9 23:26:17 2001
+++ 2.4.17-ia64-kdbv2.1-k3y_al2/include/asm-ia64/mmu_context.h	Thu Feb 28 19:28:16 2002
@@ -44,16 +44,34 @@
 {
 }
 
+/* 
+ * When the context counter wraps around all TLBs need to be flushed because
+ * an old context number might have been reused. This is signalled by a bit
+ * set in ia64_ctx.flush, which is checked in the routine below. Called by
+ * activate_mm().                                        <efocht@ess.nec.de>
+ */
+static inline void
+delayed_tlb_flush (void)
+{
+	extern void __flush_tlb_all (void);
+
+	if (unlikely(local_cpu_data->tlb_flush)) {
+		__flush_tlb_all();
+		local_cpu_data->tlb_flush = 0;
+	}
+}
+
 static inline void
 get_new_mmu_context (struct mm_struct *mm)
 {
-	spin_lock(&ia64_ctx.lock);
+	unsigned long flags;
+	spin_lock_irqsave(&ia64_ctx.lock,flags);
 	{
 		if (ia64_ctx.next >= ia64_ctx.limit)
 			wrap_mmu_context(mm);
 		mm->context = ia64_ctx.next++;
 	}
-	spin_unlock(&ia64_ctx.lock);
+	spin_unlock_irqrestore(&ia64_ctx.lock,flags);
 
 }
 
@@ -113,11 +131,28 @@
 	 * We may get interrupts here, but that's OK because interrupt
 	 * handlers cannot touch user-space.
 	 */
+	delayed_tlb_flush();
 	ia64_set_kr(IA64_KR_PT_BASE, __pa(next->pgd));
 	get_mmu_context(next);
 	reload_context(next);
 }
 
+/*
+ * Needed for the O(1) MQ scheduler.
+ */
+#if MAX_PRIO >= 192
+# error update this function. */
+#endif
+
+static inline int sched_find_first_bit(unsigned long *b)
+{
+	if (unlikely(b[0]))
+		return __ffs(b[0]);
+	if (b[1])
+		return 64 + __ffs(b[1]);
+	return __ffs(b[2]) + 128;
+}
+
 #define switch_mm(prev_mm,next_mm,next_task,cpu)	activate_mm(prev_mm, next_mm)
 
 # endif /* ! __ASSEMBLY__ */
diff -urN 2.4.17-ia64-kdbv2.1-K3/include/asm-ia64/pgalloc.h 2.4.17-ia64-kdbv2.1-k3y_al2/include/asm-ia64/pgalloc.h
--- 2.4.17-ia64-kdbv2.1-K3/include/asm-ia64/pgalloc.h	Tue Feb  5 15:33:18 2002
+++ 2.4.17-ia64-kdbv2.1-k3y_al2/include/asm-ia64/pgalloc.h	Thu Feb 28 19:28:16 2002
@@ -160,9 +160,12 @@
 
 #ifdef CONFIG_SMP
   extern void smp_flush_tlb_all (void);
+  extern void smp_flush_tlb_all_nowait (void);
 # define flush_tlb_all()	smp_flush_tlb_all()
+# define flush_tlb_all_nowait()	smp_flush_tlb_all_nowait()
 #else
 # define flush_tlb_all()	__flush_tlb_all()
+# define flush_tlb_all_nowait()	__flush_tlb_all()
 #endif
 
 /*
diff -urN 2.4.17-ia64-kdbv2.1-K3/include/asm-ia64/processor.h 2.4.17-ia64-kdbv2.1-k3y_al2/include/asm-ia64/processor.h
--- 2.4.17-ia64-kdbv2.1-K3/include/asm-ia64/processor.h	Thu Feb 14 13:08:18 2002
+++ 2.4.17-ia64-kdbv2.1-k3y_al2/include/asm-ia64/processor.h	Thu Feb 28 19:28:16 2002
@@ -258,6 +258,7 @@
 	/* CPUID-derived information: */
 	__u64 ppn;
 	__u64 features;
+	__u8 tlb_flush;		/* flush TLB before next context switch if non-zero */
 	__u8 number;
 	__u8 revision;
 	__u8 model;
diff -urN 2.4.17-ia64-kdbv2.1-K3/include/asm-ia64/smp.h 2.4.17-ia64-kdbv2.1-k3y_al2/include/asm-ia64/smp.h
--- 2.4.17-ia64-kdbv2.1-K3/include/asm-ia64/smp.h	Fri Nov  9 23:26:17 2001
+++ 2.4.17-ia64-kdbv2.1-k3y_al2/include/asm-ia64/smp.h	Thu Feb 28 19:28:16 2002
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
 
diff -urN 2.4.17-ia64-kdbv2.1-K3/include/asm-ia64/spinlock.h 2.4.17-ia64-kdbv2.1-k3y_al2/include/asm-ia64/spinlock.h
--- 2.4.17-ia64-kdbv2.1-K3/include/asm-ia64/spinlock.h	Mon Feb  4 12:41:39 2002
+++ 2.4.17-ia64-kdbv2.1-k3y_al2/include/asm-ia64/spinlock.h	Thu Feb 28 19:28:16 2002
@@ -84,7 +84,7 @@
 	"mov r29 = 1\n"						\
 	";;\n"							\
 	"1:\n"							\
-	"ld4.bias r2 = [%0]\n"					\
+	"ld4 r2 = [%0]\n"					\
 	";;\n"							\
 	"cmp4.eq p0,p7 = r0,r2\n"				\
 	"(p7) br.cond.spnt.few 1b \n"				\
diff -urN 2.4.17-ia64-kdbv2.1-K3/include/linux/sched.h 2.4.17-ia64-kdbv2.1-k3y_al2/include/linux/sched.h
--- 2.4.17-ia64-kdbv2.1-K3/include/linux/sched.h	Mon Feb 18 19:05:55 2002
+++ 2.4.17-ia64-kdbv2.1-k3y_al2/include/linux/sched.h	Thu Feb 28 19:28:16 2002
@@ -149,8 +149,7 @@
 extern void update_one_process(task_t *p, unsigned long user,
 			       unsigned long system, int cpu);
 extern void scheduler_tick(int user_tick, int system);
-extern void sched_task_migrated(task_t *p);
-extern void smp_migrate_task(int cpu, task_t *task);
+extern void migration_init(void);
 extern unsigned long cache_decay_ticks;
 
 #define	MAX_SCHEDULE_TIMEOUT	LONG_MAX
@@ -350,6 +349,10 @@
 
 	wait_queue_head_t wait_chldexit;	/* for wait4() */
 	struct completion *vfork_done;		/* for vfork() */
+
+	list_t migration_list;
+	struct semaphore migration_sem;
+
 	unsigned long rt_priority;
 	unsigned long it_real_value, it_prof_value, it_virt_value;
 	unsigned long it_real_incr, it_prof_incr, it_virt_incr;
@@ -444,7 +447,12 @@
  */
 #define _STK_LIM	(8*1024*1024)
 
+#ifdef CONFIG_SMP
 extern void set_cpus_allowed(task_t *p, unsigned long new_mask);
+#else
+# define set_cpus_allowed(p, new_mask) do { } while (0)
+#endif
+
 extern void set_user_nice(task_t *p, long nice);
 extern int task_prio(task_t *p);
 extern int task_nice(task_t *p);
@@ -476,6 +484,8 @@
     mm:			NULL,						\
     active_mm:		&init_mm,					\
     run_list:		LIST_HEAD_INIT(tsk.run_list),			\
+    migration_list:	LIST_HEAD_INIT(tsk.migration_list),		\
+    migration_sem:	__MUTEX_INITIALIZER(tsk.migration_sem),		\
     time_slice:		HZ,						\
     next_task:		&tsk,						\
     prev_task:		&tsk,						\
@@ -571,7 +581,6 @@
 #define CURRENT_TIME (xtime.tv_sec)
 
 extern void FASTCALL(__wake_up(wait_queue_head_t *q, unsigned int mode, int nr));
-extern void FASTCALL(__wake_up_sync(wait_queue_head_t *q, unsigned int mode, int nr));
 extern void FASTCALL(sleep_on(wait_queue_head_t *q));
 extern long FASTCALL(sleep_on_timeout(wait_queue_head_t *q,
 				      signed long timeout));
@@ -585,13 +594,9 @@
 #define wake_up(x)			__wake_up((x),TASK_UNINTERRUPTIBLE | TASK_INTERRUPTIBLE, 1)
 #define wake_up_nr(x, nr)		__wake_up((x),TASK_UNINTERRUPTIBLE | TASK_INTERRUPTIBLE, nr)
 #define wake_up_all(x)			__wake_up((x),TASK_UNINTERRUPTIBLE | TASK_INTERRUPTIBLE, 0)
-#define wake_up_sync(x)			__wake_up_sync((x),TASK_UNINTERRUPTIBLE | TASK_INTERRUPTIBLE, 1)
-#define wake_up_sync_nr(x, nr)		__wake_up_sync((x),TASK_UNINTERRUPTIBLE | TASK_INTERRUPTIBLE, nr)
 #define wake_up_interruptible(x)	__wake_up((x),TASK_INTERRUPTIBLE, 1)
 #define wake_up_interruptible_nr(x, nr)	__wake_up((x),TASK_INTERRUPTIBLE, nr)
 #define wake_up_interruptible_all(x)	__wake_up((x),TASK_INTERRUPTIBLE, 0)
-#define wake_up_interruptible_sync(x)	__wake_up_sync((x),TASK_INTERRUPTIBLE, 1)
-#define wake_up_interruptible_sync_nr(x) __wake_up_sync((x),TASK_INTERRUPTIBLE,  nr)
 asmlinkage long sys_wait4(pid_t pid,unsigned int * stat_addr, int options, struct rusage * ru);
 
 extern int in_group_p(gid_t);
diff -urN 2.4.17-ia64-kdbv2.1-K3/include/linux/smp.h 2.4.17-ia64-kdbv2.1-k3y_al2/include/linux/smp.h
--- 2.4.17-ia64-kdbv2.1-K3/include/linux/smp.h	Fri Feb  8 12:02:06 2002
+++ 2.4.17-ia64-kdbv2.1-k3y_al2/include/linux/smp.h	Thu Feb 28 19:28:16 2002
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
diff -urN 2.4.17-ia64-kdbv2.1-K3/init/main.c 2.4.17-ia64-kdbv2.1-k3y_al2/init/main.c
--- 2.4.17-ia64-kdbv2.1-K3/init/main.c	Fri Feb  8 12:02:06 2002
+++ 2.4.17-ia64-kdbv2.1-k3y_al2/init/main.c	Thu Feb 28 19:28:16 2002
@@ -698,7 +698,12 @@
  */
 static void __init do_basic_setup(void)
 {
-
+	/*
+	 * Let the per-CPU migration threads start up:
+	 */
+#if CONFIG_SMP
+	migration_init();
+#endif
 	/*
 	 * Tell the world that we're going to be the grim
 	 * reaper of innocent orphaned children.
diff -urN 2.4.17-ia64-kdbv2.1-K3/kdb/kdbmain.c 2.4.17-ia64-kdbv2.1-k3y_al2/kdb/kdbmain.c
--- 2.4.17-ia64-kdbv2.1-K3/kdb/kdbmain.c	Mon Feb  4 12:41:04 2002
+++ 2.4.17-ia64-kdbv2.1-k3y_al2/kdb/kdbmain.c	Thu Feb 28 19:28:16 2002
@@ -2344,7 +2344,7 @@
 	for_each_task(p) {
 		kdb_printf("0x%p %08d %08d  %1.1d  %3.3d  %s  0x%p%c%s\n",
 			   (void *)p, p->pid, p->p_pptr->pid,
-			   task_has_cpu(p), p->processor,
+			   task_has_cpu(p), p->cpu,
 			   (p->state = 0)?"run ":(p->state>0)?"stop":"unrn",
 			   (void *)(&p->thread),
 			   (p = current) ? '*': ' ',
diff -urN 2.4.17-ia64-kdbv2.1-K3/kernel/fork.c 2.4.17-ia64-kdbv2.1-k3y_al2/kernel/fork.c
--- 2.4.17-ia64-kdbv2.1-K3/kernel/fork.c	Fri Feb  8 12:02:06 2002
+++ 2.4.17-ia64-kdbv2.1-k3y_al2/kernel/fork.c	Thu Feb 28 19:28:16 2002
@@ -640,6 +640,10 @@
 	{
 		int i;
 
+		if (likely(p->cpus_allowed & (1UL<<smp_processor_id())))
+			p->cpu = smp_processor_id();
+		else
+			p->cpu = __ffs(p->cpus_allowed);
 		/* ?? should we just memset this ?? */
 		for(i = 0; i < smp_num_cpus; i++)
 			p->per_cpu_utime[cpu_logical_map(i)] diff -urN 2.4.17-ia64-kdbv2.1-K3/kernel/ksyms.c 2.4.17-ia64-kdbv2.1-k3y_al2/kernel/ksyms.c
--- 2.4.17-ia64-kdbv2.1-K3/kernel/ksyms.c	Fri Feb  8 12:02:06 2002
+++ 2.4.17-ia64-kdbv2.1-k3y_al2/kernel/ksyms.c	Thu Feb 28 19:28:16 2002
@@ -441,7 +441,6 @@
 /* process management */
 EXPORT_SYMBOL(complete_and_exit);
 EXPORT_SYMBOL(__wake_up);
-EXPORT_SYMBOL(__wake_up_sync);
 EXPORT_SYMBOL(wake_up_process);
 EXPORT_SYMBOL(sleep_on);
 EXPORT_SYMBOL(sleep_on_timeout);
@@ -451,7 +450,9 @@
 EXPORT_SYMBOL(schedule_timeout);
 EXPORT_SYMBOL(sys_sched_yield);
 EXPORT_SYMBOL(set_user_nice);
+#ifdef CONFIG_SMP
 EXPORT_SYMBOL(set_cpus_allowed);
+#endif
 EXPORT_SYMBOL(jiffies);
 EXPORT_SYMBOL(xtime);
 EXPORT_SYMBOL(do_gettimeofday);
diff -urN 2.4.17-ia64-kdbv2.1-K3/kernel/printk.c 2.4.17-ia64-kdbv2.1-k3y_al2/kernel/printk.c
--- 2.4.17-ia64-kdbv2.1-K3/kernel/printk.c	Fri Feb  8 12:02:06 2002
+++ 2.4.17-ia64-kdbv2.1-k3y_al2/kernel/printk.c	Thu Feb 28 19:28:16 2002
@@ -25,6 +25,8 @@
 #include <linux/init.h>
 #include <linux/module.h>
 #include <linux/interrupt.h>			/* For in_interrupt() */
+#include <linux/config.h>
+#include <linux/delay.h>
 
 #include <asm/uaccess.h>
 
diff -urN 2.4.17-ia64-kdbv2.1-K3/kernel/sched.c 2.4.17-ia64-kdbv2.1-k3y_al2/kernel/sched.c
--- 2.4.17-ia64-kdbv2.1-K3/kernel/sched.c	Fri Feb  8 12:02:06 2002
+++ 2.4.17-ia64-kdbv2.1-k3y_al2/kernel/sched.c	Thu Feb 28 19:53:58 2002
@@ -125,8 +125,6 @@
 
 struct prio_array {
 	int nr_active;
-	spinlock_t *lock;
-	runqueue_t *rq;
 	unsigned long bitmap[BITMAP_SIZE];
 	list_t queue[MAX_PRIO];
 };
@@ -144,6 +142,8 @@
 	task_t *curr, *idle;
 	prio_array_t *active, *expired, arrays[2];
 	int prev_nr_running[NR_CPUS];
+	task_t *migration_thread;
+	list_t migration_queue;
 } ____cacheline_aligned;
 
 static struct runqueue runqueues[NR_CPUS] __cacheline_aligned;
@@ -154,21 +154,30 @@
 #define cpu_curr(cpu)		(cpu_rq(cpu)->curr)
 #define rt_task(p)		((p)->prio < MAX_RT_PRIO)
 
-static inline runqueue_t *lock_task_rq(task_t *p, unsigned long *flags)
+/* needed on IA64, arch/ia64/kernel/head.S relies on it (EF) */
+struct task_struct * init_tasks[NR_CPUS] __initdata = {&init_task, };
+
+/* needed in kdb (EF) */
+int task_has_cpu(task_t *p)
+{
+	return (p = task_rq(p)->curr);
+}
+
+static inline runqueue_t *task_rq_lock(task_t *p, unsigned long *flags)
 {
-	struct runqueue *__rq;
+	struct runqueue *rq;
 
 repeat_lock_task:
-	__rq = task_rq(p);
-	spin_lock_irqsave(&__rq->lock, *flags);
-	if (unlikely(__rq != task_rq(p))) {
-		spin_unlock_irqrestore(&__rq->lock, *flags);
+	rq = task_rq(p);
+	spin_lock_irqsave(&rq->lock, *flags);
+	if (unlikely(rq != task_rq(p))) {
+		spin_unlock_irqrestore(&rq->lock, *flags);
 		goto repeat_lock_task;
 	}
-	return __rq;
+	return rq;
 }
 
-static inline void unlock_task_rq(runqueue_t *rq, unsigned long *flags)
+static inline void task_rq_unlock(runqueue_t *rq, unsigned long *flags)
 {
 	spin_unlock_irqrestore(&rq->lock, *flags);
 }
@@ -179,7 +188,7 @@
 static inline void dequeue_task(struct task_struct *p, prio_array_t *array)
 {
 	array->nr_active--;
-	list_del_init(&p->run_list);
+	list_del(&p->run_list);
 	if (list_empty(array->queue + p->prio))
 		__clear_bit(p->prio, array->bitmap);
 }
@@ -275,26 +284,12 @@
 		cpu_relax();
 		barrier();
 	}
-	rq = lock_task_rq(p, &flags);
+	rq = task_rq_lock(p, &flags);
 	if (unlikely(rq->curr = p)) {
-		unlock_task_rq(rq, &flags);
+		task_rq_unlock(rq, &flags);
 		goto repeat;
 	}
-	unlock_task_rq(rq, &flags);
-}
-
-/*
- * The SMP message passing code calls this function whenever
- * the new task has arrived at the target CPU. We move the
- * new task into the local runqueue.
- *
- * This function must be called with interrupts disabled.
- */
-void sched_task_migrated(task_t *new_task)
-{
-	wait_task_inactive(new_task);
-	new_task->cpu = smp_processor_id();
-	wake_up_process(new_task);
+	task_rq_unlock(rq, &flags);
 }
 
 /*
@@ -321,33 +316,34 @@
  * "current->state = TASK_RUNNING" to mark yourself runnable
  * without the overhead of this.
  */
-static int try_to_wake_up(task_t * p, int synchronous)
+static int try_to_wake_up(task_t * p)
 {
 	unsigned long flags;
 	int success = 0;
 	runqueue_t *rq;
 
-	rq = lock_task_rq(p, &flags);
+	rq = task_rq_lock(p, &flags);
 	p->state = TASK_RUNNING;
 	if (!p->array) {
 		activate_task(p, rq);
-		if ((rq->curr = rq->idle) || (p->prio < rq->curr->prio))
+		if (p->prio < rq->curr->prio)
 			resched_task(rq->curr);
 		success = 1;
 	}
-	unlock_task_rq(rq, &flags);
+	task_rq_unlock(rq, &flags);
 	return success;
 }
 
 int wake_up_process(task_t * p)
 {
-	return try_to_wake_up(p, 0);
+	return try_to_wake_up(p);
 }
 
 void wake_up_forked_process(task_t * p)
 {
 	runqueue_t *rq = this_rq();
 
+	spin_lock_irq(&rq->lock);
 	p->state = TASK_RUNNING;
 	if (!rt_task(p)) {
 		/*
@@ -359,10 +355,11 @@
 		p->sleep_avg = p->sleep_avg * CHILD_PENALTY / 100;
 		p->prio = effective_prio(p);
 	}
-	spin_lock_irq(&rq->lock);
+	INIT_LIST_HEAD(&p->migration_list);
 	p->cpu = smp_processor_id();
 	activate_task(p, rq);
 	spin_unlock_irq(&rq->lock);
+	init_MUTEX(&p->migration_sem);
 }
 
 /*
@@ -390,12 +387,12 @@
 			p->sleep_avg) / (EXIT_WEIGHT + 1);
 }
 
-#if CONFIG_SMP
 asmlinkage void schedule_tail(task_t *prev)
 {
+#if CONFIG_SMP
 	spin_unlock_irq(&this_rq()->lock);
-}
 #endif
+}
 
 static inline void context_switch(task_t *prev, task_t *next)
 {
@@ -671,7 +668,7 @@
 	task_t *p = current;
 
 	if (p = rq->idle) {
-		if (local_bh_count(cpu) || local_irq_count(cpu) > 1)
+		if (really_local_bh_count() || really_local_irq_count() > 1)
 			kstat.per_cpu_system[cpu] += system;
 #if CONFIG_SMP
 		idle_tick();
@@ -826,44 +823,32 @@
  * started to run but is not in state TASK_RUNNING.  try_to_wake_up() returns
  * zero in this (rare) case, and we handle it by continuing to scan the queue.
  */
-static inline void __wake_up_common (wait_queue_head_t *q, unsigned int mode,
-			 	     int nr_exclusive, const int sync)
+static inline void __wake_up_common (wait_queue_head_t *q, unsigned int mode,int nr_exclusive)
 {
 	struct list_head *tmp;
+	unsigned int state;
+	wait_queue_t *curr;
 	task_t *p;
 
-	list_for_each(tmp,&q->task_list) {
-		unsigned int state;
-		wait_queue_t *curr = list_entry(tmp, wait_queue_t, task_list);
-
+	list_for_each(tmp, &q->task_list) {
+		curr = list_entry(tmp, wait_queue_t, task_list);
 		p = curr->task;
 		state = p->state;
-		if ((state & mode) &&
-				try_to_wake_up(p, sync) &&
-				((curr->flags & WQ_FLAG_EXCLUSIVE) &&
-					!--nr_exclusive))
-			break;
+		if ((state & mode) && try_to_wake_up(p) &&
+			((curr->flags & WQ_FLAG_EXCLUSIVE) && !--nr_exclusive))
+				break;
 	}
 }
 
-void __wake_up(wait_queue_head_t *q, unsigned int mode, int nr)
+void __wake_up(wait_queue_head_t *q, unsigned int mode, int nr_exclusive)
 {
-	if (q) {
-		unsigned long flags;
-		wq_read_lock_irqsave(&q->lock, flags);
-		__wake_up_common(q, mode, nr, 0);
-		wq_read_unlock_irqrestore(&q->lock, flags);
-	}
-}
+	unsigned long flags;
+	if (unlikely(!q))
+		return;
 
-void __wake_up_sync(wait_queue_head_t *q, unsigned int mode, int nr)
-{
-	if (q) {
-		unsigned long flags;
-		wq_read_lock_irqsave(&q->lock, flags);
-		__wake_up_common(q, mode, nr, 1);
-		wq_read_unlock_irqrestore(&q->lock, flags);
-	}
+	wq_read_lock_irqsave(&q->lock, flags);
+	__wake_up_common(q, mode, nr_exclusive);
+	wq_read_unlock_irqrestore(&q->lock, flags);
 }
 
 void complete(struct completion *x)
@@ -872,7 +857,7 @@
 
 	spin_lock_irqsave(&x->wait.lock, flags);
 	x->done++;
-	__wake_up_common(&x->wait, TASK_UNINTERRUPTIBLE | TASK_INTERRUPTIBLE, 1, 0);
+	__wake_up_common(&x->wait, TASK_UNINTERRUPTIBLE | TASK_INTERRUPTIBLE, 1);
 	spin_unlock_irqrestore(&x->wait.lock, flags);
 }
 
@@ -959,34 +944,6 @@
 	return timeout;
 }
 
-/*
- * Change the current task's CPU affinity. Migrate the process to a
- * proper CPU and schedule away if the current CPU is removed from
- * the allowed bitmask.
- */
-void set_cpus_allowed(task_t *p, unsigned long new_mask)
-{
-	new_mask &= cpu_online_map;
-	if (!new_mask)
-		BUG();
-	if (p != current)
-		BUG();
-
-	p->cpus_allowed = new_mask;
-	/*
-	 * Can the task run on the current CPU? If not then
-	 * migrate the process off to a proper CPU.
-	 */
-	if (new_mask & (1UL << smp_processor_id()))
-		return;
-#if CONFIG_SMP
-	current->state = TASK_UNINTERRUPTIBLE;
-	smp_migrate_task(__ffs(new_mask), current);
-
-	schedule();
-#endif
-}
-
 void scheduling_functions_end_here(void) { }
 
 void set_user_nice(task_t *p, long nice)
@@ -1001,7 +958,7 @@
 	 * We have to be careful, if called from sys_setpriority(),
 	 * the task might be in the middle of scheduling on another CPU.
 	 */
-	rq = lock_task_rq(p, &flags);
+	rq = task_rq_lock(p, &flags);
 	if (rt_task(p)) {
 		p->static_prio = NICE_TO_PRIO(nice);
 		goto out_unlock;
@@ -1021,7 +978,7 @@
 			resched_task(rq->curr);
 	}
 out_unlock:
-	unlock_task_rq(rq, &flags);
+	task_rq_unlock(rq, &flags);
 }
 
 #ifndef __alpha__
@@ -1114,7 +1071,7 @@
 	 * To be able to change p->policy safely, the apropriate
 	 * runqueue lock must be held.
 	 */
-	rq = lock_task_rq(p, &flags);
+	rq = task_rq_lock(p, &flags);
 
 	if (policy < 0)
 		policy = p->policy;
@@ -1157,7 +1114,7 @@
 		activate_task(p, task_rq(p));
 
 out_unlock:
-	unlock_task_rq(rq, &flags);
+	task_rq_unlock(rq, &flags);
 out_unlock_tasklist:
 	read_unlock_irq(&tasklist_lock);
 
@@ -1229,64 +1186,26 @@
 
 asmlinkage long sys_sched_yield(void)
 {
-	task_t *prev = current, *next;
 	runqueue_t *rq = this_rq();
 	prio_array_t *array;
-	list_t *queue;
-
-	if (unlikely(prev->state != TASK_RUNNING)) {
-		schedule();
-		return 0;
-	}
-	release_kernel_lock(prev, smp_processor_id());
-	prev->sleep_timestamp = jiffies;
-	/*
-	 * Decrease the yielding task's priority by one, to avoid
-	 * livelocks. This priority loss is temporary, it's recovered
-	 * once the current timeslice expires.
-	 *
-	 * If priority is already MAX_PRIO-1 then we still
-	 * roundrobin the task within the runlist.
-	 */
+ 
+       /*
+	* Decrease the yielding task's priority by one, to avoid
+	* livelocks. This priority loss is temporary, it's recovered
+	* once the current timeslice expires.
+	*
+	* If priority is already MAX_PRIO-1 then we still
+	* roundrobin the task within the runlist.
+	*/
 	spin_lock_irq(&rq->lock);
 	array = current->array;
-	/*
-	 * If the task has reached maximum priority (or is a RT task)
-	 * then just requeue the task to the end of the runqueue:
-	 */
-	if (likely(current->prio = MAX_PRIO-1 || rt_task(current))) {
-		list_del(&current->run_list);
-		list_add_tail(&current->run_list, array->queue + current->prio);
-	} else {
-		list_del(&current->run_list);
-		if (list_empty(array->queue + current->prio))
-			__clear_bit(current->prio, array->bitmap);
-		current->prio++;
-		list_add_tail(&current->run_list, array->queue + current->prio);
-		__set_bit(current->prio, array->bitmap);
-	}
-	/*
-	 * Context-switch manually. This is equivalent to
-	 * calling schedule(), but faster, because yield()
-	 * knows lots of things that can be optimized away
-	 * from the generic scheduler path:
-	 */
-	queue = array->queue + sched_find_first_bit(array->bitmap);
-	next = list_entry(queue->next, task_t, run_list);
-	prefetch(next);
-
-	prev->need_resched = 0;
-	if (likely(prev != next)) {
-		rq->nr_switches++;
-		rq->curr = next;
-		context_switch(prev, next);
-		barrier();
-		rq = this_rq();
-	}
+	dequeue_task(current, array);
+	if (likely(!rt_task(current)))
+		if (current->prio < MAX_PRIO-1)
+			current->prio++;
+	enqueue_task(current, array);
 	spin_unlock_irq(&rq->lock);
-
-	reacquire_kernel_lock(current);
-
+	schedule();
 	return 0;
 }
 
@@ -1460,7 +1379,7 @@
 
 void __init init_idle(task_t *idle, int cpu)
 {
-	runqueue_t *idle_rq = cpu_rq(cpu), *rq = idle->array->rq;
+	runqueue_t *idle_rq = cpu_rq(cpu), *rq = cpu_rq(idle->cpu);
 	unsigned long flags;
 
 	__save_flags(flags);
@@ -1492,14 +1411,13 @@
 		runqueue_t *rq = cpu_rq(i);
 		prio_array_t *array;
 
-		rq->active = rq->arrays + 0;
+		rq->active = rq->arrays;
 		rq->expired = rq->arrays + 1;
 		spin_lock_init(&rq->lock);
+		INIT_LIST_HEAD(&rq->migration_queue);
 
 		for (j = 0; j < 2; j++) {
 			array = rq->arrays + j;
-			array->rq = rq;
-			array->lock = &rq->lock;
 			for (k = 0; k < MAX_PRIO; k++) {
 				INIT_LIST_HEAD(array->queue + k);
 				__clear_bit(k, array->bitmap);
@@ -1528,3 +1446,177 @@
 	atomic_inc(&init_mm.mm_count);
 	enter_lazy_tlb(&init_mm, current, smp_processor_id());
 }
+
+#if CONFIG_SMP
+
+/*
+ * This is how migration works:
+ *
+ * 1) we queue a migration_req_t structure in the source CPU's
+ *    runqueue and wake up that CPU's migration thread.
+ * 2) we down() the locked semaphore => thread blocks.
+ * 3) migration thread wakes up (implicitly it forces the migrated
+ *    thread off the CPU)
+ * 4) it gets the migration request and checks whether the migrated
+ *    task is still in the wrong runqueue.
+ * 5) if it's in the wrong runqueue then the migration thread removes
+ *    it and puts it into the right queue.
+ * 6) migration thread up()s the semaphore.
+ * 7) we wake up and the migration is done.
+ */
+
+typedef struct {
+	list_t list;
+	task_t *task;
+	struct semaphore sem;
+} migration_req_t;
+
+/*
+ * Change a given task's CPU affinity. Migrate the process to a
+ * proper CPU and schedule it away if the CPU it's executing on
+ * is removed from the allowed bitmask.
+ *
+ * NOTE: the caller must have a valid reference to the task, the
+ * task must not exit() & deallocate itself prematurely.
+ */
+void set_cpus_allowed(task_t *p, unsigned long new_mask)
+{
+	unsigned long flags;
+	migration_req_t req;
+	runqueue_t *rq;
+
+	new_mask &= cpu_online_map;
+	if (!new_mask)
+		BUG();
+
+	rq = task_rq_lock(p, &flags);
+	p->cpus_allowed = new_mask;
+	/*
+	 * Can the task run on the task's current CPU? If not then
+	 * migrate the process off to a proper CPU.
+	 */
+	if (new_mask & (1UL << p->cpu)) {
+		task_rq_unlock(rq, &flags);
+		return;
+	}
+
+	init_MUTEX_LOCKED(&req.sem);
+	req.task = p;
+	list_add(&req.list, &rq->migration_queue);
+	task_rq_unlock(rq, &flags);
+	wake_up_process(rq->migration_thread);
+
+	down(&req.sem);
+}
+
+static volatile unsigned long migration_mask;
+
+static int migration_thread(void * unused)
+{
+	struct sched_param param = { sched_priority: 99 };
+	runqueue_t *rq;
+	int ret;
+
+	daemonize();
+	sigfillset(&current->blocked);
+	set_fs(KERNEL_DS);
+	ret = setscheduler(0, SCHED_FIFO, &param);
+
+	/*
+	 * We have to migrate manually - there is no migration thread
+	 * to do this for us yet :-)
+	 *
+	 * We use the following property of the Linux scheduler. At
+	 * this point no other task is running, so by keeping all
+	 * migration threads running, the load-balancer will distribute
+	 * them between all CPUs equally. At that point every migration
+	 * task binds itself to the current CPU.
+	 */
+
+	/* wait for all migration threads to start up. */
+	while (!migration_mask)
+		yield();
+
+	for (;;) {
+		if (test_and_clear_bit(smp_processor_id(), &migration_mask))
+			current->cpus_allowed = 1 << smp_processor_id();
+		if (current->need_resched)
+			schedule();
+		if (!migration_mask)
+			break;
+	}
+	rq = this_rq();
+	rq->migration_thread = current;
+
+	sprintf(current->comm, "migration_CPU%d", smp_processor_id());
+
+	for (;;) {
+		runqueue_t *rq_src, *rq_dest;
+		struct list_head *head;
+		int cpu_src, cpu_dest;
+		migration_req_t *req;
+		unsigned long flags;
+		task_t *p;
+
+		spin_lock_irqsave(&rq->lock, flags);
+		head = &rq->migration_queue;
+		current->state = TASK_INTERRUPTIBLE;
+		if (list_empty(head)) {
+			spin_unlock_irqrestore(&rq->lock, flags);
+			schedule();
+			continue;
+		}
+		req = list_entry(head->next, migration_req_t, list);
+		list_del_init(head->next);
+		spin_unlock_irqrestore(&rq->lock, flags);
+
+		p = req->task;
+		cpu_dest = __ffs(p->cpus_allowed);
+		rq_dest = cpu_rq(cpu_dest);
+repeat:
+		cpu_src = p->cpu;
+		rq_src = cpu_rq(cpu_src);
+		
+		local_irq_save(flags);
+		double_rq_lock(rq_src, rq_dest);
+		if (p->cpu != cpu_src) {
+			double_rq_unlock(rq_src, rq_dest);
+			local_irq_restore(flags);
+			goto repeat;
+		}
+		if (rq_src = rq) {
+			p->cpu = cpu_dest;
+			if (p->array) {
+				deactivate_task(p, rq_src);
+				activate_task(p, rq_dest);
+			}
+		}
+		double_rq_unlock(rq_src, rq_dest);
+		local_irq_restore(flags);
+
+		up(&req->sem);
+	}
+}
+
+void __init migration_init(void)
+{
+	int cpu;
+
+	for (cpu = 0; cpu < smp_num_cpus; cpu++) {
+		current->cpus_allowed = 1UL << cpu_logical_map(cpu);
+		if (kernel_thread(migration_thread, NULL,
+				CLONE_FS | CLONE_FILES | CLONE_SIGNAL) < 0)
+			BUG();
+		else
+			current->cpus_allowed = -1L;
+	}
+
+	migration_mask = (1 << smp_num_cpus) - 1;
+
+	for (cpu = 0; cpu < smp_num_cpus; cpu++)
+		while (!cpu_rq(cpu)->migration_thread)
+			schedule_timeout(2);
+	if (migration_mask)
+		BUG();
+}
+#endif
diff -urN 2.4.17-ia64-kdbv2.1-K3/kernel/timer.c 2.4.17-ia64-kdbv2.1-k3y_al2/kernel/timer.c
--- 2.4.17-ia64-kdbv2.1-K3/kernel/timer.c	Fri Feb  8 12:02:06 2002
+++ 2.4.17-ia64-kdbv2.1-k3y_al2/kernel/timer.c	Thu Feb 28 19:28:17 2002
@@ -584,18 +584,7 @@
 	int cpu = smp_processor_id(), system = user_tick ^ 1;
 
 	update_one_process(p, user_tick, system, cpu);
-	if (p->pid) {
-		if (--p->counter <= 0) {
-			p->counter = 0;
-			p->need_resched = 1;
-		}
-		if (p->nice > 0)
-			kstat.per_cpu_nice[cpu] += user_tick;
-		else
-			kstat.per_cpu_user[cpu] += user_tick;
-		kstat.per_cpu_system[cpu] += system;
-	} else if (really_local_bh_count() || really_local_irq_count() > 1)
-		kstat.per_cpu_system[cpu] += system;
+	scheduler_tick(user_tick, system);
 }
 
 /*


