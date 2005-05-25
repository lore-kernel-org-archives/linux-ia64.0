From: Bob Picco <bob.picco@hp.com>
Date: Wed, 25 May 2005 15:14:19 +0000
Subject: [patch 4/4] V2 ia64 SPARSEMEM - SPARSEMEM code changes
Message-Id: <20050525151419.GF23448@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This patch is the minimal set of changes required by ia64 to use SPARSEMEM.

Signed-off-by: Bob Picco <bob.picco@hp.com>


 discontig.c |   40 ++++++++++++++++++++++++++++++++++++----
 init.c      |    2 +-
 numa.c      |   27 ++++++++++++++++++++++++++-
 3 files changed, 63 insertions(+), 6 deletions(-)


Index: linux-2.6.12-rc4-mm2-broken/arch/ia64/mm/discontig.c
=================================--- linux-2.6.12-rc4-mm2-broken.orig/arch/ia64/mm/discontig.c	2005-05-17 14:24:17.000000000 -0400
+++ linux-2.6.12-rc4-mm2-broken/arch/ia64/mm/discontig.c	2005-05-23 14:59:53.000000000 -0400
@@ -455,6 +455,29 @@ static void __init initialize_pernode_da
 	}
 }
 
+#ifdef CONFIG_SPARSEMEM
+/**
+ * register_sparse_mem - notify SPARSEMEM that this memory range exists.
+ * @start: physical start of range
+ * @end: physical end of range
+ * @arg: unused
+ *
+ * Simply calls SPARSEMEM to register memory section(s). 
+ */
+static int __init register_sparse_mem(unsigned long start, unsigned long end,
+	void *arg)
+{
+	int nid;
+
+	start = __pa(start) >> PAGE_SHIFT;
+	end = __pa(end) >> PAGE_SHIFT;
+	nid = early_pfn_to_nid(start);
+	memory_present(nid, start, end);
+
+	return 0;
+}
+#endif
+
 /**
  * find_memory - walk the EFI memory map and setup the bootmem allocator
  *
@@ -479,6 +502,9 @@ void __init find_memory(void)
 		reassign_cpu_only_nodes();
 
 	/* These actually end up getting called by call_pernode_memory() */
+#ifdef CONFIG_SPARSEMEM
+	efi_memmap_walk(register_sparse_mem, NULL);
+#endif
 	efi_memmap_walk(filter_rsvd_memory, build_node_maps);
 	efi_memmap_walk(filter_rsvd_memory, find_pernode_space);
 
@@ -560,8 +586,10 @@ void show_mem(void)
 		int shared = 0, cached = 0, reserved = 0;
 		printk("Node ID: %d\n", pgdat->node_id);
 		for(i = 0; i < pgdat->node_spanned_pages; i++) {
-			struct page *page = pgdat_page_nr(pgdat, i);
-			if (!ia64_pfn_valid(pgdat->node_start_pfn+i))
+			struct page *page;
+			if (pfn_valid(pgdat->node_start_pfn + i))
+				page = pfn_to_page(pgdat->node_start_pfn + i);
+			else
 				continue;
 			if (PageReserved(page))
 				reserved++;
@@ -684,6 +712,8 @@ void __init paging_init(void)
 	for_each_online_node(node)
 		mem_data[node].min_pfn = ~0UL;
 
+	sparse_init();
+
 	efi_memmap_walk(filter_rsvd_memory, count_node_pages);
 
 	for_each_online_node(node) {
@@ -719,6 +749,9 @@ void __init paging_init(void)
 				 mem_data[node].num_dma_physpages);
 		}
 
+		pfn_offset = mem_data[node].min_pfn;
+
+#ifndef CONFIG_SPARSEMEM
 		if (node = 0) {
 			vmalloc_end - 				PAGE_ALIGN(max_low_pfn * sizeof(struct page));
@@ -728,9 +761,8 @@ void __init paging_init(void)
 			printk("Virtual mem_map starts at 0x%p\n", vmem_map);
 		}
 
-		pfn_offset = mem_data[node].min_pfn;
-
 		NODE_DATA(node)->node_mem_map = vmem_map + pfn_offset;
+#endif
 		free_area_init_node(node, NODE_DATA(node), zones_size,
 				    pfn_offset, zholes_size);
 	}
Index: linux-2.6.12-rc4-mm2-broken/arch/ia64/mm/init.c
=================================--- linux-2.6.12-rc4-mm2-broken.orig/arch/ia64/mm/init.c	2005-05-16 11:26:07.000000000 -0400
+++ linux-2.6.12-rc4-mm2-broken/arch/ia64/mm/init.c	2005-05-23 14:34:06.000000000 -0400
@@ -569,7 +569,7 @@ mem_init (void)
 	platform_dma_init();
 #endif
 
-#ifndef CONFIG_DISCONTIGMEM
+#ifndef CONFIG_NEED_MULTIPLE_NODES
 	if (!mem_map)
 		BUG();
 	max_mapnr = max_low_pfn;
Index: linux-2.6.12-rc4-mm2-broken/arch/ia64/mm/numa.c
=================================--- linux-2.6.12-rc4-mm2-broken.orig/arch/ia64/mm/numa.c	2005-05-16 11:25:51.000000000 -0400
+++ linux-2.6.12-rc4-mm2-broken/arch/ia64/mm/numa.c	2005-05-23 17:28:56.000000000 -0400
@@ -45,5 +45,30 @@ paddr_to_nid(unsigned long paddr)
 		    paddr < node_memblk[i].start_paddr + node_memblk[i].size)
 			break;
 
-	return (i < num_node_memblks) ? node_memblk[i].nid : (num_node_memblks ? -1 : 0);
+	return (i < num_node_memblks) ?
+		node_memblk[i].nid : (num_node_memblks ? -1 : 0);
 }
+
+#if defined(CONFIG_SPARSEMEM) && defined(CONFIG_NUMA)
+/*
+ * Because of holes evaluate on section limits.
+ * If the section of memory exists, then return the node where the section
+ * resides.  Otherwise return node 0 as the default.  This is used by
+ * SPARSEMEM to allocate the SPARSEMEM sectionmap on the NUMA node where
+ * the section resides.
+ */
+int early_pfn_to_nid(unsigned long pfn)
+{
+	int i, section = pfn >> PFN_SECTION_SHIFT, ssec, esec;
+
+	for (i = 0; i < num_node_memblks; i++) {
+		ssec = node_memblk[i].start_paddr >> PA_SECTION_SHIFT;
+		esec = (node_memblk[i].start_paddr + node_memblk[i].size +
+			((1L << PA_SECTION_SHIFT) - 1)) >> PA_SECTION_SHIFT;
+		if (section >= ssec && section < esec)
+			return node_memblk[i].nid;
+	}
+
+	return 0;
+}
+#endif
