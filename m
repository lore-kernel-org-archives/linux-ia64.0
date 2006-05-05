From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Fri, 05 May 2006 23:19:50 +0000
Subject: [IA64] rework memory attribute aliasing
Message-Id: <200605051719.50884.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This closes a couple holes in our attribute aliasing avoidance scheme:

  - The current kernel fails mmaps of some /dev/mem MMIO regions because
    they don't appear in the EFI memory map.  This keeps X from working
    on the Intel Tiger box.

  - The current kernel allows UC mmap of the 0-1MB region of
    /sys/.../legacy_mem even when the chipset doesn't support UC
    access.  This causes an MCA when starting X on HP rx7620 and rx8620
    boxes in the default configuration.

There's more detail in the Documentation/ia64/aliasing.txt file this
adds, but the general idea is that if a region might be covered by
a granule-sized kernel identity mapping, any access via /dev/mem or
mmap must use the same attribute as the identity mapping.

Otherwise, we fall back to using an attribute that is supported
according to the EFI memory map, or to using UC if the EFI memory
map doesn't mention the region.

Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>

Index: work-mm6/Documentation/ia64/aliasing.txt
=================================--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ work-mm6/Documentation/ia64/aliasing.txt	2006-05-04 16:35:22.000000000 -0600
@@ -0,0 +1,208 @@
+	         MEMORY ATTRIBUTE ALIASING ON IA-64
+
+			   Bjorn Helgaas
+		       <bjorn.helgaas@hp.com>
+			    May 4, 2006
+
+
+MEMORY ATTRIBUTES
+
+    Itanium supports several attributes for virtual memory references.
+    The attribute is part of the virtual translation, i.e., it is
+    contained in the TLB entry.  The ones of most interest to the Linux
+    kernel are:
+
+	WB		Write-back (cacheable)
+	UC		Uncacheable
+	WC		Write-coalescing
+
+    System memory typically uses the WB attribute.  The UC attribute is
+    used for memory-mapped I/O devices.  The WC attribute is uncacheable
+    like UC is, but writes may be delayed and combined to increase
+    performance for things like frame buffers.
+
+    The Itanium architecture requires that we avoid accessing the same
+    page with both a cacheable mapping and an uncacheable mapping[1].
+
+    The design of the chipset determines which attributes are supported
+    on which regions of the address space.  For example, some chipsets
+    support either WB or UC access to main memory, while others support
+    only WB access.
+
+MEMORY MAP
+
+    Platform firmware describes the physical memory map and the
+    supported attributes for each region.  At boot-time, the kernel uses
+    the EFI GetMemoryMap() interface.  ACPI can also describe memory
+    devices and the attributes they support, but Linux/ia64 currently
+    doesn't use this information.
+
+    The kernel uses the efi_memmap table returned from GetMemoryMap() to
+    learn the attributes supported by each region of physical address
+    space.  Unfortunately, this table does not completely describe the
+    address space because some machines omit some or all of the MMIO
+    regions from the map.
+
+    The kernel maintains another table, kern_memmap, which describes the
+    memory Linux is actually using and the attribute for each region.
+    This contains only system memory; it does not contain MMIO space.
+
+    The kern_memmap table typically contains only a subset of the system
+    memory described by the efi_memmap.  Linux/ia64 can't use all memory
+    in the system because of constraints imposed by the identity mapping
+    scheme.
+
+    The efi_memmap table is preserved unmodified because the original
+    boot-time information is required for kexec.
+
+KERNEL IDENTITY MAPPINGS
+
+    Linux/ia64 identity mappings are done with large pages, currently
+    either 16MB or 64MB, referred to as "granules."  Cacheable mappings
+    are speculative[2], so the processor can read any location in the
+    page at any time, independent of the programmer's intentions.  This
+    means that to avoid attribute aliasing, Linux can create a cacheable
+    identity mapping only when the entire granule supports cacheable
+    access.
+
+    Therefore, kern_memmap contains only full granule-sized regions that
+    can referenced safely by an identity mapping.
+
+    Uncacheable mappings are not speculative, so the processor will
+    generate UC accesses only to locations explicitly referenced by
+    software.  This allows UC identity mappings to cover granules that
+    are only partially populated, or populated with a combination of UC
+    and WB regions.
+
+USER MAPPINGS
+
+    User mappings are typically done with 16K or 64K pages.  The smaller
+    page size allows more flexibility because only 16K or 64K has to be
+    homogeneous with respect to memory attributes.
+
+POTENTIAL ATTRIBUTE ALIASING CASES
+
+    There are several ways the kernel creates new mappings:
+
+    mmap of /dev/mem
+
+	This uses remap_pfn_range(), which creates user mappings.  These
+	mappings may be either WB or UC.  If the region being mapped
+	happens to be in kern_memmap, meaning that it may also be mapped
+	by a kernel identity mapping, the user mapping must use the same
+	attribute as the kernel mapping.
+
+	If the region is not in kern_memmap, the user mapping should use
+	an attribute reported as being supported in the EFI memory map.
+
+	Since the EFI memory map does not describe MMIO on some
+	machines, this should use an uncacheable mapping as a fallback.
+
+    mmap of /sys/class/pci_bus/.../legacy_mem
+
+	This is very similar to mmap of /dev/mem, except that legacy_mem
+	only allows mmap of the one megabyte "legacy MMIO" area for a
+	specific PCI bus.  Typically this is the first megabyte of
+	physical address space, but it may be different on machines with
+	several VGA devices.
+
+	"X" uses this to access VGA frame buffers.  Using legacy_mem
+	rather than /dev/mem allows multiple instances of X to talk to
+	different VGA cards.
+
+	The /dev/mem mmap constraints apply.
+
+	However, since this is for mapping legacy MMIO space, WB access
+	does not make sense.  This matters on machines without legacy
+	VGA support: these machines may have WB memory for the entire
+	first megabyte (or even the entire first granule).
+
+	On these machines, we could mmap legacy_mem as WB, which would
+	be safe in terms of attribute aliasing, but X has no way of
+	knowing that it is accessing regular memory, not a frame buffer,
+	so the kernel should fail the mmap rather than doing it with WB.
+
+    read/write of /dev/mem
+
+	This uses copy_from_user(), which implicitly uses a kernel
+	identity mapping.  This is obviously safe for things in
+	kern_memmap.
+
+	There may be corner cases of things that are not in kern_memmap,
+	but could be accessed this way.  For example, registers in MMIO
+	space are not in kern_memmap, but could be accessed with a UC
+	mapping.  This would not cause attribute aliasing.  But
+	registers typically can be accessed only with four-byte or
+	eight-byte accesses, and the copy_from_user() path doesn't allow
+	any control over the access size, so this would be dangerous.
+
+    ioremap()
+
+	This returns a kernel identity mapping for use inside the
+	kernel.
+
+	If the region is in kern_memmap, we should use the attribute
+	specified there.  Otherwise, if the EFI memory map reports that
+	the entire granule supports WB, we should use that (granules
+	that are partially reserved or occupied by firmware do not appear
+	in kern_memmap).  Otherwise, we should use a UC mapping.
+
+PAST PROBLEM CASES
+
+    mmap of various MMIO regions from /dev/mem by "X" on Intel platforms
+
+      The EFI memory map may not report these MMIO regions.
+
+      These must be allowed so that X will work.  This means that
+      when the EFI memory map is incomplete, every /dev/mem mmap must
+      succeed.  It may create either WB or UC user mappings, depending
+      on whether the region is in kern_memmap or the EFI memory map.
+
+    mmap of 0x0-0xA0000 /dev/mem by "hwinfo" on HP sx1000 with VGA enabled
+
+      See https://bugzilla.novell.com/show_bug.cgi?id0858.
+
+      The EFI memory map reports the following attributes:
+        0x00000-0x9FFFF WB only
+        0xA0000-0xBFFFF UC only (VGA frame buffer)
+        0xC0000-0xFFFFF WB only
+
+      This mmap is done with user pages, not kernel identity mappings,
+      so it is safe to use WB mappings.
+
+      The kernel VGA driver may ioremap the VGA frame buffer at 0xA0000,
+      which will use a granule-sized UC mapping covering 0-0xFFFFF.  This
+      granule covers some WB-only memory, but since UC is non-speculative,
+      the processor will never generate an uncacheable reference to the
+      WB-only areas unless the driver explicitly touches them.
+
+    mmap of 0x0-0xFFFFF legacy_mem by "X"
+
+      If the EFI memory map reports this entire range as WB, there
+      is no VGA MMIO hole, and the mmap should fail or be done with
+      a WB mapping.
+
+      There's no easy way for X to determine whether the 0xA0000-0xBFFFF
+      region is a frame buffer or just memory, so I think it's best to
+      just fail this mmap request rather than using a WB mapping.  As
+      far as I know, there's no need to map legacy_mem with WB
+      mappings.
+
+      Otherwise, a UC mapping of the entire region is probably safe.
+      The VGA hole means the region will not be in kern_memmap.  The
+      HP sx1000 chipset doesn't support UC access to the memory surrounding
+      the VGA hole, but X doesn't need that area anyway and should not
+      reference it.
+
+    mmap of 0xA0000-0xBFFFF legacy_mem by "X" on HP sx1000 with VGA disabled
+
+      The EFI memory map reports the following attributes:
+        0x00000-0xFFFFF WB only (no VGA MMIO hole)
+
+      This is a special case of the previous case, and the mmap should
+      fail for the same reason as above.
+
+NOTES
+
+    [1] SDM rev 2.2, vol 2, sec 4.4.1.
+    [2] SDM rev 2.2, vol 2, sec 4.4.6.
Index: work-mm6/include/linux/efi.h
=================================--- work-mm6.orig/include/linux/efi.h	2006-05-04 16:33:58.000000000 -0600
+++ work-mm6/include/linux/efi.h	2006-05-04 16:35:22.000000000 -0600
@@ -294,6 +294,7 @@
 extern u64 efi_get_iobase (void);
 extern u32 efi_mem_type (unsigned long phys_addr);
 extern u64 efi_mem_attributes (unsigned long phys_addr);
