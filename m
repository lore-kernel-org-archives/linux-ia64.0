From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date: Thu, 14 Jul 2005 09:33:05 +0000
Subject: [RFC][patch 7/10] Multiple vector domain support - IOSAPIC support
Message-Id: <42D63151.60005@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


This patch changes IOSAPIC code to support multiple vector domain.

Signed-off-by: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>

---

 linux-2.6.13-rc1-kanesige/arch/ia64/kernel/iosapic.c |  354 +++++++++++--------
 1 files changed, 220 insertions(+), 134 deletions(-)

diff -puN arch/ia64/kernel/iosapic.c~vector-domain-ia64-iosapic arch/ia64/kernel/iosapic.c
--- linux-2.6.13-rc1/arch/ia64/kernel/iosapic.c~vector-domain-ia64-iosapic	2005-07-13 16:12:50.000000000 +0900
+++ linux-2.6.13-rc1-kanesige/arch/ia64/kernel/iosapic.c	2005-07-13 16:12:50.000000000 +0900
@@ -123,7 +123,7 @@ static struct iosapic_intr_info {
 	unsigned char	dmode	: 3;	/* delivery mode (see iosapic.h) */
 	unsigned char 	polarity: 1;	/* interrupt polarity (see iosapic.h) */
 	unsigned char	trigger	: 1;	/* trigger mode (see iosapic.h) */
-} iosapic_intr_info[IA64_NUM_VECTORS];
+} iosapic_intr_info[NR_GSVS];
 
 static struct iosapic {
 	char __iomem	*addr;		/* base address of IOSAPIC */
@@ -157,12 +157,12 @@ find_iosapic (unsigned int gsi)
 }
 
 static inline int
