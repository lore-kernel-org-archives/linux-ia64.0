From: Yijing Wang <wangyijing@huawei.com>
Date: Mon, 17 Nov 2014 09:45:55 +0000
Subject: [RFC PATCH 11/16] x86/PCI: Use pci_scan_host_bridge() instead of pci_create_root_bus()
Message-Id: <1416219710-26088-12-git-send-email-wangyijing@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1416219710-26088-1-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1416219710-26088-1-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org, Xinwei Hu <huxinwei@huawei.com>, Wuyun <wuyun.wu@huawei.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linuxppc-dev@lists.ozlabs.org, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, Thierry Reding <thierry.reding@gmail.com>, Liviu Dudau <liviu@dudau.co.uk>, Suravee.Suthikulpanit@amd.com, Yijing Wang <wangyijing@huawei.com>

Now we could use pci_scan_host_bridge() to refactor
pci_acpi_scan_root().

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
---
 arch/x86/pci/acpi.c   |   65 ++++++++++++++++++++++++++++++-------------------
 arch/x86/pci/common.c |   23 ++++++++++++-----
 2 files changed, 56 insertions(+), 32 deletions(-)

diff --git a/arch/x86/pci/acpi.c b/arch/x86/pci/acpi.c
index cfd1b13..528fca3 100644
--- a/arch/x86/pci/acpi.c
+++ b/arch/x86/pci/acpi.c
@@ -13,6 +13,7 @@ struct pci_root_info {
 	unsigned int res_num;
 	struct resource *res;
 	resource_size_t *res_offset;
+	struct acpi_pci_root *root;
 	struct pci_sysdata sd;
 #ifdef	CONFIG_PCI_MMCONFIG
 	bool mcfg_added;
@@ -467,16 +468,40 @@ static void probe_pci_root_info(struct pci_root_info *info,
 				info);
 }
 
+static int pci_acpi_init_res(struct pci_host_bridge *host,
+		struct pci_host_info *arg)
+{
+	struct pci_sysdata *sd = arg->arg;
+	struct pci_root_info *info = container_of(sd,
+			struct pci_root_info, sd);
+
+	/* insert busn res at first */
+	pci_add_resource(&host->windows,  &info->root->secondary);
+	/*
+	 * _CRS with no apertures is normal, so only fall back to
+	 * defaults or native bridge info if we're ignoring _CRS.
+	 */
+	if (pci_use_crs)
+		add_resources(info, &host->windows);
+	else {
+		free_pci_root_info_res(info);
+		x86_pci_root_bus_resources(host->busnum, &host->windows);
+	}
+	
+	return 0;
+}
+
 struct pci_bus *pci_acpi_scan_root(struct acpi_pci_root *root)
 {
 	struct acpi_device *device = root->device;
 	struct pci_root_info *info;
 	int domain = root->segment;
 	int busnum = root->secondary.start;
-	LIST_HEAD(resources);
 	struct pci_bus *bus;
 	struct pci_sysdata *sd;
 	int node;
+	struct pci_host_info arg;
+	struct pci_host_bridge *host;
 
 	if (pci_ignore_seg)
 		domain = 0;
@@ -506,10 +531,14 @@ struct pci_bus *pci_acpi_scan_root(struct acpi_pci_root *root)
 		return NULL;
 	}
 
+	info->root = root;
 	sd = &info->sd;
 	sd->domain = domain;
 	sd->node = node;
 	sd->companion = device;
+	init_pci_host_info(&arg);
+	arg.arg = sd;
+	arg.init_res = pci_acpi_init_res;
 
 	bus = pci_find_bus(domain, busnum);
 	if (bus) {
@@ -522,33 +551,19 @@ struct pci_bus *pci_acpi_scan_root(struct acpi_pci_root *root)
 	} else {
 		probe_pci_root_info(info, device, busnum, domain);
 
-		/* insert busn res at first */
-		pci_add_resource(&resources,  &root->secondary);
-		/*
-		 * _CRS with no apertures is normal, so only fall back to
-		 * defaults or native bridge info if we're ignoring _CRS.
-		 */
-		if (pci_use_crs)
-			add_resources(info, &resources);
-		else {
-			free_pci_root_info_res(info);
-			x86_pci_root_bus_resources(busnum, &resources);
+		if (!setup_mcfg_map(info, domain, (u8)root->secondary.start,
+				    (u8)root->secondary.end, root->mcfg_addr)) {
+			host = pci_scan_host_bridge(NULL, PCI_DOMBUS(domain, busnum), 
+					&pci_root_ops, &arg);
+			bus = host->bus;
 		}
 
-		if (!setup_mcfg_map(info, domain, (u8)root->secondary.start,
-				    (u8)root->secondary.end, root->mcfg_addr))
-			bus = pci_create_root_bus(NULL, busnum, &pci_root_ops,
-						  sd, &resources);
-
-		if (bus) {
-			pci_scan_child_bus(bus);
-			pci_set_host_bridge_release(
-				to_pci_host_bridge(bus->bridge),
+		if (bus) 
+			pci_set_host_bridge_release(host,
 				release_pci_root_info, info);
-		} else {
-			pci_free_resource_list(&resources);
+		else 
 			__release_pci_root_info(info);
-		}
+		
 	}
 
 	/* After the PCI-E bus has been walked and all devices discovered,
@@ -568,7 +583,7 @@ struct pci_bus *pci_acpi_scan_root(struct acpi_pci_root *root)
 
 int pcibios_root_bridge_prepare(struct pci_host_bridge *bridge)
 {
-	struct pci_sysdata *sd = bridge->bus->sysdata;
+	struct pci_sysdata *sd = bridge->sysdata;
 
 	ACPI_COMPANION_SET(&bridge->dev, sd->companion);
 	return 0;
diff --git a/arch/x86/pci/common.c b/arch/x86/pci/common.c
index b16632b..0032065 100644
--- a/arch/x86/pci/common.c
+++ b/arch/x86/pci/common.c
@@ -456,11 +456,18 @@ void __init dmi_check_pciprobe(void)
 	dmi_check_system(pciprobe_dmi_table);
 }
 
+static int pcibios_init_res(struct pci_host_bridge *host,
+		struct pci_host_info *info)
+{
+	x86_pci_root_bus_resources(host->busnum, &host->windows);
+	return 0;
+}
+
 void pcibios_scan_root(int busnum)
 {
-	struct pci_bus *bus;
 	struct pci_sysdata *sd;
-	LIST_HEAD(resources);
+	struct pci_host_info info;
+	struct pci_host_bridge *host;
 
 	sd = kzalloc(sizeof(*sd), GFP_KERNEL);
 	if (!sd) {
@@ -468,14 +475,16 @@ void pcibios_scan_root(int busnum)
 		return;
 	}
 	sd->node = x86_pci_root_bus_node(busnum);
-	x86_pci_root_bus_resources(busnum, &resources);
+	init_pci_host_info(&info);
+	info.init_res = pcibios_init_res;
+	info.arg = sd;
 	printk(KERN_DEBUG "PCI: Probing PCI hardware (bus %02x)\n", busnum);
-	bus = pci_scan_root_bus(NULL, busnum, &pci_root_ops, sd, &resources);
-	if (bus) {
-		pci_bus_add_devices(bus);
+	host = pci_scan_host_bridge(NULL, PCI_DOMBUS(0, busnum),
+		   	&pci_root_ops, &info);
+	if (host) {
+		pci_bus_add_devices(host->bus);
 		return;
 	} 
-	pci_free_resource_list(&resources);
 	kfree(sd);
 }
 
-- 
1.7.1

