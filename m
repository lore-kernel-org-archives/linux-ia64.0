From: David Mosberger <davidm@hpl.hp.com>
Date: Thu, 14 Sep 2000 01:50:33 +0000
Subject: [Linux-ia64] kernel update (relative to v2.4.0-test8)
Message-Id: <marc-linux-ia64-105590678205492@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Since the last diff had a few serious problems, including the infamous
ACPI bug and an fph problem that caused xmms not to work on UP
machine, there is now a new diff available at:

 ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/

in file linux-2.4.0-test8-ia64-000913.diff.

Summary of changes:

 - Applied Asit's ACPI fix that prevented booting on some machines
   (B1 Big Sur mostly, it seems).

 - Applied HJ's patch to rename the loops_per_sec() macro to
   ia64_loops_per_sec().  While looking at this code, I also realized
   that the SMP code still didn't do per-CPU BogoMIPS calibration, so
   I fixed that.  Now, you too can have a machine with several
   thousand BogoMIPS! ;-)

 - Applied Mike Stephen's patch to add unwind support for modules.
   This also cleans up the module interface.  It touches the include
   file of the other platforms, but the changes involved are trivial.

 - Reapplied the kernel_thread() fixed (don't know why the original
   patch from SuSE got lost; my apologies).

 - Fixed fph management for UP machines & cleaned up code some more.

This kernel is known to build and boot for the HP Ski simulator, Big
Sur, and SMP Lion.  I tested the UP kernel extensively by listening to
xmms for hours (though job, I know... ;-).

	--david

diff -urN linux-davidm/arch/ia64/kernel/efi.c lia64/arch/ia64/kernel/efi.c
--- linux-davidm/arch/ia64/kernel/efi.c	Wed Sep 13 11:41:51 2000
+++ lia64/arch/ia64/kernel/efi.c	Wed Sep 13 14:11:45 2000
@@ -279,7 +279,7 @@
 			continue;
 		}
 
