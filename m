From: "Eric W. Biederman" <ebiederm@xmission.com>
Date: Mon, 24 Sep 2018 14:21:43 +0000
Subject: [REVIEW][PATCH 3/3] signal/ia64: Use force_sig_fault where appropriate
Message-Id: <20180924142143.21356-3-ebiederm@xmission.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <87pnx32j2p.fsf@xmission.com>
In-Reply-To: <87pnx32j2p.fsf@xmission.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: linux-arch@vger.kernel.org, linux-ia64@vger.kernel.org, Fenghua Yu <fenghua.yu@intel.com>, Tony Luck <tony.luck@intel.com>, "Eric W. Biederman" <ebiederm@xmission.com>

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 arch/ia64/kernel/brl_emu.c   |  31 ++------
 arch/ia64/kernel/traps.c     | 144 ++++++++++-------------------------
 arch/ia64/kernel/unaligned.c |  12 +--
 arch/ia64/mm/fault.c         |  12 +--
 4 files changed, 49 insertions(+), 150 deletions(-)

diff --git a/arch/ia64/kernel/brl_emu.c b/arch/ia64/kernel/brl_emu.c
index a61f6c6a36f8..c0239bf77a09 100644
--- a/arch/ia64/kernel/brl_emu.c
+++ b/arch/ia64/kernel/brl_emu.c
@@ -58,11 +58,9 @@ ia64_emulate_brl (struct pt_regs *regs, unsigned long ar_ec)
 	unsigned long bundle[2];
 	unsigned long opcode, btype, qp, offset, cpl;
 	unsigned long next_ip;
-	struct siginfo siginfo;
 	struct illegal_op_return rv;
 	long tmp_taken, unimplemented_address;
 
-	clear_siginfo(&siginfo);
 	rv.fkt = (unsigned long) -1;
 
 	/*
@@ -198,39 +196,22 @@ ia64_emulate_brl (struct pt_regs *regs, unsigned long ar_ec)
 		 *  The target address contains unimplemented bits.
 		 */
 		printk(KERN_DEBUG "Woah! Unimplemented Instruction Address Trap!\n");
-		siginfo.si_signo = SIGILL;
-		siginfo.si_errno = 0;
-		siginfo.si_flags = 0;
-		siginfo.si_isr = 0;
-		siginfo.si_imm = 0;
-		siginfo.si_code = ILL_BADIADDR;
-		force_sig_info(SIGILL, &siginfo, current);
+		force_sig_fault(SIGILL, ILL_BADIADDR, (void __user *)NULL,
+				0, 0, 0, current);
 	} else if (ia64_psr(regs)->tb) {
 		/*
 		 *  Branch Tracing is enabled.
 		 *  Force a taken branch signal.
 		 */
-		siginfo.si_signo = SIGTRAP;
-		siginfo.si_errno = 0;
-		siginfo.si_code = TRAP_BRANCH;
-		siginfo.si_flags = 0;
-		siginfo.si_isr = 0;
-		siginfo.si_addr = 0;
-		siginfo.si_imm = 0;
-		force_sig_info(SIGTRAP, &siginfo, current);
+		force_sig_fault(SIGTRAP, TRAP_BRANCH, (void __user *)NULL,
+				0, 0, 0, current);
 	} else if (ia64_psr(regs)->ss) {
 		/*
 		 *  Single Step is enabled.
 		 *  Force a trace signal.
 		 */
-		siginfo.si_signo = SIGTRAP;
-		siginfo.si_errno = 0;
-		siginfo.si_code = TRAP_TRACE;
-		siginfo.si_flags = 0;
-		siginfo.si_isr = 0;
-		siginfo.si_addr = 0;
-		siginfo.si_imm = 0;
-		force_sig_info(SIGTRAP, &siginfo, current);
+		force_sig_fault(SIGTRAP, TRAP_TRACE, (void __user *)NULL,
+				0, 0, 0, current);
 	}
 	return rv;
 }
