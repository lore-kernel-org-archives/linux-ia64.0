From: Bruce Losure <blosure@sgi.com>
Date: Mon, 28 Feb 2005 23:58:17 +0000
Subject: [PATCH 2.6.11-rc3 0/1] altix: Move some header files
Message-Id: <20050228235817.16768.81931.42372@attica.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/02/28 17:38:04-06:00 blosure@attica.americas.sgi.com 
#   Moving arch/ia64/sn/kernel/include files to include/asm-ia64/sn/
# 
# arch/ia64/sn/pci/pcibr/pcibr_provider.c
#   2005/02/28 17:37:52-06:00 blosure@attica.americas.sgi.com +2 -2
#   Moving arch/ia64/sn/kernel/include files to include/asm-ia64/sn/
# 
# arch/ia64/sn/pci/pcibr/pcibr_dma.c
#   2005/02/28 17:37:52-06:00 blosure@attica.americas.sgi.com +3 -3
#   Moving arch/ia64/sn/kernel/include files to include/asm-ia64/sn/
# 
# arch/ia64/sn/kernel/setup.c
#   2005/02/28 17:37:52-06:00 blosure@attica.americas.sgi.com +2 -2
#   Moving arch/ia64/sn/kernel/include files to include/asm-ia64/sn/
# 
# arch/ia64/sn/kernel/irq.c
#   2005/02/28 17:37:52-06:00 blosure@attica.americas.sgi.com +1 -1
#   Moving arch/ia64/sn/kernel/include files to include/asm-ia64/sn/
# 
# arch/ia64/sn/kernel/io_init.c
#   2005/02/28 17:37:52-06:00 blosure@attica.americas.sgi.com +2 -2
#   Moving arch/ia64/sn/kernel/include files to include/asm-ia64/sn/
# 
# arch/ia64/sn/kernel/huberror.c
#   2005/02/28 17:37:52-06:00 blosure@attica.americas.sgi.com +2 -2
#   Moving arch/ia64/sn/kernel/include files to include/asm-ia64/sn/
# 
# arch/ia64/sn/kernel/bte_error.c
#   2005/02/28 17:37:52-06:00 blosure@attica.americas.sgi.com +2 -2
#   Moving arch/ia64/sn/kernel/include files to include/asm-ia64/sn/
# 
# include/asm-ia64/sn/tio.h
#   2005/02/28 12:24:10-06:00 blosure@attica.americas.sgi.com +0 -0
#   Rename: arch/ia64/sn/include/tio.h -> include/asm-ia64/sn/tio.h
# 
# include/asm-ia64/sn/xtalk/xwidgetdev.h
#   2005/02/28 12:23:56-06:00 blosure@attica.americas.sgi.com +0 -0
#   Rename: arch/ia64/sn/include/xtalk/xwidgetdev.h -> include/asm-ia64/sn/xtalk/xwidgetdev.h
# 
# include/asm-ia64/sn/xtalk/hubdev.h
#   2005/02/28 12:23:42-06:00 blosure@attica.americas.sgi.com +0 -0
#   Rename: arch/ia64/sn/include/xtalk/hubdev.h -> include/asm-ia64/sn/xtalk/hubdev.h
# 
diff -Nru a/arch/ia64/sn/include/tio.h b/arch/ia64/sn/include/tio.h
--- a/arch/ia64/sn/include/tio.h	2005-02-28 17:39:15 -06:00
+++ /dev/null	Wed Dec 31 16:00:00 196900
@@ -1,37 +0,0 @@
-/* 
- * This file is subject to the terms and conditions of the GNU General Public
- * License.  See the file "COPYING" in the main directory of this archive
- * for more details.
- *
- * Copyright (C) 2000-2004 Silicon Graphics, Inc. All rights reserved.
- */
-
-#ifndef _ASM_IA64_SN_TIO_H
-#define _ASM_IA64_SN_TIO_H
-
-#define	TIO_MMR_ADDR_MOD
-
-#define TIO_NODE_ID     TIO_MMR_ADDR_MOD(0x0000000090060e80)
-
-#define TIO_ITTE_BASE   0xb0008800        /* base of translation table entries */
-#define TIO_ITTE(bigwin)        (TIO_ITTE_BASE + 8*(bigwin))
-
-#define TIO_ITTE_OFFSET_BITS    8       /* size of offset field */
-#define TIO_ITTE_OFFSET_MASK    ((1<<TIO_ITTE_OFFSET_BITS)-1)
-#define TIO_ITTE_OFFSET_SHIFT   0
-
-#define TIO_ITTE_WIDGET_BITS    2       /* size of widget field */
-#define TIO_ITTE_WIDGET_MASK    ((1<<TIO_ITTE_WIDGET_BITS)-1)
-#define TIO_ITTE_WIDGET_SHIFT   12
-#define TIO_ITTE_VALID_MASK	0x1
-#define TIO_ITTE_VALID_SHIFT	16
-
-
-#define TIO_ITTE_PUT(nasid, bigwin, widget, addr, valid) \
-        REMOTE_HUB_S((nasid), TIO_ITTE(bigwin), \
-                (((((addr) >> TIO_BWIN_SIZE_BITS) & \
-                   TIO_ITTE_OFFSET_MASK) << TIO_ITTE_OFFSET_SHIFT) | \
-                (((widget) & TIO_ITTE_WIDGET_MASK) << TIO_ITTE_WIDGET_SHIFT)) | \
-		(( (valid) & TIO_ITTE_VALID_MASK) << TIO_ITTE_VALID_SHIFT))
-
-#endif /*  _ASM_IA64_SN_TIO_H */
diff -Nru a/arch/ia64/sn/include/xtalk/hubdev.h b/arch/ia64/sn/include/xtalk/hubdev.h
--- a/arch/ia64/sn/include/xtalk/hubdev.h	2005-02-28 17:39:15 -06:00
+++ /dev/null	Wed Dec 31 16:00:00 196900
@@ -1,67 +0,0 @@
-/*
- * This file is subject to the terms and conditions of the GNU General Public
- * License.  See the file "COPYING" in the main directory of this archive
- * for more details.
- *
- * Copyright (C) 1992 - 1997, 2000-2004 Silicon Graphics, Inc. All rights reserved.
- */
-#ifndef _ASM_IA64_SN_XTALK_HUBDEV_H
-#define _ASM_IA64_SN_XTALK_HUBDEV_H
-
-#define HUB_WIDGET_ID_MAX 0xf
-#define DEV_PER_WIDGET (2*2*8)
-#define IIO_ITTE_WIDGET_BITS    4       /* size of widget field */
-#define IIO_ITTE_WIDGET_MASK    ((1<<IIO_ITTE_WIDGET_BITS)-1)
-#define IIO_ITTE_WIDGET_SHIFT   8
-
-/*
- * Use the top big window as a surrogate for the first small window
- */
-#define SWIN0_BIGWIN            HUB_NUM_BIG_WINDOW
-#define IIO_NUM_ITTES   7
-#define HUB_NUM_BIG_WINDOW      (IIO_NUM_ITTES - 1)
-
-struct sn_flush_device_list {
-	int sfdl_bus;
-	int sfdl_slot;
-	int sfdl_pin;
-	struct bar_list {
-		unsigned long start;
-		unsigned long end;
-	} sfdl_bar_list[6];
-	unsigned long sfdl_force_int_addr;
-	unsigned long sfdl_flush_value;
-	volatile unsigned long *sfdl_flush_addr;
-	uint64_t sfdl_persistent_busnum;
-	struct pcibus_info *sfdl_pcibus_info;
-	spinlock_t sfdl_flush_lock;
-};
-
-/*
- * **widget_p - Used as an array[wid_num][device] of sn_flush_device_list.
- */
-struct sn_flush_nasid_entry  {
-	struct sn_flush_device_list **widget_p; /* Used as a array of wid_num */
-	uint64_t iio_itte[8];
-};
-
-struct hubdev_info {
-	geoid_t				hdi_geoid;
-	short				hdi_nasid;
-	short				hdi_peer_nasid;   /* Dual Porting Peer */
-
-	struct sn_flush_nasid_entry	hdi_flush_nasid_list;
-	struct xwidget_info		hdi_xwidget_info[HUB_WIDGET_ID_MAX + 1];
-
-
-	void				*hdi_nodepda;
-	void				*hdi_node_vertex;
-	void				*hdi_xtalk_vertex;
-};
-
-extern void hubdev_init_node(nodepda_t *, cnodeid_t);
-extern void hub_error_init(struct hubdev_info *);
-extern void ice_error_init(struct hubdev_info *);
-
-
-#endif /* _ASM_IA64_SN_XTALK_HUBDEV_H */
diff -Nru a/arch/ia64/sn/include/xtalk/xwidgetdev.h b/arch/ia64/sn/include/xtalk/xwidgetdev.h
--- a/arch/ia64/sn/include/xtalk/xwidgetdev.h	2005-02-28 17:39:15 -06:00
+++ /dev/null	Wed Dec 31 16:00:00 196900
@@ -1,70 +0,0 @@
-/*
- * This file is subject to the terms and conditions of the GNU General Public
- * License.  See the file "COPYING" in the main directory of this archive
- * for more details.
- *
- * Copyright (C) 1992-1997,2000-2003 Silicon Graphics, Inc. All Rights Reserved.
- */
-#ifndef _ASM_IA64_SN_XTALK_XWIDGET_H
-#define _ASM_IA64_SN_XTALK_XWIDGET_H
-
-/* WIDGET_ID */
-#define WIDGET_REV_NUM                  0xf0000000
-#define WIDGET_PART_NUM                 0x0ffff000
-#define WIDGET_MFG_NUM                  0x00000ffe
-#define WIDGET_REV_NUM_SHFT             28
-#define WIDGET_PART_NUM_SHFT            12
-#define WIDGET_MFG_NUM_SHFT             1
-
-#define XWIDGET_PART_NUM(widgetid) (((widgetid) & WIDGET_PART_NUM) >> WIDGET_PART_NUM_SHFT)
-#define XWIDGET_REV_NUM(widgetid) (((widgetid) & WIDGET_REV_NUM) >> WIDGET_REV_NUM_SHFT)
-#define XWIDGET_MFG_NUM(widgetid) (((widgetid) & WIDGET_MFG_NUM) >> WIDGET_MFG_NUM_SHFT)
-#define XWIDGET_PART_REV_NUM(widgetid) ((XWIDGET_PART_NUM(widgetid) << 4) | \
-                                        XWIDGET_REV_NUM(widgetid))
-#define XWIDGET_PART_REV_NUM_REV(partrev) (partrev & 0xf)
-
-/* widget configuration registers */
-struct widget_cfg{
-	uint32_t	w_id;	/* 0x04 */
-	uint32_t	w_pad_0;	/* 0x00 */
-	uint32_t	w_status;	/* 0x0c */
-	uint32_t	w_pad_1;	/* 0x08 */
-	uint32_t	w_err_upper_addr;	/* 0x14 */
-	uint32_t	w_pad_2;	/* 0x10 */
-	uint32_t	w_err_lower_addr;	/* 0x1c */
-	uint32_t	w_pad_3;	/* 0x18 */
-	uint32_t	w_control;	/* 0x24 */
-	uint32_t	w_pad_4;	/* 0x20 */
-	uint32_t	w_req_timeout;	/* 0x2c */
-	uint32_t	w_pad_5;	/* 0x28 */
-	uint32_t	w_intdest_upper_addr;	/* 0x34 */
-	uint32_t	w_pad_6;	/* 0x30 */
-	uint32_t	w_intdest_lower_addr;	/* 0x3c */
-	uint32_t	w_pad_7;	/* 0x38 */
-	uint32_t	w_err_cmd_word;	/* 0x44 */
-	uint32_t	w_pad_8;	/* 0x40 */
-	uint32_t	w_llp_cfg;	/* 0x4c */
-	uint32_t	w_pad_9;	/* 0x48 */
-	uint32_t	w_tflush;	/* 0x54 */
-	uint32_t	w_pad_10;	/* 0x50 */
-};
-
-/*
- * Crosstalk Widget Hardware Identification, as defined in the Crosstalk spec.
- */
-struct xwidget_hwid{
-	int		mfg_num;
-	int		rev_num;
-	int		part_num;
-};
-
-struct xwidget_info{
-
-	struct xwidget_hwid	xwi_hwid;	/* Widget Identification */
-	char			xwi_masterxid;	/* Hub's Widget Port Number */
-	void			*xwi_hubinfo;     /* Hub's provider private info */
-	uint64_t		*xwi_hub_provider; /* prom provider functions */
-	void			*xwi_vertex;
-};
-
-#endif                          /* _ASM_IA64_SN_XTALK_XWIDGET_H */
diff -Nru a/arch/ia64/sn/kernel/bte_error.c b/arch/ia64/sn/kernel/bte_error.c
--- a/arch/ia64/sn/kernel/bte_error.c	2005-02-28 17:39:15 -06:00
+++ b/arch/ia64/sn/kernel/bte_error.c	2005-02-28 17:39:15 -06:00
@@ -12,8 +12,8 @@
 #include <asm/sn/addrs.h>
 #include <asm/sn/shubio.h>
 #include <asm/sn/geo.h>
