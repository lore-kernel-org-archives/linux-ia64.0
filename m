From: Petr Tesarik <ptesarik@suse.cz>
Date: Wed, 12 Dec 2007 14:23:34 +0000
Subject: [PATCH 2/3] Synchronize kernel RSE to user-space and back
Message-Id: <475FEEE6.8000405@suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <1196959920.6586.8.camel@elijah.suse.cz>
In-Reply-To: <1196959920.6586.8.camel@elijah.suse.cz>
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
Signed-off-by: Petr Tesarik <ptesarik@suse.cz>
CC: Roland McGrath <roland@redhat.com>
CC: Tony Luck <tony.luck@intel.com>

---
 arch/ia64/kernel/process.c     |    6 +++
 arch/ia64/kernel/ptrace.c      |   82 ++++++++++++++++++++++++++++++++++++++++
 include/asm-ia64/ptrace.h      |    7 +++
 include/asm-ia64/thread_info.h |    2 +
 4 files changed, 97 insertions(+), 0 deletions(-)

diff --git a/arch/ia64/kernel/process.c b/arch/ia64/kernel/process.c
index 94a92de..f5aa88d 100644
--- a/arch/ia64/kernel/process.c
+++ b/arch/ia64/kernel/process.c
@@ -161,6 +161,8 @@ #ifdef CONFIG_PERFMON
 	if (tsk->thread.pfm_needs_checking)
 		return;
 #endif
+	if (test_ti_thread_flag(task_thread_info(tsk), TIF_RESTORE_RSE))
+		return;
 	clear_ti_thread_flag(task_thread_info(tsk), TIF_NOTIFY_RESUME);
 }
 
@@ -182,6 +184,10 @@ #endif
 	/* deal with pending signal delivery */
 	if (test_thread_flag(TIF_SIGPENDING)||test_thread_flag(TIF_RESTORE_SIGMASK))
 		ia64_do_signal(scr, in_syscall);
+
+	/* copy user rbs to kernel rbs */
+	if (unlikely(test_thread_flag(TIF_RESTORE_RSE)))
+		ia64_sync_krbs();
 }
 
 static int pal_halt        = 1;
