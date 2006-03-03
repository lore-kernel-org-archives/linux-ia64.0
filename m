From: "'David Gibson'" <david@gibson.dropbear.id.au>
Date: Fri, 03 Mar 2006 01:04:08 +0000
Subject: hugepage: Fix hugepage logic in free_pgtables() harder
Message-Id: <20060303010408.GG23766@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060302045201.GA6627@localhost.localdomain>
In-Reply-To: <20060302045201.GA6627@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@osdl.org>
Cc: Hugh Dickins <hugh@veritas.com>, "Chen, Kenneth W" <kenneth.w.chen@intel.com>, William Irwin <wli@holomorphy.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Sigh.  Turns out the hugepage logic in free_pgtables() was doubly
broken.  The loop coalescing multiple normal page VMAs into one call
to free_pgd_range() had an off by one error, which could mean it would
coalesce one hugepage VMA into the same bundle (checking 'vma' not
'next' in the loop).  I transferred this bug into the new
is_vm_hugetlb_page() based version.  Here's the fix.

This one didn't bite on powerpc previously for the same reason the
is_hugepage_only_range() problem didn't: powerpc's
hugetlb_free_pgd_range() is identical to free_pgd_range().  It didn't
bite on ia64 because the hugepage region is distant enough from any
other region that the separated PMD_SIZE distance test would always
prevent coalescing the two together.

No libhugetlbfs testsuite regressions (ppc64, POWER5).

Signed-off-by: David Gibson <dwg@au1.ibm.com>

Index: working-2.6/mm/memory.c
=================================--- working-2.6.orig/mm/memory.c	2006-03-03 11:39:33.000000000 +1100
+++ working-2.6/mm/memory.c	2006-03-03 11:39:50.000000000 +1100
@@ -285,7 +285,7 @@ void free_pgtables(struct mmu_gather **t
 			 * Optimization: gather nearby vmas into one call down
 			 */
 			while (next && next->vm_start <= vma->vm_end + PMD_SIZE
-			       && !is_vm_hugetlb_page(vma)) {
+			       && !is_vm_hugetlb_page(next)) {
 				vma = next;
 				next = vma->vm_next;
 				anon_vma_unlink(vma);


-- 
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/~dgibson
