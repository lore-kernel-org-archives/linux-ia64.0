From: Yijing Wang <wangyijing@huawei.com>
Date: Fri, 06 Mar 2015 09:33:36 +0000
Subject: [PATCH v5 19/29] sparc/PCI: Use pci_scan_host_bridge() for simplicity
Message-Id: <1425634426-437-20-git-send-email-wangyijing@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1425634426-437-1-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1425634426-437-1-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, linux-pci@vger.kernel.org, Yinghai Lu <yinghai@kernel.org>, linux-kernel@vger.kernel.org, Marc Zyngier <marc.zyngier@arm.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rusty Russell <rusty@rustcorp.com.au>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-alpha@vger.kernel.org, linux-m68k@vger.kernel.org, Liviu Dudau <liviu@dudau.co.uk>, Arnd Bergmann <arnd@arndb.de>, Geert Uytterhoeven <geert@linux-m68k.org>, Yijing Wang <wangyijing@huawei.com>, sparclinux@vger.kernel.org, Bjorn Helgaas <bhelgaas@google.com>

Now we could use pci_scan_host_bridge() to scan
pci buses, provide sparc specific pci_host_bridge_ops.

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
CC: "David S. Miller" <davem@davemloft.net>
CC: sparclinux@vger.kernel.org
Signed-off-by: Bjorn Helgaas <bhelgaas@google.com>
---
 arch/sparc/kernel/pci.c |   32 ++++++++++++++++++++++----------
 1 files changed, 22 insertions(+), 10 deletions(-)

diff --git a/arch/sparc/kernel/pci.c b/arch/sparc/kernel/pci.c
index 21f804a..7e28f74 100644
--- a/arch/sparc/kernel/pci.c
+++ b/arch/sparc/kernel/pci.c
@@ -650,12 +650,25 @@ static void pci_claim_bus_resources(struct pci_bus *bus)
 		pci_claim_bus_resources(child_bus);
 }
 
+static void pci_host_bridge_of_scan_bus(
+		struct pci_host_bridge *host)
+{
+	struct pci_pbm_info *pbm = dev_get_drvdata(&host->dev);
+	struct device_node *node = pbm->op->dev.of_node;
+
+	pci_of_scan_bus(pbm, node, host->bus);
+}
+
+static struct pci_host_bridge_ops phb_ops = {
+	.scan_bus = pci_host_bridge_of_scan_bus,
+};
+
 struct pci_bus *pci_scan_one_pbm(struct pci_pbm_info *pbm,
 				 struct device *parent)
 {
 	LIST_HEAD(resources);
 	struct device_node *node = pbm->op->dev.of_node;
-	struct pci_bus *bus;
+	struct pci_host_bridge *host;
 
 	printk("PCI: Scanning PBM %s\n", node->full_name);
 
@@ -667,22 +680,21 @@ struct pci_bus *pci_scan_one_pbm(struct pci_pbm_info *pbm,
 	pbm->busn.end	= pbm->pci_last_busno;
 	pbm->busn.flags	= IORESOURCE_BUS;
 	pci_add_resource(&resources, &pbm->busn);
-	bus = pci_create_root_bus(parent,
+	host = pci_scan_host_bridge(parent,
 			PCI_DOMBUS(pbm->index, pbm->pci_first_busno),
-			pbm->pci_ops, pbm, &resources);
-	if (!bus) {
-		printk(KERN_ERR "Failed to create bus for %s\n",
+			pbm->pci_ops, pbm, &resources, &phb_ops);
+	if (!host) {
+		printk(KERN_ERR "Failed to create host bridge for %s\n",
 		       node->full_name);
 		pci_free_resource_list(&resources);
 		return NULL;
 	}
 
-	pci_of_scan_bus(pbm, node, bus);
-	pci_bus_register_of_sysfs(bus);
+	pci_bus_register_of_sysfs(host->bus);
 
-	pci_claim_bus_resources(bus);
-	pci_bus_add_devices(bus);
-	return bus;
+	pci_claim_bus_resources(host->bus);
+	pci_bus_add_devices(host->bus);
+	return host->bus;
 }
 
 void pcibios_fixup_bus(struct pci_bus *pbus)
-- 
1.7.1

