From: "Hoeflinger, Jay P" <jay.p.hoeflinger@intel.com>
Date: Mon, 25 Feb 2002 17:07:29 +0000
Subject: RE: [Linux-ia64] determining read or write on a page fault
Message-Id: <marc-linux-ia64-105590701905187@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905163@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905163@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Thanks, David.  Which released version will this appear in?

Jay

-----Original Message-----
From: David Mosberger [mailto:davidm@hpl.hp.com]
Sent: Friday, February 22, 2002 7:25 PM
To: Hoeflinger, Jay P
Cc: linux-ia64@linuxia64.org
Subject: RE: [Linux-ia64] determining read or write on a page fault


If you want to try with a new kernel, the attached patch should give
you what you want.  Specifically, if you get a SIGSEGV or a SIGBUS and
si_code is non-zero, you can check si_flags.  If it has the
__ISR_VALID flag set, then the code in si_isr is valid.  If si_isr is
valid, you can check whether bit 34 (read exception) or bit 35
(non-access exception) is set.  If so, you may assume that the signal
was due to a load (or lfetch or some such).  In all other cases, you'd
have to play it safe and assume that you're dealing with a write
access.

	--david

diff -urN linux-2.4.17/arch/ia64/ia32/ia32_support.c
lia64-2.4/arch/ia64/ia32/ia32_support.c
--- linux-2.4.17/arch/ia64/ia32/ia32_support.c	Mon Nov 26 11:18:20 2001
+++ lia64-2.4/arch/ia64/ia32/ia32_support.c	Fri Feb 22 16:37:53 2002
@@ -172,6 +174,10 @@
 
 	siginfo.si_signo = SIGTRAP;
 	siginfo.si_errno = int_num;	/* XXX is it OK to abuse si_errno
like this? */
+	siginfo.si_flags = 0;
+	siginfo.si_isr = 0;
+	siginfo.si_addr = 0;
+	siginfo.si_imm = 0;
 	siginfo.si_code = TRAP_BRKPT;
 	force_sig_info(SIGTRAP, &siginfo, current);
 }
diff -urN linux-2.4.17/arch/ia64/ia32/ia32_traps.c
lia64-2.4/arch/ia64/ia32/ia32_traps.c
--- linux-2.4.17/arch/ia64/ia32/ia32_traps.c	Mon Nov 26 11:18:20 2001
+++ lia64-2.4/arch/ia64/ia32/ia32_traps.c	Fri Feb 22 16:32:45 2002
@@ -2,7 +2,7 @@
  * IA-32 exception handlers
  *
  * Copyright (C) 2000 Asit K. Mallick <asit.k.mallick@intel.com>
- * Copyright (C) 2001 Hewlett-Packard Co
+ * Copyright (C) 2001-2002 Hewlett-Packard Co
  *	David Mosberger-Tang <davidm@hpl.hp.com>
  *
  * 06/16/00	A. Mallick	added siginfo for most cases (close to IA32)
