From: David Gibson <david@gibson.dropbear.id.au>
Date: Mon, 06 Mar 2006 02:00:05 +0000
Subject: hugepage: Move hugetlb_free_pgd_range() prototype to hugetlb.h
Message-Id: <20060306020005.GB21408@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@osdl.org>
Cc: "Chen, Kenneth W" <kenneth.w.chen@intel.com>, William Lee Irwin <wli@holomorphy.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

The optional hugepage callback, hugetlb_free_pgd_range() is presently
implemented non-trivially only on ia64 (but I plan to add one for
powerpc shortly).  It has its own prototype for the function in
asm-ia64/pgtable.h.  However, since the function is called from
generic code, it make sense for its prototype to be in the generic
hugetlb.h header file, as the protypes other arch callbacks already
are (prepare_hugepage_range(), set_huge_pte_at(), etc.).  This patch
makes it so.

Signed-off-by: David Gibson <dwg@au1.ibm.com>

Index: working-2.6/include/asm-ia64/pgtable.h
=================================--- working-2.6.orig/include/asm-ia64/pgtable.h	2006-02-24 11:44:35.000000000 +1100
+++ working-2.6/include/asm-ia64/pgtable.h	2006-03-06 12:57:11.000000000 +1100
@@ -505,9 +505,6 @@ extern struct page *zero_page_memmap_ptr
 #define HUGETLB_PGDIR_SHIFT	(HPAGE_SHIFT + 2*(PAGE_SHIFT-3))
 #define HUGETLB_PGDIR_SIZE	(__IA64_UL(1) << HUGETLB_PGDIR_SHIFT)
 #define HUGETLB_PGDIR_MASK	(~(HUGETLB_PGDIR_SIZE-1))
-struct mmu_gather;
-void hugetlb_free_pgd_range(struct mmu_gather **tlb, unsigned long addr,
-		unsigned long end, unsigned long floor, unsigned long ceiling);
 #endif
 
 /*
Index: working-2.6/include/linux/hugetlb.h
=================================--- working-2.6.orig/include/linux/hugetlb.h	2006-03-06 11:38:45.000000000 +1100
+++ working-2.6/include/linux/hugetlb.h	2006-03-06 12:53:20.000000000 +1100
@@ -47,6 +47,10 @@ void hugetlb_change_protection(struct vm
 
 #ifndef ARCH_HAS_HUGETLB_FREE_PGD_RANGE
 #define hugetlb_free_pgd_range	free_pgd_range
+#else
+void hugetlb_free_pgd_range(struct mmu_gather **tlb, unsigned long addr,
+			    unsigned long end, unsigned long floor,
+			    unsigned long ceiling);
 #endif
 
 #ifndef ARCH_HAS_PREPARE_HUGEPAGE_RANGE

-- 
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/~dgibson
