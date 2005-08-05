From: Mark Maule <maule@sgi.com>
Date: Fri, 05 Aug 2005 21:13:13 +0000
Subject: [PATCH 2.6.13 3/6] altix: add support for TIO huge-window addresses
Message-Id: <20050805211313.5173.1871.34585@attica.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Altix patch to add TIO "huge-window" address support to sn_dma_flush().

Update copyright in affected files.

Signed-off-by: Mark Maule <maule@sgi.com>

Index: ce-devel/arch/ia64/sn/include/tio.h
=================================--- ce-devel.orig/arch/ia64/sn/include/tio.h	2005-07-20 17:45:22.704257555 -0500
+++ ce-devel/arch/ia64/sn/include/tio.h	2005-07-20 17:45:32.540165827 -0500
@@ -3,7 +3,7 @@
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
  *
- * Copyright (C) 2000-2004 Silicon Graphics, Inc. All rights reserved.
+ * Copyright (C) 2000-2005 Silicon Graphics, Inc. All rights reserved.
  */
 
 #ifndef _ASM_IA64_SN_TIO_H
@@ -26,6 +26,10 @@
 #define TIO_ITTE_VALID_MASK	0x1
 #define TIO_ITTE_VALID_SHIFT	16
 
+#define TIO_ITTE_WIDGET(itte) \
+	(((itte) >> TIO_ITTE_WIDGET_SHIFT) & TIO_ITTE_WIDGET_MASK)
+#define TIO_ITTE_VALID(itte) \
+	(((itte) >> TIO_ITTE_VALID_SHIFT) & TIO_ITTE_VALID_MASK)
 
 #define TIO_ITTE_PUT(nasid, bigwin, widget, addr, valid) \
         REMOTE_HUB_S((nasid), TIO_ITTE(bigwin), \
Index: ce-devel/arch/ia64/sn/include/xtalk/hubdev.h
=================================--- ce-devel.orig/arch/ia64/sn/include/xtalk/hubdev.h	2005-07-20 17:45:22.706210481 -0500
+++ ce-devel/arch/ia64/sn/include/xtalk/hubdev.h	2005-07-20 17:45:32.546024602 -0500
@@ -3,7 +3,7 @@
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
  *
- * Copyright (C) 1992 - 1997, 2000-2004 Silicon Graphics, Inc. All rights reserved.
+ * Copyright (C) 1992 - 1997, 2000-2005 Silicon Graphics, Inc. All rights reserved.
  */
 #ifndef _ASM_IA64_SN_XTALK_HUBDEV_H
 #define _ASM_IA64_SN_XTALK_HUBDEV_H
@@ -16,6 +16,9 @@
 #define IIO_ITTE_WIDGET_MASK    ((1<<IIO_ITTE_WIDGET_BITS)-1)
 #define IIO_ITTE_WIDGET_SHIFT   8
 
+#define IIO_ITTE_WIDGET(itte)	\
+	(((itte) >> IIO_ITTE_WIDGET_SHIFT) & IIO_ITTE_WIDGET_MASK)
+
 /*
  * Use the top big window as a surrogate for the first small window
  */
Index: ce-devel/arch/ia64/sn/pci/pcibr/pcibr_dma.c
=================================--- ce-devel.orig/arch/ia64/sn/pci/pcibr/pcibr_dma.c	2005-07-20 17:45:22.706210481 -0500
+++ ce-devel/arch/ia64/sn/pci/pcibr/pcibr_dma.c	2005-07-21 11:41:37.380432167 -0500
@@ -3,7 +3,7 @@
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
  *
- * Copyright (C) 2001-2004 Silicon Graphics, Inc. All rights reserved.
+ * Copyright (C) 2001-2005 Silicon Graphics, Inc. All rights reserved.
  */
 
 #include <linux/types.h>
@@ -215,8 +215,8 @@
 	int is_tio;
 	int wid_num;
 	int i, j;
-	int bwin;
 	uint64_t flags;
+	uint64_t itte;
 	struct hubdev_info *hubinfo;
 	volatile struct sn_flush_device_list *p;
 	struct sn_flush_nasid_entry *flush_nasid_list;
@@ -233,31 +233,36 @@
 	if (!hubinfo) {
 		BUG();
 	}
-	is_tio = (nasid & 1);
-	if (is_tio) {
-		wid_num = TIO_SWIN_WIDGETNUM(addr);
-		bwin = TIO_BWIN_WINDOWNUM(addr);
-	} else {
-		wid_num = SWIN_WIDGETNUM(addr);
-		bwin = BWIN_WINDOWNUM(addr);
-	}
 
 	flush_nasid_list = &hubinfo->hdi_flush_nasid_list;
 	if (flush_nasid_list->widget_p = NULL)
 		return;
-	if (bwin > 0) {
-		uint64_t itte = flush_nasid_list->iio_itte[bwin];
 
-		if (is_tio) {
-			wid_num = (itte >> TIO_ITTE_WIDGET_SHIFT) &
-			    TIO_ITTE_WIDGET_MASK;
-		} else {
-			wid_num = (itte >> IIO_ITTE_WIDGET_SHIFT) &
-			    IIO_ITTE_WIDGET_MASK;
-		}
+	is_tio = (nasid & 1);
+	if (is_tio) {
+		int itte_index;
+
+		if (TIO_HWIN(addr))
+			itte_index = 0;
+		else if (TIO_BWIN_WINDOWNUM(addr))
+			itte_index = TIO_BWIN_WINDOWNUM(addr);
+		else
+			itte_index = -1;
+
+		if (itte_index >= 0) {
+			itte = flush_nasid_list->iio_itte[itte_index];
+			if (! TIO_ITTE_VALID(itte))
+				return;
+			wid_num = TIO_ITTE_WIDGET(itte);
+		} else
+			wid_num = TIO_SWIN_WIDGETNUM(addr);
+	} else {
+		if (BWIN_WINDOWNUM(addr)) {
+			itte = flush_nasid_list->iio_itte[BWIN_WINDOWNUM(addr)];
+			wid_num = IIO_ITTE_WIDGET(itte);
+		} else
+			wid_num = SWIN_WIDGETNUM(addr);
 	}
-	if (flush_nasid_list->widget_p = NULL)
-		return;
 	if (flush_nasid_list->widget_p[wid_num] = NULL)
 		return;
 	p = &flush_nasid_list->widget_p[wid_num][0];
@@ -283,9 +288,15 @@
 	/*
 	 * For TIOCP use the Device(x) Write Request Buffer Flush Bridge
 	 * register since it ensures the data has entered the coherence
-	 * domain, unlike PIC
+	 * domain, unlike PIC.
 	 */
 	if (is_tio) {
+		/*
+	 	 * Note:  devices behind TIOCE should never be matched in the
+		 * above code, and so the following code is PIC/CP centric.
+		 * If CE ever needs the sn_dma_flush mechanism, we will have
+		 * to account for that here and in tioce_bus_fixup().
+	 	 */
 		uint32_t tio_id = REMOTE_HUB_L(nasid, TIO_NODE_ID);
 		uint32_t revnum = XWIDGET_PART_REV_NUM(tio_id);
 
Index: ce-devel/include/asm-ia64/sn/addrs.h
=================================--- ce-devel.orig/include/asm-ia64/sn/addrs.h	2005-07-20 17:45:22.722810346 -0500
+++ ce-devel/include/asm-ia64/sn/addrs.h	2005-07-20 17:45:32.584106646 -0500
@@ -3,7 +3,7 @@
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
  *
- * Copyright (c) 1992-1999,2001-2004 Silicon Graphics, Inc. All rights reserved.
+ * Copyright (c) 1992-1999,2001-2005 Silicon Graphics, Inc. All rights reserved.
  */
 
 #ifndef _ASM_IA64_SN_ADDRS_H
@@ -191,7 +191,8 @@
 #define TIO_BWIN_WINDOW_SELECT_MASK	0x7
 #define TIO_BWIN_WINDOWNUM(x)		(((x) >> TIO_BWIN_SIZE_BITS) & TIO_BWIN_WINDOW_SELECT_MASK)
 
-
+#define TIO_HWIN_SHIFT_BITS		33
+#define TIO_HWIN(x)			(NODE_OFFSET(x) >> TIO_HWIN_SHIFT_BITS)
 
 /*
  * The following definitions pertain to the IO special address
