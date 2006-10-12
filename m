From: Christoph Lameter <clameter@sgi.com>
Date: Thu, 12 Oct 2006 19:18:23 +0000
Subject: [PATCH 3/4] vmm: Use proper macros
Message-Id: <20061012191823.21498.52344.sendpatchset@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

IA64: Use proper macros for vmem_map calculations

There are some expressions in init.c that manually do what pfn_to_page
and virt_to_page do.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.18-mm3/arch/ia64/mm/init.c
=================================--- linux-2.6.18-mm3.orig/arch/ia64/mm/init.c	2006-10-06 18:21:12.881827880 -0700
+++ linux-2.6.18-mm3/arch/ia64/mm/init.c	2006-10-06 18:30:37.376338346 -0700
@@ -421,11 +421,11 @@ int vmemmap_find_next_valid_pfn(int node
 	unsigned long stop_address;
 	pg_data_t *pgdat = NODE_DATA(node);
 
-	end_address = (unsigned long) &vmem_map[pgdat->node_start_pfn + i];
+	end_address = (unsigned long)pfn_to_page(pgdat->node_start_pfn + i);
 	end_address = PAGE_ALIGN(end_address);
 
-	stop_address = (unsigned long) &vmem_map[
-		pgdat->node_start_pfn + pgdat->node_spanned_pages];
+	stop_address = (unsigned long)pfn_to_page(pgdat->node_start_pfn +
+			pgdat->node_spanned_pages);
 
 	do {
 		pgd_t *pgd;
@@ -482,8 +482,8 @@ create_mem_map_page_table (u64 start, u6
 	pmd_t *pmd;
 	pte_t *pte;
 
-	map_start = vmem_map + (__pa(start) >> PAGE_SHIFT);
-	map_end   = vmem_map + (__pa(end) >> PAGE_SHIFT);
+	map_start = virt_to_page(start);
+	map_end   = virt_to_page(end);
 
 	start_page = (unsigned long) map_start & PAGE_MASK;
 	end_page = PAGE_ALIGN((unsigned long) map_end);
@@ -524,8 +524,8 @@ virtual_memmap_init (u64 start, u64 end,
 	struct page *map_start, *map_end;
 
 	args = (struct memmap_init_callback_data *) arg;
-	map_start = vmem_map + (__pa(start) >> PAGE_SHIFT);
-	map_end   = vmem_map + (__pa(end) >> PAGE_SHIFT);
+	map_start = virt_to_page(start);
+	map_end   = virt_to_page(end);
 
 	if (map_start < args->start)
 		map_start = args->start;
