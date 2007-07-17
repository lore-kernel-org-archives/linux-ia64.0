From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Date: Tue, 17 Jul 2007 12:22:03 +0000
Subject: [PATCH take3 6/12] Fix invalid irq vector assumption for iosapic
Message-Id: <469CB46B.5060904@jp.fujitsu.com>
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

 arch/ia64/kernel/iosapic.c |  258 +++++++++++++++++++++------------------------
 1 files changed, 122 insertions(+), 136 deletions(-)

Index: linux-2.6.22/arch/ia64/kernel/iosapic.c
=================================--- linux-2.6.22.orig/arch/ia64/kernel/iosapic.c	2007-07-13 16:43:44.000000000 +0900
+++ linux-2.6.22/arch/ia64/kernel/iosapic.c	2007-07-13 16:49:09.000000000 +0900
@@ -147,7 +147,7 @@ static struct iosapic_intr_info {
 	unsigned char 	polarity: 1;	/* interrupt polarity
 					 * (see iosapic.h) */
 	unsigned char	trigger	: 1;	/* trigger mode (see iosapic.h) */
-} iosapic_intr_info[IA64_NUM_VECTORS];
+} iosapic_intr_info[NR_IRQS];

 static unsigned char pcat_compat __devinitdata;	/* 8259 compatibility flag */

@@ -181,17 +181,18 @@ find_iosapic (unsigned int gsi)
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

@@ -202,7 +203,10 @@ _gsi_to_vector (unsigned int gsi)
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
@@ -210,62 +214,48 @@ gsi_to_irq (unsigned int gsi)
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
@@ -279,8 +269,8 @@ set_rte (unsigned int gsi, unsigned int

 	iosapic_write(rte->iosapic, IOSAPIC_RTE_HIGH(rte_index), high32);
 	iosapic_write(rte->iosapic, IOSAPIC_RTE_LOW(rte_index), low32);
-	iosapic_intr_info[vector].low32 = low32;
-	iosapic_intr_info[vector].dest = dest;
+	iosapic_intr_info[irq].low32 = low32;
+	iosapic_intr_info[irq].dest = dest;
 }

 static void
