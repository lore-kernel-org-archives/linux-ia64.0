From: Ishimatsu Yasuaki <isimatu.yasuaki@jp.fujitsu.com>
Date: Wed, 09 May 2007 07:54:14 +0000
Subject: [PATCH 6/12]  Fix invalid irq vector assumption for iosapic
Message-Id: <46417E26.4040003@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Many of IOSAPIC codes depends on the flollowing assumptions, but these
would become invalid when multiple vector domain will be supported in
the future.

  - 1:1 mapping between IRQ and vector
  - IRQ = vector

To fix those invalid assumptions, this patch changes iosapic_intr_info[]
to be indexed by irq number instead of vector.

Signed-off-by: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

---
 arch/ia64/kernel/iosapic.c |  258 +++++++++++++++++++++------------------------
 1 files changed, 122 insertions(+), 136 deletions(-)

Index: linux-2.6.21/arch/ia64/kernel/iosapic.c
=================================--- linux-2.6.21.orig/arch/ia64/kernel/iosapic.c	2007-05-08 12:08:05.000000000 +0900
+++ linux-2.6.21/arch/ia64/kernel/iosapic.c	2007-05-08 12:09:23.000000000 +0900
@@ -148,7 +148,7 @@
 	unsigned char 	polarity: 1;	/* interrupt polarity
 					 * (see iosapic.h) */
 	unsigned char	trigger	: 1;	/* trigger mode (see iosapic.h) */
-} iosapic_intr_info[IA64_NUM_VECTORS];
+} iosapic_intr_info[NR_IRQS];

 static unsigned char pcat_compat __devinitdata;	/* 8259 compatibility flag */

@@ -182,17 +182,18 @@
 	return -1;
 }

-static inline int
-_gsi_to_vector (unsigned int gsi)
+static inline int __gsi_to_irq(unsigned int gsi)
 {
+	int irq;
 	struct iosapic_intr_info *info;
 	struct iosapic_rte_info *rte;

-	for (info = iosapic_intr_info; info <
-		     iosapic_intr_info + IA64_NUM_VECTORS; ++info)
+	for (irq = 0; irq < NR_IRQS; irq++) {
+		info = &iosapic_intr_info[irq];
 		list_for_each_entry(rte, &info->rtes, rte_list)
 			if (rte->iosapic->gsi_base + rte->rte_index = gsi)
-				return info - iosapic_intr_info;
+				return irq;
+	}
 	return -1;
 }

@@ -203,7 +204,10 @@
 inline int
 gsi_to_vector (unsigned int gsi)
 {
-	return _gsi_to_vector(gsi);
+	int irq = __gsi_to_irq(gsi);
+	if (irq < 0)
+		return -1;
+	return irq_to_vector(irq);
 }

 int
@@ -211,62 +215,48 @@
 {
 	unsigned long flags;
 	int irq;
-	/*
-	 * XXX fix me: this assumes an identity mapping between IA-64 vector
-	 * and Linux irq numbers...
-	 */
+
 	spin_lock_irqsave(&iosapic_lock, flags);
-	irq = _gsi_to_vector(gsi);
+	irq = __gsi_to_irq(gsi);
 	spin_unlock_irqrestore(&iosapic_lock, flags);
-
 	return irq;
 }

-static struct iosapic_rte_info *gsi_vector_to_rte(unsigned int gsi,
-						  unsigned int vec)
+static struct iosapic_rte_info *find_rte(unsigned int irq, unsigned int gsi)
 {
 	struct iosapic_rte_info *rte;

-	list_for_each_entry(rte, &iosapic_intr_info[vec].rtes, rte_list)
+	list_for_each_entry(rte, &iosapic_intr_info[irq].rtes, rte_list)
 		if (rte->iosapic->gsi_base + rte->rte_index = gsi)
 			return rte;
 	return NULL;
 }

 static void