@@ -40,7 +40,11 @@
 {
 	struct siginfo siginfo;
 
+	/* initialize these fields to avoid leaking kernel bits to user
space: */
 	siginfo.si_errno = 0;
+	siginfo.si_flags = 0;
+	siginfo.si_isr = 0;
+	siginfo.si_imm = 0;
 	switch ((isr >> 16) & 0xff) {
 	      case 1:
 	      case 2:
@@ -103,6 +107,8 @@
 			 * and it will suffer the consequences since we
won't be able to
 			 * fully reproduce the context of the exception
 			 */
+			siginfo.si_isr = isr;
+			siginfo.si_flags = __ISR_VALID;
 			switch(((~fcr) & (fsr & 0x3f)) | (fsr & 0x240)) {
 				case 0x000:
 				default:
diff -urN linux-2.4.17/arch/ia64/kernel/brl_emu.c
lia64-2.4/arch/ia64/kernel/brl_emu.c
--- linux-2.4.17/arch/ia64/kernel/brl_emu.c	Thu Apr  5 12:51:47 2001
+++ lia64-2.4/arch/ia64/kernel/brl_emu.c	Fri Feb 22 16:39:55 2002
@@ -195,6 +195,9 @@
 		printk("Woah! Unimplemented Instruction Address Trap!\n");
 		siginfo.si_signo = SIGILL;
 		siginfo.si_errno = 0;
+		siginfo.si_flags = 0;
+		siginfo.si_isr = 0;
+		siginfo.si_imm = 0;
 		siginfo.si_code = ILL_BADIADDR;
 		force_sig_info(SIGILL, &siginfo, current);
 	} else if (ia64_psr(regs)->tb) {
@@ -205,6 +208,10 @@
 		siginfo.si_signo = SIGTRAP;
 		siginfo.si_errno = 0;
 		siginfo.si_code = TRAP_BRANCH;
+		siginfo.si_flags = 0;
+		siginfo.si_isr = 0;
+		siginfo.si_addr = 0;
+		siginfo.si_imm = 0;
 		force_sig_info(SIGTRAP, &siginfo, current);
 	} else if (ia64_psr(regs)->ss) {
 		/*
@@ -214,6 +221,10 @@
 		siginfo.si_signo = SIGTRAP;
 		siginfo.si_errno = 0;
 		siginfo.si_code = TRAP_TRACE;
+		siginfo.si_flags = 0;
+		siginfo.si_isr = 0;
+		siginfo.si_addr = 0;
+		siginfo.si_imm = 0;
 		force_sig_info(SIGTRAP, &siginfo, current);
 	}
 	return rv;
diff -urN linux-2.4.17/arch/ia64/kernel/signal.c
lia64-2.4/arch/ia64/kernel/signal.c
--- linux-2.4.17/arch/ia64/kernel/signal.c	Mon Nov 26 11:18:24 2001
+++ lia64-2.4/arch/ia64/kernel/signal.c	Fri Feb 22 16:04:49 2002
@@ -160,6 +160,7 @@
 		err |= __put_user((short)from->si_code, &to->si_code);
 		switch (from->si_code >> 16) {
 		      case __SI_FAULT >> 16:
+			err |= __put_user(from->si_flags, &to->si_flags);
 			err |= __put_user(from->si_isr, &to->si_isr);
 		      case __SI_POLL >> 16:
 			err |= __put_user(from->si_addr, &to->si_addr);
diff -urN linux-2.4.17/arch/ia64/kernel/traps.c
lia64-2.4/arch/ia64/kernel/traps.c
--- linux-2.4.17/arch/ia64/kernel/traps.c	Mon Nov 26 11:18:24 2001
+++ lia64-2.4/arch/ia64/kernel/traps.c	Fri Feb 22 16:42:59 2002
@@ -1,7 +1,7 @@
 /*
  * Architecture-specific trap handling.
  *
- * Copyright (C) 1998-2001 Hewlett-Packard Co
+ * Copyright (C) 1998-2002 Hewlett-Packard Co
  *	David Mosberger-Tang <davidm@hpl.hp.com>
  *
  * 05/12/00 grao <goutham.rao@intel.com> : added isr in siginfo for SIGFPE
@@ -133,6 +133,8 @@
 	/* SIGILL, SIGFPE, SIGSEGV, and SIGBUS want these field initialized:
*/
 	siginfo.si_addr = (void *) (regs->cr_iip + ia64_psr(regs)->ri);
 	siginfo.si_imm = break_num;
+	siginfo.si_flags = 0;		/* clear __ISR_VALID */
+	siginfo.si_isr = 0;
 
 	switch (break_num) {
 	      case 0: /* unknown error */
@@ -352,6 +354,8 @@
 				siginfo.si_code = FPE_FLTDIV;
 			}
 			siginfo.si_isr = isr;
+			siginfo.si_flags = __ISR_VALID;
+			siginfo.si_imm = 0;
 			force_sig_info(SIGFPE, &siginfo, current);
 		}
 	} else {
@@ -372,6 +376,8 @@
 				siginfo.si_code = FPE_FLTRES;
 			}
 			siginfo.si_isr = isr;
+			siginfo.si_flags = __ISR_VALID;
+			siginfo.si_imm = 0;
 			force_sig_info(SIGFPE, &siginfo, current);
 		}
 	}
@@ -490,6 +496,8 @@
 			siginfo.si_errno = 0;
 			siginfo.si_addr = (void *) (regs->cr_iip +
ia64_psr(regs)->ri);
 			siginfo.si_imm = vector;
+			siginfo.si_flags = __ISR_VALID;
+			siginfo.si_isr = isr;
 			force_sig_info(SIGILL, &siginfo, current);
 			return;
 		}
@@ -517,6 +525,10 @@
 		}
 		siginfo.si_signo = SIGTRAP;
 		siginfo.si_errno = 0;
+		siginfo.si_flags = 0;
+		siginfo.si_isr = 0;
+		siginfo.si_addr = 0;
+		siginfo.si_imm = 0;
 		force_sig_info(SIGTRAP, &siginfo, current);
 		return;
 
