From: Thomas Gleixner <tglx@linutronix.de>
Date: Fri, 25 Mar 2011 20:52:03 +0000
Subject: [patch 21/23] ia64: Provide and use a __irq_is_enabled() helper
Message-Id: <20110325204516.506729641@linutronix.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Remove the last open coded access to irq_desc.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
---
 arch/ia64/kernel/irq.c    |    2 +-
 arch/ia64/sn/kernel/irq.c |    2 +-
 include/linux/irqdesc.h   |    7 +++++++
 3 files changed, 9 insertions(+), 2 deletions(-)

Index: linux-2.6-tip/arch/ia64/kernel/irq.c
=================================--- linux-2.6-tip.orig/arch/ia64/kernel/irq.c
+++ linux-2.6-tip/arch/ia64/kernel/irq.c
@@ -137,7 +137,7 @@ static void migrate_irqs(void)
 		struct irq_data *data = irq_desc_get_irq_data(desc);
 		struct irq_chip *chip = irq_data_get_irq_chip(data);
 
-		if (desc->status = IRQ_DISABLED)
+		if (!__irq_is_enabled(irq))
 			continue;
 
 		/*
Index: linux-2.6-tip/arch/ia64/sn/kernel/irq.c
=================================--- linux-2.6-tip.orig/arch/ia64/sn/kernel/irq.c
+++ linux-2.6-tip/arch/ia64/sn/kernel/irq.c
@@ -412,7 +412,7 @@ sn_call_force_intr_provider(struct sn_ir
 	pci_provider = sn_pci_provider[sn_irq_info->irq_bridge_type];
 
 	/* Don't force an interrupt if the irq has been disabled */
-	if (!(irq_desc[sn_irq_info->irq_irq].status & IRQ_DISABLED) &&
+	if (__irq_is_enabled(sn_irq_info->irq_irq) &&
 	    pci_provider && pci_provider->force_interrupt)
 		(*pci_provider->force_interrupt)(sn_irq_info);
 }
Index: linux-2.6-tip/include/linux/irqdesc.h
=================================--- linux-2.6-tip.orig/include/linux/irqdesc.h
+++ linux-2.6-tip/include/linux/irqdesc.h
@@ -231,4 +231,11 @@ __irq_set_preflow_handler(unsigned int i
 #endif
 #endif
 
+static inline bool __irq_is_enabled(unsigned int irq)
+{
+	struct irq_desc *desc = irq_to_desc(irq);
+
+	return desc && !desc->depth;
+}
+
 #endif


