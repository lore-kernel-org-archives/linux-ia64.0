From: Robin Holt <holt@sgi.com>
Date: Tue, 15 Mar 2005 19:33:55 +0000
Subject: [Patch 1/3] Reclaim pmd and pte tables to quicklists.
Message-Id: <20050315193355.GB25617@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050302183918.GB16517@lnx-holt.americas.sgi.com>
In-Reply-To: <20050302183918.GB16517@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Tony,

This patch introduces using the quicklists for pgd, pmd, and pte levels
by combining the alloc and free functions into a common set of routines.
This greatly simplifies the reading of this header file.

I ran a full lmbench benchmark before and after this change and did not
see a significant change in performance on most things.  There is, however
a marked difference for the lat_proc fork+exit and fork+execve runs.

Signed-off-by: Robin Holt <holt@sgi.com>


Before:
Process fork+exit: 249.8571 microseconds
Process fork+execve: 840.8333 microseconds
Process fork+/bin/sh -c: 3322.0000 microseconds

After:
Process fork+exit: 186.7037 microseconds
Process fork+execve: 699.0000 microseconds
Process fork+/bin/sh -c: 2960.0000 microseconds

 arch/ia64/mm/contig.c        |    3
 arch/ia64/mm/discontig.c     |    3
 arch/ia64/mm/init.c          |   16 +++-
 include/asm-ia64/pgalloc.h   |  141 ++++++++++++++++--------------------------- include/asm-ia64/processor.h |    3
 5 files changed, 69 insertions(+), 97 deletions(-)

Index: linux-2.6/arch/ia64/mm/discontig.c
=================================--- linux-2.6.orig/arch/ia64/mm/discontig.c	2005-03-14 15:28:36.858765952 -0600
+++ linux-2.6/arch/ia64/mm/discontig.c	2005-03-14 15:28:51.543175549 -0600
@@ -582,7 +582,8 @@
 	printk("%d reserved pages\n", total_reserved);
 	printk("%d pages shared\n", total_shared);
 	printk("%d pages swap cached\n", total_cached);
-	printk("Total of %ld pages in page table cache\n", pgtable_cache_size);
+	printk("Total of %ld pages in page table cache\n",
+		pgtable_quicklist_total_size());
 	printk("%d free buffer pages\n", nr_free_buffer_pages());
 }
 
Index: linux-2.6/arch/ia64/mm/init.c
=================================--- linux-2.6.orig/arch/ia64/mm/init.c	2005-03-14 15:28:36.858765952 -0600
+++ linux-2.6/arch/ia64/mm/init.c	2005-03-15 11:53:08.751226566 -0600
@@ -39,6 +39,9 @@
 
 DEFINE_PER_CPU(struct mmu_gather, mmu_gathers);
 
+DEFINE_PER_CPU(unsigned long *, __pgtable_quicklist);
+DEFINE_PER_CPU(long, __pgtable_quicklist_size);
+
 extern void ia64_tlb_init (void);
 
 unsigned long MAX_DMA_ADDRESS = PAGE_OFFSET + 0x100000000UL;
@@ -64,13 +67,10 @@
 	high = pgt_cache_water[1];
 
 	preempt_disable();
-	if (pgtable_cache_size > (u64) high) {
+	if (pgtable_quicklist_size > (u64) high) {
 		do {
-			if (pgd_quicklist)
-				free_page((unsigned long)pgd_alloc_one_fast(NULL));
-			if (pmd_quicklist)
-				free_page((unsigned long)pmd_alloc_one_fast(NULL, 0));
-		} while (pgtable_cache_size > (u64) low);
+			free_page((unsigned long)pgtable_quicklist_alloc());
+		} while (pgtable_quicklist_size > (u64) low);
 	}
 	preempt_enable();
 }
@@ -529,6 +529,10 @@
 	int i;
 	static struct kcore_list kcore_mem, kcore_vmem, kcore_kernel;
 
