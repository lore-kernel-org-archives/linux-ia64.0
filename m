From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date: Tue, 27 Mar 2007 04:46:20 +0000
Subject: [PATCH 3/4] Use per iosapic lock for indirect iosapic register access
Message-Id: <4608A19C.4080002@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Use per-iosapic lock for indirect iosapic register access.

Signed-off-by: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>

---
 arch/ia64/kernel/iosapic.c |   57 ++++++++++++++++++++++-----------------------
 include/asm-ia64/iosapic.h |    4 +--
 2 files changed, 31 insertions(+), 30 deletions(-)

Index: linux-2.6.21-rc5/arch/ia64/kernel/iosapic.c
=================================--- linux-2.6.21-rc5.orig/arch/ia64/kernel/iosapic.c	2007-03-26 09:38:35.000000000 +0900
+++ linux-2.6.21-rc5/arch/ia64/kernel/iosapic.c	2007-03-26 09:38:35.000000000 +0900
@@ -126,6 +126,7 @@
 #ifdef CONFIG_NUMA
 	unsigned short	node;		/* numa node association via pxm */
 #endif
+	spinlock_t	lock;		/* lock for indirect reg access */
 } iosapic_lists[NR_IOSAPICS];
 
 struct iosapic_rte_info {
@@ -154,6 +155,16 @@
 static int iosapic_kmalloc_ok;
 static LIST_HEAD(free_rte_list);
 
+static inline void
+iosapic_write(struct iosapic *iosapic, unsigned int reg, u32 val)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&iosapic->lock, flags);
+	__iosapic_write(iosapic->addr, reg, val);
+	spin_unlock_irqrestore(&iosapic->lock, flags);
+}
+
 /*
  * Find an IOSAPIC associated with a GSI
  */
@@ -227,7 +238,6 @@
 {
 	unsigned long pol, trigger, dmode;
 	u32 low32, high32;
-	char __iomem *addr;
 	int rte_index;
 	char redir;
 	struct iosapic_rte_info *rte;
@@ -239,7 +249,6 @@
 		return;		/* not an IOSAPIC interrupt */
 
 	rte_index = rte->rte_index;
-	addr	= rte->iosapic->addr;
 	pol     = iosapic_intr_info[vector].polarity;
 	trigger = iosapic_intr_info[vector].trigger;
 	dmode   = iosapic_intr_info[vector].dmode;
@@ -269,8 +278,8 @@
 	/* dest contains both id and eid */
 	high32 = (dest << IOSAPIC_DEST_SHIFT);
 
-	iosapic_write(addr, IOSAPIC_RTE_HIGH(rte_index), high32);
-	iosapic_write(addr, IOSAPIC_RTE_LOW(rte_index), low32);
+	iosapic_write(rte->iosapic, IOSAPIC_RTE_HIGH(rte_index), high32);
+	iosapic_write(rte->iosapic, IOSAPIC_RTE_LOW(rte_index), low32);
 	iosapic_intr_info[vector].low32 = low32;
 	iosapic_intr_info[vector].dest = dest;
 }
