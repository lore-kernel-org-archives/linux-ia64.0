From: Christoph Lameter <clameter@sgi.com>
Date: Sun, 11 Mar 2007 02:09:29 +0000
Subject: [QUICKLIST 1/6] Extract quicklist implementation from IA64
Message-Id: <20070311020929.19905.97408.sendpatchset@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070311020923.19905.49260.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20070311020923.19905.49260.sendpatchset@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: ak@suse.com, mpm@selenic.com, linux-ia64@vger.kernel.org, holt@sgi.com, Christoph Lameter <clameter@sgi.com>

Abstract quicklist from the IA64 implementation

Extract the quicklist implementation for IA64, clean it up
and generalize it to:

1. Allow multiple quicklists

2. Add support for constructors and destructors..

Quicklist allocation and frees occur inline. The support
for constructors / destructors and multiple quicklists
can therefore be optimized out of the final code for an
arch.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.21-rc3/arch/ia64/mm/init.c
=================================--- linux-2.6.21-rc3.orig/arch/ia64/mm/init.c	2007-03-10 11:34:00.000000000 -0800
+++ linux-2.6.21-rc3/arch/ia64/mm/init.c	2007-03-10 11:50:46.000000000 -0800
@@ -39,9 +39,6 @@
 
 DEFINE_PER_CPU(struct mmu_gather, mmu_gathers);
 
-DEFINE_PER_CPU(unsigned long *, __pgtable_quicklist);
-DEFINE_PER_CPU(long, __pgtable_quicklist_size);
-
 extern void ia64_tlb_init (void);
 
 unsigned long MAX_DMA_ADDRESS = PAGE_OFFSET + 0x100000000UL;
@@ -56,54 +53,6 @@ EXPORT_SYMBOL(vmem_map);
 struct page *zero_page_memmap_ptr;	/* map entry for zero page */
 EXPORT_SYMBOL(zero_page_memmap_ptr);
 
