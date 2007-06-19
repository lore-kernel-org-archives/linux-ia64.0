From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Date: Tue, 19 Jun 2007 08:17:44 +0000
Subject: [PATCH take2 10/13] Support irq migration across domain
Message-Id: <46779128.8090503@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Add support for IRQ migration across vector domain.

Signed-off-by: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

---
 arch/ia64/kernel/iosapic.c  |   20 ++++++++++++++++---
 arch/ia64/kernel/irq_ia64.c |   46 ++++++++++++++++++++++++++++++++++++++++----
 arch/ia64/kernel/msi_ia64.c |   20 +++++++++++++------
 include/asm-ia64/hw_irq.h   |    1
 include/asm-ia64/iosapic.h  |    2 +
 5 files changed, 76 insertions(+), 13 deletions(-)

Index: linux-2.6.22-rc5/arch/ia64/kernel/iosapic.c
=================================--- linux-2.6.22-rc5.orig/arch/ia64/kernel/iosapic.c	2007-06-19 15:33:44.000000000 +0900
+++ linux-2.6.22-rc5/arch/ia64/kernel/iosapic.c	2007-06-19 15:33:47.000000000 +0900
@@ -351,11 +351,13 @@ iosapic_set_affinity (unsigned int irq,

 	irq &= (~IA64_IRQ_REDIRECTED);

-	/* IRQ migration across domain is not supported yet */
-	cpus_and(mask, mask, irq_to_domain(irq));
+	cpus_and(mask, mask, cpu_online_map);
 	if (cpus_empty(mask))
 		return;

+	if (reassign_irq_vector(irq, first_cpu(mask)))
+		return;
+
 	dest = cpu_physical_id(first_cpu(mask));

 	if (list_empty(&iosapic_intr_info[irq].rtes))
@@ -373,6 +375,8 @@ iosapic_set_affinity (unsigned int irq,
 	else
 		/* change delivery mode to fixed */
 		low32 |= (IOSAPIC_FIXED << IOSAPIC_DELIVERY_SHIFT);
+	low32 &= IOSAPIC_VECTOR_MASK;
+	low32 |= irq_to_vector(irq);

 	iosapic_intr_info[irq].low32 = low32;
 	iosapic_intr_info[irq].dest = dest;
@@ -401,10 +405,20 @@ iosapic_end_level_irq (unsigned int irq)
 {
 	ia64_vector vec = irq_to_vector(irq);
 	struct iosapic_rte_info *rte;
+	int do_unmask_irq = 0;
+
+	if (unlikely(irq_desc[irq].status & IRQ_MOVE_PENDING)) {
+		do_unmask_irq = 1;
+		mask_irq(irq);
+	}

-	move_native_irq(irq);
 	list_for_each_entry(rte, &iosapic_intr_info[irq].rtes, rte_list)
 		iosapic_eoi(rte->iosapic->addr, vec);
+
+	if (unlikely(do_unmask_irq)) {
+		move_masked_irq(irq);
+		unmask_irq(irq);
+	}
 }

 #define iosapic_shutdown_level_irq	mask_irq
Index: linux-2.6.22-rc5/arch/ia64/kernel/irq_ia64.c
=================================--- linux-2.6.22-rc5.orig/arch/ia64/kernel/irq_ia64.c	2007-06-19 15:33:44.000000000 +0900
+++ linux-2.6.22-rc5/arch/ia64/kernel/irq_ia64.c	2007-06-19 15:33:47.000000000 +0900
@@ -145,23 +145,31 @@ int bind_irq_vector(int irq, int vector,
 	return ret;
 }

-static void clear_irq_vector(int irq)
+static void __clear_irq_vector(int irq)
 {
-	unsigned long flags;
 	int vector, cpu, pos;
 	cpumask_t mask;
+	cpumask_t domain;

-	spin_lock_irqsave(&vector_lock, flags);
 	BUG_ON((unsigned)irq >= NR_IRQS);
 	BUG_ON(irq_cfg[irq].vector = IRQ_VECTOR_UNASSIGNED);
 	vector = irq_cfg[irq].vector;
+	domain = irq_cfg[irq].domain;
 	cpus_and(mask, irq_cfg[irq].domain, cpu_online_map);
 	for_each_cpu_mask(cpu, mask)
 		per_cpu(vector_irq, cpu)[vector] = VECTOR_IRQ_UNASSIGNED;
 	irq_cfg[irq].vector = IRQ_VECTOR_UNASSIGNED;
 	irq_cfg[irq].domain = CPU_MASK_NONE;
 	pos = vector - IA64_FIRST_DEVICE_VECTOR;
-	cpus_andnot(vector_table[pos], vector_table[pos], irq_cfg[irq].domain);
+	cpus_andnot(vector_table[pos], vector_table[pos], domain);
+}
+
+static void clear_irq_vector(int irq)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&vector_lock, flags);
+	__clear_irq_vector(irq);
 	spin_unlock_irqrestore(&vector_lock, flags);
 }

@@ -224,6 +232,36 @@ static cpumask_t vector_allocation_domai
 	return CPU_MASK_ALL;
 }

