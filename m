From: "Bob Picco" <bob.picco@hp.com>
Date: Wed, 17 Jan 2007 13:18:32 +0000
Subject: [PATCH] Register memory ranges in a consistent manner on IA64
Message-Id: <20070117131832.GA27728@localhost>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

While pursuing and unrelated issue with 64Mb granules I noticed a problem
related to inconsistent use of add_active_range. There doesn't appear any
reason to me why FLATMEM versus DISCONTIG_MEM should register memory
to add_active_range with different code. So I've changed the code into
a common implementation. 

The other subtle issue fixed by this patch was calling add_active_range
in count_node_pages before granule aligning is performed. We were lucky with
16MB granules but not so with 64MB granules. count_node_pages has reserved
regions filtered out and as a consequence linked kernel text and data
aren't covered by calls to count_node_pages. So linked kernel regions
wasn't reported to add_active_regions. This resulted in free_initmem causing
numerous bad_page reports. This won't occur with this patch because now
all known memory regions are reported by register_active_ranges.

Acked-by: Mel Gorman <mel@csn.ul.ie>
Signed-off-by: Bob Picco <bob.picco@hp.com>

 arch/ia64/mm/discontig.c   |    4 +++-
 arch/ia64/mm/init.c        |   19 +++++++++++++++++--
 include/asm-ia64/meminit.h |    3 ++-
 3 files changed, 22 insertions(+), 4 deletions(-)

Index: linux-2.6.20-rc4/arch/ia64/mm/discontig.c
=================================--- linux-2.6.20-rc4.orig/arch/ia64/mm/discontig.c	2007-01-11 12:11:08.000000000 -0500
+++ linux-2.6.20-rc4/arch/ia64/mm/discontig.c	2007-01-17 05:27:11.000000000 -0500
@@ -473,6 +473,9 @@ void __init find_memory(void)
 			node_clear(node, memory_less_mask);
 			mem_data[node].min_pfn = ~0UL;
 		}
+
+	efi_memmap_walk(register_active_ranges, NULL);
+
 	/*
 	 * Initialize the boot memory maps in reverse order since that's
 	 * what the bootmem allocator expects
@@ -654,7 +657,6 @@ static __init int count_node_pages(unsig
 {
 	unsigned long end = start + len;
 
-	add_active_range(node, start >> PAGE_SHIFT, end >> PAGE_SHIFT);
 	mem_data[node].num_physpages += len >> PAGE_SHIFT;
 	if (start <= __pa(MAX_DMA_ADDRESS))
 		mem_data[node].num_dma_physpages +Index: linux-2.6.20-rc4/arch/ia64/mm/init.c
=================================--- linux-2.6.20-rc4.orig/arch/ia64/mm/init.c	2007-01-11 10:47:39.000000000 -0500
+++ linux-2.6.20-rc4/arch/ia64/mm/init.c	2007-01-11 12:11:54.000000000 -0500
@@ -19,6 +19,7 @@
 #include <linux/swap.h>
 #include <linux/proc_fs.h>
 #include <linux/bitops.h>
+#include <linux/kexec.h>
 
 #include <asm/a.out.h>
 #include <asm/dma.h>
@@ -594,13 +595,27 @@ find_largest_hole (u64 start, u64 end, v
 	return 0;
 }
 
+#endif /* CONFIG_VIRTUAL_MEM_MAP */
+
 int __init
 register_active_ranges(u64 start, u64 end, void *arg)
 {
-	add_active_range(0, __pa(start) >> PAGE_SHIFT, __pa(end) >> PAGE_SHIFT);
+	int nid = paddr_to_nid(__pa(start));
+
+	if (nid < 0)
+		nid = 0;
+#ifdef CONFIG_KEXEC
+	if (start > crashk_res.start && start < crashk_res.end)
+		start = crashk_res.end;
+	if (end > crashk_res.start && end < crashk_res.end)
+		end = crashk_res.start;
+#endif
+
+	if (start < end)
+		add_active_range(nid, __pa(start) >> PAGE_SHIFT,
+			__pa(end) >> PAGE_SHIFT);
 	return 0;
 }
-#endif /* CONFIG_VIRTUAL_MEM_MAP */
 
 static int __init
 count_reserved_pages (u64 start, u64 end, void *arg)
Index: linux-2.6.20-rc4/include/asm-ia64/meminit.h
=================================--- linux-2.6.20-rc4.orig/include/asm-ia64/meminit.h	2007-01-11 10:47:41.000000000 -0500
+++ linux-2.6.20-rc4/include/asm-ia64/meminit.h	2007-01-11 12:11:54.000000000 -0500
@@ -51,12 +51,13 @@ extern void efi_memmap_init(unsigned lon
 
 #define IGNORE_PFN0	1	/* XXX fix me: ignore pfn 0 until TLB miss handler is updated... */
 
+extern int register_active_ranges (u64 start, u64 end, void *arg);
+
 #ifdef CONFIG_VIRTUAL_MEM_MAP
 # define LARGE_GAP	0x40000000 /* Use virtual mem map if hole is > than this */
   extern unsigned long vmalloc_end;
   extern struct page *vmem_map;
   extern int find_largest_hole (u64 start, u64 end, void *arg);
-  extern int register_active_ranges (u64 start, u64 end, void *arg);
   extern int create_mem_map_page_table (u64 start, u64 end, void *arg);
   extern int vmemmap_find_next_valid_pfn(int, int);
 #else
