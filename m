From: Russ Anderson <rja@sgi.com>
Date: Fri, 11 Mar 2005 00:24:23 +0000
Subject: [patch 1/2] Altix: Shub2 BTE support
Message-Id: <200503110024.j2B0ONml3994642@clink.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

[patch 1/2] Altix: Shub2 BTE support 

Add support for shub2 BTE.

patch 1:
	Add new MMR definitions.
	Modify BTE initialiation.
	Modify BTE copy.

patch 2:
	Shub2 BTE recovery code will be implemented in SAL.  
	Define the SAL interface.
	Modify bte_error to call SAL for shub2.

The patches apply on top of 
  - Jack Steiner's patch of 3/1/05 ("New chipset support for SN platform")
  - Mark Goodwin's patch of 3/8/05 ("Altix SN topology support for new 
					chipsets and pci topology")
  - Greg Howard's patch of 3/10/05 ("Altix system controller event handling").


Signed-off-by: Russ Anderson <rja@sgi.com>

---------------------------------------------------------------------------------
Index: linux/include/asm-ia64/sn/pda.h
=================================--- linux.orig/include/asm-ia64/sn/pda.h	2005-03-09 17:26:59.596492607 -0600
+++ linux/include/asm-ia64/sn/pda.h	2005-03-10 17:26:32.313522801 -0600
@@ -3,7 +3,7 @@
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
  *
- * Copyright (C) 1992 - 1997, 2000-2004 Silicon Graphics, Inc. All rights reserved.
+ * Copyright (C) 1992 - 1997, 2000-2005 Silicon Graphics, Inc. All rights reserved.
  */
 #ifndef _ASM_IA64_SN_PDA_H
 #define _ASM_IA64_SN_PDA_H
@@ -11,7 +11,6 @@
 #include <linux/cache.h>
 #include <asm/percpu.h>
 #include <asm/system.h>
-#include <asm/sn/bte.h>
 
 
 /*
@@ -48,8 +47,6 @@
 	unsigned long pio_write_status_val;
 	volatile unsigned long *pio_shub_war_cam_addr;
 
-	struct bteinfo_s *cpu_bte_if[BTES_PER_NODE];	/* cpu interface order */
-
 	unsigned long	sn_soft_irr[4];
 	unsigned long	sn_in_service_ivecs[4];
 	short		cnodeid_to_nasid_table[MAX_NUMNODES];
Index: linux/include/asm-ia64/sn/bte.h
=================================--- linux.orig/include/asm-ia64/sn/bte.h	2005-03-07 09:06:42.261898237 -0600
+++ linux/include/asm-ia64/sn/bte.h	2005-03-10 17:26:01.459540907 -0600
@@ -3,7 +3,7 @@
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
  *
- * Copyright (c) 2000-2004 Silicon Graphics, Inc.  All Rights Reserved.
+ * Copyright (c) 2000-2005 Silicon Graphics, Inc.  All Rights Reserved.
  */
 
 
@@ -13,8 +13,12 @@
 #include <linux/timer.h>
 #include <linux/spinlock.h>
 #include <linux/cache.h>
+#include <asm/sn/pda.h>
 #include <asm/sn/types.h>
+#include <asm/sn/shub_mmr.h>
 
+#define IBCT_NOTIFY             (0x1UL << 4)
+#define IBCT_ZFIL_MODE          (0x1UL << 0)
 
 /* #define BTE_DEBUG */
 /* #define BTE_DEBUG_VERBOSE */
@@ -39,8 +43,36 @@
 
 
 /* Define hardware */
-#define BTES_PER_NODE 2
+#define BTES_PER_NODE (is_shub2() ? 4 : 2)
+#define MAX_BTES_PER_NODE 4
 
+#define BTE2OFF_CTRL	(0)
+#define BTE2OFF_SRC	(SH2_BT_ENG_SRC_ADDR_0 - SH2_BT_ENG_CSR_0)
+#define BTE2OFF_DEST	(SH2_BT_ENG_DEST_ADDR_0 - SH2_BT_ENG_CSR_0)
+#define BTE2OFF_NOTIFY	(SH2_BT_ENG_NOTIF_ADDR_0 - SH2_BT_ENG_CSR_0)
+
+#define BTE_BASE_ADDR(interface) 				\
+    (is_shub2() ? (interface = 0) ? SH2_BT_ENG_CSR_0 :		\
+		  (interface = 1) ? SH2_BT_ENG_CSR_1 :		\
+		  (interface = 2) ? SH2_BT_ENG_CSR_2 :		\
+		  		     SH2_BT_ENG_CSR_3 		\
+		: (interface = 0) ? IIO_IBLS0 : IIO_IBLS1)
+
+#define BTE_SOURCE_ADDR(base)					\
+    (is_shub2() ? base + (BTE2OFF_SRC/8) 			\
+		: base + (BTEOFF_SRC/8))
+
+#define BTE_DEST_ADDR(base)					\
+    (is_shub2() ? base + (BTE2OFF_DEST/8) 			\
+		: base + (BTEOFF_DEST/8))
+
+#define BTE_CTRL_ADDR(base)					\
+    (is_shub2() ? base + (BTE2OFF_CTRL/8) 			\
+		: base + (BTEOFF_CTRL/8))
+
+#define BTE_NOTIF_ADDR(base)					\
+    (is_shub2() ? base + (BTE2OFF_NOTIFY/8) 			\
+		: base + (BTEOFF_NOTIFY/8))
 
 /* Define hardware modes */
 #define BTE_NOTIFY (IBCT_NOTIFY)