diff --git a/arch/ia64/kernel/ptrace.c b/arch/ia64/kernel/ptrace.c
index 2e96f17..2de5a52 100644
--- a/arch/ia64/kernel/ptrace.c
+++ b/arch/ia64/kernel/ptrace.c
@@ -547,6 +547,72 @@ ia64_sync_user_rbs (struct task_struct *
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
+typedef long (*syncfunc_t)(struct task_struct *, struct switch_stack *,
+			    unsigned long, unsigned long);
+
+static void do_sync_rbs(struct unw_frame_info *info, void *arg)
+{
+	struct pt_regs *pt;
+	unsigned long urbs_end;
+	syncfunc_t fn = arg;
+
+	if (unw_unwind_to_user(info) < 0)
+		return;
+	pt = task_pt_regs(info->task);
+	urbs_end = ia64_get_user_rbs_end(info->task, pt, NULL);
+
+	fn(info->task, info->sw, pt->ar_bspstore, urbs_end);
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
+void ia64_ptrace_stop(void)
+{
+	if (test_and_set_tsk_thread_flag(current, TIF_RESTORE_RSE))
+		return;
+	tsk_set_notify_resume(current);
+	unw_init_running(do_sync_rbs, ia64_sync_user_rbs);
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
+	unw_init_running(do_sync_rbs, ia64_sync_kernel_rbs);
+}
+
 static inline int
 thread_matches (struct task_struct *thread, unsigned long addr)
 {
@@ -1422,6 +1488,7 @@ sys_ptrace (long request, pid_t pid, uns
 	struct task_struct *child;
 	struct switch_stack *sw;
 	long ret;
+	struct unw_frame_info info;
 
 	lock_kernel();
 	ret = -EPERM;
@@ -1453,6 +1520,8 @@ sys_ptrace (long request, pid_t pid, uns
 
 	if (request = PTRACE_ATTACH) {
 		ret = ptrace_attach(child);
+		if (!ret)
+			arch_ptrace_attach(child);
 		goto out_tsk;
 	}
 
@@ -1481,6 +1550,11 @@ sys_ptrace (long request, pid_t pid, uns
 		/* write the word at location addr */
 		urbs_end = ia64_get_user_rbs_end(child, pt, NULL);
 		ret = ia64_poke(child, sw, urbs_end, addr, data);
+
+		/* Make sure user RBS has the latest data */
+		unw_init_from_blocked_task(&info, child);
+		do_sync_rbs(&info, ia64_sync_user_rbs);
+
 		goto out_tsk;
 
 	      case PTRACE_PEEKUSR:
@@ -1634,6 +1708,10 @@ syscall_trace_enter (long arg0, long arg
 	    && (current->ptrace & PT_PTRACED))
 		syscall_trace();
 
+	/* copy user rbs to kernel rbs */
+	if (test_thread_flag(TIF_RESTORE_RSE))
+		ia64_sync_krbs();
+
 	if (unlikely(current->audit_context)) {
 		long syscall;
 		int arch;
@@ -1671,4 +1749,8 @@ syscall_trace_leave (long arg0, long arg
 	    || test_thread_flag(TIF_SINGLESTEP))
 	    && (current->ptrace & PT_PTRACED))
 		syscall_trace();
+
+	/* copy user rbs to kernel rbs */
+	if (test_thread_flag(TIF_RESTORE_RSE))
+		ia64_sync_krbs();
 }
diff --git a/include/asm-ia64/ptrace.h b/include/asm-ia64/ptrace.h
index f4ef87a..13435f7 100644
--- a/include/asm-ia64/ptrace.h
+++ b/include/asm-ia64/ptrace.h
@@ -292,6 +292,7 @@ # define force_successful_syscall_return
 			 unsigned long, long);
   extern void ia64_flush_fph (struct task_struct *);
   extern void ia64_sync_fph (struct task_struct *);
+  extern void ia64_sync_krbs(void);
   extern long ia64_sync_user_rbs (struct task_struct *, struct switch_stack *,
 				  unsigned long, unsigned long);
 
@@ -303,6 +304,12 @@ # define force_successful_syscall_return
   extern void ia64_increment_ip (struct pt_regs *pt);
   extern void ia64_decrement_ip (struct pt_regs *pt);
 
+  extern void ia64_ptrace_stop(void);
+  #define arch_ptrace_stop(code, info) \
+	ia64_ptrace_stop()
+  #define arch_ptrace_stop_needed(code, info) \
+	(!test_thread_flag(TIF_RESTORE_RSE))
+
 #endif /* !__KERNEL__ */
 
 /* pt_all_user_regs is used for PTRACE_GETREGS PTRACE_SETREGS */
diff --git a/include/asm-ia64/thread_info.h b/include/asm-ia64/thread_info.h
index 5a2c479..93d83cb 100644
--- a/include/asm-ia64/thread_info.h
+++ b/include/asm-ia64/thread_info.h
@@ -94,6 +94,7 @@ #define TIF_MEMDIE		17
 #define TIF_MCA_INIT		18	/* this task is processing MCA or INIT */
 #define TIF_DB_DISABLED		19	/* debug trap disabled for fsyscall */
 #define TIF_FREEZE		20	/* is freezing for suspend */
+#define TIF_RESTORE_RSE		21	/* user RBS is newer than kernel RBS */
 
 #define _TIF_SYSCALL_TRACE	(1 << TIF_SYSCALL_TRACE)
 #define _TIF_SYSCALL_AUDIT	(1 << TIF_SYSCALL_AUDIT)
@@ -107,6 +108,7 @@ #define _TIF_POLLING_NRFLAG	(1 << TIF_PO
 #define _TIF_MCA_INIT		(1 << TIF_MCA_INIT)
 #define _TIF_DB_DISABLED	(1 << TIF_DB_DISABLED)
 #define _TIF_FREEZE		(1 << TIF_FREEZE)
+#define _TIF_RESTORE_RSE	(1 << TIF_RESTORE_RSE)
 
 /* "work to do on user-return" bits */
 #define TIF_ALLWORK_MASK	(_TIF_SIGPENDING|_TIF_NOTIFY_RESUME|_TIF_SYSCALL_AUDIT|\


