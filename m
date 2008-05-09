From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Fri, 09 May 2008 06:27:09 +0000
Subject: [PATCH] ia64: trivial cleanup for perfmon.c
Message-Id: <4823EEBD.4020109@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Fix a typo, and coding style cleanups for pfm_handle_work().

Signed-off-by: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
---
 arch/ia64/kernel/perfmon.c |   16 ++++++++++------
 1 files changed, 10 insertions(+), 6 deletions(-)

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

