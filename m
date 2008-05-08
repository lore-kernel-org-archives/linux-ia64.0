From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Thu, 08 May 2008 05:52:50 +0000
Subject: [PATCH] ia64: fix interrupt masking for pending works on kernel leave
Message-Id: <48229532.7000809@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Tony-san,

How about this patch as a draft?

This patch does:
 - enable interrupts before calling schedule() as same as others, ex. x86
 - enable interrupts during ia64_do_signal() and ia64_sync_krbs()
 - do_notify_resume_user() is still called with interrupts disabled, since
   we can take short path of fsys_mode if-statement quickly.
 - pfm_handle_work() is also called with interrupts disabled, since
   it can deal interrupt mask within itself.
 - fix/add some comments/notes

Signed-off-by: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
---
 arch/ia64/kernel/entry.S   |   26 ++++++++++++++++----------
 arch/ia64/kernel/perfmon.c |   16 ++++++++++------
 arch/ia64/kernel/process.c |   25 +++++++++++++++++++++----
 3 files changed, 47 insertions(+), 20 deletions(-)

diff --git a/arch/ia64/kernel/entry.S b/arch/ia64/kernel/entry.S
index e49ad8c..ca2bb95 100644
--- a/arch/ia64/kernel/entry.S
+++ b/arch/ia64/kernel/entry.S
@@ -1156,6 +1156,9 @@ skip_rbs_switch:
 	 *	r31 = current->thread_info->flags
 	 * On exit:
 	 *	p6 = TRUE if work-pending-check needs to be redone
+	 *
+	 * Interrupts are disabled on entry, reenabled depend on work, and
+	 * disabled on exit.
 	 */
 .work_pending_syscall:
 	add r2=-8,r2
@@ -1164,16 +1167,16 @@ skip_rbs_switch:
 	st8 [r2]=r8
 	st8 [r3]=r10
 .work_pending:
-	tbit.z p6,p0=r31,TIF_NEED_RESCHED		// current_thread_info()->need_resched=0?
+	tbit.z p6,p0=r31,TIF_NEED_RESCHED	// is resched not needed?
 (p6)	br.cond.sptk.few .notify
 #ifdef CONFIG_PREEMPT
 (pKStk) dep r21=-1,r0,PREEMPT_ACTIVE_BIT,1
 	;;
 (pKStk) st4 [r20]=r21
-	ssm psr.i		// enable interrupts
 #endif
+	ssm psr.i		// enable interrupts
 	br.call.spnt.many rp=schedule
-.ret9:	cmp.eq p6,p0=r0,r0				// p6 <- 1
+.ret9:	cmp.eq p6,p0=r0,r0	// p6 <- 1 (re-check)
 	rsm psr.i		// disable interrupts
 	;;
 #ifdef CONFIG_PREEMPT
@@ -1182,13 +1185,13 @@ skip_rbs_switch:
 (pKStk)	st4 [r20]=r0		// preempt_count() <- 0
 #endif
 (pLvSys)br.cond.sptk.few  .work_pending_syscall_end
-	br.cond.sptk.many .work_processed_kernel	// re-check
+	br.cond.sptk.many .work_processed_kernel
 
 .notify:
 (pUStk)	br.call.spnt.many rp=notify_resume_user
-.ret10:	cmp.ne p6,p0=r0,r0				// p6 <- 0
+.ret10:	cmp.ne p6,p0=r0,r0	// p6 <- 0 (don't re-check)
 (pLvSys)br.cond.sptk.few  .work_pending_syscall_end
-	br.cond.sptk.many .work_processed_kernel	// don't re-check
+	br.cond.sptk.many .work_processed_kernel
 
 .work_pending_syscall_end:
 	adds r2=PT(R8)+16,r12
@@ -1196,7 +1199,7 @@ skip_rbs_switch:
 	;;
 	ld8 r8=[r2]
 	ld8 r10=[r3]
-	br.cond.sptk.many .work_processed_syscall	// re-check
+	br.cond.sptk.many .work_processed_syscall
 
 END(ia64_leave_kernel)
 
@@ -1234,9 +1237,12 @@ GLOBAL_ENTRY(ia64_invoke_schedule_tail)
 END(ia64_invoke_schedule_tail)
 
 	/*
-	 * Setup stack and call do_notify_resume_user().  Note that pSys and pNonSys need to
-	 * be set up by the caller.  We declare 8 input registers so the system call
-	 * args get preserved, in case we need to restart a system call.
+	 * Setup stack and call do_notify_resume_user(), keeping interrupts
+	 * disabled.
+	 *
+	 * Note that pSys and pNonSys need to be set up by the caller.
+	 * We declare 8 input registers so the system call args get preserved,
+	 * in case we need to restart a system call.
 	 */
 ENTRY(notify_resume_user)
 	.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(8)
