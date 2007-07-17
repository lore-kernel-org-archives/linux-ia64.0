From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Date: Tue, 17 Jul 2007 12:20:42 +0000
Subject: [PATCH take3 2/12] Remove duplicated members in iosapic_rte_info
Message-Id: <469CB41A.2000508@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Remove duplicated members in iosapic_rte_info in iosapic.c. This patch
has no functional changes.

Signed-off-by: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

 arch/ia64/kernel/iosapic.c |   60 ++++++++++++++++++---------------------------
 1 files changed, 24 insertions(+), 36 deletions(-)

Index: linux-2.6.22/arch/ia64/kernel/iosapic.c
=================================--- linux-2.6.22.orig/arch/ia64/kernel/iosapic.c	2007-07-13 16:37:35.000000000 +0900
+++ linux-2.6.22/arch/ia64/kernel/iosapic.c	2007-07-13 16:38:04.000000000 +0900
@@ -117,16 +117,22 @@
  * These tables map IA-64 vectors to the IOSAPIC pin that generates this
  * vector.
  */
+static struct iosapic {
+	char __iomem	*addr;		/* base address of IOSAPIC */
+	unsigned int	gsi_base;	/* GSI base */
+	unsigned short	num_rte;	/* # of RTEs on this IOSAPIC */
+	int		rtes_inuse;	/* # of RTEs in use on this IOSAPIC */
+#ifdef CONFIG_NUMA
+	unsigned short	node;		/* numa node association via pxm */
+#endif
+} iosapic_lists[NR_IOSAPICS];

 struct iosapic_rte_info {
-	struct list_head rte_list;	/* node in list of RTEs sharing the
-					 * same vector */
-	char __iomem	*addr;		/* base address of IOSAPIC */
-	unsigned int	gsi_base;	/* first GSI assigned to this
-					 * IOSAPIC */
+	struct list_head rte_list;	/* RTEs sharing the same vector */
 	char		rte_index;	/* IOSAPIC RTE index */
 	int		refcnt;		/* reference counter */
 	unsigned int	flags;		/* flags */
+	struct iosapic	*iosapic;
 } ____cacheline_aligned;

 static struct iosapic_intr_info {
@@ -142,17 +148,6 @@
 	unsigned char	trigger	: 1;	/* trigger mode (see iosapic.h) */
 } iosapic_intr_info[IA64_NUM_VECTORS];

-static struct iosapic {
-	char __iomem	*addr;		/* base address of IOSAPIC */
-	unsigned int 	gsi_base;	/* first GSI assigned to this
-					 * IOSAPIC */
-	unsigned short 	num_rte;	/* # of RTEs on this IOSAPIC */
-	int		rtes_inuse;	/* # of RTEs in use on this IOSAPIC */
-#ifdef CONFIG_NUMA
-	unsigned short	node;		/* numa node association via pxm */
-#endif
-} iosapic_lists[NR_IOSAPICS];
-
 static unsigned char pcat_compat __devinitdata;	/* 8259 compatibility flag */

 static int iosapic_kmalloc_ok;
@@ -184,7 +179,7 @@
 	for (info = iosapic_intr_info; info <
 		     iosapic_intr_info + IA64_NUM_VECTORS; ++info)
 		list_for_each_entry(rte, &info->rtes, rte_list)
-			if (rte->gsi_base + rte->rte_index = gsi)
+			if (rte->iosapic->gsi_base + rte->rte_index = gsi)
 				return info - iosapic_intr_info;
 	return -1;
 }
@@ -221,7 +216,7 @@
 	struct iosapic_rte_info *rte;

 	list_for_each_entry(rte, &iosapic_intr_info[vec].rtes, rte_list)
-		if (rte->gsi_base + rte->rte_index = gsi)
+		if (rte->iosapic->gsi_base + rte->rte_index = gsi)
 			return rte;
 	return NULL;
 }
@@ -243,7 +238,7 @@
 		return;		/* not an IOSAPIC interrupt */

 	rte_index = rte->rte_index;
-	addr	= rte->addr;
+	addr    = rte->iosapic->addr;
 	pol     = iosapic_intr_info[vector].polarity;
 	trigger = iosapic_intr_info[vector].trigger;
 	dmode   = iosapic_intr_info[vector].dmode;
