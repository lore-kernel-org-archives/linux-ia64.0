From: Thomas Gleixner <tglx@linutronix.de>
Date: Fri, 25 Mar 2011 20:52:04 +0000
Subject: [patch 23/23] ia64: Convert to the new irq_* function names
Message-Id: <20110325204516.711107875@linutronix.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Scripted with coccinelle.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
---
 arch/ia64/hp/sim/hpsim_irq.c |    4 ++--
 arch/ia64/kernel/irq_ia64.c  |    4 ++--
 arch/ia64/kernel/msi_ia64.c  |    8 ++++----
 arch/ia64/sn/kernel/msi_sn.c |    4 ++--
 4 files changed, 10 insertions(+), 10 deletions(-)

Index: linux-2.6-tip/arch/ia64/hp/sim/hpsim_irq.c
=================================--- linux-2.6-tip.orig/arch/ia64/hp/sim/hpsim_irq.c
+++ linux-2.6-tip/arch/ia64/hp/sim/hpsim_irq.c
@@ -43,9 +43,9 @@ hpsim_irq_init (void)
 	int i;
 
 	for_each_active_irq(i) {
-		struct irq_chip *chip = get_irq_chip(i);
+		struct irq_chip *chip = irq_get_chip(i);
 
 		if (chip = &no_irq_chip)
-			set_irq_chip(i, &irq_type_hp_sim);
+			irq_set_chip(i, &irq_type_hp_sim);
 	}
 }
Index: linux-2.6-tip/arch/ia64/kernel/irq_ia64.c
=================================--- linux-2.6-tip.orig/arch/ia64/kernel/irq_ia64.c
+++ linux-2.6-tip/arch/ia64/kernel/irq_ia64.c
@@ -631,10 +631,10 @@ ia64_native_register_percpu_irq (ia64_ve
 	irq = vec;
 	BUG_ON(bind_irq_vector(irq, vec, CPU_MASK_ALL));
 	irq_set_status_flags(irq, IRQ_PER_CPU);
-	set_irq_chip(irq, &irq_type_ia64_lsapic);
+	irq_set_chip(irq, &irq_type_ia64_lsapic);
 	if (action)
 		setup_irq(irq, action);
-	set_irq_handler(irq, handle_percpu_irq);
+	irq_set_handler(irq, handle_percpu_irq);
 }
 
 void __init
Index: linux-2.6-tip/arch/ia64/kernel/msi_ia64.c
=================================--- linux-2.6-tip.orig/arch/ia64/kernel/msi_ia64.c
+++ linux-2.6-tip/arch/ia64/kernel/msi_ia64.c
@@ -56,7 +56,7 @@ int ia64_setup_msi_irq(struct pci_dev *p
 	if (irq < 0)
 		return irq;
 
-	set_irq_msi(irq, desc);
+	irq_set_msi_desc(irq, desc);
 	cpus_and(mask, irq_to_domain(irq), cpu_online_map);
 	dest_phys_id = cpu_physical_id(first_cpu(mask));
 	vector = irq_to_vector(irq);
@@ -75,7 +75,7 @@ int ia64_setup_msi_irq(struct pci_dev *p
 		MSI_DATA_VECTOR(vector);
 
 	write_msi_msg(irq, &msg);
-	set_irq_chip_and_handler(irq, &ia64_msi_chip, handle_edge_irq);
+	irq_set_chip_and_handler(irq, &ia64_msi_chip, handle_edge_irq);
 
 	return 0;
 }
@@ -206,8 +206,8 @@ int arch_setup_dmar_msi(unsigned int irq
 	if (ret < 0)
 		return ret;
 	dmar_msi_write(irq, &msg);
-	set_irq_chip_and_handler_name(irq, &dmar_msi_type, handle_edge_irq,
-		"edge");
+	irq_set_chip_and_handler_name(irq, &dmar_msi_type, handle_edge_irq,
+				      "edge");
 	return 0;
 }
 #endif /* CONFIG_DMAR */
Index: linux-2.6-tip/arch/ia64/sn/kernel/msi_sn.c
=================================--- linux-2.6-tip.orig/arch/ia64/sn/kernel/msi_sn.c
+++ linux-2.6-tip/arch/ia64/sn/kernel/msi_sn.c
@@ -144,9 +144,9 @@ int sn_setup_msi_irq(struct pci_dev *pde
 	 */
 	msg.data = 0x100 + irq;
 
-	set_irq_msi(irq, entry);
+	irq_set_msi_desc(irq, entry);
 	write_msi_msg(irq, &msg);
-	set_irq_chip_and_handler(irq, &sn_msi_chip, handle_edge_irq);
+	irq_set_chip_and_handler(irq, &sn_msi_chip, handle_edge_irq);
 
 	return 0;
 }


