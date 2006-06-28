From: "Bob Picco" <bob.picco@hp.com>
Date: Wed, 28 Jun 2006 16:55:43 +0000
Subject: [PATCH] fix show_mem for VIRTUAL_MEM_MAP+FLATMEM
Message-Id: <20060628165543.GB31441@localhost>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Tony,

contig.c (FLATMEM) requires the same optimization as in discontig.c for show_mem
when VIRTUAL_MEM_MAP is in use. Otherwise FLATMEM has softlockup timeouts.
This was boot tested for memory configuration: SPARSEMEM, 
DISCONTIG+VIRTUAL_MEM_MAP, FLATMEM, FLATMEM+VIRTUAL_MEM_MAP and 
FLATMEM+VIRTUAL_MEM_MAP with largest memory gap less than LARGE_GAP by
using boot parameter "mem=".

This was boot tested and "echo m >/proc/sysrq-trigger" output evaluated for
: FLATMEM, FLATMEM+VIRTUAL_MEM_MAP, DISCONTIGMEM+VIRTUAL_MEM_MAP and
SPARSEMEM.

bob

Signed-off-by: Bob Picco <bob.picco@hp.com>

 arch/ia64/mm/contig.c      |   12 ++++++--
 arch/ia64/mm/discontig.c   |   65 +--------------------------------------------
 arch/ia64/mm/init.c        |   55 ++++++++++++++++++++++++++++++++++++++
 include/asm-ia64/meminit.h |    7 ++++
 4 files changed, 72 insertions(+), 67 deletions(-)

Index: linux-2.6.17/arch/ia64/mm/contig.c
=================================--- linux-2.6.17.orig/arch/ia64/mm/contig.c	2006-06-18 14:31:13.000000000 -0400
+++ linux-2.6.17/arch/ia64/mm/contig.c	2006-06-20 14:30:40.000000000 -0400
@@ -28,6 +28,7 @@
 
 #ifdef CONFIG_VIRTUAL_MEM_MAP
 static unsigned long num_dma_physpages;
+static unsigned long max_gap;
 #endif
 
 /**
@@ -46,9 +47,15 @@ show_mem (void)
 
 	printk("Free swap:       %6ldkB\n", nr_swap_pages<<(PAGE_SHIFT-10));
 	i = max_mapnr;
-	while (i-- > 0) {
-		if (!pfn_valid(i))
+	for (i = 0; i < max_mapnr; i++) {
+		if (!pfn_valid(i)) {
+#ifdef CONFIG_VIRTUAL_MEM_MAP
+			if (max_gap < LARGE_GAP)
+				continue;
+			i = vmemmap_find_next_valid_pfn(0, i) - 1;
+#endif
 			continue;
+		}
 		total++;
 		if (PageReserved(mem_map+i))
 			reserved++;
@@ -235,7 +242,6 @@ paging_init (void)
 	unsigned long zones_size[MAX_NR_ZONES];
 #ifdef CONFIG_VIRTUAL_MEM_MAP
 	unsigned long zholes_size[MAX_NR_ZONES];
-	unsigned long max_gap;
 #endif
 
 	/* initialize mem_map[] */
@@ -267,7 +273,6 @@ paging_init (void)
 		}
 	}
 
-	max_gap = 0;
 	efi_memmap_walk(find_largest_hole, (u64 *)&max_gap);
 	if (max_gap < LARGE_GAP) {
 		vmem_map = (struct page *) 0;
Index: linux-2.6.17/arch/ia64/mm/discontig.c
=================================--- linux-2.6.17.orig/arch/ia64/mm/discontig.c	2006-06-18 14:31:13.000000000 -0400
+++ linux-2.6.17/arch/ia64/mm/discontig.c	2006-06-20 14:30:40.000000000 -0400
@@ -519,68 +519,6 @@ void __cpuinit *per_cpu_init(void)
 }
 #endif /* CONFIG_SMP */
 
