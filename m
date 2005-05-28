From: Keith Owens <kaos@sgi.com>
Date: Sat, 28 May 2005 06:09:06 +0000
Subject: [patch 2.6.12-rc5] Extract correct break number for break.b
Message-Id: <21741.1117260546@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

break.b does not store the break number in cr.iim, instead it stores 0,
which makes all break.b instructions look like BUG().  Extract the
break number from the instruction itself.

Signed-off-by: Keith Owens <kaos@sgi.com>

Index: linux/arch/ia64/kernel/traps.c
=================================--- linux.orig/arch/ia64/kernel/traps.c	2005-05-28 14:37:42.648499458 +1000
+++ linux/arch/ia64/kernel/traps.c	2005-05-28 14:39:52.436651847 +1000
@@ -111,6 +111,24 @@ ia64_bad_break (unsigned long break_num,
 	siginfo_t siginfo;
 	int sig, code;
 
+	/* break.b always sets cr.iim to 0, which causes problems for
+	 * debuggers.  Get the real break number from the original instruction,
+	 * but only for kernel code.  User space break.b is left alone, to
+	 * preserve the existing behaviour.  All break codings have the same
+	 * format, so there is no need to check the slot type.
+	 */
+	if (break_num = 0 && !user_mode(regs)) {
+		struct ia64_psr *ipsr = ia64_psr(regs);
+		unsigned long *bundle = (unsigned long *)regs->cr_iip;
+		unsigned long slot;
+		switch (ipsr->ri) {
+		      case 0:  slot = (bundle[0] >>  5); break;
+		      case 1:  slot = (bundle[0] >> 46) | (bundle[1] << 18); break;
+		      default: slot = (bundle[1] >> 23); break;
+		}
+		break_num = ((slot >> 36 & 1) << 20) | (slot >> 6 & 0xfffff);
+	}
+
 	/* SIGILL, SIGFPE, SIGSEGV, and SIGBUS want these field initialized: */
 	siginfo.si_addr = (void __user *) (regs->cr_iip + ia64_psr(regs)->ri);
 	siginfo.si_imm = break_num;

