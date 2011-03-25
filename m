From: Thomas Gleixner <tglx@linutronix.de>
Date: Fri, 25 Mar 2011 20:51:54 +0000
Subject: [patch 09/23] ia64: Convert msi to new irq_chip functions
Message-Id: <20110325204515.354697447@linutronix.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
---
 arch/ia64/kernel/msi_ia64.c |   41 ++++++++++++++++++++++-------------------
 1 file changed, 22 insertions(+), 19 deletions(-)

Index: linux-2.6-tip/arch/ia64/kernel/msi_ia64.c
=================================--- linux-2.6-tip.orig/arch/ia64/kernel/msi_ia64.c
+++ linux-2.6-tip/arch/ia64/kernel/msi_ia64.c
@@ -12,12 +12,13 @@
 static struct irq_chip	ia64_msi_chip;
 
 #ifdef CONFIG_SMP
-static int ia64_set_msi_irq_affinity(unsigned int irq,
-				      const cpumask_t *cpu_mask)
+static int ia64_set_msi_irq_affinity(struct irq_data *idata,
+				     const cpumask_t *cpu_mask, bool force)
 {
 	struct msi_msg msg;
 	u32 addr, data;
 	int cpu = first_cpu(*cpu_mask);
+	unsigned int irq = idata->irq;
 
 	if (!cpu_online(cpu))
 		return -1;
@@ -38,7 +39,7 @@ static int ia64_set_msi_irq_affinity(uns
 	msg.data = data;
 
 	write_msi_msg(irq, &msg);
-	cpumask_copy(irq_desc[irq].affinity, cpumask_of(cpu));
+	cpumask_copy(idata->affinity, cpumask_of(cpu));
 
 	return 0;
 }
@@ -84,16 +85,16 @@ void ia64_teardown_msi_irq(unsigned int 
 	destroy_irq(irq);
 }
 
-static void ia64_ack_msi_irq(unsigned int irq)
+static void ia64_ack_msi_irq(struct irq_data *data)
 {
-	irq_complete_move(irq);
-	move_native_irq(irq);
+	irq_complete_move(data->irq);
+	move_native_irq(data->irq);
 	ia64_eoi();
 }
 
-static int ia64_msi_retrigger_irq(unsigned int irq)
+static int ia64_msi_retrigger_irq(struct irq_data *data)
 {
-	unsigned int vector = irq_to_vector(irq);
+	unsigned int vector = irq_to_vector(data->irq);
 	ia64_resend_irq(vector);
 
 	return 1;
@@ -103,14 +104,14 @@ static int ia64_msi_retrigger_irq(unsign
  * Generic ops used on most IA64 platforms.
  */
 static struct irq_chip ia64_msi_chip = {
-	.name		= "PCI-MSI",
-	.irq_mask	= mask_msi_irq,
-	.irq_unmask	= unmask_msi_irq,
-	.ack		= ia64_ack_msi_irq,
+	.name			= "PCI-MSI",
+	.irq_mask		= mask_msi_irq,
+	.irq_unmask		= unmask_msi_irq,
+	.irq_ack		= ia64_ack_msi_irq,
 #ifdef CONFIG_SMP
-	.set_affinity	= ia64_set_msi_irq_affinity,
+	.irq_set_affinity	= ia64_set_msi_irq_affinity,
 #endif
-	.retrigger	= ia64_msi_retrigger_irq,
+	.irq_retrigger		= ia64_msi_retrigger_irq,
 };
 
 
@@ -132,8 +133,10 @@ void arch_teardown_msi_irq(unsigned int 
 
 #ifdef CONFIG_DMAR
 #ifdef CONFIG_SMP
-static int dmar_msi_set_affinity(unsigned int irq, const struct cpumask *mask)
+static int dmar_msi_set_affinity(struct irq_data *data,
+				 const struct cpumask *mask, bool force)
 {
+	unsigned int irq = data->irq;
 	struct irq_cfg *cfg = irq_cfg + irq;
 	struct msi_msg msg;
 	int cpu = cpumask_first(mask);
@@ -152,7 +155,7 @@ static int dmar_msi_set_affinity(unsigne
 	msg.address_lo |= MSI_ADDR_DEST_ID_CPU(cpu_physical_id(cpu));
 
 	dmar_msi_write(irq, &msg);
-	cpumask_copy(irq_desc[irq].affinity, mask);
+	cpumask_copy(data->affinity, mask);
 
 	return 0;
 }
@@ -162,11 +165,11 @@ static struct irq_chip dmar_msi_type = {
 	.name = "DMAR_MSI",
 	.irq_unmask = dmar_msi_unmask,
 	.irq_mask = dmar_msi_mask,
-	.ack = ia64_ack_msi_irq,
+	.irq_ack = ia64_ack_msi_irq,
 #ifdef CONFIG_SMP
-	.set_affinity = dmar_msi_set_affinity,
+	.irq_set_affinity = dmar_msi_set_affinity,
 #endif
-	.retrigger = ia64_msi_retrigger_irq,
+	.irq_retrigger = ia64_msi_retrigger_irq,
 };
 
 static int