-#include "xtalk/xwidgetdev.h"
-#include "xtalk/hubdev.h"
+#include <asm/sn/xtalk/xwidgetdev.h>
+#include <asm/sn/xtalk/hubdev.h>
 #include <asm/sn/bte.h>
 #include <asm/param.h>
 
diff -Nru a/arch/ia64/sn/kernel/huberror.c b/arch/ia64/sn/kernel/huberror.c
--- a/arch/ia64/sn/kernel/huberror.c	2005-02-28 17:39:15 -06:00
+++ b/arch/ia64/sn/kernel/huberror.c	2005-02-28 17:39:15 -06:00
@@ -15,8 +15,8 @@
 #include <asm/sn/addrs.h>
 #include <asm/sn/shubio.h>
 #include <asm/sn/geo.h>
-#include "xtalk/xwidgetdev.h"
-#include "xtalk/hubdev.h"
+#include <asm/sn/xtalk/xwidgetdev.h>
+#include <asm/sn/xtalk/hubdev.h>
 #include <asm/sn/bte.h>
 
 void hubiio_crb_error_handler(struct hubdev_info *hubdev_info);
diff -Nru a/arch/ia64/sn/kernel/io_init.c b/arch/ia64/sn/kernel/io_init.c
--- a/arch/ia64/sn/kernel/io_init.c	2005-02-28 17:39:15 -06:00
+++ b/arch/ia64/sn/kernel/io_init.c	2005-02-28 17:39:15 -06:00
@@ -14,9 +14,9 @@
 #include "pci/pcibus_provider_defs.h"
 #include "pci/pcidev.h"
 #include "pci/pcibr_provider.h"
