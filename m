From: David Mosberger <davidm@hpl.hp.com>
Date: Tue, 09 Jan 2001 09:48:10 +0000
Subject: [Linux-ia64] kernel update (relative to 2.4.0)
Message-Id: <marc-linux-ia64-105590678205894@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The latest IA-64 patch is now available at:

 ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/

in file linux-2.4.0-ia64-010109.diff*

What changed since last time:

 o Stephane's latest perfmon support
 o Asit: update SAL header file for v3.0 and update MCA code accordingly.
 o Jonathan Nicklin: Move IPI operation word into per-CPU data
   structure to avoid cache line bouncing.
 o Sync up with BJ Numa's latest qla1280/12160 SCSI driver
 o Updates for 2.4.0, including new-style Makefiles.
 o Fix & clean up IA-32 version of execve() (Don, you may want to double
   check this, though it does work well for me.)
 o Clean up interrupt register initialization (and do it on all CPUs, not
   just the boot processor)
 o Use a "lazy execute bit" approach in the PTEs to avoid flushing the cache
   for newly created anonymous pages.
 o Be more strict about enforcing the rule that no vm-area may cross
   unimplemented address space.  Also enforce 4GB addr limit for 32-bit
   processes.
 o Serialize SAL calls even on UP; also on MP interrupts are now disabled
   while we're in a SAL call (again to enforce serialization)

This kernel has been tested on Lions, Big Surs, and the HP simulator.
In particular, I used it to compile kernels on a 4-way machine for
hours and hours with a concurrency level of five and didn't encounter
any problems, so I believe it to be fairly solid.  But as always YMMV.

Enjoy,

	--david

PS: As always, the diff below is only a (very rough) approximation of
    what changed since the last IA-64 patch.  To get the real sources,
    get Linus's 2.4.0 tree and apply the above patch on top of it.

diff -urN linux-davidm/arch/ia64/Makefile linux-2.4.0-lia/arch/ia64/Makefile
--- linux-davidm/arch/ia64/Makefile	Tue Jan  9 00:09:50 2001
+++ linux-2.4.0-lia/arch/ia64/Makefile	Mon Jan  8 23:37:12 2001
@@ -5,7 +5,7 @@
 # License.  See the file "COPYING" in the main directory of this archive
 # for more details.
 #
-# Copyright (C) 1998-2000 by David Mosberger-Tang <davidm@hpl.hp.com>
+# Copyright (C) 1998-2001 by David Mosberger-Tang <davidm@hpl.hp.com>
 #
 
 NM := $(CROSS_COMPILE)nm -B
@@ -53,7 +53,7 @@
 endif
 
 ifdef CONFIG_IA64_SGI_SN1
-CFLAGS += -DBRINGUP
+	CFLAGS		+= -DBRINGUP
         SUBDIRS         :=      arch/$(ARCH)/sn/sn1	\
 				arch/$(ARCH)/sn		\
 				arch/$(ARCH)/sn/io	\
@@ -120,8 +120,6 @@
 	@$(MAKEBOOT) srmboot
 
 archclean:
-	@$(MAKE) -C arch/$(ARCH)/kernel clean
-	@$(MAKE) -C arch/$(ARCH)/tools clean
 	@$(MAKEBOOT) clean
 
 archmrproper:
diff -urN linux-davidm/arch/ia64/config.in linux-2.4.0-lia/arch/ia64/config.in
--- linux-davidm/arch/ia64/config.in	Tue Jan  9 00:09:50 2001
+++ linux-2.4.0-lia/arch/ia64/config.in	Mon Jan  8 23:37:40 2001
@@ -18,6 +18,7 @@
 comment 'General setup'
 
 define_bool CONFIG_IA64 y
+define_int  CONFIG_IA64_L1_CACHE_SHIFT	6	# align cache-sensitive data structure to 64 bytes
 
 define_bool CONFIG_ISA n
 define_bool CONFIG_EISA n
diff -urN linux-davidm/arch/ia64/dig/setup.c linux-2.4.0-lia/arch/ia64/dig/setup.c
--- linux-davidm/arch/ia64/dig/setup.c	Tue Jan  9 00:09:50 2001
+++ linux-2.4.0-lia/arch/ia64/dig/setup.c	Mon Oct 30 22:28:55 2000
@@ -95,14 +95,3 @@
 	outb(0xff, 0xA1);
 	outb(0xff, 0x21);
 }
-
-void
-dig_irq_init (void)
-{
-	/*
-	 * Disable the compatibility mode interrupts (8259 style), needs IN/OUT support
-	 * enabled.
-	 */
-	outb(0xff, 0xA1);
-	outb(0xff, 0x21);
-}
diff -urN linux-davidm/arch/ia64/ia32/binfmt_elf32.c linux-2.4.0-lia/arch/ia64/ia32/binfmt_elf32.c
--- linux-davidm/arch/ia64/ia32/binfmt_elf32.c	Tue Jan  9 00:09:50 2001
+++ linux-2.4.0-lia/arch/ia64/ia32/binfmt_elf32.c	Mon Jan  8 23:37:53 2001
@@ -98,6 +95,7 @@
 
 	current->thread.map_base  =  0x40000000;
 	current->thread.task_size =  0xc0000000;	/* use what Linux/x86 uses... */
+	set_fs(USER_DS);				/* set addr limit for new TASK_SIZE */
  
 	/* setup ia32 state for ia32_load_state */
 
diff -urN linux-davidm/arch/ia64/ia32/sys_ia32.c linux-2.4.0-lia/arch/ia64/ia32/sys_ia32.c
--- linux-davidm/arch/ia64/ia32/sys_ia32.c	Tue Jan  9 00:09:51 2001
+++ linux-2.4.0-lia/arch/ia64/ia32/sys_ia32.c	Mon Jan  8 23:38:02 2001
@@ -68,85 +68,77 @@
 extern asmlinkage long sys_mprotect (unsigned long, size_t, unsigned long);
 
 static int
-nargs(unsigned int arg, char **ap)
+nargs (unsigned int arg, char **ap)
 {
 	int n, err, addr;
 
+	if (!arg)
+		return 0;
+
 	n = 0;
 	do {
 		err = get_user(addr, (int *)A(arg));
 		if (err)
 			return err;
-		if (ap) {		/* no access_ok needed, we allocated */
-			err = __put_user((char *)A(addr), ap++);
-			if (err)
-				return err;
-		}
+		if (ap)
+			*ap++ = (char *) A(addr);
 		arg += sizeof(unsigned int);
 		n++;
 	} while (addr);
-	return(n - 1);
+	return n - 1;
 }
 
 asmlinkage long
-sys32_execve(
-char *filename,
-unsigned int argv,
-unsigned int envp,
-int dummy3,
-int dummy4,
-int dummy5,
-int dummy6,
-int dummy7,
-int stack)
+sys32_execve (char *filename, unsigned int argv, unsigned int envp,
+	      int dummy3, int dummy4, int dummy5, int dummy6, int dummy7,
+	      int stack)
 {
 	struct pt_regs *regs = (struct pt_regs *)&stack;
+	unsigned long old_map_base, old_task_size;
 	char **av, **ae;
 	int na, ne, len;
 	long r;
 
 	na = nargs(argv, NULL);
 	if (na < 0)
-		return(na);
+		return na;
 	ne = nargs(envp, NULL);
 	if (ne < 0)
-		return(ne);
+		return ne;
 	len = (na + ne + 2) * sizeof(*av);
-	/*
-	 *  kmalloc won't work because the `sys_exec' code will attempt
-	 *  to do a `get_user' on the arg list and `get_user' will fail
-	 *  on a kernel address (simplifies `get_user').  Instead we
-	 *  do an mmap to get a user address.  Note that since a successful
-	 *  `execve' frees all current memory we only have to do an
-	 *  `munmap' if the `execve' failes.
-	 */
-	down(&current->mm->mmap_sem);
-
-	av = (char **) do_mmap_pgoff(0, 0UL, len, PROT_READ | PROT_WRITE,
-				     MAP_PRIVATE | MAP_ANONYMOUS, 0);
-
-	up(&current->mm->mmap_sem);
+	av = kmalloc(len, GFP_KERNEL);
+	if (!av)
+		return -ENOMEM;
 
-	if (IS_ERR(av))
-		return (long)av;
 	ae = av + na + 1;
-	r = __put_user(0, (av + na));
-	if (r)
-		goto out;
-	r = __put_user(0, (ae + ne));
-	if (r)
-		goto out;
+	av[na] = NULL;
+	ae[ne] = NULL;
+
 	r = nargs(argv, av);
 	if (r < 0)
 		goto out;
 	r = nargs(envp, ae);
 	if (r < 0)
 		goto out;
+
+	old_map_base  = current->thread.map_base;
+	old_task_size = current->thread.task_size;
+
+	/* we may be exec'ing a 64-bit process: reset map base & task-size: */
+	current->thread.map_base  = DEFAULT_MAP_BASE;
+	current->thread.task_size = DEFAULT_TASK_SIZE;
+
+	set_fs(KERNEL_DS);
 	r = sys_execve(filename, av, ae, regs);
-	if (r < 0)
-out:
-		sys_munmap((unsigned long) av, len);
-	return(r);
+	if (r < 0) {
+		/* oops, execve failed, switch back to old map base & task-size: */
+		current->thread.map_base  = old_map_base;
+		current->thread.task_size = old_task_size;
+	  out:
+		kfree(av);
+	}
+	set_fs(USER_DS);	/* establish new task-size as the address-limit */
+	return r;
 }
 
 static inline int
@@ -179,7 +171,7 @@
 	struct stat s;
 	mm_segment_t old_fs = get_fs();
 	
-	set_fs (KERNEL_DS);
+	set_fs(KERNEL_DS);
 	ret = sys_newstat(filename, &s);
 	set_fs (old_fs);
 	if (putstat (statbuf, &s))
diff -urN linux-davidm/arch/ia64/kernel/Makefile linux-2.4.0-lia/arch/ia64/kernel/Makefile
--- linux-davidm/arch/ia64/kernel/Makefile	Tue Jan  9 00:09:51 2001
+++ linux-2.4.0-lia/arch/ia64/kernel/Makefile	Mon Jan  8 23:39:04 2001
@@ -11,7 +11,9 @@
 
 O_TARGET := kernel.o
 
-obj-y := acpi.o entry.o gate.o efi.o efi_stub.o irq.o irq_ia64.o irq_sapic.o ivt.o \
+export-objs := ia64_ksyms.o
+
+obj-y := acpi.o entry.o gate.o efi.o efi_stub.o ia64_ksyms.o irq.o irq_ia64.o irq_sapic.o ivt.o \
 	 machvec.o pal.o process.o perfmon.o ptrace.o sal.o semaphore.o setup.o	\
 	 signal.o sys_ia64.o traps.o time.o unaligned.o unwind.o
 obj-$(CONFIG_IA64_GENERIC) += machvec.o iosapic.o
@@ -21,9 +23,5 @@
 obj-$(CONFIG_SMP) += smp.o smpboot.o
 obj-$(CONFIG_IA64_MCA) += mca.o mca_asm.o
 obj-$(CONFIG_IA64_BRL_EMU) += brl_emu.o
-
-export-objs := ia64_ksyms.o
-
-clean::
 
 include $(TOPDIR)/Rules.make
diff -urN linux-davidm/arch/ia64/kernel/entry.S linux-2.4.0-lia/arch/ia64/kernel/entry.S
--- linux-davidm/arch/ia64/kernel/entry.S	Tue Jan  9 00:09:51 2001
+++ linux-2.4.0-lia/arch/ia64/kernel/entry.S	Mon Jan  8 23:39:39 2001
@@ -586,21 +573,30 @@
 back_from_resched:
 	{ .mii
 	  adds r2=IA64_TASK_NEED_RESCHED_OFFSET,r13
-	  mov r3=ip
+	  mov r3=ip					// r3 <- &back_from_resched
 	  adds r14=IA64_TASK_SIGPENDING_OFFSET,r13
 	}
+#ifdef CONFIG_PERFMON
+	adds r15=IA64_TASK_PFM_NOTIFY,r13
+#endif
 	;;
+#ifdef CONFIG_PERFMON
+	ld8 r15=[r15]
+#endif
 	ld8 r2=[r2]
 	ld4 r14=[r14]
 	mov rp=r3			// arrange for schedule() to return to back_from_resched
 	;;
-	cmp.ne p6,p0=r2,r0
 	cmp.ne p2,p0=r14,r0		// NOTE: pKern is an alias for p2!!
-	srlz.d
-(p6)	br.call.spnt.many b6=invoke_schedule	// ignore return value
-2:
-	// check & deliver pending signals:
-(p2)	br.call.spnt.few rp=handle_signal_delivery
+#ifdef CONFIG_PERFMON
+	cmp.ne p6,p0=r15,r0		// current->task.pfm_notify != 0?
+#endif
+	cmp.ne p7,p0=r2,r0		// current->need_resched != 0?
+#ifdef CONFIG_PERFMON
+(p6)	br.call.spnt.many b6=pfm_overflow_notify
+#endif
+(p7)	br.call.spnt.many b7=invoke_schedule
+(p2)	br.call.spnt.many rp=handle_signal_delivery	// check & deliver pending signals
 .ret9:
 #ifdef CONFIG_IA64_SOFTSDV_HACKS
 	// Check for lost ticks
diff -urN linux-davidm/arch/ia64/kernel/ia64_ksyms.c linux-2.4.0-lia/arch/ia64/kernel/ia64_ksyms.c
--- linux-davidm/arch/ia64/kernel/ia64_ksyms.c	Tue Jan  9 00:09:51 2001
+++ linux-2.4.0-lia/arch/ia64/kernel/ia64_ksyms.c	Mon Jan  8 23:39:53 2001
@@ -45,6 +45,15 @@
 EXPORT_SYMBOL(disable_irq);
 EXPORT_SYMBOL(disable_irq_nosync);
 
+#include <asm/semaphore.h>
+EXPORT_SYMBOL_NOVERS(__down);
+EXPORT_SYMBOL_NOVERS(__down_interruptible);
+EXPORT_SYMBOL_NOVERS(__down_trylock);
+EXPORT_SYMBOL_NOVERS(__up);
+EXPORT_SYMBOL_NOVERS(__down_read_failed);
+EXPORT_SYMBOL_NOVERS(__down_write_failed);
+EXPORT_SYMBOL_NOVERS(__rwsem_wake);
+
 #include <asm/page.h>
 EXPORT_SYMBOL(clear_page);
 
diff -urN linux-davidm/arch/ia64/kernel/irq_ia64.c linux-2.4.0-lia/arch/ia64/kernel/irq_ia64.c
--- linux-davidm/arch/ia64/kernel/irq_ia64.c	Tue Jan  9 00:09:51 2001
+++ linux-2.4.0-lia/arch/ia64/kernel/irq_ia64.c	Mon Jan  8 23:40:04 2001
@@ -147,13 +147,6 @@
 void __init
 init_IRQ (void)
 {
-	/*
-	 * Disable all local interrupts
-	 */
-	ia64_set_itv(0, 1);
-	ia64_set_lrr0(0, 1);
-	ia64_set_lrr1(0, 1);
-
 	irq_desc[IA64_SPURIOUS_INT].handler = &irq_type_ia64_sapic;
 #ifdef CONFIG_SMP
 	/* 
@@ -163,14 +156,7 @@
 	irq_desc[IPI_IRQ].handler = &irq_type_ia64_sapic;
 	setup_irq(IPI_IRQ, &ipi_irqaction);
 #endif
-
-	ia64_set_pmv(1 << 16);
-	ia64_set_cmcv(CMC_IRQ);			/* XXX fix me */
-
 	platform_irq_init();
-
-	/* clear TPR to enable all interrupt classes: */
-	ia64_set_tpr(0);
 }
 
 void
diff -urN linux-davidm/arch/ia64/kernel/ivt.S linux-2.4.0-lia/arch/ia64/kernel/ivt.S
--- linux-davidm/arch/ia64/kernel/ivt.S	Tue Jan  9 00:09:51 2001
+++ linux-2.4.0-lia/arch/ia64/kernel/ivt.S	Thu Jan  4 23:05:50 2001
@@ -504,6 +504,7 @@
 	mov r28=ar.ccv				// save ar.ccv
 	;;
 1:	ld8 r18=[r17]
+	;;
 # if defined(CONFIG_IA32_SUPPORT) && \
     (defined(CONFIG_ITANIUM_ASTEP_SPECIFIC) || defined(CONFIG_ITANIUM_B0_SPECIFIC))
 	//
@@ -511,7 +512,6 @@
 	//   If the PTE is indicates the page is not present, then just turn this into a
 	//   page fault.
 	//
-	;;
 	tbit.z p6,p0=r18,_PAGE_P_BIT		// page present bit cleared?
 (p6)	br.sptk page_fault			// page wasn't present
 # endif
diff -urN linux-davidm/arch/ia64/kernel/mca.c linux-2.4.0-lia/arch/ia64/kernel/mca.c
--- linux-davidm/arch/ia64/kernel/mca.c	Tue Jan  9 00:09:51 2001
+++ linux-2.4.0-lia/arch/ia64/kernel/mca.c	Mon Jan  8 23:40:28 2001
@@ -27,6 +27,7 @@
 #include <asm/mca.h>
 
 #include <asm/irq.h>
+#include <asm/machvec.h>
 
  
 typedef struct ia64_fptr {
@@ -235,13 +236,15 @@
 	if (ia64_sal_mc_set_params(SAL_MC_PARAM_RENDEZ_INT,
 				   SAL_MC_PARAM_MECHANISM_INT,
 				   IA64_MCA_RENDEZ_INT_VECTOR,
-				   IA64_MCA_RENDEZ_TIMEOUT))
+				   IA64_MCA_RENDEZ_TIMEOUT,
+				   0))
 		return;
 
 	/* Register the wakeup interrupt vector with SAL */
 	if (ia64_sal_mc_set_params(SAL_MC_PARAM_RENDEZ_WAKEUP,
 				   SAL_MC_PARAM_MECHANISM_INT,
 				   IA64_MCA_WAKEUP_INT_VECTOR,
+				   0,
 				   0))
 		return;
 
@@ -543,8 +546,7 @@
 	cmci_handler_platform(cmc_irq, arg, ptregs);
 
 	/* Clear the CMC SAL logs now that they have been saved in the OS buffer */
-	ia64_sal_clear_state_info(SAL_INFO_TYPE_CMC, SAL_SUB_INFO_TYPE_PROCESSOR);
-	ia64_sal_clear_state_info(SAL_INFO_TYPE_CMC, SAL_SUB_INFO_TYPE_PLATFORM);
+	ia64_sal_clear_state_info(SAL_INFO_TYPE_CMC);
 }
 
 /*
@@ -618,8 +620,7 @@
 	init_handler_platform(regs);              /* call platform specific routines */
 
 	/* Clear the INIT SAL logs now that they have been saved in the OS buffer */
-	ia64_sal_clear_state_info(SAL_INFO_TYPE_INIT, SAL_SUB_INFO_TYPE_PROCESSOR);
-	ia64_sal_clear_state_info(SAL_INFO_TYPE_INIT, SAL_SUB_INFO_TYPE_PLATFORM);
+	ia64_sal_clear_state_info(SAL_INFO_TYPE_INIT);
 }
 
 /*
@@ -658,7 +659,7 @@
 	/* Get the process state information */
 	log_buffer = IA64_LOG_NEXT_BUFFER(sal_info_type, sal_sub_info_type);
 
-	if (!(total_len=ia64_sal_get_state_info(sal_info_type, sal_sub_info_type ,(u64 *)log_buffer)))
+	if (!(total_len=ia64_sal_get_state_info(sal_info_type,(u64 *)log_buffer)))
 		prfunc("ia64_mca_log_get : Getting processor log failed\n");
 
 	IA64_MCA_DEBUG("ia64_log_get: retrieved %d bytes of error information\n",total_len);
