From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 24 Mar 2005 00:51:02 +0000
Subject: syscall improvement patch [7/12]
Message-Id: <200503240051.j2O0p2Sl022298@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

ia64: In ia64_leave_syscall(), fix comments and whitespace only.

Signed-off-by: David Mosberger-Tang <davidm@hpl.hp.com>

diff -Nru a/arch/ia64/kernel/entry.S b/arch/ia64/kernel/entry.S
--- a/arch/ia64/kernel/entry.S	2005-03-23 14:31:01 -08:00
+++ b/arch/ia64/kernel/entry.S	2005-03-23 14:31:01 -08:00
@@ -625,7 +625,7 @@
  *	      r8-r11: restored (syscall return value(s))
  *		 r12: restored (user-level stack pointer)
  *		 r13: restored (user-level thread pointer)
- *		 r14: cleared
+ *		 r14: set to __kernel_syscall_via_epc
  *		 r15: restored (syscall #)
  *	     r16-r17: cleared
  *		 r18: user-level b6
@@ -646,7 +646,7 @@
  *		  pr: restored (user-level pr)
  *		  b0: restored (user-level rp)
  *	          b6: restored
- *		  b7: cleared
+ *		  b7: set to __kernel_syscall_via_epc
  *	     ar.unat: restored (user-level ar.unat)
  *	      ar.pfs: restored (user-level ar.pfs)
  *	      ar.rsc: restored (user-level ar.rsc)
@@ -708,63 +708,63 @@
 (pNonSys) break 0		//      bug check: we shouldn't be here if pNonSys is T=
RUE!
 	;;
 	invala			// M0|1 invalidate ALAT
-	rsm psr.i | psr.ic	// M2 initiate turning off of interrupt and interrupti=
on collection
-	cmp.eq p9,p0=3Dr0,r0	// set p9 to indicate that we should restore cr.ifs
+	rsm psr.i | psr.ic	// M2   turn off interrupts and interruption collection
+	cmp.eq p9,p0=3Dr0,r0	// A    set p9 to indicate that we should restore cr=
.ifs
=20
-	ld8 r29=3D[r2],16		// load cr.ipsr
-	ld8 r28=3D[r3],16			// load cr.iip
-	mov r22=3Dr0		// clear r22
+	ld8 r29=3D[r2],16		// M0|1 load cr.ipsr
+	ld8 r28=3D[r3],16		// M0|1 load cr.iip
+	mov r22=3Dr0		// A    clear r22
 	;;
 	ld8 r30=3D[r2],16		// M0|1 load cr.ifs
 	ld8 r25=3D[r3],16		// M0|1 load ar.unat
 (pUStk) add r14=3DIA64_TASK_THREAD_ON_USTACK_OFFSET,r13
 	;;
 	ld8 r26=3D[r2],PT(B0)-PT(AR_PFS)	// M0|1 load ar.pfs
-(pKStk)	mov r22=3Dpsr		// M2 read PSR now that interrupts are disabled
+(pKStk)	mov r22=3Dpsr			// M2   read PSR now that interrupts are disabled
 	nop 0
 	;;
-	ld8 r21=3D[r2],PT(AR_RNAT)-PT(B0) // load b0
-	ld8 r27=3D[r3],PT(PR)-PT(AR_RSC)	// load ar.rsc
-	mov f6=F0		// clear f6
-	;;
-	ld8 r24=3D[r2],PT(AR_FPSR)-PT(AR_RNAT)	// load ar.rnat (may be garbage)
-	ld8 r31=3D[r3],PT(R1)-PT(PR)		// load predicates
-	mov f7=F0		// clear f7
-	;;
-	ld8 r20=3D[r2],PT(R12)-PT(AR_FPSR)	// load ar.fpsr
-	ld8.fill r1=3D[r3],16	// load r1
-(pUStk) mov r17=3D1
-	;;
-(pUStk) st1 [r14]=3Dr17
-	ld8.fill r13=3D[r3],16
-	mov f8=F0		// clear f8
-	;;
-	ld8.fill r12=3D[r2]	// restore r12 (sp)
-	ld8.fill r15=3D[r3]	// restore r15
-	mov b6=3Dr18		// I0  restore b6
-
-	addl r17=3DTHIS_CPU(ia64_phys_stacked_size_p8),r0
-	mov f9=F0		// clear f9
-(pKStk) br.cond.dpnt.many skip_rbs_switch
-
-	srlz.d			// M0  ensure interruption collection is off
-	shr.u r18=3Dr19,16	// I0|1 get byte size of existing "dirty" partition
-	cover			// B    add current frame into dirty partition and set cr.ifs
-	;;
-(pUStk)	ld4 r17=3D[r17]		// r17 =3D cpu_data->phys_stacked_size_p8
-	mov r19=3Dar.bsp		// M2   get new backing store pointer
-	mov f10=F0		// clear f10
+	ld8 r21=3D[r2],PT(AR_RNAT)-PT(B0) // M0|1 load b0
+	ld8 r27=3D[r3],PT(PR)-PT(AR_RSC)	// M0|1 load ar.rsc
+	mov f6=F0			// F    clear f6
+	;;
+	ld8 r24=3D[r2],PT(AR_FPSR)-PT(AR_RNAT)	// M0|1 load ar.rnat (may be garba=
ge)
+	ld8 r31=3D[r3],PT(R1)-PT(PR)		// M0|1 load predicates
+	mov f7=F0				// F    clear f7
+	;;
+	ld8 r20=3D[r2],PT(R12)-PT(AR_FPSR)	// M0|1 load ar.fpsr
+	ld8.fill r1=3D[r3],16			// M0|1 load r1
+(pUStk) mov r17=3D1				// A
+	;;
+(pUStk) st1 [r14]=3Dr17				// M2|3
+	ld8.fill r13=3D[r3],16			// M0|1
+	mov f8=F0				// F    clear f8
+	;;
+	ld8.fill r12=3D[r2]			// M0|1 restore r12 (sp)
+	ld8.fill r15=3D[r3]			// M0|1 restore r15
+	mov b6=3Dr18				// I0   restore b6
+
+	addl r17=3DTHIS_CPU(ia64_phys_stacked_size_p8),r0 // A
+	mov f9=F0					// F    clear f9
+(pKStk) br.cond.dpnt.many skip_rbs_switch		// B
+
+	srlz.d				// M0   ensure interruption collection is off (for cover)
+	shr.u r18=3Dr19,16		// I0|1 get byte size of existing "dirty" partition
+	cover				// B    add current frame into dirty partition & set cr.ifs
+	;;
+(pUStk) ld4 r17=3D[r17]			// M0|1 r17 =3D cpu_data->phys_stacked_size_p8
+	mov r19=3Dar.bsp			// M2   get new backing store pointer
+	mov f10=F0			// F    clear f10
=20
 	nop.m 0
