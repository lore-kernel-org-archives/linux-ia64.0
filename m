From: "Jan Beulich" <jbeulich@novell.com>
Date: Wed, 12 Dec 2007 15:24:29 +0000
Subject: [PATCH] ia64: honor notify_die() returning NOTIFY_STOP
Message-Id: <47600B3D.76E4.0078.0@novell.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

This requires making die() and die_if_kernel() return a value, and
their callers to honor this (and be prepared that it returns).

Signed-off-by: Jan Beulich <jbeulich@novell.com>

 arch/ia64/ia32/ia32_support.c |    5 +++--
 arch/ia64/kernel/traps.c      |   35 +++++++++++++++++++++++------------
 arch/ia64/kernel/unaligned.c  |   13 ++++++++-----
 arch/ia64/mm/fault.c          |    8 +++++---
 4 files changed, 39 insertions(+), 22 deletions(-)

--- linux-2.6.24-rc5/arch/ia64/ia32/ia32_support.c	2007-10-09 22:31:38.000000000 +0200
+++ 2.6.24-rc5-ia64-notify-die-return/arch/ia64/ia32/ia32_support.c	2007-12-04 16:22:55.000000000 +0100
@@ -27,7 +27,7 @@
 
 #include "ia32priv.h"
 
-extern void die_if_kernel (char *str, struct pt_regs *regs, long err);
+extern int die_if_kernel (char *str, struct pt_regs *regs, long err);
 
 struct exec_domain ia32_exec_domain;
 struct page *ia32_shared_page[NR_CPUS];
