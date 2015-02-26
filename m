From: Yijing Wang <wangyijing@huawei.com>
Date: Thu, 26 Feb 2015 01:29:35 +0000
Subject: [PATCH v3 18/30] PCI/powerpc: Use pci_scan_root_bridge() for simplicity
Message-Id: <1424914187-21027-19-git-send-email-wangyijing@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1424914187-21027-1-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1424914187-21027-1-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, linux-pci@vger.kernel.org, Yinghai Lu <yinghai@kernel.org>, linux-kernel@vger.kernel.org, Marc Zyngier <marc.zyngier@arm.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rusty Russell <rusty@rustcorp.com.au>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-alpha@vger.kernel.org, linux-m68k@vger.kernel.org, Liviu Dudau <liviu@dudau.co.uk>, Arnd Bergmann <arnd@arndb.de>, Geert Uytterhoeven <geert@linux-m68k.org>, Yijing Wang <wangyijing@huawei.com>, linuxppc-dev@lists.ozlabs.org

Now we could use pci_scan_root_bridge() to scan
pci buses, provide powerpc specific pci_host_bridge_ops.

Suggested-by: Arnd Bergmann <arnd@arndb.de>
Signed-off-by: Yijing Wang <wangyijing@huawei.com>
CC: Benjamin Herrenschmidt <benh@kernel.crashing.org>
CC: linuxppc-dev@lists.ozlabs.org
---
 arch/powerpc/include/asm/machdep.h       |    2 +-
 arch/powerpc/kernel/pci-common.c         |   63 +++++++++++++++++-------------
 arch/powerpc/platforms/pseries/pci.c     |    8 ++--
 arch/powerpc/platforms/pseries/pseries.h |    2 +-
 4 files changed, 42 insertions(+), 33 deletions(-)

diff --git a/arch/powerpc/include/asm/machdep.h b/arch/powerpc/include/asm/machdep.h
index 8e7f2a8..b811d12 100644
--- a/arch/powerpc/include/asm/machdep.h
+++ b/arch/powerpc/include/asm/machdep.h
@@ -129,7 +129,7 @@ struct machdep_calls {
 	void		(*pcibios_fixup)(void);
 	int		(*pci_probe_mode)(struct pci_bus *);
 	void		(*pci_irq_fixup)(struct pci_dev *dev);
-	int		(*pcibios_set_root_bus_speed)(struct pci_host_bridge
+	void		(*pcibios_set_root_bus_speed)(struct pci_host_bridge
 				*bridge);
 
 	/* To setup PHBs when using automatic OF platform driver for PCI */
diff --git a/arch/powerpc/kernel/pci-common.c b/arch/powerpc/kernel/pci-common.c
index 4401b6a..48a6cff 100644
--- a/arch/powerpc/kernel/pci-common.c
+++ b/arch/powerpc/kernel/pci-common.c
@@ -767,14 +767,33 @@ int pci_proc_domain(struct pci_bus *bus)
 	return 1;
 }
 
-int pcibios_root_bridge_prepare(struct pci_host_bridge *bridge)
+static void pci_host_bridge_set_root_bus_speed(
+		struct pci_host_bridge *bridge)
 {
 	if (ppc_md.pcibios_set_root_bus_speed)
-		return ppc_md.pcibios_set_root_bus_speed(bridge);
-	
-	return 0;
+		ppc_md.pcibios_set_root_bus_speed(bridge);
 }
 
+static void pci_host_bridge_of_scan_bus(struct pci_host_bridge *host)
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
+		of_scan_bus(hose->dn, bus);
+
+	if (mode = PCI_PROBE_NORMAL) {
+		pci_bus_update_busn_res_end(bus, 255);
+		hose->last_busno = pci_scan_child_bus(bus);
+		pci_bus_update_busn_res_end(bus, hose->last_busno);
+	}
+}
 /* This header fixup will do the resource fixup for all devices as they are
  * probed, but not for bridge ranges
  */
@@ -1587,6 +1606,11 @@ struct device_node *pcibios_get_phb_of_node(struct pci_bus *bus)
 	return of_node_get(hose->dn);
 }
 
