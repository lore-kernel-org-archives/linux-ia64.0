From: Matthew Wilcox <matthew@wil.cx>
Date: Wed, 19 Jan 2005 14:34:54 +0000
Subject: [PATCH] PCI root busses need resources
Message-Id: <20050119143454.GB25940@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Using the generic setup-bus.c code currently fails on HP's Integrity
servers because the root busses have their resources set to the whole
of ioport space and the whole of iomem space, instead of just the ranges
that are routed to that particular bus.

This patch uses the resources in the pci_windows to provide the ranges
to each PCI root bus.  In order to do that, I had to change them from
being bus addresses to system addresses.

Signed-off-by: Matthew Wilcox <matthew@wil.cx>

Index: linux-2.6/arch/ia64/pci/pci.c
=================================RCS file: /var/cvs/linux-2.6/arch/ia64/pci/pci.c,v
retrieving revision 1.18
diff -u -p -r1.18 pci.c
--- linux-2.6/arch/ia64/pci/pci.c	12 Jan 2005 20:15:26 -0000	1.18
+++ linux-2.6/arch/ia64/pci/pci.c	19 Jan 2005 14:26:00 -0000
@@ -187,30 +187,6 @@ alloc_pci_controller (int seg)
 	return controller;
 }
 
-static int __devinit
-alloc_resource (char *name, struct resource *root, unsigned long start, unsigned long end,
-		unsigned long flags)
-{
-	struct resource *res;
-
-	res = kmalloc(sizeof(*res), GFP_KERNEL);
-	if (!res)
-		return -ENOMEM;
-
-	memset(res, 0, sizeof(*res));
-	res->name = name;
-	res->start = start;
-	res->end = end;
-	res->flags = flags;
-
-	if (insert_resource(root, res))	{
-		kfree(res);
-		return -EBUSY;
-	}
-
-	return 0;
-}
-
 static u64 __devinit
 add_io_space (struct acpi_resource_address64 *addr)
 {
@@ -263,10 +239,9 @@ struct pci_root_info {
 	char *name;
 };
 
-static acpi_status __devinit
-add_window (struct acpi_resource *res, void *data)
+static __devinit acpi_status add_window(struct acpi_resource *res, void *data)
 {
-	struct pci_root_info *info = (struct pci_root_info *) data;
+	struct pci_root_info *info = data;
 	struct pci_window *window;
 	struct acpi_resource_address64 addr;
 	acpi_status status;
@@ -274,45 +249,71 @@ add_window (struct acpi_resource *res, v
 	struct resource *root;
 
 	status = acpi_resource_to_address64(res, &addr);
-	if (ACPI_SUCCESS(status)) {
-		if (!addr.address_length)
-			return AE_OK;
+	if (!ACPI_SUCCESS(status))
+		return AE_OK;
 
-		if (addr.resource_type = ACPI_MEMORY_RANGE) {
-			flags = IORESOURCE_MEM;
-			root = &iomem_resource;
-			offset = addr.address_translation_offset;
-		} else if (addr.resource_type = ACPI_IO_RANGE) {
-			flags = IORESOURCE_IO;
-			root = &ioport_resource;
-			offset = add_io_space(&addr);
-			if (offset = ~0)
-				return AE_OK;
-		} else
+	if (!addr.address_length)
+		return AE_OK;
+
+	if (addr.resource_type = ACPI_MEMORY_RANGE) {
+		flags = IORESOURCE_MEM;
+		root = &iomem_resource;
+		offset = addr.address_translation_offset;
+	} else if (addr.resource_type = ACPI_IO_RANGE) {
+		flags = IORESOURCE_IO;
+		root = &ioport_resource;
+		offset = add_io_space(&addr);
+		if (offset = ~0)
 			return AE_OK;
+	} else
+		return AE_OK;
 
-		window = &info->controller->window[info->controller->windows++];
-		window->resource.flags	= flags;
-		window->resource.start  = addr.min_address_range;
-		window->resource.end    = addr.max_address_range;
-		window->offset		= offset;
-
-		if (alloc_resource(info->name, root, addr.min_address_range + offset,
-			addr.max_address_range + offset, flags))
-			printk(KERN_ERR "alloc 0x%lx-0x%lx from %s for %s failed\n",
-				addr.min_address_range + offset, addr.max_address_range + offset,
-				root->name, info->name);
+	window = &info->controller->window[info->controller->windows++];
+	window->resource.name = info->name;
+	window->resource.flags = flags;
+	window->resource.start = addr.min_address_range + offset;
+	window->resource.end = addr.max_address_range + offset;
+	window->resource.child = NULL;
+	window->offset = offset;
+
+	if (insert_resource(root, &window->resource)) {
+		printk(KERN_ERR "alloc 0x%lx-0x%lx from %s for %s failed\n",
+			window->resource.start, window->resource.end,
+			root->name, info->name);
 	}
 
 	return AE_OK;
 }
 
+static void __devinit
+pcibios_setup_root_windows(struct pci_bus *bus, struct pci_controller *ctrl)
+{
+	int i, j;
+
+	j = 0;
+	for (i = 0; i < ctrl->windows; i++) {
+		struct resource *res = &ctrl->window[i].resource;
+		/* HP's firmware has a hack to work around a Windows bug.
+		 * Ignore these tiny memory ranges */
+		if ((res->flags & IORESOURCE_MEM) &&
+		    (res->end - res->start < 16))
+			continue;
+		if (j >= PCI_BUS_NUM_RESOURCES) {
+			printk("Ignoring range [%lx-%lx] (%lx)\n", res->start,
+					res->end, res->flags);
+			continue;
+		}
+		bus->resource[j++] = res;
+	}
+}
+
 struct pci_bus * __devinit
-pci_acpi_scan_root (struct acpi_device *device, int domain, int bus)
+pci_acpi_scan_root(struct acpi_device *device, int domain, int bus)
 {
 	struct pci_root_info info;
 	struct pci_controller *controller;
 	unsigned int windows = 0;
+	struct pci_bus *pbus;
 	char *name;
 
 	controller = alloc_pci_controller(domain);
@@ -321,8 +322,10 @@ pci_acpi_scan_root (struct acpi_device *
 
 	controller->acpi_handle = device->handle;
 
-	acpi_walk_resources(device->handle, METHOD_NAME__CRS, count_window, &windows);
-	controller->window = kmalloc(sizeof(*controller->window) * windows, GFP_KERNEL);
+	acpi_walk_resources(device->handle, METHOD_NAME__CRS, count_window,
+			&windows);
+	controller->window = kmalloc(sizeof(*controller->window) * windows,
+			GFP_KERNEL);
 	if (!controller->window)
 		goto out2;
 
@@ -333,9 +336,14 @@ pci_acpi_scan_root (struct acpi_device *
 	sprintf(name, "PCI Bus %04x:%02x", domain, bus);
 	info.controller = controller;
 	info.name = name;
-	acpi_walk_resources(device->handle, METHOD_NAME__CRS, add_window, &info);
+	acpi_walk_resources(device->handle, METHOD_NAME__CRS, add_window,
+			&info);
+
+	pbus = pci_scan_bus(bus, &pci_root_ops, controller);
+	if (pbus)
+		pcibios_setup_root_windows(pbus, controller);
 
-	return pci_scan_bus(bus, &pci_root_ops, controller);
+	return pbus;
 
 out3:
 	kfree(controller->window);
@@ -356,9 +364,9 @@ void pcibios_resource_to_bus(struct pci_
 		struct pci_window *window = &controller->window[i];
 		if (!(window->resource.flags & res->flags))
 			continue;
-		if (window->resource.start > res->start - window->offset)
+		if (window->resource.start > res->start)
 			continue;
-		if (window->resource.end < res->end - window->offset)
+		if (window->resource.end < res->end)
 			continue;
 		offset = window->offset;
 		break;
@@ -379,9 +387,9 @@ void pcibios_bus_to_resource(struct pci_
 		struct pci_window *window = &controller->window[i];
 		if (!(window->resource.flags & res->flags))
 			continue;
-		if (window->resource.start > region->start)
+		if (window->resource.start - window->offset > region->start)
 			continue;
-		if (window->resource.end < region->end)
+		if (window->resource.end - window->offset < region->end)
 			continue;
 		offset = window->offset;
 		break;

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
