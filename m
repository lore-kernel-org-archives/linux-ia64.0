From: Yijing Wang <wangyijing@huawei.com>
Date: Tue, 21 Apr 2015 11:34:24 +0000
Subject: [PATCH v10 05/29] PCI: Remove argument bus for pci_create_root_bus()
Message-Id: <1429616088-10249-6-git-send-email-wangyijing@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1429616088-10249-1-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1429616088-10249-1-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, linux-pci@vger.kernel.org, Yinghai Lu <yinghai@kernel.org>, linux-kernel@vger.kernel.org, Marc Zyngier <marc.zyngier@arm.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, dja@axtens.net, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rusty Russell <rusty@rustcorp.com.au>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-alpha@vger.kernel.org, linux-m68k@vger.kernel.org, Liviu Dudau <liviu@dudau.co.uk>, Arnd Bergmann <arnd@arndb.de>, Geert Uytterhoeven <geert@linux-m68k.org>, Yijing Wang <wangyijing@huawei.com>

All pci_create_root_bus() callers have supplied
busn resource, the argument bus is equal to
busn_res->start, clean up the redundant argument
bus for simplicity.

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
---
 arch/ia64/pci/pci.c                |    3 +--
 arch/powerpc/kernel/pci-common.c   |    2 +-
 arch/sparc/kernel/pci.c            |    2 +-
 arch/x86/pci/acpi.c                |    4 ++--
 drivers/parisc/dino.c              |    2 +-
 drivers/parisc/lba_pci.c           |    3 +--
 drivers/pci/host/pci-mvebu.c       |    2 +-
 drivers/pci/host/pci-tegra.c       |    2 +-
 drivers/pci/host/pci-xgene.c       |    2 +-
 drivers/pci/host/pcie-designware.c |    4 ++--
 drivers/pci/probe.c                |   26 ++++++++++++++++++++------
 include/linux/pci.h                |    2 +-
 12 files changed, 33 insertions(+), 21 deletions(-)

