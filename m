From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Mon, 20 Oct 2003 15:54:16 +0000
Subject: Re: [PATCH] fix EFI memory map trimming
Message-Id: <marc-linux-ia64-106666531709649@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106642910714855@msgid-missing>
In-Reply-To: <marc-linux-ia64-106642910714855@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Friday 17 October 2003 7:09 pm, David Mosberger wrote:
> +			if (check_md->attribute & EFI_MEMORY_WB &&
> +			    check_md->phys_addr = first_non_wb_addr)
> 
> This needs a pair of parens to avoid a compiler warning, I think.

gcc-3.3.2 doesn't warn either way, but here's a version with
the extra parens:

=== arch/ia64/kernel/efi.c 1.24 vs edited ==--- 1.24/arch/ia64/kernel/efi.c	Wed Sep 10 08:26:40 2003
+++ edited/arch/ia64/kernel/efi.c	Mon Oct 20 09:51:02 2003
@@ -297,9 +297,9 @@
 		u64 start;
 		u64 end;
 	} prev, curr;
-	void *efi_map_start, *efi_map_end, *p, *q, *r;
+	void *efi_map_start, *efi_map_end, *p, *q;
 	efi_memory_desc_t *md, *check_md;
-	u64 efi_desc_size, start, end, granule_addr, first_non_wb_addr = 0;
+	u64 efi_desc_size, start, end, granule_addr, last_granule_addr, first_non_wb_addr = 0;
 
 	efi_map_start = __va(ia64_boot_param->efi_memmap);
 	efi_map_end   = efi_map_start + ia64_boot_param->efi_memmap_size;
@@ -312,41 +312,34 @@
 		if (!(md->attribute & EFI_MEMORY_WB))
 			continue;
 
-		if (md->phys_addr + (md->num_pages << EFI_PAGE_SHIFT) > first_non_wb_addr) {
-			/*
-			 * Search for the next run of contiguous WB memory.  Start search
-			 * at first granule boundary covered by md.
-			 */
-			granule_addr = ((md->phys_addr + IA64_GRANULE_SIZE - 1)
-					& -IA64_GRANULE_SIZE);
-			first_non_wb_addr = granule_addr;
-			for (q = p; q < efi_map_end; q += efi_desc_size) {
-				check_md = q;
-
-				if (check_md->attribute & EFI_MEMORY_WB)
-					trim_bottom(check_md, granule_addr);
-
-				if (check_md->phys_addr < granule_addr)
-					continue;
+		/*
+		 * granule_addr is the base of md's first granule.
+		 * [granule_addr - first_non_wb_addr) is guaranteed to
+		 * be contiguous WB memory.
+		 */
+		granule_addr = md->phys_addr & ~(IA64_GRANULE_SIZE - 1);
+		first_non_wb_addr = max(first_non_wb_addr, granule_addr);
 
-				if (!(check_md->attribute & EFI_MEMORY_WB))
-					break;	/* hit a non-WB region; stop search */
+		if (first_non_wb_addr < md->phys_addr) {
+			trim_bottom(md, granule_addr + IA64_GRANULE_SIZE);
+			granule_addr = md->phys_addr & ~(IA64_GRANULE_SIZE - 1);
+			first_non_wb_addr = max(first_non_wb_addr, granule_addr);
+		}
 
-				if (check_md->phys_addr != first_non_wb_addr)
-					break;	/* hit a memory hole; stop search */
+		for (q = p; q < efi_map_end; q += efi_desc_size) {
+			check_md = q;
 
+			if ((check_md->attribute & EFI_MEMORY_WB) &&
+			    (check_md->phys_addr = first_non_wb_addr))
 				first_non_wb_addr += check_md->num_pages << EFI_PAGE_SHIFT;
-			}
-			/* round it down to the previous granule-boundary: */
-			first_non_wb_addr &= -IA64_GRANULE_SIZE;
-
-			if (!(first_non_wb_addr > granule_addr))
-				continue;	/* couldn't find enough contiguous memory */
-
-			for (r = p; r < q; r += efi_desc_size)
-				trim_top(r, first_non_wb_addr);
+			else
+				break;		/* non-WB or hole */
 		}
 
+		last_granule_addr = first_non_wb_addr & ~(IA64_GRANULE_SIZE - 1);
+		if (last_granule_addr < md->phys_addr + (md->num_pages << EFI_PAGE_SHIFT))
+			trim_top(md, last_granule_addr);
+
 		if (is_available_memory(md)) {
 			if (md->phys_addr + (md->num_pages << EFI_PAGE_SHIFT) > mem_limit) {
 				if (md->phys_addr > mem_limit)

