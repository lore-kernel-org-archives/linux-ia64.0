From: jbarnes@sgi.com (Jesse Barnes)
Date: Mon, 06 Oct 2003 21:34:23 +0000
Subject: [PATCH] split contig and discontig paging_init functions
Message-Id: <marc-linux-ia64-106547645502436@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Split up the contig and discontig versions of paging_init() into the
appropriate files.

 arch/ia64/mm/contig.c      |   95 +++++++++++++++++++++++++++++++++++++++
 arch/ia64/mm/discontig.c   |    6 +-
 arch/ia64/mm/init.c        |  108 +--------------------------------------------
 include/asm-ia64/meminit.h |   11 ++++

Thanks,
Jesse

diff -Nru a/arch/ia64/mm/contig.c b/arch/ia64/mm/contig.c
--- a/arch/ia64/mm/contig.c	Mon Oct  6 14:32:38 2003
+++ b/arch/ia64/mm/contig.c	Mon Oct  6 14:32:38 2003
@@ -25,6 +25,10 @@
 #include <asm/pgtable.h>
 #include <asm/sections.h>
 
+#ifdef CONFIG_VIRTUAL_MEM_MAP
+static unsigned long num_dma_physpages;
+#endif
+
 /**
  * show_mem - display a memory statistics summary
  *
@@ -160,4 +164,95 @@
 	reserve_bootmem(bootmap_start, bootmap_size);
 
 	find_initrd();
+}
+
+#ifdef CONFIG_VIRTUAL_MEM_MAP
+static int
+count_dma_pages (u64 start, u64 end, void *arg)
+{
+	unsigned long *count = arg;
+
+	if (end <= MAX_DMA_ADDRESS)
+		*count += (end - start) >> PAGE_SHIFT;
+	return 0;
+}
+#endif
+
+/*
+ * Set up the page tables.
+ */
+
+void
+paging_init (void)
+{
+	unsigned long max_dma;
+	unsigned long zones_size[MAX_NR_ZONES];
+#ifdef CONFIG_VIRTUAL_MEM_MAP
+	unsigned long zholes_size[MAX_NR_ZONES];
+	unsigned long max_gap;
+#endif
+
+	/* initialize mem_map[] */
+
+	memset(zones_size, 0, sizeof(zones_size));
+
+	num_physpages = 0;
+	efi_memmap_walk(count_pages, &num_physpages);
+
+	max_dma = virt_to_phys((void *) MAX_DMA_ADDRESS) >> PAGE_SHIFT;
+
+#ifdef CONFIG_VIRTUAL_MEM_MAP
+	memset(zholes_size, 0, sizeof(zholes_size));
+
+	num_dma_physpages = 0;
+	efi_memmap_walk(count_dma_pages, &num_dma_physpages);
+
+	if (max_low_pfn < max_dma) {
+		zones_size[ZONE_DMA] = max_low_pfn;
+		zholes_size[ZONE_DMA] = max_low_pfn - num_dma_physpages;
+	} else {
+		zones_size[ZONE_DMA] = max_dma;
+		zholes_size[ZONE_DMA] = max_dma - num_dma_physpages;
+		if (num_physpages > num_dma_physpages) {
+			zones_size[ZONE_NORMAL] = max_low_pfn - max_dma;
+			zholes_size[ZONE_NORMAL] +				((max_low_pfn - max_dma) -
+				 (num_physpages - num_dma_physpages));
+		}
+	}
+
+	max_gap = 0;
+	efi_memmap_walk(find_largest_hole, (u64 *)&max_gap);
+	if (max_gap < LARGE_GAP) {
+		vmem_map = (struct page *) 0;
+		free_area_init_node(0, &contig_page_data, NULL, zones_size, 0,
+				    zholes_size);
+		mem_map = contig_page_data.node_mem_map;
+	}
+	else {
+		unsigned long map_size;
+
+		/* allocate virtual_mem_map */
+
+		map_size = PAGE_ALIGN(max_low_pfn * sizeof(struct page));
+		vmalloc_end -= map_size;
+		vmem_map = (struct page *) vmalloc_end;
+		efi_memmap_walk(create_mem_map_page_table, 0);
+
+		free_area_init_node(0, &contig_page_data, vmem_map, zones_size,
+				    0, zholes_size);
+
+		mem_map = contig_page_data.node_mem_map;
+		printk("Virtual mem_map starts at 0x%p\n", mem_map);
+	}
+#else /* !CONFIG_VIRTUAL_MEM_MAP */
+	if (max_low_pfn < max_dma)
+		zones_size[ZONE_DMA] = max_low_pfn;
+	else {
+		zones_size[ZONE_DMA] = max_dma;
+		zones_size[ZONE_NORMAL] = max_low_pfn - max_dma;
+	}
+	free_area_init(zones_size);
+#endif /* !CONFIG_VIRTUAL_MEM_MAP */
+	zero_page_memmap_ptr = virt_to_page(ia64_imva(empty_zero_page));
 }
