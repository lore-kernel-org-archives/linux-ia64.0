From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Fri, 12 Dec 2008 06:38:54 +0000
Subject: [PATCH 05/15] ia64/pv_ops: paravirtualize fsys.S.
Message-Id: <1229063944-27462-6-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

paravirtualize fsys.S.

Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 arch/ia64/kernel/fsys.S |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/arch/ia64/kernel/fsys.S b/arch/ia64/kernel/fsys.S
index 788319f..3544d75 100644
--- a/arch/ia64/kernel/fsys.S
+++ b/arch/ia64/kernel/fsys.S
@@ -419,7 +419,7 @@ EX(.fail_efault, ld8 r14=[r33])			// r14 <- *set
 	mov r17=(1 << (SIGKILL - 1)) | (1 << (SIGSTOP - 1))
 	;;
 
-	rsm psr.i				// mask interrupt delivery
+	RSM_PSR_I(p0, r18, r19)			// mask interrupt delivery
 	mov ar.ccv=0
 	andcm r14=r14,r17			// filter out SIGKILL & SIGSTOP
 
@@ -492,7 +492,7 @@ EX(.fail_efault, ld8 r14=[r33])			// r14 <- *set
 #ifdef CONFIG_SMP
 	st4.rel [r31]=r0			// release the lock
 #endif
-	ssm psr.i
+	SSM_PSR_I(p0, p9, r31)
 	;;
 
 	srlz.d					// ensure psr.i is set again
@@ -514,7 +514,7 @@ EX(.fail_efault, (p15) st8 [r34]=r3)
 #ifdef CONFIG_SMP
 	st4.rel [r31]=r0			// release the lock
 #endif
-	ssm psr.i
+	SSM_PSR_I(p0, p9, r17)
 	;;
 	srlz.d
 	br.sptk.many fsys_fallback_syscall	// with signal pending, do the heavy-weight syscall
@@ -522,7 +522,7 @@ EX(.fail_efault, (p15) st8 [r34]=r3)
 #ifdef CONFIG_SMP
 .lock_contention:
 	/* Rather than spinning here, fall back on doing a heavy-weight syscall.  */
-	ssm psr.i
+	SSM_PSR_I(p0, p9, r17)
 	;;
 	srlz.d
 	br.sptk.many fsys_fallback_syscall
@@ -593,11 +593,11 @@ ENTRY(fsys_fallback_syscall)
 	adds r17=-1024,r15
 	movl r14=sys_call_table
 	;;
-	rsm psr.i
+	RSM_PSR_I(p0, r26, r27)
 	shladd r18=r17,3,r14
 	;;
 	ld8 r18=[r18]				// load normal (heavy-weight) syscall entry-point
-	mov r29=psr				// read psr (12 cyc load latency)
+	MOV_FROM_PSR(p0, r29, r26)		// read psr (12 cyc load latency)
 	mov r27=ar.rsc
 	mov r21=ar.fpsr
 	mov r26=ar.pfs
@@ -735,7 +735,7 @@ GLOBAL_ENTRY(paravirt_fsys_bubble_down)
 	mov rp=r14				// I0   set the real return addr
 	and r3=_TIF_SYSCALL_TRACEAUDIT,r3	// A
 	;;
-	ssm psr.i				// M2   we're on kernel stacks now, reenable irqs
+	SSM_PSR_I(p0, p6, r22)			// M2   we're on kernel stacks now, reenable irqs
 	cmp.eq p8,p0=r3,r0			// A
 (p10)	br.cond.spnt.many ia64_ret_from_syscall	// B    return if bad call-frame or r15 is a NaT
 
-- 
1.6.0.2