-_gsi_to_vector (unsigned int gsi)
+gsi_to_gsv (unsigned int gsi)
 {
 	struct iosapic_intr_info *info;
 	struct iosapic_rte_info *rte;
 
-	for (info = iosapic_intr_info; info < iosapic_intr_info + IA64_NUM_VECTORS; ++info)
+	for (info = iosapic_intr_info; info < iosapic_intr_info + NR_GSVS; ++info)
 		list_for_each_entry(rte, &info->rtes, rte_list)
 			if (rte->gsi_base + rte->rte_index = gsi)
 				return info - iosapic_intr_info;
@@ -176,7 +176,7 @@ _gsi_to_vector (unsigned int gsi)
 inline int
 gsi_to_vector (unsigned int gsi)
 {
-	return _gsi_to_vector(gsi);
+	return gsv_to_vector(gsi_to_gsv(gsi));
 }
 
 int
@@ -184,31 +184,29 @@ gsi_to_irq (unsigned int gsi)
 {
 	unsigned long flags;
 	int irq;
-	/*
-	 * XXX fix me: this assumes an identity mapping vetween IA-64 vector and Linux irq
-	 * numbers...
-	 */
+
 	spin_lock_irqsave(&iosapic_lock, flags);
 	{
-		irq = _gsi_to_vector(gsi);
+		irq = gsv_to_irq(gsi_to_gsv(gsi));
 	}
 	spin_unlock_irqrestore(&iosapic_lock, flags);
 
 	return irq;
 }
 
-static struct iosapic_rte_info *gsi_vector_to_rte(unsigned int gsi, unsigned int vec)
+static struct iosapic_rte_info *
+gsi_gsv_to_rte(unsigned int gsi, unsigned int gsv)
 {
 	struct iosapic_rte_info *rte;
 
-	list_for_each_entry(rte, &iosapic_intr_info[vec].rtes, rte_list)
+	list_for_each_entry(rte, &iosapic_intr_info[gsv].rtes, rte_list)
 		if (rte->gsi_base + rte->rte_index = gsi)
 			return rte;
 	return NULL;
 }
 
 static void
-set_rte (unsigned int gsi, unsigned int vector, unsigned int dest, int mask)
+set_rte (unsigned int gsi, unsigned int gsv, unsigned int dest, int mask)
 {
 	unsigned long pol, trigger, dmode;
 	u32 low32, high32;
@@ -216,30 +214,26 @@ set_rte (unsigned int gsi, unsigned int 
 	int rte_index;
 	char redir;
 	struct iosapic_rte_info *rte;
+	unsigned int vector = gsv_to_vector(gsv);
 
 	DBG(KERN_DEBUG"IOSAPIC: routing vector %d to 0x%x\n", vector, dest);
 
-	rte = gsi_vector_to_rte(gsi, vector);
+	rte = gsi_gsv_to_rte(gsi, gsv);
 	if (!rte)
 		return;		/* not an IOSAPIC interrupt */
 
 	rte_index = rte->rte_index;
 	addr	= rte->addr;
-	pol     = iosapic_intr_info[vector].polarity;
-	trigger = iosapic_intr_info[vector].trigger;
-	dmode   = iosapic_intr_info[vector].dmode;
+	pol     = iosapic_intr_info[gsv].polarity;
+	trigger = iosapic_intr_info[gsv].trigger;
+	dmode   = iosapic_intr_info[gsv].dmode;
 
 	redir = (dmode = IOSAPIC_LOWEST_PRIORITY) ? 1 : 0;
 
 #ifdef CONFIG_SMP
 	{
-		unsigned int irq;
-
-		for (irq = 0; irq < NR_IRQS; ++irq)
-			if (irq_to_vector(irq) = vector) {
-				set_irq_affinity_info(irq, (int)(dest & 0xffff), redir);
-				break;
-			}
+		unsigned int irq = gsv_to_irq(gsv);
+		set_irq_affinity_info(irq, (int)(dest & 0xffff), redir);
 	}
 #endif
 
@@ -254,8 +248,8 @@ set_rte (unsigned int gsi, unsigned int 
 
 	iosapic_write(addr, IOSAPIC_RTE_HIGH(rte_index), high32);
 	iosapic_write(addr, IOSAPIC_RTE_LOW(rte_index), low32);
-	iosapic_intr_info[vector].low32 = low32;
-	iosapic_intr_info[vector].dest = dest;
+	iosapic_intr_info[gsv].low32 = low32;
+	iosapic_intr_info[gsv].dest = dest;
 }
 
 static void
@@ -271,17 +265,17 @@ mask_irq (unsigned int irq)
 	char __iomem *addr;
 	u32 low32;
 	int rte_index;
-	ia64_vector vec = irq_to_vector(irq);
+	unsigned int gsv = irq_to_gsv(irq);
 	struct iosapic_rte_info *rte;
 
-	if (list_empty(&iosapic_intr_info[vec].rtes))
+	if (list_empty(&iosapic_intr_info[gsv].rtes))
 		return;			/* not an IOSAPIC interrupt! */
 
 	spin_lock_irqsave(&iosapic_lock, flags);
 	{
 		/* set only the mask bit */
-		low32 = iosapic_intr_info[vec].low32 |= IOSAPIC_MASK;
-		list_for_each_entry(rte, &iosapic_intr_info[vec].rtes, rte_list) {
+		low32 = iosapic_intr_info[gsv].low32 |= IOSAPIC_MASK;
+		list_for_each_entry(rte, &iosapic_intr_info[gsv].rtes, rte_list) {
 			addr = rte->addr;
 			rte_index = rte->rte_index;
 			iosapic_write(addr, IOSAPIC_RTE_LOW(rte_index), low32);
@@ -297,16 +291,16 @@ unmask_irq (unsigned int irq)
 	char __iomem *addr;
 	u32 low32;
 	int rte_index;
-	ia64_vector vec = irq_to_vector(irq);
+	unsigned int gsv = irq_to_gsv(irq);
 	struct iosapic_rte_info *rte;
 
-	if (list_empty(&iosapic_intr_info[vec].rtes))
+	if (list_empty(&iosapic_intr_info[gsv].rtes))
 		return;			/* not an IOSAPIC interrupt! */
 
 	spin_lock_irqsave(&iosapic_lock, flags);
 	{
-		low32 = iosapic_intr_info[vec].low32 &= ~IOSAPIC_MASK;
-		list_for_each_entry(rte, &iosapic_intr_info[vec].rtes, rte_list) {
+		low32 = iosapic_intr_info[gsv].low32 &= ~IOSAPIC_MASK;
+		list_for_each_entry(rte, &iosapic_intr_info[gsv].rtes, rte_list) {
 			addr = rte->addr;
 			rte_index = rte->rte_index;
 			iosapic_write(addr, IOSAPIC_RTE_LOW(rte_index), low32);
@@ -322,21 +316,27 @@ iosapic_set_affinity (unsigned int irq, 
 #ifdef CONFIG_SMP
 	unsigned long flags;
 	u32 high32, low32;
-	int dest, rte_index;
+	int cpu, dest, rte_index, gsv;
 	char __iomem *addr;
 	int redir = (irq & IA64_IRQ_REDIRECTED) ? 1 : 0;
-	ia64_vector vec;
 	struct iosapic_rte_info *rte;
 
 	irq &= (~IA64_IRQ_REDIRECTED);
-	vec = irq_to_vector(irq);
+	gsv = irq_to_gsv(irq);
 
 	if (cpus_empty(mask))
 		return;
 
-	dest = cpu_physical_id(first_cpu(mask));
+	cpu = first_cpu(mask);
+	dest = cpu_physical_id(cpu);
 
-	if (list_empty(&iosapic_intr_info[vec].rtes))
+	/*
+	 * XXX - IRQ migration between different domains is not supported yet.
+	 */
+	if (!cpu_isset(cpu, ia64_domain_to_cpumask(gsv_to_domain(gsv))))
+		return;
+
+	if (list_empty(&iosapic_intr_info[gsv].rtes))
 		return;			/* not an IOSAPIC interrupt */
 
 	set_irq_affinity_info(irq, dest, redir);
@@ -346,7 +346,7 @@ iosapic_set_affinity (unsigned int irq, 
 
 	spin_lock_irqsave(&iosapic_lock, flags);
 	{
-		low32 = iosapic_intr_info[vec].low32 & ~(7 << IOSAPIC_DELIVERY_SHIFT);
+		low32 = iosapic_intr_info[gsv].low32 & ~(7 << IOSAPIC_DELIVERY_SHIFT);
 
 		if (redir)
 		        /* change delivery mode to lowest priority */
@@ -355,9 +355,9 @@ iosapic_set_affinity (unsigned int irq, 
 		        /* change delivery mode to fixed */
 			low32 |= (IOSAPIC_FIXED << IOSAPIC_DELIVERY_SHIFT);
 
-		iosapic_intr_info[vec].low32 = low32;
-		iosapic_intr_info[vec].dest = dest;
-		list_for_each_entry(rte, &iosapic_intr_info[vec].rtes, rte_list) {
+		iosapic_intr_info[gsv].low32 = low32;
+		iosapic_intr_info[gsv].dest = dest;
+		list_for_each_entry(rte, &iosapic_intr_info[gsv].rtes, rte_list) {
 			addr = rte->addr;
 			rte_index = rte->rte_index;
 			iosapic_write(addr, IOSAPIC_RTE_HIGH(rte_index), high32);
@@ -382,11 +382,12 @@ iosapic_startup_level_irq (unsigned int 
 static void
 iosapic_end_level_irq (unsigned int irq)
 {
-	ia64_vector vec = irq_to_vector(irq);
+	unsigned int gsv = irq_to_gsv(irq);
+	ia64_vector vec = gsv_to_vector(gsv);
 	struct iosapic_rte_info *rte;
 
 	move_irq(irq);
-	list_for_each_entry(rte, &iosapic_intr_info[vec].rtes, rte_list)
+	list_for_each_entry(rte, &iosapic_intr_info[gsv].rtes, rte_list)
 		iosapic_eoi(rte->addr, vec);
 }
 
@@ -467,9 +468,10 @@ iosapic_version (char __iomem *addr)
 	return iosapic_read(addr, IOSAPIC_VERSION);
 }
 
-static int iosapic_find_sharable_vector (unsigned long trigger, unsigned long pol)
+static int
+__iosapic_find_sharable_gsv (unsigned long trigger, unsigned long pol, int domain)
 {
-	int i, vector = -1, min_count = -1;
+	int i, min_count = -1, gsv = -1;
 	struct iosapic_intr_info *info;
 
 	/*
@@ -479,20 +481,38 @@ static int iosapic_find_sharable_vector 
 	if (trigger = IOSAPIC_EDGE)
 		return -1;
 
-	for (i = IA64_FIRST_DEVICE_VECTOR; i <= IA64_LAST_DEVICE_VECTOR; i++) {
+	for (i = domain_vector_to_gsv(domain, IA64_FIRST_DEVICE_VECTOR);
+	     i <= domain_vector_to_gsv(domain, IA64_LAST_DEVICE_VECTOR); i++) {
 		info = &iosapic_intr_info[i];
 		if (info->trigger = trigger && info->polarity = pol &&
 		    (info->dmode = IOSAPIC_FIXED || info->dmode = IOSAPIC_LOWEST_PRIORITY)) {
 			if (min_count = -1 || info->count < min_count) {
-				vector = i;
+				gsv = i;
 				min_count = info->count;
 			}
 		}
 	}
-	if (vector < 0)
-		panic("%s: out of interrupt vectors!\n", __FUNCTION__);
+	return gsv;
+}
+
+static int
+iosapic_find_sharable_gsv (unsigned long trigger, unsigned long pol, int domain)
+{
+	static int next_domain = 0;
+	int i, gsv;
 
-	return vector;
+	if (domain = AUTO_ASSIGN) {
+		for (i = 0; i < NR_VECTOR_DOMAINS; i++) {
+			gsv = __iosapic_find_sharable_gsv(trigger, pol, next_domain++);
+			if (next_domain >= NR_VECTOR_DOMAINS)
+				next_domain = 0;
+			if (gsv >= 0)
+				break;
+		}
+		return gsv;
+	}
+	else
+		return __iosapic_find_sharable_gsv(trigger, pol, domain);
 }
 
 /*
@@ -500,20 +520,21 @@ static int iosapic_find_sharable_vector 
  *  assign a new vector for the other and make the vector available
  */
 static void __init
-iosapic_reassign_vector (int vector)
+iosapic_reassign_gsv (unsigned int gsv)
 {
-	int new_vector;
+	int new_gsv;
 
-	if (!list_empty(&iosapic_intr_info[vector].rtes)) {
-		new_vector = assign_irq_vector(AUTO_ASSIGN);
-		printk(KERN_INFO "Reassigning vector %d to %d\n", vector, new_vector);
-		memcpy(&iosapic_intr_info[new_vector], &iosapic_intr_info[vector],
+	if (!list_empty(&iosapic_intr_info[gsv].rtes)) {
+		new_gsv = assign_irq_gsv(AUTO_ASSIGN, gsv_to_domain(gsv));
+		printk(KERN_INFO "Reassigning vector %d to %d\n",
+			gsv_to_vector(gsv), gsv_to_vector(new_gsv));
+		memcpy(&iosapic_intr_info[new_gsv], &iosapic_intr_info[gsv],
 		       sizeof(struct iosapic_intr_info));
-		INIT_LIST_HEAD(&iosapic_intr_info[new_vector].rtes);
-		list_move(iosapic_intr_info[vector].rtes.next, &iosapic_intr_info[new_vector].rtes);
-		memset(&iosapic_intr_info[vector], 0, sizeof(struct iosapic_intr_info));
-		iosapic_intr_info[vector].low32 = IOSAPIC_MASK;
-		INIT_LIST_HEAD(&iosapic_intr_info[vector].rtes);
+		INIT_LIST_HEAD(&iosapic_intr_info[new_gsv].rtes);
+		list_move(iosapic_intr_info[gsv].rtes.next, &iosapic_intr_info[new_gsv].rtes);
+		memset(&iosapic_intr_info[gsv], 0, sizeof(struct iosapic_intr_info));
+		iosapic_intr_info[gsv].low32 = IOSAPIC_MASK;
+		INIT_LIST_HEAD(&iosapic_intr_info[gsv].rtes);
 	}
 }
 
@@ -556,13 +577,13 @@ static void iosapic_free_rte (struct ios
 		kfree(rte);
 }
 
-static inline int vector_is_shared (int vector)
+static inline int gsv_is_shared (unsigned int gsv)
 {
-	return (iosapic_intr_info[vector].count > 1);
+	return (iosapic_intr_info[gsv].count > 1);
 }
 
 static void
-register_intr (unsigned int gsi, int vector, unsigned char delivery,
+register_intr (unsigned int gsi, unsigned int gsv, unsigned char delivery,
 	       unsigned long polarity, unsigned long trigger)
 {
 	irq_desc_t *idesc;
@@ -582,7 +603,7 @@ register_intr (unsigned int gsi, int vec
 	iosapic_address = iosapic_lists[index].addr;
 	gsi_base = iosapic_lists[index].gsi_base;
 
-	rte = gsi_vector_to_rte(gsi, vector);
+	rte = gsi_gsv_to_rte(gsi, gsv);
 	if (!rte) {
 		rte = iosapic_alloc_rte();
 		if (!rte) {
@@ -595,48 +616,99 @@ register_intr (unsigned int gsi, int vec
 		rte->addr	= iosapic_address;
 		rte->gsi_base	= gsi_base;
 		rte->refcnt++;
-		list_add_tail(&rte->rte_list, &iosapic_intr_info[vector].rtes);
-		iosapic_intr_info[vector].count++;
+		list_add_tail(&rte->rte_list, &iosapic_intr_info[gsv].rtes);
+		iosapic_intr_info[gsv].count++;
 		iosapic_lists[index].rtes_inuse++;
 	}
-	else if (vector_is_shared(vector)) {
-		struct iosapic_intr_info *info = &iosapic_intr_info[vector];
+	else if (gsv_is_shared(gsv)) {
+		struct iosapic_intr_info *info = &iosapic_intr_info[gsv];
 		if (info->trigger != trigger || info->polarity != polarity) {
 			printk (KERN_WARNING "%s: cannot override the interrupt\n", __FUNCTION__);
 			return;
 		}
 	}
 
-	iosapic_intr_info[vector].polarity = polarity;
-	iosapic_intr_info[vector].dmode    = delivery;
-	iosapic_intr_info[vector].trigger  = trigger;
+	iosapic_intr_info[gsv].polarity = polarity;
+	iosapic_intr_info[gsv].dmode    = delivery;
+	iosapic_intr_info[gsv].trigger  = trigger;
 
 	if (trigger = IOSAPIC_EDGE)
 		irq_type = &irq_type_iosapic_edge;
 	else
 		irq_type = &irq_type_iosapic_level;
 
-	idesc = irq_descp(vector);
+	idesc = irq_descp(gsv_to_irq(gsv));
 	if (idesc->handler != irq_type) {
 		if (idesc->handler != &no_irq_type)
 			printk(KERN_WARNING "%s: changing vector %d from %s to %s\n",
-			       __FUNCTION__, vector, idesc->handler->typename, irq_type->typename);
+			       __FUNCTION__, gsv_to_vector(gsv),
+			       idesc->handler->typename, irq_type->typename);
 		idesc->handler = irq_type;
 	}
 }
 
+int
+get_target_domain (unsigned int gsi)
+{
+#ifdef CONFIG_VECTOR_DOMAIN
+	/*
+	 * Some interrupts (ACPI SCI, for instance) are registered
+	 * before the BSP is marked as online.
+	 */
+	if (!cpu_online(smp_processor_id()))
+		return ia64_cpu_to_domain(smp_processor_id());
+
+#ifdef CONFIG_NUMA
+	{
+		int num_cpus, cpu_index, iosapic_index, numa_cpu, i = 0;
+		cpumask_t cpu_mask;
+
+		iosapic_index = find_iosapic(gsi);
+		if (iosapic_index < 0 ||
+		    iosapic_lists[iosapic_index].node = MAX_NUMNODES)
+			goto skip_numa_setup;
+
+		cpu_mask = node_to_cpumask(iosapic_lists[iosapic_index].node);
+
+		for_each_cpu_mask(numa_cpu, cpu_mask) {
+			if (!cpu_online(numa_cpu))
+				cpu_clear(numa_cpu, cpu_mask);
+		}
+
+		num_cpus = cpus_weight(cpu_mask);
+
+		if (!num_cpus)
+			goto skip_numa_setup;
+
+		/* Use vector assigment to distribute across cpus in node */
+		cpu_index = gsi % num_cpus;
+
+		for (numa_cpu = first_cpu(cpu_mask) ; i < cpu_index ; i++)
+			numa_cpu = next_cpu(numa_cpu, cpu_mask);
+
+		if (numa_cpu != NR_CPUS)
+			return ia64_cpu_to_domain(numa_cpu);
+	}
+skip_numa_setup:
+#endif
+
+#endif /* CONFIG_VECTOR_DOMAIN */
+	return AUTO_ASSIGN;
+}
+
 static unsigned int
-get_target_cpu (unsigned int gsi, int vector)
+get_target_cpu (unsigned int gsi, unsigned int gsv)
 {
 #ifdef CONFIG_SMP
 	static int cpu = -1;
+	int domain;
 
 	/*
 	 * In case of vector shared by multiple RTEs, all RTEs that
 	 * share the vector need to use the same destination CPU.
 	 */
-	if (!list_empty(&iosapic_intr_info[vector].rtes))
-		return iosapic_intr_info[vector].dest;
+	if (!list_empty(&iosapic_intr_info[gsv].rtes))
+		return iosapic_intr_info[gsv].dest;
 
 	/*
 	 * If the platform supports redirection via XTP, let it
@@ -652,6 +724,8 @@ get_target_cpu (unsigned int gsi, int ve
 	if (!cpu_online(smp_processor_id()))
 		return cpu_physical_id(smp_processor_id());
 
+	domain = gsv_to_domain(gsv);
+
 #ifdef CONFIG_NUMA
 	{
 		int num_cpus, cpu_index, iosapic_index, numa_cpu, i = 0;
@@ -662,7 +736,9 @@ get_target_cpu (unsigned int gsi, int ve
 		    iosapic_lists[iosapic_index].node = MAX_NUMNODES)
 			goto skip_numa_setup;
 
-		cpu_mask = node_to_cpumask(iosapic_lists[iosapic_index].node);
+		cpus_and(cpu_mask,
+			 node_to_cpumask(iosapic_lists[iosapic_index].node),
+			 ia64_domain_to_cpumask(domain));
 
 		for_each_cpu_mask(numa_cpu, cpu_mask) {
 			if (!cpu_online(numa_cpu))
@@ -675,7 +751,7 @@ get_target_cpu (unsigned int gsi, int ve
 			goto skip_numa_setup;
 
 		/* Use vector assigment to distribute across cpus in node */
-		cpu_index = vector % num_cpus;
+		cpu_index = gsv % num_cpus;
 
 		for (numa_cpu = first_cpu(cpu_mask) ; i < cpu_index ; i++)
 			numa_cpu = next_cpu(numa_cpu, cpu_mask);
@@ -693,7 +769,7 @@ skip_numa_setup:
 	do {
 		if (++cpu >= NR_CPUS)
 			cpu = 0;
-	} while (!cpu_online(cpu));
+	} while (!cpu_isset(cpu, ia64_domain_to_cpumask(domain)));
 
 	return cpu_physical_id(cpu);
 #else
@@ -710,11 +786,12 @@ int
 iosapic_register_intr (unsigned int gsi,
 		       unsigned long polarity, unsigned long trigger)
 {
-	int vector, mask = 1;
+	int mask = 1, domain, gsv;
 	unsigned int dest;
 	unsigned long flags;
 	struct iosapic_rte_info *rte;
 	u32 low32;
+	irq_desc_t *idesc;
 again:
 	/*
 	 * If this GSI has already been registered (i.e., it's a
@@ -723,54 +800,59 @@ again:
 	 */
 	spin_lock_irqsave(&iosapic_lock, flags);
 	{
-		vector = gsi_to_vector(gsi);
-		if (vector > 0) {
-			rte = gsi_vector_to_rte(gsi, vector);
+		gsv = gsi_to_gsv(gsi);
+		if (gsv > 0) {
+			rte = gsi_gsv_to_rte(gsi, gsv);
 			rte->refcnt++;
 			spin_unlock_irqrestore(&iosapic_lock, flags);
-			return vector;
+			return gsv_to_irq(gsv);
 		}
 	}
 	spin_unlock_irqrestore(&iosapic_lock, flags);
 
+	domain = get_target_domain(gsi);
 	/* If vector is running out, we try to find a sharable vector */
-	vector = assign_irq_vector_nopanic(AUTO_ASSIGN);
-	if (vector < 0)
-		vector = iosapic_find_sharable_vector(trigger, polarity);
+	gsv = assign_irq_gsv(AUTO_ASSIGN, domain);
+	if (gsv < 0) {
+		gsv = iosapic_find_sharable_gsv(trigger, polarity, domain);
+		if (gsv < 0)
+			panic("%s: out of interrupt vectors!\n", __FUNCTION__);
+	}
 
-	spin_lock_irqsave(&irq_descp(vector)->lock, flags);
+	idesc = irq_descp(gsv_to_irq(gsv));
+	spin_lock_irqsave(&idesc->lock, flags);
 	spin_lock(&iosapic_lock);
 	{
-		if (gsi_to_vector(gsi) > 0) {
-			if (list_empty(&iosapic_intr_info[vector].rtes))
-				free_irq_vector(vector);
+		if (gsi_to_gsv(gsi) > 0) {
+			if (list_empty(&iosapic_intr_info[gsv].rtes))
+				free_irq_gsv(gsv);
 			spin_unlock(&iosapic_lock);
-			spin_unlock_irqrestore(&irq_descp(vector)->lock, flags);
+			spin_unlock_irqrestore(&idesc->lock, flags);
 			goto again;
 		}
 
-		dest = get_target_cpu(gsi, vector);
-		register_intr(gsi, vector, IOSAPIC_LOWEST_PRIORITY,
+		dest = get_target_cpu(gsi, gsv);
+		register_intr(gsi, gsv, IOSAPIC_LOWEST_PRIORITY,
 			      polarity, trigger);
 
 		/*
 		 * If the vector is shared and already unmasked for
 		 * other interrupt sources, don't mask it.
 		 */
-		low32 = iosapic_intr_info[vector].low32;
-		if (vector_is_shared(vector) && !(low32 & IOSAPIC_MASK))
+		low32 = iosapic_intr_info[gsv].low32;
+		if (gsv_is_shared(gsv) && !(low32 & IOSAPIC_MASK))
 			mask = 0;
-		set_rte(gsi, vector, dest, mask);
+		set_rte(gsi, gsv, dest, mask);
 	}
 	spin_unlock(&iosapic_lock);
-	spin_unlock_irqrestore(&irq_descp(vector)->lock, flags);
+	spin_unlock_irqrestore(&idesc->lock, flags);
 
 	printk(KERN_INFO "GSI %u (%s, %s) -> CPU %d (0x%04x) vector %d\n",
 	       gsi, (trigger = IOSAPIC_EDGE ? "edge" : "level"),
 	       (polarity = IOSAPIC_POL_HIGH ? "high" : "low"),
-	       cpu_logical_id(dest), dest, vector);
+	       cpu_logical_id(dest), dest, gsv_to_vector(gsv));
 
-	return vector;
+	return gsv_to_irq(gsv);
 }
 
 #ifdef CONFIG_ACPI_DEALLOCATE_IRQ
@@ -778,11 +860,11 @@ void
 iosapic_unregister_intr (unsigned int gsi)
 {
 	unsigned long flags;
-	int irq, vector, index;
+	int irq, index;
 	irq_desc_t *idesc;
 	u32 low32;
 	unsigned long trigger, polarity;
-	unsigned int dest;
+	unsigned int gsv, dest;
 	struct iosapic_rte_info *rte;
 
 	/*
@@ -796,13 +878,13 @@ iosapic_unregister_intr (unsigned int gs
 		WARN_ON(1);
 		return;
 	}
-	vector = irq_to_vector(irq);
+	gsv = irq_to_gsv(irq);
 
 	idesc = irq_descp(irq);
 	spin_lock_irqsave(&idesc->lock, flags);
 	spin_lock(&iosapic_lock);
 	{
-		if ((rte = gsi_vector_to_rte(gsi, vector)) = NULL) {
+		if ((rte = gsi_gsv_to_rte(gsi, gsv)) = NULL) {
 			printk(KERN_ERR "iosapic_unregister_intr(%u) unbalanced\n", gsi);
 			WARN_ON(1);
 			goto out;
@@ -812,36 +894,36 @@ iosapic_unregister_intr (unsigned int gs
 			goto out;
 
 		/* Mask the interrupt */
-		low32 = iosapic_intr_info[vector].low32 | IOSAPIC_MASK;
+		low32 = iosapic_intr_info[gsv].low32 | IOSAPIC_MASK;
 		iosapic_write(rte->addr, IOSAPIC_RTE_LOW(rte->rte_index), low32);
 
 		/* Remove the rte entry from the list */
 		list_del(&rte->rte_list);
-		iosapic_intr_info[vector].count--;
+		iosapic_intr_info[gsv].count--;
 		iosapic_free_rte(rte);
 		index = find_iosapic(gsi);
 		iosapic_lists[index].rtes_inuse--;
 		WARN_ON(iosapic_lists[index].rtes_inuse < 0);
 
-		trigger	 = iosapic_intr_info[vector].trigger;
-		polarity = iosapic_intr_info[vector].polarity;
-		dest     = iosapic_intr_info[vector].dest;
+		trigger	 = iosapic_intr_info[gsv].trigger;
+		polarity = iosapic_intr_info[gsv].polarity;
+		dest     = iosapic_intr_info[gsv].dest;
 		printk(KERN_INFO "GSI %u (%s, %s) -> CPU %d (0x%04x) vector %d unregistered\n",
 		       gsi, (trigger = IOSAPIC_EDGE ? "edge" : "level"),
 		       (polarity = IOSAPIC_POL_HIGH ? "high" : "low"),
-		       cpu_logical_id(dest), dest, vector);
+		       cpu_logical_id(dest), dest, gsv_to_vector(gsv));
 
-		if (list_empty(&iosapic_intr_info[vector].rtes)) {
+		if (list_empty(&iosapic_intr_info[gsv].rtes)) {
 			/* Sanity check */
-			BUG_ON(iosapic_intr_info[vector].count);
+			BUG_ON(iosapic_intr_info[gsv].count);
 
 			/* Clear the interrupt controller descriptor */
 			idesc->handler = &no_irq_type;
 
 			/* Clear the interrupt information */
-			memset(&iosapic_intr_info[vector], 0, sizeof(struct iosapic_intr_info));
-			iosapic_intr_info[vector].low32 |= IOSAPIC_MASK;
-			INIT_LIST_HEAD(&iosapic_intr_info[vector].rtes);
+			memset(&iosapic_intr_info[gsv], 0, sizeof(struct iosapic_intr_info));
+			iosapic_intr_info[gsv].low32 |= IOSAPIC_MASK;
+			INIT_LIST_HEAD(&iosapic_intr_info[gsv].rtes);
 
 			if (idesc->action) {
 				printk(KERN_ERR "interrupt handlers still exist on IRQ %u\n", irq);
@@ -849,7 +931,7 @@ iosapic_unregister_intr (unsigned int gs
 			}
 
 			/* Free the interrupt vector */
-			free_irq_vector(vector);
+			free_irq_gsv(gsv);
 		}
 	}
  out:
@@ -869,25 +951,26 @@ iosapic_register_platform_intr (u32 int_
 {
 	static const char * const name[] = {"unknown", "PMI", "INIT", "CPEI"};
 	unsigned char delivery;
-	int vector, mask = 0;
-	unsigned int dest = ((id << 8) | eid) & 0xffff;
+	int mask = 0;
+	unsigned int gsv, dest = ((id << 8) | eid) & 0xffff;
+	int domain = ia64_cpu_to_domain(cpu_logical_id(dest));
 
 	switch (int_type) {
 	      case ACPI_INTERRUPT_PMI:
-		vector = iosapic_vector;
+		gsv = domain_vector_to_gsv(domain, iosapic_vector);
 		/*
 		 * since PMI vector is alloc'd by FW(ACPI) not by kernel,
 		 * we need to make sure the vector is available
 		 */
-		iosapic_reassign_vector(vector);
+		iosapic_reassign_gsv(gsv);
 		delivery = IOSAPIC_PMI;
 		break;
 	      case ACPI_INTERRUPT_INIT:
-		vector = assign_irq_vector(AUTO_ASSIGN);
+		gsv = assign_irq_gsv(AUTO_ASSIGN, domain);
 		delivery = IOSAPIC_INIT;
 		break;
 	      case ACPI_INTERRUPT_CPEI:
-		vector = IA64_CPE_VECTOR;
+		gsv = domain_vector_to_gsv(domain, IA64_CPE_VECTOR);
 		delivery = IOSAPIC_LOWEST_PRIORITY;
 		mask = 1;
 		break;
@@ -896,16 +979,16 @@ iosapic_register_platform_intr (u32 int_
 		return -1;
 	}
 
-	register_intr(gsi, vector, delivery, polarity, trigger);
+	register_intr(gsi, gsv, delivery, polarity, trigger);
 
 	printk(KERN_INFO "PLATFORM int %s (0x%x): GSI %u (%s, %s) -> CPU %d (0x%04x) vector %d\n",
 	       int_type < ARRAY_SIZE(name) ? name[int_type] : "unknown",
 	       int_type, gsi, (trigger = IOSAPIC_EDGE ? "edge" : "level"),
 	       (polarity = IOSAPIC_POL_HIGH ? "high" : "low"),
-	       cpu_logical_id(dest), dest, vector);
+	       cpu_logical_id(dest), dest, gsv_to_vector(gsv));
 
-	set_rte(gsi, vector, dest, mask);
-	return vector;
+	set_rte(gsi, gsv, dest, mask);
+	return gsv_to_vector(gsv);
 }
 
 
@@ -919,28 +1002,31 @@ iosapic_override_isa_irq (unsigned int i
 			  unsigned long trigger)
 {
 	int vector;
+	unsigned int gsv;
 	unsigned int dest = cpu_physical_id(smp_processor_id());
+	unsigned int domain = ia64_cpu_to_domain(smp_processor_id());
 
 	vector = isa_irq_to_vector(isa_irq);
+	gsv = domain_vector_to_gsv(domain, vector);
 
-	register_intr(gsi, vector, IOSAPIC_LOWEST_PRIORITY, polarity, trigger);
+	register_intr(gsi, gsv, IOSAPIC_LOWEST_PRIORITY, polarity, trigger);
 
 	DBG("ISA: IRQ %u -> GSI %u (%s,%s) -> CPU %d (0x%04x) vector %d\n",
 	    isa_irq, gsi, trigger = IOSAPIC_EDGE ? "edge" : "level",
 	    polarity = IOSAPIC_POL_HIGH ? "high" : "low",
 	    cpu_logical_id(dest), dest, vector);
 
-	set_rte(gsi, vector, dest, 1);
+	set_rte(gsi, gsv, dest, 1);
 }
 
 void __init
 iosapic_system_init (int system_pcat_compat)
 {
-	int vector;
+	unsigned int gsv;
 
-	for (vector = 0; vector < IA64_NUM_VECTORS; ++vector) {
-		iosapic_intr_info[vector].low32 = IOSAPIC_MASK;
-		INIT_LIST_HEAD(&iosapic_intr_info[vector].rtes);	/* mark as unused */
+	for (gsv = 0; gsv < NR_GSVS; ++gsv) {
+		iosapic_intr_info[gsv].low32 = IOSAPIC_MASK;
+		INIT_LIST_HEAD(&iosapic_intr_info[gsv].rtes);	/* mark as unused */
 	}
 
 	pcat_compat = system_pcat_compat;

_


