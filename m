From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 26 Jan 2005 05:41:36 +0000
Subject: [patch] make traps.c fit in 80 cols
Message-Id: <16887.11664.560033.42501@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

$SUBJECT says it all...

Please apply.

Thanks,

	--david

Signed-off-by: David Mosberger-Tang <davidm@hpl.hp.com>

=== arch/ia64/kernel/traps.c 1.48 vs edited ==--- 1.48/arch/ia64/kernel/traps.c	2005-01-25 12:23:45 -08:00
+++ edited/arch/ia64/kernel/traps.c	2005-01-25 21:29:22 -08:00
@@ -1,7 +1,7 @@
 /*
  * Architecture-specific trap handling.
  *
- * Copyright (C) 1998-2003 Hewlett-Packard Co
+ * Copyright (C) 1998-2003, 2005 Hewlett-Packard Co
  *	David Mosberger-Tang <davidm@hpl.hp.com>
  *
  * 05/12/00 grao <goutham.rao@intel.com> : added isr in siginfo for SIGFPE
@@ -31,13 +31,16 @@
 trap_init (void)
 {
 	if (ia64_boot_param->fpswa)
-		/* FPSWA fixup: make the interface pointer a kernel virtual address: */
+		/*
+		 * FPSWA fixup: make the interface pointer a kernel
+		 * virtual address:
+		 */
 		fpswa_interface = __va(ia64_boot_param->fpswa);
 }
 
 /*
- * Unlock any spinlocks which will prevent us from getting the message out (timerlist_lock
- * is acquired through the console unblank code)
+ * Unlock any spinlocks which will prevent us from getting the message
+ * out (timerlist_lock is acquired through the console unblank code)
  */
 void
 bust_spinlocks (int yes)
@@ -54,11 +57,11 @@
 #endif
 	oops_in_progress = 0;
 	/*
-	 * OK, the message is on the console.  Now we call printk() without
-	 * oops_in_progress set so that printk will give klogd a poke.  Hold onto
-	 * your hats...
+	 * OK, the message is on the console.  Now we call printk()
+	 * without oops_in_progress set so that printk will give klogd
+	 * a poke.  Hold onto your hats...
 	 */
-	console_loglevel = 15;		/* NMI oopser may have shut the console up */
+	console_loglevel = 15;	/* NMI oopser may have shut the console up */
 	printk(" ");
 	console_loglevel = loglevel_save;
 }
@@ -87,10 +90,11 @@
 
 	if (++die.lock_owner_depth < 3) {
 		printk("%s[%d]: %s %ld [%d]\n",
-			current->comm, current->pid, str, err, ++die_counter);
+		       current->comm, current->pid, str, err, ++die_counter);
 		show_regs(regs);
   	} else
-		printk(KERN_ERR "Recursive die() failure, output suppressed\n");
+		printk(KERN_ERR
+		       "Recursive die() failure, output suppressed\n");
 
 	bust_spinlocks(0);
 	die.lock_owner = -1;
@@ -112,7 +116,7 @@
 	int sig, code;
 
 	/* SIGILL, SIGFPE, SIGSEGV, and SIGBUS want these field initialized: */
-	siginfo.si_addr = (void __user *) (regs->cr_iip + ia64_psr(regs)->ri);
+	siginfo.si_addr = (void __user *) instruction_pointer(regs);
 	siginfo.si_imm = break_num;
 	siginfo.si_flags = 0;		/* clear __ISR_VALID */
 	siginfo.si_isr = 0;
@@ -188,12 +192,13 @@
 }
 
 /*
- * disabled_fph_fault() is called when a user-level process attempts to access f32..f127
- * and it doesn't own the fp-high register partition.  When this happens, we save the
- * current fph partition in the task_struct of the fpu-owner (if necessary) and then load
- * the fp-high partition of the current task (if necessary).  Note that the kernel has
- * access to fph by the time we get here, as the IVT's "Disabled FP-Register" handler takes
- * care of clearing psr.dfh.
+ * disabled_fph_fault() is called when a user-level process attempts
+ * to access f32..f127 and it doesn't own the fp-high register
+ * partition.  When this happens, we save the current fph partition in
+ * the task_struct of the fpu-owner (if necessary) and then load the
+ * fp-high partition of the current task (if necessary).  Note that
+ * the kernel has access to fph by the time we get here, as the IVT's
+ * "Disabled FP-Register" handler takes care of clearing psr.dfh.
  */
 static inline void
 disabled_fph_fault (struct pt_regs *regs)
