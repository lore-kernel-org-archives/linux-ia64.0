From: jbarnes@sgi.com (Jesse Barnes)
Date: Fri, 13 Feb 2004 00:30:04 +0000
Subject: [PATCH] kill misc. warnings
Message-Id: <20040213003004.GA15451@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Fix up some misc warnings: include module.h in cache.c since it uses
EXPORT_SYMBOL(), fix printk format arg in sn_serial.c.

Jesse


=== arch/ia64/sn/kernel/sn2/cache.c 1.5 vs edited ==--- 1.5/arch/ia64/sn/kernel/sn2/cache.c	Sun Jan 18 22:36:08 2004
+++ edited/arch/ia64/sn/kernel/sn2/cache.c	Thu Feb 12 15:55:56 2004
@@ -6,7 +6,7 @@
  * Copyright (C) 2001-2003 Silicon Graphics, Inc. All rights reserved.
  *
  */
-
+#include <linux/module.h>
 #include <asm/pgalloc.h>
 
 /**
=== drivers/char/sn_serial.c 1.3 vs edited ==--- 1.3/drivers/char/sn_serial.c	Tue Feb  3 21:39:51 2004
+++ edited/drivers/char/sn_serial.c	Thu Feb 12 16:27:23 2004
@@ -772,7 +772,7 @@
 	int len = 0;
 	off_t	begin = 0;
 
-	len += sprintf(page, "sn_serial: nasid:%d irq:%d tx:%d rx:%d\n",
+	len += sprintf(page, "sn_serial: nasid:%ld irq:%d tx:%d rx:%d\n",
 		       ia64_sn_get_console_nasid(), sn_sal_irq,
 		       sn_total_tx_count, sn_total_rx_count);
 	*eof = 1;
