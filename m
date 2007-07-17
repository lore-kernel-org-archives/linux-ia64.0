From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Date: Tue, 17 Jul 2007 12:21:26 +0000
Subject: [PATCH take3 4/12] Use per iosapic lock for indirect iosapic register
Message-Id: <469CB446.6070308@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Use per-iosapic lock for indirect iosapic register access. It reduces
lock contention.

Signed-off-by: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

 arch/ia64/kernel/iosapic.c |   57 ++++++++++++++++++++++-----------------------
 include/asm-ia64/iosapic.h |    4 +--
 2 files changed, 31 insertions(+), 30 deletions(-)

Index: linux-2.6.22/arch/ia64/kernel/iosapic.c
=================================--- linux-2.6.22.orig/arch/ia64/kernel/iosapic.c	2007-07-13 16:40:56.000000000 +0900
+++ linux-2.6.22/arch/ia64/kernel/iosapic.c	2007-07-13 16:42:24.000000000 +0900
@@ -125,6 +125,7 @@ static struct iosapic {
 #ifdef CONFIG_NUMA
 	unsigned short	node;		/* numa node association via pxm */
 #endif
+	spinlock_t	lock;		/* lock for indirect reg access */
 } iosapic_lists[NR_IOSAPICS];

 struct iosapic_rte_info {
@@ -153,6 +154,16 @@ static unsigned char pcat_compat __devin
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
@@ -226,7 +237,6 @@ set_rte (unsigned int gsi, unsigned int
 {
 	unsigned long pol, trigger, dmode;
 	u32 low32, high32;
-	char __iomem *addr;
 	int rte_index;
 	char redir;
 	struct iosapic_rte_info *rte;
@@ -238,7 +248,6 @@ set_rte (unsigned int gsi, unsigned int
 		return;		/* not an IOSAPIC interrupt */

 	rte_index = rte->rte_index;
-	addr    = rte->iosapic->addr;
 	pol     = iosapic_intr_info[vector].polarity;
 	trigger = iosapic_intr_info[vector].trigger;
 	dmode   = iosapic_intr_info[vector].dmode;
@@ -268,8 +277,8 @@ set_rte (unsigned int gsi, unsigned int
 	/* dest contains both id and eid */
 	high32 = (dest << IOSAPIC_DEST_SHIFT);

-	iosapic_write(addr, IOSAPIC_RTE_HIGH(rte_index), high32);
-	iosapic_write(addr, IOSAPIC_RTE_LOW(rte_index), low32);
+	iosapic_write(rte->iosapic, IOSAPIC_RTE_HIGH(rte_index), high32);
+	iosapic_write(rte->iosapic, IOSAPIC_RTE_LOW(rte_index), low32);
 	iosapic_intr_info[vector].low32 = low32;
 	iosapic_intr_info[vector].dest = dest;
 }
@@ -292,7 +301,7 @@ kexec_disable_iosapic(void)
 			iosapic_intr_info + IA64_NUM_VECTORS; ++info, ++vec) {
 		list_for_each_entry(rte, &info->rtes,
 				rte_list) {
-			iosapic_write(rte->iosapic->addr,
+			iosapic_write(rte->iosapic,
 					IOSAPIC_RTE_LOW(rte->rte_index),
 					IOSAPIC_MASK|vec);
 			iosapic_eoi(rte->iosapic->addr, vec);
@@ -304,8 +313,6 @@ kexec_disable_iosapic(void)
 static void
 mask_irq (unsigned int irq)
 {
-	unsigned long flags;
-	char __iomem *addr;
 	u32 low32;
 	int rte_index;
 	ia64_vector vec = irq_to_vector(irq);
@@ -314,22 +321,17 @@ mask_irq (unsigned int irq)
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
@@ -338,14 +340,11 @@ unmask_irq (unsigned int irq)
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


@@ -353,13 +352,12 @@ static void
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
@@ -377,7 +375,6 @@ iosapic_set_affinity (unsigned int irq,
 	/* dest contains both id and eid */
 	high32 = dest << IOSAPIC_DEST_SHIFT;

-	spin_lock_irqsave(&iosapic_lock, flags);
 	low32 = iosapic_intr_info[vec].low32 & ~(7 << IOSAPIC_DELIVERY_SHIFT);
 	if (redir)
 		/* change delivery mode to lowest priority */
@@ -389,12 +386,11 @@ iosapic_set_affinity (unsigned int irq,
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

@@ -499,7 +495,7 @@ iosapic_version (char __iomem *addr)
 	 *	unsigned int reserved2 : 8;
 	 * }
 	 */
-	return iosapic_read(addr, IOSAPIC_VERSION);
+	return __iosapic_read(addr, IOSAPIC_VERSION);
 }

 static int iosapic_find_sharable_vector (unsigned long trigger,
@@ -857,8 +853,7 @@ iosapic_unregister_intr (unsigned int gs

 	/* Mask the interrupt */
 	low32 = iosapic_intr_info[vector].low32 | IOSAPIC_MASK;
-	iosapic_write(rte->iosapic->addr,
-		      IOSAPIC_RTE_LOW(rte->rte_index), low32);
+	iosapic_write(rte->iosapic, IOSAPIC_RTE_LOW(rte->rte_index), low32);

 	iosapic_intr_info[vector].count--;
 	iosapic_free_rte(rte);
@@ -1060,9 +1055,14 @@ iosapic_init (unsigned long phys_addr, u
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
@@ -1083,6 +1083,7 @@ iosapic_init (unsigned long phys_addr, u
 #ifdef CONFIG_NUMA
 	iosapic_lists[index].node = MAX_NUMNODES;
 #endif
+	spin_lock_init(&iosapic_lists[index].lock);
 	spin_unlock_irqrestore(&iosapic_lock, flags);

 	if ((gsi_base = 0) && pcat_compat) {
Index: linux-2.6.22/include/asm-ia64/iosapic.h
=================================--- linux-2.6.22.orig/include/asm-ia64/iosapic.h	2007-07-13 16:20:20.000000000 +0900
+++ linux-2.6.22/include/asm-ia64/iosapic.h	2007-07-13 16:42:24.000000000 +0900
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

