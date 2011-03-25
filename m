From: Thomas Gleixner <tglx@linutronix.de>
Date: Fri, 25 Mar 2011 20:51:58 +0000
Subject: [patch 15/23] ia64: Use accessor functions all over the place
Message-Id: <20110325204515.928705077@linutronix.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Use the proper accessor functions instead of open coded irq_desc access.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
---
 arch/ia64/kernel/irq.c      |    2 +-
 arch/ia64/kernel/irq_ia64.c |    6 ++----
 arch/ia64/kernel/mca.c      |    4 +---
 arch/ia64/sn/kernel/irq.c   |    6 ++----
 4 files changed, 6 insertions(+), 12 deletions(-)

Index: linux-2.6-tip/arch/ia64/kernel/irq.c
=================================--- linux-2.6-tip.orig/arch/ia64/kernel/irq.c
+++ linux-2.6-tip/arch/ia64/kernel/irq.c
@@ -103,7 +103,7 @@ static char irq_redir [NR_IRQS]; // = { 
 void set_irq_affinity_info (unsigned int irq, int hwid, int redir)
 {
 	if (irq < NR_IRQS) {
-		cpumask_copy(irq_desc[irq].affinity,
+		cpumask_copy(irq_get_irq_data(irq)->affinity,
 			     cpumask_of(cpu_logical_id(hwid)));
 		irq_redir[irq] = (char) (redir & 0xff);
 	}
Index: linux-2.6-tip/arch/ia64/kernel/irq_ia64.c
=================================--- linux-2.6-tip.orig/arch/ia64/kernel/irq_ia64.c
+++ linux-2.6-tip/arch/ia64/kernel/irq_ia64.c
@@ -343,7 +343,7 @@ static irqreturn_t smp_irq_move_cleanup_
 		if (irq < 0)
 			continue;
 
-		desc = irq_desc + irq;
+		desc = irq_to_desc(irq);
 		cfg = irq_cfg + irq;
 		raw_spin_lock(&desc->lock);
 		if (!cfg->move_cleanup_count)
@@ -626,13 +626,11 @@ static struct irqaction tlb_irqaction = 
 void
 ia64_native_register_percpu_irq (ia64_vector vec, struct irqaction *action)
 {
-	struct irq_desc *desc;
 	unsigned int irq;
 
 	irq = vec;
 	BUG_ON(bind_irq_vector(irq, vec, CPU_MASK_ALL));
-	desc = irq_desc + irq;
-	desc->status |= IRQ_PER_CPU;
+	irq_set_status_flags(irq, IRQ_PER_CPU);
 	set_irq_chip(irq, &irq_type_ia64_lsapic);
 	if (action)
 		setup_irq(irq, action);
Index: linux-2.6-tip/arch/ia64/kernel/mca.c
=================================--- linux-2.6-tip.orig/arch/ia64/kernel/mca.c
+++ linux-2.6-tip/arch/ia64/kernel/mca.c
@@ -2125,7 +2125,6 @@ ia64_mca_late_init(void)
 	cpe_poll_timer.function = ia64_mca_cpe_poll;
 
 	{
-		struct irq_desc *desc;
 		unsigned int irq;
 
 		if (cpe_vector >= 0) {
@@ -2133,8 +2132,7 @@ ia64_mca_late_init(void)
 			irq = local_vector_to_irq(cpe_vector);
 			if (irq > 0) {
 				cpe_poll_enabled = 0;
-				desc = irq_desc + irq;
-				desc->status |= IRQ_PER_CPU;
+				irq_set_status_flags(irq, IRQ_PER_CPU);
 				setup_irq(irq, &mca_cpe_irqaction);
 				ia64_cpe_irq = irq;
 				ia64_mca_register_cpev(cpe_vector);
Index: linux-2.6-tip/arch/ia64/sn/kernel/irq.c
=================================--- linux-2.6-tip.orig/arch/ia64/sn/kernel/irq.c
+++ linux-2.6-tip/arch/ia64/sn/kernel/irq.c
@@ -274,15 +274,13 @@ unsigned int sn_local_vector_to_irq(u8 v
 void sn_irq_init(void)
 {
 	int i;
-	struct irq_desc *base_desc = irq_desc;
 
 	ia64_first_device_vector = IA64_SN2_FIRST_DEVICE_VECTOR;
 	ia64_last_device_vector = IA64_SN2_LAST_DEVICE_VECTOR;
 
 	for (i = 0; i < NR_IRQS; i++) {
-		if (base_desc[i].chip = &no_irq_chip) {
-			base_desc[i].chip = &irq_type_sn;
-		}
+		if (irq_get_chip(i) = &no_irq_chip)
+			irq_set_chip(i, &irq_type_sn);
 	}
 }
 


