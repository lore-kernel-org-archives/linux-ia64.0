From: Keith Owens <kaos@sgi.com>
Date: Tue, 07 Dec 2004 06:40:05 +0000
Subject: [RFC] Add SIGDELAYED processing
Message-Id: <15945.1102401605@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Note: Compiles but not tested yet.  Being thrown open for comments
while I debug the code.

Some of the work on recoverable MCA events has a requirement to send a
signal to a user process.  But it is not safe to send signals from
MCA/INIT/NMI/PMI, because the rest of the kernel is an unknown state.
This patch adds set_sigdelayed() which is called from the problem
contexts to set the delayed signal.  The delayed signal will be
delivered from the right context on the next transition from kernel to
user space.

A recoverable MCA handler that wants to kill a user task just does

  set_sigdelayed(pid, signo, code, addr);

The patch adds flag bit TIF_SIGDELAYED.  If that bit is set when we run
ia64_leave_kernel or ia64_leave_syscall then the delayed signal is
delivered and cleared.  Adding and testing TIF_SIGDELAYED has no effect
on the fast path for ia64_leave_kernel/syscall, it is folded into the
existing test for "any work to do on user-return?".

There is a very small race which requires a change to switch_to() to
close.

* The offending task is in control when the MCA is delivered, so it is
  the only task that gets TIF_SIGDELAYED set.

* That task is scheduled off the cpu without going through
  ia64_leave_kernel/syscall, so it never delivers the signal to itself.

* The MCA aborted the I/O that the offending task was waiting on, so
  the offending task never gets rescheduled.  It is hung forever (or
  until somebody does a manual kill).

To close that small race, __switch_to() copies the sigdelayed state
from the previous task to the new task, iff the previous task was
marked TIF_SIGDELAYED.  This adds another 3 bundles to the fast
__switch_to() path.  I never like adding extra code to the fast path,
any better ideas for closing this race?


Index: linux/arch/ia64/kernel/entry.S
=================================--- linux.orig/arch/ia64/kernel/entry.S	Tue Dec  7 13:20:11 2004
+++ linux/arch/ia64/kernel/entry.S	Tue Dec  7 16:38:58 2004
@@ -1057,6 +1057,9 @@ skip_rbs_switch:
 	 *	p6 = TRUE if work-pending-check needs to be redone
 	 */
 .work_pending:
+	tbit.nz p6,p0=r31,TIF_SIGDELAYED		// signal delayed from  MCA/INIT/NMI/PMI context?
+(p6)	br.cond.sptk.few .sigdelayed
+	;;
 	tbit.z p6,p0=r31,TIF_NEED_RESCHED		// current_thread_info()->need_resched=0?
 (p6)	br.cond.sptk.few .notify
 #ifdef CONFIG_PREEMPT
@@ -1082,6 +1085,18 @@ skip_rbs_switch:
 .ret10:	cmp.ne p6,p0=r0,r0				// p6 <- 0
 (pLvSys)br.cond.sptk.many .work_processed_syscall	// don't re-check
 	br.cond.sptk.many .work_processed_kernel	// don't re-check
+
+// There is a delayed signal that was detected in MCA/INIT/NMI/PMI context where
+// it could not be delivered.  Deliver it now.  The signal might be for us and
+// may set TIF_SIGPENDING, so redrive ia64_leave_* after processing the delayed
+// signal.
+
+.sigdelayed:
+	br.call.sptk.many rp=do_sigdelayed
+	cmp.eq p6,p0=r0,r0				// p6 <- 1, always re-check
+(pLvSys)br.cond.sptk.many .work_processed_syscall	// re-check
+	br.cond.sptk.many .work_processed_kernel	// re-check
+
 END(ia64_leave_kernel)
 
 ENTRY(handle_syscall_error)
Index: linux/arch/ia64/kernel/signal.c
=================================--- linux.orig/arch/ia64/kernel/signal.c	Tue Dec  7 15:42:18 2004
+++ linux/arch/ia64/kernel/signal.c	Tue Dec  7 17:01:07 2004
@@ -589,3 +589,60 @@ ia64_do_signal (sigset_t *oldset, struct
 	}
 	return 0;
 }