@@ -221,16 +226,16 @@
 	} else {
 		__ia64_init_fpu();
 		/*
-		 * Set mfh because the state in thread.fph does not match the state in
-		 * the fph partition.
+		 * Set mfh because the state in thread.fph does not
+		 * match the state in the fph partition.
 		 */
 		psr->mfh = 1;
 	}
 }
 
 static inline int
-fp_emulate (int fp_fault, void *bundle, long *ipsr, long *fpsr, long *isr, long *pr, long *ifs,
-	    struct pt_regs *regs)
+fp_emulate (int fp_fault, void *bundle, long *ipsr, long *fpsr, long *isr,
+	    long *pr, long *ifs, struct pt_regs *regs)
 {
 	fp_state_t fp_state;
 	fpswa_ret_t ret;
@@ -260,8 +265,10 @@
 	 *	void             *fp_state);
 	 */
 	ret = (*fpswa_interface->fpswa)((unsigned long) fp_fault, bundle,
-					(unsigned long *) ipsr, (unsigned long *) fpsr,
-					(unsigned long *) isr, (unsigned long *) pr,
+					(unsigned long *) ipsr,
+					(unsigned long *) fpsr,
+					(unsigned long *) isr,
+					(unsigned long *) pr,
 					(unsigned long *) ifs, &fp_state);
 
 	return ret.status;
