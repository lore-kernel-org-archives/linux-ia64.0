From: Jack Steiner <steiner@sgi.com>
Date: Thu, 11 Aug 2005 17:26:06 +0000
Subject: [PATCH 2/7] - New SN hardware support - use_alias_space
Message-Id: <20050811172606.GA18068@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Use local SHUB alias space when referencing MMRs that are known
to be node local. There is a slight performance benefit & code 
simplification.


	Signed-off-by: Jack Steiner <steiner@sgi.com>


 kernel/irq.c          |   17 ++++++-----------
 pci/pcibr/pcibr_dma.c |    2 +-
 2 files changed, 7 insertions(+), 12 deletions(-)




Index: linux/arch/ia64/sn/kernel/irq.c
=================================--- linux.orig/arch/ia64/sn/kernel/irq.c	2005-08-10 16:40:13.554923463 -0500
+++ linux/arch/ia64/sn/kernel/irq.c	2005-08-10 16:40:39.124608234 -0500
@@ -5,7 +5,7 @@
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
  *
- * Copyright (c) 2000-2004 Silicon Graphics, Inc.  All Rights Reserved.
+ * Copyright (c) 2000-2005 Silicon Graphics, Inc.  All Rights Reserved.
  */
 
 #include <linux/irq.h>
@@ -76,16 +76,14 @@ static void sn_enable_irq(unsigned int i
 
 static void sn_ack_irq(unsigned int irq)
 {
-	uint64_t event_occurred, mask = 0;
-	int nasid;
+	u64 event_occurred, mask = 0;
 
 	irq = irq & 0xff;
-	nasid = get_nasid();
 	event_occurred -	    HUB_L((uint64_t *) GLOBAL_MMR_ADDR(nasid, SH_EVENT_OCCURRED));
+	    HUB_L((u64*)LOCAL_MMR_ADDR(SH_EVENT_OCCURRED));
 	mask = event_occurred & SH_ALL_INT_MASK;
-	HUB_S((uint64_t *) GLOBAL_MMR_ADDR(nasid, SH_EVENT_OCCURRED_ALIAS),
-		 mask);
+	HUB_S((u64*)LOCAL_MMR_ADDR(SH_EVENT_OCCURRED_ALIAS),
+	      mask);
 	__set_bit(irq, (volatile void *)pda->sn_in_service_ivecs);
 
 	move_irq(irq);
@@ -93,15 +91,12 @@ static void sn_ack_irq(unsigned int irq)
 
 static void sn_end_irq(unsigned int irq)
 {
-	int nasid;
 	int ivec;
-	uint64_t event_occurred;
+	u64 event_occurred;
 
 	ivec = irq & 0xff;
 	if (ivec = SGI_UART_VECTOR) {
-		nasid = get_nasid();
-		event_occurred = HUB_L((uint64_t *) GLOBAL_MMR_ADDR
-				       (nasid, SH_EVENT_OCCURRED));
+		event_occurred = HUB_L((u64*)LOCAL_MMR_ADDR (SH_EVENT_OCCURRED));
 		/* If the UART bit is set here, we may have received an
 		 * interrupt from the UART that the driver missed.  To
 		 * make sure, we IPI ourselves to force us to look again.
Index: linux/arch/ia64/sn/pci/pcibr/pcibr_dma.c
=================================--- linux.orig/arch/ia64/sn/pci/pcibr/pcibr_dma.c	2005-08-10 16:40:13.554923463 -0500
+++ linux/arch/ia64/sn/pci/pcibr/pcibr_dma.c	2005-08-10 16:40:47.445057508 -0500
@@ -3,7 +3,7 @@
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
  *
- * Copyright (C) 2001-2004 Silicon Graphics, Inc. All rights reserved.
+ * Copyright (C) 2001-2005 Silicon Graphics, Inc. All rights reserved.
  */
 
 #include <linux/types.h>
@@ -286,7 +286,7 @@ void sn_dma_flush(uint64_t addr)
 	 * domain, unlike PIC
 	 */
 	if (is_tio) {
-		uint32_t tio_id = REMOTE_HUB_L(nasid, TIO_NODE_ID);
+		uint32_t tio_id = HUB_L(TIO_IOSPACE_ADDR(nasid, TIO_NODE_ID));
 		uint32_t revnum = XWIDGET_PART_REV_NUM(tio_id);
 
 		/* TIOCP BRINGUP WAR (PV907516): Don't write buffer flush reg */
-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


