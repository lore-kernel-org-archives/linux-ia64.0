From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 19 Jan 2005 04:54:18 +0000
Subject: [patch] cleanup C uage of global/root-function predicates
Message-Id: <16877.59386.135421.212523@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The patch below is purely a cleanup but it's a prerequisite for the
next bug fix patch.

	--david

Signed-off-by: David Mosberger-Tang <davidm@hpl.hp.com>

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/01/18 20:48:49-08:00 davidm@tiger.hpl.hp.com 
#   ia64: Cleanup C usage of global/root-function predicates.
# 
# arch/ia64/kernel/unwind.c
#   2005/01/18 20:41:58-08:00 davidm@tiger.hpl.hp.com +1 -3
#   (p5): Delete this macro.
#   (unw_unwind): Replace pNonSys with PRED_NON_SYSCALL.
# 
# arch/ia64/kernel/ptrace.c
#   2005/01/18 20:41:57-08:00 davidm@tiger.hpl.hp.com +2 -5
#   (p4): Delete this macro.
#   (p5): Likewise.
#   (convert_to_non_syscall): Replace pSys with (1UL << PRED_SYSCALL) and
#   	pNonSys with (1UL << PRED_NON_SYSCALL).
# 
# arch/ia64/kernel/entry.h
#   2005/01/18 20:41:57-08:00 davidm@tiger.hpl.hp.com +18 -7
#   (PRED_LEAVE_SYSCALL): New macro.
#   (PRED_KERNEL_STACK): Likewise.
#   (PRED_USER_STACK): Likewise.
#   (PRED_SYSCALL): Likewise.
#   (PRED_NON_SYSCALL): Likewise.
#   (PASTE2): Likewise.
#   (PASTE): Likewise.
#   (pLvSys): Define based on PRED_LEAVE_SYSCALL.
#   (pKStk): Define based on PRED_KERNEL_STACK.
#   (pUStk): Define based on PRED_USER_STACK.
#   (pSys): Define based on PRED_SYSCALL.
#   (pNonSys): Define based on PRED_NON_SYSCALL.
# 
diff -Nru a/arch/ia64/kernel/entry.h b/arch/ia64/kernel/entry.h
--- a/arch/ia64/kernel/entry.h	2005-01-18 20:52:16 -08:00
+++ b/arch/ia64/kernel/entry.h	2005-01-18 20:52:16 -08:00
@@ -1,14 +1,25 @@
 #include <linux/config.h>
 
 /*
- * Preserved registers that are shared between code in ivt.S and entry.S.  Be
- * careful not to step on these!
+ * Preserved registers that are shared between code in ivt.S and
+ * entry.S.  Be careful not to step on these!
  */
-#define pLvSys		p1	/* set 1 if leave from syscall; otherwise, set 0 */
-#define pKStk		p2	/* will leave_{kernel,syscall} return to kernel-stacks? */
-#define pUStk		p3	/* will leave_{kernel,syscall} return to user-stacks? */
-#define pSys		p4	/* are we processing a (synchronous) system call? */
-#define pNonSys		p5	/* complement of pSys */
+#define PRED_LEAVE_SYSCALL	1 /* TRUE iff leave from syscall */
+#define PRED_KERNEL_STACK	2 /* returning to kernel-stacks? */
+#define PRED_USER_STACK		3 /* returning to user-stacks? */
+#define PRED_SYSCALL		4 /* inside a system call? */
+#define PRED_NON_SYSCALL	5 /* complement of PRED_SYSCALL */
+
+#ifdef __ASSEMBLY__
+# define PASTE2(x,y)	x##y
+# define PASTE(x,y)	PASTE2(x,y)
+
+# define pLvSys		PASTE(p,PRED_LEAVE_SYSCALL)
+# define pKStk		PASTE(p,PRED_KERNEL_STACK)
+# define pUStk		PASTE(p,PRED_USER_STACK)
+# define pSys		PASTE(p,PRED_SYSCALL)
+# define pNonSys	PASTE(p,PRED_NON_SYSCALL)
+#endif
 
 #define PT(f)		(IA64_PT_REGS_##f##_OFFSET)
 #define SW(f)		(IA64_SWITCH_STACK_##f##_OFFSET)
diff -Nru a/arch/ia64/kernel/ptrace.c b/arch/ia64/kernel/ptrace.c
--- a/arch/ia64/kernel/ptrace.c	2005-01-18 20:52:16 -08:00
+++ b/arch/ia64/kernel/ptrace.c	2005-01-18 20:52:16 -08:00
@@ -30,9 +30,6 @@
 
 #include "entry.h"
 
-#define p4	(1UL << 4)	/* for pSys (see entry.h) */
-#define p5	(1UL << 5)	/* for pNonSys (see entry.h) */
-
 /*
  * Bits in the PSR that we allow ptrace() to change:
  *	be, up, ac, mfl, mfh (the user mask; five bits total)
@@ -707,8 +704,8 @@
 	}
 
 	unw_get_pr(&prev_info, &pr);
-	pr &= ~pSys;
-	pr |= pNonSys;
+	pr &= ~(1UL << PRED_SYSCALL);
+	pr |=  (1UL << PRED_NON_SYSCALL);
 	unw_set_pr(&prev_info, pr);
 
 	pt->cr_ifs = (1UL << 63) | cfm;
diff -Nru a/arch/ia64/kernel/unwind.c b/arch/ia64/kernel/unwind.c
--- a/arch/ia64/kernel/unwind.c	2005-01-18 20:52:16 -08:00
+++ b/arch/ia64/kernel/unwind.c	2005-01-18 20:52:16 -08:00
@@ -47,8 +47,6 @@
 #include "entry.h"
 #include "unwind_i.h"
 
-#define p5		5
-
 #define UNW_LOG_CACHE_SIZE	7	/* each unw_script is ~256 bytes in size */
 #define UNW_CACHE_SIZE		(1 << UNW_LOG_CACHE_SIZE)
 
@@ -1899,7 +1897,7 @@
 	num_regs = 0;
 	if ((info->flags & UNW_FLAG_INTERRUPT_FRAME)) {
 		info->pt = info->sp + 16;
-		if ((pr & (1UL << pNonSys)) != 0)
+		if ((pr & (1UL << PRED_NON_SYSCALL)) != 0)
 			num_regs = *info->cfm_loc & 0x7f;		/* size of frame */
 		info->pfs_loc  			(unsigned long *) (info->pt + offsetof(struct pt_regs, ar_pfs));
