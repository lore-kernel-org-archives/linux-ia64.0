From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 10 May 2005 19:48:44 +0000
Subject: [patch] fix gdb inferior calls
Message-Id: <200505101948.j4AJmiJB015247@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Tony,

This patch is for the test-2.6 tree.

Running the gdb test-suite, I noticed that the test-2.6 tree is
failing segfaulting when attempting to perform an inferior call from
within gdb when the target program is blocked in a syscall.  For some
background on this issue and a simple test-case, see this mail:

  http://sources.redhat.com/ml/gdb-patches/2003-12/msg00539.html

The reason such calls are failing now is due to the new streamlined
syscall path, where I added a sanity-check to ia64_leave_syscall() to
ensure that pNonSys is FALSE and does a bug-check "break 0" otherwise.
Of course, this bugcheck was triggered by the test-case because
convert_to_non_syscall() modified pSys and pNonSys, but not
pLvSys. Thus, even after the conversion, execution would reach
ia64_leave_syscall rather than ia64_leave_kernel.  The patch below
fixes that by clearing not just pSys but also pLvSys.  In addition, to
ensure that we're not leaking kernel state, convert_to_non_syscall()
now has to explicitly clear the pt-regs state which isn't saved on
syscall-entry.

The patch below assumes that my previous fix to
convert_to_non_syscall() has been applied already but I think it will
apply even without.

Please apply test-2.6.

	--david

[IA64] Fix convert_to_non_syscall() so gdb inferior calls work again

Fix convert_to_non_syscall() so it arranges for the kernel to be left
via ia64_leave_kernel() rather than ia64_leave_syscall().  The latter
no longer tolerates being called with pSys=0 and pNonSys=1.

Modified files:
    arch/ia64/kernel/ptrace.c

Signed-off-by: David Mosberger-Tang <davidm@hpl.hp.com>

---
commit 6f764c1fcba57ac1432efbee3faddb952af9163f
tree e2923a24b6b2cd3cd5b1af3ef477da2922ba8fb2
parent 8db233099fe04a2920a25bf3371a7a5912d2248d
author <davidm@tiger.hpl.hp.com> Tue, 10 May 2005 12:32:47 -0700
committer <davidm@tiger.hpl.hp.com> Tue, 10 May 2005 12:32:47 -0700

 arch/ia64/kernel/ptrace.c |   22 +++++++++++++++++++++-
 1 files changed, 21 insertions(+), 1 deletion(-)

Index: arch/ia64/kernel/ptrace.c
=================================--- e5fb3288798ca423357c6d2bbc2e2d8ab2c70a43/arch/ia64/kernel/ptrace.c  (mode:100644)
+++ e2923a24b6b2cd3cd5b1af3ef477da2922ba8fb2/arch/ia64/kernel/ptrace.c  (mode:100644)
@@ -719,12 +719,32 @@
 			break;
 	}
 
+	/*
+	 * Note: at the time of this call, the target task is blocked
+	 * in notify_resume_user() and by clearling PRED_LEAVE_SYSCALL
+	 * (aka, "pLvSys") we redirect execution from
+	 * .work_pending_syscall_end to .work_processed_kernel.
+	 */
 	unw_get_pr(&prev_info, &pr);
-	pr &= ~(1UL << PRED_SYSCALL);
+	pr &= ~((1UL << PRED_SYSCALL) | (1UL << PRED_LEAVE_SYSCALL));
 	pr |=  (1UL << PRED_NON_SYSCALL);
 	unw_set_pr(&prev_info, pr);
 
 	pt->cr_ifs = (1UL << 63) | cfm;
+	/*
+	 * Clear the memory that is NOT written on syscall-entry to
+	 * ensure we do not leak kernel-state to user when execution
+	 * resumes.
+	 */
+	pt->r2 = 0;
+	pt->r3 = 0;
+	pt->r14 = 0;
+	memset(&pt->r16, 0, 16*8);	/* clear r16-r31 */
+	memset(&pt->f6, 0, 6*16);	/* clear f6-f11 */
+	pt->b7 = 0;
+	pt->ar_ccv = 0;
+	pt->ar_csd = 0;
+	pt->ar_ssd = 0;
 }
 
 static int
