From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 06 Mar 2003 21:26:35 +0000
Subject: [Linux-ia64] fix for siginfo.si_addr on NaT page triggered SIGSEGV
Message-Id: <marc-linux-ia64-105590709805988@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The patch below fixes a bug which caused si_addr to be set to the
faulting IP instead of the faulting data address when a SIGSEGV got
triggered by the NaT page.  The patch is relative to 2.5, but I
believe it applies on 2.4 as well.

	--david

=== arch/ia64/kernel/traps.c 1.25 vs edited ==--- 1.25/arch/ia64/kernel/traps.c	Tue Feb  4 17:06:16 2003
+++ edited/arch/ia64/kernel/traps.c	Thu Mar  6 11:44:58 2003
@@ -486,19 +486,23 @@
 
 	      case 26: /* NaT Consumption */
 		if (user_mode(regs)) {
+			void *addr;
+
 			if (((isr >> 4) & 0xf) = 2) {
 				/* NaT page consumption */
 				sig = SIGSEGV;
 				code = SEGV_ACCERR;
+				addr = (void *) ifa;
 			} else {
 				/* register NaT consumption */
 				sig = SIGILL;
 				code = ILL_ILLOPN;
+				addr = (void *) (regs->cr_iip + ia64_psr(regs)->ri);
 			}
 			siginfo.si_signo = sig;
 			siginfo.si_code = code;
 			siginfo.si_errno = 0;
-			siginfo.si_addr = (void *) (regs->cr_iip + ia64_psr(regs)->ri);
+			siginfo.si_addr = addr;
 			siginfo.si_imm = vector;
 			siginfo.si_flags = __ISR_VALID;
 			siginfo.si_isr = isr;