-#define MIN_PGT_PAGES			25UL
-#define MAX_PGT_FREES_PER_PASS		16L
-#define PGT_FRACTION_OF_NODE_MEM	16
-
-static inline long
-max_pgt_pages(void)
-{
-	u64 node_free_pages, max_pgt_pages;
-
-#ifndef	CONFIG_NUMA
-	node_free_pages = nr_free_pages();
-#else
-	node_free_pages = node_page_state(numa_node_id(), NR_FREE_PAGES);
-#endif
-	max_pgt_pages = node_free_pages / PGT_FRACTION_OF_NODE_MEM;
-	max_pgt_pages = max(max_pgt_pages, MIN_PGT_PAGES);
-	return max_pgt_pages;
-}
-
-static inline long
-min_pages_to_free(void)
-{
-	long pages_to_free;
-
-	pages_to_free = pgtable_quicklist_size - max_pgt_pages();
-	pages_to_free = min(pages_to_free, MAX_PGT_FREES_PER_PASS);
-	return pages_to_free;
-}
-
-void
-check_pgt_cache(void)
-{
-	long pages_to_free;
-
-	if (unlikely(pgtable_quicklist_size <= MIN_PGT_PAGES))
-		return;
-
-	preempt_disable();
-	while (unlikely((pages_to_free = min_pages_to_free()) > 0)) {
-		while (pages_to_free--) {
-			free_page((unsigned long)pgtable_quicklist_alloc());
-		}
-		preempt_enable();
-		preempt_disable();
-	}
-	preempt_enable();
-}
-
 void
 lazy_mmu_prot_update (pte_t pte)
 {
Index: linux-2.6.21-rc3/include/asm-ia64/pgalloc.h
=================================--- linux-2.6.21-rc3.orig/include/asm-ia64/pgalloc.h	2007-03-10 11:34:00.000000000 -0800
+++ linux-2.6.21-rc3/include/asm-ia64/pgalloc.h	2007-03-10 12:37:56.000000000 -0800
@@ -18,71 +18,18 @@
 #include <linux/mm.h>
 #include <linux/page-flags.h>
 #include <linux/threads.h>
+#include <linux/quicklist.h>
 
 #include <asm/mmu_context.h>
 
-DECLARE_PER_CPU(unsigned long *, __pgtable_quicklist);
-#define pgtable_quicklist __ia64_per_cpu_var(__pgtable_quicklist)
-DECLARE_PER_CPU(long, __pgtable_quicklist_size);
-#define pgtable_quicklist_size __ia64_per_cpu_var(__pgtable_quicklist_size)
-
-static inline long pgtable_quicklist_total_size(void)
-{
-	long ql_size = 0;
-	int cpuid;
-
-	for_each_online_cpu(cpuid) {
-		ql_size += per_cpu(__pgtable_quicklist_size, cpuid);
-	}
-	return ql_size;
-}
-
-static inline void *pgtable_quicklist_alloc(void)
-{
-	unsigned long *ret = NULL;
-
-	preempt_disable();
-
-	ret = pgtable_quicklist;
-	if (likely(ret != NULL)) {
-		pgtable_quicklist = (unsigned long *)(*ret);
-		ret[0] = 0;
-		--pgtable_quicklist_size;
-		preempt_enable();
-	} else {
-		preempt_enable();
-		ret = (unsigned long *)__get_free_page(GFP_KERNEL | __GFP_ZERO);
-	}
-
-	return ret;
-}
-
-static inline void pgtable_quicklist_free(void *pgtable_entry)
-{
-#ifdef CONFIG_NUMA
-	int nid = page_to_nid(virt_to_page(pgtable_entry));
-
-	if (unlikely(nid != numa_node_id())) {
-		free_page((unsigned long)pgtable_entry);
-		return;
-	}
-#endif
-
-	preempt_disable();
-	*(unsigned long *)pgtable_entry = (unsigned long)pgtable_quicklist;
-	pgtable_quicklist = (unsigned long *)pgtable_entry;
-	++pgtable_quicklist_size;
-	preempt_enable();
-}
-
 static inline pgd_t *pgd_alloc(struct mm_struct *mm)
 {
-	return pgtable_quicklist_alloc();
+	return quicklist_alloc(0, GFP_KERNEL, NULL);
 }
 
 static inline void pgd_free(pgd_t * pgd)
 {
-	pgtable_quicklist_free(pgd);
+	quicklist_free(0, NULL, pgd);
 }
 
 #ifdef CONFIG_PGTABLE_4
@@ -94,12 +41,12 @@ pgd_populate(struct mm_struct *mm, pgd_t
 
 static inline pud_t *pud_alloc_one(struct mm_struct *mm, unsigned long addr)
 {
-	return pgtable_quicklist_alloc();
+	return quicklist_alloc(0, GFP_KERNEL, NULL);
 }
 
 static inline void pud_free(pud_t * pud)
 {
-	pgtable_quicklist_free(pud);
+	quicklist_free(0, NULL, pud);
 }
 #define __pud_free_tlb(tlb, pud)	pud_free(pud)
 #endif /* CONFIG_PGTABLE_4 */
@@ -112,12 +59,12 @@ pud_populate(struct mm_struct *mm, pud_t
 
 static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long addr)
 {
-	return pgtable_quicklist_alloc();
+	return quicklist_alloc(0, GFP_KERNEL, NULL);
 }
 
 static inline void pmd_free(pmd_t * pmd)
 {
-	pgtable_quicklist_free(pmd);
+	quicklist_free(0, NULL, pmd);
 }
 
 #define __pmd_free_tlb(tlb, pmd)	pmd_free(pmd)
@@ -137,28 +84,31 @@ pmd_populate_kernel(struct mm_struct *mm
 static inline struct page *pte_alloc_one(struct mm_struct *mm,
 					 unsigned long addr)
 {
-	void *pg = pgtable_quicklist_alloc();
+	void *pg = quicklist_alloc(0, GFP_KERNEL, NULL);
 	return pg ? virt_to_page(pg) : NULL;
 }
 
 static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
 					  unsigned long addr)
 {
-	return pgtable_quicklist_alloc();
+	return quicklist_alloc(0, GFP_KERNEL, NULL);
 }
 
 static inline void pte_free(struct page *pte)
 {
-	pgtable_quicklist_free(page_address(pte));
+	quicklist_free(0, NULL, page_address(pte));
 }
 
 static inline void pte_free_kernel(pte_t * pte)
 {
-	pgtable_quicklist_free(pte);
+	quicklist_free(0, NULL, pte);
 }
 
-#define __pte_free_tlb(tlb, pte)	pte_free(pte)
+static inline void check_pgt_cache(void)
+{
+	quicklist_check(0, NULL);
+}
 
-extern void check_pgt_cache(void);
+#define __pte_free_tlb(tlb, pte)	pte_free(pte)
 
 #endif				/* _ASM_IA64_PGALLOC_H */
Index: linux-2.6.21-rc3/include/linux/quicklist.h
=================================--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6.21-rc3/include/linux/quicklist.h	2007-03-10 12:38:44.000000000 -0800
@@ -0,0 +1,79 @@
+#ifndef LINUX_QUICKLIST_H
+#define LINUX_QUICKLIST_H
+/*
+ * Fast allocations and disposal of pages. Pages must be in the condition
+ * as needed after allocation when they are freed. Per cpu lists of pages
+ * are kept that only contain node local pages.
+ *
+ * (C) 2007, SGI. Christoph Lameter <clameter@sgi.com>
+ */
+#include <linux/kernel.h>
+
+#ifdef CONFIG_NR_QUICK
+
+struct quicklist {
+	void *page;
+	int nr_pages;
+};
+
+DECLARE_PER_CPU(struct quicklist, quicklist)[CONFIG_NR_QUICK];
+
+static inline void *quicklist_alloc(int nr, gfp_t flags, void (*ctor)(void *))
+{
+	struct quicklist *q;
+	void **p = NULL;
+
+	q =&get_cpu_var(quicklist)[nr];
+	p = q->page;
+	if (likely(p)) {
+		q->page = p[0];
+		p[0] = NULL;
+		q->nr_pages--;
+	}
+	put_cpu_var(quicklist);
+	if (likely(p))
+		return p;
+
+	p = (void *)__get_free_page(flags | __GFP_ZERO);
+	if (ctor && p)
+		ctor(p);
+	return p;
+}
+
+static inline void quicklist_free(int nr, void (*dtor)(void *), void *pp)
+{
+	struct quicklist *q;
+	void **p = pp;
+	struct page *page = virt_to_page(p);
+	int nid = page_to_nid(page);
+
+	if (unlikely(nid != numa_node_id())) {
+		if (dtor)
+			dtor(p);
+		free_page((unsigned long)p);
+		return;
+	}
+
+	q = &get_cpu_var(quicklist)[nr];
+	p[0] = q->page;
+	q->page = p;
+	q->nr_pages++;
+	put_cpu_var(quicklist);
+}
+
+void quicklist_check(int nr, void (*dtor)(void *));
+unsigned long quicklist_total_size(void);
+
+#else
+void quicklist_check(int nr, void (*dtor)(void *))
+{
+}
+
+unsigned long quicklist_total_size(void)
+{
+	return 0;
+}
+#endif
+
+#endif /* LINUX_QUICKLIST_H */
+
Index: linux-2.6.21-rc3/mm/Makefile
=================================--- linux-2.6.21-rc3.orig/mm/Makefile	2007-03-10 11:34:00.000000000 -0800
+++ linux-2.6.21-rc3/mm/Makefile	2007-03-10 11:50:46.000000000 -0800
@@ -30,3 +30,5 @@ obj-$(CONFIG_MEMORY_HOTPLUG) += memory_h
 obj-$(CONFIG_FS_XIP) += filemap_xip.o
 obj-$(CONFIG_MIGRATION) += migrate.o
 obj-$(CONFIG_SMP) += allocpercpu.o
+obj-$(CONFIG_QUICKLIST) += quicklist.o
+
Index: linux-2.6.21-rc3/mm/quicklist.c
=================================--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6.21-rc3/mm/quicklist.c	2007-03-10 12:40:27.000000000 -0800
@@ -0,0 +1,74 @@
+/*
+ * Quicklist support.
+ *
+ * Copyright (C) 2005-2007 SGI,
+ * 	Robin Holt <holt@sgi.com>
+ * 	Christoph Lameter <clameter@sgi.com>
+ */
+#include <linux/kernel.h>
+
+#include <linux/mm.h>
+#include <linux/mmzone.h>
+#include <linux/module.h>
+#include <linux/quicklist.h>
+
+DEFINE_PER_CPU(struct quicklist, quicklist)[CONFIG_NR_QUICK];
+
+#define MIN_PAGES		25
+#define MAX_FREES_PER_PASS	16
+#define FRACTION_OF_NODE_MEM	16
+
+static unsigned long max_pages(void)
+{
+	unsigned long node_free_pages, max;
+
+	node_free_pages = node_page_state(numa_node_id(),
+			NR_FREE_PAGES);
+	max = node_free_pages / FRACTION_OF_NODE_MEM;
+	return max(max, (unsigned long)MIN_PAGES);
+}
+
+static long min_pages_to_free(struct quicklist *q)
+{
+	long pages_to_free;
+
+	pages_to_free = q->nr_pages - max_pages();
+
+	return min(pages_to_free, (long)MAX_FREES_PER_PASS);
+}
+
+void quicklist_check(int nr, void (*dtor)(void *))
+{
+	long pages_to_free;
+	struct quicklist *q;
+
+	q = &get_cpu_var(quicklist)[nr];
+	if (q->nr_pages > MIN_PAGES) {
+		pages_to_free = min_pages_to_free(q);
+
+		while (pages_to_free > 0) {
+			void *p = quicklist_alloc(nr, 0, NULL);
+
+			if (dtor)
+				dtor(p);
+			free_page((unsigned long)p);
+			pages_to_free--;
+		}
+	}
+	put_cpu_var(quicklist);
+}
+
+unsigned long quicklist_total_size(void)
+{
+	unsigned long count = 0;
+	int cpu;
+	struct quicklist *ql, *q;
+
+	for_each_online_cpu(cpu) {
+		ql = per_cpu(quicklist, cpu);
+		for (q = ql; q < ql + CONFIG_NR_QUICK; q++)
+			count += q->nr_pages;
+	}
+	return count;
+}
+
Index: linux-2.6.21-rc3/arch/ia64/mm/contig.c
=================================--- linux-2.6.21-rc3.orig/arch/ia64/mm/contig.c	2007-03-10 11:34:00.000000000 -0800
+++ linux-2.6.21-rc3/arch/ia64/mm/contig.c	2007-03-10 11:50:46.000000000 -0800
@@ -88,7 +88,7 @@ void show_mem(void)
 	printk(KERN_INFO "%d pages shared\n", total_shared);
 	printk(KERN_INFO "%d pages swap cached\n", total_cached);
 	printk(KERN_INFO "Total of %ld pages in page table cache\n",
-	       pgtable_quicklist_total_size());
+	       quicklist_total_size());
 	printk(KERN_INFO "%d free buffer pages\n", nr_free_buffer_pages());
 }
 
