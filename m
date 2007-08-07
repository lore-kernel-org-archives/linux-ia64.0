From: Shaohua Li <shaohua.li@intel.com>
Date: Tue, 07 Aug 2007 05:23:49 +0000
Subject: [PATCH]utrace: IA64 RSE bug
Message-Id: <1186464229.784.9.camel@sli10-conroe.sh.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

In ptrace case, user space RSE might be newer than kernel RSE. To avoid
stale RSE is used when return to userspace, this patch synchronize user
space RSE to kernel RSE.
Also, as TIF_ALLWORK_MASK bits are limited, TIF_NOTIFY_RESUME is
overrided.

patch is against latest utrace source (2.6.22 base + utrace patches)

Signed-off-by: Bibo Mao<bibo.mao@intel.com>
Signed-off-by: Shaohua Li<shaohua.li@intel.com> 

===============================
 arch/ia64/kernel/perfmon.c     |   21 ++--------------
 arch/ia64/kernel/process.c     |   14 +++++++++++
 arch/ia64/kernel/ptrace.c      |   52 +++++++++++++++++++++++++++++++++++++++++
 include/asm-ia64/ptrace.h      |    1 
 include/asm-ia64/thread_info.h |    4 +++
 5 files changed, 74 insertions(+), 18 deletions(-)

Index: 2.6.22/arch/ia64/kernel/process.c
=================================--- 2.6.22.orig/arch/ia64/kernel/process.c	2007-08-07 10:48:04.000000000 +0800
+++ 2.6.22/arch/ia64/kernel/process.c	2007-08-07 11:40:42.000000000 +0800
@@ -154,6 +154,17 @@ show_regs (struct pt_regs *regs)
 		show_stack(NULL, NULL);
 }
 
