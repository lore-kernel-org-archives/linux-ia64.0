From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 24 Mar 2005 00:50:52 +0000
Subject: syscall improvement patch [6/12]
Message-Id: <200503240050.j2O0oq6E022292@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

ia64: Schedule ia64_leave_syscall() to read ar.bsp earlier.

Reschedule code to read ar.bsp as early as possible.  To enable this,
don't bother clearing some of the registers when we're returning to
kernel stacks.  Also, instead of trying to support the pNonSys case
(which makes no sense), do a bugcheck instead (with break 0).  Finally,
remove a clear of r14 which is a left-over from the previous patch.

Signed-off-by: David Mosberger-Tang <davidm@hpl.hp.com>

diff -Nru a/arch/ia64/kernel/entry.S b/arch/ia64/kernel/entry.S
--- a/arch/ia64/kernel/entry.S	2005-03-23 14:19:57 -08:00
+++ b/arch/ia64/kernel/entry.S	2005-03-23 14:19:57 -08:00
@@ -694,22 +694,22 @@
 	ld8 r19=3D[r2],PT(B6)-PT(LOADRS)		// load ar.rsc value for "loadrs"
 	nop.i 0
 	;;
-	ld8 r23=3D[r3],PT(R11)-PT(AR_BSPSTORE)	// load ar.bspstore (may be garbag=
e)
+	mov r16=3Dar.bsp				// M2  get existing backing store pointer
 	ld8 r18=3D[r2],PT(R9)-PT(B6)		// load b6
 (p6)	and r15=3DTIF_WORK_MASK,r31		// any work other than TIF_SYSCALL_TRACE?
 	;;
-	mov r16=3Dar.bsp				// M2  get existing backing store pointer
+	ld8 r23=3D[r3],PT(R11)-PT(AR_BSPSTORE)	// load ar.bspstore (may be garbag=
e)
 (p6)	cmp4.ne.unc p6,p0=3Dr15, r0		// any special work pending?
 (p6)	br.cond.spnt .work_pending_syscall
 	;;
 	// start restoring the state saved on the kernel stack (struct pt_regs):
 	ld8 r9=3D[r2],PT(CR_IPSR)-PT(R9)
 	ld8 r11=3D[r3],PT(CR_IIP)-PT(R11)
-	nop.i 0
+(pNonSys) break 0		//      bug check: we shouldn't be here if pNonSys is T=
RUE!
 	;;
 	invala			// M0|1 invalidate ALAT
 	rsm psr.i | psr.ic	// M2 initiate turning off of interrupt and interrupti=
on collection
-	nop.i 0
+	cmp.eq p9,p0=3Dr0,r0	// set p9 to indicate that we should restore cr.ifs
=20
 	ld8 r29=3D[r2],16		// load cr.ipsr
 	ld8 r28=3D[r3],16			// load cr.iip
@@ -717,11 +717,11 @@
 	;;
 	ld8 r30=3D[r2],16		// M0|1 load cr.ifs
 	ld8 r25=3D[r3],16		// M0|1 load ar.unat
-	cmp.eq p9,p0=3Dr0,r0	// set p9 to indicate that we should restore cr.ifs
+(pUStk) add r14=3DIA64_TASK_THREAD_ON_USTACK_OFFSET,r13
 	;;
 	ld8 r26=3D[r2],PT(B0)-PT(AR_PFS)	// M0|1 load ar.pfs
 (pKStk)	mov r22=3Dpsr		// M2 read PSR now that interrupts are disabled
-(pUStk) add r14=3DIA64_TASK_THREAD_ON_USTACK_OFFSET,r13
+	nop 0
 	;;
 	ld8 r21=3D[r2],PT(AR_RNAT)-PT(B0) // load b0
 	ld8 r27=3D[r3],PT(PR)-PT(AR_RSC)	// load ar.rsc
@@ -735,40 +735,35 @@
 	ld8.fill r1=3D[r3],16	// load r1
 (pUStk) mov r17=3D1
 	;;
-	srlz.d			// M0  ensure interruption collection is off
+(pUStk) st1 [r14]=3Dr17
 	ld8.fill r13=3D[r3],16
 	mov f8=F0		// clear f8
 	;;
 	ld8.fill r12=3D[r2]	// restore r12 (sp)
-	mov.m ar.ssd=3Dr0		// M2 clear ar.ssd
+	ld8.fill r15=3D[r3]	// restore r15
 	mov b6=3Dr18		// I0  restore b6
=20
-	nop.m 0
+	addl r17=3DTHIS_CPU(ia64_phys_stacked_size_p8),r0
 	mov f9=F0		// clear f9
+(pKStk) br.cond.dpnt.many skip_rbs_switch
+
+	srlz.d			// M0  ensure interruption collection is off
 	shr.u r18=3Dr19,16	// I0|1 get byte size of existing "dirty" partition
+	cover			// B    add current frame into dirty partition and set cr.ifs
 	;;
-	ld8.fill r15=3D[r3]	// restore r15
-(pUStk) st1 [r14]=3Dr17
-	addl r3=3DTHIS_CPU(ia64_phys_stacked_size_p8),r0
-	;;
-(pUStk)	ld4 r17=3D[r3]		// r17 =3D cpu_data->phys_stacked_size_p8
-	mov.m ar.csd=3Dr0		// M2 clear ar.csd
+(pUStk)	ld4 r17=3D[r17]		// r17 =3D cpu_data->phys_stacked_size_p8
+	mov r19=3Dar.bsp		// M2   get new backing store pointer
 	mov f10=F0		// clear f10
=20
 	nop.m 0
 	movl r14=3D__kernel_syscall_via_epc	// X
 	;;
-	nop.m 0
-	nop.m 0
+	mov.m ar.csd=3Dr0		// M2 clear ar.csd
+	mov.m ar.ccv=3Dr0		// clear ar.ccv
 	mov b7=3Dr14		// I0   clear b7 (hint with __kernel_syscall_via_epc)
=20
-	mov r14=3Dr0		// clear r14
+	mov.m ar.ssd=3Dr0		// M2 clear ar.ssd
 	mov f11=F0		// clear f11
-(pKStk) br.cond.dpnt.many skip_rbs_switch
-
-
-	mov.m ar.ccv=3Dr0		// clear ar.ccv
-(pNonSys) br.cond.dpnt.many dont_preserve_current_frame
 	br.cond.sptk.many rbs_switch
 END(ia64_leave_syscall)
=20
@@ -946,10 +941,10 @@
 	 */
 (pNonSys) br.cond.dpnt dont_preserve_current_frame
=20
-rbs_switch:
 	cover				// add current frame into dirty partition and set cr.ifs
 	;;
 	mov r19=3Dar.bsp			// get new backing store pointer
+rbs_switch:
 	sub r16=3Dr16,r18			// krbs =3D old bsp - size of dirty partition
 	cmp.ne p9,p0=3Dr0,r0		// clear p9 to skip restore of cr.ifs
 	;;
