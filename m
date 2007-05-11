From: Simon Arlott <simon@fire.lp0.eu>
Date: Fri, 11 May 2007 19:41:49 +0000
Subject: [PATCH] spelling fixes: arch/ia64/
Message-Id: <4644C6FD.6010004@simon.arlott.org.uk>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, trivial@kernel.org

Spelling fixes in arch/ia64/.

Signed-off-by: Simon Arlott <simon@fire.lp0.eu>
---
 arch/ia64/kernel/acpi.c             |    2 +-
 arch/ia64/kernel/crash.c            |    2 +-
 arch/ia64/kernel/irq.c              |    6 +++---
 arch/ia64/kernel/irq_lsapic.c       |    2 +-
 arch/ia64/kernel/kprobes.c          |    6 +++---
 arch/ia64/kernel/mca_drv.c          |    4 ++--
 arch/ia64/kernel/module.c           |    2 +-
 arch/ia64/kernel/perfmon.c          |   18 +++++++++---------
 arch/ia64/kernel/perfmon_mckinley.h |    2 +-
 arch/ia64/kernel/sal.c              |    2 +-
 arch/ia64/kernel/salinfo.c          |    2 +-
 arch/ia64/kernel/setup.c            |    6 +++---
 arch/ia64/kernel/smp.c              |   12 ++++++------
 arch/ia64/kernel/smpboot.c          |    6 +++---
 arch/ia64/kernel/time.c             |    2 +-
 arch/ia64/kernel/traps.c            |    2 +-
 arch/ia64/kernel/unwind.c           |    2 +-
 arch/ia64/mm/discontig.c            |    2 +-
 arch/ia64/sn/kernel/bte.c           |   12 ++++++------
 arch/ia64/sn/kernel/bte_error.c     |    4 ++--
 arch/ia64/sn/kernel/io_common.c     |    2 +-
 arch/ia64/sn/kernel/setup.c         |    2 +-
 arch/ia64/sn/kernel/sn2/sn2_smp.c   |    2 +-
 arch/ia64/sn/kernel/xpc_channel.c   |    8 ++++----
 arch/ia64/sn/kernel/xpnet.c         |    2 +-
 arch/ia64/sn/pci/pci_dma.c          |    8 ++++----
 arch/ia64/sn/pci/pcibr/pcibr_ate.c  |    6 +++---
 arch/ia64/sn/pci/pcibr/pcibr_dma.c  |    2 +-
 arch/ia64/sn/pci/tioca_provider.c   |    6 +++---
 arch/ia64/sn/pci/tioce_provider.c   |   16 ++++++++--------
 30 files changed, 75 insertions(+), 75 deletions(-)

diff --git a/arch/ia64/kernel/acpi.c b/arch/ia64/kernel/acpi.c
index 3549c94..c478449 100644
--- a/arch/ia64/kernel/acpi.c
+++ b/arch/ia64/kernel/acpi.c
@@ -791,7 +791,7 @@ static __init int setup_additional_cpus(char *s)
 early_param("additional_cpus", setup_additional_cpus);
 
 /*
- * cpu_possible_map should be static, it cannot change as cpu's
+ * cpu_possible_map should be static, it cannot change as CPUs
  * are onlined, or offlined. The reason is per-cpu data-structures
  * are allocated by some modules at init time, and dont expect to
  * do this dynamically on cpu arrival/departure.
diff --git a/arch/ia64/kernel/crash.c b/arch/ia64/kernel/crash.c
index aeb79fb..e80c82c 100644
--- a/arch/ia64/kernel/crash.c
+++ b/arch/ia64/kernel/crash.c
@@ -163,7 +163,7 @@ kdump_init_notifier(struct notifier_block *self, unsigned long val, void *data)
 		return NOTIFY_DONE;
 
 	nd = (struct ia64_mca_notify_die *)args->err;
-	/* Reason code 1 means machine check rendezous*/
+	/* Reason code 1 means machine check rendezvous*/
 	if ((val = DIE_INIT_MONARCH_ENTER || val = DIE_INIT_SLAVE_ENTER) &&
 		 nd->sos->rv_rc = 1)
 		return NOTIFY_DONE;
diff --git a/arch/ia64/kernel/irq.c b/arch/ia64/kernel/irq.c
index ce49c85..f88ff7c 100644
--- a/arch/ia64/kernel/irq.c
+++ b/arch/ia64/kernel/irq.c
@@ -4,7 +4,7 @@
  *	Copyright (C) 1992, 1998 Linus Torvalds, Ingo Molnar
  *
  * This file contains the code used by various IRQ handling routines:
- * asking for different IRQ's should be done through these routines
+ * asking for different IRQs should be done through these routines
  * instead of just grabbing them. Thus setups with different IRQ numbers
  * shouldn't result in any weird surprises, and installing new handlers
  * should be easier.
@@ -12,7 +12,7 @@
  * Copyright (C) Ashok Raj<ashok.raj@intel.com>, Intel Corporation 2004
  *
  * 4/14/2004: Added code to handle cpu migration and do safe irq
- *			migration without lossing interrupts for iosapic
+ *			migration without losing interrupts for iosapic
  *			architecture.
  */
 
