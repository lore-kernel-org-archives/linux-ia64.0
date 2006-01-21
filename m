From: Keith Owens <kaos@sgi.com>
Date: Sat, 21 Jan 2006 23:55:25 +0000
Subject: [Patch 2.6.16-rc1] Delete MCA/INIT sigdelayed code
Message-Id: <32576.1137887725@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The only user of the MCA/INIT sigdelayed code (SGI's I/O probing) has
moved from the kernel into SAL.  Delete the MCA/INIT sigdelayed code.

Signed-off-by: Keith Owens <kaos@sgi.com>

---

 arch/ia64/kernel/entry.S       |   14 -----
 arch/ia64/kernel/signal.c      |  101 -----------------------------------------
 include/asm-ia64/signal.h      |    2 
 include/asm-ia64/thread_info.h |   11 ----
 4 files changed, 1 insertion(+), 127 deletions(-)

Index: linux/arch/ia64/kernel/entry.S
=================================--- linux.orig/arch/ia64/kernel/entry.S	2006-01-19 10:27:30.915948018 +1100
+++ linux/arch/ia64/kernel/entry.S	2006-01-22 10:40:27.302139077 +1100
@@ -1100,9 +1100,6 @@ skip_rbs_switch:
 	st8 [r2]=r8
 	st8 [r3]=r10
 .work_pending:
-	tbit.nz p6,p0=r31,TIF_SIGDELAYED		// signal delayed from  MCA/INIT/NMI/PMI context?
-(p6)	br.cond.sptk.few .sigdelayed
-	;;
 	tbit.z p6,p0=r31,TIF_NEED_RESCHED		// current_thread_info()->need_resched=0?
 (p6)	br.cond.sptk.few .notify
 #ifdef CONFIG_PREEMPT
@@ -1129,17 +1126,6 @@ skip_rbs_switch:
 (pLvSys)br.cond.sptk.few  .work_pending_syscall_end
 	br.cond.sptk.many .work_processed_kernel	// don't re-check
 
-// There is a delayed signal that was detected in MCA/INIT/NMI/PMI context where
-// it could not be delivered.  Deliver it now.  The signal might be for us and
-// may set TIF_SIGPENDING, so redrive ia64_leave_* after processing the delayed
-// signal.
-
-.sigdelayed:
-	br.call.sptk.many rp=do_sigdelayed
-	cmp.eq p6,p0=r0,r0				// p6 <- 1, always re-check
-(pLvSys)br.cond.sptk.few  .work_pending_syscall_end
-	br.cond.sptk.many .work_processed_kernel	// re-check
-
 .work_pending_syscall_end:
 	adds r2=PT(R8)+16,r12
 	adds r3=PT(R10)+16,r12
Index: linux/arch/ia64/kernel/signal.c
=================================--- linux.orig/arch/ia64/kernel/signal.c	2006-01-19 10:27:30.933523715 +1100
+++ linux/arch/ia64/kernel/signal.c	2006-01-22 10:41:20.166933167 +1100
@@ -588,104 +588,3 @@ ia64_do_signal (sigset_t *oldset, struct
 	}
 	return 0;
 }
