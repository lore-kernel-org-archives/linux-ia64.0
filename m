From: shaohua.li@intel.com
Date: Wed, 17 Sep 2008 08:13:22 +0000
Subject: [patch 2/4] ia64 use trace hook
Message-Id: <20080917082022.191956457@sli10-desk.sh.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Make IA64 use generic trace hook in some pathes.

Signed-off-by: Roland McGrath <roland@redhat.com>
Signed-off-by: Shaohua Li <shaohua.li@intel.com>
---
 arch/ia64/include/asm/thread_info.h |    3 --
 arch/ia64/kernel/perfmon.c          |    7 ++---
 arch/ia64/kernel/process.c          |   21 +++++------------
 arch/ia64/kernel/ptrace.c           |   43 +++++++++---------------------------
 arch/ia64/kernel/signal.c           |    8 ++++++
 5 files changed, 28 insertions(+), 54 deletions(-)

Index: linux/arch/ia64/include/asm/thread_info.h
=================================--- linux.orig/arch/ia64/include/asm/thread_info.h	2008-09-17 13:30:38.000000000 +0800
+++ linux/arch/ia64/include/asm/thread_info.h	2008-09-17 13:54:06.000000000 +0800
@@ -87,9 +87,6 @@ struct thread_info {
 #define alloc_task_struct()	((struct task_struct *)__get_free_pages(GFP_KERNEL | __GFP_COMP, KERNEL_STACK_SIZE_ORDER))
 #define free_task_struct(tsk)	free_pages((unsigned long) (tsk), KERNEL_STACK_SIZE_ORDER)
 
-#define tsk_set_notify_resume(tsk) \
-	set_ti_thread_flag(task_thread_info(tsk), TIF_NOTIFY_RESUME)
-extern void tsk_clear_notify_resume(struct task_struct *tsk);
 #endif /* !__ASSEMBLY */
 
 /*
Index: linux/arch/ia64/kernel/perfmon.c
=================================--- linux.orig/arch/ia64/kernel/perfmon.c	2008-09-17 13:30:38.000000000 +0800
+++ linux/arch/ia64/kernel/perfmon.c	2008-09-17 13:54:06.000000000 +0800
@@ -40,6 +40,7 @@
 #include <linux/capability.h>
 #include <linux/rcupdate.h>
 #include <linux/completion.h>
+#include <linux/tracehook.h>
 
 #include <asm/errno.h>
 #include <asm/intrinsics.h>
@@ -3684,7 +3685,7 @@ pfm_restart(pfm_context_t *ctx, void *ar
 
 		PFM_SET_WORK_PENDING(task, 1);
 
-		tsk_set_notify_resume(task);
+		set_notify_resume(task);
 
 		/*
 		 * XXX: send reschedule if task runs on another CPU
@@ -5044,8 +5045,6 @@ pfm_handle_work(void)
 
 	PFM_SET_WORK_PENDING(current, 0);
 
-	tsk_clear_notify_resume(current);
-
 	regs = task_pt_regs(current);
 
 	/*
@@ -5414,7 +5413,7 @@ pfm_overflow_handler(struct task_struct 
 			 * when coming from ctxsw, current still points to the
 			 * previous task, therefore we must work with task and not current.
 			 */
-			tsk_set_notify_resume(task);
+			set_notify_resume(task);
 		}
 		/*
 		 * defer until state is changed (shorten spin window). the context is locked
Index: linux/arch/ia64/kernel/process.c
=================================--- linux.orig/arch/ia64/kernel/process.c	2008-09-17 13:30:38.000000000 +0800
+++ linux/arch/ia64/kernel/process.c	2008-09-17 13:54:06.000000000 +0800
@@ -28,6 +28,7 @@
 #include <linux/delay.h>
 #include <linux/kdebug.h>
 #include <linux/utsname.h>
+#include <linux/tracehook.h>
 
 #include <asm/cpu.h>
 #include <asm/delay.h>
@@ -160,21 +161,6 @@ show_regs (struct pt_regs *regs)
 		show_stack(NULL, NULL);
 }
 
-void tsk_clear_notify_resume(struct task_struct *tsk)
-{
-#ifdef CONFIG_PERFMON
-	if (tsk->thread.pfm_needs_checking)
-		return;
-#endif
-	if (test_ti_thread_flag(task_thread_info(tsk), TIF_RESTORE_RSE))
-		return;
-	clear_ti_thread_flag(task_thread_info(tsk), TIF_NOTIFY_RESUME);
-}
-
-/*
- * do_notify_resume_user():
- *	Called from notify_resume_user at entry.S, with interrupts disabled.
- */
 void
 do_notify_resume_user(sigset_t *unused, struct sigscratch *scr, long in_syscall)
 {
@@ -203,6 +189,11 @@ do_notify_resume_user(sigset_t *unused, 
 		ia64_do_signal(scr, in_syscall);
 	}
 
+	if (test_thread_flag(TIF_NOTIFY_RESUME)) {
+		clear_thread_flag(TIF_NOTIFY_RESUME);
+		tracehook_notify_resume(&scr->pt);
+	}
+
 	/* copy user rbs to kernel rbs */
 	if (unlikely(test_thread_flag(TIF_RESTORE_RSE))) {
 		local_irq_enable();	/* force interrupt enable */
Index: linux/arch/ia64/kernel/ptrace.c
=================================--- linux.orig/arch/ia64/kernel/ptrace.c	2008-09-17 13:53:48.000000000 +0800
+++ linux/arch/ia64/kernel/ptrace.c	2008-09-17 13:54:06.000000000 +0800
@@ -22,6 +22,7 @@
 #include <linux/signal.h>
 #include <linux/regset.h>
 #include <linux/elf.h>
+#include <linux/tracehook.h>
 
 #include <asm/pgtable.h>
 #include <asm/processor.h>
@@ -603,7 +604,7 @@ void ia64_ptrace_stop(void)
 {
 	if (test_and_set_tsk_thread_flag(current, TIF_RESTORE_RSE))
 		return;
-	tsk_set_notify_resume(current);
+	set_notify_resume(current);
 	unw_init_running(do_sync_rbs, ia64_sync_user_rbs);
 }
 
@@ -613,7 +614,6 @@ void ia64_ptrace_stop(void)
 void ia64_sync_krbs(void)
 {
 	clear_tsk_thread_flag(current, TIF_RESTORE_RSE);
-	tsk_clear_notify_resume(current);
 
 	unw_init_running(do_sync_rbs, ia64_sync_kernel_rbs);
 }
@@ -644,7 +644,7 @@ ptrace_attach_sync_user_rbs (struct task
 		spin_lock_irq(&child->sighand->siglock);
 		if (child->state = TASK_STOPPED &&
 		    !test_and_set_tsk_thread_flag(child, TIF_RESTORE_RSE)) {
-			tsk_set_notify_resume(child);
+			set_notify_resume(child);
 
 			child->state = TASK_TRACED;
 			stopped = 1;
@@ -1232,27 +1232,6 @@ arch_ptrace (struct task_struct *child, 
 }
 
 
-static void
-syscall_trace (void)
-{
-	/*
-	 * The 0x80 provides a way for the tracing parent to
-	 * distinguish between a syscall stop and SIGTRAP delivery.
-	 */
-	ptrace_notify(SIGTRAP
-		      | ((current->ptrace & PT_TRACESYSGOOD) ? 0x80 : 0));
-
-	/*
-	 * This isn't the same as continuing with a signal, but it
-	 * will do for normal use.  strace only continues with a
-	 * signal if the stopping signal is not SIGTRAP.  -brl
-	 */
-	if (current->exit_code) {
-		send_sig(current->exit_code, current, 1);
-		current->exit_code = 0;
-	}
-}
-
 /* "asmlinkage" so the input arguments are preserved... */
 
 asmlinkage void
@@ -1260,9 +1239,8 @@ syscall_trace_enter (long arg0, long arg
 		     long arg4, long arg5, long arg6, long arg7,
 		     struct pt_regs regs)
 {
-	if (test_thread_flag(TIF_SYSCALL_TRACE) 
-	    && (current->ptrace & PT_PTRACED))
-		syscall_trace();
+	if (test_thread_flag(TIF_SYSCALL_TRACE))
+		tracehook_report_syscall_entry(&regs);
 
 	/* copy user rbs to kernel rbs */
 	if (test_thread_flag(TIF_RESTORE_RSE))
@@ -1292,6 +1270,8 @@ syscall_trace_leave (long arg0, long arg
 		     long arg4, long arg5, long arg6, long arg7,
 		     struct pt_regs regs)
 {
+	int step;
+
 	if (unlikely(current->audit_context)) {
 		int success = AUDITSC_RESULT(regs.r10);
 		long result = regs.r8;
@@ -1301,10 +1281,9 @@ syscall_trace_leave (long arg0, long arg
 		audit_syscall_exit(success, result);
 	}
 
-	if ((test_thread_flag(TIF_SYSCALL_TRACE)
-	    || test_thread_flag(TIF_SINGLESTEP))
-	    && (current->ptrace & PT_PTRACED))
-		syscall_trace();
+	step = test_thread_flag(TIF_SINGLESTEP);
+	if (step || test_thread_flag(TIF_SYSCALL_TRACE))
+		tracehook_report_syscall_exit(&regs, step);
 
 	/* copy user rbs to kernel rbs */
 	if (test_thread_flag(TIF_RESTORE_RSE))
@@ -1940,7 +1919,7 @@ gpregs_writeback(struct task_struct *tar
 {
 	if (test_and_set_tsk_thread_flag(target, TIF_RESTORE_RSE))
 		return 0;
-	tsk_set_notify_resume(target);
+	set_notify_resume(target);
 	return do_regset_call(do_gpregs_writeback, target, regset, 0, 0,
 		NULL, NULL);
 }
Index: linux/arch/ia64/kernel/signal.c
=================================--- linux.orig/arch/ia64/kernel/signal.c	2008-09-17 13:30:38.000000000 +0800
+++ linux/arch/ia64/kernel/signal.c	2008-09-17 13:54:06.000000000 +0800
@@ -11,6 +11,7 @@
 #include <linux/kernel.h>
 #include <linux/mm.h>
 #include <linux/ptrace.h>
+#include <linux/tracehook.h>
 #include <linux/sched.h>
 #include <linux/signal.h>
 #include <linux/smp.h>
@@ -439,6 +440,13 @@ handle_signal (unsigned long sig, struct
 		sigaddset(&current->blocked, sig);
 	recalc_sigpending();
 	spin_unlock_irq(&current->sighand->siglock);
+
+	/*
+	 * Let tracing know that we've done the handler setup.
+	 */
+	tracehook_signal_handler(sig, info, ka, &scr->pt,
+				 test_thread_flag(TIF_SINGLESTEP));
+
 	return 1;
 }
 

-- 