@@ -274,7 +281,7 @@
 handle_fpu_swa (int fp_fault, struct pt_regs *regs, unsigned long isr)
 {
 	long exception, bundle[2];
-	unsigned long fault_ip;
+	unsigned long fault_ip, ip = instruction_pointer(regs);
 	struct siginfo siginfo;
 	static int fpu_swa_count = 0;
 	static unsigned long last_time;
@@ -287,22 +294,26 @@
 
 	if (jiffies - last_time > 5*HZ)
 		fpu_swa_count = 0;
-	if ((fpu_swa_count < 4) && !(current->thread.flags & IA64_THREAD_FPEMU_NOPRINT)) {
+	if ((fpu_swa_count < 4)
+	    && !(current->thread.flags & IA64_THREAD_FPEMU_NOPRINT))
+	{
 		last_time = jiffies;
 		++fpu_swa_count;
-		printk(KERN_WARNING
-		       "%s(%d): floating-point assist fault at ip %016lx, isr %016lx\n",
-		       current->comm, current->pid, regs->cr_iip + ia64_psr(regs)->ri, isr);
+		printk(KERN_WARNING "%s(%d): floating-point assist fault "
+		       "at ip %016lx, isr %016lx\n", current->comm,
+		       current->pid, ip, isr);
 	}
 
-	exception = fp_emulate(fp_fault, bundle, &regs->cr_ipsr, &regs->ar_fpsr, &isr, &regs->pr,
+	exception = fp_emulate(fp_fault, bundle, &regs->cr_ipsr,
+			       &regs->ar_fpsr, &isr, &regs->pr,
 			       &regs->cr_ifs, regs);
 	if (fp_fault) {
 		if (exception = 0) {
 			/* emulation was successful */
 			ia64_increment_ip(regs);
 		} else if (exception = -1) {
-			printk(KERN_ERR "handle_fpu_swa: fp_emulate() returned -1\n");
+			printk(KERN_ERR
+			       "handle_fpu_swa: fp_emulate() returned -1\n");
 			return -1;
 		} else {
 			/* is next instruction a trap? */
@@ -312,12 +323,15 @@
 			siginfo.si_signo = SIGFPE;
 			siginfo.si_errno = 0;
 			siginfo.si_code = __SI_FAULT;	/* default code */
-			siginfo.si_addr = (void __user *) (regs->cr_iip + ia64_psr(regs)->ri);
+			siginfo.si_addr = (void __user *) ip;
 			if (isr & 0x11) {
 				siginfo.si_code = FPE_FLTINV;
 			} else if (isr & 0x22) {
-				/* denormal operand gets the same si_code as underflow 
-				* see arch/i386/kernel/traps.c:math_error()  */
+				/*
+				 * Denormal operand gets the same
+				 * si_code as underflow see
+				 * arch/i386/kernel/traps.c:math_error()
+				 */
 				siginfo.si_code = FPE_FLTUND;
 			} else if (isr & 0x44) {
 				siginfo.si_code = FPE_FLTDIV;
@@ -329,14 +343,15 @@
 		}
 	} else {
 		if (exception = -1) {
-			printk(KERN_ERR "handle_fpu_swa: fp_emulate() returned -1\n");
+			printk(KERN_ERR "handle_fpu_swa: fp_emulate() "
+			       "returned -1\n");
 			return -1;
 		} else if (exception != 0) {
 			/* raise exception */
 			siginfo.si_signo = SIGFPE;
 			siginfo.si_errno = 0;
 			siginfo.si_code = __SI_FAULT;	/* default code */
-			siginfo.si_addr = (void __user *) (regs->cr_iip + ia64_psr(regs)->ri);
+			siginfo.si_addr = (void __user *) ip;
 			if (isr & 0x880) {
 				siginfo.si_code = FPE_FLTOVF;
 			} else if (isr & 0x1100) {
@@ -368,7 +383,8 @@
 
 #ifdef CONFIG_IA64_BRL_EMU
 	{
-		extern struct illegal_op_return ia64_emulate_brl (struct pt_regs *, unsigned long);
+		extern struct illegal_op_return
+			ia64_emulate_brl (struct pt_regs *, unsigned long);
 
 		rv = ia64_emulate_brl(&regs, ec);
 		if (rv.fkt != (unsigned long) -1)
@@ -382,7 +398,7 @@
 	memset(&si, 0, sizeof(si));
 	si.si_signo = SIGILL;
 	si.si_code = ILL_ILLOPC;
-	si.si_addr = (void __user *) (regs.cr_iip + ia64_psr(&regs)->ri);
+	si.si_addr = (void __user *) instruction_pointer(&regs);
 	force_sig_info(SIGILL, &si, current);
 	rv.fkt = 0;
 	return rv;
@@ -403,33 +419,40 @@
 		"IA-64 Privileged Register fault",
 		"IA-64 Reserved Register/Field fault",
 		"Disabled Instruction Set Transition fault",
-		"Unknown fault 5", "Unknown fault 6", "Unknown fault 7", "Illegal Hazard fault",
-		"Unknown fault 9", "Unknown fault 10", "Unknown fault 11", "Unknown fault 12",
+		"Unknown fault 5",
+		"Unknown fault 6",
+		"Unknown fault 7",
+		"Illegal Hazard fault",
+		"Unknown fault 9",
+		"Unknown fault 10", "Unknown fault 11", "Unknown fault 12",
 		"Unknown fault 13", "Unknown fault 14", "Unknown fault 15"
 	};
 
-	if ((isr & IA64_ISR_NA) && ((isr & IA64_ISR_CODE_MASK) = IA64_ISR_CODE_LFETCH)) {
+	if ((isr & IA64_ISR_NA)
+	    && ((isr & IA64_ISR_CODE_MASK) = IA64_ISR_CODE_LFETCH))
+	{
 		/*
-		 * This fault was due to lfetch.fault, set "ed" bit in the psr to cancel
-		 * the lfetch.
+		 * This fault was due to lfetch.fault, set "ed" bit in
+		 * the psr to cancel the lfetch.
 		 */
 		ia64_psr(&regs)->ed = 1;
 		return;
 	}
 
-	iip = regs.cr_iip + ia64_psr(&regs)->ri;
+	iip = instruction_pointer(&regs);
 
 	switch (vector) {
 	      case 24: /* General Exception */
 		code = (isr >> 4) & 0xf;
 		sprintf(buf, "General Exception: %s%s", reason[code],
 			(code = 3) ? ((isr & (1UL << 37))
-				       ? " (RSE access)" : " (data access)") : "");
+				       ? " (RSE access)" : " (data access)")
+			: "");
 		if (code = 8) {
 # ifdef CONFIG_IA64_PRINT_HAZARDS
-			printk("%s[%d]: possible hazard @ ip=%016lx (pr = %016lx)\n",
-			       current->comm, current->pid,
-			       regs.cr_iip + ia64_psr(&regs)->ri, regs.pr);
+			printk("%s[%d]: possible hazard @ ip=%016lx "
+			       "(pr = %016lx)\n", current->comm, current->pid,
+			       instruction_pointer(&regs), regs.pr);
 # endif
 			return;
 		}
@@ -456,8 +479,8 @@
 				/* register NaT consumption */
 				sig = SIGILL;
 				code = ILL_ILLOPN;
-				addr = (void __user *) (regs.cr_iip
-							+ ia64_psr(&regs)->ri);
+				addr = (void __user *)
+					instruction_pointer(&regs);
 			}
 			siginfo.si_signo = sig;
 			siginfo.si_code = code;
@@ -494,16 +517,18 @@
 		if (fsys_mode(current, &regs)) {
 			extern char __kernel_syscall_via_break[];
 			/*
-			 * Got a trap in fsys-mode: Taken Branch Trap and Single Step trap
-			 * need special handling; Debug trap is not supposed to happen.
+			 * Got a trap in fsys-mode: Taken Branch Trap
+			 * and Single Step trap need special handling;
+			 * Debug trap is not supposed to happen.
 			 */
 			if (unlikely(vector = 29)) {
-				die("Got debug trap in fsys-mode---not supposed to happen!",
-				    &regs, 0);
+				die("Got debug trap in fsys-mode---"
+				    "not supposed to happen!", &regs, 0);
 				return;
 			}
 			/* re-do the system call via break 0x100000: */
-			regs.cr_iip = (unsigned long) __kernel_syscall_via_break;
+			regs.cr_iip = (unsigned long)
+				__kernel_syscall_via_break;
 			ia64_psr(&regs)->ri = 0;
 			ia64_psr(&regs)->cpl = 3;
 			return;
@@ -513,8 +538,9 @@
 			siginfo.si_code = TRAP_HWBKPT;
 #ifdef CONFIG_ITANIUM
 			/*
-			 * Erratum 10 (IFA may contain incorrect address) now has
-			 * "NoFix" status.  There are no plans for fixing this.
+			 * Erratum 10 (IFA may contain incorrect
+			 * address) now has "NoFix" status.  There are
+			 * no plans for fixing this.
 			 */
 			if (ia64_psr(&regs)->is = 0)
 			  ifa = regs.cr_iip;
@@ -535,7 +561,9 @@
 	      case 32: /* fp fault */
 	      case 33: /* fp trap */
 		result = handle_fpu_swa((vector = 32) ? 1 : 0, &regs, isr);
-		if ((result < 0) || (current->thread.flags & IA64_THREAD_FPEMU_SIGFPE)) {
+		if ((result < 0)
+		    || (current->thread.flags & IA64_THREAD_FPEMU_SIGFPE))
+		{
 			siginfo.si_signo = SIGFPE;
 			siginfo.si_errno = 0;
 			siginfo.si_code = FPE_FLTINV;
@@ -551,9 +579,10 @@
 		if (isr & 0x2) {
 			/* Lower-Privilege Transfer Trap */
 			/*
-			 * Just clear PSR.lp and then return immediately: all the
-			 * interesting work (e.g., signal delivery is done in the kernel
-			 * exit path).
+			 * Just clear PSR.lp and then return
+			 * immediately: all the interesting work
+			 * (e.g., signal delivery is done in the
+			 * kernel exit path).
 			 */
 			ia64_psr(&regs)->lp = 0;
 			return;
@@ -570,7 +599,8 @@
 				force_sig_info(SIGILL, &siginfo, current);
 				return;
 			}
-			sprintf(buf, "Unimplemented Instruction Address fault");
+			sprintf(buf,
+				"Unimplemented Instruction Address fault");
 		}
 		break;
 
@@ -591,13 +621,14 @@
 			return;
 #endif
 		printk(KERN_ERR "Unexpected IA-32 intercept trap (Trap 46)\n");
-		printk(KERN_ERR "  iip - 0x%lx, ifa - 0x%lx, isr - 0x%lx, iim - 0x%lx\n",
-		       iip, ifa, isr, iim);
+		printk(KERN_ERR "  iip - 0x%lx, ifa - 0x%lx, "
+		       "isr - 0x%lx, iim - 0x%lx\n", iip, ifa, isr, iim);
 		force_sig(SIGSEGV, current);
 		return;
 
 	      case 47:
-		sprintf(buf, "IA-32 Interruption Fault (int 0x%lx)", isr >> 16);
+		sprintf(buf, "IA-32 Interruption Fault (int 0x%lx)",
+			isr >> 16);
 		break;
 
 	      default:
