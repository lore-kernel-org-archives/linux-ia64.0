From: Bjorn Helgaas <bhelgaas@google.com>
Date: Wed, 29 Jan 2014 18:19:02 +0000
Subject: [PATCH 13/17] ia64: Remove acpi_get_pxm() usage
Message-Id: <20140129181902.15476.86815.stgit@bhelgaas-glaptop.roam.corp.google.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20140129174106.15476.7075.stgit@bhelgaas-glaptop.roam.corp.google.com>
In-Reply-To: <20140129174106.15476.7075.stgit@bhelgaas-glaptop.roam.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-pci@vger.kernel.org
Cc: linux-acpi@vger.kernel.org, x86@kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

The IOMMU, LSAPIC, IOSAPIC, and PCI host bridge code doesn't care about
_PXM values directly; it only needs to know what NUMA node the hardware is
on.

This uses acpi_get_node() directly and removes the _PXM stuff.

Signed-off-by: Bjorn Helgaas <bhelgaas@google.com>
---
 arch/ia64/hp/common/sba_iommu.c |   22 +++++-----------------
 arch/ia64/include/asm/pci.h     |    2 +-
 arch/ia64/kernel/acpi.c         |   28 +++++++---------------------
 arch/ia64/pci/pci.c             |   10 ++--------
 4 files changed, 15 insertions(+), 47 deletions(-)

diff --git a/arch/ia64/hp/common/sba_iommu.c b/arch/ia64/hp/common/sba_iommu.c
index a52d6b49b7ce..007361d59aa6 100644
--- a/arch/ia64/hp/common/sba_iommu.c
+++ b/arch/ia64/hp/common/sba_iommu.c
@@ -2017,31 +2017,19 @@ sba_connect_bus(struct pci_bus *bus)
 	printk(KERN_WARNING "No IOC for PCI Bus %04x:%02x in ACPI\n", pci_domain_nr(bus), bus->number);
 }
 
-#ifdef CONFIG_NUMA
 static void __init
 sba_map_ioc_to_node(struct ioc *ioc, acpi_handle handle)
 {
+#ifdef CONFIG_NUMA
 	unsigned int node;
-	int pxm;
-
-	ioc->node = NUMA_NO_NODE;
-
-	pxm = acpi_get_pxm(handle);
-
-	if (pxm < 0)
-		return;
 
-	node = pxm_to_node(pxm);
-
-	if (node = NUMA_NO_NODE || !node_online(node))
-		return;
+	node = acpi_get_node(handle);
+	if (node != NUMA_NO_NODE && !node_online(node))
+		node = NUMA_NO_NODE;
 
 	ioc->node = node;
-	return;
-}
-#else
-#define sba_map_ioc_to_node(ioc, handle)
 #endif
+}
 
 static int __init
 acpi_sba_ioc_add(struct acpi_device *device,
diff --git a/arch/ia64/include/asm/pci.h b/arch/ia64/include/asm/pci.h
index 71fbaaa495cc..7d41cc089822 100644
--- a/arch/ia64/include/asm/pci.h
+++ b/arch/ia64/include/asm/pci.h
@@ -98,7 +98,7 @@ struct pci_controller {
 	struct acpi_device *companion;
 	void *iommu;
 	int segment;
-	int node;		/* nearest node with memory or -1 for global allocation */
+	int node;		/* nearest node with memory or NUMA_NO_NODE for global allocation */
 
 	void *platform_data;
 };
diff --git a/arch/ia64/kernel/acpi.c b/arch/ia64/kernel/acpi.c
index 07d209c9507f..5a585ebe9df3 100644
--- a/arch/ia64/kernel/acpi.c
+++ b/arch/ia64/kernel/acpi.c
@@ -803,14 +803,9 @@ int acpi_isa_irq_to_gsi(unsigned isa_irq, u32 *gsi)
  *  ACPI based hotplug CPU support
  */
 #ifdef CONFIG_ACPI_HOTPLUG_CPU
-static
-int acpi_map_cpu2node(acpi_handle handle, int cpu, int physid)
+static int acpi_map_cpu2node(acpi_handle handle, int cpu, int physid)
 {
 #ifdef CONFIG_ACPI_NUMA
-	int pxm_id;
-	int nid;
-
-	pxm_id = acpi_get_pxm(handle);
 	/*
 	 * We don't have cpu-only-node hotadd. But if the system equips
 	 * SRAT table, pxm is already found and node is ready.
@@ -818,11 +813,10 @@ int acpi_map_cpu2node(acpi_handle handle, int cpu, int physid)
 	 * This code here is for the system which doesn't have full SRAT
   	 * table for possible cpus.
 	 */
-	nid = acpi_map_pxm_to_node(pxm_id);
 	node_cpuid[cpu].phys_id = physid;
-	node_cpuid[cpu].nid = nid;
+	node_cpuid[cpu].nid = acpi_get_node(handle);
 #endif
-	return (0);
+	return 0;
 }
 
 int additional_cpus __initdata = -1;
@@ -929,7 +923,7 @@ static acpi_status acpi_map_iosapic(acpi_handle handle, u32 depth,
 	union acpi_object *obj;
 	struct acpi_madt_io_sapic *iosapic;
 	unsigned int gsi_base;
-	int pxm, node;
+	int node;
 
 	/* Only care about objects w/ a method that returns the MADT */
 	if (ACPI_FAILURE(acpi_evaluate_object(handle, "_MAT", NULL, &buffer)))
@@ -956,17 +950,9 @@ static acpi_status acpi_map_iosapic(acpi_handle handle, u32 depth,
 
 	kfree(buffer.pointer);
 
-	/*
-	 * OK, it's an IOSAPIC MADT entry, look for a _PXM value to tell
-	 * us which node to associate this with.
-	 */
-	pxm = acpi_get_pxm(handle);
-	if (pxm < 0)
-		return AE_OK;
-
-	node = pxm_to_node(pxm);
-
-	if (node >= MAX_NUMNODES || !node_online(node) ||
+	/* OK, it's an IOSAPIC MADT entry; associate it with a node */
+	node = acpi_get_node(handle);
+	if (node = NUMA_NO_NODE || !node_online(node) ||
 	    cpumask_empty(cpumask_of_node(node)))
 		return AE_OK;
 
diff --git a/arch/ia64/pci/pci.c b/arch/ia64/pci/pci.c
index 9e4938d8ca4d..291a582777cf 100644
--- a/arch/ia64/pci/pci.c
+++ b/arch/ia64/pci/pci.c
@@ -126,7 +126,6 @@ static struct pci_controller *alloc_pci_controller(int seg)
 		return NULL;
 
 	controller->segment = seg;
-	controller->node = -1;
 	return controller;
 }
 
@@ -430,19 +429,14 @@ struct pci_bus *pci_acpi_scan_root(struct acpi_pci_root *root)
 	struct pci_root_info *info = NULL;
 	int busnum = root->secondary.start;
 	struct pci_bus *pbus;
-	int pxm, ret;
+	int ret;
 
 	controller = alloc_pci_controller(domain);
 	if (!controller)
 		return NULL;
 
 	controller->companion = device;
-
-	pxm = acpi_get_pxm(device->handle);
-#ifdef CONFIG_NUMA
-	if (pxm >= 0)
-		controller->node = pxm_to_node(pxm);
-#endif
+	controller->node = acpi_get_node(device->handle);
 
 	info = kzalloc(sizeof(*info), GFP_KERNEL);
 	if (!info) {

