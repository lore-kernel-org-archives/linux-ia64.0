From: Andrea Gelmini <andrea.gelmini@gelma.net>
Date: Sun, 23 May 2010 20:01:49 +0000
Subject: [PATCH 153/199] arch/ia64/kernel/perfmon_itanium.h: Checkpatch cleanup
Message-Id: <1274644930-26600-5-git-send-email-andrea.gelmini@gelma.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

arch/ia64/kernel/perfmon_itanium.h:57: ERROR: trailing statements should be on next line
arch/ia64/kernel/perfmon_itanium.h:70: ERROR: trailing statements should be on next line
arch/ia64/kernel/perfmon_itanium.h:77: ERROR: trailing statements should be on next line
arch/ia64/kernel/perfmon_itanium.h:89: ERROR: trailing statements should be on next line
arch/ia64/kernel/perfmon_itanium.h:96: ERROR: trailing statements should be on next line

Signed-off-by: Andrea Gelmini <andrea.gelmini@gelma.net>
---
 arch/ia64/kernel/perfmon_itanium.h |   17 ++++++++++-------
 1 files changed, 10 insertions(+), 7 deletions(-)

diff --git a/arch/ia64/kernel/perfmon_itanium.h b/arch/ia64/kernel/perfmon_itanium.h
index d1d508a..03940fa 100644
--- a/arch/ia64/kernel/perfmon_itanium.h
+++ b/arch/ia64/kernel/perfmon_itanium.h
@@ -54,7 +54,8 @@ pfm_ita_pmc_check(struct task_struct *task, pfm_context_t *ctx, unsigned int cnu
 	int is_loaded;
 
 	/* sanitfy check */
-	if (ctx = NULL) return -EINVAL;
+	if (ctx = NULL)
+		return -EINVAL;
 
 	is_loaded = ctx->ctx_state = PFM_CTX_LOADED || ctx->ctx_state = PFM_CTX_MASKED;
 
@@ -63,18 +64,19 @@ pfm_ita_pmc_check(struct task_struct *task, pfm_context_t *ctx, unsigned int cnu
 	 * before they are written (fl_using_dbreg=0) to avoid picking up stale information.
 	 */
 	if (cnum = 13 && is_loaded && ((*val & 0x1) = 0UL) && ctx->ctx_fl_using_dbreg = 0) {
-
 		DPRINT(("pmc[%d]=0x%lx has active pmc13.ta cleared, clearing ibr\n", cnum, *val));
 
 		/* don't mix debug with perfmon */
-		if (task && (task->thread.flags & IA64_THREAD_DBG_VALID) != 0) return -EINVAL;
+		if (task && (task->thread.flags & IA64_THREAD_DBG_VALID) != 0)
+			return -EINVAL;
 
 		/*
 		 * a count of 0 will mark the debug registers as in use and also
 		 * ensure that they are properly cleared.
 		 */
 		ret = pfm_write_ibr_dbr(1, ctx, NULL, 0, regs);
-		if (ret) return ret;
+		if (ret)
+			return ret;
 	}
 
 	/*
@@ -82,18 +84,19 @@ pfm_ita_pmc_check(struct task_struct *task, pfm_context_t *ctx, unsigned int cnu
 	 * before they are written (fl_using_dbreg=0) to avoid picking up stale information.
 	 */
 	if (cnum = 11 && is_loaded && ((*val >> 28)& 0x1) = 0 && ctx->ctx_fl_using_dbreg = 0) {
-
 		DPRINT(("pmc[%d]=0x%lx has active pmc11.pt cleared, clearing dbr\n", cnum, *val));
 
 		/* don't mix debug with perfmon */
-		if (task && (task->thread.flags & IA64_THREAD_DBG_VALID) != 0) return -EINVAL;
+		if (task && (task->thread.flags & IA64_THREAD_DBG_VALID) != 0)
+			return -EINVAL;
 
 		/*
 		 * a count of 0 will mark the debug registers as in use and also
 		 * ensure that they are properly cleared.
 		 */
 		ret = pfm_write_ibr_dbr(0, ctx, NULL, 0, regs);
-		if (ret) return ret;
+		if (ret)
+			return ret;
 	}
 	return 0;
 }
-- 
1.7.1.251.gf80a2

