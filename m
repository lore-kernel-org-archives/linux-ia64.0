From: Alex Williamson <alex_williamson@hp.com>
Date: Thu, 03 Apr 2003 17:51:38 +0000
Subject: [Linux-ia64] [PATCH] 2/4 pci segments
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------5F9837D71B3078EF7DD41FA5"
Message-Id: <marc-linux-ia64-105590723705394@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------5F9837D71B3078EF7DD41FA5
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit


   Patch 2 is an update to the PCI segment support that Bjorn posted
around 2.5.19ish.  Also against 2.5.64 + 030307.  Thanks,

	Alex

--
Alex Williamson                             HP Linux & Open Source Lab
--------------5F9837D71B3078EF7DD41FA5
Content-Type: text/plain; charset=us-ascii;
 name="patch-02.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-02.diff"

diff -urN linux-2.5.64/arch/ia64/kernel/acpi.c linux-work/arch/ia64/kernel/acpi.c
--- linux-2.5.64/arch/ia64/kernel/acpi.c	Tue Apr  1 08:49:07 2003
+++ linux-work/arch/ia64/kernel/acpi.c	Tue Apr  1 15:20:36 2003
@@ -109,8 +109,6 @@
 	return "sn2";
 # elif defined (CONFIG_IA64_DIG)
 	return "dig";
-# elif defined (CONFIG_IA64_HP_ZX1)
-	return "hpzx1";
 # else
 #	error Unknown platform.  Fix acpi.c.
 # endif
@@ -176,6 +174,73 @@
 	kfree(buf->pointer);
 }
 
+void
+acpi_get_crs_addr (struct acpi_buffer *buf, int type, u64 *base, u64 *size, u64 *tra)
+{
+	int offset = 0;
+	struct acpi_resource_address16 *addr16;
+	struct acpi_resource_address32 *addr32;
+	struct acpi_resource_address64 *addr64;
+
+	for (;;) {
+		struct acpi_resource *res = acpi_get_crs_next(buf, &offset);
+		if (!res)
+			return;
+		switch (res->id) {
+			case ACPI_RSTYPE_ADDRESS16:
+				addr16 = (struct acpi_resource_address16 *) &res->data;
+
+				if (type == addr16->resource_type) {
+					*base = addr16->min_address_range;
+					*size = addr16->address_length;
+					*tra = addr16->address_translation_offset;
+					return;
+				}
+				break;
+			case ACPI_RSTYPE_ADDRESS32:
+				addr32 = (struct acpi_resource_address32 *) &res->data;
+				if (type == addr32->resource_type) {
+					*base = addr32->min_address_range;
+					*size = addr32->address_length;
+					*tra = addr32->address_translation_offset;
+					return;
+				}
+				break;
+			case ACPI_RSTYPE_ADDRESS64:
+				addr64 = (struct acpi_resource_address64 *) &res->data;
+				if (type == addr64->resource_type) {
+					*base = addr64->min_address_range;
+					*size = addr64->address_length;
+					*tra = addr64->address_translation_offset;
+					return;
+				}
+				break;
+		}
+	}
+}
+
+int
+acpi_get_addr_space(void *obj, u8 type, u64 *base, u64 *length, u64 *tra)
+{
+	acpi_status status;
+	struct acpi_buffer buf;
+
+	*base = 0;
+	*length = 0;
+	*tra = 0;
+
+	status = acpi_get_crs((acpi_handle)obj, &buf);
+	if (ACPI_FAILURE(status)) {
+		printk(KERN_ERR PREFIX "Unable to get _CRS data on object\n");
+		return status;
+	}
+
+	acpi_get_crs_addr(&buf, type, base, length, tra);
+
+	acpi_dispose_crs(&buf);
+
+	return AE_OK;
+}
 #endif /* CONFIG_ACPI */
 
 #ifdef CONFIG_ACPI_BOOT
