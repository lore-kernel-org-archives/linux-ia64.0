From: Petr Tesarik <ptesarik@suse.cz>
Date: Wed, 12 Dec 2007 14:24:25 +0000
Subject: [PATCH 3/3] Synchronize RBS on PTRACE_ATTACH
Message-Id: <475FEF19.2010707@suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <1196959949.6586.10.camel@elijah.suse.cz>
In-Reply-To: <1196959949.6586.10.camel@elijah.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

When attaching to a stopped process, the RSE must be explicitly
synced to user-space, so the debugger can read the correct values.

Signed-off-by: Petr Tesarik <ptesarik@suse.cz>
CC: Roland McGrath <roland@redhat.com>
CC: Tony Luck <tony.luck@intel.com>

---
 arch/ia64/kernel/ptrace.c |   57 +++++++++++++++++++++++++++++++++++++++++++++
 include/asm-ia64/ptrace.h |    4 +++
 2 files changed, 61 insertions(+), 0 deletions(-)

diff --git a/arch/ia64/kernel/ptrace.c b/arch/ia64/kernel/ptrace.c
index 2de5a52..331d676 100644
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
+void
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
diff --git a/include/asm-ia64/ptrace.h b/include/asm-ia64/ptrace.h
index 13435f7..0bdce7d 100644
--- a/include/asm-ia64/ptrace.h
+++ b/include/asm-ia64/ptrace.h
@@ -310,6 +310,10 @@ # define force_successful_syscall_return
   #define arch_ptrace_stop_needed(code, info) \
 	(!test_thread_flag(TIF_RESTORE_RSE))
 
+  extern void ptrace_attach_sync_user_rbs (struct task_struct *);
+  #define arch_ptrace_attach(child) \
+	ptrace_attach_sync_user_rbs(child)
+
 #endif /* !__KERNEL__ */
 
 /* pt_all_user_regs is used for PTRACE_GETREGS PTRACE_SETREGS */


