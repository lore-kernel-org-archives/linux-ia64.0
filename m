From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 19 Jan 2005 05:02:07 +0000
Subject: [patch] Improve ia64_leave_syscall() for McKinley-type cores.
Message-Id: <16877.59855.421280.449700@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Optimize ia64_leave_syscall() a bit better for McKinley-type cores.
The patch looks big, but that's mostly due to renaming r16/r17 to r2/r3.
Good for a 13 cycle improvement.

	--david

Signed-off-by: David Mosberger-Tang <davidm@hpl.hp.com>

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/01/18 18:12:07-08:00 davidm@tiger.hpl.hp.com=20
#   ia64: Improve ia64_leave_syscall() for McKinley-type cores.  Improves
#   	(normal) getpid() from 271 to 258 cycles.
#=20
# arch/ia64/kernel/entry.S
#   2005/01/18 18:11:50-08:00 davidm@tiger.hpl.hp.com +51 -48
#   (ia64_leave_syscall): Make it a local function (it's not used anywhere
#   	else anymore).
#   	Use r2/r3 as base-pointers instead of r16/r17.
#   	Load b6 into r18 instead of r22 (frees up a register).
#   	Read ar.bsp early (_big_ savings!).
#   	Reschedule for McKinley-type cores.
#   	Do srlz.i _before_ restoring the stack-pointer or updating
#   	current->thread.on_ustack.
#   (skip_rbs_switch): Clear r2 if pLvSys is TRUE.
#=20
diff -Nru a/arch/ia64/kernel/entry.S b/arch/ia64/kernel/entry.S
--- a/arch/ia64/kernel/entry.S	2005-01-18 21:00:24 -08:00
+++ b/arch/ia64/kernel/entry.S	2005-01-18 21:00:24 -08:00
@@ -633,10 +633,12 @@
  *		 r13: restored (user-level thread pointer)
  *		 r14: cleared
  *		 r15: restored (syscall #)
- *	     r16-r19: cleared
+ *	     r16-r17: cleared
+ *		 r18: user-level b6
+ *		 r19: cleared
  *		 r20: user-level ar.fpsr
  *		 r21: user-level b0
- *		 r22: user-level b6
+ *		 r22: cleared
  *		 r23: user-level ar.bspstore
  *		 r24: user-level ar.rnat
  *		 r25: user-level ar.unat
@@ -661,7 +663,7 @@
  *	      ar.csd: cleared
  *	      ar.ssd: cleared
  */
-GLOBAL_ENTRY(ia64_leave_syscall)
+ENTRY(ia64_leave_syscall)
 	PT_REGS_UNWIND_INFO(0)
 	/*
 	 * work.need_resched etc. mustn't get changed by this CPU before it retur=
ns to
@@ -690,79 +692,80 @@
 (pUStk)	cmp.eq.unc p6,p0=3Dr0,r0		// p6 <- pUStk
 #endif
 .work_processed_syscall:
-	adds r16=3DPT(LOADRS)+16,r12
-	adds r17=3DPT(AR_BSPSTORE)+16,r12
+	adds r2=3DPT(LOADRS)+16,r12
+	adds r3=3DPT(AR_BSPSTORE)+16,r12
 	adds r18=3DTI_FLAGS+IA64_TASK_SIZE,r13
 	;;
 (p6)	ld4 r31=3D[r18]				// load current_thread_info()->flags
-	ld8 r19=3D[r16],PT(B6)-PT(LOADRS)		// load ar.rsc value for "loadrs"
-	nop.i 0
+	ld8 r19=3D[r2],PT(B6)-PT(LOADRS)		// load ar.rsc value for "loadrs"
+	mov b7=3Dr0		// clear b7
 	;;
-	ld8 r23=3D[r17],PT(R9)-PT(AR_BSPSTORE)	// load ar.bspstore (may be garbag=
e)
-	ld8 r22=3D[r16],PT(R8)-PT(B6)		// load b6
+	ld8 r23=3D[r3],PT(R9)-PT(AR_BSPSTORE)	// load ar.bspstore (may be garbage)
+	ld8 r18=3D[r2],PT(R8)-PT(B6)		// load b6
 (p6)	and r15=3DTIF_WORK_MASK,r31		// any work other than TIF_SYSCALL_TRACE?
 	;;
-
-	mov.m ar.ccv=3Dr0		// clear ar.ccv
+	mov r16=3Dar.bsp				// M2  get existing backing store pointer
 (p6)	cmp4.ne.unc p6,p0=3Dr15, r0		// any special work pending?
 (p6)	br.cond.spnt .work_pending
 	;;
 	// start restoring the state saved on the kernel stack (struct pt_regs):
-	ld8.fill r8=3D[r16],16
-	ld8.fill r9=3D[r17],16
+	ld8.fill r8=3D[r2],16
+	ld8.fill r9=3D[r3],16
 	mov f6=F0		// clear f6
 	;;
-	ld8.fill r10=3D[r16],16
-	ld8.fill r11=3D[r17],16
+	invala			// M0|1 invalidate ALAT
+	rsm psr.i | psr.ic	// M2 initiate turning off of interrupt and interrupti=
on collection
+	mov f9=F0		// clear f9
+
+	ld8.fill r10=3D[r2],16
+	ld8.fill r11=3D[r3],16
 	mov f7=F0		// clear f7
 	;;
-	ld8 r29=3D[r16],16	// load cr.ipsr
-	ld8 r28=3D[r17],16	// load cr.iip
+	ld8 r29=3D[r2],16		// load cr.ipsr
+	ld8 r28=3D[r3],16			// load cr.iip
 	mov f8=F0		// clear f8
 	;;
-	ld8 r30=3D[r16],16	// load cr.ifs
-	ld8 r25=3D[r17],16	// load ar.unat
+	ld8 r30=3D[r2],16		// M0|1 load cr.ifs
+	mov.m ar.ssd=3Dr0		// M2 clear ar.ssd
 	cmp.eq p9,p0=3Dr0,r0	// set p9 to indicate that we should restore cr.ifs
 	;;
-	rsm psr.i | psr.ic	// initiate turning off of interrupt and interruption =
collection
-	invala			// invalidate ALAT
-	mov f9=F0		// clear f9
-
-	mov.m ar.ssd=3Dr0		// clear ar.ssd
-	mov.m ar.csd=3Dr0		// clear ar.csd
+	ld8 r25=3D[r3],16		// M0|1 load ar.unat
+	mov.m ar.csd=3Dr0		// M2 clear ar.csd
+	mov r22=3Dr0		// clear r22
+	;;
+	ld8 r26=3D[r2],PT(B0)-PT(AR_PFS)	// M0|1 load ar.pfs
+	nop.m 0
 	mov f10=F0		// clear f10
 	;;
-	ld8 r26=3D[r16],16	// load ar.pfs
-	ld8 r27=3D[r17],PT(PR)-PT(AR_RSC)	// load ar.rsc
+	ld8 r21=3D[r2],PT(AR_RNAT)-PT(B0) // load b0
+	ld8 r27=3D[r3],PT(PR)-PT(AR_RSC)	// load ar.rsc
 	mov f11=F0		// clear f11
 	;;
-	ld8 r24=3D[r16],PT(B0)-PT(AR_RNAT)	// load ar.rnat (may be garbage)
-	ld8 r31=3D[r17],PT(R1)-PT(PR)		// load predicates
+	ld8 r24=3D[r2],PT(AR_FPSR)-PT(AR_RNAT)	// load ar.rnat (may be garbage)
+	ld8 r31=3D[r3],PT(R1)-PT(PR)		// load predicates
 (pUStk) add r14=3DIA64_TASK_THREAD_ON_USTACK_OFFSET,r13
 	;;
-	ld8 r21=3D[r16],PT(R12)-PT(B0) // load b0
-	ld8.fill r1=3D[r17],16	// load r1
-(pUStk) mov r3=3D1
-	;;
-	ld8.fill r12=3D[r16],16
-	ld8.fill r13=3D[r17],16
-	mov r2=3Dr0		// clear r2
+	ld8 r20=3D[r2],PT(R12)-PT(AR_FPSR)	// load ar.fpsr
+	ld8.fill r1=3D[r3],16	// load r1
+(pUStk) mov r17=3D1
 	;;
-	ld8 r20=3D[r16]		// load ar.fpsr
-	ld8.fill r15=3D[r17]	// load r15
-	mov b7=3Dr0		// clear b7
+	srlz.i			// M0  ensure interruption collection is off
+	ld8.fill r13=3D[r3],16
+	nop.i 0
 	;;
-(pUStk) st1 [r14]=3Dr3
-	addl r17=3DTHIS_CPU(ia64_phys_stacked_size_p8),r0
+	ld8.fill r12=3D[r2]	// restore r12 (sp)
+	ld8.fill r15=3D[r3]	// restore r15
+	addl r3=3DTHIS_CPU(ia64_phys_stacked_size_p8),r0
+	;;
+(pUStk)	ld4 r3=3D[r3]		// r3 =3D cpu_data->phys_stacked_size_p8
+(pUStk) st1 [r14]=3Dr17
+	mov b6=3Dr18		// I0  restore b6
 	;;
-	mov r16=3Dar.bsp		// get existing backing store pointer
-	srlz.i			// ensure interruption collection is off
+	shr.u r18=3Dr19,16	// I0|1 get byte size of existing "dirty" partition
 	mov r14=3Dr0		// clear r14
-	;;
-	ld4 r17=3D[r17]		// r17 =3D cpu_data->phys_stacked_size_p8
-	mov b6=3Dr22				// restore b6
-	shr.u r18=3Dr19,16	// get byte size of existing "dirty" partition
 (pKStk) br.cond.dpnt.many skip_rbs_switch
+
+	mov.m ar.ccv=3Dr0		// clear ar.ccv
 (pNonSys) br.cond.dpnt.many dont_preserve_current_frame
 	br.cond.sptk.many rbs_switch
 END(ia64_leave_syscall)
@@ -1054,7 +1057,7 @@
 	;;
 (pUStk)	mov ar.rnat=3Dr24		// M2 must happen with RSE in lazy mode
 	nop 0
-	nop 0
+(pLvSys)mov r2=3Dr0
=20
 	mov ar.rsc=3Dr27		// M2
 	mov pr=3Dr31,-1		// I0
