From: Stephane Eranian <eranian@hpl.hp.com>
Date: Wed, 16 Apr 2003 21:50:33 +0000
Subject: Re: [Linux-ia64] [BUG] perfmon doesn't send SIGPROF in kernel 2.5.64
MIME-Version: 1
Content-Type: multipart/mixed; boundary="k1lZvvs/B4yU6o8G"
Message-Id: <marc-linux-ia64-105590723705517@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705454@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705454@msgid-missing>
To: linux-ia64@vger.kernel.org

--k1lZvvs/B4yU6o8G
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Eric,

On Fri, Apr 11, 2003 at 04:33:33PM +0200, Eric Piel wrote:
> > Let me know how it goes, especially on SMP.
> For now I would say it doesn't work :-( I get the same results from
> realfeel4 than before.

Yes, it does not work. I found the source of the problem and it is 
pretty subtle especially in system-wide mode. The deferred notification
does not work with kernel only threads which is likely what you have 
running in system-wide mode with a mostly idle system.

The attached patch against 2.5.67 corrects the problem. Note that this
patch also includes other updates.

Let me know how it goes.

-- 
-Stephane

--k1lZvvs/B4yU6o8G
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="perfmon-2.5-030416"

diff -Nur --exclude=SCCS --exclude=BitKeeper --exclude=ChangeSet bk-official-extra/arch/ia64/kernel/perfmon.c bk-base/arch/ia64/kernel/perfmon.c
--- bk-official-extra/arch/ia64/kernel/perfmon.c	Thu Apr 10 14:01:35 2003
+++ bk-base/arch/ia64/kernel/perfmon.c	Tue Apr 15 15:58:21 2003
@@ -225,8 +225,9 @@
 	unsigned int protected:1;	/* allow access to creator of context only */
 	unsigned int using_dbreg:1;	/* using range restrictions (debug registers) */
 	unsigned int excl_idle:1;	/* exclude idle task in system wide session */
+	unsigned int unsecure:1;	/* sp = 0 for non self-monitored task */
 	unsigned int trap_reason:2;	/* reason for going into pfm_block_ovfl_reset() */
-	unsigned int reserved:21;
+	unsigned int reserved:20;
 } pfm_context_flags_t;
 
 #define PFM_TRAP_REASON_NONE		0x0	/* default value */
@@ -279,6 +280,7 @@
 #define ctx_fl_using_dbreg	ctx_flags.using_dbreg
 #define ctx_fl_excl_idle	ctx_flags.excl_idle
 #define ctx_fl_trap_reason	ctx_flags.trap_reason
+#define ctx_fl_unsecure		ctx_flags.unsecure
 
 /*
  * global information about all sessions
@@ -1077,10 +1079,15 @@
 		 * and it must be a valid CPU
 		 */
 		cpu = ffz(~pfx->ctx_cpu_mask);
+#ifdef CONFIG_SMP
 		if (cpu_online(cpu) == 0) {
+#else
+		if (cpu != 0) {
+#endif
 			DBprintk(("CPU%d is not online\n", cpu));
 			return -EINVAL;
 		}
+
 		/*
 		 * check for pre-existing pinning, if conflicting reject
 		 */
@@ -1226,6 +1233,7 @@
 	ctx->ctx_fl_block     = (ctx_flags & PFM_FL_NOTIFY_BLOCK) ? 1 : 0;
 	ctx->ctx_fl_system    = (ctx_flags & PFM_FL_SYSTEM_WIDE) ? 1: 0;
 	ctx->ctx_fl_excl_idle = (ctx_flags & PFM_FL_EXCL_IDLE) ? 1: 0;
+	ctx->ctx_fl_unsecure  = (ctx_flags & PFM_FL_UNSECURE) ? 1: 0;
 	ctx->ctx_fl_frozen    = 0;
 	ctx->ctx_fl_trap_reason = PFM_TRAP_REASON_NONE;
 
@@ -1252,9 +1260,11 @@
 	DBprintk(("context=%p, pid=%d notify_task=%p\n",
 			(void *)ctx, task->pid, ctx->ctx_notify_task));
 
-	DBprintk(("context=%p, pid=%d flags=0x%x inherit=%d block=%d system=%d excl_idle=%d\n", 
+	DBprintk(("context=%p, pid=%d flags=0x%x inherit=%d block=%d system=%d excl_idle=%d unsecure=%d\n", 
 			(void *)ctx, task->pid, ctx_flags, ctx->ctx_fl_inherit, 
-			ctx->ctx_fl_block, ctx->ctx_fl_system, ctx->ctx_fl_excl_idle));
+			ctx->ctx_fl_block, ctx->ctx_fl_system, 
+			ctx->ctx_fl_excl_idle,
+			ctx->ctx_fl_unsecure));
 
 	/*
 	 * when no notification is required, we can make this visible at the last moment
@@ -1883,7 +1893,10 @@
 		DBprintk(("unblocking %d \n", task->pid));
 		up(sem);
 	} else {
+		struct thread_info *info = (struct thread_info *) ((char *) task + IA64_TASK_SIZE);
 		task->thread.pfm_ovfl_block_reset = 1;
+		ctx->ctx_fl_trap_reason = PFM_TRAP_REASON_RESET;
+		set_bit(TIF_NOTIFY_RESUME, &info->flags);
 	}
 #if 0
 	/*
@@ -2052,7 +2065,7 @@
 	/*
 	 * reinforce secure monitoring: cannot toggle psr.up
 	 */
-	ia64_psr(regs)->sp = 1;
+	if (ctx->ctx_fl_unsecure == 0) ia64_psr(regs)->sp = 1;
 
 	return 0;
 }
