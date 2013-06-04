From: Yijing Wang <wangyijing@huawei.com>
Date: Tue, 04 Jun 2013 10:59:10 +0000
Subject: [PATCH -v3 4/8] PCI/IA64: Allocate pci_root_info instead of using stack
Message-Id: <1370343554-11812-5-git-send-email-wangyijing@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

We need to pass around info for release function.

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: Yinghai Lu <yinghai@kernel.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: linux-ia64@vger.kernel.org
---
 arch/ia64/pci/pci.c |   59 ++++++++++++++++++++++++++++++--------------------
 1 files changed, 35 insertions(+), 24 deletions(-)

diff --git a/arch/ia64/pci/pci.c b/arch/ia64/pci/pci.c
index a2f91b0..3a8b361 100644
--- a/arch/ia64/pci/pci.c
+++ b/arch/ia64/pci/pci.c
@@ -331,7 +331,8 @@ struct pci_bus *pci_acpi_scan_root(struct acpi_pci_root *root)
 	int domain = root->segment;
 	int bus = root->secondary.start;
 	struct pci_controller *controller;
-	struct pci_root_info info;
+	struct pci_root_info *info = NULL;
+	int busnum = root->secondary.start;
 	struct pci_bus *pbus;
 	char *name;
 	int pxm;
@@ -348,35 +349,42 @@ struct pci_bus *pci_acpi_scan_root(struct acpi_pci_root *root)
 		controller->node = pxm_to_node(pxm);
 #endif
 
-	INIT_LIST_HEAD(&info.resources);
+	info = kzalloc(sizeof(*info), GFP_KERNEL);
+	if (!info) {
+		printk(KERN_WARNING "pci_bus %04x:%02x: "
+				"ignored (out of memory)\n", root->segment, busnum);
+		goto out2;
+	}
+
+	INIT_LIST_HEAD(&info->resources);
 	/* insert busn resource at first */
-	pci_add_resource(&info.resources, &root->secondary);
+	pci_add_resource(&info->resources, &root->secondary);
 	acpi_walk_resources(device->handle, METHOD_NAME__CRS, count_window,
-			&info.res_num);
-	if (info.res_num) {
-		info.res -			kzalloc_node(sizeof(*info.res) * info.res_num,
+			&info->res_num);
+	if (info->res_num) {
+		info->res +			kzalloc_node(sizeof(*info->res) * info->res_num,
 				     GFP_KERNEL, controller->node);
-		if (!info.res)
-			goto out2;
-		
-		info.res_offset = 
-			kzalloc_node(sizeof(*info.res_offset) * info.res_num,
-				GFP_KERNEL, controller->node);
-		if (!info.res_offset)
+		if (!info->res)
 			goto out3;
+
+		info->res_offset +			kzalloc_node(sizeof(*info->res_offset) * info->res_num,
+					GFP_KERNEL, controller->node);
+		if (!info->res_offset)
+			goto out4;
 
 		name = kmalloc(16, GFP_KERNEL);
 		if (!name)
-			goto out4;
+			goto out5;
 
 		sprintf(name, "PCI Bus %04x:%02x", domain, bus);
-		info.bridge = device;
-		info.controller = controller;
-		info.name = name;
-		info.res_num = 0;
+		info->bridge = device;
+		info->controller = controller;
+		info->name = name;
+		info->res_num = 0;
 		acpi_walk_resources(device->handle, METHOD_NAME__CRS,
-			add_window, &info);
+			add_window, info);
 	}
 	/*
 	 * See arch/x86/pci/acpi.c.
@@ -385,18 +393,21 @@ struct pci_bus *pci_acpi_scan_root(struct acpi_pci_root *root)
 	 * such quirk. So we just ignore the case now.
 	 */
 	pbus = pci_create_root_bus(NULL, bus, &pci_root_ops, controller,
-				   &info.resources);
+				   &info->resources);
 	if (!pbus) {
-		pci_free_resource_list(&info.resources);
+		pci_free_resource_list(&info->resources);
 		return NULL;
 	}
 
 	pci_scan_child_bus(pbus);
 	return pbus;
+
+out5:
+	kfree(info->res_offset);
 out4:
-	kfree(info.res_offset);
+	kfree(info->res);
 out3:
-	kfree(info.res);
+	kfree(info);
 out2:
 	kfree(controller);
 out1:
-- 
1.7.1


