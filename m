From: Yijing Wang <wangyijing@huawei.com>
Date: Tue, 04 Jun 2013 10:59:07 +0000
Subject: [PATCH -v3 1/8] PCI/IA64: SN: remove sn_pci_window_fixup()
Message-Id: <1370343554-11812-2-git-send-email-wangyijing@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Currently, pcibios_bus_to_resource() and pcibios_resource_to_bus()
functions use pci_host_bridge_window in pci_host_bridge to translate
bus side to/from cpu side addresses. Pci_window in pci_controller
under IA64 is no used again, so it's no need to use sn_pci_window_fixup()
to setup pci_window again, remove it. Also rework sn_legacy_pci_window_fixup()
to avoid use pci_window struct.

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org
---
 arch/ia64/sn/kernel/io_init.c |   55 +----------------------------------------
 1 files changed, 1 insertions(+), 54 deletions(-)

diff --git a/arch/ia64/sn/kernel/io_init.c b/arch/ia64/sn/kernel/io_init.c
index 238e2c5..b8ff9ea 100644
--- a/arch/ia64/sn/kernel/io_init.c
+++ b/arch/ia64/sn/kernel/io_init.c
@@ -149,48 +149,6 @@ sn_legacy_pci_window_fixup(struct pci_controller *controller,
 }
 
 /*
- * sn_pci_window_fixup() - Create a pci_window for each device resource.
- *			   It will setup pci_windows for use by
- *			   pcibios_bus_to_resource(), pcibios_resource_to_bus(),
- *			   etc.
- */
-static void
-sn_pci_window_fixup(struct pci_dev *dev, unsigned int count,
-		    s64 * pci_addrs)
-{
-	struct pci_controller *controller = PCI_CONTROLLER(dev->bus);
-	unsigned int i;
-	unsigned int idx;
-	unsigned int new_count;
-	struct pci_window *new_window;
-
-	if (count = 0)
-		return;
-	idx = controller->windows;
-	new_count = controller->windows + count;
-	new_window = kcalloc(new_count, sizeof(struct pci_window), GFP_KERNEL);
-	BUG_ON(new_window = NULL);
-	if (controller->window) {
-		memcpy(new_window, controller->window,
-		       sizeof(struct pci_window) * controller->windows);
-		kfree(controller->window);
-	}
-
-	/* Setup a pci_window for each device resource. */
-	for (i = 0; i <= PCI_ROM_RESOURCE; i++) {
-		if (pci_addrs[i] = -1)
-			continue;
-
-		new_window[idx].offset = dev->resource[i].start - pci_addrs[i];
-		new_window[idx].resource = dev->resource[i];
-		idx++;
-	}
-
-	controller->windows = new_count;
-	controller->window = new_window;
-}
-
-/*
  * sn_io_slot_fixup() -   We are not running with an ACPI capable PROM,
  *			  and need to convert the pci_dev->resource
  *			  'start' and 'end' addresses to mapped addresses,
@@ -199,9 +157,7 @@ sn_pci_window_fixup(struct pci_dev *dev, unsigned int count,
 void
 sn_io_slot_fixup(struct pci_dev *dev)
 {
-	unsigned int count = 0;
 	int idx;
-	s64 pci_addrs[PCI_ROM_RESOURCE + 1];
 	unsigned long addr, end, size, start;
 	struct pcidev_info *pcidev_info;
 	struct sn_irq_info *sn_irq_info;
@@ -229,7 +185,6 @@ sn_io_slot_fixup(struct pci_dev *dev)
 	for (idx = 0; idx <= PCI_ROM_RESOURCE; idx++) {
 
 		if (!pcidev_info->pdi_pio_mapped_addr[idx]) {
-			pci_addrs[idx] = -1;
 			continue;
 		}
 
@@ -237,11 +192,8 @@ sn_io_slot_fixup(struct pci_dev *dev)
 		end = dev->resource[idx].end;
 		size = end - start;
 		if (size = 0) {
-			pci_addrs[idx] = -1;
 			continue;
 		}
-		pci_addrs[idx] = start;
-		count++;
 		addr = pcidev_info->pdi_pio_mapped_addr[idx];
 		addr = ((addr << 4) >> 4) | __IA64_UNCACHED_OFFSET;
 		dev->resource[idx].start = addr;
@@ -276,12 +228,7 @@ sn_io_slot_fixup(struct pci_dev *dev)
 						 IORESOURCE_ROM_BIOS_COPY;
 		}
 	}
-	/* Create a pci_window in the pci_controller struct for
-	 * each device resource.
-	 */
-	if (count > 0)
-		sn_pci_window_fixup(dev, count, pci_addrs);
-
+
 	sn_pci_fixup_slot(dev, pcidev_info, sn_irq_info);
 }
 
-- 
1.7.1