@@ -297,10 +292,10 @@
 			iosapic_intr_info + IA64_NUM_VECTORS; ++info, ++vec) {
 		list_for_each_entry(rte, &info->rtes,
 				rte_list) {
-			iosapic_write(rte->addr,
+			iosapic_write(rte->iosapic->addr,
 					IOSAPIC_RTE_LOW(rte->rte_index),
 					IOSAPIC_MASK|vec);
-			iosapic_eoi(rte->addr, vec);
+			iosapic_eoi(rte->iosapic->addr, vec);
 		}
 	}
 }
@@ -323,7 +318,7 @@
 	/* set only the mask bit */
 	low32 = iosapic_intr_info[vec].low32 |= IOSAPIC_MASK;
 	list_for_each_entry(rte, &iosapic_intr_info[vec].rtes, rte_list) {
-		addr = rte->addr;
+		addr = rte->iosapic->addr;
 		rte_index = rte->rte_index;
 		iosapic_write(addr, IOSAPIC_RTE_LOW(rte_index), low32);
 	}
@@ -346,7 +341,7 @@
 	spin_lock_irqsave(&iosapic_lock, flags);
 	low32 = iosapic_intr_info[vec].low32 &= ~IOSAPIC_MASK;
 	list_for_each_entry(rte, &iosapic_intr_info[vec].rtes, rte_list) {
-		addr = rte->addr;
+		addr = rte->iosapic->addr;
 		rte_index = rte->rte_index;
 		iosapic_write(addr, IOSAPIC_RTE_LOW(rte_index), low32);
 	}
@@ -394,7 +389,7 @@
 	iosapic_intr_info[vec].low32 = low32;
 	iosapic_intr_info[vec].dest = dest;
 	list_for_each_entry(rte, &iosapic_intr_info[vec].rtes, rte_list) {
-		addr = rte->addr;
+		addr = rte->iosapic->addr;
 		rte_index = rte->rte_index;
 		iosapic_write(addr, IOSAPIC_RTE_HIGH(rte_index), high32);
 		iosapic_write(addr, IOSAPIC_RTE_LOW(rte_index), low32);
@@ -422,7 +417,7 @@

 	move_native_irq(irq);
 	list_for_each_entry(rte, &iosapic_intr_info[vec].rtes, rte_list)
-		iosapic_eoi(rte->addr, vec);
+		iosapic_eoi(rte->iosapic->addr, vec);
 }

 #define iosapic_shutdown_level_irq	mask_irq
@@ -614,10 +609,7 @@
 {
 	irq_desc_t *idesc;
 	struct hw_interrupt_type *irq_type;
-	int rte_index;
 	int index;
-	unsigned long gsi_base;
-	void __iomem *iosapic_address;
 	struct iosapic_rte_info *rte;

 	index = find_iosapic(gsi);
@@ -627,9 +619,6 @@
 		return -ENODEV;
 	}

-	iosapic_address = iosapic_lists[index].addr;
-	gsi_base = iosapic_lists[index].gsi_base;
-
 	rte = gsi_vector_to_rte(gsi, vector);
 	if (!rte) {
 		rte = iosapic_alloc_rte();
@@ -639,10 +628,8 @@
 			return -ENOMEM;
 		}

-		rte_index = gsi - gsi_base;
-		rte->rte_index	= rte_index;
-		rte->addr	= iosapic_address;
-		rte->gsi_base	= gsi_base;
+		rte->iosapic	= &iosapic_lists[index];
+		rte->rte_index	= gsi - rte->iosapic->gsi_base;
 		rte->refcnt++;
 		list_add_tail(&rte->rte_list, &iosapic_intr_info[vector].rtes);
 		iosapic_intr_info[vector].count++;
@@ -877,7 +864,8 @@

 	/* Mask the interrupt */
 	low32 = iosapic_intr_info[vector].low32 | IOSAPIC_MASK;
-	iosapic_write(rte->addr, IOSAPIC_RTE_LOW(rte->rte_index), low32);
+	iosapic_write(rte->iosapic->addr,
+		      IOSAPIC_RTE_LOW(rte->rte_index), low32);

 	/* Remove the rte entry from the list */
 	list_del(&rte->rte_list);
