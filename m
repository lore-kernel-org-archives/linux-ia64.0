From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 24 Mar 2005 00:50:22 +0000
Subject: syscall improvement patch [3/12]
Message-Id: <200503240050.j2O0oMrl022274@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

ia64: Schedule fp-clearing insns at least 6 cycles after reading ar.bsp.

Decreases syscall overhead by approximately 6 cycles.

Signed-off-by: David Mosberger-Tang <davidm@hpl.hp.com>

diff -Nru a/arch/ia64/kernel/entry.S b/arch/ia64/kernel/entry.S
--- a/arch/ia64/kernel/entry.S	2005-03-23 13:11:22 -08:00
+++ b/arch/ia64/kernel/entry.S	2005-03-23 13:11:22 -08:00
@@ -705,15 +705,15 @@
 	// start restoring the state saved on the kernel stack (struct pt_regs):
 	ld8 r9=3D[r2],PT(CR_IPSR)-PT(R9)
 	ld8 r11=3D[r3],PT(CR_IIP)-PT(R11)
-	mov f6=F0		// clear f6
+	nop.i 0
 	;;
 	invala			// M0|1 invalidate ALAT
 	rsm psr.i | psr.ic	// M2 initiate turning off of interrupt and interrupti=
on collection
-	mov f9=F0		// clear f9
+	nop.i 0
=20
 	ld8 r29=3D[r2],16		// load cr.ipsr
 	ld8 r28=3D[r3],16			// load cr.iip
-	mov f8=F0		// clear f8
+	mov r22=3Dr0		// clear r22
 	;;
 	ld8 r30=3D[r2],16		// M0|1 load cr.ifs
 	ld8 r25=3D[r3],16		// M0|1 load ar.unat
@@ -721,15 +721,15 @@
 	;;
 	ld8 r26=3D[r2],PT(B0)-PT(AR_PFS)	// M0|1 load ar.pfs
 (pKStk)	mov r22=3Dpsr		// M2 read PSR now that interrupts are disabled
-	mov f10=F0		// clear f10
+(pUStk) add r14=3DIA64_TASK_THREAD_ON_USTACK_OFFSET,r13
 	;;
 	ld8 r21=3D[r2],PT(AR_RNAT)-PT(B0) // load b0
 	ld8 r27=3D[r3],PT(PR)-PT(AR_RSC)	// load ar.rsc
-	mov f11=F0		// clear f11
+	mov f6=F0		// clear f6
 	;;
 	ld8 r24=3D[r2],PT(AR_FPSR)-PT(AR_RNAT)	// load ar.rnat (may be garbage)
 	ld8 r31=3D[r3],PT(R1)-PT(PR)		// load predicates
-(pUStk) add r14=3DIA64_TASK_THREAD_ON_USTACK_OFFSET,r13
+	mov f7=F0		// clear f7
 	;;
 	ld8 r20=3D[r2],PT(R12)-PT(AR_FPSR)	// load ar.fpsr
 	ld8.fill r1=3D[r3],16	// load r1
@@ -737,23 +737,28 @@
 	;;
 	srlz.d			// M0  ensure interruption collection is off
 	ld8.fill r13=3D[r3],16
-	mov f7=F0		// clear f7
+	mov f8=F0		// clear f8
 	;;
 	ld8.fill r12=3D[r2]	// restore r12 (sp)
 	mov.m ar.ssd=3Dr0		// M2 clear ar.ssd
-	mov r22=3Dr0		// clear r22
+	mov b6=3Dr18		// I0  restore b6
=20
+	nop.m 0
+	mov f9=F0		// clear f9
+	shr.u r18=3Dr19,16	// I0|1 get byte size of existing "dirty" partition
+	;;
 	ld8.fill r15=3D[r3]	// restore r15
 (pUStk) st1 [r14]=3Dr17
 	addl r3=3DTHIS_CPU(ia64_phys_stacked_size_p8),r0
 	;;
 (pUStk)	ld4 r17=3D[r3]		// r17 =3D cpu_data->phys_stacked_size_p8
 	mov.m ar.csd=3Dr0		// M2 clear ar.csd
-	mov b6=3Dr18		// I0  restore b6
+	mov f10=F0		// clear f10
 	;;
 	mov r14=3Dr0		// clear r14
-	shr.u r18=3Dr19,16	// I0|1 get byte size of existing "dirty" partition
+	mov f11=F0		// clear f11
 (pKStk) br.cond.dpnt.many skip_rbs_switch
+
=20
 	mov.m ar.ccv=3Dr0		// clear ar.ccv
 (pNonSys) br.cond.dpnt.many dont_preserve_current_frame
