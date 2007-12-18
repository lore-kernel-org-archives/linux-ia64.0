From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 18 Dec 2007 19:46:38 +0000
Subject: [PATCH] print kernel release in OOPS to make kerneloops.org happy
Message-Id: <1FE6DD409037234FAB833C420AA843EC22D629@orsmsx424.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The ia64 oops message doesn't include the kernel version, which
makes it hard to automatically categorize oops messages scraped
from mailing lists and bug databases.

Signed-off-by: Tony Luck <tony.luck@intel.com>

---

There isn't any consistency about how oops messages are formatted in
different architectures.  I've added it after the "tainted" field. If
that upsets any existing ia64 oops parsing scripts, then I'm open to
placing this somewhere else.

--- a/arch/ia64/kernel/process.c	2007-12-07 21:06:52.000000000 -0800
+++ b/arch/ia64/kernel/process.c	2007-12-18 08:59:57.000000000 -0800
@@ -27,6 +27,7 @@
 #include <linux/interrupt.h>
 #include <linux/delay.h>
 #include <linux/kdebug.h>
+#include <linux/utsname.h>
 
 #include <asm/cpu.h>
 #include <asm/delay.h>
@@ -107,8 +108,9 @@
 	print_modules();
 	printk("\nPid: %d, CPU %d, comm: %20s\n", task_pid_nr(current),
 			smp_processor_id(), current->comm);
-	printk("psr : %016lx ifs : %016lx ip  : [<%016lx>]    %s\n",
-	       regs->cr_ipsr, regs->cr_ifs, ip, print_tainted());
+	printk("psr : %016lx ifs : %016lx ip  : [<%016lx>]    %s (%s)\n",
+	       regs->cr_ipsr, regs->cr_ifs, ip, print_tainted(),
+	       init_utsname()->release);
 	print_symbol("ip is at %s\n", ip);
 	printk("unat: %016lx pfs : %016lx rsc : %016lx\n",
 	       regs->ar_unat, regs->ar_pfs, regs->ar_rsc);

 
