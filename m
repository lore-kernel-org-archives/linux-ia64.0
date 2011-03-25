From: Thomas Gleixner <tglx@linutronix.de>
Date: Fri, 25 Mar 2011 20:52:02 +0000
Subject: [patch 20/23] ia64: sn: Provide and use irqd_mark_affinity_set()
Message-Id: <20110325204516.407896549@linutronix.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

irq_desc->status is going to be restricted. Provide a helper to set
that information in irq_data, where it belongs.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
---
 arch/ia64/sn/kernel/irq.c |    4 +---
 include/linux/irq.h       |    5 +++++
 2 files changed, 6 insertions(+), 3 deletions(-)

Index: linux-2.6-tip/arch/ia64/sn/kernel/irq.c
=================================--- linux-2.6-tip.orig/arch/ia64/sn/kernel/irq.c
+++ linux-2.6-tip/arch/ia64/sn/kernel/irq.c
@@ -354,7 +354,6 @@ void sn_irq_fixup(struct pci_dev *pci_de
 	int cpu = nasid_slice_to_cpuid(nasid, slice);
 #ifdef CONFIG_SMP
 	int cpuphys;
-	struct irq_desc *desc;
 #endif
 
 	pci_dev_get(pci_dev);
@@ -371,12 +370,11 @@ void sn_irq_fixup(struct pci_dev *pci_de
 #ifdef CONFIG_SMP
 	cpuphys = cpu_physical_id(cpu);
 	set_irq_affinity_info(sn_irq_info->irq_irq, cpuphys, 0);
-	desc = irq_to_desc(sn_irq_info->irq_irq);
 	/*
 	 * Affinity was set by the PROM, prevent it from
 	 * being reset by the request_irq() path.
 	 */
-	desc->status |= IRQ_AFFINITY_SET;
+	irqd_mark_affinity_was_set(irq_get_irq_data(sn_irq_info->irq_irq));
 #endif
 }
 
Index: linux-2.6-tip/include/linux/irq.h
=================================--- linux-2.6-tip.orig/include/linux/irq.h
+++ linux-2.6-tip/include/linux/irq.h
@@ -206,6 +206,11 @@ static inline bool irqd_affinity_was_set
 	return d->state_use_accessors & IRQD_AFFINITY_SET;
 }
 
+static inline void irqd_mark_affinity_was_set(struct irq_data *d)
+{
+	d->state_use_accessors |= IRQD_AFFINITY_SET;
+}
+
 static inline u32 irqd_get_trigger_type(struct irq_data *d)
 {
 	return d->state_use_accessors & IRQD_TRIGGER_MASK;


