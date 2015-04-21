From: Yijing Wang <wangyijing@huawei.com>
Date: Tue, 21 Apr 2015 11:34:37 +0000
Subject: [PATCH v10 18/29] ia64/PCI: Refine pci_acpi_scan_root() with generic pci_host_bridge
Message-Id: <1429616088-10249-19-git-send-email-wangyijing@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1429616088-10249-1-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1429616088-10249-1-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, linux-pci@vger.kernel.org, Yinghai Lu <yinghai@kernel.org>, linux-kernel@vger.kernel.org, Marc Zyngier <marc.zyngier@arm.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, dja@axtens.net, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rusty Russell <rusty@rustcorp.com.au>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-alpha@vger.kernel.org, linux-m68k@vger.kernel.org, Liviu Dudau <liviu@dudau.co.uk>, Arnd Bergmann <arnd@arndb.de>, Geert Uytterhoeven <geert@linux-m68k.org>, Yijing Wang <wangyijing@huawei.com>, Yijing Wang <wangyijing0307@gmail.com>, Fenghua Yu <fenghua.yu@intel.com>

From: Yijing Wang <wangyijing0307@gmail.com>

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
CC: Tony Luck <tony.luck@intel.com>
CC: Fenghua Yu <fenghua.yu@intel.com>
CC: linux-ia64@vger.kernel.org
---
 arch/ia64/pci/pci.c |   34 +++++++++++++++++++---------------
 1 files changed, 19 insertions(+), 15 deletions(-)

diff --git a/arch/ia64/pci/pci.c b/arch/ia64/pci/pci.c
index 84f1eb8..7f3b9fb 100644
--- a/arch/ia64/pci/pci.c
+++ b/arch/ia64/pci/pci.c
@@ -420,6 +420,19 @@ probe_pci_root_info(struct pci_root_info *info, struct acpi_device *device,
 	return 0;
 }
 
+static int pci_host_bridge_prepare(struct pci_host_bridge *bridge)
+{
+	struct pci_controller *controller = bridge->bus->sysdata;
+
+	ACPI_COMPANION_SET(&bridge->dev, controller->companion);
+	return 0;
+}
+
+static struct pci_host_bridge_ops pci_host_ops = {
+	.pci_ops = &pci_root_ops,
+	.prepare = pci_host_bridge_prepare,
+};
+
 struct pci_bus *pci_acpi_scan_root(struct acpi_pci_root *root)
 {
 	struct acpi_device *device = root->device;
@@ -427,7 +440,7 @@ struct pci_bus *pci_acpi_scan_root(struct acpi_pci_root *root)
 	struct pci_controller *controller;
 	struct pci_root_info *info = NULL;
 	int busnum = root->secondary.start;
-	struct pci_bus *pbus;
+	struct pci_host_bridge *host;
 	int ret;
 
 	controller = alloc_pci_controller(domain);
@@ -464,26 +477,17 @@ struct pci_bus *pci_acpi_scan_root(struct acpi_pci_root *root)
 	 * should handle the case here, but it appears that IA64 hasn't
 	 * such quirk. So we just ignore the case now.
 	 */
-	pbus = pci_create_root_bus(NULL, domain, &pci_root_ops,
-			controller, &info->resources);
-	if (!pbus) {
+	host = pci_scan_host_bridge(NULL, domain, controller,
+			&info->resources, &pci_host_ops);
+	if (!host) {
 		pci_free_resource_list(&info->resources);
 		__release_pci_root_info(info);
 		return NULL;
 	}
 
-	pci_set_host_bridge_release(to_pci_host_bridge(pbus->bridge),
+	pci_set_host_bridge_release(host,
 			release_pci_root_info, info);
-	pci_scan_child_bus(pbus);
-	return pbus;
-}
-
-int pcibios_root_bridge_prepare(struct pci_host_bridge *bridge)
-{
-	struct pci_controller *controller = bridge->bus->sysdata;
-
-	ACPI_COMPANION_SET(&bridge->dev, controller->companion);
-	return 0;
+	return host->bus;
 }
 
 void pcibios_fixup_device_resources(struct pci_dev *dev)
-- 
1.7.1