+extern u64 efi_mem_attribute (unsigned long phys_addr, unsigned long size);
 extern int efi_mem_attribute_range (unsigned long phys_addr, unsigned long size,
 				    u64 attr);
 extern int __init efi_uart_console_only (void);
Index: work-mm6/include/asm-ia64/io.h
=================================--- work-mm6.orig/include/asm-ia64/io.h	2006-05-04 16:33:58.000000000 -0600
+++ work-mm6/include/asm-ia64/io.h	2006-05-04 16:35:22.000000000 -0600
@@ -88,6 +88,7 @@
 }
 
 #define ARCH_HAS_VALID_PHYS_ADDR_RANGE
+extern u64 kern_mem_attribute (unsigned long phys_addr, unsigned long size);
 extern int valid_phys_addr_range (unsigned long addr, size_t count); /* efi.c */
 extern int valid_mmap_phys_addr_range (unsigned long addr, size_t count);
 
Index: work-mm6/include/asm-ia64/pgtable.h
=================================--- work-mm6.orig/include/asm-ia64/pgtable.h	2006-05-04 16:33:58.000000000 -0600
+++ work-mm6/include/asm-ia64/pgtable.h	2006-05-04 16:35:22.000000000 -0600
@@ -317,22 +317,20 @@
 #define pte_mkhuge(pte)		(__pte(pte_val(pte)))
 
 /*
- * Macro to a page protection value as "uncacheable".  Note that "protection" is really a
- * misnomer here as the protection value contains the memory attribute bits, dirty bits,
- * and various other bits as well.
+ * Make page protection values cacheable, uncacheable, or write-
+ * combining.  Note that "protection" is really a misnomer here as the
+ * protection value contains the memory attribute bits, dirty bits, and
+ * various other bits as well.
  */
