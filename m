From: David Mosberger <davidm@hpl.hp.com>
Date: Thu, 26 Jul 2001 07:06:48 +0000
Subject: [Linux-ia64] fix for 2.4.7 UP hang
Message-Id: <marc-linux-ia64-105590693005921@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The attached patch fixes the bug that causes 2.4.7 to hang on UP
systems.  It turns out that this is a very old bug (since 2.3.11!)
that happens to get triggered reliably in 2.4.7 on UP machines.  The
problem is that in the UP case, we failed to call schedule_tail()
after a fork/clone.  This had the effect that if a task yielded the
CPU and the next task to be execute was a newly forked/cloned task,
then the yielding task would never get scheduled again.  In other
words, on a UP system it would have been possible for some tasks to
get "stuck", even though they were marked runnable.  Can't say I have
seen this in practice, but I'm not using UP machines very often
anymore.

	--david

--- lia64-kdb/arch/ia64/kernel/entry.S~	Sat Jul 21 20:20:10 2001
+++ lia64-kdb/arch/ia64/kernel/entry.S	Wed Jul 25 23:49:38 2001
@@ -492,15 +492,13 @@
 
 GLOBAL_ENTRY(ia64_ret_from_clone)
 	PT_REGS_UNWIND_INFO(0)
-#ifdef CONFIG_SMP
 	/*
-	 * In SMP mode, we need to call invoke_schedule_tail to complete the scheduling process.
+	 * We need to call schedule_tail() to complete the scheduling process.
 	 * Called by ia64_switch_to after do_fork()->copy_thread().  r8 contains the
 	 * address of the previously executing task.
 	 */
 	br.call.sptk.few rp=invoke_schedule_tail
 .ret8:
-#endif
 	adds r2=IA64_TASK_PTRACE_OFFSET,r13
 	;;
 	ld8 r2=[r2]
@@ -554,7 +552,7 @@
 #ifdef CONFIG_PERFMON
 (p9)	br.call.spnt.many b7=pfm_overflow_notify
 #endif
-# if __GNUC__ < 3
+#if __GNUC__ < 3
 (p7)	br.call.spnt.many b7=invoke_schedule
 #else
 (p7)	br.call.spnt.many b7=schedule
@@ -766,7 +764,6 @@
 	br.cond.sptk.many ia64_leave_kernel
 END(handle_syscall_error)
 
-# ifdef CONFIG_SMP
 	/*
 	 * Invoke schedule_tail(task) while preserving in0-in7, which may be needed
 	 * in case a system call gets restarted.
@@ -783,7 +780,7 @@
 	br.ret.sptk.many rp
 END(invoke_schedule_tail)
 
-# endif /* CONFIG_SMP */
+#if __GNUC__ < 3
 
 	/*
 	 * Invoke schedule() while preserving in0-in7, which may be needed
@@ -805,6 +802,8 @@
 	mov rp=loc0
 	br.ret.sptk.many rp
 END(invoke_schedule)
+
+#endif /* __GNUC__ < 3 */
 
 	/*
 	 * Setup stack and call ia64_do_signal.  Note that pSys and pNonSys need to