@@ -179,7 +179,7 @@ void fixup_irqs(void)
 	}
 
 	/*
-	 * Phase 1: Locate irq's bound to this cpu and
+	 * Phase 1: Locate IRQs bound to this cpu and
 	 * relocate them for cpu removal.
 	 */
 	migrate_irqs();
diff --git a/arch/ia64/kernel/irq_lsapic.c b/arch/ia64/kernel/irq_lsapic.c
index c2f07be..e56a7a3 100644
--- a/arch/ia64/kernel/irq_lsapic.c
+++ b/arch/ia64/kernel/irq_lsapic.c
@@ -23,7 +23,7 @@ lsapic_noop_startup (unsigned int irq)
 static void
 lsapic_noop (unsigned int irq)
 {
-	/* nuthing to do... */
+	/* nothing to do... */
 }
 
 static int lsapic_retrigger(unsigned int irq)
diff --git a/arch/ia64/kernel/kprobes.c b/arch/ia64/kernel/kprobes.c
index 4f5fd09..21cd36a 100644
--- a/arch/ia64/kernel/kprobes.c
+++ b/arch/ia64/kernel/kprobes.c
@@ -151,12 +151,12 @@ static uint __kprobes is_cmp_ctype_unc_inst(uint template, uint slot,
 
 	cmp_inst.l = kprobe_inst;
 	if ((cmp_inst.f.x2 = 0) || (cmp_inst.f.x2 = 1)) {
-		/* Integere compare - Register Register (A6 type)*/
+		/* Integer compare - Register Register (A6 type)*/
 		if ((cmp_inst.f.tb = 0) && (cmp_inst.f.ta = 0)
 				&&(cmp_inst.f.c = 1))
 			ctype_unc = 1;
 	} else if ((cmp_inst.f.x2 = 2)||(cmp_inst.f.x2 = 3)) {
-		/* Integere compare - Immediate Register (A8 type)*/
+		/* Integer compare - Immediate Register (A8 type)*/
 		if ((cmp_inst.f.ta = 0) &&(cmp_inst.f.c = 1))
 			ctype_unc = 1;
 	}
@@ -950,7 +950,7 @@ int __kprobes setjmp_pre_handler(struct kprobe *p, struct pt_regs *regs)
 	/*
 	 * Callee owns the argument space and could overwrite it, eg
 	 * tail call optimization. So to be absolutely safe
-	 * we save the argument space before transfering the control
+	 * we save the argument space before transferring the control
 	 * to instrumented jprobe function which runs in
 	 * the process context
 	 */
diff --git a/arch/ia64/kernel/mca_drv.c b/arch/ia64/kernel/mca_drv.c
index 70b8bdb..aba813c 100644
--- a/arch/ia64/kernel/mca_drv.c
+++ b/arch/ia64/kernel/mca_drv.c
@@ -438,7 +438,7 @@ is_mca_global(peidx_table_t *peidx, pal_bus_check_info_t *pbci,
  * @peidx:	pointer of index of processor error section
  *
  * Return value:
- *	target address on Success / 0 on Failue
+ *	target address on Success / 0 on Failure
  */
 static u64
 get_target_identifier(peidx_table_t *peidx)
@@ -701,7 +701,7 @@ recover_from_processor_error(int platform, slidx_table_t *slidx,
 		return fatal_mca("External bus check fatal status");
 
 	/*
-	 * This is a local MCA and estimated as a recoverble error.
+	 * This is a local MCA and estimated as a recoverable error.
 	 */
 	if (platform)
 		return recover_from_platform_error(slidx, peidx, pbci, sos);
diff --git a/arch/ia64/kernel/module.c b/arch/ia64/kernel/module.c
index 158e3c5..1962879 100644
--- a/arch/ia64/kernel/module.c
+++ b/arch/ia64/kernel/module.c
@@ -861,7 +861,7 @@ apply_relocate (Elf64_Shdr *sechdrs, const char *strtab, unsigned int symindex,
 /*
  * Modules contain a single unwind table which covers both the core and the init text
  * sections but since the two are not contiguous, we need to split this table up such that
- * we can register (and unregister) each "segment" seperately.  Fortunately, this sounds
+ * we can register (and unregister) each "segment" separately.  Fortunately, this sounds
  * more complicated than it really is.
  */
 static void
diff --git a/arch/ia64/kernel/perfmon.c b/arch/ia64/kernel/perfmon.c
index e7191ca..b7133ca 100644
--- a/arch/ia64/kernel/perfmon.c
+++ b/arch/ia64/kernel/perfmon.c
@@ -1318,7 +1318,7 @@ pfm_reserve_session(struct task_struct *task, int is_syswide, unsigned int cpu)
 {
 	unsigned long flags;
 	/*
-	 * validy checks on cpu_mask have been done upstream
+	 * validity checks on cpu_mask have been done upstream
 	 */
 	LOCK_PFS(flags);
 
@@ -1384,7 +1384,7 @@ pfm_unreserve_session(pfm_context_t *ctx, int is_syswide, unsigned int cpu)
 {
 	unsigned long flags;
 	/*
-	 * validy checks on cpu_mask have been done upstream
+	 * validity checks on cpu_mask have been done upstream
 	 */
 	LOCK_PFS(flags);
 
@@ -1835,7 +1835,7 @@ pfm_flush(struct file *filp, fl_owner_t id)
 	/*
 	 * remove our file from the async queue, if we use this mode.
 	 * This can be done without the context being protected. We come
-	 * here when the context has become unreacheable by other tasks.
+	 * here when the context has become unreachable by other tasks.
 	 *
 	 * We may still have active monitoring at this point and we may
 	 * end up in pfm_overflow_handler(). However, fasync_helper()
@@ -2132,7 +2132,7 @@ doit:
 	filp->private_data = NULL;
 
 	/*
-	 * if we free on the spot, the context is now completely unreacheable
+	 * if we free on the spot, the context is now completely unreachable
 	 * from the callers side. The monitored task side is also cut, so we
 	 * can freely cut.
 	 *
@@ -2562,7 +2562,7 @@ pfm_reset_pmu_state(pfm_context_t *ctx)
 	ctx->ctx_all_pmcs[0] = pmu_conf->impl_pmcs[0] & ~0x1;
 
 	/*
-	 * bitmask of all PMDs that are accesible to this context
+	 * bitmask of all PMDs that are accessible to this context
 	 */
 	ctx->ctx_all_pmds[0] = pmu_conf->impl_pmds[0];
 
@@ -3395,7 +3395,7 @@ pfm_read_pmds(pfm_context_t *ctx, void *arg, int count, struct pt_regs *regs)
 		if (unlikely(!PMD_IS_IMPL(cnum))) goto error;
 		/*
 		 * we can only read the register that we use. That includes
-		 * the one we explicitely initialize AND the one we want included
+		 * the one we explicitly initialize AND the one we want included
 		 * in the sampling buffer (smpl_regs).
 		 *
 		 * Having this restriction allows optimization in the ctxsw routine
@@ -3715,7 +3715,7 @@ pfm_restart(pfm_context_t *ctx, void *arg, int count, struct pt_regs *regs)
 	 * if non-blocking, then we ensure that the task will go into
 	 * pfm_handle_work() before returning to user mode.
 	 *
-	 * We cannot explicitely reset another task, it MUST always
+	 * We cannot explicitly reset another task, it MUST always
 	 * be done by the task itself. This works for system wide because
 	 * the tool that is controlling the session is logically doing 
 	 * "self-monitoring".
@@ -4644,7 +4644,7 @@ pfm_exit_thread(struct task_struct *task)
 	switch(state) {
 		case PFM_CTX_UNLOADED:
 			/*
-	 		 * only comes to thios function if pfm_context is not NULL, i.e., cannot
+	 		 * only comes to this function if pfm_context is not NULL, i.e., cannot
 			 * be in unloaded state
 	 		 */
 			printk(KERN_ERR "perfmon: pfm_exit_thread [%d] ctx unloaded\n", task->pid);
@@ -5247,7 +5247,7 @@ pfm_end_notify_user(pfm_context_t *ctx)
 
 /*
  * main overflow processing routine.
- * it can be called from the interrupt path or explicitely during the context switch code
+ * it can be called from the interrupt path or explicitly during the context switch code
  */
 static void
 pfm_overflow_handler(struct task_struct *task, pfm_context_t *ctx, u64 pmc0, struct pt_regs *regs)
diff --git a/arch/ia64/kernel/perfmon_mckinley.h b/arch/ia64/kernel/perfmon_mckinley.h
index 9becccd..c4bec7a 100644
--- a/arch/ia64/kernel/perfmon_mckinley.h
+++ b/arch/ia64/kernel/perfmon_mckinley.h
@@ -181,7 +181,7 @@ static pmu_config_t pmu_conf_mck={
 	.pmc_desc      = pfm_mck_pmc_desc,
 	.num_ibrs       = 8,
 	.num_dbrs       = 8,
-	.use_rr_dbregs = 1 /* debug register are use for range retrictions */
+	.use_rr_dbregs = 1 /* debug register are use for range restrictions */
 };
 
 
diff --git a/arch/ia64/kernel/sal.c b/arch/ia64/kernel/sal.c
index 37c876f..27c2ef4 100644
--- a/arch/ia64/kernel/sal.c
+++ b/arch/ia64/kernel/sal.c
@@ -134,7 +134,7 @@ set_smp_redirect (int flag)
 	 * interrupt redirection. The reason is this would require that
 	 * All interrupts be stopped and hard bind the irq to a cpu.
 	 * Later when the interrupt is fired we need to set the redir hint
-	 * on again in the vector. This is combersome for something that the
+	 * on again in the vector. This is cumbersome for something that the
 	 * user mode irq balancer will solve anyways.
 	 */
 	no_int_routing=1;
diff --git a/arch/ia64/kernel/salinfo.c b/arch/ia64/kernel/salinfo.c
index 89f6b13..25cd75f 100644
--- a/arch/ia64/kernel/salinfo.c
+++ b/arch/ia64/kernel/salinfo.c
@@ -162,7 +162,7 @@ static DEFINE_SPINLOCK(data_saved_lock);
 /** salinfo_platform_oemdata - optional callback to decode oemdata from an error
  * record.
  * @sect_header: pointer to the start of the section to decode.
- * @oemdata: returns vmalloc area containing the decded output.
+ * @oemdata: returns vmalloc area containing the decoded output.
  * @oemdata_size: returns length of decoded output (strlen).
  *
  * Description: If user space asks for oem data to be decoded by the kernel
diff --git a/arch/ia64/kernel/setup.c b/arch/ia64/kernel/setup.c
index 9df1efe..eaa6a24 100644
--- a/arch/ia64/kernel/setup.c
+++ b/arch/ia64/kernel/setup.c
@@ -576,7 +576,7 @@ setup_arch (char **cmdline_p)
 }
 
 /*
- * Display cpu info for all cpu's.
+ * Display cpu info for all CPUs.
  */
 static int
 show_cpuinfo (struct seq_file *m, void *v)
@@ -761,7 +761,7 @@ identify_cpu (struct cpuinfo_ia64 *c)
 	c->cpu = smp_processor_id();
 
 	/* below default values will be overwritten  by identify_siblings() 
-	 * for Multi-Threading/Multi-Core capable cpu's
+	 * for Multi-Threading/Multi-Core capable CPUs
 	 */
 	c->threads_per_core = c->cores_per_socket = c->num_log = 1;
 	c->socket_id = -1;
@@ -947,7 +947,7 @@ cpu_init (void)
 	ia32_cpu_init();
 #endif
 
-	/* Clear ITC to eliminiate sched_clock() overflows in human time.  */
+	/* Clear ITC to eliminate sched_clock() overflows in human time.  */
 	ia64_set_itc(0);
 
 	/* disable all local interrupt sources: */
diff --git a/arch/ia64/kernel/smp.c b/arch/ia64/kernel/smp.c
index 221de38..b3a47f9 100644
--- a/arch/ia64/kernel/smp.c
+++ b/arch/ia64/kernel/smp.c
@@ -186,7 +186,7 @@ handle_IPI (int irq, void *dev_id)
 }
 
 /*
- * Called with preeemption disabled.
+ * Called with preemption disabled.
  */
 static inline void
 send_IPI_single (int dest_cpu, int op)
@@ -196,7 +196,7 @@ send_IPI_single (int dest_cpu, int op)
 }
 
 /*
- * Called with preeemption disabled.
+ * Called with preemption disabled.
  */
 static inline void
 send_IPI_allbutself (int op)
@@ -210,7 +210,7 @@ send_IPI_allbutself (int op)
 }
 
 /*
- * Called with preeemption disabled.
+ * Called with preemption disabled.
  */
 static inline void
 send_IPI_all (int op)
@@ -223,7 +223,7 @@ send_IPI_all (int op)
 }
 
 /*
- * Called with preeemption disabled.
+ * Called with preemption disabled.
  */
 static inline void
 send_IPI_self (int op)
@@ -252,7 +252,7 @@ kdump_smp_send_init(void)
 }
 #endif
 /*
- * Called with preeemption disabled.
+ * Called with preemption disabled.
  */
 void
 smp_send_reschedule (int cpu)
@@ -261,7 +261,7 @@ smp_send_reschedule (int cpu)
 }
 
 /*
- * Called with preeemption disabled.
+ * Called with preemption disabled.
  */
 static void
 smp_send_local_flush_tlb (int cpu)
