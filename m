From: Christoph Lameter <clameter@engr.sgi.com>
Date: Thu, 23 Jun 2005 23:08:43 +0000
Subject: Re: [PATCH] pcibus_to_node implementation for IA64
Message-Id: <Pine.LNX.4.62.0506231604190.14176@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.62.0506231400360.13123@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0506231400360.13123@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 23 Jun 2005, Alex Williamson wrote:

>   Cool.  It works on an rx8620 here.  I forgot to wrap the generic setup
> in a NUMA config.  The below chunks should replace the sba_iommu chunk
> in the original patch.  Thanks,

Great. Tony I am going to split off my patch into two pieces, one generic 
and one Altix specific. Alex's patch implements the HP subarch support 
and the patch that I am going to send separately will implement Altix 
subarch support.

Here is the generic stuff for ia64 pcibus to node support:

----

[PATCH] pcibus_to_node implementation for IA64

pcibus_to_node provides a way for the Linux kernel to identify to which node
a certain pcibus connect to. Allocations of control structures for devices can then be
made on the node where the pci bus is located to allow local access during interrupt and
other device manipulation.

The numa aware block layer patch now in Linus tree relies on pcibus_to_node
to allocate block device control structures on the correct node. There is a pending
patch for an ethernet driver to allocate the descriptors on the node of each ethernet device.

This patch only provides an extension of the the pci_controller structure and will make
pcibus_to_node return -1 (undetermined) by default. Separate patches for HP and SGI will
be needed to make subarches return useful node information.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.12/include/asm-ia64/pci.h
=================================--- linux-2.6.12.orig/include/asm-ia64/pci.h	2005-06-17 12:48:29.000000000 -0700
+++ linux-2.6.12/include/asm-ia64/pci.h	2005-06-23 15:57:26.000000000 -0700
@@ -109,6 +109,7 @@ struct pci_controller {
 	void *acpi_handle;
 	void *iommu;
 	int segment;
+	int node;		/* nearest node with memory or -1 for global allocation */
 
 	unsigned int windows;
 	struct pci_window *window;
Index: linux-2.6.12/include/asm-ia64/topology.h
=================================--- linux-2.6.12.orig/include/asm-ia64/topology.h	2005-06-17 12:48:29.000000000 -0700
+++ linux-2.6.12/include/asm-ia64/topology.h	2005-06-23 15:57:26.000000000 -0700
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
=================================--- linux-2.6.12.orig/arch/ia64/pci/pci.c	2005-06-23 15:53:53.000000000 -0700
+++ linux-2.6.12/arch/ia64/pci/pci.c	2005-06-23 15:57:26.000000000 -0700
@@ -157,6 +157,7 @@ alloc_pci_controller (int seg)
 
 	memset(controller, 0, sizeof(*controller));
 	controller->segment = seg;
+	controller->node = -1;
 	return controller;
 }
 

