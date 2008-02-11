From: Petr Tesarik <ptesarik@suse.cz>
Date: Mon, 11 Feb 2008 21:43:05 +0000
Subject: [PATCH 4/6] convert sys_ptrace to arch_ptrace
Message-Id: <1202766185.9594.28.camel@elijah.suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Convert sys_ptrace() to arch_ptrace().

Signed-off-by: Petr Tesarik <ptesarik@suse.cz>
CC: Tony Luck <tony.luck@intel.com>
CC: Christoph Hellwig <hch@infradead.org>

diff --git a/arch/ia64/kernel/ptrace.c b/arch/ia64/kernel/ptrace.c
index e82fe29..1dfff5a 100644
--- a/arch/ia64/kernel/ptrace.c
+++ b/arch/ia64/kernel/ptrace.c
@@ -1470,46 +1470,13 @@ ptrace_disable (struct task_struct *chil
 	child_psr->tb = 0;
 }
 
-asmlinkage long
-sys_ptrace (long request, pid_t pid, unsigned long addr, unsigned long data)
+long
+arch_ptrace (struct task_struct *child, long request, long addr, long data)
 {
 	struct pt_regs *pt;
-	struct task_struct *child;
 	struct switch_stack *sw;
 	long ret;
 
-	lock_kernel();
-	ret = -EPERM;
-	if (request = PTRACE_TRACEME) {
-		ret = ptrace_traceme();
-		goto out;
-	}
-
-	ret = -ESRCH;
-	read_lock(&tasklist_lock);
-	{
-		child = find_task_by_pid(pid);
-		if (child)
-			get_task_struct(child);
-	}
-	read_unlock(&tasklist_lock);
-	if (!child)
-		goto out;
-	ret = -EPERM;
-	if (pid = 1)		/* no messing around with init! */
-		goto out_tsk;
-
-	if (request = PTRACE_ATTACH) {
-		ret = ptrace_attach(child);
-		if (!ret)
-			arch_ptrace_attach(child);
-		goto out_tsk;
-	}
-
-	ret = ptrace_check_attach(child, request = PTRACE_KILL);
-	if (ret < 0)
-		goto out_tsk;
-
 	pt = task_pt_regs(child);
 	sw = (struct switch_stack *) (child->thread.ksp + 16);
 
@@ -1594,7 +1561,7 @@ sys_ptrace (long request, pid_t pid, uns
 		 */
 		if (child->exit_state = EXIT_ZOMBIE)
 			/* already dead */
-			goto out_tsk;
+			return 0;
 		child->exit_code = SIGKILL;
 
 		ptrace_disable(child);
@@ -1643,9 +1610,6 @@ sys_ptrace (long request, pid_t pid, uns
 		goto out_tsk;
 	}
   out_tsk:
-	put_task_struct(child);
-  out:
-	unlock_kernel();
 	return ret;
 }
 
diff --git a/include/asm-ia64/ptrace.h b/include/asm-ia64/ptrace.h
index 0bdce7d..5b52340 100644
--- a/include/asm-ia64/ptrace.h
+++ b/include/asm-ia64/ptrace.h
@@ -233,8 +233,6 @@ #ifdef __KERNEL__
 #include <asm/current.h>
 #include <asm/page.h>
 
-#define __ARCH_SYS_PTRACE	1
-
 /*
  * We use the ia64_psr(regs)->ri to determine which of the three
  * instructions in bundle (16 bytes) took the sample. Generate

