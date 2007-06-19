From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Date: Tue, 19 Jun 2007 08:17:30 +0000
Subject: [PATCH take2 9/13]  Add support for vector domain
Message-Id: <4677911A.9040106@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Add fundamental support for multiple vector domain. There still exists
only one vector domain even with this patch. IRQ migration across
domain is not supported yet by this patch.

Signed-off-by: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

---
 arch/ia64/kernel/iosapic.c  |   13 +++---
 arch/ia64/kernel/irq_ia64.c |   94 +++++++++++++++++++++++++++++++-------------
 arch/ia64/kernel/msi_ia64.c |    9 +++-
 include/asm-ia64/hw_irq.h   |    4 +
 include/asm-ia64/irq.h      |    4 +
 5 files changed, 89 insertions(+), 35 deletions(-)

Index: linux-2.6.22-rc5/arch/ia64/kernel/irq_ia64.c
=================================--- linux-2.6.22-rc5.orig/arch/ia64/kernel/irq_ia64.c	2007-06-19 15:33:41.000000000 +0900
+++ linux-2.6.22-rc5/arch/ia64/kernel/irq_ia64.c	2007-06-19 15:33:44.000000000 +0900
@@ -70,13 +70,20 @@ EXPORT_SYMBOL(isa_irq_to_vector_map);
 DEFINE_SPINLOCK(vector_lock);

 struct irq_cfg irq_cfg[NR_IRQS] __read_mostly = {
-	[0 ... NR_IRQS - 1] = { .vector = IRQ_VECTOR_UNASSIGNED }
+	[0 ... NR_IRQS - 1] = {
+		.vector = IRQ_VECTOR_UNASSIGNED,
+		.domain = CPU_MASK_NONE
+	}
 };

 DEFINE_PER_CPU(int[IA64_NUM_VECTORS], vector_irq) = {
 	[0 ... IA64_NUM_VECTORS - 1] = VECTOR_IRQ_UNASSIGNED
 };