-#include "xtalk/xwidgetdev.h"
+#include <asm/sn/xtalk/xwidgetdev.h>
 #include <asm/sn/geo.h>
-#include "xtalk/hubdev.h"
+#include <asm/sn/xtalk/hubdev.h>
 #include <asm/sn/io.h>
 #include <asm/sn/simulator.h>
 
diff -Nru a/arch/ia64/sn/kernel/irq.c b/arch/ia64/sn/kernel/irq.c
--- a/arch/ia64/sn/kernel/irq.c	2005-02-28 17:39:15 -06:00
+++ b/arch/ia64/sn/kernel/irq.c	2005-02-28 17:39:15 -06:00
@@ -12,7 +12,7 @@
 #include <asm/sn/intr.h>
 #include <asm/sn/addrs.h>
 #include <asm/sn/arch.h>
-#include "xtalk/xwidgetdev.h"
+#include <asm/sn/xtalk/xwidgetdev.h>
 #include "pci/pcibus_provider_defs.h"
 #include "pci/pcidev.h"
 #include "pci/pcibr_provider.h"
diff -Nru a/arch/ia64/sn/kernel/setup.c b/arch/ia64/sn/kernel/setup.c
--- a/arch/ia64/sn/kernel/setup.c	2005-02-28 17:39:15 -06:00
+++ b/arch/ia64/sn/kernel/setup.c	2005-02-28 17:39:15 -06:00
@@ -47,8 +47,8 @@
 #include <asm/sn/clksupport.h>
 #include <asm/sn/sn_sal.h>
 #include <asm/sn/geo.h>
