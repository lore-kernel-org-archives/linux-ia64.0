From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Thu, 23 Oct 2003 21:05:34 +0000
Subject: Re: [RFC] prevent "dd if=/dev/mem" crash
Message-Id: <marc-linux-ia64-106694415231396@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106642876514553@msgid-missing>
In-Reply-To: <marc-linux-ia64-106642876514553@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The drivers/char/mem.c change was accepted, so here's the
ia64-specific part.

=== arch/ia64/kernel/efi.c 1.26 vs edited ==--- 1.26/arch/ia64/kernel/efi.c	Tue Oct 21 18:52:48 2003
+++ edited/arch/ia64/kernel/efi.c	Thu Oct 23 14:35:08 2003
@@ -711,6 +711,32 @@
 	return 0;
 }
 
+int
+valid_phys_addr_range (unsigned long phys_addr, unsigned long *size)
+{
+	void *efi_map_start, *efi_map_end, *p;
+	efi_memory_desc_t *md;
+	u64 efi_desc_size;
+
+	efi_map_start = __va(ia64_boot_param->efi_memmap);
+	efi_map_end   = efi_map_start + ia64_boot_param->efi_memmap_size;
+	efi_desc_size = ia64_boot_param->efi_memdesc_size;
+
+	for (p = efi_map_start; p < efi_map_end; p += efi_desc_size) {
+		md = p;
+
+		if (phys_addr - md->phys_addr < (md->num_pages << EFI_PAGE_SHIFT)) {
+			if (!(md->attribute & EFI_MEMORY_WB))
+				return 0;
+
+			if (*size > md->phys_addr + (md->num_pages << EFI_PAGE_SHIFT) - phys_addr)
+				*size = md->phys_addr + (md->num_pages << EFI_PAGE_SHIFT) - phys_addr;
+			return 1;
+		}
+	}
+	return 0;
+}
+
 static void __exit
 efivars_exit (void)
 {
=== include/asm-ia64/io.h 1.17 vs edited ==--- 1.17/include/asm-ia64/io.h	Wed Aug 20 00:13:39 2003
+++ edited/include/asm-ia64/io.h	Thu Oct 23 14:32:42 2003
@@ -72,6 +72,9 @@
 	return (void *) (address + PAGE_OFFSET);
 }
 
+#define ARCH_HAS_VALID_PHYS_ADDR_RANGE
+extern int valid_phys_addr_range (unsigned long addr, size_t *count); /* efi.c */
+
 /*
  * The following two macros are deprecated and scheduled for removal.
  * Please use the PCI-DMA interface defined in <asm/pci.h> instead.

