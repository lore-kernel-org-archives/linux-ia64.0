From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date: Thu, 22 Nov 2007 05:09:50 +0000
Subject: [PATCH] IA64: Fix irq migration in multiple vector domain
Message-Id: <47450F1E.2060105@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Fix the problem that the following error message is sometimes displayed
at irq migration when vector domain is enabled.

    "Unexpected interrupt vector %d on CPU %d is not mapped to any IRQ!"

The cause of this problem is an interrupt is sent to the previous
target CPU after cleaning up vector to irq mapping table. To clean up
vector to irq map on the previous target CPU safty, change the irq
migration in multiple vector domain as follows. The original idea is
from x86 interrupt management code.

    - Delay vector to irq table cleanup until the interrupts are sent
      to new target CPUs. By this, it is ensured that target CPU is
      completely changed on the interrupt controller side.

    - Even after the interrupts are sent to new target CPUs, there can
      be pended interrupts remaining on the previous target CPU. So we
      need to delay clearning up vector to irq table until the pended
      interrupt is handled. For this, send IPI to the previous target
      CPU with lower priority vector and clean up vector to irq table
      in its handler.

This patch affects only to irq migration code with multiple vector
domain is enabled.

Signed-off-by: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>

---
 arch/ia64/kernel/iosapic.c  |    4 -
 arch/ia64/kernel/irq_ia64.c |  134 ++++++++++++++++++++++++++++++++++----------
 arch/ia64/kernel/msi_ia64.c |    3 
 include/asm-ia64/hw_irq.h   |   12 +++
 4 files changed, 120 insertions(+), 33 deletions(-)

Index: linux-2.6.24-rc3/arch/ia64/kernel/irq_ia64.c
=================================--- linux-2.6.24-rc3.orig/arch/ia64/kernel/irq_ia64.c
+++ linux-2.6.24-rc3/arch/ia64/kernel/irq_ia64.c
@@ -260,6 +260,8 @@ void __setup_vector_irq(int cpu)
 }
 
 #if defined(CONFIG_SMP) && (defined(CONFIG_IA64_GENERIC) || defined(CONFIG_IA64_DIG))
+#define IA64_IRQ_MOVE_VECTOR	IA64_DEF_FIRST_DEVICE_VECTOR
+
 static enum vector_domain_type {
 	VECTOR_DOMAIN_NONE,
 	VECTOR_DOMAIN_PERCPU
@@ -272,6 +274,101 @@ static cpumask_t vector_allocation_domai
 	return CPU_MASK_ALL;
 }
 