-#include "xtalk/xwidgetdev.h"
-#include "xtalk/hubdev.h"
+#include <asm/sn/xtalk/xwidgetdev.h>
+#include <asm/sn/xtalk/hubdev.h>
 #include <asm/sn/klconfig.h>
 
 
diff -Nru a/arch/ia64/sn/pci/pcibr/pcibr_dma.c b/arch/ia64/sn/pci/pcibr/pcibr_dma.c
--- a/arch/ia64/sn/pci/pcibr/pcibr_dma.c	2005-02-28 17:39:15 -06:00
+++ b/arch/ia64/sn/pci/pcibr/pcibr_dma.c	2005-02-28 17:39:15 -06:00
@@ -10,15 +10,15 @@
 #include <linux/pci.h>
 #include <asm/sn/sn_sal.h>
 #include <asm/sn/geo.h>
-#include "xtalk/xwidgetdev.h"
-#include "xtalk/hubdev.h"
+#include <asm/sn/xtalk/xwidgetdev.h>
+#include <asm/sn/xtalk/hubdev.h>
 #include "pci/pcibus_provider_defs.h"
 #include "pci/pcidev.h"
 #include "pci/tiocp.h"
 #include "pci/pic.h"
 #include "pci/pcibr_provider.h"
 #include "pci/tiocp.h"
