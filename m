From: David Mosberger <davidm@hpl.hp.com>
Date: Thu, 31 May 2001 07:37:35 +0000
Subject: [Linux-ia64] kernel update (relative to 2.4.5)
Message-Id: <marc-linux-ia64-105590693005679@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The latest IA-64 patch is available at:

 ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/

in file linux-2.4.5-ia64-010530.diff*.

What's changed:

	- updates for 2.4.5
	- fix exception table lookup so it really works for modules (Tony Luck)
	- fix perfmon bug (Sumit Roy & Stephane Eranian)
	- clean up smp boot code and structure it like on x86 (Rohit Seth)
	- set siginfo.si_code to SI_FAULT for SIGFPE (Asit Mallick)
	- fix ACPI code to handle _PRT for secondary buses (Jung-Ik Lee)
	- more cleanup for gcc3.0
	- fix some dependency-violations in MCA code (note: this doesn't
	  fix the MCA INIT handler yet; that patch is yet to come...)
	- fix IA-32 context switch typo
	- fix ptrace() so "strace -f" works again
	- don't call tty_write_message() when an unaligned fault occurs
	  inside the kernel (could deadlock otherwise)
	- tune the VM system to allow page table cache to grow bigger
	- reorg thread_struct for better cache-usage
	- initialize archdata for the module structure representing the kernel

The only really important fix here is the one for the exception table
lookup.  It turns out that there was a typo in that code which
prevented the module-specific code to get compiled into the kernel
when modules were enabled.  Thanks to Tony Luck for finding this!
Keith, you may want to look at my comment in kernel/module.c for a
suggestion on how to clean up kernel module initialization at some
point in the future.

As usual, the patch below is fyi only.  The patch has been tested on
Big Sur (SMP) and on HP Ski simulator (UP).

Enjoy,

	--david

diff -urN linux-davidm/arch/ia64/Makefile linux-2.4.5-lia/arch/ia64/Makefile
--- linux-davidm/arch/ia64/Makefile	Wed May 30 23:17:48 2001
+++ linux-2.4.5-lia/arch/ia64/Makefile	Wed May 30 22:41:05 2001
@@ -23,7 +23,7 @@
 GCC_VERSION=$(shell $(CROSS_COMPILE)$(HOSTCC) -v 2>&1 | fgrep 'gcc version' | cut -f3 -d' ' | cut -f1 -d'.')
 
 ifneq ($(GCC_VERSION),2)
-	CFLAGS += -frename-registers -fno-optimize-sibling-calls
+	CFLAGS += -frename-registers
 endif
 
 ifeq ($(CONFIG_ITANIUM_ASTEP_SPECIFIC),y)
diff -urN linux-davidm/arch/ia64/boot/bootloader.c linux-2.4.5-lia/arch/ia64/boot/bootloader.c
--- linux-davidm/arch/ia64/boot/bootloader.c	Sun Apr 29 15:49:24 2001
+++ linux-2.4.5-lia/arch/ia64/boot/bootloader.c	Wed May 30 22:41:23 2001
@@ -87,9 +87,6 @@
 	asm volatile ("movl gp=__gp;;" ::: "memory");
 	asm volatile ("mov sp=%0" :: "r"(stack) : "memory");
 	asm volatile ("bsw.1;;");
-#ifdef CONFIG_ITANIUM_ASTEP_SPECIFIC
-	asm volative ("nop 0;; nop 0;; nop 0;;");
-#endif /* CONFIG_ITANIUM_ASTEP_SPECIFIC */
 
 	ssc(0, 0, 0, 0, SSC_CONSOLE_INIT);
 
diff -urN linux-davidm/arch/ia64/hp/hpsim_setup.c linux-2.4.5-lia/arch/ia64/hp/hpsim_setup.c
--- linux-davidm/arch/ia64/hp/hpsim_setup.c	Thu Jan  4 22:40:10 2001
+++ linux-2.4.5-lia/arch/ia64/hp/hpsim_setup.c	Wed May 30 22:41:37 2001
@@ -27,28 +27,15 @@
 /*
  * Simulator system call.
  */
-inline long
-ia64_ssc (long arg0, long arg1, long arg2, long arg3, int nr)
-{
-#ifdef __GCC_DOESNT_KNOW_IN_REGS__
-	register long in0 asm ("r32") = arg0;
-	register long in1 asm ("r33") = arg1;
-	register long in2 asm ("r34") = arg2;
-	register long in3 asm ("r35") = arg3;
-#else
-	register long in0 asm ("in0") = arg0;
-	register long in1 asm ("in1") = arg1;
-	register long in2 asm ("in2") = arg2;
-	register long in3 asm ("in3") = arg3;
-#endif
-	register long r8 asm ("r8");
-	register long r15 asm ("r15") = nr;
-
-	asm volatile ("break 0x80001"
-		      : "=r"(r8)
-		      : "r"(r15), "r"(in0), "r"(in1), "r"(in2), "r"(in3));
-	return r8;
-}
+asm (".text\n"
+     ".align 32\n"
+     ".global ia64_ssc\n"
+     ".proc ia64_ssc\n"
+     "ia64_ssc:\n"
+     "mov r15=r36\n"
+     "break 0x80001\n"
+     "br.ret.sptk.many rp\n"
+     ".endp\n");
 
 void
 ia64_ssc_connect_irq (long intr, long irq)
diff -urN linux-davidm/arch/ia64/kernel/head.S linux-2.4.5-lia/arch/ia64/kernel/head.S
--- linux-davidm/arch/ia64/kernel/head.S	Wed May 30 23:17:48 2001
+++ linux-2.4.5-lia/arch/ia64/kernel/head.S	Thu May 31 00:06:01 2001
@@ -123,11 +123,12 @@
 #define isAP	p2	// are we an Application Processor?
 #define isBP	p3	// are we the Bootstrap Processor?
 
+#ifdef CONFIG_SMP
 	/*
 	 * Find the init_task for the currently booting CPU.  At poweron, and in
-	 * UP mode, cpu_now_booting is 0.
+	 * UP mode, cpucount is 0.
 	 */
-	movl r3=cpu_now_booting
+	movl r3=cpucount
  	;;
 	ld4 r3=[r3]		// r3 <- smp_processor_id()
 	movl r2=init_tasks
@@ -135,6 +136,11 @@
 	shladd r2=r3,3,r2
 	;;
 	ld8 r2=[r2]
+#else
+	mov r3=0
+	movl r2=init_task_union
+	;;
+#endif
 	cmp4.ne isAP,isBP=r3,r0
 	;;			// RAW on r2
 	extr r3=r2,0,61		// r3 = phys addr of task struct
@@ -182,7 +188,7 @@
 #endif /* CONFIG_IA64_EARLY_PRINTK */
 
 #ifdef CONFIG_SMP
-(isAP)	br.call.sptk.few rp=smp_callin
+(isAP)	br.call.sptk.few rp=start_secondary
 .ret0:
 (isAP)	br.cond.sptk.few self
 #endif
diff -urN linux-davidm/arch/ia64/kernel/ia64_ksyms.c linux-2.4.5-lia/arch/ia64/kernel/ia64_ksyms.c
--- linux-davidm/arch/ia64/kernel/ia64_ksyms.c	Wed May 30 23:17:48 2001
+++ linux-2.4.5-lia/arch/ia64/kernel/ia64_ksyms.c	Wed May 30 22:42:41 2001
@@ -7,6 +7,7 @@
 
 #include <linux/string.h>
 EXPORT_SYMBOL_NOVERS(memset);
+EXPORT_SYMBOL(memchr);
 EXPORT_SYMBOL(memcmp);
 EXPORT_SYMBOL_NOVERS(memcpy);
 EXPORT_SYMBOL(memmove);
@@ -75,6 +76,7 @@
 EXPORT_SYMBOL(smp_call_function);
 EXPORT_SYMBOL(smp_call_function_single);
 EXPORT_SYMBOL(cpu_online_map);
+EXPORT_SYMBOL(ia64_cpu_to_sapicid);
 
 #include <linux/smp.h>
 EXPORT_SYMBOL(smp_num_cpus);
diff -urN linux-davidm/arch/ia64/kernel/mca_asm.S linux-2.4.5-lia/arch/ia64/kernel/mca_asm.S
--- linux-davidm/arch/ia64/kernel/mca_asm.S	Sun Apr 29 15:49:25 2001
+++ linux-2.4.5-lia/arch/ia64/kernel/mca_asm.S	Wed May 30 22:42:51 2001
@@ -672,7 +672,7 @@
 	//
 	mov	r17=cr.lid
 	// XXX fix me: this is wrong: hard_smp_processor_id() is a pair of lid/eid
-	movl	r18=__cpu_physical_id
+	movl	r18=ia64_cpu_to_sapicid
 	;;
 	dep	r18=0,r18,61,3		// convert to physical address
 	;;
diff -urN linux-davidm/arch/ia64/kernel/perfmon.c linux-2.4.5-lia/arch/ia64/kernel/perfmon.c
--- linux-davidm/arch/ia64/kernel/perfmon.c	Wed May 30 23:17:48 2001
+++ linux-2.4.5-lia/arch/ia64/kernel/perfmon.c	Wed May 30 22:43:01 2001
@@ -787,26 +787,22 @@
 	/* XXX: ctx locking may be required here */
 
 	for (i = 0; i < count; i++, req++) {
-		int k;
-
 		if (copy_from_user(&tmp, req, sizeof(tmp))) return -EFAULT;
 
 		if (!PMD_IS_IMPL(tmp.pfr_reg.reg_num)) return -EINVAL;
 
-		k = tmp.pfr_reg.reg_num - PMU_FIRST_COUNTER;
-
 		if (PMD_IS_COUNTER(tmp.pfr_reg.reg_num)) {
 			if (ta = current){
 				val = ia64_get_pmd(tmp.pfr_reg.reg_num);
 			} else {
-				val = th->pmd[k];
+				val = th->pmd[tmp.pfr_reg.reg_num];
 			}
 			val &= pmu_conf.perf_ovfl_val;
 			/*
 			 * lower part of .val may not be zero, so we must be an addition because of
 			 * residual count (see update_counters).
 			 */
-			val += ctx->ctx_pmds[k].val;
+			val += ctx->ctx_pmds[tmp.pfr_reg.reg_num - PMU_FIRST_COUNTER].val;
 		} else {
 			/* for now */
 			if (ta != current) return -EINVAL;
diff -urN linux-davidm/arch/ia64/kernel/process.c linux-2.4.5-lia/arch/ia64/kernel/process.c
--- linux-davidm/arch/ia64/kernel/process.c	Wed May 30 23:17:48 2001
+++ linux-2.4.5-lia/arch/ia64/kernel/process.c	Wed May 30 22:43:16 2001
@@ -282,10 +282,11 @@
 	 * state from the current task to the new task
 	 */
 	if (IS_IA32_PROCESS(ia64_task_regs(current)))
-		ia32_save_state(&p->thread);
+		ia32_save_state(p);
 #endif
 #ifdef CONFIG_PERFMON
-	if (current->thread.pfm_context)
+	p->thread.pfm_pend_notify = 0;
+	if (p->thread.pfm_context)
 		retval = pfm_inherit(p);
 #endif
 	return retval;
diff -urN linux-davidm/arch/ia64/kernel/ptrace.c linux-2.4.5-lia/arch/ia64/kernel/ptrace.c
--- linux-davidm/arch/ia64/kernel/ptrace.c	Wed May 30 23:17:48 2001
+++ linux-2.4.5-lia/arch/ia64/kernel/ptrace.c	Wed May 30 22:43:28 2001
@@ -438,6 +438,25 @@
 }
 
 /*
+ * Simulate user-level "flushrs".  Note: we can't just add pt->loadrs>>16 to
+ * pt->ar_bspstore because the kernel backing store and the user-level backing store may
+ * have different alignments (and therefore a different number of intervening rnat slots).
+ */
+static void
+user_flushrs (struct task_struct *task, struct pt_regs *pt)
+{
+	unsigned long *krbs;
+	long ndirty;
+
+	krbs = (unsigned long *) task + IA64_RBS_OFFSET/8;
+	ndirty = ia64_rse_num_regs(krbs, krbs + (pt->loadrs >> 19));
+
+	pt->ar_bspstore = (unsigned long) ia64_rse_skip_regs((unsigned long *) pt->ar_bspstore,
+							     ndirty);
+	pt->loadrs = 0;
+}
+
+/*
  * Synchronize the RSE backing store of CHILD and all tasks that share the address space
  * with it.  CHILD_URBS_END is the address of the end of the register backing store of
  * CHILD.  If MAKE_WRITABLE is set, a user-level "flushrs" is simulated such that the VM
@@ -467,11 +486,8 @@
 		sw = (struct switch_stack *) (child->thread.ksp + 16);
 		pt = ia64_task_regs(child);
 		ia64_sync_user_rbs(child, sw, pt->ar_bspstore, child_urbs_end);
-		if (make_writable) {
-			/* simulate a user-level "flushrs": */
-			pt->loadrs = 0;
-			pt->ar_bspstore = child_urbs_end;
-		}
+		if (make_writable)
+			user_flushrs(child, pt);
 	} else {
 		read_lock(&tasklist_lock);
 		{
@@ -481,11 +497,8 @@
 					pt = ia64_task_regs(p);
 					urbs_end = ia64_get_user_rbs_end(p, pt, NULL);
 					ia64_sync_user_rbs(p, sw, pt->ar_bspstore, urbs_end);
-					if (make_writable) {
-						/* simulate a user-level "flushrs": */
-						pt->loadrs = 0;
-						pt->ar_bspstore = urbs_end;
-					}
+					if (make_writable)
+						user_flushrs(p, pt);
 				}
 			}
 		}
