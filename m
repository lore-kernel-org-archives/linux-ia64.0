From: "Matthew Wilcox (Oracle)" <willy@infradead.org>
Date: Mon, 27 Feb 2023 17:57:21 +0000
Subject: [PATCH v2 10/30] ia64: Implement the new page table range API
Message-Id: <20230227175741.71216-11-willy@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230227175741.71216-1-willy@infradead.org>
In-Reply-To: <20230227175741.71216-1-willy@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-mm@kvack.org, linux-arch@vger.kernel.org
Cc: "Matthew Wilcox (Oracle)" <willy@infradead.org>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Add set_ptes(), update_mmu_cache_range() and flush_dcache_folio().
Change the PG_arch_1 (aka PG_dcache_clean) flag from being per-page to
per-folio, which makes arch_dma_mark_clean() and mark_clean() a little
more exciting.

Signed-off-by: Matthew Wilcox (Oracle) <willy@infradead.org>
Cc: linux-ia64@vger.kernel.org
---
 arch/ia64/hp/common/sba_iommu.c    | 26 +++++++++++++++-----------
 arch/ia64/include/asm/cacheflush.h | 14 ++++++++++----
 arch/ia64/include/asm/pgtable.h    | 14 +++++++++++++-
 arch/ia64/mm/init.c                | 29 +++++++++++++++++++----------
 4 files changed, 57 insertions(+), 26 deletions(-)

diff --git a/arch/ia64/hp/common/sba_iommu.c b/arch/ia64/hp/common/sba_iommu.c
index 8ad6946521d8..48d475f10003 100644
--- a/arch/ia64/hp/common/sba_iommu.c
+++ b/arch/ia64/hp/common/sba_iommu.c
@@ -798,22 +798,26 @@ sba_io_pdir_entry(u64 *pdir_ptr, unsigned long vba)
 #endif
 
 #ifdef ENABLE_MARK_CLEAN
-/**
+/*
  * Since DMA is i-cache coherent, any (complete) pages that were written via
  * DMA can be marked as "clean" so that lazy_mmu_prot_update() doesn't have to
  * flush them when they get mapped into an executable vm-area.
  */
-static void
-mark_clean (void *addr, size_t size)
+static void mark_clean(void *addr, size_t size)
 {
-	unsigned long pg_addr, end;
-
-	pg_addr = PAGE_ALIGN((unsigned long) addr);
-	end = (unsigned long) addr + size;
-	while (pg_addr + PAGE_SIZE <= end) {
-		struct page *page = virt_to_page((void *)pg_addr);
-		set_bit(PG_arch_1, &page->flags);
-		pg_addr += PAGE_SIZE;
+	struct folio *folio = virt_to_folio(addr);
+	ssize_t left = size;
+	size_t offset = offset_in_folio(folio, addr);
+
+	if (offset) {
+		left -= folio_size(folio) - offset;
+		folio = folio_next(folio);
+	}
+
+	while (left >= folio_size(folio)) {
+		set_bit(PG_arch_1, &folio->flags);
+		left -= folio_size(folio);
+		folio = folio_next(folio);
 	}
 }
 #endif
diff --git a/arch/ia64/include/asm/cacheflush.h b/arch/ia64/include/asm/cacheflush.h
index 708c0fa5d975..eac493fa9e0d 100644
--- a/arch/ia64/include/asm/cacheflush.h
+++ b/arch/ia64/include/asm/cacheflush.h
@@ -13,10 +13,16 @@
 #include <asm/page.h>
 
 #define ARCH_IMPLEMENTS_FLUSH_DCACHE_PAGE 1
-#define flush_dcache_page(page)			\
-do {						\
-	clear_bit(PG_arch_1, &(page)->flags);	\
-} while (0)
+static inline void flush_dcache_folio(struct folio *folio)
+{
+	clear_bit(PG_arch_1, &folio->flags);
+}
+#define flush_dcache_folio flush_dcache_folio
+
+static inline void flush_dcache_page(struct page *page)
+{
+	flush_dcache_folio(page_folio(page));
+}
 
 extern void flush_icache_range(unsigned long start, unsigned long end);
 #define flush_icache_range flush_icache_range
diff --git a/arch/ia64/include/asm/pgtable.h b/arch/ia64/include/asm/pgtable.h
index 21c97e31a28a..0c2be4ea664b 100644
--- a/arch/ia64/include/asm/pgtable.h
+++ b/arch/ia64/include/asm/pgtable.h
@@ -303,7 +303,18 @@ static inline void set_pte(pte_t *ptep, pte_t pteval)
 	*ptep = pteval;
 }
 
