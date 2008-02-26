From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Tue, 26 Feb 2008 13:58:55 +0000
Subject: [PATCH 4/8] ia64/pv_ops: paravirtualize arch/ia64/kernel/switch_leave.S
Message-Id: <12040343393726-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 arch/ia64/kernel/switch_leave.S |   86 ++++++++++++++++++++++-------------=
---
 1 files changed, 50 insertions(+), 36 deletions(-)

diff --git a/arch/ia64/kernel/switch_leave.S b/arch/ia64/kernel/switch_leav=
e.S
index b235917..c016556 100644
--- a/arch/ia64/kernel/switch_leave.S
+++ b/arch/ia64/kernel/switch_leave.S
@@ -44,8 +44,14 @@
 #include <asm/pgtable.h>
 #include <asm/thread_info.h>
=20
-#include "minstate.h"
+#ifdef __IA64_ASM_PARAVIRTUALIZED_XEN
+#include "../xen/inst_xen.h"
+#include "../xen/xenminstate.h"
+#else
+#include "inst_native.h"
+#endif
=20
+#include "minstate.h"
=20
 /*
  * prev_task <- ia64_switch_to(struct task_struct *next)
@@ -53,7 +59,8 @@
  *	called.  The code starting at .map relies on this.  The rest of the code
  *	doesn't care about the interrupt masking status.
  */
-GLOBAL_ENTRY(__ia64_switch_to)
+GLOBAL_ENTRY(__paravirt_switch_to)
+	BR_IF_NATIVE(__ia64_switch_to, r22, p7)
 	.prologue
 	alloc r16=3Dar.pfs,1,0,0,0
 	DO_SAVE_SWITCH_STACK
@@ -77,7 +84,7 @@ GLOBAL_ENTRY(__ia64_switch_to)
 	;;
 .done:
 	ld8 sp=3D[r21]			// load kernel stack pointer of new task
-	mov IA64_KR(CURRENT)=3Din0	// update "current" application register
+	MOV_TO_KR(CURRENT, in0)		// update "current" application register
 	mov r8=3Dr13			// return pointer to previously running task
 	mov r13=3Din0			// set "current" pointer
 	;;
@@ -89,25 +96,30 @@ GLOBAL_ENTRY(__ia64_switch_to)
 	br.ret.sptk.many rp		// boogie on out in new context
=20
 .map:
-	rsm psr.ic			// interrupts (psr.i) are already disabled here
+	RSM_PSR_IC(r25)			// interrupts (psr.i) are already disabled here
 	movl r25=3DPAGE_KERNEL
 	;;
 	srlz.d
 	or r23=3Dr25,r20			// construct PA | page properties
 	mov r25=3DIA64_GRANULE_SHIFT<<2
 	;;
-	mov cr.itir=3Dr25
-	mov cr.ifa=3Din0			// VA of next task...
+	MOV_TO_ITIR(p0, r25, r8)
+	MOV_TO_IFA(in0, r8)		// VA of next task...
 	;;
 	mov r25=3DIA64_TR_CURRENT_STACK
-	mov IA64_KR(CURRENT_STACK)=3Dr26	// remember last page we mapped...
+	MOV_TO_KR(CURRENT_STACK, r26)	// remember last page we mapped...
 	;;
 	itr.d dtr[r25]=3Dr23		// wire in new mapping...
-	ssm psr.ic			// reenable the psr.ic bit
-	;;
-	srlz.d
+	SSM_PSR_IC_AND_SRLZ_D(r8, r9)	// reenable the psr.ic bit
 	br.cond.sptk .done
-END(__ia64_switch_to)
+END(__paravirt_switch_to)
+
+#ifdef IA64_ASM_PARAVIRTUALIZED_XEN
+GLOBAL_ENTRY(xen_work_processed_syscall_with_check)
+	BR_IF_NATIVE(__ia64_work_processed_syscall, r2, p7)
+	br.cond.sptk xen_work_processed_syscall
+END(xen_work_processed_syscall_with_check)
+#endif /* IA64_ASM_PARAVIRTUALIZED_XEN */
=20
 /*
  * ia64_leave_syscall(): Same as ia64_leave_kernel, except that it doesn't
@@ -153,7 +165,8 @@ END(__ia64_switch_to)
  *	      ar.csd: cleared
  *	      ar.ssd: cleared
  */
-GLOBAL_ENTRY(__ia64_leave_syscall)
+GLOBAL_ENTRY(__paravirt_leave_syscall)
+	BR_IF_NATIVE(__ia64_leave_syscall, r22, p7)
 	PT_REGS_UNWIND_INFO(0)
 	/*
 	 * work.need_resched etc. mustn't get changed by this CPU before it retur=
ns to
@@ -177,12 +190,12 @@ GLOBAL_ENTRY(__ia64_leave_syscall)
 	;;
 	cmp.eq p6,p0=3Dr21,r0		// p6 <- pUStk || (preempt_count =3D 0)
 #else /* !CONFIG_PREEMPT */
