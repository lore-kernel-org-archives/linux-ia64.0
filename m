From: Bob Picco <bob.picco@hp.com>
Date: Tue, 04 Oct 2005 19:13:44 +0000
Subject: [PATCH 2/5] V5 ia64 SPARSEMEM - eliminate contig_page_data
Message-Id: <20051004191344.GR25483@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

For FLATMEM contig_page_data has been made transparent to the arch code.
This patch conforms to that change.

Signed-off-by: Bob Picco <bob.picco@hp.com>

 arch/ia64/mm/contig.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

Index: linux-2.6.14-rc2/arch/ia64/mm/contig.c
=================================--- linux-2.6.14-rc2.orig/arch/ia64/mm/contig.c	2005-10-03 19:57:16.000000000 -0400
+++ linux-2.6.14-rc2/arch/ia64/mm/contig.c	2005-10-03 19:57:20.000000000 -0400
@@ -269,7 +269,7 @@ paging_init (void)
 	efi_memmap_walk(find_largest_hole, (u64 *)&max_gap);
 	if (max_gap < LARGE_GAP) {
 		vmem_map = (struct page *) 0;
-		free_area_init_node(0, &contig_page_data, zones_size, 0,
+		free_area_init_node(0, NODE_DATA(0), zones_size, 0,
 				    zholes_size);
 	} else {
 		unsigned long map_size;
@@ -282,7 +282,7 @@ paging_init (void)
 		efi_memmap_walk(create_mem_map_page_table, NULL);
 
 		NODE_DATA(0)->node_mem_map = vmem_map;
-		free_area_init_node(0, &contig_page_data, zones_size,
+		free_area_init_node(0, NODE_DATA(0), zones_size,
 				    0, zholes_size);
 
 		printk("Virtual mem_map starts at 0x%p\n", mem_map);
