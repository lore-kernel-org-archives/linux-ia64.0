From: "Martin K. Petersen" <mkp@wildopensource.com>
Date: Mon, 18 Oct 2004 22:52:21 +0000
Subject: [PATCH] Convert pgtable cache to slab
Message-Id: <yq1wtxnprkq.fsf@wilson.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Tony,

Below is an updated version of the ia64 page table slabification
patch.

I have got a few other fires to fight right now so I'm still using
pgtable_cache_init() for setting up the slab.  I'll look into a
general purpose zeroed page cache later.

I have made setup_gate() an initcall.  That seemed like the best
compromise and other archs do this too.  kmem_cache_init() is called
after mem_init() in init/main.c, so we'd need to introduce another
stub there to set up the gate page even if we had a general purpose
slab cache in place.

Comments?

Signed-off-by: Martin K. Petersen <mkp@wildopensource.com>

-- 
Martin K. Petersen	Wild Open Source, Inc.
mkp@wildopensource.com	http://www.wildopensource.com/

 arch/ia64/mm/contig.c      |    1 
 arch/ia64/mm/discontig.c   |    1 
 arch/ia64/mm/init.c        |   45 ++++++++-------
 include/asm-ia64/pgalloc.h |  127 ++++++++++-----------------------------------
 include/asm-ia64/pgtable.h |    6 --
 5 files changed, 53 insertions(+), 127 deletions(-)

diff -urN -X /usr/people/mkp/bin/dontdiff linux-pristine/arch/ia64/mm/contig.c pgtable-slab/arch/ia64/mm/contig.c
--- linux-pristine/arch/ia64/mm/contig.c	2004-10-11 14:57:16.000000000 -0700
+++ pgtable-slab/arch/ia64/mm/contig.c	2004-10-11 14:59:09.000000000 -0700
@@ -60,7 +60,6 @@
 	printk("%d reserved pages\n", reserved);
 	printk("%d pages shared\n", shared);
 	printk("%d pages swap cached\n", cached);
-	printk("%ld pages in page table cache\n", pgtable_cache_size);
 }
 
 /* physical address where the bootmem map is located */
diff -urN -X /usr/people/mkp/bin/dontdiff linux-pristine/arch/ia64/mm/discontig.c pgtable-slab/arch/ia64/mm/discontig.c
--- linux-pristine/arch/ia64/mm/discontig.c	2004-10-11 14:57:16.000000000 -0700
+++ pgtable-slab/arch/ia64/mm/discontig.c	2004-10-11 15:10:05.000000000 -0700
@@ -540,7 +540,6 @@
 	printk("%d reserved pages\n", total_reserved);
 	printk("%d pages shared\n", total_shared);
 	printk("%d pages swap cached\n", total_cached);
-	printk("Total of %ld pages in page table cache\n", pgtable_cache_size);
 	printk("%d free buffer pages\n", nr_free_buffer_pages());
 }
 
diff -urN -X /usr/people/mkp/bin/dontdiff linux-pristine/arch/ia64/mm/init.c pgtable-slab/arch/ia64/mm/init.c
--- linux-pristine/arch/ia64/mm/init.c	2004-10-11 14:57:16.000000000 -0700
+++ pgtable-slab/arch/ia64/mm/init.c	2004-10-18 15:34:23.000000000 -0700
@@ -56,26 +56,6 @@
 EXPORT_SYMBOL(zero_page_memmap_ptr);
 
 void
-check_pgt_cache (void)
-{
-	int low, high;
-
-	low = pgt_cache_water[0];
-	high = pgt_cache_water[1];
-
-	preempt_disable();
-	if (pgtable_cache_size > (u64) high) {
-		do {
-			if (pgd_quicklist)
-				free_page((unsigned long)pgd_alloc_one_fast(NULL));
-			if (pmd_quicklist)
-				free_page((unsigned long)pmd_alloc_one_fast(NULL, 0));
-		} while (pgtable_cache_size > (u64) low);
-	}
-	preempt_enable();
-}
-
-void
 update_mmu_cache (struct vm_area_struct *vma, unsigned long vaddr, pte_t pte)
 {
 	unsigned long addr;
@@ -254,7 +234,7 @@
 	return page;
 }
 
-static void
+static int __init
 setup_gate (void)
 {
 	struct page *page;
@@ -272,8 +252,11 @@
 	put_kernel_page(page, GATE_ADDR + PERCPU_PAGE_SIZE, PAGE_GATE);
 #endif
 	ia64_patch_gate();
+	return 0;
 }
 
