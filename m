From: Rusty Lynch <rusty.lynch@intel.com>
Date: Tue, 24 May 2005 16:47:00 +0000
Subject: [patch][ia64] Change break 0 notification string
Message-Id: <200505241647.j4OGl0sK006514@linux.jf.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: akpm@osdl.org
Cc: Anil S Keshavamurthy <anil.s.keshavamurthy@intel.com>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, Rusty Lynch <rusty.lynch@intel.com>, Keith Owens <kaos@sgi.com>

At the point in traps.c where we recieve a break with a zero value, we
can not say if the break was a result of a kprobe or some other debug
facility.

This simple patch changes the informational string to a more correct
"break 0" value, and applies to the 2.6.12-rc2-mm2 tree with all the 
kprobes patches that were just recently included for the next mm cut.

    --rusty

 arch/ia64/kernel/traps.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6.12-rc4/arch/ia64/kernel/traps.c
=================================--- linux-2.6.12-rc4.orig/arch/ia64/kernel/traps.c
+++ linux-2.6.12-rc4/arch/ia64/kernel/traps.c
@@ -133,7 +133,7 @@ ia64_bad_break (unsigned long break_num,
 
 	switch (break_num) {
 	      case 0: /* unknown error (used by GCC for __builtin_abort()) */
-		if (notify_die(DIE_BREAK, "kprobe", regs, break_num, TRAP_BRKPT, SIGTRAP)
+		if (notify_die(DIE_BREAK, "break 0", regs, break_num, TRAP_BRKPT, SIGTRAP)
 			       	= NOTIFY_STOP) {
 			return;
 		}
