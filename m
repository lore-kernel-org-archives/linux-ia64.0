From: Russ Anderson <rja@sgi.com>
Date: Tue, 19 Oct 2004 20:14:41 +0000
Subject: [Patch] BTE error handler fix
Message-Id: <200410192014.i9JKEfMJ089125@ben.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The bte_crb_error_handler() expects a cnode as the first parameter.
This patch gives it the correct data.

This applies on top of Pat Gefre's patches.


Signed-off-by: Russ Anderson


Index: linux/arch/ia64/sn/kernel/huberror.c
=================================--- linux.orig/arch/ia64/sn/kernel/huberror.c	2004-10-15 13:24:59.000000000 -0500
+++ linux/arch/ia64/sn/kernel/huberror.c	2004-10-19 14:40:47.000000000 -0500
@@ -20,7 +20,7 @@
 #include <asm/sn/bte.h>
 
 void hubiio_crb_error_handler(struct hubdev_info *hubdev_info);
-extern void bte_crb_error_handler(struct hubdev_info *, int, int, ioerror_t *,
+extern void bte_crb_error_handler(cnodeid_t, int, int, ioerror_t *,
 				  int);
 static irqreturn_t hub_eint_handler(int irq, void *arg, struct pt_regs *ep)
 {
@@ -156,7 +156,7 @@
 
 			hubiio_crb_free(hubdev_info, i);
 
-			bte_crb_error_handler(hubdev_info, bte_num,
+			bte_crb_error_handler(nasid_to_cnodeid(nasid), bte_num,
 					      i, &ioerror, icrbd.d_bteop);
 			num_errors++;
 			continue;
-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
