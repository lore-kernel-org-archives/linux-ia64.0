From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Thu, 27 Jan 2005 23:44:42 +0000
Subject: RE: syscall exit path optimization
Message-Id: <200501272344.j0RNigg07440@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200501262102.j0QL2Qg28166@unix-os.sc.intel.com>
In-Reply-To: <200501262102.j0QL2Qg28166@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

David Mosberger wrote on Wednesday, January 26, 2005 1:31 PM
> Couldn't you restore r8/r10 after .work_pending is done in if
> pLvSys is TRUE?  That way, .work_processed would simply preserve
> (save _and_ restore) r8/r10.

Thank you for reviewing and the suggestion.  Here is the updated
patch, net saving for 6 cycles compares to 4 with earlier version.

Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>
Signed-off-by: Rohit Seth <rohit.seth@intel.com>


--- linux-ia64-release/arch/ia64/kernel/entry.S.orig	2005-01-26 11:41:24.00=
0000000 -0800
+++ linux-ia64-release/arch/ia64/kernel/entry.S	2005-01-27 15:13:25.0000000=
00 -0800
@@ -558,7 +558,7 @@ GLOBAL_ENTRY(ia64_trace_syscall)
 .mem.offset 0,0; st8.spill [r2]=3Dr8		// store return value in slot for r8
 .mem.offset 8,0; st8.spill [r3]=3Dr10		// clear error indication in slot f=
or r10
 	br.call.sptk.many rp=3Dsyscall_trace_leave // give parent a chance to cat=
ch return value
-.ret3:	br.cond.sptk ia64_leave_syscall
+.ret3:	br.cond.sptk .work_pending_syscall_end

 strace_error:
 	ld8 r3=3D[r2]				// load pt_regs.r8
@@ -621,10 +621,7 @@ GLOBAL_ENTRY(ia64_ret_from_syscall)
 	PT_REGS_UNWIND_INFO(0)
 	cmp.ge p6,p7=3Dr8,r0			// syscall executed successfully?
 	adds r2=3DPT(R8)+16,sp			// r2 =3D &pt_regs.r8
-	adds r3=3DPT(R10)+16,sp			// r3 =3D &pt_regs.r10
-	;;
-(p6)	st8 [r2]=3Dr8				// store return value in slot for r8
-(p6)	st8 [r3]=3Dr0				// clear error indication in slot for r10
+	mov r10=3Dr0				// clear error indication in r10
 (p7)	br.cond.spnt handle_syscall_error	// handle potential syscall failure
 END(ia64_ret_from_syscall)
 	// fall through
@@ -709,27 +706,23 @@ ENTRY(ia64_leave_syscall)
 	ld8 r19=3D[r2],PT(B6)-PT(LOADRS)		// load ar.rsc value for "loadrs"
 	mov b7=3Dr0		// clear b7
 	;;
-	ld8 r23=3D[r3],PT(R9)-PT(AR_BSPSTORE)	// load ar.bspstore (may be garbage)
-	ld8 r18=3D[r2],PT(R8)-PT(B6)		// load b6
+	ld8 r23=3D[r3],PT(R11)-PT(AR_BSPSTORE)	// load ar.bspstore (may be garbag=
e)
+	ld8 r18=3D[r2],PT(R9)-PT(B6)		// load b6
 (p6)	and r15=3DTIF_WORK_MASK,r31		// any work other than TIF_SYSCALL_TRACE?
 	;;
 	mov r16=3Dar.bsp				// M2  get existing backing store pointer
 (p6)	cmp4.ne.unc p6,p0=3Dr15, r0		// any special work pending?
-(p6)	br.cond.spnt .work_pending
+(p6)	br.cond.spnt .work_pending_syscall
 	;;
 	// start restoring the state saved on the kernel stack (struct pt_regs):
-	ld8 r8=3D[r2],16
-	ld8 r9=3D[r3],16
+	ld8 r9=3D[r2],PT(CR_IPSR)-PT(R9)
+	ld8 r11=3D[r3],PT(CR_IIP)-PT(R11)
 	mov f6=F0		// clear f6
 	;;
 	invala			// M0|1 invalidate ALAT
 	rsm psr.i | psr.ic	// M2 initiate turning off of interrupt and interrupti=
on collection
 	mov f9=F0		// clear f9

-	ld8 r10=3D[r2],16
-	ld8 r11=3D[r3],16
-	mov f7=F0		// clear f7
-	;;
 	ld8 r29=3D[r2],16		// load cr.ipsr
 	ld8 r28=3D[r3],16			// load cr.iip
 	mov f8=F0		// clear f8
