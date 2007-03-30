From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Fri, 30 Mar 2007 16:34:05 +0000
Subject: [patch 2/5] ia64: make ioremap avoid unsupported attributes
Message-Id: <200703301034.05723.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200703211621.40717.bjorn.helgaas@hp.com>
In-Reply-To: <200703211621.40717.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Example memory map (from HP sx1000 with VGA enabled):
    0x00000 - 0x9FFFF supports only WB (cacheable) access
    0xA0000 - 0xBFFFF supports only UC (uncacheable) access
    0xC0000 - 0xFFFFF supports only WB (cacheable) access

pci_read_rom() indirectly uses ioremap(0xC0000) to read the shadow VGA option
ROM.  ioremap() used to default to a 16MB or 64MB UC kernel identity mapping,
which would cause an MCA when reading 0xC0000 since only WB is supported there.

X uses reads the option ROM to initialize devices.  A smaller test case is:
  # echo 1 > /sys/bus/pci/devices/0000:aa:03.0/rom
  # cp /sys/bus/pci/devices/0000:aa:03.0/rom x

To avoid this, we can use the same ioremap_page_range() strategy that most
architectures use for all ioremaps.  These page table mappings come out of the
vmalloc area.  On ia64, these are in region 5 (0xA... addresses) and typically
use 16KB or 64KB mappings instead of 16MB or 64MB mappings.  The smaller
mappings give more flexibility to use the correct attributes.

Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>

Index: work-mm10/arch/ia64/mm/ioremap.c
=================================--- work-mm10.orig/arch/ia64/mm/ioremap.c	2007-03-20 21:03:33.000000000 -0700
+++ work-mm10/arch/ia64/mm/ioremap.c	2007-03-30 09:19:44.000000000 -0700
@@ -1,5 +1,5 @@
 /*
- * (c) Copyright 2006 Hewlett-Packard Development Company, L.P.
+ * (c) Copyright 2006, 2007 Hewlett-Packard Development Company, L.P.
  *	Bjorn Helgaas <bjorn.helgaas@hp.com>
  *
  * This program is free software; you can redistribute it and/or modify
@@ -10,11 +10,13 @@
 #include <linux/compiler.h>
 #include <linux/module.h>
 #include <linux/efi.h>
+#include <linux/io.h>
+#include <linux/vmalloc.h>
 #include <asm/io.h>
 #include <asm/meminit.h>
 
 static inline void __iomem *
-__ioremap (unsigned long phys_addr, unsigned long size)
+__ioremap (unsigned long phys_addr)
 {
 	return (void __iomem *) (__IA64_UNCACHED_OFFSET | phys_addr);
 }
@@ -22,8 +24,13 @@
 void __iomem *
 ioremap (unsigned long phys_addr, unsigned long size)
 {
+	void __iomem *addr;
+	struct vm_struct *area;
+	unsigned long offset;
+	pgprot_t prot;
 	u64 attr;
 	unsigned long gran_base, gran_size;
+	unsigned long page_base;
 
 	/*
 	 * For things in kern_memmap, we must use the same attribute
@@ -34,7 +41,7 @@
 	if (attr & EFI_MEMORY_WB)
 		return (void __iomem *) phys_to_virt(phys_addr);
 	else if (attr & EFI_MEMORY_UC)
-		return __ioremap(phys_addr, size);
+		return __ioremap(phys_addr);
 
 	/*
 	 * Some chipsets don't support UC access to memory.  If
@@ -45,7 +52,42 @@
 	if (efi_mem_attribute(gran_base, gran_size) & EFI_MEMORY_WB)
 		return (void __iomem *) phys_to_virt(phys_addr);
 
-	return __ioremap(phys_addr, size);
+	/*
+	 * WB is not supported for the whole granule, so we can't use
+	 * the region 7 identity mapping.  If we can safely cover the
+	 * area with kernel page table mappings, we can use those
+	 * instead.
+	 */
+	page_base = phys_addr & PAGE_MASK;
+	size = PAGE_ALIGN(phys_addr + size) - page_base;
+	if (efi_mem_attribute(page_base, size) & EFI_MEMORY_WB) {
+		prot = PAGE_KERNEL;
+
+		/*
+		 * Mappings have to be page-aligned
+		 */
+		offset = phys_addr & ~PAGE_MASK;
+		phys_addr &= PAGE_MASK;
+
+		/*
+		 * Ok, go for it..
+		 */
+		area = get_vm_area(size, VM_IOREMAP);
+		if (!area)
+			return NULL;
+
+		area->phys_addr = phys_addr;
+		addr = (void __iomem *) area->addr;
+		if (ioremap_page_range((unsigned long) addr,
+				(unsigned long) addr + size, phys_addr, prot)) {
+			vunmap((void __force *) addr);
+			return NULL;
+		}
+
+		return (void __iomem *) (offset + (char __iomem *)addr);
+	}
+
+	return __ioremap(phys_addr);
 }
 EXPORT_SYMBOL(ioremap);
 
@@ -55,6 +97,14 @@
 	if (kern_mem_attribute(phys_addr, size) & EFI_MEMORY_WB)
 		return NULL;
 
-	return __ioremap(phys_addr, size);
+	return __ioremap(phys_addr);
 }
 EXPORT_SYMBOL(ioremap_nocache);
+
+void
+iounmap (volatile void __iomem *addr)
+{
+	if (REGION_NUMBER(addr) = RGN_GATE)
+		vunmap((void *) ((unsigned long) addr & PAGE_MASK));
+}
+EXPORT_SYMBOL(iounmap);
Index: work-mm10/include/asm-ia64/io.h
=================================--- work-mm10.orig/include/asm-ia64/io.h	2007-03-20 20:39:59.000000000 -0700
+++ work-mm10/include/asm-ia64/io.h	2007-03-20 21:03:34.000000000 -0700
@@ -421,11 +421,7 @@
 
 extern void __iomem * ioremap(unsigned long offset, unsigned long size);
 extern void __iomem * ioremap_nocache (unsigned long offset, unsigned long size);
-
-static inline void
-iounmap (volatile void __iomem *addr)
-{
-}
+extern void iounmap (volatile void __iomem *addr);
 
 /* Use normal IO mappings for DMI */
 #define dmi_ioremap ioremap
