From: Satoru Takeuchi <takeuchi_satoru@jp.fujitsu.com>
Date: Fri, 25 May 2007 05:46:37 +0000
Subject: [PATCH] Conform ia64 signal code to the 80-characters-per-line rule
Message-Id: <87fy5le9qa.wl%takeuchi_satoru@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Conform ia64 signal code to the 80-characters-per-line rule.
It has no functional change.

Signed-off-by: Satoru Takeuchi <takeuchi_satoru@jp.fujitsu.com>

Index: linux-2.6.22-rc2/arch/ia64/kernel/signal.c
=================================--- linux-2.6.22-rc2.orig/arch/ia64/kernel/signal.c	2007-05-25 13:24:34.000000000 +0900
+++ linux-2.6.22-rc2/arch/ia64/kernel/signal.c	2007-05-25 13:29:08.000000000 +0900
@@ -29,12 +29,14 @@
 #include "sigframe.h"
 
 #define DEBUG_SIG	0
-#define STACK_ALIGN	16		/* minimal alignment for stack pointer */
+#define STACK_ALIGN	16	/* minimal alignment for stack pointer */
 #define _BLOCKABLE	(~(sigmask(SIGKILL) | sigmask(SIGSTOP)))
 
 #if _NSIG_WORDS > 1
-# define PUT_SIGSET(k,u)	__copy_to_user((u)->sig, (k)->sig, sizeof(sigset_t))
-# define GET_SIGSET(k,u)	__copy_from_user((k)->sig, (u)->sig, sizeof(sigset_t))
+# define PUT_SIGSET(k,u)	__copy_to_user((u)->sig, (k)->sig, \
+					       sizeof(sigset_t))
+# define GET_SIGSET(k,u)	__copy_from_user((k)->sig, (u)->sig, \
+						 sizeof(sigset_t))
 #else
 # define PUT_SIGSET(k,u)	__put_user((k)->sig[0], &(u)->sig[0])
 # define GET_SIGSET(k,u)	__get_user((k)->sig[0], &(u)->sig[0])