diff -Nru a/arch/ia64/mm/discontig.c b/arch/ia64/mm/discontig.c
--- a/arch/ia64/mm/discontig.c	Mon Oct  6 14:32:38 2003
+++ b/arch/ia64/mm/discontig.c	Mon Oct  6 14:32:38 2003
@@ -248,8 +248,7 @@
  *	- replicate the nodedir structure to other nodes
  */
 
-void __init
-discontig_paging_init(void)
+void __init paging_init(void)
 {
 	int		node, mynode;
 	unsigned long	max_dma, zones_size[MAX_NR_ZONES];
@@ -306,6 +305,9 @@
 			memcpy(node_data[node], node_data[mynode], sizeof(struct ia64_node_data));
 			node_data[node]->node = node;
 		}
+
+	efi_memmap_walk(count_pages, &num_physpages);
+	zero_page_memmap_ptr = virt_to_page(ia64_imva(empty_zero_page));
 }
 
 void show_mem(void)
diff -Nru a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
--- a/arch/ia64/mm/init.c	Mon Oct  6 14:32:38 2003
+++ b/arch/ia64/mm/init.c	Mon Oct  6 14:32:38 2003
@@ -40,10 +40,8 @@
 unsigned long MAX_DMA_ADDRESS = PAGE_OFFSET + 0x100000000UL;
 
 #ifdef CONFIG_VIRTUAL_MEM_MAP
-# define LARGE_GAP	0x40000000	/* Use virtual mem map if hole is > than this */
   unsigned long vmalloc_end = VMALLOC_END_INIT;
-  static struct page *vmem_map;
-  static unsigned long num_dma_physpages;
+  struct page *vmem_map;
 #endif
 
 static int pgt_cache_water[2] = { 25, 50 };
@@ -337,7 +335,7 @@
 
 #ifdef CONFIG_VIRTUAL_MEM_MAP
 
-static int
+int
 create_mem_map_page_table (u64 start, u64 end, void *arg)
 {
 	unsigned long address, start_page, end_page;
@@ -433,17 +431,7 @@
 	return __get_user(byte, (char *) pfn_to_page(pfn)) = 0;
 }
 
-static int
-count_dma_pages (u64 start, u64 end, void *arg)
-{
-	unsigned long *count = arg;
-
-	if (end <= MAX_DMA_ADDRESS)
-		*count += (end - start) >> PAGE_SHIFT;
-	return 0;
-}
-
-static int
+int
 find_largest_hole (u64 start, u64 end, void *arg)
 {
 	u64 *max_gap = arg;
@@ -459,7 +447,7 @@
 }
 #endif /* CONFIG_VIRTUAL_MEM_MAP */
 
-static int
+int
 count_pages (u64 start, u64 end, void *arg)
 {
 	unsigned long *count = arg;
@@ -467,94 +455,6 @@
 	*count += (end - start) >> PAGE_SHIFT;
 	return 0;
 }