@@ -781,8 +794,8 @@
 	    long arg4, long arg5, long arg6, long arg7, long stack)
 {
 	struct pt_regs *pt, *regs = (struct pt_regs *) &stack;
-	struct task_struct *child;
 	unsigned long flags, urbs_end;
+	struct task_struct *child;
 	struct switch_stack *sw;
 	long ret;
 
diff -urN linux-davidm/arch/ia64/kernel/smp.c linux-2.4.5-lia/arch/ia64/kernel/smp.c
--- linux-davidm/arch/ia64/kernel/smp.c	Wed May 30 23:17:48 2001
+++ linux-2.4.5-lia/arch/ia64/kernel/smp.c	Wed May 30 22:44:12 2001
@@ -6,12 +6,16 @@
  *
  * Lots of stuff stolen from arch/alpha/kernel/smp.c
  *
- *  00/09/11 David Mosberger <davidm@hpl.hp.com> Do loops_per_jiffy calibration on each CPU.
- *  00/08/23 Asit Mallick <asit.k.mallick@intel.com> fixed logical processor id
- *  00/03/31 Rohit Seth <rohit.seth@intel.com>	Fixes for Bootstrap Processor & cpu_online_map
- *			now gets done here (instead of setup.c)
- *  99/10/05 davidm	Update to bring it in sync with new command-line processing scheme.
- *  10/13/00 Goutham Rao <goutham.rao@intel.com> Updated smp_call_function and
+ * 01/05/16 Rohit Seth <rohit.seth@intel.com>  IA64-SMP functions. Reorganized
+ * the existing code (on the lines of x86 port).
+ * 00/09/11 David Mosberger <davidm@hpl.hp.com> Do loops_per_jiffy
+ * calibration on each CPU.
+ * 00/08/23 Asit Mallick <asit.k.mallick@intel.com> fixed logical processor id
+ * 00/03/31 Rohit Seth <rohit.seth@intel.com>	Fixes for Bootstrap Processor
+ * & cpu_online_map now gets done here (instead of setup.c)
+ * 99/10/05 davidm	Update to bring it in sync with new command-line processing
+ *  scheme.
+ * 10/13/00 Goutham Rao <goutham.rao@intel.com> Updated smp_call_function and
  *		smp_call_function_single to resend IPI on timeouts
  */
 #define __KERNEL_SYSCALLS__
@@ -45,120 +49,48 @@
 #include <asm/system.h>
 #include <asm/unistd.h>
 
-extern void __init calibrate_delay(void);
-extern int cpu_idle(void * unused);
-extern void machine_halt(void);
-extern void start_ap(void);
-
-extern int cpu_now_booting;			/* used by head.S to find idle task */
-extern volatile unsigned long cpu_online_map;	/* bitmap of available cpu's */
-
-struct smp_boot_data smp_boot_data __initdata;
-
+/* The 'big kernel lock' */
 spinlock_t kernel_flag = SPIN_LOCK_UNLOCKED;
 
-char __initdata no_int_routing;
-
-/* don't make this a CPU-local variable: it's used for IPIs, mostly...  */
-int __cpu_physical_id[NR_CPUS];			/* logical ID -> physical CPU ID map */
-
-unsigned char smp_int_redirect;			/* are INT and IPI redirectable by the chipset? */
-int smp_num_cpus = 1;
-volatile int smp_threads_ready;			/* set when the idlers are all forked */
-unsigned long ap_wakeup_vector;			/* external Int to use to wakeup AP's */
-
-static volatile unsigned long cpu_callin_map;
-static volatile int smp_commenced;
-
-static int max_cpus = -1;			/* command line */
+/*
+ * Structure and data for smp_call_function(). This is designed to minimise static memory
+ * requirements. It also looks cleaner.
+ */
+static spinlock_t call_lock = SPIN_LOCK_UNLOCKED;
 
-struct smp_call_struct {
+struct call_data_struct {
 	void (*func) (void *info);
 	void *info;
 	long wait;
-	atomic_t unstarted_count;
-	atomic_t unfinished_count;
+	atomic_t started;
+	atomic_t finished;
 };
-static volatile struct smp_call_struct *smp_call_function_data;
 
-#define IPI_RESCHEDULE	        0
-#define IPI_CALL_FUNC	        1
-#define IPI_CPU_STOP	        2
+static volatile struct call_data_struct *call_data;
+
+#define IPI_RESCHEDULE		0
+#define IPI_CALL_FUNC		1
+#define IPI_CPU_STOP		2
 #ifndef CONFIG_ITANIUM_PTCG
 # define IPI_FLUSH_TLB		3
-#endif	/*!CONFIG_ITANIUM_PTCG */
-
-/*
- *	Setup routine for controlling SMP activation
- *
- *	Command-line option of "nosmp" or "maxcpus=0" will disable SMP
- *      activation entirely (the MPS table probe still happens, though).
- *
- *	Command-line option of "maxcpus=<NUM>", where <NUM> is an integer
- *	greater than 0, limits the maximum number of CPUs activated in
- *	SMP mode to <NUM>.
- */
+#endif  /*!CONFIG_ITANIUM_PTCG */
 
-static int __init
-nosmp (char *str)
-{
-	max_cpus = 0;
-	return 1;
-}
-
-__setup("nosmp", nosmp);
-
-static int __init
-maxcpus (char *str)
-{
-	get_option(&str, &max_cpus);
-	return 1;
-}
-
-__setup("maxcpus=", maxcpus);
-
-static int __init
-nointroute (char *str)
-{
-	no_int_routing = 1;
-	return 1;
-}
-
-__setup("nointroute", nointroute);
-
-/*
- * Yoink this CPU from the runnable list...
- */
-void
-halt_processor (void)
+static void
+stop_this_cpu (void)
 {
+	/*
+	 * Remove this CPU:
+	 */
 	clear_bit(smp_processor_id(), &cpu_online_map);
 	max_xtp();
 	__cli();
-	for (;;)
-		;
-}
-
-static inline int
-pointer_lock (void *lock, void *data, int retry)
-{
-	volatile long *ptr = lock;
- again:
-	if (cmpxchg_acq((void **) lock, 0, data) = 0)
-		return 0;
-
-	if (!retry)
-		return -EBUSY;
-
-	while (*ptr)
-		;
-
-	goto again;
+	for (;;);
 }
 
 void
 handle_IPI (int irq, void *dev_id, struct pt_regs *regs)
 {
+	int this_cpu = smp_processor_id();
 	unsigned long *pending_ipis = &local_cpu_data->ipi_operation;
 	unsigned long ops;
 
@@ -184,19 +116,19 @@
 
 		case IPI_CALL_FUNC:
 			{
-				struct smp_call_struct *data;
+				struct call_data_struct *data;
 				void (*func)(void *info);
 				void *info;
 				int wait;
 
 				/* release the 'pointer lock' */
-				data = (struct smp_call_struct *) smp_call_function_data;
+				data = (struct call_data_struct *) call_data;
 				func = data->func;
 				info = data->info;
 				wait = data->wait;
 
 				mb();
-				atomic_dec(&data->unstarted_count);
+				atomic_inc(&data->started);
 
 				/* At this point the structure may be gone unless wait is true.  */
 				(*func)(info);
@@ -204,12 +136,12 @@
 				/* Notify the sending CPU that the task is done.  */
 				mb();
 				if (wait)
-					atomic_dec(&data->unfinished_count);
+					atomic_inc(&data->finished);
 			}
 			break;
 
 		case IPI_CPU_STOP:
-			halt_processor();
+			stop_this_cpu();
 			break;
 
 #ifndef CONFIG_ITANIUM_PTCG
@@ -224,13 +156,9 @@
 
 			/*
 			 * Current CPU may be running with different RID so we need to
-			 * reload the RID of flushed address.
-			 * Current CPU may be running with different
-			 * RID so we need to reload the RID of flushed
-			 * address.  Purging the translation also
-			 * needs ALAT invalidation; we do not need
-			 * "invala" here since it is done in
-			 * ia64_leave_kernel.
+			 * reload the RID of flushed address.  Purging the translation
+			 * also needs ALAT invalidation; we do not need "invala" here
+			 * since it is done in ia64_leave_kernel.
 			 */
 			ia64_srlz_d();
 			if (saved_rid != flush_rid) {
@@ -260,8 +188,7 @@
 #endif	/* !CONFIG_ITANIUM_PTCG */
 
 		default:
-			printk(KERN_CRIT "Unknown IPI on CPU %d: %lu\n",
-			       smp_processor_id(), which);
+			printk(KERN_CRIT "Unknown IPI on CPU %d: %lu\n", this_cpu, which);
 			break;
 		} /* Switch */
 	  } while (ops);
@@ -313,12 +240,6 @@
 	send_IPI_single(cpu, IPI_RESCHEDULE);
 }
 
-void
-smp_send_stop (void)
-{
-	send_IPI_allbutself(IPI_CPU_STOP);
-}
-
 #ifndef CONFIG_ITANIUM_PTCG
 
 void
@@ -328,7 +249,7 @@
 }
 
 void
-smp_resend_flush_tlb(void)
+smp_resend_flush_tlb (void)
 {
 	/*
 	 * Really need a null IPI but since this rarely should happen & since this code
@@ -337,13 +258,20 @@
 	send_IPI_allbutself(IPI_RESCHEDULE);
 }
 
-#endif /* !CONFIG_ITANIUM_PTCG */
+#endif  /* !CONFIG_ITANIUM_PTCG */
+
+void
+smp_flush_tlb_all (void)
+{
+	smp_call_function ((void (*)(void *))__flush_tlb_all,0,1,1);
+	__flush_tlb_all();
+}
 
 /*
  * Run a function on another CPU
  *  <func>	The function to run. This must be fast and non-blocking.
  *  <info>	An arbitrary pointer to pass to the function.
- *  <retry>	If true, keep retrying until ready.
+ *  <nonatomic>	Currently unused.
  *  <wait>	If true, wait until function has completed on other CPUs.
  *  [RETURNS]   0 on success, else a negative status code.
  *
@@ -352,11 +280,14 @@
  */
 
 int
-smp_call_function_single (int cpuid, void (*func) (void *info), void *info, int retry, int wait)
+smp_call_function_single (int cpuid, void (*func) (void *info), void *info, int nonatomic,
+			  int wait)
 {
-	struct smp_call_struct data;
-	unsigned long timeout;
+	struct call_data_struct data;
 	int cpus = 1;
+#if (defined(CONFIG_ITANIUM_ASTEP_SPECIFIC) || defined(CONFIG_ITANIUM_BSTEP_SPECIFIC))
+	unsigned long timeout;
+#endif
 
 	if (cpuid = smp_processor_id()) {
 		printk(__FUNCTION__" trying to call self\n");
@@ -365,115 +296,103 @@
 
 	data.func = func;
 	data.info = info;
+	atomic_set(&data.started, 0);
 	data.wait = wait;
-	atomic_set(&data.unstarted_count, cpus);
-	atomic_set(&data.unfinished_count, cpus);
+	if (wait)
+		atomic_set(&data.finished, 0);
 
-	if (pointer_lock(&smp_call_function_data, &data, retry))
-		return -EBUSY;
+	spin_lock_bh(&call_lock);
+	call_data = &data;
 
-resend:
-	/*  Send a message to the other CPU and wait for it to respond  */
-	send_IPI_single(cpuid, IPI_CALL_FUNC);
+  resend:
+  	send_IPI_single(cpuid, IPI_CALL_FUNC);
 
-	/*  Wait for response  */
+#if (defined(CONFIG_ITANIUM_ASTEP_SPECIFIC) || defined(CONFIG_ITANIUM_BSTEP_SPECIFIC))
+	/*  Wait for response */
 	timeout = jiffies + HZ;
-	while ((atomic_read(&data.unstarted_count) > 0) && time_before(jiffies, timeout))
+	while ((atomic_read(&data.started) != cpus) && time_before(jiffies, timeout))
 		barrier();
-	if (atomic_read(&data.unstarted_count) > 0) {
-#if (defined(CONFIG_ITANIUM_ASTEP_SPECIFIC) || defined(CONFIG_ITANIUM_BSTEP_SPECIFIC))
+	if (atomic_read(&data.started) != cpus)
 		goto resend;
 #else
-		smp_call_function_data = NULL;
-		return -ETIMEDOUT;
+	/* Wait for response */
+	while (atomic_read(&data.started) != cpus)
+		barrier();
 #endif
-	}
 	if (wait)
-		while (atomic_read(&data.unfinished_count) > 0)
+		while (atomic_read(&data.finished) != cpus)
 			barrier();
-	/* unlock pointer */
-	smp_call_function_data = NULL;
+	call_data = NULL;
+
+	spin_unlock_bh(&call_lock);
 	return 0;
 }
 
 /*
- * Run a function on all other CPUs.
+ * this function sends a 'generic call function' IPI to all other CPUs
+ * in the system.
+ */
+
+/*
+ *  [SUMMARY]	Run a function on all other CPUs.
  *  <func>	The function to run. This must be fast and non-blocking.
  *  <info>	An arbitrary pointer to pass to the function.
- *  <retry>	If true, keep retrying until ready.
- *  <wait>	If true, wait until function has completed on other CPUs.
+ *  <nonatomic>	currently unused.
+ *  <wait>	If true, wait (atomically) until function has completed on other CPUs.
  *  [RETURNS]   0 on success, else a negative status code.
  *
- * Does not return until remote CPUs are nearly ready to execute <func>
- * or are or have executed.
+ * Does not return until remote CPUs are nearly ready to execute <func> or are or have
+ * executed.
+ *
+ * You must not call this function with disabled interrupts or from a hardware interrupt
+ * handler, you may call it from a bottom half handler.
  */
 int
-smp_call_function (void (*func) (void *info), void *info, int retry, int wait)
+smp_call_function (void (*func) (void *info), void *info, int nonatomic, int wait)
 {
-	struct smp_call_struct data;
+	struct call_data_struct data;
+	int cpus = smp_num_cpus-1;
+#if (defined(CONFIG_ITANIUM_ASTEP_SPECIFIC) || defined(CONFIG_ITANIUM_BSTEP_SPECIFIC))
 	unsigned long timeout;
-	int cpus = smp_num_cpus - 1;
+#endif
 
-	if (cpus = 0)
+	if (!cpus)
 		return 0;
 
 	data.func = func;
 	data.info = info;
+	atomic_set(&data.started, 0);
 	data.wait = wait;
-	atomic_set(&data.unstarted_count, cpus);
-	atomic_set(&data.unfinished_count, cpus);
+	if (wait)
+		atomic_set(&data.finished, 0);
 
-	if (pointer_lock(&smp_call_function_data, &data, retry))
-		return -EBUSY;
+	spin_lock_bh(&call_lock);
+	call_data = &data;
 
-	/*  Send a message to all other CPUs and wait for them to respond  */
+  resend:
+	/*  Send a message to all other CPUs and wait for them to respond */
 	send_IPI_allbutself(IPI_CALL_FUNC);
 
-retry:
-	/*  Wait for response  */
+#if (defined(CONFIG_ITANIUM_ASTEP_SPECIFIC) || defined(CONFIG_ITANIUM_BSTEP_SPECIFIC))
+	/* Wait for response */
 	timeout = jiffies + HZ;
-	while ((atomic_read(&data.unstarted_count) > 0) && time_before(jiffies, timeout))
+	while ((atomic_read(&data.started) != cpus) && time_before(jiffies, timeout))
 		barrier();
-	if (atomic_read(&data.unstarted_count) > 0) {
-#if (defined(CONFIG_ITANIUM_ASTEP_SPECIFIC) || defined(CONFIG_ITANIUM_BSTEP_SPECIFIC))
-		int i;
-		for (i = 0; i < smp_num_cpus; i++) {
-			if (i != smp_processor_id())
-				platform_send_ipi(i, IA64_IPI_VECTOR, IA64_IPI_DM_INT, 0);
-		}
-		goto retry;
+	if (atomic_read(&data.started) != cpus)
+		goto resend;
 #else
-		smp_call_function_data = NULL;
-		return -ETIMEDOUT;
+	/* Wait for response */
+	while (atomic_read(&data.started) != cpus)
+		barrier();
 #endif
-	}
+
 	if (wait)
-		while (atomic_read(&data.unfinished_count) > 0)
+		while (atomic_read(&data.finished) != cpus)
 			barrier();
-	/* unlock pointer */
-	smp_call_function_data = NULL;
-	return 0;
-}
-
-/*
- * Flush all other CPU's tlb and then mine.  Do this with smp_call_function() as we
- * want to ensure all TLB's flushed before proceeding.
- */
-void
-smp_flush_tlb_all (void)
-{
-	smp_call_function((void (*)(void *))__flush_tlb_all, NULL, 1, 1);
-	__flush_tlb_all();
-}
+	call_data = NULL;
 
-/*
- * Ideally sets up per-cpu profiling hooks.  Doesn't do much now...
- */
-static inline void __init
-smp_setup_percpu_timer(void)
-{
-	local_cpu_data->prof_counter = 1;
-	local_cpu_data->prof_multiplier = 1;
+	spin_unlock_bh(&call_lock);
+	return 0;
 }
 
 void
@@ -487,235 +406,18 @@
 	}
 }
 
