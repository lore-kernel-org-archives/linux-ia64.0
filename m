From: Pat Gefre <pfg@sgi.com>
Date: Tue, 19 Oct 2004 20:23:19 +0000
Subject: [Patch] Altix patch 012-huberror for 2.6.10
Message-Id: <Pine.SGI.3.96.1041019151446.144128E-100000@fsgi900.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Tony,

It looks like 2.6.10 is beginning. Do you still want us to spool our
mods to the oss site or just send them as we normally would ?


This is 012-huberror on the oss site.


Signed-off-by: Patrick Gefre <pfg@sgi.com>

#
# Fixes calling arg1 for bte_crb_error_handler()
#
#
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


