From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 11 Feb 2003 03:06:54 +0000
Subject: Re: [Linux-ia64] sigaltstack and RBS
Message-Id: <marc-linux-ia64-105590709805833@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805824@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805824@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

>>>>> On Sun, 9 Feb 2003 16:19:20 +1100, Matt Chapman <matthewc@cse.unsw.ed=
u.au> said:

  Matt> I'm having some difficulty "demand paging" register backing
  Matt> store from userspace (i.e. using SIGSEGV to map pages in on
  Matt> demand).

  Matt> The problem is that even when using sigaltstack, the original
  Matt> backing store (which caused the fault) is still touched when
  Matt> returning to the signal trampoline, before it switches to the
  Matt> alternate RBS.  Thus I get recursive faulting before it gets
  Matt> to the signal handler.

  Matt> Ideally, signal handling on an alternate RBS/stack wouldn't
  Matt> touch the original RBS/stack at all.

  Matt> Any suggestions how to deal with this?

OK, I looked into this.  The patch below should fix the problem.
Bjorn, you might want to consider applying the same patch for 2.4.xx
(with some extra testing).

The problem was that the signal delivery code wasn't prepared to
handle incomplete register frames.  Such frames are the result of
mandatory RSE loads which fault.  This situation is a corner-case
because when a mandatory RSE load faults, the triggering instruction
has been executed already (except for the restoration of the current
frame).  The patch below fixes the problem by making sure that we
don't try to restore any registers from the user-level backing store
when invoking the signal handler.  The dirty partition of course still
gets preserved, as it should be.

	--david

diff -Nru a/arch/ia64/kernel/entry.S b/arch/ia64/kernel/entry.S
--- a/arch/ia64/kernel/entry.S	Mon Feb 10 18:51:22 2003
+++ b/arch/ia64/kernel/entry.S	Mon Feb 10 18:51:22 2003
@@ -904,13 +904,14 @@
 	mov r9=3Dar.unat
 	mov loc0=3Drp				// save return address
 	mov out0=3D0				// there is no "oldset"
-	adds out1=3D0,sp				// out1=3D&sigscratch
+	adds out1=3D8,sp				// out1=3D&sigscratch->ar_pfs
 (pSys)	mov out2=3D1				// out2=3D1 =3D> we're in a syscall
 	;;
 (pNonSys) mov out2=3D0				// out2=3D0 =3D> not a syscall
 	.fframe 16
 	.spillpsp ar.unat, 16			// (note that offset is relative to psp+0x10!)
 	st8 [sp]=3Dr9,-16				// allocate space for ar.unat and save it
+	st8 [out1]=3Dloc1,-8			// save ar.pfs, out1=3D&sigscratch
 	.body
 	br.call.sptk.many rp=3Ddo_notify_resume_user
 .ret15:	.restore sp
@@ -931,11 +932,12 @@
 	mov loc0=3Drp				// save return address
 	mov out0=3Din0				// mask
 	mov out1=3Din1				// sigsetsize
-	adds out2=3D0,sp				// out2=3D&sigscratch
+	adds out2=3D8,sp				// out2=3D&sigscratch->ar_pfs
 	;;
 	.fframe 16
 	.spillpsp ar.unat, 16			// (note that offset is relative to psp+0x10!)
 	st8 [sp]=3Dr9,-16				// allocate space for ar.unat and save it
+	st8 [out2]=3Dloc1,-8			// save ar.pfs, out2=3D&sigscratch
 	.body
 	br.call.sptk.many rp=3Dia64_rt_sigsuspend
 .ret17:	.restore sp
diff -Nru a/arch/ia64/kernel/gate.S b/arch/ia64/kernel/gate.S
--- a/arch/ia64/kernel/gate.S	Mon Feb 10 18:51:22 2003
+++ b/arch/ia64/kernel/gate.S	Mon Feb 10 18:51:22 2003
@@ -145,11 +145,12 @@
 	 */
=20
 #define SIGTRAMP_SAVES										\
-	.unwabi @svr4, 's'		// mark this as a sigtramp handler (saves scratch reg=
s)	\
-	.savesp ar.unat, UNAT_OFF+SIGCONTEXT_OFF						\
-	.savesp ar.fpsr, FPSR_OFF+SIGCONTEXT_OFF						\
-	.savesp pr, PR_OFF+SIGCONTEXT_OFF							\
-	.savesp rp, RP_OFF+SIGCONTEXT_OFF							\
+	.unwabi @svr4, 's';	/* mark this as a sigtramp handler (saves scratch reg=
s) */	\
+	.savesp ar.unat, UNAT_OFF+SIGCONTEXT_OFF;						\
+	.savesp ar.fpsr, FPSR_OFF+SIGCONTEXT_OFF;						\
+	.savesp pr, PR_OFF+SIGCONTEXT_OFF;     							\
+	.savesp rp, RP_OFF+SIGCONTEXT_OFF;							\
+	.savesp ar.pfs, CFM_OFF+SIGCONTEXT_OFF;							\
 	.vframesp SP_OFF+SIGCONTEXT_OFF
=20
 GLOBAL_ENTRY(ia64_sigtramp)
@@ -173,9 +174,7 @@
 	.spillsp.p p8, ar.rnat, RNAT_OFF+SIGCONTEXT_OFF
 (p8)	br.cond.spnt setup_rbs		// yup -> (clobbers r14, r15, and r16)
 back_from_setup_rbs:
