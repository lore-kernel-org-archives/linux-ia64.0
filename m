From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date: Mon, 16 Jan 2006 04:45:23 +0000
Subject: [PATCH][BUG] Stop multiple pci_claim_resource() call for the same
Message-Id: <43CB24E3.8030006@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

I encountered the following problems:

    o Reading /proc/iomem cause endless loop.
    o request_mem_region() for PCI-to-PCI bridge fails.

This problem is caused by the bug that pci_claim_resource() is called
multiple times for the same P2P bridge's resource structure if P2P
bridge requires their own PCI I/O resources.

The patch below fixes this bug.

Thanks,
Kenji Kaneshige


This patch fixes the bug that pci_claim_resource() is called multiple
times for the same P2P bridge's resource structures if P2P bridges
require their own PCI I/O resources.

Signed-off-by: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>

 arch/ia64/pci/pci.c |   19 ++++++++++++++-----
 1 files changed, 14 insertions(+), 5 deletions(-)

Index: linux-2.6.15/arch/ia64/pci/pci.c
=================================--- linux-2.6.15.orig/arch/ia64/pci/pci.c	2006-01-11 21:51:43.000000000 +0900
+++ linux-2.6.15/arch/ia64/pci/pci.c	2006-01-11 22:20:51.000000000 +0900
@@ -454,14 +454,13 @@
 	return 0;
 }
 
-static void __devinit pcibios_fixup_device_resources(struct pci_dev *dev)
+static void __devinit
+pcibios_fixup_resources(struct pci_dev *dev, int start, int limit)
 {
 	struct pci_bus_region region;
 	int i;
-	int limit = (dev->hdr_type = PCI_HEADER_TYPE_NORMAL) ? \
-		PCI_BRIDGE_RESOURCES : PCI_NUM_RESOURCES;
 
-	for (i = 0; i < limit; i++) {
+	for (i = start; i < limit; i++) {
 		if (!dev->resource[i].flags)
 			continue;
 		region.start = dev->resource[i].start;
@@ -472,6 +471,16 @@
 	}
 }
 
+static void __devinit pcibios_fixup_device_resources(struct pci_dev *dev)
+{
+	pcibios_fixup_resources(dev, 0, PCI_BRIDGE_RESOURCES);
+}
+
+static void __devinit pcibios_fixup_bridge_resources(struct pci_dev *dev)
+{
+	pcibios_fixup_resources(dev, PCI_BRIDGE_RESOURCES, PCI_NUM_RESOURCES);
+}
+
 /*
  *  Called after each bus is probed, but before its children are examined.
  */
@@ -482,7 +491,7 @@
 
 	if (b->self) {
 		pci_read_bridge_bases(b);
-		pcibios_fixup_device_resources(b->self);
+		pcibios_fixup_bridge_resources(b->self);
 	}
 	list_for_each_entry(dev, &b->devices, bus_list)
 		pcibios_fixup_device_resources(dev);
