From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 08 Oct 2004 16:36:02 +0000
Subject: [patch] ptrace speedup
Message-Id: <200410081636.i98Ga2S9013171@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Tony,

While I think the attached patch is safe, it's probably better to
queue it for 2.6.10, so it can get some extra testing.  Andrew, if you
want to queue it up as well for your mm kernel, that might be useful,
too.

	--david

ia64: speedup ptrace by avoiding kernel-stack walk

This patch changes the syscall entry path to store the
current-frame-mask (CFM) in pt_regs->cr_ifs.  This just takes one
extra instruction (a "dep" to clear the bits other than 0-37) and is
free in terms of cycles.

The advantage of doing this is that it lets ptrace() avoid having to
walk the stack to determine the end of the user-level backing-store of
a process which is in the middle of a system-call.  Since this is what
strace does all the time, this speeds up strace quite a bit (by ~50%).
More importantly, it makes the syscall vs. non-syscall case much more
symmetric, which is always something I wanted.

Note that the change to ivt.S looks big but this is just a rippling
effect of instruction-scheduling to keep syscall latency the same.
All that's really going on there is that instead of storing 0 into
cr_ifs member we store the low 38 bits of ar.pfs.

Signed-off-by: David Mosberger <davidm@hpl.hp.com>

 arch/ia64/kernel/ivt.S    |   31 ++++++++++++++++---------------
 arch/ia64/kernel/ptrace.c |   31 +++++++++----------------------
 arch/ia64/kernel/signal.c |    8 +++-----
 include/asm-ia64/ptrace.h |    8 ++++++--
 4 files changed, 34 insertions(+), 44 deletions(-)

=3D=3D=3D include/asm-ia64/ptrace.h 1.17 vs edited =3D=3D--- 1.17/include/a=
sm-ia64/ptrace.h	2004-08-26 23:30:30 -07:00
+++ edited/include/asm-ia64/ptrace.h	2004-10-08 09:21:00 -07:00
@@ -2,7 +2,7 @@
 #define _ASM_IA64_PTRACE_H
=20
 /*
- * Copyright (C) 1998-2003 Hewlett-Packard Co
+ * Copyright (C) 1998-2004 Hewlett-Packard Co
  *	David Mosberger-Tang <davidm@hpl.hp.com>
  *	Stephane Eranian <eranian@hpl.hp.com>
  * Copyright (C) 2003 Intel Co
@@ -110,7 +110,11 @@
=20
 	unsigned long cr_ipsr;		/* interrupted task's psr */
 	unsigned long cr_iip;		/* interrupted task's instruction pointer */
-	unsigned long cr_ifs;		/* interrupted task's function state */
+	/*
+	 * interrupted task's function state; if bit 63 is cleared, it
+	 * contains syscall's ar.pfs.pfm:
+	 */
+	unsigned long cr_ifs;
=20
 	unsigned long ar_unat;		/* interrupted task's NaT register (preserved) */
 	unsigned long ar_pfs;		/* prev function state  */
=3D=3D=3D arch/ia64/kernel/ivt.S 1.29 vs edited =3D=3D--- 1.29/arch/ia64/ke=
rnel/ivt.S	2004-07-09 14:18:57 -07:00
+++ edited/arch/ia64/kernel/ivt.S	2004-10-08 09:10:43 -07:00
@@ -852,7 +852,7 @@
 	add r17=3DPT(R11),r1			// initialize second base pointer
 	;;
 	alloc r19=3Dar.pfs,8,0,0,0		// ensure in0-in7 are writable
-	st8 [r16]=3Dr29,PT(CR_IFS)-PT(CR_IPSR)	// save cr.ipsr
+	st8 [r16]=3Dr29,PT(AR_PFS)-PT(CR_IPSR)	// save cr.ipsr
 	tnat.nz p8,p0=3Din0
=20
 	st8.spill [r17]=3Dr11,PT(CR_IIP)-PT(R11)	// save r11
@@ -860,31 +860,31 @@
 (pKStk)	mov r18=3Dr0				// make sure r18 isn't NaT
 	;;
=20
+	st8 [r16]=3Dr26,PT(CR_IFS)-PT(AR_PFS)	// save ar.pfs
 	st8 [r17]=3Dr28,PT(AR_UNAT)-PT(CR_IIP)	// save cr.iip
 	mov r28=B0				// save b0 (2 cyc)