@@ -68,14 +100,18 @@
 #define BTE_LNSTAT_STORE(_bte, _x)					\
 			HUB_S(_bte->bte_base_addr, (_x))
 #define BTE_SRC_STORE(_bte, _x)						\
-			HUB_S(_bte->bte_base_addr + (BTEOFF_SRC/8), (_x))
+			HUB_S(_bte->bte_source_addr, (_x))
 #define BTE_DEST_STORE(_bte, _x)					\
-			HUB_S(_bte->bte_base_addr + (BTEOFF_DEST/8), (_x))
+			HUB_S(_bte->bte_destination_addr, (_x))
 #define BTE_CTRL_STORE(_bte, _x)					\
-			HUB_S(_bte->bte_base_addr + (BTEOFF_CTRL/8), (_x))
+			HUB_S(_bte->bte_control_addr, (_x))
 #define BTE_NOTIF_STORE(_bte, _x)					\
-			HUB_S(_bte->bte_base_addr + (BTEOFF_NOTIFY/8), (_x))
+			HUB_S(_bte->bte_notify_addr, (_x))
 
+#define BTE_START_TRANSFER(_bte, _len, _mode)				\
+	is_shub2() ? BTE_CTRL_STORE(_bte, IBLS_BUSY | (_mode << 24) | _len) \
+		: BTE_LNSTAT_STORE(_bte, _len);				\
+		  BTE_CTRL_STORE(_bte, _mode)
 
 /* Possible results from bte_copy and bte_unaligned_copy */
 /* The following error codes map into the BTE hardware codes
@@ -110,6 +146,10 @@
 struct bteinfo_s {
 	volatile u64 notify ____cacheline_aligned;
 	u64 *bte_base_addr ____cacheline_aligned;
+	u64 *bte_source_addr;
+	u64 *bte_destination_addr;
+	u64 *bte_control_addr;
+	u64 *bte_notify_addr;
 	spinlock_t spinlock;
 	cnodeid_t bte_cnode;	/* cnode                            */
 	int bte_error_count;	/* Number of errors encountered     */
@@ -117,6 +157,7 @@
 	int cleanup_active;	/* Interface is locked for cleanup  */
 	volatile bte_result_t bh_error;	/* error while processing   */
 	volatile u64 *most_rcnt_na;
+	struct bteinfo_s *btes_to_try[MAX_BTES_PER_NODE];
 };
 
 
Index: linux/arch/ia64/sn/kernel/bte.c
=================================--- linux.orig/arch/ia64/sn/kernel/bte.c	2005-03-07 09:06:42.321467849 -0600
+++ linux/arch/ia64/sn/kernel/bte.c	2005-03-10 17:25:49.853286279 -0600
@@ -3,7 +3,7 @@
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
  *
- * Copyright (c) 2000-2003 Silicon Graphics, Inc.  All Rights Reserved.
+ * Copyright (c) 2000-2005 Silicon Graphics, Inc.  All Rights Reserved.
  */
 
 #include <linux/config.h>
@@ -170,10 +170,6 @@
 	/* Initialize the notification to a known value. */
 	*bte->most_rcnt_na = BTE_WORD_BUSY;
 
-	/* Set the status reg busy bit and transfer length */
-	BTE_PRINTKV(("IBLS = 0x%lx\n", IBLS_BUSY | transfer_size));
-	BTE_LNSTAT_STORE(bte, IBLS_BUSY | transfer_size);
-
 	/* Set the source and destination registers */
 	BTE_PRINTKV(("IBSA = 0x%lx)\n", (TO_PHYS(src))));
 	BTE_SRC_STORE(bte, TO_PHYS(src));
@@ -188,7 +184,7 @@
 
 	/* Initiate the transfer */
 	BTE_PRINTK(("IBCT = 0x%lx)\n", BTE_VALID_MODE(mode)));