@@ -57,42 +59,63 @@ restore_sigcontext (struct sigcontext __
 	/* Always make any pending restarted system calls return -EINTR */
 	current_thread_info()->restart_block.fn = do_no_restart_syscall;
 
-	/* restore scratch that always needs gets updated during signal delivery: */
+	/*
+	 * restore scratch that always needs gets updated during signal
+	 *  delivery:
+	 */
 	err  = __get_user(flags, &sc->sc_flags);
 	err |= __get_user(nat, &sc->sc_nat);
-	err |= __get_user(ip, &sc->sc_ip);			/* instruction pointer */
+	/* instruction pointer */
+	err |= __get_user(ip, &sc->sc_ip);
 	err |= __get_user(cfm, &sc->sc_cfm);
-	err |= __get_user(um, &sc->sc_um);			/* user mask */
+	/* user mask */
+	err |= __get_user(um, &sc->sc_um);
 	err |= __get_user(rsc, &sc->sc_ar_rsc);
 	err |= __get_user(scr->pt.ar_unat, &sc->sc_ar_unat);
 	err |= __get_user(scr->pt.ar_fpsr, &sc->sc_ar_fpsr);
 	err |= __get_user(scr->pt.ar_pfs, &sc->sc_ar_pfs);
-	err |= __get_user(scr->pt.pr, &sc->sc_pr);		/* predicates */
-	err |= __get_user(scr->pt.b0, &sc->sc_br[0]);		/* b0 (rp) */
-	err |= __get_user(scr->pt.b6, &sc->sc_br[6]);		/* b6 */
-	err |= __copy_from_user(&scr->pt.r1, &sc->sc_gr[1], 8);	/* r1 */
-	err |= __copy_from_user(&scr->pt.r8, &sc->sc_gr[8], 4*8);	/* r8-r11 */
-	err |= __copy_from_user(&scr->pt.r12, &sc->sc_gr[12], 2*8);	/* r12-r13 */
-	err |= __copy_from_user(&scr->pt.r15, &sc->sc_gr[15], 8);	/* r15 */
+	/* predicates */
+	err |= __get_user(scr->pt.pr, &sc->sc_pr);
+	/* b0 (rp) */
+	err |= __get_user(scr->pt.b0, &sc->sc_br[0]);
+	/* b6 */
+	err |= __get_user(scr->pt.b6, &sc->sc_br[6]);
+	/* r1 */
+	err |= __copy_from_user(&scr->pt.r1, &sc->sc_gr[1], 8);
+	/* r8-r11 */
+	err |= __copy_from_user(&scr->pt.r8, &sc->sc_gr[8], 4*8);
+	/* r12-r13 */
+	err |= __copy_from_user(&scr->pt.r12, &sc->sc_gr[12], 2*8);
+	/* r15 */
+	err |= __copy_from_user(&scr->pt.r15, &sc->sc_gr[15], 8);
 
 	scr->pt.cr_ifs = cfm | (1UL << 63);
-	scr->pt.ar_rsc = rsc | (3 << 2); /* force PL3 */
+	/* force PL3 */
+	scr->pt.ar_rsc = rsc | (3 << 2);
 
 	/* establish new instruction pointer: */
 	scr->pt.cr_iip = ip & ~0x3UL;
 	ia64_psr(&scr->pt)->ri = ip & 0x3;
-	scr->pt.cr_ipsr = (scr->pt.cr_ipsr & ~IA64_PSR_UM) | (um & IA64_PSR_UM);
+	scr->pt.cr_ipsr = (scr->pt.cr_ipsr & ~IA64_PSR_UM)
+		| (um & IA64_PSR_UM);
 
 	scr->scratch_unat = ia64_put_scratch_nat_bits(&scr->pt, nat);
 
 	if (!(flags & IA64_SC_FLAG_IN_SYSCALL)) {
 		/* Restore most scratch-state only when not in syscall. */
-		err |= __get_user(scr->pt.ar_ccv, &sc->sc_ar_ccv);		/* ar.ccv */
-		err |= __get_user(scr->pt.b7, &sc->sc_br[7]);			/* b7 */
-		err |= __get_user(scr->pt.r14, &sc->sc_gr[14]);			/* r14 */
-		err |= __copy_from_user(&scr->pt.ar_csd, &sc->sc_ar25, 2*8); /* ar.csd & ar.ssd */
-		err |= __copy_from_user(&scr->pt.r2, &sc->sc_gr[2], 2*8);	/* r2-r3 */
-		err |= __copy_from_user(&scr->pt.r16, &sc->sc_gr[16], 16*8);	/* r16-r31 */
+
+		/* ar.ccv */
+		err |= __get_user(scr->pt.ar_ccv, &sc->sc_ar_ccv);
+		/* b7 */
+		err |= __get_user(scr->pt.b7, &sc->sc_br[7]);
+		/* r14 */
+		err |= __get_user(scr->pt.r14, &sc->sc_gr[14]);
+		/* ar.csd & ar.ssd */
+		err |= __copy_from_user(&scr->pt.ar_csd, &sc->sc_ar25, 2*8);
+		/* r2-r3 */
+		err |= __copy_from_user(&scr->pt.r2, &sc->sc_gr[2], 2*8);
+		/* r16-r31 */
+		err |= __copy_from_user(&scr->pt.r16, &sc->sc_gr[16], 16*8);
 	}
 
 	if ((flags & IA64_SC_FLAG_FPH_VALID) != 0) {
@@ -104,7 +127,10 @@ restore_sigcontext (struct sigcontext __
 		if (psr->dfh)
 			ia64_drop_fpu(current);
 		else {
-			/* We already own the local fph, otherwise psr->dfh wouldn't be 0.  */
+			/*
+			 * We already own the local fph, otherwise psr->dfh
+			 * wouldn't be 0.
+			 */
 			__ia64_load_fpu(current->thread.fph);
 			ia64_set_local_fpu_owner(current);
 		}
@@ -126,10 +152,10 @@ copy_siginfo_to_user (siginfo_t __user *
 		int err;
 
 		/*
-		 * If you change siginfo_t structure, please be sure this code is fixed
-		 * accordingly.  It should never copy any pad contained in the structure
-		 * to avoid security leaks, but must copy the generic 3 ints plus the
-		 * relevant union member.
+		 * If you change siginfo_t structure, please be sure this code
+		 * is fixed accordingly.  It should never copy any pad
+		 * contained in the structure to avoid security leaks, but
+		 * must copy the generic 3 ints plus the relevant union member.
 		 */
 		err = __put_user(from->si_signo, &to->si_signo);
 		err |= __put_user(from->si_errno, &to->si_errno);
@@ -147,7 +173,11 @@ copy_siginfo_to_user (siginfo_t __user *
 			err |= __put_user(from->si_overrun, &to->si_overrun);
 			err |= __put_user(from->si_ptr, &to->si_ptr);
 			break;
-		      case __SI_RT >> 16:	/* Not generated by the kernel as of now.  */
+
+		      case __SI_RT >> 16:	/*
+						 * Not generated by the kernel
+						 * as of now.
+						 */
 		      case __SI_MESGQ >> 16:
 			err |= __put_user(from->si_uid, &to->si_uid);
 			err |= __put_user(from->si_pid, &to->si_pid);
@@ -178,19 +208,19 @@ ia64_rt_sigreturn (struct sigscratch *sc
 	sc = &((struct sigframe __user *) (scr->pt.r12 + 16))->sc;
 
 	/*
-	 * When we return to the previously executing context, r8 and r10 have already
-	 * been setup the way we want them.  Indeed, if the signal wasn't delivered while
-	 * in a system call, we must not touch r8 or r10 as otherwise user-level state
-	 * could be corrupted.
+	 * When we return to the previously executing context, r8 and r10 have
+	 * already been setup the way we want them.  Indeed, if the signal
+	 * wasn't delivered while in a system call, we must not touch r8 or
+	 * r10 as otherwise user-level state could be corrupted.
 	 */
 	retval = (long) &ia64_leave_kernel;
 	if (test_thread_flag(TIF_SYSCALL_TRACE)
 	    || test_thread_flag(TIF_SYSCALL_AUDIT))
 		/*
-		 * strace expects to be notified after sigreturn returns even though the
-		 * context to which we return may not be in the middle of a syscall.
-		 * Thus, the return-value that strace displays for sigreturn is
-		 * meaningless.
+		 * strace expects to be notified after sigreturn returns even
+		 * though the context to which we return may not be in the
+		 * middle of a syscall. Thus, the return-value that strace
+		 * displays for sigreturn is meaningless.
 		 */
 		retval = (long) &ia64_strace_leave_kernel;
 
@@ -251,7 +281,10 @@ setup_sigcontext (struct sigcontext __us
 	if (on_sig_stack((unsigned long) sc))
 		flags |= IA64_SC_FLAG_ONSTACK;
 	if ((ifs & (1UL << 63)) = 0)
-		/* if cr_ifs doesn't have the valid bit set, we got here through a syscall */
+		/*
+		 * if cr_ifs doesn't have the valid bit set, we got here
+		 * through a syscall
+		 */
 		flags |= IA64_SC_FLAG_IN_SYSCALL;
 	cfm = ifs & ((1UL << 38) - 1);
 	ia64_flush_fph(current);
@@ -268,34 +301,63 @@ setup_sigcontext (struct sigcontext __us
 	err |= __put_user(cfm, &sc->sc_cfm);
 	err |= __put_user(scr->pt.cr_ipsr & IA64_PSR_UM, &sc->sc_um);
 	err |= __put_user(scr->pt.ar_rsc, &sc->sc_ar_rsc);
-	err |= __put_user(scr->pt.ar_unat, &sc->sc_ar_unat);		/* ar.unat */
-	err |= __put_user(scr->pt.ar_fpsr, &sc->sc_ar_fpsr);		/* ar.fpsr */
+	/* ar.unat */
+	err |= __put_user(scr->pt.ar_unat, &sc->sc_ar_unat);
+	/* ar.fpsr */
+	err |= __put_user(scr->pt.ar_fpsr, &sc->sc_ar_fpsr);
+	/* predicates */
 	err |= __put_user(scr->pt.ar_pfs, &sc->sc_ar_pfs);
-	err |= __put_user(scr->pt.pr, &sc->sc_pr);			/* predicates */
-	err |= __put_user(scr->pt.b0, &sc->sc_br[0]);			/* b0 (rp) */
-	err |= __put_user(scr->pt.b6, &sc->sc_br[6]);			/* b6 */
-	err |= __copy_to_user(&sc->sc_gr[1], &scr->pt.r1, 8);		/* r1 */
-	err |= __copy_to_user(&sc->sc_gr[8], &scr->pt.r8, 4*8);		/* r8-r11 */
-	err |= __copy_to_user(&sc->sc_gr[12], &scr->pt.r12, 2*8);	/* r12-r13 */
-	err |= __copy_to_user(&sc->sc_gr[15], &scr->pt.r15, 8);		/* r15 */
+	err |= __put_user(scr->pt.pr, &sc->sc_pr);
+	/* b0 (rp) */
+	err |= __put_user(scr->pt.b0, &sc->sc_br[0]);
+	/* b6 */
+	err |= __put_user(scr->pt.b6, &sc->sc_br[6]);
+	/* r1 */
+	err |= __copy_to_user(&sc->sc_gr[1], &scr->pt.r1, 8);
+	/* r8-r11 */
+	err |= __copy_to_user(&sc->sc_gr[8], &scr->pt.r8, 4*8);
+	/* r12-r13 */
+	err |= __copy_to_user(&sc->sc_gr[12], &scr->pt.r12, 2*8);
+	/* r15 */
+	err |= __copy_to_user(&sc->sc_gr[15], &scr->pt.r15, 8);
 	err |= __put_user(scr->pt.cr_iip + ia64_psr(&scr->pt)->ri, &sc->sc_ip);
 
 	if (flags & IA64_SC_FLAG_IN_SYSCALL) {
-		/* Clear scratch registers if the signal interrupted a system call. */
-		err |= __put_user(0, &sc->sc_ar_ccv);				/* ar.ccv */
-		err |= __put_user(0, &sc->sc_br[7]);				/* b7 */
-		err |= __put_user(0, &sc->sc_gr[14]);				/* r14 */
-		err |= __clear_user(&sc->sc_ar25, 2*8);			/* ar.csd & ar.ssd */
-		err |= __clear_user(&sc->sc_gr[2], 2*8);			/* r2-r3 */
-		err |= __clear_user(&sc->sc_gr[16], 16*8);			/* r16-r31 */
+		/*
+		 * Clear scratch registers if the signal interrupted a system
+		 * call.
+		 */
+
+		/* ar.ccv */
+		err |= __put_user(0, &sc->sc_ar_ccv);
+		/* b7 */
+		err |= __put_user(0, &sc->sc_br[7]);
+		/* r14 */
+		err |= __put_user(0, &sc->sc_gr[14]);
+		/* ar.csd & ar.ssd */
+		err |= __clear_user(&sc->sc_ar25, 2*8);
+		/* r2-r3 */
+		err |= __clear_user(&sc->sc_gr[2], 2*8);
+		/* r16-r31 */
+		err |= __clear_user(&sc->sc_gr[16], 16*8);
 	} else {
-		/* Copy scratch regs to sigcontext if the signal didn't interrupt a syscall. */
-		err |= __put_user(scr->pt.ar_ccv, &sc->sc_ar_ccv);		/* ar.ccv */
-		err |= __put_user(scr->pt.b7, &sc->sc_br[7]);			/* b7 */
-		err |= __put_user(scr->pt.r14, &sc->sc_gr[14]);			/* r14 */
-		err |= __copy_to_user(&sc->sc_ar25, &scr->pt.ar_csd, 2*8); /* ar.csd & ar.ssd */
-		err |= __copy_to_user(&sc->sc_gr[2], &scr->pt.r2, 2*8);		/* r2-r3 */
-		err |= __copy_to_user(&sc->sc_gr[16], &scr->pt.r16, 16*8);	/* r16-r31 */
+		/*
+		 * Copy scratch regs to sigcontext if the signal didn't
+		 * interrupt a syscall.
+		 */
+
+		/* ar.ccv */
+		err |= __put_user(scr->pt.ar_ccv, &sc->sc_ar_ccv);
+		/* b7 */
+		err |= __put_user(scr->pt.b7, &sc->sc_br[7]);
+		/* r14 */
+		err |= __put_user(scr->pt.r14, &sc->sc_gr[14]);
+		/* ar.csd & ar.ssd */
+		err |= __copy_to_user(&sc->sc_ar25, &scr->pt.ar_csd, 2*8);
+		/* r2-r3 */
+		err |= __copy_to_user(&sc->sc_gr[2], &scr->pt.r2, 2*8);
+		/* r16-r31 */
+		err |= __copy_to_user(&sc->sc_gr[16], &scr->pt.r16, 16*8);
 	}
 	return err;
 }
@@ -353,12 +415,14 @@ setup_frame (int sig, struct k_sigaction
 	if ((ka->sa.sa_flags & SA_ONSTACK) && sas_ss_flags(new_sp) = 0) {
 		new_sp = current->sas_ss_sp + current->sas_ss_size;
 		/*
-		 * We need to check for the register stack being on the signal stack
-		 * separately, because it's switched separately (memory stack is switched
-		 * in the kernel, register stack is switched in the signal trampoline).
+		 * We need to check for the register stack being on the signal
+		 * stack separately, because it's switched separately (memory
+		 * stack is switched in the kernel, register stack is switched
+		 * in the signal trampoline).
 		 */
 		if (!rbs_on_sig_stack(scr->pt.ar_bspstore))
-			new_rbs = (current->sas_ss_sp + sizeof(long) - 1) & ~(sizeof(long) - 1);
+			new_rbs = (current->sas_ss_sp + sizeof(long) - 1)
+				& ~(sizeof(long) - 1);
 	}
 	frame = (void __user *) ((new_sp - sizeof(*frame)) & -STACK_ALIGN);
 
@@ -369,7 +433,8 @@ setup_frame (int sig, struct k_sigaction
 	err |= __put_user(&frame->info, &frame->arg1);
 	err |= __put_user(&frame->sc, &frame->arg2);
 	err |= __put_user(new_rbs, &frame->sc.sc_rbs_base);
-	err |= __put_user(0, &frame->sc.sc_loadrs);	/* initialize to zero */
+	/* initialize to zero */
+	err |= __put_user(0, &frame->sc.sc_loadrs);
 	err |= __put_user(ka->sa.sa_handler, &frame->handler);
 
 	err |= copy_siginfo_to_user(&frame->info, info);
@@ -382,37 +447,44 @@ setup_frame (int sig, struct k_sigaction
 	if (unlikely(err))
 		return force_sigsegv_info(sig, frame);
 
-	scr->pt.r12 = (unsigned long) frame - 16;	/* new stack pointer */
-	scr->pt.ar_fpsr = FPSR_DEFAULT;			/* reset fpsr for signal handler */
+	/* new stack pointer */
+	scr->pt.r12 = (unsigned long) frame - 16;
+	/* reset fpsr for signal handler */
+	scr->pt.ar_fpsr = FPSR_DEFAULT;
 	scr->pt.cr_iip = tramp_addr;
-	ia64_psr(&scr->pt)->ri = 0;			/* start executing in first slot */
-	ia64_psr(&scr->pt)->be = 0;			/* force little-endian byte-order */
+	/* start executing in first slot */
+	ia64_psr(&scr->pt)->ri = 0;
+	/* force little-endian byte-order */
+	ia64_psr(&scr->pt)->be = 0;
 	/*
-	 * Force the interruption function mask to zero.  This has no effect when a
-	 * system-call got interrupted by a signal (since, in that case, scr->pt_cr_ifs is
-	 * ignored), but it has the desirable effect of making it possible to deliver a
-	 * signal with an incomplete register frame (which happens when a mandatory RSE
-	 * load faults).  Furthermore, it has no negative effect on the getting the user's
-	 * dirty partition preserved, because that's governed by scr->pt.loadrs.
+	 * Force the interruption function mask to zero.  This has no effect
+	 * when a system-call got interrupted by a signal (since, in that
+	 * case, scr->pt_cr_ifs is ignored), but it has the desirable effect
+	 * of making it possible to deliver a signal with an incomplete
+	 * register frame (which happens when a mandatory RSE load faults).
+	 * Furthermore, it has no negative effect on the getting the user's
+	 * dirty partition preserved, because that's governed by
+	 * scr->pt.loadrs.
 	 */
 	scr->pt.cr_ifs = (1UL << 63);
 
 	/*
-	 * Note: this affects only the NaT bits of the scratch regs (the ones saved in
-	 * pt_regs), which is exactly what we want.
+	 * Note: this affects only the NaT bits of the scratch regs (the ones
+	 * saved in pt_regs), which is exactly what we want.
 	 */
 	scr->scratch_unat = 0; /* ensure NaT bits of r12 is clear */
 
 #if DEBUG_SIG
 	printk("SIG deliver (%s:%d): sig=%d sp=%lx ip=%lx handler=%p\n",
-	       current->comm, current->pid, sig, scr->pt.r12, frame->sc.sc_ip, frame->handler);
+	       current->comm, current->pid, sig, scr->pt.r12,
+	       frame->sc.sc_ip, frame->handler);
 #endif
 	return 1;
 }
 
 static long
-handle_signal (unsigned long sig, struct k_sigaction *ka, siginfo_t *info, sigset_t *oldset,
-	       struct sigscratch *scr)
+handle_signal (unsigned long sig, struct k_sigaction *ka, siginfo_t *info,
+	       sigset_t *oldset, struct sigscratch *scr)
 {
 	if (IS_IA32_PROCESS(&scr->pt)) {
 		/* send signal to IA-32 process */
@@ -433,8 +505,9 @@ handle_signal (unsigned long sig, struct
 }
 
 /*
- * Note that `init' is a special process: it doesn't get signals it doesn't want to
- * handle.  Thus you cannot kill init even with a SIGKILL even by mistake.
+ * Note that `init' is a special process: it doesn't get signals it doesn't
+ * want to handle.  Thus you cannot kill init even with a SIGKILL even by
+ * mistake.
  */
 void
 ia64_do_signal (struct sigscratch *scr, long in_syscall)
@@ -447,9 +520,9 @@ ia64_do_signal (struct sigscratch *scr, 
 #	define ERR_CODE(c)	(IS_IA32_PROCESS(&scr->pt) ? -(c) : (c))
 
 	/*
-	 * In the ia64_leave_kernel code path, we want the common case to go fast, which
-	 * is why we may in certain cases get here from kernel mode. Just return without
-	 * doing anything if so.
+	 * In the ia64_leave_kernel code path, we want the common case to go
+	 * fast, which is why we may in certain cases get here from kernel
+	 * mode. Just return without doing anything if so.
 	 */
 	if (!user_mode(&scr->pt))
 		return;
@@ -460,16 +533,17 @@ ia64_do_signal (struct sigscratch *scr, 
 		oldset = &current->blocked;
 
 	/*
-	 * This only loops in the rare cases of handle_signal() failing, in which case we
-	 * need to push through a forced SIGSEGV.
+	 * This only loops in the rare cases of handle_signal() failing, in
+	 * which case we need to push through a forced SIGSEGV.
 	 */
 	while (1) {
 		int signr = get_signal_to_deliver(&info, &ka, &scr->pt, NULL);
 
 		/*
-		 * get_signal_to_deliver() may have run a debugger (via notify_parent())
-		 * and the debugger may have modified the state (e.g., to arrange for an
-		 * inferior call), thus it's important to check for restarting _after_
+		 * get_signal_to_deliver() may have run a debugger
+		 * (via notify_parent()) and the debugger may have modified
+		 * the state (e.g., to arrange for an inferior call), thus
+		 * it's important to check for restarting _after_
 		 * get_signal_to_deliver().
 		 */
 		if (IS_IA32_PROCESS(&scr->pt)) {
@@ -481,10 +555,12 @@ ia64_do_signal (struct sigscratch *scr, 
 			}
 		} else if ((long) scr->pt.r10 != -1)
 			/*
-			 * A system calls has to be restarted only if one of the error codes
-			 * ERESTARTNOHAND, ERESTARTSYS, or ERESTARTNOINTR is returned.  If r10
-			 * isn't -1 then r8 doesn't hold an error code and we don't need to
-			 * restart the syscall, so we can clear the "restart" flag here.
+			 * A system calls has to be restarted only if one of
+			 * the error codes ERESTARTNOHAND, ERESTARTSYS, or
+			 * ERESTARTNOINTR is returned.  If r10 isn't -1 then
+			 * r8 doesn't hold an error code and we don't need to
+			 * restart the syscall, so we can clear the "restart"
+			 * flag here.
 			 */
 			restart = 0;
 
@@ -511,13 +587,17 @@ ia64_do_signal (struct sigscratch *scr, 
 					scr->pt.cr_iip -= 2;
 				} else
 					ia64_decrement_ip(&scr->pt);
-				restart = 0; /* don't restart twice if handle_signal() fails... */
+				restart = 0; /*
+					      * don't restart twice if
+					      * handle_signal() fails...
+					      */
 			}
 		}
 
 		/*
-		 * Whee!  Actually deliver the signal.  If the delivery failed, we need to
-		 * continue to iterate in this loop so we can deliver the SIGSEGV...
+		 * Whee!  Actually deliver the signal.  If the delivery
+		 * failed, we need to continue to iterate in this loop so we
+		 * can deliver the SIGSEGV...
 		 */
 		if (handle_signal(signr, &ka, &info, oldset, scr)) {
 			/* a signal was successfully delivered; the saved
@@ -533,19 +613,26 @@ ia64_do_signal (struct sigscratch *scr, 
 	/* Did we come from a system call? */
 	if (restart) {
 		/* Restart the system call - no handlers present */
-		if (errno = ERESTARTNOHAND || errno = ERESTARTSYS || errno = ERESTARTNOINTR
+		if (errno = ERESTARTNOHAND || errno = ERESTARTSYS
+		    || errno = ERESTARTNOINTR
 		    || errno = ERESTART_RESTARTBLOCK)
 		{
 			if (IS_IA32_PROCESS(&scr->pt)) {
 				scr->pt.r8 = scr->pt.r1;
 				scr->pt.cr_iip -= 2;
 				if (errno = ERESTART_RESTARTBLOCK)
-					scr->pt.r8 = 0;	/* x86 version of __NR_restart_syscall */
+					/*
+					 * x86 version of
+					 * __NR_restart_syscall
+					 */
+
+					scr->pt.r8 = 0;
 			} else {
 				/*
-				 * Note: the syscall number is in r15 which is saved in
-				 * pt_regs so all we need to do here is adjust ip so that
-				 * the "break" instruction gets re-executed.
+				 * Note: the syscall number is in r15 which is
+				 * saved in pt_regs so all we need to do here
+				 * is adjust ip so that the "break"
+				 * instruction gets re-executed.
 				 */
 				ia64_decrement_ip(&scr->pt);
 				if (errno = ERESTART_RESTARTBLOCK)
Index: linux-2.6.22-rc2/arch/ia64/kernel/sigframe.h
=================================--- linux-2.6.22-rc2.orig/arch/ia64/kernel/sigframe.h	2007-05-25 13:24:34.000000000 +0900
+++ linux-2.6.22-rc2/arch/ia64/kernel/sigframe.h	2007-05-25 13:29:08.000000000 +0900
@@ -1,14 +1,21 @@
 struct sigscratch {
-	unsigned long scratch_unat;	/* ar.unat for the general registers saved in pt */
-	unsigned long ar_pfs;		/* for syscalls, the user-level function-state  */
+	unsigned long scratch_unat;	/*
+					 * ar.unat for the general registers
+					 * saved in pt
+					 */
+	unsigned long ar_pfs;		/*
+					 * for syscalls, the user-level
+					 * function-state
+					 */
 	struct pt_regs pt;
 };
 
 struct sigframe {
 	/*
-	 * Place signal handler args where user-level unwinder can find them easily.
-	 * DO NOT MOVE THESE.  They are part of the IA-64 Linux ABI and there is
-	 * user-level code that depends on their presence!
+	 * Place signal handler args where user-level unwinder can find them
+	 * easily.
+	 * DO NOT MOVE THESE.  They are part of the IA-64 Linux ABI and there
+	 * is user-level code that depends on their presence!
 	 */
 	unsigned long arg0;		/* signum */
 	unsigned long arg1;		/* siginfo pointer */
@@ -17,7 +24,10 @@ struct sigframe {
 	 * End of architected state.
 	 */
 
-	void __user *handler;		/* pointer to the plabel of the signal handler */
+	void __user *handler;		/*
+					 * pointer to the plabel of the signal
+					 * handler
+					 */
 	struct siginfo info;
 	struct sigcontext sc;
 };