-
-/*
- * Set up the page tables.
- */
-
-#ifdef CONFIG_DISCONTIGMEM
-void
-paging_init (void)
-{
-	extern void discontig_paging_init(void);
-
-	discontig_paging_init();
-	efi_memmap_walk(count_pages, &num_physpages);
-	zero_page_memmap_ptr = virt_to_page(ia64_imva(empty_zero_page));
-}
-#else /* !CONFIG_DISCONTIGMEM */
-void
-paging_init (void)
-{
-	unsigned long max_dma;
-	unsigned long zones_size[MAX_NR_ZONES];
-#  ifdef CONFIG_VIRTUAL_MEM_MAP
-	unsigned long zholes_size[MAX_NR_ZONES];
-	unsigned long max_gap;
-#  endif
-
-	/* initialize mem_map[] */
-
-	memset(zones_size, 0, sizeof(zones_size));
-
-	num_physpages = 0;
-	efi_memmap_walk(count_pages, &num_physpages);
-
-	max_dma = virt_to_phys((void *) MAX_DMA_ADDRESS) >> PAGE_SHIFT;
-
-#  ifdef CONFIG_VIRTUAL_MEM_MAP
-	memset(zholes_size, 0, sizeof(zholes_size));
-
-	num_dma_physpages = 0;
-	efi_memmap_walk(count_dma_pages, &num_dma_physpages);
-
-	if (max_low_pfn < max_dma) {
-		zones_size[ZONE_DMA] = max_low_pfn;
-		zholes_size[ZONE_DMA] = max_low_pfn - num_dma_physpages;
-	} else {
-		zones_size[ZONE_DMA] = max_dma;
-		zholes_size[ZONE_DMA] = max_dma - num_dma_physpages;
-		if (num_physpages > num_dma_physpages) {
-			zones_size[ZONE_NORMAL] = max_low_pfn - max_dma;
-			zholes_size[ZONE_NORMAL] = ((max_low_pfn - max_dma)
-						    - (num_physpages - num_dma_physpages));
-		}
-	}
-
-	max_gap = 0;
-	efi_memmap_walk(find_largest_hole, (u64 *)&max_gap);
-	if (max_gap < LARGE_GAP) {
-		vmem_map = (struct page *) 0;
-		free_area_init_node(0, &contig_page_data, NULL, zones_size, 0, zholes_size);
-		mem_map = contig_page_data.node_mem_map;
-	}
-	else {
-		unsigned long map_size;
-
-		/* allocate virtual_mem_map */
-
-		map_size = PAGE_ALIGN(max_low_pfn * sizeof(struct page));
-		vmalloc_end -= map_size;
-		vmem_map = (struct page *) vmalloc_end;
-		efi_memmap_walk(create_mem_map_page_table, 0);
-
-		free_area_init_node(0, &contig_page_data, vmem_map, zones_size, 0, zholes_size);
-
-		mem_map = contig_page_data.node_mem_map;
-		printk("Virtual mem_map starts at 0x%p\n", mem_map);
-	}
-#  else /* !CONFIG_VIRTUAL_MEM_MAP */
-	if (max_low_pfn < max_dma)
-		zones_size[ZONE_DMA] = max_low_pfn;
-	else {
-		zones_size[ZONE_DMA] = max_dma;
-		zones_size[ZONE_NORMAL] = max_low_pfn - max_dma;
-	}
-	free_area_init(zones_size);
-#  endif /* !CONFIG_VIRTUAL_MEM_MAP */
-	zero_page_memmap_ptr = virt_to_page(ia64_imva(empty_zero_page));
-}
-#endif /* !CONFIG_DISCONTIGMEM */
 
 static int
 count_reserved_pages (u64 start, u64 end, void *arg)
diff -Nru a/include/asm-ia64/meminit.h b/include/asm-ia64/meminit.h
--- a/include/asm-ia64/meminit.h	Mon Oct  6 14:32:38 2003
+++ b/include/asm-ia64/meminit.h	Mon Oct  6 14:32:38 2003
@@ -7,6 +7,9 @@
  * for more details.
  */
 
+#include <linux/config.h>
+#include <linux/mm.h>
+
 /*
  * Entries defined so far:
  * 	- boot param structure itself
@@ -31,11 +34,19 @@
 extern void reserve_memory (void);
 extern void find_initrd (void);
 extern int filter_rsvd_memory (unsigned long start, unsigned long end, void *arg);
+extern int count_pages (u64 start, u64 end, void *arg);
 
 #ifdef CONFIG_DISCONTIGMEM
 extern void call_pernode_memory (unsigned long start, unsigned long end, void *arg);
 #endif
 
 #define IGNORE_PFN0	1	/* XXX fix me: ignore pfn 0 until TLB miss handler is updated... */
+
+#ifdef CONFIG_VIRTUAL_MEM_MAP
+#define LARGE_GAP 0x40000000 /* Use virtual mem map if hole is > than this */
+extern struct page *vmem_map;
+extern int find_largest_hole (u64 start, u64 end, void *arg);
+extern int create_mem_map_page_table (u64 start, u64 end, void *arg);
+#endif
 
 #endif /* meminit_h */
