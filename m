From: Yijing Wang <wangyijing@huawei.com>
Date: Fri, 17 May 2013 09:55:45 +0000
Subject: [PATCH -v2 2/7] PCI/IA64: SN: remove sn_pci_window_fixup()
Message-Id: <1368784550-18332-3-git-send-email-wangyijing@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1368784550-18332-1-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1368784550-18332-1-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: linux-pci@vger.kernel.org, Hanjun Guo <guohanjun@huawei.com>, jiang.liu@huawei.com, Yijing Wang <wangyijing@huawei.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

Currently, pcibios_bus_to_resource() and pcibios_resource_to_bus()
functions use pci_host_bridge_window in pci_host_bridge to translate
bus side to/from cpu side addresses. Pci_window in pci_controller
under IA64 is no used again, so remove this function.

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org
---
 arch/ia64/sn/kernel/io_init.c |   49 +----------------------------------------
 1 files changed, 1 insertions(+), 48 deletions(-)

diff --git a/arch/ia64/sn/kernel/io_init.c b/arch/ia64/sn/kernel/io_init.c
index 238e2c5..99710f5 100644
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
@@ -276,12 +234,7 @@ sn_io_slot_fixup(struct pci_dev *dev)
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


