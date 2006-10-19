From: Russ Anderson <rja@sgi.com>
Date: Thu, 19 Oct 2006 20:57:20 +0000
Subject: Re: [PATCH] - Fix get_model_name() for mixed cpu type systems
Message-Id: <200610192057.k9JKvLgD20044289@clink.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20061018212559.GA2965@sgi.com>
In-Reply-To: <20061018212559.GA2965@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Stephane Eranian wrote:
> 
> Yes, it could work for very simple measurements. The CPU_CYCLES is a good example, though
> the event on Montecito as a different name (by same encoding). But it gets more tricky as soon
> as you try accessing PMU registers outside the range of architected registers, i.e., outside
> PMC4-7/PMD4-7. There there are big differences. Montecito has 12 counters, Madison has 4.
> All the extended features, such as opcode matching, range restrictions use differnet registers
> between the 2 models.
> 
> Perfmon detects the cpu type using cpuid only once during initialization. So it depends
> on which CPU executes the initialization. The only common set guaranteed to work the same
> way is PMC4-7/PMD4-7 and events CPU_CYCLES and INSTRUCTION_RETIRED.

Stephane,

Attached is a test patch for supporting mixed CPUs.  It changes pmu_conf to
an array, to keep track of the different CPU characteristics.  At initialization
information is saved for each of the CPUs.

Routines have been modified to access the corresponding CPU information.  There
are likely mistakes accessing the correct CPU, but it is a start.

It boots on a mixed CPU system.  I can help test.

Thanks,


Debugging output:
--------------------------------------------------------------------------
Brought up 11 CPUs
Total of 11 processors activated (26955.76 BogoMIPS).
[...]
perfmon: version 2.0 IRQ 238
perfmon: Montecito PMU detected, 27 PMCs, 35 PMDs, 12 counters (47 bits)
perfmon: Montecito PMU detected, 27 PMCs, 35 PMDs, 12 counters (47 bits)
perfmon: Montecito PMU detected, 27 PMCs, 35 PMDs, 12 counters (47 bits)
perfmon: Montecito PMU detected, 27 PMCs, 35 PMDs, 12 counters (47 bits)
perfmon: Itanium 2 PMU detected, 16 PMCs, 18 PMDs, 4 counters (47 bits)
perfmon: Itanium 2 PMU detected, 16 PMCs, 18 PMDs, 4 counters (47 bits)
perfmon: Itanium 2 PMU detected, 16 PMCs, 18 PMDs, 4 counters (47 bits)
perfmon: Montecito PMU detected, 27 PMCs, 35 PMDs, 12 counters (47 bits)
perfmon: Montecito PMU detected, 27 PMCs, 35 PMDs, 12 counters (47 bits)
perfmon: Montecito PMU detected, 27 PMCs, 35 PMDs, 12 counters (47 bits)
perfmon: Montecito PMU detected, 27 PMCs, 35 PMDs, 12 counters (47 bits)
PAL Information Facility v0.5
perfmon: added sampling format default_format
perfmon_default_smpl: default_format v2.0 registered
Please use IA-32 EL for executing IA-32 binaries
--------------------------------------------------------------------------



The patch:
--------------------------------------------------------------------------
---
 arch/ia64/kernel/perfmon.c |  228 ++++++++++++++++++++++-----------------------
 1 file changed, 116 insertions(+), 112 deletions(-)

Index: test/arch/ia64/kernel/perfmon.c
=================================--- test.orig/arch/ia64/kernel/perfmon.c	2006-10-19 11:27:13.319047123 -0500
+++ test/arch/ia64/kernel/perfmon.c	2006-10-19 15:25:40.267661775 -0500
@@ -92,25 +92,25 @@
 #define	PFM_REG_CONFIG		(0x8<<4|PFM_REG_IMPL) /* configuration register */
 #define PFM_REG_BUFFER	 	(0xc<<4|PFM_REG_IMPL) /* PMD used as buffer */
 
-#define PMC_IS_LAST(i)	(pmu_conf->pmc_desc[i].type & PFM_REG_END)
-#define PMD_IS_LAST(i)	(pmu_conf->pmd_desc[i].type & PFM_REG_END)
+#define PMC_IS_LAST(_cpu, i)	(pmu_conf[_cpu]->pmc_desc[i].type & PFM_REG_END)
+#define PMD_IS_LAST(_cpu, i)	(pmu_conf[_cpu]->pmd_desc[i].type & PFM_REG_END)
 
 #define PMC_OVFL_NOTIFY(ctx, i)	((ctx)->ctx_pmds[i].flags &  PFM_REGFL_OVFL_NOTIFY)
 
 /* i assumed unsigned */
-#define PMC_IS_IMPL(i)	  (i< PMU_MAX_PMCS && (pmu_conf->pmc_desc[i].type & PFM_REG_IMPL))
-#define PMD_IS_IMPL(i)	  (i< PMU_MAX_PMDS && (pmu_conf->pmd_desc[i].type & PFM_REG_IMPL))
+#define PMC_IS_IMPL(_cpu, i)	(i< PMU_MAX_PMCS && (pmu_conf[_cpu]->pmc_desc[i].type & PFM_REG_IMPL))
+#define PMD_IS_IMPL(_cpu, i)	(i< PMU_MAX_PMDS && (pmu_conf[_cpu]->pmd_desc[i].type & PFM_REG_IMPL))
 
 /* XXX: these assume that register i is implemented */