diff --git a/arch/ia64/kernel/traps.c b/arch/ia64/kernel/traps.c
index c6f4932073a1..85d8616ac4f6 100644
--- a/arch/ia64/kernel/traps.c
+++ b/arch/ia64/kernel/traps.c
@@ -100,16 +100,8 @@ die_if_kernel (char *str, struct pt_regs *regs, long err)
 void
 __kprobes ia64_bad_break (unsigned long break_num, struct pt_regs *regs)
 {
-	siginfo_t siginfo;
 	int sig, code;
 
-	/* SIGILL, SIGFPE, SIGSEGV, and SIGBUS want these field initialized: */
-	clear_siginfo(&siginfo);
-	siginfo.si_addr = (void __user *) (regs->cr_iip + ia64_psr(regs)->ri);
-	siginfo.si_imm = break_num;
-	siginfo.si_flags = 0;		/* clear __ISR_VALID */
-	siginfo.si_isr = 0;
-
 	switch (break_num) {
 	      case 0: /* unknown error (used by GCC for __builtin_abort()) */
 		if (notify_die(DIE_BREAK, "break 0", regs, break_num, TRAP_BRKPT, SIGTRAP)
@@ -182,10 +174,9 @@ __kprobes ia64_bad_break (unsigned long break_num, struct pt_regs *regs)
 			sig = SIGTRAP; code = TRAP_BRKPT;
 		}
 	}
-	siginfo.si_signo = sig;
-	siginfo.si_errno = 0;
-	siginfo.si_code = code;
-	force_sig_info(sig, &siginfo, current);
+	force_sig_fault(sig, code,
+			(void __user *) (regs->cr_iip + ia64_psr(regs)->ri),
+			break_num, 0 /* clear __ISR_VALID */, 0, current);
 }
 
 /*
@@ -344,30 +335,25 @@ handle_fpu_swa (int fp_fault, struct pt_regs *regs, unsigned long isr)
 			printk(KERN_ERR "handle_fpu_swa: fp_emulate() returned -1\n");
 			return -1;
 		} else {
-			struct siginfo siginfo;
-
 			/* is next instruction a trap? */
+			int si_code;
+
 			if (exception & 2) {
 				ia64_increment_ip(regs);
 			}
-			clear_siginfo(&siginfo);
-			siginfo.si_signo = SIGFPE;
-			siginfo.si_errno = 0;
-			siginfo.si_code = FPE_FLTUNK;	/* default code */
-			siginfo.si_addr = (void __user *) (regs->cr_iip + ia64_psr(regs)->ri);
+			si_code = FPE_FLTUNK;	/* default code */
 			if (isr & 0x11) {
-				siginfo.si_code = FPE_FLTINV;
+				si_code = FPE_FLTINV;
 			} else if (isr & 0x22) {
 				/* denormal operand gets the same si_code as underflow 
 				* see arch/i386/kernel/traps.c:math_error()  */
-				siginfo.si_code = FPE_FLTUND;
+				si_code = FPE_FLTUND;
 			} else if (isr & 0x44) {
-				siginfo.si_code = FPE_FLTDIV;
+				si_code = FPE_FLTDIV;
 			}
-			siginfo.si_isr = isr;
-			siginfo.si_flags = __ISR_VALID;
-			siginfo.si_imm = 0;
-			force_sig_info(SIGFPE, &siginfo, current);
+			force_sig_fault(SIGFPE, si_code,
+					(void __user *) (regs->cr_iip + ia64_psr(regs)->ri),
+					0, __ISR_VALID, isr, current);
 		}
 	} else {
 		if (exception = -1) {
@@ -375,24 +361,19 @@ handle_fpu_swa (int fp_fault, struct pt_regs *regs, unsigned long isr)
 			return -1;
 		} else if (exception != 0) {
 			/* raise exception */
-			struct siginfo siginfo;
+			int si_code;
 
-			clear_siginfo(&siginfo);
-			siginfo.si_signo = SIGFPE;
-			siginfo.si_errno = 0;
-			siginfo.si_code = FPE_FLTUNK;	/* default code */
-			siginfo.si_addr = (void __user *) (regs->cr_iip + ia64_psr(regs)->ri);
+			si_code = FPE_FLTUNK;	/* default code */
 			if (isr & 0x880) {
-				siginfo.si_code = FPE_FLTOVF;
+				si_code = FPE_FLTOVF;
 			} else if (isr & 0x1100) {
-				siginfo.si_code = FPE_FLTUND;
+				si_code = FPE_FLTUND;
 			} else if (isr & 0x2200) {
-				siginfo.si_code = FPE_FLTRES;
+				si_code = FPE_FLTRES;
 			}
-			siginfo.si_isr = isr;
-			siginfo.si_flags = __ISR_VALID;
-			siginfo.si_imm = 0;
-			force_sig_info(SIGFPE, &siginfo, current);
+			force_sig_fault(SIGFPE, si_code,
+					(void __user *) (regs->cr_iip + ia64_psr(regs)->ri),
+					0, __ISR_VALID, isr, current);
 		}
 	}
 	return 0;
