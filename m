From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 24 Mar 2005 00:51:42 +0000
Subject: syscall improvement patch [11/12]
Message-Id: <200503240051.j2O0pfCh022322@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

ia64: Reschedule fsys_bubble_down().

Improvements come from eliminating srlz.i, not scheduling AR/CR-reads
too early (while there are others still pending), scheduling the
backing-store switch as well as possible, splitting the BBB bundle
into a MIB/MBB pair.

Why is it safe to eliminate the srlz.i?  Observe
that we used to clear bits ~PSR_PRESERVED_BITS in PSR.L.  Since
PSR_PRESERVED_BITS=3DPSR.{UP,MFL,MFH,PK,DT,PP,SP,RT,IC}, we
ended up clearing PSR.{BE,AC,I,DFL,DFH,DI,DB,SI,TB}.  However,

 PSR.BE : already is turned off in __kernel_syscall_via_epc()
 PSR.AC : don't care (kernel normally turns PSR.AC on)
 PSR.I  : already turned off by the time fsys_bubble_down gets invoked
 PSR.DFL: always 0 (kernel never turns it on)
 PSR.DFH: don't care --- kernel never touches f32-f127 on its own
	  initiative
 PSR.DI : always 0 (kernel never turns it on)
 PSR.SI : always 0 (kernel never turns it on)
 PSR.DB : don't care --- kernel never enables kernel-level breakpoints
 PSR.TB : must be 0 already; if it wasn't zero on entry to
	  __kernel_syscall_via_epc, the branch to fsys_bubble_down
	  will trigger a taken branch; the taken-trap-handler then
	  converts the syscall into a break-based system-call.

In other words: all the bits we're clearying are either 0 already or
are don't cares!  Thus, we don't have to write PSR.L at all and we
don't have to do a srlz.i either.

Good for another ~20 cycle improvement for EPC-based heavy-weight
syscalls.

Signed-off-by: David Mosberger-Tang <davidm@hpl.hp.com>

diff -Nru a/arch/ia64/kernel/fsys.S b/arch/ia64/kernel/fsys.S
--- a/arch/ia64/kernel/fsys.S	2005-03-23 16:19:33 -08:00
+++ b/arch/ia64/kernel/fsys.S	2005-03-23 16:19:33 -08:00
@@ -549,9 +549,6 @@
 	 *	- r27: ar.rsc
 	 *	- r29: psr
 	 */