+static int __irq_prepare_move(int irq, int cpu)
+{
+	struct irq_cfg *cfg = &irq_cfg[irq];
+	int vector;
+	cpumask_t domain;
+
+	if (cfg->move_in_progress || cfg->move_cleanup_count)
+		return -EBUSY;
+	if (cfg->vector = IRQ_VECTOR_UNASSIGNED || !cpu_online(cpu))
+		return -EINVAL;
+	if (cpu_isset(cpu, cfg->domain))
+		return 0;
+	domain = vector_allocation_domain(cpu);
+	vector = find_unassigned_vector(domain);
+	if (vector < 0)
+		return -ENOSPC;
+	cfg->move_in_progress = 1;
+	cfg->old_domain = cfg->domain;
+	cfg->vector = IRQ_VECTOR_UNASSIGNED;
+	cfg->domain = CPU_MASK_NONE;
+	BUG_ON(__bind_irq_vector(irq, vector, domain));
+	return 0;
+}
+
+int irq_prepare_move(int irq, int cpu)
+{
+	unsigned long flags;
+	int ret;
+
+	spin_lock_irqsave(&vector_lock, flags);
+	ret = __irq_prepare_move(irq, cpu);
+	spin_unlock_irqrestore(&vector_lock, flags);
+	return ret;
+}
+
+void irq_complete_move(unsigned irq)
+{
+	struct irq_cfg *cfg = &irq_cfg[irq];
+	cpumask_t cleanup_mask;
+	int i;
+
+	if (likely(!cfg->move_in_progress))
+		return;
+
+	if (unlikely(cpu_isset(smp_processor_id(), cfg->old_domain)))
+		return;
+
+	cpus_and(cleanup_mask, cfg->old_domain, cpu_online_map);
+	cfg->move_cleanup_count = cpus_weight(cleanup_mask);
+	for_each_cpu_mask(i, cleanup_mask)
+		platform_send_ipi(i, IA64_IRQ_MOVE_VECTOR, IA64_IPI_DM_INT, 0);
+	cfg->move_in_progress = 0;
+}
+
+static irqreturn_t smp_irq_move_cleanup_interrupt(int irq, void *dev_id)
+{
+	int me = smp_processor_id();
+	ia64_vector vector;
+	unsigned long flags;
+
+	for (vector = IA64_FIRST_DEVICE_VECTOR;
+	     vector < IA64_LAST_DEVICE_VECTOR; vector++) {
+		int irq;
+		struct irq_desc *desc;
+		struct irq_cfg *cfg;
+		irq = __get_cpu_var(vector_irq)[vector];
+		if (irq < 0)
+			continue;
+
+		desc = irq_desc + irq;
+		cfg = irq_cfg + irq;
+		spin_lock(&desc->lock);
+		if (!cfg->move_cleanup_count)
+			goto unlock;
+
+		if (!cpu_isset(me, cfg->old_domain))
+			goto unlock;
+
+		spin_lock_irqsave(&vector_lock, flags);
+		__get_cpu_var(vector_irq)[vector] = -1;
+		cpu_clear(me, vector_table[vector]);
+		spin_unlock_irqrestore(&vector_lock, flags);
+		cfg->move_cleanup_count--;
+	unlock:
+		spin_unlock(&desc->lock);
+	}
+	return IRQ_HANDLED;
+}
+
+static struct irqaction irq_move_irqaction = {
+	.handler =	smp_irq_move_cleanup_interrupt,
+	.flags =	IRQF_DISABLED,
+	.name =		"irq_move"
+};
+
 static int __init parse_vector_domain(char *arg)
 {
 	if (!arg)
@@ -303,36 +400,6 @@ void destroy_and_reserve_irq(unsigned in
 	spin_unlock_irqrestore(&vector_lock, flags);
 }
 
-static int __reassign_irq_vector(int irq, int cpu)
-{
-	struct irq_cfg *cfg = &irq_cfg[irq];
-	int vector;
-	cpumask_t domain;
-
-	if (cfg->vector = IRQ_VECTOR_UNASSIGNED || !cpu_online(cpu))
-		return -EINVAL;
-	if (cpu_isset(cpu, cfg->domain))
-		return 0;
-	domain = vector_allocation_domain(cpu);
-	vector = find_unassigned_vector(domain);
-	if (vector < 0)
-		return -ENOSPC;
-	__clear_irq_vector(irq);
-	BUG_ON(__bind_irq_vector(irq, vector, domain));
-	return 0;
-}
-
-int reassign_irq_vector(int irq, int cpu)
-{
-	unsigned long flags;
-	int ret;
-
-	spin_lock_irqsave(&vector_lock, flags);
-	ret = __reassign_irq_vector(irq, cpu);
-	spin_unlock_irqrestore(&vector_lock, flags);
-	return ret;
-}
-
 /*
  * Dynamic irq allocate and deallocation for MSI
  */
@@ -578,6 +645,13 @@ init_IRQ (void)
 	register_percpu_irq(IA64_IPI_VECTOR, &ipi_irqaction);
 	register_percpu_irq(IA64_IPI_RESCHEDULE, &resched_irqaction);
 	register_percpu_irq(IA64_IPI_LOCAL_TLB_FLUSH, &tlb_irqaction);
+#if defined(CONFIG_IA64_GENERIC) || defined(CONFIG_IA64_DIG)
+	if (vector_domain_type != VECTOR_DOMAIN_NONE) {
+		BUG_ON(IA64_FIRST_DEVICE_VECTOR != IA64_IRQ_MOVE_VECTOR);
+		IA64_FIRST_DEVICE_VECTOR++;
+		register_percpu_irq(IA64_IRQ_MOVE_VECTOR, &irq_move_irqaction);
+	}
+#endif
 #endif
 #ifdef CONFIG_PERFMON
 	pfm_init_percpu();
Index: linux-2.6.24-rc3/include/asm-ia64/hw_irq.h
=================================--- linux-2.6.24-rc3.orig/include/asm-ia64/hw_irq.h
+++ linux-2.6.24-rc3/include/asm-ia64/hw_irq.h
@@ -93,6 +93,9 @@ extern __u8 isa_irq_to_vector_map[16];
 struct irq_cfg {
 	ia64_vector vector;
 	cpumask_t domain;
+	cpumask_t old_domain;
+	unsigned move_cleanup_count;
+	u8 move_in_progress : 1;
 };
 extern spinlock_t vector_lock;
 extern struct irq_cfg irq_cfg[NR_IRQS];
@@ -106,12 +109,19 @@ extern int assign_irq_vector (int irq);	
 extern void free_irq_vector (int vector);
 extern int reserve_irq_vector (int vector);
 extern void __setup_vector_irq(int cpu);
-extern int reassign_irq_vector(int irq, int cpu);
 extern void ia64_send_ipi (int cpu, int vector, int delivery_mode, int redirect);
 extern void register_percpu_irq (ia64_vector vec, struct irqaction *action);
 extern int check_irq_used (int irq);
 extern void destroy_and_reserve_irq (unsigned int irq);
 
+#if defined(CONFIG_SMP) && (defined(CONFIG_IA64_GENERIC) || defined(CONFIG_IA64_DIG))
+extern int irq_prepare_move(int irq, int cpu);
+extern void irq_complete_move(unsigned int irq);
+#else
+static inline int irq_prepare_move(int irq, int cpu) { return 0; }
+static inline void irq_complete_move(unsigned int irq) {}
+#endif
+
 static inline void ia64_resend_irq(unsigned int vector)
 {
 	platform_send_ipi(smp_processor_id(), vector, IA64_IPI_DM_INT, 0);
Index: linux-2.6.24-rc3/arch/ia64/kernel/iosapic.c
=================================--- linux-2.6.24-rc3.orig/arch/ia64/kernel/iosapic.c
+++ linux-2.6.24-rc3/arch/ia64/kernel/iosapic.c
@@ -358,7 +358,7 @@ iosapic_set_affinity (unsigned int irq, 
 	if (cpus_empty(mask))
 		return;
 
-	if (reassign_irq_vector(irq, first_cpu(mask)))
+	if (irq_prepare_move(irq, first_cpu(mask)))
 		return;
 
 	dest = cpu_physical_id(first_cpu(mask));
@@ -410,6 +410,7 @@ iosapic_end_level_irq (unsigned int irq)
 	struct iosapic_rte_info *rte;
 	int do_unmask_irq = 0;
 
+	irq_complete_move(irq);
 	if (unlikely(irq_desc[irq].status & IRQ_MOVE_PENDING)) {
 		do_unmask_irq = 1;
 		mask_irq(irq);
@@ -463,6 +464,7 @@ iosapic_ack_edge_irq (unsigned int irq)
 {
 	irq_desc_t *idesc = irq_desc + irq;
 
+	irq_complete_move(irq);
 	move_native_irq(irq);
 	/*
 	 * Once we have recorded IRQ_PENDING already, we can mask the
Index: linux-2.6.24-rc3/arch/ia64/kernel/msi_ia64.c
=================================--- linux-2.6.24-rc3.orig/arch/ia64/kernel/msi_ia64.c
+++ linux-2.6.24-rc3/arch/ia64/kernel/msi_ia64.c
@@ -57,7 +57,7 @@ static void ia64_set_msi_irq_affinity(un
 	if (!cpu_online(cpu))
 		return;
 
-	if (reassign_irq_vector(irq, cpu))
+	if (irq_prepare_move(irq, cpu))
 		return;
 
 	read_msi_msg(irq, &msg);
@@ -119,6 +119,7 @@ void ia64_teardown_msi_irq(unsigned int 
 
 static void ia64_ack_msi_irq(unsigned int irq)
 {
+	irq_complete_move(irq);
 	move_native_irq(irq);
 	ia64_eoi();
 }

