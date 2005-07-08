From: Christoph Lameter <clameter@engr.sgi.com>
Date: Fri, 08 Jul 2005 00:04:27 +0000
Subject: [PATCH] Altix pcibus_to_node fixes
Message-Id: <Pine.LNX.4.62.0507071659290.5288@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This patch depends on the pcibus_to_node patch posted earlier.

The Altix subarch does not provide node information via ACPI. Instead hooks
are used to fixup pci structures. This patch determines the nodes for Altix
PCI busses and sets the controller node information accordingly.

Remote Bridges:
---------------
Altix supports remote I/O nodes without memory or processors but with bridges.
The TIOCA type of bridge is an AGP bridge and the PROM provides information
about the closest node. That information will be returned by pcibus_to_node.

The TIOCP remote bridge type is a PCI bridge but the PROM does not provide a
closest node id. pcibus_to_node will return -1 for devices on those 
bridges.

Safeguard:
----------
Should the fixups result in invalid node information for a pci controller then
a warning will be printed and the controller->node field 
will be set to -1.


This patch also removes the "FIXME" in sn_dma_alloc_coherent. 
dma_alloc_coherent will use alloc_pages_node to allocate memory local 
to the node that the PCI device is connected to.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.13-rc2/arch/ia64/sn/kernel/io_init.c
=================================--- linux-2.6.13-rc2.orig/arch/ia64/sn/kernel/io_init.c	2005-07-05 20:46:33.000000000 -0700
+++ linux-2.6.13-rc2/arch/ia64/sn/kernel/io_init.c	2005-07-06 13:15:47.000000000 -0700
@@ -54,7 +54,7 @@ sn_default_pci_unmap(struct pci_dev *pde
 }
 
 static void *
-sn_default_pci_bus_fixup(struct pcibus_bussoft *soft)
+sn_default_pci_bus_fixup(struct pcibus_bussoft *soft, struct pci_controller *controller)
 {
 	return NULL;
 }
