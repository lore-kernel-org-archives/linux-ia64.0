From: Christoph Lameter <clameter@engr.sgi.com>
Date: Thu, 07 Jul 2005 23:59:21 +0000
Subject: [PATCH] pcibus_to_node implementation for IA64
Message-Id: <Pine.LNX.4.62.0507071657040.5277@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.62.0506231400360.13123@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0506231400360.13123@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

pcibus_to_node provides a way for the Linux kernel to identify to which node
a certain pcibus connects to. Allocations of control structures for devices can then be
made on the node where the pci bus is located to allow local access during interrupt and
other device manipulation.

This patch provides a new "node" field in the the pci_controller 
structure. The node field will be set based on ACPI information (thanks to 
Alex Williamson  <alex.williamson@hp.com for that piece).

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.13-rc2/include/asm-ia64/pci.h
=================================--- linux-2.6.13-rc2.orig/include/asm-ia64/pci.h	2005-07-05 20:46:33.000000000 -0700
+++ linux-2.6.13-rc2/include/asm-ia64/pci.h	2005-07-06 12:20:02.000000000 -0700
@@ -128,6 +128,7 @@ struct pci_controller {
 	void *acpi_handle;
 	void *iommu;
 	int segment;
+	int node;		/* nearest node with memory or -1 for global allocation */
 
 	unsigned int windows;
 	struct pci_window *window;
Index: linux-2.6.13-rc2/include/asm-ia64/topology.h
=================================--- linux-2.6.13-rc2.orig/include/asm-ia64/topology.h	2005-07-05 20:46:33.000000000 -0700
+++ linux-2.6.13-rc2/include/asm-ia64/topology.h	2005-07-06 12:20:02.000000000 -0700
@@ -40,6 +40,11 @@
  */
 #define node_to_first_cpu(node) (__ffs(node_to_cpumask(node)))
 
+/*
+ * Determines the node for a given pci bus
+ */
+#define pcibus_to_node(bus) PCI_CONTROLLER(bus)->node
+
 void build_cpu_to_node_map(void);
 
 #define SD_CPU_INIT (struct sched_domain) {		\
Index: linux-2.6.13-rc2/arch/ia64/pci/pci.c
=================================--- linux-2.6.13-rc2.orig/arch/ia64/pci/pci.c	2005-07-05 20:46:33.000000000 -0700
+++ linux-2.6.13-rc2/arch/ia64/pci/pci.c	2005-07-07 16:35:27.000000000 -0700
@@ -157,6 +157,7 @@ alloc_pci_controller (int seg)
 
 	memset(controller, 0, sizeof(*controller));
 	controller->segment = seg;
+	controller->node = -1;
 	return controller;
 }
 
@@ -288,6 +289,7 @@ pci_acpi_scan_root(struct acpi_device *d
 	unsigned int windows = 0;
 	struct pci_bus *pbus;
 	char *name;
+	int pxm;
 
 	controller = alloc_pci_controller(domain);
 	if (!controller)
@@ -295,10 +297,16 @@ pci_acpi_scan_root(struct acpi_device *d
 
 	controller->acpi_handle = device->handle;
 
+	pxm = acpi_get_pxm(controller->acpi_handle);
+#ifdef CONFIG_NUMA
+	if (pxm >= 0)
+		controller->node = pxm_to_nid_map[pxm];
+#endif
+
 	acpi_walk_resources(device->handle, METHOD_NAME__CRS, count_window,
 			&windows);
-	controller->window = kmalloc(sizeof(*controller->window) * windows,
-			GFP_KERNEL);
+	controller->window = kmalloc_node(sizeof(*controller->window) * windows,
+			GFP_KERNEL, controller->node);
 	if (!controller->window)
 		goto out2;
 
