From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Fri, 30 Mar 2007 16:35:43 +0000
Subject: [patch 4/5] ia64: fail mmaps that span areas with incompatible attributes
Message-Id: <200703301035.43391.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200703211622.05198.bjorn.helgaas@hp.com>
In-Reply-To: <200703211622.05198.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Example memory map (from HP sx1000 with VGA enabled):
    0x00000 - 0x9FFFF supports only WB (cacheable) access
    0xA0000 - 0xBFFFF supports only UC (uncacheable) access
    0xC0000 - 0xFFFFF supports only WB (cacheable) access

Some versions of X map the entire 0x00000-0xFFFFF area at once.  With the
example above, this mmap must fail because there's no memory attribute that's
safe for the entire area.

Prior to this patch, we performed the mmap with a UC mapping.  When X
accessed the WB memory at 0xC0000, it caused an MCA.  The crash can happen
when mapping 0xC0000 from either /dev/mem or a /sys/.../legacy_mem file.

Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>

Index: work-mm10/arch/ia64/kernel/efi.c
=================================--- work-mm10.orig/arch/ia64/kernel/efi.c	2007-03-20 21:07:28.000000000 -0700
+++ work-mm10/arch/ia64/kernel/efi.c	2007-03-20 21:13:05.000000000 -0700
@@ -663,6 +663,29 @@
 	return NULL;
 }
 
+static int
+efi_memmap_intersects (unsigned long phys_addr, unsigned long size)
+{
+	void *efi_map_start, *efi_map_end, *p;
+	efi_memory_desc_t *md;
+	u64 efi_desc_size;
+	unsigned long end;
+
+	efi_map_start = __va(ia64_boot_param->efi_memmap);
+	efi_map_end   = efi_map_start + ia64_boot_param->efi_memmap_size;
+	efi_desc_size = ia64_boot_param->efi_memdesc_size;
+
+	end = phys_addr + size;
+
+	for (p = efi_map_start; p < efi_map_end; p += efi_desc_size) {
+		md = p;
+
+		if (md->phys_addr < end && efi_md_end(md) > phys_addr)
+			return 1;
+	}
+	return 0;
+}
+
 u32
 efi_mem_type (unsigned long phys_addr)
 {
@@ -769,11 +792,28 @@
 int
 valid_mmap_phys_addr_range (unsigned long pfn, unsigned long size)
 {
+	unsigned long phys_addr = pfn << PAGE_SHIFT;
+	u64 attr;
+
+	attr = efi_mem_attribute(phys_addr, size);
+
 	/*
-	 * MMIO regions are often missing from the EFI memory map.
-	 * We must allow mmap of them for programs like X, so we
-	 * currently can't do any useful validation.
+	 * /dev/mem mmap uses normal user pages, so we don't need the entire
+	 * granule, but the entire region we're mapping must support the same
+	 * attribute.
 	 */
+	if (attr & EFI_MEMORY_WB || attr & EFI_MEMORY_UC)
+		return 1;
+
+	/*
+	 * Intel firmware doesn't tell us about all the MMIO regions, so
+	 * in general we have to allow mmap requests.  But if EFI *does*
+	 * tell us about anything inside this region, we should deny it.
+	 * The user can always map a smaller region to avoid the overlap.
+	 */
+	if (efi_memmap_intersects(phys_addr, size))
+		return 0;
+
 	return 1;
 }
 
