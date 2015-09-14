From: Jiang Liu <jiang.liu@linux.intel.com>
Date: Mon, 14 Sep 2015 08:07:32 +0000
Subject: [Patch v6 3/7] ia64/PCI: Use common struct resource_entry to replace struct iospace_resource
Message-Id: <1442218057-4355-4-git-send-email-jiang.liu@linux.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1442218057-4355-1-git-send-email-jiang.liu@linux.intel.com>
In-Reply-To: <1442218057-4355-1-git-send-email-jiang.liu@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, Lorenzo Pieralisi <lorenzo.pieralisi@arm.com>, Marc Zyngier <marc.zyngier@arm.com>, Hanjun Guo <hanjun.guo@linaro.org>, Liviu Dudau <Liviu.Dudau@arm.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Jiang Liu <jiang.liu@linux.intel.com>, Yinghai Lu <yinghai@kernel.org>
Cc: linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, x86@kernel.org, linux-ia64@vger.kernel.org

Use common struct resource_entry to replace private
struct iospace_resource.

Signed-off-by: Jiang Liu <jiang.liu@linux.intel.com>
Reviewed-by: Hanjun Guo <hanjun.guo@linaro.org>
---
 arch/ia64/include/asm/pci.h |    5 -----
 arch/ia64/pci/pci.c         |   17 ++++++++---------
 2 files changed, 8 insertions(+), 14 deletions(-)

diff --git a/arch/ia64/include/asm/pci.h b/arch/ia64/include/asm/pci.h
index 36d2c1e3928b..07039d168f37 100644
--- a/arch/ia64/include/asm/pci.h
+++ b/arch/ia64/include/asm/pci.h
@@ -64,11 +64,6 @@ extern int pci_mmap_legacy_page_range(struct pci_bus *bus,
 #define pci_legacy_read platform_pci_legacy_read
 #define pci_legacy_write platform_pci_legacy_write
 
-struct iospace_resource {
-	struct list_head list;
-	struct resource res;
-};
-
 struct pci_controller {
 	struct acpi_device *companion;
 	void *iommu;
diff --git a/arch/ia64/pci/pci.c b/arch/ia64/pci/pci.c
index d092c6b08666..5dd3753a2739 100644
--- a/arch/ia64/pci/pci.c
+++ b/arch/ia64/pci/pci.c
@@ -154,14 +154,14 @@ new_space (u64 phys_base, int sparse)
 static int add_io_space(struct device *dev, struct pci_root_info *info,
 			struct resource_entry *entry)
 {
-	struct iospace_resource *iospace;
+	struct resource_entry *iospace;
 	struct resource *resource, *res = entry->res;
 	char *name;
 	unsigned long base, min, max, base_port;
 	unsigned int sparse = 0, space_nr, len;
 
 	len = strlen(info->name) + 32;
-	iospace = kzalloc(sizeof(*iospace) + len, GFP_KERNEL);
+	iospace = resource_list_create_entry(NULL, len);
 	if (!iospace) {
 		dev_err(dev, "PCI: No memory for %s I/O port space\n",
 			info->name);
@@ -190,7 +190,7 @@ static int add_io_space(struct device *dev, struct pci_root_info *info,
 	if (space_nr = 0)
 		sparse = 1;
 
-	resource = &iospace->res;
+	resource = iospace->res;
 	resource->name  = name;
 	resource->flags = IORESOURCE_MEM;
 	resource->start = base + (sparse ? IO_SPACE_SPARSE_ENCODING(min) : min);
@@ -205,12 +205,12 @@ static int add_io_space(struct device *dev, struct pci_root_info *info,
 	entry->offset = base_port;
 	res->start = min + base_port;
 	res->end = max + base_port;
-	list_add_tail(&iospace->list, &info->io_resources);
+	resource_list_add_tail(iospace, &info->io_resources);
 
 	return 0;
 
 free_resource:
-	kfree(iospace);
+	resource_list_free_entry(iospace);
 	return -ENOSPC;
 }
 
@@ -369,12 +369,11 @@ static void add_resources(struct pci_root_info *info, struct device *dev)
 static void __release_pci_root_info(struct pci_root_info *info)
 {
 	struct resource *res;
-	struct iospace_resource *iospace, *tmp;
 	struct resource_entry *entry, *tentry;
 
-	list_for_each_entry_safe(iospace, tmp, &info->io_resources, list) {
-		release_resource(&iospace->res);
-		kfree(iospace);
+	resource_list_for_each_entry_safe(entry, tentry, &info->io_resources) {
+		release_resource(entry->res);
+		resource_list_destroy_entry(entry);
 	}
 
 	resource_list_for_each_entry_safe(entry, tentry, &info->resources) {
-- 
1.7.10.4

