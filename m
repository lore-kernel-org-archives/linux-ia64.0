From: Alex Williamson <alex_williamson@hp.com>
Date: Mon, 13 May 2002 15:12:03 +0000
Subject: [Linux-ia64] more prefetch/vga issues
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------A50D29FFF548A95A4BDD34DA"
Message-Id: <marc-linux-ia64-105590701905576@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------A50D29FFF548A95A4BDD34DA
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit


   Thanks to Asit's patch a while back, we've seen a lot less MCA's
from accesses to the VGA range.  There still seems to be one lurking
though.  I've traced it down to the prefetching in free_one_pgd().
This function prefetches farther than it needs to, and can easily
try to prefetch from the VGA MMIO region at 0xa0000.  On an HP zx1
system, this causes an MCA if the VGA card doesn't respond.

   There seem to be (at least) two solutions to this.  One is to
modify mm/memory.c such that it only prefetches to the extent that
it uses.  This might have some performance implications, but they're
likely minimal.  The other alternative, is that efi_memmap_walk()
could detect this situation, and ignore a page of memory.  This can
be a generic test, just checking for usable memory directly adjacent
to MMIO.  I've included diffs to illustrate each solution.  I'd be
interested to know which people think is the more viable alternative
or if there are other potential solutions.  Thanks,

	Alex

--
Alex Williamson                                  Linux Development Lab
alex_williamson@hp.com                                 Hewlett Packard
970-898-9173                                          Fort Collins, CO
--------------A50D29FFF548A95A4BDD34DA
Content-Type: text/plain; charset=us-ascii;
 name="memory_prefetch.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="memory_prefetch.diff"

--- mm/memory.c	25 Jan 2002 20:15:16 -0000	1.2
+++ mm/memory.c	13 May 2002 00:05:05 -0000
@@ -118,8 +118,11 @@ static inline void free_one_pgd(pgd_t * 
 	}
 	pmd = pmd_offset(dir, 0);
 	pgd_clear(dir);
-	for (j = 0; j < PTRS_PER_PMD ; j++) {
+	for (j = 0; j < (PTRS_PER_PMD - (PREFETCH_STRIDE/sizeof(*pmd))) ; j++) {
 		prefetchw(pmd + j + PREFETCH_STRIDE/sizeof(*pmd));
+		free_one_pmd(pmd+j);
+	}
+	for (; j < PTRS_PER_PMD ; j++) {
 		free_one_pmd(pmd+j);
 	}
 	pmd_free(pmd);

--------------A50D29FFF548A95A4BDD34DA
Content-Type: text/plain; charset=us-ascii;
 name="efi.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="efi.diff"

--- arch/ia64/kernel/efi.c	22 Mar 2002 23:39:30 -0000	1.5
+++ arch/ia64/kernel/efi.c	13 May 2002 14:51:24 -0000
@@ -137,7 +137,7 @@ efi_memmap_walk (efi_freemem_callback_t 
 		u64 start;
 		u64 end;
 	} prev, curr;
-	void *efi_map_start, *efi_map_end, *p;
+	void *efi_map_start, *efi_map_end, *p, *p_next;
 	efi_memory_desc_t *md;
 	u64 efi_desc_size, start, end;
 
@@ -164,6 +164,19 @@ efi_memmap_walk (efi_freemem_callback_t 
 				printk("efi_memmap_walk: ignoring empty region at 0x%lx",
 				       md->phys_addr);
 				continue;
+			}
+
+			p_next = (p + efi_desc_size);
+
+			if (p_next < efi_map_end) {
+				efi_memory_desc_t *md_next = p_next;
+
+				if ((md_next->type == EFI_MEMORY_MAPPED_IO) &&
+				    (md_next->phys_addr == (md->phys_addr +
+				    (md->num_pages << 12)))) {
+
+					md->num_pages--;
+				}
 			}
 
 			curr.start = PAGE_OFFSET + md->phys_addr;

--------------A50D29FFF548A95A4BDD34DA--