-
-/*
- * AP's start using C here.
- */
-void __init
-smp_callin (void)
-{
-	extern void ia64_rid_init (void);
-	extern void ia64_init_itm (void);
-	extern void ia64_cpu_local_tick (void);
-	extern void ia64_sync_itc (void *);
-#ifdef CONFIG_PERFMON
-	extern void perfmon_init_percpu (void);
-#endif
-	int cpu = smp_processor_id();
-
-	if (test_and_set_bit(cpu, &cpu_online_map)) {
-		printk("CPU#%d already initialized!\n", cpu);
-		machine_halt();
-	}
-
-	efi_map_pal_code();
-	cpu_init();
-
-	ia64_sync_itc(0);		/* synchronize ar.itc with master */
-
-	smp_setup_percpu_timer();
-
-	/* setup the CPU local timer tick */
-	ia64_init_itm();
-
-#ifdef CONFIG_PERFMON
-	perfmon_init_percpu();
-#endif
-	local_irq_enable();		/* Interrupts have been off until now */
-
-	calibrate_delay();
-	local_cpu_data->loops_per_jiffy = loops_per_jiffy;
-
-	/* allow the master to continue */
-	set_bit(cpu, &cpu_callin_map);
-
-	/* finally, wait for the BP to finish initialization: */
-	while (!smp_commenced);
-
-	cpu_idle(NULL);
-}
-
-/*
- * Create the idle task for a new AP.  DO NOT use kernel_thread() because
- * that could end up calling schedule() in the ia64_leave_kernel exit
- * path in which case the new idle task could get scheduled before we
- * had a chance to remove it from the run-queue...
- */
-static int __init
-fork_by_hand (void)
-{
-	/*
-	 * Don't care about the usp and regs settings since we'll never
-	 * reschedule the forked task.
-	 */
-	return do_fork(CLONE_VM|CLONE_PID, 0, 0, 0);
-}
-
-/*
- * Bring one cpu online.  Return 0 if this fails for any reason.
- */
-static int __init
-smp_boot_one_cpu (int cpu)
-{
-	struct task_struct *idle;
-	int cpu_phys_id = cpu_physical_id(cpu);
-	long timeout;
-
-	/*
-	 * Create an idle task for this CPU.  Note that the address we
-	 * give to kernel_thread is irrelevant -- it's going to start
-	 * where OS_BOOT_RENDEVZ vector in SAL says to start.  But
-	 * this gets all the other task-y sort of data structures set
-	 * up like we wish.   We need to pull the just created idle task
-	 * off the run queue and stuff it into the init_tasks[] array.
-	 * Sheesh . . .
-	 */
-	if (fork_by_hand() < 0)
-		panic("failed fork for CPU 0x%x", cpu_phys_id);
-	/*
-	 * We remove it from the pidhash and the runqueue
-	 * once we got the process:
-	 */
-	idle = init_task.prev_task;
-	if (!idle)
-		panic("No idle process for CPU 0x%x", cpu_phys_id);
-	init_tasks[cpu] = idle;
-	del_from_runqueue(idle);
-	unhash_process(idle);
-
-	/* Schedule the first task manually.  */
-	idle->processor = cpu;
-	idle->has_cpu = 1;
-
-	/* Let _start know what logical CPU we're booting (offset into init_tasks[] */
-	cpu_now_booting = cpu;
-
-	/* Kick the AP in the butt */
-	platform_send_ipi(cpu, ap_wakeup_vector, IA64_IPI_DM_INT, 0);
-
-	/* wait up to 10s for the AP to start  */
-	for (timeout = 0; timeout < 100000; timeout++) {
-		if (test_bit(cpu, &cpu_callin_map))
-			return 1;
-		udelay(100);
-	}
-
-	printk(KERN_ERR "SMP: CPU 0x%x is stuck\n", cpu_phys_id);
-	return 0;
-}
-
-
-
 /*
- * Called by smp_init bring all the secondaries online and hold them.
+ * this function calls the 'stop' function on all other CPUs in the system.
  */
-void __init
-smp_boot_cpus (void)
-{
-	int i, cpu_count = 1;
-	unsigned long bogosum;
-
-	/* on the BP, the kernel already called calibrate_delay_loop() in init/main.c */
-	local_cpu_data->loops_per_jiffy = loops_per_jiffy;
-#if 0
-	smp_tune_scheduling();
-#endif
-	smp_setup_percpu_timer();
-
-	if (test_and_set_bit(0, &cpu_online_map)) {
-		printk("CPU#%d already initialized!\n", smp_processor_id());
-		machine_halt();
-	}
-	init_idle();
-
-	/* Nothing to do when told not to.  */
-	if (max_cpus = 0) {
-		printk(KERN_INFO "SMP mode deactivated.\n");
-		return;
-	}
-
-	if (max_cpus != -1)
-		printk("Limiting CPUs to %d\n", max_cpus);
-
-	if (smp_boot_data.cpu_count > 1) {
-		printk(KERN_INFO "SMP: starting up secondaries.\n");
-
-		for (i = 0; i < smp_boot_data.cpu_count; i++) {
-			/* skip performance restricted and bootstrap cpu: */
-			if (smp_boot_data.cpu_phys_id[i] = -1
-			    || smp_boot_data.cpu_phys_id[i] = hard_smp_processor_id())
-				continue;
-
-			cpu_physical_id(cpu_count) = smp_boot_data.cpu_phys_id[i];
-			if (!smp_boot_one_cpu(cpu_count))
-				continue;	/* failed */
-
-			cpu_count++; /* Count good CPUs only... */
-			/*
-			 * Bail if we've started as many CPUS as we've been told to.
-			 */
-			if (cpu_count = max_cpus)
-				break;
-		}
-	}
-
-	if (cpu_count = 1) {
-		printk(KERN_ERR "SMP: Bootstrap processor only.\n");
-	}
-
-	bogosum = 0;
-	for (i = 0; i < NR_CPUS; i++) {
-		if (cpu_online_map & (1L << i))
-			bogosum += cpu_data[i].loops_per_jiffy;
-	}
-
-	printk(KERN_INFO "SMP: Total of %d processors activated (%lu.%02lu BogoMIPS).\n",
-	       cpu_count, bogosum*HZ/500000, (bogosum*HZ/5000) % 100);
-
-	smp_num_cpus = cpu_count;
-}
-
-/*
- * Called when the BP is just about to fire off init.
- */
-void __init
-smp_commence (void)
+void
+smp_send_stop (void)
 {
-	smp_commenced = 1;
+	send_IPI_allbutself(IPI_CPU_STOP);
+	smp_num_cpus = 1;
 }
 
 int __init
 setup_profiling_timer (unsigned int multiplier)
 {
 	return -EINVAL;
-}
-
-/*
- * Assume that CPU's have been discovered by some platform-dependant
- * interface.  For SoftSDV/Lion, that would be ACPI.
- *
- * Setup of the IPI irq handler is done in irq.c:init_IRQ().
- *
- * This also registers the AP OS_MC_REDVEZ address with SAL.
- */
-void __init
-init_smp_config (void)
-{
-	struct fptr {
-		unsigned long fp;
-		unsigned long gp;
-	} *ap_startup;
-	long sal_ret;
-
-	/* Tell SAL where to drop the AP's.  */
-	ap_startup = (struct fptr *) start_ap;
-	sal_ret = ia64_sal_set_vectors(SAL_VECTOR_OS_BOOT_RENDEZ, __pa(ap_startup->fp),
-				       __pa(ap_startup->gp), 0, 0, 0, 0);
-	if (sal_ret < 0) {
-		printk("SMP: Can't set SAL AP Boot Rendezvous: %s\n", ia64_sal_strerror(sal_ret));
-		printk("     Forcing UP mode\n");
-		max_cpus = 0;
-		smp_num_cpus = 1;
-	}
-
 }
diff -urN linux-davidm/arch/ia64/kernel/smpboot.c linux-2.4.5-lia/arch/ia64/kernel/smpboot.c
--- linux-davidm/arch/ia64/kernel/smpboot.c	Wed May 30 23:17:48 2001
+++ linux-2.4.5-lia/arch/ia64/kernel/smpboot.c	Wed May 30 22:44:32 2001
@@ -2,15 +2,56 @@
  * SMP boot-related support
  *
  * Copyright (C) 2001 David Mosberger-Tang <davidm@hpl.hp.com>
+ *
+ * 01/05/16 Rohit Seth <rohit.seth@intel.com>	Moved SMP booting functions from smp.c to here.
+ * 01/04/27 David Mosberger <davidm@hpl.hp.com>	Added ITC synching code.
  */
 
+
+#define __KERNEL_SYSCALLS__
+
+#include <linux/config.h>
+
+#include <linux/bootmem.h>
+#include <linux/delay.h>
+#include <linux/init.h>
+#include <linux/interrupt.h>
+#include <linux/irq.h>
 #include <linux/kernel.h>
+#include <linux/kernel_stat.h>
+#include <linux/mm.h>
+#include <linux/smp.h>
+#include <linux/smp_lock.h>
 #include <linux/spinlock.h>
 
+#include <asm/atomic.h>
+#include <asm/bitops.h>
 #include <asm/cache.h>
+#include <asm/current.h>
 #include <asm/delay.h>
+#include <asm/efi.h>
+#include <asm/io.h>
+#include <asm/irq.h>
+#include <asm/machvec.h>
+#include <asm/page.h>
+#include <asm/pgalloc.h>
+#include <asm/pgtable.h>
+#include <asm/processor.h>
+#include <asm/ptrace.h>
+#include <asm/sal.h>
 #include <asm/system.h>
+#include <asm/unistd.h>
+
+#if SMP_DEBUG
+#define Dprintk(x...)  printk(x)
+#else
+#define Dprintk(x...)
+#endif
+
 
+/*
+ * ITC synchronization related stuff:
+ */
 #define MASTER	0
 #define SLAVE	(SMP_CACHE_BYTES/8)
 
@@ -20,7 +61,75 @@
 static spinlock_t itc_sync_lock = SPIN_LOCK_UNLOCKED;
 static volatile unsigned long go[SLAVE + 1];
 
