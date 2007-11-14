From: Petr Tesarik <ptesarik@suse.cz>
Date: Wed, 14 Nov 2007 07:37:09 +0000
Subject: RE: [PATCH] ptrace RSE bug
Message-Id: <1195025829.24798.5.camel@elijah.suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <1188357710.22637.7.camel@sli10-conroe.sh.intel.com>
In-Reply-To: <1188357710.22637.7.camel@sli10-conroe.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Shaohua Li wrote:
> On Tue, 2007-11-13 at 12:07 +0100, Petr Tesarik wrote:
>> On Mon, 2007-11-12 at 16:30 -0800, Roland McGrath wrote:
>>> [...]
>>> If you do the artificial test using a long sleep in arch_ptrace_stop,
>>> then you can probably produce this by hand with gdb.  Have the process
>>> doing raise(SIGCHLD) or some other harmless signal.  The traced
>>> process will stop to report the signal to gdb, and then gdb will sit
>>> at the prompt before resuming it (given "handle SIGFOO stop" if not default).  
>>> If your sleep is long enough, it won't be hard to get your SIGKILL in there.
>>> Then when gdb is sitting, the traced process may still be sitting too.
>>> But it should have gone away instantly from SIGKILL.
>> I found it extremely difficult to trigger the race condition without the
>> articifial test - arch_ptrace_stop() only sleeps if the user page is not
>> present, but in the common case the register stack backing store will
>> have been quite recently accessed by the process.
>>
>> It should be possible to create a large file, flush the page cache, put
>> the RSE into lazy mode, flush it and map the register stack from that
>> file, so that no memory accesses to the backing store are done before
>> ptrace_stop(), but for the time being I placed an msleep(100) after
>> arch_ptrace_stop().
>>
>> Anyway, I produced a test case which succeeds when the call to
>> sigkill_pending() is in and fails when it's commented out. I'm attaching
>> it here (the kernel patch to follow).
> So without the sigkill_pending() check, your test case will print an
> error, and otherwise, nothing. This is expected output, right? Looks I
> can reproduce it here.

Yes - you can also check the exit code - it is TEST_OK (=0) if the test
passes, TEST_FAILED (=1) if it fails in a known way and TEST_ABORTED
(=2) if something went wrong unexpectedly.

I was able to manage my test case to run even without the msleep() -
I'll send the instruction in the following mail. Anyway, I was finally
running with the following patch:

diff -ru linux-2.6.orig/arch/ia64/kernel/ptrace.c linux-2.6/arch/ia64/kernel/ptrace.c
--- linux-2.6.orig/arch/ia64/kernel/ptrace.c	2007-10-09 22:31:38.000000000 +0200
+++ linux-2.6/arch/ia64/kernel/ptrace.c	2007-11-13 11:34:03.664000000 +0100
@@ -547,6 +547,64 @@
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
+ * newer RSE to return to user.
+ */
+void ia64_ptrace_stop(void)
+{
+	unw_init_running(do_sync_rbs, (void *)RBS_SYNC_TO_USER);
+}
+
+void ia64_ptrace_resume(void)
+{
+	unw_init_running(do_sync_rbs, (void *)RBS_SYNC_TO_KERNEL);
+}
+
 static inline int
 thread_matches (struct task_struct *thread, unsigned long addr)
 {
diff -ru linux-2.6.orig/include/asm-ia64/ptrace.h linux-2.6/include/asm-ia64/ptrace.h
--- linux-2.6.orig/include/asm-ia64/ptrace.h	2007-10-09 22:31:38.000000000 +0200
+++ linux-2.6/include/asm-ia64/ptrace.h	2007-11-13 11:35:17.848000000 +0100
@@ -303,6 +303,12 @@
   extern void ia64_increment_ip (struct pt_regs *pt);
   extern void ia64_decrement_ip (struct pt_regs *pt);
 
+  extern void ia64_ptrace_stop(void);
+  extern void ia64_ptrace_resume(void);
+
+  #define arch_ptrace_stop		ia64_ptrace_stop
+  #define arch_ptrace_resume		ia64_ptrace_resume
+  #define arch_ptrace_stop_needed()	1
 #endif /* !__KERNEL__ */
 
 /* pt_all_user_regs is used for PTRACE_GETREGS PTRACE_SETREGS */
diff -ru linux-2.6.orig/include/linux/ptrace.h linux-2.6/include/linux/ptrace.h
--- linux-2.6.orig/include/linux/ptrace.h	2007-10-09 22:31:38.000000000 +0200
+++ linux-2.6/include/linux/ptrace.h	2007-11-13 11:32:01.568000000 +0100
@@ -128,6 +128,18 @@
 #define force_successful_syscall_return() do { } while (0)
 #endif
 
+#ifndef arch_ptrace_stop
+#define arch_ptrace_stop()	do { } while (0)
+#endif
+
+#ifndef arch_ptrace_resume
+#define arch_ptrace_resume()	do { } while (0)
+#endif
+
+#ifndef arch_ptrace_stop_needed
+#define arch_ptrace_stop_needed()	0
+#endif
+
 #endif
 
 #endif
diff -ru linux-2.6.orig/kernel/signal.c linux-2.6/kernel/signal.c
--- linux-2.6.orig/kernel/signal.c	2007-11-13 14:19:35.267851100 +0100
+++ linux-2.6/kernel/signal.c	2007-11-13 11:37:49.236000000 +0100
@@ -1569,6 +1570,17 @@
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
@@ -1581,6 +1593,26 @@
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
@@ -1596,10 +1630,11 @@
 	spin_unlock_irq(&current->sighand->siglock);
 	try_to_freeze();
 	read_lock(&tasklist_lock);
-	if (may_ptrace_stop()) {
+	if (likely(!killed) && may_ptrace_stop()) {
 		do_notify_parent_cldstop(current, CLD_TRAPPED);
 		read_unlock(&tasklist_lock);
 		schedule();
+		arch_ptrace_resume();
 	} else {
 		/*
 		 * By the time we got the lock, our tracer went away.