-	  	printk(__FUNCTION__": CPU %d mapping PAL code [0x%lx-0x%lx) into [0x%lx-0x%lx)\n",
+	  	printk("CPU %d: mapping PAL code [0x%lx-0x%lx) into [0x%lx-0x%lx)\n",
 		       smp_processor_id(), md->phys_addr, md->phys_addr + (md->num_pages << 12),
 		       vaddr & mask, (vaddr & mask) + 256*1024*1024);
 
diff -urN linux-davidm/arch/ia64/kernel/ia64_ksyms.c lia64/arch/ia64/kernel/ia64_ksyms.c
--- linux-davidm/arch/ia64/kernel/ia64_ksyms.c	Wed Sep 13 11:41:51 2000
+++ lia64/arch/ia64/kernel/ia64_ksyms.c	Wed Sep 13 13:39:26 2000
@@ -10,6 +10,7 @@
 EXPORT_SYMBOL(memcmp);
 EXPORT_SYMBOL_NOVERS(memcpy);
 EXPORT_SYMBOL(memmove);
+EXPORT_SYMBOL(memscan);
 EXPORT_SYMBOL(strcat);
 EXPORT_SYMBOL(strchr);
 EXPORT_SYMBOL(strcmp);
@@ -29,14 +30,21 @@
 
 #include <linux/in6.h>
 #include <asm/checksum.h>
+/* not coded yet?? EXPORT_SYMBOL(csum_ipv6_magic); */
 EXPORT_SYMBOL(csum_partial_copy_nocheck);
 EXPORT_SYMBOL(csum_tcpudp_magic);
 EXPORT_SYMBOL(ip_compute_csum);
 EXPORT_SYMBOL(ip_fast_csum);
 
+#include <asm/io.h>
+EXPORT_SYMBOL(__ia64_memcpy_fromio);
+EXPORT_SYMBOL(__ia64_memcpy_toio);
+EXPORT_SYMBOL(__ia64_memset_c_io);
+
 #include <asm/irq.h>
 EXPORT_SYMBOL(enable_irq);
 EXPORT_SYMBOL(disable_irq);
+EXPORT_SYMBOL(disable_irq_nosync);
 
 #include <asm/page.h>
 EXPORT_SYMBOL(clear_page);
@@ -53,18 +61,27 @@
 EXPORT_SYMBOL(cpu_data);
 EXPORT_SYMBOL(kernel_thread);
 
+#include <asm/system.h>
+#ifdef CONFIG_IA64_DEBUG_IRQ
+EXPORT_SYMBOL(last_cli_ip);
+#endif
+
 #ifdef CONFIG_SMP
+
+#include <asm/current.h>
 #include <asm/hardirq.h>
 EXPORT_SYMBOL(synchronize_irq);
 
 #include <asm/smp.h>
 EXPORT_SYMBOL(smp_call_function);
+
+#include <linux/smp.h>
 EXPORT_SYMBOL(smp_num_cpus);
 
 #include <asm/smplock.h>
 EXPORT_SYMBOL(kernel_flag);
 
-#include <asm/system.h>
+/* #include <asm/system.h> */
 EXPORT_SYMBOL(__global_sti);
 EXPORT_SYMBOL(__global_cli);
 EXPORT_SYMBOL(__global_save_flags);
@@ -74,6 +91,7 @@
 
 #include <asm/uaccess.h>
 EXPORT_SYMBOL(__copy_user);
+EXPORT_SYMBOL(__do_clear_user);
 
 #include <asm/unistd.h>
 EXPORT_SYMBOL(__ia64_syscall);
@@ -88,3 +106,4 @@
 EXPORT_SYMBOL_NOVERS(__udivdi3);
 EXPORT_SYMBOL_NOVERS(__moddi3);
 EXPORT_SYMBOL_NOVERS(__umoddi3);
+
diff -urN linux-davidm/arch/ia64/kernel/process.c lia64/arch/ia64/kernel/process.c
--- linux-davidm/arch/ia64/kernel/process.c	Wed Sep 13 11:41:51 2000
+++ lia64/arch/ia64/kernel/process.c	Wed Sep 13 13:39:42 2000
@@ -495,14 +495,14 @@
 kernel_thread (int (*fn)(void *), void *arg, unsigned long flags)
 {
 	struct task_struct *parent = current;
-	int result;
+	int result, tid;
 
-	clone(flags | CLONE_VM, 0);
+	tid = clone(flags | CLONE_VM, 0);
 	if (parent != current) {
 		result = (*fn)(arg);
 		_exit(result);
 	}
-	return 0;		/* parent: just return */
+	return tid;
 }
 
 /*
diff -urN linux-davidm/arch/ia64/kernel/ptrace.c lia64/arch/ia64/kernel/ptrace.c
--- linux-davidm/arch/ia64/kernel/ptrace.c	Wed Sep 13 11:41:51 2000
+++ lia64/arch/ia64/kernel/ptrace.c	Wed Sep 13 18:36:17 2000
@@ -543,32 +543,49 @@
 	child->thread.flags |= IA64_THREAD_KRBS_SYNCED;
 }
 
-void
-ia64_flush_fph (struct task_struct *child)
+/*
+ * Write f32-f127 back to task->thread.fph if it has been modified.
+ */
+inline void
+ia64_flush_fph (struct task_struct *task)
 {
-	struct ia64_psr *psr = ia64_psr(ia64_task_regs(child));
+	struct ia64_psr *psr = ia64_psr(ia64_task_regs(task));
+#ifdef CONFIG_SMP
+	struct task_struct *fpu_owner = current;
+#else
+	struct task_struct *fpu_owner = ia64_get_fpu_owner();
+#endif
 
-	if (psr->mfh) {
+	if (task = fpu_owner && psr->mfh) {
 		psr->mfh = 0;
-#ifndef CONFIG_SMP
-		ia64_set_fpu_owner(0);
-#endif
-		ia64_save_fpu(&child->thread.fph[0]);
-		child->thread.flags |= IA64_THREAD_FPH_VALID;
+		ia64_save_fpu(&task->thread.fph[0]);
+		task->thread.flags |= IA64_THREAD_FPH_VALID;
 	}
 }
 
 /*
- * Ensure the state in child->thread.fph is up-to-date.
+ * Sync the fph state of the task so that it can be manipulated
+ * through thread.fph.  If necessary, f32-f127 are written back to
+ * thread.fph or, if the fph state hasn't been used before, thread.fph
+ * is cleared to zeroes.  Also, access to f32-f127 is disabled to
+ * ensure that the task picks up the state from thread.fph when it
+ * executes again.
  */
 void
-ia64_sync_fph (struct task_struct *child)
+ia64_sync_fph (struct task_struct *task)
 {
-	ia64_flush_fph(child);
-	if (!(child->thread.flags & IA64_THREAD_FPH_VALID)) {
-		memset(&child->thread.fph, 0, sizeof(child->thread.fph));
-		child->thread.flags |= IA64_THREAD_FPH_VALID;
+	struct ia64_psr *psr = ia64_psr(ia64_task_regs(task));
+
+	ia64_flush_fph(task);
+	if (!(task->thread.flags & IA64_THREAD_FPH_VALID)) {
+		task->thread.flags |= IA64_THREAD_FPH_VALID;
+		memset(&task->thread.fph, 0, sizeof(task->thread.fph));
 	}
+#ifndef CONFIG_SMP
+	if (ia64_get_fpu_owner() = task)
+		ia64_set_fpu_owner(0);
+#endif
+	psr->dfh = 1;
 }
 
 #ifdef CONFIG_IA64_NEW_UNWIND
@@ -611,7 +628,10 @@
 
 	if (addr < PT_F127 + 16) {
 		/* accessing fph */
-		ia64_sync_fph(child);
+		if (write_access)
+			ia64_sync_fph(child);
+		else
+			ia64_flush_fph(child);
 		ptr = (unsigned long *) ((unsigned long) &child->thread.fph + addr);
 	} else if (addr >= PT_F10 && addr < PT_F15 + 16) {
 		/* scratch registers untouched by kernel (saved in switch_stack) */
@@ -808,7 +828,7 @@
 static int
 access_uarea (struct task_struct *child, unsigned long addr, unsigned long *data, int write_access)
 {
-	unsigned long *ptr, *rbs, *bspstore, ndirty, regnum;
+	unsigned long *ptr = NULL, *rbs, *bspstore, ndirty, regnum;
 	struct switch_stack *sw;
 	struct pt_regs *pt;
 
@@ -817,7 +837,10 @@
 
 	if (addr < PT_F127+16) {
 		/* accessing fph */
-		ia64_sync_fph(child);
+		if (write_access)
+			ia64_sync_fph(child);
+		else
+			ia64_flush_fph(child);
 		ptr = (unsigned long *) ((unsigned long) &child->thread.fph + addr);
 	} else if (addr < PT_F9+16) {
 		/* accessing switch_stack or pt_regs: */
diff -urN linux-davidm/arch/ia64/kernel/setup.c lia64/arch/ia64/kernel/setup.c
--- linux-davidm/arch/ia64/kernel/setup.c	Wed Sep 13 11:41:51 2000
+++ lia64/arch/ia64/kernel/setup.c	Wed Sep 13 13:40:08 2000
@@ -320,7 +320,7 @@
 			     features,
 			     c->ppn, c->number, c->proc_freq / 1000000, c->proc_freq % 1000000,
 			     c->itc_freq / 1000000, c->itc_freq % 1000000,
-			     loops_per_sec() / 500000, (loops_per_sec() / 5000) % 100);
+			     ia64_loops_per_sec() / 500000, (ia64_loops_per_sec() / 5000) % 100);
         }
 	return p - buffer;
 }
@@ -382,8 +382,8 @@
 #endif
 		phys_addr_size = vm1.pal_vm_info_1_s.phys_add_size;
 	}
-	printk("processor implements %lu virtual and %lu physical address bits\n",
-	       impl_va_msb + 1, phys_addr_size);
+	printk("CPU %d: %lu virtual and %lu physical address bits\n",
+	       smp_processor_id(), impl_va_msb + 1, phys_addr_size);
 	c->unimpl_va_mask = ~((7L<<61) | ((1L << (impl_va_msb + 1)) - 1));
 	c->unimpl_pa_mask = ~((1L<<63) | ((1L << phys_addr_size) - 1));
 
diff -urN linux-davidm/arch/ia64/kernel/signal.c lia64/arch/ia64/kernel/signal.c
--- linux-davidm/arch/ia64/kernel/signal.c	Wed Sep 13 11:41:51 2000
+++ lia64/arch/ia64/kernel/signal.c	Wed Sep 13 13:40:38 2000
@@ -147,12 +147,14 @@
 	ia64_put_nat_bits(&scr->pt, &scr->sw, nat);	/* restore the original scratch NaT bits */
 #endif
 
-	if ((flags & IA64_SC_FLAG_FPH_VALID)) {
-		struct ia64_psr *psr = ia64_psr(ia64_task_regs(current));
+	if ((flags & IA64_SC_FLAG_FPH_VALID) != 0) {
+		struct ia64_psr *psr = ia64_psr(&scr->pt);
 
 		__copy_from_user(current->thread.fph, &sc->sc_fr[32], 96*16);
-		if (!psr->dfh)
+		if (!psr->dfh) {
+			psr->mfh = 0;
 			__ia64_load_fpu(current->thread.fph);
+		}
 	}
 	return err;
 }
diff -urN linux-davidm/arch/ia64/kernel/smp.c lia64/arch/ia64/kernel/smp.c
--- linux-davidm/arch/ia64/kernel/smp.c	Wed Sep 13 11:41:51 2000
+++ lia64/arch/ia64/kernel/smp.c	Wed Sep 13 13:41:24 2000
@@ -6,6 +6,7 @@
  * 
  * Lots of stuff stolen from arch/alpha/kernel/smp.c
  *
+ *  00/09/11 David Mosberger <davidm@hpl.hp.com> Do loops_per_sec calibration on each CPU.
  *  00/08/23 Asit Mallick <asit.k.mallick@intel.com> fixed logical processor id
  *  00/03/31 Rohit Seth <rohit.seth@intel.com>	Fixes for Bootstrap Processor & cpu_online_map
  *			now gets done here (instead of setup.c)
@@ -41,6 +42,7 @@
 #include <asm/system.h>
 #include <asm/unistd.h>
 
+extern void __init calibrate_delay(void);
 extern int cpu_idle(void * unused);
 extern void _start(void);
 extern void machine_halt(void);
@@ -58,9 +60,13 @@
 unsigned char smp_int_redirect;			/* are INT and IPI redirectable by the chipset? */
 volatile int __cpu_physical_id[NR_CPUS] = { -1, };    /* Logical ID -> SAPIC ID */
 int smp_num_cpus = 1;		
-int smp_threads_ready = 0;			     /* Set when the idlers are all forked */
-cycles_t cacheflush_time = 0;
+volatile int smp_threads_ready;			     /* Set when the idlers are all forked */
+cycles_t cacheflush_time;
 unsigned long ap_wakeup_vector = -1;		     /* External Int to use to wakeup AP's */
+
+static volatile unsigned long cpu_callin_map;
+static volatile int smp_commenced;
+
 static int max_cpus = -1;			     /* Command line */
 static unsigned long ipi_op[NR_CPUS];
 struct smp_call_struct {
@@ -335,7 +341,7 @@
 smp_call_function_single (int cpuid, void (*func) (void *info), void *info, int retry, int wait)
 {
 	struct smp_call_struct data;
-	long timeout;
+	unsigned long timeout;
 	int cpus = 1;
 
 	if (cpuid = smp_processor_id()) {
@@ -387,7 +393,7 @@
 smp_call_function (void (*func) (void *info), void *info, int retry, int wait)
 {
 	struct smp_call_struct data;
-	long timeout;
+	unsigned long timeout;
 	int cpus = smp_num_cpus - 1;
 
 	if (cpus = 0)
@@ -457,23 +463,6 @@
 	}
 }
 
-static inline void __init
-smp_calibrate_delay(int cpuid)
-{
-	struct cpuinfo_ia64 *c = &cpu_data[cpuid];
-#if 0
-	unsigned long old = loops_per_sec;
-	extern void calibrate_delay(void);
-	
-	loops_per_sec = 0;
-	calibrate_delay();
-	c->loops_per_sec = loops_per_sec;
-	loops_per_sec = old;
-#else
-	c->loops_per_sec = loops_per_sec;
-#endif
-}
-
 /* 
  * SAL shoves the AP's here when we start them.  Physical mode, no kernel TR, 
  * no RRs set, better than even chance that psr is bogus.  Fix all that and 
@@ -519,7 +508,7 @@
  * AP's start using C here.
  */
 void __init
-smp_callin(void) 
+smp_callin (void) 
 {
 	extern void ia64_rid_init(void);
 	extern void ia64_init_itm(void);
@@ -529,8 +518,14 @@
 #endif
 	int cpu = smp_processor_id();
 
+	if (test_and_set_bit(cpu, &cpu_online_map)) {
+		printk("CPU#%d already initialized!\n", cpu);
+		machine_halt();
+	}  
+
 	efi_map_pal_code();
 	cpu_init();
+
 	smp_setup_percpu_timer(cpu);
 
 	/* setup the CPU local timer tick */
@@ -544,16 +539,16 @@
 	ia64_set_lrr0(0, 1);	
 	ia64_set_lrr1(0, 1);	
 
-	if (test_and_set_bit(cpu, &cpu_online_map)) {
-		printk("CPU#%d already initialized!\n", cpu);
-		machine_halt();
-	}  
-	while (!smp_threads_ready) 
-		mb();
-
 	local_irq_enable();		/* Interrupts have been off until now */
-	smp_calibrate_delay(cpu);
-	printk("SMP: CPU %d starting idle loop\n", cpu);
+
+	calibrate_delay();
+	my_cpu_data.loops_per_sec = loops_per_sec;
+
+	/* allow the master to continue */
+	set_bit(cpu, &cpu_callin_map);
+
+	/* finally, wait for the BP to finish initialization: */
+	while (!smp_commenced);
 
 	cpu_idle(NULL);
 }
@@ -616,23 +611,15 @@
 	/* Kick the AP in the butt */
 	ipi_send(cpu, ap_wakeup_vector, IA64_IPI_DM_INT, 0);
 
-	/* 
-	 * OK, wait a bit for that CPU to finish staggering about.  smp_callin() will
-	 * call cpu_init() which will set a bit for this AP.  When that bit flips, the AP
-	 * is waiting for smp_threads_ready to be 1 and we can move on.
-	 */
+	/* wait up to 10s for the AP to start  */
 	for (timeout = 0; timeout < 100000; timeout++) {
-		if (test_bit(cpu, &cpu_online_map))
-			goto alive;
+		if (test_bit(cpu, &cpu_callin_map))
+			return 1;
 		udelay(100);
-		barrier();
 	}
 
 	printk(KERN_ERR "SMP: Processor 0x%x is stuck.\n", cpu_phys_id);
 	return 0;
-
-alive:
-	return 1;
 }
 
 
@@ -652,10 +639,11 @@
 	memset(&__cpu_physical_id, -1, sizeof(__cpu_physical_id));
 	memset(&ipi_op, 0, sizeof(ipi_op));
 
-	/* Setup BSP mappings */
+	/* Setup BP mappings */
 	__cpu_physical_id[0] = hard_smp_processor_id();
 
-	smp_calibrate_delay(smp_processor_id());
+	calibrate_delay();
+	my_cpu_data.loops_per_sec = loops_per_sec;
 #if 0
 	smp_tune_scheduling();
 #endif
@@ -717,20 +705,12 @@
 }
 
 /* 
- * Called from main.c by each AP.
+ * Called when the BP is just about to fire off init.
  */
 void __init 
 smp_commence(void)
 {
-	mb();
-}
-
-/*
- * Not used; part of the i386 bringup
- */
-void __init 
-initialize_secondary(void)
-{
+	smp_commenced = 1;
 }
 
 int __init
diff -urN linux-davidm/arch/ia64/kernel/time.c lia64/arch/ia64/kernel/time.c
--- linux-davidm/arch/ia64/kernel/time.c	Wed Sep 13 11:41:51 2000
+++ lia64/arch/ia64/kernel/time.c	Wed Sep 13 13:43:16 2000
@@ -303,7 +303,7 @@
 
         itc_freq = (platform_base_freq*itc_ratio.num)/itc_ratio.den;
         itm.delta = itc_freq / HZ;
-        printk("timer: CPU %d base freq=%lu.%03luMHz, ITC ratio=%lu/%lu, ITC freq=%lu.%03luMHz\n",
+        printk("CPU %d: base freq=%lu.%03luMHz, ITC ratio=%lu/%lu, ITC freq=%lu.%03luMHz\n",
 	       smp_processor_id(),
 	       platform_base_freq / 1000000, (platform_base_freq / 1000) % 1000,
                itc_ratio.num, itc_ratio.den, itc_freq / 1000000, (itc_freq / 1000) % 1000);
diff -urN linux-davidm/arch/ia64/kernel/traps.c lia64/arch/ia64/kernel/traps.c
--- linux-davidm/arch/ia64/kernel/traps.c	Wed Sep 13 11:41:51 2000
+++ lia64/arch/ia64/kernel/traps.c	Wed Sep 13 13:43:42 2000
@@ -192,54 +192,46 @@
 }
 
 /*
- * disabled_fp_fault() is called when a user-level process attempts to
- * access one of the registers f32..f127 while it doesn't own the
+ * disabled_fph_fault() is called when a user-level process attempts
+ * to access one of the registers f32..f127 when it doesn't own the
  * fp-high register partition.  When this happens, we save the current
  * fph partition in the task_struct of the fpu-owner (if necessary)
  * and then load the fp-high partition of the current task (if
- * necessary).
+ * necessary).  Note that the kernel has access to fph by the time we
+ * get here, as the IVT's "Diabled FP-Register" handler takes care of
+ * clearing psr.dfh.
  */
 static inline void
 disabled_fph_fault (struct pt_regs *regs)
 {
-	/* first, clear psr.dfh and psr.mfh: */
-	regs->cr_ipsr &= ~(IA64_PSR_DFH | IA64_PSR_MFH);
-#ifdef CONFIG_SMP
-	if ((current->thread.flags & IA64_THREAD_FPH_VALID) != 0)
-		__ia64_load_fpu(current->thread.fph);
-	else {
-		__ia64_init_fpu();
-		/*
-		 * Set mfh because the state in thread.fph does not match
-		 * the state in the fph partition.
-		 */
-		ia64_psr(regs)->mfh = 1;
-	}
-#else /* !CONFIG_SMP */
+	struct ia64_psr *psr = ia64_psr(regs);
+
+	/* first, grant user-level access to fph partition: */
+	psr->dfh = 0;
+#ifndef CONFIG_SMP
 	{
 		struct task_struct *fpu_owner = ia64_get_fpu_owner();
 
-		if (fpu_owner != current) {
-			ia64_set_fpu_owner(current);
+		if (fpu_owner = current)
+			return;
 
-			if (fpu_owner && ia64_psr(ia64_task_regs(fpu_owner))->mfh) {
-				ia64_psr(ia64_task_regs(fpu_owner))->mfh = 0;
-				fpu_owner->thread.flags |= IA64_THREAD_FPH_VALID;
-				__ia64_save_fpu(fpu_owner->thread.fph);
-			}
-			if ((current->thread.flags & IA64_THREAD_FPH_VALID) != 0) {
-				__ia64_load_fpu(current->thread.fph);
-			} else {
-				__ia64_init_fpu();
-				/*
-				 * Set mfh because the state in thread.fph does not match
-				 * the state in the fph partition.
-				 */
-				ia64_psr(regs)->mfh = 1;
-			}
-		}
+		if (fpu_owner)
+			ia64_flush_fph(fpu_owner);
+
+		ia64_set_fpu_owner(current);
 	}
 #endif /* !CONFIG_SMP */
+	if ((current->thread.flags & IA64_THREAD_FPH_VALID) != 0) {
+		__ia64_load_fpu(current->thread.fph);
+		psr->mfh = 0;
+	} else {
+		__ia64_init_fpu();
+		/*
+		 * Set mfh because the state in thread.fph does not match the state in
+		 * the fph partition.
+		 */
+		psr->mfh = 1;
+	}
 }
 
 static inline int
diff -urN linux-davidm/arch/ia64/kernel/unaligned.c lia64/arch/ia64/kernel/unaligned.c
--- linux-davidm/arch/ia64/kernel/unaligned.c	Wed Sep 13 11:41:51 2000
+++ lia64/arch/ia64/kernel/unaligned.c	Wed Sep 13 13:43:58 2000
@@ -455,16 +455,15 @@
 	unsigned long addr;
 
 	/*
-	 * From EAS-2.5: FPDisableFault has higher priority than 
-	 * Unaligned Fault. Thus, when we get here, we know the partition is 
-	 * enabled.
+	 * From EAS-2.5: FPDisableFault has higher priority than Unaligned
+	 * Fault. Thus, when we get here, we know the partition is enabled.
+	 * To update f32-f127, there are three choices:
+	 *
+	 *	(1) save f32-f127 to thread.fph and update the values there
+	 *	(2) use a gigantic switch statement to directly access the registers
+	 *	(3) generate code on the fly to update the desired register
 	 *
-	 * The registers [32-127] are ususally saved in the tss. When get here,
-	 * they are NECESSARILY live because they are only saved explicitely.
-	 * We have 3 ways of updating the values: force a save of the range
-	 * in tss, use a gigantic switch/case statement or generate code on the
-	 * fly to store to the right register.
-	 * For now, we are using the (slow) save/restore way.
+	 * For now, we are using approach (1).
 	 */
  	if (regnum >= IA64_FIRST_ROTATING_FR) {
 		ia64_sync_fph(current);
@@ -491,7 +490,6 @@
 		 * let's do it for safety.
 	 	 */
 		regs->cr_ipsr |= IA64_PSR_MFL;
-
 	}
 }
 
