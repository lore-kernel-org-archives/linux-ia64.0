From: David Mosberger <davidm@hpl.hp.com>
Date: Thu, 17 May 2001 14:58:21 +0000
Subject: [Linux-ia64] ia32 & perfmon fix (relative to 2.4.4 + 010508 ia64 patch)
Message-Id: <marc-linux-ia64-105590693005602@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The patch below fixes a silly typo in the ia32 support and a buglet in
the PMU support.  I also noticed that "strace -f" is currently broken
for ia64 processes.  I tracked it down to the coredump related changes
in ptrace(), but don't have a complete fix yet.

	--david

--- arch/ia64/kernel/process.c~	Wed May 16 18:27:32 2001
+++ arch/ia64/kernel/process.c	Wed May 16 23:18:57 2001
@@ -285,7 +285,7 @@
 	 * state from the current task to the new task
 	 */
 	if (IS_IA32_PROCESS(ia64_task_regs(current)))
-		ia32_save_state(&p->thread);
+		ia32_save_state(p);
 #endif
 #ifdef CONFIG_PERFMON
 	p->thread.pfm_pend_notify = 0;
--- ../lia64/arch/ia64/kernel/perfmon.c	Sun Apr 29 17:09:23 2001
+++ arch/ia64/kernel/perfmon.c	Wed May 16 18:13:26 2001
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