@@ -296,9 +286,12 @@ kexec_disable_iosapic(void)
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
@@ -315,15 +308,14 @@ mask_irq (unsigned int irq)
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
@@ -334,14 +326,13 @@ unmask_irq (unsigned int irq)
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
@@ -355,19 +346,17 @@ iosapic_set_affinity (unsigned int irq,
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
@@ -375,7 +364,7 @@ iosapic_set_affinity (unsigned int irq,
 	/* dest contains both id and eid */
 	high32 = dest << IOSAPIC_DEST_SHIFT;

-	low32 = iosapic_intr_info[vec].low32 & ~(7 << IOSAPIC_DELIVERY_SHIFT);
+	low32 = iosapic_intr_info[irq].low32 & ~(7 << IOSAPIC_DELIVERY_SHIFT);
 	if (redir)
 		/* change delivery mode to lowest priority */
 		low32 |= (IOSAPIC_LOWEST_PRIORITY << IOSAPIC_DELIVERY_SHIFT);
@@ -383,9 +372,9 @@ iosapic_set_affinity (unsigned int irq,
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
@@ -412,7 +401,7 @@ iosapic_end_level_irq (unsigned int irq)
 	struct iosapic_rte_info *rte;

 	move_native_irq(irq);
-	list_for_each_entry(rte, &iosapic_intr_info[vec].rtes, rte_list)
+	list_for_each_entry(rte, &iosapic_intr_info[irq].rtes, rte_list)
 		iosapic_eoi(rte->iosapic->addr, vec);
 }

@@ -498,10 +487,9 @@ iosapic_version (char __iomem *addr)
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
@@ -511,19 +499,18 @@ static int iosapic_find_sharable_vector
 	if (trigger = IOSAPIC_EDGE)
 		return -EINVAL;

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
@@ -531,26 +518,25 @@ static int iosapic_find_sharable_vector
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

@@ -595,13 +581,13 @@ static void iosapic_free_rte (struct ios
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
@@ -616,7 +602,7 @@ register_intr (unsigned int gsi, int vec
 		return -ENODEV;
 	}

-	rte = gsi_vector_to_rte(gsi, vector);
+	rte = find_rte(irq, gsi);
 	if (!rte) {
 		rte = iosapic_alloc_rte();
 		if (!rte) {
@@ -628,12 +614,12 @@ register_intr (unsigned int gsi, int vec
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
@@ -642,21 +628,21 @@ register_intr (unsigned int gsi, int vec
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
@@ -664,7 +650,7 @@ register_intr (unsigned int gsi, int vec
 }

 static unsigned int
-get_target_cpu (unsigned int gsi, int vector)
+get_target_cpu (unsigned int gsi, int irq)
 {
 #ifdef CONFIG_SMP
 	static int cpu = -1;
@@ -674,8 +660,8 @@ get_target_cpu (unsigned int gsi, int ve
 	 * In case of vector shared by multiple RTEs, all RTEs that
 	 * share the vector need to use the same destination CPU.
 	 */
-	if (!list_empty(&iosapic_intr_info[vector].rtes))
-		return iosapic_intr_info[vector].dest;
+	if (!list_empty(&iosapic_intr_info[irq].rtes))
+		return iosapic_intr_info[irq].dest;

 	/*
 	 * If the platform supports redirection via XTP, let it
@@ -692,7 +678,7 @@ get_target_cpu (unsigned int gsi, int ve
 		return cpu_physical_id(smp_processor_id());

 #ifdef CONFIG_ACPI
-	if (cpe_vector > 0 && vector = IA64_CPEP_VECTOR)
+	if (cpe_vector > 0 && irq_to_vector(irq) = IA64_CPEP_VECTOR)
 		return get_cpei_target_cpu();
 #endif

@@ -718,8 +704,8 @@ get_target_cpu (unsigned int gsi, int ve
 		if (!num_cpus)
 			goto skip_numa_setup;

-		/* Use vector assignment to distribute across cpus in node */
-		cpu_index = vector % num_cpus;
+		/* Use irq assignment to distribute across cpus in node */
+		cpu_index = irq % num_cpus;

 		for (numa_cpu = first_cpu(cpu_mask) ; i < cpu_index ; i++)
 			numa_cpu = next_cpu(numa_cpu, cpu_mask);
@@ -754,7 +740,7 @@ int
 iosapic_register_intr (unsigned int gsi,
 		       unsigned long polarity, unsigned long trigger)
 {
-	int irq, vector, mask = 1, err;
+	int irq, mask = 1, err;
 	unsigned int dest;
 	unsigned long flags;
 	struct iosapic_rte_info *rte;
@@ -766,9 +752,9 @@ iosapic_register_intr (unsigned int gsi,
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
@@ -776,18 +762,17 @@ iosapic_register_intr (unsigned int gsi,
 	/* If vector is running out, we try to find a sharable vector */
 	irq = create_irq();
 	if (irq < 0) {
-		vector = iosapic_find_sharable_vector(trigger, polarity);
-  		if (vector < 0)
+		irq = iosapic_find_sharable_irq(trigger, polarity);
+		if (irq < 0)
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

@@ -795,27 +780,27 @@ iosapic_register_intr (unsigned int gsi,
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
@@ -834,10 +819,9 @@ iosapic_unregister_intr (unsigned int gs
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
@@ -854,36 +838,36 @@ iosapic_unregister_intr (unsigned int gs
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

-	trigger  = iosapic_intr_info[vector].trigger;
-	polarity = iosapic_intr_info[vector].polarity;
-	dest     = iosapic_intr_info[vector].dest;
+	trigger  = iosapic_intr_info[irq].trigger;
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
@@ -908,11 +892,12 @@ iosapic_register_platform_intr (u32 int_
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
@@ -924,6 +909,7 @@ iosapic_register_platform_intr (u32 int_
 		break;
 	      case ACPI_INTERRUPT_CPEI:
 		vector = IA64_CPE_VECTOR;
+		irq = vector;		/* FIXME */
 		delivery = IOSAPIC_LOWEST_PRIORITY;
 		mask = 1;
 		break;
@@ -933,7 +919,7 @@ iosapic_register_platform_intr (u32 int_
 		return -1;
 	}

-	register_intr(gsi, vector, delivery, polarity, trigger);
+	register_intr(gsi, irq, delivery, polarity, trigger);

 	printk(KERN_INFO
 	       "PLATFORM int %s (0x%x): GSI %u (%s, %s) -> CPU %d (0x%04x)"
@@ -943,7 +929,7 @@ iosapic_register_platform_intr (u32 int_
 	       (polarity = IOSAPIC_POL_HIGH ? "high" : "low"),
 	       cpu_logical_id(dest), dest, vector);

-	set_rte(gsi, vector, dest, mask);
+	set_rte(gsi, irq, dest, mask);
 	return vector;
 }

@@ -955,30 +941,30 @@ iosapic_override_isa_irq (unsigned int i
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
