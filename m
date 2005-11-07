From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Mon, 07 Nov 2005 22:13:59 +0000
Subject: [PATCH] ia64: add the MMIO regions that are translated to I/O port space to /proc/iomem
Message-Id: <200511071513.59565.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

ia64 translates normal loads and stores to special MMIO regions into I/O port
accesses.  Reserve these special MMIO regions in /proc/iomem.

Sample /proc/iomem:
    f8100000000-f81003fffff : PCI Bus 0000:80 I/O Ports 00000000-00000fff
    f8100400000-f81007fffff : PCI Bus 0000:8e I/O Ports 00001000-00001fff
    f8100800000-f8100ffffff : PCI Bus 0000:9c I/O Ports 00002000-00003fff
    f8101000000-f81017fffff : PCI Bus 0000:aa I/O Ports 00004000-00005fff

and corresponding /proc/ioports:
    00000000-00000fff : PCI Bus 0000:80
    00001000-00001fff : PCI Bus 0000:8e
    00002000-00003fff : PCI Bus 0000:9c
    00004000-00005fff : PCI Bus 0000:aa

Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>

Index: work4/arch/ia64/pci/pci.c
=================================--- work4.orig/arch/ia64/pci/pci.c	2005-10-13 15:41:39.000000000 -0600
+++ work4/arch/ia64/pci/pci.c	2005-10-20 14:53:42.000000000 -0600
@@ -95,7 +95,7 @@
 }
 
 static struct pci_raw_ops pci_sal_ops = {
-	.read = 	pci_sal_read,
+	.read =		pci_sal_read,
 	.write =	pci_sal_write
 };
 
@@ -137,35 +137,98 @@
 	return controller;
 }
 
-static u64 __devinit
-add_io_space (struct acpi_resource_address64 *addr)
+struct pci_root_info {
+	struct pci_controller *controller;
+	char *name;
+};
+
+static unsigned int
+new_space (u64 phys_base, int sparse)
 {
-	u64 offset;
-	int sparse = 0;
+	u64 mmio_base;
 	int i;
 
-	if (addr->address_translation_offset = 0)
-		return IO_SPACE_BASE(0);	/* part of legacy IO space */
+	if (phys_base = 0)
+		return 0;	/* legacy I/O port space */
 
-	if (addr->attribute.io.translation_attribute = ACPI_SPARSE_TRANSLATION)
-		sparse = 1;
-
-	offset = (u64) ioremap(addr->address_translation_offset, 0);
+	mmio_base = (u64) ioremap(phys_base, 0);
 	for (i = 0; i < num_io_spaces; i++)
-		if (io_space[i].mmio_base = offset &&
+		if (io_space[i].mmio_base = mmio_base &&
 		    io_space[i].sparse = sparse)
-			return IO_SPACE_BASE(i);
+			return i;
 
 	if (num_io_spaces = MAX_IO_SPACES) {
-		printk("Too many IO port spaces\n");
+		printk(KERN_ERR "PCI: Too many IO port spaces "
+			"(MAX_IO_SPACES=%lu)\n", MAX_IO_SPACES);
 		return ~0;
 	}
 
 	i = num_io_spaces++;
-	io_space[i].mmio_base = offset;
+	io_space[i].mmio_base = mmio_base;
 	io_space[i].sparse = sparse;
 
-	return IO_SPACE_BASE(i);
+	return i;
+}
+
+static u64 __devinit
+add_io_space (struct pci_root_info *info, struct acpi_resource_address64 *addr)
+{
+	struct resource *resource;
+	char *name;
+	u64 base, min, max, base_port;
+	unsigned int sparse = 0, space_nr, len;
+
+	resource = kzalloc(sizeof(*resource), GFP_KERNEL);
+	if (!resource) {
+		printk(KERN_ERR "PCI: No memory for %s I/O port space\n",
+			info->name);
+		goto out;
+	}
+
+	len = strlen(info->name) + 32;
+	name = kzalloc(len, GFP_KERNEL);
+	if (!name) {
+		printk(KERN_ERR "PCI: No memory for %s I/O port space name\n",
+			info->name);
+		goto free_resource;
+	}
+
+	min = addr->min_address_range;
+	max = min + addr->address_length - 1;
+	if (addr->attribute.io.translation_attribute = ACPI_SPARSE_TRANSLATION)
+		sparse = 1;
+
+	space_nr = new_space(addr->address_translation_offset, sparse);
+	if (space_nr = ~0)
+		goto free_name;
+
+	base = __pa(io_space[space_nr].mmio_base);
+	base_port = IO_SPACE_BASE(space_nr);
+	snprintf(name, len, "%s I/O Ports %08lx-%08lx", info->name,
+		base_port + min, base_port + max);
+
+	/*
+	 * The SDM guarantees the legacy 0-64K space is sparse, but if the
+	 * mapping is done by the processor (not the bridge), ACPI may not
+	 * mark it as sparse.
+	 */
+	if (space_nr = 0)
+		sparse = 1;
+
+	resource->name  = name;
+	resource->flags = IORESOURCE_MEM;
+	resource->start = base + (sparse ? IO_SPACE_SPARSE_ENCODING(min) : min);
+	resource->end   = base + (sparse ? IO_SPACE_SPARSE_ENCODING(max) : max);
+	insert_resource(&iomem_resource, resource);
+
+	return base_port;
+
+free_name:
+	kfree(name);
+free_resource:
+	kfree(resource);
+out:
+	return ~0;
 }
 
 static acpi_status __devinit resource_to_window(struct acpi_resource *resource,
@@ -205,11 +268,6 @@
 	return AE_OK;
 }
 
-struct pci_root_info {
-	struct pci_controller *controller;
-	char *name;
-};
-
 static __devinit acpi_status add_window(struct acpi_resource *res, void *data)
 {
 	struct pci_root_info *info = data;
@@ -231,7 +289,7 @@
 	} else if (addr.resource_type = ACPI_IO_RANGE) {
 		flags = IORESOURCE_IO;
 		root = &ioport_resource;
-		offset = add_io_space(&addr);
+		offset = add_io_space(info, &addr);
 		if (offset = ~0)
 			return AE_OK;
 	} else
@@ -241,7 +299,7 @@
 	window->resource.name = info->name;
 	window->resource.flags = flags;
 	window->resource.start = addr.min_address_range + offset;
-	window->resource.end = addr.max_address_range + offset;
+	window->resource.end = window->resource.start + addr.address_length - 1;
 	window->resource.child = NULL;
 	window->offset = offset;
 
@@ -739,7 +797,7 @@
 {
 	int count = nr_released;
 
- 	count += (IA64_LAST_DEVICE_VECTOR - last);
+	count += (IA64_LAST_DEVICE_VECTOR - last);
 
 	return count;
 }