diff --git a/arch/ia64/pci/pci.c b/arch/ia64/pci/pci.c
index c642bc8..84f1eb8 100644
--- a/arch/ia64/pci/pci.c
+++ b/arch/ia64/pci/pci.c
@@ -424,7 +424,6 @@ struct pci_bus *pci_acpi_scan_root(struct acpi_pci_root *root)
 {
 	struct acpi_device *device = root->device;
 	int domain = root->segment;
-	int bus = root->secondary.start;
 	struct pci_controller *controller;
 	struct pci_root_info *info = NULL;
 	int busnum = root->secondary.start;
@@ -465,7 +464,7 @@ struct pci_bus *pci_acpi_scan_root(struct acpi_pci_root *root)
 	 * should handle the case here, but it appears that IA64 hasn't
 	 * such quirk. So we just ignore the case now.
 	 */
-	pbus = pci_create_root_bus(NULL, domain, bus, &pci_root_ops,
+	pbus = pci_create_root_bus(NULL, domain, &pci_root_ops,
 			controller, &info->resources);
 	if (!pbus) {
 		pci_free_resource_list(&info->resources);
diff --git a/arch/powerpc/kernel/pci-common.c b/arch/powerpc/kernel/pci-common.c
index 9913f6c..9acc08d 100644
--- a/arch/powerpc/kernel/pci-common.c
+++ b/arch/powerpc/kernel/pci-common.c
@@ -1613,7 +1613,7 @@ void pcibios_scan_phb(struct pci_controller *hose)
 
 	/* Create an empty bus for the toplevel */
 	bus = pci_create_root_bus(hose->parent, hose->global_number,
-			hose->first_busno, hose->ops, hose, &resources);
+			hose->ops, hose, &resources);
 	if (bus = NULL) {
 		pr_err("Failed to create bus for PCI domain %04x\n",
 			hose->global_number);
diff --git a/arch/sparc/kernel/pci.c b/arch/sparc/kernel/pci.c
index e40e456..6ff363c 100644
--- a/arch/sparc/kernel/pci.c
+++ b/arch/sparc/kernel/pci.c
@@ -667,7 +667,7 @@ struct pci_bus *pci_scan_one_pbm(struct pci_pbm_info *pbm,
 	pbm->busn.end	= pbm->pci_last_busno;
 	pbm->busn.flags	= IORESOURCE_BUS;
 	pci_add_resource(&resources, &pbm->busn);
-	bus = pci_create_root_bus(parent, pbm->index, pbm->pci_first_busno,
+	bus = pci_create_root_bus(parent, pbm->index,
 			pbm->pci_ops, pbm, &resources);
 	if (!bus) {
 		printk(KERN_ERR "Failed to create bus for %s\n",
diff --git a/arch/x86/pci/acpi.c b/arch/x86/pci/acpi.c
index 7563855..d6aab1c 100644
--- a/arch/x86/pci/acpi.c
+++ b/arch/x86/pci/acpi.c
@@ -430,8 +430,8 @@ struct pci_bus *pci_acpi_scan_root(struct acpi_pci_root *root)
 
 		if (!setup_mcfg_map(info, domain, (u8)root->secondary.start,
 				    (u8)root->secondary.end, root->mcfg_addr))
-			bus = pci_create_root_bus(NULL, domain, busnum,
-					&pci_root_ops, sd, &resources);
+			bus = pci_create_root_bus(NULL, domain, &pci_root_ops,
+					sd, &resources);
 
 		if (bus) {
 			pci_scan_child_bus(bus);
diff --git a/drivers/parisc/dino.c b/drivers/parisc/dino.c
index f375252..56abc43 100644
--- a/drivers/parisc/dino.c
+++ b/drivers/parisc/dino.c
@@ -986,7 +986,7 @@ static int __init dino_probe(struct parisc_device *dev)
 	** with configuration accessor functions.
 	*/
 	dino_dev->hba.hba_bus = bus = pci_create_root_bus(&dev->dev,
-			 0, dino_current_bus, &dino_cfg_ops, NULL, &resources);
+			 0, &dino_cfg_ops, NULL, &resources);
 	if (!bus) {
 		printk(KERN_ERR "ERROR: failed to scan PCI bus on %s (duplicate bus number %d?)\n",
 		       dev_name(&dev->dev), dino_current_bus);
diff --git a/drivers/parisc/lba_pci.c b/drivers/parisc/lba_pci.c
index 2949030..0b9ed96 100644
--- a/drivers/parisc/lba_pci.c
+++ b/drivers/parisc/lba_pci.c
@@ -1563,8 +1563,7 @@ lba_driver_probe(struct parisc_device *dev)
 
 	dev->dev.platform_data = lba_dev;
 	lba_bus = lba_dev->hba.hba_bus -		pci_create_root_bus(&dev->dev, 0, lba_dev->hba.bus_num.start,
-				    cfg_ops, NULL, &resources);
+		pci_create_root_bus(&dev->dev, 0, cfg_ops, NULL, &resources);
 	if (!lba_bus) {
 		pci_free_resource_list(&resources);
 		return 0;
diff --git a/drivers/pci/host/pci-mvebu.c b/drivers/pci/host/pci-mvebu.c
index bc4c6c0..c91a8b4 100644
--- a/drivers/pci/host/pci-mvebu.c
+++ b/drivers/pci/host/pci-mvebu.c
@@ -756,7 +756,7 @@ static struct pci_bus *mvebu_pcie_scan_bus(int nr, struct pci_sys_data *sys)
 	struct mvebu_pcie *pcie = sys_to_pcie(sys);
 	struct pci_bus *bus;
 
-	bus = pci_create_root_bus(&pcie->pdev->dev, -1, sys->busnr,
+	bus = pci_create_root_bus(&pcie->pdev->dev, -1,
 				  &mvebu_pcie_ops, sys, &sys->resources);
 	if (!bus)
 		return NULL;
diff --git a/drivers/pci/host/pci-tegra.c b/drivers/pci/host/pci-tegra.c
index 94e9362..3e45142 100644
--- a/drivers/pci/host/pci-tegra.c
+++ b/drivers/pci/host/pci-tegra.c
@@ -635,7 +635,7 @@ static struct pci_bus *tegra_pcie_scan_bus(int nr, struct pci_sys_data *sys)
 	struct tegra_pcie *pcie = sys_to_pcie(sys);
 	struct pci_bus *bus;
 
-	bus = pci_create_root_bus(pcie->dev, -1, sys->busnr, &tegra_pcie_ops,
+	bus = pci_create_root_bus(pcie->dev, -1, &tegra_pcie_ops,
 			sys, &sys->resources);
 	if (!bus)
 		return NULL;
diff --git a/drivers/pci/host/pci-xgene.c b/drivers/pci/host/pci-xgene.c
index c048e03..f11e77b 100644
--- a/drivers/pci/host/pci-xgene.c
+++ b/drivers/pci/host/pci-xgene.c
@@ -499,7 +499,7 @@ static int xgene_pcie_probe_bridge(struct platform_device *pdev)
 	if (ret)
 		return ret;
 
-	bus = pci_create_root_bus(&pdev->dev, -1, 0,
+	bus = pci_create_root_bus(&pdev->dev, -1,
 					&xgene_pcie_ops, port, &res);
 	if (!bus)
 		return -ENOMEM;
diff --git a/drivers/pci/host/pcie-designware.c b/drivers/pci/host/pcie-designware.c
index 93778b9..8854d25 100644
--- a/drivers/pci/host/pcie-designware.c
+++ b/drivers/pci/host/pcie-designware.c
@@ -728,8 +728,8 @@ static struct pci_bus *dw_pcie_scan_bus(int nr, struct pci_sys_data *sys)
 	struct pcie_port *pp = sys_to_pcie(sys);
 
 	pp->root_bus_nr = sys->busnr;
-	bus = pci_create_root_bus(pp->dev, -1, sys->busnr,
-				  &dw_pcie_ops, sys, &sys->resources);
+	bus = pci_create_root_bus(pp->dev, -1, &dw_pcie_ops, sys,
+			&sys->resources);
 	if (!bus)
 		return NULL;
 
diff --git a/drivers/pci/probe.c b/drivers/pci/probe.c
index 9f9445e..52b9257 100644
--- a/drivers/pci/probe.c
+++ b/drivers/pci/probe.c
@@ -59,6 +59,17 @@ static struct resource *get_pci_domain_busn_res(int domain_nr)
 	return &r->res;
 }
 
+static struct resource_entry *pci_busn_resource(
+		struct list_head *resources)
+{
+	struct resource_entry *entry;
+
+	resource_list_for_each_entry(entry, resources)
+		if (entry->res->flags & IORESOURCE_BUS)
+			return entry;
+	return NULL;
+}
+
 static int find_anything(struct device *dev, void *data)
 {
 	return 1;
@@ -1892,18 +1903,21 @@ void __weak pcibios_remove_bus(struct pci_bus *bus)
 }
 
 struct pci_bus *pci_create_root_bus(struct device *parent, int domain,
-		int bus, struct pci_ops *ops, void *sysdata,
-		struct list_head *resources)
+		struct pci_ops *ops, void *sysdata, struct list_head *resources)
 {
-	int error;
+	int error, bus;
 	struct pci_host_bridge *bridge;
 	struct pci_bus *b, *b2;
-	struct resource_entry *window, *n;
+	struct resource_entry *window, *n, *busn_res;
 	struct resource *res;
 	resource_size_t offset;
 	char bus_addr[64];
 	char *fmt;
 
+	busn_res = pci_busn_resource(resources);
+	if (!busn_res)
+		return NULL;
+	bus = busn_res->res->start;
 	b = pci_alloc_bus(NULL);
 	if (!b)
 		return NULL;
@@ -2077,7 +2091,7 @@ struct pci_bus *pci_scan_root_bus(struct device *parent, int domain,
 			break;
 		}
 
-	b = pci_create_root_bus(parent, domain, bus, ops,
+	b = pci_create_root_bus(parent, domain, ops,
 			sysdata, resources);
 	if (!b)
 		return NULL;
@@ -2107,7 +2121,7 @@ struct pci_bus *pci_scan_bus(int domain, int bus,
 	pci_add_resource(&resources, &ioport_resource);
 	pci_add_resource(&resources, &iomem_resource);
 	pci_add_resource(&resources, &busn_resource);
-	b = pci_create_root_bus(NULL, domain, bus, ops, sysdata,
+	b = pci_create_root_bus(NULL, domain, ops, sysdata,
 			&resources);
 	if (b) {
 		pci_scan_child_bus(b);
diff --git a/include/linux/pci.h b/include/linux/pci.h
index 0bdc639..df77a62 100644
--- a/include/linux/pci.h
+++ b/include/linux/pci.h
@@ -776,7 +776,7 @@ struct pci_bus *pci_find_bus(int domain, int busnr);
 void pci_bus_add_devices(const struct pci_bus *bus);
 struct pci_bus *pci_scan_bus(int domain, int bus, struct pci_ops *ops,
 					void *sysdata);
-struct pci_bus *pci_create_root_bus(struct device *parent, int domain, int bus,
+struct pci_bus *pci_create_root_bus(struct device *parent, int domain,
 				    struct pci_ops *ops, void *sysdata,
 				    struct list_head *resources);
 int pci_bus_insert_busn_res(struct pci_bus *b, int bus, int busmax);
-- 
1.7.1

