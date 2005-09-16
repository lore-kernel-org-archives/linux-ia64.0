From: Khalid Aziz <khalid_aziz@hp.com>
Date: Fri, 16 Sep 2005 15:26:27 +0000
Subject: Re: [PATCH] Updated /proc/iomem patch
Message-Id: <1126884387.1287.11.camel@lyra.fc.hp.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=-lAqlNJmX8zidnWktvTqa"
List-Id: <linux-ia64.vger.kernel.org>
References: <1126716323.29344.55.camel@lyra.fc.hp.com>
In-Reply-To: <1126716323.29344.55.camel@lyra.fc.hp.com>
To: linux-ia64@vger.kernel.org


--=-lAqlNJmX8zidnWktvTqa
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Thu, 2005-09-15 at 10:26 -0600, Khalid Aziz wrote:
> On Wed, 2005-09-14 at 10:45 -0600, Khalid Aziz wrote:
> > Here is an updated patch that makes /proc/iomem include information
> > about system RAM as well. This makes /proc/iomem on ia64 look like it
> > does on x86 and also enables kexec-tools to work on ia64.
> > 
> 
> I am not sure if marking the memory allocated by bootloader for kernel,
> inital ramdisk, EFI memory map and boot parameters as "reserved"
> in /proc/iomem is the right thing to do. I have done it this way in the
> patch but I would appreciate other opinions.
> 

The more I think about it, the more I am convinced memory type
EFI_LOADER_DATA should be marked simply "System RAM", not
"reserved". /proc/iomem is supposed to represent how physical address
space is used, not how physical memory is used.

Updated patch attached.

-- 
Khalid

====================================================================
Khalid Aziz                       Open Source and Linux Organization
(970)898-9214                                        Hewlett-Packard
khalid.aziz@hp.com                                  Fort Collins, CO

"The Linux kernel is subject to relentless development" 
                                - Alessandro Rubini

--=-lAqlNJmX8zidnWktvTqa
Content-Disposition: attachment; filename=iomem.patch
Content-Type: text/x-patch; name=iomem.patch; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 7bit

diff -urNp linux-2.6.13.orig/arch/ia64/kernel/efi.c linux-2.6.13/arch/ia64/kernel/efi.c
--- linux-2.6.13.orig/arch/ia64/kernel/efi.c	2005-08-28 17:41:01.000000000 -0600
+++ linux-2.6.13/arch/ia64/kernel/efi.c	2005-09-14 09:37:47.000000000 -0600
@@ -862,3 +862,91 @@ efi_uart_console_only(void)
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
+		if (md->num_pages == 0)
+			continue;
+
+		if ((res = kmalloc(sizeof(struct resource), GFP_KERNEL)) == NULL) {
+			printk("ERROR: failed to alocate resource for iomem\n");
+			return;
+		}
+		memset(res, 0, sizeof(*res));
+		res->flags = IORESOURCE_MEM;
+		switch (md->type) {
+
+			case EFI_MEMORY_MAPPED_IO:
+			case EFI_MEMORY_MAPPED_IO_PORT_SPACE:
+				kfree(res);
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
diff -urNp linux-2.6.13.orig/arch/ia64/kernel/setup.c linux-2.6.13/arch/ia64/kernel/setup.c
--- linux-2.6.13.orig/arch/ia64/kernel/setup.c	2005-08-28 17:41:01.000000000 -0600
+++ linux-2.6.13/arch/ia64/kernel/setup.c	2005-09-14 09:16:50.000000000 -0600
@@ -78,6 +78,23 @@ struct screen_info screen_info;
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
@@ -171,6 +188,20 @@ sort_regions (struct rsvd_region *rsvd_r
 	}
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

--=-lAqlNJmX8zidnWktvTqa--