@@ -683,7 +684,7 @@
 void
 ia64_log_clear(int sal_info_type, int sal_sub_info_type, int clear_os_buffer, prfunc_t prfunc)
 {
-	if (ia64_sal_clear_state_info(sal_info_type, sal_sub_info_type))
+	if (ia64_sal_clear_state_info(sal_info_type))
 		prfunc("ia64_mca_log_get : Clearing processor log failed\n");
 
 	if (clear_os_buffer) {
diff -urN linux-davidm/arch/ia64/kernel/mca_asm.S linux-2.4.0-lia/arch/ia64/kernel/mca_asm.S
--- linux-davidm/arch/ia64/kernel/mca_asm.S	Tue Jan  9 00:09:51 2001
+++ linux-2.4.0-lia/arch/ia64/kernel/mca_asm.S	Wed Nov 15 17:57:45 2000
@@ -7,7 +7,6 @@
 // 00/03/29 cfleck Added code to save INIT handoff state in pt_regs format, switch to temp
 //		   kstack, switch modes, jump to C INIT handler
 //
-#include <linux/config.h>
 #include <asm/pgtable.h>
 #include <asm/processor.h>
 #include <asm/mca_asm.h>
diff -urN linux-davidm/arch/ia64/kernel/perfmon.c linux-2.4.0-lia/arch/ia64/kernel/perfmon.c
--- linux-davidm/arch/ia64/kernel/perfmon.c	Tue Jan  9 00:09:51 2001
+++ linux-2.4.0-lia/arch/ia64/kernel/perfmon.c	Mon Jan  8 23:40:51 2001
@@ -11,53 +11,35 @@
  */
 
 #include <linux/config.h>
-
 #include <linux/kernel.h>
-#include <linux/init.h>
 #include <linux/sched.h>
 #include <linux/interrupt.h>
 #include <linux/smp_lock.h>
 #include <linux/proc_fs.h>
+#include <linux/init.h>
+#include <linux/vmalloc.h>
+#include <linux/wrapper.h>
+#include <linux/mm.h>
 
+#include <asm/bitops.h>
+#include <asm/efi.h>
 #include <asm/errno.h>
 #include <asm/hw_irq.h>
+#include <asm/page.h>
+#include <asm/pal.h>
+#include <asm/perfmon.h>
+#include <asm/pgtable.h>
 #include <asm/processor.h>
+#include <asm/signal.h>
+#include <asm/system.h>
 #include <asm/system.h>
 #include <asm/uaccess.h>
-#include <asm/pal.h>
-
-/* Long blurb on how this works: 
- * We set dcr.pp, psr.pp, and the appropriate pmc control values with
- * this.  Notice that we go about modifying _each_ task's pt_regs to
- * set cr_ipsr.pp.  This will start counting when "current" does an
- * _rfi_. Also, since each task's cr_ipsr.pp, and cr_ipsr is inherited
- * across forks, we do _not_ need additional code on context
- * switches. On stopping of the counters we dont need to go about
- * changing every task's cr_ipsr back to where it wuz, because we can
- * just set pmc[0]=1. But we do it anyways becuase we will probably
- * add thread specific accounting later.
- *
- * The obvious problem with this is that on SMP systems, it is a bit
- * of work (when someone wants to do it:-)) - it would be easier if we
- * just added code to the context-switch path, but if we wanted to support
- * per-thread accounting, the context-switch path might be long unless 
- * we introduce a flag in the task_struct. Right now, the following code 
- * will NOT work correctly on MP (for more than one reason:-)).
- *
- * The short answer is that to make this work on SMP,  we would need 
- * to lock the run queue to ensure no context switches, send 
- * an IPI to each processor, and in that IPI handler, set processor regs,
- * and just modify the psr bit of only the _current_ thread, since we have 
- * modified the psr bit correctly in the kernel stack for every process 
- * which is not running. Also, we need pmd arrays per-processor, and 
- * the READ_PMD command will need to get values off of other processors. 
- * IPIs are the answer, irrespective of what the question is. Might 
- * crash on SMP systems without the lock_kernel().
- */
 
 #ifdef CONFIG_PERFMON
 
-#define MAX_PERF_COUNTER	4	/* true for Itanium, at least */
+#define PFM_VERSION		"0.2"
+#define PFM_SMPL_HDR_VERSION	1
+
 #define PMU_FIRST_COUNTER	4	/* first generic counter */
 
 #define PFM_WRITE_PMCS		0xa0
@@ -67,6 +49,8 @@
 #define PFM_START		0xa4
 #define PFM_ENABLE		0xa5	/* unfreeze only */
 #define PFM_DISABLE		0xa6	/* freeze only */
+#define PFM_RESTART		0xcf
+#define PFM_CREATE_CONTEXT	0xa7
 /* 
  * Those 2 are just meant for debugging. I considered using sysctl() for
  * that but it is a little bit too pervasive. This solution is at least
@@ -75,101 +59,869 @@
 #define PFM_DEBUG_ON		0xe0	
 #define PFM_DEBUG_OFF		0xe1
 
+
+/*
+ * perfmon API flags
+ */
+#define PFM_FL_INHERIT_NONE	 0x00	/* never inherit a context across fork (default) */
+#define PFM_FL_INHERIT_ONCE	 0x01	/* clone pfm_context only once across fork() */
+#define PFM_FL_INHERIT_ALL	 0x02	/* always clone pfm_context across fork() */
+#define PFM_FL_SMPL_OVFL_NOBLOCK 0x04	/* do not block on sampling buffer overflow */
+#define PFM_FL_SYSTEMWIDE	 0x08	/* create a systemwide context */
+
+/*
+ * PMC API flags
+ */
+#define PFM_REGFL_OVFL_NOTIFY	1		/* send notification on overflow */
+
+/*
+ * Private flags and masks
+ */
+#define PFM_FL_INHERIT_MASK	(PFM_FL_INHERIT_NONE|PFM_FL_INHERIT_ONCE|PFM_FL_INHERIT_ALL)
+
 #ifdef CONFIG_SMP
 #define cpu_is_online(i) (cpu_online_map & (1UL << i))
 #else
 #define cpu_is_online(i)	1
 #endif
 
-#define PMC_IS_IMPL(i)		(pmu_conf.impl_regs[i>>6] & (1<< (i&~(64-1))))
-#define PMD_IS_IMPL(i)  	(pmu_conf.impl_regs[4+(i>>6)] & (1<< (i&~(64-1))))
+#define PMC_IS_IMPL(i)		(i < pmu_conf.num_pmcs && pmu_conf.impl_regs[i>>6] & (1<< (i&~(64-1))))
+#define PMD_IS_IMPL(i)  	(i < pmu_conf.num_pmds &&  pmu_conf.impl_regs[4+(i>>6)] & (1<< (i&~(64-1))))
 #define PMD_IS_COUNTER(i)	(i>=PMU_FIRST_COUNTER && i < (PMU_FIRST_COUNTER+pmu_conf.max_counters))
 #define PMC_IS_COUNTER(i)	(i>=PMU_FIRST_COUNTER && i < (PMU_FIRST_COUNTER+pmu_conf.max_counters))
 
+/* This is the Itanium-specific PMC layout for counter config */
+typedef struct {
+	unsigned long pmc_plm:4;	/* privilege level mask */
+	unsigned long pmc_ev:1;		/* external visibility */
+	unsigned long pmc_oi:1;		/* overflow interrupt */
+	unsigned long pmc_pm:1;		/* privileged monitor */
+	unsigned long pmc_ig1:1;	/* reserved */
+	unsigned long pmc_es:7;		/* event select */
+	unsigned long pmc_ig2:1;	/* reserved */
+	unsigned long pmc_umask:4;	/* unit mask */
+	unsigned long pmc_thres:3;	/* threshold */
+	unsigned long pmc_ig3:1;	/* reserved (missing from table on p6-17) */
+	unsigned long pmc_ism:2;	/* instruction set mask */
+	unsigned long pmc_ig4:38;	/* reserved */
+} pmc_counter_reg_t;
+
+/* test for EAR/BTB configuration */
+#define PMU_DEAR_EVENT	0x67
+#define PMU_IEAR_EVENT	0x23
+#define PMU_BTB_EVENT	0x11
+
+#define PMC_IS_DEAR(a)		(((pmc_counter_reg_t *)(a))->pmc_es = PMU_DEAR_EVENT)
+#define PMC_IS_IEAR(a)		(((pmc_counter_reg_t *)(a))->pmc_es = PMU_IEAR_EVENT)
+#define PMC_IS_BTB(a)		(((pmc_counter_reg_t *)(a))->pmc_es = PMU_BTB_EVENT)
+
 /*
- * this structure needs to be enhanced
+ * This header is at the beginning of the sampling buffer returned to the user.
+ * It is exported as Read-Only at this point. It is directly followed with the
+ * first record.
  */
 typedef struct {
-	unsigned long	pfr_reg_num;	/* which register */
-	unsigned long	pfr_reg_value;	/* configuration (PMC) or initial value (PMD) */
-	unsigned long	pfr_reg_reset;	/* reset value on overflow (PMD) */
-	void		*pfr_smpl_buf;	/* pointer to user buffer for EAR/BTB */
-	unsigned long	pfr_smpl_size;	/* size of user buffer for EAR/BTB */
-	pid_t		pfr_notify_pid;	/* process to notify */
-	int		pfr_notify_sig;	/* signal for notification, 0=no notification */
-} perfmon_req_t;
+	int		hdr_version;		/* could be used to differentiate formats */
+	int		hdr_reserved;
+	unsigned long	hdr_entry_size;		/* size of one entry in bytes */
+	unsigned long	hdr_count;		/* how many valid entries */
+	unsigned long 	hdr_pmds;		/* which pmds are recorded */
+} perfmon_smpl_hdr_t;
 
-#if 0
+/*
+ * Header entry in the buffer as a header as follows.
+ * The header is directly followed with the PMDS to saved in increasing index order:
+ * PMD4, PMD5, .... How many PMDs are present is determined by the tool which must
+ * keep track of it when generating the final trace file.
+ */
 typedef struct {
-	unsigned long pmu_reg_data;	/* generic PMD register */
-	unsigned long pmu_reg_num;	/* which register number */
-} perfmon_reg_t; 
-#endif
+	int 		pid;		/* identification of process */
+	int 		cpu;		/* which cpu was used */
+	unsigned long	rate;		/* initial value of this counter */
+	unsigned long	stamp;		/* timestamp */
+	unsigned long	ip;		/* where did the overflow interrupt happened */
+	unsigned long	regs;		/* which registers overflowed (up to 64)*/
+} perfmon_smpl_entry_t;
 
 /*
- * This structure is initialize at boot time and contains
+ * There is one such data structure per perfmon context. It is used to describe the
+ * sampling buffer. It is to be shared among siblings whereas the pfm_context isn't.
+ * Therefore we maintain a refcnt which is incremented on fork().
+ * This buffer is private to the kernel only the actual sampling buffer including its
+ * header are exposed to the user. This construct allows us to export the buffer read-write,
+ * if needed, without worrying about security problems.
+ */
+typedef struct {
+	atomic_t		psb_refcnt;	/* how many users for the buffer */
+	int			reserved;
+	void			*psb_addr;	/* points to location of first entry */
+	unsigned long		psb_entries;	/* maximum number of entries */
+	unsigned long		psb_size;	/* aligned size of buffer */
+	unsigned long		psb_index;	/* next free entry slot */
+	unsigned long		psb_entry_size;	/* size of each entry including entry header */
+	perfmon_smpl_hdr_t	*psb_hdr;	/* points to sampling buffer header */
+} pfm_smpl_buffer_desc_t;
+
+
+/*
+ * This structure is initialized at boot time and contains
  * a description of the PMU main characteristic as indicated
  * by PAL
  */
 typedef struct {
+	unsigned long pfm_is_disabled;	/* indicates if perfmon is working properly */
 	unsigned long perf_ovfl_val;	/* overflow value for generic counters   */
 	unsigned long max_counters;	/* upper limit on counter pair (PMC/PMD) */
+	unsigned long num_pmcs ;	/* highest PMC implemented (may have holes) */
+	unsigned long num_pmds;		/* highest PMD implemented (may have holes) */
 	unsigned long impl_regs[16];	/* buffer used to hold implememted PMC/PMD mask */
 } pmu_config_t;
 
+#define PERFMON_IS_DISABLED() pmu_conf.pfm_is_disabled
+
+typedef struct {
+	__u64		val;		/* virtual 64bit counter value */
+	__u64		ival;		/* initial value from user */
+	__u64		smpl_rval;	/* reset value on sampling overflow */
+	__u64		ovfl_rval;	/* reset value on overflow */
+	int		flags;		/* notify/do not notify */
+} pfm_counter_t;
+#define PMD_OVFL_NOTIFY(ctx, i)	((ctx)->ctx_pmds[i].flags &  PFM_REGFL_OVFL_NOTIFY)
+
+/*
+ * perfmon context. One per process, is cloned on fork() depending on inheritance flags
+ */
+typedef struct {
+	unsigned int inherit:2;	/* inherit mode */
+	unsigned int noblock:1;	/* block/don't block on overflow with notification */
+	unsigned int system:1;	/* do system wide monitoring */
+	unsigned int frozen:1;	/* pmu must be kept frozen on ctxsw in */
+	unsigned int reserved:27;
+} pfm_context_flags_t;
+
+typedef struct pfm_context {
+
+	pfm_smpl_buffer_desc_t	*ctx_smpl_buf;		/* sampling buffer descriptor, if any */
+	unsigned long 		ctx_dear_counter;	/* which PMD holds D-EAR */
+	unsigned long 		ctx_iear_counter;	/* which PMD holds I-EAR */
+	unsigned long 		ctx_btb_counter;	/* which PMD holds BTB */
+
+	pid_t			ctx_notify_pid;	/* who to notify on overflow */
+	int			ctx_notify_sig;	/* XXX: SIGPROF or other */
+	pfm_context_flags_t	ctx_flags;	/* block/noblock */
+	pid_t			ctx_creator;	/* pid of creator (debug) */
+	unsigned long		ctx_ovfl_regs;	/* which registers just overflowed (notification) */
+	unsigned long		ctx_smpl_regs;	/* which registers to record on overflow */
+
+	struct semaphore	ctx_restart_sem; /* use for blocking notification mode */
+
+	pfm_counter_t		ctx_pmds[IA64_NUM_PMD_COUNTERS]; /* XXX: size should be dynamic */
+} pfm_context_t;
+
+#define ctx_fl_inherit	ctx_flags.inherit
+#define ctx_fl_noblock	ctx_flags.noblock
+#define ctx_fl_system	ctx_flags.system
+#define ctx_fl_frozen	ctx_flags.frozen
+
+#define CTX_IS_DEAR(c,n)	((c)->ctx_dear_counter = (n))
+#define CTX_IS_IEAR(c,n)	((c)->ctx_iear_counter = (n))
+#define CTX_IS_BTB(c,n)		((c)->ctx_btb_counter = (n))
+#define CTX_OVFL_NOBLOCK(c)	((c)->ctx_fl_noblock = 1)
+#define CTX_INHERIT_MODE(c)	((c)->ctx_fl_inherit)
+#define CTX_HAS_SMPL(c)		((c)->ctx_smpl_buf != NULL)
+
 static pmu_config_t pmu_conf;
 
 /* for debug only */
-static unsigned long pfm_debug=1;	/* 0= nodebug, >0= debug output on */
-#define DBprintk(a)	{\
-	if (pfm_debug >0) { printk a; } \
+static unsigned long pfm_debug=0;	/* 0= nodebug, >0= debug output on */
+#define DBprintk(a) \
+	do { \
+		if (pfm_debug >0) { printk(__FUNCTION__" "); printk a; } \
+	} while (0);
+
+static void perfmon_softint(unsigned long ignored);
+static void ia64_reset_pmu(void);
+
+DECLARE_TASKLET(pfm_tasklet, perfmon_softint, 0);
+
+/*
+ * structure used to pass information between the interrupt handler
+ * and the tasklet. 
+ */
+typedef struct {
+	pid_t		to_pid;		/* which process to notify */
+	pid_t		from_pid;	/* which process is source of overflow */
+	int		sig;		/* with which signal */
+	unsigned long	bitvect;	/* which counters have overflowed */
+} notification_info_t;
+
+#define notification_is_invalid(i)	(i->to_pid < 2)
+
+/* will need to be cache line padded */
+static notification_info_t notify_info[NR_CPUS];
+
+/*
+ * We force cache line alignment to avoid false sharing
+ * given that we have one entry per CPU.
+ */
+static struct {
+	struct task_struct *owner;
+} ____cacheline_aligned pmu_owners[NR_CPUS];
+/* helper macros */
+#define SET_PMU_OWNER(t)	do { pmu_owners[smp_processor_id()].owner = (t); } while(0);
+#define PMU_OWNER()		pmu_owners[smp_processor_id()].owner
+
+/* for debug only */
+static struct proc_dir_entry *perfmon_dir;
+
+/*
+ * finds the number of PM(C|D) registers given 
+ * the bitvector returned by PAL
+ */
+static unsigned long __init
+find_num_pm_regs(long *buffer)
+{
+	int i=3; /* 4 words/per bitvector */
+
+	/* start from the most significant word */
+	while (i>=0 && buffer[i] = 0 ) i--;
+	if (i< 0) {
+		printk(KERN_ERR "perfmon: No bit set in pm_buffer\n");
+		return 0;
+	}
+	return 1+ ia64_fls(buffer[i]) + 64 * i;
+}
+
+
+/*
+ * Generates a unique (per CPU) timestamp
+ */
+static inline unsigned long
+perfmon_get_stamp(void)
+{
+	unsigned long tmp;
+
+	/* XXX: need more to adjust for Itanium itc bug */
+	__asm__ __volatile__("mov %0=ar.itc" : "=r"(tmp) :: "memory");
+
+	return tmp;
+}
+
+/* Given PGD from the address space's page table, return the kernel
+ * virtual mapping of the physical memory mapped at ADR.
+ */
+static inline unsigned long 
+uvirt_to_kva(pgd_t *pgd, unsigned long adr)
+{
+	unsigned long ret = 0UL;
+	pmd_t *pmd;
+	pte_t *ptep, pte;
+
+	if (!pgd_none(*pgd)) {
+		pmd = pmd_offset(pgd, adr);
+		if (!pmd_none(*pmd)) {
+			ptep = pte_offset(pmd, adr);
+			pte = *ptep;
+			if (pte_present(pte)) {
+				ret = (unsigned long) page_address(pte_page(pte));
+				ret |= (adr & (PAGE_SIZE - 1));
+			}
+		}
+	}
+	DBprintk(("uv2kva(%lx-->%lx)\n", adr, ret));
+	return ret;
+}
+
+
+/* Here we want the physical address of the memory.
+ * This is used when initializing the contents of the
+ * area and marking the pages as reserved.
+ */
+static inline unsigned long 
+kvirt_to_pa(unsigned long adr)
+{
+	unsigned long va, kva, ret;
+
+	va = VMALLOC_VMADDR(adr);
+	kva = uvirt_to_kva(pgd_offset_k(va), va);
+	ret = __pa(kva);
+	DBprintk(("kv2pa(%lx-->%lx)\n", adr, ret));
+	return ret;
+}
+
+
+static void *
+rvmalloc(unsigned long size)
+{
+	void *mem;
+	unsigned long adr, page;
+
+	/* XXX: may have to revisit this part because
+	 * vmalloc() does not necessarily return a page-aligned buffer.
+	 * This maybe a security problem when mapped at user level
+	 */
+	mem=vmalloc(size);
+	if (mem) {
+		memset(mem, 0, size); /* Clear the ram out, no junk to the user */
+	        adr=(unsigned long) mem;
+		while (size > 0) {
+	                page = kvirt_to_pa(adr);
+			mem_map_reserve(virt_to_page(__va(page)));
+			adr+=PAGE_SIZE;
+			size-=PAGE_SIZE;
+		}
+	}
+	return mem;
+}
+
+static void
+rvfree(void *mem, unsigned long size)
+{
+        unsigned long adr, page;
+        
+	if (mem) {
+	        adr=(unsigned long) mem;
+		while (size > 0) {
+	                page = kvirt_to_pa(adr);
+			mem_map_unreserve(virt_to_page(__va(page)));
+			adr+=PAGE_SIZE;
+			size-=PAGE_SIZE;
+		}
+		vfree(mem);
+	}
+}
+
+static pfm_context_t *
+pfm_context_alloc(void)
+{
+	pfm_context_t *pfc;
+
+	/* allocate context descriptor */
+	pfc = vmalloc(sizeof(*pfc));
+	if (pfc) memset(pfc, 0, sizeof(*pfc));
+
+	return pfc;
+}
+
+static void
+pfm_context_free(pfm_context_t *pfc)
+{
+	if (pfc) vfree(pfc);
+}
+
+static int
+pfm_remap_buffer(unsigned long buf, unsigned long addr, unsigned long size)
+{
+        unsigned long page;
+
+        while (size > 0) {
+                page = kvirt_to_pa(buf);
+
+                if (remap_page_range(addr, page, PAGE_SIZE, PAGE_SHARED)) return -ENOMEM;
+
+                addr  += PAGE_SIZE;
+                buf   += PAGE_SIZE;
+                size  -= PAGE_SIZE;
+        }
+	return 0;
+}
+
+/* 
+ * counts the number of PMDS to save per entry.
+ * This code is generic enough to accomodate more than 64 PMDS when they become available
+ */
+static unsigned long
+pfm_smpl_entry_size(unsigned long *which, unsigned long size)
+{
+	unsigned long res = 0;
+	int i;
+
+	for (i=0; i < size; i++, which++) res += hweight64(*which);
+
+	DBprintk((" res=%ld\n", res));
+
+	return res;
 }
 
 /*
- * could optimize to avoid cache line conflicts in SMP
+ * Allocates the sampling buffer and remaps it into caller's address space
  */