-(p8)	mov in0=3D-1
 	;;
=20
-	st8 [r16]=3Dr0,PT(AR_PFS)-PT(CR_IFS)	// clear cr.ifs
 	st8 [r17]=3Dr25,PT(AR_RSC)-PT(AR_UNAT)	// save ar.unat
-(p9)	mov in1=3D-1
+	dep r19=3D0,r19,38,26			// clear all bits but 0..37 [I0]
+(p8)	mov in0=3D-1
 	;;
=20
-	st8 [r16]=3Dr26,PT(AR_RNAT)-PT(AR_PFS)	// save ar.pfs
+	st8 [r16]=3Dr19,PT(AR_RNAT)-PT(CR_IFS)	// store ar.pfs.pfm in cr.ifs
 	st8 [r17]=3Dr27,PT(AR_BSPSTORE)-PT(AR_RSC)// save ar.rsc
-	tnat.nz p10,p0=3Din2
+(p9)	mov in1=3D-1
=20
 (pUStk) sub r18=3Dr18,r22				// r18=3DRSE.ndirty*8
 	tbit.nz p15,p0=3Dr29,IA64_PSR_I_BIT
-	tnat.nz p11,p0=3Din3
+	tnat.nz p10,p0=3Din2
 	;;
 (pKStk) adds r16=3DPT(PR)-PT(AR_RNAT),r16		// skip over ar_rnat field
 (pKStk) adds r17=3DPT(B0)-PT(AR_BSPSTORE),r17	// skip over ar_bspstore fie=
ld
+	tnat.nz p11,p0=3Din3
+	;;
 (p10)	mov in2=3D-1
-
+	tnat.nz p12,p0=3Din4				// [I0]
 (p11)	mov in3=3D-1
-	tnat.nz p12,p0=3Din4
-	tnat.nz p13,p0=3Din5
 	;;
 (pUStk) st8 [r16]=3Dr24,PT(PR)-PT(AR_RNAT)	// save ar.rnat
 (pUStk) st8 [r17]=3Dr23,PT(B0)-PT(AR_BSPSTORE)	// save ar.bspstore
@@ -892,28 +892,29 @@
 	;;
 	st8 [r16]=3Dr31,PT(LOADRS)-PT(PR)		// save predicates
 	st8 [r17]=3Dr28,PT(R1)-PT(B0)		// save b0
-(p12)	mov in4=3D-1
+	tnat.nz p13,p0=3Din5				// [I0]
 	;;
 	st8 [r16]=3Dr18,PT(R12)-PT(LOADRS)	// save ar.rsc value for "loadrs"
 	st8.spill [r17]=3Dr20,PT(R13)-PT(R1)	// save original r1
-(p13)	mov in5=3D-1
+(p12)	mov in4=3D-1
 	;;
=20
 .mem.offset 0,0; st8.spill [r16]=3Dr12,PT(AR_FPSR)-PT(R12)	// save r12
 .mem.offset 8,0; st8.spill [r17]=3Dr13,PT(R15)-PT(R13)		// save r13
-	tnat.nz p14,p0=3Din6
+(p13)	mov in5=3D-1
 	;;
 	st8 [r16]=3Dr21,PT(R8)-PT(AR_FPSR)	// save ar.fpsr
 	st8.spill [r17]=3Dr15			// save r15
-	tnat.nz p8,p0=3Din7
+	tnat.nz p14,p0=3Din6
 	;;
 	stf8 [r16]=F1		// ensure pt_regs.r8 !=3D 0 (see handle_syscall_error)
 	adds r12=3D-16,r1		// switch to kernel memory stack (with 16 bytes of scr=
atch)
-(p14)	mov in6=3D-1
+	tnat.nz p8,p0=3Din7
=20
 	mov r13=3Dr2				// establish `current'
 	movl r1=3D__gp				// establish kernel global pointer
 	;;
+(p14)	mov in6=3D-1
 (p8)	mov in7=3D-1
 	tnat.nz p9,p0=3Dr15
