From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Fri, 19 Apr 2002 18:44:56 +0000
Subject: [Linux-ia64] [PATCH] ACPI merge cleanup
Message-Id: <marc-linux-ia64-105590701905484@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This patch against 2.4.18+ia64-020410 puts back a few things that
got lost in the big ACPI merge and makes the generic kernel work again.

  - Adjust to pci_root_ops declaration change
  - Add back acpi_get_sysname() body
  - Add back acpi_get_crs() and friends
  - Declare acpi_get_sysname()
  - Define page_to_phys() for generic kernel
  - ACPI: Fix _CID match
  - ACPI: virt_to_phys(efi.acpi20) (previously treated as already phys)
  - ACPI: Use ioremap rather phys_to_virt() for uncacheable space

David, I think you already have the _CID fix.  I'll send the ACPI
stuff to the ACPI folks as well.

This does not fix the problem of the ACPI interpreter barfing on
the HP zx1 _CRS methods.
-- 
Bjorn Helgaas - bjorn_helgaas@hp.com
Linux Systems Operation R&D
Hewlett-Packard



diff -u -r -X exclude linux-2.4.18-ia64-020410/arch/ia64/hp/zx1/hpzx1_misc.c linux-2.4.18-ia64-020410-test/arch/ia64/hp/zx1/hpzx1_misc.c
--- linux-2.4.18-ia64-020410/arch/ia64/hp/zx1/hpzx1_misc.c	Wed Apr 10 17:01:16 2002
+++ linux-2.4.18-ia64-020410-test/arch/ia64/hp/zx1/hpzx1_misc.c	Thu Apr 18 11:40:34 2002
@@ -42,7 +42,7 @@
 
 static struct fake_pci_dev *fake_pci_head, **fake_pci_tail = &fake_pci_head;
 
-static struct pci_ops orig_pci_ops;
+static struct pci_ops *orig_pci_ops;
 
 static inline struct fake_pci_dev *
 fake_pci_find_slot(unsigned char bus, unsigned int devfn)