@@ -522,12 +520,12 @@
 	 * Unaligned Fault. Thus, when we get here, we know the partition is 
 	 * enabled.
 	 *
-	 * When regnum > 31, the register is still live and
-	 * we need to force a save to the tss to get access to it.
-	 * See discussion in setfpreg() for reasons and other ways of doing this.
+	 * When regnum > 31, the register is still live and we need to force a save
+	 * to current->thread.fph to get access to it.  See discussion in setfpreg()
+	 * for reasons and other ways of doing this.
 	 */
  	if (regnum >= IA64_FIRST_ROTATING_FR) {
-		ia64_sync_fph(current);
+		ia64_flush_fph(current);
 		*fpval = current->thread.fph[IA64_FPH_OFFS(regnum)];
 	} else {
 		/*
@@ -1084,9 +1082,9 @@
 		/*
 		 * XXX fixme
 		 *
-		 * A possible optimization would be to drop fpr_final
-		 * and directly use the storage from the saved context i.e.,
-		 * the actual final destination (pt_regs, switch_stack or tss).
+		 * A possible optimization would be to drop fpr_final and directly
+		 * use the storage from the saved context i.e., the actual final
+		 * destination (pt_regs, switch_stack or thread structure).
 		 */
 		setfpreg(ld->r1, &fpr_final[0], regs);
 		setfpreg(ld->imm, &fpr_final[1], regs);
@@ -1212,9 +1210,9 @@
 		/*
 		 * XXX fixme
 		 *
-		 * A possible optimization would be to drop fpr_final
-		 * and directly use the storage from the saved context i.e.,
-		 * the actual final destination (pt_regs, switch_stack or tss).
+		 * A possible optimization would be to drop fpr_final and directly
+		 * use the storage from the saved context i.e., the actual final
+		 * destination (pt_regs, switch_stack or thread structure).
 		 */
 		setfpreg(ld->r1, &fpr_final, regs);
 	}
