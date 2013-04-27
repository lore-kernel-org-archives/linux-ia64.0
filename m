From: Yijing Wang <wangyijing@huawei.com>
Date: Sat, 27 Apr 2013 09:12:25 +0000
Subject: [PATCH 3/7] PCI/IA64: make pci_root_info holds pci hostbridge resources
Message-Id: <1367053949-38424-4-git-send-email-wangyijing@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1367053949-38424-1-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1367053949-38424-1-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: linux-pci@vger.kernel.org, Hanjun Guo <guohanjun@huawei.com>, jiang.liu@huawei.com, Yijing Wang <wangyijing@huawei.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Yinghai Lu <yinghai@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Thierry Reding <thierry.reding@avionic-design.de>, linux-ia64@vger.kernel.org

Currently, pcibios_resource_to_bus() and pcibios_bus_to_resource()
functions use pci_host_bridge to translate bus side address from/to
cpu side address. The pci_window in pci_controller never be used again.
So we remove pci_window in pci_controller and make pci_root_info hold
the pci hostbridge resources like in x86.

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: Yinghai Lu <yinghai@kernel.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Thierry Reding <thierry.reding@avionic-design.de>
Cc: linux-ia64@vger.kernel.org
---
 arch/ia64/include/asm/pci.h   |   18 ++++++-----
 arch/ia64/pci/pci.c           |   68 ++++++++++++++++++++--------------------
 arch/ia64/sn/kernel/io_init.c |   67 ++++++++++++++++++++++++---------------
 3 files changed, 85 insertions(+), 68 deletions(-)

diff --git a/arch/ia64/include/asm/pci.h b/arch/ia64/include/asm/pci.h
index 5e04b59..82a236c 100644
--- a/arch/ia64/include/asm/pci.h
+++ b/arch/ia64/include/asm/pci.h
@@ -89,23 +89,25 @@ extern int pci_mmap_legacy_page_range(struct pci_bus *bus,
 #define pci_legacy_read platform_pci_legacy_read
 #define pci_legacy_write platform_pci_legacy_write
 
-struct pci_window {
-	struct resource resource;
-	u64 offset;
-};
-
 struct pci_controller {
 	void *acpi_handle;
 	void *iommu;
 	int segment;
 	int node;		/* nearest node with memory or -1 for global allocation */
 
-	unsigned int windows;
-	struct pci_window *window;
-
 	void *platform_data;
 };
 
+struct pci_root_info {
+	struct acpi_device *bridge;
+	struct pci_controller *controller;
+	struct list_head resources;
+	struct resource *res;
+	resource_size_t *res_offset;
+	unsigned int res_num;
+	char *name;
+};
+
 #define PCI_CONTROLLER(busdev) ((struct pci_controller *) busdev->sysdata)
 #define pci_domain_nr(busdev)    (PCI_CONTROLLER(busdev)->segment)
 
diff --git a/arch/ia64/pci/pci.c b/arch/ia64/pci/pci.c
index de1474f..d7681c6 100644
--- a/arch/ia64/pci/pci.c
+++ b/arch/ia64/pci/pci.c
@@ -130,12 +130,6 @@ static struct pci_controller *alloc_pci_controller(int seg)
 	return controller;
 }
 
-struct pci_root_info {
-	struct acpi_device *bridge;
-	struct pci_controller *controller;
-	struct list_head resources;
-	char *name;
-};
 
 static unsigned int
 new_space (u64 phys_base, int sparse)
@@ -265,7 +259,7 @@ static acpi_status count_window(struct acpi_resource *resource, void *data)
 static acpi_status add_window(struct acpi_resource *res, void *data)
 {
 	struct pci_root_info *info = data;
-	struct pci_window *window;
+	struct resource *resource;
 	struct acpi_resource_address64 addr;
 	acpi_status status;
 	unsigned long flags, offset = 0;
@@ -289,37 +283,36 @@ static acpi_status add_window(struct acpi_resource *res, void *data)
 	} else
 		return AE_OK;
 