-#define DEBUG_ITC_SYNC	1
+#define DEBUG_ITC_SYNC	0
+
+extern void __init calibrate_delay(void);
+extern void start_ap(void);
+
+int cpucount;
+
+/* Setup configured maximum number of CPUs to activate */
+static int max_cpus = -1;
+
+/* Total count of live CPUs */
+int smp_num_cpus = 1;
+
+/* Bitmask of currently online CPUs */
+volatile unsigned long cpu_online_map;
+
+/* which logical CPU number maps to which CPU (physical APIC ID) */
+volatile int ia64_cpu_to_sapicid[NR_CPUS];
+
+static volatile unsigned long cpu_callin_map;
+
+struct smp_boot_data smp_boot_data __initdata;
+
+/* Set when the idlers are all forked */
+volatile int smp_threads_ready;
+
+unsigned long ap_wakeup_vector = -1; /* External Int use to wakeup APs */
+
+char __initdata no_int_routing;
+
+unsigned char smp_int_redirect; /* are INT and IPI redirectable by the chipset? */
+
+/*
+ * Setup routine for controlling SMP activation
+ *
+ * Command-line option of "nosmp" or "maxcpus=0" will disable SMP
+ * activation entirely (the MPS table probe still happens, though).
+ *
+ * Command-line option of "maxcpus=<NUM>", where <NUM> is an integer
+ * greater than 0, limits the maximum number of CPUs activated in
+ * SMP mode to <NUM>.
+ */
+
+static int __init
+nosmp (char *str)
+{
+	max_cpus = 0;
+	return 1;
+}
+
+__setup("nosmp", nosmp);
+
+static int __init
+maxcpus (char *str)
+{
+	get_option(&str, &max_cpus);
+	return 1;
+}
+
+__setup("maxcpus=", maxcpus);
+
+static int __init
+nointroute (char *str)
+{
+	no_int_routing = 1;
+	return 1;
+}
+
+__setup("nointroute", nointroute);
 
 void
 sync_master (void *arg)
@@ -164,4 +273,292 @@
 
 	printk("CPU %d: synchronized ITC with CPU %u (last diff %ld cycles, maxerr %lu cycles)\n",
 	       smp_processor_id(), master, delta, rt);
+}
+
+/*
+ * Ideally sets up per-cpu profiling hooks.  Doesn't do much now...
+ */
+static inline void __init
+smp_setup_percpu_timer (void)
+{
+	local_cpu_data->prof_counter = 1;
+	local_cpu_data->prof_multiplier = 1;
+}
+
+/*
+ * Architecture specific routine called by the kernel just before init is
+ * fired off. This allows the BP to have everything in order [we hope].
+ * At the end of this all the APs will hit the system scheduling and off
+ * we go. Each AP will jump through the kernel
+ * init into idle(). At this point the scheduler will one day take over
+ * and give them jobs to do. smp_callin is a standard routine
+ * we use to track CPUs as they power up.
+ */
+
+static volatile atomic_t smp_commenced = ATOMIC_INIT(0);
+
+void __init
+smp_commence (void)
+{
+	/*
+	 * Lets the callins below out of their loop.
+	 */
+	Dprintk("Setting commenced=1, go go go\n");
+
+	wmb();
+	atomic_set(&smp_commenced,1);
+}
+
+
+void __init
+smp_callin (void)
+{
+	int cpuid, phys_id;
+	extern void ia64_init_itm(void);
+
+#ifdef CONFIG_PERFMON
+	extern void perfmon_init_percpu(void);
+#endif
+
+	cpuid = smp_processor_id();
+	phys_id = hard_smp_processor_id();
+
+	if (test_and_set_bit(cpuid, &cpu_online_map)) {
+		printk("huh, phys CPU#0x%x, CPU#0x%x already present??\n", 
+					phys_id, cpuid);
+		BUG();
+	}
+
+	smp_setup_percpu_timer();
+
+	/*
+	 * Synchronize the ITC with the BP
+	 */
+	Dprintk("Going to syncup ITC with BP.\n");
+
+	ia64_sync_itc(0);
+	/*
+	 * Get our bogomips.
+	 */
+	ia64_init_itm();
+#ifdef CONFIG_PERFMON
+	perfmon_init_percpu();
+#endif
+
+	local_irq_enable();
+	calibrate_delay();
+	local_cpu_data->loops_per_jiffy = loops_per_jiffy;
+	/*
+	 * Allow the master to continue.
+	 */
+	set_bit(cpuid, &cpu_callin_map);
+	Dprintk("Stack on CPU %d at about %p\n",cpuid, &cpuid);
+}
+
+
+/*
+ * Activate a secondary processor.  head.S calls this.
+ */
+int __init
+start_secondary (void *unused)
+{
+	extern int cpu_idle (void);
+
+	efi_map_pal_code();
+	cpu_init();
+	smp_callin();
+	Dprintk("CPU %d is set to go. \n", smp_processor_id());
+	while (!atomic_read(&smp_commenced))
+		;
+
+	Dprintk("CPU %d is starting idle. \n", smp_processor_id());
+	return cpu_idle();
+}
+
+static int __init
+fork_by_hand (void)
+{
+	/*
+	 * don't care about the eip and regs settings since
+	 * we'll never reschedule the forked task.
+	 */
+	return do_fork(CLONE_VM|CLONE_PID, 0, 0, 0);
+}
+
+static void __init
+do_boot_cpu (int sapicid)
+{
+	struct task_struct *idle;
+	int timeout, cpu;
+
+	cpu = ++cpucount;
+	/*
+	 * We can't use kernel_thread since we must avoid to
+	 * reschedule the child.
+	 */
+	if (fork_by_hand() < 0)
+		panic("failed fork for CPU %d", cpu);
+
+	/*
+	 * We remove it from the pidhash and the runqueue
+	 * once we got the process:
+	 */
+	idle = init_task.prev_task;
+	if (!idle)
+		panic("No idle process for CPU %d", cpu);
+
+	idle->processor = cpu;
+	ia64_cpu_to_sapicid[cpu] = sapicid;
+	idle->has_cpu = 1; /* we schedule the first task manually */
+
+	del_from_runqueue(idle);
+	unhash_process(idle);
+	init_tasks[cpu] = idle;
+
+	Dprintk("Sending Wakeup Vector to AP 0x%x/0x%x.\n", cpu, sapicid);
+
+	platform_send_ipi(cpu, ap_wakeup_vector, IA64_IPI_DM_INT, 0);
+
+	/*
+	 * Wait 10s total for the AP to start
+	 */
+	Dprintk("Waiting on callin_map ...");
+	for (timeout = 0; timeout < 100000; timeout++) {
+		Dprintk(".");
+		if (test_bit(cpu, &cpu_callin_map))
+			break;  /* It has booted */
+		udelay(100);
+	}
+	Dprintk("\n");
+
+	if (test_bit(cpu, &cpu_callin_map)) {
+		/* number CPUs logically, starting from 1 (BSP is 0) */
+		printk("CPU%d: ", cpu);
+		/*print_cpu_info(&cpu_data[cpu]); */
+		printk("CPU has booted.\n");
+	} else {
+		printk(KERN_ERR "Processor 0x%x/0x%x is stuck.\n", cpu, sapicid);
+		ia64_cpu_to_sapicid[cpu] = -1;
+		cpucount--;
+	}
+}
+
+/*
+ * Cycle through the APs sending Wakeup IPIs to boot each.
+ */
+void __init
+smp_boot_cpus (void)
+{
+	int sapicid, cpu;
+	int boot_cpu_id = hard_smp_processor_id();
+
+	/*
+	 * Initialize the logical to physical CPU number mapping
+	 * and the per-CPU profiling counter/multiplier
+	 */
+
+	for (cpu = 0; cpu < NR_CPUS; cpu++)
+		ia64_cpu_to_sapicid[cpu] = -1;
+	smp_setup_percpu_timer();
+
+	/*
+	* We have the boot CPU online for sure.
+	*/
+	set_bit(0, &cpu_online_map);
+	set_bit(0, &cpu_callin_map);
+
+	printk("Loops_per_jiffy for BOOT CPU = 0x%x\n", loops_per_jiffy);
+
+	local_cpu_data->loops_per_jiffy = loops_per_jiffy;
+	ia64_cpu_to_sapicid[0] = boot_cpu_id;
+
+	printk("Boot processor id 0x%x/0x%x\n", 0, boot_cpu_id);
+
+	global_irq_holder = 0;
+	current->processor = 0;
+	init_idle();
+
+	/*
+	 * If SMP should be disabled, then really disable it!
+	 */
+	if ((!max_cpus) || (max_cpus < -1)) {
+		printk(KERN_INFO "SMP mode deactivated.\n");
+		cpu_online_map =  1;
+		smp_num_cpus = 1;
+		goto smp_done;
+	}
+	if  (max_cpus != -1)
+		printk (KERN_INFO "Limiting CPUs to %d\n", max_cpus);
+
+	if (smp_boot_data.cpu_count > 1) {
+
+		printk(KERN_INFO "SMP: starting up secondaries.\n");
+
+		for (cpu = 0; cpu < smp_boot_data.cpu_count; cpu++) {
+			/*
+			 * Don't even attempt to start the boot CPU!
+			 */
+			sapicid = smp_boot_data.cpu_phys_id[cpu];
+			if ((sapicid = -1) || (sapicid = hard_smp_processor_id()))
+				continue;
+
+			if ((max_cpus > 0) && (max_cpus = cpucount+1))
+				break;
+
+			do_boot_cpu(sapicid);
+
+			/*
+			* Make sure we unmap all failed CPUs
+			*/
+			if (ia64_cpu_to_sapicid[cpu] = -1)
+				printk("phys CPU#%d not responding - cannot use it.\n", cpu);
+		}
+
+		smp_num_cpus = cpucount + 1;
+
+		/*
+		* Allow the user to impress friends.
+		*/
+
+		printk("Before bogomips.\n");
+		if (!cpucount) {
+			printk(KERN_ERR "Error: only one processor found.\n");
+		} else {
+			unsigned long bogosum = 0;
+  			for (cpu = 0; cpu < NR_CPUS; cpu++)
+				if (cpu_online_map & (1<<cpu))
+					bogosum += cpu_data[cpu].loops_per_jiffy;
+
+			printk(KERN_INFO"Total of %d processors activated (%lu.%02lu BogoMIPS).\n",
+			       cpucount + 1, bogosum/(500000/HZ), (bogosum/(5000/HZ))%100);
+		}
+	}
+  smp_done:
+}
+
+/*
+ * Assume that CPU's have been discovered by some platform-dependant interface.  For
+ * SoftSDV/Lion, that would be ACPI.
+ *
+ * Setup of the IPI irq handler is done in irq.c:init_IRQ_SMP().
+ */
+void __init
+init_smp_config(void)
+{
+	struct fptr {
+		unsigned long fp;
+		unsigned long gp;
+	} *ap_startup;
+	long sal_ret;
+
+	/* Tell SAL where to drop the AP's.  */
+	ap_startup = (struct fptr *) start_ap;
+	sal_ret = ia64_sal_set_vectors(SAL_VECTOR_OS_BOOT_RENDEZ,
+				       __pa(ap_startup->fp), __pa(ap_startup->gp), 0, 0, 0, 0);
+	if (sal_ret < 0) {
+		printk("SMP: Can't set SAL AP Boot Rendezvous: %s\n     Forcing UP mode\n",
+		       ia64_sal_strerror(sal_ret));
+		max_cpus = 0;
+		smp_num_cpus = 1;
+	}
 }
diff -urN linux-davidm/arch/ia64/kernel/traps.c linux-2.4.5-lia/arch/ia64/kernel/traps.c
--- linux-davidm/arch/ia64/kernel/traps.c	Wed May 30 23:17:48 2001
+++ linux-2.4.5-lia/arch/ia64/kernel/traps.c	Wed May 30 22:45:44 2001
@@ -320,7 +320,7 @@
 			}
 			siginfo.si_signo = SIGFPE;
 			siginfo.si_errno = 0;