-
-/* Set a delayed signal that was detected in MCA/INIT/NMI/PMI context where it
- * could not be delivered.  It is important that the target process is not
- * allowed to do any more work in user space.  Possible cases for the target
- * process:
- *
- * - It is sleeping and will wake up soon.  Store the data in the current task,
- *   the signal will be sent when the current task returns from the next
- *   interrupt.
- *
- * - It is running in user context.  Store the data in the current task, the
- *   signal will be sent when the current task returns from the next interrupt.
- *
- * - It is running in kernel context on this or another cpu and will return to
- *   user context.  Store the data in the target task, the signal will be sent
- *   to itself when the target task returns to user space.
- *
- * - It is running in kernel context on this cpu and will sleep before
- *   returning to user context.  Because this is also the current task, the
- *   signal will not get delivered and the task could sleep indefinitely.
- *   Store the data in the idle task for this cpu, the signal will be sent
- *   after the idle task processes its next interrupt.
- *
- * To cover all cases, store the data in the target task, the current task and
- * the idle task on this cpu.  Whatever happens, the signal will be delivered
- * to the target task before it can do any useful user space work.  Multiple
- * deliveries have no unwanted side effects.
- *
- * Note: This code is executed in MCA/INIT/NMI/PMI context, with interrupts
- * disabled.  It must not take any locks nor use kernel structures or services
- * that require locks.
- */
-
-/* To ensure that we get the right pid, check its start time.  To avoid extra
- * include files in thread_info.h, convert the task start_time to unsigned long,
- * giving us a cycle time of > 580 years.
- */
-static inline unsigned long
-start_time_ul(const struct task_struct *t)
-{
-	return t->start_time.tv_sec * NSEC_PER_SEC + t->start_time.tv_nsec;
-}
-
-void
-set_sigdelayed(pid_t pid, int signo, int code, void __user *addr)
-{
-	struct task_struct *t;
-	unsigned long start_time =  0;
-	int i;
-
-	for (i = 1; i <= 3; ++i) {
-		switch (i) {
-		case 1:
-			t = find_task_by_pid(pid);
-			if (t)
-				start_time = start_time_ul(t);
-			break;
-		case 2:
-			t = current;
-			break;
-		default:
-			t = idle_task(smp_processor_id());
-			break;
-		}
-
-		if (!t)
-			return;
-		task_thread_info(t)->sigdelayed.signo = signo;
-		task_thread_info(t)->sigdelayed.code = code;
-		task_thread_info(t)->sigdelayed.addr = addr;
-		task_thread_info(t)->sigdelayed.start_time = start_time;
-		task_thread_info(t)->sigdelayed.pid = pid;
-		wmb();
-		set_tsk_thread_flag(t, TIF_SIGDELAYED);
-	}
-}
-
-/* Called from entry.S when it detects TIF_SIGDELAYED, a delayed signal that
- * was detected in MCA/INIT/NMI/PMI context where it could not be delivered.
- */
-
-void
-do_sigdelayed(void)
-{
-	struct siginfo siginfo;
-	pid_t pid;
-	struct task_struct *t;
-
-	clear_thread_flag(TIF_SIGDELAYED);
-	memset(&siginfo, 0, sizeof(siginfo));
-	siginfo.si_signo = current_thread_info()->sigdelayed.signo;
-	siginfo.si_code = current_thread_info()->sigdelayed.code;
-	siginfo.si_addr = current_thread_info()->sigdelayed.addr;
-	pid = current_thread_info()->sigdelayed.pid;
-	t = find_task_by_pid(pid);
-	if (!t)
-		return;
-	if (current_thread_info()->sigdelayed.start_time != start_time_ul(t))
-		return;
-	force_sig_info(siginfo.si_signo, &siginfo, t);
-}
Index: linux/include/asm-ia64/signal.h
=================================--- linux.orig/include/asm-ia64/signal.h	2006-01-03 14:21:10.000000000 +1100
+++ linux/include/asm-ia64/signal.h	2006-01-22 10:40:27.347054769 +1100
@@ -158,8 +158,6 @@ struct k_sigaction {
 
 #define ptrace_signal_deliver(regs, cookie) do { } while (0)
 
-void set_sigdelayed(pid_t pid, int signo, int code, void __user *addr);
-
 #endif /* __KERNEL__ */
 
 # endif /* !__ASSEMBLY__ */
Index: linux/include/asm-ia64/thread_info.h
=================================--- linux.orig/include/asm-ia64/thread_info.h	2006-01-19 10:27:37.988213223 +1100
+++ linux/include/asm-ia64/thread_info.h	2006-01-22 10:42:17.512555905 +1100
@@ -29,13 +29,6 @@ struct thread_info {
 	mm_segment_t addr_limit;	/* user-level address space limit */
 	int preempt_count;		/* 0=premptable, <0=BUG; will also serve as bh-counter */
 	struct restart_block restart_block;
-	struct {
-		int signo;
-		int code;
-		void __user *addr;
-		unsigned long start_time;
-		pid_t pid;
-	} sigdelayed;			/* Saved information for TIF_SIGDELAYED */
 };
 
 #define THREAD_SIZE			KERNEL_STACK_SIZE
@@ -89,7 +82,6 @@ struct thread_info {
 #define TIF_NEED_RESCHED	2	/* rescheduling necessary */
 #define TIF_SYSCALL_TRACE	3	/* syscall trace active */
 #define TIF_SYSCALL_AUDIT	4	/* syscall auditing active */
-#define TIF_SIGDELAYED		5	/* signal delayed from MCA/INIT/NMI/PMI context */
 #define TIF_POLLING_NRFLAG	16	/* true if poll_idle() is polling TIF_NEED_RESCHED */
 #define TIF_MEMDIE		17
 #define TIF_MCA_INIT		18	/* this task is processing MCA or INIT */
@@ -101,13 +93,12 @@ struct thread_info {
 #define _TIF_NOTIFY_RESUME	(1 << TIF_NOTIFY_RESUME)
 #define _TIF_SIGPENDING		(1 << TIF_SIGPENDING)
 #define _TIF_NEED_RESCHED	(1 << TIF_NEED_RESCHED)
-#define _TIF_SIGDELAYED		(1 << TIF_SIGDELAYED)
 #define _TIF_POLLING_NRFLAG	(1 << TIF_POLLING_NRFLAG)
 #define _TIF_MCA_INIT		(1 << TIF_MCA_INIT)
 #define _TIF_DB_DISABLED	(1 << TIF_DB_DISABLED)
 
 /* "work to do on user-return" bits */
-#define TIF_ALLWORK_MASK	(_TIF_NOTIFY_RESUME|_TIF_SIGPENDING|_TIF_NEED_RESCHED|_TIF_SYSCALL_TRACE|_TIF_SYSCALL_AUDIT|_TIF_SIGDELAYED)
+#define TIF_ALLWORK_MASK	(_TIF_NOTIFY_RESUME|_TIF_SIGPENDING|_TIF_NEED_RESCHED|_TIF_SYSCALL_TRACE|_TIF_SYSCALL_AUDIT)
 /* like TIF_ALLWORK_BITS but sans TIF_SYSCALL_TRACE or TIF_SYSCALL_AUDIT */
 #define TIF_WORK_MASK		(TIF_ALLWORK_MASK&~(_TIF_SYSCALL_TRACE|_TIF_SYSCALL_AUDIT))
 

