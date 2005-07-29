From: Khalid Aziz <khalid@fc.hp.com>
Date: Fri, 29 Jul 2005 18:10:12 +0000
Subject: [PATCH] /proc/iomem update
Message-Id: <E1DyZJE-0006Au-00@lyra.fc.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Included patch updates /proc/iomem on ia64 to include information about
system RAM and kernel memory. This makes /proc/iomem on ia64 similar to
one on x86. This patch is relative to 2.6.13-rc3 and applies on top of 
the EFI memory map walk rewrite patch at 
<http://free.linux.hp.com/~khalid/ia64/efi_memmapwalk_2.6.13rc3.patch>
(Tony, this EFI memory map walk patch is same as the one I sent you this
morning).

Signed-off-by:  Khalid Aziz <khalid.aziz@hp.com>

===================================

diff -urNp linux-2.6.13-rc3-efimemmap/arch/ia64/kernel/efi.c linux-2.6.13-rc3-efimemmap-iomem/arch/ia64/kernel/efi.c
--- linux-2.6.13-rc3-efimemmap/arch/ia64/kernel/efi.c	2005-07-29 10:17:36.000000000 -0600
+++ linux-2.6.13-rc3-efimemmap-iomem/arch/ia64/kernel/efi.c	2005-07-29 10:18:43.000000000 -0600
@@ -21,6 +21,9 @@
  * Rewrote efi_memap_walk() to create a linked list of available 
  * memory regions instead of editing EFI memory map in place 
  * 				- Khalid Aziz <khalid.aziz@hp.com>
+ *
+ * Added system memory info to /proc/iomem - Robin Lewis <robinl@hp.com>, 
+ * 					     Khalid Aziz <khalid.aziz@hp.com>
  */
 #include <linux/config.h>
 #include <linux/module.h>
@@ -958,3 +961,90 @@ efi_uart_console_only(void)
 	printk(KERN_ERR "Malformed %s value\n", name);
 	return 0;
 }
+
+void 
+efi_initialize_iomem_resources(struct resource *code_resource,
+			       struct resource *data_resource)
+{
+	struct resource *res;
+	void *efi_map_start, *efi_map_end, *p;
+	efi_memory_desc_t *md;
+	u64 efi_desc_size;
+
+	efi_map_start = __va(ia64_boot_param->efi_memmap);
+	efi_map_end   = efi_map_start + ia64_boot_param->efi_memmap_size;
+	efi_desc_size = ia64_boot_param->efi_memdesc_size;
+
+	res = NULL;
+  
+	for (p = efi_map_start; p < efi_map_end; p += efi_desc_size) {
+		md = p;
+    
+		/* 
+		 * Data was trimmed and may not be correct, look for bad data 
+		 * and skip it 
+		 */
+		if (md->num_pages = 0)
+			continue;
+
+		if ((res = kmalloc(sizeof(struct resource), GFP_KERNEL)) = NULL) {
+			printk("ERROR: failed to alocate resource for iomem\n");
+			return;
+		}
+		memset(res, 0, sizeof(*res));
+		res->flags = IORESOURCE_MEM;
+		switch (md->type) {
+
+			case EFI_MEMORY_MAPPED_IO:
+			case EFI_MEMORY_MAPPED_IO_PORT_SPACE:
+				continue;
+				break;
+
+			case EFI_LOADER_CODE:
+			case EFI_LOADER_DATA:
+			case EFI_BOOT_SERVICES_DATA:
+			case EFI_BOOT_SERVICES_CODE:
+			case EFI_CONVENTIONAL_MEMORY:
+				if (md->attribute & EFI_MEMORY_WP) {
+					res->name = "System ROM";
+					res->flags |= IORESOURCE_READONLY;
+				} else {
+					res->name = "System RAM";
+				}
+				break;
+
+			case EFI_ACPI_MEMORY_NVS:
+				res->name = "ACPI Non-volatile Storage";
+				res->flags |= IORESOURCE_BUSY;
+				break;
+    
+			case EFI_UNUSABLE_MEMORY:
+				res->name = "reserved";
+				res->flags |= IORESOURCE_BUSY | IORESOURCE_DISABLED;
+				break;
+
+			case EFI_RESERVED_TYPE:
+			case EFI_RUNTIME_SERVICES_CODE:
+			case EFI_RUNTIME_SERVICES_DATA:
+			case EFI_ACPI_RECLAIM_MEMORY:
+			default:
+				res->name = "reserved";
+				res->flags |= IORESOURCE_BUSY;
+				break;
+		}
+
+		res->start = md->phys_addr;
+		res->end = md->phys_addr + (md->num_pages << EFI_PAGE_SHIFT) - 1;
+		if (insert_resource(&iomem_resource, res) < 0)
+			kfree(res);
+		else {
+			/*
+			 * We don't know which region contains 
+			 * kernel data so we try it repeatedly and 
+			 * let the resource manager test it.
+			 */
+			insert_resource(res, code_resource);
+			insert_resource(res, data_resource);
+		}
+	}
+}
diff -urNp linux-2.6.13-rc3-efimemmap/arch/ia64/kernel/setup.c linux-2.6.13-rc3-efimemmap-iomem/arch/ia64/kernel/setup.c
--- linux-2.6.13-rc3-efimemmap/arch/ia64/kernel/setup.c	2005-07-29 10:17:36.000000000 -0600
+++ linux-2.6.13-rc3-efimemmap-iomem/arch/ia64/kernel/setup.c	2005-07-29 10:18:43.000000000 -0600
@@ -77,6 +77,23 @@ struct screen_info screen_info;
 unsigned long vga_console_iobase;
 unsigned long vga_console_membase;
 
+static struct resource data_resource = {
+	.name	= "Kernel data",
+	.start	= 0,
+	.end	= 0,
+	.flags	= IORESOURCE_BUSY | IORESOURCE_MEM
+};
+
+static struct resource code_resource = {
+	.name	= "Kernel code",
+	.start	= 0,
+	.end	= 0,
+	.flags	= IORESOURCE_BUSY | IORESOURCE_MEM
+};
+extern void efi_initialize_iomem_resources(struct resource *,
+		struct resource *);
+extern char _text[], _edata[], _etext[];
+
 unsigned long ia64_max_cacheline_size;
 unsigned long ia64_iobase;	/* virtual address for I/O accesses */
 EXPORT_SYMBOL(ia64_iobase);
@@ -239,6 +256,20 @@ find_memmap_space (int *marker)
 	return 0;
 }
 
+/*
+ * Request address space for all standard resources
+ */
+static void __init register_memory(void)
+{
+        code_resource.start = ia64_tpa(_text);
+	code_resource.end   = ia64_tpa(_etext) - 1;
+	data_resource.start = ia64_tpa(_etext);
+	data_resource.end   = ia64_tpa(_edata) - 1;
+	efi_initialize_iomem_resources(&code_resource, &data_resource);
+}
+
+__initcall(register_memory);
+
 /**
  * reserve_memory - setup reserved memory areas
  *