@@ -528,6 +540,9 @@
 			siginfo.si_errno = 0;
 			siginfo.si_code = FPE_FLTINV;
 			siginfo.si_addr = (void *) (regs->cr_iip +
ia64_psr(regs)->ri);
+			siginfo.si_flags = __ISR_VALID;
+			siginfo.si_isr = isr;
+			siginfo.si_imm = 0;
 			force_sig_info(SIGFPE, &siginfo, current);
 		}
 		return;
@@ -537,6 +552,9 @@
 			siginfo.si_signo = SIGILL;
 			siginfo.si_code = ILL_BADIADDR;
 			siginfo.si_errno = 0;
+			siginfo.si_flags = 0;
+			siginfo.si_isr = 0;
+			siginfo.si_imm = 0;
 			siginfo.si_addr = (void *) (regs->cr_iip +
ia64_psr(regs)->ri);
 			force_sig_info(SIGILL, &siginfo, current);
 			return;
diff -urN linux-2.4.17/arch/ia64/kernel/unaligned.c
lia64-2.4/arch/ia64/kernel/unaligned.c
--- linux-2.4.17/arch/ia64/kernel/unaligned.c	Mon Nov 26 11:18:24 2001
+++ lia64-2.4/arch/ia64/kernel/unaligned.c	Fri Feb 22 16:36:18 2002
@@ -1488,6 +1488,9 @@
 	si.si_errno = 0;
 	si.si_code = BUS_ADRALN;
 	si.si_addr = (void *) ifa;
+	si.si_flags = 0;
+	si.si_isr = 0;
+	si.si_imm = 0;
 	force_sig_info(SIGBUS, &si, current);
 	goto done;
 }
diff -urN linux-2.4.17/arch/ia64/mm/fault.c lia64-2.4/arch/ia64/mm/fault.c
--- linux-2.4.17/arch/ia64/mm/fault.c	Mon Nov 26 11:18:25 2001
+++ lia64-2.4/arch/ia64/mm/fault.c	Fri Feb 22 15:52:41 2002
@@ -151,6 +151,8 @@
 		si.si_errno = 0;
 		si.si_code = code;
 		si.si_addr = (void *) address;
+		si.si_isr = isr;
+		si.si_flags = __ISR_VALID;
 		force_sig_info(signal, &si, current);
 		return;
 	}
diff -urN linux-2.4.17/include/asm-ia64/siginfo.h
lia64-2.4/include/asm-ia64/siginfo.h
--- linux-2.4.17/include/asm-ia64/siginfo.h	Wed Dec 26 16:58:57 2001
+++ lia64-2.4/include/asm-ia64/siginfo.h	Fri Feb 22 16:49:28 2002
@@ -2,8 +2,8 @@
 #define _ASM_IA64_SIGINFO_H
 
 /*
- * Copyright (C) 1998-2001 Hewlett-Packard Co
- * Copyright (C) 1998-2001 David Mosberger-Tang <davidm@hpl.hp.com>
+ * Copyright (C) 1998-2002 Hewlett-Packard Co
+ *	David Mosberger-Tang <davidm@hpl.hp.com>
  */
 
 #include <linux/types.h>
@@ -57,7 +57,7 @@
 		struct {
 			void *_addr;		/* faulting insn/memory ref.
*/
 			int _imm;		/* immediate value for
"break" */
-			int _pad0;
+			unsigned int _flags;	/* see below */
 			unsigned long _isr;	/* isr */
 		} _sigfault;
 
@@ -88,10 +88,21 @@
 #define si_ptr		_sifields._rt._sigval.sival_ptr
 #define si_addr		_sifields._sigfault._addr
 #define si_imm		_sifields._sigfault._imm	/* as per UNIX SysV
ABI spec */
-#define si_isr		_sifields._sigfault._isr	/* valid if
si_code=FPE_FLTxxx */
+#define si_flags	_sifields._sigfault._flags
+/*
+ * si_isr is valid for SIGILL, SIGFPE, SIGSEGV, SIGBUS, and SIGTRAP
provided that
+ * si_code is non-zero and __ISR_VALID is set in si_flags.
+ */
+#define si_isr		_sifields._sigfault._isr
 #define si_band		_sifields._sigpoll._band
 #define si_fd		_sifields._sigpoll._fd
 #define si_pfm_ovfl	_sifields._sigprof._pfm_ovfl_counters
+
+/*
+ * Flag values for si_flags:
+ */
+#define __ISR_VALID_BIT	0
+#define __ISR_VALID	(1 << __ISR_VALID_BIT)
 
 /*
  * si_code values