@@ -408,7 +389,6 @@ ia64_illegal_op_fault (unsigned long ec, long arg1, long arg2, long arg3,
 		       struct pt_regs regs)
 {
 	struct illegal_op_return rv;
-	struct siginfo si;
 	char buf[128];
 
 #ifdef CONFIG_IA64_BRL_EMU
@@ -426,11 +406,9 @@ ia64_illegal_op_fault (unsigned long ec, long arg1, long arg2, long arg3,
 	if (die_if_kernel(buf, &regs, 0))
 		return rv;
 
-	clear_siginfo(&si);
-	si.si_signo = SIGILL;
-	si.si_code = ILL_ILLOPC;
-	si.si_addr = (void __user *) (regs.cr_iip + ia64_psr(&regs)->ri);
-	force_sig_info(SIGILL, &si, current);
+	force_sig_fault(SIGILL, ILL_ILLOPC,
+			(void __user *) (regs.cr_iip + ia64_psr(&regs)->ri),
+			0, 0, 0, current);
 	return rv;
 }
 
@@ -441,7 +419,7 @@ ia64_fault (unsigned long vector, unsigned long isr, unsigned long ifa,
 {
 	unsigned long code, error = isr, iip;
 	char buf[128];
-	int result, sig;
+	int result, sig, si_code;
 	static const char *reason[] = {
 		"IA-64 Illegal Operation fault",
 		"IA-64 Privileged Operation fault",
@@ -490,7 +468,6 @@ ia64_fault (unsigned long vector, unsigned long isr, unsigned long ifa,
 
 	      case 26: /* NaT Consumption */
 		if (user_mode(&regs)) {
-			struct siginfo siginfo;
 			void __user *addr;
 
 			if (((isr >> 4) & 0xf) = 2) {
@@ -505,15 +482,8 @@ ia64_fault (unsigned long vector, unsigned long isr, unsigned long ifa,
 				addr = (void __user *) (regs.cr_iip
 							+ ia64_psr(&regs)->ri);
 			}
-			clear_siginfo(&siginfo);
-			siginfo.si_signo = sig;
-			siginfo.si_code = code;
-			siginfo.si_errno = 0;
-			siginfo.si_addr = addr;
-			siginfo.si_imm = vector;
-			siginfo.si_flags = __ISR_VALID;
-			siginfo.si_isr = isr;
-			force_sig_info(sig, &siginfo, current);
+			force_sig_fault(sig, code, addr,
+					vector, __ISR_VALID, isr, current);
 			return;
 		} else if (ia64_done_with_exception(&regs))
 			return;
@@ -522,17 +492,8 @@ ia64_fault (unsigned long vector, unsigned long isr, unsigned long ifa,
 
 	      case 31: /* Unsupported Data Reference */
 		if (user_mode(&regs)) {
-			struct siginfo siginfo;
-
-			clear_siginfo(&siginfo);
-			siginfo.si_signo = SIGILL;
-			siginfo.si_code = ILL_ILLOPN;
-			siginfo.si_errno = 0;
-			siginfo.si_addr = (void __user *) iip;
-			siginfo.si_imm = vector;
-			siginfo.si_flags = __ISR_VALID;
-			siginfo.si_isr = isr;
-			force_sig_info(SIGILL, &siginfo, current);
+			force_sig_fault(SIGILL, ILL_ILLOPN, (void __user *) iip,
+					vector, __ISR_VALID, isr, current);
 			return;
 		}
 		sprintf(buf, "Unsupported data reference");
@@ -541,10 +502,6 @@ ia64_fault (unsigned long vector, unsigned long isr, unsigned long ifa,
 	      case 29: /* Debug */
 	      case 35: /* Taken Branch Trap */
 	      case 36: /* Single Step Trap */
-	      {
-		struct siginfo siginfo;
-
-		clear_siginfo(&siginfo);
 		if (fsys_mode(current, &regs)) {
 			extern char __kernel_syscall_via_break[];
 			/*
@@ -568,7 +525,7 @@ ia64_fault (unsigned long vector, unsigned long isr, unsigned long ifa,
 		switch (vector) {
 		      default:
 		      case 29:
-			siginfo.si_code = TRAP_HWBKPT;
+			si_code = TRAP_HWBKPT;
 #ifdef CONFIG_ITANIUM
 			/*
 			 * Erratum 10 (IFA may contain incorrect address) now has
@@ -578,37 +535,22 @@ ia64_fault (unsigned long vector, unsigned long isr, unsigned long ifa,
 			  ifa = regs.cr_iip;
 #endif
 			break;
-		      case 35: siginfo.si_code = TRAP_BRANCH; ifa = 0; break;
-		      case 36: siginfo.si_code = TRAP_TRACE; ifa = 0; break;
+		      case 35: si_code = TRAP_BRANCH; ifa = 0; break;
+		      case 36: si_code = TRAP_TRACE; ifa = 0; break;
 		}
-		if (notify_die(DIE_FAULT, "ia64_fault", &regs, vector, siginfo.si_code, SIGTRAP)
+		if (notify_die(DIE_FAULT, "ia64_fault", &regs, vector, si_code, SIGTRAP)
 			       	= NOTIFY_STOP)
 			return;
-		siginfo.si_signo = SIGTRAP;
-		siginfo.si_errno = 0;
-		siginfo.si_addr  = (void __user *) ifa;
-		siginfo.si_imm   = 0;
-		siginfo.si_flags = __ISR_VALID;
-		siginfo.si_isr   = isr;
-		force_sig_info(SIGTRAP, &siginfo, current);
+		force_sig_fault(SIGTRAP, si_code, (void __user *) ifa,
+				0, __ISR_VALID, isr, current);
 		return;
-	      }
 
 	      case 32: /* fp fault */
 	      case 33: /* fp trap */
 		result = handle_fpu_swa((vector = 32) ? 1 : 0, &regs, isr);
 		if ((result < 0) || (current->thread.flags & IA64_THREAD_FPEMU_SIGFPE)) {
-			struct siginfo siginfo;
-
-			clear_siginfo(&siginfo);
-			siginfo.si_signo = SIGFPE;
-			siginfo.si_errno = 0;
-			siginfo.si_code = FPE_FLTINV;
-			siginfo.si_addr = (void __user *) iip;
-			siginfo.si_flags = __ISR_VALID;
-			siginfo.si_isr = isr;
-			siginfo.si_imm = 0;
-			force_sig_info(SIGFPE, &siginfo, current);
+			force_sig_fault(SIGFPE, FPE_FLTINV, (void __user *) iip,
+					0, __ISR_VALID, isr, current);
 		}
 		return;
 
@@ -634,17 +576,9 @@ ia64_fault (unsigned long vector, unsigned long isr, unsigned long ifa,
 		} else {
 			/* Unimplemented Instr. Address Trap */
 			if (user_mode(&regs)) {
-				struct siginfo siginfo;
-
-				clear_siginfo(&siginfo);
-				siginfo.si_signo = SIGILL;
-				siginfo.si_code = ILL_BADIADDR;
-				siginfo.si_errno = 0;
-				siginfo.si_flags = 0;
-				siginfo.si_isr = 0;
-				siginfo.si_imm = 0;
-				siginfo.si_addr = (void __user *) iip;
-				force_sig_info(SIGILL, &siginfo, current);
+				force_sig_fault(SIGILL, ILL_BADIADDR,
+						(void __user *) iip,
+						0, 0, 0, current);
 				return;
 			}
 			sprintf(buf, "Unimplemented Instruction Address fault");
diff --git a/arch/ia64/kernel/unaligned.c b/arch/ia64/kernel/unaligned.c
index e309f9859acc..a167a3824b35 100644
--- a/arch/ia64/kernel/unaligned.c
+++ b/arch/ia64/kernel/unaligned.c
@@ -1298,7 +1298,6 @@ ia64_handle_unaligned (unsigned long ifa, struct pt_regs *regs)
 	mm_segment_t old_fs = get_fs();
 	unsigned long bundle[2];
 	unsigned long opcode;
-	struct siginfo si;
 	const struct exception_table_entry *eh = NULL;
 	union {
 		unsigned long l;
@@ -1537,14 +1536,7 @@ ia64_handle_unaligned (unsigned long ifa, struct pt_regs *regs)
 		/* NOT_REACHED */
 	}
   force_sigbus:
-	clear_siginfo(&si);
-	si.si_signo = SIGBUS;
-	si.si_errno = 0;
-	si.si_code = BUS_ADRALN;
-	si.si_addr = (void __user *) ifa;
-	si.si_flags = 0;
-	si.si_isr = 0;
-	si.si_imm = 0;
-	force_sig_info(SIGBUS, &si, current);
+	force_sig_fault(SIGBUS, BUS_ADRALN, (void __user *) ifa,
+			0, 0, 0, current);
 	goto done;
 }
diff --git a/arch/ia64/mm/fault.c b/arch/ia64/mm/fault.c
index a9d55ad8d67b..5baeb022f474 100644
--- a/arch/ia64/mm/fault.c
+++ b/arch/ia64/mm/fault.c
@@ -248,16 +248,8 @@ ia64_do_page_fault (unsigned long address, unsigned long isr, struct pt_regs *re
 		return;
 	}
 	if (user_mode(regs)) {
-		struct siginfo si;
-
-		clear_siginfo(&si);
-		si.si_signo = signal;
-		si.si_errno = 0;
-		si.si_code = code;
-		si.si_addr = (void __user *) address;
-		si.si_isr = isr;
-		si.si_flags = __ISR_VALID;
-		force_sig_info(signal, &si, current);
+		force_sig_fault(signal, code, (void __user *) address,
+				0, __ISR_VALID, isr, current);
 		return;
 	}
 
-- 
2.17.1
