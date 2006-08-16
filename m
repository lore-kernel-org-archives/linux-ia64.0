From: Al Stone <ahs3@fc.hp.com>
Date: Wed, 16 Aug 2006 20:59:38 +0000
Subject: [PATCH] 80-column cleanup for entry.S
Message-Id: <1155761979.24946.11.camel@fcboson.fc.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

This patch reformats entry.S so it is usable on 80-column
displays, in accordance with Linux coding style.  There are
a couple of typo repairs, as well.


Signed-of-by: Al Stone <ahs3@fc.hp.com>


diff --git a/arch/ia64/kernel/entry.S b/arch/ia64/kernel/entry.S
index 12701cf..b5eb2ed 100644
--- a/arch/ia64/kernel/entry.S
+++ b/arch/ia64/kernel/entry.S
@@ -66,8 +66,8 @@ ENTRY(ia64_execve)
 .ret0:
 #ifdef CONFIG_IA32_SUPPORT
 	/*
-	 * Check if we're returning to ia32 mode. If so, we need to restore ia32 =
registers
-	 * from pt_regs.
+	 * Check if we're returning to ia32 mode. If so, we need to restore
+	 * ia32 registers from pt_regs.
 	 */
 	adds r16=3DPT(CR_IPSR)+16,sp
 	;;
@@ -78,16 +78,17 @@ #endif
 	sxt4 r8=3Dr8			// return 64-bit result
 	;;
 	stf.spill [sp]=F0
-(p6)	cmp.ne pKStk,pUStk=3Dr0,r0	// a successful execve() lands us in user-=
mode...
+(p6)	cmp.ne pKStk,pUStk=3Dr0,r0	// a successful execve() lands us=20
+					//   in user-mode...
 	mov rp=3Dloc0
 (p6)	mov ar.pfs=3Dr0			// clear ar.pfs on success
 (p7)	br.ret.sptk.many rp
=20
 	/*
 	 * In theory, we'd have to zap this state only to prevent leaking of
-	 * security sensitive state (e.g., if current->mm->dumpable is zero).  Ho=
wever,
-	 * this executes in less than 20 cycles even on Itanium, so it's not worth
-	 * optimizing for...).
+	 * security sensitive state (e.g., if current->mm->dumpable is zero).
+	 * However, this executes in less than 20 cycles even on Itanium, so
+	 * it's not worth optimizing for...).
 	 */
 	mov ar.unat=3D0; 		mov ar.lc=3D0
 	mov r4=3D0;		mov f2=F0;		mov b1=3Dr0
@@ -111,8 +112,8 @@ #endif
 END(ia64_execve)
=20
 /*
- * sys_clone2(u64 flags, u64 ustack_base, u64 ustack_size, u64 parent_tidp=
tr, u64 child_tidptr,
- *	      u64 tls)
+ * sys_clone2(u64 flags, u64 ustack_base, u64 ustack_size, u64 parent_tidp=
tr,
+ *            u64 child_tidptr, u64 tls)
  */
 GLOBAL_ENTRY(sys_clone2)
 	/*
@@ -123,15 +124,18 @@ GLOBAL_ENTRY(sys_clone2)
 	DO_SAVE_SWITCH_STACK
 	adds r2=3DPT(R16)+IA64_SWITCH_STACK_SIZE+16,sp
 	mov loc0=3Drp
-	mov loc1=3Dr16				// save ar.pfs across do_fork
+	mov loc1=3Dr16			// save ar.pfs across do_fork
 	.body
 	mov out1=3Din1
 	mov out3=3Din2
 	tbit.nz p6,p0=3Din0,CLONE_SETTLS_BIT
-	mov out4=3Din3	// parent_tidptr: valid only w/CLONE_PARENT_SETTID
+	mov out4=3Din3			// parent_tidptr: valid only with
+					//   CLONE_PARENT_SETTID
 	;;
-(p6)	st8 [r2]=3Din5				// store TLS in r16 for copy_thread()
-	mov out5=3Din4	// child_tidptr:  valid only w/CLONE_CHILD_SETTID or CLONE=
_CHILD_CLEARTID
+(p6)	st8 [r2]=3Din5			// store TLS in r16 for copy_thread()
+	mov out5=3Din4			// child_tidptr:  valid only with
+					//   CLONE_CHILD_SETTID or=20
+					//   CLONE_CHILD_CLEARTID
 	adds out2=3DIA64_SWITCH_STACK_SIZE+16,sp	// out2 =3D &regs
 	mov out0=3Din0				// out0 =3D clone_flags
 	br.call.sptk.many rp=3Ddo_fork
@@ -143,7 +147,8 @@ (p6)	st8 [r2]=3Din5				// store TLS in r16
 END(sys_clone2)
=20
 /*
- * sys_clone(u64 flags, u64 ustack_base, u64 parent_tidptr, u64 child_tidp=
tr, u64 tls)
+ * sys_clone(u64 flags, u64 ustack_base, u64 parent_tidptr, u64 child_tidp=
tr,
+ *           u64 tls)
  *	Deprecated.  Use sys_clone2() instead.
  */
 GLOBAL_ENTRY(sys_clone)
@@ -158,12 +163,16 @@ GLOBAL_ENTRY(sys_clone)
 	mov loc1=3Dr16				// save ar.pfs across do_fork
 	.body
 	mov out1=3Din1
-	mov out3=16				// stacksize (compensates for 16-byte scratch area)
+	mov out3=16				// stacksize (compensates for
+						//   16-byte scratch area)
 	tbit.nz p6,p0=3Din0,CLONE_SETTLS_BIT
-	mov out4=3Din2	// parent_tidptr: valid only w/CLONE_PARENT_SETTID
+	mov out4=3Din2				// parent_tidptr: valid only
+						//   w/CLONE_PARENT_SETTID
 	;;
 (p6)	st8 [r2]=3Din4				// store TLS in r13 (tp)
-	mov out5=3Din3	// child_tidptr:  valid only w/CLONE_CHILD_SETTID or CLONE=
_CHILD_CLEARTID
+	mov out5=3Din3				// child_tidptr:  valid only
+						//   w/CLONE_CHILD_SETTID or
+						//   CLONE_CHILD_CLEARTID
 	adds out2=3DIA64_SWITCH_STACK_SIZE+16,sp	// out2 =3D &regs
 	mov out0=3Din0				// out0 =3D clone_flags
 	br.call.sptk.many rp=3Ddo_fork
@@ -176,9 +185,9 @@ END(sys_clone)
=20
 /*
  * prev_task <- ia64_switch_to(struct task_struct *next)
- *	With Ingo's new scheduler, interrupts are disabled when this routine ge=
ts
- *	called.  The code starting at .map relies on this.  The rest of the code
- *	doesn't care about the interrupt masking status.
+ *	With Ingo's new scheduler, interrupts are disabled when this routine
+ *	gets called.  The code starting at .map relies on this.  The rest of
+ *	the code doesn't care about the interrupt masking status.
  */
 GLOBAL_ENTRY(ia64_switch_to)
 	.prologue
@@ -190,33 +199,40 @@ GLOBAL_ENTRY(ia64_switch_to)
 	movl r25=3Dinit_task
 	mov r27=3DIA64_KR(CURRENT_STACK)
 	adds r21=3DIA64_TASK_THREAD_KSP_OFFSET,in0
-	dep r20=3D0,in0,61,3		// physical address of "next"
+	dep r20=3D0,in0,61,3			// physical address of "next"
 	;;
-	st8 [r22]=3Dsp			// save kernel stack pointer of old task
+	st8 [r22]=3Dsp				// save kernel stack pointer=20
+						//   of old task
 	shr.u r26=3Dr20,IA64_GRANULE_SHIFT
 	cmp.eq p7,p6=3Dr25,in0
 	;;
 	/*
-	 * If we've already mapped this task's page, we can skip doing it again.
+	 * If we've already mapped this task's page, we can skip doing it
+	 * again.
 	 */
 (p6)	cmp.eq p7,p6=3Dr26,r27
 (p6)	br.cond.dpnt .map
 	;;
 .done:
