From: Bob Picco <bob.picco@hp.com>
Date: Tue, 04 Oct 2005 19:13:57 +0000
Subject: [PATCH 4/5] V5 ia64 SPARSEMEM - SPARSEMEM code changes
Message-Id: <20051004191357.GT25483@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This patch is the minimal set of changes required by ia64 to use SPARSEMEM.

Signed-off-by: Bob Picco <bob.picco@hp.com>

 arch/ia64/mm/discontig.c |   43 +++++++++++++++++++++++++++++++++++++++++--
 arch/ia64/mm/init.c      |    2 +-
 arch/ia64/mm/numa.c      |   24 ++++++++++++++++++++++++
 3 files changed, 66 insertions(+), 3 deletions(-)

Index: linux-2.6.14-rc2/arch/ia64/mm/discontig.c
=================================--- linux-2.6.14-rc2.orig/arch/ia64/mm/discontig.c	2005-10-03 19:57:14.000000000 -0400
+++ linux-2.6.14-rc2/arch/ia64/mm/discontig.c	2005-10-03 19:57:29.000000000 -0400
@@ -421,6 +421,37 @@ static void __init memory_less_nodes(voi
 	return;
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
+
+static void __init arch_sparse_init(void)
+{
+	efi_memmap_walk(register_sparse_mem, NULL);
+	sparse_init();
+}
+#else
+#define arch_sparse_init() do {} while (0)
+#endif
+
 /**
  * find_memory - walk the EFI memory map and setup the bootmem allocator
  *
@@ -528,8 +559,10 @@ void show_mem(void)
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
@@ -648,12 +681,16 @@ void __init paging_init(void)
 
 	max_dma = virt_to_phys((void *) MAX_DMA_ADDRESS) >> PAGE_SHIFT;
 
+	arch_sparse_init();
+
 	efi_memmap_walk(filter_rsvd_memory, count_node_pages);
 
+#ifdef CONFIG_VIRTUAL_MEM_MAP
 	vmalloc_end -= PAGE_ALIGN(max_low_pfn * sizeof(struct page));
 	vmem_map = (struct page *) vmalloc_end;
 	efi_memmap_walk(create_mem_map_page_table, NULL);
 	printk("Virtual mem_map starts at 0x%p\n", vmem_map);
+#endif
 
 	for_each_online_node(node) {
 		memset(zones_size, 0, sizeof(zones_size));
@@ -690,7 +727,9 @@ void __init paging_init(void)
 
 		pfn_offset = mem_data[node].min_pfn;
 
+#ifdef CONFIG_VIRTUAL_MEM_MAP
 		NODE_DATA(node)->node_mem_map = vmem_map + pfn_offset;
+#endif
 		free_area_init_node(node, NODE_DATA(node), zones_size,
 				    pfn_offset, zholes_size);
 	}
Index: linux-2.6.14-rc2/arch/ia64/mm/init.c
=================================--- linux-2.6.14-rc2.orig/arch/ia64/mm/init.c	2005-10-03 19:57:14.000000000 -0400
+++ linux-2.6.14-rc2/arch/ia64/mm/init.c	2005-10-03 19:57:29.000000000 -0400
@@ -593,7 +593,7 @@ mem_init (void)
 	platform_dma_init();
 #endif
 
-#ifndef CONFIG_DISCONTIGMEM
+#ifdef CONFIG_FLATMEM
 	if (!mem_map)
 		BUG();
 	max_mapnr = max_low_pfn;
Index: linux-2.6.14-rc2/arch/ia64/mm/numa.c
=================================--- linux-2.6.14-rc2.orig/arch/ia64/mm/numa.c	2005-10-03 19:57:14.000000000 -0400
+++ linux-2.6.14-rc2/arch/ia64/mm/numa.c	2005-10-03 19:57:29.000000000 -0400
@@ -47,3 +47,27 @@ paddr_to_nid(unsigned long paddr)
 
 	return (i < num_node_memblks) ? node_memblk[i].nid : (num_node_memblks ? -1 : 0);
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
