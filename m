From: Petr Tesarik <ptesarik@suse.cz>
Date: Thu, 06 Dec 2007 16:52:29 +0000
Subject: [PATCH 3/3] Synchronize RBS on PTRACE_ATTACH
Message-Id: <1196959949.6586.10.camel@elijah.suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

When attaching to a stopped process, the RSE must be explicitly
synced to user-space, so the debugger can read the correct values.

Signed-off-by: Petr Tesarik <ptesarik@suse.cz>
---
 ptrace.c |   59 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 59 insertions(+)

diff --git a/arch/ia64/kernel/ptrace.c b/arch/ia64/kernel/ptrace.c
index d8c9864..76cc4d4 100644
--- a/arch/ia64/kernel/ptrace.c
+++ b/arch/ia64/kernel/ptrace.c
@@ -613,6 +613,63 @@ void ia64_sync_krbs(void)
 	unw_init_running(do_sync_rbs, ia64_sync_kernel_rbs);
 }
 
+/*
+ * After PTRACE_ATTACH, a thread's register backing store area in user
+ * space is assumed to contain correct data whenever the thread is
+ * stopped.  arch_ptrace_stop takes care of this on tracing stops.
+ * But if the child was already stopped for job control when we attach
+ * to it, then it might not ever get into ptrace_stop by the time we
+ * want to examine the user memory containing the RBS.
+ */
+static void
+ptrace_attach_sync_user_rbs (struct task_struct *child)
+{
+	int stopped = 0;
+	struct unw_frame_info info;
+
+	/*
+	 * If the child is in TASK_STOPPED, we need to change that to
+	 * TASK_TRACED momentarily while we operate on it.  This ensures
+	 * that the child won't be woken up and return to user mode while
+	 * we are doing the sync.  (It can only be woken up for SIGKILL.)
+	 */
+
+	read_lock(&tasklist_lock);
+	if (child->signal) {
+		spin_lock_irq(&child->sighand->siglock);
+		if (child->state = TASK_STOPPED &&
+		    !test_and_set_tsk_thread_flag(child, TIF_RESTORE_RSE)) {
+			tsk_set_notify_resume(child);
+
+			child->state = TASK_TRACED;
+			stopped = 1;
+		}
+		spin_unlock_irq(&child->sighand->siglock);
+	}
+	read_unlock(&tasklist_lock);
+
+	if (!stopped)
+		return;
+
+	unw_init_from_blocked_task(&info, child);
+	do_sync_rbs(&info, ia64_sync_user_rbs);
+
+	/*
+	 * Now move the child back into TASK_STOPPED if it should be in a
+	 * job control stop, so that SIGCONT can be used to wake it up.
+	 */
+	read_lock(&tasklist_lock);
+	if (child->signal) {
+		spin_lock_irq(&child->sighand->siglock);
+		if (child->state = TASK_TRACED &&
+		    (child->signal->flags & SIGNAL_STOP_STOPPED)) {
+			child->state = TASK_STOPPED;
+		}
+		spin_unlock_irq(&child->sighand->siglock);
+	}
+	read_unlock(&tasklist_lock);
+}
+
 static inline int
 thread_matches (struct task_struct *thread, unsigned long addr)
 {
@@ -1520,6 +1577,8 @@ sys_ptrace (long request, pid_t pid, uns
 
 	if (request = PTRACE_ATTACH) {
 		ret = ptrace_attach(child);
+		if (ret = 0)
+			ptrace_attach_sync_user_rbs(child);
 		goto out_tsk;
 	}
 

