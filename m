From: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 21 Dec 2004 07:11:26 +0000
Subject: [PATCH] modifing vmemmap initialization [0/1] : move vmemmap creation
Message-Id: <41C7CC9E.7080602@jp.fujitsu.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------030500070101070302090302"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------030500070101070302090302
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi

In current tree, mem_map is allocated in mm/page_alloc.c::node_alloc_mem_map()
when !defined(CONFIG_VIRTUAL_MEM_MAP).

So, ia64's vmem_map initialization, which is done before calling free_area_init(),
seems to be different from other archs.

Following 2 patches modifies vmem_map init call sequence to fit to current tree.

all patches are against rc3-mm1.

This patch moves duplicated vmem_map creation call in contig.c/discontig.c to init.c

-- Kame <kamezawa.hiroyu@jp.fujitsu.com>



--------------030500070101070302090302
Content-Type: text/x-patch;
 name="vmemmap_init_cleanup.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="vmemmap_init_cleanup.patch"


This patch moves duplicated vmem_map allocation code from 
arch/ia64/mm/contig.c and arch/ia64/mm/discontig.c
to arch/ia64/mm/init.c.



---

 linux-2.6.10-rc3-mm1-kamezawa/arch/ia64/mm/contig.c      |   27 ++-------------
 linux-2.6.10-rc3-mm1-kamezawa/arch/ia64/mm/discontig.c   |    7 ---
 linux-2.6.10-rc3-mm1-kamezawa/arch/ia64/mm/init.c        |   24 +++++++++++++
 linux-2.6.10-rc3-mm1-kamezawa/include/asm-ia64/meminit.h |    2 +
 4 files changed, 31 insertions(+), 29 deletions(-)

diff -puN arch/ia64/mm/contig.c~vmemmap_init_cleanup arch/ia64/mm/contig.c
--- linux-2.6.10-rc3-mm1/arch/ia64/mm/contig.c~vmemmap_init_cleanup	2004-12-21 14:15:35.383402648 +0900
+++ linux-2.6.10-rc3-mm1-kamezawa/arch/ia64/mm/contig.c	2004-12-21 14:53:13.801070976 +0900
@@ -262,29 +262,10 @@ paging_init (void)
 				 (num_physpages - num_dma_physpages));
 		}
 	}
-
-	max_gap = 0;
-	efi_memmap_walk(find_largest_hole, (u64 *)&max_gap);
-	if (max_gap < LARGE_GAP) {
-		vmem_map = (struct page *) 0;
-		free_area_init_node(0, &contig_page_data, zones_size, 0,
-				    zholes_size);
-	} else {
-		unsigned long map_size;
-
-		/* allocate virtual_mem_map */
-
-		map_size = PAGE_ALIGN(max_low_pfn * sizeof(struct page));
-		vmalloc_end -= map_size;
-		vmem_map = (struct page *) vmalloc_end;
-		efi_memmap_walk(create_mem_map_page_table, NULL);
-
-		mem_map = contig_page_data.node_mem_map = vmem_map;
-		free_area_init_node(0, &contig_page_data, zones_size,
-				    0, zholes_size);
-
-		printk("Virtual mem_map starts at 0x%p\n", mem_map);
-	}
+	virtual_mem_map_alloc(&contig_page_data);
+	contig_page_data.node_mem_map = mem_map;
+	free_area_init_node(0, &contig_page_data, zones_size,
+			    0, zholes_size);
 #else /* !CONFIG_VIRTUAL_MEM_MAP */
 	if (max_low_pfn < max_dma)
 		zones_size[ZONE_DMA] = max_low_pfn;
diff -puN arch/ia64/mm/discontig.c~vmemmap_init_cleanup arch/ia64/mm/discontig.c
--- linux-2.6.10-rc3-mm1/arch/ia64/mm/discontig.c~vmemmap_init_cleanup	2004-12-21 14:15:35.385402344 +0900
+++ linux-2.6.10-rc3-mm1-kamezawa/arch/ia64/mm/discontig.c	2004-12-21 14:53:13.801070976 +0900
@@ -677,12 +677,7 @@ void __init paging_init(void)
 		}
 
 		if (node == 0) {
-			vmalloc_end -=
-				PAGE_ALIGN(max_low_pfn * sizeof(struct page));
-			vmem_map = (struct page *) vmalloc_end;
-
-			efi_memmap_walk(create_mem_map_page_table, NULL);
-			printk("Virtual mem_map starts at 0x%p\n", vmem_map);
+			virtual_mem_map_alloc(NODE_DATA(0));
 		}
 
 		pfn_offset = mem_data[node].min_pfn;
diff -puN arch/ia64/mm/init.c~vmemmap_init_cleanup arch/ia64/mm/init.c
--- linux-2.6.10-rc3-mm1/arch/ia64/mm/init.c~vmemmap_init_cleanup	2004-12-21 14:15:35.388401888 +0900
+++ linux-2.6.10-rc3-mm1-kamezawa/arch/ia64/mm/init.c	2004-12-21 14:54:09.314631632 +0900
@@ -407,6 +407,30 @@ create_mem_map_page_table (u64 start, u6
 	return 0;
 }
 
+void
+virtual_mem_map_alloc(struct pglist_data *pgdat)
+{
+	unsigned long map_size;
+#ifndef CONFIG_DISCONTIGMEM
+	unsigned long max_gap = 0;
+	efi_memmap_walk(find_largest_hole, (u64 *)&max_gap);
+	if (max_gap < LARGE_GAP) {
+		return;
+	}
+#endif
+	if (pgdat == NODE_DATA(0)) {
+		map_size = PAGE_ALIGN(max_low_pfn * sizeof(struct page));
+		vmalloc_end -= map_size;
+		vmem_map = (struct page *)vmalloc_end;
+		efi_memmap_walk(create_mem_map_page_table , NULL);
+		printk("Virtual mem_map starts at 0x%p\n", vmem_map);
+#ifndef CONFIG_DISCONTIGMEM
+		mem_map = vmem_map;
+#endif
+	}
+	return;
+}
+
 struct memmap_init_callback_data {
 	struct page *start;
 	struct page *end;
diff -puN include/asm-ia64/meminit.h~vmemmap_init_cleanup include/asm-ia64/meminit.h
--- linux-2.6.10-rc3-mm1/include/asm-ia64/meminit.h~vmemmap_init_cleanup	2004-12-21 14:39:24.510142360 +0900
+++ linux-2.6.10-rc3-mm1-kamezawa/include/asm-ia64/meminit.h	2004-12-21 14:53:44.072469024 +0900
@@ -55,6 +55,8 @@ extern int filter_rsvd_memory (unsigned 
   extern struct page *vmem_map;
   extern int find_largest_hole (u64 start, u64 end, void *arg);
   extern int create_mem_map_page_table (u64 start, u64 end, void *arg);
+struct pglist_data;
+  extern void virtual_mem_map_alloc(struct pglist_data *pgdat);
 #endif
 
 #endif /* meminit_h */

_

--------------030500070101070302090302--
