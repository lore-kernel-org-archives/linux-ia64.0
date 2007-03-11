From: Christoph Lameter <clameter@sgi.com>
Date: Sun, 11 Mar 2007 02:09:44 +0000
Subject: [QUICKLIST 4/6] x86_64: Single Quicklist
Message-Id: <20070311020944.19905.87599.sendpatchset@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070311020923.19905.49260.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20070311020923.19905.49260.sendpatchset@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: ak@suse.com, linux-ia64@vger.kernel.org, holt@sgi.com, Christoph Lameter <clameter@sgi.com>, mpm@selenic.com

x86_64: Convert to use a single quicklists

This adds caching of pgds and puds, pmds, pte. That way we can
avoid costly zeroing and initialization of special mappings in the
pgd.

The first patch just adds a simple implementation using a single
quicklist. As a consequence we need to zero a pgd before returning
it to the pool.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.21-rc3/arch/x86_64/Kconfig
=================================--- linux-2.6.21-rc3.orig/arch/x86_64/Kconfig	2007-03-10 10:45:38.000000000 -0800
+++ linux-2.6.21-rc3/arch/x86_64/Kconfig	2007-03-10 12:50:47.000000000 -0800
@@ -56,6 +56,10 @@ config ZONE_DMA
 	bool
 	default y
 
+config NR_QUICK
+	int
+	default 1
+
 config ISA
 	bool
 
Index: linux-2.6.21-rc3/include/asm-x86_64/pgalloc.h
=================================--- linux-2.6.21-rc3.orig/include/asm-x86_64/pgalloc.h	2007-03-10 10:45:39.000000000 -0800
+++ linux-2.6.21-rc3/include/asm-x86_64/pgalloc.h	2007-03-10 12:52:14.000000000 -0800
@@ -5,6 +5,7 @@
 #include <asm/pda.h>
 #include <linux/threads.h>
 #include <linux/mm.h>
+#include <linux/quicklist.h>
 
 #define pmd_populate_kernel(mm, pmd, pte) \
 		set_pmd(pmd, __pmd(_PAGE_TABLE | __pa(pte)))
