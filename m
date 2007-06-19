From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Date: Tue, 19 Jun 2007 08:18:33 +0000
Subject: [PATCH take2 13/13] Bind gsi to irq
Message-Id: <46779159.9080905@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

When pci drivers enabled/disabled devices dynamically, its irq number is
changed to the different one. Therefore, suspend/resume code may happen problem.

To fix this problem, I bound gsi to irq.

Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

---
 arch/ia64/kernel/iosapic.c  |   34 +++++++++++++++++----------
 arch/ia64/kernel/irq_ia64.c |   54 +++++++++++++++++++++++++++++++++++++-------
 include/asm-ia64/irq.h      |    2 +
 3 files changed, 69 insertions(+), 21 deletions(-)

Index: linux-2.6.22-rc5/arch/ia64/kernel/iosapic.c
=================================--- linux-2.6.22-rc5.orig/arch/ia64/kernel/iosapic.c	2007-06-19 15:33:47.000000000 +0900
+++ linux-2.6.22-rc5/arch/ia64/kernel/iosapic.c	2007-06-19 15:34:05.000000000 +0900
@@ -113,6 +113,8 @@

 static DEFINE_SPINLOCK(iosapic_lock);

+#define GSI_IRQ_UNASSIGNED	(-1)
+
 /*
  * These tables map IA-64 vectors to the IOSAPIC pin that generates this
  * vector.
@@ -139,6 +141,7 @@ struct iosapic_rte_info {
 static struct iosapic_intr_info {
 	struct list_head rtes;		/* RTEs using this vector (empty =>
 					 * not an IOSAPIC interrupt) */
+	unsigned int	gsi;
 	int		count;		/* # of RTEs that shares this vector */
 	u32		low32;		/* current value of low word of
 					 * Redirection table entry */
@@ -184,15 +187,12 @@ find_iosapic (unsigned int gsi)
 static inline int __gsi_to_irq(unsigned int gsi)
 {
 	int irq;
-	struct iosapic_intr_info *info;
-	struct iosapic_rte_info *rte;

-	for (irq = 0; irq < NR_IRQS; irq++) {
-		info = &iosapic_intr_info[irq];
-		list_for_each_entry(rte, &info->rtes, rte_list)
-			if (rte->iosapic->gsi_base + rte->rte_index = gsi)
-				return irq;
+	for(irq = 0; irq < NR_IRQS; irq++) {
+		if(iosapic_intr_info[irq].gsi = gsi)
+			return irq;
 	}
+
 	return -1;
 }

@@ -645,6 +645,7 @@ register_intr (unsigned int gsi, int irq
 		}
 	}

+	iosapic_intr_info[irq].gsi = gsi;
 	iosapic_intr_info[irq].polarity = polarity;
 	iosapic_intr_info[irq].dmode    = delivery;
 	iosapic_intr_info[irq].trigger  = trigger;
@@ -772,13 +773,18 @@ iosapic_register_intr (unsigned int gsi,
 	spin_lock_irqsave(&iosapic_lock, flags);
 	irq = __gsi_to_irq(gsi);
 	if (irq > 0) {
-		rte = find_rte(irq, gsi);
-		rte->refcnt++;
-		goto unlock_iosapic_lock;
-	}
+		if(list_empty(&iosapic_intr_info[irq].rtes)) {
+			assign_irq_vector(irq);
+			dynamic_irq_init(irq);
+		} else {
+			rte = find_rte(irq, gsi);
+			rte->refcnt++;
+			goto unlock_iosapic_lock;
+		}
+	} else
+		irq = create_irq();

 	/* If vector is running out, we try to find a sharable vector */
