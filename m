From: Keshavamurthy Anil S <anil.s.keshavamurthy@intel.com>
Date: Tue, 29 Aug 2006 18:08:56 +0000
Subject: Move perfmon tables from thread_struct to pfm_context
Message-Id: <20060829110856.A23515@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This patch renders thread_struct->pmcs[] and thread_struct->pmds[]
OBSOLETE. The actual table is moved to pfm_context structure which 
is the right thing to do. Also this will in future avoid KABI breakages
for the distro as well when the table size changes.

This patch has been tested on Montecito and did not have any issues.

Please apply this patch to your tree.

Signed-off-by: Stephane Eranian <eranian@hpl.hp.com>
Signed-off-by: Anil S Keshavamurthy <anil.s.keshavamurthy@intel.com>

 arch/ia64/kernel/perfmon.c   |  111 ++++++++++++++++++-------------------------
 include/asm-ia64/processor.h |   10 +--
 2 files changed, 51 insertions(+), 70 deletions(-)

Index: anil/arch/ia64/kernel/perfmon.c
=================================--- anil.orig/arch/ia64/kernel/perfmon.c
+++ anil/arch/ia64/kernel/perfmon.c
@@ -62,6 +62,9 @@
 
 #define PFM_INVALID_ACTIVATION	(~0UL)
 
+#define PFM_NUM_PMC_REGS	64	/* PMC save area for ctxsw */
+#define PFM_NUM_PMD_REGS	64	/* PMD save area for ctxsw */
+
 /*
  * depth of message queue
  */