+#define pgprot_cacheable(prot)		__pgprot((pgprot_val(prot) & ~_PAGE_MA_MASK) | _PAGE_MA_WB)
 #define pgprot_noncached(prot)		__pgprot((pgprot_val(prot) & ~_PAGE_MA_MASK) | _PAGE_MA_UC)
-
-/*
- * Macro to make mark a page protection value as "write-combining".
- * Note that "protection" is really a misnomer here as the protection
- * value contains the memory attribute bits, dirty bits, and various
- * other bits as well.  Accesses through a write-combining translation
- * works bypasses the caches, but does allow for consecutive writes to
- * be combined into single (but larger) write transactions.
- */
 #define pgprot_writecombine(prot)	__pgprot((pgprot_val(prot) & ~_PAGE_MA_MASK) | _PAGE_MA_WC)
 
+struct file;
+extern pgprot_t phys_mem_access_prot(struct file *file, unsigned long pfn,
+				     unsigned long size, pgprot_t vma_prot);
+#define __HAVE_PHYS_MEM_ACCESS_PROT
+
 static inline unsigned long
 pgd_index (unsigned long address)
 {
Index: work-mm6/arch/ia64/kernel/efi.c
=================================--- work-mm6.orig/arch/ia64/kernel/efi.c	2006-05-04 16:33:58.000000000 -0600
+++ work-mm6/arch/ia64/kernel/efi.c	2006-05-05 10:05:10.000000000 -0600
@@ -8,6 +8,8 @@
  * Copyright (C) 1999-2003 Hewlett-Packard Co.
  *	David Mosberger-Tang <davidm@hpl.hp.com>
  *	Stephane Eranian <eranian@hpl.hp.com>
+ * (c) Copyright 2006 Hewlett-Packard Development Company, L.P.
+ *	Bjorn Helgaas <bjorn.helgaas@hp.com>
  *
  * All EFI Runtime Services are not implemented yet as EFI only
  * supports physical mode addressing on SoftSDV. This is to be fixed
@@ -622,28 +624,20 @@
 	return 0;
 }
 
