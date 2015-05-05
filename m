From: Jiang Liu <jiang.liu@linux.intel.com>
Date: Tue, 05 May 2015 02:46:10 +0000
Subject: [RFC v2 7/7] ia64/PCI/ACPI: Use common interface to support PCI host bridge
Message-Id: <1430793970-11159-8-git-send-email-jiang.liu@linux.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1430793970-11159-1-git-send-email-jiang.liu@linux.intel.com>
In-Reply-To: <1430793970-11159-1-git-send-email-jiang.liu@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Rafael J . Wysocki" <rjw@rjwysocki.net>, Bjorn Helgaas <bhelgaas@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Hanjun Guo <hanjun.guo@linaro.org>, Yijing Wang <wangyijing@huawei.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Jiang Liu <jiang.liu@linux.intel.com>, Yinghai Lu <yinghai@kernel.org>
Cc: Lv Zheng <lv.zheng@intel.com>, "lenb @ kernel . org" <lenb@kernel.org>, LKML <linux-kernel@vger.kernel.org>, linux-pci@vger.kernel.org, linux-acpi@vger.kernel.org, "x86 @ kernel . org" <x86@kernel.org>, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org

Use common interface to simplify PCI host bridge implementation.

Tested-by: Tony Luck <tony.luck@intel.com>
Signed-off-by: Jiang Liu <jiang.liu@linux.intel.com>
---
 arch/ia64/pci/pci.c |  246 +++++++++++----------------------------------------
 1 file changed, 51 insertions(+), 195 deletions(-)

diff --git a/arch/ia64/pci/pci.c b/arch/ia64/pci/pci.c
index 4af1b52c7a44..0819d6274e82 100644
--- a/arch/ia64/pci/pci.c
+++ b/arch/ia64/pci/pci.c
@@ -116,15 +116,11 @@ struct pci_ops pci_root_ops = {
 };
 
 struct pci_root_info {
-	struct pci_controller controller;
-	struct acpi_device *bridge;
-	struct list_head resources;
+	struct acpi_pci_root_info_common common;
 	struct list_head io_resources;
-	char name[16];
 };
 
-static unsigned int
-new_space (u64 phys_base, int sparse)
+static unsigned int new_space(u64 phys_base, int sparse)
 {
 	u64 mmio_base;
 	int i;
@@ -160,11 +156,11 @@ static int add_io_space(struct device *dev, struct pci_root_info *info,
 	unsigned long base, min, max, base_port;
 	unsigned int sparse = 0, space_nr, len;
 
-	len = strlen(info->name) + 32;
+	len = strlen(info->common.name) + 32;
 	iospace = resource_list_create_entry(NULL, len);
 	if (!iospace) {
 		dev_err(dev, "PCI: No memory for %s I/O port space\n",
-			info->name);
+			info->common.name);
 		return -ENOMEM;
 	}
 
@@ -179,7 +175,7 @@ static int add_io_space(struct device *dev, struct pci_root_info *info,
 	max = res->end - entry->offset;
 	base = __pa(io_space[space_nr].mmio_base);
 	base_port = IO_SPACE_BASE(space_nr);
-	snprintf(name, len, "%s I/O Ports %08lx-%08lx", info->name,
+	snprintf(name, len, "%s I/O Ports %08lx-%08lx", info->common.name,
 		 base_port + min, base_port + max);
 
 	/*
@@ -234,217 +230,77 @@ static bool resource_is_pcicfg_ioport(struct resource *res)
 		res->start = 0xCF8 && res->end = 0xCFF;
 }
 
-static int
-probe_pci_root_info(struct pci_root_info *info, struct acpi_device *device,
-		    int busnum, int domain)
+static int pci_acpi_root_prepare_resources(struct acpi_pci_root_info_common *ci,
+					   int status)
 {
-	int ret;
-	struct list_head *list = &info->resources;
+	struct device *dev = &ci->bridge->dev;
+	struct pci_root_info *info;
+	struct resource *res;
 	struct resource_entry *entry, *tmp;
 
-	ret = acpi_dev_get_resources(device, list,
-				     acpi_dev_filter_resource_type_cb,
-				     (void *)(IORESOURCE_IO | IORESOURCE_MEM));
-	if (ret < 0)
-		dev_warn(&device->dev,
-			 "failed to parse _CRS method, error code %d\n", ret);
-	else if (ret = 0)
-		dev_dbg(&device->dev,
-			"no IO and memory resources present in _CRS\n");
-	else
-		resource_list_for_each_entry_safe(entry, tmp, list) {
-			if ((entry->res->flags & IORESOURCE_DISABLED) ||
-			    resource_is_pcicfg_ioport(entry->res))
-				resource_list_destroy_entry(entry);
-			else
-				entry->res->name = info->name;
+	if (status > 0) {
+		info = container_of(ci, struct pci_root_info, common);
+		resource_list_for_each_entry_safe(entry, tmp, &ci->resources) {
+			res = entry->res;
+			if (res->flags & IORESOURCE_MEM) {
+				/*
+				 * HP's firmware has a hack to work around a
+				 * Windows bug. Ignore these tiny memory ranges.
+				 */
+				if (resource_size(res) <= 16) {
+					resource_list_del(entry);
+					insert_resource(&iomem_resource,
+							entry->res);
+					resource_list_add_tail(entry,
+							&info->io_resources);
+				}
+			} else if (res->flags & IORESOURCE_IO) {
+				if (resource_is_pcicfg_ioport(entry->res))
+					resource_list_destroy_entry(entry);
+				else if (add_io_space(dev, info, entry))
+					resource_list_destroy_entry(entry);
+			}
 		}
+	}
 
