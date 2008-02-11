From: Petr Tesarik <ptesarik@suse.cz>
Date: Mon, 11 Feb 2008 21:44:08 +0000
Subject: [PATCH 6/6] arch_ptrace() cleanup
Message-Id: <1202766249.9594.32.camel@elijah.suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Remove duplicate code and clean up goto's.

Signed-off-by: Petr Tesarik <ptesarik@suse.cz>
CC: Tony Luck <tony.luck@intel.com>
CC: Christoph Hellwig <hch@infradead.org>

diff --git a/arch/ia64/kernel/ptrace.c b/arch/ia64/kernel/ptrace.c
index f10c8b4..2477de8 100644
--- a/arch/ia64/kernel/ptrace.c
+++ b/arch/ia64/kernel/ptrace.c
@@ -1491,37 +1491,22 @@ user_disable_single_step (struct task_st
 void
 ptrace_disable (struct task_struct *child)
 {
-	struct ia64_psr *child_psr = ia64_psr(task_pt_regs(child));
-
-	/* make sure the single step/taken-branch trap bits are not set: */
-	clear_tsk_thread_flag(child, TIF_SINGLESTEP);
-	child_psr->ss = 0;
-	child_psr->tb = 0;
+	user_disable_single_step(child);
 }
 
 long
 arch_ptrace (struct task_struct *child, long request, long addr, long data)
 {
-	struct pt_regs *pt;
-	struct switch_stack *sw;
-	long ret;
-
-	pt = task_pt_regs(child);
-	sw = (struct switch_stack *) (child->thread.ksp + 16);
-
 	switch (request) {
 	      case PTRACE_PEEKTEXT:
 	      case PTRACE_PEEKDATA:
 		/* read word at location addr */
 		if (access_process_vm(child, addr, &data, sizeof(data), 0)
-		    != sizeof(data)) {
-			ret = -EIO;
-			goto out_tsk;
-		}
-		ret = data;
-		/* ensure "ret" is not mistaken as an error code */
+		    != sizeof(data))
+			return -EIO;
+		/* ensure return value is not mistaken for error code */
 		force_successful_syscall_return();
-		goto out_tsk;
+		return data;
 
 	/* PTRACE_POKETEXT and PTRACE_POKEDATA is handled
 	 * by the generic ptrace_request().
@@ -1529,50 +1514,37 @@ arch_ptrace (struct task_struct *child, 
 
 	      case PTRACE_PEEKUSR:
 		/* read the word at addr in the USER area */
-		if (access_uarea(child, addr, &data, 0) < 0) {
-			ret = -EIO;
-			goto out_tsk;
-		}
-		ret = data;
-		/* ensure "ret" is not mistaken as an error code */
+		if (access_uarea(child, addr, &data, 0) < 0)
+			return -EIO;
+		/* ensure return value is not mistaken for error code */
 		force_successful_syscall_return();
-		goto out_tsk;
+		return data;
 
 	      case PTRACE_POKEUSR:
 		/* write the word at addr in the USER area */
-		if (access_uarea(child, addr, &data, 1) < 0) {
-			ret = -EIO;
-			goto out_tsk;
-		}
-		ret = 0;
-		goto out_tsk;
+		if (access_uarea(child, addr, &data, 1) < 0)
+			return -EIO;
+		return 0;
 
 	      case PTRACE_OLD_GETSIGINFO:
 		/* for backwards-compatibility */
-		ret = ptrace_request(child, PTRACE_GETSIGINFO, addr, data);
-		goto out_tsk;
+		return ptrace_request(child, PTRACE_GETSIGINFO, addr, data);
 
 	      case PTRACE_OLD_SETSIGINFO:
 		/* for backwards-compatibility */
-		ret = ptrace_request(child, PTRACE_SETSIGINFO, addr, data);
-		goto out_tsk;
+		return ptrace_request(child, PTRACE_SETSIGINFO, addr, data);
 
 	      case PTRACE_GETREGS:
-		ret = ptrace_getregs(child,
-				     (struct pt_all_user_regs __user *) data);
-		goto out_tsk;
+		return ptrace_getregs(child,
+				      (struct pt_all_user_regs __user *) data);
 
 	      case PTRACE_SETREGS:
-		ret = ptrace_setregs(child,
-				     (struct pt_all_user_regs __user *) data);
-		goto out_tsk;
+		return ptrace_setregs(child,
+				      (struct pt_all_user_regs __user *) data);
 
 	      default:
-		ret = ptrace_request(child, request, addr, data);
-		goto out_tsk;
+		return ptrace_request(child, request, addr, data);
 	}
-  out_tsk:
-	return ret;
 }
 
 

