From: Petr Tesarik <ptesarik@suse.cz>
Date: Thu, 06 Dec 2007 16:52:00 +0000
Subject: [PATCH 2/3] Synchronize kernel RSE to user-space and back
Message-Id: <1196959920.6586.8.camel@elijah.suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This is base kernel patch for ptrace RSE bug. It's basically a backport
from the utrace RSE patch I sent out several weeks ago. please review.

when a thread is stopped (ptraced), debugger might change thread's user
stack (change memory directly), and we must avoid the RSE stored in
kernel to override user stack (user space's RSE is newer than kernel's
in the case). To workaround the issue, we copy kernel RSE to user RSE
before the task is stopped, so user RSE has updated data.  we then copy
user RSE to kernel after the task is resummed from traced stop and
kernel will use the newer RSE to return to user.

Signed-off-by: Shaohua Li <shaohua.li@intel.com>
Signed-off-by: Petr Tesarik <ptesarik@suse.cz>
---
 arch/ia64/kernel/process.c     |    6 +++
 arch/ia64/kernel/ptrace.c      |   80 +++++++++++++++++++++++++++++++++++++++++
 include/asm-ia64/ptrace.h      |    5 ++
 include/asm-ia64/thread_info.h |    2 +
 include/linux/ptrace.h         |    8 ++++
 kernel/signal.c                |   33 ++++++++++++++++
 6 files changed, 133 insertions(+), 1 deletion(-)

diff --git a/arch/ia64/kernel/process.c b/arch/ia64/kernel/process.c
index 94a92de..f5aa88d 100644
--- a/arch/ia64/kernel/process.c
+++ b/arch/ia64/kernel/process.c
@@ -161,6 +161,8 @@ #ifdef CONFIG_PERFMON
 	if (tsk->thread.pfm_needs_checking)
 		return;
 #endif
+	if (test_ti_thread_flag(task_thread_info(tsk), TIF_RESTORE_RSE))
+		return;
 	clear_ti_thread_flag(task_thread_info(tsk), TIF_NOTIFY_RESUME);
 }
 
@@ -182,6 +184,10 @@ #endif
 	/* deal with pending signal delivery */
 	if (test_thread_flag(TIF_SIGPENDING)||test_thread_flag(TIF_RESTORE_SIGMASK))
 		ia64_do_signal(scr, in_syscall);
+
+	/* copy user rbs to kernel rbs */
+	if (unlikely(test_thread_flag(TIF_RESTORE_RSE)))
+		ia64_sync_krbs();
 }
 
 static int pal_halt        = 1;
diff --git a/arch/ia64/kernel/ptrace.c b/arch/ia64/kernel/ptrace.c
index 2e96f17..d8c9864 100644
--- a/arch/ia64/kernel/ptrace.c
+++ b/arch/ia64/kernel/ptrace.c
@@ -547,6 +547,72 @@ ia64_sync_user_rbs (struct task_struct *
 	return 0;
 }
 