-			siginfo.si_code = 0;
+			siginfo.si_code = __SI_FAULT;	/* default code */
 			siginfo.si_addr = (void *) (regs->cr_iip + ia64_psr(regs)->ri);
 			if (isr & 0x11) {
 				siginfo.si_code = FPE_FLTINV;
@@ -338,7 +338,7 @@
 			/* raise exception */
 			siginfo.si_signo = SIGFPE;
 			siginfo.si_errno = 0;
-			siginfo.si_code = 0;
+			siginfo.si_code = __SI_FAULT;	/* default code */
 			siginfo.si_addr = (void *) (regs->cr_iip + ia64_psr(regs)->ri);
 			if (isr & 0x880) {
 				siginfo.si_code = FPE_FLTOVF;
diff -urN linux-davidm/arch/ia64/kernel/unaligned.c linux-2.4.5-lia/arch/ia64/kernel/unaligned.c
--- linux-davidm/arch/ia64/kernel/unaligned.c	Wed May 30 23:17:48 2001
+++ linux-2.4.5-lia/arch/ia64/kernel/unaligned.c	Wed May 30 22:46:22 2001
@@ -1299,7 +1299,12 @@
 			len = sprintf(buf, "%s(%d): unaligned access to 0x%016lx, "
 				      "ip=0x%016lx\n\r", current->comm, current->pid,
 				      ifa, regs->cr_iip + ipsr->ri);
-			tty_write_message(current->tty, buf);
+			/*
+			 * Don't call tty_write_message() if we're in the kernel; we might
+			 * be holding locks...
+			 */
+			if (user_mode(regs))
+				tty_write_message(current->tty, buf);
 			buf[len-1] = '\0';	/* drop '\r' */
 			printk(KERN_WARNING "%s", buf);	/* watch for command names containing %s */
 		}
diff -urN linux-davidm/arch/ia64/kernel/unwind.c linux-2.4.5-lia/arch/ia64/kernel/unwind.c
--- linux-davidm/arch/ia64/kernel/unwind.c	Wed May 30 23:17:48 2001
+++ linux-2.4.5-lia/arch/ia64/kernel/unwind.c	Wed May 30 22:46:37 2001
@@ -1847,9 +1847,9 @@
 
 static void
 init_unwind_table (struct unw_table *table, const char *name, unsigned long segment_base,
-		   unsigned long gp, void *table_start, void *table_end)
+		   unsigned long gp, const void *table_start, const void *table_end)
 {
-	struct unw_table_entry *start = table_start, *end = table_end;
+	const struct unw_table_entry *start = table_start, *end = table_end;
 
 	table->name = name;
 	table->segment_base = segment_base;
@@ -1862,9 +1862,9 @@
 
 void *
 unw_add_unwind_table (const char *name, unsigned long segment_base, unsigned long gp,
-		      void *table_start, void *table_end)
+		      const void *table_start, const void *table_end)
 {
-	struct unw_table_entry *start = table_start, *end = table_end;
+	const struct unw_table_entry *start = table_start, *end = table_end;
 	struct unw_table *table;
 	unsigned long flags;
 
diff -urN linux-davidm/arch/ia64/lib/swiotlb.c linux-2.4.5-lia/arch/ia64/lib/swiotlb.c
--- linux-davidm/arch/ia64/lib/swiotlb.c	Sun Apr 29 15:49:26 2001
+++ linux-2.4.5-lia/arch/ia64/lib/swiotlb.c	Wed May 30 22:47:32 2001
@@ -263,7 +263,7 @@
 
 	memset(ret, 0, size);
 	pci_addr = virt_to_phys(ret);
-	if ((pci_addr & ~hwdev->dma_mask) != 0)
+	if (hwdev && (pci_addr & ~hwdev->dma_mask) != 0)
 		panic("swiotlb_alloc_consistent: allocated memory is out of range for PCI device");
 	*dma_handle = pci_addr;
 	return ret;
diff -urN linux-davidm/arch/ia64/mm/extable.c linux-2.4.5-lia/arch/ia64/mm/extable.c
--- linux-davidm/arch/ia64/mm/extable.c	Sun Apr 29 15:49:26 2001
+++ linux-2.4.5-lia/arch/ia64/mm/extable.c	Wed May 30 22:47:51 2001
@@ -6,8 +6,9 @@
  */
 
 #include <linux/config.h>
-#include <linux/module.h>
+
 #include <asm/uaccess.h>
+#include <asm/module.h>
 
 extern const struct exception_table_entry __start___ex_table[];
 extern const struct exception_table_entry __stop___ex_table[];
@@ -15,35 +16,25 @@
 static inline const struct exception_table_entry *
 search_one_table (const struct exception_table_entry *first,
 		  const struct exception_table_entry *last,
-		  signed long value)
+		  unsigned long ip, unsigned long gp)
 {
-	/* Abort early if the search value is out of range.  */
-	if (value != (signed int)value)
-		return 0;
-
         while (first <= last) {
 		const struct exception_table_entry *mid;
 		long diff;
-		/*
-		 * We know that first and last are both kernel virtual
-		 * pointers (region 7) so first+last will cause an
-		 * overflow.  We fix that by calling __va() on the
-		 * result, which will ensure that the top two bits get
-		 * set again.
-		 */
-		mid = (void *) __va((((__u64) first + (__u64) last)/2/sizeof(*mid))*sizeof(*mid));
-		diff = mid->addr - value;
+
+		mid = &first[(last - first)/2];
+		diff = (mid->addr + gp) - ip;
                 if (diff = 0)
                         return mid;
                 else if (diff < 0)
-                        first = mid+1;
+                        first = mid + 1;
                 else
-                        last = mid-1;
+                        last = mid - 1;
         }
         return 0;
 }
 
-#ifndef CONFIG_MODULE
+#ifndef CONFIG_MODULES
 register unsigned long main_gp __asm__("gp");
 #endif
 
@@ -53,23 +44,25 @@
 	const struct exception_table_entry *entry;
 	struct exception_fixup fix = { 0 };
 
-#ifndef CONFIG_MODULE
+#ifndef CONFIG_MODULES
 	/* There is only the kernel to search.  */
-	entry = search_one_table(__start___ex_table, __stop___ex_table - 1, addr - main_gp);
+	entry = search_one_table(__start___ex_table, __stop___ex_table - 1, addr, main_gp);
 	if (entry)
 		fix.cont = entry->cont + main_gp;
 	return fix;
 #else
-	struct exception_table_entry *ret;
-	/* The kernel is the last "module" -- no need to treat it special. */
+	struct archdata *archdata;
 	struct module *mp;
 
+	/* The kernel is the last "module" -- no need to treat it special. */
 	for (mp = module_list; mp ; mp = mp->next) {
 		if (!mp->ex_table_start)
 			continue;
-		entry = search_one_table(mp->ex_table_start, mp->ex_table_end - 1, addr - mp->gp);
+		archdata = (struct archdata *) mp->archdata_start;
+		entry = search_one_table(mp->ex_table_start, mp->ex_table_end - 1,
+					 addr, (unsigned long) archdata->gp);
 		if (entry) {
-			fix.cont = entry->cont + mp->gp;
+			fix.cont = entry->cont + (unsigned long) archdata->gp;
 			return fix;
 		}
 	}
diff -urN linux-davidm/arch/ia64/mm/init.c linux-2.4.5-lia/arch/ia64/mm/init.c
--- linux-davidm/arch/ia64/mm/init.c	Wed May 30 23:17:48 2001
+++ linux-2.4.5-lia/arch/ia64/mm/init.c	Wed May 30 22:52:30 2001
@@ -354,6 +354,7 @@
 {
 	extern char __start_gate_section[];
 	long reserved_pages, codesize, datasize, initsize;
+	unsigned long num_pgt_pages;
 
 #ifdef CONFIG_PCI
 	/*
@@ -386,6 +387,19 @@
 	       (unsigned long) nr_free_pages() << (PAGE_SHIFT - 10),
 	       max_mapnr << (PAGE_SHIFT - 10), codesize >> 10, reserved_pages << (PAGE_SHIFT - 10),
 	       datasize >> 10, initsize >> 10);
+
+	/*
+	 * Allow for enough (cached) page table pages so that we can map the entire memory
+	 * at least once.  Each task also needs a couple of page tables pages, so add in a
+	 * fudge factor for that (don't use "threads-max" here; that would be wrong!).
+	 * Don't allow the cache to be more than 10% of total memory, though.
+	 */
+#	define NUM_TASKS	500	/* typical number of tasks */
+	num_pgt_pages = nr_free_pages() / PTRS_PER_PGD + NUM_TASKS;
+	if (num_pgt_pages > nr_free_pages() / 10)
+		num_pgt_pages = nr_free_pages() / 10;
+	if (num_pgt_pages > pgt_cache_water[1])
+		pgt_cache_water[1] = num_pgt_pages;
 
 	/* install the gate page in the global page table: */
 	put_gate_page(virt_to_page(__start_gate_section), GATE_ADDR);
diff -urN linux-davidm/drivers/acpi/acpiconf.c linux-2.4.5-lia/drivers/acpi/acpiconf.c
--- linux-davidm/drivers/acpi/acpiconf.c	Wed May 30 23:17:48 2001
+++ linux-2.4.5-lia/drivers/acpi/acpiconf.c	Wed May 30 22:52:55 2001
@@ -1,21 +1,24 @@
 /*
  *  acpiconf.c - ACPI based kernel configuration
  *
- *  Copyright (C) 2000 Intel Corp.
- *  Copyright (C) 2000 J.I. Lee <Jung-Ik.Lee@intel.com>
+ *  Copyright (C) 2000-2001 Intel Corp.
+ *  Copyright (C) 2000-2001 J.I. Lee <Jung-Ik.Lee@intel.com>
  *
- *  revision history:
+ *  Revision History:
  *	 9/15/2000 J.I.
  *		Major revision:	for new ACPI initialization requirements
- *				for ACPI CA label 915
  *	11/15/2000 J.I.
- *		Major revision:	ACPI 2.0 tables support with ACPI CA label 1115
+ *		Major revision:	ACPI 2.0 tables support
+ *	04/23/2001 J.I.
+ *		Rewrote functions to support multiple _PRTs of child P2Ps
+ *		under root pci bus
  */
 
 
 #include <linux/config.h>
 #include <linux/init.h>
 #include <linux/kernel.h>
+#include <linux/pci.h>
 #include <asm/system.h>
 #include <asm/iosapic.h>
 #include <asm/efi.h>
@@ -114,7 +117,7 @@
 
 	status = acpi_cf_get_prt (&prts);
 	if (ACPI_FAILURE (status)) {
-		printk("Acpi Cfg: get prt fail\n");
+		printk("Acpi cfg: get prt fail\n");
 		return status;
 	}
 
@@ -124,59 +127,76 @@
 		acpi_cf_print_pci_vectors (*vectors, *num_pci_vectors);
 	}
 #endif
-	printk("Acpi Cfg: get PRT %s\n", (ACPI_SUCCESS(status))?"pass":"fail");
+	printk("Acpi cfg: get PCI interrupt vectors %s\n",
+		(ACPI_SUCCESS(status))?"pass":"fail");
 
 	return status;
 }
 
 
 static	PCI_ROUTING_TABLE	*pci_routing_tables[PCI_MAX_BUS] __initdata = {NULL};
-static	struct pci_vector_struct *vectors_to_free __initdata = NULL;
+
+
+typedef struct _acpi_rpb {
+	NATIVE_UINT	rpb_busnum;
+	NATIVE_UINT	lastbusnum;
+	ACPI_HANDLE	rpb_handle;
+} acpi_rpb_t;
 
 
 static ACPI_STATUS	__init
-acpi_cf_get_prt (
-	void		**prts
+acpi_cf_evaluate_method (
+	ACPI_HANDLE	handle,
+	UINT8		*method_name,
+	NATIVE_UINT	*nuint
 	)
 {
-	ACPI_STATUS	status;
+	UINT32			tnuint = 0;
+	ACPI_STATUS		status;
 
-	status = acpi_walk_namespace ( ACPI_TYPE_DEVICE,
-					ACPI_ROOT_OBJECT,
-					ACPI_UINT32_MAX,
-					acpi_cf_get_prt_callback,
-					NULL,
-					NULL );
+	ACPI_BUFFER		ret_buf;
+	ACPI_OBJECT		*ext_obj;
+	UINT8			buf[PATHNAME_MAX];
+
+
+	ret_buf.length  = PATHNAME_MAX;
+	ret_buf.pointer = (void *) buf;
 
+	status = acpi_evaluate_object(handle, method_name, NULL, &ret_buf);
 	if (ACPI_FAILURE(status)) {
-		printk("Acpi cfg:walk namespace error=0x%x\n", status);
-	}
+		if (status = AE_NOT_FOUND) {
+			printk("Acpi cfg: no %s found\n", method_name);
+		} else {
+			printk("Acpi cfg: %s fail=0x%x\n", method_name, status);
+		}
+	} else {
+		ext_obj = (ACPI_OBJECT *) ret_buf.pointer;
 
-	*prts = (void *)pci_routing_tables;
+		switch (ext_obj->type) {
+		case ACPI_TYPE_INTEGER:
+			tnuint = (NATIVE_UINT) ext_obj->integer.value;
+			break;
+		default:
+			printk("Acpi cfg: %s obj type incorrect\n", method_name);
+			status = AE_TYPE;
+			break;
+		}
+	}
 
-	return status;
+	*nuint = tnuint;
+	return (status);
 }
 
 
 static ACPI_STATUS	__init
