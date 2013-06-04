From: Yijing Wang <wangyijing@huawei.com>
Date: Tue, 04 Jun 2013 10:59:11 +0000
Subject: [PATCH -v3 5/8] PCI/IA64: fix memleak for create pci root bus fail
Message-Id: <1370343554-11812-6-git-send-email-wangyijing@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

From: Jiang Liu <jiang.liu@huawei.com>

If pci_create_root_bus() return fail, we should release
pci root info, pci controller etc.

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Signed-off-by: Yijing Wang <wangyijing@huawei.com>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: Yinghai Lu <yinghai@kernel.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: linux-ia64@vger.kernel.org
---
 arch/ia64/include/asm/pci.h |    5 +++
 arch/ia64/pci/pci.c         |   75 ++++++++++++++++++++++++++++++++++--------
 2 files changed, 65 insertions(+), 15 deletions(-)

diff --git a/arch/ia64/include/asm/pci.h b/arch/ia64/include/asm/pci.h
index a7ebe5f..00487b8 100644
--- a/arch/ia64/include/asm/pci.h
+++ b/arch/ia64/include/asm/pci.h
@@ -89,6 +89,11 @@ extern int pci_mmap_legacy_page_range(struct pci_bus *bus,
 #define pci_legacy_read platform_pci_legacy_read
 #define pci_legacy_write platform_pci_legacy_write
 
+struct iospace_resource {
+	struct list_head list;
+	struct resource res;
+};
+
 struct pci_controller {
 	void *acpi_handle;
 	void *iommu;
diff --git a/arch/ia64/pci/pci.c b/arch/ia64/pci/pci.c
index 3a8b361..dfb6149 100644
--- a/arch/ia64/pci/pci.c
+++ b/arch/ia64/pci/pci.c
@@ -137,6 +137,7 @@ struct pci_root_info {
 	struct resource *res;
 	resource_size_t *res_offset;
 	unsigned int res_num;
+	struct list_head io_resources;
 	char *name;
 };
 
@@ -171,25 +172,21 @@ new_space (u64 phys_base, int sparse)
 static u64 add_io_space(struct pci_root_info *info,
 			struct acpi_resource_address64 *addr)
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
@@ -198,7 +195,7 @@ static u64 add_io_space(struct pci_root_info *info,
 
 	space_nr = new_space(addr->translation_offset, sparse);
 	if (space_nr = ~0)
-		goto free_name;
+		goto free_resource;
 
 	base = __pa(io_space[space_nr].mmio_base);
 	base_port = IO_SPACE_BASE(space_nr);
@@ -213,18 +210,23 @@ static u64 add_io_space(struct pci_root_info *info,
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
+				"can't allocate host bridge io space resource  %pR\n",
+				resource);
+		goto free_resource;
+	}
 
+	list_add_tail(&iospace->list, &info->io_resources);
 	return base_port;
 
-free_name:
-	kfree(name);
 free_resource:
-	kfree(resource);
+	kfree(iospace);
 out:
 	return ~0;
 }
@@ -325,6 +327,47 @@ static acpi_status add_window(struct acpi_resource *res, void *data)
 	return AE_OK;
 }
 
+static void free_pci_root_info_res(struct pci_root_info *info)
+{
+	struct iospace_resource *iospace, *tmp;
+
+	list_for_each_entry_safe(iospace, tmp, &info->io_resources, list)
+		kfree(iospace);
+
+	kfree(info->res);
+	info->res = NULL;
+	kfree(info->res_offset);
+	info->res_offset = NULL;
+	info->res_num = 0;
+	kfree(info->controller);
+	info->controller = NULL;
+}
+
+static void __release_pci_root_info(struct pci_root_info *info)
+{
+	int i;
+	struct resource *res;
+	struct iospace_resource *iospace;
+
+	list_for_each_entry(iospace, &info->io_resources, list)
+		release_resource(&iospace->res);
+
+	for (i = 0; i < info->res_num; i++) {
+		res = &info->res[i];
+
+		if (!res->parent)
+			continue;
+
+		if (!(res->flags & (IORESOURCE_MEM | IORESOURCE_IO)))
+			continue;
+
+		release_resource(res);
+	}
+
+	free_pci_root_info_res(info);
+	kfree(info);
+}
+
 struct pci_bus *pci_acpi_scan_root(struct acpi_pci_root *root)
 {
 	struct acpi_device *device = root->device;
@@ -355,7 +398,8 @@ struct pci_bus *pci_acpi_scan_root(struct acpi_pci_root *root)
 				"ignored (out of memory)\n", root->segment, busnum);
 		goto out2;
 	}
-
+
+	INIT_LIST_HEAD(&info->io_resources);
 	INIT_LIST_HEAD(&info->resources);
 	/* insert busn resource at first */
 	pci_add_resource(&info->resources, &root->secondary);
@@ -396,6 +440,7 @@ struct pci_bus *pci_acpi_scan_root(struct acpi_pci_root *root)
 				   &info->resources);
 	if (!pbus) {
 		pci_free_resource_list(&info->resources);
+		__release_pci_root_info(info);
 		return NULL;
 	}
 
-- 
1.7.1