+void tsk_clear_notify_resume(struct task_struct *tsk)
+{
+#ifdef CONFIG_PERFMON
+	if (tsk->thread.pfm_needs_checking)
+		return;
+#endif
+	if (test_ti_thread_flag(task_thread_info(tsk), TIF_RESTORE_RSE))
+		return;
+	clear_ti_thread_flag(task_thread_info(tsk), TIF_NOTIFY_RESUME);
+}
+
 void
 do_notify_resume_user (sigset_t *unused, struct sigscratch *scr, long in_syscall)
 {
@@ -172,6 +183,9 @@ do_notify_resume_user (sigset_t *unused,
 	/* deal with pending signal delivery */
 	if (test_thread_flag(TIF_SIGPENDING)||test_thread_flag(TIF_RESTORE_SIGMASK))
 		ia64_do_signal(scr, in_syscall);
+	/* copy user rbs to kernel rbs */
+	if (unlikely(test_thread_flag(TIF_RESTORE_RSE)))
+		ia64_sync_krbs(current);
 }
 
 static int pal_halt        = 1;
Index: 2.6.22/arch/ia64/kernel/ptrace.c
=================================--- 2.6.22.orig/arch/ia64/kernel/ptrace.c	2007-08-07 10:48:04.000000000 +0800
+++ 2.6.22/arch/ia64/kernel/ptrace.c	2007-08-07 12:54:26.000000000 +0800
@@ -554,6 +554,25 @@ ia64_sync_user_rbs (struct task_struct *
 	return 0;
 }
 
+long
+ia64_sync_kernel_rbs (struct task_struct *child, struct switch_stack *sw,
+                    unsigned long user_rbs_start, unsigned long user_rbs_end)
+{
+        unsigned long addr, val;
+        long ret;
+
+        /* now copy word for word from user rbs to kernel rbs: */
+        for (addr = user_rbs_start; addr < user_rbs_end; addr += 8) {
+                if (access_process_vm(child, addr, &val, sizeof(val), 0)
+                    != sizeof(val))
+                        return -EIO;
+                ret = ia64_poke(child, sw, user_rbs_end, addr, val);
+                if (ret < 0)
+                        return ret;
+        }
+        return 0;
+}
+
 /*
  * Write f32-f127 back to task->thread.fph if it has been modified.
  */
@@ -728,6 +747,10 @@ syscall_trace_enter (long arg0, long arg
 	if (test_thread_flag(TIF_SYSCALL_TRACE))
 		tracehook_report_syscall(&regs, 0);
 
+	/* copy user rbs to kernel rbs */
+        if (test_thread_flag(TIF_RESTORE_RSE))
+                ia64_sync_krbs(current);
+
 	if (unlikely(current->audit_context)) {
 		long syscall;
 		int arch;
@@ -764,6 +787,10 @@ syscall_trace_leave (long arg0, long arg
 	if (test_thread_flag(TIF_SYSCALL_TRACE))
 		tracehook_report_syscall(&regs, 1);
 
+	/* copy user rbs to kernel rbs */
+        if (test_thread_flag(TIF_RESTORE_RSE))
+                ia64_sync_krbs(current);
+
 	if (test_thread_flag(TIF_SINGLESTEP)) {
 		force_sig(SIGTRAP, current); /* XXX */
 		tracehook_report_syscall_step(&regs);
@@ -1416,9 +1443,34 @@ gpregs_writeback(struct task_struct *tar
 		 const struct utrace_regset *regset,
 		 int now)
 {
+	if (test_and_set_tsk_thread_flag(target, TIF_RESTORE_RSE))
+		return 0;
+	tsk_set_notify_resume(target);
 	return do_regset_call(do_gpregs_writeback, target, regset, 0, 0, NULL, NULL);
 }
 
+static void do_gpregs_readback(struct unw_frame_info *info, void *arg)
+{
+	struct pt_regs *pt;
+	utrace_getset_t *dst = arg;
+	unsigned long urbs_end;
+
+	if (unw_unwind_to_user(info) < 0)
+		return;
+	pt = task_pt_regs(dst->target);
+	urbs_end = ia64_get_user_rbs_end(dst->target, pt, NULL);
+	dst->ret = ia64_sync_kernel_rbs(dst->target, info->sw, pt->ar_bspstore, urbs_end);
+}
+/*
+ * This is called to read back the register backing store.
+ */
+long ia64_sync_krbs(struct task_struct *target)
+{
+	clear_tsk_thread_flag(target, TIF_RESTORE_RSE);
+	tsk_clear_notify_resume(target);
+	return do_regset_call(do_gpregs_readback, target, NULL, 0, 0, NULL, NULL);
+}
+
 static int
 fpregs_active(struct task_struct *target, const struct utrace_regset *regset)
 {
Index: 2.6.22/include/asm-ia64/ptrace.h
=================================--- 2.6.22.orig/include/asm-ia64/ptrace.h	2007-08-07 10:48:04.000000000 +0800
+++ 2.6.22/include/asm-ia64/ptrace.h	2007-08-07 10:48:21.000000000 +0800
@@ -292,6 +292,7 @@ struct switch_stack {
 			 unsigned long, long);
   extern void ia64_flush_fph (struct task_struct *);
   extern void ia64_sync_fph (struct task_struct *);
+  extern long ia64_sync_krbs(struct task_struct *);
   extern long ia64_sync_user_rbs (struct task_struct *, struct switch_stack *,
 				  unsigned long, unsigned long);
 
Index: 2.6.22/include/asm-ia64/thread_info.h
=================================--- 2.6.22.orig/include/asm-ia64/thread_info.h	2007-08-07 10:48:04.000000000 +0800
+++ 2.6.22/include/asm-ia64/thread_info.h	2007-08-07 11:08:45.000000000 +0800
@@ -71,6 +71,9 @@ struct thread_info {
 #define alloc_task_struct()	((struct task_struct *)__get_free_pages(GFP_KERNEL | __GFP_COMP, KERNEL_STACK_SIZE_ORDER))
 #define free_task_struct(tsk)	free_pages((unsigned long) (tsk), KERNEL_STACK_SIZE_ORDER)
 
+#define tsk_set_notify_resume(tsk) \
+	set_ti_thread_flag(task_thread_info(tsk), TIF_NOTIFY_RESUME)
+extern void tsk_clear_notify_resume(struct task_struct *tsk);
 #endif /* !__ASSEMBLY */
 
 /*
@@ -86,6 +89,7 @@ struct thread_info {
 #define TIF_SYSCALL_AUDIT	4	/* syscall auditing active */
 #define TIF_SINGLESTEP		5	/* restore singlestep on return to user mode */
 #define TIF_RESTORE_SIGMASK	6	/* restore signal mask in do_signal() */
+#define TIF_RESTORE_RSE		9	/* task need RSE synchronization */
 #define TIF_POLLING_NRFLAG	16	/* true if poll_idle() is polling TIF_NEED_RESCHED */
 #define TIF_MEMDIE		17
 #define TIF_MCA_INIT		18	/* this task is processing MCA or INIT */
Index: 2.6.22/arch/ia64/kernel/perfmon.c
=================================--- 2.6.22.orig/arch/ia64/kernel/perfmon.c	2007-08-07 10:48:04.000000000 +0800
+++ 2.6.22/arch/ia64/kernel/perfmon.c	2007-08-07 11:01:07.000000000 +0800
@@ -586,21 +586,6 @@ pfm_put_task(struct task_struct *task)
 }
 
 static inline void
-pfm_set_task_notify(struct task_struct *task)
-{
-	struct thread_info *info;
-
-	info = (struct thread_info *) ((char *) task + IA64_TASK_SIZE);
-	set_bit(TIF_NOTIFY_RESUME, &info->flags);
-}
-
-static inline void
-pfm_clear_task_notify(void)
-{
-	clear_thread_flag(TIF_NOTIFY_RESUME);
-}
-
-static inline void
 pfm_reserve_page(unsigned long a)
 {
 	SetPageReserved(vmalloc_to_page((void *)a));
@@ -3730,7 +3715,7 @@ pfm_restart(pfm_context_t *ctx, void *ar
 
 		PFM_SET_WORK_PENDING(task, 1);
 
-		pfm_set_task_notify(task);
+		tsk_set_notify_resume(task);
 
 		/*
 		 * XXX: send reschedule if task runs on another CPU
@@ -5087,7 +5072,7 @@ pfm_handle_work(void)
 
 	PFM_SET_WORK_PENDING(current, 0);
 
-	pfm_clear_task_notify();
+	tsk_clear_notify_resume(current);
 
 	regs = task_pt_regs(current);
 
@@ -5455,7 +5440,7 @@ pfm_overflow_handler(struct task_struct 
 			 * when coming from ctxsw, current still points to the
 			 * previous task, therefore we must work with task and not current.
 			 */
-			pfm_set_task_notify(task);
+			tsk_set_notify_resume(task);
 		}
 		/*
 		 * defer until state is changed (shorten spin window). the context is locked
