From: Roland McGrath <roland@redhat.com>
Date: Wed, 30 Apr 2008 21:40:14 +0000
Subject: [PATCH] ia64 TS_RESTORE_SIGMASK
Message-Id: <20080430214014.7E2C426FA05@magilla.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Replace TIF_RESTORE_SIGMASK with TS_RESTORE_SIGMASK and define
our own set_restore_sigmask() function.  This saves the costly
SMP-safe set_bit operation, which we do not need for the sigmask
flag since TIF_SIGPENDING always has to be set too.

Signed-off-by: Roland McGrath <roland@redhat.com>
---
 arch/ia64/ia32/ia32_signal.c   |    2 +-
 arch/ia64/kernel/signal.c      |   15 ++++++++-------
 include/asm-ia64/thread_info.h |   13 +++++++++++--
 3 files changed, 20 insertions(+), 10 deletions(-)

diff --git a/arch/ia64/ia32/ia32_signal.c b/arch/ia64/ia32/ia32_signal.c
index 256a7fa..b763ca1 100644
--- a/arch/ia64/ia32/ia32_signal.c
+++ b/arch/ia64/ia32/ia32_signal.c
@@ -463,7 +463,7 @@ sys32_sigsuspend (int history0, int history1, old_sigset_t mask)
 
 	current->state = TASK_INTERRUPTIBLE;
 	schedule();
-	set_thread_flag(TIF_RESTORE_SIGMASK);
+	set_restore_sigmask();
 	return -ERESTARTNOHAND;
 }
 
diff --git a/arch/ia64/kernel/signal.c b/arch/ia64/kernel/signal.c
index 5740296..19c5a78 100644
--- a/arch/ia64/kernel/signal.c
+++ b/arch/ia64/kernel/signal.c
@@ -464,7 +464,7 @@ ia64_do_signal (struct sigscratch *scr, long in_syscall)
 	if (!user_mode(&scr->pt))
 		return;
 
-	if (test_thread_flag(TIF_RESTORE_SIGMASK))
+	if (current_thread_info()->status & TS_RESTORE_SIGMASK)
 		oldset = &current->saved_sigmask;
 	else
 		oldset = &current->blocked;
@@ -530,12 +530,13 @@ ia64_do_signal (struct sigscratch *scr, long in_syscall)
 		 * continue to iterate in this loop so we can deliver the SIGSEGV...
 		 */
 		if (handle_signal(signr, &ka, &info, oldset, scr)) {
-			/* a signal was successfully delivered; the saved
+			/*
+			 * A signal was successfully delivered; the saved
 			 * sigmask will have been stored in the signal frame,
 			 * and will be restored by sigreturn, so we can simply
-			 * clear the TIF_RESTORE_SIGMASK flag */
-			if (test_thread_flag(TIF_RESTORE_SIGMASK))
-				clear_thread_flag(TIF_RESTORE_SIGMASK);
+			 * clear the TS_RESTORE_SIGMASK flag.
+			 */
+			current_thread_info()->status &= ~TS_RESTORE_SIGMASK;
 			return;
 		}
 	}
@@ -566,8 +567,8 @@ ia64_do_signal (struct sigscratch *scr, long in_syscall)
 
 	/* if there's no signal to deliver, we just put the saved sigmask
 	 * back */
-	if (test_thread_flag(TIF_RESTORE_SIGMASK)) {
-		clear_thread_flag(TIF_RESTORE_SIGMASK);
+	if (current_thread_info()->status & TS_RESTORE_SIGMASK) {
+		current_thread_info()->status &= ~TS_RESTORE_SIGMASK;
 		sigprocmask(SIG_SETMASK, &current->saved_sigmask, NULL);
 	}
 }
diff --git a/include/asm-ia64/thread_info.h b/include/asm-ia64/thread_info.h
index f30e055..2422ac6 100644
--- a/include/asm-ia64/thread_info.h
+++ b/include/asm-ia64/thread_info.h
@@ -108,13 +108,11 @@ extern void tsk_clear_notify_resume(struct task_struct *tsk);
 #define TIF_DB_DISABLED		19	/* debug trap disabled for fsyscall */
 #define TIF_FREEZE		20	/* is freezing for suspend */
 #define TIF_RESTORE_RSE		21	/* user RBS is newer than kernel RBS */
-#define TIF_RESTORE_SIGMASK	22	/* restore signal mask in do_signal() */
 
 #define _TIF_SYSCALL_TRACE	(1 << TIF_SYSCALL_TRACE)
 #define _TIF_SYSCALL_AUDIT	(1 << TIF_SYSCALL_AUDIT)
 #define _TIF_SINGLESTEP		(1 << TIF_SINGLESTEP)
 #define _TIF_SYSCALL_TRACEAUDIT	(_TIF_SYSCALL_TRACE|_TIF_SYSCALL_AUDIT|_TIF_SINGLESTEP)
-#define _TIF_RESTORE_SIGMASK	(1 << TIF_RESTORE_SIGMASK)
 #define _TIF_NOTIFY_RESUME	(1 << TIF_NOTIFY_RESUME)
 #define _TIF_SIGPENDING		(1 << TIF_SIGPENDING)
 #define _TIF_NEED_RESCHED	(1 << TIF_NEED_RESCHED)
@@ -131,7 +129,18 @@ extern void tsk_clear_notify_resume(struct task_struct *tsk);
 #define TIF_WORK_MASK		(TIF_ALLWORK_MASK&~(_TIF_SYSCALL_TRACE|_TIF_SYSCALL_AUDIT))
 
 #define TS_POLLING		1 	/* true if in idle loop and not sleeping */
+#define TS_RESTORE_SIGMASK	2	/* restore signal mask in do_signal() */
 
 #define tsk_is_polling(t) (task_thread_info(t)->status & TS_POLLING)
 
+#ifndef __ASSEMBLY__
+#define HAVE_SET_RESTORE_SIGMASK	1
+static inline void set_restore_sigmask(void)
+{
+	struct thread_info *ti = current_thread_info();
+	ti->status |= TS_RESTORE_SIGMASK;
+	set_bit(TIF_SIGPENDING, &ti->flags);
+}
+#endif	/* !__ASSEMBLY__ */
+
 #endif /* _ASM_IA64_THREAD_INFO_H */
