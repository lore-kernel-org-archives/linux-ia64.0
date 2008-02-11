From: Petr Tesarik <ptesarik@suse.cz>
Date: Mon, 11 Feb 2008 21:43:38 +0000
Subject: [PATCH 5/6] remove duplicate code from arch_ptrace()
Message-Id: <1202766218.9594.30.camel@elijah.suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Remove all code which does exactly the same thing as ptrace_request().

Signed-off-by: Petr Tesarik <ptesarik@suse.cz>
CC: Tony Luck <tony.luck@intel.com>
CC: Christoph Hellwig <hch@infradead.org>

diff --git a/arch/ia64/kernel/ptrace.c b/arch/ia64/kernel/ptrace.c
index 1dfff5a..f10c8b4 100644
--- a/arch/ia64/kernel/ptrace.c
+++ b/arch/ia64/kernel/ptrace.c
@@ -1454,6 +1454,35 @@ ptrace_setregs (struct task_struct *chil
 	return ret;
 }
 
+void
+user_enable_single_step (struct task_struct *child)
+{
+	struct ia64_psr *child_psr = ia64_psr(task_pt_regs(child));
+
+	set_tsk_thread_flag(child, TIF_SINGLESTEP);
+	child_psr->ss = 1;
+}
+
+void
+user_enable_block_step (struct task_struct *child)
+{
+	struct ia64_psr *child_psr = ia64_psr(task_pt_regs(child));
+
+	set_tsk_thread_flag(child, TIF_SINGLESTEP);
+	child_psr->tb = 1;
+}
+
+void
+user_disable_single_step (struct task_struct *child)
+{
+	struct ia64_psr *child_psr = ia64_psr(task_pt_regs(child));
+
+	/* make sure the single step/taken-branch trap bits are not set: */
+	clear_tsk_thread_flag(child, TIF_SINGLESTEP);
+	child_psr->ss = 0;
+	child_psr->tb = 0;
+}
+
 /*
  * Called by kernel/ptrace.c when detaching..
  *
@@ -1528,73 +1557,6 @@ arch_ptrace (struct task_struct *child, 
 		ret = ptrace_request(child, PTRACE_SETSIGINFO, addr, data);
 		goto out_tsk;
 
-	      case PTRACE_SYSCALL:
-		/* continue and stop at next (return from) syscall */
-	      case PTRACE_CONT:
-		/* restart after signal. */
-		ret = -EIO;
-		if (!valid_signal(data))
-			goto out_tsk;
-		if (request = PTRACE_SYSCALL)
-			set_tsk_thread_flag(child, TIF_SYSCALL_TRACE);
-		else
-			clear_tsk_thread_flag(child, TIF_SYSCALL_TRACE);
-		child->exit_code = data;
-
-		/*
-		 * Make sure the single step/taken-branch trap bits
-		 * are not set:
-		 */
-		clear_tsk_thread_flag(child, TIF_SINGLESTEP);
-		ia64_psr(pt)->ss = 0;
-		ia64_psr(pt)->tb = 0;
-
-		wake_up_process(child);
-		ret = 0;
-		goto out_tsk;
-
-	      case PTRACE_KILL:
-		/*
-		 * Make the child exit.  Best I can do is send it a
-		 * sigkill.  Perhaps it should be put in the status
-		 * that it wants to exit.
-		 */
-		if (child->exit_state = EXIT_ZOMBIE)
-			/* already dead */
-			return 0;
-		child->exit_code = SIGKILL;
-
-		ptrace_disable(child);
-		wake_up_process(child);
-		ret = 0;
-		goto out_tsk;
-
-	      case PTRACE_SINGLESTEP:
-		/* let child execute for one instruction */
-	      case PTRACE_SINGLEBLOCK:
-		ret = -EIO;
-		if (!valid_signal(data))
-			goto out_tsk;
-
-		clear_tsk_thread_flag(child, TIF_SYSCALL_TRACE);
-		set_tsk_thread_flag(child, TIF_SINGLESTEP);
-		if (request = PTRACE_SINGLESTEP) {
-			ia64_psr(pt)->ss = 1;
-		} else {
-			ia64_psr(pt)->tb = 1;
-		}
-		child->exit_code = data;
-
-		/* give it a chance to run. */
-		wake_up_process(child);
-		ret = 0;
-		goto out_tsk;
-
-	      case PTRACE_DETACH:
-		/* detach a process that was attached. */
-		ret = ptrace_detach(child, data);
-		goto out_tsk;
-
 	      case PTRACE_GETREGS:
 		ret = ptrace_getregs(child,
 				     (struct pt_all_user_regs __user *) data);
diff --git a/include/asm-ia64/ptrace.h b/include/asm-ia64/ptrace.h
index 5b52340..4b2a8d4 100644
--- a/include/asm-ia64/ptrace.h
+++ b/include/asm-ia64/ptrace.h
@@ -312,6 +312,13 @@ # define force_successful_syscall_return
   #define arch_ptrace_attach(child) \
 	ptrace_attach_sync_user_rbs(child)
 
+  #define arch_has_single_step()  (1)
+  extern void user_enable_single_step(struct task_struct *);
+  extern void user_disable_single_step(struct task_struct *);
+
+  #define arch_has_block_step()   (1)
+  extern void user_enable_block_step(struct task_struct *);
+
 #endif /* !__KERNEL__ */
 
 /* pt_all_user_regs is used for PTRACE_GETREGS PTRACE_SETREGS */