diff --git a/arch/ia64/kernel/smpboot.c b/arch/ia64/kernel/smpboot.c
index a44792d..5429580 100644
--- a/arch/ia64/kernel/smpboot.c
+++ b/arch/ia64/kernel/smpboot.c
@@ -694,7 +694,7 @@ int migrate_platform_irqs(unsigned int cpu)
 			set_cpei_target_cpu(new_cpei_cpu);
 			desc = irq_desc + ia64_cpe_irq;
 			/*
-			 * Switch for now, immediatly, we need to do fake intr
+			 * Switch for now, immediately, we need to do fake intr
 			 * as other interrupts, but need to study CPEI behaviour with
 			 * polling before making changes.
 			 */
@@ -840,7 +840,7 @@ __cpu_up (unsigned int cpu)
 }
 
 /*
- * Assume that CPU's have been discovered by some platform-dependent interface.  For
+ * Assume that CPUs have been discovered by some platform-dependent interface.  For
  * SoftSDV/Lion, that would be ACPI.
  *
  * Setup of the IPI irq handler is done in irq.c:init_IRQ_SMP().
@@ -854,7 +854,7 @@ init_smp_config(void)
 	} *ap_startup;
 	long sal_ret;
 
-	/* Tell SAL where to drop the AP's.  */
+	/* Tell SAL where to drop the APs.  */
 	ap_startup = (struct fptr *) start_ap;
 	sal_ret = ia64_sal_set_vectors(SAL_VECTOR_OS_BOOT_RENDEZ,
 				       ia64_tpa(ap_startup->fp), ia64_tpa(ap_startup->gp), 0, 0, 0, 0);