-static efi_memory_desc_t *
-efi_memory_descriptor (unsigned long phys_addr)
+static struct kern_memdesc *
+kern_memory_descriptor (unsigned long phys_addr)
 {
-	void *efi_map_start, *efi_map_end, *p;
-	efi_memory_desc_t *md;
-	u64 efi_desc_size;
-
-	efi_map_start = __va(ia64_boot_param->efi_memmap);
-	efi_map_end   = efi_map_start + ia64_boot_param->efi_memmap_size;
-	efi_desc_size = ia64_boot_param->efi_memdesc_size;
+	struct kern_memdesc *md;
 
-	for (p = efi_map_start; p < efi_map_end; p += efi_desc_size) {
-		md = p;
-
-		if (phys_addr - md->phys_addr < (md->num_pages << EFI_PAGE_SHIFT))
+	for (md = kern_memmap; md->start != ~0UL; md++) {
+		if (phys_addr - md->start < (md->num_pages << EFI_PAGE_SHIFT))
 			 return md;
 	}
 	return 0;
 }
 
-static int
-efi_memmap_has_mmio (void)
+static efi_memory_desc_t *
+efi_memory_descriptor (unsigned long phys_addr)
 {
 	void *efi_map_start, *efi_map_end, *p;
 	efi_memory_desc_t *md;
@@ -656,8 +650,8 @@
 	for (p = efi_map_start; p < efi_map_end; p += efi_desc_size) {
 		md = p;
 
-		if (md->type = EFI_MEMORY_MAPPED_IO)
-			return 1;
+		if (phys_addr - md->phys_addr < (md->num_pages << EFI_PAGE_SHIFT))
+			 return md;
 	}
 	return 0;
 }
@@ -683,71 +677,125 @@
 }
 EXPORT_SYMBOL(efi_mem_attributes);
 