-static struct task_struct *pmu_owners[NR_CPUS];
+static int
+pfm_smpl_buffer_alloc(pfm_context_t *ctx, unsigned long which_pmds, unsigned long entries, void **user_addr)
+{
+	struct mm_struct *mm = current->mm;
+	struct vm_area_struct *vma;
+	unsigned long addr, size, regcount;
+	void *smpl_buf;
+	pfm_smpl_buffer_desc_t *psb;
+
+	regcount = pfm_smpl_entry_size(&which_pmds, 1);
+	/*
+	 * ask for a sampling buffer but nothing to record !
+	 */
+	if (regcount = 0) {
+		DBprintk((" no pmds to record\n"));
+		return -EINVAL;
+	}
+	/*
+	 * 1 buffer hdr and for each entry a header + regcount PMDs to save
+	 */
+	size = PAGE_ALIGN(  sizeof(perfmon_smpl_hdr_t)
+			  + entries * (sizeof(perfmon_smpl_entry_t) + regcount*sizeof(u64)));
+	/*
+	 * check requested size to avoid Denial-of-service attacks
+	 * XXX: may have to refine this test
+	 */
+	if (size > current->rlim[RLIMIT_MEMLOCK].rlim_cur) return -EAGAIN;
+
+	/* find some free area in address space */
+	addr = get_unmapped_area(0, size);
+	if (!addr) goto no_addr;
+
+	DBprintk((" entries=%ld aligned size=%ld, unmapped @0x%lx\n", entries, size, addr));
+
+	/* allocate vma */
+	vma = kmem_cache_alloc(vm_area_cachep, SLAB_KERNEL);
+	if (!vma) goto no_vma;
+
+	/* XXX: see rvmalloc() for page alignment problem */
+	smpl_buf = rvmalloc(size);
+	if (smpl_buf = NULL) goto no_buffer;
+
+	DBprintk((" smpl_buf @%p\n", smpl_buf));
+
+	if (pfm_remap_buffer((unsigned long)smpl_buf, addr, size)) goto cant_remap;
+
+	/* allocate sampling buffer descriptor now */
+	psb = vmalloc(sizeof(*psb)); 
+	if (psb = NULL) goto no_buffer_desc;
+
+	/* start with something clean */
+	memset(smpl_buf, 0x0, size);
+
+	psb->psb_hdr	 = smpl_buf;
+	psb->psb_addr    = (char *)smpl_buf+sizeof(perfmon_smpl_hdr_t); /* first entry */
+	psb->psb_size    = size; /* aligned size */
+	psb->psb_index   = 0;
+	psb->psb_entries = entries;
+
+	atomic_set(&psb->psb_refcnt, 1);
+
+	psb->psb_entry_size = sizeof(perfmon_smpl_entry_t) + regcount*sizeof(u64);
+
+	DBprintk((" psb @%p entry_size=%ld hdr=%p addr=%p\n", psb,psb->psb_entry_size, psb->psb_hdr, psb->psb_addr)); 
+
+	/* initialize some of the fields of header */
+	psb->psb_hdr->hdr_version    = PFM_SMPL_HDR_VERSION;
+	psb->psb_hdr->hdr_entry_size = sizeof(perfmon_smpl_entry_t)+regcount*sizeof(u64);
+	psb->psb_hdr->hdr_pmds	     = which_pmds;
+
+	/* store which PMDS to record */
+	ctx->ctx_smpl_regs = which_pmds;
+
+	/* link to perfmon context */
+	ctx->ctx_smpl_buf  = psb;
+
+	/*
+	 * initialize the vma for the sampling buffer
+  	 */
+	vma->vm_mm    	  = mm;
+	vma->vm_start	  = addr;
+	vma->vm_end   	  = addr + size;
+	vma->vm_flags	  = VM_READ|VM_MAYREAD;
+	vma->vm_page_prot = PAGE_READONLY; /* XXX may need to change */
+	vma->vm_ops   	  = NULL;
+	vma->vm_pgoff	  = 0;
+	vma->vm_file	  = NULL;
+	vma->vm_raend	  = 0;
+
+	vma->vm_private_data = ctx;	/* link to pfm_context(not yet used) */
+
+	/*
+	 * now insert the vma in the vm list for the process 
+	 */
+	insert_vm_struct(mm, vma);
+	
+	mm->total_vm  += size >> PAGE_SHIFT;
+
+	/*
+	 * that's the address returned to the user 
+	 */
+	*user_addr = (void *)addr;
+
+	return 0;
+
+	/* outlined error handling */
+no_addr:
+	DBprintk(("Cannot find unmapped area for size %ld\n", size));
+	return -ENOMEM;
+no_vma:
+	DBprintk(("Cannot allocate vma\n"));
+	return -ENOMEM;
+cant_remap:
+	DBprintk(("Can't remap buffer\n"));
+	rvfree(smpl_buf, size);
+no_buffer:
+	DBprintk(("Can't allocate sampling buffer\n"));
+	kmem_cache_free(vm_area_cachep, vma);
+	return -ENOMEM;
+no_buffer_desc:
+	DBprintk(("Can't allocate sampling buffer descriptor\n"));
+	kmem_cache_free(vm_area_cachep, vma);
+	rvfree(smpl_buf, size);
+	return -ENOMEM;
+}
+
+static int 
+pfx_is_sane(pfreq_context_t *pfx)
+{
+	/* valid signal */
+	if (pfx->notify_sig < 1 || pfx->notify_sig >= _NSIG) return 0;
+
+	/* cannot send to process 1, 0 means do not notify */
+	if (pfx->notify_pid < 0 || pfx->notify_pid = 1) return 0;
+
+	/* asked for sampling, but nothing to record ! */
+	if (pfx->smpl_entries > 0 && pfm_smpl_entry_size(&pfx->smpl_regs, 1) = 0) return 0;
+
+	/* probably more to add here */
+
+
+	return 1;
+}
+
+static int
+pfm_context_create(struct task_struct *task, int flags, perfmon_req_t *req)
+{
+	pfm_context_t *ctx;
+        perfmon_req_t tmp;
+	void *uaddr = NULL;
+	int ret = -EINVAL;
+	int ctx_flags;
+
+	/* to go away */
+	if (flags) {
+		printk("perfmon: use context flags instead of perfmon() flags. Obsoleted API\n");
+	}
+
+	copy_from_user(&tmp, req, sizeof(tmp));
+
+	ctx_flags = tmp.pfr_ctx.flags;
+
+	/* not yet supported */
+	if (ctx_flags & PFM_FL_SYSTEMWIDE) return -EINVAL;
+
+	if (!pfx_is_sane(&tmp.pfr_ctx)) return -EINVAL;
+	
+	ctx = pfm_context_alloc();
+	if (!ctx) return -ENOMEM;
+
+	/* record who the creator is (for debug) */
+	ctx->ctx_creator = task->pid;
+
+	ctx->ctx_notify_pid = tmp.pfr_ctx.notify_pid;
+	ctx->ctx_notify_sig = SIGPROF;	/* siginfo imposes a fixed signal */
+
+	if (tmp.pfr_ctx.smpl_entries) {
+		DBprintk((" sampling entries=%ld\n",tmp.pfr_ctx.smpl_entries));
+		if ((ret=pfm_smpl_buffer_alloc(ctx, tmp.pfr_ctx.smpl_regs, tmp.pfr_ctx.smpl_entries, &uaddr)) ) goto buffer_error;
+		tmp.pfr_ctx.smpl_vaddr = uaddr;
+	}
+	/* initialization of context's flags */
+	ctx->ctx_fl_inherit = ctx_flags & PFM_FL_INHERIT_MASK;
+	ctx->ctx_fl_noblock = (ctx_flags & PFM_FL_SMPL_OVFL_NOBLOCK) ? 1 : 0;
+	ctx->ctx_fl_system  = (ctx_flags & PFM_FL_SYSTEMWIDE) ? 1: 0;
+	ctx->ctx_fl_frozen  = 0;	
+
+	sema_init(&ctx->ctx_restart_sem, 0); /* init this semaphore to locked */ 
+
+	/* XXX fixme take care of errors here */
+	copy_to_user(req, &tmp, sizeof(tmp));
+
+	DBprintk((" context=%p, pid=%d notify_sig %d notify_pid=%d\n",ctx, task->pid, ctx->ctx_notify_sig, ctx->ctx_notify_pid));
+	DBprintk((" context=%p, pid=%d flags=0x%x inherit=%d noblock=%d system=%d\n",ctx, task->pid, ctx_flags, ctx->ctx_fl_inherit, ctx->ctx_fl_noblock, ctx->ctx_fl_system));
+
+	/* link with task */
+	task->thread.pfm_context = ctx;
+
+	return 0;
+
+buffer_error:
+	vfree(ctx);
+
+	return ret;
+}
+
+static void
+pfm_reset_regs(pfm_context_t *ctx)
+{
+	unsigned long mask = ctx->ctx_ovfl_regs;
+	int i, cnum;
+
+	DBprintk((" ovfl_regs=0x%lx\n", mask));
+	/*
+	 * now restore reset value on sampling overflowed counters
+	 */
+	for(i=0, cnum=PMU_FIRST_COUNTER; i < pmu_conf.max_counters; i++, cnum++, mask >>= 1) {
+		if (mask & 0x1) {
+			DBprintk((" reseting PMD[%d]=%lx\n", cnum, ctx->ctx_pmds[i].smpl_rval & pmu_conf.perf_ovfl_val));
+
+			/* upper part is ignored on rval */
+			ia64_set_pmd(cnum, ctx->ctx_pmds[i].smpl_rval);
+		}
+	}
+}
+
+static int
+pfm_write_pmcs(struct task_struct *ta, perfmon_req_t *req, int count)
+{
+	struct thread_struct *th = &ta->thread;
+	pfm_context_t *ctx = th->pfm_context;
+	perfmon_req_t tmp;
+	unsigned long cnum;
+	int i;
+
+	/* XXX: ctx locking may be required here */
+
+	for (i = 0; i < count; i++, req++) {
+
+		copy_from_user(&tmp, req, sizeof(tmp));
+
+		cnum = tmp.pfr_reg.reg_num;
+
+		/* XXX needs to check validity of the data maybe */
+		if (!PMC_IS_IMPL(cnum)) {
+			DBprintk((" invalid pmc[%ld]\n", cnum));
+			return -EINVAL;
+		}
+
+		if (PMC_IS_COUNTER(cnum)) {
+
+			/*
+			 * we keep track of EARS/BTB to speed up sampling later
+			 */
+			if (PMC_IS_DEAR(&tmp.pfr_reg.reg_value)) {
+				ctx->ctx_dear_counter = cnum;
+			} else if (PMC_IS_IEAR(&tmp.pfr_reg.reg_value)) {
+				ctx->ctx_iear_counter = cnum;
+			} else if (PMC_IS_BTB(&tmp.pfr_reg.reg_value)) {
+				ctx->ctx_btb_counter = cnum;
+			}
+
+			if (tmp.pfr_reg.reg_flags & PFM_REGFL_OVFL_NOTIFY)
+				ctx->ctx_pmds[cnum - PMU_FIRST_COUNTER].flags |= PFM_REGFL_OVFL_NOTIFY;
+		}
+
+		ia64_set_pmc(cnum, tmp.pfr_reg.reg_value);
+			DBprintk((" setting PMC[%ld]=0x%lx flags=0x%x\n", cnum, tmp.pfr_reg.reg_value, ctx->ctx_pmds[cnum - PMU_FIRST_COUNTER].flags));
+
+	}
+	/*
+	 * we have to set this here event hough we haven't necessarily started monitoring
+	 * because we may be context switched out
+	 */
+	th->flags |= IA64_THREAD_PM_VALID;
+
+	return 0;
+}
+
+static int
+pfm_write_pmds(struct task_struct *ta, perfmon_req_t *req, int count)
+{
+	struct thread_struct *th = &ta->thread;
+	pfm_context_t *ctx = th->pfm_context;
+	perfmon_req_t tmp;
+	unsigned long cnum;
+	int i;
+
+	/* XXX: ctx locking may be required here */
+
+	for (i = 0; i < count; i++, req++) {
+		int k;
+
+		copy_from_user(&tmp, req, sizeof(tmp));
+
+		cnum = tmp.pfr_reg.reg_num;
+
+		k = cnum - PMU_FIRST_COUNTER;
+
+		if (!PMD_IS_IMPL(cnum)) return -EINVAL;
+
+		/* update virtualized (64bits) counter */
+		if (PMD_IS_COUNTER(cnum)) {
+			ctx->ctx_pmds[k].ival = tmp.pfr_reg.reg_value;
+			ctx->ctx_pmds[k].val  = tmp.pfr_reg.reg_value & ~pmu_conf.perf_ovfl_val;
+			ctx->ctx_pmds[k].smpl_rval = tmp.pfr_reg.reg_smpl_reset;
+			ctx->ctx_pmds[k].ovfl_rval = tmp.pfr_reg.reg_ovfl_reset;
+		}
+
+		/* writes to unimplemented part is ignored, so this is safe */
+		ia64_set_pmd(cnum, tmp.pfr_reg.reg_value);
+
+		/* to go away */
+		ia64_srlz_d();
+		DBprintk((" setting PMD[%ld]:  pmd.val=0x%lx pmd.ovfl_rval=0x%lx pmd.smpl_rval=0x%lx pmd=%lx\n", 
+					cnum, 
+					ctx->ctx_pmds[k].val,
+					ctx->ctx_pmds[k].ovfl_rval,
+					ctx->ctx_pmds[k].smpl_rval,
+					ia64_get_pmd(cnum) & pmu_conf.perf_ovfl_val));
+	}
+	/*
+	 * we have to set this here event hough we haven't necessarily started monitoring
+	 * because we may be context switched out
+	 */
+	th->flags |= IA64_THREAD_PM_VALID;
+
+	return 0;
+}
+
+static int
+pfm_read_pmds(struct task_struct *ta, perfmon_req_t *req, int count)
+{
+	struct thread_struct *th = &ta->thread;
+	pfm_context_t *ctx = th->pfm_context;
+	unsigned long val=0;
+	perfmon_req_t tmp;
+	int i;
+
+	/*
+	 * XXX: MUST MAKE SURE WE DON"T HAVE ANY PENDING OVERFLOW BEFORE READING
+	 * This is required when the monitoring has been stoppped by user of kernel.
+	 * If ity is still going on, then that's fine because we a re not gauranteed
+	 * to return an accurate value in this case
+	 */
+
+	/* XXX: ctx locking may be required here */
+
+	for (i = 0; i < count; i++, req++) {
+		int k;
+
+		copy_from_user(&tmp, req, sizeof(tmp));
+
+		if (!PMD_IS_IMPL(tmp.pfr_reg.reg_num)) return -EINVAL;
+
+		k = tmp.pfr_reg.reg_num - PMU_FIRST_COUNTER; 
+
+		if (PMD_IS_COUNTER(tmp.pfr_reg.reg_num)) {
+			if (ta = current){
+				val = ia64_get_pmd(tmp.pfr_reg.reg_num);
+			} else {
+				val = th->pmd[k];
+			}
+			val &= pmu_conf.perf_ovfl_val;
+			/* 
+			 * lower part of .val may not be zero, so we must be an addition because of 
+			 * residual count (see update_counters).
+			 */
+			val += ctx->ctx_pmds[k].val;
+		} else {
+			/* for now */
+			if (ta != current) return -EINVAL;
+
+			val = ia64_get_pmd(tmp.pfr_reg.reg_num);
+		}
+		tmp.pfr_reg.reg_value = val;
+
+		DBprintk((" reading PMD[%ld]=0x%lx\n", tmp.pfr_reg.reg_num, val));
+
+		if (copy_to_user(req, &tmp, sizeof(tmp))) return -EFAULT;
+	}
+	return 0;
+}
+
+static int
+pfm_do_restart(struct task_struct *task)
+{
+	struct thread_struct *th = &task->thread;
+	pfm_context_t *ctx = th->pfm_context;
+	void *sem = &ctx->ctx_restart_sem;
+
+	if (task = current) {
+		DBprintk((" restartig self %d frozen=%d \n", current->pid, ctx->ctx_fl_frozen));
+
+		pfm_reset_regs(ctx);
+
+		/* 
+		 * We ignore block/don't block because we never block
+		 * for a self-monitoring process.
+		 */
+		ctx->ctx_fl_frozen = 0;
+
+		if (CTX_HAS_SMPL(ctx)) {
+			ctx->ctx_smpl_buf->psb_hdr->hdr_count = 0;
+			ctx->ctx_smpl_buf->psb_index = 0;
+		}
+
+		/* pfm_reset_smpl_buffers(ctx,th->pfm_ovfl_regs);*/
+
+		/* simply unfreeze */
+		ia64_set_pmc(0, 0);
+		ia64_srlz_d();
+
+		return 0;
+	}
+
+	/* check if blocking */
+	if (CTX_OVFL_NOBLOCK(ctx) = 0) {
+		DBprintk((" unblocking %d \n", task->pid));
+		up(sem);
+		return 0;
+	} 
+
+	/* 
+	 * in case of non blocking mode, then it's just a matter of
+	 * of reseting the sampling buffer (if any) index. The PMU
+	 * is already active.
+	 */
+	
+	/* 
+	 * must reset the header count first
+	 */
+	if (CTX_HAS_SMPL(ctx)) {
+		DBprintk((" resetting sampling indexes for %d \n", task->pid));
+		ctx->ctx_smpl_buf->psb_hdr->hdr_count = 0;
+		ctx->ctx_smpl_buf->psb_index = 0;
+	}
+
+	return 0;
+}
+
 
 static int
 do_perfmonctl (struct task_struct *task, int cmd, int flags, perfmon_req_t *req, int count, struct pt_regs *regs)
 {
         perfmon_req_t tmp;
-        int i;
+	struct thread_struct *th = &task->thread;
+	pfm_context_t *ctx = th->pfm_context;
+
+	memset(&tmp, 0, sizeof(tmp));
 
         switch (cmd) {
-		case PFM_WRITE_PMCS:          
-			/* we don't quite support this right now */
+		case PFM_CREATE_CONTEXT:
+			/* a context has already been defined */
+			if (ctx) return -EBUSY;
+
+			/* may be a temporary limitation */
 			if (task != current) return -EINVAL;
 
+			if (req = NULL || count != 1) return -EINVAL;
+
 			if (!access_ok(VERIFY_READ, req, sizeof(struct perfmon_req_t)*count)) return -EFAULT;
 
-			for (i = 0; i < count; i++, req++) {
-				copy_from_user(&tmp, req, sizeof(tmp));
+			return pfm_context_create(task, flags, req);
 
-				/* XXX needs to check validity of the data maybe */
+		case PFM_WRITE_PMCS:          
+			/* we don't quite support this right now */
+			if (task != current) return -EINVAL;
 
-				if (!PMC_IS_IMPL(tmp.pfr_reg_num)) {
-					DBprintk((__FUNCTION__ " invalid pmc[%ld]\n", tmp.pfr_reg_num));
-					return -EINVAL;
-				}
-
-				/* XXX: for counters, need to some checks */
-				if (PMC_IS_COUNTER(tmp.pfr_reg_num)) {
-					current->thread.pmu_counters[tmp.pfr_reg_num - PMU_FIRST_COUNTER].sig = tmp.pfr_notify_sig;
-					current->thread.pmu_counters[tmp.pfr_reg_num - PMU_FIRST_COUNTER].pid = tmp.pfr_notify_pid;
-
-					DBprintk((__FUNCTION__" setting PMC[%ld] send sig %d to %d\n",tmp.pfr_reg_num, tmp.pfr_notify_sig, tmp.pfr_notify_pid));
-				}
-				ia64_set_pmc(tmp.pfr_reg_num, tmp.pfr_reg_value);
+			if (!access_ok(VERIFY_READ, req, sizeof(struct perfmon_req_t)*count)) return -EFAULT;
 
-				DBprintk((__FUNCTION__" setting PMC[%ld]=0x%lx\n", tmp.pfr_reg_num, tmp.pfr_reg_value));
+			if (!ctx) {
+				DBprintk((" PFM_WRITE_PMCS: no context for task %d\n", task->pid));
+				return -EINVAL;
 			}
-			/*
-			 * we have to set this here event hough we haven't necessarily started monitoring
-			 * because we may be context switched out
-			 */
-			current->thread.flags |= IA64_THREAD_PM_VALID;
-                	break;
+			return pfm_write_pmcs(task, req, count);
 
 		case PFM_WRITE_PMDS:
 			/* we don't quite support this right now */
@@ -177,34 +929,22 @@
 
 			if (!access_ok(VERIFY_READ, req, sizeof(struct perfmon_req_t)*count)) return -EFAULT;
 
-			for (i = 0; i < count; i++, req++) {
-				copy_from_user(&tmp, req, sizeof(tmp));
-
-				if (!PMD_IS_IMPL(tmp.pfr_reg_num)) return -EINVAL;
-
-				/* update virtualized (64bits) counter */
-				if (PMD_IS_COUNTER(tmp.pfr_reg_num)) {
-					current->thread.pmu_counters[tmp.pfr_reg_num - PMU_FIRST_COUNTER].val  = tmp.pfr_reg_value & ~pmu_conf.perf_ovfl_val;
-					current->thread.pmu_counters[tmp.pfr_reg_num - PMU_FIRST_COUNTER].rval = tmp.pfr_reg_reset;
-				}
-				/* writes to unimplemented part is ignored, so this is safe */
-				ia64_set_pmd(tmp.pfr_reg_num, tmp.pfr_reg_value);
-				/* to go away */
-				ia64_srlz_d();
-				DBprintk((__FUNCTION__" setting PMD[%ld]:  pmod.val=0x%lx pmd=0x%lx rval=0x%lx\n", tmp.pfr_reg_num, current->thread.pmu_counters[tmp.pfr_reg_num - PMU_FIRST_COUNTER].val, ia64_get_pmd(tmp.pfr_reg_num),current->thread.pmu_counters[tmp.pfr_reg_num - PMU_FIRST_COUNTER].rval));
+			if (!ctx) {
+				DBprintk((" PFM_WRITE_PMDS: no context for task %d\n", task->pid));
+				return -EINVAL;
 			}
-			/*
-			 * we have to set this here event hough we haven't necessarily started monitoring
-			 * because we may be context switched out
-			 */
-			current->thread.flags |= IA64_THREAD_PM_VALID;
-                	break;
+			return pfm_write_pmds(task, req, count);
 
 		case PFM_START:
 			/* we don't quite support this right now */
 			if (task != current) return -EINVAL;
 
-			pmu_owners[smp_processor_id()] = current;
+			if (!ctx) {
+				DBprintk((" PFM_START: no context for task %d\n", task->pid));
+				return -EINVAL;
+			}
+
+			SET_PMU_OWNER(current);
 
 			/* will start monitoring right after rfi */
 			ia64_psr(regs)->up = 1;
@@ -213,9 +953,10 @@
 		 	 * mark the state as valid.
 		 	 * this will trigger save/restore at context switch
 		 	 */
-			current->thread.flags |= IA64_THREAD_PM_VALID;
+			th->flags |= IA64_THREAD_PM_VALID;
 
 			ia64_set_pmc(0, 0);
+			ia64_srlz_d();
 
                 	break;
 
@@ -223,23 +964,39 @@
 			/* we don't quite support this right now */
 			if (task != current) return -EINVAL;
 
-			pmu_owners[smp_processor_id()] = current;
+			if (!ctx) {
+				DBprintk((" PFM_ENABLE: no context for task %d\n", task->pid));
+				return -EINVAL;
+			}
+
+			/* reset all registers to stable quiet state */
+			ia64_reset_pmu();
+
+			/* make sure nothing starts */
+			ia64_psr(regs)->up = 0;
+			ia64_psr(regs)->pp = 0;
+
+			/* do it on the live register as well */
+			__asm__ __volatile__ ("rsm psr.pp|psr.pp;;"::: "memory");
+
+			SET_PMU_OWNER(current);
 
 			/* 
 		 	 * mark the state as valid.
 		 	 * this will trigger save/restore at context switch
 		 	 */
-			current->thread.flags |= IA64_THREAD_PM_VALID;
+			th->flags |= IA64_THREAD_PM_VALID;
 
 			/* simply unfreeze */
 			ia64_set_pmc(0, 0);
+			ia64_srlz_d();
 			break;
 
 		case PFM_DISABLE:
 			/* we don't quite support this right now */
 			if (task != current) return -EINVAL;
 
-			/* simply unfreeze */
+			/* simply freeze */
 			ia64_set_pmc(0, 1);
 			ia64_srlz_d();
 			break;
@@ -248,121 +1005,89 @@
 			if (!access_ok(VERIFY_READ, req, sizeof(struct perfmon_req_t)*count)) return -EFAULT;
 			if (!access_ok(VERIFY_WRITE, req, sizeof(struct perfmon_req_t)*count)) return -EFAULT;
 
-		/* This looks shady, but IMHO this will work fine. This is  
-		 * the sequence that I could come up with to avoid races
-		 * with the interrupt handler. See explanation in the 
-		 * following comment.
-		 */
-#if 0
-/* irrelevant with user monitors */
-		local_irq_save(flags);
-		__asm__ __volatile__("rsm psr.pp\n");
-		dcr = ia64_get_dcr();
-		dcr &= ~IA64_DCR_PP;
-		ia64_set_dcr(dcr);
-		local_irq_restore(flags);
-#endif
-		/*
-		 * We cannot write to pmc[0] to stop counting here, as
-		 * that particular instruction might cause an overflow
-		 * and the mask in pmc[0] might get lost. I'm _not_ 
-		 * sure of the hardware behavior here. So we stop
-		 * counting by psr.pp = 0. And we reset dcr.pp to
-		 * prevent an interrupt from mucking up psr.pp in the
-		 * meanwhile. Perfmon interrupts are pended, hence the
-		 * above code should be ok if one of the above instructions 
-		 * caused overflows, i.e the interrupt should get serviced
-		 * when we re-enabled interrupts. When I muck with dcr, 
-		 * is the irq_save/restore needed?
-		 */
-
-		for (i = 0; i < count; i++, req++) {
-			unsigned long val=0;
-
-			copy_from_user(&tmp, req, sizeof(tmp));
-
-			if (!PMD_IS_IMPL(tmp.pfr_reg_num)) return -EINVAL;
-
-			if (PMD_IS_COUNTER(tmp.pfr_reg_num)) {
-				if (task = current){
-					val = ia64_get_pmd(tmp.pfr_reg_num) & pmu_conf.perf_ovfl_val;
-				} else {
-					val = task->thread.pmd[tmp.pfr_reg_num - PMU_FIRST_COUNTER] & pmu_conf.perf_ovfl_val;
-				}
-				val += task->thread.pmu_counters[tmp.pfr_reg_num - PMU_FIRST_COUNTER].val;
-			} else {
-				/* for now */
-				if (task != current) return -EINVAL;
-
-				val = ia64_get_pmd(tmp.pfr_reg_num);
+			if (!ctx) {
+				DBprintk((" PFM_READ_PMDS: no context for task %d\n", task->pid));
+				return -EINVAL;
 			}
-			tmp.pfr_reg_value = val;
-
-DBprintk((__FUNCTION__" reading PMD[%ld]=0x%lx\n", tmp.pfr_reg_num, val));
-
-			if (copy_to_user(req, &tmp, sizeof(tmp))) return -EFAULT;
-		}
-#if 0
-/* irrelevant with user monitors */
-		local_irq_save(flags);
-		__asm__ __volatile__("ssm psr.pp");
-		dcr = ia64_get_dcr();
-		dcr |= IA64_DCR_PP;
-		ia64_set_dcr(dcr);
-		local_irq_restore(flags);
-#endif
-                break;
+			return pfm_read_pmds(task, req, count);
 
 	      case PFM_STOP:
-		/* we don't quite support this right now */
-		if (task != current) return -EINVAL;
-
-		ia64_set_pmc(0, 1);
-		ia64_srlz_d();
+			/* we don't quite support this right now */
+			if (task != current) return -EINVAL;
 
-		ia64_psr(regs)->up = 0;
+			ia64_set_pmc(0, 1);
+			ia64_srlz_d();
 
-		current->thread.flags &= ~IA64_THREAD_PM_VALID;
+			ia64_psr(regs)->up = 0;
 
-		pmu_owners[smp_processor_id()] = NULL;
+			th->flags &= ~IA64_THREAD_PM_VALID;
 
-#if 0
-/* irrelevant with user monitors */
-		local_irq_save(flags);
-		dcr = ia64_get_dcr();
-		dcr &= ~IA64_DCR_PP;
-		ia64_set_dcr(dcr);
-		local_irq_restore(flags);
-		ia64_psr(regs)->up = 0;
-#endif
+			SET_PMU_OWNER(NULL);
 
-		break;
+			/* we probably will need some more cleanup here */
+			break;
 
 	      case PFM_DEBUG_ON:
-			printk(__FUNCTION__" debuggin on\n");
+			printk(" debugging on\n");
 			pfm_debug = 1;
 			break;
 
 	      case PFM_DEBUG_OFF:
-			printk(__FUNCTION__" debuggin off\n");
+			printk(" debugging off\n");
 			pfm_debug = 0;
 			break;
 
+	      case PFM_RESTART: /* temporary, will most likely end up as a PFM_ENABLE */
+
+			if ((th->flags & IA64_THREAD_PM_VALID) = 0) {
+				printk(" PFM_RESTART not monitoring\n");
+				return -EINVAL;
+			}
+			if (!ctx) {
+				printk(" PFM_RESTART no ctx for %d\n", task->pid);
+				return -EINVAL;
+			}
+			if (CTX_OVFL_NOBLOCK(ctx) = 0 && ctx->ctx_fl_frozen=0) {
+				printk("task %d without pmu_frozen set\n", task->pid);
+				return -EINVAL;
+			}
+
+			return pfm_do_restart(task); /* we only look at first entry */
+
 	      default:
-		DBprintk((__FUNCTION__" UNknown command 0x%x\n", cmd));
-		return -EINVAL;
-		break;
+			DBprintk((" UNknown command 0x%x\n", cmd));
+			return -EINVAL;
         }
         return 0;
 }
 
+/*
+ * XXX: do something better here
+ */
+static int
+perfmon_bad_permissions(struct task_struct *task)
+{
+	/* stolen from bad_signal() */
+	return (current->session != task->session)
+	    && (current->euid ^ task->suid) && (current->euid ^ task->uid)
+	    && (current->uid ^ task->suid) && (current->uid ^ task->uid);
+}
+
 asmlinkage int
 sys_perfmonctl (int pid, int cmd, int flags, perfmon_req_t *req, int count, long arg6, long arg7, long arg8, long stack)
 {
 	struct pt_regs *regs = (struct pt_regs *) &stack;
 	struct task_struct *child = current;
-	int ret;
+	int ret = -ESRCH;
 
+	/* sanity check:
+	 *
+	 * ensures that we don't do bad things in case the OS
+	 * does not have enough storage to save/restore PMC/PMD
+	 */
+	if (PERFMON_IS_DISABLED()) return -ENOSYS;
+
+	/* XXX: pid interface is going away in favor of pfm context */
 	if (pid != current->pid) {
 		read_lock(&tasklist_lock);
 		{
@@ -370,37 +1095,240 @@
 			if (child)
 				get_task_struct(child);
 		}
-		if (!child) { 
-			read_unlock(&tasklist_lock);
-			return -ESRCH;
-		}
+
+		if (!child) goto abort_call;
+
+		ret = -EPERM;
+
+		if (perfmon_bad_permissions(child)) goto abort_call;
+		
 		/*
 		 * XXX: need to do more checking here
 		 */
-		if (child->state != TASK_ZOMBIE) {
-			DBprintk((__FUNCTION__" warning process %d not in stable state %ld\n", pid, child->state));
+		if (child->state != TASK_ZOMBIE && child->state != TASK_STOPPED) {
+			DBprintk((" warning process %d not in stable state %ld\n", pid, child->state));
 		}
 	} 
 	ret = do_perfmonctl(child, cmd, flags, req, count, regs);
 
+abort_call:
 	if (child != current) read_unlock(&tasklist_lock);
 
 	return ret;
 }
 
 
-static inline int
-update_counters (u64 pmc0)
+/*
+ * This function is invoked on the exit path of the kernel. Therefore it must make sure
+ * it does does modify the caller's input registers (in0-in7) in case of entry by system call
+ * which can be restarted. That's why it's declared as a system call and all 8 possible args
+ * are declared even though not used.
+ */
+void asmlinkage
+pfm_overflow_notify(u64 arg0, u64 arg1, u64 arg2, u64 arg3, u64 arg4, u64 arg5, u64 arg6, u64 arg7)
 {
-	unsigned long mask, i, cnum;
-	struct thread_struct *th;
-	struct task_struct *ta;
+	struct task_struct *task;
+	struct thread_struct *th = &current->thread;
+	pfm_context_t *ctx = current->thread.pfm_context;
+	struct siginfo si;
+	int ret;
 
-	if (pmu_owners[smp_processor_id()] = NULL) {
-		DBprintk((__FUNCTION__" Spurious overflow interrupt: PMU not owned\n"));
-		return 0;
+	/*
+	 * do some sanity checks first
+	 */
+	if (!ctx) {
+		printk("perfmon: process %d has no PFM context\n", current->pid);
+		return;
 	}
-	
+	if (ctx->ctx_notify_pid < 2) {
+		printk("perfmon: process %d invalid notify_pid=%d\n", current->pid, ctx->ctx_notify_pid);
+		return;
+	}
+
+	DBprintk((" current=%d ctx=%p bv=0%lx\n", current->pid, ctx, ctx->ctx_ovfl_regs));
+	/*
+	 * NO matter what notify_pid is, 
+	 * we clear overflow, won't notify again
+	 */
+	th->pfm_pend_notify = 0;
+
+	/*
+	 * When measuring in kernel mode and non-blocking fashion, it is possible to
+	 * get an overflow while executing this code. Therefore the state of pend_notify
+	 * and ovfl_regs can be altered. The important point is not to loose any notification.
+	 * It is fine to get called for nothing. To make sure we do collect as much state as
+	 * possible, update_counters() always uses |= to add bit to the ovfl_regs field.
+	 *
+	 * In certain cases, it is possible to come here, with ovfl_regs = 0;
+	 *
+	 * XXX: pend_notify and ovfl_regs could be merged maybe !
+	 */
+	if (ctx->ctx_ovfl_regs = 0) {
+		printk("perfmon: spurious overflow notification from pid %d\n", current->pid);
+		return;
+	}
+	read_lock(&tasklist_lock);
+
+	task = find_task_by_pid(ctx->ctx_notify_pid);
+
+	if (task) {
+		si.si_signo    = ctx->ctx_notify_sig;
+		si.si_errno    = 0;
+		si.si_code     = PROF_OVFL; /* goes to user */
+		si.si_addr     = NULL;
+		si.si_pid      = current->pid; /* who is sending */
+		si.si_pfm_ovfl = ctx->ctx_ovfl_regs;
+
+		DBprintk((" SIGPROF to %d @ %p\n", task->pid, task));
+
+		/* must be done with tasklist_lock locked */
+		ret = send_sig_info(ctx->ctx_notify_sig, &si, task);
+		if (ret != 0) {
+			DBprintk((" send_sig_info(process %d, SIGPROF)=%d\n", ctx->ctx_notify_pid, ret));
+			task = NULL; /* will cause return */
+		}
+	} else {
+		printk("perfmon: notify_pid %d not found\n", ctx->ctx_notify_pid);
+	}
+
+	read_unlock(&tasklist_lock);
+
+	/* now that we have released the lock handle error condition */
+	if (!task || CTX_OVFL_NOBLOCK(ctx)) {
+		/* we clear all pending overflow bits in noblock mode */
+		ctx->ctx_ovfl_regs = 0;
+		return;
+	}
+	DBprintk((" CPU%d %d before sleep\n", smp_processor_id(), current->pid));
+
+	/*
+	 * may go through without blocking on SMP systems
+	 * if restart has been received already by the time we call down()
+	 */
+	ret = down_interruptible(&ctx->ctx_restart_sem);
+
+	DBprintk((" CPU%d %d after sleep ret=%d\n", smp_processor_id(), current->pid, ret));
+
+	/*
+	 * in case of interruption of down() we don't restart anything
+	 */
+	if (ret >= 0) {
+		/* we reactivate on context switch */
+		ctx->ctx_fl_frozen = 0;
+		/* 
+	 	 * the ovfl_sem is cleared by the restart task and this is safe because we always
+	 	 * use the local reference
+	 	 */
+
+		pfm_reset_regs(ctx);
+
+		/* now we can clear this mask */
+		ctx->ctx_ovfl_regs = 0;
+
+		/* 
+		 * Unlock sampling buffer and reset index atomically
+		 * XXX: not really needed when blocking
+		 */
+		if (CTX_HAS_SMPL(ctx)) {
+			ctx->ctx_smpl_buf->psb_hdr->hdr_count = 0;
+			ctx->ctx_smpl_buf->psb_index = 0;
+		}
+
+		DBprintk((" CPU%d %d unfreeze PMU\n", smp_processor_id(), current->pid));
+
+		ia64_set_pmc(0, 0);
+		ia64_srlz_d();
+
+		/* state restored, can go back to work (user mode) */
+	}
+}
+
+static void
+perfmon_softint(unsigned long ignored)
+{
+	notification_info_t *info;
+	int my_cpu = smp_processor_id();
+	struct task_struct *task;
+	struct siginfo si;
+
+	info = notify_info+my_cpu;
+
+	DBprintk((" CPU%d current=%d to_pid=%d from_pid=%d bv=0x%lx\n", \
+		smp_processor_id(), current->pid, info->to_pid, info->from_pid, info->bitvect));
+
+	/* assumption check */
+	if (info->from_pid = info->to_pid) {
+		DBprintk((" Tasklet assumption error: from=%d tor=%d\n", info->from_pid, info->to_pid));
+		return;
+	}
+
+	if (notification_is_invalid(info)) {
+		DBprintk((" invalid notification information\n"));
+		return;
+	}
+
+	/* sanity check */
+	if (info->to_pid = 1) {
+		DBprintk((" cannot notify init\n"));
+		return;
+	}
+	/*
+	 * XXX: needs way more checks here to make sure we send to a task we have control over
+	 */
+	read_lock(&tasklist_lock);
+
+	task = find_task_by_pid(info->to_pid);
+
+	DBprintk((" after find %p\n", task));
+
+	if (task) {
+		int ret;
+
+		si.si_signo    = SIGPROF;
+		si.si_errno    = 0;
+		si.si_code     = PROF_OVFL; /* goes to user */
+		si.si_addr     =  NULL;
+		si.si_pid      = info->from_pid; /* who is sending */
+		si.si_pfm_ovfl = info->bitvect;
+
+		DBprintk((" SIGPROF to %d @ %p\n", task->pid, task));
+
+		/* must be done with tasklist_lock locked */
+		ret = send_sig_info(SIGPROF, &si, task);
+		if (ret != 0) 
+			DBprintk((" send_sig_info(process %d, SIGPROF)=%d\n", info->to_pid, ret));
+
+		/* invalidate notification */
+		info->to_pid  = info->from_pid = 0;
+		info->bitvect = 0;
+	}
+
+	read_unlock(&tasklist_lock);
+
+	DBprintk((" after unlock %p\n", task));
+
+	if (!task) { 
+		printk("perfmon: CPU%d cannot find process %d\n", smp_processor_id(), info->to_pid);
+	}
+}
+
+/*
+ * main overflow processing routine.
+ * it can be called from the interrupt path or explicitely during the context switch code
+ * Return:
+ * 	0 : do not unfreeze the PMU 
+ *	1 : PMU can be unfrozen 
+ */
+static unsigned long
+update_counters (struct task_struct *ta, u64 pmc0, struct pt_regs *regs)
+{
+	unsigned long mask, i, cnum;
+	struct thread_struct *th;
+	pfm_context_t *ctx;
+	unsigned long bv = 0;
+	int my_cpu = smp_processor_id();
+	int ret = 1, buffer_is_full = 0;
+	int ovfl_is_smpl, can_notify, need_reset_pmd16=0;
 	/*
 	 * It is never safe to access the task for which the overflow interrupt is destinated
 	 * using the current variable as the interrupt may occur in the middle of a context switch
@@ -408,76 +1336,269 @@
 	 *
 	 * For monitoring, however, we do need to get access to the task which caused the overflow
 	 * to account for overflow on the counters.
+	 *
 	 * We accomplish this by maintaining a current owner of the PMU per CPU. During context
 	 * switch the ownership is changed in a way such that the reflected owner is always the 
 	 * valid one, i.e. the one that caused the interrupt.
 	 */
-	ta = pmu_owners[smp_processor_id()];
-	th = &pmu_owners[smp_processor_id()]->thread;
+
+	if (ta = NULL) {
+		DBprintk((" owners[%d]=NULL\n", my_cpu));
+		return 0x1;
+	}
+	th  = &ta->thread;
+	ctx = th->pfm_context;
 
 	/*
-	 * Don't think this could happen given first test. Keep as sanity check
+	 * XXX: debug test
+	 * Don't think this could happen given upfront tests
 	 */
 	if ((th->flags & IA64_THREAD_PM_VALID) = 0) {
-		DBprintk((__FUNCTION__" Spurious overflow interrupt: process %d not using perfmon\n", ta->pid));
+		printk("perfmon: Spurious overflow interrupt: process %d not using perfmon\n", ta->pid);
+		return 0x1;
+	}
+	if (!ctx) {
+		printk("perfmon: Spurious overflow interrupt: process %d has no PFM context\n", ta->pid);
 		return 0;
 	}
 
 	/*
-	 * if PMU not frozen: spurious from previous context 
-	 * if PMC[0] = 0x1 : frozen but no overflow reported: leftover from previous context
-	 *
-	 * in either case we don't touch the state upon return from handler
+	 * sanity test. Should never happen
 	 */
-	if ((pmc0 & 0x1) = 0 || pmc0 = 0x1) { 
-		DBprintk((__FUNCTION__" Spurious overflow interrupt: process %d freeze=0\n",ta->pid));
-		return 0;
+	if ((pmc0 & 0x1 )= 0) {
+		printk("perfmon: pid %d pmc0=0x%lx assumption error for freeze bit\n", ta->pid, pmc0);
+		return 0x0;
 	}
 
-	mask = pmc0 >> 4;
+	mask = pmc0 >> PMU_FIRST_COUNTER;
 
-	for (i = 0, cnum = PMU_FIRST_COUNTER; i < pmu_conf.max_counters; cnum++, i++, mask >>= 1) {
+	DBprintk(("pmc0=0x%lx pid=%d\n", pmc0, ta->pid));
 
-		if (mask & 0x1) {
-			DBprintk((__FUNCTION__ " PMD[%ld] overflowed pmd=0x%lx pmod.val=0x%lx\n", cnum, ia64_get_pmd(cnum), th->pmu_counters[i].val)); 
-			
+	DBprintk(("ctx is in %s mode\n", CTX_OVFL_NOBLOCK(ctx) ? "NO-BLOCK" : "BLOCK"));
+
+	if (CTX_HAS_SMPL(ctx)) {
+		pfm_smpl_buffer_desc_t *psb = ctx->ctx_smpl_buf;
+		unsigned long *e, m, idx=0;
+		perfmon_smpl_entry_t *h;
+		int j;
+
+		idx = ia64_fetch_and_add(1, &psb->psb_index);
+		DBprintk((" trying to record index=%ld entries=%ld\n", idx, psb->psb_entries));
+
+		/*
+		 * XXX: there is a small chance that we could run out on index before resetting
+		 * but index is unsigned long, so it will take some time.....
+		 */
+		if (idx > psb->psb_entries) {
+			buffer_is_full = 1;
+			goto reload_pmds;
+		}
+
+		/* first entry is really entry 0, not 1 caused by fetch_and_add */
+		idx--;
+
+		h = (perfmon_smpl_entry_t *)(((char *)psb->psb_addr) + idx*(psb->psb_entry_size));
+
+		h->pid  = ta->pid;
+		h->cpu  = my_cpu;
+		h->rate = 0;
+		h->ip   = regs ? regs->cr_iip : 0x0; /* where did the fault happened */
+		h->regs = mask; /* which registers overflowed */
+
+		/* guaranteed to monotonically increase on each cpu */
+		h->stamp = perfmon_get_stamp(); 
+
+		e = (unsigned long *)(h+1);
+		/*
+		 * selectively store PMDs in increasing index number
+		 */
+		for (j=0, m = ctx->ctx_smpl_regs; m; m >>=1, j++) {
+			if (m & 0x1) {
+				if (PMD_IS_COUNTER(j))
+					*e =  ctx->ctx_pmds[j-PMU_FIRST_COUNTER].val
+					    + (ia64_get_pmd(j) & pmu_conf.perf_ovfl_val);
+				else
+					*e = ia64_get_pmd(j); /* slow */
+				DBprintk((" e=%p pmd%d =0x%lx\n", e, j, *e)); 
+				e++;
+			}
+		}
+		/* make the new entry visible to user, needs to be atomic */
+		ia64_fetch_and_add(1, &psb->psb_hdr->hdr_count);
+
+		DBprintk((" index=%ld entries=%ld hdr_count=%ld\n", idx, psb->psb_entries, psb->psb_hdr->hdr_count));
+
+		/* sampling buffer full ? */
+		if (idx = (psb->psb_entries-1)) {
+			bv = mask;
+			buffer_is_full = 1;
+
+			DBprintk((" sampling buffer full must notify bv=0x%lx\n", bv));
+
+			if (!CTX_OVFL_NOBLOCK(ctx)) goto buffer_full;
 			/*
-			 * Because we somtimes (EARS/BTB) reset to a specific value, we cannot simply use 
-			 * val to count the number of times we overflowed. Otherwise we would loose the value
-			 * current in the PMD (which can be >0). So to make sure we don't loose
-			 * the residual counts we set val to contain full 64bits value of the counter.
+			 * here, we have a full buffer but we are in non-blocking mode
+			 * so we need to reloads overflowed PMDs with sampling reset values
+			 * and restart
 			 */
-			th->pmu_counters[i].val += 1+pmu_conf.perf_ovfl_val+(ia64_get_pmd(cnum) &pmu_conf.perf_ovfl_val);
+		}
+	} 
+reload_pmds:
+	ovfl_is_smpl = CTX_OVFL_NOBLOCK(ctx) && buffer_is_full;
+	can_notify   = CTX_HAS_SMPL(ctx) = 0 && ctx->ctx_notify_pid;
 
-			/* writes to upper part are ignored, so this is safe */
-			ia64_set_pmd(cnum, th->pmu_counters[i].rval);
+	for (i = 0, cnum = PMU_FIRST_COUNTER; mask ; cnum++, i++, mask >>= 1) {
+
+		if ((mask & 0x1) = 0) continue;
+
+		DBprintk((" PMD[%ld] overflowed pmd=0x%lx pmod.val=0x%lx\n", cnum, ia64_get_pmd(cnum), ctx->ctx_pmds[i].val)); 
+			
+		/*
+		 * Because we sometimes (EARS/BTB) reset to a specific value, we cannot simply use 
+		 * val to count the number of times we overflowed. Otherwise we would loose the current value
+		 * in the PMD (which can be >0). So to make sure we don't loose
+		 * the residual counts we set val to contain full 64bits value of the counter.
+		 *
+		 * XXX: is this needed for EARS/BTB ?
+		 */
+		ctx->ctx_pmds[i].val += 1 + pmu_conf.perf_ovfl_val
+				      + (ia64_get_pmd(cnum) & pmu_conf.perf_ovfl_val); /* slow */
+
+		DBprintk((" pmod[%ld].val=0x%lx pmd=0x%lx\n", i, ctx->ctx_pmds[i].val, ia64_get_pmd(cnum)&pmu_conf.perf_ovfl_val)); 
 
-			DBprintk((__FUNCTION__ " pmod[%ld].val=0x%lx pmd=0x%lx\n", i, th->pmu_counters[i].val, ia64_get_pmd(cnum)&pmu_conf.perf_ovfl_val)); 
+		if (can_notify && PMD_OVFL_NOTIFY(ctx, i)) {
+			DBprintk((" CPU%d should notify process %d with signal %d\n", my_cpu, ctx->ctx_notify_pid, ctx->ctx_notify_sig)); 
+			bv |= 1 << i;
+		} else {
+			DBprintk((" CPU%d PMD[%ld] overflow, no notification\n", my_cpu, cnum));
+			/*
+			 * In case no notification is requested, we reload the reset value right away
+			 * otherwise we wait until the notify_pid process has been called and has
+			 * has finished processing data. Check out pfm_overflow_notify()
+			 */
 
-			if (th->pmu_counters[i].pid != 0 && th->pmu_counters[i].sig>0) {
-				DBprintk((__FUNCTION__ " shouild notify process %d with signal %d\n",th->pmu_counters[i].pid, th->pmu_counters[i].sig)); 
+			/* writes to upper part are ignored, so this is safe */
+			if (ovfl_is_smpl) {
+				DBprintk((" CPU%d PMD[%ld] reloaded with smpl_val=%lx\n", my_cpu, cnum,ctx->ctx_pmds[i].smpl_rval));
+				ia64_set_pmd(cnum, ctx->ctx_pmds[i].smpl_rval);
+			} else {
+				DBprintk((" CPU%d PMD[%ld] reloaded with ovfl_val=%lx\n", my_cpu, cnum,ctx->ctx_pmds[i].smpl_rval));
+				ia64_set_pmd(cnum, ctx->ctx_pmds[i].ovfl_rval);
 			}
 		}
+		if (cnum = ctx->ctx_btb_counter) need_reset_pmd16=1;
 	}
-	return 1;
+	/*
+	 * In case of BTB, overflow
+	 * we need to reset the BTB index.
+	 */ 
+	if (need_reset_pmd16) {
+		DBprintk(("reset PMD16\n"));
+		ia64_set_pmd(16, 0);
+	}
+buffer_full:
+	/* see pfm_overflow_notify() on details for why we use |= here */
+	ctx->ctx_ovfl_regs  |= bv;
+
+	/* nobody to notify, return and unfreeze */
+	if (!bv) return 0x0;
+
+
+	if (ctx->ctx_notify_pid = ta->pid) {
+		struct siginfo si;
+
+		si.si_errno    = 0;
+		si.si_addr     = NULL;
+		si.si_pid      = ta->pid; /* who is sending */
+
+
+		si.si_signo    = ctx->ctx_notify_sig; /* is SIGPROF */
+		si.si_code     = PROF_OVFL; /* goes to user */
+		si.si_pfm_ovfl = bv;
+
+
+		/*
+		 * in this case, we don't stop the task, we let it go on. It will
+		 * necessarily go to the signal handler (if any) when it goes back to
+		 * user mode.
+		 */
+		DBprintk((" sending %d notification to self %d\n", si.si_signo, ta->pid));
+
+
+		/* this call is safe in an interrupt handler */
+		ret = send_sig_info(ctx->ctx_notify_sig, &si, ta);
+		if (ret != 0) 
+			printk(" send_sig_info(process %d, SIGPROF)=%d\n", ta->pid, ret);
+		/*
+		 * no matter if we block or not, we keep PMU frozen and do not unfreeze on ctxsw
+		 */
+		ctx->ctx_fl_frozen = 1;
+
+	} else {
+#if 0
+			/*
+			 * The tasklet is guaranteed to be scheduled for this CPU only
+			 */
+			notify_info[my_cpu].to_pid   = ctx->notify_pid;
+			notify_info[my_cpu].from_pid = ta->pid; /* for debug only */
+			notify_info[my_cpu].bitvect  = bv;
+			/* tasklet is inserted and active */
+			tasklet_schedule(&pfm_tasklet);
+#endif
+			/*
+			 * stored the vector of overflowed registers for use in notification
+			 * mark that a notification/blocking is pending (arm the trap)
+			 */
+		th->pfm_pend_notify = 1;
+
+		/*
+		 * if we do block, then keep PMU frozen until restart
+		 */
+		if (!CTX_OVFL_NOBLOCK(ctx)) ctx->ctx_fl_frozen = 1;
+
+		DBprintk((" process %d notify ovfl_regs=0x%lx\n", ta->pid, bv));
+	}
+	/*
+	 * keep PMU frozen (and overflowed bits cleared) when we have to stop, 
+	 * otherwise return a resume 'value' for PMC[0]
+	 *
+	 * XXX: maybe that's enough to get rid of ctx_fl_frozen ?
+	 */
+	DBprintk((" will return pmc0=0x%x\n",ctx->ctx_fl_frozen ? 0x1 : 0x0)); 
+	return ctx->ctx_fl_frozen ? 0x1 : 0x0;
 }
 
 static void
 perfmon_interrupt (int irq, void *arg, struct pt_regs *regs)
 {
-	/* unfreeze if not spurious */
-	if ( update_counters(ia64_get_pmc(0)) ) {
-		ia64_set_pmc(0, 0);
+	u64 pmc0;
+	struct task_struct *ta;
+
+	pmc0 = ia64_get_pmc(0); /* slow */
+
+	/*
+	 * if we have some pending bits set
+	 * assumes : if any PM[0].bit[63-1] is set, then PMC[0].fr = 1 
+	 */
+	if ((pmc0 & ~0x1) && (ta=PMU_OWNER())) {
+
+		/* assumes, PMC[0].fr = 1 at this point */
+		pmc0 = update_counters(ta, pmc0, regs);
+
+		/* 
+		 * if pmu_frozen = 0
+		 * 	pmc0 = 0 and we resume monitoring right away
+		 * else
+		 * 	pmc0 = 0x1 frozen but all pending bits are cleared
+		 */
+		ia64_set_pmc(0, pmc0);
 		ia64_srlz_d();
+	} else {
+		printk("perfmon: Spurious PMU overflow interrupt: pmc0=0x%lx owner=%p\n", pmc0, PMU_OWNER());
 	}
 }
 
-static struct irqaction perfmon_irqaction = {
-	handler:	perfmon_interrupt,
-	flags:		SA_INTERRUPT,
-	name:		"perfmon"
-};
-
+/* for debug only */
 static int
 perfmon_proc_info(char *page)
 {
@@ -488,11 +1609,12 @@
 	p += sprintf(p, "PMC[0]=%lx\nPerfmon debug: %s\n", pmc0, pfm_debug ? "On" : "Off");
 	for(i=0; i < NR_CPUS; i++) {
 		if (cpu_is_online(i)) 
-			p += sprintf(p, "CPU%d.PMU %d\n", i, pmu_owners[i] ? pmu_owners[i]->pid: -1);
+			p += sprintf(p, "CPU%d.PMU %d\n", i, pmu_owners[i].owner ? pmu_owners[i].owner->pid: 0);
 	}
 	return p - page;
 }
 
+/* for debug only */
 static int
 perfmon_read_entry(char *page, char **start, off_t off, int count, int *eof, void *data)
 {
@@ -509,7 +1631,11 @@
         return len;
 }
 
-static struct proc_dir_entry *perfmon_dir;
+static struct irqaction perfmon_irqaction = {
+	handler:	perfmon_interrupt,
+	flags:		SA_INTERRUPT,
+	name:		"perfmon"
+};
 
 void __init
 perfmon_init (void)
@@ -524,19 +1650,39 @@
 	ia64_set_pmv(PERFMON_IRQ);
 	ia64_srlz_d();
 
-	printk("perfmon: Initialized vector to %u\n",PERFMON_IRQ);
+	pmu_conf.pfm_is_disabled = 1;
+
+	printk("perfmon: version %s\n", PFM_VERSION);
+	printk("perfmon: Interrupt vectored to %u\n", PERFMON_IRQ);
 
 	if ((status=ia64_pal_perf_mon_info(pmu_conf.impl_regs, &pm_info)) != 0) {
-		printk(__FUNCTION__ " pal call failed (%ld)\n", status);
+		printk("perfmon: PAL call failed (%ld)\n", status);
 		return;
 	} 
 	pmu_conf.perf_ovfl_val = (1L << pm_info.pal_perf_mon_info_s.width) - 1; 
-
-	/* XXX need to use PAL instead */
 	pmu_conf.max_counters  = pm_info.pal_perf_mon_info_s.generic;
+	pmu_conf.num_pmds      = find_num_pm_regs(pmu_conf.impl_regs);
+	pmu_conf.num_pmcs      = find_num_pm_regs(&pmu_conf.impl_regs[4]);
 
 	printk("perfmon: Counters are %d bits\n", pm_info.pal_perf_mon_info_s.width);
 	printk("perfmon: Maximum counter value 0x%lx\n", pmu_conf.perf_ovfl_val);
+	printk("perfmon: %ld PMC/PMD pairs\n", pmu_conf.max_counters);
+	printk("perfmon: %ld PMCs, %ld PMDs\n", pmu_conf.num_pmcs, pmu_conf.num_pmds);
+	printk("perfmon: Sampling format v%d\n", PFM_SMPL_HDR_VERSION);
+
+	/* sanity check */
+	if (pmu_conf.num_pmds >= IA64_NUM_PMD_REGS || pmu_conf.num_pmcs >= IA64_NUM_PMC_REGS) {
+		printk(KERN_ERR "perfmon: ERROR not enough PMC/PMD storage in kernel, perfmon is DISABLED\n");
+		return; /* no need to continue anyway */
+	}
+	/* we are all set */
+	pmu_conf.pfm_is_disabled = 0;
+
+	/*
+	 * Insert the tasklet in the list. 
+	 * It is still disabled at this point, so it won't run
+	printk(__FUNCTION__" tasklet is %p state=%d, count=%d\n", &perfmon_tasklet, perfmon_tasklet.state, perfmon_tasklet.count);
+	 */
 
 	/*
 	 * for now here for debug purposes
@@ -555,14 +1701,19 @@
  * XXX: for system wide this function MUST never be called
  */
 void
-ia64_save_pm_regs (struct task_struct *ta)
+pfm_save_regs (struct task_struct *ta)
 {
-	struct thread_struct *t = &ta->thread;
+	struct task_struct *owner;
+	struct thread_struct *t;
 	u64 pmc0, psr;
-	int i,j;
+	int i;
 
+	if (ta = NULL) {
+		panic(__FUNCTION__" task is NULL\n");
+	}
+	t = &ta->thread;
 	/*
-	 * We must maek sure that we don't loose any potential overflow
+	 * We must make sure that we don't loose any potential overflow
 	 * interrupt while saving PMU context. In this code, external
 	 * interrupts are always enabled.
 	 */
@@ -575,94 +1726,102 @@
 	/*
 	 * stop monitoring:
 	 * This is the only way to stop monitoring without destroying overflow
-	 * information in PMC[0..3].
+	 * information in PMC[0].
 	 * This is the last instruction which can cause overflow when monitoring
 	 * in kernel.
-	 * By now, we could still have an overflow interrupt in flight.
+	 * By now, we could still have an overflow interrupt in-flight.
 	 */
-	__asm__ __volatile__ ("rsm psr.up;;"::: "memory");
+	__asm__ __volatile__ ("rum psr.up;;"::: "memory");
 	
 	/*
+	 * Mark the PMU as not owned
+	 * This will cause the interrupt handler to do nothing in case an overflow
+	 * interrupt was in-flight
+	 * This also guarantees that pmc0 will contain the final state 
+	 * It virtually gives us full control on overflow processing from that point
+	 * on.
+	 * It must be an atomic operation.
+	 */
+	owner = PMU_OWNER();
+	SET_PMU_OWNER(NULL);
+
+	/*
 	 * read current overflow status:
 	 *
-	 * We may be reading stale information at this point, if we got interrupt
-	 * just before the read(pmc0) but that's all right. However, if we did
-	 * not get the interrupt before, this read reflects LAST state.
-	 *
+	 * we are guaranteed to read the final stable state
 	 */
-	pmc0 = ia64_get_pmc(0);
+	ia64_srlz_d();
+	pmc0 = ia64_get_pmc(0); /* slow */
 
 	/*
 	 * freeze PMU:
 	 *
 	 * This destroys the overflow information. This is required to make sure
 	 * next process does not start with monitoring on if not requested
-	 * (PSR.up may not be enough).
-	 *
-	 * We could still get an overflow interrupt by now. However the handler
-	 * will not do anything if is sees PMC[0].fr=1 but no overflow bits
-	 * are set. So PMU will stay in frozen state. This implies that pmc0
-	 * will still be holding the correct unprocessed information.
-	 *
 	 */
 	ia64_set_pmc(0, 1);
 	ia64_srlz_d();
 
 	/*
-	 * check for overflow bits set:
-	 *
-	 * If pmc0 reports PMU frozen, this means we have a pending overflow,
-	 * therefore we invoke the handler. Handler is reentrant with regards
-	 * to PMC[0] so it is safe to call it twice.
-	 *
-	 * IF pmc0 reports overflow, we need to reread current PMC[0] value
-	 * in case the handler was invoked right after the first pmc0 read.
-	 * it is was not invoked then pmc0=PMC[0], otherwise it's been invoked
-	 * and overflow information has been processed, so we don't need to call.
-	 *
-	 * Test breakdown:
-	 *	- pmc0 & ~0x1: test if overflow happened
-	 * 	- second part: check if current register reflects this as well.
-	 *
-	 * NOTE: testing for pmc0 & 0x1 is not enough has it would trigger call
-	 * when PM_VALID and PMU.fr which is common when setting up registers
-	 * just before actually starting monitors.
+	 * Check for overflow bits and proceed manually if needed
 	 *
+	 * It is safe to call the interrupt handler now because it does
+	 * not try to block the task right away. Instead it will set a
+	 * flag and let the task proceed. The blocking will only occur
+	 * next time the task exits from the kernel. 
 	 */
-	if ((pmc0 & ~0x1) && ((pmc0=ia64_get_pmc(0)) &~0x1) ) {
-		printk(__FUNCTION__" Warning: pmc[0]=0x%lx\n", pmc0);
-		update_counters(pmc0);
-		/* 
-		 * XXX: not sure that's enough. the next task may still get the
-		 * interrupt.
-		 */
+	if (pmc0 & ~0x1) {
+		if (owner != ta) printk(__FUNCTION__" owner=%p task=%p\n", owner, ta);
+		printk(__FUNCTION__" Warning: pmc[0]=0x%lx explicit call\n", pmc0);
+
+		pmc0 = update_counters(owner, pmc0, NULL);
+		/* we will save the updated version of pmc0 */
 	}
 
 	/*
 	 * restore PSR for context switch to save
 	 */
-	__asm__ __volatile__ ("mov psr.l=%0;;"::"r"(psr): "memory");
+	__asm__ __volatile__ ("mov psr.l=%0;; srlz.i;;"::"r"(psr): "memory");
 
-	/*
-	 * XXX: this will need to be extended beyong just counters
+	
+	/* 
+	 * XXX needs further optimization.
+	 * Also must take holes into account
 	 */
-	for (i=0,j=4; i< IA64_NUM_PMD_COUNTERS; i++,j++) {
-		t->pmd[i] = ia64_get_pmd(j);
-		t->pmc[i] = ia64_get_pmc(j);
+	for (i=0; i< pmu_conf.num_pmds; i++) {
+		t->pmd[i] = ia64_get_pmd(i);
 	}
+
+	/* skip PMC[0], we handle it separately */
+	for (i=1; i< pmu_conf.num_pmcs; i++) {
+		t->pmc[i] = ia64_get_pmc(i);
+	}
+
 	/*
-	 * PMU is frozen, PMU context is saved: nobody owns the PMU on this CPU
-	 * At this point, we should not receive any pending interrupt from the 
-	 * 'switched out' task
+	 * Throughout this code we could have gotten an overflow interrupt. It is transformed
+	 * into a spurious interrupt as soon as we give up pmu ownership.
 	 */
-	pmu_owners[smp_processor_id()] = NULL;
 }
 
 void
-ia64_load_pm_regs (struct task_struct *ta)
+pfm_load_regs (struct task_struct *ta)
 {
 	struct thread_struct *t = &ta->thread;
-	int i,j;
+	pfm_context_t *ctx = ta->thread.pfm_context;
+	int i;
+
+	/* 
+	 * XXX needs further optimization.
+	 * Also must take holes into account
+	 */
+	for (i=0; i< pmu_conf.num_pmds; i++) {
+		ia64_set_pmd(i, t->pmd[i]);
+	}
+
+	/* skip PMC[0] to avoid side effects */
+	for (i=1; i< pmu_conf.num_pmcs; i++) {
+		ia64_set_pmc(i, t->pmc[i]);
+	}
 
 	/*
 	 * we first restore ownership of the PMU to the 'soon to be current'
@@ -670,26 +1829,277 @@
 	 * of this function, we get an interrupt, we attribute it to the correct
 	 * task
 	 */
-	pmu_owners[smp_processor_id()] = ta;
+	SET_PMU_OWNER(ta);
+
+#if 0
+	/*
+	 * check if we had pending overflow before context switching out
+	 * If so, we invoke the handler manually, i.e. simulate interrupt.
+	 *
+	 * XXX: given that we do not use the tasklet anymore to stop, we can
+	 * move this back to the pfm_save_regs() routine.
+	 */
+	if (t->pmc[0] & ~0x1) {
+		/* freeze set in pfm_save_regs() */
+		DBprintk((" pmc[0]=0x%lx manual interrupt\n",t->pmc[0])); 
+		update_counters(ta, t->pmc[0], NULL);
+	}
+#endif
 
 	/*
-	 * XXX: this will need to be extended beyong just counters 
+	 * unfreeze only when possible 
 	 */
-	for (i=0,j=4; i< IA64_NUM_PMD_COUNTERS; i++,j++) {
-		ia64_set_pmd(j, t->pmd[i]);
-		ia64_set_pmc(j, t->pmc[i]);
+	if (ctx->ctx_fl_frozen = 0) {
+		ia64_set_pmc(0, 0);
+		ia64_srlz_d();
+	}
+}
+
+
+/*
+ * This function is called when a thread exits (from exit_thread()).
+ * This is a simplified pfm_save_regs() that simply flushes hthe current
+ * register state into the save area taking into account any pending
+ * overflow. This time no notification is sent because the taks is dying
+ * anyway. The inline processing of overflows avoids loosing some counts.
+ * The PMU is frozen on exit from this call and is to never be reenabled
+ * again for this task.
+ */
+void
+pfm_flush_regs (struct task_struct *ta)
+{
+	pfm_context_t *ctx;
+	u64 pmc0, psr, mask;
+	int i,j;
+
+	if (ta = NULL) {
+		panic(__FUNCTION__" task is NULL\n");
+	}
+	ctx = ta->thread.pfm_context;
+	if (ctx = NULL) {
+		panic(__FUNCTION__" no PFM ctx is NULL\n");
 	}
 	/*
-	 * unfreeze PMU
+	 * We must make sure that we don't loose any potential overflow
+	 * interrupt while saving PMU context. In this code, external
+	 * interrupts are always enabled.
+	 */
+
+	/*
+	 * save current PSR: needed because we modify it
+	 */
+	__asm__ __volatile__ ("mov %0=psr;;": "=r"(psr) :: "memory");
+
+	/*
+	 * stop monitoring:
+	 * This is the only way to stop monitoring without destroying overflow
+	 * information in PMC[0].
+	 * This is the last instruction which can cause overflow when monitoring
+	 * in kernel.
+	 * By now, we could still have an overflow interrupt in-flight.
+	 */
+	__asm__ __volatile__ ("rsm psr.up;;"::: "memory");
+	
+	/*
+	 * Mark the PMU as not owned
+	 * This will cause the interrupt handler to do nothing in case an overflow
+	 * interrupt was in-flight
+	 * This also guarantees that pmc0 will contain the final state 
+	 * It virtually gives us full control on overflow processing from that point
+	 * on.
+	 * It must be an atomic operation.
+	 */
+	SET_PMU_OWNER(NULL);
+
+	/*
+	 * read current overflow status:
+	 *
+	 * we are guaranteed to read the final stable state
+	 */
+	ia64_srlz_d();
+	pmc0 = ia64_get_pmc(0); /* slow */
+
+	/*
+	 * freeze PMU:
+	 *
+	 * This destroys the overflow information. This is required to make sure
+	 * next process does not start with monitoring on if not requested
+	 */
+	ia64_set_pmc(0, 1);
+	ia64_srlz_d();
+
+	/*
+	 * restore PSR for context switch to save
+	 */
+	__asm__ __volatile__ ("mov psr.l=%0;;"::"r"(psr): "memory");
+
+	/* 
+	 * This loop flushes the PMD into the PFM context.
+	 * IT also processes overflow inline.
+	 *
+	 * IMPORTANT: No notification is sent at this point as the process is dying.
+	 * The implicit notification will come from a SIGCHILD or a return from a
+	 * waitpid().
+	 *
+	 * XXX: must take holes into account
 	 */
-	ia64_set_pmc(0, 0);
+	mask = pmc0 >> PMU_FIRST_COUNTER;
+	for (i=0,j=PMU_FIRST_COUNTER; i< pmu_conf.max_counters; i++,j++) {
+
+		/* collect latest results */
+		ctx->ctx_pmds[i].val += ia64_get_pmd(j) & pmu_conf.perf_ovfl_val;
+
+		/* take care of overflow inline */
+		if (mask & 0x1) {
+			ctx->ctx_pmds[i].val += 1 + pmu_conf.perf_ovfl_val;
+			DBprintk((" PMD[%d] overflowed pmd=0x%lx pmds.val=0x%lx\n", 
+			j, ia64_get_pmd(j), ctx->ctx_pmds[i].val)); 
+		}
+	}
+}
+
+/*
+ * XXX: this routine is not very portable for PMCs
+ * XXX: make this routine able to work with non current context
+ */
+static void
+ia64_reset_pmu(void)
+{
+	int i;
+
+	/* PMU is frozen, no pending overflow bits */
+	ia64_set_pmc(0,1);
+
+	/* extra overflow bits + counter configs cleared */
+	for(i=1; i< PMU_FIRST_COUNTER + pmu_conf.max_counters ; i++) {
+		ia64_set_pmc(i,0);
+	}
+
+	/* opcode matcher set to all 1s */
+	ia64_set_pmc(8,~0);
+	ia64_set_pmc(9,~0);
+
+	/* I-EAR config cleared, plm=0 */
+	ia64_set_pmc(10,0);
+
+	/* D-EAR config cleared, PMC[11].pt must be 1 */
+	ia64_set_pmc(11,1 << 28);
+
+	/* BTB config. plm=0 */
+	ia64_set_pmc(12,0);
+
+	/* Instruction address range, PMC[13].ta must be 1 */
+	ia64_set_pmc(13,1);
+
+	/* clears all PMD registers */
+	for(i=0;i< pmu_conf.num_pmds; i++) {
+		if (PMD_IS_IMPL(i)) ia64_set_pmd(i,0);
+	}
 	ia64_srlz_d();
 }
 
+/*
+ * task is the newly created task
+ */
+int
+pfm_inherit(struct task_struct *task)
+{
+	pfm_context_t *ctx = current->thread.pfm_context;
+	pfm_context_t *nctx;
+	struct thread_struct *th = &task->thread;
+	int i, cnum;
+
+	/*
+	 * takes care of easiest case first
+	 */
+	if (CTX_INHERIT_MODE(ctx) = PFM_FL_INHERIT_NONE) {
+		DBprintk((" removing PFM context for %d\n", task->pid));
+		task->thread.pfm_context     = NULL;
+		task->thread.pfm_pend_notify = 0;
+		/* copy_thread() clears IA64_THREAD_PM_VALID */
+		return 0;
+	}
+	nctx = pfm_context_alloc();
+	if (nctx = NULL) return -ENOMEM;
+
+	/* copy content */
+	*nctx = *ctx;
+
+	if (ctx->ctx_fl_inherit = PFM_FL_INHERIT_ONCE) {
+		nctx->ctx_fl_inherit = PFM_FL_INHERIT_NONE;
+		DBprintk((" downgrading to INHERIT_NONE for %d\n", task->pid));
+	}
+
+	/* initialize counters in new context */
+	for(i=0, cnum= PMU_FIRST_COUNTER; i < pmu_conf.max_counters; cnum++, i++) {
+		nctx->ctx_pmds[i].val = nctx->ctx_pmds[i].ival & ~pmu_conf.perf_ovfl_val;
+		th->pmd[cnum]	      = nctx->ctx_pmds[i].ival & pmu_conf.perf_ovfl_val;
+		
+	}
+	/* clear BTB index register */
+	th->pmd[16] = 0;
+	
+	/* if sampling then increment number of users of buffer */
+	if (nctx->ctx_smpl_buf) {
+		atomic_inc(&nctx->ctx_smpl_buf->psb_refcnt);
+	}
+
+	nctx->ctx_fl_frozen = 0;
+	nctx->ctx_ovfl_regs = 0;
+	sema_init(&nctx->ctx_restart_sem, 0); /* reset this semaphore to locked */ 
+	
+	/* clear pending notification */
+	th->pfm_pend_notify = 0;
+
+	/* link with new task */
+	th->pfm_context     = nctx;
+
+	DBprintk((" nctx=%p for process %d\n", nctx, task->pid));
+
+	/*
+	 * the copy_thread routine automatically clears
+	 * IA64_THREAD_PM_VALID, so we need to reenable it, if it was used by the caller
+	 */
+	if (current->thread.flags & IA64_THREAD_PM_VALID) {
+		DBprintk(("  setting PM_VALID for %d\n", task->pid));
+		th->flags |= IA64_THREAD_PM_VALID;
+	} 
+
+	return 0;
+}
+
+/* called from exit_thread() */
+void
+pfm_context_exit(struct task_struct *task)
+{
+	pfm_context_t *ctx = task->thread.pfm_context;
+
+	if (!ctx) {
+		DBprintk((" invalid context for %d\n", task->pid));
+		return;
+	}
+
+	/* check is we have a sampling buffer attached */
+	if (ctx->ctx_smpl_buf) {
+		pfm_smpl_buffer_desc_t *psb = ctx->ctx_smpl_buf;	
+
+		/* if only user left, then remove */
+		DBprintk((" pid %d: task %d sampling psb->refcnt=%d\n", current->pid, task->pid, psb->psb_refcnt.counter));
+
+		if (atomic_dec_and_test(&psb->psb_refcnt) ) {
+			rvfree(psb->psb_hdr, psb->psb_size);
+			vfree(psb);
+			DBprintk((" pid %d: cleaning task %d sampling buffer\n", current->pid, task->pid )); 
+		}
+	}
+	DBprintk((" pid %d: task %d pfm_context is freed @%p\n", current->pid, task->pid, ctx)); 
+	pfm_context_free(ctx);
+}
+
 #else /* !CONFIG_PERFMON */
 
-asmlinkage unsigned long
-sys_perfmonctl (int cmd, int count, void *ptr)
+asmlinkage int
+sys_perfmonctl (int pid, int cmd, int flags, perfmon_req_t *req, int count, long arg6, long arg7, long arg8, long stack)
 {
 	return -ENOSYS;
 }
diff -urN linux-davidm/arch/ia64/kernel/process.c linux-2.4.0-lia/arch/ia64/kernel/process.c
--- linux-davidm/arch/ia64/kernel/process.c	Tue Jan  9 00:09:51 2001
+++ linux-2.4.0-lia/arch/ia64/kernel/process.c	Mon Jan  8 23:41:03 2001
@@ -1,8 +1,8 @@
 /*
  * Architecture-specific setup.
  *
- * Copyright (C) 1998-2000 Hewlett-Packard Co
- * Copyright (C) 1998-2000 David Mosberger-Tang <davidm@hpl.hp.com>
+ * Copyright (C) 1998-2001 Hewlett-Packard Co
+ * Copyright (C) 1998-2001 David Mosberger-Tang <davidm@hpl.hp.com>
  */
 #define __KERNEL_SYSCALLS__	/* see <asm/unistd.h> */
 #include <linux/config.h>
@@ -20,6 +20,7 @@
 
 #include <asm/delay.h>
 #include <asm/efi.h>
+#include <asm/perfmon.h>
 #include <asm/pgtable.h>
 #include <asm/processor.h>
 #include <asm/sal.h>
@@ -147,7 +148,7 @@
 		ia64_save_debug_regs(&task->thread.dbr[0]);
 #ifdef CONFIG_PERFMON
 	if ((task->thread.flags & IA64_THREAD_PM_VALID) != 0)
-		ia64_save_pm_regs(task);
+		pfm_save_regs(task);
 #endif
 	if (IS_IA32_PROCESS(ia64_task_regs(task)))
 		ia32_save_state(&task->thread);
@@ -160,7 +161,7 @@
 		ia64_load_debug_regs(&task->thread.dbr[0]);
 #ifdef CONFIG_PERFMON
 	if ((task->thread.flags & IA64_THREAD_PM_VALID) != 0)
-		ia64_load_pm_regs(task);
+		pfm_load_regs(task);
 #endif
 	if (IS_IA32_PROCESS(ia64_task_regs(task)))
 		ia32_load_state(&task->thread);
@@ -210,6 +211,7 @@
 	struct switch_stack *child_stack, *stack;
 	extern char ia64_ret_from_clone;
 	struct pt_regs *child_ptregs;
+	int retval = 0;
 
 #ifdef CONFIG_SMP
 	/*
@@ -290,7 +292,11 @@
 	if (IS_IA32_PROCESS(ia64_task_regs(current)))
 		ia32_save_state(&p->thread);
 #endif
-	return 0;
+#ifdef CONFIG_PERFMON
+	if (current->thread.pfm_context)
+		retval = pfm_inherit(p);
+#endif
+	return retval;
 }
 
 #ifdef CONFIG_IA64_NEW_UNWIND
@@ -523,6 +530,15 @@
 #endif
 }
 
+#ifdef CONFIG_PERFMON
+void
+release_thread (struct task_struct *task)
+{
+	if (task->thread.pfm_context)
+		pfm_context_exit(task);
+}
+#endif
+
 /*
  * Clean up state associated with current thread.  This is called when
  * the thread calls exit().
@@ -545,7 +561,7 @@
 		 * we garantee no race.  this call we also stop
 		 * monitoring
 		 */
-		ia64_save_pm_regs(current);
+		pfm_flush_regs(current);
 		/*
 		 * make sure that switch_to() will not save context again
 		 */
diff -urN linux-davidm/arch/ia64/kernel/setup.c linux-2.4.0-lia/arch/ia64/kernel/setup.c
--- linux-davidm/arch/ia64/kernel/setup.c	Tue Jan  9 00:09:51 2001
+++ linux-2.4.0-lia/arch/ia64/kernel/setup.c	Mon Jan  8 23:41:49 2001
@@ -1,8 +1,8 @@
 /*
  * Architecture-specific setup.
  *
- * Copyright (C) 1998-2000 Hewlett-Packard Co
- * Copyright (C) 1998-2000 David Mosberger-Tang <davidm@hpl.hp.com>
+ * Copyright (C) 1998-2001 Hewlett-Packard Co
+ * Copyright (C) 1998-2001 David Mosberger-Tang <davidm@hpl.hp.com>
  * Copyright (C) 1998, 1999 Stephane Eranian <eranian@hpl.hp.com>
  * Copyright (C) 2000, Rohit Seth <rohit.seth@intel.com>
  * Copyright (C) 1999 VA Linux Systems
@@ -444,6 +431,15 @@
 		: "r" (((ulong) IA32_CR4 << 32) | IA32_CR0));
 #endif
 
+	/* disable all local interrupt sources: */
+	ia64_set_itv(1 << 16);
+	ia64_set_lrr0(1 << 16);
+	ia64_set_lrr1(1 << 16);
+	ia64_set_pmv(1 << 16);
+	ia64_set_cmcv(1 << 16);
+
+	/* clear TPR & XTP to enable all interrupt classes: */
+	ia64_set_tpr(0);
 #ifdef CONFIG_SMP
 	normal_xtp();
 #endif
diff -urN linux-davidm/arch/ia64/kernel/signal.c linux-2.4.0-lia/arch/ia64/kernel/signal.c
--- linux-davidm/arch/ia64/kernel/signal.c	Tue Jan  9 00:09:51 2001
+++ linux-2.4.0-lia/arch/ia64/kernel/signal.c	Mon Jan  8 23:53:05 2001
@@ -190,6 +190,11 @@
 			err |= __put_user(from->si_utime, &to->si_utime);
 			err |= __put_user(from->si_stime, &to->si_stime);
 			err |= __put_user(from->si_status, &to->si_status);
+		      case __SI_PROF >> 16:
+			err |= __put_user(from->si_uid, &to->si_uid);
+			err |= __put_user(from->si_pid, &to->si_pid);
+			err |= __put_user(from->si_pfm_ovfl, &to->si_pfm_ovfl);
+			break;
 		      default:
 			err |= __put_user(from->si_uid, &to->si_uid);
 			err |= __put_user(from->si_pid, &to->si_pid);
diff -urN linux-davidm/arch/ia64/kernel/smp.c linux-2.4.0-lia/arch/ia64/kernel/smp.c
--- linux-davidm/arch/ia64/kernel/smp.c	Tue Jan  9 00:09:51 2001
+++ linux-2.4.0-lia/arch/ia64/kernel/smp.c	Mon Jan  8 23:42:26 2001
@@ -71,7 +79,7 @@
 static volatile int smp_commenced;
 
 static int max_cpus = -1;			     /* Command line */
-static unsigned long ipi_op[NR_CPUS];
+
 struct smp_call_struct {
 	void (*func) (void *info);
 	void *info;
@@ -159,7 +172,7 @@
 handle_IPI(int irq, void *dev_id, struct pt_regs *regs) 
 {
 	int this_cpu = smp_processor_id();
-	unsigned long *pending_ipis = &ipi_op[this_cpu];
+	unsigned long *pending_ipis = &cpu_data[this_cpu].ipi_operation;
 	unsigned long ops;
 
 	/* Count this now; we may make a call that never returns. */
@@ -274,7 +293,7 @@
 	if (dest_cpu = -1) 
                 return;
         
-	set_bit(op, &ipi_op[dest_cpu]);
+	set_bit(op, &cpu_data[dest_cpu].ipi_operation);
 	platform_send_ipi(dest_cpu, IPI_IRQ, IA64_IPI_DM_INT, 0);
 }
 
@@ -508,10 +526,6 @@
 	perfmon_init_percpu();
 #endif
 
-	/* Disable all local interrupts */
-	ia64_set_lrr0(0, 1);	
-	ia64_set_lrr1(0, 1);	
-
 	local_irq_enable();		/* Interrupts have been off until now */
 
 	calibrate_delay();
@@ -610,7 +624,6 @@
 
 	/* Take care of some initial bookkeeping.  */
 	memset(&__cpu_physical_id, -1, sizeof(__cpu_physical_id));
-	memset(&ipi_op, 0, sizeof(ipi_op));
 
 	/* Setup BP mappings */
 	__cpu_physical_id[0] = hard_smp_processor_id();
diff -urN linux-davidm/arch/ia64/kernel/time.c linux-2.4.0-lia/arch/ia64/kernel/time.c
--- linux-davidm/arch/ia64/kernel/time.c	Tue Jan  9 00:09:51 2001
+++ linux-2.4.0-lia/arch/ia64/kernel/time.c	Mon Jan  8 23:43:02 2001
@@ -226,7 +226,7 @@
 #endif
 
 	/* arrange for the cycle counter to generate a timer interrupt: */
-	ia64_set_itv(TIMER_IRQ, 0);
+	ia64_set_itv(TIMER_IRQ);
 	itm.next[smp_processor_id()].count = ia64_get_itc() + itm.delta;
 	ia64_set_itm(itm.next[smp_processor_id()].count);
 }
diff -urN linux-davidm/arch/ia64/lib/Makefile linux-2.4.0-lia/arch/ia64/lib/Makefile
--- linux-davidm/arch/ia64/lib/Makefile	Tue Jan  9 00:09:51 2001
+++ linux-2.4.0-lia/arch/ia64/lib/Makefile	Mon Jan  8 23:43:14 2001
@@ -7,18 +7,18 @@
 
 L_TARGET = lib.a
 
+export-objs := io.o swiotlb.o
+
 obj-y := __divsi3.o __udivsi3.o __modsi3.o __umodsi3.o					\
 	__divdi3.o __udivdi3.o __moddi3.o __umoddi3.o					\
 	checksum.o clear_page.o csum_partial_copy.o copy_page.o				\
 	copy_user.o clear_user.o strncpy_from_user.o strlen_user.o strnlen_user.o	\
-	flush.o do_csum.o								\
+	flush.o io.o do_csum.o								\
 	swiotlb.o
 
 ifneq ($(CONFIG_ITANIUM_ASTEP_SPECIFIC),y)
   obj-y += memcpy.o memset.o strlen.o
 endif
-
-export-objs += io.o
 
 IGNORE_FLAGS_OBJS =	__divsi3.o __udivsi3.o __modsi3.o __umodsi3.o \
 			__divdi3.o __udivdi3.o __moddi3.o __umoddi3.o
diff -urN linux-davidm/arch/ia64/lib/swiotlb.c linux-2.4.0-lia/arch/ia64/lib/swiotlb.c
--- linux-davidm/arch/ia64/lib/swiotlb.c	Tue Jan  9 00:09:51 2001
+++ linux-2.4.0-lia/arch/ia64/lib/swiotlb.c	Mon Jan  8 23:43:36 2001
@@ -10,7 +10,10 @@
  *			unnecessary i-cache flushing.
  */
 
+#include <linux/config.h>
+
 #include <linux/mm.h>
+#include <linux/module.h>
 #include <linux/pci.h>
 #include <linux/spinlock.h>
 #include <linux/string.h>
@@ -325,12 +328,8 @@
 	pg_addr = PAGE_ALIGN((unsigned long) addr);
 	end = (unsigned long) addr + size;
 	while (pg_addr + PAGE_SIZE <= end) {
-#if 0
-		set_bit(PG_arch_1, virt_to_page(pg_addr));
-#else
-		if (!VALID_PAGE(virt_to_page(pg_addr)))
-			printk("Invalid addr %lx!!!\n", pg_addr);
-#endif
+		struct page *page = virt_to_page(pg_addr);
+		set_bit(PG_arch_1, &page->flags);
 		pg_addr += PAGE_SIZE;
 	}
 }
@@ -454,3 +453,14 @@
 {
 	return virt_to_phys(sg->address);
 }
+
+EXPORT_SYMBOL(swiotlb_init);
+EXPORT_SYMBOL(swiotlb_map_single);
+EXPORT_SYMBOL(swiotlb_unmap_single);
+EXPORT_SYMBOL(swiotlb_map_sg);
+EXPORT_SYMBOL(swiotlb_unmap_sg);
+EXPORT_SYMBOL(swiotlb_sync_single);
+EXPORT_SYMBOL(swiotlb_sync_sg);
+EXPORT_SYMBOL(swiotlb_dma_address);
+EXPORT_SYMBOL(swiotlb_alloc_consistent);
+EXPORT_SYMBOL(swiotlb_free_consistent);
diff -urN linux-davidm/arch/ia64/tools/print_offsets.c linux-2.4.0-lia/arch/ia64/tools/print_offsets.c
--- linux-davidm/arch/ia64/tools/print_offsets.c	Tue Jan  9 00:09:51 2001
+++ linux-2.4.0-lia/arch/ia64/tools/print_offsets.c	Mon Jan  8 23:43:49 2001
@@ -1,8 +1,8 @@
 /*
  * Utility to generate asm-ia64/offsets.h.
  *
- * Copyright (C) 1999-2000 Hewlett-Packard Co
- * Copyright (C) 1999-2000 David Mosberger-Tang <davidm@hpl.hp.com>
+ * Copyright (C) 1999-2001 Hewlett-Packard Co
+ * Copyright (C) 1999-2001 David Mosberger-Tang <davidm@hpl.hp.com>
  *
  * Note that this file has dual use: when building the kernel
  * natively, the file is translated into a binary and executed.  When
@@ -57,6 +57,9 @@
     { "IA64_TASK_THREAD_KSP_OFFSET",	offsetof (struct task_struct, thread.ksp) },
 #ifdef CONFIG_IA32_SUPPORT
     { "IA64_TASK_THREAD_SIGMASK_OFFSET",offsetof (struct task_struct, thread.un.sigmask) },
+#endif
+#ifdef CONFIG_PERFMON
+    { "IA64_TASK_PFM_NOTIFY", offsetof(struct task_struct, thread.pfm_pend_notify) },
 #endif
     { "IA64_TASK_PID_OFFSET",		offsetof (struct task_struct, pid) },
     { "IA64_TASK_MM_OFFSET",		offsetof (struct task_struct, mm) },
diff -urN linux-davidm/drivers/ide/ide-geometry.c linux-2.4.0-lia/drivers/ide/ide-geometry.c
--- linux-davidm/drivers/ide/ide-geometry.c	Thu Jan  4 22:40:12 2001
+++ linux-2.4.0-lia/drivers/ide/ide-geometry.c	Thu Jan  4 23:10:38 2001
@@ -3,8 +3,11 @@
  */
 #include <linux/config.h>
 #include <linux/ide.h>
-#include <linux/mc146818rtc.h>
 #include <asm/io.h>
+
+#ifdef __i386__
+# include <linux/mc146818rtc.h>
+#endif
 
 /*
  * We query CMOS about hard disks : it could be that we have a SCSI/ESDI/etc
diff -urN linux-davidm/drivers/scsi/qla1280.c linux-2.4.0-lia/drivers/scsi/qla1280.c
--- linux-davidm/drivers/scsi/qla1280.c	Tue Jan  9 00:09:52 2001
+++ linux-2.4.0-lia/drivers/scsi/qla1280.c	Mon Jan  8 23:45:09 2001
@@ -16,9 +16,21 @@
 * General Public License for more details.
 **
 ******************************************************************************/
-#define QLA1280_VERSION      "3.19 Beta"
+#define QLA1280_VERSION      "3.21 Beta"
 /****************************************************************************
     Revision History:
+    Rev  3.21 Beta January 4, 2001 BN Qlogic
+        - Changed criteria of 64/32 Bit mode of HBA
+          operation according to BITS_PER_LONG rather
+          than HBA's NVRAM setting of >4Gig memory bit;
+          so that the HBA auto-configures without the need
+          to setup each system individually.
+    Rev  3.20 Beta December 5, 2000 BN Qlogic
+        - Added priority handling to IA-64  onboard SCSI
+          ISP12160 chip for kernels greater than 2.3.18.
+        - Added irqrestore for qla1280_intr_handler.
+        - Enabled /proc/scsi/qla1280 interface.
+        - Clear /proc/scsi/qla1280 counters in detect().
     Rev  3.19 Beta October 13, 2000 BN Qlogic
         - Declare driver_template for new kernel
           (2.4.0 and greater) scsi initialization scheme.
@@ -167,16 +179,9 @@
 #define  STOP_ON_ERROR                 0   /* Stop on aborts and resets  */
 #define  STOP_ON_RESET                 0 
 #define  STOP_ON_ABORT                 0
- 
+#define  QLA1280_PROFILE               1   /* 3.20 */ 
 #define  DEBUG_QLA1280                 0
 
-/*************** 64 BIT PCI DMA ******************************************/
-#define  FORCE_64BIT_PCI_DMA           0 /* set to one for testing only  */
-/* Applicable to 64 version of the Linux 2.4.x and above only            */
-/* NVRAM bit nv->cntr_flags_1.enable_64bit_addressing should be used for */
-/* administrator control of PCI DMA width size per system configuration  */
-/*************************************************************************/  
-
 #define	BZERO(ptr, amt)		memset(ptr, 0, amt)
 #define	BCOPY(src, dst, amt)	memcpy(dst, src, amt)
 #define	KMALLOC(siz)	kmalloc((siz), GFP_ATOMIC)
@@ -241,7 +246,7 @@
 STATIC int qla1280_return_status( sts_entry_t *sts, Scsi_Cmnd       *cp);
 STATIC void qla1280_removeq(scsi_lu_t *q, srb_t *sp);
 STATIC void qla1280_mem_free(scsi_qla_host_t *ha);
-static void qla1280_do_dpc(void *p);
+void qla1280_do_dpc(void *p);
 static char	*qla1280_get_token(char *, char *);
 #if LINUX_VERSION_CODE < KERNEL_VERSION(2,1,0)
 STATIC inline void mdelay(int);
@@ -429,7 +434,7 @@
 
 static unsigned long qla1280_verbose = 1L;
 static scsi_qla_host_t *qla1280_hostlist = NULL;
-#ifdef QLA1280_PROFILE
+#if QLA1280_PROFILE
 static int qla1280_buffer_size = 0;
 static char *qla1280_buffer = NULL;
 #endif
@@ -521,7 +526,7 @@
     uint32_t        b, t, l;
 
   host = NULL;
-    
+
     /* Find the host that was specified */
     for( ha=qla1280_hostlist; (ha != NULL) && ha->host->host_no != hostno; ha=ha->next )
     ;
@@ -579,7 +584,7 @@
                         ha->request_dma,
                         ha->response_dma);
     len += size;
-    size = sprintf(PROC_BUF, "Request Queue count= 0x%lx, Response Queue count= 0x%lx\n",
+    size = sprintf(PROC_BUF, "Request Queue count= 0x%x, Response Queue count= 0x%x\n",
                         REQUEST_ENTRY_CNT,
                         RESPONSE_ENTRY_CNT);
     len += size; 
@@ -671,7 +676,7 @@
     struct Scsi_Host *host;
     scsi_qla_host_t *ha, *cur_ha;
     struct _qlaboards  *bdp;
-    int i, j;
+    int i,j;
 #if LINUX_VERSION_CODE < KERNEL_VERSION(2,3,18)
     unsigned short subsys;
 #endif
@@ -747,14 +752,99 @@
 #else
     template->proc_name = "qla1280";
 #endif
+
+        /* 3.20 */
+        /* present the on-board ISP12160 for IA-64 Lion systems
+        first to the OS; to preserve boot drive access in case another
+        QLA12160 is inserted in the PCI slots */
+#if LINUX_VERSION_CODE > KERNEL_VERSION(2,3,18)
+        while ((pdev = pci_find_subsys(QLA1280_VENDOR_ID,
+                               bdp->device_id,  /* QLA12160 first in list */ 
+                               PCI_ANY_ID, 
+                               PCI_ANY_ID,pdev))) {
+
+                /* only interested here on devices on PCI bus=1 slot=2 */
+                if ((pdev->bus->number     != 1)   ||
+                    (PCI_SLOT(pdev->devfn) != 2))  continue;
+
+                if (pci_enable_device(pdev)) goto find_devices;
+                printk("qla1x160: Initializing IA-64 ISP12160\n");
+		host = scsi_register(template, sizeof(scsi_qla_host_t));
+		ha = (scsi_qla_host_t *) host->hostdata;
+		/* Clear our data area */
+		for( j =0, cp = (char *)ha;  j < sizeof(scsi_qla_host_t); j++)
+			*cp++ = 0;
+		/* Sanitize the information from PCI BIOS.  */
+		host->irq = pdev->irq;
+		host->io_port = pci_resource_start(pdev, 0);
+		ha->pci_bus = pdev->bus->number;
+		ha->pci_device_fn = pdev->devfn;
+		ha->pdev = pdev;
+		ha->device_id = bdp->device_id; /* QLA12160 first in list */
+    
+                ha->devnum = 0; // This priority ISP12160 is always devnum zero
+		if( qla1280_mem_alloc(ha) ) {
+  	          printk(KERN_INFO "qla1x160: Failed to get memory\n");
+		}                
+                ha->ports = bdp->numPorts; 
+                /* following needed for all cases of OS versions */
+                host->io_port &= PCI_BASE_ADDRESS_IO_MASK; 
+                ha->iobase = (device_reg_t *) host->io_port;
+                ha->host = host;
+                ha->host_no = host->host_no;
+                /* 3.20 zero out /proc/scsi/qla1280 counters */
+                ha->actthreads = 0;
+                ha->qthreads = 0;
+                ha->isr_count = 0; 
+
+                /* load the F/W, read paramaters, and init the H/W */
+                ha->instance = num_hosts;
+                if (qla1280_initialize_adapter(ha))
+                {
+                   printk(KERN_INFO "qla1x160: Failed to initialize onboard ISP12160 on IA-64 \n");
+                   qla1280_mem_free(ha);
+                   scsi_unregister(host);
+                   goto find_devices;
+                }                
+                host->max_channel = bdp->numPorts-1; 
+		/* Register our resources with Linux */
+		if( qla1280_register_with_Linux(ha, bdp->numPorts-1) ) {
+		  printk(KERN_INFO "qla1x160: Failed to register resources for onboard ISP12160 on IA-64\n");
+		  qla1280_mem_free(ha);
+		  scsi_unregister(host);
+		  goto find_devices;
+		}
+                reg = ha->iobase;
+                /* Disable ISP interrupts. */
+		qla1280_disable_intrs(ha);
+                /* Insure mailbox registers are free. */
+                WRT_REG_WORD(&reg->semaphore, 0);
+                WRT_REG_WORD(&reg->host_cmd, HC_CLR_RISC_INT);
+                WRT_REG_WORD(&reg->host_cmd, HC_CLR_HOST_INT);
+
+                /* Enable chip interrupts. */
+		qla1280_enable_intrs(ha);
+                /* Insert new entry into the list of adapters */
+                ha->next = NULL;
+                /* this preferred device will always be the first one found */
+                cur_ha = qla1280_hostlist = ha;
+                num_hosts++;
+        }
+#endif
+
+#if LINUX_VERSION_CODE > KERNEL_VERSION(2,3,18)
+ find_devices:
+#endif
+
+        pdev = NULL;
 	/* Try and find each different type of adapter we support */
-	for( i=0; bdp->device_id != 0 && i < NUM_OF_ISP_DEVICES; i++, bdp++ ) {
+	for(i=0;bdp->device_id != 0 && i < NUM_OF_ISP_DEVICES;i++,bdp++) {
 #if LINUX_VERSION_CODE > KERNEL_VERSION(2,1,95)
 #if LINUX_VERSION_CODE > KERNEL_VERSION(2,3,18)
                 /* PCI_SUBSYSTEM_IDS supported */ 
 		while ((pdev = pci_find_subsys(QLA1280_VENDOR_ID,
 			bdp->device_id, PCI_ANY_ID, PCI_ANY_ID, pdev) )) {
-			if (pci_enable_device(pdev)) continue;
+ 			if (pci_enable_device(pdev)) continue;
 #else
 		while ((pdev = pci_find_device(QLA1280_VENDOR_ID,
 			bdp->device_id, pdev ) ))  {
@@ -766,24 +856,31 @@
 #endif /* 2,1,95 */ 
                 /* found a adapter */
 #if LINUX_VERSION_CODE > KERNEL_VERSION(2,3,18)
-                  printk("qla1280: detect() found an HBA\n");
-		  printk("qla1280: VID=%x DID=%x SSVID=%x SSDID=%x\n",
-			pdev->vendor, pdev->device,
-			pdev->subsystem_vendor, pdev->subsystem_device); 
 		  /* If it's an AMI SubSys Vendor ID adapter, skip it. */
                   if (pdev->subsystem_vendor = PCI_VENDOR_ID_AMI) 
                     { 
-                      printk("qla1280: Skip AMI SubSys Vendor ID Chip\n");
+                      printk("qla1x160: Skip AMI SubSys Vendor ID Chip\n");
                       continue;
                     }
+
+		  /* 3.20 skip IA-64 Lion on-board ISP12160 */
+                  /* since we already initialized and presented it */
+                  if ((pdev->bus->number     = 1)   &&
+                      (PCI_SLOT(pdev->devfn) = 2))  continue;
+
+ 		  printk("qla1x160: Supported Device Found VID=%x DID=%x SSVID=%x SSDID=%x\n",
+			pdev->vendor, pdev->device,
+			pdev->subsystem_vendor, pdev->subsystem_device); 
+
 #else
 #if LINUX_VERSION_CODE > KERNEL_VERSION(2,1,95)
+                  printk("qla1x160: Supported Device Found\n");
 		  pci_read_config_word(pdev, PCI_SUBSYSTEM_VENDOR_ID,
                                        &subsys);
 		  /* Bypass all AMI SUBSYS VENDOR IDs */
                   if (subsys = PCI_VENDOR_ID_AMI) 
                     { 
-                      printk("qla1280: Skip AMI SubSys Vendor ID  Chip\n");
+                      printk("qla1x160: Skip AMI SubSys Vendor ID  Chip\n");
                       continue;
                     }
 #endif /* 2,1,95 */
@@ -814,10 +911,10 @@
 		ha->pci_device_fn = pci_devfn;
 #endif
 		ha->device_id = bdp->device_id;
-    
-                ha->devnum = i;
+                ha->devnum = i; // specifies microcode load address
+
 		if( qla1280_mem_alloc(ha) ) {
-  	          printk(KERN_INFO "qla1280: Failed to get memory\n");
+  	          printk(KERN_INFO "qla1x160: Failed to get memory\n");
 		}
                 
                 ha->ports = bdp->numPorts; 
@@ -831,7 +928,7 @@
                 ha->instance = num_hosts;
                 if (qla1280_initialize_adapter(ha))
                 {
-                   printk(KERN_INFO "qla1280: Failed to initialize adapter\n");
+                   printk(KERN_INFO "qla1x160:Failed to initialize adapter\n");
                    qla1280_mem_free(ha);
                    scsi_unregister(host);
                    continue;
@@ -840,7 +937,7 @@
                 host->max_channel = bdp->numPorts-1; 
 		/* Register our resources with Linux */
 		if( qla1280_register_with_Linux(ha, bdp->numPorts-1) ) {
-		  printk(KERN_INFO "qla1280: Failed to register resources\n");
+		  printk(KERN_INFO "qla1x160: Failed to register resources\n");
 		  qla1280_mem_free(ha);
 		  scsi_unregister(host);
 		  continue;
@@ -1068,8 +1165,7 @@
         {
             CMD_RESULT(cmd) = (int) (DID_BUS_BUSY << 16);
             qla1280_done_q_put(sp, &ha->done_q_first, &ha->done_q_last);
-
-            schedule_task(&ha->run_qla_bh);
+            schedule_task(&ha->run_qla_bh); 
             ha->flags.dpc_sched = TRUE;
             DRIVER_UNLOCK
             return(0);
@@ -1507,6 +1603,7 @@
     if(test_and_set_bit(QLA1280_IN_ISR_BIT, &ha->flags))
     {
         COMTRACE('X')
+        spin_unlock_irqrestore(&io_request_lock, cpu_flags);
         return;
     }
     ha->isr_count++;
@@ -1534,6 +1631,7 @@
     {
           COMTRACE('X')
           printk(KERN_INFO "scsi(%d): Already in interrupt - returning \n", (int)ha->host_no);
+          spin_unlock_irqrestore(&io_request_lock, cpu_flags);
           return;
     }
     set_bit(QLA1280_IN_ISR_BIT, (int *)&ha->flags);
@@ -1565,7 +1663,7 @@
             ha->run_qla_bh.routine = qla1280_do_dpc; 
 
              COMTRACE('P') 
-            schedule_task(&ha->run_qla_bh);
+            schedule_task(&ha->run_qla_bh); 
             ha->flags.dpc_sched = TRUE;
         }
         clear_bit(QLA1280_IN_ISR_BIT, (int *)&ha->flags);
@@ -1589,7 +1687,7 @@
  * "host->can_queue". This can cause a panic if we were in our interrupt
  * code .
  **************************************************************************/
-static void qla1280_do_dpc(void *p)
+void qla1280_do_dpc(void *p)
 {
     scsi_qla_host_t *ha = (scsi_qla_host_t *) p;
 #if LINUX_VERSION_CODE > KERNEL_VERSION(2,1,95)
@@ -1773,10 +1871,10 @@
                          scsi_to_pci_dma_dir(cmd->sc_data_direction));
         }
         else if (cmd->request_bufflen) {
-                 DEBUG(sprintf(debug_buff,
+          /*DEBUG(sprintf(debug_buff,
                  "No S/G unmap_single cmd=%x saved_dma_handle=%lx\n\r",
                   cmd,sp->saved_dma_handle);)
-                  DEBUG(qla1280_print(debug_buff);)
+                  DEBUG(qla1280_print(debug_buff);)*/
 
                   pci_unmap_single(ha->pdev,sp->saved_dma_handle,
                                   cmd->request_bufflen,
@@ -3220,17 +3318,19 @@
     ha->flags.disable_risc_code_load              nv->cntr_flags_1.disable_loading_risc_code;
 
-    /* Enable 64bit addressing. */
-    ha->flags.enable_64bit_addressing -            nv->cntr_flags_1.enable_64bit_addressing;
-
-#if FORCE_64BIT_PCI_DMA
+#if BITS_PER_LONG > 32
+    /* Enable 64bit addressing for OS/System combination supporting it   */
+    /* actual NVRAM bit is: nv->cntr_flags_1.enable_64bit_addressing     */ 
+    /* but we will ignore it and use BITS_PER_LONG macro to setup for    */
+    /* 64 or 32 bit access of host memory in all x86/ia-64/Alpha systems */
     ha->flags.enable_64bit_addressing = 1;
+#else
+    ha->flags.enable_64bit_addressing = 0;
 #endif
 
 #if LINUX_VERSION_CODE >= KERNEL_VERSION(2,3,18)
     if (ha->flags.enable_64bit_addressing) {
-           printk("[[[ qla1x160: 64 Bit PCI Addressing Enabled ]]]\n");
+      printk("[[[ qla1x160: 64 Bit PCI Addressing Enabled ]]]\n");
 
 #if BITS_PER_LONG > 32
            /* Update our PCI device dma_mask for full 64 bit mask */
@@ -3979,7 +4079,7 @@
     }
     else if (cmd->request_bufflen)  /* If data transfer. */
     {
-        DEBUG(printk("Single data transfer len=0x%x\n",cmd->request_bufflen));
+      /*DEBUG(printk("Single data transfer len=0x%x\n",cmd->request_bufflen));*/
         seg_cnt = 1;
     }
 
@@ -4169,9 +4269,9 @@
                     *dword_ptr++ = cpu_to_le32(pci_dma_lo32(dma_handle));
                     *dword_ptr++ = cpu_to_le32(pci_dma_hi32(dma_handle));
                     *dword_ptr   = (uint32_t) cmd->request_bufflen;
-                    DEBUG(sprintf(debug_buff,
+                    /*DEBUG(sprintf(debug_buff,
                     "No S/G map_single saved_dma_handle=%lx\n\r",dma_handle));
-                    DEBUG(qla1280_print(debug_buff));
+                    DEBUG(qla1280_print(debug_buff));*/
 #ifdef QL_DEBUG_LEVEL_5
                     qla1280_print(
                             "qla1280_64bit_start_scsi: No scatter/gather command packet data - c");
@@ -4215,6 +4315,10 @@
                 ha->request_ring_ptr++;
 
             /* Set chip new ring index. */
+            DEBUG(qla1280_print("qla1280_64bit_start_scsi: Wakeup RISC for pending command\n\r"));
+            ha->qthreads--;
+            sp->flags |= SRB_SENT;
+            ha->actthreads++;
             WRT_REG_WORD(&reg->mailbox4, ha->req_ring_index);
         }
         else
@@ -4557,9 +4661,9 @@
 
                     *dword_ptr++ = cpu_to_le32(pci_dma_lo32(dma_handle));
                     *dword_ptr   = (uint32_t) cmd->request_bufflen;
-                    DEBUG(sprintf(debug_buff,
+                    /*DEBUG(sprintf(debug_buff,
                     "No S/G map_single saved_dma_handle=%lx\n\r",dma_handle));
-                    DEBUG(qla1280_print(debug_buff));
+                    DEBUG(qla1280_print(debug_buff));*/
 #endif 
                 }
             }
@@ -4593,7 +4697,6 @@
             ha->qthreads--;
             sp->flags |= SRB_SENT;
             ha->actthreads++;
-            /* qla1280_output_number((uint32_t)ha->actthreads++, 16); */
             WRT_REG_WORD(&reg->mailbox4, ha->req_ring_index);
         }
         else
diff -urN linux-davidm/drivers/scsi/qla1280.h linux-2.4.0-lia/drivers/scsi/qla1280.h
--- linux-davidm/drivers/scsi/qla1280.h	Tue Jan  9 00:09:52 2001
+++ linux-2.4.0-lia/drivers/scsi/qla1280.h	Mon Jan  8 23:47:49 2001
@@ -40,14 +40,14 @@
  * Driver debug definitions.
  */
 /* #define QL_DEBUG_LEVEL_1 */      /* Output register accesses to COM1 */
-/* #define QL_DEBUG_LEVEL_2 */      /* Output error msgs to COM1 */
+/* #define QL_DEBUG_LEVEL_2 */       /* Output error msgs to COM1 */
 /* #define QL_DEBUG_LEVEL_3 */      /* Output function trace msgs to COM1 */
-/* #define QL_DEBUG_LEVEL_4 */      /* Output NVRAM trace msgs to COM1 */
+/* #define QL_DEBUG_LEVEL_4 */       /* Output NVRAM trace msgs to COM1 */
 /* #define QL_DEBUG_LEVEL_5 */      /* Output ring trace msgs to COM1 */
 /* #define QL_DEBUG_LEVEL_6 */      /* Output WATCHDOG timer trace to COM1 */
 /* #define QL_DEBUG_LEVEL_7 */      /* Output RISC load trace msgs to COM1 */
 
-  #define QL_DEBUG_CONSOLE    /* Output to console instead of COM1   */
+#define QL_DEBUG_CONSOLE    /* Output to console instead of COM1   */
   /* comment this #define to get output of qla1280_print to COM1         */
   /* if COM1 is not connected to a host system, the driver hangs system! */
 
diff -urN linux-davidm/drivers/sound/sound_firmware.c linux-2.4.0-lia/drivers/sound/sound_firmware.c
--- linux-davidm/drivers/sound/sound_firmware.c	Tue Mar 14 17:54:42 2000
+++ linux-2.4.0-lia/drivers/sound/sound_firmware.c	Mon Jan  8 23:48:00 2001
@@ -7,7 +7,6 @@
 #include <linux/unistd.h>
 #include <asm/uaccess.h>
 
-static int errno;
 static int do_mod_firmware_load(const char *fn, char **fp)
 {
 	int fd;
diff -urN linux-davidm/include/asm-ia64/cache.h linux-2.4.0-lia/include/asm-ia64/cache.h
--- linux-davidm/include/asm-ia64/cache.h	Tue Jan  9 00:09:52 2001
+++ linux-2.4.0-lia/include/asm-ia64/cache.h	Tue Jan  9 00:09:37 2001
@@ -9,7 +9,7 @@
  */
 
 /* Bytes per L1 (data) cache line.  */
-#define L1_CACHE_SHIFT		6
+#define L1_CACHE_SHIFT		CONFIG_IA64_L1_CACHE_SHIFT
 #define L1_CACHE_BYTES		(1 << L1_CACHE_SHIFT)
 
 #ifdef CONFIG_SMP
diff -urN linux-davidm/include/asm-ia64/delay.h linux-2.4.0-lia/include/asm-ia64/delay.h
--- linux-davidm/include/asm-ia64/delay.h	Tue Jan  9 00:09:52 2001
+++ linux-2.4.0-lia/include/asm-ia64/delay.h	Tue Jan  9 00:10:48 2001
@@ -34,13 +34,9 @@
 }
 
 static __inline__ void
-ia64_set_itv (unsigned char vector, unsigned char masked)
+ia64_set_itv (unsigned long val)
 {
-	if (masked > 1)
-		masked = 1;
-
-	__asm__ __volatile__("mov cr.itv=%0;; srlz.d;;"
-			     :: "r"((masked << 16) | vector) : "memory");
+	__asm__ __volatile__("mov cr.itv=%0;; srlz.d;;" :: "r"(val) : "memory");
 }
 
 static __inline__ void
diff -urN linux-davidm/include/asm-ia64/perfmon.h linux-2.4.0-lia/include/asm-ia64/perfmon.h
--- linux-davidm/include/asm-ia64/perfmon.h	Wed Dec 31 16:00:00 1969
+++ linux-2.4.0-lia/include/asm-ia64/perfmon.h	Mon Jan  8 23:48:59 2001
@@ -0,0 +1,51 @@
+/*
+ * Copyright (C) 2001 Hewlett-Packard Co
+ * Copyright (C) 2001 Stephane Eranian <eranian@hpl.hp.com>
+ */
+
+#ifndef _ASM_IA64_PERFMON_H
+#define _ASM_IA64_PERFMON_H
+
+#include <linux/types.h>
+
+/*
+ * Structure used to define a context
+ */
+typedef struct {
+	unsigned long smpl_entries;	/* how many entries in sampling buffer */
+	unsigned long smpl_regs;	/* which pmds to record on overflow */
+	void	      *smpl_vaddr;	/* returns address of BTB buffer */
+
+	pid_t	      notify_pid;	/* which process to notify on overflow */
+	int	      notify_sig; 	/* XXX: not used anymore */
+
+	int	      flags;		/* NOBLOCK/BLOCK/ INHERIT flags (will replace API flags) */
+} pfreq_context_t;
+
+/*
+ * Structure used to configure a PMC or PMD
+ */
+typedef struct {
+	unsigned long	reg_num;	/* which register */
+	unsigned long	reg_value;	/* configuration (PMC) or initial value (PMD) */
+	unsigned long	reg_smpl_reset;	/* reset of sampling buffer overflow (large) */
+	unsigned long	reg_ovfl_reset;	/* reset on counter overflow (small) */
+	int		reg_flags;	/* (PMD): notify/don't notify */
+} pfreq_reg_t;
+
+/*
+ * main request structure passed by user
+ */
+typedef union {
+	pfreq_context_t	pfr_ctx;	/* request to configure a context */
+	pfreq_reg_t	pfr_reg;	/* request to configure a PMD/PMC */
+} perfmon_req_t;
+
+extern void pfm_save_regs (struct task_struct *);
+extern void pfm_load_regs (struct task_struct *);
+
+extern int pfm_inherit (struct task_struct *);
+extern void pfm_context_exit (struct task_struct *);
+extern void pfm_flush_regs (struct task_struct *);
+
+#endif /* _ASM_IA64_PERFMON_H */
diff -urN linux-davidm/include/asm-ia64/processor.h linux-2.4.0-lia/include/asm-ia64/processor.h
--- linux-davidm/include/asm-ia64/processor.h	Tue Jan  9 00:09:52 2001
+++ linux-2.4.0-lia/include/asm-ia64/processor.h	Tue Jan  9 00:10:47 2001
@@ -2,9 +2,9 @@
 #define _ASM_IA64_PROCESSOR_H
 
 /*
- * Copyright (C) 1998-2000 Hewlett-Packard Co
- * Copyright (C) 1998-2000 David Mosberger-Tang <davidm@hpl.hp.com>
- * Copyright (C) 1998-2000 Stephane Eranian <eranian@hpl.hp.com>
+ * Copyright (C) 1998-2001 Hewlett-Packard Co
+ * Copyright (C) 1998-2001 David Mosberger-Tang <davidm@hpl.hp.com>
+ * Copyright (C) 1998-2001 Stephane Eranian <eranian@hpl.hp.com>
  * Copyright (C) 1999 Asit Mallick <asit.k.mallick@intel.com>
  * Copyright (C) 1999 Don Dugger <don.dugger@intel.com>
  *
@@ -27,6 +27,9 @@
 #define IA64_NUM_PMD_REGS	32
 #define IA64_NUM_PMD_COUNTERS	4
 
+#define DEFAULT_MAP_BASE	0x2000000000000000
+#define DEFAULT_TASK_SIZE	0xa000000000000000
+
 /*
  * TASK_SIZE really is a mis-named.  It really is the maximum user
  * space address (plus one).  On IA-64, there are five regions of 2TB
@@ -257,6 +260,7 @@
 	__u64 ipi_count;
 	__u64 prof_counter;
 	__u64 prof_multiplier;
+	__u64 ipi_operation;
 #endif
 };
 
@@ -294,13 +298,9 @@
 #ifdef CONFIG_PERFMON
 	__u64 pmc[IA64_NUM_PMC_REGS];
 	__u64 pmd[IA64_NUM_PMD_REGS];
-	struct {
-		__u64		val;	/* virtual 64bit counter */
-		__u64		rval;	/* reset value on overflow */
-		int		sig;	/* signal used to notify */
-		int		pid;	/* process to notify */
-	} pmu_counters[IA64_NUM_PMD_COUNTERS];
-# define INIT_THREAD_PM		{0, }, {0, }, {{ 0, 0, 0, 0}, },
+	unsigned long pfm_pend_notify;	/* non-zero if we need to notify and block */
+	void *pfm_context;		/* pointer to detailed PMU context */
+# define INIT_THREAD_PM		{0, }, {0, }, 0, 0,
 #else
 # define INIT_THREAD_PM
 #endif
@@ -338,8 +338,8 @@
 	{0, },				/* dbr */	\
 	{0, },				/* ibr */	\
 	INIT_THREAD_PM					\
-	0x2000000000000000,		/* map_base */	\
-	0xa000000000000000,		/* task_size */	\
+	DEFAULT_MAP_BASE,		/* map_base */	\
+	DEFAULT_TASK_SIZE,		/* task_size */	\
 	INIT_THREAD_IA32				\
 	0				/* siginfo */	\
 }
@@ -368,7 +368,11 @@
  * parent of DEAD_TASK has collected the exist status of the task via
  * wait().  This is a no-op on IA-64.
  */
-#define release_thread(dead_task)
+#ifdef CONFIG_PERFMON
+  extern void release_thread (struct task_struct *task);
+#else
+# define release_thread(dead_task)
+#endif
 
 /*
  * This is the mechanism for creating a new kernel thread.
@@ -619,24 +623,16 @@
 }
 
 static inline void
-ia64_set_lrr0 (__u8 vector, __u8 masked)
+ia64_set_lrr0 (unsigned long val)
 {
-	if (masked > 1)
-		masked = 1;
-
-	__asm__ __volatile__ ("mov cr.lrr0=%0;; srlz.d"
-			      :: "r"((masked << 16) | vector) : "memory");
+	__asm__ __volatile__ ("mov cr.lrr0=%0;; srlz.d" :: "r"(val) : "memory");
 }
 
 
 static inline void
-ia64_set_lrr1 (__u8 vector, __u8 masked)
+ia64_set_lrr1 (unsigned long val)
 {
-	if (masked > 1)
-		masked = 1;
-
-	__asm__ __volatile__ ("mov cr.lrr1=%0;; srlz.d"
-			      :: "r"((masked << 16) | vector) : "memory");
+	__asm__ __volatile__ ("mov cr.lrr1=%0;; srlz.d" :: "r"(val) : "memory");
 }
 
 static inline void
diff -urN linux-davidm/include/asm-ia64/sal.h linux-2.4.0-lia/include/asm-ia64/sal.h
--- linux-davidm/include/asm-ia64/sal.h	Tue Jan  9 00:09:52 2001
+++ linux-2.4.0-lia/include/asm-ia64/sal.h	Tue Jan  9 00:09:49 2001
@@ -28,15 +28,12 @@
 #define __SAL_CALL(result,a0,a1,a2,a3,a4,a5,a6,a7)	\
 	result = (*ia64_sal)(a0,a1,a2,a3,a4,a5,a6,a7)
 
-#ifdef CONFIG_SMP
-# define SAL_CALL(result,args...) do {		\
-	  spin_lock(&sal_lock);			\
-	  __SAL_CALL(result,args);		\
-	  spin_unlock(&sal_lock);		\
+# define SAL_CALL(result,args...) do {			\
+	unsigned long flags;				\
+	spin_lock_irqsave(&sal_lock, flags);		\
+	__SAL_CALL(result,args);			\
+	spin_unlock_irqrestore(&sal_lock, flags);	\
 } while (0)
-#else
-# define SAL_CALL(result,args...)	__SAL_CALL(result,args)
-#endif
 
 #define SAL_SET_VECTORS			0x01000000
 #define SAL_GET_STATE_INFO		0x01000001
@@ -440,11 +437,10 @@
  * machine state at the time of MCA's, INITs or CMCs 
  */
 static inline s64
-ia64_sal_clear_state_info (u64 sal_info_type, u64 sal_info_sub_type)
+ia64_sal_clear_state_info (u64 sal_info_type)
 {
 	struct ia64_sal_retval isrv;
-	SAL_CALL(isrv, SAL_CLEAR_STATE_INFO, sal_info_type, sal_info_sub_type,
-	         0, 0, 0, 0, 0);
+	SAL_CALL(isrv, SAL_CLEAR_STATE_INFO, sal_info_type, 0, 0, 0, 0, 0, 0);
 	return isrv.status;
 }
 
@@ -453,10 +449,10 @@
  * state at the time of the MCAs, INITs or CMCs.
  */
 static inline u64
-ia64_sal_get_state_info (u64 sal_info_type, u64 sal_info_sub_type, u64 *sal_info)
+ia64_sal_get_state_info (u64 sal_info_type, u64 *sal_info)
 {
 	struct ia64_sal_retval isrv;
-	SAL_CALL(isrv, SAL_GET_STATE_INFO, sal_info_type, sal_info_sub_type,
+	SAL_CALL(isrv, SAL_GET_STATE_INFO, sal_info_type, 0,
 	         sal_info, 0, 0, 0, 0);
 	if (isrv.status)
 		return 0;
@@ -466,11 +462,10 @@
  * state at the time of MCAs, INITs or CMCs
  */
 static inline u64
-ia64_sal_get_state_info_size (u64 sal_info_type, u64 sal_info_sub_type)
+ia64_sal_get_state_info_size (u64 sal_info_type)
 {
 	struct ia64_sal_retval isrv;
-	SAL_CALL(isrv, SAL_GET_STATE_INFO_SIZE, sal_info_type, sal_info_sub_type,
-	         0, 0, 0, 0, 0);
+	SAL_CALL(isrv, SAL_GET_STATE_INFO_SIZE, sal_info_type, 0, 0, 0, 0, 0, 0);
 	if (isrv.status)
 		return 0;
 	return isrv.v0;
@@ -492,11 +487,10 @@
  * non-monarch processor at the end of machine check processing.
  */
 static inline s64
-ia64_sal_mc_set_params (u64 param_type, u64 i_or_m, u64 i_or_m_val, u64 timeout)
+ia64_sal_mc_set_params (u64 param_type, u64 i_or_m, u64 i_or_m_val, u64 timeout, u64 rz_always)
 {
 	struct ia64_sal_retval isrv;
-	SAL_CALL(isrv, SAL_MC_SET_PARAMS, param_type, i_or_m, i_or_m_val, timeout,
-	         0, 0, 0);
+	SAL_CALL(isrv, SAL_MC_SET_PARAMS, param_type, i_or_m, i_or_m_val, timeout, rz_always, 0, 0);
 	return isrv.status;
 }
 
diff -urN linux-davidm/include/asm-ia64/siginfo.h linux-2.4.0-lia/include/asm-ia64/siginfo.h
--- linux-davidm/include/asm-ia64/siginfo.h	Mon Oct  9 17:55:00 2000
+++ linux-2.4.0-lia/include/asm-ia64/siginfo.h	Mon Jan  8 23:49:52 2001
@@ -2,8 +2,8 @@
 #define _ASM_IA64_SIGINFO_H
 
 /*
- * Copyright (C) 1998, 1999 Hewlett-Packard Co
- * Copyright (C) 1998, 1999 David Mosberger-Tang <davidm@hpl.hp.com>
+ * Copyright (C) 1998-2001 Hewlett-Packard Co
+ * Copyright (C) 1998-2001 David Mosberger-Tang <davidm@hpl.hp.com>
  */
 
 #include <linux/types.h>
@@ -66,6 +66,12 @@
 			long _band;	/* POLL_IN, POLL_OUT, POLL_MSG (XPG requires a "long") */
 			int _fd;
 		} _sigpoll;
+		/* SIGPROF */
+		struct {
+			pid_t _pid;		/* which child */
+			uid_t _uid;		/* sender's uid */
+			unsigned long _pfm_ovfl_counters; /* which PMU counter overflowed */
+		} _sigprof;
 	} _sifields;
 } siginfo_t;
 
@@ -85,6 +91,7 @@
 #define si_isr		_sifields._sigfault._isr	/* valid if si_code=FPE_FLTxxx */
 #define si_band		_sifields._sigpoll._band
 #define si_fd		_sifields._sigpoll._fd
+#define si_pfm_ovfl	_sifields._sigprof._pfm_ovfl_counters
 
 /*
  * si_code values
@@ -98,6 +105,7 @@
 #define __SI_FAULT	(3 << 16)
 #define __SI_CHLD	(4 << 16)
 #define __SI_RT		(5 << 16)
+#define __SI_PROF	(6 << 16)
 #define __SI_CODE(T,N)	((T) << 16 | ((N) & 0xffff))
 #else
 #define __SI_KILL	0
@@ -199,6 +207,11 @@
 #define POLL_PRI	(__SI_POLL|5)	/* high priority input available */
 #define POLL_HUP	(__SI_POLL|6)	/* device disconnected */
 #define NSIGPOLL	6
+
+/*
+ * SIGPROF si_codes
+ */
+#define PROF_OVFL	(__SI_PROF|1)  /* some counters overflowed */
 
 /*
  * sigevent definitions
diff -urN linux-davidm/kernel/ptrace.c linux-2.4.0-lia/kernel/ptrace.c
--- linux-davidm/kernel/ptrace.c	Tue Jan  9 00:09:53 2001
+++ linux-2.4.0-lia/kernel/ptrace.c	Wed Jan  3 23:17:46 2001
@@ -68,7 +68,7 @@
 
 fault_in_page:
 	/* -1: out of memory. 0 - unmapped page */
-	if (handle_mm_fault(mm, vma, addr, write) > 0)
+	if (handle_mm_fault(mm, vma, addr, write ? VM_WRITE : VM_READ) > 0)
 		goto repeat;
 	return 0;
 
diff -urN linux-davidm/lib/Makefile linux-2.4.0-lia/lib/Makefile
--- linux-davidm/lib/Makefile	Tue Jan  9 00:09:53 2001
+++ linux-2.4.0-lia/lib/Makefile	Wed Jan  3 23:17:56 2001
@@ -10,7 +10,7 @@
 
 export-objs := cmdline.o
 
-obj-y := errno.o ctype.o string.o vsprintf.o brlock.o cmdline.o
+obj-y := errno.o ctype.o string.o vsprintf.o brlock.o cmdline.o crc32.o
 
 ifneq ($(CONFIG_HAVE_DEC_LOCK),y) 
   obj-y += dec_and_lock.o
diff -urN linux-davidm/mm/memory.c linux-2.4.0-lia/mm/memory.c
--- linux-davidm/mm/memory.c	Tue Jan  9 00:09:53 2001
+++ linux-2.4.0-lia/mm/memory.c	Thu Jan  4 22:52:47 2001
@@ -1150,8 +1150,10 @@
  */
 static inline int handle_pte_fault(struct mm_struct *mm,
 	struct vm_area_struct * vma, unsigned long address,
-	int write_access, pte_t * pte)
+	int access_type, pte_t * pte)
 {
+	int write_access = is_write_access(access_type);
+	int exec_access = is_exec_access(access_type);
 	pte_t entry;
 
 	/*
@@ -1178,6 +1180,8 @@
 
 		entry = pte_mkdirty(entry);
 	}
+	if (exec_access)
+		entry = pte_mkexec(entry);
 	entry = pte_mkyoung(entry);
 	establish_pte(vma, address, pte, entry);
 	spin_unlock(&mm->page_table_lock);
@@ -1188,7 +1192,7 @@
  * By the time we get here, we already hold the mm semaphore
  */
 int handle_mm_fault(struct mm_struct *mm, struct vm_area_struct * vma,
-	unsigned long address, int write_access)
+	unsigned long address, int access_type)
 {
 	int ret = -1;
 	pgd_t *pgd;
@@ -1200,7 +1204,7 @@
 	if (pmd) {
 		pte_t * pte = pte_alloc(pmd, address);
 		if (pte)
-			ret = handle_pte_fault(mm, vma, address, write_access, pte);
+			ret = handle_pte_fault(mm, vma, address, access_type, pte);
 	}
 	return ret;
 }


