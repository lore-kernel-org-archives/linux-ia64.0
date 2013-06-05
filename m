From: Yijing Wang <wangyijing@huawei.com>
Date: Wed, 05 Jun 2013 06:01:56 +0000
Subject: [PATCH -v4 7/8] PCI/IA64: introduce probe_pci_root_info() to manage  _CRS resource
Message-Id: <1370412117-12860-8-git-send-email-wangyijing@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1370412117-12860-1-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1370412117-12860-1-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: Yinghai Lu <yinghai@kernel.org>, linux-pci@vger.kernel.org, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, Fenghua Yu <fenghua.yu@intel.com>, Hanjun Guo <guohanjun@huawei.com>, jiang.liu@huawei.com, Yijing Wang <wangyijing@huawei.com>

Currently, initialize _CRS resource code in IA64 make pci_acpi_scan_root()
some lengthiness. Introduce probe_pci_root_info() to manage it like in X86,

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
---
 arch/ia64/pci/pci.c |  100 +++++++++++++++++++++++++++++----------------------
 1 files changed, 57 insertions(+), 43 deletions(-)

diff --git a/arch/ia64/pci/pci.c b/arch/ia64/pci/pci.c
index 4383b03..f2139b4 100644
--- a/arch/ia64/pci/pci.c
+++ b/arch/ia64/pci/pci.c
@@ -375,6 +375,50 @@ static void release_pci_root_info(struct pci_host_bridge *bridge)
 	__release_pci_root_info(info);
 }
 
+static int
+probe_pci_root_info(struct pci_root_info *info, struct acpi_device *device,
+		int busnum, int domain)
+{
+	char *name;
+
+	name = kmalloc(16, GFP_KERNEL);
+	if (!name)
+		return -ENOMEM;
+
+	sprintf(name, "PCI Bus %04x:%02x", domain, busnum);
+	info->bridge = device;
+	info->name = name;
+
+	acpi_walk_resources(device->handle, METHOD_NAME__CRS, count_window,
+			&info->res_num);
+	if (info->res_num) {
+		info->res +			kzalloc_node(sizeof(*info->res) * info->res_num,
+				     GFP_KERNEL, info->controller->node);
+		if (!info->res) {
+			kfree(name);
+			return -ENOMEM;
+		}
+
+		info->res_offset +			kzalloc_node(sizeof(*info->res_offset) * info->res_num,
+					GFP_KERNEL, info->controller->node);
+		if (!info->res_offset) {
+			kfree(name);
+			kfree(info->res);
+			info->res = NULL;
+			return -ENOMEM;
+		}
+
+		info->res_num = 0;
+		acpi_walk_resources(device->handle, METHOD_NAME__CRS,
+			add_window, info);
+	} else
+		kfree(name);
+
+	return 0;
+}
+
 struct pci_bus *pci_acpi_scan_root(struct acpi_pci_root *root)
 {
 	struct acpi_device *device = root->device;
@@ -384,12 +428,11 @@ struct pci_bus *pci_acpi_scan_root(struct acpi_pci_root *root)
 	struct pci_root_info *info = NULL;
 	int busnum = root->secondary.start;
 	struct pci_bus *pbus;
-	char *name;
-	int pxm;
+	int pxm, ret;
 
 	controller = alloc_pci_controller(domain);
 	if (!controller)
-		goto out1;
+		return NULL;
 
 	controller->acpi_handle = device->handle;
 
@@ -402,41 +445,23 @@ struct pci_bus *pci_acpi_scan_root(struct acpi_pci_root *root)
 	info = kzalloc(sizeof(*info), GFP_KERNEL);
 	if (!info) {
 		printk(KERN_WARNING "pci_bus %04x:%02x: "
-				"ignored (out of memory)\n", root->segment, busnum);
-		goto out2;
+				"ignored (out of memory)\n", domain, busnum);
+		kfree(controller);
+		return NULL;
 	}
 	
+	info->controller = controller;
 	INIT_LIST_HEAD(&info->io_resources);
 	INIT_LIST_HEAD(&info->resources);
+	ret = probe_pci_root_info(info, device, busnum, domain);
+	if (ret) {
+		kfree(info->controller);
+		kfree(info);
+		return NULL;
+	}
+
 	/* insert busn resource at first */
 	pci_add_resource(&info->resources, &root->secondary);
-	acpi_walk_resources(device->handle, METHOD_NAME__CRS, count_window,
-			&info->res_num);
-	if (info->res_num) {
-		info->res -			kzalloc_node(sizeof(*info->res) * info->res_num,
-				     GFP_KERNEL, controller->node);
-		if (!info->res)
-			goto out3;
-		
-		info->res_offset = 
-			kzalloc_node(sizeof(*info->res_offset) * info->res_num, 
-					GFP_KERNEL, controller->node);
-		if (!info->res_offset)
-			goto out4;
-
-		name = kmalloc(16, GFP_KERNEL);
-		if (!name)
-			goto out5;
-
-		sprintf(name, "PCI Bus %04x:%02x", domain, bus);
-		info->bridge = device;
-		info->controller = controller;
-		info->name = name;
-		info->res_num = 0;
-		acpi_walk_resources(device->handle, METHOD_NAME__CRS,
-			add_window, info);
-	}
 	/*
 	 * See arch/x86/pci/acpi.c.
 	 * The desired pci bus might already be scanned in a quirk. We
@@ -455,17 +480,6 @@ struct pci_bus *pci_acpi_scan_root(struct acpi_pci_root *root)
 			release_pci_root_info, info);
 	pci_scan_child_bus(pbus);
 	return pbus;
-
-out5:
-	kfree(info->res_offset);
-out4:
-	kfree(info->res);
-out3:
-	kfree(info);
-out2:
-	kfree(controller);
-out1:
-	return NULL;
 }
 
 int pcibios_root_bridge_prepare(struct pci_host_bridge *bridge)
-- 
1.7.1