-#define set_pte_at(mm,addr,ptep,pteval) set_pte(ptep,pteval)
+static inline void set_ptes(struct mm_struct *mm, unsigned long addr,
+		pte_t *ptep, pte_t pte, unsigned int nr)
+{
+	for (;;) {
+		set_pte(ptep, pte);
+		if (--nr = 0)
+			break;
+		ptep++;
+		pte_val(pte) += PAGE_SIZE;
+	}
+}
+#define set_pte_at(mm, addr, ptep, pte) set_ptes(mm, add, ptep, pte, 1)
 
 /*
  * Make page protection values cacheable, uncacheable, or write-
@@ -396,6 +407,7 @@ pte_same (pte_t a, pte_t b)
 	return pte_val(a) = pte_val(b);
 }
 
+#define update_mmu_cache_range(vma, address, ptep, nr) do { } while (0)
 #define update_mmu_cache(vma, address, ptep) do { } while (0)
 
 extern pgd_t swapper_pg_dir[PTRS_PER_PGD];
diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
index 7f5353e28516..12aef25944aa 100644
--- a/arch/ia64/mm/init.c
+++ b/arch/ia64/mm/init.c
@@ -50,30 +50,39 @@ void
 __ia64_sync_icache_dcache (pte_t pte)
 {
 	unsigned long addr;
-	struct page *page;
+	struct folio *folio;
 
-	page = pte_page(pte);
-	addr = (unsigned long) page_address(page);
+	folio = page_folio(pte_page(pte));
+	addr = (unsigned long)folio_address(folio);
 
-	if (test_bit(PG_arch_1, &page->flags))
+	if (test_bit(PG_arch_1, &folio->flags))
 		return;				/* i-cache is already coherent with d-cache */
 
-	flush_icache_range(addr, addr + page_size(page));
-	set_bit(PG_arch_1, &page->flags);	/* mark page as clean */
+	flush_icache_range(addr, addr + folio_size(folio));
+	set_bit(PG_arch_1, &folio->flags);	/* mark page as clean */
 }
 
 /*
- * Since DMA is i-cache coherent, any (complete) pages that were written via
+ * Since DMA is i-cache coherent, any (complete) folios that were written via
  * DMA can be marked as "clean" so that lazy_mmu_prot_update() doesn't have to
  * flush them when they get mapped into an executable vm-area.
  */
 void arch_dma_mark_clean(phys_addr_t paddr, size_t size)
 {
-	unsigned long pfn = PHYS_PFN(paddr);
+	struct folio *folio = page_folio(phys_to_page(paddr));
+	ssize_t left = size;
+	size_t offset = offset_in_folio(folio, paddr);
 
-	do {
+	if (offset) {
+		left -= folio_size(folio) - offset;
+		folio = folio_next(folio);
+	}
+
+	while (left >= (ssize_t)folio_size(folio)) {
 		set_bit(PG_arch_1, &pfn_to_page(pfn)->flags);
-	} while (++pfn <= PHYS_PFN(paddr + size - 1));
+		left -= folio_size(folio);
+		folio = folio_next(folio);
+	}
 }
 
 inline void
-- 
2.39.1