-#	define PSR_PRESERVED_BITS	(IA64_PSR_UP | IA64_PSR_MFL | IA64_PSR_MFH | I=
A64_PSR_PK \
-					 | IA64_PSR_DT | IA64_PSR_PP | IA64_PSR_SP | IA64_PSR_RT \
-					 | IA64_PSR_IC)
 	/*
 	 * Reading psr.l gives us only bits 0-31, psr.it, and psr.mc.  The rest w=
e have
 	 * to synthesize.
@@ -560,62 +557,58 @@
 					 | IA64_PSR_BN | IA64_PSR_I)
=20
 	invala
-	movl r8=3DPSR_ONE_BITS
+	movl r14=3Dia64_ret_from_syscall
=20
-	mov r25=3Dar.unat			// save ar.unat (5 cyc)
-	movl r9=3DPSR_PRESERVED_BITS
-
-	mov ar.rsc=3D0			// set enforced lazy mode, pl 0, little-endian, loadrs=
=3D0
+	nop.m 0
 	movl r28=3D__kernel_syscall_via_break
 	;;
-	mov r23=3Dar.bspstore		// save ar.bspstore (12 cyc)
-	mov r31=3Dpr			// save pr (2 cyc)
-	mov r20=3Dr1			// save caller's gp in r20
-	;;
+
 	mov r2=3Dr16			// copy current task addr to addl-addressable register
-	and r9=3Dr9,r29
-	mov r19=B6			// save b6 (2 cyc)
+	adds r16=3DIA64_TASK_THREAD_ON_USTACK_OFFSET,r16
+	mov r31=3Dpr			// save pr (2 cyc)
 	;;
-	mov psr.l=3Dr9			// slam the door (17 cyc to srlz.i)
-	or r29=3Dr8,r29			// construct cr.ipsr value to save
+	st1 [r16]=3Dr0			// clear current->thread.on_ustack flag
 	addl r22=3DIA64_RBS_OFFSET,r2	// compute base of RBS
+	add r3=3DTI_FLAGS+IA64_TASK_SIZE,r2
 	;;
-	// GAS reports a spurious RAW hazard on the read of ar.rnat because it th=
inks
-	// we may be reading ar.itc after writing to psr.l.  Avoid that message w=
ith
-	// this directive:
-	dv_serialize_data
-	mov.m r24=3Dar.rnat		// read ar.rnat (5 cyc lat)
+	ld4 r3=3D[r3]				// r2 =3D current_thread_info()->flags
 	lfetch.fault.excl.nt1 [r22]
-	adds r16=3DIA64_TASK_THREAD_ON_USTACK_OFFSET,r2
-
-	// ensure previous insn group is issued before we stall for srlz.i:
+	nop.i 0
 	;;
-	srlz.i				// ensure new psr.l has been established
-	/////////////////////////////////////////////////////////////////////////=
////
-	////////// from this point on, execution is not interruptible anymore
-	/////////////////////////////////////////////////////////////////////////=
////
-	addl r1=3DIA64_STK_OFFSET-IA64_PT_REGS_SIZE,r2	// compute base of memory =
stack
-	cmp.ne pKStk,pUStk=3Dr0,r0	// set pKStk <- 0, pUStk <- 1
+	mov ar.rsc=3D0			// set enforced lazy mode, pl 0, little-endian, loadrs=
=3D0
+	nop.m 0
+	nop.i 0
+	;;
+	mov r23=3Dar.bspstore		// save ar.bspstore (12 cyc)
+	mov.m r24=3Dar.rnat		// read ar.rnat (5 cyc lat)
+	nop.i 0
 	;;
-	st1 [r16]=3Dr0			// clear current->thread.on_ustack flag
 	mov ar.bspstore=3Dr22		// switch to kernel RBS
-	mov b6=3Dr18			// copy syscall entry-point to b6 (7 cyc)
-	add r3=3DTI_FLAGS+IA64_TASK_SIZE,r2
+	movl r8=3DPSR_ONE_BITS			// X
 	;;
-	ld4 r3=3D[r3]				// r2 =3D current_thread_info()->flags
+	mov r25=3Dar.unat			// save ar.unat (5 cyc)
+	mov r19=B6			// save b6 (2 cyc)
+	mov r20=3Dr1			// save caller's gp in r20
+	;;
+	or r29=3Dr8,r29			// construct cr.ipsr value to save
+	mov b6=3Dr18			// copy syscall entry-point to b6 (7 cyc)
+	addl r1=3DIA64_STK_OFFSET-IA64_PT_REGS_SIZE,r2	// compute base of memory =
stack
+
 	mov r18=3Dar.bsp			// save (kernel) ar.bsp (12 cyc)
-	mov ar.rsc=3D0x3			// set eager mode, pl 0, little-endian, loadrs=3D0
+	cmp.ne pKStk,pUStk=3Dr0,r0	// set pKStk <- 0, pUStk <- 1
 	br.call.sptk.many b7=3Dia64_syscall_setup
 	;;
-	ssm psr.i
-	movl r2=3Dia64_ret_from_syscall
+	mov ar.rsc=3D0x3			// set eager mode, pl 0, little-endian, loadrs=3D0
+	mov rp=3Dr14				// set the real return addr
+	nop.i 0
 	;;
-	mov rp=3Dr2				// set the real return addr
+	ssm psr.i
 	tbit.z p8,p0=3Dr3,TIF_SYSCALL_TRACE
-	;;
 (p10)	br.cond.spnt.many ia64_ret_from_syscall	// p10=3Dtrue means out regi=
sters are more than 8
+
+	nop.m 0
 (p8)	br.call.sptk.many b6=B6		// ignore this return addr
-	br.cond.sptk ia64_trace_syscall
+	br.cond.spnt ia64_trace_syscall
 END(fsys_bubble_down)
=20
 	.rodata