-	BTE_CTRL_STORE(bte, BTE_VALID_MODE(mode));
+	BTE_START_TRANSFER(bte, transfer_size, BTE_VALID_MODE(mode));
 
 	itc_end = ia64_get_itc() + (40000000 * local_cpu_data->cyc_per_usec);
 
@@ -429,10 +425,16 @@
 	mynodepda->bte_recovery_timer.data = (unsigned long)mynodepda;
 
 	for (i = 0; i < BTES_PER_NODE; i++) {
+		u64 *base_addr;
+
 		/* Which link status register should we use? */
-		unsigned long link_status = (i = 0 ? IIO_IBLS0 : IIO_IBLS1);
-		mynodepda->bte_if[i].bte_base_addr = (u64 *)
-		    REMOTE_HUB_ADDR(cnodeid_to_nasid(cnode), link_status);
+		base_addr = (u64 *)
+		    REMOTE_HUB_ADDR(cnodeid_to_nasid(cnode), BTE_BASE_ADDR(i));
+		mynodepda->bte_if[i].bte_base_addr = base_addr;
+		mynodepda->bte_if[i].bte_source_addr = BTE_SOURCE_ADDR(base_addr);
+		mynodepda->bte_if[i].bte_destination_addr = BTE_DEST_ADDR(base_addr);
+		mynodepda->bte_if[i].bte_control_addr = BTE_CTRL_ADDR(base_addr);
+		mynodepda->bte_if[i].bte_notify_addr = BTE_NOTIF_ADDR(base_addr);
 
 		/*
 		 * Initialize the notification and spinlock
Index: linux/include/asm-ia64/sn/nodepda.h
=================================--- linux.orig/include/asm-ia64/sn/nodepda.h	2005-03-04 15:39:31.978643987 -0600
+++ linux/include/asm-ia64/sn/nodepda.h	2005-03-10 17:28:19.416208989 -0600
@@ -3,7 +3,7 @@
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
  *
- * Copyright (C) 1992 - 1997, 2000-2004 Silicon Graphics, Inc. All rights reserved.
+ * Copyright (C) 1992 - 1997, 2000-2005 Silicon Graphics, Inc. All rights reserved.
  */
 #ifndef _ASM_IA64_SN_NODEPDA_H
 #define _ASM_IA64_SN_NODEPDA_H
@@ -43,7 +43,7 @@
 	/*
 	 * The BTEs on this node are shared by the local cpus
 	 */
-	struct bteinfo_s	bte_if[BTES_PER_NODE];	/* Virtual Interface */
+	struct bteinfo_s	bte_if[MAX_BTES_PER_NODE];	/* Virtual Interface */
 	struct timer_list	bte_recovery_timer;
 	spinlock_t		bte_recovery_lock;
 
Index: linux/include/asm-ia64/sn/shub_mmr.h
=================================--- linux.orig/include/asm-ia64/sn/shub_mmr.h	2005-03-10 15:56:22.857326092 -0600
+++ linux/include/asm-ia64/sn/shub_mmr.h	2005-03-10 17:42:19.664809350 -0600
@@ -4,7 +4,7 @@
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
  *
- * Copyright (c) 2001-2004 Silicon Graphics, Inc.  All rights reserved.
+ * Copyright (c) 2001-2005 Silicon Graphics, Inc.  All rights reserved.
  */
 
 #ifndef _ASM_IA64_SN_SHUB_MMR_H
@@ -455,4 +455,22 @@
 #define SH_INT_CMPC		shubmmr(SH, INT_CMPC)
 #define SH_INT_CMPD		shubmmr(SH, INT_CMPD)
 
+/* ===================================== */
+/*                        Register "SH2_BT_ENG_CSR_0"                         */
+/*                    Engine 0 Control and Status Register                    */
+/* ===================================== */
+
+#define SH2_BT_ENG_CSR_0                         0x0000000030040000
+#define SH2_BT_ENG_SRC_ADDR_0                    0x0000000030040080
+#define SH2_BT_ENG_DEST_ADDR_0                   0x0000000030040100
+#define SH2_BT_ENG_NOTIF_ADDR_0                  0x0000000030040180
+
+/* ===================================== */
+/*                       BTE interfaces 1-3                                   */
+/* ===================================== */
+
+#define SH2_BT_ENG_CSR_1                         0x0000000030050000
+#define SH2_BT_ENG_CSR_2                         0x0000000030060000
+#define SH2_BT_ENG_CSR_3                         0x0000000030070000
+
 #endif /* _ASM_IA64_SN_SHUB_MMR_H */
