From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Fri, 17 Oct 2003 22:13:44 +0000
Subject: [PATCH] fix EFI memory map trimming
Message-Id: <marc-linux-ia64-106642910714855@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This fixes a problem in EFI memory map trimming.  I've never been
able to wrap my head around the existing code, so this is perhaps
more of a rewrite than it ought to be, but ... well, you can see
what you think.

For example, here's part of the memory map on my i2000:

    mem00: type=4, attr=0x9, range=[0x0000000000000000-0x0000000000001000) (0MB)
    mem01: type=7, attr=0x9, range=[0x0000000000001000-0x0000000000088000) (0MB)
    mem02: type=4, attr=0x9, range=[0x0000000000088000-0x00000000000a0000) (0MB)
    mem03: type=5, attr=0x8000000000000009, range=[0x00000000000c0000-0x0000000000100000) (0MB)
    mem04: type=7, attr=0x9, range=[0x0000000000100000-0x0000000004000000) (63MB)
    mem05: type=2, attr=0x9, range=[0x0000000004000000-0x00000000049ba000) (9MB)
    mem06: type=7, attr=0x9, range=[0x00000000049ba000-0x000000007ec0b000) (1954MB)
    ...

There's a hole at 0xa0000-0xc0000, so we should ignore all the WB memory
in that granule.  With 16MB granules, the existing code trims like this
(note the 4K page at 0x0 should have been ignored, but wasn't):

    efi.trim_bottom: ignoring 540KB of memory at 0x1000 due to granule hole at 0x0
    efi.trim_bottom: ignoring 96KB of memory at 0x88000 due to granule hole at 0x0
    efi.trim_bottom: ignoring 15360KB of memory at 0x100000 due to granule hole at 0x0

The patch makes it trim correctly, like this:

    efi.trim_top: ignoring 4KB of memory at 0x0 due to granule hole at 0x0
    efi.trim_top: ignoring 540KB of memory at 0x1000 due to granule hole at 0x0
    efi.trim_top: ignoring 96KB of memory at 0x88000 due to granule hole at 0x0
    efi.trim_bottom: ignoring 15360KB of memory at 0x100000 due to granule hole at 0x0

This patch is for 2.6.

Bjorn

=== arch/ia64/kernel/efi.c 1.24 vs edited ==--- 1.24/arch/ia64/kernel/efi.c	Wed Sep 10 08:26:40 2003
+++ edited/arch/ia64/kernel/efi.c	Fri Oct 17 12:51:59 2003
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
 
+			if (check_md->attribute & EFI_MEMORY_WB &&
+			    check_md->phys_addr = first_non_wb_addr)
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

