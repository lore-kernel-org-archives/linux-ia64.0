From: Robin Holt <holt@sgi.com>
Date: Wed, 02 Mar 2005 18:39:18 +0000
Subject: [Patch 1/3] Reclaim pmd and pte tables to quicklists.
Message-Id: <20050302183918.GB16517@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
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



 arch/ia64/mm/contig.c        |    2 
 arch/ia64/mm/discontig.c     |    2 
 arch/ia64/mm/init.c          |    9 +---
 include/asm-ia64/pgalloc.h   |   95 +++++++++++++------------------------------
 include/asm-ia64/processor.h |    5 --
 5 files changed, 36 insertions(+), 77 deletions(-)


Index: linux-2.6/arch/ia64/mm/discontig.c
=================================--- linux-2.6.orig/arch/ia64/mm/discontig.c	2005-03-02 12:01:02.438578237 -0600
+++ linux-2.6/arch/ia64/mm/discontig.c	2005-03-02 12:19:54.928448700 -0600
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
=================================--- linux-2.6.orig/arch/ia64/mm/init.c	2005-03-02 12:01:02.438578237 -0600
+++ linux-2.6/arch/ia64/mm/init.c	2005-03-02 12:36:47.707812440 -0600
@@ -39,6 +39,9 @@
 
 DEFINE_PER_CPU(struct mmu_gather, mmu_gathers);
 
+DEFINE_PER_CPU(unsigned long *, pgtable_quicklist);
+DEFINE_PER_CPU(long, pgtable_quicklist_size);
+
 extern void ia64_tlb_init (void);
 
 unsigned long MAX_DMA_ADDRESS = PAGE_OFFSET + 0x100000000UL;
@@ -64,13 +67,10 @@
 	high = pgt_cache_water[1];
 
 	preempt_disable();
-	if (pgtable_cache_size > (u64) high) {
+	if (__ia64_per_cpu_var(pgtable_quicklist_size) > (u64) high) {
 		do {
-			if (pgd_quicklist)
-				free_page((unsigned long)pgd_alloc_one_fast(NULL));
-			if (pmd_quicklist)
-				free_page((unsigned long)pmd_alloc_one_fast(NULL, 0));
-		} while (pgtable_cache_size > (u64) low);
+			free_page((unsigned long)pgtable_quicklist_alloc());
+		} while (__ia64_per_cpu_var(pgtable_quicklist_size) > (u64) low);
 	}
 	preempt_enable();
 }
Index: linux-2.6/include/asm-ia64/pgalloc.h
=================================--- linux-2.6.orig/include/asm-ia64/pgalloc.h	2005-03-02 12:01:02.439554788 -0600
+++ linux-2.6/include/asm-ia64/pgalloc.h	2005-03-02 12:36:54.923549812 -0600
@@ -23,57 +23,64 @@
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
 
-static inline pgd_t*
-pgd_alloc_one_fast (struct mm_struct *mm)
+DECLARE_PER_CPU(unsigned long *, pgtable_quicklist);
+DECLARE_PER_CPU(long, pgtable_quicklist_size);
+
+static inline long
+pgtable_quicklist_total_size(void)
+{
+	long quicklist_total_size;
+	int cpuid;
+
+	for_each_online_cpu(cpuid) {
+		quicklist_total_size += per_cpu(pgtable_quicklist_size, cpuid);
+	}
+	return quicklist_total_size;
+}
+
+
+static inline void*
+pgtable_quicklist_alloc(void)
 {
 	unsigned long *ret = NULL;
 
 	preempt_disable();
 
-	ret = pgd_quicklist;
+	ret = __ia64_per_cpu_var(pgtable_quicklist);
 	if (likely(ret != NULL)) {
-		pgd_quicklist = (unsigned long *)(*ret);
+		__ia64_per_cpu_var(pgtable_quicklist) = (unsigned long *)(*ret);
 		ret[0] = 0;
-		--pgtable_cache_size;
-	} else
-		ret = NULL;
+		--__ia64_per_cpu_var(pgtable_quicklist_size);
+	} else {
+		ret = (unsigned long *)__get_free_page(GFP_KERNEL|__GFP_ZERO);
+	}
 
 	preempt_enable();
 
