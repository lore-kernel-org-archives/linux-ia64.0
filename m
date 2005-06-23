From: Christoph Lameter <clameter@engr.sgi.com>
Date: Thu, 23 Jun 2005 21:02:24 +0000
Subject: [PATCH] pcibus_to_node implementation for IA64
Message-Id: <Pine.LNX.4.62.0506231400360.13123@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

pcibus_to_node provides a way for the Linux kernel to identify to which node
a certain pcibus connect to. Allocations of control structures for devices can then be
made on the node where the pci bus is located to allow local access during interrupt and
other device manipulation.

The numa aware block layer patch now in Linus tree relies on 
pcibus_to_node to allocate block device control structures on the correct 
node. There is a pending patch for an ethernet driver to allocate the 
descriptors on the node of each ethernet device.

pcibus_to_node was implemented for IA64 by adding an additional node field 
to the pci_controller structure and then have each subarchitecture set 
this field.

I hope I got the implementation for HP right. Please check.

The implementation for Altix is currently only returning the correct node 
id for devices that are located on nodes with memory. For devices from 
nodes without memory pcibus_to_node will return -1 (undetermined) which 
will then result in the fallback to old any node (or cpu local node) 
allocation strategy. We will fix that as soon as we can figure out how to
get to valid Linux node numbers from the io node numbers.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.12/include/asm-ia64/pci.h
=================================--- linux-2.6.12.orig/include/asm-ia64/pci.h	2005-06-17 12:48:29.000000000 -0700
+++ linux-2.6.12/include/asm-ia64/pci.h	2005-06-23 13:55:01.000000000 -0700
@@ -109,6 +109,7 @@ struct pci_controller {
 	void *acpi_handle;
 	void *iommu;
 	int segment;
+	int node;		/* nearest node with memory or -1 for global allocation */
 
 	unsigned int windows;
 	struct pci_window *window;
Index: linux-2.6.12/include/asm-ia64/topology.h
=================================--- linux-2.6.12.orig/include/asm-ia64/topology.h	2005-06-17 12:48:29.000000000 -0700
+++ linux-2.6.12/include/asm-ia64/topology.h	2005-06-23 13:55:01.000000000 -0700
@@ -40,6 +40,11 @@
  */
 #define node_to_first_cpu(node) (__ffs(node_to_cpumask(node)))
 
+/*
+ * Determines the node for a given pci bus
+ */
+#define pcibus_to_node(bus) PCI_CONTROLLER(bus)->node
+
 void build_cpu_to_node_map(void);
 
 /* sched_domains SD_NODE_INIT for IA64 NUMA machines */
Index: linux-2.6.12/arch/ia64/pci/pci.c
=================================--- linux-2.6.12.orig/arch/ia64/pci/pci.c	2005-06-17 12:48:29.000000000 -0700
+++ linux-2.6.12/arch/ia64/pci/pci.c	2005-06-23 13:55:01.000000000 -0700
@@ -175,6 +175,7 @@ alloc_pci_controller (int seg)
 
 	memset(controller, 0, sizeof(*controller));
 	controller->segment = seg;
+	controller->node = -1;
 	return controller;
 }
 
Index: linux-2.6.12/arch/ia64/sn/kernel/io_init.c
=================================--- linux-2.6.12.orig/arch/ia64/sn/kernel/io_init.c	2005-06-17 12:48:29.000000000 -0700
+++ linux-2.6.12/arch/ia64/sn/kernel/io_init.c	2005-06-23 13:55:02.000000000 -0700
@@ -364,6 +364,8 @@ static void sn_pci_controller_fixup(int 
 
 	nasid = NASID_GET(SN_PCIBUS_BUSSOFT(bus)->bs_base);
 	cnode = nasid_to_cnodeid(nasid);
+	if (cnode < num_online_nodes() && cnode < numionodes)
+		controller->node = cnode;
 	hubdev_info = (struct hubdev_info *)(NODEPDA(cnode)->pdinfo);
 	SN_PCIBUS_BUSSOFT(bus)->bs_xwidget_info  	    &(hubdev_info->hdi_xwidget_info[SN_PCIBUS_BUSSOFT(bus)->bs_xid]);
Index: linux-2.6.12/arch/ia64/sn/pci/pci_dma.c
=================================--- linux-2.6.12.orig/arch/ia64/sn/pci/pci_dma.c	2005-06-17 12:48:29.000000000 -0700
+++ linux-2.6.12/arch/ia64/sn/pci/pci_dma.c	2005-06-23 13:55:02.000000000 -0700
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
Index: linux-2.6.12/arch/ia64/hp/common/sba_iommu.c
=================================--- linux-2.6.12.orig/arch/ia64/hp/common/sba_iommu.c	2005-06-17 12:48:29.000000000 -0700
+++ linux-2.6.12/arch/ia64/hp/common/sba_iommu.c	2005-06-23 13:55:02.000000000 -0700
@@ -1930,6 +1930,9 @@ sba_connect_bus(struct pci_bus *bus)
 		for (ioc = ioc_list; ioc; ioc = ioc->next)
 			if (ioc->handle = handle) {
 				PCI_CONTROLLER(bus)->iommu = ioc;
+#ifdef CONFIG_NUMA
+				PCI_CONTROLLER(bus)->node = ioc->node;
+#endif
 				return;
 			}
 