+static struct pci_host_bridge_ops phb_ops = {
+	.phb_set_root_bus_speed = pci_host_bridge_set_root_bus_speed,
+	.phb_of_scan_bus = pci_host_bridge_of_scan_bus,
+};
+
 /**
  * pci_scan_phb - Given a pci_controller, setup and scan the PCI bus
  * @hose: Pointer to the PCI host controller instance structure
@@ -1594,9 +1618,8 @@ struct device_node *pcibios_get_phb_of_node(struct pci_bus *bus)
 void pcibios_scan_phb(struct pci_controller *hose)
 {
 	LIST_HEAD(resources);
-	struct pci_bus *bus;
+	struct pci_host_bridge *host;
 	struct device_node *node = hose->dn;
-	int mode;
 
 	pr_debug("PCI: Scanning PHB %s\n", of_node_full_name(node));
 
@@ -1612,30 +1635,16 @@ void pcibios_scan_phb(struct pci_controller *hose)
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
 
 	/* Platform gets a chance to do some global fixups before
 	 * we proceed to resource allocation
@@ -1644,9 +1653,9 @@ void pcibios_scan_phb(struct pci_controller *hose)
 		ppc_md.pcibios_fixup_phb(hose);
 
 	/* Configure PCI Express settings */
-	if (bus && !pci_has_flag(PCI_PROBE_ONLY)) {
+	if (host->bus && !pci_has_flag(PCI_PROBE_ONLY)) {
 		struct pci_bus *child;
-		list_for_each_entry(child, &bus->children, node)
+		list_for_each_entry(child, &host->bus->children, node)
 			pcie_bus_configure_settings(child);
 	}
 }
diff --git a/arch/powerpc/platforms/pseries/pci.c b/arch/powerpc/platforms/pseries/pci.c
index af685d6..89ff79c 100644
--- a/arch/powerpc/platforms/pseries/pci.c
+++ b/arch/powerpc/platforms/pseries/pci.c
@@ -110,7 +110,7 @@ static void fixup_winbond_82c105(struct pci_dev* dev)
 DECLARE_PCI_FIXUP_HEADER(PCI_VENDOR_ID_WINBOND, PCI_DEVICE_ID_WINBOND_82C105,
 			 fixup_winbond_82c105);
 
-int pseries_set_root_bus_speed(struct pci_host_bridge *bridge)
+void pseries_set_root_bus_speed(struct pci_host_bridge *bridge)
 {
 	struct device_node *dn, *pdn;
 	struct pci_bus *bus;
@@ -121,7 +121,7 @@ int pseries_set_root_bus_speed(struct pci_host_bridge *bridge)
 
 	dn = pcibios_get_phb_of_node(bus);
 	if (!dn)
-		return 0;
+		return;
 
 	for (pdn = dn; pdn != NULL; pdn = of_get_next_parent(pdn)) {
 		rc = of_property_read_u32_array(pdn,
@@ -135,7 +135,7 @@ int pseries_set_root_bus_speed(struct pci_host_bridge *bridge)
 
 	if (rc) {
 		pr_debug("no ibm,pcie-link-speed-stats property\n");
-		return 0;
+		return;
 	}
 
 	switch (pcie_link_speed_stats[0]) {
@@ -168,5 +168,5 @@ int pseries_set_root_bus_speed(struct pci_host_bridge *bridge)
 		break;
 	}
 
-	return 0;
+	return;
 }
diff --git a/arch/powerpc/platforms/pseries/pseries.h b/arch/powerpc/platforms/pseries/pseries.h
index 5d0be3a..9aa9c13 100644
--- a/arch/powerpc/platforms/pseries/pseries.h
+++ b/arch/powerpc/platforms/pseries/pseries.h
@@ -63,7 +63,7 @@ extern int dlpar_detach_node(struct device_node *);
 
 /* PCI root bridge prepare function override for pseries */
 struct pci_host_bridge;
-int pseries_set_root_bus_speed(struct pci_host_bridge *bridge);
+void pseries_set_root_bus_speed(struct pci_host_bridge *bridge);
 
 unsigned long pseries_memory_block_size(void);
 
-- 
1.7.1

