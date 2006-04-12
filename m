From: Robin Holt <holt@sgi.com>
Date: Wed, 12 Apr 2006 07:18:55 +0000
Subject: Re: show_mem() for ia64 discontig takes a really long time on large systems.
Message-Id: <20060412071854.GA7931@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060328184315.GA8162@lnx-holt.americas.sgi.com>
In-Reply-To: <20060328184315.GA8162@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Mar 30, 2006 at 09:48:18AM -0800, Chen, Kenneth W wrote:
> Jack Steiner wrote on Thursday, March 30, 2006 9:29 AM
> > > Time is wasted trying to fill the TLB entry for the vmem_map.  When it
> > > fails, we show_mem() advances to the next page which repeats the sequence.
> > > Jack had thrown out a couple suggestions.  One was essentially what
> > > you proposed below.  The other was advance i to point the next page
> > > of pfns.  He frowned when saying the second, but I don't recall exactly
> > > why he frowned.
> > 
> > Advancing to the next page will be considerably faster but I wonder if
> > it is fast enough.
> > 
...
> > My gut feeling is that is not good enough. 
> 
> What about the earlier proposal of advancing at pmd and pud granule by
> walking the page table?  There it can walk at 32MB/64GB step.

Does the attached seem like the right direction?  I have tested it on
the simulator and it seems _much_ faster, but that is the simulator.
I have time reserved on the machine where the problem was first observed
later today to test it on actual hardware.

Thanks,
Robin


Index: linux-2.6/arch/ia64/mm/discontig.c
=================================--- linux-2.6.orig/arch/ia64/mm/discontig.c	2006-04-11 16:06:54.243967238 -0500
+++ linux-2.6/arch/ia64/mm/discontig.c	2006-04-12 02:16:46.111406150 -0500
@@ -567,8 +567,68 @@ void show_mem(void)
 			struct page *page;
 			if (pfn_valid(pgdat->node_start_pfn + i))
 				page = pfn_to_page(pgdat->node_start_pfn + i);
-			else
+			else {
+				/* At the beginning of a hole. Search for the end. */
+				unsigned long end_address, next_page_offset;
+				unsigned long stop_address;
+
+				end_address = (unsigned long) &vmem_map[pgdat->node_start_pfn + i];
+				end_address = PAGE_ALIGN(end_address);
+
+				stop_address = (unsigned long) &vmem_map[
+					pgdat->node_start_pfn + pgdat->node_spanned_pages];
+
+				/* walk vmem_map page tables until valid pfn found */
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
+				end_address = end_address - (unsigned long) vmem_map;
+				next_page_offset = ALIGN(end_address, sizeof(struct page));
+				i = next_page_offset / sizeof(struct page) - pgdat->node_start_pfn;
+
 				continue;
+			}
 			if (PageReserved(page))
 				reserved++;
 			else if (PageSwapCache(page))
