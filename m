From: Robin Holt <holt@sgi.com>
Date: Sat, 26 Feb 2005 14:25:41 +0000
Subject: [Patch 1/3] Reclaim pmd and pte entries to quicklists.
Message-Id: <20050226142541.GE10965@lnx-holt.americas.sgi.com>
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
Process fork+exit: 255.0909 microseconds
Process fork+exit: 254.5238 microseconds
Process fork+exit: 254.5714 microseconds
Process fork+exit: 260.8636 microseconds
Process fork+exit: 248.9091 microseconds
Process fork+exit: 254.0952 microseconds
Process fork+exit: 252.1364 microseconds
Process fork+exit: 251.3478 microseconds
Process fork+exit: 250.5217 microseconds
Process fork+exit: 249.5238 microseconds
Process fork+execve: 258.0500 microseconds
Process fork+execve: 258.5500 microseconds
Process fork+execve: 259.2500 microseconds
Process fork+execve: 255.5000 microseconds
Process fork+execve: 254.6500 microseconds
Process fork+execve: 262.0455 microseconds
Process fork+execve: 257.2500 microseconds
Process fork+execve: 256.0909 microseconds
Process fork+execve: 258.4500 microseconds
Process fork+execve: 258.4000 microseconds

After:
Process fork+exit: 184.2333 microseconds
Process fork+exit: 184.7241 microseconds
Process fork+exit: 184.0333 microseconds
Process fork+exit: 185.6667 microseconds
Process fork+exit: 185.4000 microseconds
Process fork+exit: 184.6000 microseconds
Process fork+exit: 184.1333 microseconds
Process fork+exit: 184.3667 microseconds
Process fork+exit: 184.7667 microseconds
Process fork+exit: 183.7097 microseconds
Process fork+execve: 188.5172 microseconds
Process fork+execve: 190.0000 microseconds
Process fork+execve: 189.7931 microseconds
Process fork+execve: 190.2414 microseconds
Process fork+execve: 190.5517 microseconds
Process fork+execve: 190.5172 microseconds
Process fork+execve: 191.0000 microseconds
Process fork+execve: 189.9310 microseconds
Process fork+execve: 191.2069 microseconds
Process fork+execve: 190.8276 microseconds


 arch/ia64/mm/contig.c        |    2 
 arch/ia64/mm/discontig.c     |    2 
 arch/ia64/mm/init.c          |    9 +---
 include/asm-ia64/pgalloc.h   |   95 +++++++++++++------------------------------
 include/asm-ia64/processor.h |    5 --
 5 files changed, 36 insertions(+), 77 deletions(-)


Index: linux-2.6/arch/ia64/mm/discontig.c
=================================--- linux-2.6.orig/arch/ia64/mm/discontig.c	2005-02-25 17:14:45.712380229 -0600
+++ linux-2.6/arch/ia64/mm/discontig.c	2005-02-26 07:25:48.590951585 -0600
@@ -582,7 +582,7 @@
 	printk("%d reserved pages\n", total_reserved);
 	printk("%d pages shared\n", total_shared);
 	printk("%d pages swap cached\n", total_cached);
-	printk("Total of %ld pages in page table cache\n", pgtable_cache_size);
+	printk("Total of %ld pages in page table cache\n", local_cpu_data->pgtable_quicklist_size);
 	printk("%d free buffer pages\n", nr_free_buffer_pages());
 }
 
Index: linux-2.6/arch/ia64/mm/init.c
=================================--- linux-2.6.orig/arch/ia64/mm/init.c	2005-02-25 17:14:45.713356780 -0600
+++ linux-2.6/arch/ia64/mm/init.c	2005-02-26 07:36:18.933000631 -0600
@@ -64,13 +64,10 @@
 	high = pgt_cache_water[1];
 
 	preempt_disable();
-	if (pgtable_cache_size > (u64) high) {
+	if (local_cpu_data->pgtable_quicklist_size > (u64) high) {
 		do {
-			if (pgd_quicklist)
-				free_page((unsigned long)pgd_alloc_one_fast(NULL));
-			if (pmd_quicklist)
-				free_page((unsigned long)pmd_alloc_one_fast(NULL, 0));
-		} while (pgtable_cache_size > (u64) low);
+			free_page((unsigned long)pgtable_quicklist_alloc());
+		} while (local_cpu_data->pgtable_quicklist_size > (u64) low);
 	}
 	preempt_enable();
 }
Index: linux-2.6/include/asm-ia64/pgalloc.h
=================================--- linux-2.6.orig/include/asm-ia64/pgalloc.h	2005-02-25 17:14:45.714333331 -0600
+++ linux-2.6/include/asm-ia64/pgalloc.h	2005-02-26 07:31:43.557396415 -0600
@@ -23,57 +23,49 @@
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
+
+static inline void*
+pgtable_quicklist_alloc(void)
 {
 	unsigned long *ret = NULL;
 
 	preempt_disable();
 
-	ret = pgd_quicklist;
+	ret = local_cpu_data->pgtable_quicklist;
 	if (likely(ret != NULL)) {
-		pgd_quicklist = (unsigned long *)(*ret);
+		local_cpu_data->pgtable_quicklist = (unsigned long *)(*ret);
 		ret[0] = 0;
-		--pgtable_cache_size;
-	} else
-		ret = NULL;
+		--local_cpu_data->pgtable_quicklist_size;
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
+	*(unsigned long *)pgtable_entry = (unsigned long) local_cpu_data->pgtable_quicklist;
+	local_cpu_data->pgtable_quicklist = (unsigned long *) pgtable_entry;
+	++local_cpu_data->pgtable_quicklist_size;
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
@@ -83,40 +75,15 @@
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
@@ -136,32 +103,28 @@
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
=================================--- linux-2.6.orig/include/asm-ia64/processor.h	2005-02-25 17:14:45.714333331 -0600
+++ linux-2.6/include/asm-ia64/processor.h	2005-02-26 07:25:48.785285191 -0600
@@ -145,9 +145,8 @@
 	__u64 nsec_per_cyc;	/* (1000000000<<IA64_NSEC_PER_CYC_SHIFT)/itc_freq */
 	__u64 unimpl_va_mask;	/* mask of unimplemented virtual address bits (from PAL) */
 	__u64 unimpl_pa_mask;	/* mask of unimplemented physical address bits (from PAL) */
-	__u64 *pgd_quick;
-	__u64 *pmd_quick;
-	__u64 pgtable_cache_sz;
+	__u64 *pgtable_quicklist;
+	__u64 pgtable_quicklist_size;
 	__u64 itc_freq;		/* frequency of ITC counter */
 	__u64 proc_freq;	/* frequency of processor */
 	__u64 cyc_per_usec;	/* itc_freq/1000000 */
Index: linux-2.6/arch/ia64/mm/contig.c
=================================--- linux-2.6.orig/arch/ia64/mm/contig.c	2005-02-25 17:14:45.713356780 -0600
+++ linux-2.6/arch/ia64/mm/contig.c	2005-02-26 07:25:48.817511367 -0600
@@ -61,7 +61,7 @@
 	printk("%d reserved pages\n", reserved);
 	printk("%d pages shared\n", shared);
 	printk("%d pages swap cached\n", cached);
-	printk("%ld pages in page table cache\n", pgtable_cache_size);
+	printk("%ld pages in page table cache\n", local_cpu_data->pgtable_quicklist_size);
 }
 
 /* physical address where the bootmem map is located */
