From: Yijing Wang <wangyijing@huawei.com>
Date: Mon, 17 Nov 2014 09:43:17 +0000
Subject: [RFC PATCH 13/16] ia64/PCI: Use pci_scan_host_bridge() to refactor pci_acpi_scan_root()
Message-Id: <1416219710-26088-14-git-send-email-wangyijing@huawei.com>
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
 arch/ia64/pci/pci.c |   84 +++++++++++++++++++++++---------------------------
 1 files changed, 39 insertions(+), 45 deletions(-)

diff --git a/arch/ia64/pci/pci.c b/arch/ia64/pci/pci.c
index aac3220..c7d97ae 100644
--- a/arch/ia64/pci/pci.c
+++ b/arch/ia64/pci/pci.c
@@ -115,23 +115,10 @@ struct pci_ops pci_root_ops = {
 	.write = pci_write,
 };
 
-/* Called by ACPI when it finds a new root bus.  */
-
-static struct pci_controller *alloc_pci_controller(int seg)
-{
-	struct pci_controller *controller;
-
-	controller = kzalloc(sizeof(*controller), GFP_KERNEL);
-	if (!controller)
-		return NULL;
-
-	controller->segment = seg;
-	return controller;
-}
-
 struct pci_root_info {
 	struct acpi_device *bridge;
-	struct pci_controller *controller;
+	struct pci_controller controller;
+	struct acpi_pci_root *root;
 	struct list_head resources;
 	struct resource *res;
 	resource_size_t *res_offset;
@@ -340,8 +327,6 @@ static void free_pci_root_info_res(struct pci_root_info *info)
 	kfree(info->res_offset);
 	info->res_offset = NULL;
 	info->res_num = 0;
-	kfree(info->controller);
-	info->controller = NULL;
 }
 
 static void __release_pci_root_info(struct pci_root_info *info)
@@ -395,7 +380,7 @@ probe_pci_root_info(struct pci_root_info *info, struct acpi_device *device,
 	if (info->res_num) {
 		info->res  			kzalloc_node(sizeof(*info->res) * info->res_num,
-				     GFP_KERNEL, info->controller->node);
+				     GFP_KERNEL, info->controller.node);
 		if (!info->res) {
 			kfree(name);
 			return -ENOMEM;
@@ -403,7 +388,7 @@ probe_pci_root_info(struct pci_root_info *info, struct acpi_device *device,
 
 		info->res_offset  			kzalloc_node(sizeof(*info->res_offset) * info->res_num,
-					GFP_KERNEL, info->controller->node);
+					GFP_KERNEL, info->controller.node);
 		if (!info->res_offset) {
 			kfree(name);
 			kfree(info->res);
@@ -420,6 +405,27 @@ probe_pci_root_info(struct pci_root_info *info, struct acpi_device *device,
 	return 0;
 }
 
+static int pci_acpi_init_res(struct pci_host_bridge *host,
+		struct pci_host_info *info)
+{
+	int ret;
+	struct pci_host_bridge_window *window, *n;
+	struct pci_controller *ctrl = info->arg;
+	struct pci_root_info *arg = container_of(ctrl,
+			struct pci_root_info, controller);
+
+	ret = probe_pci_root_info(arg, arg->root->device, 
+			host->busnum, host->domain);
+	if (ret) 
+		return -1;
+	list_for_each_entry_safe(window, n, &arg->resources,
+			list)
+		list_move_tail(&window->list, &host->windows);
+	/* insert busn resource at first */
+	pci_add_resource(&host->windows, &arg->root->secondary);
+	return 0;
+}
+
 struct pci_bus *pci_acpi_scan_root(struct acpi_pci_root *root)
 {
 	struct acpi_device *device = root->device;
@@ -427,55 +433,43 @@ struct pci_bus *pci_acpi_scan_root(struct acpi_pci_root *root)
 	struct pci_controller *controller;
 	struct pci_root_info *info = NULL;
 	int busnum = root->secondary.start;
-	struct pci_bus *pbus;
-	int ret;
-
-	controller = alloc_pci_controller(domain);
-	if (!controller)
-		return NULL;
-
-	controller->companion = device;
-	controller->node = acpi_get_node(device->handle);
+	struct pci_host_bridge *host;
+	struct pci_host_info arg;
 
 	info = kzalloc(sizeof(*info), GFP_KERNEL);
 	if (!info) {
 		dev_err(&device->dev,
 				"pci_bus %04x:%02x: ignored (out of memory)\n",
 				domain, busnum);
-		kfree(controller);
 		return NULL;
 	}
 
-	info->controller = controller;
+	controller = &info->controller;
+	controller->segment = domain;
+	controller->companion = device;
+	controller->node = acpi_get_node(device->handle);
 	INIT_LIST_HEAD(&info->io_resources);
 	INIT_LIST_HEAD(&info->resources);
+	init_pci_host_info(&arg);
+	arg.arg = controller;
+	arg.init_res = pci_acpi_init_res;
 
-	ret = probe_pci_root_info(info, device, busnum, domain);
-	if (ret) {
-		kfree(info->controller);
-		kfree(info);
-		return NULL;
-	}
-	/* insert busn resource at first */
-	pci_add_resource(&info->resources, &root->secondary);
 	/*
 	 * See arch/x86/pci/acpi.c.
 	 * The desired pci bus might already be scanned in a quirk. We
 	 * should handle the case here, but it appears that IA64 hasn't
 	 * such quirk. So we just ignore the case now.
 	 */
-	pbus = pci_create_root_bus(NULL, busnum, &pci_root_ops, controller,
-				   &info->resources);
-	if (!pbus) {
-		pci_free_resource_list(&info->resources);
+	host = pci_scan_host_bridge(NULL, PCI_DOMBUS(domain, busnum), 
+			&pci_root_ops, &arg);
+	if (!host) {
 		__release_pci_root_info(info);
 		return NULL;
 	}
 
-	pci_set_host_bridge_release(to_pci_host_bridge(pbus->bridge),
+	pci_set_host_bridge_release(host,
 			release_pci_root_info, info);
-	pci_scan_child_bus(pbus);
-	return pbus;
+	return host->bus;
 }
 
 int pcibios_root_bridge_prepare(struct pci_host_bridge *bridge)
-- 
1.7.1

