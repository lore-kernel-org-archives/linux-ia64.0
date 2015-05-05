From: Jiang Liu <jiang.liu@linux.intel.com>
Date: Tue, 05 May 2015 02:46:05 +0000
Subject: [RFC v2 2/7] ia64/PCI/ACPI: Use common ACPI resource parsing interface for host bridge
Message-Id: <1430793970-11159-3-git-send-email-jiang.liu@linux.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1430793970-11159-1-git-send-email-jiang.liu@linux.intel.com>
In-Reply-To: <1430793970-11159-1-git-send-email-jiang.liu@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Rafael J . Wysocki" <rjw@rjwysocki.net>, Bjorn Helgaas <bhelgaas@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Hanjun Guo <hanjun.guo@linaro.org>, Yijing Wang <wangyijing@huawei.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Jiang Liu <jiang.liu@linux.intel.com>, Yinghai Lu <yinghai@kernel.org>
Cc: Lv Zheng <lv.zheng@intel.com>, "lenb @ kernel . org" <lenb@kernel.org>, LKML <linux-kernel@vger.kernel.org>, linux-pci@vger.kernel.org, linux-acpi@vger.kernel.org, "x86 @ kernel . org" <x86@kernel.org>, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org

Use common ACPI resource parsing interface to parse ACPI resources for
PCI host bridge, so we could share more code between IA64 and x86.
Later we will consolidate arch specific implementations into ACPI core.

Tested-by: Tony Luck <tony.luck@intel.com>
Signed-off-by: Jiang Liu <jiang.liu@linux.intel.com>
---
 arch/ia64/pci/pci.c |  414 ++++++++++++++++++++++++---------------------------
 1 file changed, 193 insertions(+), 221 deletions(-)

diff --git a/arch/ia64/pci/pci.c b/arch/ia64/pci/pci.c
index d4e162d35b34..23689d4c37ae 100644
--- a/arch/ia64/pci/pci.c
+++ b/arch/ia64/pci/pci.c
@@ -115,29 +115,12 @@ struct pci_ops pci_root_ops = {
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
+	struct pci_controller controller;
 	struct acpi_device *bridge;
-	struct pci_controller *controller;
 	struct list_head resources;
-	struct resource *res;
-	resource_size_t *res_offset;
-	unsigned int res_num;
 	struct list_head io_resources;
-	char *name;
+	char name[16];
 };
 
 static unsigned int
@@ -168,11 +151,11 @@ new_space (u64 phys_base, int sparse)
 	return i;
 }
 
