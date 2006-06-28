From: "Bob Picco" <bob.picco@hp.com>
Date: Wed, 28 Jun 2006 16:54:55 +0000
Subject: [PATCH] align high endpoint of VIRTUAL_MEM_MAP
Message-Id: <20060628165455.GA31441@localhost>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Tony,

Assure that vmem_map's high endpoint is MAX_ORDER aligned. Not doing so violates
the buddy allocator algorithm. Also anyone using mem=XXX on boot line and 
not aligned to MAX_ORDER requires this patch in order to satisfy buddy 
allocator. vmem_map always starts at pfn 0. The potentially large MAX_ORDER
on ia64 (due to hugetlbfs) requires that the end of vmem_map be aligned
to MAX_ORDER_NR_PAGES.

This was boot tested for: FLATMEM, FLATMEM+VIRTUAL_MEM_MAP, 
DISCONTIGMEM+VIRTUAL_MEM_MAP and SPARSEMEM.

bob

Signed-off-by: Bob Picco <bob.picco@hp.com>

 arch/ia64/mm/contig.c    |    3 ++-
 arch/ia64/mm/discontig.c |    3 ++-
 2 files changed, 4 insertions(+), 2 deletions(-)

Index: linux-2.6.17/arch/ia64/mm/contig.c
=================================--- linux-2.6.17.orig/arch/ia64/mm/contig.c	2006-06-19 19:20:11.000000000 -0400
+++ linux-2.6.17/arch/ia64/mm/contig.c	2006-06-19 19:20:12.000000000 -0400
@@ -283,7 +283,8 @@ paging_init (void)
 
 		/* allocate virtual_mem_map */
 
-		map_size = PAGE_ALIGN(max_low_pfn * sizeof(struct page));
+		map_size = PAGE_ALIGN(ALIGN(max_low_pfn, MAX_ORDER_NR_PAGES) *
+			sizeof(struct page));
 		vmalloc_end -= map_size;
 		vmem_map = (struct page *) vmalloc_end;
 		efi_memmap_walk(create_mem_map_page_table, NULL);
Index: linux-2.6.17/arch/ia64/mm/discontig.c
=================================--- linux-2.6.17.orig/arch/ia64/mm/discontig.c	2006-06-19 19:20:11.000000000 -0400
+++ linux-2.6.17/arch/ia64/mm/discontig.c	2006-06-19 19:20:12.000000000 -0400
@@ -675,7 +675,8 @@ void __init paging_init(void)
 	efi_memmap_walk(filter_rsvd_memory, count_node_pages);
 
 #ifdef CONFIG_VIRTUAL_MEM_MAP
-	vmalloc_end -= PAGE_ALIGN(max_low_pfn * sizeof(struct page));
+	vmalloc_end -= PAGE_ALIGN(ALIGN(max_low_pfn, MAX_ORDER_NR_PAGES) *
+		sizeof(struct page));
 	vmem_map = (struct page *) vmalloc_end;
 	efi_memmap_walk(create_mem_map_page_table, NULL);
 	printk("Virtual mem_map starts at 0x%p\n", vmem_map);