@@ -21,23 +22,23 @@ static inline void pmd_populate(struct m
 static inline void pmd_free(pmd_t *pmd)
 {
 	BUG_ON((unsigned long)pmd & (PAGE_SIZE-1));
-	free_page((unsigned long)pmd);
+	quicklist_free(0, NULL, pmd);
 }
 
 static inline pmd_t *pmd_alloc_one (struct mm_struct *mm, unsigned long addr)
 {
-	return (pmd_t *)get_zeroed_page(GFP_KERNEL|__GFP_REPEAT);
+	return (pmd_t *)quicklist_alloc(0, GFP_KERNEL|__GFP_REPEAT, NULL);
 }
 
 static inline pud_t *pud_alloc_one(struct mm_struct *mm, unsigned long addr)
 {
-	return (pud_t *)get_zeroed_page(GFP_KERNEL|__GFP_REPEAT);
+	return (pud_t *)quicklist_alloc(0, GFP_KERNEL|__GFP_REPEAT, NULL);
 }
 
 static inline void pud_free (pud_t *pud)
 {
 	BUG_ON((unsigned long)pud & (PAGE_SIZE-1));
-	free_page((unsigned long)pud);
+	quicklist_free(0, NULL, pud);
 }
 
 static inline void pgd_list_add(pgd_t *pgd)
@@ -69,9 +70,10 @@ static inline void pgd_list_del(pgd_t *p
 static inline pgd_t *pgd_alloc(struct mm_struct *mm)
 {
 	unsigned boundary;
-	pgd_t *pgd = (pgd_t *)__get_free_page(GFP_KERNEL|__GFP_REPEAT);
+	pgd_t *pgd = (pgd_t *)quicklist_alloc(0, GFP_KERNEL|__GFP_REPEAT, NULL);
 	if (!pgd)
 		return NULL;
+
 	pgd_list_add(pgd);
 	/*
 	 * Copy kernel pointers in from init.
@@ -90,17 +92,18 @@ static inline void pgd_free(pgd_t *pgd)
 {
 	BUG_ON((unsigned long)pgd & (PAGE_SIZE-1));
 	pgd_list_del(pgd);
-	free_page((unsigned long)pgd);
+	memset(pgd, 0, PAGE_SIZE);
+	quicklist_free(0, NULL, pgd);
 }
 
 static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address)
 {
-	return (pte_t *)get_zeroed_page(GFP_KERNEL|__GFP_REPEAT);
+	return (pte_t *)quicklist_alloc(0, GFP_KERNEL|__GFP_REPEAT, NULL);
 }
 
 static inline struct page *pte_alloc_one(struct mm_struct *mm, unsigned long address)
 {
-	void *p = (void *)get_zeroed_page(GFP_KERNEL|__GFP_REPEAT);
+	void *p = (void *)quicklist_alloc(0, GFP_KERNEL|__GFP_REPEAT, NULL);
 	if (!p)
 		return NULL;
 	return virt_to_page(p);
@@ -112,17 +115,21 @@ static inline struct page *pte_alloc_one
 static inline void pte_free_kernel(pte_t *pte)
 {
 	BUG_ON((unsigned long)pte & (PAGE_SIZE-1));
-	free_page((unsigned long)pte); 
+	quicklist_free(0, NULL, pte);
 }
 
 static inline void pte_free(struct page *pte)
 {
 	__free_page(pte);
-} 
+}
 
 #define __pte_free_tlb(tlb,pte) tlb_remove_page((tlb),(pte))
 
 #define __pmd_free_tlb(tlb,x)   tlb_remove_page((tlb),virt_to_page(x))
 #define __pud_free_tlb(tlb,x)   tlb_remove_page((tlb),virt_to_page(x))
 
+static inline void check_pgt_cache(void)
+{
+	quicklist_check(0, NULL);
+}
 #endif /* _X86_64_PGALLOC_H */
Index: linux-2.6.21-rc3/mm/Kconfig
=================================--- linux-2.6.21-rc3.orig/mm/Kconfig	2007-03-10 11:50:46.000000000 -0800
+++ linux-2.6.21-rc3/mm/Kconfig	2007-03-10 12:50:47.000000000 -0800
@@ -168,3 +168,8 @@ config QUICKLIST
 	default y if NR_QUICK != 0
 
 
+config QUICKLIST
+	bool
+	default y if NR_QUICK != 0
+
+
Index: linux-2.6.21-rc3/arch/x86_64/kernel/process.c
=================================--- linux-2.6.21-rc3.orig/arch/x86_64/kernel/process.c	2007-03-10 10:45:38.000000000 -0800
+++ linux-2.6.21-rc3/arch/x86_64/kernel/process.c	2007-03-10 12:52:46.000000000 -0800
@@ -207,6 +207,7 @@ void cpu_idle (void)
 			if (__get_cpu_var(cpu_idle_state))
 				__get_cpu_var(cpu_idle_state) = 0;
 
+			check_pgt_cache();
 			rmb();
 			idle = pm_idle;
 			if (!idle)
Index: linux-2.6.21-rc3/arch/x86_64/kernel/smp.c
=================================--- linux-2.6.21-rc3.orig/arch/x86_64/kernel/smp.c	2007-03-10 10:45:38.000000000 -0800
+++ linux-2.6.21-rc3/arch/x86_64/kernel/smp.c	2007-03-10 12:54:44.000000000 -0800
@@ -242,7 +242,7 @@ void flush_tlb_mm (struct mm_struct * mm
 	}
 	if (!cpus_empty(cpu_mask))
 		flush_tlb_others(cpu_mask, mm, FLUSH_ALL);
-
+	check_pgt_cache();
 	preempt_enable();
 }
 EXPORT_SYMBOL(flush_tlb_mm);