-set_rte (unsigned int gsi, unsigned int vector, unsigned int dest, int mask)
+set_rte (unsigned int gsi, unsigned int irq, unsigned int dest, int mask)
 {
 	unsigned long pol, trigger, dmode;
 	u32 low32, high32;
 	int rte_index;
 	char redir;
 	struct iosapic_rte_info *rte;
+	ia64_vector vector = irq_to_vector(irq);

 	DBG(KERN_DEBUG"IOSAPIC: routing vector %d to 0x%x\n", vector, dest);

-	rte = gsi_vector_to_rte(gsi, vector);
+	rte = find_rte(irq, gsi);
 	if (!rte)
 		return;		/* not an IOSAPIC interrupt */

 	rte_index = rte->rte_index;
-	pol     = iosapic_intr_info[vector].polarity;
-	trigger = iosapic_intr_info[vector].trigger;
-	dmode   = iosapic_intr_info[vector].dmode;
+	pol     = iosapic_intr_info[irq].polarity;
+	trigger = iosapic_intr_info[irq].trigger;
+	dmode   = iosapic_intr_info[irq].dmode;

 	redir = (dmode = IOSAPIC_LOWEST_PRIORITY) ? 1 : 0;

 #ifdef CONFIG_SMP
-	{
-		unsigned int irq;
-
-		for (irq = 0; irq < NR_IRQS; ++irq)
-			if (irq_to_vector(irq) = vector) {
-				set_irq_affinity_info(irq,
-						      (int)(dest & 0xffff),
-						      redir);
-				break;
-			}
-	}
+	set_irq_affinity_info(irq, (int)(dest & 0xffff), redir);
 #endif

 	low32 = ((pol << IOSAPIC_POLARITY_SHIFT) |
@@ -280,8 +270,8 @@

 	iosapic_write(rte->iosapic, IOSAPIC_RTE_HIGH(rte_index), high32);
 	iosapic_write(rte->iosapic, IOSAPIC_RTE_LOW(rte_index), low32);
-	iosapic_intr_info[vector].low32 = low32;
-	iosapic_intr_info[vector].dest = dest;
+	iosapic_intr_info[irq].low32 = low32;
+	iosapic_intr_info[irq].dest = dest;
 }

 static void
@@ -297,9 +287,12 @@
 {
 	struct iosapic_intr_info *info;
 	struct iosapic_rte_info *rte;
-	u8 vec = 0;
-	for (info = iosapic_intr_info; info <
-			iosapic_intr_info + IA64_NUM_VECTORS; ++info, ++vec) {
+	ia64_vector vec;
+	int irq;
+
+	for (irq = 0; irq < NR_IRQS; irq++) {
+		info = &iosapic_intr_info[irq];
+		vec = irq_to_vector(irq);
 		list_for_each_entry(rte, &info->rtes,
 				rte_list) {
 			iosapic_write(rte->iosapic,
@@ -316,15 +309,14 @@
 {
 	u32 low32;
 	int rte_index;
-	ia64_vector vec = irq_to_vector(irq);
 	struct iosapic_rte_info *rte;

-	if (list_empty(&iosapic_intr_info[vec].rtes))
+	if (list_empty(&iosapic_intr_info[irq].rtes))
 		return;			/* not an IOSAPIC interrupt! */

 	/* set only the mask bit */
-	low32 = iosapic_intr_info[vec].low32 |= IOSAPIC_MASK;
-	list_for_each_entry(rte, &iosapic_intr_info[vec].rtes, rte_list) {
+	low32 = iosapic_intr_info[irq].low32 |= IOSAPIC_MASK;
+	list_for_each_entry(rte, &iosapic_intr_info[irq].rtes, rte_list) {
 		rte_index = rte->rte_index;
 		iosapic_write(rte->iosapic, IOSAPIC_RTE_LOW(rte_index), low32);
 	}
@@ -335,14 +327,13 @@
 {
 	u32 low32;
 	int rte_index;
-	ia64_vector vec = irq_to_vector(irq);
 	struct iosapic_rte_info *rte;

-	if (list_empty(&iosapic_intr_info[vec].rtes))
+	if (list_empty(&iosapic_intr_info[irq].rtes))
 		return;			/* not an IOSAPIC interrupt! */

-	low32 = iosapic_intr_info[vec].low32 &= ~IOSAPIC_MASK;
-	list_for_each_entry(rte, &iosapic_intr_info[vec].rtes, rte_list) {
+	low32 = iosapic_intr_info[irq].low32 &= ~IOSAPIC_MASK;
+	list_for_each_entry(rte, &iosapic_intr_info[irq].rtes, rte_list) {
 		rte_index = rte->rte_index;
 		iosapic_write(rte->iosapic, IOSAPIC_RTE_LOW(rte_index), low32);
 	}
@@ -356,19 +347,17 @@
 	u32 high32, low32;
 	int dest, rte_index;
 	int redir = (irq & IA64_IRQ_REDIRECTED) ? 1 : 0;
-	ia64_vector vec;
 	struct iosapic_rte_info *rte;
 	struct iosapic *iosapic;

 	irq &= (~IA64_IRQ_REDIRECTED);
-	vec = irq_to_vector(irq);

 	if (cpus_empty(mask))
 		return;

 	dest = cpu_physical_id(first_cpu(mask));

-	if (list_empty(&iosapic_intr_info[vec].rtes))
+	if (list_empty(&iosapic_intr_info[irq].rtes))
 		return;			/* not an IOSAPIC interrupt */

 	set_irq_affinity_info(irq, dest, redir);
@@ -376,7 +365,7 @@
 	/* dest contains both id and eid */
 	high32 = dest << IOSAPIC_DEST_SHIFT;

-	low32 = iosapic_intr_info[vec].low32 & ~(7 << IOSAPIC_DELIVERY_SHIFT);
+	low32 = iosapic_intr_info[irq].low32 & ~(7 << IOSAPIC_DELIVERY_SHIFT);
 	if (redir)
 		/* change delivery mode to lowest priority */
 		low32 |= (IOSAPIC_LOWEST_PRIORITY << IOSAPIC_DELIVERY_SHIFT);
@@ -384,9 +373,9 @@
 		/* change delivery mode to fixed */
 		low32 |= (IOSAPIC_FIXED << IOSAPIC_DELIVERY_SHIFT);

-	iosapic_intr_info[vec].low32 = low32;
-	iosapic_intr_info[vec].dest = dest;
-	list_for_each_entry(rte, &iosapic_intr_info[vec].rtes, rte_list) {
+	iosapic_intr_info[irq].low32 = low32;
+	iosapic_intr_info[irq].dest = dest;
+	list_for_each_entry(rte, &iosapic_intr_info[irq].rtes, rte_list) {
 		iosapic = rte->iosapic;
 		rte_index = rte->rte_index;
 		iosapic_write(iosapic, IOSAPIC_RTE_HIGH(rte_index), high32);
@@ -413,7 +402,7 @@
 	struct iosapic_rte_info *rte;

 	move_native_irq(irq);
-	list_for_each_entry(rte, &iosapic_intr_info[vec].rtes, rte_list)
+	list_for_each_entry(rte, &iosapic_intr_info[irq].rtes, rte_list)
 		iosapic_eoi(rte->iosapic->addr, vec);
 }

@@ -499,10 +488,9 @@
 	return __iosapic_read(addr, IOSAPIC_VERSION);
 }

-static int iosapic_find_sharable_vector (unsigned long trigger,
-					 unsigned long pol)
+static int iosapic_find_sharable_irq(unsigned long trigger, unsigned long pol)
 {
-	int i, vector = -ENOSPC, min_count = -1;
+	int i, irq = -ENOSPC, min_count = -1;
 	struct iosapic_intr_info *info;

 	/*
@@ -512,19 +500,18 @@
 	if (trigger = IOSAPIC_EDGE)
 		return -ENOSPC;

-	for (i = IA64_FIRST_DEVICE_VECTOR; i <= IA64_LAST_DEVICE_VECTOR; i++) {
+	for (i = 0; i <= NR_IRQS; i++) {
 		info = &iosapic_intr_info[i];
 		if (info->trigger = trigger && info->polarity = pol &&
 		    (info->dmode = IOSAPIC_FIXED || info->dmode =
 		     IOSAPIC_LOWEST_PRIORITY)) {
 			if (min_count = -1 || info->count < min_count) {
-				vector = i;
+				irq = i;
 				min_count = info->count;
 			}
 		}
 	}
-
-	return vector;
+	return irq;
 }

 /*
@@ -532,26 +519,25 @@
  *  assign a new vector for the other and make the vector available
  */
 static void __init
-iosapic_reassign_vector (int vector)
+iosapic_reassign_vector (int irq)
 {
-	int irq, new_vector;
+	int new_irq;

-	if (!list_empty(&iosapic_intr_info[vector].rtes)) {
-		irq = create_irq();
-		if (irq < 0)
+	if (!list_empty(&iosapic_intr_info[irq].rtes)) {
+		new_irq = create_irq();
+		if (new_irq < 0)
 			panic("%s: out of interrupt vectors!\n", __FUNCTION__);
-		new_vector = irq_to_vector(irq);
 		printk(KERN_INFO "Reassigning vector %d to %d\n",
-		       vector, new_vector);
-		memcpy(&iosapic_intr_info[new_vector], &iosapic_intr_info[vector],
+		       irq_to_vector(irq), irq_to_vector(new_irq));
+		memcpy(&iosapic_intr_info[new_irq], &iosapic_intr_info[irq],
 		       sizeof(struct iosapic_intr_info));
-		INIT_LIST_HEAD(&iosapic_intr_info[new_vector].rtes);
-		list_move(iosapic_intr_info[vector].rtes.next,
-			  &iosapic_intr_info[new_vector].rtes);
-		memset(&iosapic_intr_info[vector], 0,
+		INIT_LIST_HEAD(&iosapic_intr_info[new_irq].rtes);
+		list_move(iosapic_intr_info[irq].rtes.next,
+			  &iosapic_intr_info[new_irq].rtes);
+		memset(&iosapic_intr_info[irq], 0,
 		       sizeof(struct iosapic_intr_info));
-		iosapic_intr_info[vector].low32 = IOSAPIC_MASK;
-		INIT_LIST_HEAD(&iosapic_intr_info[vector].rtes);
+		iosapic_intr_info[irq].low32 = IOSAPIC_MASK;
+		INIT_LIST_HEAD(&iosapic_intr_info[irq].rtes);
 	}
 }

@@ -596,13 +582,13 @@
 		kfree(rte);
 }

-static inline int vector_is_shared (int vector)
+static inline int irq_is_shared (int irq)
 {
-	return (iosapic_intr_info[vector].count > 1);
+	return (iosapic_intr_info[irq].count > 1);
 }

 static int
-register_intr (unsigned int gsi, int vector, unsigned char delivery,
+register_intr (unsigned int gsi, int irq, unsigned char delivery,
 	       unsigned long polarity, unsigned long trigger)
 {
 	irq_desc_t *idesc;
@@ -617,7 +603,7 @@
 		return -ENODEV;
 	}

-	rte = gsi_vector_to_rte(gsi, vector);
+	rte = find_rte(irq, gsi);
 	if (!rte) {
 		rte = iosapic_alloc_rte();
 		if (!rte) {
@@ -629,12 +615,12 @@
 		rte->iosapic	= &iosapic_lists[index];
 		rte->rte_index	= gsi - rte->iosapic->gsi_base;
 		rte->refcnt++;
-		list_add_tail(&rte->rte_list, &iosapic_intr_info[vector].rtes);
-		iosapic_intr_info[vector].count++;
+		list_add_tail(&rte->rte_list, &iosapic_intr_info[irq].rtes);
+		iosapic_intr_info[irq].count++;
 		iosapic_lists[index].rtes_inuse++;
 	}
-	else if (vector_is_shared(vector)) {
-		struct iosapic_intr_info *info = &iosapic_intr_info[vector];
+	else if (irq_is_shared(irq)) {
+		struct iosapic_intr_info *info = &iosapic_intr_info[irq];
 		if (info->trigger != trigger || info->polarity != polarity) {
 			printk (KERN_WARNING
 				"%s: cannot override the interrupt\n",
@@ -643,21 +629,21 @@
 		}
 	}

-	iosapic_intr_info[vector].polarity = polarity;
-	iosapic_intr_info[vector].dmode    = delivery;
-	iosapic_intr_info[vector].trigger  = trigger;
+	iosapic_intr_info[irq].polarity = polarity;
+	iosapic_intr_info[irq].dmode    = delivery;
+	iosapic_intr_info[irq].trigger  = trigger;

 	if (trigger = IOSAPIC_EDGE)
 		irq_type = &irq_type_iosapic_edge;
 	else
 		irq_type = &irq_type_iosapic_level;

-	idesc = irq_desc + vector;
+	idesc = irq_desc + irq;
 	if (idesc->chip != irq_type) {
 		if (idesc->chip != &no_irq_type)
 			printk(KERN_WARNING
 			       "%s: changing vector %d from %s to %s\n",
-			       __FUNCTION__, vector,
+			       __FUNCTION__, irq_to_vector(irq),
 			       idesc->chip->name, irq_type->name);
 		idesc->chip = irq_type;
 	}
@@ -665,7 +651,7 @@
 }

 static unsigned int
-get_target_cpu (unsigned int gsi, int vector)
+get_target_cpu (unsigned int gsi, int irq)
 {
 #ifdef CONFIG_SMP
 	static int cpu = -1;
@@ -675,8 +661,8 @@
 	 * In case of vector shared by multiple RTEs, all RTEs that
 	 * share the vector need to use the same destination CPU.
 	 */
-	if (!list_empty(&iosapic_intr_info[vector].rtes))
-		return iosapic_intr_info[vector].dest;
+	if (!list_empty(&iosapic_intr_info[irq].rtes))
+		return iosapic_intr_info[irq].dest;

 	/*
 	 * If the platform supports redirection via XTP, let it
@@ -693,7 +679,7 @@
 		return cpu_physical_id(smp_processor_id());

 #ifdef CONFIG_ACPI
-	if (cpe_vector > 0 && vector = IA64_CPEP_VECTOR)
+	if (cpe_vector > 0 && irq_to_vector(irq) = IA64_CPEP_VECTOR)
 		return get_cpei_target_cpu();
 #endif

@@ -719,8 +705,8 @@
 		if (!num_cpus)
 			goto skip_numa_setup;

-		/* Use vector assignment to distribute across cpus in node */
-		cpu_index = vector % num_cpus;
+		/* Use irq assignment to distribute across cpus in node */
+		cpu_index = irq % num_cpus;

 		for (numa_cpu = first_cpu(cpu_mask) ; i < cpu_index ; i++)
 			numa_cpu = next_cpu(numa_cpu, cpu_mask);
@@ -755,7 +741,7 @@
 iosapic_register_intr (unsigned int gsi,
 		       unsigned long polarity, unsigned long trigger)
 {
-	int irq, vector, mask = 1, err;
+	int irq, mask = 1, err;
 	unsigned int dest;
 	unsigned long flags;
 	struct iosapic_rte_info *rte;
@@ -767,9 +753,9 @@
 	 * don't touch the RTE.
 	 */
 	spin_lock_irqsave(&iosapic_lock, flags);
-	vector = gsi_to_vector(gsi);
-	if (vector > 0) {
-		rte = gsi_vector_to_rte(gsi, vector);
+	irq = __gsi_to_irq(gsi);
+	if (irq > 0) {
+		rte = find_rte(irq, gsi);
 		rte->refcnt++;
 		goto unlock_iosapic_lock;
 	}
@@ -777,18 +763,17 @@
 	/* If vector is running out, we try to find a sharable vector */
 	irq = create_irq();
 	if (irq < 0) {
-		vector = iosapic_find_sharable_vector(trigger, polarity);
-  		if (vector < 0)
+		irq = iosapic_find_sharable_irq(trigger, polarity);
+  		if (irq < 0)
 			goto unlock_iosapic_lock;
-	} else
-		vector = irq_to_vector(irq);
+	}

-	spin_lock(&irq_desc[vector].lock);
-	dest = get_target_cpu(gsi, vector);
-	err = register_intr(gsi, vector, IOSAPIC_LOWEST_PRIORITY,
+	spin_lock(&irq_desc[irq].lock);
+	dest = get_target_cpu(gsi, irq);
+	err = register_intr(gsi, irq, IOSAPIC_LOWEST_PRIORITY,
 			    polarity, trigger);
 	if (err < 0) {
-		vector = err;
+		irq = err;
 		goto unlock_all;
 	}

@@ -796,27 +781,27 @@
 	 * If the vector is shared and already unmasked for other
 	 * interrupt sources, don't mask it.
 	 */
-	low32 = iosapic_intr_info[vector].low32;
-	if (vector_is_shared(vector) && !(low32 & IOSAPIC_MASK))
+	low32 = iosapic_intr_info[irq].low32;
+	if (irq_is_shared(irq) && !(low32 & IOSAPIC_MASK))
 		mask = 0;
-	set_rte(gsi, vector, dest, mask);
+	set_rte(gsi, irq, dest, mask);

 	printk(KERN_INFO "GSI %u (%s, %s) -> CPU %d (0x%04x) vector %d\n",
 	       gsi, (trigger = IOSAPIC_EDGE ? "edge" : "level"),
 	       (polarity = IOSAPIC_POL_HIGH ? "high" : "low"),
-	       cpu_logical_id(dest), dest, vector);
+	       cpu_logical_id(dest), dest, irq_to_vector(irq));
  unlock_all:
-	spin_unlock(&irq_desc[vector].lock);
+	spin_unlock(&irq_desc[irq].lock);
  unlock_iosapic_lock:
 	spin_unlock_irqrestore(&iosapic_lock, flags);
-	return vector;
+	return irq;
 }

 void
 iosapic_unregister_intr (unsigned int gsi)
 {
 	unsigned long flags;
-	int irq, vector, index;
+	int irq, index;
 	irq_desc_t *idesc;
 	u32 low32;
 	unsigned long trigger, polarity;
@@ -835,10 +820,9 @@
 		WARN_ON(1);
 		return;
 	}
-	vector = irq_to_vector(irq);

 	spin_lock_irqsave(&iosapic_lock, flags);
-	if ((rte = gsi_vector_to_rte(gsi, vector)) = NULL) {
+	if ((rte = find_rte(irq, gsi)) = NULL) {
 		printk(KERN_ERR "iosapic_unregister_intr(%u) unbalanced\n",
 		       gsi);
 		WARN_ON(1);
@@ -855,36 +839,36 @@
 	spin_unlock(&idesc->lock);

 	/* Mask the interrupt */
-	low32 = iosapic_intr_info[vector].low32 | IOSAPIC_MASK;
+	low32 = iosapic_intr_info[irq].low32 | IOSAPIC_MASK;
 	iosapic_write(rte->iosapic, IOSAPIC_RTE_LOW(rte->rte_index), low32);

-	iosapic_intr_info[vector].count--;
+	iosapic_intr_info[irq].count--;
 	iosapic_free_rte(rte);
 	index = find_iosapic(gsi);
 	iosapic_lists[index].rtes_inuse--;
 	WARN_ON(iosapic_lists[index].rtes_inuse < 0);

-	trigger	 = iosapic_intr_info[vector].trigger;
-	polarity = iosapic_intr_info[vector].polarity;
-	dest     = iosapic_intr_info[vector].dest;
+	trigger	 = iosapic_intr_info[irq].trigger;
+	polarity = iosapic_intr_info[irq].polarity;
+	dest     = iosapic_intr_info[irq].dest;
 	printk(KERN_INFO
 	       "GSI %u (%s, %s) -> CPU %d (0x%04x) vector %d unregistered\n",
 	       gsi, (trigger = IOSAPIC_EDGE ? "edge" : "level"),
 	       (polarity = IOSAPIC_POL_HIGH ? "high" : "low"),
-	       cpu_logical_id(dest), dest, vector);
+	       cpu_logical_id(dest), dest, irq_to_vector(irq));

-	if (list_empty(&iosapic_intr_info[vector].rtes)) {
+	if (list_empty(&iosapic_intr_info[irq].rtes)) {
 		/* Sanity check */
-		BUG_ON(iosapic_intr_info[vector].count);
+		BUG_ON(iosapic_intr_info[irq].count);
 #ifdef CONFIG_SMP
 		/* Clear affinity */
 		cpus_setall(idesc->affinity);
 #endif
 		/* Clear the interrupt information */
-		memset(&iosapic_intr_info[vector], 0,
+		memset(&iosapic_intr_info[irq], 0,
 		       sizeof(struct iosapic_intr_info));
-		iosapic_intr_info[vector].low32 |= IOSAPIC_MASK;
-		INIT_LIST_HEAD(&iosapic_intr_info[vector].rtes);
+		iosapic_intr_info[irq].low32 |= IOSAPIC_MASK;
+		INIT_LIST_HEAD(&iosapic_intr_info[irq].rtes);

 		/* Destroy IRQ */
 		destroy_irq(irq);
@@ -909,11 +893,12 @@
 	switch (int_type) {
 	      case ACPI_INTERRUPT_PMI:
 		vector = iosapic_vector;
+		irq = vector;		/* FIXME */
 		/*
 		 * since PMI vector is alloc'd by FW(ACPI) not by kernel,
 		 * we need to make sure the vector is available
 		 */
-		iosapic_reassign_vector(vector);
+		iosapic_reassign_vector(irq);
 		delivery = IOSAPIC_PMI;
 		break;
 	      case ACPI_INTERRUPT_INIT:
@@ -925,6 +910,7 @@
 		break;
 	      case ACPI_INTERRUPT_CPEI:
 		vector = IA64_CPE_VECTOR;
+		irq = vector;		/* FIXME */
 		delivery = IOSAPIC_LOWEST_PRIORITY;
 		mask = 1;
 		break;
@@ -934,7 +920,7 @@
 		return -1;
 	}

-	register_intr(gsi, vector, delivery, polarity, trigger);
+	register_intr(gsi, irq, delivery, polarity, trigger);

 	printk(KERN_INFO
 	       "PLATFORM int %s (0x%x): GSI %u (%s, %s) -> CPU %d (0x%04x)"
@@ -944,7 +930,7 @@
 	       (polarity = IOSAPIC_POL_HIGH ? "high" : "low"),
 	       cpu_logical_id(dest), dest, vector);

-	set_rte(gsi, vector, dest, mask);
+	set_rte(gsi, irq, dest, mask);
 	return vector;
 }

@@ -956,30 +942,30 @@
 			  unsigned long polarity,
 			  unsigned long trigger)
 {
-	int vector;
+	int vector, irq;
 	unsigned int dest = cpu_physical_id(smp_processor_id());

 	vector = isa_irq_to_vector(isa_irq);
-
-	register_intr(gsi, vector, IOSAPIC_LOWEST_PRIORITY, polarity, trigger);
+	irq = vector;	/* FIXME */
+	register_intr(gsi, irq, IOSAPIC_LOWEST_PRIORITY, polarity, trigger);

 	DBG("ISA: IRQ %u -> GSI %u (%s,%s) -> CPU %d (0x%04x) vector %d\n",
 	    isa_irq, gsi, trigger = IOSAPIC_EDGE ? "edge" : "level",
 	    polarity = IOSAPIC_POL_HIGH ? "high" : "low",
 	    cpu_logical_id(dest), dest, vector);

-	set_rte(gsi, vector, dest, 1);
+	set_rte(gsi, irq, dest, 1);
 }

 void __init
 iosapic_system_init (int system_pcat_compat)
 {
-	int vector;
+	int irq;

-	for (vector = 0; vector < IA64_NUM_VECTORS; ++vector) {
-		iosapic_intr_info[vector].low32 = IOSAPIC_MASK;
+	for (irq = 0; irq < NR_IRQS; ++irq) {
+		iosapic_intr_info[irq].low32 = IOSAPIC_MASK;
 		/* mark as unused */
-		INIT_LIST_HEAD(&iosapic_intr_info[vector].rtes);
+		INIT_LIST_HEAD(&iosapic_intr_info[irq].rtes);
 	}

 	pcat_compat = system_pcat_compat;


