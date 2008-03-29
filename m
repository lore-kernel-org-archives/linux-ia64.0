From: Roland McGrath <roland@redhat.com>
Date: Sat, 29 Mar 2008 03:14:51 +0000
Subject: [PATCH 2/2] x86 TS_RESTORE_SIGMASK
Message-Id: <20080329031451.D2E1226FA1D@magilla.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080329001230.D013726FA1D@magilla.localdomain>
	<20080329001341.7F93826FA1D@magilla.localdomain>
	<alpine.LFD.1.00.0803281746480.14670@woody.linux-foundation.org>
	<20080329022408.0DD4726FA1D@magilla.localdomain>
	<20080329031413.EA38926FA1D@magilla.localdomain>
In-Reply-To: Roland McGrath's message of  Friday, 28 March 2008 20:14:13 -0700 <20080329031413.EA38926FA1D@magilla.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, linux-s390@vger.kernel.org, tony.luck@intel.com, linux-ia64@vger.kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

Replace TIF_RESTORE_SIGMASK with TS_RESTORE_SIGMASK and define
our own set_restore_sigmask() function.  This saves the costly
SMP-safe set_bit operation, which we do not need for the sigmask
flag since TIF_SIGPENDING always has to be set too.

Signed-off-by: Roland McGrath <roland@redhat.com>
---
 arch/x86/ia32/ia32_signal.c      |    2 +-
 arch/x86/kernel/signal_32.c      |   19 ++++++++++---------
 arch/x86/kernel/signal_64.c      |   16 +++++++++-------
 include/asm-x86/thread_info_32.h |   13 +++++++++++--
 include/asm-x86/thread_info_64.h |   13 +++++++++++--
 5 files changed, 42 insertions(+), 21 deletions(-)

diff --git a/arch/x86/ia32/ia32_signal.c b/arch/x86/ia32/ia32_signal.c
index 101b4b8..b7a531f 100644
--- a/arch/x86/ia32/ia32_signal.c
+++ b/arch/x86/ia32/ia32_signal.c
@@ -128,7 +128,7 @@ asmlinkage long sys32_sigsuspend(int history0, int history1, old_sigset_t mask)
 
 	current->state = TASK_INTERRUPTIBLE;
 	schedule();
-	set_thread_flag(TIF_RESTORE_SIGMASK);
+	set_restore_sigmask();
 	return -ERESTARTNOHAND;
 }
 
diff --git a/arch/x86/kernel/signal_32.c b/arch/x86/kernel/signal_32.c
index a06fa55..f8fbc20 100644
--- a/arch/x86/kernel/signal_32.c
+++ b/arch/x86/kernel/signal_32.c
@@ -45,7 +45,7 @@ sys_sigsuspend(int history0, int history1, old_sigset_t mask)
 
 	current->state = TASK_INTERRUPTIBLE;
 	schedule();
-	set_thread_flag(TIF_RESTORE_SIGMASK);
+	set_restore_sigmask();
 	return -ERESTARTNOHAND;
 }
 
@@ -591,7 +591,7 @@ static void do_signal(struct pt_regs *regs)
 	if (!user_mode(regs))
 		return;
 
-	if (test_thread_flag(TIF_RESTORE_SIGMASK))
+	if (current_thread_info()->status & TS_RESTORE_SIGMASK)
 		oldset = &current->saved_sigmask;
 	else
 		oldset = &current->blocked;
@@ -608,12 +608,13 @@ static void do_signal(struct pt_regs *regs)
 
 		/* Whee!  Actually deliver the signal.  */
 		if (handle_signal(signr, &info, &ka, oldset, regs) = 0) {
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
 		}
 
 		return;
@@ -639,8 +640,8 @@ static void do_signal(struct pt_regs *regs)
 
 	/* if there's no signal to deliver, we just put the saved sigmask
 	 * back */
-	if (test_thread_flag(TIF_RESTORE_SIGMASK)) {
-		clear_thread_flag(TIF_RESTORE_SIGMASK);
+	if (current_thread_info()->status & TS_RESTORE_SIGMASK) {
+		current_thread_info()->status &= ~TS_RESTORE_SIGMASK;
 		sigprocmask(SIG_SETMASK, &current->saved_sigmask, NULL);
 	}
 }
@@ -660,7 +661,7 @@ void do_notify_resume(struct pt_regs *regs, void *_unused,
 	}
 
 	/* deal with pending signal delivery */
-	if (thread_info_flags & (_TIF_SIGPENDING | _TIF_RESTORE_SIGMASK))
+	if (thread_info_flags & _TIF_SIGPENDING)
 		do_signal(regs);
 
 	if (thread_info_flags & _TIF_HRTICK_RESCHED)
diff --git a/arch/x86/kernel/signal_64.c b/arch/x86/kernel/signal_64.c
index 016413b..fc97dec 100644
--- a/arch/x86/kernel/signal_64.c
+++ b/arch/x86/kernel/signal_64.c
@@ -443,7 +443,7 @@ static void do_signal(struct pt_regs *regs)
 	if (!user_mode(regs))
 		return;
 
-	if (test_thread_flag(TIF_RESTORE_SIGMASK))
+	if (current_thread_info()->status & TS_RESTORE_SIGMASK)
 		oldset = &current->saved_sigmask;
 	else
 		oldset = &current->blocked;