-/*
- * Determines whether the memory at phys_addr supports the desired
- * attribute (WB, UC, etc).  If this returns 1, the caller can safely
- * access size bytes at phys_addr with the specified attribute.
- */
-int
-efi_mem_attribute_range (unsigned long phys_addr, unsigned long size, u64 attr)
+u64
+efi_mem_attribute (unsigned long phys_addr, unsigned long size)
 {
 	unsigned long end = phys_addr + size;
 	efi_memory_desc_t *md = efi_memory_descriptor(phys_addr);
+	u64 attr;
+
+	if (!md)
+		return 0;
+
+	/*
+	 * EFI_MEMORY_RUNTIME is not a memory attribute; it just tells
+	 * the kernel that firmware needs this region mapped.
+	 */
+	attr = md->attribute & ~EFI_MEMORY_RUNTIME;
+	do {
+		unsigned long md_end = efi_md_end(md);
+
+		if (end <= md_end)
+			return attr;
+
+		md = efi_memory_descriptor(md_end);
+		if (!md || (md->attribute & ~EFI_MEMORY_RUNTIME) != attr)
+			return 0;
+	} while (md);
+	return 0;
+}
+
+u64
+kern_mem_attribute (unsigned long phys_addr, unsigned long size)
+{
+	unsigned long end = phys_addr + size;
+	struct kern_memdesc *md;
+	u64 attr;
 
 	/*
-	 * Some firmware doesn't report MMIO regions in the EFI memory
-	 * map.  The Intel BigSur (a.k.a. HP i2000) has this problem.
-	 * On those platforms, we have to assume UC is valid everywhere.
+	 * This is a hack for ioremap calls before we set up kern_memmap.
+	 * Maybe we should do efi_memmap_init() earlier instead.
 	 */
-	if (!md || (md->attribute & attr) != attr) {
-		if (attr = EFI_MEMORY_UC && !efi_memmap_has_mmio())
-			return 1;
+	if (!kern_memmap) {
+		attr = efi_mem_attribute(phys_addr, size);
+		if (attr & EFI_MEMORY_WB)
+			return EFI_MEMORY_WB;
 		return 0;
 	}
 
+	md = kern_memory_descriptor(phys_addr);
+	if (!md)
+		return 0;
+
+	attr = md->attribute;
 	do {
-		unsigned long md_end = efi_md_end(md);
+		unsigned long md_end = kmd_end(md);
 
 		if (end <= md_end)
-			return 1;
+			return attr;
 
-		md = efi_memory_descriptor(md_end);
-		if (!md || (md->attribute & attr) != attr)
+		md = kern_memory_descriptor(md_end);
+		if (!md || md->attribute != attr)
 			return 0;
 	} while (md);
 	return 0;
 }
+EXPORT_SYMBOL(kern_mem_attribute);
 
-/*
- * For /dev/mem, we only allow read & write system calls to access
- * write-back memory, because read & write don't allow the user to
- * control access size.
- */
 int
 valid_phys_addr_range (unsigned long phys_addr, unsigned long size)
 {
-	return efi_mem_attribute_range(phys_addr, size, EFI_MEMORY_WB);
+	u64 attr;
+
+	/*
+	 * /dev/mem reads and writes use copy_to_user(), which implicitly
+	 * uses a granule-sized kernel identity mapping.  It's really
+	 * only safe to do this for regions in kern_memmap.  For more
+	 * details, see Documentation/ia64/aliasing.txt.
+	 */
+	attr = kern_mem_attribute(phys_addr, size);
+	if (attr & EFI_MEMORY_WB || attr & EFI_MEMORY_UC)
+		return 1;
+	return 0;
 }
 
-/*
- * We allow mmap of anything in the EFI memory map that supports
- * either write-back or uncacheable access.  For uncacheable regions,
- * the supported access sizes are system-dependent, and the user is
- * responsible for using the correct size.
- *
- * Note that this doesn't currently allow access to hot-added memory,
- * because that doesn't appear in the boot-time EFI memory map.
- */
 int
 valid_mmap_phys_addr_range (unsigned long phys_addr, unsigned long size)
 {
-	if (efi_mem_attribute_range(phys_addr, size, EFI_MEMORY_WB))
-		return 1;
+	/*
+	 * MMIO regions are often missing from the EFI memory map.
+	 * We must allow mmap of them for programs like X, so we
+	 * currently can't do any useful validation.
+	 */
+	return 1;
+}
 
-	if (efi_mem_attribute_range(phys_addr, size, EFI_MEMORY_UC))
-		return 1;
+pgprot_t
+phys_mem_access_prot(struct file *file, unsigned long pfn, unsigned long size,
+		     pgprot_t vma_prot)
+{
+	unsigned long phys_addr = pfn << PAGE_SHIFT;
+	u64 attr;
 
-	return 0;
+	/*
+	 * For /dev/mem mmap, we use user mappings, but if the region is
+	 * in kern_memmap (and hence may be covered by a kernel mapping),
+	 * we must use the same attribute as the kernel mapping.
+	 */
+	attr = kern_mem_attribute(phys_addr, size);
+	if (attr & EFI_MEMORY_WB)
+		return pgprot_cacheable(vma_prot);
+	else if (attr & EFI_MEMORY_UC)
+		return pgprot_noncached(vma_prot);
+
+	/*
+	 * Some chipsets don't support UC access to memory.  If
+	 * WB is supported, we prefer that.
+	 */
+	if (efi_mem_attribute(phys_addr, size) & EFI_MEMORY_WB)
+		return pgprot_cacheable(vma_prot);
+
+	return pgprot_noncached(vma_prot);
 }
 
 int __init
Index: work-mm6/arch/ia64/mm/ioremap.c
=================================--- work-mm6.orig/arch/ia64/mm/ioremap.c	2006-05-04 16:33:58.000000000 -0600
+++ work-mm6/arch/ia64/mm/ioremap.c	2006-05-05 09:53:32.000000000 -0600
@@ -11,6 +11,7 @@
 #include <linux/module.h>
 #include <linux/efi.h>
 #include <asm/io.h>
+#include <asm/meminit.h>
 
 static inline void __iomem *
 __ioremap (unsigned long offset, unsigned long size)
@@ -21,16 +22,29 @@
 void __iomem *
 ioremap (unsigned long offset, unsigned long size)
 {
-	if (efi_mem_attribute_range(offset, size, EFI_MEMORY_WB))
-		return phys_to_virt(offset);
+	u64 attr;
+	unsigned long gran_base, gran_size;
 
-	if (efi_mem_attribute_range(offset, size, EFI_MEMORY_UC))
+	/*
+	 * For things in kern_memmap, we must use the same attribute
+	 * as the rest of the kernel.  For more details, see
+	 * Documentation/ia64/aliasing.txt.
+	 */
+	attr = kern_mem_attribute(offset, size);
+	if (attr & EFI_MEMORY_WB)
+		return phys_to_virt(offset);
+	else if (attr & EFI_MEMORY_UC)
 		return __ioremap(offset, size);
 
 	/*
-	 * Someday this should check ACPI resources so we
-	 * can do the right thing for hot-plugged regions.
+	 * Some chipsets don't support UC access to memory.  If
+	 * WB is supported for the whole granule, we prefer that.
 	 */
+	gran_base = GRANULEROUNDDOWN(offset);
+	gran_size = GRANULEROUNDUP(offset + size) - gran_base;
+	if (efi_mem_attribute(gran_base, gran_size) & EFI_MEMORY_WB)
+		return phys_to_virt(offset);
+
 	return __ioremap(offset, size);
 }
 EXPORT_SYMBOL(ioremap);
@@ -38,6 +52,9 @@
 void __iomem *
 ioremap_nocache (unsigned long offset, unsigned long size)
 {
+	if (kern_mem_attribute(offset, size) & EFI_MEMORY_WB)
+		return 0;
+
 	return __ioremap(offset, size);
 }
 EXPORT_SYMBOL(ioremap_nocache);
Index: work-mm6/arch/ia64/pci/pci.c
=================================--- work-mm6.orig/arch/ia64/pci/pci.c	2006-05-04 16:33:58.000000000 -0600
+++ work-mm6/arch/ia64/pci/pci.c	2006-05-05 10:13:56.000000000 -0600
@@ -645,18 +645,31 @@
 int
 pci_mmap_legacy_page_range(struct pci_bus *bus, struct vm_area_struct *vma)
 {
+	unsigned long size = vma->vm_end - vma->vm_start;
+	pgprot_t prot;
 	char *addr;
 
+	/*
+	 * Avoid attribute aliasing.  See Documentation/ia64/aliasing.txt
+	 * for more details.
+	 */
+	if (!valid_mmap_phys_addr_range(vma->vm_pgoff << PAGE_SHIFT, size))
+		return -EINVAL;
+	prot = phys_mem_access_prot(NULL, vma->vm_pgoff, size,
+				    vma->vm_page_prot);
+	if (pgprot_val(prot) != pgprot_val(pgprot_noncached(vma->vm_page_prot)))
+		return -EINVAL;
+
 	addr = pci_get_legacy_mem(bus);
 	if (IS_ERR(addr))
 		return PTR_ERR(addr);
 
 	vma->vm_pgoff += (unsigned long)addr >> PAGE_SHIFT;
-	vma->vm_page_prot = pgprot_noncached(vma->vm_page_prot);
+	vma->vm_page_prot = prot;
 	vma->vm_flags |= (VM_SHM | VM_RESERVED | VM_IO);
 
 	if (remap_pfn_range(vma, vma->vm_start, vma->vm_pgoff,
-			    vma->vm_end - vma->vm_start, vma->vm_page_prot))
+			    size, vma->vm_page_prot))
 		return -EAGAIN;
 
 	return 0;
