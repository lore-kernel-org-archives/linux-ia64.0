From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 11 Mar 2005 06:10:39 +0000
Subject: [patch] add missing cpu_relax() in ITC syncing code
Message-Id: <16945.13919.265444.179679@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Tony,

Attached trivial patch adds 3 cpu_relax() calls in busy-waiting loops.
Please apply.

Thanks,

	--david

Call cpu_relax() in busy-waiting loops of the ITC-syncing code.

Signed-off-by: David Mosberger-Tang <davidm@hpl.hp.com>

=== arch/ia64/kernel/smpboot.c 1.65 vs edited ==--- 1.65/arch/ia64/kernel/smpboot.c	2005-01-22 13:13:47 -08:00
+++ edited/arch/ia64/kernel/smpboot.c	2005-03-10 22:08:36 -08:00
@@ -1,7 +1,7 @@
 /*
  * SMP boot-related support
  *
- * Copyright (C) 1998-2003 Hewlett-Packard Co
+ * Copyright (C) 1998-2003, 2005 Hewlett-Packard Co
  *	David Mosberger-Tang <davidm@hpl.hp.com>
  *
  * 01/05/16 Rohit Seth <rohit.seth@intel.com>	Moved SMP booting functions from smp.c to here.
@@ -124,7 +124,8 @@
 	local_irq_save(flags);
 	{
 		for (i = 0; i < NUM_ROUNDS*NUM_ITERS; ++i) {
-			while (!go[MASTER]);
+			while (!go[MASTER])
+				cpu_relax();
 			go[MASTER] = 0;
 			go[SLAVE] = ia64_get_itc();
 		}
@@ -147,7 +148,8 @@
 	for (i = 0; i < NUM_ITERS; ++i) {
 		t0 = ia64_get_itc();
 		go[MASTER] = 1;
-		while (!(tm = go[SLAVE]));
+		while (!(tm = go[SLAVE]))
+			cpu_relax();
 		go[SLAVE] = 0;
 		t1 = ia64_get_itc();
 
@@ -226,7 +228,8 @@
 		return;
 	}
 
-	while (go[MASTER]);	/* wait for master to be ready */
+	while (go[MASTER])
+		cpu_relax();	/* wait for master to be ready */
 
 	spin_lock_irqsave(&itc_sync_lock, flags);
 	{