-acpi_cf_get_prt_callback (
+acpi_cf_evaluate_PRT (
 	ACPI_HANDLE		handle,
-	UINT32			Level,
-	void			*context,
-	void			**retval
+	PCI_ROUTING_TABLE	**prt
 	)
 {
 	ACPI_BUFFER		acpi_buffer;
-	PCI_ROUTING_TABLE	*prt;
-	NATIVE_UINT		busnum = 0;
-	static NATIVE_UINT	next_busnum = 0;
 	ACPI_STATUS		status;
 
-	ACPI_BUFFER		ret_buf;
-	ACPI_OBJECT		*ext_obj;
-	UINT8			buf[PATHNAME_MAX];
-
-
 	acpi_buffer.length  = 0;
 	acpi_buffer.pointer = NULL;
 
@@ -184,105 +204,277 @@
 
 	switch (status) {
 	case AE_BUFFER_OVERFLOW:
-		dprintk(("Acpi Cfg: _PRT found. Need %d bytes\n", acpi_buffer.length));
+		dprintk(("Acpi cfg: _PRT found. need %d bytes\n",
+			acpi_buffer.length));
 		break;		/* found */
-	case AE_NOT_FOUND:
-		return AE_OK;	/* let acpi_walk_namespace continue. */
 	default:
-		printk("Acpi cfg:get irq routing table fail=0x%x\n", status);
-		return AE_ERROR;
+		printk("Acpi cfg: _PRT fail=0x%x\n", status);
+	case AE_NOT_FOUND:
+		return status;
 	}
 
-	prt = (PCI_ROUTING_TABLE *) acpi_os_callocate (acpi_buffer.length);
-	if (prt = NULL) {
-		printk("Acpi cfg:callocate %d bytes Fail\n", acpi_buffer.length);
-		return AE_ERROR;
+	*prt = (PCI_ROUTING_TABLE *) acpi_os_callocate (acpi_buffer.length);
+	if (!*prt) {
+		printk("Acpi cfg: callocate %d bytes for _PRT fail\n",
+			acpi_buffer.length);
+		return AE_NO_MEMORY;
 	}
-	acpi_buffer.pointer = (void *) prt;
+	acpi_buffer.pointer = (void *) *prt;
 
 	status = acpi_get_irq_routing_table (handle, &acpi_buffer);
 	if (ACPI_FAILURE(status)) {
-		printk("Acpi cfg:get irq routing table Fail=0x%x\n", status);
+		printk("Acpi cfg: _PRT fail=0x%x.\n", status);
 		acpi_os_free(prt);
-		return AE_OK;
 	}
 
+	return status;
+}
+
+static ACPI_STATUS	__init
+acpi_cf_get_root_pci_callback (
+	ACPI_HANDLE		handle,
+	UINT32			Level,
+	void			*context,
+	void			**retval
+	)
+{
+	NATIVE_UINT		busnum = 0;
+	ACPI_STATUS		status;
+	acpi_rpb_t		rpb;
+	PCI_ROUTING_TABLE	*prt;
+
+	ACPI_BUFFER		ret_buf;
+	UINT8			path_name[PATHNAME_MAX];
+
 #ifdef	CONFIG_ACPI_KERNEL_CONFIG_DEBUG
 	ret_buf.length  = PATHNAME_MAX;
-	ret_buf.pointer = (void *) buf;
+	ret_buf.pointer = (void *) path_name;
 
 	status = acpi_get_name(handle, ACPI_FULL_PATHNAME, &ret_buf);
-	if (ACPI_SUCCESS(status)) {
-		printk("Acpi cfg:path=[%s]\n", (char *)ret_buf.pointer);
-	}
+#else
+	memset(path_name, 0, sizeof (path_name));
 #endif
 
+	/*
+	 * get bus number of this pci root bridge
+	 */
+	status = acpi_cf_evaluate_method(handle, METHOD_NAME__BBN, &busnum);
+	if (ACPI_FAILURE(status)) {
+		printk("Acpi cfg:%s evaluate _BBN fail=0x%x\n",
+			path_name, status);
+		return (status);
+	}
+	printk("Acpi cfg:%s ROOT PCI bus %ld\n", path_name, busnum);
+
+	/*
+	 * evaluate root pci bridge's _CRS for Bus number range for child P2P
+	 * (bus min/max/len) - not yet.
+	 */
+
+	/*
+	 * get immediate _PRT of this root pci bridge if any
+	 */
+	status = acpi_cf_evaluate_PRT (handle, &prt);
+	switch(status) {
+	case AE_NOT_FOUND:
+		break;
+	default:
+		if (ACPI_FAILURE(status)) {
+			printk("Acpi cfg:%s _PRT fail=0x%x\n",
+				path_name, status);
+			return status;
+		}
+		dprintk(("Acpi cfg:%s bus %ld got _PRT\n", path_name, busnum));
+		acpi_cf_add_to_pci_routing_tables (busnum, prt);
+		break;
+	}
+
+
+	/*
+	 * walk down this root pci bridge to get _PRTs if any
+	 */
+	rpb.rpb_busnum = rpb.lastbusnum = busnum;
+	rpb.rpb_handle = handle;
+	status = acpi_walk_namespace ( ACPI_TYPE_DEVICE,
+					handle,
+					ACPI_UINT32_MAX,
+					acpi_cf_get_prt_callback,
+					&rpb,
+					NULL );
+	if (ACPI_FAILURE(status))
+		printk("Acpi cfg:%s walk namespace for _PRT error=0x%x\n",
+			path_name, status);
+
+	return (status);
+}
+
+
+/*
+ * handle _PRTs of immediate P2Ps of root pci. 
+ */
+static ACPI_STATUS	__init
+acpi_cf_associate_prt_to_bus (
+	ACPI_HANDLE		handle,
+	acpi_rpb_t		*rpb,
+	NATIVE_UINT		*retbusnum,
+	NATIVE_UINT		depth
+	)
+{
+	ACPI_STATUS		status;
+	UINT32			segbus;
+	NATIVE_UINT		devfn;
+	UINT8			bn;
+
+	ACPI_BUFFER		ret_buf;
+	UINT8			path_name[PATHNAME_MAX];
+
+#ifdef	CONFIG_ACPI_KERNEL_CONFIG_DEBUG
 	ret_buf.length  = PATHNAME_MAX;
-	ret_buf.pointer = (void *) buf;
+	ret_buf.pointer = (void *) path_name;
+
+	status = acpi_get_name(handle, ACPI_FULL_PATHNAME, &ret_buf);
+#else
+	memset(path_name, 0, sizeof (path_name));
+#endif
 
-	status = acpi_evaluate_object(handle, METHOD_NAME__BBN, NULL, &ret_buf);
+	/*
+	 * get devfn from _ADR
+	 */
+	status = acpi_cf_evaluate_method(handle, METHOD_NAME__ADR, &devfn);
 	if (ACPI_FAILURE(status)) {
-		if (status = AE_NOT_FOUND) {
-			printk("Acpi cfg:_BBN not found for _PRT %ld: set busnum to %ld\n", next_busnum, next_busnum);
-		} else {
-			printk("Acpi cfg:_BBN fail=0x%x for _PRT %ld: set busnum to %ld\n", status, next_busnum, next_busnum);
-		}
-		if (next_busnum)
-			printk("Acpi cfg: Warning: Invalid or unimplemented _BBNs for PRTs may cause incorrect PCI vector configuration. Check AML\n");
-		busnum = next_busnum++;
-	} else {
-		ext_obj = (ACPI_OBJECT *) ret_buf.pointer;
+		*retbusnum = rpb->rpb_busnum + 1;
+		printk("Acpi cfg:%s _ADR fail=0x%x. Set busnum to %ld\n",
+			path_name, status, *retbusnum);
+		return AE_OK;
+	}
+	dprintk(("Acpi cfg:%s _ADR =0x%x\n", path_name, (UINT32)devfn));
 
-		switch (ext_obj->type) {
-		case ACPI_TYPE_INTEGER:
-			busnum = (NATIVE_UINT) ext_obj->integer.value;
-			next_busnum = busnum + 1;
-			dprintk(("Acpi cfg:_BBN busnum is %ld\n ", busnum));
-			break;
-		default:
-			printk("Acpi cfg:_BBN object type incorrect: set busnum to %ld\n ", next_busnum);
-			printk("Acpi cfg: Warning: Invalid _BBN for PRT may cause incorrect PCI vector configuration. Check AML\n");
-			busnum = next_busnum++;
-			break;
-		}
 
-		/*
-		 * Placeholder for PCI SEG when PAL supports it,
-		 * status = acpi_evaluate_object(handle, "_SEG", NULL, &ret_buf);
-		 */
+	/*
+	 * access pci config space for bus number
+	 *	segbus = from rpb, devfn = from _ADR
+	 */
+	segbus = (UINT32)(rpb->rpb_busnum & 0xFFFFFFFF);
+
+	status = acpi_os_read_pci_cfg_byte(segbus,
+				(UINT32)devfn, PCI_PRIMARY_BUS, &bn);
+	if (ACPI_FAILURE(status)) {
+		*retbusnum = rpb->rpb_busnum + 1;
+		printk("Acpi cfg:%s pci read fail=0x%x. b:df:a=%x:%x:%x\n",
+			path_name, status, segbus, (UINT32)devfn,
+			PCI_PRIMARY_BUS);
+		printk("Acpi cfg:%s Set busnum to %ld\n",
+			path_name, *retbusnum);
+		return AE_OK;
 	}
+	dprintk(("Acpi cfg:%s pribus %d\n", path_name, bn));
 
 
-	ret_buf.length  = PATHNAME_MAX;
-	ret_buf.pointer = (void *) buf;
+	status = acpi_os_read_pci_cfg_byte(segbus,
+				(UINT32)devfn, PCI_SECONDARY_BUS, &bn);
+	if (ACPI_FAILURE(status)) {
+		*retbusnum = rpb->rpb_busnum + 1;
+		printk("Acpi cfg:%s pci read fail=0x%x. b:df:a=%x:%x:%x\n",
+			path_name, status, segbus, (UINT32)devfn,
+			PCI_SECONDARY_BUS);
+		printk("Acpi cfg:%s Set busnum to %ld\n",
+			path_name, *retbusnum);
+		return AE_OK;
+	}
+	dprintk(("Acpi cfg:%s busnum %d\n", path_name, bn));
+
+	*retbusnum = (NATIVE_UINT)bn;
+	return AE_OK;
+}
+
+
+static ACPI_STATUS	__init
+acpi_cf_get_prt (
+	void		**prts
+	)
+{
+	ACPI_STATUS	status;
+
+	status = acpi_get_devices ( PCI_ROOT_HID_STRING,
+				acpi_cf_get_root_pci_callback,
+				NULL,
+				NULL );
 
-	status = acpi_evaluate_object(handle, METHOD_NAME__STA, NULL, &ret_buf);
 	if (ACPI_FAILURE(status)) {
-		if (status = AE_NOT_FOUND)
-			dprintk(("Acpi cfg:no _STA: pci bus %ld exist\n", busnum));
-		else
-			printk("Acpi cfg:_STA fail=0x%x: pci bus %ld exist. Check AML\n", status, busnum);
-	} else {
-		ext_obj = (ACPI_OBJECT *) ret_buf.pointer;
+		printk("Acpi cfg:get_device PCI ROOT HID error=0x%x\n", status);
+	}
 
-		switch (ext_obj->type) {
-		case ACPI_TYPE_INTEGER:
-			if((NATIVE_UINT) ext_obj->integer.value & ACPI_STA_DEVICE_PRESENT) {
-				dprintk(("Acpi cfg:_STA: pci bus %ld exist\n", busnum));
-			} else {
-				printk("Acpi cfg:_STA: pci bus %ld not exist. Discarding the _PRT\n", busnum);
-				next_busnum--;
-				acpi_os_free(prt);
-				return AE_OK;
-			}
-			break;
-		default:
-			printk("Acpi cfg:_STA object type incorrect: pci bus %ld exist. Check AML\n", busnum);
-			break;
+	*prts = (void *)pci_routing_tables;
+
+	return status;
+}
+
+static ACPI_STATUS	__init
+acpi_cf_get_prt_callback (
+	ACPI_HANDLE		handle,
+	UINT32			Level,
+	void			*context,
+	void			**retval
+	)
+{
+	PCI_ROUTING_TABLE	*prt;
+	NATIVE_UINT		busnum = 0;
+	NATIVE_UINT		temp = 0x0F;
+	ACPI_STATUS		status;
+
+	ACPI_BUFFER		ret_buf;
+	UINT8			path_name[PATHNAME_MAX];
+
+#ifdef	CONFIG_ACPI_KERNEL_CONFIG_DEBUG
+	ret_buf.length  = PATHNAME_MAX;
+	ret_buf.pointer = (void *) path_name;
+
+	status = acpi_get_name(handle, ACPI_FULL_PATHNAME, &ret_buf);
+#else
+	memset(path_name, 0, sizeof (path_name));
+#endif
+
+	status = acpi_cf_evaluate_PRT (handle, &prt);
+	switch(status) {
+	case AE_NOT_FOUND:
+		return AE_OK;
+	default:
+		if (ACPI_FAILURE(status)) {
+			printk("Acpi cfg:%s _PRT fail=0x%x\n",
+				path_name, status);
+			return status;
 		}
 	}
 
+	/*
+	 * evaluate _STA in case this device does not exist
+	 */
+	status = acpi_cf_evaluate_method(handle, METHOD_NAME__STA, &temp);
+	switch(status) {
+	case AE_NOT_FOUND:
+		break;
+	default:
+		if (ACPI_FAILURE(status)) {
+			printk("Acpi cfg:%s _STA fail=0x%x\n",
+				path_name, status);
+			return status;
+		}
+		if (!(temp & ACPI_STA_DEVICE_PRESENT)) {
+			dprintk(("Acpi cfg:%s not exist. _PRT discarded\n",
+				path_name));
+			acpi_os_free(prt);
+			return AE_OK;
+		}
+		break;
+	}
 
+	/*
+	 * associate a bus number to this _PRT since 
+	 * this _PRT is not on root pci bridge 
+	 */
+	acpi_cf_associate_prt_to_bus(handle, context, &busnum, 0);
+
+	printk("Acpi cfg:%s busnum %ld got _PRT\n", path_name, busnum);
 	acpi_cf_add_to_pci_routing_tables (busnum, prt);
 
 	return AE_OK;
@@ -304,7 +496,6 @@
 	if (pci_routing_tables[busnum]) {
 		printk("Acpi cfg:duplicate PRT for pci bus %ld. overiding...\n", busnum);
 		acpi_os_free(pci_routing_tables[busnum]);
-		/* override... */
 	}
 
 	pci_routing_tables[busnum] = prt;
@@ -333,15 +524,14 @@
 		if (prt) {
 			for ( ; prt->length > 0; nvec++) {
 				prt = (PCI_ROUTING_TABLE *) ((NATIVE_UINT)prt + (NATIVE_UINT)prt->length);
-				//prt = ROUND_PTR_UP_TO_4(prt, PCI_ROUTING_TABLE);
 			}
 		}
 	}
 
 	*num_pci_vectors = nvec;
 	*vectors = acpi_os_callocate (sizeof(struct pci_vector_struct) * nvec);
-	if (*vectors = NULL) {
-		printk("Acpi cfg:callocate error\n");
+	if (!*vectors) {
+		printk("Acpi cfg: callocate for pci_vector error\n");
 		return AE_NO_MEMORY;
 	}
 
@@ -358,13 +548,10 @@
 				pvec->irq	= (UINT8)prt->source_index;
 
 				prt = (PCI_ROUTING_TABLE *) ((NATIVE_UINT)prt + (NATIVE_UINT)prt->length);
-				//prt = ROUND_PTR_UP_TO_4(prt, PCI_ROUTING_TABLE);
 			}
 			acpi_os_free((void *)prtf);
 		}
 	}
-
-	vectors_to_free = *vectors;
 
 	return AE_OK;
 }
