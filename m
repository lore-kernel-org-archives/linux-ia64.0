From: Mark Maule <maule@sgi.com>
Date: Wed, 03 Aug 2005 21:06:02 +0000
Subject: [PATCH 2.6.13 2/4] altix: abstract force_interrupt() mechanism
Message-Id: <20050803210602.785.48692.56968@attica.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Altix patch to abstract the force_interrupt() mechanism away from the
pcibr provider.

Signed-off-by: Mark Maule <maule@sgi.com>

Index: ce-devel/arch/ia64/sn/kernel/irq.c
=================================--- ce-devel.orig/arch/ia64/sn/kernel/irq.c	2005-08-02 15:36:46.190240937 -0500
+++ ce-devel/arch/ia64/sn/kernel/irq.c	2005-08-02 15:39:52.990001754 -0500
@@ -317,6 +317,16 @@
 	pci_dev_put(pci_dev);
 }
 
+static inline void
+sn_call_force_intr_provider(struct sn_irq_info *sn_irq_info)
+{
+	struct sn_pcibus_provider *pci_provider;
+
+	pci_provider = sn_pci_provider[sn_irq_info->irq_bridge_type];
+	if (pci_provider && pci_provider->force_interrupt)
+		(*pci_provider->force_interrupt)(sn_irq_info);
+}
+
 static void force_interrupt(int irq)
 {
 	struct sn_irq_info *sn_irq_info;
@@ -325,11 +335,9 @@
 		return;
 
 	rcu_read_lock();
-	list_for_each_entry_rcu(sn_irq_info, sn_irq_lh[irq], list) {
-		if (IS_PCI_BRIDGE_ASIC(sn_irq_info->irq_bridge_type) &&
-		    (sn_irq_info->irq_bridge != NULL))
-			pcibr_force_interrupt(sn_irq_info);
-	}
+	list_for_each_entry_rcu(sn_irq_info, sn_irq_lh[irq], list)
+		sn_call_force_intr_provider(sn_irq_info);
+
 	rcu_read_unlock();
 }
 
@@ -351,6 +359,14 @@
 	struct pcidev_info *pcidev_info;
 	struct pcibus_info *pcibus_info;
 
+	/*
+	 * Bridge types attached to TIO (anything but PIC) do not need this WAR
+	 * since they do not target Shub II interrupt registers.  If that
+	 * ever changes, this check needs to accomodate.
+	 */
+	if (sn_irq_info->irq_bridge_type != PCIIO_ASIC_TYPE_PIC)
+		return;
+
 	pcidev_info = (struct pcidev_info *)sn_irq_info->irq_pciioinfo;
 	if (!pcidev_info)
 		return;
@@ -377,16 +393,12 @@
 		break;
 	}
 	if (!test_bit(irr_bit, &irr_reg)) {
-		if (!test_bit(irq, pda->sn_soft_irr)) {
-			if (!test_bit(irq, pda->sn_in_service_ivecs)) {
-				regval &= 0xff;
-				if (sn_irq_info->irq_int_bit & regval &
-				    sn_irq_info->irq_last_intr) {
-					regval &-					    ~(sn_irq_info->
-					      irq_int_bit & regval);
-					pcibr_force_interrupt(sn_irq_info);
-				}
+		if (!test_bit(irq, pda->sn_in_service_ivecs)) {
+			regval &= 0xff;
+			if (sn_irq_info->irq_int_bit & regval &
+			    sn_irq_info->irq_last_intr) {
+				regval &= ~(sn_irq_info->irq_int_bit & regval);
+				sn_call_force_intr_provider(sn_irq_info);
 			}
 		}
 	}
@@ -404,13 +416,7 @@
 	rcu_read_lock();
 	for (i = pda->sn_first_irq; i <= pda->sn_last_irq; i++) {
 		list_for_each_entry_rcu(sn_irq_info, sn_irq_lh[i], list) {
-			/*
-			 * Only call for PCI bridges that are fully
-			 * initialized.
-			 */
-			if (IS_PCI_BRIDGE_ASIC(sn_irq_info->irq_bridge_type) &&
-			    (sn_irq_info->irq_bridge != NULL))
-				sn_check_intr(i, sn_irq_info);
+			sn_check_intr(i, sn_irq_info);
 		}
 	}
 	rcu_read_unlock();
Index: ce-devel/arch/ia64/sn/pci/pcibr/pcibr_provider.c
=================================--- ce-devel.orig/arch/ia64/sn/pci/pcibr/pcibr_provider.c	2005-08-02 15:39:43.278078407 -0500
+++ ce-devel/arch/ia64/sn/pci/pcibr/pcibr_provider.c	2005-08-02 15:39:52.992931150 -0500
@@ -170,6 +170,9 @@
 	struct pcibus_info *pcibus_info;
 	int bit = sn_irq_info->irq_int_bit;
 
+	if (! sn_irq_info->irq_bridge)
+		return;
+
 	pcidev_info = (struct pcidev_info *)sn_irq_info->irq_pciioinfo;
 	if (pcidev_info) {
 		pcibus_info @@ -214,6 +217,7 @@
 	.dma_map_consistent = pcibr_dma_map_consistent,
 	.dma_unmap = pcibr_dma_unmap,
 	.bus_fixup = pcibr_bus_fixup,
+	.force_interrupt = pcibr_force_interrupt
 };
 
 int
Index: ce-devel/arch/ia64/sn/pci/tioca_provider.c
=================================--- ce-devel.orig/arch/ia64/sn/pci/tioca_provider.c	2005-08-02 15:38:06.829674677 -0500
+++ ce-devel/arch/ia64/sn/pci/tioca_provider.c	2005-08-02 15:39:52.995860546 -0500
@@ -655,6 +655,7 @@
 	.dma_map_consistent = tioca_dma_map,
 	.dma_unmap = tioca_dma_unmap,
 	.bus_fixup = tioca_bus_fixup,
+	.force_interrupt = NULL
 };
 
 /**
Index: ce-devel/include/asm-ia64/sn/pcibus_provider_defs.h
=================================--- ce-devel.orig/include/asm-ia64/sn/pcibus_provider_defs.h	2005-08-02 15:38:06.824792351 -0500
+++ ce-devel/include/asm-ia64/sn/pcibus_provider_defs.h	2005-08-02 15:39:52.998789942 -0500
@@ -47,6 +47,7 @@
 	dma_addr_t	(*dma_map_consistent)(struct pci_dev *, unsigned long, size_t);
 	void		(*dma_unmap)(struct pci_dev *, dma_addr_t, int);
 	void *		(*bus_fixup)(struct pcibus_bussoft *);
+	void		(*force_interrupt)(struct sn_irq_info *);
 };
 
 extern struct sn_pcibus_provider *sn_pci_provider[];
Index: ce-devel/include/asm-ia64/sn/pda.h
=================================--- ce-devel.orig/include/asm-ia64/sn/pda.h	2005-08-02 15:36:58.086517822 -0500
+++ ce-devel/include/asm-ia64/sn/pda.h	2005-08-02 15:39:53.000742872 -0500
@@ -39,7 +39,6 @@
 	unsigned long pio_write_status_val;
 	volatile unsigned long *pio_shub_war_cam_addr;
 
-	unsigned long	sn_soft_irr[4];
 	unsigned long	sn_in_service_ivecs[4];
 	int		sn_lb_int_war_ticks;
 	int		sn_last_irq;