-	movl r14=3D__kernel_syscall_via_epc	// X
+	movl r14=3D__kernel_syscall_via_epc // X
 	;;
-	mov.m ar.csd=3Dr0		// M2 clear ar.csd
-	mov.m ar.ccv=3Dr0		// clear ar.ccv
-	mov b7=3Dr14		// I0   clear b7 (hint with __kernel_syscall_via_epc)
-
-	mov.m ar.ssd=3Dr0		// M2 clear ar.ssd
-	mov f11=F0		// clear f11
-	br.cond.sptk.many rbs_switch
+	mov.m ar.csd=3Dr0			// M2   clear ar.csd
+	mov.m ar.ccv=3Dr0			// M2   clear ar.ccv
+	mov b7=3Dr14			// I0   clear b7 (hint with __kernel_syscall_via_epc)
+
+	mov.m ar.ssd=3Dr0			// M2   clear ar.ssd
+	mov f11=F0			// F    clear f11
+	br.cond.sptk.many rbs_switch	// B
 END(ia64_leave_syscall)
=20
 #ifdef CONFIG_IA32_SUPPORT
@@ -940,7 +940,6 @@
 	 * NOTE: alloc, loadrs, and cover can't be predicated.
 	 */
 (pNonSys) br.cond.dpnt dont_preserve_current_frame
-
 	cover				// add current frame into dirty partition and set cr.ifs
 	;;
 	mov r19=3Dar.bsp			// get new backing store pointer
