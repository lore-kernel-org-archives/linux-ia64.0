From: Alex Williamson <alex.williamson@hp.com>
Date: Tue, 28 Sep 2004 22:58:38 +0000
Subject: perfmon broken
Message-Id: <1096412318.14161.51.camel@tdi>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


   Looks like this changeset back between 2.6.9-rc1-bk15 & bk16 broke
perfmon:

http://linux.bkbits.net:8080/linux-2.5/cset@413f1bdabfaQNzIZpU6bPxNlSxdriQ

        [PATCH] cleanup ptrace stops and remove notify_parent
        
        This adds a new state TASK_TRACED that is used in place of
        TASK_STOPPED when a thread stops because it is ptraced.  Now
        ptrace operations are only permitted when the target is in
        TASK_TRACED state, not in TASK_STOPPED.
        ...

 Here's the simple fix, perhaps Stephane has a better approach.  Thanks,

	Alex

-- 
Signed-off-by: Alex Williamson <alex.williamson@hp.com>


=== arch/ia64/kernel/perfmon.c 1.90 vs edited ==--- 1.90/arch/ia64/kernel/perfmon.c	2004-09-03 08:54:08 -06:00
+++ edited/arch/ia64/kernel/perfmon.c	2004-09-28 16:42:05 -06:00
@@ -2601,7 +2601,7 @@
 	 */
 	if (task = current) return 0;
 
-	if (task->state != TASK_STOPPED) {
+	if ((task->state != TASK_STOPPED) && (task->state != TASK_TRACED)){
 		DPRINT(("cannot attach to non-stopped task [%d] state=%ld\n", task->pid, task->state));
 		return -EBUSY;
 	}
@@ -4755,7 +4755,8 @@
 	 * the task must be stopped.
 	 */
 	if (PFM_CMD_STOPPED(cmd)) {
-		if (task->state != TASK_STOPPED) {
+		if ((task->state != TASK_STOPPED) &&
+		    (task->state != TASK_TRACED)) {
 			DPRINT(("[%d] task not in stopped state\n", task->pid));
 			return -EBUSY;
 		}