+core_initcall(setup_gate);
+
 void __devinit
 ia64_mmu_init (void *my_cpu_data)
 {
@@ -584,9 +567,27 @@
 		if (!fsyscall_table[i] || nolwsys)
 			fsyscall_table[i] = sys_call_table[i] | 1;
 	}
-	setup_gate();
 
 #ifdef CONFIG_IA32_SUPPORT
 	ia32_mem_init();
 #endif
 }
+
+kmem_cache_t *pgtable_cache;
+
+static void pgtable_cache_ctor(void *pte, kmem_cache_t *cache, unsigned long flags)
+{
+	memset(pte, 0, PAGE_SIZE);
+}
+
+void pgtable_cache_init(void)
+{
+	pgtable_cache = kmem_cache_create("pgtable_cache",
+				       PAGE_SIZE,
+				       0,
+				       SLAB_HWCACHE_ALIGN | SLAB_MUST_HWCACHE_ALIGN,
+				       pgtable_cache_ctor,
+				       NULL);
+	if (!pgtable_cache)
+		panic("pgtable_cache_init(): could not create pgtable_cache!\n");
+}
diff -urN -X /usr/people/mkp/bin/dontdiff linux-pristine/include/asm-ia64/pgalloc.h pgtable-slab/include/asm-ia64/pgalloc.h
--- linux-pristine/include/asm-ia64/pgalloc.h	2004-08-13 22:36:12.000000000 -0700
+++ pgtable-slab/include/asm-ia64/pgalloc.h	2004-10-18 14:22:50.000000000 -0700
@@ -17,65 +17,26 @@
 
 #include <linux/compiler.h>
 #include <linux/mm.h>
+#include <linux/slab.h>
 #include <linux/page-flags.h>
 #include <linux/threads.h>
 
 #include <asm/mmu_context.h>
 #include <asm/processor.h>
+#include <asm/pgtable.h>
 
-/*
- * Very stupidly, we used to get new pgd's and pmd's, init their contents
- * to point to the NULL versions of the next level page table, later on
- * completely re-init them the same way, then free them up.  This wasted
- * a lot of work and caused unnecessary memory traffic.  How broken...
- * We fix this by caching them.
- */
-#define pgd_quicklist		(local_cpu_data->pgd_quick)
-#define pmd_quicklist		(local_cpu_data->pmd_quick)
-#define pgtable_cache_size	(local_cpu_data->pgtable_cache_sz)
-
-static inline pgd_t*
-pgd_alloc_one_fast (struct mm_struct *mm)
-{
-	unsigned long *ret = NULL;
-
-	preempt_disable();
-
-	ret = pgd_quicklist;
-	if (likely(ret != NULL)) {
-		pgd_quicklist = (unsigned long *)(*ret);
-		ret[0] = 0;
-		--pgtable_cache_size;
-	} else
-		ret = NULL;
-
-	preempt_enable();
-
-	return (pgd_t *) ret;
-}
+extern kmem_cache_t *pgtable_cache;
 
 static inline pgd_t*
 pgd_alloc (struct mm_struct *mm)
 {
-	/* the VM system never calls pgd_alloc_one_fast(), so we do it here. */
-	pgd_t *pgd = pgd_alloc_one_fast(mm);
-
-	if (unlikely(pgd = NULL)) {
-		pgd = (pgd_t *)__get_free_page(GFP_KERNEL);
-		if (likely(pgd != NULL))
-			clear_page(pgd);
-	}
-	return pgd;
+	return kmem_cache_alloc(pgtable_cache, GFP_KERNEL);
 }
 
 static inline void
 pgd_free (pgd_t *pgd)
 {
-	preempt_disable();
-	*(unsigned long *)pgd = (unsigned long) pgd_quicklist;
-	pgd_quicklist = (unsigned long *) pgd;
-	++pgtable_cache_size;
-	preempt_enable();
+	kmem_cache_free(pgtable_cache, pgd);
 }
 
 static inline void
@@ -86,92 +47,62 @@
 
 
 static inline pmd_t*