+	BUG_ON(PTRS_PER_PGD * sizeof(pgd_t) != PAGE_SIZE);
+	BUG_ON(PTRS_PER_PMD * sizeof(pmd_t) != PAGE_SIZE);
+	BUG_ON(PTRS_PER_PTE * sizeof(pte_t) != PAGE_SIZE);
+
 #ifdef CONFIG_PCI
 	/*
 	 * This needs to be called _after_ the command line has been parsed but _before_
Index: linux-2.6/include/asm-ia64/pgalloc.h
=================================--- linux-2.6.orig/include/asm-ia64/pgalloc.h	2005-03-14 15:28:36.859742504 -0600
+++ linux-2.6/include/asm-ia64/pgalloc.h	2005-03-15 11:53:13.456256641 -0600
@@ -23,146 +23,115 @@
 #include <asm/mmu_context.h>
 #include <asm/processor.h>
 
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
+DECLARE_PER_CPU(unsigned long *, __pgtable_quicklist);
+#define pgtable_quicklist __ia64_per_cpu_var(__pgtable_quicklist)
+DECLARE_PER_CPU(long, __pgtable_quicklist_size);
+#define pgtable_quicklist_size __ia64_per_cpu_var(__pgtable_quicklist_size)
 
-static inline pgd_t*
-pgd_alloc_one_fast (struct mm_struct *mm)
+static inline long pgtable_quicklist_total_size(void)
+{
+	long ql_size;
+	int cpuid;
+
+	for_each_online_cpu(cpuid) {
+		ql_size += per_cpu(__pgtable_quicklist_size, cpuid);
+	}
+	return ql_size;
+}
+
+static inline void *pgtable_quicklist_alloc(void)
 {
 	unsigned long *ret = NULL;
 
 	preempt_disable();
 
-	ret = pgd_quicklist;
+	ret = pgtable_quicklist;
 	if (likely(ret != NULL)) {
-		pgd_quicklist = (unsigned long *)(*ret);
+		pgtable_quicklist = (unsigned long *)(*ret);
 		ret[0] = 0;
-		--pgtable_cache_size;
-	} else
-		ret = NULL;
+		--pgtable_quicklist_size;
+	} else {
+		ret = (unsigned long *)__get_free_page(GFP_KERNEL | __GFP_ZERO);
+	}
 
 	preempt_enable();
 
-	return (pgd_t *) ret;
-}
-
-static inline pgd_t*
-pgd_alloc (struct mm_struct *mm)
-{
-	/* the VM system never calls pgd_alloc_one_fast(), so we do it here. */
-	pgd_t *pgd = pgd_alloc_one_fast(mm);
-
-	if (unlikely(pgd = NULL)) {
-		pgd = (pgd_t *)__get_free_page(GFP_KERNEL|__GFP_ZERO);
-	}
-	return pgd;
+	return ret;
 }
 
-static inline void
-pgd_free (pgd_t *pgd)
+static inline void pgtable_quicklist_free(void *pgtable_entry)
 {
 	preempt_disable();
-	*(unsigned long *)pgd = (unsigned long) pgd_quicklist;
-	pgd_quicklist = (unsigned long *) pgd;
-	++pgtable_cache_size;
+	*(unsigned long *)pgtable_entry = (unsigned long)pgtable_quicklist;
+	pgtable_quicklist = (unsigned long *)pgtable_entry;
+	++pgtable_quicklist_size;
 	preempt_enable();
 }
 
-static inline void
-pud_populate (struct mm_struct *mm, pud_t *pud_entry, pmd_t *pmd)
+static inline pgd_t *pgd_alloc(struct mm_struct *mm)
 {
-	pud_val(*pud_entry) = __pa(pmd);
+	return pgtable_quicklist_alloc();
 }
 
-static inline pmd_t*
-pmd_alloc_one_fast (struct mm_struct *mm, unsigned long addr)
+static inline void pgd_free(pgd_t * pgd)
 {
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
+	pgtable_quicklist_free(pgd);
 }
 
-static inline pmd_t*
-pmd_alloc_one (struct mm_struct *mm, unsigned long addr)
+static inline void
+pud_populate(struct mm_struct *mm, pud_t * pud_entry, pmd_t * pmd)
 {
-	pmd_t *pmd = (pmd_t *)__get_free_page(GFP_KERNEL|__GFP_REPEAT|__GFP_ZERO);
+	pud_val(*pud_entry) = __pa(pmd);
+}
 
-	return pmd;
+static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long addr)
+{
+	return pgtable_quicklist_alloc();
 }
 