diff --git a/arch/ia64/kernel/perfmon.c b/arch/ia64/kernel/perfmon.c
index c1ad27d..71d0513 100644
--- a/arch/ia64/kernel/perfmon.c
+++ b/arch/ia64/kernel/perfmon.c
@@ -5013,12 +5013,13 @@ pfm_context_force_terminate(pfm_context_t *ctx, struct pt_regs *regs)
 }
 
 static int pfm_ovfl_notify_user(pfm_context_t *ctx, unsigned long ovfl_pmds);
+
  /*
   * pfm_handle_work() can be called with interrupts enabled
   * (TIF_NEED_RESCHED) or disabled. The down_interruptible
   * call may sleep, therefore we must re-enable interrupts
   * to avoid deadlocks. It is safe to do so because this function
-  * is called ONLY when returning to user level (PUStk=1), in which case
+  * is called ONLY when returning to user level (pUStk=1), in which case
   * there is no risk of kernel stack overflow due to deep
   * interrupt nesting.
   */
@@ -5034,7 +5035,8 @@ pfm_handle_work(void)
 
 	ctx = PFM_GET_CTX(current);
 	if (ctx = NULL) {
-		printk(KERN_ERR "perfmon: [%d] has no PFM context\n", task_pid_nr(current));
+		printk(KERN_ERR "perfmon: [%d] has no PFM context\n",
+			task_pid_nr(current));
 		return;
 	}
 
@@ -5058,11 +5060,12 @@ pfm_handle_work(void)
 	/*
 	 * must be done before we check for simple-reset mode
 	 */
-	if (ctx->ctx_fl_going_zombie || ctx->ctx_state = PFM_CTX_ZOMBIE) goto do_zombie;
-
+	if (ctx->ctx_fl_going_zombie || ctx->ctx_state = PFM_CTX_ZOMBIE)
+		goto do_zombie;
 
 	//if (CTX_OVFL_NOBLOCK(ctx)) goto skip_blocking;
-	if (reason = PFM_TRAP_REASON_RESET) goto skip_blocking;
+	if (reason = PFM_TRAP_REASON_RESET)
+		goto skip_blocking;
 
 	/*
 	 * restore interrupt mask to what it was on entry.
@@ -5110,7 +5113,8 @@ do_zombie:
 	/*
 	 * in case of interruption of down() we don't restart anything
 	 */
-	if (ret < 0) goto nothing_to_do;
+	if (ret < 0)
+		goto nothing_to_do;
 
 skip_blocking:
 	pfm_resume_after_ovfl(ctx, ovfl_regs, regs);
diff --git a/arch/ia64/kernel/process.c b/arch/ia64/kernel/process.c
index 58dcfac..c7d4885 100644
--- a/arch/ia64/kernel/process.c
+++ b/arch/ia64/kernel/process.c
@@ -167,11 +167,18 @@ void tsk_clear_notify_resume(struct task_struct *tsk)
 	clear_ti_thread_flag(task_thread_info(tsk), TIF_NOTIFY_RESUME);
 }
 
+/*
+ * do_notify_resume_user():
+ *	Called from notify_from_user at entry.S, with interrupts disabled.
+ */
 void
-do_notify_resume_user (sigset_t *unused, struct sigscratch *scr, long in_syscall)
+do_notify_resume_user(sigset_t *unused, struct sigscratch *scr, long in_syscall)
 {
 	if (fsys_mode(current, &scr->pt)) {
-		/* defer signal-handling etc. until we return to privilege-level 0.  */
+		/*
+		 * defer signal-handling etc. until we return to
+		 * privilege-level 0.
+		 */
 		if (!ia64_psr(&scr->pt)->lp)
 			ia64_psr(&scr->pt)->lp = 1;
 		return;
@@ -179,16 +186,26 @@ do_notify_resume_user (sigset_t *unused, struct sigscratch *scr, long in_syscall
 
 #ifdef CONFIG_PERFMON
 	if (current->thread.pfm_needs_checking)
+		/*
+		 * Note: pfm_handle_work() allow us to call it with interrupts
+		 * disabled, and may enable interrupts within the function.
+		 */
 		pfm_handle_work();
 #endif
 
 	/* deal with pending signal delivery */
-	if (test_thread_flag(TIF_SIGPENDING))
+	if (test_thread_flag(TIF_SIGPENDING)) {
+		local_irq_enable();	/* force interrupt enable */
 		ia64_do_signal(scr, in_syscall);
+	}
 
 	/* copy user rbs to kernel rbs */
-	if (unlikely(test_thread_flag(TIF_RESTORE_RSE)))
+	if (unlikely(test_thread_flag(TIF_RESTORE_RSE))) {
+		local_irq_enable();	/* force interrupt enable */
 		ia64_sync_krbs();
+	}
+
+	local_irq_disable();	/* force interrupt disable */
 }
 
 static int pal_halt        = 1;
