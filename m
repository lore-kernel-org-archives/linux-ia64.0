From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 19 Jan 2005 07:12:56 +0000
Subject: [patch] ia64: fix potential NaT bit error for sys_pipe().
Message-Id: <16878.2168.388519.26567@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

While working on the syscall exit path again, I realized that in
theory it would be possible for sys_pipe() to mistakenly return a
NaTed value in r9, even though the syscall succeeded.

The problem is due to the fact that sys_pipe() sets r9, but doesn't
clear the matching NaT bit.  In fact, it can't even do so easily since
the NaT bit may be either in ar.unat or in some other location (e.g.,
saved on the stack or a stacked register).

I think the best fix for this is to return r9/r11 directly (not via
pt_regs).  The patch below changes ia64_ret_from_syscall() to save r9
and r11 along with the existing saves for r8 and r10.  There was some
fallout since kernel_thread() used to abuse r9/r11 for its own
purposes.  That was easy to fix though by using r4/r5 instead.

	--david

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/01/18 22:57:59-08:00 davidm@tiger.hpl.hp.com 
#   ia64: Fix potential (though extremely unlikely) NaT bit error for sys_pipe().
# 
# arch/ia64/kernel/sys_ia64.c
#   2005/01/18 22:57:48-08:00 davidm@tiger.hpl.hp.com +16 -11
#   (sys_pipe): Return second file-descriptor directly via r9.
# 
# arch/ia64/kernel/process.c
#   2005/01/18 22:57:48-08:00 davidm@tiger.hpl.hp.com +4 -3
#   (kernel_thread): Pass fn/arg in r4/r5 instead of r9/r11.
#   	For consistency, also set pSys predicate since it will look like
#   	we'll be returning from clone2().
# 
# arch/ia64/kernel/head.S
#   2005/01/18 22:57:48-08:00 davidm@tiger.hpl.hp.com +3 -3
#   (start_kernel_thread): Pick up out0/out1 from r4/r5 instead of r9/r11.
#   	Instead of an endless loop, do "break 0" if sys_exit returns
#   	unexpectedly.
# 
# arch/ia64/kernel/entry.S
#   2005/01/18 22:57:48-08:00 davidm@tiger.hpl.hp.com +5 -2
#   (ia64_ret_from_syscall): Also spill r9 and r11 so their NaT bits are valid.
# 
diff -Nru a/arch/ia64/kernel/entry.S b/arch/ia64/kernel/entry.S
--- a/arch/ia64/kernel/entry.S	2005-01-18 23:01:00 -08:00
+++ b/arch/ia64/kernel/entry.S	2005-01-18 23:01:00 -08:00
@@ -614,8 +614,11 @@
 	adds r2=PT(R8)+16,sp			// r2 = &pt_regs.r8
 	adds r3=PT(R10)+16,sp			// r3 = &pt_regs.r10
 	;;
-.mem.offset 0,0; (p6) st8.spill [r2]=r8	// store return value in slot for r8 and set unat bit
-.mem.offset 8,0; (p6) st8.spill [r3]=r0	// clear error indication in slot for r10 and set unat bit
+.mem.offset 0,0; (p6) st8.spill [r2]=r8,PT(R9)-PT(R8)	// return retval via r8/set unat bit
+.mem.offset 8,0; (p6) st8.spill [r3]=r0,PT(R11)-PT(R10)	// clear error flag via r10/set unat bit
+	;;
+.mem.offset 0,0; (p6)	st8.spill [r2]=r9	// save r9/set unat bit
+.mem.offset 8,0; (p6)	st8.spill [r3]=r11	// save r9/set unat bit
 (p7)	br.cond.spnt handle_syscall_error	// handle potential syscall failure
 END(ia64_ret_from_syscall)
 	// fall through
diff -Nru a/arch/ia64/kernel/head.S b/arch/ia64/kernel/head.S
--- a/arch/ia64/kernel/head.S	2005-01-18 23:01:00 -08:00
+++ b/arch/ia64/kernel/head.S	2005-01-18 23:01:00 -08:00
@@ -885,12 +885,12 @@
 	.save rp, r0				// this is the end of the call-chain
 	.body
 	alloc r2 = ar.pfs, 0, 0, 2, 0