@@ -347,7 +347,7 @@ static void sn_pci_controller_fixup(int 
 
 	provider_soft = NULL;
 	if (provider->bus_fixup) {
-		provider_soft = (*provider->bus_fixup) (prom_bussoft_ptr);
+		provider_soft = (*provider->bus_fixup) (prom_bussoft_ptr, controller);
 	}
 
 	if (provider_soft = NULL) {
@@ -367,6 +367,17 @@ static void sn_pci_controller_fixup(int 
 	hubdev_info = (struct hubdev_info *)(NODEPDA(cnode)->pdinfo);
 	SN_PCIBUS_BUSSOFT(bus)->bs_xwidget_info  	    &(hubdev_info->hdi_xwidget_info[SN_PCIBUS_BUSSOFT(bus)->bs_xid]);
+
+	/*
+	 * If the node information we obtained during the fixup phase is invalid
+	 * then set controller->node to -1 (undetermined)
+	 */
+	if (controller->node >= num_online_nodes()) {
+		struct pcibus_bussoft *b = SN_PCIBUS_BUSSOFT(bus);
+		printk(KERN_WARNING "Device ASIC=%u XID=%u PBUSNUM=%lu L_IO=%lx L_MEM=%lx BASE=%lx\n",b->bs_asic_type, b->bs_xid, b->bs_persist_busnum, b->bs_legacy_io, b->bs_legacy_mem, b->bs_base);
+		printk(KERN_WARNING "on node %d but only %d nodes online. Association set to undetermined.\n", controller->node, num_online_nodes());
+		controller->node = -1;
+	}
 }
 
 /*
Index: linux-2.6.13-rc2/arch/ia64/sn/pci/pci_dma.c
=================================--- linux-2.6.13-rc2.orig/arch/ia64/sn/pci/pci_dma.c	2005-07-05 20:46:33.000000000 -0700
+++ linux-2.6.13-rc2/arch/ia64/sn/pci/pci_dma.c	2005-07-06 12:42:18.000000000 -0700
@@ -78,6 +78,7 @@ void *sn_dma_alloc_coherent(struct devic
 {
 	void *cpuaddr;
 	unsigned long phys_addr;
+	int node;
 	struct pci_dev *pdev = to_pci_dev(dev);
 	struct sn_pcibus_provider *provider = SN_PCIDEV_BUSPROVIDER(pdev);
 
@@ -85,10 +86,19 @@ void *sn_dma_alloc_coherent(struct devic
 
 	/*
 	 * Allocate the memory.
-	 * FIXME: We should be doing alloc_pages_node for the node closest
-	 *        to the PCI device.
 	 */
-	if (!(cpuaddr = (void *)__get_free_pages(GFP_ATOMIC, get_order(size))))
+	node = pcibus_to_node(pdev->bus);
+	if (likely(node >=0)) {
+		struct page *p = alloc_pages_node(node, GFP_ATOMIC, get_order(size));
+
+		if (likely(p))
+			cpuaddr = page_address(p);
+		else
+			return NULL;
+	} else
+		cpuaddr = (void *)__get_free_pages(GFP_ATOMIC, get_order(size));
+
+	if (unlikely(!cpuaddr))
 		return NULL;
 
 	memset(cpuaddr, 0x0, size);
Index: linux-2.6.13-rc2/include/asm-ia64/sn/pcibus_provider_defs.h
=================================--- linux-2.6.13-rc2.orig/include/asm-ia64/sn/pcibus_provider_defs.h	2005-07-05 20:46:33.000000000 -0700
+++ linux-2.6.13-rc2/include/asm-ia64/sn/pcibus_provider_defs.h	2005-07-06 12:42:18.000000000 -0700
@@ -37,6 +37,7 @@ struct pcibus_bussoft {
 	struct xwidget_info	*bs_xwidget_info;
 };
 
+struct pci_controller;
 /*
  * SN pci bus indirection
  */
@@ -45,7 +46,7 @@ struct sn_pcibus_provider {
 	dma_addr_t	(*dma_map)(struct pci_dev *, unsigned long, size_t);
 	dma_addr_t	(*dma_map_consistent)(struct pci_dev *, unsigned long, size_t);
 	void		(*dma_unmap)(struct pci_dev *, dma_addr_t, int);
-	void *		(*bus_fixup)(struct pcibus_bussoft *);
+	void *		(*bus_fixup)(struct pcibus_bussoft *, struct pci_controller *);
 };
 
 extern struct sn_pcibus_provider *sn_pci_provider[];
Index: linux-2.6.13-rc2/arch/ia64/sn/pci/pcibr/pcibr_provider.c
=================================--- linux-2.6.13-rc2.orig/arch/ia64/sn/pci/pcibr/pcibr_provider.c	2005-07-05 20:46:33.000000000 -0700
+++ linux-2.6.13-rc2/arch/ia64/sn/pci/pcibr/pcibr_provider.c	2005-07-07 16:06:12.000000000 -0700
@@ -52,7 +52,7 @@ pcibr_error_intr_handler(int irq, void *
 }
 
 void *
-pcibr_bus_fixup(struct pcibus_bussoft *prom_bussoft)
+pcibr_bus_fixup(struct pcibus_bussoft *prom_bussoft, struct pci_controller *controller)
 {
 	int nasid, cnode, j;
 	struct hubdev_info *hubdev_info;
@@ -125,6 +125,14 @@ pcibr_bus_fixup(struct pcibus_bussoft *p
 	memset(soft->pbi_int_ate_resource.ate, 0,
  	       (soft->pbi_int_ate_size * sizeof(uint64_t)));
 
+	if (prom_bussoft->bs_asic_type = PCIIO_ASIC_TYPE_TIOCP)
+		/*
+		 * TIO PCI Bridge with no closest node information.
+		 * FIXME: Find another way to determine the closest node
+		 */
+		controller->node = -1;
+	else
+		controller->node = cnode;
 	return soft;
 }
 
Index: linux-2.6.13-rc2/arch/ia64/sn/pci/tioca_provider.c
=================================--- linux-2.6.13-rc2.orig/arch/ia64/sn/pci/tioca_provider.c	2005-07-05 20:46:33.000000000 -0700
+++ linux-2.6.13-rc2/arch/ia64/sn/pci/tioca_provider.c	2005-07-06 12:43:19.000000000 -0700
@@ -581,7 +581,7 @@ tioca_error_intr_handler(int irq, void *
  * the caller.
  */
 static void *
-tioca_bus_fixup(struct pcibus_bussoft *prom_bussoft)
+tioca_bus_fixup(struct pcibus_bussoft *prom_bussoft, struct pci_controller *controller)
 {
 	struct tioca_common *tioca_common;
 	struct tioca_kernel *tioca_kern;
@@ -647,6 +647,8 @@ tioca_bus_fixup(struct pcibus_bussoft *p
 		       __FUNCTION__, SGI_TIOCA_ERROR,
 		       (int)tioca_common->ca_common.bs_persist_busnum);
 
+	/* Setup locality information */
+	controller->node = tioca_kern->ca_closest_node;
 	return tioca_common;
 }
 
Index: linux-2.6.13-rc2/arch/ia64/sn/include/pci/pcibr_provider.h
=================================--- linux-2.6.13-rc2.orig/arch/ia64/sn/include/pci/pcibr_provider.h	2005-07-05 20:46:33.000000000 -0700
+++ linux-2.6.13-rc2/arch/ia64/sn/include/pci/pcibr_provider.h	2005-07-06 12:42:18.000000000 -0700
@@ -124,7 +124,7 @@ pcibr_lock(struct pcibus_info *pcibus_in
 #define pcibr_unlock(pcibus_info, flag)  spin_unlock_irqrestore(&pcibus_info->pbi_lock, flag)
 
 extern int  pcibr_init_provider(void);
-extern void *pcibr_bus_fixup(struct pcibus_bussoft *);
+extern void *pcibr_bus_fixup(struct pcibus_bussoft *,struct pci_controller *);
 extern dma_addr_t pcibr_dma_map(struct pci_dev *, unsigned long, size_t);
 extern dma_addr_t pcibr_dma_map_consistent(struct pci_dev *, unsigned long, size_t);
 extern void pcibr_dma_unmap(struct pci_dev *, dma_addr_t, int);
