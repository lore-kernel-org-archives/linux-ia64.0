From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Thu, 24 Apr 2003 22:25:41 +0000
Subject: [Linux-ia64] [PATCH] 2/4 multi-ioport space support for 2.5
Message-Id: <marc-linux-ia64-105590723705600@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

diff -u -ur linux-2.5.67-ia64-030416-io1/arch/ia64/pci/pci.c linux-2.5.67-ia64-030416-io2/arch/ia64/pci/pci.c
--- linux-2.5.67-ia64-030416-io1/arch/ia64/pci/pci.c	2003-04-24 10:10:58.000000000 -0600
+++ linux-2.5.67-ia64-030416-io2/arch/ia64/pci/pci.c	2003-04-24 12:36:53.000000000 -0600
@@ -116,24 +116,31 @@
 
 subsys_initcall(pci_acpi_init);
 
-static void __init
-pcibios_fixup_resource(struct resource *res, u64 offset)
-{
-	res->start += offset;
-	res->end += offset;
-}
-
 void __init
-pcibios_fixup_device_resources(struct pci_dev *dev, struct pci_bus *bus)
+pcibios_fixup_device_resources (struct pci_dev *dev, struct pci_bus *bus)
 {
-	int i;
+	struct pci_controller *controller = PCI_CONTROLLER(dev);
+	struct pci_window *window;
+	int i, j;
 
 	for (i = 0; i < PCI_NUM_RESOURCES; i++) {
 		if (!dev->resource[i].start)
 			continue;
-		if (dev->resource[i].flags & IORESOURCE_MEM)
-			pcibios_fixup_resource(&dev->resource[i],
-			                       PCI_CONTROLLER(dev)->mem_offset);
+
+#define contains(win, res)	((res)->start >= (win)->start && \
+				 (res)->end   <= (win)->end)
+
+		for (j = 0; j < controller->windows; j++) {
+			window = &controller->window[j];
+			if (((dev->resource[i].flags & IORESOURCE_MEM &&
+			      window->resource.flags & IORESOURCE_MEM) ||
+			     (dev->resource[i].flags & IORESOURCE_IO &&
+			      window->resource.flags & IORESOURCE_IO)) &&
+			    contains(&window->resource, &dev->resource[i])) {
+				dev->resource[i].start += window->offset;
+				dev->resource[i].end   += window->offset;
+			}
+		}
 	}
 }
 
@@ -184,23 +191,127 @@
 	return b;
 }
 
+static u64
+add_io_space (struct acpi_resource_address64 *addr)
+{
+	u64 offset;
+	int sparse = 0;
+	int i;
+
+	if (addr->address_translation_offset = 0)
+		return IO_SPACE_BASE(0);	/* part of legacy IO space */
+
+	if (addr->attribute.io.translation_attribute = ACPI_SPARSE_TRANSLATION)
+		sparse = 1;
+
+	offset = (u64) ioremap(addr->address_translation_offset, 0);
+	for (i = 0; i < num_io_spaces; i++)
+		if (io_space[i].mmio_base = offset &&
+		    io_space[i].sparse = sparse)
+			return IO_SPACE_BASE(i);
+
+	if (num_io_spaces = MAX_IO_SPACES) {
+		printk("Too many IO port spaces\n");
+		return ~0;
+	}
+
+	i = num_io_spaces++;
+	io_space[i].mmio_base = offset;
+	io_space[i].sparse = sparse;
+
+	return IO_SPACE_BASE(i);
+}
+
+static acpi_status
+count_window (struct acpi_resource *resource, void *data)
+{
+	unsigned int *windows = (unsigned int *) data;
+	struct acpi_resource_address64 addr;
+	acpi_status status;
+
+	status = acpi_resource_to_address64(resource, &addr);
+	if (ACPI_SUCCESS(status))
+		if (addr.resource_type = ACPI_MEMORY_RANGE ||
+		    addr.resource_type = ACPI_IO_RANGE)
+			(*windows)++;
+
+	return AE_OK;
+}
+
+struct pci_root_info {
+	struct pci_controller *controller;
+	char *name;
+};
+
+static acpi_status
+add_window (struct acpi_resource *res, void *data)
+{
+	struct pci_root_info *info = (struct pci_root_info *) data;
+	struct pci_window *window;
+	struct acpi_resource_address64 addr;
+	acpi_status status;
+	unsigned long flags, offset = 0;
+
+	status = acpi_resource_to_address64(res, &addr);
+	if (ACPI_SUCCESS(status)) {
+		if (addr.resource_type = ACPI_MEMORY_RANGE) {
+			flags = IORESOURCE_MEM;
+			offset = addr.address_translation_offset;
+		} else if (addr.resource_type = ACPI_IO_RANGE) {
+			flags = IORESOURCE_IO;
+			offset = add_io_space(&addr);
+			if (offset = ~0)
+				return AE_OK;
+		} else
+			return AE_OK;
+
+		window = &info->controller->window[info->controller->windows++];
+		window->resource.flags |= flags;
+		window->resource.start  = addr.min_address_range;
+		window->resource.end    = addr.max_address_range;
+		window->offset		= offset;
+	}
+
+	return AE_OK;
+}
+
 struct pci_bus *
