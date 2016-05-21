From: Andrea Gelmini <andrea.gelmini@gelma.net>
Date: Sat, 21 May 2016 11:57:07 +0000
Subject: [PATCH 0159/1529] Fix typo
Message-Id: <20160521115707.7981-1-andrea.gelmini@gelma.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Signed-off-by: Andrea Gelmini <andrea.gelmini@gelma.net>
---
 arch/ia64/kernel/ptrace.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/ia64/kernel/ptrace.c b/arch/ia64/kernel/ptrace.c
index 6f54d51..cd11ccf 100644
--- a/arch/ia64/kernel/ptrace.c
+++ b/arch/ia64/kernel/ptrace.c
@@ -753,7 +753,7 @@ convert_to_non_syscall (struct task_struct *child, struct pt_regs  *pt,
 
 	/*
 	 * Note: at the time of this call, the target task is blocked
-	 * in notify_resume_user() and by clearling PRED_LEAVE_SYSCALL
+	 * in notify_resume_user() and by clearing PRED_LEAVE_SYSCALL
 	 * (aka, "pLvSys") we redirect execution from
 	 * .work_pending_syscall_end to .work_processed_kernel.
 	 */
-- 
2.8.2.534.g1f66975

