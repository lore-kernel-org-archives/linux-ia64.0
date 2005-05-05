From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 05 May 2005 13:39:59 +0000
Subject: [patch] merge audit fix for fsys.S
Message-Id: <200505051339.j45DdxNQ028640@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Trying to merge the test-2.6 tree with Linus' tree, a merge conflict
occurred in fsys.S.  The problem was due to the auditing fix merged by
Linus and the syscall-path optimizations in the test-2.6 tree.  The
patch below fixes the conflict.  I have not tested with auditing but
normal syscalls seem to be fine and performance remains unaffected.

Please apply to test-2.6.

Thanks,

	--david

[IA64] Merge audit fix for fsyscalls with syscall-optimizations

Signed-off-by: David Mosberger-Tang <davidm@hpl.hp.com>

Index: arch/ia64/kernel/fsys.S
=================================--- a63eb89df905efd86a58940286a63c5f670b1c05/arch/ia64/kernel/fsys.S  (mode:100644 sha1:d09a5b8a09820fbe92493c61c99073a767284c55)
+++ uncommitted/arch/ia64/kernel/fsys.S  (mode:100644 sha1:f566ff43a389a6882f91b83ef401c511a689ccb7)
@@ -630,10 +630,10 @@
 	;;
 	mov ar.rsc=0x3				// M2   set eager mode, pl 0, LE, loadrs=0
 	mov rp=r14				// I0   set the real return addr
-	nop.i 0
+	and r3=_TIF_SYSCALL_TRACEAUDIT,r3	// A
 	;;
 	ssm psr.i				// M2   we're on kernel stacks now, reenable irqs
-	tbit.z p8,p0=r3,TIF_SYSCALL_TRACE	// I0
+	cmp.eq p8,p0=r3,r0			// A
 (p10)	br.cond.spnt.many ia64_ret_from_syscall	// B    return if bad call-frame or r15 is a NaT
 
 	nop.m 0
