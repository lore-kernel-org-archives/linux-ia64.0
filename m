From: Shaohua Li <shaohua.li@intel.com>
Date: Wed, 29 Aug 2007 03:21:50 +0000
Subject: [PATCH] ptrace RSE bug
Message-Id: <1188357710.22637.7.camel@sli10-conroe.sh.intel.com>
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
---
 arch/ia64/kernel/perfmon.c     |   21 +---------
 arch/ia64/kernel/process.c     |   15 +++++++
 arch/ia64/kernel/ptrace.c      |   82 +++++++++++++++++++++++++++++++++++++++++
 include/asm-ia64/ptrace.h      |    3 +
 include/asm-ia64/thread_info.h |   11 ++++-
 include/linux/ptrace.h         |    4 ++
 kernel/signal.c                |    5 ++
 7 files changed, 119 insertions(+), 22 deletions(-)

Index: linux/arch/ia64/kernel/perfmon.c
=================================--- linux.orig/arch/ia64/kernel/perfmon.c	2007-08-28 16:54:18.000000000 +0800
+++ linux/arch/ia64/kernel/perfmon.c	2007-08-28 16:54:41.000000000 +0800
@@ -586,21 +586,6 @@ pfm_put_task(struct task_struct *task)
 }
 
 static inline void
-pfm_set_task_notify(struct task_struct *task)
-{
-	struct thread_info *info;
-
-	info = (struct thread_info *) ((char *) task + IA64_TASK_SIZE);
-	set_bit(TIF_PERFMON_WORK, &info->flags);
-}
-
-static inline void
-pfm_clear_task_notify(void)
-{
-	clear_thread_flag(TIF_PERFMON_WORK);
-}
-
-static inline void
 pfm_reserve_page(unsigned long a)
 {
 	SetPageReserved(vmalloc_to_page((void *)a));
@@ -3730,7 +3715,7 @@ pfm_restart(pfm_context_t *ctx, void *ar
 
 		PFM_SET_WORK_PENDING(task, 1);
 
-		pfm_set_task_notify(task);
+		tsk_set_notify_resume(task);
 
 		/*
 		 * XXX: send reschedule if task runs on another CPU
@@ -5087,7 +5072,7 @@ pfm_handle_work(void)
 
 	PFM_SET_WORK_PENDING(current, 0);
 
-	pfm_clear_task_notify();
+	tsk_clear_notify_resume(current);
 
 	regs = task_pt_regs(current);
 
@@ -5455,7 +5440,7 @@ pfm_overflow_handler(struct task_struct 
 			 * when coming from ctxsw, current still points to the
 			 * previous task, therefore we must work with task and not current.
 			 */
-			pfm_set_task_notify(task);
+			tsk_set_notify_resume(task);
 		}
 		/*
 		 * defer until state is changed (shorten spin window). the context is locked
Index: linux/arch/ia64/kernel/process.c
=================================--- linux.orig/arch/ia64/kernel/process.c	2007-08-28 16:54:18.000000000 +0800
+++ linux/arch/ia64/kernel/process.c	2007-08-28 16:54:41.000000000 +0800
@@ -154,6 +154,17 @@ show_regs (struct pt_regs *regs)
 		show_stack(NULL, NULL);
 }
 
+void tsk_clear_notify_resume(struct task_struct *tsk)
+{
+#ifdef CONFIG_PERFMON
+	if (tsk->thread.pfm_needs_checking)
+		return;
+#endif
+	if (test_ti_thread_flag(task_thread_info(tsk), TIF_RESTORE_RSE))
+		return;
+	clear_ti_thread_flag(task_thread_info(tsk), TIF_NOTIFY_RESUME);
+}
+
 void
 do_notify_resume_user (sigset_t *unused, struct sigscratch *scr, long in_syscall)
 {
@@ -172,6 +183,10 @@ do_notify_resume_user (sigset_t *unused,
 	/* deal with pending signal delivery */
 	if (test_thread_flag(TIF_SIGPENDING)||test_thread_flag(TIF_RESTORE_SIGMASK))
 		ia64_do_signal(scr, in_syscall);
+
+	/* copy user rbs to kernel rbs */
+	if (unlikely(test_thread_flag(TIF_RESTORE_RSE)))
+		ia64_sync_krbs();
 }
 
 static int pal_halt        = 1;