+static cpumask_t vector_table[IA64_MAX_DEVICE_VECTORS] = {
+	[0 ... IA64_MAX_DEVICE_VECTORS - 1] = CPU_MASK_NONE
+};
+
 static inline int find_unassigned_irq(void)
 {
 	int irq;
@@ -87,38 +94,53 @@ static inline int find_unassigned_irq(vo
 	return -ENOSPC;
 }

-static inline int find_unassigned_vector(void)
+static inline int find_unassigned_vector(cpumask_t domain)
 {
-	int vector;
+	cpumask_t mask;
+	int pos;

-	for (vector = IA64_FIRST_DEVICE_VECTOR;
-	     vector <= IA64_LAST_DEVICE_VECTOR; vector++)
-		if (__get_cpu_var(vector_irq[vector]) = VECTOR_IRQ_UNASSIGNED)
-			return vector;
+	cpus_and(mask, domain, cpu_online_map);
+	if (cpus_empty(mask))
+		return -EINVAL;
+
+	for (pos = 0; pos < IA64_NUM_DEVICE_VECTORS; pos++) {
+		cpus_and(mask, domain, vector_table[pos]);
+		if (!cpus_empty(mask))
+			continue;
+		return IA64_FIRST_DEVICE_VECTOR + pos;
+	}
 	return -ENOSPC;
 }

-static int __bind_irq_vector(int irq, int vector)
+static int __bind_irq_vector(int irq, int vector, cpumask_t domain)
 {
-	int cpu;
+	cpumask_t mask;
+	int cpu, pos;
+	struct irq_cfg *cfg = &irq_cfg[irq];

-	if (irq_to_vector(irq) = vector)
+	cpus_and(mask, domain, cpu_online_map);
+	if (cpus_empty(mask))
+		return -EINVAL;
+	if ((cfg->vector = vector) && cpus_equal(cfg->domain, domain))
 		return 0;
-	if (irq_to_vector(irq) != IRQ_VECTOR_UNASSIGNED)
+	if (cfg->vector != IRQ_VECTOR_UNASSIGNED)
 		return -EBUSY;
-	for_each_online_cpu(cpu)
+	for_each_cpu_mask(cpu, mask)
 		per_cpu(vector_irq, cpu)[vector] = irq;
-	irq_cfg[irq].vector = vector;
+	cfg->vector = vector;
+	cfg->domain = domain;
+	pos = vector - IA64_FIRST_DEVICE_VECTOR;
+	cpus_or(vector_table[pos], vector_table[pos], domain);
 	return 0;
 }

-int bind_irq_vector(int irq, int vector)
+int bind_irq_vector(int irq, int vector, cpumask_t domain)
 {
 	unsigned long flags;
 	int ret;

 	spin_lock_irqsave(&vector_lock, flags);
-	ret = __bind_irq_vector(irq, vector);
+	ret = __bind_irq_vector(irq, vector, domain);
 	spin_unlock_irqrestore(&vector_lock, flags);
 	return ret;
 }
@@ -126,15 +148,20 @@ int bind_irq_vector(int irq, int vector)
 static void clear_irq_vector(int irq)
 {
 	unsigned long flags;
-	int vector, cpu;
+	int vector, cpu, pos;
+	cpumask_t mask;

 	spin_lock_irqsave(&vector_lock, flags);
 	BUG_ON((unsigned)irq >= NR_IRQS);
 	BUG_ON(irq_cfg[irq].vector = IRQ_VECTOR_UNASSIGNED);
 	vector = irq_cfg[irq].vector;
-	for_each_online_cpu(cpu)
+	cpus_and(mask, irq_cfg[irq].domain, cpu_online_map);
+	for_each_cpu_mask(cpu, mask)
 		per_cpu(vector_irq, cpu)[vector] = VECTOR_IRQ_UNASSIGNED;
 	irq_cfg[irq].vector = IRQ_VECTOR_UNASSIGNED;
+	irq_cfg[irq].domain = CPU_MASK_NONE;
+	pos = vector - IA64_FIRST_DEVICE_VECTOR;
+	cpus_andnot(vector_table[pos], vector_table[pos], irq_cfg[irq].domain);
 	spin_unlock_irqrestore(&vector_lock, flags);
 }

@@ -145,10 +172,10 @@ assign_irq_vector (int irq)
 	int vector;

 	spin_lock_irqsave(&vector_lock, flags);
-	vector = find_unassigned_vector();
+	vector = find_unassigned_vector(CPU_MASK_ALL);
 	if (vector < 0)
 		goto out;
-	BUG_ON(__bind_irq_vector(vector, vector));
+	BUG_ON(__bind_irq_vector(vector, vector, CPU_MASK_ALL));
 	spin_unlock_irqrestore(&vector_lock, flags);
  out:
 	return vector;
@@ -169,7 +196,7 @@ reserve_irq_vector (int vector)
 	if (vector < IA64_FIRST_DEVICE_VECTOR ||
 	    vector > IA64_LAST_DEVICE_VECTOR)
 		return -EINVAL;
-	return !!bind_irq_vector(vector, vector);
+	return !!bind_irq_vector(vector, vector, CPU_MASK_ALL);
 }

 /*
@@ -185,28 +212,41 @@ void __setup_vector_irq(int cpu)
 		per_cpu(vector_irq, cpu)[vector] = VECTOR_IRQ_UNASSIGNED;
 	/* Mark the inuse vectors */
 	for (irq = 0; irq < NR_IRQS; ++irq) {
-		if ((vector = irq_to_vector(irq)) != IRQ_VECTOR_UNASSIGNED)
-			per_cpu(vector_irq, cpu)[vector] = irq;
+		if (!cpu_isset(cpu, irq_cfg[irq].domain))
+			continue;
+		vector = irq_to_vector(irq);
+		per_cpu(vector_irq, cpu)[vector] = irq;
 	}
 }

