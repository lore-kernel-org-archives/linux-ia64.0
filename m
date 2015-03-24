From: Yijing Wang <wangyijing@huawei.com>
Date: Tue, 24 Mar 2015 03:34:11 +0000
Subject: [PATCH v8 17/30] x86/PCI: Refine pci_acpi_scan_root() with generic pci_host_bridge
Message-Id: <1427168064-8657-18-git-send-email-wangyijing@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1427168064-8657-1-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1427168064-8657-1-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, linux-pci@vger.kernel.org, Yinghai Lu <yinghai@kernel.org>, linux-kernel@vger.kernel.org, Marc Zyngier <marc.zyngier@arm.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rusty Russell <rusty@rustcorp.com.au>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-alpha@vger.kernel.org, linux-m68k@vger.kernel.org, Liviu Dudau <liviu@dudau.co.uk>, Arnd Bergmann <arnd@arndb.de>, Geert Uytterhoeven <geert@linux-m68k.org>, Yijing Wang <wangyijing@huawei.com>

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
CC: Thomas Gleixner <tglx@linutronix.de>
CC: x86@kernel.org
---
 arch/x86/pci/acpi.c |   37 +++++++++++++++++++++----------------
 1 files changed, 21 insertions(+), 16 deletions(-)

diff --git a/arch/x86/pci/acpi.c b/arch/x86/pci/acpi.c
index d2655d5..877acaf 100644
--- a/arch/x86/pci/acpi.c
+++ b/arch/x86/pci/acpi.c
@@ -349,6 +349,19 @@ static void probe_pci_root_info(struct pci_root_info *info,
 			entry->res->name = info->name;
 }
 
+static int pci_host_bridge_prepare(struct pci_host_bridge *bridge)
+{
+	struct pci_sysdata *sd = dev_get_drvdata(&bridge->dev);
+
+	ACPI_COMPANION_SET(&bridge->dev, sd->companion);
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
@@ -359,6 +372,7 @@ struct pci_bus *pci_acpi_scan_root(struct acpi_pci_root *root)
 	LIST_HEAD(crs_res);
 	LIST_HEAD(resources);
 	struct pci_bus *bus;
+	struct pci_host_bridge *host = NULL;
 	struct pci_sysdata *sd;
 	int node;
 
@@ -425,14 +439,13 @@ struct pci_bus *pci_acpi_scan_root(struct acpi_pci_root *root)
 
 		if (!setup_mcfg_map(info, domain, (u8)root->secondary.start,
 				    (u8)root->secondary.end, root->mcfg_addr))
-			bus = pci_create_root_bus(NULL, domain, busnum,
-					&pci_root_ops, sd, &resources);
-
-		if (bus) {
-			pci_scan_child_bus(bus);
-			pci_set_host_bridge_release(
-				to_pci_host_bridge(bus->bridge),
-				release_pci_root_info, info);
+			host = pci_scan_host_bridge(NULL, domain, busnum, sd,
+					&resources, &pci_host_ops);
+
+		if (host) {
+			bus = host->bus;
+			pci_set_host_bridge_release(host,
+					release_pci_root_info, info);
 		} else {
 			resource_list_free(&resources);
 			teardown_mcfg_map(info);
@@ -455,14 +468,6 @@ struct pci_bus *pci_acpi_scan_root(struct acpi_pci_root *root)
 	return bus;
 }
 
-int pcibios_root_bridge_prepare(struct pci_host_bridge *bridge)
-{
-	struct pci_sysdata *sd = bridge->bus->sysdata;
-
-	ACPI_COMPANION_SET(&bridge->dev, sd->companion);
-	return 0;
-}
-
 int __init pci_acpi_init(void)
 {
 	struct pci_dev *dev = NULL;
-- 
1.7.1