-	ld8 sp=3D[r21]			// load kernel stack pointer of new task
-	mov IA64_KR(CURRENT)=3Din0	// update "current" application register
-	mov r8=3Dr13			// return pointer to previously running task
+	ld8 sp=3D[r21]			// load kernel stack pointer of=20
+					//   new task
+	mov IA64_KR(CURRENT)=3Din0	// update "current" application
+					//   register
+	mov r8=3Dr13			// return pointer to previously
+					//   running task
 	mov r13=3Din0			// set "current" pointer
 	;;
 	DO_LOAD_SWITCH_STACK
=20
 #ifdef CONFIG_SMP
-	sync.i				// ensure "fc"s done by this CPU are visible on other CPUs
+	sync.i				// ensure "fc"s done by this CPU are
+					//   visible on other CPUs
 #endif
 	br.ret.sptk.many rp		// boogie on out in new context
=20
 .map:
-	rsm psr.ic			// interrupts (psr.i) are already disabled here
+	rsm psr.ic			// interrupts (psr.i) are already
+					//   disabled here
 	movl r25=3DPAGE_KERNEL
 	;;
 	srlz.d
@@ -237,13 +253,14 @@ #endif
 END(ia64_switch_to)
=20
 /*
- * Note that interrupts are enabled during save_switch_stack and load_swit=
ch_stack.  This
- * means that we may get an interrupt with "sp" pointing to the new kernel=
 stack while
- * ar.bspstore is still pointing to the old kernel backing store area.  Si=
nce ar.rsc,
- * ar.rnat, ar.bsp, and ar.bspstore are all preserved by interrupts, this =
is not a
- * problem.  Also, we don't need to specify unwind information for preserv=
ed registers
- * that are not modified in save_switch_stack as the right unwind informat=
ion is already
- * specified at the call-site of save_switch_stack.
+ * Note that interrupts are enabled during save_switch_stack and=20
+ * load_switch_stack.  This means that we may get an interrupt with "sp"
+ * pointing to the new kernel stack while ar.bspstore is still pointing=20
+ * to the old kernel backing store area.  Since ar.rsc, ar.rnat, ar.bsp,
+ * and ar.bspstore are all preserved by interrupts, this is not a problem.
+ * Also, we don't need to specify unwind information for preserved registe=
rs
+ * that are not modified in save_switch_stack as the right unwind informat=
ion
+ * is already specified at the call-site of save_switch_stack.
  */