@@ -2733,12 +2746,13 @@
 	 * again
 	 */
 	th->pfm_ovfl_block_reset = 0;
+	clear_thread_flag(TIF_NOTIFY_RESUME);
 
 	/*
 	 * do some sanity checks first
 	 */
 	if (!ctx) {
-		printk(KERN_DEBUG "perfmon: [%d] has no PFM context\n", current->pid);
+		printk(KERN_ERR "perfmon: [%d] has no PFM context\n", current->pid);
 		return;
 	}
 	/*
@@ -2901,14 +2915,17 @@
 /*
  * main overflow processing routine.
  * it can be called from the interrupt path or explicitely during the context switch code
+ * Arguments:
+ *	mode: 0=coming from PMU interrupt, 1=coming from ctxsw 
+ *	
  * Return:
  *	new value of pmc[0]. if 0x0 then unfreeze, else keep frozen
  */
 static unsigned long
-pfm_overflow_handler(struct task_struct *task, pfm_context_t *ctx, u64 pmc0, struct pt_regs *regs)
+pfm_overflow_handler(int mode, struct task_struct *task, pfm_context_t *ctx, u64 pmc0, struct pt_regs *regs)
 {
-	unsigned long mask;
 	struct thread_struct *t;
+	unsigned long mask;
 	unsigned long old_val;
 	unsigned long ovfl_notify = 0UL, ovfl_pmds = 0UL;
 	int i;
@@ -2999,10 +3016,10 @@
 	/*
 	 * check for sampling buffer
 	 *
-	 * if present, record sample. We propagate notification ONLY when buffer
-	 * becomes full.
+	 * if present, record sample only when a 64-bit counter has overflowed.
+	 * We propagate notification ONLY when buffer becomes full.
 	 */
-	if(CTX_HAS_SMPL(ctx)) {
+	if(CTX_HAS_SMPL(ctx) && ovfl_pmds) {
 		ret = pfm_record_sample(task, ctx, ovfl_pmds, regs);
 		if (ret == 1) {
 			/*
@@ -3047,12 +3064,55 @@
 	 * ctx_notify_task could already be NULL, checked in pfm_notify_user() 
 	 */
 	if (CTX_OVFL_NOBLOCK(ctx) == 0 && ctx->ctx_notify_task != task) {
-		t->pfm_ovfl_block_reset = 1; /* will cause blocking */
 		ctx->ctx_fl_trap_reason = PFM_TRAP_REASON_BLOCKSIG;
 	} else {
-		t->pfm_ovfl_block_reset = 1; /* will cause blocking */
 		ctx->ctx_fl_trap_reason = PFM_TRAP_REASON_SIG;
 	}
+	/*
+	 * we cannot block in system wide mode and we do not go
+	 * through the PMU ctxsw code. Therefore we can generate
+	 * the notification here. In system wide mode, the current
+	 * task maybe different from the task controlling the session
+	 * on this CPU, therefore owner can be different from current.
+	 *
+	 * In per-process mode, this function gets called from 
+	 * the interrupt handler or pfm_load_regs(). The mode argument
+	 * tells where we are coming from. When coming from the interrupt
+	 * handler, it is safe to notify (send signal) right here because
+	 * we do not hold any runqueue locks needed by send_sig_info(). 
+	 *
+	 * However when coming from ctxsw, we cannot send the signal here.
+	 * It must be deferred until we are sure we do not hold any runqueue
+	 * related locks. The current task maybe different from the owner
+	 * only in UP mode. The deferral is implemented using the 
+	 * TIF_NOTIFY_RESUME mechanism. In this case, the pending work
+	 * is checked when the task is about to leave the kernel (see
+	 * entry.S). As of this version of perfmon, a kernel only
+	 * task cannot be monitored in per-process mode. Therefore,
+	 * when this function gets called from pfm_load_regs(), we know
+	 * we have a user level task which will eventually either exit
+	 * or leave the kernel, and thereby go through the checkpoint
+	 * for TIF_*.
+	 */
+	if (ctx->ctx_fl_system || mode == 0) {
+		pfm_notify_user(ctx);
+		ctx->ctx_fl_trap_reason = PFM_TRAP_REASON_NONE;
+	} else {
+		struct thread_info *info;
+
+		/*
+		 * given that TIF_NOTIFY_RESUME is not specific to
+		 * perfmon, we need to have a second level check to
+		 * verify the source of the notification.
+		 */
+		task->thread.pfm_ovfl_block_reset = 1;
+		/*
+		 * when coming from ctxsw, current still points to the
+		 * previous task, therefore we must work with task and not current.
+		 */
+		info = ((struct thread_info *) ((char *) task + IA64_TASK_SIZE));
+		set_bit(TIF_NOTIFY_RESUME, &info->flags);
+	}
 
 	/*
 	 * keep the PMU frozen until either pfm_restart() or 
@@ -3060,7 +3120,10 @@
 	 */
 	ctx->ctx_fl_frozen = 1;
 
-	DBprintk_ovfl(("return pmc0=0x%x must_block=%ld reason=%d\n",
+	DBprintk_ovfl(("current [%d] owner [%d] mode=%d return pmc0=0x%x must_block=%ld reason=%d\n",
+		current->pid, 
+		PMU_OWNER() ? PMU_OWNER()->pid : -1,
+		mode,
 		ctx->ctx_fl_frozen ? 0x1 : 0x0, 
 		t->pfm_ovfl_block_reset,
 		ctx->ctx_fl_trap_reason));
@@ -3115,7 +3178,7 @@
 		/* 
 		 * assume PMC[0].fr = 1 at this point 
 		 */
-		pmc0 = pfm_overflow_handler(task, ctx, pmc0, regs);
+		pmc0 = pfm_overflow_handler(0, task, ctx, pmc0, regs);
 		/*
 		 * we can only update pmc0 when the overflow
 		 * is for the current context. In UP the current
@@ -3455,7 +3518,7 @@
 	 * Side effect on ctx_fl_frozen is possible.
 	 */
 	if (t->pmc[0] & ~0x1) {
-		t->pmc[0] = pfm_overflow_handler(task, ctx, t->pmc[0], NULL);
+		t->pmc[0] = pfm_overflow_handler(1, task, ctx, t->pmc[0], NULL);
 	}
 
 	/*
@@ -3755,11 +3818,15 @@
 
 	preempt_disable();
 	/*
-	 * make sure child cannot mess up the monitoring session
+	 * for secure sessions, make sure child cannot mess up 
+	 * the monitoring session.
 	 */
-	 ia64_psr(regs)->sp = 1;
-	 DBprintk(("enabling psr.sp for [%d]\n", task->pid));
-
+	if (ctx->ctx_fl_unsecure == 0) {
+		ia64_psr(regs)->sp = 1;
+	 	DBprintk(("enabling psr.sp for [%d]\n", task->pid));
+	} else {
+	 	DBprintk(("psr.sp=%d [%d]\n", ia64_psr(regs)->sp, task->pid));
+	}
 
 	/*
 	 * if there was a virtual mapping for the sampling buffer
diff -Nur --exclude=SCCS --exclude=BitKeeper --exclude=ChangeSet bk-official-extra/arch/ia64/kernel/perfmon_mckinley.h bk-base/arch/ia64/kernel/perfmon_mckinley.h
--- bk-official-extra/arch/ia64/kernel/perfmon_mckinley.h	Thu Apr 10 14:01:35 2003
+++ bk-base/arch/ia64/kernel/perfmon_mckinley.h	Thu Apr 10 13:46:37 2003
@@ -25,8 +25,8 @@
 /* pmc5  */ { PFM_REG_COUNTING, 6, 0x0UL, 0xfffff7fUL, NULL,  pfm_mck_reserved, {RDEP(5),0UL, 0UL, 0UL}, {0UL,0UL, 0UL, 0UL}},
 /* pmc6  */ { PFM_REG_COUNTING, 6, 0x0UL, 0xfffff7fUL, NULL,  pfm_mck_reserved, {RDEP(6),0UL, 0UL, 0UL}, {0UL,0UL, 0UL, 0UL}},
 /* pmc7  */ { PFM_REG_COUNTING, 6, 0x0UL, 0xfffff7fUL, NULL,  pfm_mck_reserved, {RDEP(7),0UL, 0UL, 0UL}, {0UL,0UL, 0UL, 0UL}},
-/* pmc8  */ { PFM_REG_CONFIG  , 0, 0xffffffff3fffffffUL, 0xffffffff9fffffffUL, NULL, pfm_mck_pmc_check, {0UL,0UL, 0UL, 0UL}, {0UL,0UL, 0UL, 0UL}},
-/* pmc9  */ { PFM_REG_CONFIG  , 0, 0xffffffff3ffffffcUL, 0xffffffff9fffffffUL, NULL, pfm_mck_pmc_check, {0UL,0UL, 0UL, 0UL}, {0UL,0UL, 0UL, 0UL}},
+/* pmc8  */ { PFM_REG_CONFIG  , 0, 0xffffffff3fffffffUL, 0xffffffff3fffffffUL, NULL, pfm_mck_pmc_check, {0UL,0UL, 0UL, 0UL}, {0UL,0UL, 0UL, 0UL}},
+/* pmc9  */ { PFM_REG_CONFIG  , 0, 0xffffffff3ffffffcUL, 0xffffffff3fffffffUL, NULL, pfm_mck_pmc_check, {0UL,0UL, 0UL, 0UL}, {0UL,0UL, 0UL, 0UL}},
 /* pmc10 */ { PFM_REG_MONITOR , 4, 0x0UL, 0xffffUL, NULL, pfm_mck_reserved, {RDEP(0)|RDEP(1),0UL, 0UL, 0UL}, {0UL,0UL, 0UL, 0UL}},
 /* pmc11 */ { PFM_REG_MONITOR , 6, 0x0UL, 0x30f01cf, NULL,  pfm_mck_reserved, {RDEP(2)|RDEP(3)|RDEP(17),0UL, 0UL, 0UL}, {0UL,0UL, 0UL, 0UL}},
 /* pmc12 */ { PFM_REG_MONITOR , 6, 0x0UL, 0xffffUL, NULL,  pfm_mck_reserved, {RDEP(8)|RDEP(9)|RDEP(10)|RDEP(11)|RDEP(12)|RDEP(13)|RDEP(14)|RDEP(15)|RDEP(16),0UL, 0UL, 0UL}, {0UL,0UL, 0UL, 0UL}},
@@ -143,10 +143,7 @@
 		case  8: val8 = *val;
 			 val13 = th->pmc[13];
 			 val14 = th->pmc[14];
-			 *val |= 1UL << 2; /* bit 2 must always be 1 */
 			 check_case1 = 1;
-			 break;
-		case  9: *val |= 1UL << 2; /* bit 2 must always be 1 */
 			 break;
 		case 13: val8  = th->pmc[8];
 			 val13 = *val;
diff -Nur --exclude=SCCS --exclude=BitKeeper --exclude=ChangeSet bk-official-extra/include/asm-ia64/perfmon.h bk-base/include/asm-ia64/perfmon.h
--- bk-official-extra/include/asm-ia64/perfmon.h	Thu Apr 10 14:02:30 2003
+++ bk-base/include/asm-ia64/perfmon.h	Tue Apr 15 15:59:04 2003
@@ -41,6 +41,7 @@
 #define PFM_FL_NOTIFY_BLOCK    	 0x04	/* block task on user level notifications */
 #define PFM_FL_SYSTEM_WIDE	 0x08	/* create a system wide context */
 #define PFM_FL_EXCL_IDLE         0x20   /* exclude idle task from system wide session */
+#define PFM_FL_UNSECURE		 0x40   /* allow unsecure monitoring for non self-monitoring task */
 
 /*
  * PMC flags
@@ -125,7 +126,7 @@
  * Define the version numbers for both perfmon as a whole and the sampling buffer format.
  */
 #define PFM_VERSION_MAJ		1U
-#define PFM_VERSION_MIN		3U
+#define PFM_VERSION_MIN		4U
 #define PFM_VERSION		(((PFM_VERSION_MAJ&0xffff)<<16)|(PFM_VERSION_MIN & 0xffff))
 
 #define PFM_SMPL_VERSION_MAJ	1U
diff -Nur --exclude=SCCS --exclude=BitKeeper --exclude=ChangeSet bk-official-extra/include/asm-ia64/processor.h bk-base/include/asm-ia64/processor.h
--- bk-official-extra/include/asm-ia64/processor.h	Thu Apr 10 14:02:30 2003
+++ bk-base/include/asm-ia64/processor.h	Tue Apr 15 16:06:17 2003
@@ -291,7 +291,7 @@
 
 #define start_thread(regs,new_ip,new_sp) do {							\
 	set_fs(USER_DS);									\
-	regs->cr_ipsr = ((regs->cr_ipsr | (IA64_PSR_BITS_TO_SET | IA64_PSR_CPL | IA64_PSR_SP))	\
+	regs->cr_ipsr = ((regs->cr_ipsr | (IA64_PSR_BITS_TO_SET | IA64_PSR_CPL))		\
 			 & ~(IA64_PSR_BITS_TO_CLEAR | IA64_PSR_RI | IA64_PSR_IS));		\
 	regs->cr_iip = new_ip;									\
 	regs->ar_rsc = 0xf;		/* eager mode, privilege level 3 */			\

--k1lZvvs/B4yU6o8G--