-#ifdef CONFIG_VIRTUAL_MEM_MAP
-static inline int find_next_valid_pfn_for_pgdat(pg_data_t *pgdat, int i)
-{
-	unsigned long end_address, hole_next_pfn;
-	unsigned long stop_address;
-
-	end_address = (unsigned long) &vmem_map[pgdat->node_start_pfn + i];
-	end_address = PAGE_ALIGN(end_address);
-
-	stop_address = (unsigned long) &vmem_map[
-		pgdat->node_start_pfn + pgdat->node_spanned_pages];
-
-	do {
-		pgd_t *pgd;
-		pud_t *pud;
-		pmd_t *pmd;
-		pte_t *pte;
-
-		pgd = pgd_offset_k(end_address);
-		if (pgd_none(*pgd)) {
-			end_address += PGDIR_SIZE;
-			continue;
-		}
-
-		pud = pud_offset(pgd, end_address);
-		if (pud_none(*pud)) {
-			end_address += PUD_SIZE;
-			continue;
-		}
-
-		pmd = pmd_offset(pud, end_address);
-		if (pmd_none(*pmd)) {
-			end_address += PMD_SIZE;
-			continue;
-		}
-
-		pte = pte_offset_kernel(pmd, end_address);
-retry_pte:
-		if (pte_none(*pte)) {
-			end_address += PAGE_SIZE;
-			pte++;
-			if ((end_address < stop_address) &&
-			    (end_address != ALIGN(end_address, 1UL << PMD_SHIFT)))
-				goto retry_pte;
-			continue;
-		}
-		/* Found next valid vmem_map page */
-		break;
-	} while (end_address < stop_address);
-
-	end_address = min(end_address, stop_address);
-	end_address = end_address - (unsigned long) vmem_map + sizeof(struct page) - 1;
-	hole_next_pfn = end_address / sizeof(struct page);
-	return hole_next_pfn - pgdat->node_start_pfn;
-}
-#else
-static inline int find_next_valid_pfn_for_pgdat(pg_data_t *pgdat, int i)
-{
-	return i + 1;
-}
-#endif
-
 /**
  * show_mem - give short summary of memory stats
  *
@@ -610,7 +548,8 @@ void show_mem(void)
 			if (pfn_valid(pgdat->node_start_pfn + i))
 				page = pfn_to_page(pgdat->node_start_pfn + i);
 			else {
-				i = find_next_valid_pfn_for_pgdat(pgdat, i) - 1;
+				i = vmemmap_find_next_valid_pfn(pgdat->node_id,
+					 i) - 1;
 				continue;
 			}
 			if (PageReserved(page))
Index: linux-2.6.17/arch/ia64/mm/init.c
=================================--- linux-2.6.17.orig/arch/ia64/mm/init.c	2006-06-18 14:31:13.000000000 -0400
+++ linux-2.6.17/arch/ia64/mm/init.c	2006-06-19 19:20:11.000000000 -0400
@@ -416,6 +416,61 @@ ia64_mmu_init (void *my_cpu_data)
 }
 
 #ifdef CONFIG_VIRTUAL_MEM_MAP
+int vmemmap_find_next_valid_pfn(int node, int i)
+{
+	unsigned long end_address, hole_next_pfn;
+	unsigned long stop_address;
+	pg_data_t *pgdat = NODE_DATA(node);
+
+	end_address = (unsigned long) &vmem_map[pgdat->node_start_pfn + i];
+	end_address = PAGE_ALIGN(end_address);
+
+	stop_address = (unsigned long) &vmem_map[
+		pgdat->node_start_pfn + pgdat->node_spanned_pages];
+
+	do {
+		pgd_t *pgd;
+		pud_t *pud;
+		pmd_t *pmd;
+		pte_t *pte;
+
+		pgd = pgd_offset_k(end_address);
+		if (pgd_none(*pgd)) {
+			end_address += PGDIR_SIZE;
+			continue;
+		}
+
+		pud = pud_offset(pgd, end_address);
+		if (pud_none(*pud)) {
+			end_address += PUD_SIZE;
+			continue;
+		}
+
+		pmd = pmd_offset(pud, end_address);
+		if (pmd_none(*pmd)) {
+			end_address += PMD_SIZE;
+			continue;
+		}
+
+		pte = pte_offset_kernel(pmd, end_address);
+retry_pte:
+		if (pte_none(*pte)) {
+			end_address += PAGE_SIZE;
+			pte++;
+			if ((end_address < stop_address) &&
+			    (end_address != ALIGN(end_address, 1UL << PMD_SHIFT)))
+				goto retry_pte;
+			continue;
+		}
+		/* Found next valid vmem_map page */
+		break;
+	} while (end_address < stop_address);
+
+	end_address = min(end_address, stop_address);
+	end_address = end_address - (unsigned long) vmem_map + sizeof(struct page) - 1;
+	hole_next_pfn = end_address / sizeof(struct page);
+	return hole_next_pfn - pgdat->node_start_pfn;
+}
 
 int __init
 create_mem_map_page_table (u64 start, u64 end, void *arg)
Index: linux-2.6.17/include/asm-ia64/meminit.h
=================================--- linux-2.6.17.orig/include/asm-ia64/meminit.h	2006-01-02 22:21:10.000000000 -0500
+++ linux-2.6.17/include/asm-ia64/meminit.h	2006-06-19 19:20:11.000000000 -0400
@@ -57,6 +57,11 @@ extern void efi_memmap_init(unsigned lon
   extern struct page *vmem_map;
   extern int find_largest_hole (u64 start, u64 end, void *arg);
   extern int create_mem_map_page_table (u64 start, u64 end, void *arg);
+  extern int vmemmap_find_next_valid_pfn(int, int);
+#else
+static inline int vmemmap_find_next_valid_pfn(int node, int i)
+{
+	return i + 1;
+}
 #endif
-
 #endif /* meminit_h */