-	window = &info->controller->window[info->controller->windows++];
-	window->resource.name = info->name;
-	window->resource.flags = flags;
-	window->resource.start = addr.minimum + offset;
-	window->resource.end = window->resource.start + addr.address_length - 1;
-	window->offset = offset;
+	resource = &info->res[info->res_num];
+	resource->name = info->name;
+	resource->flags = flags;
+	resource->start = addr.minimum + offset;
+	resource->end = resource->start + addr.address_length - 1;
+	info->res_offset[info->res_num] = offset;
 
-	if (insert_resource(root, &window->resource)) {
+	if (insert_resource(root, resource)) {
 		dev_err(&info->bridge->dev,
 			"can't allocate host bridge window %pR\n",
-			&window->resource);
+			resource);
 	} else {
 		if (offset)
 			dev_info(&info->bridge->dev, "host bridge window %pR "
 				 "(PCI address [%#llx-%#llx])\n",
-				 &window->resource,
-				 window->resource.start - offset,
-				 window->resource.end - offset);
+				 resource,
+				 resource->start - offset,
+				 resource->end - offset);
 		else
 			dev_info(&info->bridge->dev,
-				 "host bridge window %pR\n",
-				 &window->resource);
+				 "host bridge window %pR\n", resource);
 	}
-
 	/* HP's firmware has a hack to work around a Windows bug.
 	 * Ignore these tiny memory ranges */
-	if (!((window->resource.flags & IORESOURCE_MEM) &&
-	      (window->resource.end - window->resource.start < 16)))
-		pci_add_resource_offset(&info->resources, &window->resource,
-					window->offset);
+	if (!((resource->flags & IORESOURCE_MEM) &&
+	      (resource->end - resource->start < 16)))
+		pci_add_resource_offset(&info->resources, resource,
+					info->res_offset[info->res_num]);
 
+	info->res_num++;
 	return AE_OK;
 }
 
@@ -329,7 +322,6 @@ struct pci_bus *pci_acpi_scan_root(struct acpi_pci_root *root)
 	int domain = root->segment;
 	int bus = root->secondary.start;
 	struct pci_controller *controller;
-	unsigned int windows = 0;
 	struct pci_root_info info;
 	struct pci_bus *pbus;
 	char *name;
