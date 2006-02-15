From: Horms <horms@verge.net.au>
Date: Wed, 15 Feb 2006 08:23:09 +0000
Subject: [PATCH] ia64: support panic_on_oops sysctl
Message-Id: <20060215082307.GA28244@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Trivial port of this feature from i386
As it stands, panic_on_oops but does nothing on ia64

Signed-Off-By: Horms <horms@verge.net.au>

diff --git a/arch/ia64/kernel/traps.c b/arch/ia64/kernel/traps.c
--- a/arch/ia64/kernel/traps.c
+++ b/arch/ia64/kernel/traps.c
@@ -16,6 +16,7 @@
 #include <linux/module.h>       /* for EXPORT_SYMBOL */
 #include <linux/hardirq.h>
 #include <linux/kprobes.h>
+#include <linux/delay.h>		/* for ssleep() */
 
 #include <asm/fpswa.h>
 #include <asm/ia32.h>
@@ -116,6 +117,13 @@ die (const char *str, struct pt_regs *re
 	bust_spinlocks(0);
 	die.lock_owner = -1;
 	spin_unlock_irq(&die.lock);
+
+	if (panic_on_oops) {
+		printk(KERN_EMERG "Fatal exception: panic in 5 seconds\n");
+		ssleep(5);
+		panic("Fatal exception");
+	}
+
   	do_exit(SIGSEGV);
 }
 
