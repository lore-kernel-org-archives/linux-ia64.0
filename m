From: Robin Holt <holt@sgi.com>
Date: Thu, 13 Apr 2006 03:15:19 +0000
Subject: Make show_mem() skip holes in a pgdat.
Message-Id: <20060413031519.GB2678@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This patch modifies ia64's show_mem() to walk the vmem_map page tables and
rapidly skip forward across regions where the page tables are missing.
This prevents the pfn_valid() check from causing numerous unnecessary
page faults.

Without this patch on a 512 node 512 cpu system where every node has four
memory holes, the show_mem() call takes 1 hour 18 minutes.  With this
patch, it takes less than 3 seconds.

Signed-off-by: Robin Holt <holt@sgi.com>


Index: linux-2.6/arch/ia64/mm/discontig.c
=================================--- linux-2.6.orig/arch/ia64/mm/discontig.c	2006-04-12 18:20:44.374700839 -0500
+++ linux-2.6/arch/ia64/mm/discontig.c	2006-04-12 22:11:31.971106982 -0500
@@ -547,8 +547,71 @@ void show_mem(void)
 			struct page *page;
 			if (pfn_valid(pgdat->node_start_pfn + i))
 				page = pfn_to_page(pgdat->node_start_pfn + i);
-			else
+			else {
+				/*
+				 * At the beginning of a hole. Search vmem_map
+				 * page tables for the end.
+				 */
+				unsigned long end_address, hole_end_pfn;
+				unsigned long stop_address;
+
+				end_address = (unsigned long) &vmem_map[pgdat->node_start_pfn + i];
+				end_address = PAGE_ALIGN(end_address);
+
+				stop_address = (unsigned long) &vmem_map[
+					pgdat->node_start_pfn + pgdat->node_spanned_pages];
+
+				do {
+					pgd_t *pgd;
+					pud_t *pud;
+					pmd_t *pmd;
+					pte_t *pte;
+
+					pgd = pgd_offset_k(end_address);
+					if (pgd_none(*pgd)) {
+						end_address += PTRS_PER_PUD *
+							       PTRS_PER_PMD *
+							       PTRS_PER_PTE *
+							       PAGE_SIZE;
+						continue;
+					}
+
+					pud = pud_offset(pgd, end_address);
+					if (pud_none(*pud)) {
+						end_address += PTRS_PER_PMD *
+							       PTRS_PER_PTE *
+							       PAGE_SIZE;
+						continue;
+					}
+
+					pmd = pmd_offset(pud, end_address);
+					if (pmd_none(*pmd)) {
+						end_address += PTRS_PER_PTE *
+							       PAGE_SIZE;
+						continue;
+					}
+
+					pte = pte_offset_kernel(pmd, end_address);
+
+retry_pte:
+					if (pte_none(*pte)) {
+						end_address += PAGE_SIZE;
+						pte++;
+						if ((end_address < stop_address) &&
+						    (end_address != ALIGN(end_address, 1UL << PMD_SHIFT)))
+							goto retry_pte;
+						continue;
+					}
+					/* Found next valid vmem_map page */
+					break;
+				} while (end_address < stop_address);
+
+				end_address = end_address - (unsigned long) vmem_map - 1;
+				hole_end_pfn = end_address / sizeof(struct page);
+				i = hole_end_pfn - pgdat->node_start_pfn;
+
 				continue;
+			}
 			if (PageReserved(page))
 				reserved++;
 			else if (PageSwapCache(page))