@@ -1223,9 +1221,7 @@
 	 * check for updates on any loads
 	 */
 	if (ld->op = 0x7 || ld->m)
-		emulate_load_updates(ld->op = 0x7 ? UPD_IMMEDIATE: UPD_REG, 
-				ld, regs, ifa);
-
+		emulate_load_updates(ld->op = 0x7 ? UPD_IMMEDIATE: UPD_REG, ld, regs, ifa);
 
 	/*
 	 * invalidate ALAT entry in case of advanced floating point loads
diff -urN linux-davidm/arch/ia64/kernel/unwind.c lia64/arch/ia64/kernel/unwind.c
--- linux-davidm/arch/ia64/kernel/unwind.c	Wed Sep 13 11:41:51 2000
+++ lia64/arch/ia64/kernel/unwind.c	Wed Sep 13 13:47:44 2000
@@ -395,7 +395,10 @@
 	} else {
 		struct task_struct *t = info->task;
 
-		ia64_sync_fph(t);
+		if (write)
+			ia64_sync_fph(t);
+		else
+			ia64_flush_fph(t);
 		addr = t->thread.fph + (regnum - 32);
 	}
 
diff -urN linux-davidm/arch/ia64/lib/io.c lia64/arch/ia64/lib/io.c
--- linux-davidm/arch/ia64/lib/io.c	Thu Jun 22 07:09:44 2000
+++ lia64/arch/ia64/lib/io.c	Wed Sep 13 13:47:27 2000
@@ -1,4 +1,3 @@
-#include <linux/module.h>
 #include <linux/types.h>
 
 #include <asm/io.h>
@@ -49,6 +48,3 @@
 	}
 }
 
-EXPORT_SYMBOL(__ia64_memcpy_fromio);
-EXPORT_SYMBOL(__ia64_memcpy_toio);
-EXPORT_SYMBOL(__ia64_memset_c_io);
diff -urN linux-davidm/drivers/acpi/acpiconf.c lia64/drivers/acpi/acpiconf.c
--- linux-davidm/drivers/acpi/acpiconf.c	Wed Sep 13 11:41:51 2000
+++ lia64/drivers/acpi/acpiconf.c	Wed Sep 13 13:47:57 2000
@@ -311,7 +311,7 @@
 	pprts = (PCI_ROUTING_TABLE **)prts;
 
 	for ( i = 0; i < PCI_MAX_BUS; i++) {
-		prt = prtf = *pprts++;
+		prt = *pprts++;
 		if (prt) {
 			for ( ; prt->length > 0; nvec++) {
 				prt = (PCI_ROUTING_TABLE *) ((NATIVE_UINT)prt + (NATIVE_UINT)prt->length);
@@ -331,7 +331,7 @@
 	pprts = (PCI_ROUTING_TABLE **)prts;
 
 	for ( i = 0; i < PCI_MAX_BUS; i++) {
-		prt = *pprts++;
+		prt = prtf = *pprts++;
 		if (prt) {
 			for ( ; prt->length > 0; pvec++) {
 				pvec->bus	= (UINT16)i;
diff -urN linux-davidm/include/asm-alpha/module.h lia64/include/asm-alpha/module.h
--- linux-davidm/include/asm-alpha/module.h	Wed Dec 31 16:00:00 1969
+++ lia64/include/asm-alpha/module.h	Wed Sep 13 13:48:34 2000
@@ -0,0 +1,11 @@
+#ifndef _ASM_ALPHA_MODULE_H
+#define _ASM_ALPHA_MODULE_H
+/*
+ * This file contains the alpha architecture specific module code.
+ */
+
+#define module_map(x)		vmalloc(x)
+#define module_unmap(x)		vfree(x)
+#define module_arch_init(x)	(0)
+
+#endif /* _ASM_ALPHA_MODULE_H */
diff -urN linux-davidm/include/asm-alpha/pgtable.h lia64/include/asm-alpha/pgtable.h
--- linux-davidm/include/asm-alpha/pgtable.h	Thu Aug 10 19:56:31 2000
+++ lia64/include/asm-alpha/pgtable.h	Wed Sep 13 13:48:41 2000
@@ -300,9 +300,6 @@
 #define pte_to_swp_entry(pte)		((swp_entry_t) { pte_val(pte) })
 #define swp_entry_to_pte(x)		((pte_t) { (x).val })
 
