From: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 21 Dec 2004 07:20:29 +0000
Subject: [PATCH] modifing vmemmap initialization [1/1] : modifies init sequence
Message-Id: <41C7CEBD.6030709@jp.fujitsu.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------030600000507050900060907"
List-Id: <linux-ia64.vger.kernel.org>
References: <41C7CC9E.7080602@jp.fujitsu.com>
In-Reply-To: <41C7CC9E.7080602@jp.fujitsu.com>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------030600000507050900060907
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit


This patch adjust calling sequence of virtual_mem_map_alloc(),
which is added by previous patch.

There are 3 combinations of config..
CONFIG_DISCONTIGMEM != y && CONFIG_VIRTUAL_MEM_MAP != y
CONFIG_DISCONTIGMEM != y && CONFIG_VIRTUAL_MEM_MAP  = y
CONFIG_DISCONTIGMEM  = y && CONFIG_VIRTUAL_MEM_MAP  = y
I don't want to use many #ifdefs but..


-- Kame <kamezawa.horoyu@jp.fujitsu.com>


--------------030600000507050900060907
Content-Type: text/x-patch;
 name="vmemmap_adjust_callpath.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="vmemmap_adjust_callpath.patch"


Curret ia64's vmem_map initialization path is different from other archs.
This patch modifies it.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


---

 linux-2.6.10-rc3-mm1-kamezawa/arch/ia64/mm/contig.c      |    2 --
 linux-2.6.10-rc3-mm1-kamezawa/arch/ia64/mm/discontig.c   |    6 ------
 linux-2.6.10-rc3-mm1-kamezawa/arch/ia64/mm/init.c        |    7 ++++---
 linux-2.6.10-rc3-mm1-kamezawa/include/asm-ia64/meminit.h |    2 +-
 linux-2.6.10-rc3-mm1-kamezawa/mm/page_alloc.c            |    7 +++++--
 5 files changed, 10 insertions(+), 14 deletions(-)

diff -puN arch/ia64/mm/init.c~vmemmap_adjust_callpath arch/ia64/mm/init.c
--- linux-2.6.10-rc3-mm1/arch/ia64/mm/init.c~vmemmap_adjust_callpath	2004-12-21 14:55:46.204902072 +0900
+++ linux-2.6.10-rc3-mm1-kamezawa/arch/ia64/mm/init.c	2004-12-21 14:55:46.216900248 +0900
@@ -407,7 +407,7 @@ create_mem_map_page_table (u64 start, u6
 	return 0;
 }
 
-void
+struct page *
 virtual_mem_map_alloc(struct pglist_data *pgdat)
 {
 	unsigned long map_size;
@@ -415,7 +415,7 @@ virtual_mem_map_alloc(struct pglist_data
 	unsigned long max_gap = 0;
 	efi_memmap_walk(find_largest_hole, (u64 *)&max_gap);
 	if (max_gap < LARGE_GAP) {
-		return;
+		return NULL;
 	}
 #endif
 	if (pgdat == NODE_DATA(0)) {
@@ -428,7 +428,8 @@ virtual_mem_map_alloc(struct pglist_data
 		mem_map = vmem_map;
 #endif
 	}
-	return;
+	pgdat->node_mem_map  = vmem_map + pgdat->node_start_pfn;
+	return pgdat->node_mem_map;
 }
 
 struct memmap_init_callback_data {
diff -puN arch/ia64/mm/contig.c~vmemmap_adjust_callpath arch/ia64/mm/contig.c
--- linux-2.6.10-rc3-mm1/arch/ia64/mm/contig.c~vmemmap_adjust_callpath	2004-12-21 14:55:46.206901768 +0900
+++ linux-2.6.10-rc3-mm1-kamezawa/arch/ia64/mm/contig.c	2004-12-21 14:55:46.217900096 +0900
@@ -262,8 +262,6 @@ paging_init (void)
 				 (num_physpages - num_dma_physpages));
 		}
 	}
-	virtual_mem_map_alloc(&contig_page_data);
-	contig_page_data.node_mem_map = mem_map;
 	free_area_init_node(0, &contig_page_data, zones_size,
 			    0, zholes_size);
 #else /* !CONFIG_VIRTUAL_MEM_MAP */
diff -puN arch/ia64/mm/discontig.c~vmemmap_adjust_callpath arch/ia64/mm/discontig.c
--- linux-2.6.10-rc3-mm1/arch/ia64/mm/discontig.c~vmemmap_adjust_callpath	2004-12-21 14:55:46.208901464 +0900
+++ linux-2.6.10-rc3-mm1-kamezawa/arch/ia64/mm/discontig.c	2004-12-21 14:55:46.217900096 +0900
@@ -676,13 +676,7 @@ void __init paging_init(void)
 				 mem_data[node].num_dma_physpages);
 		}
 
-		if (node == 0) {
-			virtual_mem_map_alloc(NODE_DATA(0));
-		}
-
 		pfn_offset = mem_data[node].min_pfn;
-
-		NODE_DATA(node)->node_mem_map = vmem_map + pfn_offset;
 		free_area_init_node(node, NODE_DATA(node), zones_size,
 				    pfn_offset, zholes_size);
 	}
diff -puN mm/page_alloc.c~vmemmap_adjust_callpath mm/page_alloc.c
--- linux-2.6.10-rc3-mm1/mm/page_alloc.c~vmemmap_adjust_callpath	2004-12-21 14:55:46.211901008 +0900
+++ linux-2.6.10-rc3-mm1-kamezawa/mm/page_alloc.c	2004-12-21 14:55:46.219899792 +0900
@@ -1738,7 +1738,10 @@ static void __init free_area_init_core(s
 void __init node_alloc_mem_map(struct pglist_data *pgdat)
 {
 	unsigned long size;
-
+#ifdef CONFIG_VIRTUAL_MEM_MAP
+	if (virtual_mem_map_alloc(pgdat))
+		return;
+#endif
 	size = (pgdat->node_spanned_pages + 1) * sizeof(struct page);
 	pgdat->node_mem_map = alloc_bootmem_node(pgdat, size);
 #ifndef CONFIG_DISCONTIGMEM
@@ -1754,7 +1757,7 @@ void __init free_area_init_node(int nid,
 	pgdat->node_start_pfn = node_start_pfn;
 	calculate_zone_totalpages(pgdat, zones_size, zholes_size);
 
-	if (!pfn_to_page(node_start_pfn))
+	if (!pgdat->node_mem_map && pgdat->node_spanned_pages)
 		node_alloc_mem_map(pgdat);
 
 	free_area_init_core(pgdat, zones_size, zholes_size);
diff -puN include/asm-ia64/meminit.h~vmemmap_adjust_callpath include/asm-ia64/meminit.h
--- linux-2.6.10-rc3-mm1/include/asm-ia64/meminit.h~vmemmap_adjust_callpath	2004-12-21 14:55:46.214900552 +0900
+++ linux-2.6.10-rc3-mm1-kamezawa/include/asm-ia64/meminit.h	2004-12-21 14:55:46.220899640 +0900
@@ -56,7 +56,7 @@ extern int filter_rsvd_memory (unsigned 
   extern int find_largest_hole (u64 start, u64 end, void *arg);
   extern int create_mem_map_page_table (u64 start, u64 end, void *arg);
 struct pglist_data;
-  extern void virtual_mem_map_alloc(struct pglist_data *pgdat);
+  extern struct page *virtual_mem_map_alloc(struct pglist_data *pgdat);
 #endif
 
 #endif /* meminit_h */

_

--------------030600000507050900060907--