-#include "tio.h"
+#include <asm/sn/tio.h>
 #include <asm/sn/addrs.h>
 
 extern int sn_ioif_inited;
diff -Nru a/arch/ia64/sn/pci/pcibr/pcibr_provider.c b/arch/ia64/sn/pci/pcibr/pcibr_provider.c
--- a/arch/ia64/sn/pci/pcibr/pcibr_provider.c	2005-02-28 17:39:15 -06:00
+++ b/arch/ia64/sn/pci/pcibr/pcibr_provider.c	2005-02-28 17:39:15 -06:00
@@ -10,9 +10,9 @@
 #include <linux/interrupt.h>
 #include <linux/pci.h>
 #include <asm/sn/sn_sal.h>
-#include "xtalk/xwidgetdev.h"
+#include <asm/sn/xtalk/xwidgetdev.h>
 #include <asm/sn/geo.h>
-#include "xtalk/hubdev.h"
+#include <asm/sn/xtalk/hubdev.h>
 #include "pci/pcibus_provider_defs.h"
 #include "pci/pcidev.h"
 #include "pci/pcibr_provider.h"
diff -Nru a/include/asm-ia64/sn/tio.h b/include/asm-ia64/sn/tio.h
--- /dev/null	Wed Dec 31 16:00:00 196900
+++ b/include/asm-ia64/sn/tio.h	2005-02-28 17:39:15 -06:00
@@ -0,0 +1,37 @@
+/* 
+ * This file is subject to the terms and conditions of the GNU General Public
+ * License.  See the file "COPYING" in the main directory of this archive
+ * for more details.
+ *
+ * Copyright (C) 2000-2004 Silicon Graphics, Inc. All rights reserved.
+ */
+
+#ifndef _ASM_IA64_SN_TIO_H
+#define _ASM_IA64_SN_TIO_H
+
+#define	TIO_MMR_ADDR_MOD
+
+#define TIO_NODE_ID     TIO_MMR_ADDR_MOD(0x0000000090060e80)
+
+#define TIO_ITTE_BASE   0xb0008800        /* base of translation table entries */
+#define TIO_ITTE(bigwin)        (TIO_ITTE_BASE + 8*(bigwin))
+
+#define TIO_ITTE_OFFSET_BITS    8       /* size of offset field */
+#define TIO_ITTE_OFFSET_MASK    ((1<<TIO_ITTE_OFFSET_BITS)-1)
+#define TIO_ITTE_OFFSET_SHIFT   0
+
+#define TIO_ITTE_WIDGET_BITS    2       /* size of widget field */
+#define TIO_ITTE_WIDGET_MASK    ((1<<TIO_ITTE_WIDGET_BITS)-1)
+#define TIO_ITTE_WIDGET_SHIFT   12
+#define TIO_ITTE_VALID_MASK	0x1
+#define TIO_ITTE_VALID_SHIFT	16
+
+
+#define TIO_ITTE_PUT(nasid, bigwin, widget, addr, valid) \
+        REMOTE_HUB_S((nasid), TIO_ITTE(bigwin), \
+                (((((addr) >> TIO_BWIN_SIZE_BITS) & \
+                   TIO_ITTE_OFFSET_MASK) << TIO_ITTE_OFFSET_SHIFT) | \
+                (((widget) & TIO_ITTE_WIDGET_MASK) << TIO_ITTE_WIDGET_SHIFT)) | \
+		(( (valid) & TIO_ITTE_VALID_MASK) << TIO_ITTE_VALID_SHIFT))
+
+#endif /*  _ASM_IA64_SN_TIO_H */
diff -Nru a/include/asm-ia64/sn/xtalk/hubdev.h b/include/asm-ia64/sn/xtalk/hubdev.h
--- /dev/null	Wed Dec 31 16:00:00 196900
+++ b/include/asm-ia64/sn/xtalk/hubdev.h	2005-02-28 17:39:15 -06:00
@@ -0,0 +1,67 @@
+/*
+ * This file is subject to the terms and conditions of the GNU General Public
+ * License.  See the file "COPYING" in the main directory of this archive
+ * for more details.
+ *
+ * Copyright (C) 1992 - 1997, 2000-2004 Silicon Graphics, Inc. All rights reserved.
+ */
+#ifndef _ASM_IA64_SN_XTALK_HUBDEV_H
+#define _ASM_IA64_SN_XTALK_HUBDEV_H
+
+#define HUB_WIDGET_ID_MAX 0xf
+#define DEV_PER_WIDGET (2*2*8)
+#define IIO_ITTE_WIDGET_BITS    4       /* size of widget field */
+#define IIO_ITTE_WIDGET_MASK    ((1<<IIO_ITTE_WIDGET_BITS)-1)
+#define IIO_ITTE_WIDGET_SHIFT   8
+
+/*
+ * Use the top big window as a surrogate for the first small window
+ */
+#define SWIN0_BIGWIN            HUB_NUM_BIG_WINDOW
+#define IIO_NUM_ITTES   7
+#define HUB_NUM_BIG_WINDOW      (IIO_NUM_ITTES - 1)
+
+struct sn_flush_device_list {
+	int sfdl_bus;
+	int sfdl_slot;
+	int sfdl_pin;
+	struct bar_list {
+		unsigned long start;
+		unsigned long end;
+	} sfdl_bar_list[6];
+	unsigned long sfdl_force_int_addr;
+	unsigned long sfdl_flush_value;
+	volatile unsigned long *sfdl_flush_addr;
+	uint64_t sfdl_persistent_busnum;
+	struct pcibus_info *sfdl_pcibus_info;
+	spinlock_t sfdl_flush_lock;
+};
+
+/*
+ * **widget_p - Used as an array[wid_num][device] of sn_flush_device_list.
+ */
+struct sn_flush_nasid_entry  {
+	struct sn_flush_device_list **widget_p; /* Used as a array of wid_num */
+	uint64_t iio_itte[8];
+};
+
+struct hubdev_info {
+	geoid_t				hdi_geoid;
+	short				hdi_nasid;
+	short				hdi_peer_nasid;   /* Dual Porting Peer */
+
+	struct sn_flush_nasid_entry	hdi_flush_nasid_list;
+	struct xwidget_info		hdi_xwidget_info[HUB_WIDGET_ID_MAX + 1];
+
+
+	void				*hdi_nodepda;
+	void				*hdi_node_vertex;
+	void				*hdi_xtalk_vertex;
+};
+
+extern void hubdev_init_node(nodepda_t *, cnodeid_t);
+extern void hub_error_init(struct hubdev_info *);
+extern void ice_error_init(struct hubdev_info *);
+
+
+#endif /* _ASM_IA64_SN_XTALK_HUBDEV_H */
diff -Nru a/include/asm-ia64/sn/xtalk/xwidgetdev.h b/include/asm-ia64/sn/xtalk/xwidgetdev.h
--- /dev/null	Wed Dec 31 16:00:00 196900
+++ b/include/asm-ia64/sn/xtalk/xwidgetdev.h	2005-02-28 17:39:15 -06:00
@@ -0,0 +1,70 @@
+/*
+ * This file is subject to the terms and conditions of the GNU General Public
+ * License.  See the file "COPYING" in the main directory of this archive
+ * for more details.
+ *
+ * Copyright (C) 1992-1997,2000-2003 Silicon Graphics, Inc. All Rights Reserved.
+ */
+#ifndef _ASM_IA64_SN_XTALK_XWIDGET_H
+#define _ASM_IA64_SN_XTALK_XWIDGET_H
+
+/* WIDGET_ID */
+#define WIDGET_REV_NUM                  0xf0000000
+#define WIDGET_PART_NUM                 0x0ffff000
+#define WIDGET_MFG_NUM                  0x00000ffe
+#define WIDGET_REV_NUM_SHFT             28
+#define WIDGET_PART_NUM_SHFT            12
+#define WIDGET_MFG_NUM_SHFT             1
+
+#define XWIDGET_PART_NUM(widgetid) (((widgetid) & WIDGET_PART_NUM) >> WIDGET_PART_NUM_SHFT)
+#define XWIDGET_REV_NUM(widgetid) (((widgetid) & WIDGET_REV_NUM) >> WIDGET_REV_NUM_SHFT)
+#define XWIDGET_MFG_NUM(widgetid) (((widgetid) & WIDGET_MFG_NUM) >> WIDGET_MFG_NUM_SHFT)
+#define XWIDGET_PART_REV_NUM(widgetid) ((XWIDGET_PART_NUM(widgetid) << 4) | \
+                                        XWIDGET_REV_NUM(widgetid))
+#define XWIDGET_PART_REV_NUM_REV(partrev) (partrev & 0xf)
+
+/* widget configuration registers */
+struct widget_cfg{
+	uint32_t	w_id;	/* 0x04 */
+	uint32_t	w_pad_0;	/* 0x00 */
+	uint32_t	w_status;	/* 0x0c */
+	uint32_t	w_pad_1;	/* 0x08 */
+	uint32_t	w_err_upper_addr;	/* 0x14 */
+	uint32_t	w_pad_2;	/* 0x10 */
+	uint32_t	w_err_lower_addr;	/* 0x1c */
+	uint32_t	w_pad_3;	/* 0x18 */
+	uint32_t	w_control;	/* 0x24 */
+	uint32_t	w_pad_4;	/* 0x20 */
+	uint32_t	w_req_timeout;	/* 0x2c */
+	uint32_t	w_pad_5;	/* 0x28 */
+	uint32_t	w_intdest_upper_addr;	/* 0x34 */
+	uint32_t	w_pad_6;	/* 0x30 */
+	uint32_t	w_intdest_lower_addr;	/* 0x3c */
+	uint32_t	w_pad_7;	/* 0x38 */
+	uint32_t	w_err_cmd_word;	/* 0x44 */
+	uint32_t	w_pad_8;	/* 0x40 */
+	uint32_t	w_llp_cfg;	/* 0x4c */
+	uint32_t	w_pad_9;	/* 0x48 */
+	uint32_t	w_tflush;	/* 0x54 */
+	uint32_t	w_pad_10;	/* 0x50 */
+};
+
+/*
+ * Crosstalk Widget Hardware Identification, as defined in the Crosstalk spec.
+ */
+struct xwidget_hwid{
+	int		mfg_num;
+	int		rev_num;
+	int		part_num;
+};
+
+struct xwidget_info{
+
+	struct xwidget_hwid	xwi_hwid;	/* Widget Identification */
+	char			xwi_masterxid;	/* Hub's Widget Port Number */
+	void			*xwi_hubinfo;     /* Hub's provider private info */
+	uint64_t		*xwi_hub_provider; /* prom provider functions */
+	void			*xwi_vertex;
+};
+
+#endif                          /* _ASM_IA64_SN_XTALK_XWIDGET_H */

-- 
Bruce Losure                            internet: blosure@sgi.com
SGI                                     phone:    +1 651 683-7263
2750 Blue Water Rd			vnet:	  233-7263
Eagan, MN, USA 55121