+static int __reassign_irq_vector(int irq, int cpu)
+{
+	struct irq_cfg *cfg = &irq_cfg[irq];
+	int vector;
+	cpumask_t domain;
+
+	if (cfg->vector = IRQ_VECTOR_UNASSIGNED || !cpu_online(cpu))
+		return -EINVAL;
+	if (cpu_isset(cpu, cfg->domain))
+		return 0;
+	domain = vector_allocation_domain(cpu);
+	vector = find_unassigned_vector(domain);
+	if (vector < 0)
+		return -ENOSPC;
+	__clear_irq_vector(irq);
+	BUG_ON(__bind_irq_vector(irq, vector, domain));
+	return 0;
+}
+
+int reassign_irq_vector(int irq, int cpu)
+{
+	unsigned long flags;
+	int ret;
+
+	spin_lock_irqsave(&vector_lock, flags);
+	ret = __reassign_irq_vector(irq, cpu);
+	spin_unlock_irqrestore(&vector_lock, flags);
+	return ret;
+}
+
 /*
  * Dynamic irq allocate and deallocation for MSI
  */
Index: linux-2.6.22-rc5/arch/ia64/kernel/msi_ia64.c
=================================--- linux-2.6.22-rc5.orig/arch/ia64/kernel/msi_ia64.c	2007-06-19 15:33:44.000000000 +0900
+++ linux-2.6.22-rc5/arch/ia64/kernel/msi_ia64.c	2007-06-19 15:33:47.000000000 +0900
@@ -13,6 +13,7 @@

 #define MSI_DATA_VECTOR_SHIFT		0
 #define	    MSI_DATA_VECTOR(v)		(((u8)v) << MSI_DATA_VECTOR_SHIFT)
+#define MSI_DATA_VECTOR_MASK		0xffffff00

 #define MSI_DATA_DELIVERY_SHIFT		8
 #define     MSI_DATA_DELIVERY_FIXED	(0 << MSI_DATA_DELIVERY_SHIFT)
@@ -50,22 +51,29 @@ static struct irq_chip	ia64_msi_chip;
 static void ia64_set_msi_irq_affinity(unsigned int irq, cpumask_t cpu_mask)
 {
 	struct msi_msg msg;
-	u32 addr;
+	u32 addr, data;
+	int cpu = first_cpu(cpu_mask);

-	/* IRQ migration across domain is not supported yet */
-	cpus_and(cpu_mask, cpu_mask, irq_to_domain(irq));
-	if (cpus_empty(cpu_mask))
+	if (!cpu_online(cpu))
+		return;
+
+	if (reassign_irq_vector(irq, cpu))
 		return;

 	read_msi_msg(irq, &msg);

 	addr = msg.address_lo;
 	addr &= MSI_ADDR_DESTID_MASK;
-	addr |= MSI_ADDR_DESTID_CPU(cpu_physical_id(first_cpu(cpu_mask)));
+	addr |= MSI_ADDR_DESTID_CPU(cpu_physical_id(cpu));
 	msg.address_lo = addr;

+	data = msg.data;
+	data &= MSI_DATA_VECTOR_MASK;
+	data |= MSI_DATA_VECTOR(irq_to_vector(irq));
+	msg.data = data;
+
 	write_msi_msg(irq, &msg);
-	irq_desc[irq].affinity = cpu_mask;
+	irq_desc[irq].affinity = cpumask_of_cpu(cpu);
 }
 #endif /* CONFIG_SMP */

Index: linux-2.6.22-rc5/include/asm-ia64/iosapic.h
=================================--- linux-2.6.22-rc5.orig/include/asm-ia64/iosapic.h	2007-06-19 15:33:23.000000000 +0900
+++ linux-2.6.22-rc5/include/asm-ia64/iosapic.h	2007-06-19 15:33:47.000000000 +0900
@@ -47,6 +47,8 @@
 #define	IOSAPIC_MASK_SHIFT		16
 #define	IOSAPIC_MASK			(1<<IOSAPIC_MASK_SHIFT)

+#define IOSAPIC_VECTOR_MASK		0xffffff00
+
 #ifndef __ASSEMBLY__

 #ifdef CONFIG_IOSAPIC
Index: linux-2.6.22-rc5/include/asm-ia64/hw_irq.h
=================================--- linux-2.6.22-rc5.orig/include/asm-ia64/hw_irq.h	2007-06-19 15:33:44.000000000 +0900
+++ linux-2.6.22-rc5/include/asm-ia64/hw_irq.h	2007-06-19 15:33:47.000000000 +0900
@@ -106,6 +106,7 @@ extern int assign_irq_vector (int irq);	
 extern void free_irq_vector (int vector);
 extern int reserve_irq_vector (int vector);
 extern void __setup_vector_irq(int cpu);
+extern int reassign_irq_vector(int irq, int cpu);
 extern void ia64_send_ipi (int cpu, int vector, int delivery_mode, int redirect);
 extern void register_percpu_irq (ia64_vector vec, struct irqaction *action);