-static inline void
-pmd_free (pmd_t *pmd)
+static inline void pmd_free(pmd_t * pmd)
 {
-	preempt_disable();
-	*(unsigned long *)pmd = (unsigned long) pmd_quicklist;
-	pmd_quicklist = (unsigned long *) pmd;
-	++pgtable_cache_size;
-	preempt_enable();
+	pgtable_quicklist_free(pmd);
 }
 
 #define __pmd_free_tlb(tlb, pmd)	pmd_free(pmd)
 
 static inline void
-pmd_populate (struct mm_struct *mm, pmd_t *pmd_entry, struct page *pte)
+pmd_populate(struct mm_struct *mm, pmd_t * pmd_entry, struct page *pte)
 {
 	pmd_val(*pmd_entry) = page_to_phys(pte);
 }
 
 static inline void
-pmd_populate_kernel (struct mm_struct *mm, pmd_t *pmd_entry, pte_t *pte)
+pmd_populate_kernel(struct mm_struct *mm, pmd_t * pmd_entry, pte_t * pte)
 {
 	pmd_val(*pmd_entry) = __pa(pte);
 }
 
-static inline struct page *
-pte_alloc_one (struct mm_struct *mm, unsigned long addr)
+static inline struct page *pte_alloc_one(struct mm_struct *mm,
+					 unsigned long addr)
 {
-	struct page *pte = alloc_pages(GFP_KERNEL|__GFP_REPEAT|__GFP_ZERO, 0);
-
-	return pte;
+	return virt_to_page(pgtable_quicklist_alloc());
 }
 
-static inline pte_t *
-pte_alloc_one_kernel (struct mm_struct *mm, unsigned long addr)
+static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
+					  unsigned long addr)
 {
-	pte_t *pte = (pte_t *)__get_free_page(GFP_KERNEL|__GFP_REPEAT|__GFP_ZERO);
-
-	return pte;
+	return pgtable_quicklist_alloc();
 }
 
-static inline void
-pte_free (struct page *pte)
+static inline void pte_free(struct page *pte)
 {
-	__free_page(pte);
+	pgtable_quicklist_free(page_address(pte));
 }
 
-static inline void
-pte_free_kernel (pte_t *pte)
+static inline void pte_free_kernel(pte_t * pte)
 {
-	free_page((unsigned long) pte);
+	pgtable_quicklist_free(pte);
 }
 
-#define __pte_free_tlb(tlb, pte)	tlb_remove_page((tlb), (pte))
+#define __pte_free_tlb(tlb, pte)	pte_free(pte)
 
-extern void check_pgt_cache (void);
+extern void check_pgt_cache(void);
 
-#endif /* _ASM_IA64_PGALLOC_H */
+#endif				/* _ASM_IA64_PGALLOC_H */
Index: linux-2.6/include/asm-ia64/processor.h
=================================--- linux-2.6.orig/include/asm-ia64/processor.h	2005-03-14 15:28:36.860719056 -0600
+++ linux-2.6/include/asm-ia64/processor.h	2005-03-14 15:28:51.548058308 -0600
@@ -145,9 +145,6 @@
 	__u64 nsec_per_cyc;	/* (1000000000<<IA64_NSEC_PER_CYC_SHIFT)/itc_freq */
 	__u64 unimpl_va_mask;	/* mask of unimplemented virtual address bits (from PAL) */
 	__u64 unimpl_pa_mask;	/* mask of unimplemented physical address bits (from PAL) */
-	__u64 *pgd_quick;
-	__u64 *pmd_quick;
-	__u64 pgtable_cache_sz;
 	__u64 itc_freq;		/* frequency of ITC counter */
 	__u64 proc_freq;	/* frequency of processor */
 	__u64 cyc_per_usec;	/* itc_freq/1000000 */
Index: linux-2.6/arch/ia64/mm/contig.c
=================================--- linux-2.6.orig/arch/ia64/mm/contig.c	2005-03-14 15:28:36.859742504 -0600
+++ linux-2.6/arch/ia64/mm/contig.c	2005-03-14 15:28:51.548058308 -0600
@@ -61,7 +61,8 @@
 	printk("%d reserved pages\n", reserved);
 	printk("%d pages shared\n", shared);
 	printk("%d pages swap cached\n", cached);
-	printk("%ld pages in page table cache\n", pgtable_cache_size);
+	printk("%ld pages in page table cache\n",
+		pgtable_quicklist_total_size());
 }
 
 /* physical address where the bootmem map is located */