-	return ret;
+	return status;
 }
 
-static void validate_resources(struct device *dev, struct list_head *resources,
-			       unsigned long type)
+static int pci_acpi_root_init_info(struct acpi_pci_root_info_common *ci)
 {
-	LIST_HEAD(list);
-	struct resource *res1, *res2, *root = NULL;
-	struct resource_entry *tmp, *entry, *entry2;
-
-	BUG_ON((type & (IORESOURCE_MEM | IORESOURCE_IO)) = 0);
-	root = (type & IORESOURCE_MEM) ? &iomem_resource : &ioport_resource;
-
-	list_splice_init(resources, &list);
-	resource_list_for_each_entry_safe(entry, tmp, &list) {
-		bool free = false;
-		resource_size_t end;
-
-		res1 = entry->res;
-		if (!(res1->flags & type))
-			goto next;
-
-		/* Exclude non-addressable range or non-addressable portion */
-		end = min(res1->end, root->end);
-		if (end <= res1->start) {
-			dev_info(dev, "host bridge window %pR (ignored, not CPU addressable)\n",
-				 res1);
-			free = true;
-			goto next;
-		} else if (res1->end != end) {
-			dev_info(dev, "host bridge window %pR ([%#llx-%#llx] ignored, not CPU addressable)\n",
-				 res1, (unsigned long long)end + 1,
-				 (unsigned long long)res1->end);
-			res1->end = end;
-		}
+	struct pci_root_info *info;
 
-		resource_list_for_each_entry(entry2, resources) {
-			res2 = entry2->res;
-			if (!(res2->flags & type))
-				continue;
-
-			/*
-			 * I don't like throwing away windows because then
-			 * our resources no longer match the ACPI _CRS, but
-			 * the kernel resource tree doesn't allow overlaps.
-			 */
-			if (resource_overlaps(res1, res2)) {
-				res2->start = min(res1->start, res2->start);
-				res2->end = max(res1->end, res2->end);
-				dev_info(dev, "host bridge window expanded to %pR; %pR ignored\n",
-					 res2, res1);
-				free = true;
-				goto next;
-			}
-		}
+	info = container_of(ci, struct pci_root_info, common);
+	INIT_LIST_HEAD(&info->io_resources);
 
-next:
-		resource_list_del(entry);
-		if (free)
-			resource_list_free_entry(entry);
-		else
-			resource_list_add_tail(entry, resources);
-	}
+	return 0;
 }
 