Index: linux-2.6.21-rc3/arch/ia64/mm/discontig.c
=================================--- linux-2.6.21-rc3.orig/arch/ia64/mm/discontig.c	2007-03-10 11:34:00.000000000 -0800
+++ linux-2.6.21-rc3/arch/ia64/mm/discontig.c	2007-03-10 11:50:46.000000000 -0800
@@ -563,7 +563,7 @@ void show_mem(void)
 	printk(KERN_INFO "%d pages shared\n", total_shared);
 	printk(KERN_INFO "%d pages swap cached\n", total_cached);
 	printk(KERN_INFO "Total of %ld pages in page table cache\n",
-	       pgtable_quicklist_total_size());
+	       quicklist_total_size());
 	printk(KERN_INFO "%d free buffer pages\n", nr_free_buffer_pages());
 }
 
Index: linux-2.6.21-rc3/arch/ia64/Kconfig
=================================--- linux-2.6.21-rc3.orig/arch/ia64/Kconfig	2007-03-10 11:34:00.000000000 -0800
+++ linux-2.6.21-rc3/arch/ia64/Kconfig	2007-03-10 11:50:46.000000000 -0800
@@ -29,6 +29,10 @@ config ZONE_DMA
 	def_bool y
 	depends on !IA64_SGI_SN2
 
+config NR_QUICK
+	int
+	default 1
+
 config MMU
 	bool
 	default y
Index: linux-2.6.21-rc3/mm/Kconfig
=================================--- linux-2.6.21-rc3.orig/mm/Kconfig	2007-03-10 11:34:00.000000000 -0800
+++ linux-2.6.21-rc3/mm/Kconfig	2007-03-10 12:55:15.000000000 -0800
@@ -163,3 +163,8 @@ config ZONE_DMA_FLAG
 	default "0" if !ZONE_DMA
 	default "1"
 
+config QUICKLIST
+	bool
+	default y if NR_QUICK != 0
+
+
