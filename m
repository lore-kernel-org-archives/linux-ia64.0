From: Christoph Lameter <clameter@sgi.com>
Date: Sun, 11 Mar 2007 02:09:34 +0000
Subject: [QUICKLIST 2/6] i386: quicklist support
Message-Id: <20070311020934.19905.57850.sendpatchset@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070311020923.19905.49260.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20070311020923.19905.49260.sendpatchset@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: ak@suse.com, linux-ia64@vger.kernel.org, holt@sgi.com, Christoph Lameter <clameter@sgi.com>, mpm@selenic.com

i386: Convert to quicklists

Implement the i386 management of pgd and pmds using quicklists.

The i386 management of page table pages currently uses page sized slabs.
The page state is therefore mainly determined by the slab code. However,
i386 also uses its own fields in the page struct to mark special pages
and to build a list of pgds using the ->private and ->index field (yuck!).
This has been finely tuned to work right with SLAB but SLUB needs more
control over the page struct. Currently the only way for SLUB to support
these slabs is through special casing PAGE_SIZE slabs.

If we use quicklists instead then we can avoid the mess, and also the
overhead of manipulating page sized objects through slab.

It also allows us to use standard list manipulation macros for the
pgd list using page->lru thereby simplifying the code.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.21-rc3/arch/i386/mm/init.c
=================================--- linux-2.6.21-rc3.orig/arch/i386/mm/init.c	2007-03-10 13:13:32.000000000 -0800
+++ linux-2.6.21-rc3/arch/i386/mm/init.c	2007-03-10 13:39:23.000000000 -0800
@@ -695,31 +695,6 @@ int remove_memory(u64 start, u64 size)
 EXPORT_SYMBOL_GPL(remove_memory);
 #endif
 
-struct kmem_cache *pgd_cache;
-struct kmem_cache *pmd_cache;
-
-void __init pgtable_cache_init(void)
-{
-	if (PTRS_PER_PMD > 1) {
-		pmd_cache = kmem_cache_create("pmd",
-					PTRS_PER_PMD*sizeof(pmd_t),
-					PTRS_PER_PMD*sizeof(pmd_t),
-					0,
-					pmd_ctor,
-					NULL);
-		if (!pmd_cache)
-			panic("pgtable_cache_init(): cannot create pmd cache");
-	}
-	pgd_cache = kmem_cache_create("pgd",
-				PTRS_PER_PGD*sizeof(pgd_t),
-				PTRS_PER_PGD*sizeof(pgd_t),
-				0,
-				pgd_ctor,
-				PTRS_PER_PMD = 1 ? pgd_dtor : NULL);
-	if (!pgd_cache)
-		panic("pgtable_cache_init(): Cannot create pgd cache");
-}
-
 /*
  * This function cannot be __init, since exceptions don't work in that
  * section.  Put this after the callers, so that it cannot be inlined.
Index: linux-2.6.21-rc3/arch/i386/mm/pgtable.c
=================================--- linux-2.6.21-rc3.orig/arch/i386/mm/pgtable.c	2007-03-10 13:13:32.000000000 -0800
+++ linux-2.6.21-rc3/arch/i386/mm/pgtable.c	2007-03-10 13:43:39.000000000 -0800
@@ -13,6 +13,7 @@
 #include <linux/pagemap.h>
 #include <linux/spinlock.h>
 #include <linux/module.h>
+#include <linux/quicklist.h>
 
 #include <asm/system.h>
 #include <asm/pgtable.h>
@@ -181,9 +182,12 @@ void reserve_top_address(unsigned long r
 #endif
 }
 
+#define QUICK_PGD 0
+#define QUICK_PT 1
+
 pte_t *pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address)
 {
-	return (pte_t *)__get_free_page(GFP_KERNEL|__GFP_REPEAT|__GFP_ZERO);
+	return (pte_t *)quicklist_alloc(QUICK_PT, GFP_KERNEL, NULL);
 }
 
 struct page *pte_alloc_one(struct mm_struct *mm, unsigned long address)
@@ -198,11 +202,6 @@ struct page *pte_alloc_one(struct mm_str
 	return pte;
 }
 
-void pmd_ctor(void *pmd, struct kmem_cache *cache, unsigned long flags)
-{
-	memset(pmd, 0, PTRS_PER_PMD*sizeof(pmd_t));
-}
-
 /*
  * List of all pgd's needed for non-PAE so it can invalidate entries
  * in both cached and uncached pgd's; not needed for PAE since the
@@ -211,8 +210,6 @@ void pmd_ctor(void *pmd, struct kmem_cac
  * against pageattr.c; it is the unique case in which a valid change
  * of kernel pagetables can't be lazily synchronized by vmalloc faults.
  * vmalloc faults work because attached pagetables are never freed.
- * The locking scheme was chosen on the basis of manfred's
- * recommendations and having no core impact whatsoever.
  * -- wli
  */
 DEFINE_SPINLOCK(pgd_lock);
