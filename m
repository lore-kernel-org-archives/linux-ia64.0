From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 24 Mar 2005 00:51:14 +0000
Subject: syscall improvement patch [8/12]
Message-Id: <200503240051.j2O0pEg1022304@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

ia64: Reschedule break_fault() for better performance.

This patch reorganizes break_fault() to optimistically assume that a
system-call is being performed from user-space (which is almost always
the case).  If it turns out that (a) we're not being called due to a
system call or (b) we're being called from within the kernel, we fixup
the no-longer-valid assumptions in non_syscall() and .break_fixup(),
respectively.

With this approach, there are 3 major phases:

 - Phase 1: Read various control & application registers, in
	    particular the current task pointer from AR.K6.
 - Phase 2: Do all memory loads (load system-call entry,
	    load current_thread_info()->flags, prefetch
	    kernel register-backing store) and switch
	    to kernel register-stack.
 - Phase 3: Call ia64_syscall_setup() and invoke
	    syscall-handler.

Good for 26-30 cycles of improvement on break-based syscall-path.

Signed-off-by: David Mosberger-Tang <davidm@hpl.hp.com>

diff -Nru a/arch/ia64/kernel/ivt.S b/arch/ia64/kernel/ivt.S
--- a/arch/ia64/kernel/ivt.S	2005-03-23 14:58:25 -08:00
+++ b/arch/ia64/kernel/ivt.S	2005-03-23 14:58:25 -08:00
@@ -687,82 +687,118 @@
 	 * to prevent leaking bits from kernel to user level.
 	 */
 	DBG_FAULT(11)
-	mov r16=3DIA64_KR(CURRENT)		// r16 =3D current task; 12 cycle read lat.
-	mov r17=3Dcr.iim
-	mov r18=3D__IA64_BREAK_SYSCALL
-	mov r21=3Dar.fpsr
-	mov r29=3Dcr.ipsr
-	mov r19=B6
-	mov r25=3Dar.unat
-	mov r27=3Dar.rsc
-	mov r26=3Dar.pfs
-	mov r28=3Dcr.iip
-	mov r31=3Dpr				// prepare to save predicates
-	mov r20=3Dr1
-	;;
+	mov.m r16=3DIA64_KR(CURRENT)		// M2 r16 <- current task (12 cyc)
+	mov r29=3Dcr.ipsr				// M2 (12 cyc)
+	mov r31=3Dpr				// I0 (2 cyc)
+
+	mov r17=3Dcr.iim				// M2 (2 cyc)
+	mov.m r27=3Dar.rsc			// M2 (12 cyc)
+	mov r18=3D__IA64_BREAK_SYSCALL		// A
+
+	mov.m ar.rsc=3D0				// M2
+	mov.m r21=3Dar.fpsr			// M2 (12 cyc)
+	mov r19=B6				// I0 (2 cyc)
+	;;
+	mov.m r23=3Dar.bspstore			// M2 (12 cyc)
+	mov.m r24=3Dar.rnat			// M2 (5 cyc)
+	mov.i r26=3Dar.pfs			// I0 (2 cyc)
+
+	invala					// M0|1
+	nop.m 0					// M
+	mov r20=3Dr1				// A			save r1
+
+	nop.m 0
+	movl r30=3Dsys_call_table			// X
+
+	mov r28=3Dcr.iip				// M2 (2 cyc)
+	cmp.eq p0,p7=3Dr18,r17			// I0 is this a system call?
+(p7)	br.cond.spnt non_syscall		// B  no ->
+	//
+	// From this point on, we are definitely on the syscall-path
+	// and we can use (non-banked) scratch registers.
+	//
+///////////////////////////////////////////////////////////////////////
+	mov r1=3Dr16				// A    move task-pointer to "addl"-addressable reg
+	mov r2=3Dr16				// A    setup r2 for ia64_syscall_setup
+	add r9=3DTI_FLAGS+IA64_TASK_SIZE,r16	// A	r9 =3D &current_thread_info()->=
flags
+
 	adds r16=3DIA64_TASK_THREAD_ON_USTACK_OFFSET,r16
-	cmp.eq p0,p7=3Dr18,r17			// is this a system call? (p7 <- false, if so)
-(p7)	br.cond.spnt non_syscall
+	adds r15=3D-1024,r15			// A    subtract 1024 from syscall number
+	mov r3=3DNR_syscalls - 1
 	;;
