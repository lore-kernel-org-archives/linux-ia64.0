From: Baolin Wang <baolin.wang@linux.alibaba.com>
Date: Fri, 29 Apr 2022 08:14:43 +0000
Subject: [PATCH 3/3] mm: rmap: Fix CONT-PTE/PMD size hugetlb issue when unmapping
Message-Id: <c91e04ebb792ef7b72966edea8bd6fa2dfa5bfa7.1651216964.git.baolin.wang@linux.alibaba.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1651216964.git.baolin.wang@linux.alibaba.com>
In-Reply-To: <cover.1651216964.git.baolin.wang@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: akpm@linux-foundation.org, mike.kravetz@oracle.com, catalin.marinas@arm.com, will@kernel.org
Cc: tsbogend@alpha.franken.de, James.Bottomley@HansenPartnership.com, deller@gmx.de, mpe@ellerman.id.au, benh@kernel.crashing.org, paulus@samba.org, hca@linux.ibm.com, gor@linux.ibm.com, agordeev@linux.ibm.com, borntraeger@linux.ibm.com, svens@linux.ibm.com, ysato@users.sourceforge.jp, dalias@libc.org, davem@davemloft.net, arnd@arndb.de, baolin.wang@linux.alibaba.com, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org

On some architectures (like ARM64), it can support CONT-PTE/PMD size
hugetlb, which means it can support not only PMD/PUD size hugetlb:
2M and 1G, but also CONT-PTE/PMD size: 64K and 32M if a 4K page
size specified.

When unmapping a hugetlb page, we will get the relevant page table
entry by huge_pte_offset() only once to nuke it. This is correct
for PMD or PUD size hugetlb, since they always contain only one
pmd entry or pud entry in the page table.

However this is incorrect for CONT-PTE and CONT-PMD size hugetlb,
since they can contain several continuous pte or pmd entry with
same page table attributes, so we will nuke only one pte or pmd
entry for this CONT-PTE/PMD size hugetlb page.

And now we only use try_to_unmap() to unmap a poisoned hugetlb page,
which means now we will unmap only one pte entry for a CONT-PTE or
CONT-PMD size poisoned hugetlb page, and we can still access other
subpages of a CONT-PTE or CONT-PMD size poisoned hugetlb page,
which will cause serious issues possibly.

So we should change to use huge_ptep_clear_flush() to nuke the
hugetlb page table to fix this issue, which already considered
CONT-PTE and CONT-PMD size hugetlb.

Note we've already used set_huge_swap_pte_at() to set a poisoned
swap entry for a poisoned hugetlb page.

Signed-off-by: Baolin Wang <baolin.wang@linux.alibaba.com>
---
 mm/rmap.c | 34 +++++++++++++++++-----------------
 1 file changed, 17 insertions(+), 17 deletions(-)

diff --git a/mm/rmap.c b/mm/rmap.c
index 7cf2408..1e168d7 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1564,28 +1564,28 @@ static bool try_to_unmap_one(struct folio *folio, struct vm_area_struct *vma,
 					break;
 				}
 			}
+			pteval = huge_ptep_clear_flush(vma, address, pvmw.pte);
 		} else {
 			flush_cache_page(vma, address, pte_pfn(*pvmw.pte));
-		}
-
-		/*
-		 * Nuke the page table entry. When having to clear
-		 * PageAnonExclusive(), we always have to flush.
-		 */
-		if (should_defer_flush(mm, flags) && !anon_exclusive) {
 			/*
-			 * We clear the PTE but do not flush so potentially
-			 * a remote CPU could still be writing to the folio.
-			 * If the entry was previously clean then the
-			 * architecture must guarantee that a clear->dirty
-			 * transition on a cached TLB entry is written through
-			 * and traps if the PTE is unmapped.
+			 * Nuke the page table entry. When having to clear
+			 * PageAnonExclusive(), we always have to flush.
 			 */
-			pteval = ptep_get_and_clear(mm, address, pvmw.pte);
+			if (should_defer_flush(mm, flags) && !anon_exclusive) {
+				/*
+				 * We clear the PTE but do not flush so potentially
+				 * a remote CPU could still be writing to the folio.
+				 * If the entry was previously clean then the
+				 * architecture must guarantee that a clear->dirty
+				 * transition on a cached TLB entry is written through
+				 * and traps if the PTE is unmapped.
+				 */
+				pteval = ptep_get_and_clear(mm, address, pvmw.pte);
 
-			set_tlb_ubc_flush_pending(mm, pte_dirty(pteval));
-		} else {
-			pteval = ptep_clear_flush(vma, address, pvmw.pte);
+				set_tlb_ubc_flush_pending(mm, pte_dirty(pteval));
+			} else {
+				pteval = ptep_clear_flush(vma, address, pvmw.pte);
+			}
 		}
 
 		/*
-- 
1.8.3.1
