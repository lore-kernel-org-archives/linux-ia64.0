From: Adrian Bunk <bunk@stusta.de>
Date: Sun, 12 Dec 2004 19:39:21 +0000
Subject: [2.6 patch] ia64 smpboot.c: remove an unused function
Message-Id: <20041212193921.GA22324@stusta.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Mosberger-Tang <davidm@hpl.hp.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

The patch below removes an unused global functions.


Signed-off-by: Adrian Bunk <bunk@stusta.de>

--- linux-2.6.10-rc2-mm4-full/arch/ia64/kernel/smpboot.c.old	2004-12-12 02:51:04.000000000 +0100
+++ linux-2.6.10-rc2-mm4-full/arch/ia64/kernel/smpboot.c	2004-12-12 02:51:18.000000000 +0100
@@ -356,11 +356,6 @@
 	return cpu_idle();
 }
 
-struct pt_regs * __devinit idle_regs(struct pt_regs *regs)
-{
-	return NULL;
-}
-
 struct create_idle {
 	struct task_struct *idle;
 	struct completion done;

