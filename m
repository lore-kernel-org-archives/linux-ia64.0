From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 24 Mar 2005 00:51:52 +0000
Subject: syscall improvement patch [12/12]
Message-Id: <200503240051.j2O0pqsK022328@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

ia64: Annotate fsys_bubble_down() with McKinley dispatch info.

This patch changes comments & formatting only.  There is no code
change.

Signed-off-by: David Mosberger-Tang <davidm@hpl.hp.com>

diff -Nru a/arch/ia64/kernel/fsys.S b/arch/ia64/kernel/fsys.S
--- a/arch/ia64/kernel/fsys.S	2005-03-23 16:33:21 -08:00
+++ b/arch/ia64/kernel/fsys.S	2005-03-23 16:33:21 -08:00
@@ -531,84 +531,114 @@
 	.altrp b6
 	.body
 	/*
-	 * We get here for syscalls that don't have a lightweight handler.  For t=
hose, we
-	 * need to bubble down into the kernel and that requires setting up a min=
imal
-	 * pt_regs structure, and initializing the CPU state more or less as if an
-	 * interruption had occurred.  To make syscall-restarts work, we setup pt=
_regs
-	 * such that cr_iip points to the second instruction in syscall_via_break.
-	 * Decrementing the IP hence will restart the syscall via break and not
-	 * decrementing IP will return us to the caller, as usual.  Note that we =
preserve
-	 * the value of psr.pp rather than initializing it from dcr.pp.  This mak=
es it
-	 * possible to distinguish fsyscall execution from other privileged execu=
tion.
+	 * We get here for syscalls that don't have a lightweight
+	 * handler.  For those, we need to bubble down into the kernel
+	 * and that requires setting up a minimal pt_regs structure,
+	 * and initializing the CPU state more or less as if an
+	 * interruption had occurred.  To make syscall-restarts work,
+	 * we setup pt_regs such that cr_iip points to the second
+	 * instruction in syscall_via_break.  Decrementing the IP
+	 * hence will restart the syscall via break and not
+	 * decrementing IP will return us to the caller, as usual.
+	 * Note that we preserve the value of psr.pp rather than
+	 * initializing it from dcr.pp.  This makes it possible to
+	 * distinguish fsyscall execution from other privileged
+	 * execution.
 	 *
 	 * On entry:
-	 *	- normal fsyscall handler register usage, except that we also have:
+	 *	- normal fsyscall handler register usage, except
+	 *	  that we also have:
 	 *	- r18: address of syscall entry point
 	 *	- r21: ar.fpsr
 	 *	- r26: ar.pfs
 	 *	- r27: ar.rsc
 	 *	- r29: psr
+	 *
+	 * We used to clear some PSR bits here but that requires slow
+	 * serialization.  Fortuntely, that isn't really necessary.
+	 * The rationale is as follows: we used to clear bits
+	 * ~PSR_PRESERVED_BITS in PSR.L.  Since
+	 * PSR_PRESERVED_BITS=3DPSR.{UP,MFL,MFH,PK,DT,PP,SP,RT,IC}, we
+	 * ended up clearing PSR.{BE,AC,I,DFL,DFH,DI,DB,SI,TB}.
+	 * However,
+	 *
+	 * PSR.BE : already is turned off in __kernel_syscall_via_epc()
+	 * PSR.AC : don't care (kernel normally turns PSR.AC on)
+	 * PSR.I  : already turned off by the time fsys_bubble_down gets
+	 *	    invoked
+	 * PSR.DFL: always 0 (kernel never turns it on)
+	 * PSR.DFH: don't care --- kernel never touches f32-f127 on its own
+	 *	    initiative
+	 * PSR.DI : always 0 (kernel never turns it on)
+	 * PSR.SI : always 0 (kernel never turns it on)
+	 * PSR.DB : don't care --- kernel never enables kernel-level
+	 *	    breakpoints
+	 * PSR.TB : must be 0 already; if it wasn't zero on entry to
+	 *          __kernel_syscall_via_epc, the branch to fsys_bubble_down
+	 *          will trigger a taken branch; the taken-trap-handler then
+	 *          converts the syscall into a break-based system-call.
 	 */
 	/*
-	 * Reading psr.l gives us only bits 0-31, psr.it, and psr.mc.  The rest w=
e have
-	 * to synthesize.
+	 * Reading psr.l gives us only bits 0-31, psr.it, and psr.mc.
+	 * The rest we have to synthesize.
 	 */
-#	define PSR_ONE_BITS		((3 << IA64_PSR_CPL0_BIT) | (0x1 << IA64_PSR_RI_BIT=
) \
+#	define PSR_ONE_BITS		((3 << IA64_PSR_CPL0_BIT)	\
+					 | (0x1 << IA64_PSR_RI_BIT)	\
 					 | IA64_PSR_BN | IA64_PSR_I)
=20
-	invala
-	movl r14=3Dia64_ret_from_syscall
+	invala					// M0|1
+	movl r14=3Dia64_ret_from_syscall		// X
=20
 	nop.m 0
-	movl r28=3D__kernel_syscall_via_break
+	movl r28=3D__kernel_syscall_via_break	// X	create cr.iip
 	;;