-	mov out0 = r9
-	mov out1 = r11;;
+	mov out0 = r4
+	mov out1 = r5;;
 	br.call.sptk.many rp = kernel_thread_helper;;
 	mov out0 = r8
 	br.call.sptk.many rp = sys_exit;;
-1:	br.sptk.few 1b				// not reached
+	break 0					// not reached
 END(start_kernel_thread)
 
 #ifdef CONFIG_IA64_BRL_EMU
diff -Nru a/arch/ia64/kernel/process.c b/arch/ia64/kernel/process.c
--- a/arch/ia64/kernel/process.c	2005-01-18 23:01:00 -08:00
+++ b/arch/ia64/kernel/process.c	2005-01-18 23:01:00 -08:00
@@ -662,14 +662,15 @@
 	memset(&regs, 0, sizeof(regs));
 	regs.pt.cr_iip = helper_fptr[0];	/* set entry point (IP) */
 	regs.pt.r1 = helper_fptr[1];		/* set GP */
-	regs.pt.r9 = (unsigned long) fn;	/* 1st argument */
-	regs.pt.r11 = (unsigned long) arg;	/* 2nd argument */
+	regs.sw.r4 = (unsigned long) fn;	/* 1st argument */
+	regs.sw.r5 = (unsigned long) arg;	/* 2nd argument */
 	/* Preserve PSR bits, except for bits 32-34 and 37-45, which we can't read.  */
 	regs.pt.cr_ipsr = ia64_getreg(_IA64_REG_PSR) | IA64_PSR_BN;
 	regs.pt.cr_ifs = 1UL << 63;		/* mark as valid, empty frame */
 	regs.sw.ar_fpsr = regs.pt.ar_fpsr = ia64_getreg(_IA64_REG_AR_FPSR);
 	regs.sw.ar_bspstore = (unsigned long) current + IA64_RBS_OFFSET;
-	regs.sw.pr = (1 << PRED_KERNEL_STACK);
+	/* It'll look like new thread is returning from clone(): */
+	regs.sw.pr = (1 << PRED_KERNEL_STACK) | (1 << PRED_SYSCALL);
 	return do_fork(flags | CLONE_VM | CLONE_UNTRACED, 0, &regs.pt, 0, NULL, NULL);
 }
 EXPORT_SYMBOL(kernel_thread);
diff -Nru a/arch/ia64/kernel/sys_ia64.c b/arch/ia64/kernel/sys_ia64.c
--- a/arch/ia64/kernel/sys_ia64.c	2005-01-18 23:01:00 -08:00
+++ b/arch/ia64/kernel/sys_ia64.c	2005-01-18 23:01:00 -08:00
@@ -2,7 +2,7 @@
  * This file contains various system calls that have different calling
  * conventions on different platforms.
  *
- * Copyright (C) 1999-2000, 2002-2003 Hewlett-Packard Co
+ * Copyright (C) 1999-2000, 2002-2003, 2005 Hewlett-Packard Co
  *	David Mosberger-Tang <davidm@hpl.hp.com>
  */
 #include <linux/config.h>
@@ -162,21 +162,26 @@
  * On IA-64, we return the two file descriptors in ret0 and ret1 (r8
  * and r9) as this is faster than doing a copy_to_user().
  */
-asmlinkage long
-sys_pipe (long arg0, long arg1, long arg2, long arg3,
-	  long arg4, long arg5, long arg6, long arg7, long stack)
+struct sysret {
+	long r8;
+	long r9;
+};
+
+asmlinkage struct sysret
+sys_pipe (void)
 {
-	struct pt_regs *regs = (struct pt_regs *) &stack;
+	struct sysret sysret;
 	int fd[2];
-	int retval;
+	long ret;
 
-	retval = do_pipe(fd);
-	if (retval)
+	ret = do_pipe(fd);
+	if (ret)
 		goto out;
-	retval = fd[0];
-	regs->r9 = fd[1];
+	ret = fd[0];
+	sysret.r9 = fd[1];
   out:
-	return retval;
+	sysret.r8 = ret;
+	return sysret;
 }
 
 static inline unsigned long