@@ -296,14 +299,17 @@ typedef struct pfm_context {
 	unsigned long		ctx_reload_pmcs[4];	/* bitmask of force reload PMC on ctxsw in */
 	unsigned long		ctx_used_monitors[4];	/* bitmask of monitor PMC being used */
 
-	unsigned long		ctx_pmcs[IA64_NUM_PMC_REGS];	/*  saved copies of PMC values */
+	unsigned long		ctx_pmcs[PFM_NUM_PMC_REGS];	/*  saved copies of PMC values */
 
 	unsigned int		ctx_used_ibrs[1];		/* bitmask of used IBR (speedup ctxsw in) */
 	unsigned int		ctx_used_dbrs[1];		/* bitmask of used DBR (speedup ctxsw in) */
 	unsigned long		ctx_dbrs[IA64_NUM_DBG_REGS];	/* DBR values (cache) when not loaded */
 	unsigned long		ctx_ibrs[IA64_NUM_DBG_REGS];	/* IBR values (cache) when not loaded */
 
-	pfm_counter_t		ctx_pmds[IA64_NUM_PMD_REGS]; /* software state for PMDS */
+	pfm_counter_t		ctx_pmds[PFM_NUM_PMD_REGS]; /* software state for PMDS */
+
+	unsigned long		th_pmcs[PFM_NUM_PMC_REGS];	/* PMC thread save state */
+	unsigned long		th_pmds[PFM_NUM_PMD_REGS];	/* PMD thread save state */
 
 	u64			ctx_saved_psr_up;	/* only contains psr.up value */
 
@@ -867,7 +873,6 @@ static void
 pfm_mask_monitoring(struct task_struct *task)
 {
 	pfm_context_t *ctx = PFM_GET_CTX(task);
-	struct thread_struct *th = &task->thread;
 	unsigned long mask, val, ovfl_mask;
 	int i;
 
@@ -888,7 +893,7 @@ pfm_mask_monitoring(struct task_struct *
 	 * So in both cases, the live register contains the owner's
 	 * state. We can ONLY touch the PMU registers and NOT the PSR.
 	 *
-	 * As a consequence to this call, the thread->pmds[] array
+	 * As a consequence to this call, the ctx->th_pmds[] array
 	 * contains stale information which must be ignored
 	 * when context is reloaded AND monitoring is active (see
 	 * pfm_restart).
@@ -923,9 +928,9 @@ pfm_mask_monitoring(struct task_struct *
 	mask = ctx->ctx_used_monitors[0] >> PMU_FIRST_COUNTER;
 	for(i= PMU_FIRST_COUNTER; mask; i++, mask>>=1) {
 		if ((mask & 0x1) = 0UL) continue;
-		ia64_set_pmc(i, th->pmcs[i] & ~0xfUL);
-		th->pmcs[i] &= ~0xfUL;
-		DPRINT_ovfl(("pmc[%d]=0x%lx\n", i, th->pmcs[i]));
+		ia64_set_pmc(i, ctx->th_pmcs[i] & ~0xfUL);
+		ctx->th_pmcs[i] &= ~0xfUL;
+		DPRINT_ovfl(("pmc[%d]=0x%lx\n", i, ctx->th_pmcs[i]));
 	}
 	/*
 	 * make all of this visible
@@ -942,7 +947,6 @@ static void
 pfm_restore_monitoring(struct task_struct *task)
 {
 	pfm_context_t *ctx = PFM_GET_CTX(task);
-	struct thread_struct *th = &task->thread;
 	unsigned long mask, ovfl_mask;
 	unsigned long psr, val;
 	int i, is_system;
@@ -1008,9 +1012,9 @@ pfm_restore_monitoring(struct task_struc
 	mask = ctx->ctx_used_monitors[0] >> PMU_FIRST_COUNTER;
 	for(i= PMU_FIRST_COUNTER; mask; i++, mask>>=1) {
 		if ((mask & 0x1) = 0UL) continue;
-		th->pmcs[i] = ctx->ctx_pmcs[i];
-		ia64_set_pmc(i, th->pmcs[i]);
-		DPRINT(("[%d] pmc[%d]=0x%lx\n", task->pid, i, th->pmcs[i]));
+		ctx->th_pmcs[i] = ctx->ctx_pmcs[i];
+		ia64_set_pmc(i, ctx->th_pmcs[i]);
+		DPRINT(("[%d] pmc[%d]=0x%lx\n", task->pid, i, ctx->th_pmcs[i]));
 	}
 	ia64_srlz_d();
 
@@ -1069,7 +1073,6 @@ pfm_restore_pmds(unsigned long *pmds, un
 static inline void
 pfm_copy_pmds(struct task_struct *task, pfm_context_t *ctx)
 {
-	struct thread_struct *thread = &task->thread;
 	unsigned long ovfl_val = pmu_conf->ovfl_val;
 	unsigned long mask = ctx->ctx_all_pmds[0];
 	unsigned long val;
@@ -1091,11 +1094,11 @@ pfm_copy_pmds(struct task_struct *task, 
 			ctx->ctx_pmds[i].val = val & ~ovfl_val;
 			 val &= ovfl_val;
 		}
-		thread->pmds[i] = val;
+		ctx->th_pmds[i] = val;
 
 		DPRINT(("pmd[%d]=0x%lx soft_val=0x%lx\n",
 			i,
-			thread->pmds[i],
+			ctx->th_pmds[i],
 			ctx->ctx_pmds[i].val));
 	}
 }
@@ -1106,7 +1109,6 @@ pfm_copy_pmds(struct task_struct *task, 
 static inline void
 pfm_copy_pmcs(struct task_struct *task, pfm_context_t *ctx)
 {
-	struct thread_struct *thread = &task->thread;
 	unsigned long mask = ctx->ctx_all_pmcs[0];
 	int i;
 
@@ -1114,8 +1116,8 @@ pfm_copy_pmcs(struct task_struct *task, 
 
 	for (i=0; mask; i++, mask>>=1) {
 		/* masking 0 with ovfl_val yields 0 */
-		thread->pmcs[i] = ctx->ctx_pmcs[i];
-		DPRINT(("pmc[%d]=0x%lx\n", i, thread->pmcs[i]));
+		ctx->th_pmcs[i] = ctx->ctx_pmcs[i];
+		DPRINT(("pmc[%d]=0x%lx\n", i, ctx->th_pmcs[i]));
 	}
 }
 
@@ -2859,7 +2861,6 @@ pfm_reset_regs(pfm_context_t *ctx, unsig
 static int
 pfm_write_pmcs(pfm_context_t *ctx, void *arg, int count, struct pt_regs *regs)
 {
-	struct thread_struct *thread = NULL;
 	struct task_struct *task;
 	pfarg_reg_t *req = (pfarg_reg_t *)arg;
 	unsigned long value, pmc_pm;
@@ -2880,7 +2881,6 @@ pfm_write_pmcs(pfm_context_t *ctx, void 
 	if (state = PFM_CTX_ZOMBIE) return -EINVAL;
 
 	if (is_loaded) {
-		thread = &task->thread;
 		/*
 		 * In system wide and when the context is loaded, access can only happen
 		 * when the caller is running on the CPU being monitored by the session.
@@ -3035,7 +3035,7 @@ pfm_write_pmcs(pfm_context_t *ctx, void 
 		 *
 		 * The value in ctx_pmcs[] can only be changed in pfm_write_pmcs().
 		 *
-		 * The value in thread->pmcs[] may be modified on overflow, i.e.,  when
+		 * The value in th_pmcs[] may be modified on overflow, i.e.,  when
 		 * monitoring needs to be stopped.
 		 */
 		if (is_monitor) CTX_USED_MONITOR(ctx, 1UL << cnum);
@@ -3049,7 +3049,7 @@ pfm_write_pmcs(pfm_context_t *ctx, void 
 			/*
 			 * write thread state
 			 */
-			if (is_system = 0) thread->pmcs[cnum] = value;
+			if (is_system = 0) ctx->th_pmcs[cnum] = value;
 
 			/*
 			 * write hardware register if we can
@@ -3101,7 +3101,6 @@ error:
 static int
 pfm_write_pmds(pfm_context_t *ctx, void *arg, int count, struct pt_regs *regs)
 {
-	struct thread_struct *thread = NULL;
 	struct task_struct *task;
 	pfarg_reg_t *req = (pfarg_reg_t *)arg;
 	unsigned long value, hw_value, ovfl_mask;
@@ -3125,7 +3124,6 @@ pfm_write_pmds(pfm_context_t *ctx, void 
 	 * the owner of the local PMU.
 	 */
 	if (likely(is_loaded)) {
-		thread = &task->thread;
 		/*
 		 * In system wide and when the context is loaded, access can only happen
 		 * when the caller is running on the CPU being monitored by the session.
@@ -3233,7 +3231,7 @@ pfm_write_pmds(pfm_context_t *ctx, void 
 			/*
 		 	 * write thread state
 		 	 */
-			if (is_system = 0) thread->pmds[cnum] = hw_value;
+			if (is_system = 0) ctx->th_pmds[cnum] = hw_value;
 
 			/*
 			 * write hardware register if we can
@@ -3299,7 +3297,6 @@ abort_mission:
 static int
 pfm_read_pmds(pfm_context_t *ctx, void *arg, int count, struct pt_regs *regs)
 {
-	struct thread_struct *thread = NULL;
 	struct task_struct *task;
 	unsigned long val = 0UL, lval, ovfl_mask, sval;
 	pfarg_reg_t *req = (pfarg_reg_t *)arg;
@@ -3323,7 +3320,6 @@ pfm_read_pmds(pfm_context_t *ctx, void *
 	if (state = PFM_CTX_ZOMBIE) return -EINVAL;
 
 	if (likely(is_loaded)) {
-		thread = &task->thread;
 		/*
 		 * In system wide and when the context is loaded, access can only happen
 		 * when the caller is running on the CPU being monitored by the session.
@@ -3385,7 +3381,7 @@ pfm_read_pmds(pfm_context_t *ctx, void *
 			 * if context is zombie, then task does not exist anymore.
 			 * In this case, we use the full value saved in the context (pfm_flush_regs()).
 			 */
-			val = is_loaded ? thread->pmds[cnum] : 0UL;
+			val = is_loaded ? ctx->th_pmds[cnum] : 0UL;
 		}
 		rd_func = pmu_conf->pmd_desc[cnum].read_check;
 
@@ -4354,8 +4350,8 @@ pfm_context_load(pfm_context_t *ctx, voi
 	pfm_copy_pmds(task, ctx);
 	pfm_copy_pmcs(task, ctx);
 
-	pmcs_source = thread->pmcs;
-	pmds_source = thread->pmds;
+	pmcs_source = ctx->th_pmcs;
+	pmds_source = ctx->th_pmds;
 
 	/*
 	 * always the case for system-wide
@@ -5862,14 +5858,12 @@ void
 pfm_save_regs(struct task_struct *task)
 {
 	pfm_context_t *ctx;
-	struct thread_struct *t;
 	unsigned long flags;
 	u64 psr;
 
 
 	ctx = PFM_GET_CTX(task);
 	if (ctx = NULL) return;
-	t = &task->thread;
 
 	/*
  	 * we always come here with interrupts ALREADY disabled by
@@ -5927,19 +5921,19 @@ pfm_save_regs(struct task_struct *task)
 	 * guarantee we will be schedule at that same
 	 * CPU again.
 	 */
-	pfm_save_pmds(t->pmds, ctx->ctx_used_pmds[0]);
+	pfm_save_pmds(ctx->th_pmds, ctx->ctx_used_pmds[0]);
 
 	/*
 	 * save pmc0 ia64_srlz_d() done in pfm_save_pmds()
 	 * we will need it on the restore path to check
 	 * for pending overflow.
 	 */
-	t->pmcs[0] = ia64_get_pmc(0);
+	ctx->th_pmcs[0] = ia64_get_pmc(0);
 
 	/*
 	 * unfreeze PMU if had pending overflows
 	 */
-	if (t->pmcs[0] & ~0x1UL) pfm_unfreeze_pmu();
+	if (ctx->th_pmcs[0] & ~0x1UL) pfm_unfreeze_pmu();
 
 	/*
 	 * finally, allow context access.
@@ -5984,7 +5978,6 @@ static void
 pfm_lazy_save_regs (struct task_struct *task)
 {
 	pfm_context_t *ctx;
-	struct thread_struct *t;
 	unsigned long flags;
 
 	{ u64 psr  = pfm_get_psr();
@@ -5992,7 +5985,6 @@ pfm_lazy_save_regs (struct task_struct *
 	}
 
 	ctx = PFM_GET_CTX(task);
-	t   = &task->thread;
 
 	/*
 	 * we need to mask PMU overflow here to
@@ -6024,12 +6016,12 @@ pfm_lazy_save_regs (struct task_struct *
 	 * it is needed to check for pended overflow
 	 * on the restore path
 	 */
-	t->pmcs[0] = ia64_get_pmc(0);
+	ctx->th_pmcs[0] = ia64_get_pmc(0);
 
 	/*
 	 * unfreeze PMU if had pending overflows
 	 */
-	if (t->pmcs[0] & ~0x1UL) pfm_unfreeze_pmu();
+	if (ctx->th_pmcs[0] & ~0x1UL) pfm_unfreeze_pmu();
 
 	/*
 	 * now get can unmask PMU interrupts, they will
@@ -6048,7 +6040,6 @@ void
 pfm_load_regs (struct task_struct *task)
 {
 	pfm_context_t *ctx;
-	struct thread_struct *t;
 	unsigned long pmc_mask = 0UL, pmd_mask = 0UL;
 	unsigned long flags;
 	u64 psr, psr_up;
@@ -6059,11 +6050,10 @@ pfm_load_regs (struct task_struct *task)
 
 	BUG_ON(GET_PMU_OWNER());
 
-	t     = &task->thread;
 	/*
 	 * possible on unload
 	 */
-	if (unlikely((t->flags & IA64_THREAD_PM_VALID) = 0)) return;
+	if (unlikely((task->thread.flags & IA64_THREAD_PM_VALID) = 0)) return;
 
 	/*
  	 * we always come here with interrupts ALREADY disabled by
@@ -6145,21 +6135,21 @@ pfm_load_regs (struct task_struct *task)
 	 *
 	 * XXX: optimize here
 	 */
-	if (pmd_mask) pfm_restore_pmds(t->pmds, pmd_mask);
-	if (pmc_mask) pfm_restore_pmcs(t->pmcs, pmc_mask);
+	if (pmd_mask) pfm_restore_pmds(ctx->th_pmds, pmd_mask);
+	if (pmc_mask) pfm_restore_pmcs(ctx->th_pmcs, pmc_mask);
 
 	/*
 	 * check for pending overflow at the time the state
 	 * was saved.
 	 */
-	if (unlikely(PMC0_HAS_OVFL(t->pmcs[0]))) {
+	if (unlikely(PMC0_HAS_OVFL(ctx->th_pmcs[0]))) {
 		/*
 		 * reload pmc0 with the overflow information
 		 * On McKinley PMU, this will trigger a PMU interrupt
 		 */
-		ia64_set_pmc(0, t->pmcs[0]);
+		ia64_set_pmc(0, ctx->th_pmcs[0]);
 		ia64_srlz_d();
-		t->pmcs[0] = 0UL;
+		ctx->th_pmcs[0] = 0UL;
 
 		/*
 		 * will replay the PMU interrupt
@@ -6212,7 +6202,6 @@ pfm_load_regs (struct task_struct *task)
 void
 pfm_load_regs (struct task_struct *task)
 {
-	struct thread_struct *t;
 	pfm_context_t *ctx;
 	struct task_struct *owner;
 	unsigned long pmd_mask, pmc_mask;
@@ -6221,7 +6210,6 @@ pfm_load_regs (struct task_struct *task)
 
 	owner = GET_PMU_OWNER();
 	ctx   = PFM_GET_CTX(task);
-	t     = &task->thread;
 	psr   = pfm_get_psr();
 
 	BUG_ON(psr & (IA64_PSR_UP|IA64_PSR_PP));
@@ -6284,22 +6272,22 @@ pfm_load_regs (struct task_struct *task)
 	 */
 	pmc_mask = ctx->ctx_all_pmcs[0];
 
-	pfm_restore_pmds(t->pmds, pmd_mask);
-	pfm_restore_pmcs(t->pmcs, pmc_mask);
+	pfm_restore_pmds(ctx->th_pmds, pmd_mask);
+	pfm_restore_pmcs(ctx->th_pmcs, pmc_mask);
 
 	/*
 	 * check for pending overflow at the time the state
 	 * was saved.
 	 */
-	if (unlikely(PMC0_HAS_OVFL(t->pmcs[0]))) {
+	if (unlikely(PMC0_HAS_OVFL(ctx->th_pmcs[0]))) {
 		/*
 		 * reload pmc0 with the overflow information
 		 * On McKinley PMU, this will trigger a PMU interrupt
 		 */
-		ia64_set_pmc(0, t->pmcs[0]);
+		ia64_set_pmc(0, ctx->th_pmcs[0]);
 		ia64_srlz_d();
 
-		t->pmcs[0] = 0UL;
+		ctx->th_pmcs[0] = 0UL;
 
 		/*
 		 * will replay the PMU interrupt
@@ -6374,11 +6362,11 @@ pfm_flush_pmds(struct task_struct *task,
 		 */
 		pfm_unfreeze_pmu();
 	} else {
-		pmc0 = task->thread.pmcs[0];
+		pmc0 = ctx->th_pmcs[0];
 		/*
 		 * clear whatever overflow status bits there were
 		 */
-		task->thread.pmcs[0] = 0;
+		ctx->th_pmcs[0] = 0;
 	}
 	ovfl_val = pmu_conf->ovfl_val;
 	/*
@@ -6399,7 +6387,7 @@ pfm_flush_pmds(struct task_struct *task,
 		/*
 		 * can access PMU always true in system wide mode
 		 */
-		val = pmd_val = can_access_pmu ? ia64_get_pmd(i) : task->thread.pmds[i];
+		val = pmd_val = can_access_pmu ? ia64_get_pmd(i) : ctx->th_pmds[i];
 
 		if (PMD_IS_COUNTING(i)) {
 			DPRINT(("[%d] pmd[%d] ctx_pmd=0x%lx hw_pmd=0x%lx\n",
@@ -6431,7 +6419,7 @@ pfm_flush_pmds(struct task_struct *task,
 
 		DPRINT(("[%d] ctx_pmd[%d]=0x%lx  pmd_val=0x%lx\n", task->pid, i, val, pmd_val));
 
-		if (is_self) task->thread.pmds[i] = pmd_val;
+		if (is_self) ctx->th_pmds[i] = pmd_val;
 
 		ctx->ctx_pmds[i].val = val;
 	}
@@ -6675,7 +6663,7 @@ pfm_init(void)
 	       ffz(pmu_conf->ovfl_val));
 
 	/* sanity check */
-	if (pmu_conf->num_pmds >= IA64_NUM_PMD_REGS || pmu_conf->num_pmcs >= IA64_NUM_PMC_REGS) {
+	if (pmu_conf->num_pmds >= PFM_NUM_PMD_REGS || pmu_conf->num_pmcs >= PFM_NUM_PMC_REGS) {
 		printk(KERN_ERR "perfmon: not enough pmc/pmd, perfmon disabled\n");
 		pmu_conf = NULL;
 		return -1;
@@ -6750,7 +6738,6 @@ void
 dump_pmu_state(const char *from)
 {
 	struct task_struct *task;
-	struct thread_struct *t;
 	struct pt_regs *regs;
 	pfm_context_t *ctx;
 	unsigned long psr, dcr, info, flags;
@@ -6795,16 +6782,14 @@ dump_pmu_state(const char *from)
 	ia64_psr(regs)->up = 0;
 	ia64_psr(regs)->pp = 0;
 
-	t = &current->thread;
-
 	for (i=1; PMC_IS_LAST(i) = 0; i++) {
 		if (PMC_IS_IMPL(i) = 0) continue;
-		printk("->CPU%d pmc[%d]=0x%lx thread_pmc[%d]=0x%lx\n", this_cpu, i, ia64_get_pmc(i), i, t->pmcs[i]);
+		printk("->CPU%d pmc[%d]=0x%lx thread_pmc[%d]=0x%lx\n", this_cpu, i, ia64_get_pmc(i), i, ctx->th_pmcs[i]);
 	}
 
 	for (i=1; PMD_IS_LAST(i) = 0; i++) {
 		if (PMD_IS_IMPL(i) = 0) continue;
-		printk("->CPU%d pmd[%d]=0x%lx thread_pmd[%d]=0x%lx\n", this_cpu, i, ia64_get_pmd(i), i, t->pmds[i]);
+		printk("->CPU%d pmd[%d]=0x%lx thread_pmd[%d]=0x%lx\n", this_cpu, i, ia64_get_pmd(i), i, ctx->th_pmds[i]);
 	}
 
 	if (ctx) {
Index: anil/include/asm-ia64/processor.h
=================================--- anil.orig/include/asm-ia64/processor.h
+++ anil/include/asm-ia64/processor.h
@@ -24,8 +24,8 @@
  * Limits for PMC and PMD are set to less than maximum architected values
  * but should be sufficient for a while
  */
-#define IA64_NUM_PMC_REGS	64
-#define IA64_NUM_PMD_REGS	64
+#define IA64_NUM_PMC_REGS	32 /* obsolete: replaced by PFM_NUM_PMC_REGS */
+#define IA64_NUM_PMD_REGS	32 /* obsolete: replaced by PFM_NUM_PMC_REGS */
 
 #define DEFAULT_MAP_BASE	__IA64_UL_CONST(0x2000000000000000)
 #define DEFAULT_TASK_SIZE	__IA64_UL_CONST(0xa000000000000000)
@@ -262,13 +262,9 @@ struct thread_struct {
 # define INIT_THREAD_IA32
 #endif /* CONFIG_IA32_SUPPORT */
 #ifdef CONFIG_PERFMON
-	__u64 pmcs[IA64_NUM_PMC_REGS];
-	__u64 pmds[IA64_NUM_PMD_REGS];
 	void *pfm_context;		     /* pointer to detailed PMU context */
 	unsigned long pfm_needs_checking;    /* when >0, pending perfmon work on kernel exit */
-# define INIT_THREAD_PM		.pmcs =			{0UL, },  \
-				.pmds =			{0UL, },  \
-				.pfm_context =		NULL,     \
+# define INIT_THREAD_PM		.pfm_context =		NULL,     \
 				.pfm_needs_checking =	0UL,
 #else
 # define INIT_THREAD_PM
