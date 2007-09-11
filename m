From: Shaohua Li <shaohua.li@intel.com>
Date: Tue, 11 Sep 2007 08:39:39 +0000
Subject: Re: [PATCH] ptrace RSE bug
Message-Id: <1189499979.25803.2.camel@sli10-conroe.sh.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1188357710.22637.7.camel@sli10-conroe.sh.intel.com>
In-Reply-To: <1188357710.22637.7.camel@sli10-conroe.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 2007-09-07 at 09:11 -0600, David Mosberger-Tang wrote:
> Anything that avoids complicating the kernel exit path is worth doing!
>  The exit path is complicated enough as it is.
> 
>   --david
> 
> On 9/7/07, Petr Tesarik <ptesarik@suse.cz> wrote:
> > -----BEGIN PGP SIGNED MESSAGE-----
> > Hash: SHA1
> >
> > Shaohua Li wrote:
> > > On Thu, 2007-09-06 at 15:59 +0200, Petr Tesarik wrote:
> > >>[...]
> > >> So, what happens if upon syscall entry notification the debugger
> > >> modifies the part of the RBS (in user-space) which corresponds to the
> > >> arguments of that syscall? Currently, the syscall takes the modified
> > >> arguments, but with your change it would still take the stale data
> > >> from
> > >> the kernel RBS.
> > > The patch does sync from user RBS to kernel RBS just after syscall trace
> > > enter. this is an exception I said doing sync just before syscall
> > > return. I thought this covers your case, no?
> >
> > Ah, I'm sorry, I missed that part of the patch. Well, if we have to do a
> > sync on every syscall_trace_enter() and syscall_trace_leave(), then the
> > only cases where introducing TIF_RESTORE_RSE saves us a duplicate sync
> > seems to be in the clone/fork and exit paths. In other words, it's
> > probably not worth the added complexity. But since you have written the
> > whole complex thing already, I have no objections against it.
Ok, this is a simplified patch. please review.

Signed-off-by: Shaohua Li <shaohua.li@intel.com>
---
 arch/ia64/kernel/ptrace.c |   62 ++++++++++++++++++++++++++++++++++++++++++++++
 include/asm-ia64/ptrace.h |    2 +
 include/linux/ptrace.h    |    4 ++
 kernel/signal.c           |    5 ++-
 4 files changed, 72 insertions(+), 1 deletion(-)

Index: linux/arch/ia64/kernel/ptrace.c
=================================--- linux.orig/arch/ia64/kernel/ptrace.c	2007-09-06 13:06:49.000000000 +0800
+++ linux/arch/ia64/kernel/ptrace.c	2007-09-11 11:33:35.000000000 +0800
@@ -547,6 +547,62 @@ ia64_sync_user_rbs (struct task_struct *
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
+void arch_ptrace_stop(int before_suspend)
+{
+	if (before_suspend)
+		unw_init_running(do_sync_rbs, (void *)RBS_SYNC_TO_USER);
+	else
+		unw_init_running(do_sync_rbs, (void *)RBS_SYNC_TO_KERNEL);
+}
+
 static inline int
 thread_matches (struct task_struct *thread, unsigned long addr)
 {
@@ -1422,6 +1478,7 @@ sys_ptrace (long request, pid_t pid, uns
 	struct task_struct *child;
 	struct switch_stack *sw;
 	long ret;
+	struct unw_frame_info info;
 
 	lock_kernel();
 	ret = -EPERM;
@@ -1481,6 +1538,11 @@ sys_ptrace (long request, pid_t pid, uns
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
Index: linux/include/asm-ia64/ptrace.h
=================================--- linux.orig/include/asm-ia64/ptrace.h	2007-08-29 11:26:33.000000000 +0800
+++ linux/include/asm-ia64/ptrace.h	2007-09-11 09:53:04.000000000 +0800
@@ -303,6 +303,8 @@ struct switch_stack {
   extern void ia64_increment_ip (struct pt_regs *pt);
   extern void ia64_decrement_ip (struct pt_regs *pt);
 
+  extern void arch_ptrace_stop(int);
+  #define HAVE_ARCH_PTRACE_STOP
 #endif /* !__KERNEL__ */
 
 /* pt_all_user_regs is used for PTRACE_GETREGS PTRACE_SETREGS */
Index: linux/kernel/signal.c
=================================--- linux.orig/kernel/signal.c	2007-09-11 09:33:14.000000000 +0800
+++ linux/kernel/signal.c	2007-09-11 10:55:05.000000000 +0800
@@ -1599,15 +1599,18 @@ static void ptrace_stop(int exit_code, i
 	current->last_siginfo = info;
 	current->exit_code = exit_code;
 
+	spin_unlock_irq(&current->sighand->siglock);
+	arch_ptrace_stop(1);
 	/* Let the debugger run.  */
 	set_current_state(TASK_TRACED);
-	spin_unlock_irq(&current->sighand->siglock);
+
 	try_to_freeze();
 	read_lock(&tasklist_lock);
 	if (may_ptrace_stop()) {
 		do_notify_parent_cldstop(current, CLD_TRAPPED);
 		read_unlock(&tasklist_lock);
 		schedule();
+		arch_ptrace_stop(0);
 	} else {
 		/*
 		 * By the time we got the lock, our tracer went away.
Index: linux/include/linux/ptrace.h
=================================--- linux.orig/include/linux/ptrace.h	2007-08-29 11:26:33.000000000 +0800
+++ linux/include/linux/ptrace.h	2007-09-11 09:52:32.000000000 +0800
@@ -128,6 +128,10 @@ int generic_ptrace_pokedata(struct task_
 #define force_successful_syscall_return() do { } while (0)
 #endif
 
+#ifndef HAVE_ARCH_PTRACE_STOP
+#define arch_ptrace_stop(a)	do { } while (0)
+#endif
+
 #endif
 
 #endif