=20
 /*
@@ -255,7 +272,8 @@ END(ia64_switch_to)
 GLOBAL_ENTRY(save_switch_stack)
 	.prologue
 	.altrp b7
-	flushrs			// flush dirty regs to backing store (must be first in insn gro=
up)
+	flushrs			// flush dirty regs to backing store (must
+				//   be first in insn group)
 	.save @priunat,r17
 	mov r17=3Dar.unat		// preserve caller's
 	.body
@@ -264,7 +282,7 @@ #ifdef CONFIG_ITANIUM
 	adds r3=16+64,sp
 	adds r14=3DSW(R4)+16,sp
 	;;
-	st8.spill [r14]=3Dr4,16		// spill r4
+	st8.spill [r14]=3Dr4,16			// spill r4
 	lfetch.fault.excl.nt1 [r3],128
 	;;
 	lfetch.fault.excl.nt1 [r2],128
@@ -278,24 +296,26 @@ #else
 	add r3=16,sp
 	add r14=3DSW(R4)+16,sp
 	;;
-	st8.spill [r14]=3Dr4,SW(R6)-SW(R4)	// spill r4 and prefetch offset 0x1c0
-	lfetch.fault.excl.nt1 [r3],128	//		prefetch offset 0x010
+	st8.spill [r14]=3Dr4,SW(R6)-SW(R4)	// spill r4 and prefetch
+						//   offset 0x1c0
+	lfetch.fault.excl.nt1 [r3],128		// prefetch offset 0x010
 	;;
-	lfetch.fault.excl.nt1 [r3],128	//		prefetch offset 0x090
-	lfetch.fault.excl.nt1 [r2],128	//		prefetch offset 0x190
+	lfetch.fault.excl.nt1 [r3],128		// prefetch offset 0x090
+	lfetch.fault.excl.nt1 [r2],128		// prefetch offset 0x190
 	;;
-	lfetch.fault.excl.nt1 [r3]	//		prefetch offset 0x110
-	lfetch.fault.excl.nt1 [r2]	//		prefetch offset 0x210
+	lfetch.fault.excl.nt1 [r3]		// prefetch offset 0x110
+	lfetch.fault.excl.nt1 [r2]		// prefetch offset 0x210
 	adds r15=3DSW(R5)+16,sp
 #endif
 	;;
 	st8.spill [r15]=3Dr5,SW(R7)-SW(R5)	// spill r5
-	mov.m ar.rsc=3D0			// put RSE in mode: enforced lazy, little endian, pl 0
-	add r2=3DSW(F2)+16,sp		// r2 =3D &sw->f2
+	mov.m ar.rsc=3D0				// put RSE in mode: enforced
+						//   lazy, little endian, pl 0
+	add r2=3DSW(F2)+16,sp			// r2 =3D &sw->f2
 	;;
 	st8.spill [r14]=3Dr6,SW(B0)-SW(R6)	// spill r6
-	mov.m r18=3Dar.fpsr		// preserve fpsr
-	add r3=3DSW(F3)+16,sp		// r3 =3D &sw->f3
+	mov.m r18=3Dar.fpsr			// preserve fpsr
+	add r3=3DSW(F3)+16,sp			// r3 =3D &sw->f3
 	;;
 	stf.spill [r2]=F2,32
 	mov.m r19=3Dar.rnat
@@ -365,7 +385,8 @@ #endif
 	;;
 	st8 [r2]=3Dr20				// save ar.bspstore
 	st8 [r14]=3Dr18				// save fpsr
-	mov ar.rsc=3D3		// put RSE back into eager mode, pl 0
+	mov ar.rsc=3D3				// put RSE back into eager=20
+						//   mode, pl 0
 	br.cond.sptk.many b7
 END(save_switch_stack)
=20
@@ -383,30 +404,31 @@ ENTRY(load_switch_stack)
 	lfetch.fault.nt1 [sp]
 	adds r2=3DSW(AR_BSPSTORE)+16,sp
 	adds r3=3DSW(AR_UNAT)+16,sp
-	mov ar.rsc=3D0						// put RSE into enforced lazy mode
+	mov ar.rsc=3D0				// put RSE into enforced=20
+						//   lazy mode
 	adds r14=3DSW(CALLER_UNAT)+16,sp
 	adds r15=3DSW(AR_FPSR)+16,sp
 	;;
 	ld8 r27=3D[r2],(SW(B0)-SW(AR_BSPSTORE))	// bspstore
 	ld8 r29=3D[r3],(SW(B1)-SW(AR_UNAT))	// unat
 	;;
-	ld8 r21=3D[r2],16		// restore b0
-	ld8 r22=3D[r3],16		// restore b1
+	ld8 r21=3D[r2],16				// restore b0
+	ld8 r22=3D[r3],16				// restore b1
 	;;
-	ld8 r23=3D[r2],16		// restore b2
-	ld8 r24=3D[r3],16		// restore b3
+	ld8 r23=3D[r2],16				// restore b2
+	ld8 r24=3D[r3],16				// restore b3
 	;;
-	ld8 r25=3D[r2],16		// restore b4
-	ld8 r26=3D[r3],16		// restore b5
+	ld8 r25=3D[r2],16				// restore b4
+	ld8 r26=3D[r3],16				// restore b5
 	;;
 	ld8 r16=3D[r2],(SW(PR)-SW(AR_PFS))	// ar.pfs
 	ld8 r17=3D[r3],(SW(AR_RNAT)-SW(AR_LC))	// ar.lc
 	;;
-	ld8 r28=3D[r2]		// restore pr
-	ld8 r30=3D[r3]		// restore rnat
+	ld8 r28=3D[r2]				// restore pr
+	ld8 r30=3D[r3]				// restore rnat
 	;;
-	ld8 r18=3D[r14],16	// restore caller's unat
-	ld8 r19=3D[r15],24	// restore fpsr
+	ld8 r18=3D[r14],16			// restore caller's unat
+	ld8 r19=3D[r15],24			// restore fpsr
 	;;
 	ldf.fill f2=3D[r14],32
 	ldf.fill f3=3D[r15],32
@@ -436,7 +458,8 @@ ENTRY(load_switch_stack)
 	mov b2=3Dr23
 	;;
 	mov ar.bspstore=3Dr27
-	mov ar.unat=3Dr29		// establish unat holding the NaT bits for r4-r7
+	mov ar.unat=3Dr29			// establish unat holding the NaT
+					//   bits for r4-r7
 	mov b3=3Dr24
 	;;
 	ldf.fill f24=3D[r14],32
@@ -463,9 +486,11 @@ ENTRY(load_switch_stack)
 	ld8.fill r7=3D[r15],16
=20
 	mov ar.unat=3Dr18				// restore caller's unat
-	mov ar.rnat=3Dr30				// must restore after bspstore but before rsc!
+	mov ar.rnat=3Dr30				// must restore after bspstore
+						//   but before rsc!
 	mov ar.fpsr=3Dr19				// restore fpsr
-	mov ar.rsc=3D3				// put RSE back into eager mode, pl 0
+	mov ar.rsc=3D3				// put RSE back into eager=20
+						//   mode, pl 0
 	br.cond.sptk.many b7
 END(load_switch_stack)
=20
@@ -527,7 +552,8 @@ GLOBAL_ENTRY(ia64_trace_syscall)
 	;;
  	stf.spill [r16]=F10
  	stf.spill [r17]=F11
-	br.call.sptk.many rp=3Dsyscall_trace_enter // give parent a chance to cat=
ch syscall args
+	br.call.sptk.many rp=3Dsyscall_trace_enter // give parent a chance to=20
+						 //   catch syscall args
 	adds r16=3DPT(F6)+16,sp
 	adds r17=3DPT(F7)+16,sp
 	;;
@@ -539,9 +565,9 @@ GLOBAL_ENTRY(ia64_trace_syscall)
 	;;
 	ldf.fill f10=3D[r16]
 	ldf.fill f11=3D[r17]
-	// the syscall number may have changed, so re-load it and re-calculate the
-	// syscall entry-point:
-	adds r15=3DPT(R15)+16,sp			// r15 =3D &pt_regs.r15 (syscall #)
+	// the syscall number may have changed, so re-load it and re-calculate
+	// the syscall entry-point:
+	adds r15=3DPT(R15)+16,sp			// r15 =3D &pt_regs.r15 (syscall#)
 	;;
 	ld8 r15=3D[r15]
 	mov r3=3DNR_syscalls - 1
@@ -549,10 +575,12 @@ GLOBAL_ENTRY(ia64_trace_syscall)
 	adds r15=3D-1024,r15
 	movl r16=3Dsys_call_table
 	;;
-	shladd r20=3Dr15,3,r16			// r20 =3D sys_call_table + 8*(syscall-1024)
+	shladd r20=3Dr15,3,r16			// r20 =3D sys_call_table +=20
+						//       8*(syscall-1024)
 	cmp.leu p6,p7=3Dr15,r3
 	;;
-(p6)	ld8 r20=3D[r20]				// load address of syscall entry point
+(p6)	ld8 r20=3D[r20]				// load address of syscall
+						//   entry point
 (p7)	movl r20=3Dsys_ni_syscall
 	;;
 	mov b6=3Dr20
@@ -565,16 +593,20 @@ (p7)	movl r20=3Dsys_ni_syscall
 (p6)	br.cond.sptk strace_error		// syscall failed ->
 	;;					// avoid RAW on r10
 .strace_save_retval:
-.mem.offset 0,0; st8.spill [r2]=3Dr8		// store return value in slot for r8
-.mem.offset 8,0; st8.spill [r3]=3Dr10		// clear error indication in slot f=
or r10
-	br.call.sptk.many rp=3Dsyscall_trace_leave // give parent a chance to cat=
ch return value
+.mem.offset 0,0; st8.spill [r2]=3Dr8		// store return value in slot
+						//   for r8
+.mem.offset 8,0; st8.spill [r3]=3Dr10		// clear error indication in
+						//   slot for r10
+	br.call.sptk.many rp=3Dsyscall_trace_leave // give parent a chance to
+						 //   catch return value
 .ret3:
 (pUStk)	cmp.eq.unc p6,p0=3Dr0,r0			// p6 <- pUStk
 	br.cond.sptk .work_pending_syscall_end
=20
 strace_error:
 	ld8 r3=3D[r2]				// load pt_regs.r8
-	sub r9=3D0,r8				// negate return value to get errno value
+	sub r9=3D0,r8				// negate return value to get
+						//   errno value
 	;;
 	cmp.ne p6,p0=3Dr3,r0			// is pt_regs.r8!=3D0?
 	adds r3=16,r2				// r3=3D&pt_regs.r10
@@ -585,18 +617,21 @@ (p6)	mov r8=3Dr9
 END(ia64_trace_syscall)
=20
 	/*
-	 * When traced and returning from sigreturn, we invoke syscall_trace but =
then
-	 * go straight to ia64_leave_kernel rather than ia64_leave_syscall.
+	 * When traced and returning from sigreturn, we invoke syscall_trace
+	 * but then go straight to ia64_leave_kernel rather than=20
+	 * ia64_leave_syscall.
 	 */
 GLOBAL_ENTRY(ia64_strace_leave_kernel)
 	PT_REGS_UNWIND_INFO(0)
 {	/*
-	 * Some versions of gas generate bad unwind info if the first instruction=
 of a
-	 * procedure doesn't go into the first slot of a bundle.  This is a worka=
round.
+	 * Some versions of gas generate bad unwind info if the first=20
+	 * instruction of a procedure doesn't go into the first slot of
+	 * a bundle.  This is a workaround.
 	 */
 	nop.m 0
 	nop.i 0
-	br.call.sptk.many rp=3Dsyscall_trace_leave // give parent a chance to cat=
ch return value
+	br.call.sptk.many rp=3Dsyscall_trace_leave // give parent a chance to
+						 //   catch return value
 }
 .ret4:	br.cond.sptk ia64_leave_kernel
 END(ia64_strace_leave_kernel)
@@ -604,15 +639,16 @@ END(ia64_strace_leave_kernel)
 GLOBAL_ENTRY(ia64_ret_from_clone)
 	PT_REGS_UNWIND_INFO(0)
 {	/*
-	 * Some versions of gas generate bad unwind info if the first instruction=
 of a
-	 * procedure doesn't go into the first slot of a bundle.  This is a worka=
round.
+	 * Some versions of gas generate bad unwind info if the first
+	 * instruction of a procedure doesn't go into the first slot of
+	 * a bundle.  This is a workaround.
 	 */
 	nop.m 0
 	nop.i 0
 	/*
-	 * We need to call schedule_tail() to complete the scheduling process.
-	 * Called by ia64_switch_to() after do_fork()->copy_thread().  r8 contain=
s the
-	 * address of the previously executing task.
+	 * We need to call schedule_tail() to complete the scheduling
+	 * process.  Called by ia64_switch_to() after do_fork()->copy_thread().
+	 * Register r8 contains the address of the previously executing task.
 	 */
 	br.call.sptk.many rp=3Dia64_invoke_schedule_tail
 }
@@ -626,15 +662,19 @@ GLOBAL_ENTRY(ia64_ret_from_clone)
 	;;
 	cmp.ne p6,p0=3Dr2,r0
 (p6)	br.cond.spnt .strace_check_retval
-	;;					// added stop bits to prevent r8 dependency
+	;;					// added stop bits to prevent
+						//   r8 dependency
 END(ia64_ret_from_clone)
 	// fall through
 GLOBAL_ENTRY(ia64_ret_from_syscall)
 	PT_REGS_UNWIND_INFO(0)
