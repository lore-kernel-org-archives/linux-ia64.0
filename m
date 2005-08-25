From: Mark Maule <maule@sgi.com>
Date: Thu, 25 Aug 2005 18:45:11 +0000
Subject: [PATCH] altix: Abstract irq_affinity at the sn pci provider level
Message-Id: <20050825184511.13412.56139.33588@lnx-maule.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Altix patch to abstract irq_affinity down to the pci provider level since
different SGI hardware implements this in different ways.

Patch generated against:

rsync://rsync.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git#test

Signed-off-by: Mark Maule <maule@sgi.com>

Index: affinity/arch/ia64/sn/kernel/irq.c
=================================--- affinity.orig/arch/ia64/sn/kernel/irq.c	2005-08-23 16:06:35.755876779 -0500
+++ affinity/arch/ia64/sn/kernel/irq.c	2005-08-23 16:07:22.467036930 -0500
@@ -132,6 +132,7 @@
 		int local_widget, status;
 		nasid_t local_nasid;
 		struct sn_irq_info *new_irq_info;
+		struct sn_pcibus_provider *pci_provider;
 
 		new_irq_info = kmalloc(sizeof(struct sn_irq_info), GFP_ATOMIC);
 		if (new_irq_info = NULL)
@@ -171,8 +172,9 @@
 		new_irq_info->irq_cpuid = cpuid;
 		register_intr_pda(new_irq_info);
 
-		if (IS_PCI_BRIDGE_ASIC(new_irq_info->irq_bridge_type))
-			pcibr_change_devices_irq(new_irq_info);
+		pci_provider = sn_pci_provider[new_irq_info->irq_bridge_type];
+		if (pci_provider && pci_provider->target_interrupt)
+			(pci_provider->target_interrupt)(new_irq_info);
 
 		spin_lock(&sn_irq_info_lock);
 		list_replace_rcu(&sn_irq_info->list, &new_irq_info->list);
Index: affinity/arch/ia64/sn/pci/pcibr/pcibr_provider.c
=================================--- affinity.orig/arch/ia64/sn/pci/pcibr/pcibr_provider.c	2005-08-23 16:06:35.756853244 -0500
+++ affinity/arch/ia64/sn/pci/pcibr/pcibr_provider.c	2005-08-23 16:07:22.471919255 -0500
@@ -190,7 +190,7 @@
 	}
 }
 
-void pcibr_change_devices_irq(struct sn_irq_info *sn_irq_info)
+void pcibr_target_interrupt(struct sn_irq_info *sn_irq_info)
 {
 	struct pcidev_info *pcidev_info;
 	struct pcibus_info *pcibus_info;
@@ -225,7 +225,8 @@
 	.dma_map_consistent = pcibr_dma_map_consistent,
 	.dma_unmap = pcibr_dma_unmap,
 	.bus_fixup = pcibr_bus_fixup,
-	.force_interrupt = pcibr_force_interrupt
+	.force_interrupt = pcibr_force_interrupt,
+	.target_interrupt = pcibr_target_interrupt
 };
 
 int
Index: affinity/arch/ia64/sn/pci/tioca_provider.c
=================================--- affinity.orig/arch/ia64/sn/pci/tioca_provider.c	2005-08-23 16:06:35.756853244 -0500
+++ affinity/arch/ia64/sn/pci/tioca_provider.c	2005-08-23 16:07:22.473872185 -0500
@@ -657,7 +657,8 @@
 	.dma_map_consistent = tioca_dma_map,
 	.dma_unmap = tioca_dma_unmap,
 	.bus_fixup = tioca_bus_fixup,
-	.force_interrupt = NULL
+	.force_interrupt = NULL,
+	.target_interrupt = NULL
 };
 
 /**
Index: affinity/arch/ia64/sn/pci/tioce_provider.c
=================================--- affinity.orig/arch/ia64/sn/pci/tioce_provider.c	2005-08-23 16:06:35.757829709 -0500
+++ affinity/arch/ia64/sn/pci/tioce_provider.c	2005-08-23 16:11:39.363281088 -0500
@@ -669,6 +669,43 @@
 }
 
 /**
+ * tioce_target_interrupt - implement set_irq_affinity for tioce resident
+ * functions.  Note:  only applies to line interrupts, not MSI's.
+ *
+ * @sn_irq_info: SN IRQ context
+ *
+ * Given an sn_irq_info, set the associated CE device's interrupt destination
+ * register.  Since the interrupt destination registers are on a per-ce-slot
+ * basis, this will retarget line interrupts for all functions downstream of
+ * the slot.
+ */
+static void
+tioce_target_interrupt(struct sn_irq_info *sn_irq_info)
+{
+	struct pcidev_info *pcidev_info;
+	struct tioce_common *ce_common;
+	struct tioce *ce_mmr;
+	int bit;
+
+	pcidev_info = (struct pcidev_info *)sn_irq_info->irq_pciioinfo;
+	if (!pcidev_info)
+		return;
+
+	ce_common = (struct tioce_common *)pcidev_info->pdi_pcibus_info;
+	ce_mmr = (struct tioce *)ce_common->ce_pcibus.bs_base;
+
+	bit = sn_irq_info->irq_int_bit;
+
+	ce_mmr->ce_adm_int_mask |= (1UL << bit);
+	ce_mmr->ce_adm_int_dest[bit] +		((uint64_t)sn_irq_info->irq_irq << INTR_VECTOR_SHFT) |
+			   sn_irq_info->irq_xtalkaddr;
+	ce_mmr->ce_adm_int_mask &= ~(1UL << bit);
+
+	tioce_force_interrupt(sn_irq_info);
+}
+
+/**
  * tioce_bus_fixup - perform final PCI fixup for a TIO CE bus
  * @prom_bussoft: Common prom/kernel struct representing the bus
  *
@@ -719,7 +756,8 @@
 	.dma_map_consistent = tioce_dma_consistent,
 	.dma_unmap = tioce_dma_unmap,
 	.bus_fixup = tioce_bus_fixup,
-	.force_interrupt = tioce_force_interrupt
+	.force_interrupt = tioce_force_interrupt,
+	.target_interrupt = tioce_target_interrupt
 };
 
 /**
Index: affinity/include/asm-ia64/sn/pcibus_provider_defs.h
=================================--- affinity.orig/include/asm-ia64/sn/pcibus_provider_defs.h	2005-08-23 16:06:35.758806174 -0500
+++ affinity/include/asm-ia64/sn/pcibus_provider_defs.h	2005-08-23 16:07:22.481683906 -0500
@@ -50,6 +50,7 @@
 	void		(*dma_unmap)(struct pci_dev *, dma_addr_t, int);
 	void *		(*bus_fixup)(struct pcibus_bussoft *, struct pci_controller *);
  	void		(*force_interrupt)(struct sn_irq_info *);
+ 	void		(*target_interrupt)(struct sn_irq_info *);
 };
 
 extern struct sn_pcibus_provider *sn_pci_provider[];