@@ -808,6 +873,7 @@
 
 	list_for_each(node, &acpi_prt.entries) {
 		entry = (struct acpi_prt_entry *)node;
+		vector[i].segment = entry->id.segment;
 		vector[i].bus    = entry->id.bus;
 		vector[i].pci_id = ((u32) entry->id.device << 16) | 0xffff;
 		vector[i].pin    = entry->pin;
diff -urN linux-2.5.64/arch/ia64/pci/pci.c linux-work/arch/ia64/pci/pci.c
--- linux-2.5.64/arch/ia64/pci/pci.c	Tue Apr  1 08:49:07 2003
+++ linux-work/arch/ia64/pci/pci.c	Tue Apr  1 09:19:53 2003
@@ -49,11 +49,13 @@
 /*
  * Low-level SAL-based PCI configuration access functions. Note that SAL
  * calls are already serialized (via sal_lock), so we don't need another
- * synchronization mechanism here.  Not using segment number (yet).
+ * synchronization mechanism here.
  */
 
-#define PCI_SAL_ADDRESS(bus, dev, fn, reg) \
-	((u64)(bus << 16) | (u64)(dev << 11) | (u64)(fn << 8) | (u64)(reg))
+#define PCI_SAL_ADDRESS(seg, bus, dev, fn, reg) \
+	((u64)(seg << 24) | (u64)(bus << 16) | \
+	 (u64)(dev << 11) | (u64)(fn << 8) | (u64)(reg))
+
 
 static int
 __pci_sal_read (int seg, int bus, int dev, int fn, int reg, int len, u32 *value)
@@ -61,10 +63,10 @@
 	int result = 0;
 	u64 data = 0;
 
-	if (!value || (bus > 255) || (dev > 31) || (fn > 7) || (reg > 255))
+	if (!value || (seg > 255) || (bus > 255) || (dev > 31) || (fn > 7) || (reg > 255))
 		return -EINVAL;
 
-	result = ia64_sal_pci_config_read(PCI_SAL_ADDRESS(bus, dev, fn, reg), len, &data);
+	result = ia64_sal_pci_config_read(PCI_SAL_ADDRESS(seg, bus, dev, fn, reg), len, &data);
 
 	*value = (u32) data;
 
@@ -74,24 +76,24 @@
 static int
 __pci_sal_write (int seg, int bus, int dev, int fn, int reg, int len, u32 value)
 {
-	if ((bus > 255) || (dev > 31) || (fn > 7) || (reg > 255))
+	if ((seg > 255) || (bus > 255) || (dev > 31) || (fn > 7) || (reg > 255))
 		return -EINVAL;
 
-	return ia64_sal_pci_config_write(PCI_SAL_ADDRESS(bus, dev, fn, reg), len, value);
+	return ia64_sal_pci_config_write(PCI_SAL_ADDRESS(seg, bus, dev, fn, reg), len, value);
 }
 
 
 static int
 pci_sal_read (struct pci_bus *bus, unsigned int devfn, int where, int size, u32 *value)
 {
-	return __pci_sal_read(0, bus->number, PCI_SLOT(devfn), PCI_FUNC(devfn),
+	return __pci_sal_read(PCI_SEGMENT(bus), bus->number, PCI_SLOT(devfn), PCI_FUNC(devfn),
 			      where, size, value);
 }
 
 static int
 pci_sal_write (struct pci_bus *bus, unsigned int devfn, int where, int size, u32 value)
 {
-	return __pci_sal_write(0, bus->number, PCI_SLOT(devfn), PCI_FUNC(devfn),
+	return __pci_sal_write(PCI_SEGMENT(bus), bus->number, PCI_SLOT(devfn), PCI_FUNC(devfn),
 			       where, size, value);
 }
 
@@ -114,24 +116,91 @@
 
 subsys_initcall(pci_acpi_init);
 
+static void __init
+pcibios_fixup_resource(struct resource *res, u64 offset)
+{
+	res->start += offset;
+	res->end += offset;
+}
+
+void __init
+pcibios_fixup_device_resources(struct pci_dev *dev, struct pci_bus *bus)
+{
+	int i;
+
+	for (i = 0; i < PCI_NUM_RESOURCES; i++) {
+		if (!dev->resource[i].start)
+			continue;
+		if (dev->resource[i].flags & IORESOURCE_MEM)
+			pcibios_fixup_resource(&dev->resource[i],
+			                       PCI_CONTROLLER(dev)->mem_offset);
+	}
+}
+
 /* Called by ACPI when it finds a new root bus.  */
+
+static struct pci_controller *
+alloc_pci_controller(int seg)
+{
+	struct pci_controller *controller;
+
+	controller = kmalloc(sizeof(*controller), GFP_KERNEL);
+	if (!controller)
+		return NULL;
+
+	memset(controller, 0, sizeof(*controller));
+	controller->segment = seg;
+	return controller;
+}
+
 struct pci_bus *
-pcibios_scan_root (int bus)
+scan_root_bus(int bus, struct pci_ops *ops, void *sysdata)
 {
-	struct list_head *list;
-	struct pci_bus *pci_bus;
+	struct pci_bus *b;
 
-	list_for_each(list, &pci_root_buses) {
-		pci_bus = pci_bus_b(list);
-		if (pci_bus->number == bus) {
-			/* Already scanned */
-			printk("PCI: Bus (%02x) already probed\n", bus);
-			return pci_bus;
-		}
-	}
+	/*
+	 * We know this is a new root bus we haven't seen before, so
+	 * scan it, even if we've seen the same bus number in a different
+	 * segment.
+	 */
+	b = kmalloc(sizeof(*b), GFP_KERNEL);
+	if (!b)
+		return NULL;
+
+	memset(b, 0, sizeof(*b));
+	INIT_LIST_HEAD(&b->children);
+	INIT_LIST_HEAD(&b->devices);
+
+	list_add_tail(&b->node, &pci_root_buses);
+
+	b->number = b->secondary = bus;
+	b->resource[0] = &ioport_resource;
+	b->resource[1] = &iomem_resource;
+
+	b->sysdata = sysdata;
+	b->ops = ops;
+	b->subordinate = pci_do_scan_bus(b);
+
+	return b;
+}
+
+struct pci_bus *
+pcibios_scan_root(void *handle, int seg, int bus)
+{
+	struct pci_controller *controller;
+	u64 base, size, offset;
+
+	printk("PCI: Probing PCI hardware on bus (%02x:%02x)\n", seg, bus);
+	controller = alloc_pci_controller(seg);
+	if (!controller)
+		return NULL;
+
+	controller->acpi_handle = handle;
 
-	printk("PCI: Probing PCI hardware on bus (%02x)\n", bus);
-	return pci_scan_bus(bus, pci_root_ops, NULL);
+	acpi_get_addr_space(handle, ACPI_MEMORY_RANGE, &base, &size, &offset);
+	controller->mem_offset = offset;
+
+	return scan_root_bus(bus, pci_root_ops, controller);
 }
 
 /*
@@ -140,6 +209,11 @@
 void __devinit
 pcibios_fixup_bus (struct pci_bus *b)
 {
+	struct list_head *ln;
+
+	for (ln = b->devices.next; ln != &b->devices; ln = ln->next)
+		pcibios_fixup_device_resources(pci_dev_b(ln), b);
+
 	return;
 }
 
diff -urN linux-2.5.64/drivers/acpi/pci_root.c linux-work/drivers/acpi/pci_root.c
--- linux-2.5.64/drivers/acpi/pci_root.c	Tue Mar  4 20:29:04 2003
+++ linux-work/drivers/acpi/pci_root.c	Tue Apr  1 09:19:53 2003
@@ -265,7 +265,8 @@
 	 * PCI namespace does not get created until this call is made (and 
 	 * thus the root bridge's pci_dev does not exist).
 	 */
-	root->bus = pcibios_scan_root(root->id.bus);
+	root->bus = pcibios_scan_root(root->handle,
+	                              root->id.segment, root->id.bus);
 	if (!root->bus) {
 		ACPI_DEBUG_PRINT((ACPI_DB_ERROR, 
 			"Bus %02x:%02x not present in PCI namespace\n", 
diff -urN linux-2.5.64/include/asm-ia64/acpi.h linux-work/include/asm-ia64/acpi.h
--- linux-2.5.64/include/asm-ia64/acpi.h	Tue Mar  4 20:29:34 2003
+++ linux-work/include/asm-ia64/acpi.h	Wed Apr  2 13:20:35 2003
@@ -100,7 +100,9 @@
 int acpi_request_vector (u32 int_type);
 int acpi_get_prt (struct pci_vector_struct **vectors, int *count);
 int acpi_get_interrupt_model (int *type);
+int acpi_register_irq (u32 gsi, u32 polarity, u32 trigger);
 int acpi_irq_to_vector (u32 irq);
+int acpi_get_addr_space (void *obj, u8 type, u64 *base, u64 *length,u64 *tra);
 
 #ifdef CONFIG_ACPI_NUMA
 #include <asm/numa.h>
diff -urN linux-2.5.64/include/asm-ia64/pci.h linux-work/include/asm-ia64/pci.h
--- linux-2.5.64/include/asm-ia64/pci.h	Tue Apr  1 08:49:07 2003
+++ linux-work/include/asm-ia64/pci.h	Tue Apr  1 09:19:53 2003
@@ -21,7 +21,7 @@
 #define PCIBIOS_MIN_MEM		0x10000000
 
 void pcibios_config_init(void);
-struct pci_bus * pcibios_scan_root(int bus);
+struct pci_bus * pcibios_scan_root(void *acpi_handle, int segment, int bus);
 
 struct pci_dev;
 
@@ -58,7 +58,6 @@
 #define pci_unmap_sg			platform_pci_unmap_sg
 #define pci_dma_sync_single		platform_pci_dma_sync_single
 #define pci_dma_sync_sg			platform_pci_dma_sync_sg
-#define sg_dma_address			platform_pci_dma_address
 #define pci_dma_supported		platform_pci_dma_supported
 
 /* pci_unmap_{single,page} is not a nop, thus... */
@@ -92,9 +91,21 @@
 #define pci_controller_num(PDEV)	(0)
 
 #define sg_dma_len(sg)		((sg)->dma_length)
+#define sg_dma_address(sg)	((sg)->dma_address)
 
 #define HAVE_PCI_MMAP
 extern int pci_mmap_page_range (struct pci_dev *dev, struct vm_area_struct *vma,
 				enum pci_mmap_state mmap_state, int write_combine);
+
+struct pci_controller {
+	void *acpi_handle;
+	void *iommu;
+	int segment;
+
+	u64 mem_offset;
+};
+
+#define PCI_CONTROLLER(busdev) ((struct pci_controller *) busdev->sysdata)
+#define PCI_SEGMENT(busdev)    (PCI_CONTROLLER(busdev)->segment)
 
 #endif /* _ASM_IA64_PCI_H */
diff -urN linux-2.5.64/include/asm-ia64/system.h linux-work/include/asm-ia64/system.h
--- linux-2.5.64/include/asm-ia64/system.h	Tue Apr  1 08:49:07 2003
+++ linux-work/include/asm-ia64/system.h	Tue Apr  1 09:19:53 2003
@@ -31,6 +31,7 @@
 #include <linux/types.h>
 
 struct pci_vector_struct {
+	__u16 segment;	/* PCI Segment number */
 	__u16 bus;	/* PCI Bus number */
 	__u32 pci_id;	/* ACPI split 16 bits device, 16 bits function (see section 6.1.1) */
 	__u8 pin;	/* PCI PIN (0 = A, 1 = B, 2 = C, 3 = D) */

--------------5F9837D71B3078EF7DD41FA5--