@@ -760,7 +753,7 @@ ENTRY(ia64_leave_syscall)
 	;;
 	srlz.d			// M0  ensure interruption collection is off
 	ld8.fill r13=3D[r3],16
-	nop.i 0
+	mov f7=F0		// clear f7
 	;;
 	ld8.fill r12=3D[r2]	// restore r12 (sp)
 	ld8.fill r15=3D[r3]	// restore r15
@@ -770,8 +763,8 @@ ENTRY(ia64_leave_syscall)
 (pUStk) st1 [r14]=3Dr17
 	mov b6=3Dr18		// I0  restore b6
 	;;
-	shr.u r18=3Dr19,16	// I0|1 get byte size of existing "dirty" partition
 	mov r14=3Dr0		// clear r14
+	shr.u r18=3Dr19,16	// I0|1 get byte size of existing "dirty" partition
 (pKStk) br.cond.dpnt.many skip_rbs_switch

 	mov.m ar.ccv=3Dr0		// clear ar.ccv
@@ -1083,6 +1076,12 @@ skip_rbs_switch:
 	 * On exit:
 	 *	p6 =3D TRUE if work-pending-check needs to be redone
 	 */
+.work_pending_syscall:
+	add r2=3D-8,r2
+	add r3=3D-8,r3
+	;;
+	st8 [r2]=3Dr8
+	st8 [r3]=3Dr10
 .work_pending:
 	tbit.nz p6,p0=3Dr31,TIF_SIGDELAYED		// signal delayed from  MCA/INIT/NMI/=
PMI context?
 (p6)	br.cond.sptk.few .sigdelayed
@@ -1104,13 +1103,13 @@ skip_rbs_switch:
 	;;
 (pKStk)	st4 [r20]=3Dr0		// preempt_count() <- 0
 #endif
-(pLvSys)br.cond.sptk.many .work_processed_syscall	// re-check
+(pLvSys)br.cond.sptk.few  .work_pending_syscall_end
 	br.cond.sptk.many .work_processed_kernel	// re-check

 .notify:
 (pUStk)	br.call.spnt.many rp=3Dnotify_resume_user
 .ret10:	cmp.ne p6,p0=3Dr0,r0				// p6 <- 0
-(pLvSys)br.cond.sptk.many .work_processed_syscall	// don't re-check
+(pLvSys)br.cond.sptk.few  .work_pending_syscall_end
 	br.cond.sptk.many .work_processed_kernel	// don't re-check

 // There is a delayed signal that was detected in MCA/INIT/NMI/PMI context=
 where
@@ -1121,9 +1120,17 @@ skip_rbs_switch:
 .sigdelayed:
 	br.call.sptk.many rp=3Ddo_sigdelayed
 	cmp.eq p6,p0=3Dr0,r0				// p6 <- 1, always re-check
-(pLvSys)br.cond.sptk.many .work_processed_syscall	// re-check
+(pLvSys)br.cond.sptk.few  .work_pending_syscall_end
 	br.cond.sptk.many .work_processed_kernel	// re-check

+.work_pending_syscall_end:
+	adds r2=3DPT(R8)+16,r12
+	adds r3=3DPT(R10)+16,r12
+	;;
+	ld8 r8=3D[r2]
+	ld8 r10=3D[r3]
+	br.cond.sptk.many .work_processed_syscall	// re-check
+
 END(ia64_leave_kernel)

 ENTRY(handle_syscall_error)
@@ -1135,17 +1142,11 @@ ENTRY(handle_syscall_error)
 	 */
 	PT_REGS_UNWIND_INFO(0)
 	ld8 r3=3D[r2]		// load pt_regs.r8
-	sub r9=3D0,r8		// negate return value to get errno
 	;;
-	mov r10=3D-1		// return -1 in pt_regs.r10 to indicate error
 	cmp.eq p6,p7=3Dr3,r0	// is pt_regs.r8=3D0?
-	adds r3=16,r2		// r3=3D&pt_regs.r10
-	;;
-(p6)	mov r9=3Dr8
-(p6)	mov r10=3D0
 	;;
-	st8 [r2]=3Dr9		// store errno in pt_regs.r8
-	st8 [r3]=3Dr10		// store error indication in pt_regs.r10
+(p7)	mov r10=3D-1
+(p7)	sub r8=3D0,r8		// negate return value to get errno
 	br.cond.sptk ia64_leave_syscall
 END(handle_syscall_error)




