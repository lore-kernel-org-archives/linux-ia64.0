From: Ben Hutchings <ben@decadent.org.uk>
Date: Thu, 07 Jun 2018 14:05:21 +0000
Subject: [PATCH 3.16 267/410] arm64: do not use print_symbol()
Message-Id: <lsq.1528380321.214381661@decadent.org.uk>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <lsq.1528380320.647747352@decadent.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org

3.16.57-rc1 review patch.  If anyone has any objections, please let me know.

------------------

From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

commit 4ef7963843d3243260aa335dfb9cb2fede06aacf upstream.

print_symbol() is a very old API that has been obsoleted by %pS format
specifier in a normal printk() call.

Replace print_symbol() with a direct printk("%pS") call.

Link: http://lkml.kernel.org/r/20171211125025.2270-3-sergey.senozhatsky@gmail.com
To: Andrew Morton <akpm@linux-foundation.org>
To: Russell King <linux@armlinux.org.uk>
To: Catalin Marinas <catalin.marinas@arm.com>
To: Mark Salter <msalter@redhat.com>
To: Tony Luck <tony.luck@intel.com>
To: David Howells <dhowells@redhat.com>
To: Yoshinori Sato <ysato@users.sourceforge.jp>
To: Guan Xuetao <gxt@mprc.pku.edu.cn>
To: Borislav Petkov <bp@alien8.de>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To: Thomas Gleixner <tglx@linutronix.de>
To: Peter Zijlstra <peterz@infradead.org>
To: Vineet Gupta <vgupta@synopsys.com>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: Steven Rostedt <rostedt@goodmis.org>
Cc: Petr Mladek <pmladek@suse.com>
Cc: LKML <linux-kernel@vger.kernel.org>
Cc: linux-arm-kernel@lists.infradead.org
Cc: linux-c6x-dev@linux-c6x.org
Cc: linux-ia64@vger.kernel.org
Cc: linux-am33-list@redhat.com
Cc: linux-sh@vger.kernel.org
Cc: linux-edac@vger.kernel.org
Cc: x86@kernel.org
Cc: linux-snps-arc@lists.infradead.org
Cc: Catalin Marinas <catalin.marinas@arm.com>
Cc: Will Deacon <will.deacon@arm.com>
Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
[pmladek@suse.com: updated commit message]
Signed-off-by: Petr Mladek <pmladek@suse.com>
[bwh: Backported to 3.16: adjust context]
Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 arch/arm64/kernel/process.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

--- a/arch/arm64/kernel/process.c
+++ b/arch/arm64/kernel/process.c
@@ -31,7 +31,6 @@
 #include <linux/delay.h>
 #include <linux/reboot.h>
 #include <linux/interrupt.h>
-#include <linux/kallsyms.h>
 #include <linux/init.h>
 #include <linux/cpu.h>
 #include <linux/elfcore.h>
@@ -198,8 +197,8 @@ void __show_regs(struct pt_regs *regs)
 	}
 
 	show_regs_print_info(KERN_DEFAULT);
-	print_symbol("pc : %s\n", regs->pc);
-	print_symbol("lr : %s\n", lr);
+	printk("pc : %pS\n", (void *)regs->pc);
+	printk("lr : %pS\n", (void *)lr);
 	printk("sp : %016llx pstate : %08llx\n", sp, regs->pstate);
 	for (i = top_reg; i >= 0; i--) {
 		printk("x%-2d: %016llx ", i, regs->regs[i]);

