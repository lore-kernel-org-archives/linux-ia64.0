From: Russ Anderson <rja@efs.americas.sgi.com>
Date: Fri, 03 Feb 2006 20:47:15 +0000
Subject: [patch] Shub2 BTE address fix
Message-Id: <200602032047.k13KlFod981630@efs.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

[patch] Shub2 BTE address fix

After converting the cpu physical address to shub2 physical 
addressing, the address was run through TO_PHYS() which
clobbered a high node offset bit causing the BTE to fail
on shub2 nodes with large memory.  This fix corrects
that problem.

Signed-off-by: Russ Anderson (rja@sgi.com)

--------------------------------------------------------------
 arch/ia64/sn/kernel/bte.c |   17 ++++++-----------
 include/asm-ia64/sn/bte.h |   23 +++++++++++++++++++----
 2 files changed, 25 insertions(+), 15 deletions(-)

Index: linux-2.6.15/arch/ia64/sn/kernel/bte.c
=================================--- linux-2.6.15.orig/arch/ia64/sn/kernel/bte.c	2006-01-02 21:21:10.000000000 -0600
+++ linux-2.6.15/arch/ia64/sn/kernel/bte.c	2006-02-02 11:04:50.664306647 -0600
@@ -3,7 +3,7 @@
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
  *
- * Copyright (c) 2000-2005 Silicon Graphics, Inc.  All Rights Reserved.
+ * Copyright (c) 2000-2006 Silicon Graphics, Inc.  All Rights Reserved.
  */
 
 #include <linux/config.h>
@@ -186,18 +186,13 @@ retry_bteop:
 
 	/* Initialize the notification to a known value. */
 	*bte->most_rcnt_na = BTE_WORD_BUSY;
-	notif_phys_addr = TO_PHYS(ia64_tpa((unsigned long)bte->most_rcnt_na));
+	notif_phys_addr = (u64)bte->most_rcnt_na;
 
-	if (is_shub2()) {
-		src = SH2_TIO_PHYS_TO_DMA(src);
-		dest = SH2_TIO_PHYS_TO_DMA(dest);
-		notif_phys_addr = SH2_TIO_PHYS_TO_DMA(notif_phys_addr);
-	}
 	/* Set the source and destination registers */
-	BTE_PRINTKV(("IBSA = 0x%lx)\n", (TO_PHYS(src))));
-	BTE_SRC_STORE(bte, TO_PHYS(src));
-	BTE_PRINTKV(("IBDA = 0x%lx)\n", (TO_PHYS(dest))));
-	BTE_DEST_STORE(bte, TO_PHYS(dest));
+	BTE_PRINTKV(("IBSA = 0x%lx)\n", src));
+	BTE_SRC_STORE(bte, src);
+	BTE_PRINTKV(("IBDA = 0x%lx)\n", dest));
+	BTE_DEST_STORE(bte, dest);
 
 	/* Set the notification register */
 	BTE_PRINTKV(("IBNA = 0x%lx)\n", notif_phys_addr));
Index: linux-2.6.15/include/asm-ia64/sn/bte.h
=================================--- linux-2.6.15.orig/include/asm-ia64/sn/bte.h	2006-01-02 21:21:10.000000000 -0600
+++ linux-2.6.15/include/asm-ia64/sn/bte.h	2006-02-02 14:45:36.922401783 -0600
@@ -3,7 +3,7 @@
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
  *
- * Copyright (c) 2000-2005 Silicon Graphics, Inc.  All Rights Reserved.
+ * Copyright (c) 2000-2006 Silicon Graphics, Inc.  All Rights Reserved.
  */
 
 
@@ -100,13 +100,28 @@
 #define BTE_LNSTAT_STORE(_bte, _x)					\
 			HUB_S(_bte->bte_base_addr, (_x))
 #define BTE_SRC_STORE(_bte, _x)						\
-			HUB_S(_bte->bte_source_addr, (_x))
+({									\
+		u64 __addr = ((_x) & ~AS_MASK);				\
+		if (is_shub2()) 					\
+			__addr = SH2_TIO_PHYS_TO_DMA(__addr);		\
+		HUB_S(_bte->bte_source_addr, __addr);			\
+})
 #define BTE_DEST_STORE(_bte, _x)					\
-			HUB_S(_bte->bte_destination_addr, (_x))
+({									\
+		u64 __addr = ((_x) & ~AS_MASK);				\
+		if (is_shub2()) 					\
+			__addr = SH2_TIO_PHYS_TO_DMA(__addr);		\
+		HUB_S(_bte->bte_destination_addr, __addr);		\
+})
 #define BTE_CTRL_STORE(_bte, _x)					\
 			HUB_S(_bte->bte_control_addr, (_x))
 #define BTE_NOTIF_STORE(_bte, _x)					\
-			HUB_S(_bte->bte_notify_addr, (_x))
+({									\
+		u64 __addr = ia64_tpa((_x) & ~AS_MASK);			\
+		if (is_shub2()) 					\
+			__addr = SH2_TIO_PHYS_TO_DMA(__addr);		\
+		HUB_S(_bte->bte_notify_addr, __addr);			\
+})
 
 #define BTE_START_TRANSFER(_bte, _len, _mode)				\
 	is_shub2() ? BTE_CTRL_STORE(_bte, IBLS_BUSY | (_mode << 24) | _len) \
