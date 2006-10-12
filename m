From: Christoph Lameter <clameter@sgi.com>
Date: Thu, 12 Oct 2006 19:18:18 +0000
Subject: [PATCH 2/4] vmm: We do not need node memmap
Message-Id: <20061012191818.21498.50417.sendpatchset@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

vmemmap: No need to use node_mem_map

If we have a virtual memory map then we will not need a per node memory map.
Do not defined node_mem_map if we have a virtual memory map and #ifdef
out the code in alloc_node_mem_map.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.19-rc1-mm1/arch/ia64/mm/discontig.c
=================================--- linux-2.6.19-rc1-mm1.orig/arch/ia64/mm/discontig.c	2006-10-10 14:46:05.000068954 -0500
+++ linux-2.6.19-rc1-mm1/arch/ia64/mm/discontig.c	2006-10-10 21:21:08.412585297 -0500
@@ -705,10 +705,6 @@ void __init paging_init(void)
 	for_each_online_node(node) {
 		num_physpages += mem_data[node].num_physpages;
 		pfn_offset = mem_data[node].min_pfn;
-
-#ifdef CONFIG_VIRTUAL_MEM_MAP
-		NODE_DATA(node)->node_mem_map = vmem_map + pfn_offset;
-#endif
 		if (mem_data[node].max_pfn > max_pfn)
 			max_pfn = mem_data[node].max_pfn;
 	}
Index: linux-2.6.19-rc1-mm1/include/linux/mmzone.h
=================================--- linux-2.6.19-rc1-mm1.orig/include/linux/mmzone.h	2006-10-10 14:46:49.177643291 -0500
+++ linux-2.6.19-rc1-mm1/include/linux/mmzone.h	2006-10-10 21:21:08.488763783 -0500
@@ -359,7 +359,7 @@ typedef struct pglist_data {
 	struct zone node_zones[MAX_NR_ZONES];
 	struct zonelist node_zonelists[MAX_NR_ZONES];
 	int nr_zones;
-#ifdef CONFIG_FLAT_NODE_MEM_MAP
+#if !defined(CONFIG_VIRTUAL_MEM_MAP) || defined(CONFIG_FLAT_NODE_MEM_MAP)
 	struct page *node_mem_map;
 #endif
 	struct bootmem_data *bdata;
Index: linux-2.6.19-rc1-mm1/mm/page_alloc.c
=================================--- linux-2.6.19-rc1-mm1.orig/mm/page_alloc.c	2006-10-10 14:46:51.909320259 -0500
+++ linux-2.6.19-rc1-mm1/mm/page_alloc.c	2006-10-10 21:21:08.575685390 -0500
@@ -2497,13 +2497,13 @@ static void __meminit free_area_init_cor
 
 static void __init alloc_node_mem_map(struct pglist_data *pgdat)
 {
+#ifndef CONFIG_VIRTUAL_MEM_MAP
 	/* Skip empty nodes */
 	if (!pgdat->node_spanned_pages)
 		return;
 
 #ifdef CONFIG_FLAT_NODE_MEM_MAP
-	/* ia64 gets its own node_mem_map, before this, without bootmem */
-	if (!pgdat->node_mem_map) {
+	{
 		unsigned long size, start, end;
 		struct page *map;
 
@@ -2534,6 +2534,7 @@ static void __init alloc_node_mem_map(st
 	}
 #endif
 #endif /* CONFIG_FLAT_NODE_MEM_MAP */
+#endif /* CONFIG_VIRTUAL_MEM_MAP */
 }
 
 void __meminit free_area_init_node(int nid, struct pglist_data *pgdat,