@@ -77,7 +77,7 @@
 { \
 	struct fake_pci_dev *fake_dev; \
 	if (!(fake_dev = fake_pci_find_slot(dev->bus->number, dev->devfn))) \
-		return orig_pci_ops.name(dev, where, value); \
+		return orig_pci_ops->name(dev, where, value); \
 	\
 	switch (where) { \
 	case PCI_COMMAND: \
@@ -105,7 +105,7 @@
 { \
 	struct fake_pci_dev *fake_dev; \
 	if (!(fake_dev = fake_pci_find_slot(dev->bus->number, dev->devfn))) \
-		return orig_pci_ops.name(dev, where, value); \
+		return orig_pci_ops->name(dev, where, value); \
 	\
 	switch (where) { \
 	case PCI_BASE_ADDRESS_0: \
@@ -261,7 +261,6 @@
 
 	status = hp_csr_space(obj, &csr_base, &csr_length);
 
-printk("hpzx1_sba_probe: status=%d\n", status);
 	if (status != AE_OK)
 		return status;
 
@@ -296,7 +295,7 @@
 	if (status != AE_OK)
 		return status;
 
-	status = acpi_cf_evaluate_method(obj, METHOD_NAME__BBN, &busnum);
+	status = acpi_evaluate_integer(obj, METHOD_NAME__BBN, NULL, &busnum);
 	if (ACPI_FAILURE(status)) {
 		printk(KERN_ERR PFX "evaluate _BBN fail=0x%x\n", status);
 		busnum = 0;	// no _BBN; stick it on bus 0
@@ -314,7 +313,7 @@
 static void
 hpzx1_acpi_dev_init(void)
 {
-	extern struct pci_ops pci_conf;
+	extern struct pci_ops *pci_root_ops;
 
 	/*
 	 * Make fake PCI devices for the following hardware in the
@@ -328,7 +327,6 @@
 	 * HWP0002: LBA device
 	 * HWP0003: AGP LBA device
 	 */
-printk("hpzx1_acpi_dev_init\n");
 	acpi_get_devices("HWP0001", hpzx1_sba_probe, "HWP0001", NULL);
 #ifdef CONFIG_IA64_HP_PROTO
 	if (fake_pci_tail != &fake_pci_head) {
@@ -385,8 +383,8 @@
 	/*
 	 * Replace PCI ops, but only if we made fake devices.
 	 */
-	orig_pci_ops = pci_conf;
-	pci_conf = hp_pci_conf;
+	orig_pci_ops = pci_root_ops;
+	pci_root_ops = &hp_pci_conf;
 }
 
 extern void sba_init(void);
diff -u -r -X exclude linux-2.4.18-ia64-020410/arch/ia64/kernel/acpi.c linux-2.4.18-ia64-020410-test/arch/ia64/kernel/acpi.c
--- linux-2.4.18-ia64-020410/arch/ia64/kernel/acpi.c	Wed Apr 10 17:01:16 2002
+++ linux-2.4.18-ia64-020410-test/arch/ia64/kernel/acpi.c	Fri Apr 19 11:30:43 2002
@@ -64,10 +64,39 @@
 acpi_get_sysname (void)
 {
 #ifdef CONFIG_IA64_GENERIC
-	return "hpsim";
+	unsigned long rsdp_phys = 0;
+	struct acpi20_table_rsdp *rsdp;
+	struct acpi_table_xsdt *xsdt;
+	struct acpi_table_header *hdr;
+
+	if ((0 != acpi_find_rsdp(&rsdp_phys)) || !rsdp_phys) {
+		printk("ACPI 2.0 RSDP not found, default to \"dig\"\n");
+		return "dig";
+	}
+
+	rsdp = (struct acpi20_table_rsdp *) __va(rsdp_phys);
+	if (strncmp(rsdp->signature, RSDP_SIG, sizeof(RSDP_SIG) - 1)) {
+		printk("ACPI 2.0 RSDP signature incorrect, default to \"dig\"\n");
+		return "dig";
+	}
+
+	xsdt = (struct acpi_table_xsdt *) __va(rsdp->xsdt_address);
+	hdr = &xsdt->header;
+	if (strncmp(hdr->signature, XSDT_SIG, sizeof(XSDT_SIG) - 1)) {
+		printk("ACPI 2.0 XSDT signature incorrect, default to \"dig\"\n");
+		return "dig";
+	}
+
+	if (!strcmp(hdr->oem_id, "HP")) {
+		return "hpzx1";
+	}
+
+	return "dig";
 #else
 # if defined (CONFIG_IA64_HP_SIM)
 	return "hpsim";
+# elif defined (CONFIG_IA64_HP_ZX1)
+	return "hpzx1";
 # elif defined (CONFIG_IA64_SGI_SN1)
 	return "sn1";
 # elif defined (CONFIG_IA64_SGI_SN2)
@@ -592,3 +621,61 @@
 
         return 0;
 }
+
+#ifdef CONFIG_ACPI
+
+/**
+ * acpi_get_crs - Return the current resource settings for a device
+ * obj: A handle for this device
+ * buf: A buffer to be populated by this call.
+ *
+ * Pass a valid handle, typically obtained by walking the namespace and a
+ * pointer to an allocated buffer, and this function will fill in the buffer
+ * with a list of acpi_resource structures.
+ */
+acpi_status acpi_get_crs(acpi_handle obj, acpi_buffer *buf)
+{
+	acpi_status result;
+	buf->length = 0;
+	buf->pointer = NULL;
+
+	result = acpi_get_current_resources(obj, buf);
+	if (result != AE_BUFFER_OVERFLOW)
+		return result;
+	buf->pointer = kmalloc(buf->length, GFP_KERNEL);
+	if (!buf->pointer)
+		return -ENOMEM;
+
+	result = acpi_get_current_resources(obj, buf);
+
+	return result;
+}
+
+acpi_resource *acpi_get_crs_next(acpi_buffer *buf, int *offset)
+{
+	acpi_resource *res;
+
+	if (*offset >= buf->length)
+		return NULL;
+
+	res = buf->pointer + *offset;
+	*offset += res->length;
+	return res;
+}
+
+acpi_resource_data *acpi_get_crs_type(acpi_buffer *buf, int *offset, int type)
+{
+	for (;;) {
+		acpi_resource *res = acpi_get_crs_next(buf, offset);
+		if (!res)
+			return NULL;
+		if (res->id = type)
+			return &res->data;
+	}
+}
+
+void acpi_dispose_crs(acpi_buffer *buf)
+{
+	kfree(buf->pointer);
+}
+#endif /* CONFIG_ACPI */
diff -u -r -X exclude linux-2.4.18-ia64-020410/drivers/acpi/acpi_bus.c linux-2.4.18-ia64-020410-test/drivers/acpi/acpi_bus.c
--- linux-2.4.18-ia64-020410/drivers/acpi/acpi_bus.c	Wed Apr 10 17:01:16 2002
+++ linux-2.4.18-ia64-020410-test/drivers/acpi/acpi_bus.c	Thu Apr 18 13:04:31 2002
@@ -1053,7 +1053,7 @@
 		if (!cid[0])
 			return -ENOENT;
 
-		if (0 != strstr(cid, device->pnp.hardware_id))
+		if (0 != strstr(driver->ids, cid))
 			return 0;
 	}
 
diff -u -r -X exclude linux-2.4.18-ia64-020410/drivers/acpi/acpi_osl.c linux-2.4.18-ia64-020410-test/drivers/acpi/acpi_osl.c
--- linux-2.4.18-ia64-020410/drivers/acpi/acpi_osl.c	Wed Apr 10 17:01:16 2002
+++ linux-2.4.18-ia64-020410-test/drivers/acpi/acpi_osl.c	Fri Apr 19 12:24:41 2002
@@ -158,9 +158,9 @@
 #else /*CONFIG_ACPI_EFI*/
 	addr->pointer_type = ACPI_PHYSICAL_POINTER;
 	if (efi.acpi20)
-		addr->pointer.physical = (ACPI_PHYSICAL_ADDRESS) efi.acpi20;
+		addr->pointer.physical = (ACPI_PHYSICAL_ADDRESS) virt_to_phys(efi.acpi20);
 	else if (efi.acpi)
-		addr->pointer.physical = (ACPI_PHYSICAL_ADDRESS) efi.acpi;
+		addr->pointer.physical = (ACPI_PHYSICAL_ADDRESS) virt_to_phys(efi.acpi);
 	else {
 		printk(KERN_ERR PREFIX "System description tables not found\n");
 		addr->pointer.physical = 0;
@@ -174,6 +174,13 @@
 acpi_status
 acpi_os_map_memory(ACPI_PHYSICAL_ADDRESS phys, ACPI_SIZE size, void **virt)
 {
+#ifdef CONFIG_ACPI_EFI
+	if (EFI_MEMORY_UC & efi_mem_attributes(phys)) {
+		*virt = ioremap(phys, size);
+	} else {
+		*virt = phys_to_virt(phys);
+	}
+#else
 	if (phys > ULONG_MAX) {
 		printk(KERN_ERR PREFIX "Cannot map memory that high\n");
 		return AE_BAD_PARAMETER;
@@ -183,6 +190,7 @@
 	 * ioremap already checks to ensure this is in reserved space
 	 */
 	*virt = ioremap((unsigned long) phys, size);
+#endif
 	if (!*virt)
 		return AE_NO_MEMORY;
 
@@ -324,26 +332,41 @@
 	void			*value,
 	u32			width)
 {
-	u32 dummy;
-
+	u32			dummy;
+	int			iomem = 0;
+	void			*virt_addr;
+
+#ifdef CONFIG_ACPI_EFI
+	if (EFI_MEMORY_UC & efi_mem_attributes(phys_addr)) {
+		iomem = 1;
+		virt_addr = ioremap(phys_addr, width);
+	} else {
+		virt_addr = phys_to_virt(phys_addr);
+	}
+#else
+	virt_addr = phys_to_virt(phys_addr);
+#endif
 	if (!value)
 		value = &dummy;
 
 	switch (width)
 	{
 	case 8:
-		*(u8*) value = *(u8*) phys_to_virt(phys_addr);
+		*(u8*) value = *(u8*) virt_addr;
 		break;
 	case 16:
-		*(u16*) value = *(u16*) phys_to_virt(phys_addr);
+		*(u16*) value = *(u16*) virt_addr;
 		break;
 	case 32:
-		*(u32*) value = *(u32*) phys_to_virt(phys_addr);
+		*(u32*) value = *(u32*) virt_addr;
 		break;
 	default:
 		BUG();
 	}
 
+	if (iomem)
+		iounmap(virt_addr);
+
 	return AE_OK;
 }
 
@@ -353,20 +376,37 @@
 	acpi_integer		value,
 	u32			width)
 {
+	int			iomem = 0;
+	void			*virt_addr;
+
+#ifdef CONFIG_ACPI_EFI
+	if (EFI_MEMORY_UC & efi_mem_attributes(phys_addr)) {
+		iomem = 1;
+		virt_addr = ioremap(phys_addr,width);
+	} else {
+		virt_addr = phys_to_virt(phys_addr);
+	}
+#else
+	virt_addr = phys_to_virt(phys_addr);
+#endif
+
 	switch (width)
 	{
 	case 8:
-		*(u8*) phys_to_virt(phys_addr) = value;
+		*(u8*) virt_addr = value;
 		break;
 	case 16:
-		*(u16*) phys_to_virt(phys_addr) = value;
+		*(u16*) virt_addr = value;
 		break;
 	case 32:
-		*(u32*) phys_to_virt(phys_addr) = value;
+		*(u32*) virt_addr = value;
 		break;
 	default:
 		BUG();
 	}
+
+	if (iomem)
+		iounmap(virt_addr);
 
 	return AE_OK;
 }
diff -u -r -X exclude linux-2.4.18-ia64-020410/include/asm-ia64/acpi.h linux-2.4.18-ia64-020410-test/include/asm-ia64/acpi.h
--- linux-2.4.18-ia64-020410/include/asm-ia64/acpi.h	Wed Apr 10 17:01:19 2002
+++ linux-2.4.18-ia64-020410-test/include/asm-ia64/acpi.h	Thu Apr 18 11:40:34 2002
@@ -32,6 +32,7 @@
 
 #define __acpi_map_table(phys_addr, size) __va(phys_addr)
 
+const char *acpi_get_sysname (void);
 int acpi_boot_init (char *cdline);
 int acpi_find_rsdp (unsigned long *phys_addr);
 int acpi_request_vector (u32 int_type);
diff -u -r -X exclude linux-2.4.18-ia64-020410/include/asm-ia64/page.h linux-2.4.18-ia64-020410-test/include/asm-ia64/page.h
--- linux-2.4.18-ia64-020410/include/asm-ia64/page.h	Thu Apr 11 14:03:53 2002
+++ linux-2.4.18-ia64-020410-test/include/asm-ia64/page.h	Thu Apr 18 11:43:15 2002
@@ -55,7 +55,7 @@
 #ifdef CONFIG_IA64_GENERIC
 # include <asm/machvec.h>
 # define virt_to_page(kaddr)	(mem_map + platform_map_nr(kaddr))
-# define page_to_phys(page)	XXX fix me
+# define page_to_phys(page)	((page - mem_map) << PAGE_SHIFT)
 #elif defined (CONFIG_IA64_SGI_SN1)
 # ifndef CONFIG_DISCONTIGMEM
 #  define virt_to_page(kaddr)	(mem_map + MAP_NR_DENSE(kaddr))