-#define PMD_IS_COUNTING(i) ((pmu_conf->pmd_desc[i].type & PFM_REG_COUNTING) = PFM_REG_COUNTING)
-#define PMC_IS_COUNTING(i) ((pmu_conf->pmc_desc[i].type & PFM_REG_COUNTING) = PFM_REG_COUNTING)
-#define PMC_IS_MONITOR(i)  ((pmu_conf->pmc_desc[i].type & PFM_REG_MONITOR)  = PFM_REG_MONITOR)
-#define PMC_IS_CONTROL(i)  ((pmu_conf->pmc_desc[i].type & PFM_REG_CONTROL)  = PFM_REG_CONTROL)
-
-#define PMC_DFL_VAL(i)     pmu_conf->pmc_desc[i].default_value
-#define PMC_RSVD_MASK(i)   pmu_conf->pmc_desc[i].reserved_mask
-#define PMD_PMD_DEP(i)	   pmu_conf->pmd_desc[i].dep_pmd[0]
-#define PMC_PMD_DEP(i)	   pmu_conf->pmc_desc[i].dep_pmd[0]
+#define PMD_IS_COUNTING(_cpu, i) ((pmu_conf[_cpu]->pmd_desc[i].type & PFM_REG_COUNTING) = PFM_REG_COUNTING)
+#define PMC_IS_COUNTING(_cpu, i) ((pmu_conf[_cpu]->pmc_desc[i].type & PFM_REG_COUNTING) = PFM_REG_COUNTING)
+#define PMC_IS_MONITOR(_cpu, i)  ((pmu_conf[_cpu]->pmc_desc[i].type & PFM_REG_MONITOR)  = PFM_REG_MONITOR)
+#define PMC_IS_CONTROL(_cpu, i)  ((pmu_conf[_cpu]->pmc_desc[i].type & PFM_REG_CONTROL)  = PFM_REG_CONTROL)
+
+#define PMC_DFL_VAL(i)     pmu_conf[smp_processor_id()]->pmc_desc[i].default_value
+#define PMC_RSVD_MASK(i)   pmu_conf[smp_processor_id()]->pmc_desc[i].reserved_mask
+#define PMD_PMD_DEP(i)	   pmu_conf[smp_processor_id()]->pmd_desc[i].dep_pmd[0]
+#define PMC_PMD_DEP(i)	   pmu_conf[smp_processor_id()]->pmc_desc[i].dep_pmd[0]
 
 #define PFM_NUM_IBRS	  IA64_NUM_DBG_REGS
 #define PFM_NUM_DBRS	  IA64_NUM_DBG_REGS
