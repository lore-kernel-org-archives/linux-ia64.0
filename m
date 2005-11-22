From: Keshavamurthy Anil S <anil.s.keshavamurthy@intel.com>
Date: Tue, 22 Nov 2005 22:15:49 +0000
Subject: [PATCH] Remove getting break_num by decoding instruction
Message-Id: <20051122141549.A16679@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


break.b always sets cr.iim to 0 and the current code tries to
get the break_num by decoding instruction. However, their 
seems to be a race condition while reading the regs->cr_iip, 
as on other cpu the break.b at regs->cr_iip might have been 
replaced with the original instruction as a result of 
unregister_kprobe() and hence decoding instruction to 
obtain break_num will result in wrong value in this case.

Also includes changes to kprobes.c which now has to handle
break number zero.

Signed-off-by: Anil S Keshavamurthy <anil.s.keshavamurthy@intel.com>

--------------------------------------------------------------------
 arch/ia64/kernel/kprobes.c |    2 +-
 arch/ia64/kernel/traps.c   |   18 ------------------
 2 files changed, 1 insertion(+), 19 deletions(-)

Index: linux-2.6.15-rc1/arch/ia64/kernel/kprobes.c
=================================--- linux-2.6.15-rc1.orig/arch/ia64/kernel/kprobes.c
+++ linux-2.6.15-rc1/arch/ia64/kernel/kprobes.c
@@ -740,7 +740,7 @@ int __kprobes kprobe_exceptions_notify(s
 	switch(val) {
 	case DIE_BREAK:
 		/* err is break number from ia64_bad_break() */
-		if (args->err = 0x80200 || args->err = 0x80300)
+		if (args->err = 0x80200 || args->err = 0x80300 || args->err = 0)
 			if (pre_kprobes_handler(args))
 				ret = NOTIFY_STOP;
 		break;
Index: linux-2.6.15-rc1/arch/ia64/kernel/traps.c
=================================--- linux-2.6.15-rc1.orig/arch/ia64/kernel/traps.c
+++ linux-2.6.15-rc1/arch/ia64/kernel/traps.c
@@ -132,24 +132,6 @@ __kprobes ia64_bad_break (unsigned long 
 	siginfo_t siginfo;
 	int sig, code;
 
-	/* break.b always sets cr.iim to 0, which causes problems for
-	 * debuggers.  Get the real break number from the original instruction,
-	 * but only for kernel code.  User space break.b is left alone, to
-	 * preserve the existing behaviour.  All break codings have the same
-	 * format, so there is no need to check the slot type.
-	 */
-	if (break_num = 0 && !user_mode(regs)) {
-		struct ia64_psr *ipsr = ia64_psr(regs);
-		unsigned long *bundle = (unsigned long *)regs->cr_iip;
-		unsigned long slot;
-		switch (ipsr->ri) {
-		      case 0:  slot = (bundle[0] >>  5); break;
-		      case 1:  slot = (bundle[0] >> 46) | (bundle[1] << 18); break;
-		      default: slot = (bundle[1] >> 23); break;
-		}
-		break_num = ((slot >> 36 & 1) << 20) | (slot >> 6 & 0xfffff);
-	}
-
 	/* SIGILL, SIGFPE, SIGSEGV, and SIGBUS want these field initialized: */
 	siginfo.si_addr = (void __user *) (regs->cr_iip + ia64_psr(regs)->ri);
 	siginfo.si_imm = break_num;
