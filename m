From: Alex Dowad <alexinbeijing@gmail.com>
Date: Fri, 13 Mar 2015 18:14:36 +0000
Subject: [PATCH 13/32] ia64: copy_thread(): rename 'user_stack_size' argument to 'kthread_arg'
Message-Id: <1426270496-26362-3-git-send-email-alexinbeijing@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1426270496-26362-1-git-send-email-alexinbeijing@gmail.com>
In-Reply-To: <1426270496-26362-1-git-send-email-alexinbeijing@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, Matt Fleming <matt.fleming@intel.com>, "open list:IA64 Itanium PL..." <linux-ia64@vger.kernel.org>

'user_stack_size' is very misleading, since the argument is never used for the
size of the user stack. Rather, it is an argument which is passed to the main
function executed by a newly forked kernel thread. Hence, rename it to
'kthread_arg'.

When forking a new user thread, the kernel thread arg was (uselessly) added
to the new user stack pointer. This "worked", since the kernel thread arg is
always zero when forking a user thread, but it was obviously not intended.

Signed-off-by: Alex Dowad <alexinbeijing@gmail.com>
---
 arch/ia64/kernel/process.c | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/arch/ia64/kernel/process.c b/arch/ia64/kernel/process.c
index b515149..d4a78da 100644
--- a/arch/ia64/kernel/process.c
+++ b/arch/ia64/kernel/process.c
@@ -300,7 +300,7 @@ ia64_load_extra (struct task_struct *task)
 }
 
 /*
- * Copy the state of an ia-64 thread.
+ * Copy the architecture-specific state of an ia-64 thread.
  *
  * We get here through the following  call chain:
  *
@@ -332,7 +332,7 @@ ia64_load_extra (struct task_struct *task)
  */
 int
 copy_thread(unsigned long clone_flags,
-	     unsigned long user_stack_base, unsigned long user_stack_size,
+	     unsigned long user_stack_base, unsigned long kthread_arg,
 	     struct task_struct *p)
 {
 	extern char ia64_ret_from_clone;
@@ -376,13 +376,14 @@ copy_thread(unsigned long clone_flags,
 	ia64_drop_fpu(p);	/* don't pick up stale state from a CPU's fph */
 
 	if (unlikely(p->flags & PF_KTHREAD)) {
+		/* kernel thread */
 		if (unlikely(!user_stack_base)) {
 			/* fork_idle() called us */
 			return 0;
 		}
 		memset(child_stack, 0, sizeof(*child_ptregs) + sizeof(*child_stack));
 		child_stack->r4 = user_stack_base;	/* payload */
-		child_stack->r5 = user_stack_size;	/* argument */
+		child_stack->r5 = kthread_arg;
 		/*
 		 * Preserve PSR bits, except for bits 32-34 and 37-45,
 		 * which we can't read.
@@ -406,6 +407,8 @@ copy_thread(unsigned long clone_flags,
 
 		return 0;
 	}
+
+	/* user thread */
 	stack = ((struct switch_stack *) regs) - 1;
 	/* copy parent's switch_stack & pt_regs to child: */
 	memcpy(child_stack, stack, sizeof(*child_ptregs) + sizeof(*child_stack));
@@ -416,7 +419,7 @@ copy_thread(unsigned long clone_flags,
 	if (clone_flags & CLONE_SETTLS)
 		child_ptregs->r13 = regs->r16;	/* see sys_clone2() in entry.S */
 	if (user_stack_base) {
-		child_ptregs->r12 = user_stack_base + user_stack_size - 16;
+		child_ptregs->r12 = user_stack_base - 16;
 		child_ptregs->ar_bspstore = user_stack_base;
 		child_ptregs->ar_rnat = 0;
 		child_ptregs->loadrs = 0;
-- 
2.0.0.GIT