diff -urN linux-davidm/include/asm-ia64/bitops.h linux-2.4.5-lia/include/asm-ia64/bitops.h
--- linux-davidm/include/asm-ia64/bitops.h	Sun Apr 29 15:50:41 2001
+++ linux-2.4.5-lia/include/asm-ia64/bitops.h	Wed May 30 23:29:37 2001
@@ -2,8 +2,8 @@
 #define _ASM_IA64_BITOPS_H
 
 /*
- * Copyright (C) 1998-2000 Hewlett-Packard Co
- * Copyright (C) 1998-2000 David Mosberger-Tang <davidm@hpl.hp.com>
+ * Copyright (C) 1998-2001 Hewlett-Packard Co
+ * Copyright (C) 1998-2001 David Mosberger-Tang <davidm@hpl.hp.com>
  *
  * 02/04/00 D. Mosberger  Require 64-bit alignment for bitops, per suggestion from davem
  */
@@ -11,11 +11,10 @@
 #include <asm/system.h>
 
 /*
- * These operations need to be atomic.  The address must be (at least)
- * 32-bit aligned.  Note that there are driver (e.g., eepro100) which
- * use these operations to operate on hw-defined data-structures, so
- * we can't easily change these operations to force a bigger
- * alignment.
+ * These operations need to be atomic.  The address must be (at least) "long" aligned.
+ * Note that there are driver (e.g., eepro100) which use these operations to operate on
+ * hw-defined data-structures, so we can't easily change these operations to force a
+ * bigger alignment.
  *
  * bit 0 is the LSB of addr; bit 32 is the LSB of (addr+1).
  */
@@ -57,6 +56,18 @@
 	} while (cmpxchg_acq(m, old, new) != old);
 }
 
+/*
+ * WARNING: non atomic version.
+ */
+static __inline__ void
+__change_bit (int nr, void *addr)
+{
+	volatile __u32 *m = (__u32 *) addr + (nr >> 5);
+	__u32 bit = (1 << (nr & 31));
+
+	*m = *m ^ bit;
+}
+
 static __inline__ void
 change_bit (int nr, volatile void *addr)
 {
@@ -107,6 +118,20 @@
 	return (old & ~mask) != 0;
 }
 
+/*
+ * WARNING: non atomic version.
+ */
+static __inline__ int
+__test_and_change_bit (int nr, void *addr)
+{
+	__u32 old, bit = (1 << (nr & 31));
+	__u32 *m = (__u32 *) addr + (nr >> 5);
+
+	old = *m;
+	*m = old ^ bit;
+	return (old & bit) != 0;
+}
+
 static __inline__ int
 test_and_change_bit (int nr, volatile void *addr)
 {
@@ -131,8 +156,9 @@
 }
 
 /*
- * ffz = Find First Zero in word. Undefined if no zero exists,
- * so code should check against ~0UL first..
+ * ffz = "find first zero".  Returns the bit number (0..63) of the first (least
+ * significant) bit that is zero in X.  Undefined if no zero exists, so code should check
+ * against ~0UL first...
  */
 static inline unsigned long
 ffz (unsigned long x)
@@ -160,9 +186,10 @@
 }
 
 /*
- * ffs: find first bit set. This is defined the same way as
- * the libc and compiler builtin ffs routines, therefore
- * differs in spirit from the above ffz (man ffs).
+ * ffs: find first bit set. This is defined the same way as the libc and compiler builtin
+ * ffs routines, therefore differs in spirit from the above ffz (man ffs): it operates on
+ * "int" values only and the result value is the bit number + 1.  ffs(0) is defined to
+ * return zero.
  */
 #define ffs(x)	__builtin_ffs(x)
 
diff -urN linux-davidm/include/asm-ia64/mca_asm.h linux-2.4.5-lia/include/asm-ia64/mca_asm.h
--- linux-davidm/include/asm-ia64/mca_asm.h	Sun Apr 29 15:50:41 2001
+++ linux-2.4.5-lia/include/asm-ia64/mca_asm.h	Wed May 30 22:56:29 2001
@@ -1,5 +1,5 @@
 /*
- * File: 	mca_asm.h
+ * File:	mca_asm.h
  *
  * Copyright (C) 1999 Silicon Graphics, Inc.
  * Copyright (C) Vijay Chander (vijay@engr.sgi.com)
@@ -16,23 +16,23 @@
 #define PSR_RT		27
 #define PSR_IT		36
 #define PSR_BN		44
-	
+
 /*
  * This macro converts a instruction virtual address to a physical address
  * Right now for simulation purposes the virtual addresses are
  * direct mapped to physical addresses.
- * 	1. Lop off bits 61 thru 63 in the virtual address
+ *	1. Lop off bits 61 thru 63 in the virtual address
  */
 #define INST_VA_TO_PA(addr)							\
-	dep 	addr	= 0, addr, 61, 3;
+	dep	addr	= 0, addr, 61, 3;
 /*
  * This macro converts a data virtual address to a physical address
  * Right now for simulation purposes the virtual addresses are
  * direct mapped to physical addresses.
- * 	1. Lop off bits 61 thru 63 in the virtual address
+ *	1. Lop off bits 61 thru 63 in the virtual address
  */
 #define DATA_VA_TO_PA(addr)							\
-	dep 	addr	= 0, addr, 61, 3;
+	dep	addr	= 0, addr, 61, 3;
 /*
  * This macro converts a data physical address to a virtual address
  * Right now for simulation purposes the virtual addresses are
@@ -40,7 +40,7 @@
  *	1. Put 0x7 in bits 61 thru 63.
  */
 #define DATA_PA_TO_VA(addr,temp)							\
-	mov	temp	= 0x7	;							\
+	mov	temp	= 0x7	;;							\
 	dep	addr	= temp, addr, 61, 3;
 
 /*
@@ -48,11 +48,11 @@
  * and starts execution in physical mode with all the address
  * translations turned off.
  *	1.	Save the current psr
- *	2. 	Make sure that all the upper 32 bits are off
+ *	2.	Make sure that all the upper 32 bits are off
  *
  *	3.	Clear the interrupt enable and interrupt state collection bits
  *		in the psr before updating the ipsr and iip.
- *	
+ *
  *	4.	Turn off the instruction, data and rse translation bits of the psr
  *		and store the new value into ipsr
  *		Also make sure that the interrupts are disabled.
@@ -71,7 +71,7 @@
 	mov	old_psr = psr;								\
 	;;										\
 	dep	old_psr = 0, old_psr, 32, 32;						\
-	                                                                                \
+											\
 	mov	ar.rsc = 0 ;								\
 	;;										\
 	mov	temp2 = ar.bspstore;							\
@@ -86,7 +86,7 @@
 	mov	temp1 = psr;								\
 	mov	temp2 = psr;								\
 	;;										\
-	                                                                                \
+											\
 	dep	temp2 = 0, temp2, PSR_IC, 2;						\
 	;;										\
 	mov	psr.l = temp2;								\
@@ -94,11 +94,11 @@
 	srlz.d;										\
 	dep	temp1 = 0, temp1, 32, 32;						\
 	;;										\
- 	dep	temp1 = 0, temp1, PSR_IT, 1;						\
+	dep	temp1 = 0, temp1, PSR_IT, 1;						\
 	;;										\
- 	dep	temp1 = 0, temp1, PSR_DT, 1;						\
+	dep	temp1 = 0, temp1, PSR_DT, 1;						\
 	;;										\
- 	dep	temp1 = 0, temp1, PSR_RT, 1;						\
+	dep	temp1 = 0, temp1, PSR_RT, 1;						\
 	;;										\
 	dep	temp1 = 0, temp1, PSR_I, 1;						\
 	;;										\
@@ -125,72 +125,73 @@
  * This macro jumps to the instruction at the given virtual address
  * and starts execution in virtual mode with all the address
  * translations turned on.
- *	1. 	Get the old saved psr
- *	
- *	2. 	Clear the interrupt enable and interrupt state collection bits
+ *	1.	Get the old saved psr
+ *
+ *	2.	Clear the interrupt enable and interrupt state collection bits
  *		in the current psr.
- *	
+ *
  *	3.	Set the instruction translation bit back in the old psr
  *		Note we have to do this since we are right now saving only the
  *		lower 32-bits of old psr.(Also the old psr has the data and
  *		rse translation bits on)
- *	
+ *
  *	4.	Set ipsr to this old_psr with "it" bit set and "bn" = 1.
  *
- *	5. 	Set iip to the virtual address of the next instruction bundle.
+ *	5.	Set iip to the virtual address of the next instruction bundle.
  *
  *	6.	Do an rfi to move ipsr to psr and iip to ip.
  */
 
-#define VIRTUAL_MODE_ENTER(temp1, temp2, start_addr, old_psr)				\
-	mov	temp2 = psr;								\
-	;;										\
-	dep	temp2 = 0, temp2, PSR_IC, 2;						\
-	;;										\
-	mov	psr.l = temp2;								\
-	mov	ar.rsc = 0;								\
-	;;										\
-	srlz.d;										\
-	mov	temp2 = ar.bspstore;							\
-	;;										\
-	DATA_PA_TO_VA(temp2,temp1);							\
-	;;										\
-	mov	temp1 = ar.rnat;							\
-	;;										\
-	mov	ar.bspstore = temp2;							\
-	;;										\
-	mov	ar.rnat = temp1;							\
-	;;										\
-	mov	temp1 = old_psr;							\
-	;;										\
-	mov	temp2 = 1	;							\
-	dep	temp1 = temp2, temp1, PSR_I,  1;					\
-	;;										\
- 	dep	temp1 = temp2, temp1, PSR_IC, 1;					\
-	;;										\
-	dep	temp1 = temp2, temp1, PSR_IT, 1;					\
-	;;										\
- 	dep	temp1 = temp2, temp1, PSR_DT, 1;					\
-	;;										\
- 	dep	temp1 = temp2, temp1, PSR_RT, 1;					\
-	;;										\
-	dep	temp1 = temp2, temp1, PSR_BN, 1;					\
-	;;										\
-	                                                                                \
-	mov     cr.ipsr = temp1;							\
-	movl	temp2 = start_addr;							\
-	;;										\
-	mov	cr.iip = temp2;								\
-	DATA_PA_TO_VA(sp, temp1);							\
-	DATA_PA_TO_VA(gp, temp2);							\
-	;;										\
-	nop	1;									\
-	nop	2;									\
-	nop	1;									\
-	rfi;										\
+#define VIRTUAL_MODE_ENTER(temp1, temp2, start_addr, old_psr)	\
+	mov	temp2 = psr;					\
+	;;							\
+	dep	temp2 = 0, temp2, PSR_IC, 2;			\
+	;;							\
+	mov	psr.l = temp2;					\
+	mov	ar.rsc = 0;					\
+	;;							\
+	srlz.d;							\
+	mov	temp2 = ar.bspstore;				\
+	;;							\
+	DATA_PA_TO_VA(temp2,temp1);				\
+	;;							\
+	mov	temp1 = ar.rnat;				\
+	;;							\
+	mov	ar.bspstore = temp2;				\
+	;;							\
+	mov	ar.rnat = temp1;				\
+	;;							\
+	mov	temp1 = old_psr;				\
+	;;							\
+	mov	temp2 = 1					\
+	;;							\
+	dep	temp1 = temp2, temp1, PSR_I,  1;		\
+	;;							\
+	dep	temp1 = temp2, temp1, PSR_IC, 1;		\
+	;;							\
+	dep	temp1 = temp2, temp1, PSR_IT, 1;		\
+	;;							\
+	dep	temp1 = temp2, temp1, PSR_DT, 1;		\
+	;;							\
+	dep	temp1 = temp2, temp1, PSR_RT, 1;		\
+	;;							\
+	dep	temp1 = temp2, temp1, PSR_BN, 1;		\
+	;;							\
+								\
+	mov     cr.ipsr = temp1;				\
+	movl	temp2 = start_addr;				\
+	;;							\
+	mov	cr.iip = temp2;					\
+	DATA_PA_TO_VA(sp, temp1);				\
+	DATA_PA_TO_VA(gp, temp2);				\
+	;;							\
+	nop	1;						\
+	nop	2;						\
+	nop	1;						\
+	rfi;							\
 	;;
 
-/* 
+/*
  * The following offsets capture the order in which the
  * RSE related registers from the old context are
  * saved onto the new stack frame.
@@ -198,15 +199,15 @@
  *	+-----------------------+
  *	|NDIRTY [BSP - BSPSTORE]|
  *	+-----------------------+
- *	| 	RNAT	      	|
+ *	|	RNAT		|
  *	+-----------------------+
- *	| 	BSPSTORE      	|
+ *	|	BSPSTORE	|
  *	+-----------------------+
- *	| 	IFS	      	|
+ *	|	IFS		|
  *	+-----------------------+
- *	| 	PFS	      	|
+ *	|	PFS		|
  *	+-----------------------+
- *	| 	RSC	      	|
+ *	|	RSC		|
  *	+-----------------------+ <-------- Bottom of new stack frame
  */
 #define  rse_rsc_offset		0
@@ -229,23 +230,23 @@
  *	8. Read and save the new BSP to calculate the #dirty registers
  * NOTE: Look at pages 11-10, 11-11 in PRM Vol 2
  */
