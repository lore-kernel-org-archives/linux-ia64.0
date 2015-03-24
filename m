From: Yijing Wang <wangyijing@huawei.com>
Date: Tue, 24 Mar 2015 03:34:15 +0000
Subject: [PATCH v8 21/30] sparc/PCI: Use pci_scan_host_bridge() for simplicity
Message-Id: <1427168064-8657-22-git-send-email-wangyijing@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1427168064-8657-1-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1427168064-8657-1-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, linux-pci@vger.kernel.org, Yinghai Lu <yinghai@kernel.org>, linux-kernel@vger.kernel.org, Marc Zyngier <marc.zyngier@arm.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rusty Russell <rusty@rustcorp.com.au>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-alpha@vger.kernel.org, linux-m68k@vger.kernel.org, Liviu Dudau <liviu@dudau.co.uk>, Arnd Bergmann <arnd@arndb.de>, Geert Uytterhoeven <geert@linux-m68k.org>, Yijing Wang <wangyijing@huawei.com>, sparclinux@vger.kernel.org

Now we could use pci_scan_host_bridge() to scan
pci buses, provide sparc specific pci_host_bridge_ops.

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
CC: "David S. Miller" <davem@davemloft.net>
CC: sparclinux@vger.kernel.org
---
 arch/sparc/kernel/pci.c |   28 ++++++++++++++++++++++------
 1 files changed, 22 insertions(+), 6 deletions(-)

diff --git a/arch/sparc/kernel/pci.c b/arch/sparc/kernel/pci.c
index e40e456..fa95a1d 100644
--- a/arch/sparc/kernel/pci.c
+++ b/arch/sparc/kernel/pci.c
@@ -650,12 +650,27 @@ static void pci_claim_bus_resources(struct pci_bus *bus)
 		pci_claim_bus_resources(child_bus);
 }
 
+static int pci_host_of_scan_bus(
+		struct pci_host_bridge *host)
+{
+	struct pci_pbm_info *pbm = dev_get_drvdata(&host->dev);
+	struct device_node *node = pbm->op->dev.of_node;
+
+	pci_of_scan_bus(pbm, node, host->bus);
+	return pci_bus_child_max_busnr(host->bus);
+}
+
+static struct pci_host_bridge_ops pci_host_ops = {
+	.scan_bus = pci_host_of_scan_bus,
+};
+
 struct pci_bus *pci_scan_one_pbm(struct pci_pbm_info *pbm,
 				 struct device *parent)
 {
 	LIST_HEAD(resources);
 	struct device_node *node = pbm->op->dev.of_node;
 	struct pci_bus *bus;
+	struct pci_host_bridge *host;
 
 	printk("PCI: Scanning PBM %s\n", node->full_name);
 
@@ -667,16 +682,17 @@ struct pci_bus *pci_scan_one_pbm(struct pci_pbm_info *pbm,
 	pbm->busn.end	= pbm->pci_last_busno;
 	pbm->busn.flags	= IORESOURCE_BUS;
 	pci_add_resource(&resources, &pbm->busn);
-	bus = pci_create_root_bus(parent, pbm->index, pbm->pci_first_busno,
-			pbm->pci_ops, pbm, &resources);
-	if (!bus) {
-		printk(KERN_ERR "Failed to create bus for %s\n",
-		       node->full_name);
+	pci_host_ops.pci_ops = pbm->pci_ops;
+	host = pci_scan_host_bridge(parent, pbm->index, pbm->pci_first_busno,
+			pbm, &resources, &pci_host_ops);
+	if (!host) {
+		pr_err("Failed to create host bridge pci%04x:%02x for %s\n",
+		       pbm->index, pbm->pci_first_busno, node->full_name);
 		pci_free_resource_list(&resources);
 		return NULL;
 	}
 
-	pci_of_scan_bus(pbm, node, bus);
+	bus = host->bus;
 	pci_bus_register_of_sysfs(bus);
 
 	pci_claim_bus_resources(bus);
-- 
1.7.1