@@ -238,7 +235,7 @@ static inline void pgd_list_del(pgd_t *p
 		set_page_private(next, (unsigned long)pprev);
 }
 
-void pgd_ctor(void *pgd, struct kmem_cache *cache, unsigned long unused)
+void pgd_ctor(void *pgd)
 {
 	unsigned long flags;
 
@@ -264,7 +261,7 @@ void pgd_ctor(void *pgd, struct kmem_cac
 }
 
 /* never called when PTRS_PER_PMD > 1 */
-void pgd_dtor(void *pgd, struct kmem_cache *cache, unsigned long unused)
+void pgd_dtor(void *pgd)
 {
 	unsigned long flags; /* can be called from interrupt context */
 
@@ -277,13 +274,13 @@ void pgd_dtor(void *pgd, struct kmem_cac
 pgd_t *pgd_alloc(struct mm_struct *mm)
 {
 	int i;
-	pgd_t *pgd = kmem_cache_alloc(pgd_cache, GFP_KERNEL);
+	pgd_t *pgd = quicklist_alloc(QUICK_PGD, GFP_KERNEL, pgd_ctor);
 
 	if (PTRS_PER_PMD = 1 || !pgd)
 		return pgd;
 
 	for (i = 0; i < USER_PTRS_PER_PGD; ++i) {
-		pmd_t *pmd = kmem_cache_alloc(pmd_cache, GFP_KERNEL);
+		pmd_t *pmd = quicklist_alloc(QUICK_PT, GFP_KERNEL, NULL);
 		if (!pmd)
 			goto out_oom;
 		paravirt_alloc_pd(__pa(pmd) >> PAGE_SHIFT);
@@ -296,9 +293,9 @@ out_oom:
 		pgd_t pgdent = pgd[i];
 		void* pmd = (void *)__va(pgd_val(pgdent)-1);
 		paravirt_release_pd(__pa(pmd) >> PAGE_SHIFT);
-		kmem_cache_free(pmd_cache, pmd);
+		quicklist_free(QUICK_PT, NULL, pmd);
 	}
-	kmem_cache_free(pgd_cache, pgd);
+	quicklist_free(QUICK_PGD, pgd_dtor, pgd);
 	return NULL;
 }
 
@@ -312,8 +309,14 @@ void pgd_free(pgd_t *pgd)
 			pgd_t pgdent = pgd[i];
 			void* pmd = (void *)__va(pgd_val(pgdent)-1);
 			paravirt_release_pd(__pa(pmd) >> PAGE_SHIFT);
-			kmem_cache_free(pmd_cache, pmd);
+			quicklist_free(QUICK_PT, NULL, pmd);
 		}
 	/* in the non-PAE case, free_pgtables() clears user pgd entries */
-	kmem_cache_free(pgd_cache, pgd);
+	quicklist_free(QUICK_PGD, pgd_ctor, pgd);
+}
+
+void check_pgt_cache(void)
+{
+	quicklist_check(QUICK_PGD, pgd_dtor);
+	quicklist_check(QUICK_PT, NULL);
 }
Index: linux-2.6.21-rc3/arch/i386/Kconfig
=================================--- linux-2.6.21-rc3.orig/arch/i386/Kconfig	2007-03-10 13:13:32.000000000 -0800
+++ linux-2.6.21-rc3/arch/i386/Kconfig	2007-03-10 13:16:22.000000000 -0800
@@ -55,6 +55,10 @@ config ZONE_DMA
 	bool
 	default y
 
+config NR_QUICK
+	int
+	default 2
+
 config SBUS
 	bool
 
Index: linux-2.6.21-rc3/include/asm-i386/pgtable.h
=================================--- linux-2.6.21-rc3.orig/include/asm-i386/pgtable.h	2007-03-10 13:13:32.000000000 -0800
+++ linux-2.6.21-rc3/include/asm-i386/pgtable.h	2007-03-10 13:38:30.000000000 -0800
@@ -35,15 +35,12 @@ struct vm_area_struct;
 #define ZERO_PAGE(vaddr) (virt_to_page(empty_zero_page))
 extern unsigned long empty_zero_page[1024];
 extern pgd_t swapper_pg_dir[1024];
-extern struct kmem_cache *pgd_cache;
-extern struct kmem_cache *pmd_cache;
+
+void check_pgt_cache(void);
+
 extern spinlock_t pgd_lock;
 extern struct page *pgd_list;
-
-void pmd_ctor(void *, struct kmem_cache *, unsigned long);
-void pgd_ctor(void *, struct kmem_cache *, unsigned long);
-void pgd_dtor(void *, struct kmem_cache *, unsigned long);
-void pgtable_cache_init(void);
+static inline void pgtable_cache_init(void) {}
 void paging_init(void);
 
 /*
Index: linux-2.6.21-rc3/arch/i386/kernel/smp.c
=================================--- linux-2.6.21-rc3.orig/arch/i386/kernel/smp.c	2007-03-10 13:13:32.000000000 -0800
+++ linux-2.6.21-rc3/arch/i386/kernel/smp.c	2007-03-10 13:16:22.000000000 -0800
@@ -437,7 +437,7 @@ void flush_tlb_mm (struct mm_struct * mm
 	}
 	if (!cpus_empty(cpu_mask))
 		flush_tlb_others(cpu_mask, mm, FLUSH_ALL);
-
+	check_pgt_cache();
 	preempt_enable();
 }
 
Index: linux-2.6.21-rc3/arch/i386/kernel/process.c
=================================--- linux-2.6.21-rc3.orig/arch/i386/kernel/process.c	2007-03-10 13:13:32.000000000 -0800
+++ linux-2.6.21-rc3/arch/i386/kernel/process.c	2007-03-10 13:16:22.000000000 -0800
@@ -181,6 +181,7 @@ void cpu_idle(void)
 			if (__get_cpu_var(cpu_idle_state))
 				__get_cpu_var(cpu_idle_state) = 0;
 
+			check_pgt_cache();
 			rmb();
 			idle = pm_idle;
 
Index: linux-2.6.21-rc3/include/asm-i386/pgalloc.h
=================================--- linux-2.6.21-rc3.orig/include/asm-i386/pgalloc.h	2007-03-10 13:44:28.000000000 -0800
+++ linux-2.6.21-rc3/include/asm-i386/pgalloc.h	2007-03-10 13:45:50.000000000 -0800
@@ -66,6 +66,6 @@ do {									\
 #define pud_populate(mm, pmd, pte)	BUG()
 #endif
 
-#define check_pgt_cache()	do { } while (0)
+extern void check_pgt_cache(void);
 
 #endif /* _I386_PGALLOC_H */
