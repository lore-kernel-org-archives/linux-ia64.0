From: Keith Owens <kaos@sgi.com>
Date: Wed, 08 Dec 2004 05:05:44 +0000
Subject: [patch 2.6.10-rc3] Add TIF_SIGDELAYED processing
Message-Id: <15449.1102482344@kao1.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Some of the work on recoverable MCA events has a requirement to send a
signal to a user process.  But it is not safe to send signals from
MCA/INIT/NMI/PMI, because the rest of the kernel is an unknown state.
This patch adds set_sigdelayed() which is called from the problem
contexts to set the delayed signal.  The delayed signal will be
delivered from the right context on the next transition from kernel to
user space.

If TIF_SIGDELAYED is set when we run ia64_leave_kernel or
ia64_leave_syscall then the delayed signal is delivered and cleared.
All code for sigdelayed processing is on the slow paths.

A recoverable MCA handler that wants to kill a user task just does

  set_sigdelayed(pid, signo, code, addr);

Index: linux/arch/ia64/kernel/entry.S
=================================--- linux.orig/arch/ia64/kernel/entry.S	Wed Dec  8 15:27:29 2004
+++ linux/arch/ia64/kernel/entry.S	Wed Dec  8 15:27:33 2004
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
=================================--- linux.orig/arch/ia64/kernel/signal.c	Wed Dec  8 15:27:29 2004
+++ linux/arch/ia64/kernel/signal.c	Wed Dec  8 15:46:48 2004
@@ -589,3 +589,81 @@ ia64_do_signal (sigset_t *oldset, struct
 	}
 	return 0;
 }
+
+/* Set a delayed signal that was detected in MCA/INIT/NMI/PMI context where it
+ * could not be delivered.  It is important that the target process is not
+ * allowed to do any more work in user space.  Possible cases for the target
+ * process:
+ *
+ * - It is sleeping and will wake up soon.  Store the data in the current task,
+ *   the signal will be sent when the current task returns from the next
+ *   interrupt.
+ *
+ * - It is running in user context.  Store the data in the current task, the
+ *   signal will be sent when the current task returns from the next interrupt.
+ *
+ * - It is running in kernel context on this or another cpu and will return to
+ *   user context.  Store the data in the target task, the signal will be sent
+ *   to itself when the target task returns to user space.
+ *
+ * - It is running in kernel context on this cpu and will sleep before
+ *   returning to user context.  Because this is also the current task, the
+ *   signal will not get delivered and the task could sleep indefinitely.
+ *   Store the data in the idle task for this cpu, the signal will be sent
+ *   after the idle task processes its next interrupt.
+ *
+ * To cover all cases, store the data in the target task, the current task and
+ * the idle task on this cpu.  Whatever happens, the signal will be delivered
+ * to the target task before it can do any useful user space work.  Multiple
+ * deliveries have no unwanted side effects.
+ *
+ * Note: This code is executed in MCA/INIT/NMI/PMI context, with interrupts
+ * disabled.  It must not take any locks nor use kernel structures or services
+ * that require locks.
+ */
+
+void
+set_sigdelayed(pid_t pid, int signo, int code, void __user *addr)
+{
+	struct task_struct *t;
+	int i;
+
+	for (i = 1; i < 3; ++i) {
+		switch (i) {
+		case 1: t = find_task_by_pid(pid); break;
+		case 2: t = current; break;
+		default: t = idle_task(smp_processor_id()); break;
+		}
+
+		if (!t)
+			return;
+		t->thread_info->sigdelayed.signo = signo;
+		t->thread_info->sigdelayed.code = code;
+		t->thread_info->sigdelayed.addr = addr;
+		t->thread_info->sigdelayed.pid = pid;
+		wmb();
+		set_tsk_thread_flag(t, TIF_SIGDELAYED);
+	}
+}
+
+/* Called from entry.S when it detects TIF_SIGDELAYED, a delayed signal that
+ * was detected in MCA/INIT/NMI/PMI context where it could not be delivered.
+ */
+
+void
+do_sigdelayed(void)
+{
+	struct siginfo siginfo;
+	pid_t pid;
+	struct task_struct *t;
+
+	clear_thread_flag(TIF_SIGDELAYED);
+	memset(&siginfo, 0, sizeof(siginfo));
+	siginfo.si_signo = current_thread_info()->sigdelayed.signo;
+	siginfo.si_code = current_thread_info()->sigdelayed.code;
+	siginfo.si_addr = current_thread_info()->sigdelayed.addr;
+	pid = current_thread_info()->sigdelayed.pid;
+	t = find_task_by_pid(pid);
+	if (t)
+		force_sig_info(siginfo.si_signo, &siginfo, t);
+}
Index: linux/include/asm-ia64/signal.h
=================================--- linux.orig/include/asm-ia64/signal.h	Tue Oct 19 07:53:21 2004
+++ linux/include/asm-ia64/signal.h	Wed Dec  8 15:27:33 2004
@@ -177,6 +177,8 @@ struct k_sigaction {
 
 #define ptrace_signal_deliver(regs, cookie) do { } while (0)
 
+void set_sigdelayed(pid_t pid, int signo, int code, void __user *addr);
+
 #endif /* __KERNEL__ */
 
 # endif /* !__ASSEMBLY__ */
Index: linux/include/asm-ia64/thread_info.h
=================================--- linux.orig/include/asm-ia64/thread_info.h	Tue Oct 19 07:55:36 2004
+++ linux/include/asm-ia64/thread_info.h	Wed Dec  8 15:27:33 2004
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
Index: linux/include/linux/sched.h
=================================--- linux.orig/include/linux/sched.h	Wed Dec  8 15:27:32 2004
+++ linux/include/linux/sched.h	Wed Dec  8 15:27:33 2004
@@ -740,6 +740,7 @@ extern int task_prio(const task_t *p);
 extern int task_nice(const task_t *p);
 extern int task_curr(const task_t *p);
 extern int idle_cpu(int cpu);
+extern task_t *idle_task(int cpu);
 
 void yield(void);
 
Index: linux/kernel/sched.c
=================================--- linux.orig/kernel/sched.c	Wed Dec  8 15:27:32 2004
+++ linux/kernel/sched.c	Wed Dec  8 15:27:33 2004
@@ -3067,6 +3067,15 @@ int idle_cpu(int cpu)
 EXPORT_SYMBOL_GPL(idle_cpu);
 
 /**
+ * idle_task - return the idle task for a given cpu.
+ * @cpu: the processor in question.
+ */
+task_t *idle_task(int cpu)
+{
+	return cpu_rq(cpu)->idle;
+}
+
+/**
  * find_process_by_pid - find a process with a matching PID value.
  * @pid: the pid in question.
  */