-(pUStk)	rsm psr.i
+	RSM_PSR_I(pUStk, r2, r18)
 	cmp.eq pLvSys,p0=3Dr0,r0		// pLvSys=3D1: leave from syscall
 (pUStk)	cmp.eq.unc p6,p0=3Dr0,r0		// p6 <- pUStk
 #endif
-.global __ia64_work_processed_syscall;
-__ia64_work_processed_syscall:
+.global __paravirt_work_processed_syscall;
+__paravirt_work_processed_syscall:
 	adds r2=3DPT(LOADRS)+16,r12
 	adds r3=3DPT(AR_BSPSTORE)+16,r12
 	adds r18=3DTI_FLAGS+IA64_TASK_SIZE,r13
@@ -205,7 +218,7 @@ __ia64_work_processed_syscall:
 (pNonSys) break 0		//      bug check: we shouldn't be here if pNonSys is T=
RUE!
 	;;
 	invala			// M0|1 invalidate ALAT
-	rsm psr.i | psr.ic	// M2   turn off interrupts and interruption collection
+	RSM_PSR_I_IC(r28, r29, r30)	// M2   turn off interrupts and interruption =
collection
 	cmp.eq p9,p0=3Dr0,r0	// A    set p9 to indicate that we should restore cr=
.ifs
=20
 	ld8 r29=3D[r2],16		// M0|1 load cr.ipsr
@@ -217,7 +230,7 @@ __ia64_work_processed_syscall:
 (pUStk) add r14=3DIA64_TASK_THREAD_ON_USTACK_OFFSET,r13
 	;;
 	ld8 r26=3D[r2],PT(B0)-PT(AR_PFS)	// M0|1 load ar.pfs
-(pKStk)	mov r22=3Dpsr			// M2   read PSR now that interrupts are disabled
+	MOV_FROM_PSR(pKStk, r22, r21)	// M2   read PSR now that interrupts are di=
sabled
 	nop 0
 	;;
 	ld8 r21=3D[r2],PT(AR_RNAT)-PT(B0) // M0|1 load b0
@@ -246,7 +259,7 @@ __ia64_work_processed_syscall:
=20
 	srlz.d				// M0   ensure interruption collection is off (for cover)
 	shr.u r18=3Dr19,16		// I0|1 get byte size of existing "dirty" partition
-	cover				// B    add current frame into dirty partition & set cr.ifs
+	COVER				// B    add current frame into dirty partition & set cr.ifs
 	;;
 	mov r19=3Dar.bsp			// M2   get new backing store pointer
 	mov f10=F0			// F    clear f10
@@ -261,9 +274,10 @@ __ia64_work_processed_syscall:
 	mov.m ar.ssd=3Dr0			// M2   clear ar.ssd
 	mov f11=F0			// F    clear f11
 	br.cond.sptk.many rbs_switch	// B
-END(__ia64_leave_syscall)
+END(__paravirt_leave_syscall)
=20
-GLOBAL_ENTRY(__ia64_leave_kernel)
+GLOBAL_ENTRY(__paravirt_leave_kernel)
+	BR_IF_NATIVE(__ia64_leave_kernel, r22, p7)
 	PT_REGS_UNWIND_INFO(0)
 	/*
 	 * work.need_resched etc. mustn't get changed by this CPU before it retur=
ns to
@@ -287,7 +301,7 @@ GLOBAL_ENTRY(__ia64_leave_kernel)
 	;;
 	cmp.eq p6,p0=3Dr21,r0		// p6 <- pUStk || (preempt_count =3D 0)
 #else
-(pUStk)	rsm psr.i
+	RSM_PSR_I(pUStk, r17, r31)
 	cmp.eq p0,pLvSys=3Dr0,r0		// pLvSys=3D0: leave from kernel
 (pUStk)	cmp.eq.unc p6,p0=3Dr0,r0		// p6 <- pUStk
 #endif
@@ -335,7 +349,7 @@ GLOBAL_ENTRY(__ia64_leave_kernel)
 	mov ar.csd=3Dr30
 	mov ar.ssd=3Dr31
 	;;
-	rsm psr.i | psr.ic	// initiate turning off of interrupt and interruption =
collection
+	RSM_PSR_I_IC(r23, r22, r25)	// initiate turning off of interrupt and inte=
rruption collection
 	invala			// invalidate ALAT
 	;;
 	ld8.fill r22=3D[r2],24
@@ -367,13 +381,13 @@ GLOBAL_ENTRY(__ia64_leave_kernel)
 	mov ar.ccv=3Dr15
 	;;
 	ldf.fill f11=3D[r2]
-	bsw.0			// switch back to bank 0 (no stop bit required beforehand...)
+	BSW_0(r2, r3, r15)	// switch back to bank 0 (no stop bit required beforeh=
and...)
 	;;
 (pUStk)	mov r18=3DIA64_KR(CURRENT)// M2 (12 cycle read latency)
 	adds r16=3DPT(CR_IPSR)+16,r12
 	adds r17=3DPT(CR_IIP)+16,r12
=20
-(pKStk)	mov r22=3Dpsr		// M2 read PSR now that interrupts are disabled
+	MOV_FROM_PSR(pKStk, r22, r29)	// M2 read PSR now that interrupts are disa=
bled
 	nop.i 0
 	nop.i 0
 	;;
@@ -421,7 +435,7 @@ GLOBAL_ENTRY(__ia64_leave_kernel)
 	 * NOTE: alloc, loadrs, and cover can't be predicated.
 	 */
 (pNonSys) br.cond.dpnt dont_preserve_current_frame