@@ -293,7 +302,7 @@
 			iosapic_intr_info + IA64_NUM_VECTORS; ++info, ++vec) {
 		list_for_each_entry(rte, &info->rtes,
 				rte_list) {
-			iosapic_write(rte->iosapic->addr,
+			iosapic_write(rte->iosapic,
 					IOSAPIC_RTE_LOW(rte->rte_index),
 					IOSAPIC_MASK|vec);
 			iosapic_eoi(rte->iosapic->addr, vec);
@@ -305,8 +314,6 @@
 static void
 mask_irq (unsigned int irq)
 {
-	unsigned long flags;
-	char __iomem *addr;
 	u32 low32;
 	int rte_index;
 	ia64_vector vec = irq_to_vector(irq);
@@ -315,22 +322,17 @@
 	if (list_empty(&iosapic_intr_info[vec].rtes))
 		return;			/* not an IOSAPIC interrupt! */
 
-	spin_lock_irqsave(&iosapic_lock, flags);
 	/* set only the mask bit */
 	low32 = iosapic_intr_info[vec].low32 |= IOSAPIC_MASK;
 	list_for_each_entry(rte, &iosapic_intr_info[vec].rtes, rte_list) {
-		addr = rte->iosapic->addr;
 		rte_index = rte->rte_index;
-		iosapic_write(addr, IOSAPIC_RTE_LOW(rte_index), low32);
+		iosapic_write(rte->iosapic, IOSAPIC_RTE_LOW(rte_index), low32);
 	}
-	spin_unlock_irqrestore(&iosapic_lock, flags);
 }
 
 static void
 unmask_irq (unsigned int irq)
 {
-	unsigned long flags;
-	char __iomem *addr;
 	u32 low32;
 	int rte_index;
 	ia64_vector vec = irq_to_vector(irq);
@@ -339,14 +341,11 @@
 	if (list_empty(&iosapic_intr_info[vec].rtes))
 		return;			/* not an IOSAPIC interrupt! */
 
-	spin_lock_irqsave(&iosapic_lock, flags);
 	low32 = iosapic_intr_info[vec].low32 &= ~IOSAPIC_MASK;
 	list_for_each_entry(rte, &iosapic_intr_info[vec].rtes, rte_list) {
-		addr = rte->iosapic->addr;
 		rte_index = rte->rte_index;
-		iosapic_write(addr, IOSAPIC_RTE_LOW(rte_index), low32);
+		iosapic_write(rte->iosapic, IOSAPIC_RTE_LOW(rte_index), low32);
 	}
-	spin_unlock_irqrestore(&iosapic_lock, flags);
 }
 
 
@@ -354,13 +353,12 @@
 iosapic_set_affinity (unsigned int irq, cpumask_t mask)
 {
 #ifdef CONFIG_SMP
-	unsigned long flags;
 	u32 high32, low32;
 	int dest, rte_index;
-	char __iomem *addr;
 	int redir = (irq & IA64_IRQ_REDIRECTED) ? 1 : 0;
 	ia64_vector vec;
 	struct iosapic_rte_info *rte;
+	struct iosapic *iosapic;
 
 	irq &= (~IA64_IRQ_REDIRECTED);
 	vec = irq_to_vector(irq);
@@ -378,7 +376,6 @@
 	/* dest contains both id and eid */
 	high32 = dest << IOSAPIC_DEST_SHIFT;
 
-	spin_lock_irqsave(&iosapic_lock, flags);
 	low32 = iosapic_intr_info[vec].low32 & ~(7 << IOSAPIC_DELIVERY_SHIFT);
 	if (redir)
 		/* change delivery mode to lowest priority */
@@ -390,12 +387,11 @@
 	iosapic_intr_info[vec].low32 = low32;
 	iosapic_intr_info[vec].dest = dest;
 	list_for_each_entry(rte, &iosapic_intr_info[vec].rtes, rte_list) {
-		addr = rte->iosapic->addr;
+		iosapic = rte->iosapic;
 		rte_index = rte->rte_index;
-		iosapic_write(addr, IOSAPIC_RTE_HIGH(rte_index), high32);
-		iosapic_write(addr, IOSAPIC_RTE_LOW(rte_index), low32);
+		iosapic_write(iosapic, IOSAPIC_RTE_HIGH(rte_index), high32);
+		iosapic_write(iosapic, IOSAPIC_RTE_LOW(rte_index), low32);
 	}
-	spin_unlock_irqrestore(&iosapic_lock, flags);
 #endif
 }
 
@@ -500,7 +496,7 @@
 	 *	unsigned int reserved2 : 8;
 	 * }
 	 */
-	return iosapic_read(addr, IOSAPIC_VERSION);
+	return __iosapic_read(addr, IOSAPIC_VERSION);
 }
 
 static int iosapic_find_sharable_vector (unsigned long trigger,
@@ -865,8 +861,7 @@
 
 	/* Mask the interrupt */
 	low32 = iosapic_intr_info[vector].low32 | IOSAPIC_MASK;
-	iosapic_write(rte->iosapic->addr,
-		      IOSAPIC_RTE_LOW(rte->rte_index), low32);
+	iosapic_write(rte->iosapic, IOSAPIC_RTE_LOW(rte->rte_index), low32);
 
 	/* Remove the rte entry from the list */
 	list_del(&rte->rte_list);
@@ -1071,9 +1066,14 @@
 	unsigned long flags;
 
 	spin_lock_irqsave(&iosapic_lock, flags);
+	index = find_iosapic(gsi_base);
+	if (index >= 0) {
+		spin_unlock_irqrestore(&iosapic_lock, flags);
+		return -EBUSY;
+	}
+
 	addr = ioremap(phys_addr, 0);
 	ver = iosapic_version(addr);
-
 	if ((err = iosapic_check_gsi_range(gsi_base, ver))) {
 		iounmap(addr);
 		spin_unlock_irqrestore(&iosapic_lock, flags);
@@ -1094,6 +1094,7 @@
 #ifdef CONFIG_NUMA
 	iosapic_lists[index].node = MAX_NUMNODES;
 #endif
+	spin_lock_init(&iosapic_lists[index].lock);
 	spin_unlock_irqrestore(&iosapic_lock, flags);
 
 	if ((gsi_base = 0) && pcat_compat) {
Index: linux-2.6.21-rc5/include/asm-ia64/iosapic.h
=================================--- linux-2.6.21-rc5.orig/include/asm-ia64/iosapic.h	2007-03-26 09:24:26.000000000 +0900
+++ linux-2.6.21-rc5/include/asm-ia64/iosapic.h	2007-03-26 09:38:35.000000000 +0900
@@ -53,13 +53,13 @@
 
 #define NR_IOSAPICS			256
 
-static inline unsigned int iosapic_read(char __iomem *iosapic, unsigned int reg)
+static inline unsigned int __iosapic_read(char __iomem *iosapic, unsigned int reg)
 {
 	writel(reg, iosapic + IOSAPIC_REG_SELECT);
 	return readl(iosapic + IOSAPIC_WINDOW);
 }
 
-static inline void iosapic_write(char __iomem *iosapic, unsigned int reg, u32 val)
+static inline void __iosapic_write(char __iomem *iosapic, unsigned int reg, u32 val)
 {
 	writel(reg, iosapic + IOSAPIC_REG_SELECT);
 	writel(val, iosapic + IOSAPIC_WINDOW);