-	return (pgd_t *) ret;
+	return ret;
+}
+
+static inline void
+pgtable_quicklist_free (void *pgtable_entry)
+{
+	preempt_disable();
+	*(unsigned long *)pgtable_entry = (unsigned long) __ia64_per_cpu_var(pgtable_quicklist);
+	__ia64_per_cpu_var(pgtable_quicklist) = (unsigned long *) pgtable_entry;
+	++__ia64_per_cpu_var(pgtable_quicklist_size);
+	preempt_enable();
 }
 
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
+	return pgtable_quicklist_alloc();
 }
 
 static inline void
 pgd_free (pgd_t *pgd)
 {
-	preempt_disable();
-	*(unsigned long *)pgd = (unsigned long) pgd_quicklist;
-	pgd_quicklist = (unsigned long *) pgd;
-	++pgtable_cache_size;
-	preempt_enable();
+	pgtable_quicklist_free(pgd);
 }
 
 static inline void
@@ -83,40 +90,15 @@
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
+	return pgtable_quicklist_alloc();
 }
 
 static inline void
 pmd_free (pmd_t *pmd)
 {
-	preempt_disable();
-	*(unsigned long *)pmd = (unsigned long) pmd_quicklist;
-	pmd_quicklist = (unsigned long *) pmd;
-	++pgtable_cache_size;
-	preempt_enable();
+	pgtable_quicklist_free(pmd);
 }
 
 #define __pmd_free_tlb(tlb, pmd)	pmd_free(pmd)
@@ -136,32 +118,28 @@
 static inline struct page *
 pte_alloc_one (struct mm_struct *mm, unsigned long addr)
 {
-	struct page *pte = alloc_pages(GFP_KERNEL|__GFP_REPEAT|__GFP_ZERO, 0);
-
-	return pte;
+	return virt_to_page(pgtable_quicklist_alloc());
 }
 
 static inline pte_t *
 pte_alloc_one_kernel (struct mm_struct *mm, unsigned long addr)
 {
-	pte_t *pte = (pte_t *)__get_free_page(GFP_KERNEL|__GFP_REPEAT|__GFP_ZERO);
-
-	return pte;
+	return pgtable_quicklist_alloc();
 }
 
 static inline void
 pte_free (struct page *pte)
 {
-	__free_page(pte);
+	pgtable_quicklist_free(page_address(pte));
 }
 
 static inline void
 pte_free_kernel (pte_t *pte)
 {
-	free_page((unsigned long) pte);
+	pgtable_quicklist_free(pte);
 }
 
-#define __pte_free_tlb(tlb, pte)	tlb_remove_page((tlb), (pte))
+#define __pte_free_tlb(tlb, pte)	pte_free(pte)
 
 extern void check_pgt_cache (void);
 
Index: linux-2.6/include/asm-ia64/processor.h
=================================--- linux-2.6.orig/include/asm-ia64/processor.h	2005-03-02 12:01:02.439554788 -0600
+++ linux-2.6/include/asm-ia64/processor.h	2005-03-02 12:13:30.521744672 -0600
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
=================================--- linux-2.6.orig/arch/ia64/mm/contig.c	2005-03-02 12:01:02.438578237 -0600
+++ linux-2.6/arch/ia64/mm/contig.c	2005-03-02 12:20:08.362864301 -0600
@@ -61,7 +61,8 @@
 	printk("%d reserved pages\n", reserved);
 	printk("%d pages shared\n", shared);
 	printk("%d pages swap cached\n", cached);
-	printk("%ld pages in page table cache\n", pgtable_cache_size);
+	printk("%ld pages in page table cache\n",
+		pgtable_quicklist_total_size());
 }
 
 /* physical address where the bootmem map is located */
