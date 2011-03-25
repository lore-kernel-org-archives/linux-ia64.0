From: Thomas Gleixner <tglx@linutronix.de>
Date: Fri, 25 Mar 2011 20:51:52 +0000
Subject: [patch 07/23] ia64: Convert msi_sn to new irq_chip functions
Message-Id: <20110325204515.163943967@linutronix.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
---
 arch/ia64/sn/kernel/msi_sn.c |   28 ++++++++++++++--------------
 1 file changed, 14 insertions(+), 14 deletions(-)

Index: linux-2.6-tip/arch/ia64/sn/kernel/msi_sn.c
=================================--- linux-2.6-tip.orig/arch/ia64/sn/kernel/msi_sn.c
+++ linux-2.6-tip/arch/ia64/sn/kernel/msi_sn.c
@@ -152,8 +152,8 @@ int sn_setup_msi_irq(struct pci_dev *pde
 }
 
 #ifdef CONFIG_SMP
-static int sn_set_msi_irq_affinity(unsigned int irq,
-				    const struct cpumask *cpu_mask)
+static int sn_set_msi_irq_affinity(struct irq_data *data,
+				   const struct cpumask *cpu_mask, bool force)
 {
 	struct msi_msg msg;
 	int slice;
@@ -164,7 +164,7 @@ static int sn_set_msi_irq_affinity(unsig
 	struct sn_irq_info *sn_irq_info;
 	struct sn_irq_info *new_irq_info;
 	struct sn_pcibus_provider *provider;
-	unsigned int cpu;
+	unsigned int cpu, irq = data->irq;
 
 	cpu = cpumask_first(cpu_mask);
 	sn_irq_info = sn_msi_info[irq].sn_irq_info;
@@ -206,33 +206,33 @@ static int sn_set_msi_irq_affinity(unsig
 	msg.address_lo = (u32)(bus_addr & 0x00000000ffffffff);
 
 	write_msi_msg(irq, &msg);
-	cpumask_copy(irq_desc[irq].affinity, cpu_mask);
+	cpumask_copy(data->affinity, cpu_mask);
 
 	return 0;
 }
 #endif /* CONFIG_SMP */
 
-static void sn_ack_msi_irq(unsigned int irq)
+static void sn_ack_msi_irq(struct irq_data *data)
 {
-	move_native_irq(irq);
+	move_native_irq(data->irq);
 	ia64_eoi();
 }
 
-static int sn_msi_retrigger_irq(unsigned int irq)
+static int sn_msi_retrigger_irq(struct irq_data *data)
 {
-	unsigned int vector = irq;
+	unsigned int vector = data->irq;
 	ia64_resend_irq(vector);
 
 	return 1;
 }
 
 static struct irq_chip sn_msi_chip = {
-	.name		= "PCI-MSI",
-	.irq_mask	= mask_msi_irq,
-	.irq_unmask	= unmask_msi_irq,
-	.ack		= sn_ack_msi_irq,
+	.name			= "PCI-MSI",
+	.irq_mask		= mask_msi_irq,
+	.irq_unmask		= unmask_msi_irq,
+	.irq_ack		= sn_ack_msi_irq,
 #ifdef CONFIG_SMP
-	.set_affinity	= sn_set_msi_irq_affinity,
+	.irq_set_affinity	= sn_set_msi_irq_affinity,
 #endif
-	.retrigger	= sn_msi_retrigger_irq,
+	.irq_retrigger		= sn_msi_retrigger_irq,
 };


