From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Fri, 18 Feb 2005 23:10:27 +0000
Subject: [PATCH] ia64/pci/pci.c cosmetic cleanup
Message-Id: <1108768227.25491.41.camel@eeyore>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Rewrap a few long lines, add KERN_* and "PCI: " prefixes, etc.
No functional changes. 

Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>

=== arch/ia64/pci/pci.c 1.65 vs edited ==--- 1.65/arch/ia64/pci/pci.c	2005-01-12 11:08:48 -07:00
+++ edited/arch/ia64/pci/pci.c	2005-02-18 15:52:27 -07:00
@@ -198,8 +198,8 @@
 }
 
 static int __devinit
-alloc_resource (char *name, struct resource *root, unsigned long start, unsigned long end,
-		unsigned long flags)
+alloc_resource (char *name, struct resource *root, unsigned long start,
+		unsigned long end, unsigned long flags)
 {
 	struct resource *res;
 
@@ -241,7 +241,7 @@
 			return IO_SPACE_BASE(i);
 
 	if (num_io_spaces = MAX_IO_SPACES) {
-		printk("Too many IO port spaces\n");
+		printk(KERN_ERR "PCI: too many IO port spaces\n");
 		return ~0;
 	}
 
@@ -284,35 +284,38 @@
 	struct resource *root;
 
 	status = acpi_resource_to_address64(res, &addr);
-	if (ACPI_SUCCESS(status)) {
-		if (!addr.address_length)
-			return AE_OK;
+	if (!ACPI_SUCCESS(status))
+		return AE_OK;
+
+	if (!addr.address_length)
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
+	window = &info->controller->window[info->controller->windows++];
+	window->resource.flags	= flags;
+	window->resource.start  = addr.min_address_range;
+	window->resource.end    = addr.max_address_range;
+	window->offset		= offset;
 
-		if (alloc_resource(info->name, root, addr.min_address_range + offset,
+	if (alloc_resource(info->name, root, addr.min_address_range + offset,
 			addr.max_address_range + offset, flags))
-			printk(KERN_ERR "alloc 0x%lx-0x%lx from %s for %s failed\n",
-				addr.min_address_range + offset, addr.max_address_range + offset,
-				root->name, info->name);
-	}
+		printk(KERN_ERR
+			"PCI: alloc 0x%lx-0x%lx from %s for %s failed\n",
+			addr.min_address_range + offset,
+			addr.max_address_range + offset,
+			root->name, info->name);
 
 	return AE_OK;
 }
@@ -331,8 +334,10 @@
 
 	controller->acpi_handle = device->handle;
 
-	acpi_walk_resources(device->handle, METHOD_NAME__CRS, count_window, &windows);
-	controller->window = kmalloc(sizeof(*controller->window) * windows, GFP_KERNEL);
+	acpi_walk_resources(device->handle, METHOD_NAME__CRS, count_window,
+		&windows);
+	controller->window = kmalloc(sizeof(*controller->window) * windows,
+		GFP_KERNEL);
 	if (!controller->window)
 		goto out2;
 
@@ -343,7 +348,8 @@
 	sprintf(name, "PCI Bus %04x:%02x", domain, bus);
 	info.controller = controller;
 	info.name = name;
-	acpi_walk_resources(device->handle, METHOD_NAME__CRS, add_window, &info);
+	acpi_walk_resources(device->handle, METHOD_NAME__CRS, add_window,
+		&info);
 
 	return pci_scan_bus(bus, &pci_root_ops, controller);
 
@@ -460,9 +466,8 @@
 
 		r = &dev->resource[idx];
 		if (!r->start && r->end) {
-			printk(KERN_ERR
-			       "PCI: Device %s not available because of resource collisions\n",
-			       pci_name(dev));
+			printk(KERN_ERR "PCI: Device %s not available because "
+				"of resource collisions\n", pci_name(dev));
 			return -EINVAL;
 		}
 		if (r->flags & IORESOURCE_IO)
@@ -473,7 +478,8 @@
 	if (dev->resource[PCI_ROM_RESOURCE].start)
 		cmd |= PCI_COMMAND_MEMORY;
 	if (cmd != old_cmd) {
-		printk("PCI: Enabling device %s (%04x -> %04x)\n", pci_name(dev), old_cmd, cmd);
+		printk(KERN_DEBUG "PCI: Enabling device %s (%04x -> %04x)\n",
+			pci_name(dev), old_cmd, cmd);
 		pci_write_config_word(dev, PCI_COMMAND, cmd);
 	}
 	return 0;
@@ -686,16 +692,15 @@
 
 	status = ia64_pal_cache_summary(&levels, &unique_caches);
 	if (status != 0) {
-		printk(KERN_ERR "%s: ia64_pal_cache_summary() failed (status=%ld)\n",
-		       __FUNCTION__, status);
+		printk(KERN_ERR "%s: ia64_pal_cache_summary() failed "
+			"(status=%ld)\n", __FUNCTION__, status);
 		return SMP_CACHE_BYTES;
 	}
 
-	status = ia64_pal_cache_config_info(levels - 1, /* cache_type (data_or_unified)= */ 2,
-					    &cci);
+	status = ia64_pal_cache_config_info(levels - 1, 2, &cci);
 	if (status != 0) {
-		printk(KERN_ERR "%s: ia64_pal_cache_config_info() failed (status=%ld)\n",
-		       __FUNCTION__, status);
+		printk(KERN_ERR "%s: ia64_pal_cache_config_info() failed "
+			"(status=%ld)\n", __FUNCTION__, status);
 		return SMP_CACHE_BYTES;
 	}
 	cacheline_size = 1 << cci.pcci_line_size;
@@ -722,14 +727,17 @@
 	pci_read_config_byte(dev, PCI_CACHE_LINE_SIZE, &pci_linesize);
 	current_linesize = 4 * pci_linesize;
 	if (desired_linesize != current_linesize) {
-		printk(KERN_WARNING "PCI: slot %s has incorrect PCI cache line size of %lu bytes,",
-		       pci_name(dev), current_linesize);
+		printk(KERN_WARNING "PCI: slot %s has incorrect PCI cache "
+			"line size of %lu bytes,",
+			pci_name(dev),current_linesize);
 		if (current_linesize > desired_linesize) {
-			printk(" expected %lu bytes instead\n", desired_linesize);
+			printk(" expected %lu bytes instead\n",
+				desired_linesize);
 			rc = -EINVAL;
 		} else {
 			printk(" correcting to %lu\n", desired_linesize);
-			pci_write_config_byte(dev, PCI_CACHE_LINE_SIZE, desired_linesize / 4);
+			pci_write_config_byte(dev, PCI_CACHE_LINE_SIZE,
+				desired_linesize / 4);
 		}
 	}
 	return rc;


