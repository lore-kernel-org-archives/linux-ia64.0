From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Thu, 30 Mar 2006 16:53:39 +0000
Subject: Re: [Fedora-ia64-list] kernel 2.6.16-1.2097_FC6 unbootable on Itanium
Message-Id: <200603300953.39279.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <442AB6DD.4020800@sgi.com>
In-Reply-To: <442AB6DD.4020800@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thursday 30 March 2006 08:16, Jack Steiner wrote:
> acpi_os_map_memory() has changed the order of checking the EFI attributes on
> pages being mapped. In 2.6.15, if the EFI map indicates that an address
> supports both cached & uncached references, acpi_os_map_memory() would map
> it as cached.

> OLD:
>         acpi_os_map_memory
>                 if (EFI_MEMORY_WB & efi_mem_attributes(phys)) {
>                         *virt = (void __iomem *)phys_to_virt(phys);
>                 } else {
>                         *virt = ioremap(phys, size);
>                 }
> 
> NEW
>         acpi_os_map_memory() unconditionally calls ioremap() to do the
>         mapping
> 
>         ioremap
>                 if (efi_mem_attribute_range(offset, size, EFI_MEMORY_UC))
>                          return __ioremap(offset, size);
> 
>                 if (efi_mem_attribute_range(offset, size, EFI_MEMORY_WB))
>                          return phys_to_virt(offset);

I debated whether to check for UC or WB first, and I think I got it
wrong.  My reasoning for UC first was that it was a smaller change
for the typical case CSR mapping case, because ioremap() used to
*always* return UC mappings.

But efi_memmap_init() collects full granules of WB memory, without
regard for whether they also support UC.  So if ioremap() needs to
work for main memory (which is slightly strange in itself, but seems
to be the precedent), it needs to prefer WB mappings when possible.

> Earlier in the boot, the ACPI tables are unconditionally references as cached:
> 
>         char *__acpi_map_table(unsigned long phys_addr, unsigned long size)
>         {
>                 return __va(phys_addr);
>         }

This seems suspicious to me.  But we look at some of these ACPI tables
prior to calling efi_memmap_init(), so it might not be safe to use
ioremap() yet.  It's conceivable that a platform could place ACPI
tables in UC-only ROM, and this would blow up.  But I guess we
haven't tripped over that yet.

Does the patch below solve your immediate problem?


[IA64] ioremap() should prefer WB over UC

efi_memmap_init() collects full granules of WB memory, without
regard for whether they also support UC.  So in order for ioremap()
to work for main memory, it must prefer WB mappings when possible.

Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>

Index: work-mm5/arch/ia64/mm/ioremap.c
=================================--- work-mm5.orig/arch/ia64/mm/ioremap.c	2006-03-23 10:22:40.000000000 -0700
+++ work-mm5/arch/ia64/mm/ioremap.c	2006-03-30 09:36:57.000000000 -0700
@@ -21,12 +21,12 @@
 void __iomem *
 ioremap (unsigned long offset, unsigned long size)
 {
-	if (efi_mem_attribute_range(offset, size, EFI_MEMORY_UC))
-		return __ioremap(offset, size);
-
 	if (efi_mem_attribute_range(offset, size, EFI_MEMORY_WB))
 		return phys_to_virt(offset);
 
+	if (efi_mem_attribute_range(offset, size, EFI_MEMORY_UC))
+		return __ioremap(offset, size);
+
 	/*
 	 * Someday this should check ACPI resources so we
 	 * can do the right thing for hot-plugged regions.