-	ld1 r17=3D[r16]				// load current->thread.on_ustack flag
-	st1 [r16]=3Dr0				// clear current->thread.on_ustack flag
-	add r1=3D-IA64_TASK_THREAD_ON_USTACK_OFFSET,r16	// set r1 for MINSTATE_ST=
ART_SAVE_MIN_VIRT
+	ld1.bias r17=3D[r16]			// M0|1 r17 =3D current->thread.on_ustack flag
+	ld4 r9=3D[r9]				// M0|1 r9 =3D current_thread_info()->flags
+	extr.u r8=3Dr29,41,2			// I0   extract ei field from cr.ipsr
+
+	shladd r30=3Dr15,3,r30			// A    r30 =3D sys_call_table + 8*(syscall-1024)
+	addl r22=3DIA64_RBS_OFFSET,r1		// A    compute base of RBS
+	cmp.leu p6,p7=3Dr15,r3			// A    syscall number in range?
 	;;
-	invala
=20
-	/* adjust return address so we skip over the break instruction: */
+	lfetch.fault.excl.nt1 [r22]		// M0|1 prefetch RBS
+(p6)	ld8 r30=3D[r30]				// M0|1 load address of syscall entry point
+	tnat.nz.or p7,p0=3Dr15			// I0	is syscall nr a NaT?
=20
-	extr.u r8=3Dr29,41,2			// extract ei field from cr.ipsr
-	;;
-	cmp.eq p6,p7=3D2,r8			// isr.ei=3D2?
-	mov r2=3Dr1				// setup r2 for ia64_syscall_setup
-	;;
-(p6)	mov r8=3D0				// clear ei to 0
-(p6)	adds r28=16,r28				// switch cr.iip to next bundle cr.ipsr.ei wrapped
-(p7)	adds r8=3D1,r8				// increment ei to next slot
-	;;
-	cmp.eq pKStk,pUStk=3Dr0,r17		// are we in kernel mode already?
-	dep r29=3Dr8,r29,41,2			// insert new ei into cr.ipsr
+	mov.m ar.bspstore=3Dr22			// M2   switch to kernel RBS
+	cmp.eq p8,p9=3D2,r8			// A    isr.ei=3D2?
 	;;
=20
-	// switch from user to kernel RBS:
-	MINSTATE_START_SAVE_MIN_VIRT
-	br.call.sptk.many b7=3Dia64_syscall_setup
-	;;
-	MINSTATE_END_SAVE_MIN_VIRT		// switch to bank 1
-	ssm psr.ic | PSR_DEFAULT_BITS
-	;;
-	srlz.i					// guarantee that interruption collection is on
-	mov r3=3DNR_syscalls - 1
-	;;
-(p15)	ssm psr.i				// restore psr.i
-	// p10=3Dtrue means out registers are more than 8 or r15's Nat is true
-(p10)	br.cond.spnt.many ia64_ret_from_syscall
-	;;
-	movl r16=3Dsys_call_table
+(p8)	mov r8=3D0				// A    clear ei to 0
+(p7)	movl r30=3Dsys_ni_syscall			// X
=20
-	adds r15=3D-1024,r15			// r15 contains the syscall number---subtract 1024
-	movl r2=3Dia64_ret_from_syscall
-	;;
-	shladd r20=3Dr15,3,r16			// r20 =3D sys_call_table + 8*(syscall-1024)
-	cmp.leu p6,p7=3Dr15,r3			// (syscall > 0 && syscall < 1024 + NR_syscalls)=
 ?
-	mov rp=3Dr2				// set the real return addr
+(p8)	adds r28=16,r28				// A    switch cr.iip to next bundle
+(p9)	adds r8=3D1,r8				// A    increment ei to next slot
+	nop.i 0
 	;;