+static long
+ia64_sync_kernel_rbs (struct task_struct *child, struct switch_stack *sw,
+		unsigned long user_rbs_start, unsigned long user_rbs_end)
+{
+	unsigned long addr, val;
+	long ret;
+
+	/* now copy word for word from user rbs to kernel rbs: */
+	for (addr = user_rbs_start; addr < user_rbs_end; addr += 8) {
+		if (access_process_vm(child, addr, &val, sizeof(val), 0)
+				!= sizeof(val))
+			return -EIO;
+
+		ret = ia64_poke(child, sw, user_rbs_end, addr, val);
+		if (ret < 0)
+			return ret;
+	}
+	return 0;
+}
+
+typedef long (*syncfunc_t)(struct task_struct *, struct switch_stack *,
+			    unsigned long, unsigned long);
+
+static void do_sync_rbs(struct unw_frame_info *info, void *arg)
+{
+	struct pt_regs *pt;
+	unsigned long urbs_end;
+	syncfunc_t fn = arg;
+
+	if (unw_unwind_to_user(info) < 0)
+		return;
+	pt = task_pt_regs(info->task);
+	urbs_end = ia64_get_user_rbs_end(info->task, pt, NULL);
+
+	fn(info->task, info->sw, pt->ar_bspstore, urbs_end);
+}
+
+/*
+ * when a thread is stopped (ptraced), debugger might change thread's user
+ * stack (change memory directly), and we must avoid the RSE stored in kernel
+ * to override user stack (user space's RSE is newer than kernel's in the
+ * case). To workaround the issue, we copy kernel RSE to user RSE before the
+ * task is stopped, so user RSE has updated data.  we then copy user RSE to
+ * kernel after the task is resummed from traced stop and kernel will use the
+ * newer RSE to return to user. TIF_RESTORE_RSE is the flag to indicate we need
+ * synchronize user RSE to kernel.
+ */
+void ia64_ptrace_stop(void)
+{
+	if (test_and_set_tsk_thread_flag(current, TIF_RESTORE_RSE))
+		return;
+	tsk_set_notify_resume(current);
+	unw_init_running(do_sync_rbs, ia64_sync_user_rbs);
+}
+
+/*
+ * This is called to read back the register backing store.
+ */
+void ia64_sync_krbs(void)
+{
+	clear_tsk_thread_flag(current, TIF_RESTORE_RSE);
+	tsk_clear_notify_resume(current);
+
+	unw_init_running(do_sync_rbs, ia64_sync_kernel_rbs);
+}
+
 static inline int
 thread_matches (struct task_struct *thread, unsigned long addr)
 {
@@ -1422,6 +1488,7 @@ sys_ptrace (long request, pid_t pid, uns
 	struct task_struct *child;
 	struct switch_stack *sw;
 	long ret;
+	struct unw_frame_info info;
 
 	lock_kernel();
 	ret = -EPERM;
@@ -1481,6 +1548,11 @@ sys_ptrace (long request, pid_t pid, uns
 		/* write the word at location addr */
 		urbs_end = ia64_get_user_rbs_end(child, pt, NULL);
 		ret = ia64_poke(child, sw, urbs_end, addr, data);
+
+		/* Make sure user RBS has the latest data */
+		unw_init_from_blocked_task(&info, child);
+		do_sync_rbs(&info, ia64_sync_user_rbs);
+
 		goto out_tsk;
 
 	      case PTRACE_PEEKUSR:
@@ -1634,6 +1706,10 @@ syscall_trace_enter (long arg0, long arg
 	    && (current->ptrace & PT_PTRACED))
 		syscall_trace();
 
+	/* copy user rbs to kernel rbs */
+	if (test_thread_flag(TIF_RESTORE_RSE))
+		ia64_sync_krbs();
+
 	if (unlikely(current->audit_context)) {
 		long syscall;
 		int arch;
@@ -1671,4 +1747,8 @@ syscall_trace_leave (long arg0, long arg
 	    || test_thread_flag(TIF_SINGLESTEP))
 	    && (current->ptrace & PT_PTRACED))
 		syscall_trace();
+
+	/* copy user rbs to kernel rbs */
+	if (test_thread_flag(TIF_RESTORE_RSE))
+		ia64_sync_krbs();
 }
diff --git a/include/asm-ia64/ptrace.h b/include/asm-ia64/ptrace.h
index f4ef87a..57859ff 100644
--- a/include/asm-ia64/ptrace.h
+++ b/include/asm-ia64/ptrace.h
@@ -292,6 +292,7 @@ # define force_successful_syscall_return
 			 unsigned long, long);
   extern void ia64_flush_fph (struct task_struct *);
   extern void ia64_sync_fph (struct task_struct *);
+  extern void ia64_sync_krbs(void);
   extern long ia64_sync_user_rbs (struct task_struct *, struct switch_stack *,
 				  unsigned long, unsigned long);
 
@@ -303,6 +304,10 @@ # define force_successful_syscall_return
   extern void ia64_increment_ip (struct pt_regs *pt);
   extern void ia64_decrement_ip (struct pt_regs *pt);
 
+  extern void ia64_ptrace_stop(void);
+
+  #define arch_ptrace_stop		ia64_ptrace_stop
+  #define arch_ptrace_stop_needed()	1
 #endif /* !__KERNEL__ */
 
 /* pt_all_user_regs is used for PTRACE_GETREGS PTRACE_SETREGS */
diff --git a/include/asm-ia64/thread_info.h b/include/asm-ia64/thread_info.h
index 5a2c479..93d83cb 100644
--- a/include/asm-ia64/thread_info.h
+++ b/include/asm-ia64/thread_info.h
@@ -94,6 +94,7 @@ #define TIF_MEMDIE		17
 #define TIF_MCA_INIT		18	/* this task is processing MCA or INIT */
 #define TIF_DB_DISABLED		19	/* debug trap disabled for fsyscall */
 #define TIF_FREEZE		20	/* is freezing for suspend */
+#define TIF_RESTORE_RSE		21	/* user RBS is newer than kernel RBS */
 
 #define _TIF_SYSCALL_TRACE	(1 << TIF_SYSCALL_TRACE)
 #define _TIF_SYSCALL_AUDIT	(1 << TIF_SYSCALL_AUDIT)
@@ -107,6 +108,7 @@ #define _TIF_POLLING_NRFLAG	(1 << TIF_PO
 #define _TIF_MCA_INIT		(1 << TIF_MCA_INIT)
 #define _TIF_DB_DISABLED	(1 << TIF_DB_DISABLED)
 #define _TIF_FREEZE		(1 << TIF_FREEZE)
+#define _TIF_RESTORE_RSE	(1 << TIF_RESTORE_RSE)
 
 /* "work to do on user-return" bits */
 #define TIF_ALLWORK_MASK	(_TIF_SIGPENDING|_TIF_NOTIFY_RESUME|_TIF_SYSCALL_AUDIT|\
diff --git a/include/linux/ptrace.h b/include/linux/ptrace.h
index ae8146a..e9feff1 100644
--- a/include/linux/ptrace.h
+++ b/include/linux/ptrace.h
@@ -128,6 +128,14 @@ #ifndef force_successful_syscall_return
 #define force_successful_syscall_return() do { } while (0)
 #endif
 
+#ifndef arch_ptrace_stop
+#define arch_ptrace_stop()	do { } while (0)
+#endif
+
+#ifndef arch_ptrace_stop_needed
+#define arch_ptrace_stop_needed()	0
+#endif
+
 #endif
 
 #endif
diff --git a/kernel/signal.c b/kernel/signal.c
index afa4f78..2612e9e 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -1594,6 +1594,17 @@ static inline int may_ptrace_stop(void)
 }
 
 /*
+ * Return non-zero if there is a SIGKILL that should be waking us up.
+ * Called with the siglock held.
+ */
+static int sigkill_pending(struct task_struct *tsk)
+{
+	return ((sigismember(&tsk->pending.signal, SIGKILL) ||
+		 sigismember(&tsk->signal->shared_pending.signal, SIGKILL)) &&
+		!unlikely(sigismember(&tsk->blocked, SIGKILL)));
+}
+
+/*
  * This must be called with current->sighand->siglock held.
  *
  * This should be the path for all ptrace stops.
@@ -1606,6 +1617,26 @@ static inline int may_ptrace_stop(void)
  */
 static void ptrace_stop(int exit_code, int nostop_code, siginfo_t *info)
 {
+	int killed = 0;
+
+	if (arch_ptrace_stop_needed()) {
+		/*
+		 * The arch code has something special to do before a
+		 * ptrace stop.  This is allowed to block, e.g. for faults
+		 * on user stack pages.  We can't keep the siglock while
+		 * calling arch_ptrace_stop, so we must release it now.
+		 * To preserve proper semantics, we must do this before
+		 * any signal bookkeeping like checking group_stop_count.
+		 * Meanwhile, a SIGKILL could come in before we retake the
+		 * siglock.  That must prevent us from sleeping in TASK_TRACED.
+		 * So after regaining the lock, we must check for SIGKILL.
+		 */
+		spin_unlock_irq(&current->sighand->siglock);
+		arch_ptrace_stop();
+		spin_lock_irq(&current->sighand->siglock);
+		killed = sigkill_pending(current);
+	}
+
 	/*
 	 * If there is a group stop in progress,
 	 * we must participate in the bookkeeping.
@@ -1621,7 +1652,7 @@ static void ptrace_stop(int exit_code, i
 	spin_unlock_irq(&current->sighand->siglock);
 	try_to_freeze();
 	read_lock(&tasklist_lock);
-	if (may_ptrace_stop()) {
+	if (likely(!killed) && may_ptrace_stop()) {
 		do_notify_parent_cldstop(current, CLD_TRAPPED);
 		read_unlock(&tasklist_lock);
 		schedule();