=20
-	mov r2=3Dr16			// copy current task addr to addl-addressable register
-	adds r16=3DIA64_TASK_THREAD_ON_USTACK_OFFSET,r16
-	mov r31=3Dpr			// save pr (2 cyc)
-	;;
-	st1 [r16]=3Dr0			// clear current->thread.on_ustack flag
-	addl r22=3DIA64_RBS_OFFSET,r2	// compute base of RBS
-	add r3=3DTI_FLAGS+IA64_TASK_SIZE,r2
+	mov r2=3Dr16				// A    get task addr to addl-addressable register
+	adds r16=3DIA64_TASK_THREAD_ON_USTACK_OFFSET,r16 // A
+	mov r31=3Dpr				// I0   save pr (2 cyc)
+	;;
+	st1 [r16]=3Dr0				// M2|3 clear current->thread.on_ustack flag
+	addl r22=3DIA64_RBS_OFFSET,r2		// A    compute base of RBS
+	add r3=3DTI_FLAGS+IA64_TASK_SIZE,r2	// A
 	;;
-	ld4 r3=3D[r3]				// r2 =3D current_thread_info()->flags
-	lfetch.fault.excl.nt1 [r22]
+	ld4 r3=3D[r3]				// M0|1 r3 =3D current_thread_info()->flags
+	lfetch.fault.excl.nt1 [r22]		// M0|1 prefetch register backing-store
 	nop.i 0
 	;;
-	mov ar.rsc=3D0			// set enforced lazy mode, pl 0, little-endian, loadrs=
=3D0
+	mov ar.rsc=3D0				// M2   set enforced lazy mode, pl 0, LE, loadrs=3D0
 	nop.m 0
 	nop.i 0
 	;;
-	mov r23=3Dar.bspstore		// save ar.bspstore (12 cyc)
-	mov.m r24=3Dar.rnat		// read ar.rnat (5 cyc lat)
+	mov r23=3Dar.bspstore			// M2 (12 cyc) save ar.bspstore
+	mov.m r24=3Dar.rnat			// M2 (5 cyc) read ar.rnat (dual-issues!)
 	nop.i 0
 	;;
-	mov ar.bspstore=3Dr22		// switch to kernel RBS
+	mov ar.bspstore=3Dr22			// M2 (6 cyc) switch to kernel RBS
 	movl r8=3DPSR_ONE_BITS			// X
 	;;
-	mov r25=3Dar.unat			// save ar.unat (5 cyc)
-	mov r19=B6			// save b6 (2 cyc)
-	mov r20=3Dr1			// save caller's gp in r20
-	;;
-	or r29=3Dr8,r29			// construct cr.ipsr value to save
-	mov b6=3Dr18			// copy syscall entry-point to b6 (7 cyc)
-	addl r1=3DIA64_STK_OFFSET-IA64_PT_REGS_SIZE,r2	// compute base of memory =
stack
+	mov r25=3Dar.unat				// M2 (5 cyc) save ar.unat
+	mov r19=B6				// I0   save b6 (2 cyc)
+	mov r20=3Dr1				// A    save caller's gp in r20
+	;;
+	or r29=3Dr8,r29				// A    construct cr.ipsr value to save
+	mov b6=3Dr18				// I0   copy syscall entry-point to b6 (7 cyc)
+	addl r1=3DIA64_STK_OFFSET-IA64_PT_REGS_SIZE,r2 // A compute base of memor=
y stack
=20
-	mov r18=3Dar.bsp			// save (kernel) ar.bsp (12 cyc)
-	cmp.ne pKStk,pUStk=3Dr0,r0	// set pKStk <- 0, pUStk <- 1
-	br.call.sptk.many b7=3Dia64_syscall_setup
+	mov r18=3Dar.bsp				// M2   save (kernel) ar.bsp (12 cyc)
+	cmp.ne pKStk,pUStk=3Dr0,r0		// A    set pKStk <- 0, pUStk <- 1
+	br.call.sptk.many b7=3Dia64_syscall_setup	// B
 	;;
-	mov ar.rsc=3D0x3			// set eager mode, pl 0, little-endian, loadrs=3D0
-	mov rp=3Dr14				// set the real return addr
+	mov ar.rsc=3D0x3				// M2   set eager mode, pl 0, LE, loadrs=3D0
+	mov rp=3Dr14				// I0   set the real return addr
 	nop.i 0
 	;;
-	ssm psr.i
-	tbit.z p8,p0=3Dr3,TIF_SYSCALL_TRACE
-(p10)	br.cond.spnt.many ia64_ret_from_syscall	// p10=3Dtrue means out regi=
sters are more than 8
+	ssm psr.i				// M2   we're on kernel stacks now, reenable irqs
+	tbit.z p8,p0=3Dr3,TIF_SYSCALL_TRACE	// I0
+(p10)	br.cond.spnt.many ia64_ret_from_syscall	// B    return if bad call-f=
rame or r15 is a NaT
=20
 	nop.m 0
-(p8)	br.call.sptk.many b6=B6		// ignore this return addr
-	br.cond.spnt ia64_trace_syscall
+(p8)	br.call.sptk.many b6=B6			// B    (ignore return address)
+	br.cond.spnt ia64_trace_syscall		// B
 END(fsys_bubble_down)
=20
 	.rodata