Index: linux/arch/ia64/kernel/ptrace.c
=================================--- linux.orig/arch/ia64/kernel/ptrace.c	2007-08-28 16:54:18.000000000 +0800
+++ linux/arch/ia64/kernel/ptrace.c	2007-08-29 10:59:02.000000000 +0800
@@ -547,6 +547,74 @@ ia64_sync_user_rbs (struct task_struct *
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
+#define RBS_SYNC_TO_USER 0
+#define RBS_SYNC_TO_KERNEL 1
+static void do_sync_rbs(struct unw_frame_info *info, void *arg)
+{
+	struct pt_regs *pt;
+	unsigned long urbs_end;
+	int to_user = (unsigned long)arg;
+
+	if (unw_unwind_to_user(info) < 0)
+		return;
+	pt = task_pt_regs(info->task);
+	urbs_end = ia64_get_user_rbs_end(info->task, pt, NULL);
+
+	if (to_user = RBS_SYNC_TO_USER)
+		ia64_sync_user_rbs(info->task, info->sw, pt->ar_bspstore, urbs_end);
+	else
+		ia64_sync_kernel_rbs(info->task, info->sw, pt->ar_bspstore, urbs_end);
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
+void arch_ptrace_stop(void)
+{
+	if (test_and_set_tsk_thread_flag(current, TIF_RESTORE_RSE))
+		return;
+	tsk_set_notify_resume(current);
+	unw_init_running(do_sync_rbs, (void *)RBS_SYNC_TO_USER);
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
+	unw_init_running(do_sync_rbs, (void *)RBS_SYNC_TO_KERNEL);
+}
+
 static inline int
 thread_matches (struct task_struct *thread, unsigned long addr)
 {
@@ -1422,6 +1490,7 @@ sys_ptrace (long request, pid_t pid, uns
 	struct task_struct *child;
 	struct switch_stack *sw;
 	long ret;
+	struct unw_frame_info info;
 
 	lock_kernel();
 	ret = -EPERM;
@@ -1481,6 +1550,11 @@ sys_ptrace (long request, pid_t pid, uns
 		/* write the word at location addr */
 		urbs_end = ia64_get_user_rbs_end(child, pt, NULL);
 		ret = ia64_poke(child, sw, urbs_end, addr, data);
+
+		/* Make sure user RBS has the latest data */
+		unw_init_from_blocked_task(&info, child);
+		do_sync_rbs(&info, RBS_SYNC_TO_USER);
+
 		goto out_tsk;
 
 	      case PTRACE_PEEKUSR:
@@ -1635,6 +1709,10 @@ syscall_trace_enter (long arg0, long arg
 	    && (current->ptrace & PT_PTRACED))
 		syscall_trace();
 
+	/* copy user rbs to kernel rbs */
+	if (test_thread_flag(TIF_RESTORE_RSE))
+		ia64_sync_krbs();
+
 	if (unlikely(current->audit_context)) {
 		long syscall;
 		int arch;
@@ -1672,4 +1750,8 @@ syscall_trace_leave (long arg0, long arg
 	    || test_thread_flag(TIF_SINGLESTEP))
 	    && (current->ptrace & PT_PTRACED))
 		syscall_trace();
+
+	/* copy user rbs to kernel rbs */
+	if (test_thread_flag(TIF_RESTORE_RSE))
+		ia64_sync_krbs();
 }
Index: linux/include/asm-ia64/ptrace.h
=================================--- linux.orig/include/asm-ia64/ptrace.h	2007-08-28 16:54:18.000000000 +0800
+++ linux/include/asm-ia64/ptrace.h	2007-08-28 16:54:41.000000000 +0800
@@ -292,6 +292,7 @@ struct switch_stack {
 			 unsigned long, long);
   extern void ia64_flush_fph (struct task_struct *);
   extern void ia64_sync_fph (struct task_struct *);
+  extern void ia64_sync_krbs(void);
   extern long ia64_sync_user_rbs (struct task_struct *, struct switch_stack *,
 				  unsigned long, unsigned long);
 
@@ -303,6 +304,8 @@ struct switch_stack {
   extern void ia64_increment_ip (struct pt_regs *pt);
   extern void ia64_decrement_ip (struct pt_regs *pt);
 
+  extern void arch_ptrace_stop(void);
+  #define HAVE_ARCH_PTRACE_STOP
 #endif /* !__KERNEL__ */
 
 /* pt_all_user_regs is used for PTRACE_GETREGS PTRACE_SETREGS */
Index: linux/include/asm-ia64/thread_info.h
=================================--- linux.orig/include/asm-ia64/thread_info.h	2007-08-28 16:54:18.000000000 +0800
+++ linux/include/asm-ia64/thread_info.h	2007-08-28 16:54:41.000000000 +0800
@@ -71,6 +71,9 @@ struct thread_info {
 #define alloc_task_struct()	((struct task_struct *)__get_free_pages(GFP_KERNEL | __GFP_COMP, KERNEL_STACK_SIZE_ORDER))
 #define free_task_struct(tsk)	free_pages((unsigned long) (tsk), KERNEL_STACK_SIZE_ORDER)
 
+#define tsk_set_notify_resume(tsk) \
+	set_ti_thread_flag(task_thread_info(tsk), TIF_NOTIFY_RESUME)
+extern void tsk_clear_notify_resume(struct task_struct *tsk);
 #endif /* !__ASSEMBLY */
 
 /*
@@ -85,28 +88,30 @@ struct thread_info {
 #define TIF_SYSCALL_AUDIT	3	/* syscall auditing active */
 #define TIF_SINGLESTEP		4	/* restore singlestep on return to user mode */
 #define TIF_RESTORE_SIGMASK	5	/* restore signal mask in do_signal() */
-#define TIF_PERFMON_WORK	6	/* work for pfm_handle_work() */
+#define TIF_NOTIFY_RESUME	6	/* resumption notification requested */
 #define TIF_POLLING_NRFLAG	16	/* true if poll_idle() is polling TIF_NEED_RESCHED */
 #define TIF_MEMDIE		17
 #define TIF_MCA_INIT		18	/* this task is processing MCA or INIT */
 #define TIF_DB_DISABLED		19	/* debug trap disabled for fsyscall */
 #define TIF_FREEZE		20	/* is freezing for suspend */
+#define TIF_RESTORE_RSE		21	/* task need RSE synchronization */
 
 #define _TIF_SYSCALL_TRACE	(1 << TIF_SYSCALL_TRACE)
 #define _TIF_SYSCALL_AUDIT	(1 << TIF_SYSCALL_AUDIT)
 #define _TIF_SINGLESTEP		(1 << TIF_SINGLESTEP)
 #define _TIF_SYSCALL_TRACEAUDIT	(_TIF_SYSCALL_TRACE|_TIF_SYSCALL_AUDIT|_TIF_SINGLESTEP)
 #define _TIF_RESTORE_SIGMASK	(1 << TIF_RESTORE_SIGMASK)
-#define _TIF_PERFMON_WORK	(1 << TIF_PERFMON_WORK)
+#define _TIF_NOTIFY_RESUME	(1 << TIF_NOTIFY_RESUME)
 #define _TIF_SIGPENDING		(1 << TIF_SIGPENDING)
 #define _TIF_NEED_RESCHED	(1 << TIF_NEED_RESCHED)
 #define _TIF_POLLING_NRFLAG	(1 << TIF_POLLING_NRFLAG)
 #define _TIF_MCA_INIT		(1 << TIF_MCA_INIT)
 #define _TIF_DB_DISABLED	(1 << TIF_DB_DISABLED)
 #define _TIF_FREEZE		(1 << TIF_FREEZE)
+#define _TIF_RESTORE_RSE	(1 << TIF_RESTORE_RSE)
 
 /* "work to do on user-return" bits */
-#define TIF_ALLWORK_MASK	(_TIF_SIGPENDING|_TIF_PERFMON_WORK|_TIF_SYSCALL_AUDIT|\
+#define TIF_ALLWORK_MASK	(_TIF_SIGPENDING|_TIF_NOTIFY_RESUME|_TIF_SYSCALL_AUDIT|\
 				 _TIF_NEED_RESCHED| _TIF_SYSCALL_TRACE|\
 				 _TIF_RESTORE_SIGMASK)
 /* like TIF_ALLWORK_BITS but sans TIF_SYSCALL_TRACE or TIF_SYSCALL_AUDIT */
Index: linux/kernel/signal.c
=================================--- linux.orig/kernel/signal.c	2007-08-28 16:54:18.000000000 +0800
+++ linux/kernel/signal.c	2007-08-28 16:54:41.000000000 +0800
@@ -1600,9 +1600,12 @@ static void ptrace_stop(int exit_code, i
 	current->last_siginfo = info;
 	current->exit_code = exit_code;
 
+	spin_unlock_irq(&current->sighand->siglock);
 	/* Let the debugger run.  */
+	arch_ptrace_stop();
+
 	set_current_state(TASK_TRACED);
-	spin_unlock_irq(&current->sighand->siglock);
+
 	try_to_freeze();
 	read_lock(&tasklist_lock);
 	if (may_ptrace_stop()) {
Index: linux/include/linux/ptrace.h
=================================--- linux.orig/include/linux/ptrace.h	2007-08-28 16:54:18.000000000 +0800
+++ linux/include/linux/ptrace.h	2007-08-28 16:54:41.000000000 +0800
@@ -128,6 +128,10 @@ int generic_ptrace_pokedata(struct task_
 #define force_successful_syscall_return() do { } while (0)
 #endif
 
+#ifndef HAVE_ARCH_PTRACE_STOP
+#define arch_ptrace_stop()	do { } while (0)
+#endif
+
 #endif
 
 #endif