-static void add_resources(struct pci_root_info *info, struct device *dev)
+static void pci_acpi_root_release_info(struct acpi_pci_root_info_common *ci)
 {
+	struct pci_root_info *info;
 	struct resource_entry *entry, *tmp;
-	struct resource *res, *conflict, *root = NULL;
-	struct list_head *list = &info->resources;
-
-	validate_resources(dev, list, IORESOURCE_MEM);
-	validate_resources(dev, list, IORESOURCE_IO);
-
-	resource_list_for_each_entry_safe(entry, tmp, list) {
-		res = entry->res;
-		if (res->flags & IORESOURCE_MEM) {
-			root = &iomem_resource;
-			/*
-			 * HP's firmware has a hack to work around a Windows
-			 * bug. Ignore these tiny memory ranges.
-			 */
-			if (resource_size(res) <= 16) {
-				resource_list_destroy_entry(entry);
-				continue;
-			}
-		} else if (res->flags & IORESOURCE_IO) {
-			root = &ioport_resource;
-			if (add_io_space(&info->bridge->dev, info, entry)) {
-				resource_list_destroy_entry(entry);
-				continue;
-			}
-		} else {
-			BUG_ON(res);
-		}
-
-		conflict = insert_resource_conflict(root, res);
-		if (conflict) {
-			dev_info(dev,
-				 "ignoring host bridge window %pR (conflicts with %s %pR)\n",
-				 res, conflict->name, conflict);
-			resource_list_destroy_entry(entry);
-		}
-	}
-}
 
-static void __release_pci_root_info(struct pci_root_info *info)
-{
-	struct resource *res;
-	struct resource_entry *entry, *tentry;
-
-	resource_list_for_each_entry_safe(entry, tentry, &info->io_resources) {
+	info = container_of(ci, struct pci_root_info, common);
+	resource_list_for_each_entry_safe(entry, tmp, &info->io_resources) {
 		release_resource(entry->res);
 		resource_list_destroy_entry(entry);
 	}
-
-	resource_list_for_each_entry_safe(entry, tentry, &info->resources) {
-		res = entry->res;
-		if (res->parent &&
-		    (res->flags & (IORESOURCE_MEM | IORESOURCE_IO)))
-			release_resource(res);
-		resource_list_destroy_entry(entry);
-	}
-
-	kfree(info);
 }
 
-static void release_pci_root_info(struct pci_host_bridge *bridge)
-{
-	struct pci_root_info *info = bridge->release_data;
-
-	__release_pci_root_info(info);
-}
+static struct acpi_pci_root_ops pci_acpi_root_ops = {
+	.pci_ops = &pci_root_ops,
+	.init_info = pci_acpi_root_init_info,
+	.release_info = pci_acpi_root_release_info,
+	.prepare_resources = pci_acpi_root_prepare_resources,
+};
 
 struct pci_bus *pci_acpi_scan_root(struct acpi_pci_root *root)
 {
-	struct acpi_device *device = root->device;
-	int domain = root->segment;
-	int bus = root->secondary.start;
 	struct pci_root_info *info;
-	struct pci_bus *pbus;
-	int ret;
-
-	info = kzalloc(sizeof(*info), GFP_KERNEL);
-	if (!info) {
-		dev_err(&device->dev,
-			"pci_bus %04x:%02x: ignored (out of memory)\n",
-			domain, bus);
-		return NULL;
-	}
-
-	info->controller.segment = domain;
-	info->controller.companion = device;
-	info->controller.node = acpi_get_node(device->handle);
-	info->bridge = device;
-	INIT_LIST_HEAD(&info->resources);
-	INIT_LIST_HEAD(&info->io_resources);
-	snprintf(info->name, sizeof(info->name),
-		 "PCI Bus %04x:%02x", domain, bus);
-
-	ret = probe_pci_root_info(info, device, bus, domain);
-	if (ret <= 0) {
-		kfree(info);
-		return NULL;
-	}
-	add_resources(info, &info->bridge->dev);
-	pci_add_resource(&info->resources, &root->secondary);
-
-	/*
-	 * See arch/x86/pci/acpi.c.
-	 * The desired pci bus might already be scanned in a quirk. We
-	 * should handle the case here, but it appears that IA64 hasn't
-	 * such quirk. So we just ignore the case now.
-	 */
-	pbus = pci_create_root_bus(NULL, bus, &pci_root_ops,
-				   &info->controller, &info->resources);
-	if (!pbus) {
-		__release_pci_root_info(info);
-		return NULL;
-	}
 
-	pci_set_host_bridge_release(to_pci_host_bridge(pbus->bridge),
-			release_pci_root_info, info);
-	pci_scan_child_bus(pbus);
-	return pbus;
+	return acpi_pci_root_create(root, &pci_acpi_root_ops,
+				    sizeof(*info) - sizeof(info->common));
 }
 
 int pcibios_root_bridge_prepare(struct pci_host_bridge *bridge)
-- 
1.7.10.4

