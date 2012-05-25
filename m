From: Jiang Liu <jiang.liu@huawei.com>
Date: Fri, 25 May 2012 07:23:42 +0000
Subject: [PATCH v1] PCI,IA64: free associated resources when removing host bridges
Message-Id: <1337930622-7696-1-git-send-email-jiang.liu@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>, Yinghai Lu <yinghai@kernel.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Yijing Wang <wangyijing@huawei.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Keping Chen <chenkeping@huawei.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org, Jiang Liu <liuj97@gmail.com>

There are some resources associated with PCI host bridges on
IA 64 platforms, they should be released when removing host
bridges. Otherwise it will cause memory leak and other strange
behavior.

For example, PCI IO port address space are mapped into memory
address space on IA64. Those IO port resource should be released
when removing PCI host bridges. Otherwise host bridge hotplug
may cause duplicated entries in the iomem resource pool.
All "1fffffe400000-1fffffffffffe" are duplicated entries.

30fc000000-30ffffffff : reserved
1fffffc000000-1fffffc33dcf7 : PCI Bus 0000:00 I/O Ports 00000000-00000cf7
1fffffc400000-1fffffe3fffff : PCI Bus 0000:00 I/O Ports 00001000-00008fff
30fc000000-30ffffffff : reserved
1fffffc000000-1fffffc33dcf7 : PCI Bus 0000:00 I/O Ports 00000000-00000cf7
1fffffc400000-1fffffe3fffff : PCI Bus 0000:00 I/O Ports 00001000-00008fff
1fffffe400000-1fffffffffffe : PCI Bus 0000:40 I/O Ports 00009000-0000fffe
  1fffffe400000-1fffffffffffe : PCI Bus 0000:40 I/O Ports 00009000-0000fffe
    1fffffe400000-1fffffffffffe : PCI Bus 0000:40 I/O Ports 00009000-0000fffe

Signed-off-by: Jiang Liu <liuj97@gmail.com>
Signed-off-by: Yijing Wang <wangyijing@huawei.com>
---

This patch applies to
git://git.kernel.org/pub/scm/linux/kernel/git/helgaas/pci.git pci/next-3.5

---
 arch/ia64/include/asm/pci.h |    6 +++
 arch/ia64/pci/pci.c         |   80 +++++++++++++++++++++++++++++++++++--------
 2 files changed, 71 insertions(+), 15 deletions(-)

diff --git a/arch/ia64/include/asm/pci.h b/arch/ia64/include/asm/pci.h
index 5e04b59..3939f00 100644
--- a/arch/ia64/include/asm/pci.h
+++ b/arch/ia64/include/asm/pci.h
@@ -94,6 +94,11 @@ struct pci_window {
 	u64 offset;
 };
 