-	cover				// add current frame into dirty partition and set cr.ifs
+	COVER				// add current frame into dirty partition and set cr.ifs
 	;;
 	mov r19=3Dar.bsp			// get new backing store pointer
 rbs_switch:
@@ -524,16 +538,16 @@ skip_rbs_switch:
 (pKStk)	dep r29=3Dr22,r29,21,1	// I0 update ipsr.pp with psr.pp
 (pLvSys)mov r16=3Dr0		// A  clear r16 for leave_syscall, no-op otherwise
 	;;
-	mov cr.ipsr=3Dr29		// M2
+	MOV_TO_IPSR(r29, r25)	// M2
 	mov ar.pfs=3Dr26		// I0
 (pLvSys)mov r17=3Dr0		// A  clear r17 for leave_syscall, no-op otherwise
=20
-(p9)	mov cr.ifs=3Dr30		// M2
+	MOV_TO_IFS(p9, r30, r25)// M2
 	mov b0=3Dr21		// I0
 (pLvSys)mov r18=3Dr0		// A  clear r18 for leave_syscall, no-op otherwise
=20
 	mov ar.fpsr=3Dr20		// M2
-	mov cr.iip=3Dr28		// M2
+	MOV_TO_IIP(r28, r25)	// M2
 	nop 0
 	;;
 (pUStk)	mov ar.rnat=3Dr24		// M2 must happen with RSE in lazy mode
@@ -542,7 +556,7 @@ skip_rbs_switch:
=20
 	mov ar.rsc=3Dr27		// M2
 	mov pr=3Dr31,-1		// I0
-	rfi			// B
+	RFI			// B
=20
 	/*
 	 * On entry:
@@ -568,28 +582,28 @@ skip_rbs_switch:
 #endif
 	br.call.spnt.many rp=3Dschedule
 .ret9:	cmp.eq p6,p0=3Dr0,r0				// p6 <- 1
-	rsm psr.i		// disable interrupts
+	RSM_PSR_I(p0, r2, r20)	// disable interrupts
 	;;
 #ifdef CONFIG_PREEMPT
 (pKStk)	adds r20=3DTI_PRE_COUNT+IA64_TASK_SIZE,r13
 	;;
 (pKStk)	st4 [r20]=3Dr0		// preempt_count() <- 0
 #endif
-(pLvSys)br.cond.sptk.few  ia64_work_pending_syscall_end
+(pLvSys)br.cond.sptk.few  __paravirt_pending_syscall_end
 	br.cond.sptk.many .work_processed_kernel	// re-check
=20
 .notify:
 (pUStk)	br.call.spnt.many rp=3Dnotify_resume_user
 .ret10:	cmp.ne p6,p0=3Dr0,r0				// p6 <- 0
-(pLvSys)br.cond.sptk.few  ia64_work_pending_syscall_end
+(pLvSys)br.cond.sptk.few  __paravirt_pending_syscall_end
 	br.cond.sptk.many .work_processed_kernel	// don't re-check
=20
-.global ia64_work_pending_syscall_end;
-ia64_work_pending_syscall_end:
+.global __paravirt_pending_syscall_end;
+__paravirt_pending_syscall_end:
 	adds r2=3DPT(R8)+16,r12
 	adds r3=3DPT(R10)+16,r12
 	;;
 	ld8 r8=3D[r2]
 	ld8 r10=3D[r3]
-	br.cond.sptk.many ia64_work_processed_syscall	// re-check
-END(__ia64_leave_kernel)
+	br.cond.sptk.many __paravirt_work_processed_syscall_target	// re-check
+END(__paravirt_leave_kernel)
--=20
1.5.3