-#define module_map	vmalloc
-#define module_unmap	vfree
-
 /* Needs to be defined here and not in linux/mm.h, as it is arch dependent */
 #define PageSkip(page)		(0)
 #define kern_addr_valid(addr)	(1)
diff -urN linux-davidm/include/asm-arm/module.h lia64/include/asm-arm/module.h
--- linux-davidm/include/asm-arm/module.h	Wed Dec 31 16:00:00 1969
+++ lia64/include/asm-arm/module.h	Wed Sep 13 13:48:52 2000
@@ -0,0 +1,11 @@
+#ifndef _ASM_ARM_MODULE_H
+#define _ASM_ARM_MODULE_H
+/*
+ * This file contains the arm architecture specific module code.
+ */
+
+#define module_map(x)		vmalloc(x)
+#define module_unmap(x)		vfree(x)
+#define module_arch_init(x)	(0)
+
+#endif /* _ASM_ARM_MODULE_H */
diff -urN linux-davidm/include/asm-arm/pgtable.h lia64/include/asm-arm/pgtable.h
--- linux-davidm/include/asm-arm/pgtable.h	Thu Aug 24 08:17:47 2000
+++ lia64/include/asm-arm/pgtable.h	Wed Sep 13 13:48:48 2000
@@ -170,9 +170,6 @@
 #define pte_to_swp_entry(pte)	((swp_entry_t) { pte_val(pte) })
 #define swp_entry_to_pte(swp)	((pte_t) { (swp).val })
 
-#define module_map		vmalloc
-#define module_unmap		vfree
-
 #define io_remap_page_range	remap_page_range
 
 #endif /* !__ASSEMBLY__ */
diff -urN linux-davidm/include/asm-i386/module.h lia64/include/asm-i386/module.h
--- linux-davidm/include/asm-i386/module.h	Wed Dec 31 16:00:00 1969
+++ lia64/include/asm-i386/module.h	Wed Sep 13 13:49:00 2000
@@ -0,0 +1,11 @@
+#ifndef _ASM_I386_MODULE_H
+#define _ASM_I386_MODULE_H
+/*
+ * This file contains the i386 architecture specific module code.
+ */
+
+#define module_map(x)		vmalloc(x)
+#define module_unmap(x)		vfree(x)
+#define module_arch_init(x)	(0)
+
+#endif /* _ASM_I386_MODULE_H */
diff -urN linux-davidm/include/asm-i386/pgtable.h lia64/include/asm-i386/pgtable.h
--- linux-davidm/include/asm-i386/pgtable.h	Thu Aug 10 19:56:31 2000
+++ lia64/include/asm-i386/pgtable.h	Wed Sep 13 13:49:03 2000
@@ -327,9 +327,6 @@
 #define pte_to_swp_entry(pte)		((swp_entry_t) { pte_val(pte) })
 #define swp_entry_to_pte(x)		((pte_t) { (x).val })
 
-#define module_map      vmalloc
-#define module_unmap    vfree
-
 #endif /* !__ASSEMBLY__ */
 
 /* Needs to be defined here and not in linux/mm.h, as it is arch dependent */