@@ -343,6 +343,7 @@ typedef struct pfm_context {
 
 #define PFM_GET_CTX(t)	 	((pfm_context_t *)(t)->thread.pfm_context)
 
+#define CTX_CPU			(ctx)->ctx_cpu
 #ifdef CONFIG_SMP
 #define SET_LAST_CPU(ctx, v)	(ctx)->ctx_last_cpu = (v)
 #define GET_LAST_CPU(ctx)	(ctx)->ctx_last_cpu
@@ -397,7 +398,7 @@ typedef struct {
 } pfm_reg_desc_t;
 
 /* assume cnum is a valid monitor */
-#define PMC_PM(cnum, val)	(((val) >> (pmu_conf->pmc_desc[cnum].pm_pos)) & 0x1)
+#define PMC_PM(cnum, val)	(((val) >> (pmu_conf[smp_processor_id()]->pmc_desc[cnum].pm_pos)) & 0x1)
 
 /*
  * This structure is initialized at boot time and contains
@@ -514,7 +515,7 @@ static pfm_uuid_t		pfm_null_uuid = {0,};
 static spinlock_t		pfm_buffer_fmt_lock;
 static LIST_HEAD(pfm_buffer_fmt_list);
 
-static pmu_config_t		*pmu_conf;
+static pmu_config_t		*pmu_conf[NR_CPUS];
 
 /* sysctl() controls */
 pfm_sysctl_t pfm_sysctl;
@@ -737,7 +738,7 @@ pfm_restore_dbrs(unsigned long *dbrs, un
 static inline unsigned long
 pfm_read_soft_counter(pfm_context_t *ctx, int i)
 {
-	return ctx->ctx_pmds[i].val + (ia64_get_pmd(i) & pmu_conf->ovfl_val);
+	return ctx->ctx_pmds[i].val + (ia64_get_pmd(i) & pmu_conf[CTX_CPU]->ovfl_val);
 }
 
 /*
@@ -746,7 +747,7 @@ pfm_read_soft_counter(pfm_context_t *ctx
 static inline void
 pfm_write_soft_counter(pfm_context_t *ctx, int i, unsigned long val)
 {
-	unsigned long ovfl_val = pmu_conf->ovfl_val;
+	unsigned long ovfl_val = pmu_conf[CTX_CPU]->ovfl_val;
 
 	ctx->ctx_pmds[i].val = val  & ~ovfl_val;
 	/*
@@ -879,7 +880,7 @@ pfm_mask_monitoring(struct task_struct *
 
 	DPRINT_ovfl(("masking monitoring for [%d]\n", task->pid));
 
-	ovfl_mask = pmu_conf->ovfl_val;
+	ovfl_mask = pmu_conf[CTX_CPU]->ovfl_val;
 	/*
 	 * monitoring can only be masked as a result of a valid
 	 * counter overflow. In UP, it means that the PMU still
@@ -905,7 +906,7 @@ pfm_mask_monitoring(struct task_struct *
 		if ((mask & 0x1) = 0) continue;
 		val = ia64_get_pmd(i);
 
-		if (PMD_IS_COUNTING(i)) {
+		if (PMD_IS_COUNTING(CTX_CPU, i)) {
 			/*
 		 	 * we rebuild the full 64 bit value of the counter
 		 	 */
@@ -953,7 +954,7 @@ pfm_restore_monitoring(struct task_struc
 	int i, is_system;
 
 	is_system = ctx->ctx_fl_system;
-	ovfl_mask = pmu_conf->ovfl_val;
+	ovfl_mask = pmu_conf[CTX_CPU]->ovfl_val;
 
 	if (task != current) {
 		printk(KERN_ERR "perfmon.%d: invalid task[%d] current[%d]\n", __LINE__, task->pid, current->pid);
@@ -990,7 +991,7 @@ pfm_restore_monitoring(struct task_struc
 		/* skip non used pmds */
 		if ((mask & 0x1) = 0) continue;
 
-		if (PMD_IS_COUNTING(i)) {
+		if (PMD_IS_COUNTING(CTX_CPU, i)) {
 			/*
 			 * we split the 64bit value according to
 			 * counter width
@@ -1024,8 +1025,8 @@ pfm_restore_monitoring(struct task_struc
 	 * XXX: need to optimize 
 	 */
 	if (ctx->ctx_fl_using_dbreg) {
-		pfm_restore_ibrs(ctx->ctx_ibrs, pmu_conf->num_ibrs);
-		pfm_restore_dbrs(ctx->ctx_dbrs, pmu_conf->num_dbrs);
+		pfm_restore_ibrs(ctx->ctx_ibrs, pmu_conf[smp_processor_id()]->num_ibrs);
+		pfm_restore_dbrs(ctx->ctx_dbrs, pmu_conf[smp_processor_id()]->num_dbrs);
 	}
 
 	/*
@@ -1055,14 +1056,14 @@ pfm_save_pmds(unsigned long *pmds, unsig
  * reload from thread state (used for ctxw only)
  */
 static inline void
-pfm_restore_pmds(unsigned long *pmds, unsigned long mask)
+pfm_restore_pmds(unsigned long *pmds, unsigned int cpu, unsigned long mask)
 {
 	int i;
-	unsigned long val, ovfl_val = pmu_conf->ovfl_val;
+	unsigned long val, ovfl_val = pmu_conf[cpu]->ovfl_val;
 
 	for (i=0; mask; i++, mask>>=1) {
 		if ((mask & 0x1) = 0) continue;
-		val = PMD_IS_COUNTING(i) ? pmds[i] & ovfl_val : pmds[i];
+		val = PMD_IS_COUNTING(cpu, i) ? pmds[i] & ovfl_val : pmds[i];
 		ia64_set_pmd(i, val);
 	}
 	ia64_srlz_d();
@@ -1074,7 +1075,7 @@ pfm_restore_pmds(unsigned long *pmds, un
 static inline void
 pfm_copy_pmds(struct task_struct *task, pfm_context_t *ctx)
 {
-	unsigned long ovfl_val = pmu_conf->ovfl_val;
+	unsigned long ovfl_val = pmu_conf[CTX_CPU]->ovfl_val;
 	unsigned long mask = ctx->ctx_all_pmds[0];
 	unsigned long val;
 	int i;
@@ -1091,7 +1092,7 @@ pfm_copy_pmds(struct task_struct *task, 
 		 * thread (will be reloaded on ctxsw in).
 		 * The upper part stays in the soft-counter.
 		 */
-		if (PMD_IS_COUNTING(i)) {
+		if (PMD_IS_COUNTING(CTX_CPU, i)) {
 			ctx->ctx_pmds[i].val = val & ~ovfl_val;
 			 val &= ovfl_val;
 		}
@@ -2484,13 +2485,13 @@ error:
 static void
 pfm_reset_pmu_state(pfm_context_t *ctx)
 {
-	int i;
+	int i, cpu = smp_processor_id();
 
 	/*
 	 * install reset values for PMC.
 	 */
-	for (i=1; PMC_IS_LAST(i) = 0; i++) {
-		if (PMC_IS_IMPL(i) = 0) continue;
+	for (i=1; PMC_IS_LAST(cpu, i) = 0; i++) {
+		if (PMC_IS_IMPL(cpu, i) = 0) continue;
 		ctx->ctx_pmcs[i] = PMC_DFL_VAL(i);
 		DPRINT(("pmc[%d]=0x%lx\n", i, ctx->ctx_pmcs[i]));
 	}
@@ -2521,12 +2522,12 @@ pfm_reset_pmu_state(pfm_context_t *ctx)
 	  *
 	  * PMC0 is treated differently.
 	  */
-	ctx->ctx_all_pmcs[0] = pmu_conf->impl_pmcs[0] & ~0x1;
+	ctx->ctx_all_pmcs[0] = pmu_conf[cpu]->impl_pmcs[0] & ~0x1;
 
 	/*
 	 * bitmask of all PMDs that are accesible to this context
 	 */
-	ctx->ctx_all_pmds[0] = pmu_conf->impl_pmds[0];
+	ctx->ctx_all_pmds[0] = pmu_conf[cpu]->impl_pmds[0];
 
 	DPRINT(("<%d> all_pmcs=0x%lx all_pmds=0x%lx\n", ctx->ctx_fd, ctx->ctx_all_pmcs[0],ctx->ctx_all_pmds[0]));
 
@@ -2848,7 +2849,7 @@ pfm_reset_regs(pfm_context_t *ctx, unsig
 
 		val = pfm_new_counter_value(ctx->ctx_pmds + i, is_long_reset);
 
-		if (PMD_IS_COUNTING(i)) {
+		if (PMD_IS_COUNTING(CTX_CPU, i)) {
 			pfm_write_soft_counter(ctx, i, val);
 		} else {
 			ia64_set_pmd(i, val);
@@ -2877,7 +2878,7 @@ pfm_write_pmcs(pfm_context_t *ctx, void 
 	is_loaded = state = PFM_CTX_LOADED ? 1 : 0;
 	is_system = ctx->ctx_fl_system;
 	task      = ctx->ctx_task;
-	impl_pmds = pmu_conf->impl_pmds[0];
+	impl_pmds = pmu_conf[CTX_CPU]->impl_pmds[0];
 
 	if (state = PFM_CTX_ZOMBIE) return -EINVAL;
 
@@ -2910,8 +2911,8 @@ pfm_write_pmcs(pfm_context_t *ctx, void 
 			goto error;
 		}
 
-		pmc_type   = pmu_conf->pmc_desc[cnum].type;
-		pmc_pm     = (value >> pmu_conf->pmc_desc[cnum].pm_pos) & 0x1;
+		pmc_type   = pmu_conf[CTX_CPU]->pmc_desc[cnum].type;
+		pmc_pm     = (value >> pmu_conf[CTX_CPU]->pmc_desc[cnum].pm_pos) & 0x1;
 		is_counting = (pmc_type & PFM_REG_COUNTING) = PFM_REG_COUNTING ? 1 : 0;
 		is_monitor  = (pmc_type & PFM_REG_MONITOR) = PFM_REG_MONITOR ? 1 : 0;
 
@@ -2924,7 +2925,7 @@ pfm_write_pmcs(pfm_context_t *ctx, void 
 			DPRINT(("pmc%u is unimplemented or no-access pmc_type=%x\n", cnum, pmc_type));
 			goto error;
 		}
-		wr_func = pmu_conf->pmc_desc[cnum].write_check;
+		wr_func = pmu_conf[CTX_CPU]->pmc_desc[cnum].write_check;
 		/*
 		 * If the PMC is a monitor, then if the value is not the default:
 		 * 	- system-wide session: PMCx.pm=1 (privileged monitor)
@@ -3025,7 +3026,7 @@ pfm_write_pmcs(pfm_context_t *ctx, void 
 		 * PMD. Clearing is done indirectly via pfm_reset_pmu_state() so there is no
 		 * possible leak here.
 		 */
-		CTX_USED_PMD(ctx, pmu_conf->pmc_desc[cnum].dep_pmd[0]);
+		CTX_USED_PMD(ctx, pmu_conf[CTX_CPU]->pmc_desc[cnum].dep_pmd[0]);
 
 		/*
 		 * keep track of the monitor PMC that we are using.
@@ -3115,7 +3116,7 @@ pfm_write_pmds(pfm_context_t *ctx, void 
 	state     = ctx->ctx_state;
 	is_loaded = state = PFM_CTX_LOADED ? 1 : 0;
 	is_system = ctx->ctx_fl_system;
-	ovfl_mask = pmu_conf->ovfl_val;
+	ovfl_mask = pmu_conf[CTX_CPU]->ovfl_val;
 	task      = ctx->ctx_task;
 
 	if (unlikely(state = PFM_CTX_ZOMBIE)) return -EINVAL;
@@ -3143,12 +3144,12 @@ pfm_write_pmds(pfm_context_t *ctx, void 
 		cnum  = req->reg_num;
 		value = req->reg_value;
 
-		if (!PMD_IS_IMPL(cnum)) {
+		if (!PMD_IS_IMPL(CTX_CPU, cnum)) {
 			DPRINT(("pmd[%u] is unimplemented or invalid\n", cnum));
 			goto abort_mission;
 		}
-		is_counting = PMD_IS_COUNTING(cnum);
-		wr_func     = pmu_conf->pmd_desc[cnum].write_check;
+		is_counting = PMD_IS_COUNTING(CTX_CPU, cnum);
+		wr_func     = pmu_conf[CTX_CPU]->pmd_desc[cnum].write_check;
 
 		/*
 		 * execute write checker, if any
@@ -3315,7 +3316,7 @@ pfm_read_pmds(pfm_context_t *ctx, void *
 	state     = ctx->ctx_state;
 	is_loaded = state = PFM_CTX_LOADED ? 1 : 0;
 	is_system = ctx->ctx_fl_system;
-	ovfl_mask = pmu_conf->ovfl_val;
+	ovfl_mask = pmu_conf[CTX_CPU]->ovfl_val;
 	task      = ctx->ctx_task;
 
 	if (state = PFM_CTX_ZOMBIE) return -EINVAL;
@@ -3354,7 +3355,7 @@ pfm_read_pmds(pfm_context_t *ctx, void *
 		cnum        = req->reg_num;
 		reg_flags   = req->reg_flags;
 
-		if (unlikely(!PMD_IS_IMPL(cnum))) goto error;
+		if (unlikely(!PMD_IS_IMPL(CTX_CPU, cnum))) goto error;
 		/*
 		 * we can only read the register that we use. That includes
 		 * the one we explicitely initialize AND the one we want included
@@ -3367,7 +3368,7 @@ pfm_read_pmds(pfm_context_t *ctx, void *
 
 		sval        = ctx->ctx_pmds[cnum].val;
 		lval        = ctx->ctx_pmds[cnum].lval;
-		is_counting = PMD_IS_COUNTING(cnum);
+		is_counting = PMD_IS_COUNTING(CTX_CPU, cnum);
 
 		/*
 		 * If the task is not the current one, then we check if the
@@ -3384,7 +3385,7 @@ pfm_read_pmds(pfm_context_t *ctx, void *
 			 */
 			val = is_loaded ? ctx->th_pmds[cnum] : 0UL;
 		}
-		rd_func = pmu_conf->pmd_desc[cnum].read_check;
+		rd_func = pmu_conf[CTX_CPU]->pmd_desc[cnum].read_check;
 
 		if (is_counting) {
 			/*
@@ -3479,7 +3480,7 @@ pfm_use_debug_registers(struct task_stru
 	unsigned long flags;
 	int ret = 0;
 
-	if (pmu_conf->use_rr_dbregs = 0) return 0;
+	if (pmu_conf[CTX_CPU]->use_rr_dbregs = 0) return 0;
 
 	DPRINT(("called for [%d]\n", task->pid));
 
@@ -3530,10 +3531,11 @@ pfm_use_debug_registers(struct task_stru
 int
 pfm_release_debug_registers(struct task_struct *task)
 {
+	pfm_context_t *ctx = task->thread.pfm_context;
 	unsigned long flags;
 	int ret;
 
-	if (pmu_conf->use_rr_dbregs = 0) return 0;
+	if (pmu_conf[CTX_CPU]->use_rr_dbregs = 0) return 0;
 
 	LOCK_PFS(flags);
 	if (pfm_sessions.pfs_ptrace_use_dbregs = 0) {
@@ -3734,7 +3736,7 @@ pfm_write_ibr_dbr(int mode, pfm_context_
 	int i, can_access_pmu = 0;
 	int is_system, is_loaded;
 
-	if (pmu_conf->use_rr_dbregs = 0) return -EINVAL;
+	if (pmu_conf[CTX_CPU]->use_rr_dbregs = 0) return -EINVAL;
 
 	state     = ctx->ctx_state;
 	is_loaded = state = PFM_CTX_LOADED ? 1 : 0;
@@ -3816,12 +3818,12 @@ pfm_write_ibr_dbr(int mode, pfm_context_
  	 */
 	if (first_time && can_access_pmu) {
 		DPRINT(("[%d] clearing ibrs, dbrs\n", task->pid));
-		for (i=0; i < pmu_conf->num_ibrs; i++) {
+		for (i=0; i < pmu_conf[smp_processor_id()]->num_ibrs; i++) {
 			ia64_set_ibr(i, 0UL);
 			ia64_dv_serialize_instruction();
 		}
 		ia64_srlz_i();
-		for (i=0; i < pmu_conf->num_dbrs; i++) {
+		for (i=0; i < pmu_conf[smp_processor_id()]->num_dbrs; i++) {
 			ia64_set_dbr(i, 0UL);
 			ia64_dv_serialize_data();
 		}
@@ -4161,7 +4163,7 @@ pfm_get_pmc_reset(pfm_context_t *ctx, vo
 
 		cnum = req->reg_num;
 
-		if (!PMC_IS_IMPL(cnum)) goto abort_mission;
+		if (!PMC_IS_IMPL(CTX_CPU, cnum)) goto abort_mission;
 
 		req->reg_value = PMC_DFL_VAL(cnum);
 
@@ -4380,7 +4382,7 @@ pfm_context_load(pfm_context_t *ctx, voi
 		 * load all PMD from ctx to PMU (as opposed to thread state)
 		 * restore all PMC from ctx to PMU
 		 */
-		pfm_restore_pmds(pmds_source, ctx->ctx_all_pmds[0]);
+		pfm_restore_pmds(pmds_source, CTX_CPU, ctx->ctx_all_pmds[0]);
 		pfm_restore_pmcs(pmcs_source, ctx->ctx_all_pmcs[0]);
 
 		ctx->ctx_reload_pmcs[0] = 0UL;
@@ -4390,8 +4392,8 @@ pfm_context_load(pfm_context_t *ctx, voi
 		 * guaranteed safe by earlier check against DBG_VALID
 		 */
 		if (ctx->ctx_fl_using_dbreg) {
-			pfm_restore_ibrs(ctx->ctx_ibrs, pmu_conf->num_ibrs);
-			pfm_restore_dbrs(ctx->ctx_dbrs, pmu_conf->num_dbrs);
+			pfm_restore_ibrs(ctx->ctx_ibrs, pmu_conf[CTX_CPU]->num_ibrs);
+			pfm_restore_dbrs(ctx->ctx_dbrs, pmu_conf[CTX_CPU]->num_dbrs);
 		}
 		/*
 		 * set new ownership
@@ -4816,7 +4818,7 @@ sys_perfmonctl (int fd, int cmd, void __
 	/*
 	 * reject any call if perfmon was disabled at initialization
 	 */
-	if (unlikely(pmu_conf = NULL)) return -ENOSYS;
+	if (unlikely(pmu_conf[smp_processor_id()] = NULL)) return -ENOSYS;
 
 	if (unlikely(cmd < 0 || cmd >= PFM_CMD_COUNT)) {
 		DPRINT(("invalid cmd=%d\n", cmd));
@@ -5232,7 +5234,7 @@ pfm_overflow_handler(struct task_struct 
 
 	tstamp   = ia64_get_itc();
 	mask     = pmc0 >> PMU_FIRST_COUNTER;
-	ovfl_val = pmu_conf->ovfl_val;
+	ovfl_val = pmu_conf[smp_processor_id()]->ovfl_val;
 	has_smpl = CTX_HAS_SMPL(ctx);
 
 	DPRINT_ovfl(("pmc0=0x%lx pid=%d iip=0x%lx, %s "
@@ -5329,7 +5331,7 @@ pfm_overflow_handler(struct task_struct 
 			if (smpl_pmds) {
 				for(j=0, k=0; smpl_pmds; j++, smpl_pmds >>=1) {
 					if ((smpl_pmds & 0x1) = 0) continue;
-					ovfl_arg->smpl_pmds_values[k++] = PMD_IS_COUNTING(j) ?  pfm_read_soft_counter(ctx, j) : ia64_get_pmd(j);
+					ovfl_arg->smpl_pmds_values[k++] = PMD_IS_COUNTING(CTX_CPU, j) ?  pfm_read_soft_counter(ctx, j) : ia64_get_pmd(j);
 					DPRINT_ovfl(("smpl_pmd[%d]=pmd%u=0x%lx\n", k-1, j, ovfl_arg->smpl_pmds_values[k-1]));
 				}
 			}
@@ -5646,11 +5648,11 @@ pfm_proc_show_header(struct seq_file *m)
 		"ovfl_mask                 : 0x%lx\n"
 		"PMU flags                 : 0x%x\n",
 		PFM_VERSION_MAJ, PFM_VERSION_MIN,
-		pmu_conf->pmu_name,
+		pmu_conf[smp_processor_id()]->pmu_name,
 		pfm_sysctl.fastctxsw > 0 ? "Yes": "No",
 		pfm_sysctl.expert_mode > 0 ? "Yes": "No",
-		pmu_conf->ovfl_val,
-		pmu_conf->flags);
+		pmu_conf[smp_processor_id()]->ovfl_val,
+		pmu_conf[smp_processor_id()]->flags);
 
   	LOCK_PFS(flags);
 
@@ -5750,8 +5752,8 @@ pfm_proc_show(struct seq_file *m, void *
 			cpu, psr,
 			cpu, ia64_get_pmc(0));
 
-		for (i=0; PMC_IS_LAST(i) = 0;  i++) {
-			if (PMC_IS_COUNTING(i) = 0) continue;
+		for (i=0; PMC_IS_LAST(cpu, i) = 0;  i++) {
+			if (PMC_IS_COUNTING(cpu, i) = 0) continue;
    			seq_printf(m, 
 				"CPU%-2d pmc%u                : 0x%lx\n"
    				"CPU%-2d pmd%u                : 0x%lx\n", 
@@ -5777,10 +5779,10 @@ pfm_proc_open(struct inode *inode, struc
 
 
 /*
- * we come here as soon as local_cpu_data->pfm_syst_wide is set. this happens
+ * we come here as soon as cpu_data(cpu)->pfm_syst_wide is set. this happens
  * during pfm_enable() hence before pfm_start(). We cannot assume monitoring
  * is active or inactive based on mode. We must rely on the value in
- * local_cpu_data->pfm_syst_info
+ * cpu_data(cpu)->pfm_syst_info
  */
 void
 pfm_syst_wide_update_task(struct task_struct *task, unsigned long info, int is_ctxswin)
@@ -6067,7 +6069,7 @@ pfm_load_regs (struct task_struct *task)
 	flags = pfm_protect_ctx_ctxsw(ctx);
 	psr   = pfm_get_psr();
 
-	need_irq_resend = pmu_conf->flags & PFM_PMU_IRQ_RESEND;
+	need_irq_resend = pmu_conf[CTX_CPU]->flags & PFM_PMU_IRQ_RESEND;
 
 	BUG_ON(psr & (IA64_PSR_UP|IA64_PSR_PP));
 	BUG_ON(psr & IA64_PSR_I);
@@ -6094,8 +6096,8 @@ pfm_load_regs (struct task_struct *task)
 	 * stale state.
 	 */
 	if (ctx->ctx_fl_using_dbreg) {
-		pfm_restore_ibrs(ctx->ctx_ibrs, pmu_conf->num_ibrs);
-		pfm_restore_dbrs(ctx->ctx_dbrs, pmu_conf->num_dbrs);
+		pfm_restore_ibrs(ctx->ctx_ibrs, pmu_conf[CTX_CPU]->num_ibrs);
+		pfm_restore_dbrs(ctx->ctx_dbrs, pmu_conf[CTX_CPU]->num_dbrs);
 	}
 	/*
 	 * retrieve saved psr.up
@@ -6139,7 +6141,7 @@ pfm_load_regs (struct task_struct *task)
 	 *
 	 * XXX: optimize here
 	 */
-	if (pmd_mask) pfm_restore_pmds(ctx->th_pmds, pmd_mask);
+	if (pmd_mask) pfm_restore_pmds(ctx->th_pmds, CTX_CPU, pmd_mask);
 	if (pmc_mask) pfm_restore_pmcs(ctx->th_pmcs, pmc_mask);
 
 	/*
@@ -6160,7 +6162,7 @@ pfm_load_regs (struct task_struct *task)
 		 */
 		if (need_irq_resend) ia64_resend_irq(IA64_PERFMON_VECTOR);
 
-		pfm_stats[smp_processor_id()].pfm_replay_ovfl_intr_count++;
+		pfm_stats[CTX_CPU].pfm_replay_ovfl_intr_count++;
 	}
 
 	/*
@@ -6228,15 +6230,15 @@ pfm_load_regs (struct task_struct *task)
 	 * (not perfmon) by the previous task.
 	 */
 	if (ctx->ctx_fl_using_dbreg) {
-		pfm_restore_ibrs(ctx->ctx_ibrs, pmu_conf->num_ibrs);
-		pfm_restore_dbrs(ctx->ctx_dbrs, pmu_conf->num_dbrs);
+		pfm_restore_ibrs(ctx->ctx_ibrs, pmu_conf[CTX_CPU]->num_ibrs);
+		pfm_restore_dbrs(ctx->ctx_dbrs, pmu_conf[CTX_CPU]->num_dbrs);
 	}
 
 	/*
 	 * retrieved saved psr.up
 	 */
 	psr_up = ctx->ctx_saved_psr_up;
-	need_irq_resend = pmu_conf->flags & PFM_PMU_IRQ_RESEND;
+	need_irq_resend = pmu_conf[CTX_CPU]->flags & PFM_PMU_IRQ_RESEND;
 
 	/*
 	 * short path, our state is still there, just
@@ -6276,7 +6278,7 @@ pfm_load_regs (struct task_struct *task)
 	 */
 	pmc_mask = ctx->ctx_all_pmcs[0];
 
-	pfm_restore_pmds(ctx->th_pmds, pmd_mask);
+	pfm_restore_pmds(ctx->th_pmds, CTX_CPU, pmd_mask);
 	pfm_restore_pmcs(ctx->th_pmcs, pmc_mask);
 
 	/*
@@ -6372,7 +6374,7 @@ pfm_flush_pmds(struct task_struct *task,
 		 */
 		ctx->th_pmcs[0] = 0;
 	}
-	ovfl_val = pmu_conf->ovfl_val;
+	ovfl_val = pmu_conf[CTX_CPU]->ovfl_val;
 	/*
 	 * we save all the used pmds
 	 * we take care of overflows for counting PMDs
@@ -6393,7 +6395,7 @@ pfm_flush_pmds(struct task_struct *task,
 		 */
 		val = pmd_val = can_access_pmu ? ia64_get_pmd(i) : ctx->th_pmds[i];
 
-		if (PMD_IS_COUNTING(i)) {
+		if (PMD_IS_COUNTING(CTX_CPU, i)) {
 			DPRINT(("[%d] pmd[%d] ctx_pmd=0x%lx hw_pmd=0x%lx\n",
 				task->pid,
 				i,
@@ -6576,12 +6578,12 @@ EXPORT_SYMBOL_GPL(pfm_remove_alt_pmu_int
 static int init_pfm_fs(void);
 
 static int __init
-pfm_probe_pmu(void)
+pfm_probe_pmu(unsigned int cpu)
 {
 	pmu_config_t **p;
 	int family;
 
-	family = local_cpu_data->family;
+	family = cpu_data(cpu)->family;
 	p      = pmu_confs;
 
 	while(*p) {
@@ -6594,7 +6596,7 @@ pfm_probe_pmu(void)
 	}
 	return -1;
 found:
-	pmu_conf = *p;
+	pmu_conf[cpu] = *p;
 	return 0;
 }
 
@@ -6608,16 +6610,17 @@ static struct file_operations pfm_proc_f
 int __init
 pfm_init(void)
 {
-	unsigned int n, n_counters, i;
+	unsigned int n, n_counters, i, cpu;
 
 	printk("perfmon: version %u.%u IRQ %u\n",
 		PFM_VERSION_MAJ,
 		PFM_VERSION_MIN,
 		IA64_PERFMON_VECTOR);
 
-	if (pfm_probe_pmu()) {
+	for_each_online_cpu(cpu) {
+	if (pfm_probe_pmu(cpu)) {
 		printk(KERN_INFO "perfmon: disabled, there is no support for processor family %d\n", 
-				local_cpu_data->family);
+				cpu_data(cpu)->family);
 		return -ENODEV;
 	}
 
@@ -6626,60 +6629,61 @@ pfm_init(void)
 	 * description tables
 	 */
 	n = 0;
-	for (i=0; PMC_IS_LAST(i) = 0;  i++) {
-		if (PMC_IS_IMPL(i) = 0) continue;
-		pmu_conf->impl_pmcs[i>>6] |= 1UL << (i&63);
+	for (i=0; PMC_IS_LAST(cpu, i) = 0;  i++) {
+		if (PMC_IS_IMPL(cpu, i) = 0) continue;
+		pmu_conf[cpu]->impl_pmcs[i>>6] |= 1UL << (i&63);
 		n++;
 	}
-	pmu_conf->num_pmcs = n;
+	pmu_conf[cpu]->num_pmcs = n;
 
 	n = 0; n_counters = 0;
-	for (i=0; PMD_IS_LAST(i) = 0;  i++) {
-		if (PMD_IS_IMPL(i) = 0) continue;
-		pmu_conf->impl_pmds[i>>6] |= 1UL << (i&63);
+	for (i=0; PMD_IS_LAST(cpu, i) = 0;  i++) {
+		if (PMD_IS_IMPL(cpu, i) = 0) continue;
+		pmu_conf[cpu]->impl_pmds[i>>6] |= 1UL << (i&63);
 		n++;
-		if (PMD_IS_COUNTING(i)) n_counters++;
+		if (PMD_IS_COUNTING(cpu, i)) n_counters++;
 	}
-	pmu_conf->num_pmds      = n;
-	pmu_conf->num_counters  = n_counters;
+	pmu_conf[cpu]->num_pmds      = n;
+	pmu_conf[cpu]->num_counters  = n_counters;
 
 	/*
 	 * sanity checks on the number of debug registers
 	 */
-	if (pmu_conf->use_rr_dbregs) {
-		if (pmu_conf->num_ibrs > IA64_NUM_DBG_REGS) {
-			printk(KERN_INFO "perfmon: unsupported number of code debug registers (%u)\n", pmu_conf->num_ibrs);
-			pmu_conf = NULL;
+	if (pmu_conf[cpu]->use_rr_dbregs) {
+		if (pmu_conf[cpu]->num_ibrs > IA64_NUM_DBG_REGS) {
+			printk(KERN_INFO "perfmon: unsupported number of code debug registers (%u)\n", pmu_conf[cpu]->num_ibrs);
+			pmu_conf[cpu] = NULL;
 			return -1;
 		}
-		if (pmu_conf->num_dbrs > IA64_NUM_DBG_REGS) {
-			printk(KERN_INFO "perfmon: unsupported number of data debug registers (%u)\n", pmu_conf->num_ibrs);
-			pmu_conf = NULL;
+		if (pmu_conf[cpu]->num_dbrs > IA64_NUM_DBG_REGS) {
+			printk(KERN_INFO "perfmon: unsupported number of data debug registers (%u)\n", pmu_conf[cpu]->num_ibrs);
+			pmu_conf[cpu] = NULL;
 			return -1;
 		}
 	}
 
 	printk("perfmon: %s PMU detected, %u PMCs, %u PMDs, %u counters (%lu bits)\n",
-	       pmu_conf->pmu_name,
-	       pmu_conf->num_pmcs,
-	       pmu_conf->num_pmds,
-	       pmu_conf->num_counters,
-	       ffz(pmu_conf->ovfl_val));
+	       pmu_conf[cpu]->pmu_name,
+	       pmu_conf[cpu]->num_pmcs,
+	       pmu_conf[cpu]->num_pmds,
+	       pmu_conf[cpu]->num_counters,
+	       ffz(pmu_conf[cpu]->ovfl_val));
 
 	/* sanity check */
-	if (pmu_conf->num_pmds >= PFM_NUM_PMD_REGS || pmu_conf->num_pmcs >= PFM_NUM_PMC_REGS) {
+	if (pmu_conf[cpu]->num_pmds >= PFM_NUM_PMD_REGS || pmu_conf[cpu]->num_pmcs >= PFM_NUM_PMC_REGS) {
 		printk(KERN_ERR "perfmon: not enough pmc/pmd, perfmon disabled\n");
-		pmu_conf = NULL;
+		pmu_conf[cpu] = NULL;
 		return -1;
 	}
 
+	} 	/* for_each_online_cpu() */
 	/*
 	 * create /proc/perfmon (mostly for debugging purposes)
 	 */
  	perfmon_dir = create_proc_entry("perfmon", S_IRUGO, NULL);
 	if (perfmon_dir = NULL) {
 		printk(KERN_ERR "perfmon: cannot create /proc entry, perfmon disabled\n");
-		pmu_conf = NULL;
+		pmu_conf[smp_processor_id()] = NULL;
 		return -1;
 	}
   	/*
@@ -6786,13 +6790,13 @@ dump_pmu_state(const char *from)
 	ia64_psr(regs)->up = 0;
 	ia64_psr(regs)->pp = 0;
 
-	for (i=1; PMC_IS_LAST(i) = 0; i++) {
-		if (PMC_IS_IMPL(i) = 0) continue;
+	for (i=1; PMC_IS_LAST(this_cpu, i) = 0; i++) {
+		if (PMC_IS_IMPL(this_cpu, i) = 0) continue;
 		printk("->CPU%d pmc[%d]=0x%lx thread_pmc[%d]=0x%lx\n", this_cpu, i, ia64_get_pmc(i), i, ctx->th_pmcs[i]);
 	}
 
-	for (i=1; PMD_IS_LAST(i) = 0; i++) {
-		if (PMD_IS_IMPL(i) = 0) continue;
+	for (i=1; PMD_IS_LAST(this_cpu, i) = 0; i++) {
+		if (PMD_IS_IMPL(this_cpu, i) = 0) continue;
 		printk("->CPU%d pmd[%d]=0x%lx thread_pmd[%d]=0x%lx\n", this_cpu, i, ia64_get_pmd(i), i, ctx->th_pmds[i]);
 	}
 

-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