-#define rse_switch_context(temp,p_stackframe,p_bspstore) 			\
-        ;; 									\
-        mov     temp=ar.rsc;; 							\
-        st8     [p_stackframe]=temp,8;; 					\
-        mov     temp=ar.pfs;; 							\
-        st8     [p_stackframe]=temp,8; 						\
-        cover ;;								\
-        mov     temp=cr.ifs;; 							\
-        st8     [p_stackframe]=temp,8;;	 					\
-        mov     temp=ar.bspstore;; 						\
-        st8     [p_stackframe]=temp,8;; 					\
-        mov     temp=ar.rnat;; 							\
-        st8     [p_stackframe]=temp,8; 						\
-        mov     ar.bspstore=p_bspstore;; 					\
-        mov     temp=ar.bsp;; 							\
-        sub     temp=temp,p_bspstore;;						\
-        st8     [p_stackframe]=temp,8
+#define rse_switch_context(temp,p_stackframe,p_bspstore)			\
+	;;									\
+	mov     temp=ar.rsc;;							\
+	st8     [p_stackframe]=temp,8;;					\
+	mov     temp=ar.pfs;;							\
+	st8     [p_stackframe]=temp,8;						\
+	cover ;;								\
+	mov     temp=cr.ifs;;							\
+	st8     [p_stackframe]=temp,8;;						\
+	mov     temp=ar.bspstore;;						\
+	st8     [p_stackframe]=temp,8;;					\
+	mov     temp=ar.rnat;;							\
+	st8     [p_stackframe]=temp,8;						\
+	mov     ar.bspstore=p_bspstore;;					\
+	mov     temp=ar.bsp;;							\
+	sub     temp=temp,p_bspstore;;						\
+	st8     [p_stackframe]=temp,8
 
 /*
  * rse_return_context
@@ -253,7 +254,7 @@
  *	2. Store the number of dirty registers RSC.loadrs field
  *	3. Issue a loadrs to insure that any registers from the interrupted
  *	   context which were saved on the new stack frame have been loaded
- * 	   back into the stacked registers
+ *	   back into the stacked registers
  *	4. Restore BSPSTORE
  *	5. Restore RNAT
  *	6. Restore PFS
@@ -261,44 +262,44 @@
  *	8. Restore RSC
  *	9. Issue an RFI
  */
-#define rse_return_context(psr_mask_reg,temp,p_stackframe) 			\
-        ;; 									\
-        alloc   temp=ar.pfs,0,0,0,0;						\
-        add     p_stackframe=rse_ndirty_offset,p_stackframe;;			\
-        ld8     temp=[p_stackframe];; 						\
-        shl     temp=temp,16;;							\
-        mov     ar.rsc=temp;; 							\
-        loadrs;;								\
-        add     p_stackframe=-rse_ndirty_offset+rse_bspstore_offset,p_stackframe;;\
-        ld8     temp=[p_stackframe];; 						\
-        mov     ar.bspstore=temp;; 						\
-        add     p_stackframe=-rse_bspstore_offset+rse_rnat_offset,p_stackframe;;\
-        ld8     temp=[p_stackframe];; 						\
-        mov     ar.rnat=temp;;							\
-        add     p_stackframe=-rse_rnat_offset+rse_pfs_offset,p_stackframe;;	\
-        ld8     temp=[p_stackframe];; 						\
-        mov     ar.pfs=temp;							\
-        add     p_stackframe=-rse_pfs_offset+rse_ifs_offset,p_stackframe;;	\
-        ld8     temp=[p_stackframe];; 						\
-        mov     cr.ifs=temp;							\
-        add     p_stackframe=-rse_ifs_offset+rse_rsc_offset,p_stackframe;;	\
-        ld8     temp=[p_stackframe];; 						\
-        mov     ar.rsc=temp ;							\
-        add     p_stackframe=-rse_rsc_offset,p_stackframe;			\
-        mov     temp=cr.ipsr;;							\
-        st8     [p_stackframe]=temp,8;						\
-        mov     temp=cr.iip;;							\
-        st8     [p_stackframe]=temp,-8;						\
-        mov     temp=psr;;							\
-        or      temp=temp,psr_mask_reg;;					\
-        mov     cr.ipsr=temp;;							\
-        mov     temp=ip;;							\
-        add     temp=0x30,temp;;						\
-        mov     cr.iip=temp;;							\
-        rfi;;									\
-        ld8     temp=[p_stackframe],8;;						\
-        mov     cr.ipsr=temp;;							\
-        ld8     temp=[p_stackframe];;						\
-        mov     cr.iip=temp
+#define rse_return_context(psr_mask_reg,temp,p_stackframe)			\
+	;;									\
+	alloc   temp=ar.pfs,0,0,0,0;						\
+	add     p_stackframe=rse_ndirty_offset,p_stackframe;;			\
+	ld8     temp=[p_stackframe];;						\
+	shl     temp=temp,16;;							\
+	mov     ar.rsc=temp;;							\
+	loadrs;;								\
+	add     p_stackframe=-rse_ndirty_offset+rse_bspstore_offset,p_stackframe;;\
+	ld8     temp=[p_stackframe];;						\
+	mov     ar.bspstore=temp;;						\
+	add     p_stackframe=-rse_bspstore_offset+rse_rnat_offset,p_stackframe;;\
+	ld8     temp=[p_stackframe];;						\
+	mov     ar.rnat=temp;;							\
+	add     p_stackframe=-rse_rnat_offset+rse_pfs_offset,p_stackframe;;	\
+	ld8     temp=[p_stackframe];;						\
+	mov     ar.pfs=temp;							\
+	add     p_stackframe=-rse_pfs_offset+rse_ifs_offset,p_stackframe;;	\
+	ld8     temp=[p_stackframe];;						\
+	mov     cr.ifs=temp;							\
+	add     p_stackframe=-rse_ifs_offset+rse_rsc_offset,p_stackframe;;	\
+	ld8     temp=[p_stackframe];;						\
+	mov     ar.rsc=temp ;							\
+	add     p_stackframe=-rse_rsc_offset,p_stackframe;			\
+	mov     temp=cr.ipsr;;							\
+	st8     [p_stackframe]=temp,8;						\
+	mov     temp=cr.iip;;							\
+	st8     [p_stackframe]=temp,-8;						\
+	mov     temp=psr;;							\
+	or      temp=temp,psr_mask_reg;;					\
+	mov     cr.ipsr=temp;;							\
+	mov     temp=ip;;							\
+	add     temp=0x30,temp;;						\
+	mov     cr.iip=temp;;							\
+	rfi;;									\
+	ld8     temp=[p_stackframe],8;;						\
+	mov     cr.ipsr=temp;;							\
+	ld8     temp=[p_stackframe];;						\
+	mov     cr.iip=temp
 
 #endif /* _ASM_IA64_MCA_ASM_H */
diff -urN linux-davidm/include/asm-ia64/processor.h linux-2.4.5-lia/include/asm-ia64/processor.h
--- linux-davidm/include/asm-ia64/processor.h	Wed May 30 23:17:53 2001
+++ linux-2.4.5-lia/include/asm-ia64/processor.h	Wed May 30 23:29:37 2001
@@ -314,20 +314,10 @@
 struct thread_struct {
 	__u64 ksp;			/* kernel stack pointer */
 	unsigned long flags;		/* various flags */
-	struct ia64_fpreg fph[96];	/* saved/loaded on demand */
-	__u64 dbr[IA64_NUM_DBG_REGS];
-	__u64 ibr[IA64_NUM_DBG_REGS];
-#ifdef CONFIG_PERFMON
-	__u64 pmc[IA64_NUM_PMC_REGS];
-	__u64 pmd[IA64_NUM_PMD_REGS];
-	unsigned long pfm_pend_notify;	/* non-zero if we need to notify and block */
-	void *pfm_context;		/* pointer to detailed PMU context */
-# define INIT_THREAD_PM		{0, }, {0, }, 0, 0,
-#else
-# define INIT_THREAD_PM
-#endif
 	__u64 map_base;			/* base address for get_unmapped_area() */
 	__u64 task_size;		/* limit for task size */
+	struct siginfo *siginfo;	/* current siginfo struct for ptrace() */
+
 #ifdef CONFIG_IA32_SUPPORT
 	__u64 eflag;			/* IA32 EFLAGS reg */
 	__u64 fsr;			/* IA32 floating pt status reg */
@@ -345,7 +335,18 @@
 #else
 # define INIT_THREAD_IA32
 #endif /* CONFIG_IA32_SUPPORT */
-	struct siginfo *siginfo;	/* current siginfo struct for ptrace() */
+#ifdef CONFIG_PERFMON
+	__u64 pmc[IA64_NUM_PMC_REGS];
+	__u64 pmd[IA64_NUM_PMD_REGS];
+	unsigned long pfm_pend_notify;	/* non-zero if we need to notify and block */
+	void *pfm_context;		/* pointer to detailed PMU context */
+# define INIT_THREAD_PM		{0, }, {0, }, 0, 0,
+#else
+# define INIT_THREAD_PM
+#endif
+	__u64 dbr[IA64_NUM_DBG_REGS];
+	__u64 ibr[IA64_NUM_DBG_REGS];
+	struct ia64_fpreg fph[96];	/* saved/loaded on demand */
 };
 
 #define INIT_MMAP {								\
@@ -356,14 +357,14 @@
 #define INIT_THREAD {					\
 	0,				/* ksp */	\
 	0,				/* flags */	\
-	{{{{0}}}, },			/* fph */	\
-	{0, },				/* dbr */	\
-	{0, },				/* ibr */	\
-	INIT_THREAD_PM					\
 	DEFAULT_MAP_BASE,		/* map_base */	\
 	DEFAULT_TASK_SIZE,		/* task_size */	\
+	0,				/* siginfo */	\
 	INIT_THREAD_IA32				\
-	0				/* siginfo */	\
+	INIT_THREAD_PM					\
+	{0, },				/* dbr */	\
+	{0, },				/* ibr */	\
+	{{{{0}}}, }			/* fph */	\
 }
 
 #define start_thread(regs,new_ip,new_sp) do {							\
diff -urN linux-davidm/include/asm-ia64/smp.h linux-2.4.5-lia/include/asm-ia64/smp.h
--- linux-davidm/include/asm-ia64/smp.h	Sun Apr 29 15:50:42 2001
+++ linux-2.4.5-lia/include/asm-ia64/smp.h	Wed May 30 23:29:37 2001
@@ -1,7 +1,7 @@
 /*
  * SMP Support
  *
- * Copyright (C) 1999 VA Linux Systems 
+ * Copyright (C) 1999 VA Linux Systems
  * Copyright (C) 1999 Walt Drummond <drummond@valinux.com>
  * Copyright (C) 2001 Hewlett-Packard Co
  * Copyright (C) 2001 David Mosberger-Tang <davidm@hpl.hp.com>
@@ -35,14 +35,13 @@
 
 extern char no_int_routing __initdata;
 
-extern unsigned long cpu_present_map;
 extern unsigned long cpu_online_map;
 extern unsigned long ipi_base_addr;
-extern int __cpu_physical_id[NR_CPUS];
 extern unsigned char smp_int_redirect;
 extern int smp_num_cpus;
 
-#define cpu_physical_id(i)	__cpu_physical_id[i]
+extern  volatile int ia64_cpu_to_sapicid[];
+#define cpu_physical_id(i)	ia64_cpu_to_sapicid[i]
 #define cpu_number_map(i)	(i)
 #define cpu_logical_map(i)	(i)
 
@@ -70,7 +69,7 @@
  *	max_xtp   : never deliver interrupts to this CPU.
  */
 
-static inline void 
+static inline void
 min_xtp (void)
 {
 	if (smp_int_redirect & SMP_IRQ_REDIRECTION)
@@ -85,13 +84,13 @@
 }
 
 static inline void
-max_xtp (void) 
+max_xtp (void)
 {
 	if (smp_int_redirect & SMP_IRQ_REDIRECTION)
 		writeb(0x0f, ipi_base_addr | XTP_OFFSET); /* Set XTP to max */
 }
 
-static inline unsigned int 
+static inline unsigned int
 hard_smp_processor_id (void)
 {
 	union {
diff -urN linux-davidm/include/asm-ia64/unaligned.h linux-2.4.5-lia/include/asm-ia64/unaligned.h
--- linux-davidm/include/asm-ia64/unaligned.h	Mon Oct  9 17:55:00 2000
+++ linux-2.4.5-lia/include/asm-ia64/unaligned.h	Wed May 30 22:58:19 2001
@@ -1,6 +1,8 @@
 #ifndef _ASM_IA64_UNALIGNED_H
 #define _ASM_IA64_UNALIGNED_H
 
+#include <linux/types.h>
+
 /*
  * The main single-value unaligned transfer routines.  Derived from
  * the Linux/Alpha version.
diff -urN linux-davidm/include/asm-ia64/unwind.h linux-2.4.5-lia/include/asm-ia64/unwind.h
--- linux-davidm/include/asm-ia64/unwind.h	Wed May 30 23:17:53 2001
+++ linux-2.4.5-lia/include/asm-ia64/unwind.h	Wed May 30 22:58:29 2001
@@ -97,7 +97,7 @@
 extern void unw_create_gate_table (void);
 
 extern void *unw_add_unwind_table (const char *name, unsigned long segment_base, unsigned long gp,
-				   void *table_start, void *table_end);
+				   const void *table_start, const void *table_end);
 
 extern void unw_remove_unwind_table (void *handle);
 
diff -urN linux-davidm/kernel/module.c linux-2.4.5-lia/kernel/module.c
--- linux-davidm/kernel/module.c	Wed May 30 09:58:18 2001
+++ linux-2.4.5-lia/kernel/module.c	Wed May 30 23:02:44 2001
@@ -246,8 +246,23 @@
 {
 	kernel_module.nsyms = __stop___ksymtab - __start___ksymtab;
 
+	/*
+	 * XXX fix me: this should be cleaned up.  Perhaps calling
+	 * module_arch_init(&kernel_module) here would be cleanest, but this would require
+	 * updating all platform specific header files.
+	 */
 #ifdef __alpha__
 	__asm__("stq $29,%0" : "=m"(kernel_module.gp));
+#endif
+#ifdef __ia64__
+	{
+		static struct archdata archdata;
+		register char *kernel_gp asm ("gp");
+
+		archdata.gp = kernel_gp;
+		kernel_module.archdata_start = (const char *) &archdata;
+		kernel_module.archdata_end   = (const char *) (&archdata + 1);
+	}
 #endif
 }
 