@@ -217,7 +217,8 @@ ia32_bad_interrupt (unsigned long int_nu
 {
 	siginfo_t siginfo;
 
-	die_if_kernel("Bad IA-32 interrupt", regs, int_num);
+	if (die_if_kernel("Bad IA-32 interrupt", regs, int_num))
+		return;
 
 	siginfo.si_signo = SIGTRAP;
 	siginfo.si_errno = int_num;	/* XXX is it OK to abuse si_errno like this? */
--- linux-2.6.24-rc5/arch/ia64/kernel/traps.c	2007-12-12 12:27:11.000000000 +0100
+++ 2.6.24-rc5-ia64-notify-die-return/arch/ia64/kernel/traps.c	2007-12-04 16:24:42.000000000 +0100
@@ -35,7 +35,7 @@ trap_init (void)
 		fpswa_interface = __va(ia64_boot_param->fpswa);
 }
 
-void
+int
 die (const char *str, struct pt_regs *regs, long err)
 {
 	static struct {
@@ -62,8 +62,11 @@ die (const char *str, struct pt_regs *re
 	if (++die.lock_owner_depth < 3) {
 		printk("%s[%d]: %s %ld [%d]\n",
 		current->comm, task_pid_nr(current), str, err, ++die_counter);
-		(void) notify_die(DIE_OOPS, (char *)str, regs, err, 255, SIGSEGV);
-		show_regs(regs);
+		if (notify_die(DIE_OOPS, str, regs, err, 255, SIGSEGV)
+	            != NOTIFY_STOP)
+			show_regs(regs);
+		else
+			regs = NULL;
   	} else
 		printk(KERN_ERR "Recursive die() failure, output suppressed\n");
 
@@ -72,17 +75,22 @@ die (const char *str, struct pt_regs *re
 	add_taint(TAINT_DIE);
 	spin_unlock_irq(&die.lock);
 
+	if (!regs)
+		return 1;
+
 	if (panic_on_oops)
 		panic("Fatal exception");
 
   	do_exit(SIGSEGV);
+	return 0;
 }
 
-void
+int
 die_if_kernel (char *str, struct pt_regs *regs, long err)
 {
 	if (!user_mode(regs))
-		die(str, regs, err);
+		return die(str, regs, err);
+	return 0;
 }
 
 void
@@ -102,7 +110,8 @@ __kprobes ia64_bad_break (unsigned long 
 		if (notify_die(DIE_BREAK, "break 0", regs, break_num, TRAP_BRKPT, SIGTRAP)
 			       	= NOTIFY_STOP)
 			return;
-		die_if_kernel("bugcheck!", regs, break_num);
+		if (die_if_kernel("bugcheck!", regs, break_num))
+			return;
 		sig = SIGILL; code = ILL_ILLOPC;
 		break;
 
@@ -155,8 +164,9 @@ __kprobes ia64_bad_break (unsigned long 
 		break;
 
 	      default:
-		if (break_num < 0x40000 || break_num > 0x100000)
-			die_if_kernel("Bad break", regs, break_num);
+		if ((break_num < 0x40000 || break_num > 0x100000)
+		    && die_if_kernel("Bad break", regs, break_num))
+			return;
 
 		if (break_num < 0x80000) {
 			sig = SIGILL; code = __ILL_BREAK;
@@ -402,14 +412,15 @@ ia64_illegal_op_fault (unsigned long ec,
 #endif
 
 	sprintf(buf, "IA-64 Illegal operation fault");
-	die_if_kernel(buf, &regs, 0);
+	rv.fkt = 0;
+	if (die_if_kernel(buf, &regs, 0))
+		return rv;
 
 	memset(&si, 0, sizeof(si));
 	si.si_signo = SIGILL;
 	si.si_code = ILL_ILLOPC;
 	si.si_addr = (void __user *) (regs.cr_iip + ia64_psr(&regs)->ri);
 	force_sig_info(SIGILL, &si, current);
-	rv.fkt = 0;
 	return rv;
 }
 
@@ -644,6 +655,6 @@ ia64_fault (unsigned long vector, unsign
 		sprintf(buf, "Fault %lu", vector);
 		break;
 	}
-	die_if_kernel(buf, &regs, error);
-	force_sig(SIGILL, current);
+	if (!die_if_kernel(buf, &regs, error))
+		force_sig(SIGILL, current);
 }
--- linux-2.6.24-rc5/arch/ia64/kernel/unaligned.c	2007-12-12 12:27:11.000000000 +0100
+++ 2.6.24-rc5-ia64-notify-die-return/arch/ia64/kernel/unaligned.c	2007-12-04 16:22:55.000000000 +0100
@@ -23,7 +23,7 @@
 #include <asm/uaccess.h>
 #include <asm/unaligned.h>
 
-extern void die_if_kernel(char *str, struct pt_regs *regs, long err);
+extern int die_if_kernel(char *str, struct pt_regs *regs, long err);
 
 #undef DEBUG_UNALIGNED_TRAP
 
@@ -675,8 +675,9 @@ emulate_load_updates (update_t type, loa
 	 */
 	if (ld.x6_op = 1 || ld.x6_op = 3) {
 		printk(KERN_ERR "%s: register update on speculative load, error\n", __FUNCTION__);
-		die_if_kernel("unaligned reference on speculative load with register update\n",
-			      regs, 30);
+		if (die_if_kernel("unaligned reference on speculative load with register update\n",
+				  regs, 30))
+			return;
 	}
 
 
@@ -1317,7 +1318,8 @@ ia64_handle_unaligned (unsigned long ifa
 
 	if (ia64_psr(regs)->be) {
 		/* we don't support big-endian accesses */
-		die_if_kernel("big-endian unaligned accesses are not supported", regs, 0);
+		if (die_if_kernel("big-endian unaligned accesses are not supported", regs, 0))
+			return;
 		goto force_sigbus;
 	}
 
@@ -1531,7 +1533,8 @@ ia64_handle_unaligned (unsigned long ifa
 			ia64_handle_exception(regs, eh);
 			goto done;
 		}
-		die_if_kernel("error during unaligned kernel access\n", regs, ret);
+		if (die_if_kernel("error during unaligned kernel access\n", regs, ret))
+			return;
 		/* NOT_REACHED */
 	}
   force_sigbus:
--- linux-2.6.24-rc5/arch/ia64/mm/fault.c	2007-12-12 12:27:11.000000000 +0100
+++ 2.6.24-rc5-ia64-notify-die-return/arch/ia64/mm/fault.c	2007-12-04 16:22:55.000000000 +0100
@@ -16,7 +16,7 @@
 #include <asm/system.h>
 #include <asm/uaccess.h>
 
-extern void die (char *, struct pt_regs *, long);
+extern int die(char *, struct pt_regs *, long);
 
 #ifdef CONFIG_KPROBES
 static inline int notify_page_fault(struct pt_regs *regs, int trap)
@@ -267,9 +267,11 @@ ia64_do_page_fault (unsigned long addres
 	else
 		printk(KERN_ALERT "Unable to handle kernel paging request at "
 		       "virtual address %016lx\n", address);
-	die("Oops", regs, isr);
+	if (die("Oops", regs, isr))
+		regs = NULL;
 	bust_spinlocks(0);
-	do_exit(SIGKILL);
+	if (regs)
+		do_exit(SIGKILL);
 	return;
 
   out_of_memory:


