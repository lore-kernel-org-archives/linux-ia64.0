From: Keith Owens <kaos@sgi.com>
Date: Thu, 16 Sep 2004 22:59:03 +0000
Subject: Re: RFC - freeing up ar.k5
Message-Id: <19581.1095375543@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <200409162152.i8GLqwG01566@unix-os.sc.intel.com>
In-Reply-To: <200409162152.i8GLqwG01566@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 16 Sep 2004 14:52:58 -0700, 
"Luck, Tony" <tony.luck@intel.com> wrote:
>Well, this is what a patch to free up ar.k5 by replacing its use
>with a percpu variable looks like.

And a micro-optimization to add to it.

Index: linux/arch/ia64/kernel/ptrace.c
=================================--- linux.orig/arch/ia64/kernel/ptrace.c	Sat Aug 14 15:38:08 2004
+++ linux/arch/ia64/kernel/ptrace.c	Fri Sep 17 08:53:12 2004
@@ -613,7 +613,7 @@ ia64_flush_fph (struct task_struct *task
 {
 	struct ia64_psr *psr = ia64_psr(ia64_task_regs(task));
 
-	if (ia64_is_local_fpu_owner(task) && psr->mfh) {
+	if (psr->mfh && ia64_is_local_fpu_owner(task)) {
 		psr->mfh = 0;
 		task->thread.flags |= IA64_THREAD_FPH_VALID;
 		ia64_save_fpu(&task->thread.fph[0]);