diff --git a/arch/ia64/kernel/time.c b/arch/ia64/kernel/time.c
index a06667c..bf7e7b5 100644
--- a/arch/ia64/kernel/time.c
+++ b/arch/ia64/kernel/time.c
@@ -216,7 +216,7 @@ ia64_init_itm (void)
 #ifdef CONFIG_SMP
 		/* On IA64 in an SMP configuration ITCs are never accurately synchronized.
 		 * Jitter compensation requires a cmpxchg which may limit
-		 * the scalability of the syscalls for retrieving time.
+		 * the scalibility of the syscalls for retrieving time.
 		 * The ITC synchronization is usually successful to within a few
 		 * ITC ticks but this is not a sure thing. If you need to improve
 		 * timer performance in SMP situations then boot the kernel with the
diff --git a/arch/ia64/kernel/traps.c b/arch/ia64/kernel/traps.c
index b8e0d70..15ad85d 100644
--- a/arch/ia64/kernel/traps.c
+++ b/arch/ia64/kernel/traps.c
@@ -304,7 +304,7 @@ handle_fpu_swa (int fp_fault, struct pt_regs *regs, unsigned long isr)
 			 * Lower 4 bits are used as a count. Upper bits are a sequence
 			 * number that is updated when count is reset. The cmpxchg will
 			 * fail is seqno has changed. This minimizes mutiple cpus
-			 * reseting the count.
+			 * resetting the count.
 			 */
 			if (current_jiffies > last.time)
 				(void) cmpxchg_acq(&last.count, count, 16 + (count & ~15));