diff -urN linux-davidm/include/asm-ia64/module.h lia64/include/asm-ia64/module.h
--- linux-davidm/include/asm-ia64/module.h	Wed Dec 31 16:00:00 1969
+++ lia64/include/asm-ia64/module.h	Wed Sep 13 13:50:04 2000
@@ -0,0 +1,106 @@
+#ifndef _ASM_IA64_MODULE_H
+#define _ASM_IA64_MODULE_H
+/*
+ * This file contains the ia64 architecture specific module code.
+ *
+ * Copyright (C) 2000 Intel Corporation.
+ * Copyright (C) 2000 Mike Stephens <mike.stephens@intel.com>
+ */
+
+#include <linux/config.h>
+#include <linux/module.h>
+#include <linux/vmalloc.h>
+#include <asm/unwind.h>
+
+#define module_map(x)		vmalloc(x)
+#define module_unmap(x)		ia64_module_unmap(x)
+#define module_arch_init(x)	ia64_module_init(x)
+
+/*
+ * This must match in size and layout the data created by
+ * modutils/obj/obj-ia64.c
+ */
+struct archdata {
+	const char *unw_table;
+	const char *segment_base;
+	const char *unw_start;
+	const char *unw_end;
+	const char *gp;
+};
+
+/*
+ * functions to add/remove a modules unwind info when
+ * it is loaded or unloaded.
+ */
+static inline int
+ia64_module_init(struct module *mod)
+{
+#ifdef CONFIG_IA64_NEW_UNWIND
+	struct archdata *archdata;
+
+	if (!mod_member_present(mod, archdata_start) || !mod->archdata_start)
+		return 0;
+	archdata = (struct archdata *)(mod->archdata_start);
+
+	/*
+	 * Make sure the unwind pointers are sane.
+	 */
+
+	if (archdata->unw_table)
+	{
+		printk(KERN_ERR "arch_init_module: archdata->unw_table must be zero.\n");
+		return 1;
+	}
+	if (!mod_bound(archdata->gp, 0, mod))
+	{
+		printk(KERN_ERR "arch_init_module: archdata->gp out of bounds.\n");
+		return 1;
+	}
+	if (!mod_bound(archdata->unw_start, 0, mod))
+	{
+		printk(KERN_ERR "arch_init_module: archdata->unw_start out of bounds.\n");
+		return 1;
+	}
+	if (!mod_bound(archdata->unw_end, 0, mod))
+	{
+		printk(KERN_ERR "arch_init_module: archdata->unw_end out of bounds.\n");
+		return 1;
+	}
+	if (!mod_bound(archdata->segment_base, 0, mod))
+	{
+		printk(KERN_ERR "arch_init_module: archdata->unw_table out of bounds.\n");
+		return 1;
+	}
+
+	/*
+	 * Pointers are reasonable, add the module unwind table
+	 */
+	archdata->unw_table = unw_add_unwind_table(mod->name, archdata->segment_base,
+		archdata->gp, archdata->unw_start, archdata->unw_end);
+#endif /* CONFIG_IA64_NEW_UNWIND */
+	return 0;
+}
+
+static inline void
+ia64_module_unmap(void * addr)
+{
+#ifdef CONFIG_IA64_NEW_UNWIND
+	struct module *mod = (struct module *) addr;
+	struct archdata *archdata;
+
+	/*
+	 * Before freeing the module memory remove the unwind table entry
+	 */
+	if (mod_member_present(mod, archdata_start) && mod->archdata_start)
+	{
+		archdata = (struct archdata *)(mod->archdata_start);
+
+		if (archdata->unw_table != NULL)
+			unw_remove_unwind_table(archdata->unw_table);
+	}
+#endif /* CONFIG_IA64_NEW_UNWIND */
+
+	vfree(addr);
+}
+
+#endif /* _ASM_IA64_MODULE_H */
diff -urN linux-davidm/include/asm-ia64/pgtable.h lia64/include/asm-ia64/pgtable.h
--- linux-davidm/include/asm-ia64/pgtable.h	Wed Sep 13 11:41:51 2000
+++ lia64/include/asm-ia64/pgtable.h	Wed Sep 13 15:44:36 2000
@@ -426,9 +426,6 @@
 #define pte_to_swp_entry(pte)		((swp_entry_t) { pte_val(pte) })
 #define swp_entry_to_pte(x)		((pte_t) { (x).val })
 
-#define module_map	vmalloc
-#define module_unmap	vfree
-
 /* Needs to be defined here and not in linux/mm.h, as it is arch dependent */
 #define PageSkip(page)		(0)
 
diff -urN linux-davidm/include/asm-ia64/processor.h lia64/include/asm-ia64/processor.h
--- linux-davidm/include/asm-ia64/processor.h	Wed Sep 13 11:41:51 2000
+++ lia64/include/asm-ia64/processor.h	Wed Sep 13 13:50:21 2000
@@ -253,9 +253,9 @@
 #define my_cpu_data		cpu_data[smp_processor_id()]
 
 #ifdef CONFIG_SMP
-# define loops_per_sec()	my_cpu_data.loops_per_sec
+# define ia64_loops_per_sec()	my_cpu_data.loops_per_sec
 #else
-# define loops_per_sec()	loops_per_sec
+# define ia64_loops_per_sec()	loops_per_sec
 #endif
 
 extern struct cpuinfo_ia64 cpu_data[NR_CPUS];
diff -urN linux-davidm/include/asm-m68k/module.h lia64/include/asm-m68k/module.h
--- linux-davidm/include/asm-m68k/module.h	Wed Dec 31 16:00:00 1969
+++ lia64/include/asm-m68k/module.h	Wed Sep 13 13:50:35 2000
@@ -0,0 +1,11 @@
+#ifndef _ASM_M68K_MODULE_H
+#define _ASM_M68K_MODULE_H
+/*
+ * This file contains the m68k architecture specific module code.
+ */
+
+#define module_map(x)		vmalloc(x)
+#define module_unmap(x)		vfree(x)
+#define module_arch_init(x)	(0)
+
+#endif /* _ASM_M68K_MODULE_H */
diff -urN linux-davidm/include/asm-m68k/pgtable.h lia64/include/asm-m68k/pgtable.h
--- linux-davidm/include/asm-m68k/pgtable.h	Thu Aug 10 19:56:31 2000
+++ lia64/include/asm-m68k/pgtable.h	Wed Sep 13 13:50:37 2000
@@ -390,9 +390,6 @@
 
 #endif /* __ASSEMBLY__ */
 
-#define module_map      vmalloc
-#define module_unmap    vfree
-
 /* Needs to be defined here and not in linux/mm.h, as it is arch dependent */
 #define PageSkip(page)		(0)
 #define kern_addr_valid(addr)	(1)
diff -urN linux-davidm/include/asm-mips/module.h lia64/include/asm-mips/module.h
--- linux-davidm/include/asm-mips/module.h	Wed Dec 31 16:00:00 1969
+++ lia64/include/asm-mips/module.h	Wed Sep 13 13:50:47 2000
@@ -0,0 +1,11 @@
+#ifndef _ASM_MIPS_MODULE_H
+#define _ASM_MIPS_MODULE_H
+/*
+ * This file contains the mips architecture specific module code.
+ */
+
+#define module_map(x)		vmalloc(x)
+#define module_unmap(x)		vfree(x)
+#define module_arch_init(x)	(0)
+
+#endif /* _ASM_MIPS_MODULE_H */
diff -urN linux-davidm/include/asm-mips/pgtable.h lia64/include/asm-mips/pgtable.h
--- linux-davidm/include/asm-mips/pgtable.h	Thu Aug 10 19:56:31 2000
+++ lia64/include/asm-mips/pgtable.h	Wed Sep 13 13:50:44 2000
@@ -451,10 +451,6 @@
 #define pte_to_swp_entry(pte)	((swp_entry_t) { pte_val(pte) })
 #define swp_entry_to_pte(x)	((pte_t) { (x).val })
 
-
-#define module_map      vmalloc
-#define module_unmap    vfree
-
 /* Needs to be defined here and not in linux/mm.h, as it is arch dependent */
 #define PageSkip(page)		(0)
 #define kern_addr_valid(addr)	(1)
diff -urN linux-davidm/include/asm-mips64/module.h lia64/include/asm-mips64/module.h
--- linux-davidm/include/asm-mips64/module.h	Wed Dec 31 16:00:00 1969
+++ lia64/include/asm-mips64/module.h	Wed Sep 13 13:50:57 2000
@@ -0,0 +1,11 @@
+#ifndef _ASM_MIPS64_MODULE_H
+#define _ASM_MIPS64_MODULE_H
+/*
+ * This file contains the mips64 architecture specific module code.
+ */
+
+#define module_map(x)		vmalloc(x)
+#define module_unmap(x)		vfree(x)
+#define module_arch_init(x)	(0)
+
+#endif /* _ASM_MIPS64_MODULE_H */
diff -urN linux-davidm/include/asm-mips64/pgtable.h lia64/include/asm-mips64/pgtable.h
--- linux-davidm/include/asm-mips64/pgtable.h	Thu Aug 10 19:56:31 2000
+++ lia64/include/asm-mips64/pgtable.h	Wed Sep 13 13:50:59 2000
@@ -525,9 +525,6 @@
 #define pte_to_swp_entry(pte)	((swp_entry_t) { pte_val(pte) })
 #define swp_entry_to_pte(x)	((pte_t) { (x).val })
 