-pcibios_scan_root(void *handle, int seg, int bus)
+pcibios_scan_root (void *handle, int seg, int bus)
 {
+	struct pci_root_info info;
 	struct pci_controller *controller;
-	u64 base, size, offset;
+	unsigned int windows = 0;
+	char *name;
 
 	printk("PCI: Probing PCI hardware on bus (%02x:%02x)\n", seg, bus);
 	controller = alloc_pci_controller(seg);
 	if (!controller)
-		return NULL;
+		goto out1;
 
 	controller->acpi_handle = handle;
 
-	acpi_get_addr_space(handle, ACPI_MEMORY_RANGE, &base, &size, &offset);
-	controller->mem_offset = offset;
+	acpi_walk_resources(handle, METHOD_NAME__CRS, count_window, &windows);
+	controller->window = kmalloc(sizeof(*controller->window) * windows, GFP_KERNEL);
+	if (!controller->window)
+		goto out2;
+
+	name = kmalloc(16, GFP_KERNEL);
+	if (!name)
+		goto out3;
+
+	sprintf(name, "PCI Bus %02x:%02x", seg, bus);
+	info.controller = controller;
+	info.name = name;
+	acpi_walk_resources(handle, METHOD_NAME__CRS, add_window, &info);
 
 	return scan_root_bus(bus, pci_root_ops, controller);
+
+out3:
+	kfree(controller->window);
+out2:
+	kfree(controller);
+out1:
+	return NULL;
 }
 
 /*
diff -u -ur linux-2.5.67-ia64-030416-io1/include/asm-ia64/pci.h linux-2.5.67-ia64-030416-io2/include/asm-ia64/pci.h
--- linux-2.5.67-ia64-030416-io1/include/asm-ia64/pci.h	2003-04-24 10:10:58.000000000 -0600
+++ linux-2.5.67-ia64-030416-io2/include/asm-ia64/pci.h	2003-04-24 11:17:10.000000000 -0600
@@ -97,12 +97,18 @@
 extern int pci_mmap_page_range (struct pci_dev *dev, struct vm_area_struct *vma,
 				enum pci_mmap_state mmap_state, int write_combine);
 
+struct pci_window {
+	struct resource resource;
+	u64 offset;
+};
+
 struct pci_controller {
 	void *acpi_handle;
 	void *iommu;
 	int segment;
 
-	u64 mem_offset;
+	unsigned int windows;
+	struct pci_window *window;
 };
 
 #define PCI_CONTROLLER(busdev) ((struct pci_controller *) busdev->sysdata)