+
+/* Set a delayed signal that was detected in MCA/INIT/NMI/PMI context where it
+ * could not be delivered.  The data is stored in the current task to ensure
+ * that the signal gets delivered as soon as this task leave the kernel.  It is
+ * also stored in the target task, just in case that task gets scheduled on
+ * another cpu before the current task has a chance to send the signal.  In
+ * either case, the target task will be killed before it can do any useful
+ * work.
+ */
+
+void
+set_sigdelayed(pid_t pid, int signo, int code, void __user *addr)
+{
+	struct task_struct *target;
+	current->thread_info->sigdelayed.signo = signo;
+	current->thread_info->sigdelayed.code = code;
+	current->thread_info->sigdelayed.addr = addr;
+	current->thread_info->sigdelayed.pid = pid;
+	wmb();
+	set_tsk_thread_flag(current, TIF_SIGDELAYED);
+	target = find_task_by_pid(pid);
+	if (!target)
+		return;
+	target->thread_info->sigdelayed.signo = signo;
+	target->thread_info->sigdelayed.code = code;
+	target->thread_info->sigdelayed.addr = addr;
+	target->thread_info->sigdelayed.pid = pid;
+	wmb();
+	set_tsk_thread_flag(target, TIF_SIGDELAYED);
+}
+
+/* Called from entry.S when it detects TIF_SIGDELAYED, a delayed signal that
+ * was detected in MCA/INIT/NMI/PMI context where it could not be delivered.
+ * The data for the delayed signal was stored in thread_info->sigdelayed.
+ */
+
+void
+do_sigdelayed(void)
+{
+	struct siginfo siginfo;
+	pid_t pid;
+	struct task_struct *target;
+
+	clear_thread_flag(TIF_SIGDELAYED);
+	memset(&siginfo, 0, sizeof(siginfo));
+	siginfo.si_signo = current->thread_info->sigdelayed.signo;
+	siginfo.si_code = current->thread_info->sigdelayed.code;
+	siginfo.si_addr = current->thread_info->sigdelayed.addr;
+	pid = current->thread_info->sigdelayed.pid;
+	current->thread_info->sigdelayed.pid = 0;
+	if (!pid)
+		return;
+	target = find_task_by_pid(pid);
+	if (!target)
+		return;
+	force_sig_info(siginfo.si_signo, &siginfo, target);
+}
Index: linux/include/asm-ia64/signal.h
=================================--- linux.orig/include/asm-ia64/signal.h	Tue Oct 19 07:53:21 2004
+++ linux/include/asm-ia64/signal.h	Tue Dec  7 16:24:29 2004
@@ -177,6 +177,8 @@ struct k_sigaction {
 
 #define ptrace_signal_deliver(regs, cookie) do { } while (0)
 
+void set_sigdelayed(pid_t pid, int signo, int code, void __user *addr);
+
 #endif /* __KERNEL__ */
 
 # endif /* !__ASSEMBLY__ */
Index: linux/include/asm-ia64/system.h
=================================--- linux.orig/include/asm-ia64/system.h	Tue Oct 19 07:53:51 2004
+++ linux/include/asm-ia64/system.h	Tue Dec  7 16:55:21 2004
@@ -229,6 +229,12 @@ __switch_to
 		ia64_load_extra(next);								 \
 	ia64_psr(ia64_task_regs(next))->dfh = !ia64_is_local_fpu_owner(next);			 \
 	(last) = ia64_switch_to((next));							 \
+	if (unlikely(test_tsk_thread_flag((prev), TIF_SIGDELAYED))) {				 \
+		(next)->thread_info->sigdelayed = (prev)->thread_info->sigdelayed;		 \
+		(prev)->thread_info->sigdelayed.pid = 0;					 \
+		set_tsk_thread_flag((next), TIF_SIGDELAYED);					 \
+		clear_tsk_thread_flag((prev), TIF_SIGDELAYED);					 \
+	}											 \
 } while (0)
 
 #ifdef CONFIG_SMP
Index: linux/include/asm-ia64/thread_info.h
=================================--- linux.orig/include/asm-ia64/thread_info.h	Tue Oct 19 07:55:36 2004
+++ linux/include/asm-ia64/thread_info.h	Tue Dec  7 15:24:25 2004
@@ -27,6 +27,12 @@ struct thread_info {
 	mm_segment_t addr_limit;	/* user-level address space limit */
 	__s32 preempt_count;		/* 0=premptable, <0=BUG; will also serve as bh-counter */
 	struct restart_block restart_block;
+	struct {
+		int signo;
+		int code;
+		void __user *addr;
+		pid_t pid;
+	} sigdelayed;			/* Saved information for TIF_SIGDELAYED */
 };
 
 #define THREAD_SIZE			KERNEL_STACK_SIZE
@@ -66,18 +72,21 @@ struct thread_info {
 #define TIF_NEED_RESCHED	2	/* rescheduling necessary */
 #define TIF_SYSCALL_TRACE	3	/* syscall trace active */
 #define TIF_SYSCALL_AUDIT	4	/* syscall auditing active */
+#define TIF_SIGDELAYED		5	/* signal delayed from MCA/INIT/NMI/PMI context */
 #define TIF_POLLING_NRFLAG	16	/* true if poll_idle() is polling TIF_NEED_RESCHED */
 
-#define TIF_WORK_MASK		0x7	/* like TIF_ALLWORK_BITS but sans TIF_SYSCALL_TRACE */
-#define TIF_ALLWORK_MASK	0x1f	/* bits 0..4 are "work to do on user-return" bits */
-
 #define _TIF_SYSCALL_TRACE	(1 << TIF_SYSCALL_TRACE)
 #define _TIF_SYSCALL_AUDIT	(1 << TIF_SYSCALL_AUDIT)
 #define _TIF_SYSCALL_TRACEAUDIT	(_TIF_SYSCALL_TRACE|_TIF_SYSCALL_AUDIT)
 #define _TIF_NOTIFY_RESUME	(1 << TIF_NOTIFY_RESUME)
 #define _TIF_SIGPENDING		(1 << TIF_SIGPENDING)
 #define _TIF_NEED_RESCHED	(1 << TIF_NEED_RESCHED)
-#define _TIF_USEDFPU		(1 << TIF_USEDFPU)
+#define _TIF_SIGDELAYED	(1 << TIF_SIGDELAYED)
 #define _TIF_POLLING_NRFLAG	(1 << TIF_POLLING_NRFLAG)
 
+/* "work to do on user-return" bits */
+#define TIF_ALLWORK_MASK	(_TIF_NOTIFY_RESUME|_TIF_SIGPENDING|_TIF_NEED_RESCHED|_TIF_SYSCALL_TRACE|_TIF_SYSCALL_AUDIT|_TIF_SIGDELAYED)
+/* like TIF_ALLWORK_BITS but sans TIF_SYSCALL_TRACE or TIF_SYSCALL_AUDIT */
+#define TIF_WORK_MASK		(TIF_ALLWORK_MASK&~(_TIF_SYSCALL_TRACE|_TIF_SYSCALL_AUDIT))
+
 #endif /* _ASM_IA64_THREAD_INFO_H */

