From: Robin Holt <holt@sgi.com>
Date: Thu, 10 Feb 2005 20:29:31 +0000
Subject: Re: [PATCH] Convert pgtable cache to slab
Message-Id: <20050210202931.GA28014@attica.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <yq1wtxnprkq.fsf@wilson.mkp.net>
In-Reply-To: <yq1wtxnprkq.fsf@wilson.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Tony,

I have resurrected the ia64 page table slabification patch that Martin
Petersen proposed earlier.  This applies against the 2.6.11-rc3 tarball
and builds for allyesconfig, allmodconfig, and defconfig.  Additionally,
defconfig was booted on an SN2 machine.

I am deferring the general purpose zeroed page cache work for later as
did Martin.

Signed-off-by: Robin Holt <holt@sgi.com>
Signed-off-by: Martin K. Petersen <mkp@wildopensource.com>


 arch/ia64/mm/contig.c      |    1 
 arch/ia64/mm/discontig.c   |    1 
 arch/ia64/mm/init.c        |   45 ++++++++---------
 include/asm-ia64/pgalloc.h |  118 ++++++++++-----------------------------------
 include/asm-ia64/pgtable.h |    6 --
 5 files changed, 52 insertions(+), 119 deletions(-)


Index: linux-2.6/arch/ia64/mm/contig.c
=================================--- linux-2.6.orig/arch/ia64/mm/contig.c	2005-02-10 12:14:31.248130419 -0600
+++ linux-2.6/arch/ia64/mm/contig.c	2005-02-10 12:49:41.734267769 -0600
@@ -61,7 +61,6 @@
 	printk("%d reserved pages\n", reserved);
 	printk("%d pages shared\n", shared);
 	printk("%d pages swap cached\n", cached);
-	printk("%ld pages in page table cache\n", pgtable_cache_size);
 }
 
 /* physical address where the bootmem map is located */
Index: linux-2.6/arch/ia64/mm/discontig.c
=================================--- linux-2.6.orig/arch/ia64/mm/discontig.c	2005-02-10 12:15:04.474319994 -0600
+++ linux-2.6/arch/ia64/mm/discontig.c	2005-02-10 12:49:41.735244321 -0600
@@ -582,7 +582,6 @@
 	printk("%d reserved pages\n", total_reserved);
 	printk("%d pages shared\n", total_shared);
 	printk("%d pages swap cached\n", total_cached);
-	printk("Total of %ld pages in page table cache\n", pgtable_cache_size);
 	printk("%d free buffer pages\n", nr_free_buffer_pages());
 }
 
Index: linux-2.6/arch/ia64/mm/init.c
=================================--- linux-2.6.orig/arch/ia64/mm/init.c	2005-02-10 12:14:35.318397233 -0600
+++ linux-2.6/arch/ia64/mm/init.c	2005-02-10 12:49:41.737197424 -0600
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
@@ -271,7 +251,7 @@
 	return page;
 }
 
-static void
+static int __init
 setup_gate (void)
 {
 	struct page *page;
@@ -289,8 +269,11 @@
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
@@ -590,9 +573,27 @@
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
Index: linux-2.6/include/asm-ia64/pgalloc.h
=================================--- linux-2.6.orig/include/asm-ia64/pgalloc.h	2005-02-10 12:14:10.711251555 -0600
+++ linux-2.6/include/asm-ia64/pgalloc.h	2005-02-10 13:06:17.960526962 -0600
@@ -17,63 +17,26 @@
 
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
-		pgd = (pgd_t *)__get_free_page(GFP_KERNEL|__GFP_ZERO);
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
@@ -83,86 +46,61 @@
 }
 
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
-	pmd_t *pmd = (pmd_t *)__get_free_page(GFP_KERNEL|__GFP_REPEAT|__GFP_ZERO);
-
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
-	struct page *pte = alloc_pages(GFP_KERNEL|__GFP_REPEAT|__GFP_ZERO, 0);
-
-	return pte;
+	pmd_val(*pmd_entry) = page_to_phys(pte);
 }
 
 static inline pte_t *
 pte_alloc_one_kernel (struct mm_struct *mm, unsigned long addr)
 {
-	pte_t *pte = (pte_t *)__get_free_page(GFP_KERNEL|__GFP_REPEAT|__GFP_ZERO);
-
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
Index: linux-2.6/include/asm-ia64/pgtable.h
=================================--- linux-2.6.orig/include/asm-ia64/pgtable.h	2005-02-10 12:14:29.641703137 -0600
+++ linux-2.6/include/asm-ia64/pgtable.h	2005-02-10 12:49:41.745009837 -0600
@@ -423,6 +423,7 @@
 
 extern pgd_t swapper_pg_dir[PTRS_PER_PGD];
 extern void paging_init (void);
+extern void pgtable_cache_init(void);
 
 /*
  * Note: The macros below rely on the fact that MAX_SWAPFILES_SHIFT <= number of
@@ -545,11 +546,6 @@
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