-(p6)	ld8 r20=3D[r20]				// load address of syscall entry point
-(p7)	movl r20=3Dsys_ni_syscall
=20
-	add r2=3DTI_FLAGS+IA64_TASK_SIZE,r13
-	;;
-	ld4 r2=3D[r2]				// r2 =3D current_thread_info()->flags
-	;;
-	and r2=3D_TIF_SYSCALL_TRACEAUDIT,r2	// mask trace or audit
-	;;
-	cmp.eq p8,p0=3Dr2,r0
-	mov b6=3Dr20
-	;;
-(p8)	br.call.sptk.many b6=B6			// ignore this return addr
-	br.cond.sptk ia64_trace_syscall
+	mov.m r25=3Dar.unat			// M2 (5 cyc)
+	dep r29=3Dr8,r29,41,2			// I0   insert new ei into cr.ipsr
+	adds r15=1024,r15			// A    restore original syscall number
+	//
+	// If any of the above loads miss in L1D, we'll stall here until
+	// the data arrives.
+	//
+///////////////////////////////////////////////////////////////////////
+	st1 [r16]=3Dr0				// M2|3 clear current->thread.on_ustack flag
+	mov b6=3Dr30				// I0   setup syscall handler branch reg early
+	cmp.eq pKStk,pUStk=3Dr0,r17		// A    were we on kernel stacks already?
+
+	and r9=3D_TIF_SYSCALL_TRACEAUDIT,r9	// A    mask trace or audit
+	mov r18=3Dar.bsp				// M2 (12 cyc)
+(pKStk)	br.cond.spnt .break_fixup		// B	we're already in kernel-mode -- fi=
x up RBS
+	;;
+.back_from_break_fixup:
+(pUStk)	addl r1=3DIA64_STK_OFFSET-IA64_PT_REGS_SIZE,r1 // A    compute bas=
e of memory stack
+	cmp.eq p14,p0=3Dr9,r0			// A    are syscalls being traced/audited?
+	br.call.sptk.many b7=3Dia64_syscall_setup	// B
+1:
+	mov ar.rsc=3D0x3				// M2   set eager mode, pl 0, LE, loadrs=3D0
+	nop 0
+	bsw.1					// B (6 cyc) regs are saved, switch to bank 1
+	;;
+
+	ssm psr.ic | PSR_DEFAULT_BITS		// M2	now it's safe to re-enable intr.-col=
lection
+	movl r3=3Dia64_ret_from_syscall		// X
+	;;
+
+	srlz.i					// M0   ensure interruption collection is on
+	mov rp=3Dr3				// I0   set the real return addr
+(p10)	br.cond.spnt.many ia64_ret_from_syscall	// B    return if bad call-f=
rame or r15 is a NaT
+
+(p15)	ssm psr.i				// M2   restore psr.i
+(p14)	br.call.sptk.many b6=B6			// B    invoke syscall-handker (ignore ret=
urn addr)
+	br.cond.spnt.many ia64_trace_syscall	// B	do syscall-tracing thingamagic
 	// NOT REACHED
+///////////////////////////////////////////////////////////////////////
+	// On entry, we optimistically assumed that we're coming from user-space.
+	// For the rare cases where a system-call is done from within the kernel,
+	// we fix things up at this point:
+.break_fixup:
+	add r1=3D-IA64_PT_REGS_SIZE,sp		// A    allocate space for pt_regs struct=
ure
+	mov ar.rnat=3Dr24				// M2	restore kernel's AR.RNAT
+	;;
+	mov ar.bspstore=3Dr23			// M2	restore kernel's AR.BSPSTORE
+	br.cond.sptk .back_from_break_fixup
 END(break_fault)
=20
 	.org ia64_ivt+0x3000
@@ -837,8 +873,6 @@
 	 *	- r31: saved pr
 	 *	-  b0: original contents (to be saved)
 	 * On exit:
-	 *	- executing on bank 1 registers
-	 *	- psr.ic enabled, interrupts restored
 	 *	-  p10: TRUE if syscall is invoked with more than 8 out
 	 *		registers or r15's Nat is true
 	 *	-  r1: kernel's gp
@@ -846,8 +880,11 @@
 	 *	-  r8: -EINVAL if p10 is true
 	 *	- r12: points to kernel stack
 	 *	- r13: points to current task
+	 *	- r14: preserved (same as on entry)
+	 *	- p13: preserved
 	 *	- p15: TRUE if interrupts need to be re-enabled
 	 *	- ar.fpsr: set to kernel settings
+	 *	-  b6: preserved (same as on entry)
 	 */
 GLOBAL_ENTRY(ia64_syscall_setup)
 #if PT(B6) !=3D 0
@@ -915,7 +952,7 @@
 (p13)	mov in5=3D-1
 	;;
 	st8 [r16]=3Dr21,PT(R8)-PT(AR_FPSR)	// save ar.fpsr
-	tnat.nz p14,p0=3Din6
+	tnat.nz p13,p0=3Din6
 	cmp.lt p10,p9=3Dr11,r8	// frame size can't be more than local+8
 	;;
 	mov r8=3D1
@@ -930,7 +967,7 @@
 	movl r1=3D__gp				// establish kernel global pointer
 	;;
 	st8 [r16]=3Dr8		// ensure pt_regs.r8 !=3D 0 (see handle_syscall_error)
-(p14)	mov in6=3D-1
+(p13)	mov in6=3D-1
 (p8)	mov in7=3D-1
=20
 	cmp.eq pSys,pNonSys=3Dr0,r0		// set pSys=3D1, pNonSys=3D0
@@ -999,6 +1036,8 @@
 	FAULT(17)
=20
 ENTRY(non_syscall)
+	mov ar.rsc=3Dr27			// restore ar.rsc before SAVE_MIN_WITH_COVER
+	;;
 	SAVE_MIN_WITH_COVER
=20
 	// There is no particular reason for this code to be here, other than that
