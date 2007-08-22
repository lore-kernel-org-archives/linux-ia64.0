From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date: Wed, 22 Aug 2007 10:52:45 +0000
Subject: [PATCH 1/2] Fix unexpected interrupt vector handling
Message-Id: <1187779965.3798.72.camel@kane-linux>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Fix handlings for spurious interrupts not being mapped to any IRQs.

Currently, spurious interrupts not being mapped to any IRQs are
handled as IRQ 15 (= IA64_SPURIOUS_VECTOR). But it is not proper
because vector != irq. We need special handlings for such spurious
interrupts not being mapped to any IRQs.

Signed-off-by: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>

---
 arch/ia64/kernel/irq_ia64.c |   28 ++++++++++++++++++++++------
 1 files changed, 22 insertions(+), 6 deletions(-)

Index: linux-2.6.23-rc3/arch/ia64/kernel/irq_ia64.c
=================================--- linux-2.6.23-rc3.orig/arch/ia64/kernel/irq_ia64.c
+++ linux-2.6.23-rc3/arch/ia64/kernel/irq_ia64.c
@@ -82,7 +82,7 @@ struct irq_cfg irq_cfg[NR_IRQS] __read_m
 };
 
 DEFINE_PER_CPU(int[IA64_NUM_VECTORS], vector_irq) = {
-	[0 ... IA64_NUM_VECTORS - 1] = IA64_SPURIOUS_INT_VECTOR
+	[0 ... IA64_NUM_VECTORS - 1] = -1
 };
 
 static cpumask_t vector_table[IA64_NUM_VECTORS] = {
@@ -179,7 +179,7 @@ static void __clear_irq_vector(int irq)
 	domain = cfg->domain;
 	cpus_and(mask, cfg->domain, cpu_online_map);
 	for_each_cpu_mask(cpu, mask)
-		per_cpu(vector_irq, cpu)[vector] = IA64_SPURIOUS_INT_VECTOR;
+		per_cpu(vector_irq, cpu)[vector] = -1;
 	cfg->vector = IRQ_VECTOR_UNASSIGNED;
 	cfg->domain = CPU_MASK_NONE;
 	irq_status[irq] = IRQ_UNUSED;
@@ -249,7 +249,7 @@ void __setup_vector_irq(int cpu)
 
 	/* Clear vector_irq */
 	for (vector = 0; vector < IA64_NUM_VECTORS; ++vector)
-		per_cpu(vector_irq, cpu)[vector] = IA64_SPURIOUS_INT_VECTOR;
+		per_cpu(vector_irq, cpu)[vector] = -1;
 	/* Mark the inuse vectors */
 	for (irq = 0; irq < NR_IRQS; ++irq) {
 		if (!cpu_isset(cpu, irq_cfg[irq].domain))
@@ -432,10 +432,18 @@ ia64_handle_irq (ia64_vector vector, str
 		} else if (unlikely(IS_RESCHEDULE(vector)))
 			kstat_this_cpu.irqs[vector]++;
 		else {
+			int irq = local_vector_to_irq(vector);
+
 			ia64_setreg(_IA64_REG_CR_TPR, vector);
 			ia64_srlz_d();
 
-			generic_handle_irq(local_vector_to_irq(vector));
+			if (unlikely(irq < 0)) {
+				printk(KERN_ERR "%s: Unexpected interrupt "
+				       "vector %d on CPU %d not being mapped "
+				       "to any IRQ!!\n", __FUNCTION__, vector,
+				       smp_processor_id());
+			} else
+				generic_handle_irq(irq);
 
 			/*
 			 * Disable interrupts and send EOI:
@@ -483,6 +491,7 @@ void ia64_process_pending_intr(void)
 			kstat_this_cpu.irqs[vector]++;
 		else {
 			struct pt_regs *old_regs = set_irq_regs(NULL);
+			int irq = local_vector_to_irq(vector);
 
 			ia64_setreg(_IA64_REG_CR_TPR, vector);
 			ia64_srlz_d();
@@ -493,8 +502,15 @@ void ia64_process_pending_intr(void)
 			 * it will work. I hope it works!.
 			 * Probably could shared code.
 			 */
-			vectors_in_migration[local_vector_to_irq(vector)]=0;
-			generic_handle_irq(local_vector_to_irq(vector));
+			if (unlikely(irq < 0)) {
+				printk(KERN_ERR "%s: Unexpected interrupt "
+				       "vector %d on CPU %d not being mapped "
+				       "to any IRQ!!\n", __FUNCTION__, vector,
+				       smp_processor_id());
+			} else {
+				vectors_in_migration[irq]=0;
+				generic_handle_irq(irq);
+			}
 			set_irq_regs(old_regs);
 
 			/*