@@ -460,11 +460,13 @@ static void do_signal(struct pt_regs *regs)
 
 		/* Whee!  Actually deliver the signal.  */
 		if (handle_signal(signr, &info, &ka, oldset, regs) = 0) {
-			/* a signal was successfully delivered; the saved
+			/*
+			 * A signal was successfully delivered; the saved
 			 * sigmask will have been stored in the signal frame,
 			 * and will be restored by sigreturn, so we can simply
-			 * clear the TIF_RESTORE_SIGMASK flag */
-			clear_thread_flag(TIF_RESTORE_SIGMASK);
+			 * clear the TS_RESTORE_SIGMASK flag.
+			 */
+			current_thread_info()->status &= ~TS_RESTORE_SIGMASK;
 		}
 		return;
 	}
@@ -490,8 +492,8 @@ static void do_signal(struct pt_regs *regs)
 
 	/* if there's no signal to deliver, we just put the saved sigmask
 	   back. */
-	if (test_thread_flag(TIF_RESTORE_SIGMASK)) {
-		clear_thread_flag(TIF_RESTORE_SIGMASK);
+	if (current_thread_info()->status & TS_RESTORE_SIGMASK) {
+		current_thread_info()->status &= ~TS_RESTORE_SIGMASK;
 		sigprocmask(SIG_SETMASK, &current->saved_sigmask, NULL);
 	}
 }
@@ -517,7 +519,7 @@ do_notify_resume(struct pt_regs *regs, void *unused, __u32 thread_info_flags)
 #endif /* CONFIG_X86_MCE */
 
 	/* deal with pending signal delivery */
-	if (thread_info_flags & (_TIF_SIGPENDING|_TIF_RESTORE_SIGMASK))
+	if (thread_info_flags & _TIF_SIGPENDING)
 		do_signal(regs);
 
 	if (thread_info_flags & _TIF_HRTICK_RESCHED)
diff --git a/include/asm-x86/thread_info_32.h b/include/asm-x86/thread_info_32.h
index 5bd5082..4c4fd4e 100644
--- a/include/asm-x86/thread_info_32.h
+++ b/include/asm-x86/thread_info_32.h
@@ -131,7 +131,6 @@ static inline struct thread_info *current_thread_info(void)
 #define TIF_SYSCALL_EMU		5	/* syscall emulation active */
 #define TIF_SYSCALL_AUDIT	6	/* syscall auditing active */
 #define TIF_SECCOMP		7	/* secure computing */
-#define TIF_RESTORE_SIGMASK	8	/* restore signal mask in do_signal() */
 #define TIF_HRTICK_RESCHED	9	/* reprogram hrtick timer */
 #define TIF_MEMDIE		16
 #define TIF_DEBUG		17	/* uses debug registers */
@@ -151,7 +150,6 @@ static inline struct thread_info *current_thread_info(void)
 #define _TIF_SYSCALL_EMU	(1<<TIF_SYSCALL_EMU)
 #define _TIF_SYSCALL_AUDIT	(1<<TIF_SYSCALL_AUDIT)
 #define _TIF_SECCOMP		(1<<TIF_SECCOMP)
-#define _TIF_RESTORE_SIGMASK	(1<<TIF_RESTORE_SIGMASK)
 #define _TIF_HRTICK_RESCHED	(1<<TIF_HRTICK_RESCHED)
 #define _TIF_DEBUG		(1<<TIF_DEBUG)
 #define _TIF_IO_BITMAP		(1<<TIF_IO_BITMAP)
@@ -186,9 +184,20 @@ static inline struct thread_info *current_thread_info(void)
  */
 #define TS_USEDFPU		0x0001	/* FPU was used by this task this quantum (SMP) */
 #define TS_POLLING		0x0002	/* True if in idle loop and not sleeping */
+#define TS_RESTORE_SIGMASK	0x0004	/* restore signal mask in do_signal() */
 
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
 #endif /* __KERNEL__ */
 
 #endif /* _ASM_THREAD_INFO_H */
diff --git a/include/asm-x86/thread_info_64.h b/include/asm-x86/thread_info_64.h
index 6c9b214..ead94d5 100644
--- a/include/asm-x86/thread_info_64.h
+++ b/include/asm-x86/thread_info_64.h
@@ -110,7 +110,6 @@ static inline struct thread_info *stack_thread_info(void)
 #define TIF_IRET		5	/* force IRET */
 #define TIF_SYSCALL_AUDIT	7	/* syscall auditing active */
 #define TIF_SECCOMP		8	/* secure computing */
-#define TIF_RESTORE_SIGMASK	9	/* restore signal mask in do_signal */
 #define TIF_MCE_NOTIFY		10	/* notify userspace of an MCE */
 #define TIF_HRTICK_RESCHED	11	/* reprogram hrtick timer */
 /* 16 free */
@@ -133,7 +132,6 @@ static inline struct thread_info *stack_thread_info(void)
 #define _TIF_IRET		(1<<TIF_IRET)
 #define _TIF_SYSCALL_AUDIT	(1<<TIF_SYSCALL_AUDIT)
 #define _TIF_SECCOMP		(1<<TIF_SECCOMP)
-#define _TIF_RESTORE_SIGMASK	(1<<TIF_RESTORE_SIGMASK)
 #define _TIF_MCE_NOTIFY		(1<<TIF_MCE_NOTIFY)
 #define _TIF_HRTICK_RESCHED	(1<<TIF_HRTICK_RESCHED)
 #define _TIF_IA32		(1<<TIF_IA32)
@@ -174,9 +172,20 @@ static inline struct thread_info *stack_thread_info(void)
 #define TS_USEDFPU		0x0001	/* FPU was used by this task this quantum (SMP) */
 #define TS_COMPAT		0x0002	/* 32bit syscall active */
 #define TS_POLLING		0x0004	/* true if in idle loop and not sleeping */
+#define TS_RESTORE_SIGMASK	0x0008	/* restore signal mask in do_signal() */
 
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
 #endif /* __KERNEL__ */
 
 #endif /* _ASM_THREAD_INFO_H */