-#define module_map      vmalloc
-#define module_unmap    vfree
-
 /* Needs to be defined here and not in linux/mm.h, as it is arch dependent */
 #define PageSkip(page)		test_bit(PG_skip, &(page)->flags)
 #ifndef CONFIG_DISCONTIGMEM
diff -urN linux-davidm/include/asm-ppc/module.h lia64/include/asm-ppc/module.h
--- linux-davidm/include/asm-ppc/module.h	Wed Dec 31 16:00:00 1969
+++ lia64/include/asm-ppc/module.h	Wed Sep 13 13:51:10 2000
@@ -0,0 +1,11 @@
+#ifndef _ASM_PPC_MODULE_H
+#define _ASM_PPC_MODULE_H
+/*
+ * This file contains the PPC architecture specific module code.
+ */
+
+#define module_map(x)		vmalloc(x)
+#define module_unmap(x)		vfree(x)
+#define module_arch_init(x)	(0)
+
+#endif /* _ASM_PPC_MODULE_H */
diff -urN linux-davidm/include/asm-ppc/pgtable.h lia64/include/asm-ppc/pgtable.h
--- linux-davidm/include/asm-ppc/pgtable.h	Thu Aug 10 19:56:32 2000
+++ lia64/include/asm-ppc/pgtable.h	Wed Sep 13 13:51:08 2000
@@ -451,9 +451,6 @@
 #define pte_to_swp_entry(pte)		((swp_entry_t) { pte_val(pte) })
 #define swp_entry_to_pte(x)		((pte_t) { (x).val })
 
-#define module_map      vmalloc
-#define module_unmap    vfree
-
 /* CONFIG_APUS */
 /* For virtual address to physical address conversion */
 extern void cache_clear(__u32 addr, int length);
diff -urN linux-davidm/include/asm-s390/module.h lia64/include/asm-s390/module.h
--- linux-davidm/include/asm-s390/module.h	Wed Dec 31 16:00:00 1969
+++ lia64/include/asm-s390/module.h	Wed Sep 13 13:51:20 2000
@@ -0,0 +1,11 @@
+#ifndef _ASM_S390_MODULE_H
+#define _ASM_S390_MODULE_H
+/*
+ * This file contains the s390 architecture specific module code.
+ */
+
+#define module_map(x)		vmalloc(x)
+#define module_unmap(x)		vfree(x)
+#define module_arch_init(x)	(0)
+
+#endif /* _ASM_S390_MODULE_H */
diff -urN linux-davidm/include/asm-s390/pgtable.h lia64/include/asm-s390/pgtable.h
--- linux-davidm/include/asm-s390/pgtable.h	Thu Aug 10 19:56:32 2000
+++ lia64/include/asm-s390/pgtable.h	Wed Sep 13 13:51:22 2000
@@ -405,9 +405,6 @@
 #define pte_to_swp_entry(pte)           ((swp_entry_t) { pte_val(pte) })
 #define swp_entry_to_pte(x)             ((pte_t) { (x).val })
 
-#define module_map      vmalloc
-#define module_unmap    vfree
-
 #endif /* !__ASSEMBLY__ */
 
 /* Needs to be defined here and not in linux/mm.h, as it is arch dependent */
diff -urN linux-davidm/include/asm-sh/module.h lia64/include/asm-sh/module.h
--- linux-davidm/include/asm-sh/module.h	Wed Dec 31 16:00:00 1969
+++ lia64/include/asm-sh/module.h	Wed Sep 13 13:51:30 2000
@@ -0,0 +1,11 @@
+#ifndef _ASM_SH_MODULE_H
+#define _ASM_SH_MODULE_H
+/*
+ * This file contains the SH architecture specific module code.
+ */
+
+#define module_map(x)		vmalloc(x)
+#define module_unmap(x)		vfree(x)
+#define module_arch_init(x)	(0)
+
+#endif /* _ASM_SH_MODULE_H */
diff -urN linux-davidm/include/asm-sh/pgtable.h lia64/include/asm-sh/pgtable.h
--- linux-davidm/include/asm-sh/pgtable.h	Thu Aug 10 19:56:32 2000
+++ lia64/include/asm-sh/pgtable.h	Wed Sep 13 13:51:29 2000
@@ -250,9 +250,6 @@
 #define pte_to_swp_entry(pte)		((swp_entry_t) { pte_val(pte) })
 #define swp_entry_to_pte(x)		((pte_t) { (x).val })
 
-#define module_map      vmalloc
-#define module_unmap    vfree
-
 #endif /* !__ASSEMBLY__ */
 
 /* Needs to be defined here and not in linux/mm.h, as it is arch dependent */
diff -urN linux-davidm/include/asm-sparc/module.h lia64/include/asm-sparc/module.h
--- linux-davidm/include/asm-sparc/module.h	Wed Dec 31 16:00:00 1969
+++ lia64/include/asm-sparc/module.h	Wed Sep 13 13:51:41 2000
@@ -0,0 +1,11 @@
+#ifndef _ASM_SPARC_MODULE_H
+#define _ASM_SPARC_MODULE_H
+/*
+ * This file contains the sparc architecture specific module code.
+ */
+
+#define module_map(x)		vmalloc(x)
+#define module_unmap(x)		vfree(x)
+#define module_arch_init(x)	(0)
+
+#endif /* _ASM_SPARC_MODULE_H */
diff -urN linux-davidm/include/asm-sparc/pgtable.h lia64/include/asm-sparc/pgtable.h
--- linux-davidm/include/asm-sparc/pgtable.h	Thu Aug 24 08:17:47 2000
+++ lia64/include/asm-sparc/pgtable.h	Wed Sep 13 13:51:44 2000
@@ -444,8 +444,6 @@
 	}
 }
 
-#define module_map      vmalloc
-#define module_unmap    vfree
 extern unsigned long *sparc_valid_addr_bitmap;
 
 /* Needs to be defined here and not in linux/mm.h, as it is arch dependent */
diff -urN linux-davidm/include/asm-sparc64/module.h lia64/include/asm-sparc64/module.h
--- linux-davidm/include/asm-sparc64/module.h	Wed Dec 31 16:00:00 1969
+++ lia64/include/asm-sparc64/module.h	Wed Sep 13 13:51:55 2000
@@ -0,0 +1,11 @@
+#ifndef _ASM_SPARC64_MODULE_H
+#define _ASM_SPARC64_MODULE_H
+/*
+ * This file contains the sparc64 architecture specific module code.
+ */
+
+extern void * module_map (unsigned long size);
+extern void module_unmap (void *addr);
+#define module_arch_init (x)	(0)
+
+#endif /* _ASM_SPARC64_MODULE_H */
diff -urN linux-davidm/include/asm-sparc64/pgtable.h lia64/include/asm-sparc64/pgtable.h
--- linux-davidm/include/asm-sparc64/pgtable.h	Thu Aug 24 08:17:48 2000
+++ lia64/include/asm-sparc64/pgtable.h	Wed Sep 13 13:51:53 2000
@@ -284,8 +284,6 @@
 	return ((sun4u_get_pte (addr) & 0xf0000000) >> 28);
 }
 