diff --git a/arch/ia64/kernel/unwind.c b/arch/ia64/kernel/unwind.c
index fe14262..7d3dd6c 100644
--- a/arch/ia64/kernel/unwind.c
+++ b/arch/ia64/kernel/unwind.c
@@ -2,7 +2,7 @@
  * Copyright (C) 1999-2004 Hewlett-Packard Co
  *	David Mosberger-Tang <davidm@hpl.hp.com>
  * Copyright (C) 2003 Fenghua Yu <fenghua.yu@intel.com>
- * 	- Change pt_regs_off() to make it less dependant on pt_regs structure.
+ * 	- Change pt_regs_off() to make it less dependent on pt_regs structure.
  */
 /*
  * This file implements call frame unwind support for the Linux
diff --git a/arch/ia64/mm/discontig.c b/arch/ia64/mm/discontig.c
index 9484444..9868be4 100644
--- a/arch/ia64/mm/discontig.c
+++ b/arch/ia64/mm/discontig.c
@@ -317,7 +317,7 @@ static void __meminit scatter_node_data(void)
 	 * node_online_map is not set for hot-added nodes at this time,
 	 * because we are halfway through initialization of the new node's
 	 * structures.  If for_each_online_node() is used, a new node's
-	 * pg_data_ptrs will be not initialized. Insted of using it,
+	 * pg_data_ptrs will be not initialized. Instead of using it,
 	 * pgdat_list[] is checked.
 	 */
 	for_each_node(node) {
diff --git a/arch/ia64/sn/kernel/bte.c b/arch/ia64/sn/kernel/bte.c
index ff1c556..b362d6d 100644
--- a/arch/ia64/sn/kernel/bte.c
+++ b/arch/ia64/sn/kernel/bte.c
@@ -63,7 +63,7 @@ static inline void bte_start_transfer(struct bteinfo_s *bte, u64 len, u64 mode)
  * Use the block transfer engine to move kernel memory from src to dest
  * using the assigned mode.
  *
- * Paramaters:
+ * Parameters:
  *   src - physical address of the transfer source.
  *   dest - physical address of the transfer destination.
  *   len - number of bytes to transfer from source to dest.
@@ -247,7 +247,7 @@ EXPORT_SYMBOL(bte_copy);
  * use the block transfer engine to move kernel
  * memory from src to dest using the assigned mode.
  *
- * Paramaters:
+ * Parameters:
  *   src - physical address of the transfer source.
  *   dest - physical address of the transfer destination.
  *   len - number of bytes to transfer from source to dest.
@@ -255,7 +255,7 @@ EXPORT_SYMBOL(bte_copy);
  *          for IBCT0/1 in the SGI documentation.
  *
  * NOTE: If the source, dest, and len are all cache line aligned,
- * then it would be _FAR_ preferrable to use bte_copy instead.
+ * then it would be _FAR_ preferable to use bte_copy instead.
  */
 bte_result_t bte_unaligned_copy(u64 src, u64 dest, u64 len, u64 mode)
 {
@@ -300,7 +300,7 @@ bte_result_t bte_unaligned_copy(u64 src, u64 dest, u64 len, u64 mode)
 	 * a standard bte copy.
 	 *
 	 * One nasty exception to the above rule is when the
-	 * source and destination are not symetrically
+	 * source and destination are not symmetrically
 	 * mis-aligned.  If the source offset from the first
 	 * cache line is different from the destination offset,
 	 * we make the first section be the entire transfer
@@ -337,7 +337,7 @@ bte_result_t bte_unaligned_copy(u64 src, u64 dest, u64 len, u64 mode)
 
 			if (footBcopyDest = (headBcopyDest + headBcopyLen)) {
 				/*
-				 * We have two contigous bcopy
+				 * We have two contiguous bcopy
 				 * blocks.  Merge them.
 				 */
 				headBcopyLen += footBcopyLen;
@@ -375,7 +375,7 @@ bte_result_t bte_unaligned_copy(u64 src, u64 dest, u64 len, u64 mode)
 	} else {
 
 		/*
-		 * The transfer is not symetric, we will
+		 * The transfer is not symmetric, we will
 		 * allocate a buffer large enough for all the
 		 * data, bte_copy into that buffer and then
 		 * bcopy to the destination.
diff --git a/arch/ia64/sn/kernel/bte_error.c b/arch/ia64/sn/kernel/bte_error.c
index b6fcf81..27c5936 100644
--- a/arch/ia64/sn/kernel/bte_error.c
+++ b/arch/ia64/sn/kernel/bte_error.c
@@ -105,7 +105,7 @@ int shub1_bte_error_handler(unsigned long _nodepda)
 	}
 
 	BTE_PRINTK(("eh:%p:%d Cleaning up\n", err_nodepda, smp_processor_id()));
-	/* Reenable both bte interfaces */
+	/* Re-enable both bte interfaces */
 	imem.ii_imem_regval = REMOTE_HUB_L(nasid, IIO_IMEM);
 	imem.ii_imem_fld_s.i_b0_esd = imem.ii_imem_fld_s.i_b1_esd = 1;
 	REMOTE_HUB_S(nasid, IIO_IMEM, imem.ii_imem_regval);
@@ -243,7 +243,7 @@ bte_crb_error_handler(cnodeid_t cnode, int btenum,
 
 	/*
 	 * The caller has already figured out the error type, we save that
-	 * in the bte handle structure for the thread excercising the
+	 * in the bte handle structure for the thread exercising the
 	 * interface to consume.
 	 */
 	bte->bh_error = ioe->ie_errortype + BTEFAIL_OFFSET;
diff --git a/arch/ia64/sn/kernel/io_common.c b/arch/ia64/sn/kernel/io_common.c
index d48bcd8..450caa3 100644
--- a/arch/ia64/sn/kernel/io_common.c
+++ b/arch/ia64/sn/kernel/io_common.c
@@ -479,7 +479,7 @@ sn_io_early_init(void)
 	}
 
 	/*
-	 * prime sn_pci_provider[].  Individial provider init routines will
+	 * prime sn_pci_provider[].  Individual provider init routines will
 	 * override their respective default entries.
 	 */
 
diff --git a/arch/ia64/sn/kernel/setup.c b/arch/ia64/sn/kernel/setup.c
index a9bed5c..a574fcd 100644
--- a/arch/ia64/sn/kernel/setup.c
+++ b/arch/ia64/sn/kernel/setup.c
@@ -167,7 +167,7 @@ void __init early_sn_setup(void)
 	 * IO on SN2 is done via SAL calls, early_printk won't work without this.
 	 *
 	 * This code duplicates some of the ACPI table parsing that is in efi.c & sal.c.
-	 * Any changes to those file may have to be made hereas well.
+	 * Any changes to those file may have to be made here as well.
 	 */
 	efi_systab = (efi_system_table_t *) __va(ia64_boot_param->efi_systab);
 	config_tables = __va(efi_systab->tables);
diff --git a/arch/ia64/sn/kernel/sn2/sn2_smp.c b/arch/ia64/sn/kernel/sn2/sn2_smp.c
index 5d318b5..033c8a9 100644
--- a/arch/ia64/sn/kernel/sn2/sn2_smp.c
+++ b/arch/ia64/sn/kernel/sn2/sn2_smp.c
@@ -104,7 +104,7 @@ static inline unsigned long wait_piowc(void)
  *
  * SN2 PIO writes from separate CPUs are not guaranteed to arrive in order.
  * Context switching user threads which have memory-mapped MMIO may cause
- * PIOs to issue from seperate CPUs, thus the PIO writes must be drained
+ * PIOs to issue from separate CPUs, thus the PIO writes must be drained
  * from the previous CPU's Shub before execution resumes on the new CPU.
  */
 void sn_migrate(struct task_struct *task)
diff --git a/arch/ia64/sn/kernel/xpc_channel.c b/arch/ia64/sn/kernel/xpc_channel.c
index c08db9c..44ccc0d 100644
--- a/arch/ia64/sn/kernel/xpc_channel.c
+++ b/arch/ia64/sn/kernel/xpc_channel.c
@@ -293,7 +293,7 @@ xpc_pull_remote_cachelines(struct xpc_partition *part, void *dst,
 
 
 /*
- * Pull the remote per partititon specific variables from the specified
+ * Pull the remote per partition specific variables from the specified
  * partition.
  */
 enum xpc_retval
@@ -461,7 +461,7 @@ xpc_allocate_local_msgqueue(struct xpc_channel *ch)
 	// >>> may want to check for ch->flags & XPC_C_DISCONNECTING between
 	// >>> iterations of the for-loop, bail if set?
 
-	// >>> should we impose a minumum #of entries? like 4 or 8?
+	// >>> should we impose a minimum #of entries? like 4 or 8?
 	for (nentries = ch->local_nentries; nentries > 0; nentries--) {
 
 		nbytes = nentries * ch->msg_size;
@@ -514,7 +514,7 @@ xpc_allocate_remote_msgqueue(struct xpc_channel *ch)
 	// >>> may want to check for ch->flags & XPC_C_DISCONNECTING between
 	// >>> iterations of the for-loop, bail if set?
 
-	// >>> should we impose a minumum #of entries? like 4 or 8?
+	// >>> should we impose a minimum #of entries? like 4 or 8?
 	for (nentries = ch->remote_nentries; nentries > 0; nentries--) {
 
 		nbytes = nentries * ch->msg_size;
@@ -1478,7 +1478,7 @@ xpc_teardown_infrastructure(struct xpc_partition *part)
 
 
 	/*
-	 * Before proceding with the teardown we have to wait until all
+	 * Before proceeding with the teardown we have to wait until all
 	 * existing references cease.
 	 */
 	wait_event(part->teardown_wq, (atomic_read(&part->references) = 0));
diff --git a/arch/ia64/sn/kernel/xpnet.c b/arch/ia64/sn/kernel/xpnet.c
index 88fad85..4226bdb 100644
--- a/arch/ia64/sn/kernel/xpnet.c
+++ b/arch/ia64/sn/kernel/xpnet.c
@@ -531,7 +531,7 @@ xpnet_dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	dev_dbg(xpnet, "destination Partitions mask (dp) = 0x%lx\n", dp);
 
 	/*
-	 * If we wanted to allow promiscous mode to work like an
+	 * If we wanted to allow promiscuous mode to work like an
 	 * unswitched network, this would be a good point to OR in a
 	 * mask of partitions which should be receiving all packets.
 	 */
diff --git a/arch/ia64/sn/pci/pci_dma.c b/arch/ia64/sn/pci/pci_dma.c
index 7a291a2..d79ddac 100644
--- a/arch/ia64/sn/pci/pci_dma.c
+++ b/arch/ia64/sn/pci/pci_dma.c
@@ -333,7 +333,7 @@ int sn_pci_legacy_read(struct pci_bus *bus, u16 port, u32 *val, u8 size)
 	/*
 	 * First, try the SN_SAL_IOIF_PCI_SAFE SAL call which can work
 	 * around hw issues at the pci bus level.  SGI proms older than
-	 * 4.10 don't implment this.
+	 * 4.10 don't implement this.
 	 */
 
 	SAL_CALL(isrv, SN_SAL_IOIF_PCI_SAFE,
@@ -348,7 +348,7 @@ int sn_pci_legacy_read(struct pci_bus *bus, u16 port, u32 *val, u8 size)
 	/*
 	 * If the above failed, retry using the SAL_PROBE call which should
 	 * be present in all proms (but which cannot work round PCI chipset
-	 * bugs).  This code is retained for compatability with old
+	 * bugs).  This code is retained for compatibility with old
 	 * pre-4.10 proms, and should be removed at some point in the future.
 	 */
 
@@ -379,7 +379,7 @@ int sn_pci_legacy_write(struct pci_bus *bus, u16 port, u32 val, u8 size)
 	/*
 	 * First, try the SN_SAL_IOIF_PCI_SAFE SAL call which can work
 	 * around hw issues at the pci bus level.  SGI proms older than
-	 * 4.10 don't implment this.
+	 * 4.10 don't implement this.
 	 */
 
 	SAL_CALL(isrv, SN_SAL_IOIF_PCI_SAFE,
@@ -394,7 +394,7 @@ int sn_pci_legacy_write(struct pci_bus *bus, u16 port, u32 val, u8 size)
 	/*
 	 * If the above failed, retry using the SAL_PROBE call which should
 	 * be present in all proms (but which cannot work round PCI chipset
-	 * bugs).  This code is retained for compatability with old
+	 * bugs).  This code is retained for compatibility with old
 	 * pre-4.10 proms, and should be removed at some point in the future.
 	 */
 
diff --git a/arch/ia64/sn/pci/pcibr/pcibr_ate.c b/arch/ia64/sn/pci/pcibr/pcibr_ate.c
index 935029f..239b3ce 100644
--- a/arch/ia64/sn/pci/pcibr/pcibr_ate.c
+++ b/arch/ia64/sn/pci/pcibr/pcibr_ate.c
@@ -30,7 +30,7 @@ static void mark_ate(struct ate_resource *ate_resource, int start, int number,
 
 /*
  * find_free_ate:  Find the first free ate index starting from the given
- *		   index for the desired consequtive count.
+ *		   index for the desired consecutive count.
  */
 static int find_free_ate(struct ate_resource *ate_resource, int start,
 			 int count)
@@ -88,7 +88,7 @@ static inline int alloc_ate_resource(struct ate_resource *ate_resource,
 		return -1;
 
 	/*
-	 * Find the required number of free consequtive ates.
+	 * Find the required number of free consecutive ates.
 	 */
 	start_index  	    find_free_ate(ate_resource, ate_resource->lowest_free_index,
@@ -105,7 +105,7 @@ static inline int alloc_ate_resource(struct ate_resource *ate_resource,
 /*
  * Allocate "count" contiguous Bridge Address Translation Entries
  * on the specified bridge to be used for PCI to XTALK mappings.
- * Indices in rm map range from 1..num_entries.  Indicies returned
+ * Indices in rm map range from 1..num_entries.  Indices returned
  * to caller range from 0..num_entries-1.
  *
  * Return the start index on success, -1 on failure.
diff --git a/arch/ia64/sn/pci/pcibr/pcibr_dma.c b/arch/ia64/sn/pci/pcibr/pcibr_dma.c
index 95af40c..e626e50 100644
--- a/arch/ia64/sn/pci/pcibr/pcibr_dma.c
+++ b/arch/ia64/sn/pci/pcibr/pcibr_dma.c
@@ -201,7 +201,7 @@ pcibr_dmatrans_direct32(struct pcidev_info * info,
 }
 
 /*
- * Wrapper routine for free'ing DMA maps
+ * Wrapper routine for freeing DMA maps
  * DMA mappings for Direct 64 and 32 do not have any DMA maps.
  */
 void
diff --git a/arch/ia64/sn/pci/tioca_provider.c b/arch/ia64/sn/pci/tioca_provider.c
index 8a2cb4e..b9bedbd 100644
--- a/arch/ia64/sn/pci/tioca_provider.c
+++ b/arch/ia64/sn/pci/tioca_provider.c
@@ -223,7 +223,7 @@ tioca_fastwrite_enable(struct tioca_kernel *tioca_kern)
 
 	/*
 	 * Scan all vga controllers on this bus making sure they all
-	 * suport FW.  If not, return.
+	 * support FW.  If not, return.
 	 */
 
 	list_for_each_entry(pdev, tioca_kern->ca_devices, bus_list) {
@@ -364,7 +364,7 @@ tioca_dma_d48(struct pci_dev *pdev, u64 paddr)
  * @req_size: len (bytes) to map
  *
  * Map @paddr into CA address space using the GART mechanism.  The mapped
- * dma_addr_t is guarenteed to be contiguous in CA bus space.
+ * dma_addr_t is guaranteed to be contiguous in CA bus space.
  */
 static dma_addr_t
 tioca_dma_mapped(struct pci_dev *pdev, u64 paddr, size_t req_size)
@@ -526,7 +526,7 @@ tioca_dma_map(struct pci_dev *pdev, u64 paddr, size_t byte_count, int dma_flags)
 		return 0;
 
 	/*
-	 * If card is 64 or 48 bit addresable, use a direct mapping.  32
+	 * If card is 64 or 48 bit addressable, use a direct mapping.  32
 	 * bit direct is so restrictive w.r.t. where the memory resides that
 	 * we don't use it even though CA has some support.
 	 */
diff --git a/arch/ia64/sn/pci/tioce_provider.c b/arch/ia64/sn/pci/tioce_provider.c
index 35f854f..f4c0b96 100644
--- a/arch/ia64/sn/pci/tioce_provider.c
+++ b/arch/ia64/sn/pci/tioce_provider.c
@@ -256,9 +256,9 @@ pcidev_to_tioce(struct pci_dev *pdev, struct tioce __iomem **base,
  * @ct_addr: the coretalk address to map
  * @len: number of bytes to map
  *
- * Given the addressing type, set up various paramaters that define the
+ * Given the addressing type, set up various parameters that define the
  * ATE pool to use.  Search for a contiguous block of entries to cover the
- * length, and if enough resources exist, fill in the ATE's and construct a
+ * length, and if enough resources exist, fill in the ATEs and construct a
  * tioce_dmamap struct to track the mapping.
  */
 static u64
@@ -581,8 +581,8 @@ tioce_do_dma_map(struct pci_dev *pdev, u64 paddr, size_t byte_count,
 	 */
 	if (!mapaddr && !barrier && dma_mask >= 0xffffffffffUL) {
 		/*
-		 * We have two options for 40-bit mappings:  16GB "super" ATE's
-		 * and 64MB "regular" ATE's.  We'll try both if needed for a
+		 * We have two options for 40-bit mappings:  16GB "super" ATEs
+		 * and 64MB "regular" ATEs.  We'll try both if needed for a
 		 * given mapping but which one we try first depends on the
 		 * size.  For requests >64MB, prefer to use a super page with
 		 * regular as the fallback. Otherwise, try in the reverse order.
@@ -687,8 +687,8 @@ tioce_error_intr_handler(int irq, void *arg)
 }
 
 /**
- * tioce_reserve_m32 - reserve M32 ate's for the indicated address range
- * @tioce_kernel: TIOCE context to reserve ate's for
+ * tioce_reserve_m32 - reserve M32 ATEs for the indicated address range
+ * @tioce_kernel: TIOCE context to reserve ATEs for
  * @base: starting bus address to reserve
  * @limit: last bus address to reserve
  *
@@ -763,7 +763,7 @@ tioce_kern_init(struct tioce_common *tioce_common)
 
 	/*
 	 * Set PMU pagesize to the largest size available, and zero out
-	 * the ate's.
+	 * the ATEs.
 	 */
 
 	tioce_mmr = (struct tioce __iomem *)tioce_common->ce_pcibus.bs_base;
@@ -784,7 +784,7 @@ tioce_kern_init(struct tioce_common *tioce_common)
 	}
 
 	/*
-	 * Reserve ATE's corresponding to reserved address ranges.  These
+	 * Reserve ATEs corresponding to reserved address ranges.  These
 	 * include:
 	 *
 	 *	Memory space covered by each PPB mem base/limit register
-- 
1.5.0.1

-- 
Simon Arlott
