From: Robin Holt <holt@sgi.com>
Date: Tue, 29 Jul 2008 01:51:11 +0000
Subject: [Patch] ia64 build failure due to msleep not defined.
Message-Id: <20080729015111.GI9663@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

qla_attr.c failes to compile because it is missing the definition
of msleep.  Specifically include linux/delay.h fixes this compile failure.

Signed-off-by: Robin Holt <holt@sgi.com>


Index: contention_unroll/drivers/scsi/qla2xxx/qla_attr.c
=================================--- contention_unroll.orig/drivers/scsi/qla2xxx/qla_attr.c	2008-07-28 20:36:58.302429101 -0500
+++ contention_unroll/drivers/scsi/qla2xxx/qla_attr.c	2008-07-28 20:45:09.451163519 -0500
@@ -8,6 +8,7 @@
 
 #include <linux/kthread.h>
 #include <linux/vmalloc.h>
+#include <linux/delay.h>
 
 static int qla24xx_vport_disable(struct fc_vport *, bool);
 
