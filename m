From: Yijing Wang <wangyijing@huawei.com>
Date: Mon, 17 Nov 2014 09:42:55 +0000
Subject: [RFC PATCH 16/16] powerpc/PCI: Use pci_scan_host_bridge() to scan PCI bus
Message-Id: <1416219710-26088-17-git-send-email-wangyijing@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1416219710-26088-1-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1416219710-26088-1-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org, Xinwei Hu <huxinwei@huawei.com>, Wuyun <wuyun.wu@huawei.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linuxppc-dev@lists.ozlabs.org, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, Thierry Reding <thierry.reding@gmail.com>, Liviu Dudau <liviu@dudau.co.uk>, Suravee.Suthikulpanit@amd.com, Yijing Wang <wangyijing@huawei.com>

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
---
 arch/powerpc/kernel/pci-common.c |   81 ++++++++++++++++++++++---------------
 1 files changed, 48 insertions(+), 33 deletions(-)

diff --git a/arch/powerpc/kernel/pci-common.c b/arch/powerpc/kernel/pci-common.c
index e5dad9a..5b0f078 100644
--- a/arch/powerpc/kernel/pci-common.c
+++ b/arch/powerpc/kernel/pci-common.c
@@ -1578,54 +1578,69 @@ struct device_node *pcibios_get_phb_of_node(struct pci_bus *bus)
 	return of_node_get(hose->dn);
 }
 
-/**
- * pci_scan_phb - Given a pci_controller, setup and scan the PCI bus
- * @hose: Pointer to the PCI host controller instance structure
- */
-void pcibios_scan_phb(struct pci_controller *hose)
+static int pcibios_host_init_res(struct pci_host_bridge *host,
+		struct pci_host_info *info)
 {
-	LIST_HEAD(resources);
-	struct pci_bus *bus;
-	struct device_node *node = hose->dn;
-	int mode;
-
-	pr_debug("PCI: Scanning PHB %s\n", of_node_full_name(node));
+	struct pci_controller *hose = info->arg;
 
 	/* Get some IO space for the new PHB */
 	pcibios_setup_phb_io_space(hose);
-
 	/* Wire up PHB bus resources */
-	pcibios_setup_phb_resources(hose, &resources);
+	pcibios_setup_phb_resources(hose, &host->windows);
 
 	hose->busn.start = hose->first_busno;
 	hose->busn.end	 = hose->last_busno;
 	hose->busn.flags = IORESOURCE_BUS;
-	pci_add_resource(&resources, &hose->busn);
+	pci_add_resource(&host->windows, &hose->busn);
+	return 0;
+}
 
-	/* Create an empty bus for the toplevel */
-	bus = pci_create_root_bus(hose->parent, hose->first_busno,
-				  hose->ops, hose, &resources);
-	if (bus = NULL) {
-		pr_err("Failed to create bus for PCI domain %04x\n",
-			hose->global_number);
-		pci_free_resource_list(&resources);
-		return;
-	}
-	hose->bus = bus;
+static void pcibios_of_scan_bus(struct pci_host_bridge *host)
+{
+	int mode;
+	int max;
 
 	/* Get probe mode and perform scan */
 	mode = PCI_PROBE_NORMAL;
-	if (node && ppc_md.pci_probe_mode)
-		mode = ppc_md.pci_probe_mode(bus);
+	if (host->node && ppc_md.pci_probe_mode)
+		mode = ppc_md.pci_probe_mode(host->bus);
 	pr_debug("    probe mode: %d\n", mode);
 	if (mode = PCI_PROBE_DEVTREE)
-		of_scan_bus(node, bus);
-
+		of_scan_bus(host->node, host->bus);
+	
 	if (mode = PCI_PROBE_NORMAL) {
-		pci_bus_update_busn_res_end(bus, 255);
-		hose->last_busno = pci_scan_child_bus(bus);
-		pci_bus_update_busn_res_end(bus, hose->last_busno);
+		pci_bus_update_busn_res_end(host->bus, 255);
+		max = pci_scan_child_bus(host->bus);
+		pci_bus_update_busn_res_end(host->bus, max);
+	}
+}
+/**
+ * pci_scan_phb - Given a pci_controller, setup and scan the PCI bus
+ * @hose: Pointer to the PCI host controller instance structure
+ */
+void pcibios_scan_phb(struct pci_controller *hose)
+{
+	struct pci_host_bridge *host;
+	struct pci_host_info info;
+
+	pr_debug("PCI: Scanning PHB %s\n", of_node_full_name(hose->dn));
+
+	init_pci_host_info(&info);
+	info.arg = hose;
+	info.node = hose->dn;
+	info.init_res = pcibios_host_init_res;
+	info.of_scan_bus = pcibios_of_scan_bus;
+	/* Create an empty bus for the toplevel */
+	host = pci_scan_host_bridge(hose->parent, 
+			PCI_DOMBUS(hose->global_number,hose->first_busno),
+				  hose->ops, &info);
+	if (host = NULL) {
+		pr_err("Failed to create bus for PCI domain %04x\n",
+			hose->global_number);
+		return;
 	}
+	hose->bus = host->bus;
+	hose->last_busno = host->bus->busn_res.end;
 
 	/* Platform gets a chance to do some global fixups before
 	 * we proceed to resource allocation
@@ -1634,9 +1649,9 @@ void pcibios_scan_phb(struct pci_controller *hose)
 		ppc_md.pcibios_fixup_phb(hose);
 
 	/* Configure PCI Express settings */
-	if (bus && !pci_has_flag(PCI_PROBE_ONLY)) {
+	if (!pci_has_flag(PCI_PROBE_ONLY)) {
 		struct pci_bus *child;
-		list_for_each_entry(child, &bus->children, node)
+		list_for_each_entry(child, &host->bus->children, node)
 			pcie_bus_configure_settings(child);
 	}
 }
-- 
1.7.1