-	cmp.ge p6,p7=3Dr8,r0			// syscall executed successfully?
+	cmp.ge p6,p7=3Dr8,r0			// did syscall execute
+						//   successfully?
 	adds r2=3DPT(R8)+16,sp			// r2 =3D &pt_regs.r8
-	mov r10=3Dr0				// clear error indication in r10
-(p7)	br.cond.spnt handle_syscall_error	// handle potential syscall failure
+	mov r10=3Dr0				// clear error indication is
+						//   in r10
+(p7)	br.cond.spnt handle_syscall_error	// handle potential syscall
+						//   failure
 END(ia64_ret_from_syscall)
 	// fall through
 /*
@@ -684,14 +724,16 @@ END(ia64_ret_from_syscall)
 ENTRY(ia64_leave_syscall)
 	PT_REGS_UNWIND_INFO(0)
 	/*
-	 * work.need_resched etc. mustn't get changed by this CPU before it retur=
ns to
-	 * user- or fsys-mode, hence we disable interrupts early on.
+	 * work.need_resched etc. mustn't get changed by this CPU before
+	 * it returns to user- or fsys-mode, hence we disable interrupts
+	 * early on.
 	 *
-	 * p6 controls whether current_thread_info()->flags needs to be check for
-	 * extra work.  We always check for extra work when returning to user-lev=
el.
-	 * With CONFIG_PREEMPT, we also check for extra work when the preempt_cou=
nt
-	 * is 0.  After extra work processing has been completed, execution
-	 * resumes at .work_processed_syscall with p6 set to 1 if the extra-work-=
check
+	 * p6 controls whether current_thread_info()->flags needs to be=20
+	 * checked for extra work.  We always check for extra work when=20
+	 * returning to user-level.  With CONFIG_PREEMPT, we also check=20
+	 * for extra work when the preempt_count is 0.  After extra work
+	 * processing has been completed, execution resumes at=20
+	 * .work_processed_syscall with p6 set to 1 if the extra-work-check
 	 * needs to be redone.
 	 */
 #ifdef CONFIG_PREEMPT
@@ -714,26 +756,33 @@ #endif
 	adds r3=3DPT(AR_BSPSTORE)+16,r12
 	adds r18=3DTI_FLAGS+IA64_TASK_SIZE,r13
 	;;
-(p6)	ld4 r31=3D[r18]				// load current_thread_info()->flags
-	ld8 r19=3D[r2],PT(B6)-PT(LOADRS)		// load ar.rsc value for "loadrs"
+(p6)	ld4 r31=3D[r18]			// load current_thread_info()->flags
+	ld8 r19=3D[r2],PT(B6)-PT(LOADRS)	// load ar.rsc value for "loadrs"
 	nop.i 0
 	;;
-	mov r16=3Dar.bsp				// M2  get existing backing store pointer
-	ld8 r18=3D[r2],PT(R9)-PT(B6)		// load b6
-(p6)	and r15=3DTIF_WORK_MASK,r31		// any work other than TIF_SYSCALL_TRACE?
+	mov r16=3Dar.bsp			// M2 get existing backing store=20
+					//   pointer
+	ld8 r18=3D[r2],PT(R9)-PT(B6)	// load b6
+(p6)	and r15=3DTIF_WORK_MASK,r31	// any work other than=20
+					//   TIF_SYSCALL_TRACE?
 	;;
-	ld8 r23=3D[r3],PT(R11)-PT(AR_BSPSTORE)	// load ar.bspstore (may be garbag=
e)
+	ld8 r23=3D[r3],PT(R11)-PT(AR_BSPSTORE)	// load ar.bspstore (may be
+						//   garbage)
 (p6)	cmp4.ne.unc p6,p0=3Dr15, r0		// any special work pending?
 (p6)	br.cond.spnt .work_pending_syscall
 	;;
-	// start restoring the state saved on the kernel stack (struct pt_regs):
+	// start restoring the state saved on the kernel stack
+	// (struct pt_regs):
 	ld8 r9=3D[r2],PT(CR_IPSR)-PT(R9)
 	ld8 r11=3D[r3],PT(CR_IIP)-PT(R11)
-(pNonSys) break 0		//      bug check: we shouldn't be here if pNonSys is T=
RUE!
+(pNonSys) break 0		// bug check: we shouldn't be here if pNonSys
+				//   is TRUE!
 	;;
 	invala			// M0|1 invalidate ALAT
-	rsm psr.i | psr.ic	// M2   turn off interrupts and interruption collection
-	cmp.eq p9,p0=3Dr0,r0	// A    set p9 to indicate that we should restore cr=
.ifs
+	rsm psr.i | psr.ic	// M2   turn off interrupts and interruption
+				//      collection
+	cmp.eq p9,p0=3Dr0,r0	// A    set p9 to indicate that we should
+				//      restore cr.ifs
=20
 	ld8 r29=3D[r2],16		// M0|1 load cr.ipsr
 	ld8 r28=3D[r3],16		// M0|1 load cr.iip
@@ -744,14 +793,16 @@ (pNonSys) break 0		//      bug check: we
 (pUStk) add r14=3DIA64_TASK_THREAD_ON_USTACK_OFFSET,r13
 	;;
 	ld8 r26=3D[r2],PT(B0)-PT(AR_PFS)	// M0|1 load ar.pfs
-(pKStk)	mov r22=3Dpsr			// M2   read PSR now that interrupts are disabled
+(pKStk)	mov r22=3Dpsr			// M2   read PSR now that interrupts
+					//      are disabled
 	nop 0
 	;;
 	ld8 r21=3D[r2],PT(AR_RNAT)-PT(B0) // M0|1 load b0
 	ld8 r27=3D[r3],PT(PR)-PT(AR_RSC)	// M0|1 load ar.rsc
 	mov f6=F0			// F    clear f6
 	;;
-	ld8 r24=3D[r2],PT(AR_FPSR)-PT(AR_RNAT)	// M0|1 load ar.rnat (may be garba=
ge)
+	ld8 r24=3D[r2],PT(AR_FPSR)-PT(AR_RNAT)	// M0|1 load ar.rnat (may be
+						//      garbage)
 	ld8 r31=3D[r3],PT(R1)-PT(PR)		// M0|1 load predicates
 	mov f7=F0				// F    clear f7
 	;;
@@ -771,11 +822,15 @@ (pUStk) st1 [r14]=3Dr17				// M2|3
 	mov f9=F0					// F    clear f9
 (pKStk) br.cond.dpnt.many skip_rbs_switch		// B
=20
-	srlz.d				// M0   ensure interruption collection is off (for cover)
-	shr.u r18=3Dr19,16		// I0|1 get byte size of existing "dirty" partition
-	cover				// B    add current frame into dirty partition & set cr.ifs
-	;;
-(pUStk) ld4 r17=3D[r17]			// M0|1 r17 =3D cpu_data->phys_stacked_size_p8
+	srlz.d				// M0   ensure interruption collection
+					//	is off (for cover)
+	shr.u r18=3Dr19,16		// I0|1 get byte size of existing=20
+					//	"dirty" partition
+	cover				// B    add current frame into dirty
+					//	partition & set cr.ifs
+	;;
+(pUStk) ld4 r17=3D[r17]			// M0|1 r17 =3D cpu_data->
+					//	      phys_stacked_size_p8
 	mov r19=3Dar.bsp			// M2   get new backing store pointer
 	mov f10=F0			// F    clear f10
=20
@@ -784,7 +839,8 @@ (pUStk) ld4 r17=3D[r17]			// M0|1 r17 =3D cp
 	;;
 	mov.m ar.csd=3Dr0			// M2   clear ar.csd
 	mov.m ar.ccv=3Dr0			// M2   clear ar.ccv
-	mov b7=3Dr14			// I0   clear b7 (hint with __kernel_syscall_via_epc)
+	mov b7=3Dr14			// I0   clear b7 (hint with=20
+					//	__kernel_syscall_via_epc)
=20
 	mov.m ar.ssd=3Dr0			// M2   clear ar.ssd
 	mov f11=F0			// F    clear f11
