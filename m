From: akpm@linux-foundation.org
Date: Tue, 05 Feb 2008 07:43:03 +0000
Subject: [patch 3/4] ia64: make pfm_get_task work with virtual pids
Message-Id: <200802050742.m157gjgW010220@imap1.linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

From: Pavel Emelyanov <xemul@openvz.org>

This pid comes from user space, so treat it accordingly.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: "Luck, Tony" <tony.luck@intel.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 arch/ia64/kernel/perfmon.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff -puN arch/ia64/kernel/perfmon.c~ia64-make-pfm_get_task-work-with-virtual-pids arch/ia64/kernel/perfmon.c
--- a/arch/ia64/kernel/perfmon.c~ia64-make-pfm_get_task-work-with-virtual-pids
+++ a/arch/ia64/kernel/perfmon.c
@@ -2654,11 +2654,11 @@ pfm_get_task(pfm_context_t *ctx, pid_t p
 	/* XXX: need to add more checks here */
 	if (pid < 2) return -EPERM;
 
-	if (pid != current->pid) {
+	if (pid != task_pid_vnr(current)) {
 
 		read_lock(&tasklist_lock);
 
-		p = find_task_by_pid(pid);
+		p = find_task_by_vpid(pid);
 
 		/* make sure task cannot go away while we operate on it */
 		if (p) get_task_struct(p);
_