-extern void * module_map (unsigned long size);
-extern void module_unmap (void *addr);
 extern unsigned long *sparc64_valid_addr_bitmap;
 
 /* Needs to be defined here and not in linux/mm.h, as it is arch dependent */
diff -urN linux-davidm/include/linux/module.h lia64/include/linux/module.h
--- linux-davidm/include/linux/module.h	Thu Aug 10 19:56:32 2000
+++ lia64/include/linux/module.h	Wed Sep 13 13:52:30 2000
@@ -83,6 +83,12 @@
 	const struct module_persist *persist_start;
 	const struct module_persist *persist_end;
 	int (*can_unload)(void);
+	int runsize;			/* In modutils, not currently used */
+	const char *kallsyms_start;	/* All symbols for kernel debugging */
+	const char *kallsyms_end;
+	const char *archdata_start;	/* arch specific data for module */
+	const char *archdata_end;
+	const char *kernel_data;	/* Reserved for kernel internal use */
 };
 
 struct module_info
@@ -122,6 +128,10 @@
 #define mod_member_present(mod,member) 					\
 	((unsigned long)(&((struct module *)0L)->member + 1)		\
 	 <= (mod)->size_of_struct)
+
+/* Check if an address p with number of entries n is within the body of module m */
+#define mod_bound(p, n, m) ((unsigned long)(p) >= ((unsigned long)(m) + ((m)->size_of_struct)) && \
+	         (unsigned long)((p)+(n)) <= (unsigned long)(m) + (m)->size)
 
 /* Backwards compatibility definition.  */
 
diff -urN linux-davidm/kernel/module.c lia64/kernel/module.c
--- linux-davidm/kernel/module.c	Mon Jun 26 12:11:10 2000
+++ lia64/kernel/module.c	Wed Sep 13 13:53:24 2000
@@ -1,6 +1,7 @@
 #include <linux/config.h>
 #include <linux/mm.h>
 #include <linux/module.h>
+#include <asm/module.h>
 #include <asm/uaccess.h>
 #include <linux/vmalloc.h>
 #include <linux/smp_lock.h>
@@ -195,7 +196,7 @@
 	   of righteousness.  */
 	mod_tmp = *mod;
 
-	error = copy_from_user(mod, mod_user, sizeof(struct module));
+	error = copy_from_user(mod, mod_user, mod_user_size);
 	if (error) {
 		error = -EFAULT;
 		goto err2;
@@ -212,32 +213,29 @@
 
 	/* Make sure all interesting pointers are sane.  */
 
-#define bound(p, n, m)  ((unsigned long)(p) >= (unsigned long)(m+1) &&  \
-	         (unsigned long)((p)+(n)) <= (unsigned long)(m) + (m)->size)
-
-	if (!bound(mod->name, namelen, mod)) {
+	if (!mod_bound(mod->name, namelen, mod)) {
 		printk(KERN_ERR "init_module: mod->name out of bounds.\n");
 		goto err2;
 	}
-	if (mod->nsyms && !bound(mod->syms, mod->nsyms, mod)) {
+	if (mod->nsyms && !mod_bound(mod->syms, mod->nsyms, mod)) {
 		printk(KERN_ERR "init_module: mod->syms out of bounds.\n");
 		goto err2;
 	}
-	if (mod->ndeps && !bound(mod->deps, mod->ndeps, mod)) {
+	if (mod->ndeps && !mod_bound(mod->deps, mod->ndeps, mod)) {
 		printk(KERN_ERR "init_module: mod->deps out of bounds.\n");
 		goto err2;
 	}
-	if (mod->init && !bound(mod->init, 0, mod)) {
+	if (mod->init && !mod_bound(mod->init, 0, mod)) {
 		printk(KERN_ERR "init_module: mod->init out of bounds.\n");
 		goto err2;
 	}
-	if (mod->cleanup && !bound(mod->cleanup, 0, mod)) {
+	if (mod->cleanup && !mod_bound(mod->cleanup, 0, mod)) {
 		printk(KERN_ERR "init_module: mod->cleanup out of bounds.\n");
 		goto err2;
 	}
 	if (mod->ex_table_start > mod->ex_table_end
 	    || (mod->ex_table_start &&
-		!((unsigned long)mod->ex_table_start >= (unsigned long)(mod+1)
+		!((unsigned long)mod->ex_table_start >= ((unsigned long)mod + mod->size_of_struct)
 		  && ((unsigned long)mod->ex_table_end
 		      < (unsigned long)mod + mod->size)))
 	    || (((unsigned long)mod->ex_table_start
@@ -251,24 +249,51 @@
 		goto err2;
 	}
 #ifdef __alpha__
-	if (!bound(mod->gp - 0x8000, 0, mod)) {
+	if (!mod_bound(mod->gp - 0x8000, 0, mod)) {
 		printk(KERN_ERR "init_module: mod->gp out of bounds.\n");
 		goto err2;
 	}
 #endif
 	if (mod_member_present(mod, can_unload)
-	    && mod->can_unload && !bound(mod->can_unload, 0, mod)) {
+	    && mod->can_unload && !mod_bound(mod->can_unload, 0, mod)) {
 		printk(KERN_ERR "init_module: mod->can_unload out of bounds.\n");
 		goto err2;
 	}
-
-#undef bound
+	if (mod_member_present(mod, kallsyms_end)) {
+	    if (mod->kallsyms_end &&
+	        (!mod_bound(mod->kallsyms_start, 0, mod) ||
+	         !mod_bound(mod->kallsyms_end, 0, mod))) {
+		printk(KERN_ERR "init_module: mod->kallsyms out of bounds.\n");
+		goto err2;
+	    }
+	    if (mod->kallsyms_start > mod->kallsyms_end) {
+		printk(KERN_ERR "init_module: mod->kallsyms invalid.\n");
+		goto err2;
+	    }
+	}
+	if (mod_member_present(mod, archdata_end)) {
+	    if (mod->archdata_end &&
+	        (!mod_bound(mod->archdata_start, 0, mod) ||
+	         !mod_bound(mod->archdata_end, 0, mod))) {
+		printk(KERN_ERR "init_module: mod->archdata out of bounds.\n");
+		goto err2;
+	    }
+	    if (mod->archdata_start > mod->archdata_end) {
+		printk(KERN_ERR "init_module: mod->archdata invalid.\n");
+		goto err2;
+	    }
+	}
+	if (mod_member_present(mod, kernel_data) && mod->kernel_data) {
+	    printk(KERN_ERR "init_module: mod->kernel_data must be zero.\n");
+	    goto err2;
+	}
 
 	/* Check that the user isn't doing something silly with the name.  */
 
 	if ((n_namelen = get_mod_name(mod->name - (unsigned long)mod
 				      + (unsigned long)mod_user,
 				      &n_name)) < 0) {
+	        printk(KERN_ERR "init_module: get_mod_name failure.\n");
 		error = n_namelen;
 		goto err2;
 	}
@@ -285,6 +310,9 @@
 		error = -EFAULT;
 		goto err3;
 	}
+
+	if (module_arch_init(mod))
+		goto err3;
 
 	/* On some machines it is necessary to do something here
 	   to make the I and D caches consistent.  */