@@ -794,27 +850,31 @@ END(ia64_leave_syscall)
 #ifdef CONFIG_IA32_SUPPORT
 GLOBAL_ENTRY(ia64_ret_from_ia32_execve)
 	PT_REGS_UNWIND_INFO(0)
-	adds r2=3DPT(R8)+16,sp			// r2 =3D &pt_regs.r8
-	adds r3=3DPT(R10)+16,sp			// r3 =3D &pt_regs.r10
+	adds r2=3DPT(R8)+16,sp		// r2 =3D &pt_regs.r8
+	adds r3=3DPT(R10)+16,sp		// r3 =3D &pt_regs.r10
 	;;
 	.mem.offset 0,0
-	st8.spill [r2]=3Dr8	// store return value in slot for r8 and set unat bit
+	st8.spill [r2]=3Dr8		// store return value in slot for r8
+					//   and set unat bit
 	.mem.offset 8,0
-	st8.spill [r3]=3Dr0	// clear error indication in slot for r10 and set una=
t bit
+	st8.spill [r3]=3Dr0		// clear error indication in slot for
+					//   r10 and set unat bit
 END(ia64_ret_from_ia32_execve)
 	// fall through
 #endif /* CONFIG_IA32_SUPPORT */
 GLOBAL_ENTRY(ia64_leave_kernel)
 	PT_REGS_UNWIND_INFO(0)
 	/*
-	 * work.need_resched etc. mustn't get changed by this CPU before it retur=
ns to
-	 * user- or fsys-mode, hence we disable interrupts early on.
+	 * work.need_resched etc. mustn't get changed by this CPU before=20
+	 * it returns to user- or fsys-mode, hence we disable interrupts
+	 * early on.
 	 *
-	 * p6 controls whether current_thread_info()->flags needs to be check for
-	 * extra work.  We always check for extra work when returning to user-lev=
el.
-	 * With CONFIG_PREEMPT, we also check for extra work when the preempt_cou=
nt
-	 * is 0.  After extra work processing has been completed, execution
-	 * resumes at .work_processed_syscall with p6 set to 1 if the extra-work-=
check
+	 * p6 controls whether current_thread_info()->flags needs to be=20
+	 * checked for extra work.  We always check for extra work when=20
+	 * returning to user-level.  With CONFIG_PREEMPT, we also check=20
+	 * for extra work when the preempt_count is 0.  After extra work=20
+	 * processing has been completed, execution resumes at
+	 * .work_processed_syscall with p6 set to 1 if the extra-work-check
 	 * needs to be redone.
 	 */
 #ifdef CONFIG_PREEMPT
@@ -835,7 +895,7 @@ #endif
 .work_processed_kernel:
 	adds r17=3DTI_FLAGS+IA64_TASK_SIZE,r13
 	;;
-(p6)	ld4 r31=3D[r17]				// load current_thread_info()->flags
+(p6)	ld4 r31=3D[r17]			// load current_thread_info()->flags
 	adds r21=3DPT(PR)+16,r12
 	;;
=20
@@ -844,22 +904,23 @@ (p6)	ld4 r31=3D[r17]				// load current_th
 	adds r3=3DPT(R16)+16,r12
 	;;
 	lfetch [r21]
-	ld8 r28=3D[r2],8		// load b6
+	ld8 r28=3D[r2],8				// load b6
 	adds r29=3DPT(R24)+16,r12
=20
 	ld8.fill r16=3D[r3],PT(AR_CSD)-PT(R16)
 	adds r30=3DPT(AR_CCV)+16,r12
-(p6)	and r19=3DTIF_WORK_MASK,r31		// any work other than TIF_SYSCALL_TRACE?
+(p6)	and r19=3DTIF_WORK_MASK,r31		// any work other than=20
+						//   TIF_SYSCALL_TRACE?
 	;;
 	ld8.fill r24=3D[r29]
-	ld8 r15=3D[r30]		// load ar.ccv
+	ld8 r15=3D[r30]				// load ar.ccv
 (p6)	cmp4.ne.unc p6,p0=3Dr19, r0		// any special work pending?
 	;;
-	ld8 r29=3D[r2],16		// load b7
-	ld8 r30=3D[r3],16		// load ar.csd
+	ld8 r29=3D[r2],16				// load b7
+	ld8 r30=3D[r3],16				// load ar.csd
 (p6)	br.cond.spnt .work_pending
 	;;
-	ld8 r31=3D[r2],16		// load ar.ssd
+	ld8 r31=3D[r2],16				// load ar.ssd
 	ld8.fill r8=3D[r3],16
 	;;
 	ld8.fill r9=3D[r2],16
@@ -876,8 +937,9 @@ (p6)	br.cond.spnt .work_pending
 	mov ar.csd=3Dr30
 	mov ar.ssd=3Dr31
 	;;
-	rsm psr.i | psr.ic	// initiate turning off of interrupt and interruption =
collection
-	invala			// invalidate ALAT
+	rsm psr.i | psr.ic		// initiate turning off of interrupt
+					//   and interruption collection
+	invala				// invalidate ALAT
 	;;
 	ld8.fill r22=3D[r2],24
 	ld8.fill r23=3D[r3],24
@@ -904,44 +966,49 @@ (p6)	br.cond.spnt .work_pending
 	ldf.fill f7=3D[r2],PT(F11)-PT(F7)
 	ldf.fill f8=3D[r3],32
 	;;
-	srlz.d	// ensure that inter. collection is off (VHPT is don't care, since=
 text is pinned)
+	srlz.d				// ensure that interrupt collection=20
+					//   is off (VHPT is don't care, since
+					//   text is pinned)
 	mov ar.ccv=3Dr15
 	;;
 	ldf.fill f11=3D[r2]
-	bsw.0			// switch back to bank 0 (no stop bit required beforehand...)
+	bsw.0				// switch back to bank 0 (no stop bit
+					//   required beforehand...)
 	;;
-(pUStk)	mov r18=3DIA64_KR(CURRENT)// M2 (12 cycle read latency)
+(pUStk)	mov r18=3DIA64_KR(CURRENT)	// M2 (12 cycle read latency)
 	adds r16=3DPT(CR_IPSR)+16,r12
 	adds r17=3DPT(CR_IIP)+16,r12
=20
-(pKStk)	mov r22=3Dpsr		// M2 read PSR now that interrupts are disabled
+(pKStk)	mov r22=3Dpsr			// M2 read PSR now that interrupts=20
+					//    are disabled
 	nop.i 0
 	nop.i 0
 	;;
-	ld8 r29=3D[r16],16	// load cr.ipsr
-	ld8 r28=3D[r17],16	// load cr.iip
+	ld8 r29=3D[r16],16		// load cr.ipsr
+	ld8 r28=3D[r17],16		// load cr.iip
 	;;
-	ld8 r30=3D[r16],16	// load cr.ifs
-	ld8 r25=3D[r17],16	// load ar.unat
+	ld8 r30=3D[r16],16		// load cr.ifs
+	ld8 r25=3D[r17],16		// load ar.unat
 	;;
-	ld8 r26=3D[r16],16	// load ar.pfs
-	ld8 r27=3D[r17],16	// load ar.rsc
-	cmp.eq p9,p0=3Dr0,r0	// set p9 to indicate that we should restore cr.ifs
+	ld8 r26=3D[r16],16		// load ar.pfs
+	ld8 r27=3D[r17],16		// load ar.rsc
+	cmp.eq p9,p0=3Dr0,r0		// set p9 to indicate that we should
+					//   restore cr.ifs
 	;;
-	ld8 r24=3D[r16],16	// load ar.rnat (may be garbage)
-	ld8 r23=3D[r17],16	// load ar.bspstore (may be garbage)
+	ld8 r24=3D[r16],16		// load ar.rnat (may be garbage)
+	ld8 r23=3D[r17],16		// load ar.bspstore (may be garbage)
 	;;