@@ -351,22 +343,29 @@ struct pci_bus *pci_acpi_scan_root(struct acpi_pci_root *root)
 	/* insert busn resource at first */
 	pci_add_resource(&info.resources, &root->secondary);
 	acpi_walk_resources(device->handle, METHOD_NAME__CRS, count_window,
-			&windows);
-	if (windows) {
-		controller->window -			kzalloc_node(sizeof(*controller->window) * windows,
+			&info.res_num);
+	if (info.res_num) {
+		info.res +			kzalloc_node(sizeof(*info.res) * info.res_num,
 				     GFP_KERNEL, controller->node);
-		if (!controller->window)
+		if (!info.res)
 			goto out2;
+
+		info.res_offset +			kzalloc_node(sizeof(*info.res_offset) * info.res_num,
+				GFP_KERNEL, controller->node);
+		if (!info.res_offset)
+			goto out3;
 
 		name = kmalloc(16, GFP_KERNEL);
 		if (!name)
-			goto out3;
+			goto out4;
 
 		sprintf(name, "PCI Bus %04x:%02x", domain, bus);
 		info.bridge = device;
 		info.controller = controller;
 		info.name = name;
+		info.res_num = 0;
 		acpi_walk_resources(device->handle, METHOD_NAME__CRS,
 			add_window, &info);
 	}
@@ -385,9 +384,10 @@ struct pci_bus *pci_acpi_scan_root(struct acpi_pci_root *root)
 
 	pci_scan_child_bus(pbus);
 	return pbus;
-
+out4:
+	kfree(info.res_offset);
 out3:
-	kfree(controller->window);
+	kfree(info.res);
 out2:
 	kfree(controller);
 out1:
diff --git a/arch/ia64/sn/kernel/io_init.c b/arch/ia64/sn/kernel/io_init.c
index 99710f5..86c2335 100644
--- a/arch/ia64/sn/kernel/io_init.c
+++ b/arch/ia64/sn/kernel/io_init.c
@@ -125,27 +125,39 @@ static void __init sn_fixup_ionodes(void)
  *				and their resources (_CRS),
  */
 static void
-sn_legacy_pci_window_fixup(struct pci_controller *controller,
+sn_legacy_pci_window_fixup(struct pci_root_info *info,
 			   u64 legacy_io, u64 legacy_mem)
 {
-		controller->window = kcalloc(2, sizeof(struct pci_window),
-					     GFP_KERNEL);
-		BUG_ON(controller->window = NULL);
-		controller->window[0].offset = legacy_io;
-		controller->window[0].resource.name = "legacy_io";
-		controller->window[0].resource.flags = IORESOURCE_IO;
-		controller->window[0].resource.start = legacy_io;
-		controller->window[0].resource.end -	    			controller->window[0].resource.start + 0xffff;
-		controller->window[0].resource.parent = &ioport_resource;
-		controller->window[1].offset = legacy_mem;
-		controller->window[1].resource.name = "legacy_mem";
-		controller->window[1].resource.flags = IORESOURCE_MEM;
-		controller->window[1].resource.start = legacy_mem;
-		controller->window[1].resource.end -	    	       controller->window[1].resource.start + (1024 * 1024) - 1;
-		controller->window[1].resource.parent = &iomem_resource;
-		controller->windows = 2;
+	info->res_num = 2;
+	info->res = kzalloc(sizeof(*info->res) * info->res_num, GFP_KERNEL);
+	if (!info->res) {
+		info->res_num = 0;
+		return;
+	}
+
+	info->res_offset = kzalloc(sizeof(*info->res_offset) * info->res_num,
+			GFP_KERNEL);
+	if (!info->res_offset) {
+		kfree(info->res);
+		info->res = NULL;
+		info->res_num = 0;
+		return;
+	}
+
+	info->res_offset[0] = legacy_io;
+	info->res[0].name = "legacy_io";
+	info->res[0].flags = IORESOURCE_IO;
+	info->res[0].start = legacy_io;
+	info->res[0].end +		info->res[0].start + 0xffff;
+	info->res[0].parent = &ioport_resource;
+	info->res_offset[1] = legacy_mem;
+	info->res[1].name = "legacy_mem";
+	info->res[1].flags = IORESOURCE_MEM;
+	info->res[1].start = legacy_mem;
+	info->res[1].end +		info->res[1].start + (1024 * 1024) - 1;
+	info->res[1].parent = &iomem_resource;
 }
 
 /*
@@ -248,6 +260,7 @@ static void __init
 sn_pci_controller_fixup(int segment, int busnum, struct pci_bus *bus)
 {
 	s64 status = 0;
+	struct pci_root_info info;
 	struct pci_controller *controller;
 	struct pcibus_bussoft *prom_bussoft_ptr;
 	LIST_HEAD(resources);
@@ -262,20 +275,21 @@ sn_pci_controller_fixup(int segment, int busnum, struct pci_bus *bus)
 	controller = kzalloc(sizeof(*controller), GFP_KERNEL);
 	BUG_ON(!controller);
 	controller->segment = segment;
-
-	/*
+		/*
 	 * Temporarily save the prom_bussoft_ptr for use by sn_bus_fixup().
 	 * (platform_data will be overwritten later in sn_common_bus_fixup())
 	 */
 	controller->platform_data = prom_bussoft_ptr;
+
+	info.controller = controller;
 
-	sn_legacy_pci_window_fixup(controller,
+	sn_legacy_pci_window_fixup(&info,
 				   prom_bussoft_ptr->bs_legacy_io,
 				   prom_bussoft_ptr->bs_legacy_mem);
-	for (i = 0; i < controller->windows; i++)
+	for (i = 0; i < info.res_num; i++)
 		pci_add_resource_offset(&resources,
-					&controller->window[i].resource,
-					controller->window[i].offset);
+					&info.res[i],
+					info.res_offset[i]);
 	bus = pci_scan_root_bus(NULL, busnum, &pci_root_ops, controller,
 				&resources);
  	if (bus = NULL)
@@ -286,8 +300,9 @@ sn_pci_controller_fixup(int segment, int busnum, struct pci_bus *bus)
 	return;
 
 error_return:
-
 	kfree(controller);
+	kfree(info.res);
+	kfree(info.res_offset);
 	return;
 }
 
-- 
1.7.1


