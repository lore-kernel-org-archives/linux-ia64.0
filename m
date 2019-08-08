From: Mike Rapoport <rppt@linux.ibm.com>
Date: Thu, 08 Aug 2019 07:52:07 +0000
Subject: [PATCH 2/3] ia64: switch to generic version of pte allocation
Message-Id: <1565250728-21721-3-git-send-email-rppt@linux.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1565250728-21721-1-git-send-email-rppt@linux.ibm.com>
In-Reply-To: <1565250728-21721-1-git-send-email-rppt@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nicholas Piggin <npiggin@gmail.com>, Tony Luck <tony.luck@intel.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, linux-arch@vger.kernel.org, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.ibm.com>

The ia64 implementation pte_alloc_one(), pte_alloc_one_kernel(),
pte_free_kernel() and pte_free() is identical to the generic except of lack
of __GFP_ACCOUNT for the user PTEs allocation.

Switch ia64 to use generic version of these functions.

Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
---
 arch/ia64/include/asm/pgalloc.h | 32 ++------------------------------
 1 file changed, 2 insertions(+), 30 deletions(-)

diff --git a/arch/ia64/include/asm/pgalloc.h b/arch/ia64/include/asm/pgalloc.h
index b03d993..f4c4910 100644
--- a/arch/ia64/include/asm/pgalloc.h
+++ b/arch/ia64/include/asm/pgalloc.h
@@ -20,6 +20,8 @@
 #include <linux/page-flags.h>
 #include <linux/threads.h>
 
+#include <asm-generic/pgalloc.h>
+
 #include <asm/mmu_context.h>
 
 static inline pgd_t *pgd_alloc(struct mm_struct *mm)
@@ -82,36 +84,6 @@ pmd_populate_kernel(struct mm_struct *mm, pmd_t * pmd_entry, pte_t * pte)
 	pmd_val(*pmd_entry) = __pa(pte);
 }
 
-static inline pgtable_t pte_alloc_one(struct mm_struct *mm)
-{
-	struct page *page;
-
-	page = alloc_page(GFP_KERNEL | __GFP_ZERO);
-	if (!page)
-		return NULL;
-	if (!pgtable_page_ctor(page)) {
-		__free_page(page);
-		return NULL;
-	}
-	return page;
-}
-
-static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm)
-{
-	return (pte_t *)__get_free_page(GFP_KERNEL | __GFP_ZERO);
-}
-
-static inline void pte_free(struct mm_struct *mm, pgtable_t pte)
-{
-	pgtable_page_dtor(pte);
-	__free_page(pte);
-}
-
-static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
-{
-	free_page((unsigned long)pte);
-}
-
 #define __pte_free_tlb(tlb, pte, address)	pte_free((tlb)->mm, pte)
 
 #endif				/* _ASM_IA64_PGALLOC_H */
-- 
2.7.4