-	ld8 r31=3D[r16],16	// load predicates
-	ld8 r21=3D[r17],16	// load b0
+	ld8 r31=3D[r16],16		// load predicates
+	ld8 r21=3D[r17],16		// load b0
 	;;
-	ld8 r19=3D[r16],16	// load ar.rsc value for "loadrs"
-	ld8.fill r1=3D[r17],16	// load r1
+	ld8 r19=3D[r16],16		// load ar.rsc value for "loadrs"
+	ld8.fill r1=3D[r17],16		// load r1
 	;;
 	ld8.fill r12=3D[r16],16
 	ld8.fill r13=3D[r17],16
 (pUStk)	adds r18=3DIA64_TASK_THREAD_ON_USTACK_OFFSET,r18
 	;;
-	ld8 r20=3D[r16],16	// ar.fpsr
+	ld8 r20=3D[r16],16		// ar.fpsr
 	ld8.fill r15=3D[r17],16
 	;;
 	ld8.fill r14=3D[r16],16
@@ -949,13 +1016,14 @@ (pUStk)	adds r18=3DIA64_TASK_THREAD_ON_UST
 (pUStk)	mov r17=3D1
 	;;
 	ld8.fill r3=3D[r16]
-(pUStk)	st1 [r18]=3Dr17		// restore current->thread.on_ustack
-	shr.u r18=3Dr19,16	// get byte size of existing "dirty" partition
+(pUStk)	st1 [r18]=3Dr17			// restore current->thread.on_ustack
+	shr.u r18=3Dr19,16		// get byte size of existing "dirty"
+					//   partition
 	;;
-	mov r16=3Dar.bsp		// get existing backing store pointer
+	mov r16=3Dar.bsp			// get existing backing store pointer
 	addl r17=3DTHIS_CPU(ia64_phys_stacked_size_p8),r0
 	;;
-	ld4 r17=3D[r17]		// r17 =3D cpu_data->phys_stacked_size_p8
+	ld4 r17=3D[r17]			// r17 =3D cpu_data->phys_stacked_size_p8
 (pKStk)	br.cond.dpnt skip_rbs_switch
=20
 	/*
@@ -964,17 +1032,21 @@ (pKStk)	br.cond.dpnt skip_rbs_switch
 	 * NOTE: alloc, loadrs, and cover can't be predicated.
 	 */
 (pNonSys) br.cond.dpnt dont_preserve_current_frame
-	cover				// add current frame into dirty partition and set cr.ifs
+	cover				// add current frame into dirty=20
+					//   partition and set cr.ifs
 	;;
 	mov r19=3Dar.bsp			// get new backing store pointer
 rbs_switch:
-	sub r16=3Dr16,r18			// krbs =3D old bsp - size of dirty partition
+	sub r16=3Dr16,r18			// krbs =3D old bsp - size of dirty
+					//   partition
 	cmp.ne p9,p0=3Dr0,r0		// clear p9 to skip restore of cr.ifs
 	;;
-	sub r19=3Dr19,r16			// calculate total byte size of dirty partition
+	sub r19=3Dr19,r16			// calculate total byte size of dirty
+					//   partition
 	add r18d,r18			// don't force in0-in7 into memory...
 	;;
-	shl r19=3Dr19,16			// shift size of dirty partition into loadrs position
+	shl r19=3Dr19,16			// shift size of dirty partition into
+					//   loadrs position
 	;;
 dont_preserve_current_frame:
 	/*
@@ -991,8 +1063,8 @@ #else
 #	define Nregs	14
 #endif
 	alloc loc0=3Dar.pfs,2,Nregs-2,2,0
-	shr.u loc1=3Dr18,9		// RNaTslots <=3D floor(dirtySize / (64*8))
-	sub r17=3Dr17,r18			// r17 =3D (physStackedSize + 8) - dirtySize
+	shr.u loc1=3Dr18,9		// RNaTslots <=3D floor(dirtySize/(64*8))
+	sub r17=3Dr17,r18			// r17 =3D (physStackedSize+8)-dirtySize
 	;;
 	mov ar.rsc=3Dr19			// load ar.rsc to be used for "loadrs"
 	shladd in0=3Dloc1,3,r17
@@ -1004,12 +1076,13 @@ #ifdef CONFIG_ITANIUM
 	// cycle 0
  { .mii
 	alloc loc0=3Dar.pfs,2,Nregs-2,2,0
-	cmp.lt pRecurse,p0=3DNregs*8,in0	// if more than Nregs regs left to clear=
, (re)curse
+	cmp.lt pRecurse,p0=3DNregs*8,in0	// if more than Nregs registers left=20
+					//   to clear, (re)curse
 	add out0=3D-Nregs*8,in0
 }{ .mfb
 	add out1=3D1,in1			// increment recursion count
 	nop.f 0
-	nop.b 0				// can't do br.call here because of alloc (WAW on CFM)
+	nop.b 0				// can't do br.call here because of 						//   alloc (WAW on C=
FM)
 	;;
 }{ .mfi	// cycle 1
 	mov loc1=3D0
@@ -1023,7 +1096,8 @@ (pRecurse) br.call.sptk.many b0=3Drse_clea
 }{ .mfi	// cycle 2
 	mov loc5=3D0
 	nop.f 0
-	cmp.ne pReturn,p0=3Dr0,in1	// if recursion count !=3D 0, we need to do a =
br.ret
+	cmp.ne pReturn,p0=3Dr0,in1	// if recursion count !=3D 0, we need=20
+					//   to do a br.ret
 }{ .mib
 	mov loc6=3D0
 	mov loc7=3D0
@@ -1031,7 +1105,8 @@ (pReturn) br.ret.sptk.many b0
 }
 #else /* !CONFIG_ITANIUM */
 	alloc loc0=3Dar.pfs,2,Nregs-2,2,0
-	cmp.lt pRecurse,p0=3DNregs*8,in0	// if more than Nregs regs left to clear=
, (re)curse
+	cmp.lt pRecurse,p0=3DNregs*8,in0	// if more than Nregs registers left
+					//   to clear, (re)curse
 	add out0=3D-Nregs*8,in0
 	add out1=3D1,in1			// increment recursion count
 	mov loc1=3D0
@@ -1046,7 +1121,8 @@ (pRecurse) br.call.dptk.few b0=3Drse_clear
 	;;
 	mov loc8=3D0
 	mov loc9=3D0
-	cmp.ne pReturn,p0=3Dr0,in1	// if recursion count !=3D 0, we need to do a =
br.ret
+	cmp.ne pReturn,p0=3Dr0,in1	// if recursion count !=3D 0, we need
+					//   to do a br.ret
 	mov loc10=3D0
 	mov loc11=3D0
 (pReturn) br.ret.dptk.many b0
@@ -1059,33 +1135,38 @@ #	undef pReturn
 	loadrs
 	;;
 skip_rbs_switch:
-	mov ar.unat=3Dr25		// M2
-(pKStk)	extr.u r22=3Dr22,21,1	// I0 extract current value of psr.pp from r=
22
-(pLvSys)mov r19=3Dr0		// A  clear r19 for leave_syscall, no-op otherwise
-	;;
-(pUStk)	mov ar.bspstore=3Dr23	// M2
-(pKStk)	dep r29=3Dr22,r29,21,1	// I0 update ipsr.pp with psr.pp
-(pLvSys)mov r16=3Dr0		// A  clear r16 for leave_syscall, no-op otherwise
-	;;
-	mov cr.ipsr=3Dr29		// M2
-	mov ar.pfs=3Dr26		// I0
-(pLvSys)mov r17=3Dr0		// A  clear r17 for leave_syscall, no-op otherwise
+	mov ar.unat=3Dr25			// M2
+(pKStk)	extr.u r22=3Dr22,21,1		// I0 extract current value of psr.pp
+					//    from r22
+(pLvSys)mov r19=3Dr0			// A  clear r19 for leave_syscall,=20
+					//    no-op otherwise
+	;;
+(pUStk)	mov ar.bspstore=3Dr23		// M2
+(pKStk)	dep r29=3Dr22,r29,21,1		// I0 update ipsr.pp with psr.pp
+(pLvSys)mov r16=3Dr0			// A  clear r16 for leave_syscall,=20
+					//    no-op otherwise
+	;;
+	mov cr.ipsr=3Dr29			// M2
+	mov ar.pfs=3Dr26			// I0
+(pLvSys)mov r17=3Dr0			// A  clear r17 for leave_syscall,=20
+					//    no-op otherwise
=20
-(p9)	mov cr.ifs=3Dr30		// M2
-	mov b0=3Dr21		// I0
-(pLvSys)mov r18=3Dr0		// A  clear r18 for leave_syscall, no-op otherwise
+(p9)	mov cr.ifs=3Dr30			// M2
+	mov b0=3Dr21			// I0
+(pLvSys)mov r18=3Dr0			// A  clear r18 for leave_syscall,=20
+					//    no-op otherwise
=20
-	mov ar.fpsr=3Dr20		// M2
-	mov cr.iip=3Dr28		// M2
+	mov ar.fpsr=3Dr20			// M2
+	mov cr.iip=3Dr28			// M2
 	nop 0
 	;;
-(pUStk)	mov ar.rnat=3Dr24		// M2 must happen with RSE in lazy mode
+(pUStk)	mov ar.rnat=3Dr24			// M2 must happen with RSE in lazy mode
 	nop 0
 (pLvSys)mov r2=3Dr0
=20
-	mov ar.rsc=3Dr27		// M2
-	mov pr=3Dr31,-1		// I0
-	rfi			// B
+	mov ar.rsc=3Dr27			// M2
+	mov pr=3Dr31,-1			// I0
+	rfi				// B
=20
 	/*
 	 * On entry:
@@ -1101,31 +1182,32 @@ (pLvSys)mov r2=3Dr0
 	st8 [r2]=3Dr8
 	st8 [r3]=3Dr10
 .work_pending:
-	tbit.z p6,p0=3Dr31,TIF_NEED_RESCHED		// current_thread_info()->need_resch=
ed=3D0?
+	tbit.z p6,p0=3Dr31,TIF_NEED_RESCHED	// current_thread_info()->
+						//   need_resched =3D 0?
 (p6)	br.cond.sptk.few .notify
 #ifdef CONFIG_PREEMPT
 (pKStk) dep r21=3D-1,r0,PREEMPT_ACTIVE_BIT,1
 	;;
 (pKStk) st4 [r20]=3Dr21
-	ssm psr.i		// enable interrupts
+	ssm psr.i				// enable interrupts
 #endif
 	br.call.spnt.many rp=3Dschedule
-.ret9:	cmp.eq p6,p0=3Dr0,r0				// p6 <- 1
-	rsm psr.i		// disable interrupts
+.ret9:	cmp.eq p6,p0=3Dr0,r0			// p6 <- 1
+	rsm psr.i				// disable interrupts
 	;;
 #ifdef CONFIG_PREEMPT
 (pKStk)	adds r20=3DTI_PRE_COUNT+IA64_TASK_SIZE,r13
 	;;
-(pKStk)	st4 [r20]=3Dr0		// preempt_count() <- 0
+(pKStk)	st4 [r20]=3Dr0				// preempt_count() <- 0
 #endif
 (pLvSys)br.cond.sptk.few  .work_pending_syscall_end
-	br.cond.sptk.many .work_processed_kernel	// re-check
+	br.cond.sptk.many .work_processed_kernel // re-check
=20
 .notify:
 (pUStk)	br.call.spnt.many rp=3Dnotify_resume_user
-.ret10:	cmp.ne p6,p0=3Dr0,r0				// p6 <- 0
+.ret10:	cmp.ne p6,p0=3Dr0,r0			// p6 <- 0
 (pLvSys)br.cond.sptk.few  .work_pending_syscall_end
-	br.cond.sptk.many .work_processed_kernel	// don't re-check
+	br.cond.sptk.many .work_processed_kernel // don't re-check
=20
 .work_pending_syscall_end:
 	adds r2=3DPT(R8)+16,r12
@@ -1133,36 +1215,37 @@ (pLvSys)br.cond.sptk.few  .work_pending_
 	;;
 	ld8 r8=3D[r2]
 	ld8 r10=3D[r3]
-	br.cond.sptk.many .work_processed_syscall	// re-check
+	br.cond.sptk.many .work_processed_syscall // re-check
=20
 END(ia64_leave_kernel)
=20
 ENTRY(handle_syscall_error)
 	/*
-	 * Some system calls (e.g., ptrace, mmap) can return arbitrary values whi=
ch could
-	 * lead us to mistake a negative return value as a failed syscall.  Those=
 syscall
-	 * must deposit a non-zero value in pt_regs.r8 to indicate an error.  If
-	 * pt_regs.r8 is zero, we assume that the call completed successfully.
+	 * Some system calls (e.g., ptrace, mmap) can return arbitrary
+	 * values which could lead us to mistake a negative return value
+	 * as a failed syscall.  Those syscalls must deposit a non-zero
+	 * value in pt_regs.r8 to indicate an error.  If pt_regs.r8 is=20
+	 * zero, we assume that the call completed successfully.
 	 */
 	PT_REGS_UNWIND_INFO(0)
-	ld8 r3=3D[r2]		// load pt_regs.r8
+	ld8 r3=3D[r2]			// load pt_regs.r8
 	;;
-	cmp.eq p6,p7=3Dr3,r0	// is pt_regs.r8=3D0?
+	cmp.eq p6,p7=3Dr3,r0		// is pt_regs.r8=3D0?
 	;;
 (p7)	mov r10=3D-1
-(p7)	sub r8=3D0,r8		// negate return value to get errno
+(p7)	sub r8=3D0,r8			// negate return value to get errno
 	br.cond.sptk ia64_leave_syscall
 END(handle_syscall_error)
=20
 	/*
-	 * Invoke schedule_tail(task) while preserving in0-in7, which may be need=
ed
-	 * in case a system call gets restarted.
+	 * Invoke schedule_tail(task) while preserving in0-in7, which may=20
+	 * be needed in case a system call gets restarted.
 	 */
 GLOBAL_ENTRY(ia64_invoke_schedule_tail)
 	.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(8)
 	alloc loc1=3Dar.pfs,8,2,1,0
 	mov loc0=3Drp
-	mov out0=3Dr8				// Address of previous task
+	mov out0=3Dr8			// Address of previous task
 	;;
 	br.call.sptk.many rp=3Dschedule_tail
 .ret11:	mov ar.pfs=3Dloc1
@@ -1171,13 +1254,16 @@ GLOBAL_ENTRY(ia64_invoke_schedule_tail)
 END(ia64_invoke_schedule_tail)
=20
 	/*
-	 * Setup stack and call do_notify_resume_user().  Note that pSys and pNon=
Sys need to
-	 * be set up by the caller.  We declare 8 input registers so the system c=
all
-	 * args get preserved, in case we need to restart a system call.
+	 * Setup stack and call do_notify_resume_user().  Note that pSys=20
+	 * and pNonSys need to be set up by the caller.  We declare 8=20
+	 * input registers so the system call args get preserved, in case
+	 * we need to restart a system call.
 	 */
 ENTRY(notify_resume_user)
 	.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(8)
-	alloc loc1=3Dar.pfs,8,2,3,0 // preserve all eight input regs in case of s=
yscall restart!
+	alloc loc1=3Dar.pfs,8,2,3,0 		// preserve all eight input=20
+						//   registers in case of a
+						//   syscall restart!
 	mov r9=3Dar.unat
 	mov loc0=3Drp				// save return address
 	mov out0=3D0				// there is no "oldset"
@@ -1187,14 +1273,16 @@ (pSys)	mov out2=3D1				// out2=3D1 =3D> we're
 (pNonSys) mov out2=3D0				// out2=3D0 =3D> not a syscall
 	.fframe 16
 	.spillsp ar.unat, 16
