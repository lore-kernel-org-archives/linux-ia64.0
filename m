From: John Marvin <jsm@udlkern.fc.hp.com>
Date: Fri, 26 Jul 2002 13:35:11 +0000
Subject: [Linux-ia64] [PATCH] arch/ia64/kernel/efi.c
Message-Id: <marc-linux-ia64-105590701905832@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

In doing some testing, I discovered the the mem= kernel command line option
doesn't behave as expected for zx1 based machines. The current implementation
assumes that memory starts at physical address zero and is physically
contiguous, i.e. the mem= value is used as a limit on the physical address,
rather than specifying the maximum physical memory to use.

I've enclosed a patch to fix the problem.  Since this is primarily a
debugging option, this isn't a critical fix.

John Marvin
jsm@fc.hp.com

--- arch/ia64/kernel/efi.c.old	Mon Oct 17 14:01:13 2044
+++ arch/ia64/kernel/efi.c	Mon Oct 17 14:01:31 2044
@@ -210,6 +210,7 @@ efi_memmap_walk (efi_freemem_callback_t 
 	void *efi_map_start, *efi_map_end, *p, *q;
 	efi_memory_desc_t *md, *check_md;
 	u64 efi_desc_size, start, end, granule_addr, first_non_wb_addr = 0;
+       unsigned long mem_found = 0;
 
 	efi_map_start = __va(ia64_boot_param->efi_memmap);
 	efi_map_end   = efi_map_start + ia64_boot_param->efi_memmap_size;
@@ -259,14 +260,16 @@ efi_memmap_walk (efi_freemem_callback_t 
 		trim_top(md, first_non_wb_addr);
 
 		if (is_available_memory(md)) {
-			if (md->phys_addr + (md->num_pages << EFI_PAGE_SHIFT) > mem_limit) {
-				if (md->phys_addr > mem_limit)
+			if (mem_found + (md->num_pages << EFI_PAGE_SHIFT) > mem_limit) {
+				if (mem_found >= mem_limit)
 					continue;
-				md->num_pages = (mem_limit - md->phys_addr) >> EFI_PAGE_SHIFT;
+				md->num_pages = (mem_limit - mem_found) >> EFI_PAGE_SHIFT;
 			}
 
 			if (md->num_pages = 0)
 				continue;
+
+			mem_found += (md->num_pages << EFI_PAGE_SHIFT);
 
 			curr.start = PAGE_OFFSET + md->phys_addr;
 			curr.end   = curr.start + (md->num_pages << EFI_PAGE_SHIFT);