-pmd_alloc_one_fast (struct mm_struct *mm, unsigned long addr)
-{
-	unsigned long *ret = NULL;
-
-	preempt_disable();
-
-	ret = (unsigned long *)pmd_quicklist;
-	if (likely(ret != NULL)) {
-		pmd_quicklist = (unsigned long *)(*ret);
-		ret[0] = 0;
-		--pgtable_cache_size;
-	}
-
-	preempt_enable();
-
-	return (pmd_t *)ret;
-}
-
-static inline pmd_t*
 pmd_alloc_one (struct mm_struct *mm, unsigned long addr)
 {
-	pmd_t *pmd = (pmd_t *)__get_free_page(GFP_KERNEL|__GFP_REPEAT);
-
-	if (likely(pmd != NULL))
-		clear_page(pmd);
-	return pmd;
+	return kmem_cache_alloc(pgtable_cache, GFP_KERNEL|__GFP_REPEAT);
 }
 
 static inline void
 pmd_free (pmd_t *pmd)
 {
-	preempt_disable();
-	*(unsigned long *)pmd = (unsigned long) pmd_quicklist;
-	pmd_quicklist = (unsigned long *) pmd;
-	++pgtable_cache_size;
-	preempt_enable();
+	kmem_cache_free(pgtable_cache, pmd);
 }
 
 #define __pmd_free_tlb(tlb, pmd)	pmd_free(pmd)
 
 static inline void
-pmd_populate (struct mm_struct *mm, pmd_t *pmd_entry, struct page *pte)
-{
-	pmd_val(*pmd_entry) = page_to_phys(pte);
-}
-
-static inline void
 pmd_populate_kernel (struct mm_struct *mm, pmd_t *pmd_entry, pte_t *pte)
 {
 	pmd_val(*pmd_entry) = __pa(pte);
 }
 
-static inline struct page *
-pte_alloc_one (struct mm_struct *mm, unsigned long addr)
+static inline void
+pmd_populate (struct mm_struct *mm, pmd_t *pmd_entry, struct page *pte)
 {
-	struct page *pte = alloc_pages(GFP_KERNEL|__GFP_REPEAT, 0);
-
-	if (likely(pte != NULL))
-		clear_page(page_address(pte));
-	return pte;
+	pmd_val(*pmd_entry) = page_to_phys(pte);
 }
 
+
 static inline pte_t *
 pte_alloc_one_kernel (struct mm_struct *mm, unsigned long addr)
 {
-	pte_t *pte = (pte_t *)__get_free_page(GFP_KERNEL|__GFP_REPEAT);
-
-	if (likely(pte != NULL))
-		clear_page(pte);
-	return pte;
+	return kmem_cache_alloc(pgtable_cache, GFP_KERNEL|__GFP_REPEAT);
 }
 
 static inline void
-pte_free (struct page *pte)
+pte_free_kernel (pte_t *pte)
 {
-	__free_page(pte);
+	kmem_cache_free(pgtable_cache, pte);
 }
 
-static inline void
-pte_free_kernel (pte_t *pte)
+static inline struct page *
+pte_alloc_one (struct mm_struct *mm, unsigned long addr)
 {
-	free_page((unsigned long) pte);
+	pte_t *pte = pte_alloc_one_kernel(mm, addr);
+
+	if (pte)
+		return virt_to_page(pte);
+
+	return NULL;
 }
 
-#define __pte_free_tlb(tlb, pte)	tlb_remove_page((tlb), (pte))
+static inline void
+pte_free (struct page *pte)
+{
+	pte_free_kernel(page_address(pte));
+}
 
-extern void check_pgt_cache (void);
+#define __pte_free_tlb(tlb, pte)	pte_free(pte)
+#define check_pgt_cache()		do { } while (0)
 
 #endif /* _ASM_IA64_PGALLOC_H */
diff -urN -X /usr/people/mkp/bin/dontdiff linux-pristine/include/asm-ia64/pgtable.h pgtable-slab/include/asm-ia64/pgtable.h
--- linux-pristine/include/asm-ia64/pgtable.h	2004-10-11 14:57:19.000000000 -0700
+++ pgtable-slab/include/asm-ia64/pgtable.h	2004-10-18 14:38:34.000000000 -0700
@@ -422,6 +422,7 @@
 
 extern pgd_t swapper_pg_dir[PTRS_PER_PGD];
 extern void paging_init (void);
+extern void pgtable_cache_init(void);
 
 /*
  * Note: The macros below rely on the fact that MAX_SWAPFILES_SHIFT <= number of
@@ -542,11 +543,6 @@
 #define KERNEL_TR_PAGE_SHIFT	_PAGE_SIZE_64M
 #define KERNEL_TR_PAGE_SIZE	(1 << KERNEL_TR_PAGE_SHIFT)
 
-/*
- * No page table caches to initialise
- */
-#define pgtable_cache_init()	do { } while (0)
-
 /* These tell get_user_pages() that the first gate page is accessible from user-level.  */
 #define FIXADDR_USER_START	GATE_ADDR
 #define FIXADDR_USER_END	(GATE_ADDR + 2*PERCPU_PAGE_SIZE)
