From: Dominik Dingel <dingel@linux.vnet.ibm.com>
Date: Thu, 28 May 2015 11:52:36 +0000
Subject: [PATCH 4/5] s390/hugetlb: remove dead code for sw emulated huge pages
Message-Id: <1432813957-46874-5-git-send-email-dingel@linux.vnet.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1432813957-46874-1-git-send-email-dingel@linux.vnet.ibm.com>
In-Reply-To: <1432813957-46874-1-git-send-email-dingel@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org

We now support only hugepages on hardware with EDAT1 support.
So we remove the prepare/release_hugepage hooks and
simplify set_huge_pte_at and huge_ptep_get.

Acked-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
Signed-off-by: Dominik Dingel <dingel@linux.vnet.ibm.com>
---
 arch/s390/include/asm/hugetlb.h |  3 ---
 arch/s390/mm/hugetlbpage.c      | 60 +++--------------------------------------
 2 files changed, 3 insertions(+), 60 deletions(-)

diff --git a/arch/s390/include/asm/hugetlb.h b/arch/s390/include/asm/hugetlb.h
index dfb542a..0130d03 100644
--- a/arch/s390/include/asm/hugetlb.h
+++ b/arch/s390/include/asm/hugetlb.h
@@ -37,9 +37,6 @@ static inline int prepare_hugepage_range(struct file *file,
 
 #define arch_clear_hugepage_flags(page)		do { } while (0)
 
-int arch_prepare_hugepage(struct page *page);
-void arch_release_hugepage(struct page *page);
-
 static inline void huge_pte_clear(struct mm_struct *mm, unsigned long addr,
 				  pte_t *ptep)
 {
diff --git a/arch/s390/mm/hugetlbpage.c b/arch/s390/mm/hugetlbpage.c
index fa6e1bc..999616b 100644
--- a/arch/s390/mm/hugetlbpage.c
+++ b/arch/s390/mm/hugetlbpage.c
@@ -80,31 +80,16 @@ static inline pte_t __pmd_to_pte(pmd_t pmd)
 void set_huge_pte_at(struct mm_struct *mm, unsigned long addr,
 		     pte_t *ptep, pte_t pte)
 {
-	pmd_t pmd;
+	pmd_t pmd = __pte_to_pmd(pte);
 
-	pmd = __pte_to_pmd(pte);
-	if (!MACHINE_HAS_HPAGE) {
-		/* Emulated huge ptes loose the dirty and young bit */
-		pmd_val(pmd) &= ~_SEGMENT_ENTRY_ORIGIN;
-		pmd_val(pmd) |= pte_page(pte)[1].index;
-	} else
-		pmd_val(pmd) |= _SEGMENT_ENTRY_LARGE;
+	pmd_val(pmd) |= _SEGMENT_ENTRY_LARGE;
 	*(pmd_t *) ptep = pmd;
 }
 
 pte_t huge_ptep_get(pte_t *ptep)
 {
-	unsigned long origin;
-	pmd_t pmd;
+	pmd_t pmd = *(pmd_t *) ptep;
 
-	pmd = *(pmd_t *) ptep;
-	if (!MACHINE_HAS_HPAGE && pmd_present(pmd)) {
-		origin = pmd_val(pmd) & _SEGMENT_ENTRY_ORIGIN;
-		pmd_val(pmd) &= ~_SEGMENT_ENTRY_ORIGIN;
-		pmd_val(pmd) |= *(unsigned long *) origin;
-		/* Emulated huge ptes are young and dirty by definition */
-		pmd_val(pmd) |= _SEGMENT_ENTRY_YOUNG | _SEGMENT_ENTRY_DIRTY;
-	}
 	return __pmd_to_pte(pmd);
 }
 
@@ -119,45 +104,6 @@ pte_t huge_ptep_get_and_clear(struct mm_struct *mm,
 	return pte;
 }
 
-int arch_prepare_hugepage(struct page *page)
-{
-	unsigned long addr = page_to_phys(page);
-	pte_t pte;
-	pte_t *ptep;
-	int i;
-
-	if (MACHINE_HAS_HPAGE)
-		return 0;
-
-	ptep = (pte_t *) pte_alloc_one(&init_mm, addr);
-	if (!ptep)
-		return -ENOMEM;
-
-	pte_val(pte) = addr;
-	for (i = 0; i < PTRS_PER_PTE; i++) {
-		set_pte_at(&init_mm, addr + i * PAGE_SIZE, ptep + i, pte);
-		pte_val(pte) += PAGE_SIZE;
-	}
-	page[1].index = (unsigned long) ptep;
-	return 0;
-}
-
-void arch_release_hugepage(struct page *page)
-{
-	pte_t *ptep;
-
-	if (MACHINE_HAS_HPAGE)
-		return;
-
-	ptep = (pte_t *) page[1].index;
-	if (!ptep)
-		return;
-	clear_table((unsigned long *) ptep, _PAGE_INVALID,
-		    PTRS_PER_PTE * sizeof(pte_t));
-	page_table_free(&init_mm, (unsigned long *) ptep);
-	page[1].index = 0;
-}
-
 pte_t *huge_pte_alloc(struct mm_struct *mm,
 			unsigned long addr, unsigned long sz)
 {
-- 
2.3.7