=20
=3D=3D=3D arch/ia64/kernel/ptrace.c 1.38 vs edited =3D=3D--- 1.38/arch/ia64=
/kernel/ptrace.c	2004-10-06 02:28:32 -07:00
+++ edited/arch/ia64/kernel/ptrace.c	2004-10-08 09:16:21 -07:00
@@ -1,7 +1,7 @@
 /*
  * Kernel support for the ptrace() and syscall tracing interfaces.
  *
- * Copyright (C) 1999-2003 Hewlett-Packard Co
+ * Copyright (C) 1999-2004 Hewlett-Packard Co
  *	David Mosberger-Tang <davidm@hpl.hp.com>
  *
  * Derived from the x86 and Alpha versions.  Most of the code in here
@@ -304,7 +304,6 @@
 	long num_regs, nbits;
 	struct pt_regs *pt;
 	unsigned long cfm, *urbs_kargs;
-	struct unw_frame_info info;
=20
 	pt =3D ia64_task_regs(task);
 	kbsp =3D (unsigned long *) sw->ar_bspstore;
@@ -316,11 +315,8 @@
 		 * If entered via syscall, don't allow user to set rnat bits
 		 * for syscall args.
 		 */
-		unw_init_from_blocked_task(&info,task);
-		if (unw_unwind_to_user(&info) =3D 0) {
-			unw_get_cfm(&info,&cfm);
-			urbs_kargs =3D ia64_rse_skip_regs(urbs_end,-(cfm & 0x7f));
-		}
+		cfm =3D pt->cr_ifs;
+		urbs_kargs =3D ia64_rse_skip_regs(urbs_end, -(cfm & 0x7f));
 	}
=20
 	if (urbs_kargs >=3D urnat_addr)
@@ -480,27 +476,18 @@
 unsigned long
 ia64_get_user_rbs_end (struct task_struct *child, struct pt_regs *pt, unsi=
gned long *cfmp)
 {
-	unsigned long *krbs, *bspstore, cfm;
-	struct unw_frame_info info;
+	unsigned long *krbs, *bspstore, cfm =3D pt->cr_ifs;
 	long ndirty;
=20
 	krbs =3D (unsigned long *) child + IA64_RBS_OFFSET/8;
 	bspstore =3D (unsigned long *) pt->ar_bspstore;
 	ndirty =3D ia64_rse_num_regs(krbs, krbs + (pt->loadrs >> 19));
-	cfm =3D pt->cr_ifs & ~(1UL << 63);
=20
-	if (in_syscall(pt)) {
-		/*
-		 * If bit 63 of cr.ifs is cleared, the kernel was entered via a system
-		 * call and we need to recover the CFM that existed on entry to the
-		 * kernel by unwinding the kernel stack.
-		 */
-		unw_init_from_blocked_task(&info, child);
-		if (unw_unwind_to_user(&info) =3D 0) {
-			unw_get_cfm(&info, &cfm);
-			ndirty +=3D (cfm & 0x7f);
-		}
-	}
+	if (in_syscall(pt))
+		ndirty +=3D (cfm & 0x7f);
+	else
+		cfm &=3D ~(1UL << 63);	/* clear valid bit */
+
 	if (cfmp)
 		*cfmp =3D cfm;
 	return (unsigned long) ia64_rse_skip_regs(bspstore, ndirty);
=3D=3D=3D arch/ia64/kernel/signal.c 1.48 vs edited =3D=3D--- 1.48/arch/ia64=
/kernel/signal.c	2004-10-06 02:28:32 -07:00
+++ edited/arch/ia64/kernel/signal.c	2004-10-08 09:15:37 -07:00
@@ -290,12 +290,10 @@
=20
 	if (on_sig_stack((unsigned long) sc))
 		flags |=3D IA64_SC_FLAG_ONSTACK;
-	if ((ifs & (1UL << 63)) =3D 0) {
-		/* if cr_ifs isn't valid, we got here through a syscall */
+	if ((ifs & (1UL << 63)) =3D 0)
+		/* if cr_ifs doesn't have the valid bit set, we got here through a sysca=
ll */
 		flags |=3D IA64_SC_FLAG_IN_SYSCALL;
-		cfm =3D scr->ar_pfs & ((1UL << 38) - 1);
-	} else
-		cfm =3D ifs & ((1UL << 38) - 1);
+	cfm =3D ifs & ((1UL << 38) - 1);
 	ia64_flush_fph(current);
 	if ((current->thread.flags & IA64_THREAD_FPH_VALID)) {
 		flags |=3D IA64_SC_FLAG_FPH_VALID;