-	st8 [sp]=3Dr9,-16				// allocate space for ar.unat and save it
+	st8 [sp]=3Dr9,-16				// allocate space for ar.unat
+						//   and save it
 	st8 [out1]=3Dloc1,-8			// save ar.pfs, out1=3D&sigscratch
 	.body
 	br.call.sptk.many rp=3Ddo_notify_resume_user
 .ret15:	.restore sp
 	adds sp=16,sp				// pop scratch stack space
 	;;
-	ld8 r9=3D[sp]				// load new unat from sigscratch->scratch_unat
+	ld8 r9=3D[sp]				// load new unat from=20
+						//   sigscratch->scratch_unat
 	mov rp=3Dloc0
 	;;
 	mov ar.unat=3Dr9
@@ -1204,7 +1292,9 @@ END(notify_resume_user)
=20
 GLOBAL_ENTRY(sys_rt_sigsuspend)
 	.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(8)
-	alloc loc1=3Dar.pfs,8,2,3,0 // preserve all eight input regs in case of s=
yscall restart!
+	alloc loc1=3Dar.pfs,8,2,3,0 		// preserve all eight input=20
+						//   registers in case of a
+						//   syscall restart!
 	mov r9=3Dar.unat
 	mov loc0=3Drp				// save return address
 	mov out0=3Din0				// mask
@@ -1213,14 +1303,16 @@ GLOBAL_ENTRY(sys_rt_sigsuspend)
 	;;
 	.fframe 16
 	.spillsp ar.unat, 16
-	st8 [sp]=3Dr9,-16				// allocate space for ar.unat and save it
+	st8 [sp]=3Dr9,-16				// allocate space for ar.unat
+						//   and save it
 	st8 [out2]=3Dloc1,-8			// save ar.pfs, out2=3D&sigscratch
 	.body
 	br.call.sptk.many rp=3Dia64_rt_sigsuspend
 .ret17:	.restore sp
 	adds sp=16,sp				// pop scratch stack space
 	;;
-	ld8 r9=3D[sp]				// load new unat from sw->caller_unat
+	ld8 r9=3D[sp]				// load new unat from=20
+						//   sw->caller_unat
 	mov rp=3Dloc0
 	;;
 	mov ar.unat=3Dr9
@@ -1238,13 +1330,15 @@ ENTRY(sys_rt_sigreturn)
 	PT_REGS_SAVES(16)
 	adds sp=3D-16,sp
 	.body
-	cmp.eq pNonSys,pSys=3Dr0,r0		// sigreturn isn't a normal syscall...
+	cmp.eq pNonSys,pSys=3Dr0,r0		// sigreturn isn't a normal
+						//   syscall...
 	;;
 	/*
-	 * leave_kernel() restores f6-f11 from pt_regs, but since the streamlined
-	 * syscall-entry path does not save them we save them here instead.  Note=
: we
-	 * don't need to save any other registers that are not saved by the strea=
m-lined
-	 * syscall path, because restore_sigcontext() restores them.
+	 * leave_kernel() restores f6-f11 from pt_regs, but since the=20
+	 * streamlined syscall-entry path does not save them we save them=20
+	 * here instead.  Note: we don't need to save any other registers=20
+	 * that are not saved by the stream-lined syscall path, because=20
+	 * restore_sigcontext() restores them.
 	 */
 	adds r16=3DPT(F6)+32,sp
 	adds r17=3DPT(F7)+32,sp
@@ -1276,10 +1370,10 @@ GLOBAL_ENTRY(ia64_prepare_handle_unalign
 	 */
 	mov r16=3Dr0
 	DO_SAVE_SWITCH_STACK
-	br.call.sptk.many rp=3Dia64_handle_unaligned	// stack frame setup in ivt
+	br.call.sptk.many rp=3Dia64_handle_unaligned  // stack frame setup in ivt
 .ret21:	.body
 	DO_LOAD_SWITCH_STACK
-	br.cond.sptk.many rp				// goes to ia64_leave_kernel
+	br.cond.sptk.many rp			// goes to ia64_leave_kernel
 END(ia64_prepare_handle_unaligned)
=20
 	//
@@ -1309,7 +1403,8 @@ GLOBAL_ENTRY(unw_init_running)
 	br.call.sptk.many rp=3Dunw_init_frame_info
 1:	adds out0=16,sp				// &info
 	mov b6=3Dloc2
-	mov loc2=3Dgp				// save gp across indirect function call
+	mov loc2=3Dgp				// save gp across indirect=20
+						//   function call
 	;;
 	ld8 gp=3D[in0]
 	mov out1=3Din1				// arg
@@ -1331,7 +1426,8 @@ END(unw_init_running)
 	.align 8
 	.globl sys_call_table
 sys_call_table:
-	data8 sys_ni_syscall		//  This must be sys_ni_syscall!  See ivt.S.
+	data8 sys_ni_syscall			// This must be sys_ni_syscall!
+						//   See ivt.S.
 	data8 sys_exit				// 1025
 	data8 sys_read
 	data8 sys_write
@@ -1427,9 +1523,9 @@ sys_call_table:
 	data8 sys_syslog
 	data8 sys_setitimer
 	data8 sys_getitimer
-	data8 sys_ni_syscall			// 1120		/* was: ia64_oldstat */
-	data8 sys_ni_syscall					/* was: ia64_oldlstat */
-	data8 sys_ni_syscall					/* was: ia64_oldfstat */
+	data8 sys_ni_syscall			// 1120	/* was: ia64_oldstat */
+	data8 sys_ni_syscall			/* was: ia64_oldlstat */
+	data8 sys_ni_syscall			/* was: ia64_oldfstat */
 	data8 sys_vhangup
 	data8 sys_lchown
 	data8 sys_remap_file_pages		// 1125
@@ -1439,16 +1535,16 @@ sys_call_table:
 	data8 sys_setdomainname
 	data8 sys_newuname			// 1130
 	data8 sys_adjtimex
-	data8 sys_ni_syscall					/* was: ia64_create_module */
+	data8 sys_ni_syscall			/* was: ia64_create_module */
 	data8 sys_init_module
 	data8 sys_delete_module
-	data8 sys_ni_syscall			// 1135		/* was: sys_get_kernel_syms */
-	data8 sys_ni_syscall					/* was: sys_query_module */
+	data8 sys_ni_syscall		// 1135	/* was: sys_get_kernel_syms */
+	data8 sys_ni_syscall			/* was: sys_query_module */
 	data8 sys_quotactl
 	data8 sys_bdflush
 	data8 sys_sysfs
 	data8 sys_personality			// 1140
-	data8 sys_ni_syscall		// sys_afs_syscall
+	data8 sys_ni_syscall			// sys_afs_syscall
 	data8 sys_setfsuid
 	data8 sys_setfsgid
 	data8 sys_getdents
@@ -1495,8 +1593,8 @@ sys_call_table:
 	data8 sys_capget			// 1185
 	data8 sys_capset
 	data8 sys_sendfile64
-	data8 sys_ni_syscall		// sys_getpmsg (STREAMS)
-	data8 sys_ni_syscall		// sys_putpmsg (STREAMS)
+	data8 sys_ni_syscall			// sys_getpmsg (STREAMS)
+	data8 sys_ni_syscall			// sys_putpmsg (STREAMS)
 	data8 sys_socket			// 1190
 	data8 sys_bind
 	data8 sys_connect
@@ -1611,4 +1709,5 @@ sys_call_table:
 	data8 sys_tee
 	data8 sys_vmsplice
=20
-	.org sys_call_table + 8*NR_syscalls	// guard against failures to increase=
 NR_syscalls
+	.org sys_call_table + 8*NR_syscalls	// guard against failures to
+						//   increase NR_syscalls


--=20
Ciao,
al
----------------------------------------------------------------------
Al Stone                                      Alter Ego:
Open Source and Linux R&D                     Debian Developer
Hewlett-Packard Company                       http://www.debian.org
E-mail: ahs3@fc.hp.com                        ahs3@debian.org
----------------------------------------------------------------------