-	irq = create_irq();
 	if (irq < 0) {
 		irq = iosapic_find_sharable_irq(trigger, polarity);
   		if (irq < 0)
@@ -885,10 +891,11 @@ iosapic_unregister_intr (unsigned int gs
 		memset(&iosapic_intr_info[irq], 0,
 		       sizeof(struct iosapic_intr_info));
 		iosapic_intr_info[irq].low32 |= IOSAPIC_MASK;
+		iosapic_intr_info[irq].gsi = gsi;
 		INIT_LIST_HEAD(&iosapic_intr_info[irq].rtes);

 		/* Destroy IRQ */
-		destroy_irq(irq);
+		destroy_and_reserve_irq(irq);
 	}
  out:
 	spin_unlock_irqrestore(&iosapic_lock, flags);
@@ -980,6 +987,7 @@ iosapic_system_init (int system_pcat_com
 	int irq;

 	for (irq = 0; irq < NR_IRQS; ++irq) {
+		iosapic_intr_info[irq].gsi = GSI_IRQ_UNASSIGNED;
 		iosapic_intr_info[irq].low32 = IOSAPIC_MASK;
 		/* mark as unused */
 		INIT_LIST_HEAD(&iosapic_intr_info[irq].rtes);
Index: linux-2.6.22-rc5/arch/ia64/kernel/irq_ia64.c
=================================--- linux-2.6.22-rc5.orig/arch/ia64/kernel/irq_ia64.c	2007-06-19 15:33:52.000000000 +0900
+++ linux-2.6.22-rc5/arch/ia64/kernel/irq_ia64.c	2007-06-19 15:34:05.000000000 +0900
@@ -49,6 +49,10 @@
 #define IRQ_VECTOR_UNASSIGNED	(0)
 #define VECTOR_IRQ_UNASSIGNED	(-1)

+#define IRQ_UNUSED		(0)
+#define IRQ_USED		(1)
+#define IRQ_RSVD 		(2)
+
 /* These can be overridden in platform_irq_init */
 int ia64_first_device_vector = IA64_DEF_FIRST_DEVICE_VECTOR;
 int ia64_last_device_vector = IA64_DEF_LAST_DEVICE_VECTOR;
@@ -57,6 +61,8 @@ int ia64_last_device_vector = IA64_DEF_L
 void __iomem *ipi_base_addr = ((void __iomem *)
 			       (__IA64_UNCACHED_OFFSET | IA64_IPI_DEFAULT_BASE_ADDR));

+static cpumask_t vector_allocation_domain(int cpu);
+
 /*
  * Legacy IRQ to IA-64 vector translation table.
  */
@@ -84,12 +90,16 @@ static cpumask_t vector_table[IA64_MAX_D
 	[0 ... IA64_MAX_DEVICE_VECTORS - 1] = CPU_MASK_NONE
 };

+static int irq_status[NR_IRQS] = {
+	[0 ... NR_IRQS -1] = IRQ_UNUSED
+};
+
 static inline int find_unassigned_irq(void)
 {
 	int irq;

 	for (irq = IA64_FIRST_DEVICE_VECTOR; irq < NR_IRQS; irq++)
-		if (irq_cfg[irq].vector = IRQ_VECTOR_UNASSIGNED)
+		if (irq_status[irq] = IRQ_UNUSED)
 			return irq;
 	return -ENOSPC;
 }
@@ -125,6 +135,7 @@ static int __bind_irq_vector(int irq, in
 		return 0;
 	if (cfg->vector != IRQ_VECTOR_UNASSIGNED)
 		return -EBUSY;
+	irq_status[irq] = IRQ_USED;
 	for_each_cpu_mask(cpu, mask)
 		per_cpu(vector_irq, cpu)[vector] = irq;
 	cfg->vector = vector;
@@ -160,6 +171,7 @@ static void __clear_irq_vector(int irq)
 		per_cpu(vector_irq, cpu)[vector] = VECTOR_IRQ_UNASSIGNED;
 	irq_cfg[irq].vector = IRQ_VECTOR_UNASSIGNED;
 	irq_cfg[irq].domain = CPU_MASK_NONE;
+	irq_status[irq] = IRQ_UNUSED;
 	pos = vector - IA64_FIRST_DEVICE_VECTOR;
 	cpus_andnot(vector_table[pos], vector_table[pos], domain);
 }
@@ -177,17 +189,26 @@ int
 assign_irq_vector (int irq)
 {
 	unsigned long flags;
-	int vector;
-
+	int vector, cpu;
+	cpumask_t domain;
+	vector = -ENOSPC;
 	spin_lock_irqsave(&vector_lock, flags);
-	vector = find_unassigned_vector(CPU_MASK_ALL);
+	if (irq < 0) {
+		goto out;
+	}
+	for_each_online_cpu(cpu) {
+		domain = vector_allocation_domain(cpu);
+		vector = find_unassigned_vector(domain);
+		if (vector >= 0)
+			break;
+	}
 	if (vector < 0)
 		goto out;
-	BUG_ON(__bind_irq_vector(vector, vector, CPU_MASK_ALL));
-	spin_unlock_irqrestore(&vector_lock, flags);
+	BUG_ON(__bind_irq_vector(irq, vector, domain));
  out:
-	return vector;
-}
+	spin_unlock_irqrestore(&vector_lock, flags);
+ 	return vector;
+ }

 void
 free_irq_vector (int vector)
@@ -288,6 +309,23 @@ int reassign_irq_vector(int irq, int cpu
 	return ret;
 }

+static void reserve_irq(unsigned int irq)
+{
+	irq_status[irq] = IRQ_RSVD;
+}
+
+void destroy_and_reserve_irq(unsigned int irq)
+{
+	unsigned long flags;
+
+	dynamic_irq_cleanup(irq);
+
+	spin_lock_irqsave(&vector_lock, flags);
+	__clear_irq_vector(irq);
+	reserve_irq(irq);
+	spin_unlock_irqrestore(&vector_lock, flags);
+}
+
 /*
  * Dynamic irq allocate and deallocation for MSI
  */
Index: linux-2.6.22-rc5/include/asm-ia64/irq.h
=================================--- linux-2.6.22-rc5.orig/include/asm-ia64/irq.h	2007-06-19 15:33:44.000000000 +0900
+++ linux-2.6.22-rc5/include/asm-ia64/irq.h	2007-06-19 15:34:05.000000000 +0900
@@ -35,6 +35,8 @@ extern void disable_irq_nosync (unsigned
 extern void enable_irq (unsigned int);
 extern void set_irq_affinity_info (unsigned int irq, int dest, int redir);
 bool is_affinity_mask_valid(cpumask_t cpumask);
+extern void destroy_and_reserve_irq(unsigned int irq);
+extern int assign_irq_vector(int irq);

 #define is_affinity_mask_valid is_affinity_mask_valid