+static cpumask_t vector_allocation_domain(int cpu)
+{
+	return CPU_MASK_ALL;
+}
+
 /*
  * Dynamic irq allocate and deallocation for MSI
  */
 int create_irq(void)
 {
 	unsigned long flags;
-	int irq, vector;
+	int irq, vector, cpu;
+	cpumask_t domain;

-	irq = -ENOSPC;
+	irq = vector = -ENOSPC;
 	spin_lock_irqsave(&vector_lock, flags);
-	vector = find_unassigned_vector();
+	for_each_online_cpu(cpu) {
+		domain = vector_allocation_domain(cpu);
+		vector = find_unassigned_vector(domain);
+		if (vector >= 0)
+			break;
+	}
 	if (vector < 0)
 		goto out;
 	irq = find_unassigned_irq();
 	if (irq < 0)
 		goto out;
-	BUG_ON(__bind_irq_vector(irq, vector));
+	BUG_ON(__bind_irq_vector(irq, vector, domain));
  out:
 	spin_unlock_irqrestore(&vector_lock, flags);
 	if (irq >= 0)
@@ -397,7 +437,7 @@ register_percpu_irq (ia64_vector vec, st
 	unsigned int irq;

 	irq = vec;
-	BUG_ON(bind_irq_vector(irq, vec));
+	BUG_ON(bind_irq_vector(irq, vec, CPU_MASK_ALL));
 	desc = irq_desc + irq;
 	desc->status |= IRQ_PER_CPU;
 	desc->chip = &irq_type_ia64_lsapic;
Index: linux-2.6.22-rc5/include/asm-ia64/hw_irq.h
=================================--- linux-2.6.22-rc5.orig/include/asm-ia64/hw_irq.h	2007-06-19 15:33:41.000000000 +0900
+++ linux-2.6.22-rc5/include/asm-ia64/hw_irq.h	2007-06-19 15:33:44.000000000 +0900
@@ -92,14 +92,16 @@ extern __u8 isa_irq_to_vector_map[16];

 struct irq_cfg {
 	ia64_vector vector;
+	cpumask_t domain;
 };
 extern spinlock_t vector_lock;
 extern struct irq_cfg irq_cfg[NR_IRQS];
+#define irq_to_domain(x)	irq_cfg[(x)].domain
 DECLARE_PER_CPU(int[IA64_NUM_VECTORS], vector_irq);

 extern struct hw_interrupt_type irq_type_ia64_lsapic;	/* CPU-internal interrupt controller */

-extern int bind_irq_vector(int irq, int vector);
+extern int bind_irq_vector(int irq, int vector, cpumask_t domain);
 extern int assign_irq_vector (int irq);	/* allocate a free vector */
 extern void free_irq_vector (int vector);
 extern int reserve_irq_vector (int vector);
Index: linux-2.6.22-rc5/arch/ia64/kernel/iosapic.c
=================================--- linux-2.6.22-rc5.orig/arch/ia64/kernel/iosapic.c	2007-06-19 15:33:41.000000000 +0900
+++ linux-2.6.22-rc5/arch/ia64/kernel/iosapic.c	2007-06-19 15:33:44.000000000 +0900
@@ -351,6 +351,8 @@ iosapic_set_affinity (unsigned int irq,

 	irq &= (~IA64_IRQ_REDIRECTED);

+	/* IRQ migration across domain is not supported yet */
+	cpus_and(mask, mask, irq_to_domain(irq));
 	if (cpus_empty(mask))
 		return;

@@ -656,6 +658,7 @@ get_target_cpu (unsigned int gsi, int ir
 #ifdef CONFIG_SMP
 	static int cpu = -1;
 	extern int cpe_vector;
+	cpumask_t domain = irq_to_domain(irq);

 	/*
 	 * In case of vector shared by multiple RTEs, all RTEs that
@@ -694,7 +697,7 @@ get_target_cpu (unsigned int gsi, int ir
 			goto skip_numa_setup;

 		cpu_mask = node_to_cpumask(iosapic_lists[iosapic_index].node);
-
+		cpus_and(cpu_mask, cpu_mask, domain);
 		for_each_cpu_mask(numa_cpu, cpu_mask) {
 			if (!cpu_online(numa_cpu))
 				cpu_clear(numa_cpu, cpu_mask);
@@ -724,7 +727,7 @@ skip_numa_setup:
 	do {
 		if (++cpu >= NR_CPUS)
 			cpu = 0;
-	} while (!cpu_online(cpu));
+	} while (!cpu_online(cpu) || !cpu_isset(cpu, domain));

 	return cpu_physical_id(cpu);
 #else  /* CONFIG_SMP */
@@ -893,7 +896,7 @@ iosapic_register_platform_intr (u32 int_
 	switch (int_type) {
 	      case ACPI_INTERRUPT_PMI:
 		irq = vector = iosapic_vector;
-		bind_irq_vector(irq, vector);
+		bind_irq_vector(irq, vector, CPU_MASK_ALL);
 		/*
 		 * since PMI vector is alloc'd by FW(ACPI) not by kernel,
 		 * we need to make sure the vector is available
@@ -910,7 +913,7 @@ iosapic_register_platform_intr (u32 int_
 		break;
 	      case ACPI_INTERRUPT_CPEI:
 		irq = vector = IA64_CPE_VECTOR;
-		BUG_ON(bind_irq_vector(irq, vector));
+		BUG_ON(bind_irq_vector(irq, vector, CPU_MASK_ALL));
 		delivery = IOSAPIC_LOWEST_PRIORITY;
 		mask = 1;
 		break;
@@ -946,7 +949,7 @@ iosapic_override_isa_irq (unsigned int i
 	unsigned int dest = cpu_physical_id(smp_processor_id());

 	irq = vector = isa_irq_to_vector(isa_irq);
-	BUG_ON(bind_irq_vector(irq, vector));
+	BUG_ON(bind_irq_vector(irq, vector, CPU_MASK_ALL));
 	register_intr(gsi, irq, IOSAPIC_LOWEST_PRIORITY, polarity, trigger);

 	DBG("ISA: IRQ %u -> GSI %u (%s,%s) -> CPU %d (0x%04x) vector %d\n",
Index: linux-2.6.22-rc5/arch/ia64/kernel/msi_ia64.c
=================================--- linux-2.6.22-rc5.orig/arch/ia64/kernel/msi_ia64.c	2007-06-19 15:32:06.000000000 +0900
+++ linux-2.6.22-rc5/arch/ia64/kernel/msi_ia64.c	2007-06-19 15:33:44.000000000 +0900
@@ -52,6 +52,11 @@ static void ia64_set_msi_irq_affinity(un
 	struct msi_msg msg;
 	u32 addr;

+	/* IRQ migration across domain is not supported yet */
+	cpus_and(cpu_mask, cpu_mask, irq_to_domain(irq));
+	if (cpus_empty(cpu_mask))
+		return;
+
 	read_msi_msg(irq, &msg);

 	addr = msg.address_lo;
@@ -69,13 +74,15 @@ int ia64_setup_msi_irq(struct pci_dev *p
 	struct msi_msg	msg;
 	unsigned long	dest_phys_id;
 	int	irq, vector;
+	cpumask_t mask;

 	irq = create_irq();
 	if (irq < 0)
 		return irq;

 	set_irq_msi(irq, desc);
-	dest_phys_id = cpu_physical_id(first_cpu(cpu_online_map));
+	cpus_and(mask, irq_to_domain(irq), cpu_online_map);
+	dest_phys_id = cpu_physical_id(first_cpu(mask));
 	vector = irq_to_vector(irq);

 	msg.address_hi = 0;
Index: linux-2.6.22-rc5/include/asm-ia64/irq.h
=================================--- linux-2.6.22-rc5.orig/include/asm-ia64/irq.h	2007-06-19 15:32:06.000000000 +0900
+++ linux-2.6.22-rc5/include/asm-ia64/irq.h	2007-06-19 15:33:44.000000000 +0900
@@ -14,7 +14,9 @@
 #include <linux/types.h>
 #include <linux/cpumask.h>

-#define NR_IRQS		256
+#define NR_VECTORS	256
+
+#define NR_IRQS		(NR_VECTORS + (32 * NR_CPUS))
 #define NR_IRQ_VECTORS	NR_IRQS

 static __inline__ int

