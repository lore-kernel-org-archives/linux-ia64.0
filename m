From: Yijing Wang <wangyijing@huawei.com>
Date: Mon, 23 Mar 2015 12:40:42 +0000
Subject: [PATCH v7 16/31] PCI: Introduce pci_bus_child_max_busnr()
Message-Id: <1427114457-16687-17-git-send-email-wangyijing@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1427114457-16687-1-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1427114457-16687-1-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, linux-pci@vger.kernel.org, Yinghai Lu <yinghai@kernel.org>, linux-kernel@vger.kernel.org, Marc Zyngier <marc.zyngier@arm.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rusty Russell <rusty@rustcorp.com.au>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-alpha@vger.kernel.org, linux-m68k@vger.kernel.org, Liviu Dudau <liviu@dudau.co.uk>, Arnd Bergmann <arnd@arndb.de>, Geert Uytterhoeven <geert@linux-m68k.org>, Yijing Wang <wangyijing@huawei.com>, Fengguang Wu <fengguang.wu@intel.com>

Sometimes, we want to know the highest reserved
busnr for children bus. Because parent's bus->busn_res
may have padding in it. For example, some host drivers
don't know the bus end, so they supply the bus
resource (root_bus, 255), they want to update the
max bus number after pci scan complete. But pci scan
functions won't return the actual max bus number.
So we could use pci_bus_child_max_busnr() to find
that.

Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
Signed-off-by: Yijing Wang <wangyijing@huawei.com>
---
 drivers/pci/hotplug/acpiphp_glue.c |   29 +----------------------------
 drivers/pci/pci.c                  |   27 +++++++++++++++++++++++++--
 include/linux/pci.h                |    2 +-
 3 files changed, 27 insertions(+), 31 deletions(-)

diff --git a/drivers/pci/hotplug/acpiphp_glue.c b/drivers/pci/hotplug/acpiphp_glue.c
index bcb90e4..84f2584 100644
--- a/drivers/pci/hotplug/acpiphp_glue.c
+++ b/drivers/pci/hotplug/acpiphp_glue.c
@@ -397,33 +397,6 @@ static void cleanup_bridge(struct acpiphp_bridge *bridge)
 	acpi_unlock_hp_context();
 }
 
-/**
- * acpiphp_max_busnr - return the highest reserved bus number under the given bus.
- * @bus: bus to start search with
- */
-static unsigned char acpiphp_max_busnr(struct pci_bus *bus)
-{
-	struct pci_bus *tmp;
-	unsigned char max, n;
-
-	/*
-	 * pci_bus_max_busnr will return the highest
-	 * reserved busnr for all these children.
-	 * that is equivalent to the bus->subordinate
-	 * value.  We don't want to use the parent's
-	 * bus->subordinate value because it could have
-	 * padding in it.
-	 */
-	max = bus->busn_res.start;
-
-	list_for_each_entry(tmp, &bus->children, node) {
-		n = pci_bus_max_busnr(tmp);
-		if (n > max)
-			max = n;
-	}
-	return max;
-}
-
 static void acpiphp_set_acpi_region(struct acpiphp_slot *slot)
 {
 	struct acpiphp_func *func;
@@ -489,7 +462,7 @@ static void enable_slot(struct acpiphp_slot *slot)
 	LIST_HEAD(add_list);
 
 	acpiphp_rescan_slot(slot);
-	max = acpiphp_max_busnr(bus);
+	max = pci_bus_child_max_busnr(bus);
 	for (pass = 0; pass < 2; pass++) {
 		list_for_each_entry(dev, &bus->devices, bus_list) {
 			if (PCI_SLOT(dev->devfn) != slot->device)
diff --git a/drivers/pci/pci.c b/drivers/pci/pci.c
index 6677fac..8a2f12c 100644
--- a/drivers/pci/pci.c
+++ b/drivers/pci/pci.c
@@ -108,7 +108,7 @@ static bool pcie_ari_disabled;
  * Given a PCI bus, returns the highest PCI bus number present in the set
  * including the given PCI bus and its list of child PCI buses.
  */
-unsigned char pci_bus_max_busnr(struct pci_bus *bus)
+static unsigned char pci_bus_max_busnr(struct pci_bus *bus)
 {
 	struct pci_bus *tmp;
 	unsigned char max, n;
@@ -121,7 +121,30 @@ unsigned char pci_bus_max_busnr(struct pci_bus *bus)
 	}
 	return max;
 }
-EXPORT_SYMBOL_GPL(pci_bus_max_busnr);
+
+unsigned char pci_bus_child_max_busnr(struct pci_bus *bus)
+{
+	struct pci_bus *tmp;
+	unsigned char max, n;
+
+	/*
+	 * pci_bus_max_busnr will return the highest
+	 * reserved busnr for all these children.
+	 * that is equivalent to the bus->subordinate
+	 * value.  We don't want to use the parent's
+	 * bus->subordinate value because it could have
+	 * padding in it.
+	 */
+	max = bus->busn_res.start;
+
+	list_for_each_entry(tmp, &bus->children, node) {
+		n = pci_bus_max_busnr(tmp);
+		if (n > max)
+			max = n;
+	}
+	return max;
+}
+EXPORT_SYMBOL_GPL(pci_bus_child_max_busnr);
 
 #ifdef CONFIG_HAS_IOMEM
 void __iomem *pci_ioremap_bar(struct pci_dev *pdev, int bar)
diff --git a/include/linux/pci.h b/include/linux/pci.h
index 7f4f182..0b921d6 100644
--- a/include/linux/pci.h
+++ b/include/linux/pci.h
@@ -1185,7 +1185,7 @@ int pci_scan_bridge(struct pci_bus *bus, struct pci_dev *dev, int max,
 void pci_walk_bus(struct pci_bus *top, int (*cb)(struct pci_dev *, void *),
 		  void *userdata);
 int pci_cfg_space_size(struct pci_dev *dev);
-unsigned char pci_bus_max_busnr(struct pci_bus *bus);
+unsigned char pci_bus_child_max_busnr(struct pci_bus *bus);
 void pci_setup_bridge(struct pci_bus *bus);
 resource_size_t pcibios_window_alignment(struct pci_bus *bus,
 					 unsigned long type);
-- 
1.7.1