+struct iospace_resource {
+	struct list_head list;
+	struct resource res;
+};
+
 struct pci_controller {
 	void *acpi_handle;
 	void *iommu;
@@ -102,6 +107,7 @@ struct pci_controller {
 
 	unsigned int windows;
 	struct pci_window *window;
+	struct list_head io_resources;
 
 	void *platform_data;
 };
diff --git a/arch/ia64/pci/pci.c b/arch/ia64/pci/pci.c
index d173a88..a66cba4 100644
--- a/arch/ia64/pci/pci.c
+++ b/arch/ia64/pci/pci.c
@@ -168,25 +168,20 @@ new_space (u64 phys_base, int sparse)
 static u64 __devinit
 add_io_space (struct pci_root_info *info, struct acpi_resource_address64 *addr)
 {
+	struct iospace_resource *iospace;
 	struct resource *resource;
 	char *name;
 	unsigned long base, min, max, base_port;
 	unsigned int sparse = 0, space_nr, len;
 
-	resource = kzalloc(sizeof(*resource), GFP_KERNEL);
-	if (!resource) {
+	len = strlen(info->name) + 32;
+	iospace = kzalloc(sizeof(*iospace) + len, GFP_KERNEL);
+	if (!iospace) {
 		printk(KERN_ERR "PCI: No memory for %s I/O port space\n",
 			info->name);
 		goto out;
 	}
-
-	len = strlen(info->name) + 32;
-	name = kzalloc(len, GFP_KERNEL);
-	if (!name) {
-		printk(KERN_ERR "PCI: No memory for %s I/O port space name\n",
-			info->name);
-		goto free_resource;
-	}
+	name = (char *)(iospace + 1);
 
 	min = addr->minimum;
 	max = min + addr->address_length - 1;
@@ -195,7 +190,7 @@ add_io_space (struct pci_root_info *info, struct acpi_resource_address64 *addr)
 
 	space_nr = new_space(addr->translation_offset, sparse);
 	if (space_nr = ~0)
-		goto free_name;
+		goto free_resource;
 
 	base = __pa(io_space[space_nr].mmio_base);
 	base_port = IO_SPACE_BASE(space_nr);
@@ -210,18 +205,24 @@ add_io_space (struct pci_root_info *info, struct acpi_resource_address64 *addr)
 	if (space_nr = 0)
 		sparse = 1;
 
+	resource = &iospace->res;
 	resource->name  = name;
 	resource->flags = IORESOURCE_MEM;
 	resource->start = base + (sparse ? IO_SPACE_SPARSE_ENCODING(min) : min);
 	resource->end   = base + (sparse ? IO_SPACE_SPARSE_ENCODING(max) : max);
-	insert_resource(&iomem_resource, resource);
+	if (insert_resource(&iomem_resource, resource)) {
+		dev_err(&info->bridge->dev,
+			"can't allocate host bridge io space resource  %pR\n",
+			resource);
+		goto free_resource;
+	}
+
+	list_add_tail(&iospace->list, &info->controller->io_resources);
 
 	return base_port;
 
-free_name:
-	kfree(name);
 free_resource:
-	kfree(resource);
+	kfree(iospace);
 out:
 	return ~0;
 }
@@ -325,6 +326,51 @@ static __devinit acpi_status add_window(struct acpi_resource *res, void *data)
 	return AE_OK;
 }
 
+static void shutdown_pci_controller(struct pci_host_bridge *bridge)
+{
+	unsigned int i;
+	struct resource *resource;
+	struct iospace_resource *iospace;
+	struct pci_controller *controller = bridge->release_data;
+
+	if (!controller)
+		return;
+
+	/* release io space resource */
+	list_for_each_entry(iospace, &controller->io_resources, list)
+		release_resource(&iospace->res);
+
+	/* release root bus resource */
+	for (i = 0; i < controller->windows; i++) {
+		resource = &controller->window[i].resource;
+		if (resource->flags & (IORESOURCE_MEM | IORESOURCE_IO))
+			if (resource->parent)
+				release_resource(resource);
+	}
+}
+
+static void free_pci_controller(struct pci_host_bridge *bridge)
+{
+	struct resource *resource;
+	struct iospace_resource *iospace, *tmp;
+	struct pci_controller *controller = bridge->release_data;
+
+	if (!controller)
+		return;
+
+	shutdown_pci_controller(bridge);
+
+	list_for_each_entry_safe(iospace, tmp, &controller->io_resources, list)
+		kfree(iospace);
+
+	if (controller->window) {
+		kfree(controller->window->resource.name);
+		kfree(controller->window);
+	}
+
+	kfree(controller);
+}
+
 struct pci_bus * __devinit
 pci_acpi_scan_root(struct acpi_pci_root *root)
 {
@@ -343,6 +389,7 @@ pci_acpi_scan_root(struct acpi_pci_root *root)
 		goto out1;
 
 	controller->acpi_handle = device->handle;
+	INIT_LIST_HEAD(&controller->io_resources);
 
 	pxm = acpi_get_pxm(controller->acpi_handle);
 #ifdef CONFIG_NUMA
@@ -386,6 +433,9 @@ pci_acpi_scan_root(struct acpi_pci_root *root)
 		return NULL;
 	}
 
+	pci_set_host_bridge_release(to_pci_host_bridge(pbus->bridge),
+			free_pci_controller, controller);
+
 	pci_scan_child_bus(pbus);
 	return pbus;
 
-- 
1.7.1