-
-	.spillreg ar.pfs, r8
-	alloc r8=3Dar.pfs,0,0,3,0		// get CFM0, EC0, and CPL0 into r8
+	alloc r8=3Dar.pfs,0,0,3,0
 	ld8 out0=3D[base0],16		// load arg0 (signum)
 	adds base1=3D(ARG1_OFF-(RBS_BASE_OFF+SIGCONTEXT_OFF)),base1
 	;;
@@ -184,17 +183,12 @@
 	;;
 	ld8 out2=3D[base0]		// load arg2 (sigcontextp)
 	ld8 gp=3D[r17]			// get signal handler's global pointer
-
 	adds base0=3D(BSP_OFF+SIGCONTEXT_OFF),sp
 	;;
 	.spillsp ar.bsp, BSP_OFF+SIGCONTEXT_OFF
-	st8 [base0]=3Dr9,(CFM_OFF-BSP_OFF)	// save sc_ar_bsp
-	dep r8=3D0,r8,38,26			// clear EC0, CPL0 and reserved bits
-	adds base1=3D(FR6_OFF+16+SIGCONTEXT_OFF),sp
-	;;
-	.spillsp ar.pfs, CFM_OFF+SIGCONTEXT_OFF
-	st8 [base0]=3Dr8				// save CFM0
+	st8 [base0]=3Dr9			// save sc_ar_bsp
 	adds base0=3D(FR6_OFF+SIGCONTEXT_OFF),sp
+	adds base1=3D(FR6_OFF+16+SIGCONTEXT_OFF),sp
 	;;
 	stf.spill [base0]=F6,32
 	stf.spill [base1]=F7,32
@@ -217,7 +211,6 @@
 	ld8 r15=3D[base0],(CFM_OFF-BSP_OFF)	// fetch sc_ar_bsp and advance to CFM=
_OFF
 	mov r14=3Dar.bsp
 	;;
-	ld8 r8=3D[base0]				// restore (perhaps modified) CFM0, EC0, and CPL0
 	cmp.ne p8,p0=3Dr14,r15			// do we need to restore the rbs?
 (p8)	br.cond.spnt restore_rbs		// yup -> (clobbers r14-r18, f6 & f7)
 	;;
diff -Nru a/arch/ia64/kernel/sigframe.h b/arch/ia64/kernel/sigframe.h
--- a/arch/ia64/kernel/sigframe.h	Mon Feb 10 18:51:22 2003
+++ b/arch/ia64/kernel/sigframe.h	Mon Feb 10 18:51:22 2003
@@ -1,6 +1,6 @@
 struct sigscratch {
 	unsigned long scratch_unat;	/* ar.unat for the general registers saved in=
 pt */
-	unsigned long pad;
+	unsigned long ar_pfs;		/* for syscalls, the user-level function-state  */
 	struct pt_regs pt;
 };
=20
diff -Nru a/arch/ia64/kernel/signal.c b/arch/ia64/kernel/signal.c
--- a/arch/ia64/kernel/signal.c	Mon Feb 10 18:51:22 2003
+++ b/arch/ia64/kernel/signal.c	Mon Feb 10 18:51:22 2003
@@ -315,7 +315,7 @@
 static long
 setup_sigcontext (struct sigcontext *sc, sigset_t *mask, struct sigscratch=
 *scr)
 {
-	unsigned long flags =3D 0, ifs, nat;
+	unsigned long flags =3D 0, ifs, cfm, nat;
 	long err;
=20
 	ifs =3D scr->pt.cr_ifs;
@@ -325,7 +325,9 @@
 	if ((ifs & (1UL << 63)) =3D 0) {
 		/* if cr_ifs isn't valid, we got here through a syscall */
 		flags |=3D IA64_SC_FLAG_IN_SYSCALL;
-	}
+		cfm =3D scr->ar_pfs & ((1UL << 38) - 1);
+	} else
+		cfm =3D ifs & ((1UL << 38) - 1);
 	ia64_flush_fph(current);
 	if ((current->thread.flags & IA64_THREAD_FPH_VALID)) {
 		flags |=3D IA64_SC_FLAG_FPH_VALID;
@@ -344,6 +346,7 @@
=20
 	err |=3D __put_user(nat, &sc->sc_nat);
 	err |=3D PUT_SIGSET(mask, &sc->sc_mask);
+	err |=3D __put_user(cfm, &sc->sc_cfm);
 	err |=3D __put_user(scr->pt.cr_ipsr & IA64_PSR_UM, &sc->sc_um);
 	err |=3D __put_user(scr->pt.ar_rsc, &sc->sc_ar_rsc);
 	err |=3D __put_user(scr->pt.ar_ccv, &sc->sc_ar_ccv);
@@ -422,6 +425,15 @@
 	scr->pt.ar_fpsr =3D FPSR_DEFAULT;			/* reset fpsr for signal handler */
 	scr->pt.cr_iip =3D tramp_addr;
 	ia64_psr(&scr->pt)->ri =3D 0;			/* start executing in first slot */
+	/*
+	 * Force the interruption function mask to zero.  This has no effect when=
 a
+	 * system-call got interrupted by a signal (since, in that case, scr->pt_=
cr_ifs is
+	 * ignored), but it has the desirable effect of making it possible to del=
iver a
+	 * signal with an incomplete register frame (which happens when a mandato=
ry RSE
+	 * load faults).  Furthermore, it has no negative effect on the getting t=
he user's
+	 * dirty partition preserved, because that's governed by scr->pt.loadrs.
+	 */
+	scr->pt.cr_ifs =3D (1UL << 63);
=20
 	/*
 	 * Note: this affects only the NaT bits of the scratch regs (the ones sav=
ed in


