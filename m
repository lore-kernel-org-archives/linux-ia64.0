From: Yijing Wang <wangyijing@huawei.com>
Date: Fri, 16 Jan 2015 01:44:14 +0000
Subject: [PATCH 16/28] PCI/powerpc: Use pci_scan_root_bridge() for simplicity
Message-Id: <1421372666-12288-17-git-send-email-wangyijing@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1421372666-12288-1-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1421372666-12288-1-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, linux-pci@vger.kernel.org, Yinghai Lu <yinghai@kernel.org>, linux-kernel@vger.kernel.org, Marc Zyngier <marc.zyngier@arm.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-alpha@vger.kernel.org, linux-m68k@vger.kernel.org, Liviu Dudau <liviu@dudau.co.uk>, Arnd Bergmann <arnd@arndb.de>, Geert Uytterhoeven <geert@linux-m68k.org>, Yijing Wang <wangyijing@huawei.com>

Now we could use pci_scan_root_bridge() to scan
pci buses, provide powerpc specific pci_host_bridge_ops.

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
---
 arch/powerpc/kernel/pci-common.c |   57 ++++++++++++++++++++++++--------------
 1 files changed, 36 insertions(+), 21 deletions(-)

diff --git a/arch/powerpc/kernel/pci-common.c b/arch/powerpc/kernel/pci-common.c
index 2cf941e..0c7fb81 100644
--- a/arch/powerpc/kernel/pci-common.c
+++ b/arch/powerpc/kernel/pci-common.c
@@ -767,7 +767,8 @@ int pci_proc_domain(struct pci_bus *bus)
 	return 1;
 }
 
-int pcibios_root_bridge_prepare(struct pci_host_bridge *bridge)
+static int pci_host_bridge_set_root_bus_speed(
+		struct pci_host_bridge *bridge)
 {
 	if (ppc_md.pcibios_set_root_bus_speed)
 		return ppc_md.pcibios_set_root_bus_speed(bridge);
@@ -775,6 +776,27 @@ int pcibios_root_bridge_prepare(struct pci_host_bridge *bridge)
 	return 0;
 }
 
+static void pci_host_bridge_probe_mode(struct pci_host_bridge *host)
+{
+	int mode = PCI_PROBE_NORMAL;
+	struct pci_bus *bus = host->bus;
+	struct pci_controller *hose = dev_get_drvdata(&host->dev);
+
+	/* Get probe mode and perform scan */
+	if (hose->dn && ppc_md.pci_probe_mode)
+		mode = ppc_md.pci_probe_mode(bus);
+
+	pr_debug("    probe mode: %d\n", mode);
+	if (mode = PCI_PROBE_DEVTREE)
+		host->of_scan = true;
+}
+
+static void pci_host_bridge_of_scan_bus(struct pci_host_bridge *host)
+{
+	struct pci_controller *hose = dev_get_drvdata(&host->dev);
+
+	of_scan_bus(host->dn, bus);
+}
 /* This header fixup will do the resource fixup for all devices as they are
  * probed, but not for bridge ranges
  */
@@ -1577,6 +1599,12 @@ struct device_node *pcibios_get_phb_of_node(struct pci_bus *bus)
 	return of_node_get(hose->dn);
 }
 
+static struct pci_host_bridge_ops *phb_ops = {
+	.phb_set_root_bus_speed = pci_host_bridge_set_root_bus_speed,
+	.phb_probe_mode = pci_host_bridge_probe_mode,
+	.phb_of_scan_bus = pci_host_bridge_of_scan_bus,
+};
+
 /**
  * pci_scan_phb - Given a pci_controller, setup and scan the PCI bus
  * @hose: Pointer to the PCI host controller instance structure
@@ -1584,9 +1612,9 @@ struct device_node *pcibios_get_phb_of_node(struct pci_bus *bus)
 void pcibios_scan_phb(struct pci_controller *hose)
 {
 	LIST_HEAD(resources);
+	struct pci_host_bridge *host;
 	struct pci_bus *bus;
 	struct device_node *node = hose->dn;
-	int mode;
 
 	pr_debug("PCI: Scanning PHB %s\n", of_node_full_name(node));
 
@@ -1602,30 +1630,17 @@ void pcibios_scan_phb(struct pci_controller *hose)
 	pci_add_resource(&resources, &hose->busn);
 
 	/* Create an empty bus for the toplevel */
-	bus = pci_create_root_bus(hose->parent, 
+	host = pci_scan_root_bridge(hose->parent,
 			PCI_DOMBUS(hose->global_number, hose->first_busno),
-			hose->ops, hose, &resources);
-	if (bus = NULL) {
-		pr_err("Failed to create bus for PCI domain %04x\n",
+			hose->ops, hose, &resources, &phb_ops);
+	if (host = NULL) {
+		pr_err("Failed to create host bridge for PCI domain %04x\n",
 			hose->global_number);
 		pci_free_resource_list(&resources);
 		return;
 	}
-	hose->bus = bus;
-
-	/* Get probe mode and perform scan */
-	mode = PCI_PROBE_NORMAL;
-	if (node && ppc_md.pci_probe_mode)
-		mode = ppc_md.pci_probe_mode(bus);
-	pr_debug("    probe mode: %d\n", mode);
-	if (mode = PCI_PROBE_DEVTREE)
-		of_scan_bus(node, bus);
-
-	if (mode = PCI_PROBE_NORMAL) {
-		pci_bus_update_busn_res_end(bus, 255);
-		hose->last_busno = pci_scan_child_bus(bus);
-		pci_bus_update_busn_res_end(bus, hose->last_busno);
-	}
+	hose->bus = host->bus;
+	hose->last_busno = host->bus->busn_res.end;
 
 	/* Platform gets a chance to do some global fixups before
 	 * we proceed to resource allocation
-- 
1.7.1