-static u64 add_io_space(struct pci_root_info *info,
-			struct acpi_resource_address64 *addr)
+static int add_io_space(struct device *dev, struct pci_root_info *info,
+			struct resource_entry *entry)
 {
 	struct iospace_resource *iospace;
-	struct resource *resource;
+	struct resource *resource, *res = entry->res;
 	char *name;
 	unsigned long base, min, max, base_port;
 	unsigned int sparse = 0, space_nr, len;
@@ -180,27 +163,24 @@ static u64 add_io_space(struct pci_root_info *info,
 	len = strlen(info->name) + 32;
 	iospace = kzalloc(sizeof(*iospace) + len, GFP_KERNEL);
 	if (!iospace) {
-		dev_err(&info->bridge->dev,
-				"PCI: No memory for %s I/O port space\n",
-				info->name);
-		goto out;
+		dev_err(dev, "PCI: No memory for %s I/O port space\n",
+			info->name);
+		return -ENOMEM;
 	}
 
-	name = (char *)(iospace + 1);
-
-	min = addr->address.minimum;
-	max = min + addr->address.address_length - 1;
-	if (addr->info.io.translation_type = ACPI_SPARSE_TRANSLATION)
+	if (res->flags & IORESOURCE_IO_SPARSE)
 		sparse = 1;
-
-	space_nr = new_space(addr->address.translation_offset, sparse);
+	space_nr = new_space(entry->offset, sparse);
 	if (space_nr = ~0)
 		goto free_resource;
 
+	name = (char *)(iospace + 1);
+	min = res->start - entry->offset;
+	max = res->end - entry->offset;
 	base = __pa(io_space[space_nr].mmio_base);
 	base_port = IO_SPACE_BASE(space_nr);
 	snprintf(name, len, "%s I/O Ports %08lx-%08lx", info->name,
-		base_port + min, base_port + max);
+		 base_port + min, base_port + max);
 
 	/*
 	 * The SDM guarantees the legacy 0-64K space is sparse, but if the
@@ -216,153 +196,195 @@ static u64 add_io_space(struct pci_root_info *info,
 	resource->start = base + (sparse ? IO_SPACE_SPARSE_ENCODING(min) : min);
 	resource->end   = base + (sparse ? IO_SPACE_SPARSE_ENCODING(max) : max);
 	if (insert_resource(&iomem_resource, resource)) {
-		dev_err(&info->bridge->dev,
-				"can't allocate host bridge io space resource  %pR\n",
-				resource);
+		dev_err(dev,
+			"can't allocate host bridge io space resource  %pR\n",
+			resource);
 		goto free_resource;
 	}
 
+	entry->offset = base_port;
+	res->start = min + base_port;
+	res->end = max + base_port;
 	list_add_tail(&iospace->list, &info->io_resources);
-	return base_port;
+
+	return 0;
 
 free_resource:
 	kfree(iospace);
-out:
-	return ~0;
+	return -ENOSPC;
+}
+
+/*
+ * An IO port or MMIO resource assigned to a PCI host bridge may be
+ * consumed by the host bridge itself or available to its child
+ * bus/devices. The ACPI specification defines a bit (Producer/Consumer)
+ * to tell whether the resource is consumed by the host bridge itself,
+ * but firmware hasn't used that bit consistently, so we can't rely on it.
+ *
+ * On x86 and IA64 platforms, all IO port and MMIO resources are assumed
+ * to be available to child bus/devices except one special case:
+ *     IO port [0xCF8-0xCFF] is consumed by the host bridge itself
+ *     to access PCI configuration space.
+ *
+ * So explicitly filter out PCI CFG IO ports[0xCF8-0xCFF].
+ */
+static bool resource_is_pcicfg_ioport(struct resource *res)
+{
+	return (res->flags & IORESOURCE_IO) &&
+		res->start = 0xCF8 && res->end = 0xCFF;
 }
 
-static acpi_status resource_to_window(struct acpi_resource *resource,
-				      struct acpi_resource_address64 *addr)
+static int
+probe_pci_root_info(struct pci_root_info *info, struct acpi_device *device,
+		    int busnum, int domain)
 {
-	acpi_status status;
+	int ret;
+	struct list_head *list = &info->resources;
+	struct resource_entry *entry, *tmp;
 
-	/*
-	 * We're only interested in _CRS descriptors that are
-	 *	- address space descriptors for memory or I/O space
-	 *	- non-zero size
-	 */
-	status = acpi_resource_to_address64(resource, addr);
-	if (ACPI_SUCCESS(status) &&
-	    (addr->resource_type = ACPI_MEMORY_RANGE ||
-	     addr->resource_type = ACPI_IO_RANGE) &&
-	    addr->address.address_length)
-		return AE_OK;
-
-	return AE_ERROR;
-}
-
-static acpi_status count_window(struct acpi_resource *resource, void *data)
-{
-	unsigned int *windows = (unsigned int *) data;
-	struct acpi_resource_address64 addr;
-	acpi_status status;
-
-	status = resource_to_window(resource, &addr);
-	if (ACPI_SUCCESS(status))
-		(*windows)++;
-
-	return AE_OK;
-}
-
-static acpi_status add_window(struct acpi_resource *res, void *data)
-{
-	struct pci_root_info *info = data;
-	struct resource *resource;
-	struct acpi_resource_address64 addr;
-	acpi_status status;
-	unsigned long flags, offset = 0;
-	struct resource *root;
-
-	/* Return AE_OK for non-window resources to keep scanning for more */
-	status = resource_to_window(res, &addr);
-	if (!ACPI_SUCCESS(status))
-		return AE_OK;
-
-	if (addr.resource_type = ACPI_MEMORY_RANGE) {
-		flags = IORESOURCE_MEM;
-		root = &iomem_resource;
-		offset = addr.address.translation_offset;
-	} else if (addr.resource_type = ACPI_IO_RANGE) {
-		flags = IORESOURCE_IO;
-		root = &ioport_resource;
-		offset = add_io_space(info, &addr);
-		if (offset = ~0)
-			return AE_OK;
-	} else
-		return AE_OK;
-
-	resource = &info->res[info->res_num];
-	resource->name = info->name;
-	resource->flags = flags;
-	resource->start = addr.address.minimum + offset;
-	resource->end = resource->start + addr.address.address_length - 1;
-	info->res_offset[info->res_num] = offset;
-
-	if (insert_resource(root, resource)) {
-		dev_err(&info->bridge->dev,
-			"can't allocate host bridge window %pR\n",
-			resource);
-	} else {
-		if (offset)
-			dev_info(&info->bridge->dev, "host bridge window %pR "
-				 "(PCI address [%#llx-%#llx])\n",
-				 resource,
-				 resource->start - offset,
-				 resource->end - offset);
-		else
-			dev_info(&info->bridge->dev,
-				 "host bridge window %pR\n", resource);
-	}
-	/* HP's firmware has a hack to work around a Windows bug.
-	 * Ignore these tiny memory ranges */
-	if (!((resource->flags & IORESOURCE_MEM) &&
-	      (resource->end - resource->start < 16)))
-		pci_add_resource_offset(&info->resources, resource,
-					info->res_offset[info->res_num]);
+	ret = acpi_dev_get_resources(device, list,
+				     acpi_dev_filter_resource_type_cb,
+				     (void *)(IORESOURCE_IO | IORESOURCE_MEM));
+	if (ret < 0)
+		dev_warn(&device->dev,
+			 "failed to parse _CRS method, error code %d\n", ret);
+	else if (ret = 0)
+		dev_dbg(&device->dev,
+			"no IO and memory resources present in _CRS\n");
+	else
+		resource_list_for_each_entry_safe(entry, tmp, list) {
+			if ((entry->res->flags & IORESOURCE_DISABLED) ||
+			    resource_is_pcicfg_ioport(entry->res))
+				resource_list_destroy_entry(entry);
+			else
+				entry->res->name = info->name;
+		}
 
-	info->res_num++;
-	return AE_OK;
+	return ret;
 }
 
-static void free_pci_root_info_res(struct pci_root_info *info)
-{
-	struct iospace_resource *iospace, *tmp;
+static void validate_resources(struct device *dev, struct list_head *resources,
+			       unsigned long type)
+{
+	LIST_HEAD(list);
+	struct resource *res1, *res2, *root = NULL;
+	struct resource_entry *tmp, *entry, *entry2;
+
+	BUG_ON((type & (IORESOURCE_MEM | IORESOURCE_IO)) = 0);
+	root = (type & IORESOURCE_MEM) ? &iomem_resource : &ioport_resource;
+
+	list_splice_init(resources, &list);
+	resource_list_for_each_entry_safe(entry, tmp, &list) {
+		bool free = false;
+		resource_size_t end;
+
+		res1 = entry->res;
+		if (!(res1->flags & type))
+			goto next;
+
+		/* Exclude non-addressable range or non-addressable portion */
+		end = min(res1->end, root->end);
+		if (end <= res1->start) {
+			dev_info(dev, "host bridge window %pR (ignored, not CPU addressable)\n",
+				 res1);
+			free = true;
+			goto next;
+		} else if (res1->end != end) {
+			dev_info(dev, "host bridge window %pR ([%#llx-%#llx] ignored, not CPU addressable)\n",
+				 res1, (unsigned long long)end + 1,
+				 (unsigned long long)res1->end);
+			res1->end = end;
+		}
 
-	list_for_each_entry_safe(iospace, tmp, &info->io_resources, list)
-		kfree(iospace);
+		resource_list_for_each_entry(entry2, resources) {
+			res2 = entry2->res;
+			if (!(res2->flags & type))
+				continue;
+
+			/*
+			 * I don't like throwing away windows because then
+			 * our resources no longer match the ACPI _CRS, but
+			 * the kernel resource tree doesn't allow overlaps.
+			 */
+			if (resource_overlaps(res1, res2)) {
+				res2->start = min(res1->start, res2->start);
+				res2->end = max(res1->end, res2->end);
+				dev_info(dev, "host bridge window expanded to %pR; %pR ignored\n",
+					 res2, res1);
+				free = true;
+				goto next;
+			}
+		}
 
-	kfree(info->name);
-	kfree(info->res);
-	info->res = NULL;
-	kfree(info->res_offset);
-	info->res_offset = NULL;
-	info->res_num = 0;
-	kfree(info->controller);
-	info->controller = NULL;
+next:
+		resource_list_del(entry);
+		if (free)
+			resource_list_free_entry(entry);
+		else
+			resource_list_add_tail(entry, resources);
+	}
+}
+
+static void add_resources(struct pci_root_info *info, struct device *dev)
+{
+	struct resource_entry *entry, *tmp;
+	struct resource *res, *conflict, *root = NULL;
+	struct list_head *list = &info->resources;
+
+	validate_resources(dev, list, IORESOURCE_MEM);
+	validate_resources(dev, list, IORESOURCE_IO);
+
+	resource_list_for_each_entry_safe(entry, tmp, list) {
+		res = entry->res;
+		if (res->flags & IORESOURCE_MEM) {
+			root = &iomem_resource;
+			/*
+			 * HP's firmware has a hack to work around a Windows
+			 * bug. Ignore these tiny memory ranges.
+			 */
+			if (resource_size(res) <= 16) {
+				resource_list_destroy_entry(entry);
+				continue;
+			}
+		} else if (res->flags & IORESOURCE_IO) {
+			root = &ioport_resource;
+			if (add_io_space(&info->bridge->dev, info, entry)) {
+				resource_list_destroy_entry(entry);
+				continue;
+			}
+		} else {
+			BUG_ON(res);
+		}
+
+		conflict = insert_resource_conflict(root, res);
+		if (conflict) {
+			dev_info(dev,
+				 "ignoring host bridge window %pR (conflicts with %s %pR)\n",
+				 res, conflict->name, conflict);
+			resource_list_destroy_entry(entry);
+		}
+	}
 }
 
 static void __release_pci_root_info(struct pci_root_info *info)
 {
-	int i;
 	struct resource *res;
-	struct iospace_resource *iospace;
+	struct iospace_resource *iospace, *tmp;
+	struct resource_entry *entry, *tentry;
 
-	list_for_each_entry(iospace, &info->io_resources, list)
+	list_for_each_entry_safe(iospace, tmp, &info->io_resources, list) {
 		release_resource(&iospace->res);
+		kfree(iospace);
+	}
 
-	for (i = 0; i < info->res_num; i++) {
-		res = &info->res[i];
-
-		if (!res->parent)
-			continue;
-
-		if (!(res->flags & (IORESOURCE_MEM | IORESOURCE_IO)))
-			continue;
-
-		release_resource(res);
+	resource_list_for_each_entry_safe(entry, tentry, &info->resources) {
+		res = entry->res;
+		if (res->parent &&
+		    (res->flags & (IORESOURCE_MEM | IORESOURCE_IO)))
+			release_resource(res);
+		resource_list_destroy_entry(entry);
 	}
 
-	free_pci_root_info_res(info);
 	kfree(info);
 }
 
@@ -373,99 +395,49 @@ static void release_pci_root_info(struct pci_host_bridge *bridge)
 	__release_pci_root_info(info);
 }
 
-static int
-probe_pci_root_info(struct pci_root_info *info, struct acpi_device *device,
-		int busnum, int domain)
-{
-	char *name;
-
-	name = kmalloc(16, GFP_KERNEL);
-	if (!name)
-		return -ENOMEM;
-
-	sprintf(name, "PCI Bus %04x:%02x", domain, busnum);
-	info->bridge = device;
-	info->name = name;
-
-	acpi_walk_resources(device->handle, METHOD_NAME__CRS, count_window,
-			&info->res_num);
-	if (info->res_num) {
-		info->res -			kzalloc_node(sizeof(*info->res) * info->res_num,
-				     GFP_KERNEL, info->controller->node);
-		if (!info->res) {
-			kfree(name);
-			return -ENOMEM;
-		}
-
-		info->res_offset -			kzalloc_node(sizeof(*info->res_offset) * info->res_num,
-					GFP_KERNEL, info->controller->node);
-		if (!info->res_offset) {
-			kfree(name);
-			kfree(info->res);
-			info->res = NULL;
-			return -ENOMEM;
-		}
-
-		info->res_num = 0;
-		acpi_walk_resources(device->handle, METHOD_NAME__CRS,
-			add_window, info);
-	} else
-		kfree(name);
-
-	return 0;
-}
-
 struct pci_bus *pci_acpi_scan_root(struct acpi_pci_root *root)
 {
 	struct acpi_device *device = root->device;
 	int domain = root->segment;
 	int bus = root->secondary.start;
-	struct pci_controller *controller;
-	struct pci_root_info *info = NULL;
-	int busnum = root->secondary.start;
+	struct pci_root_info *info;
 	struct pci_bus *pbus;
 	int ret;
 
-	controller = alloc_pci_controller(domain);
-	if (!controller)
-		return NULL;
-
-	controller->companion = device;
-	controller->node = acpi_get_node(device->handle);
-
 	info = kzalloc(sizeof(*info), GFP_KERNEL);
 	if (!info) {
 		dev_err(&device->dev,
-				"pci_bus %04x:%02x: ignored (out of memory)\n",
-				domain, busnum);
-		kfree(controller);
+			"pci_bus %04x:%02x: ignored (out of memory)\n",
+			domain, bus);
 		return NULL;
 	}
 
-	info->controller = controller;
-	INIT_LIST_HEAD(&info->io_resources);
+	info->controller.segment = domain;
+	info->controller.companion = device;
+	info->controller.node = acpi_get_node(device->handle);
+	info->bridge = device;
 	INIT_LIST_HEAD(&info->resources);
+	INIT_LIST_HEAD(&info->io_resources);
+	snprintf(info->name, sizeof(info->name),
+		 "PCI Bus %04x:%02x", domain, bus);
 
-	ret = probe_pci_root_info(info, device, busnum, domain);
-	if (ret) {
-		kfree(info->controller);
+	ret = probe_pci_root_info(info, device, bus, domain);
+	if (ret <= 0) {
 		kfree(info);
 		return NULL;
 	}
-	/* insert busn resource at first */
+	add_resources(info, &info->bridge->dev);
 	pci_add_resource(&info->resources, &root->secondary);
+
 	/*
 	 * See arch/x86/pci/acpi.c.
 	 * The desired pci bus might already be scanned in a quirk. We
 	 * should handle the case here, but it appears that IA64 hasn't
 	 * such quirk. So we just ignore the case now.
 	 */
-	pbus = pci_create_root_bus(NULL, bus, &pci_root_ops, controller,
-				   &info->resources);
+	pbus = pci_create_root_bus(NULL, bus, &pci_root_ops,
+				   &info->controller, &info->resources);
 	if (!pbus) {
-		pci_free_resource_list(&info->resources);
 		__release_pci_root_info(info);
 		return NULL;
 	}
-- 
1.7.10.4

