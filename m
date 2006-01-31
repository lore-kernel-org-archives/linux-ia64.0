From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Tue, 31 Jan 2006 09:16:04 +0000
Subject: [patch 4/6] prefetch bottom of kernel rbs stack at kernel exit path
Message-Id: <200601310916.k0V9GCg13405@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Kernel knows where the register backing store is corresponding
to user dirty stack registers.  Prefetch those cache lines as
early as possible in ia64_leave_kernel path.


Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>

--- ./arch/ia64/kernel/entry.S.orig	2006-01-31 01:10:47.189437208 -0800
+++ ./arch/ia64/kernel/entry.S	2006-01-31 01:10:56.418929282 -0800
@@ -847,11 +847,13 @@ GLOBAL_ENTRY(ia64_leave_kernel)
 #endif
 .work_processed_kernel:
 	adds r17=TI_FLAGS+IA64_TASK_SIZE,r13
+	adds r20=PT(LOADRS)+16+2,r12		// r20 = &pt_regs->loadrs[30:16]
+	adds r22=IA64_RBS_OFFSET,r13
 	;;
 (p6)	ld4 r31=[r17]				// load current_thread_info()->flags
+(pUStk)	ld2 r27=[r20]			// get size of dirty partition
 	adds r21=PT(PR)+16,r12
 	;;
-
 	lfetch [r21],PT(CR_IPSR)-PT(PR)
 	adds r2=PT(B6)+16,r12
 	adds r3=PT(R16)+16,r12
@@ -871,6 +873,12 @@ GLOBAL_ENTRY(ia64_leave_kernel)
 	ld8 r29=[r2],16		// load b7
 	ld8 r30=[r3],16		// load ar.csd
 (p6)	br.cond.spnt .work_pending
+1:
+(pUStk)	lfetch[r22],128
+	add r27=-128,r27
+	;;
+(pUStk)	cmp.gt.unc p7,p0=r27,r0
+(p7)	br.dptk.few 1b
 	;;
 	ld8 r31=[r2],16		// load ar.ssd
 	ld8.fill r8=[r3],16


