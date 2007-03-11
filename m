From: Christoph Lameter <clameter@sgi.com>
Date: Sun, 11 Mar 2007 02:09:49 +0000
Subject: [QUICKLIST 5/6] x86_64: Separate quicklist for pgds
Message-Id: <20070311020949.19905.48402.sendpatchset@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070311020923.19905.49260.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20070311020923.19905.49260.sendpatchset@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: ak@suse.com, mpm@selenic.com, linux-ia64@vger.kernel.org, holt@sgi.com, Christoph Lameter <clameter@sgi.com>

x86_64: Add quicklist for pgd.

A second quicklist is useful to separate out PGD handling. We can carry
the initialized pgds over to the next process needing them. This
avoids the zeroing of the pgds on free that we had to introduce
in the last patch.

Also clean up the pgd_list handling to use regular list macros.
There is no need anymore to avoid the lru field.

Move the add/removal of the pgds to the pgdlist into the
constructor / destructor. That way the implementation is
congruent with i386.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.21-rc3/arch/x86_64/Kconfig
=================================--- linux-2.6.21-rc3.orig/arch/x86_64/Kconfig	2007-03-10 14:00:52.000000000 -0800
+++ linux-2.6.21-rc3/arch/x86_64/Kconfig	2007-03-10 14:00:53.000000000 -0800
@@ -58,7 +58,7 @@
 
 config NR_QUICK
 	int
-	default 1
+	default 2
 
 config ISA
 	bool
Index: linux-2.6.21-rc3/arch/x86_64/mm/fault.c
=================================--- linux-2.6.21-rc3.orig/arch/x86_64/mm/fault.c	2007-03-10 14:00:29.000000000 -0800
+++ linux-2.6.21-rc3/arch/x86_64/mm/fault.c	2007-03-10 14:00:53.000000000 -0800
@@ -585,7 +585,7 @@
 }
 
 DEFINE_SPINLOCK(pgd_lock);
-struct page *pgd_list;
+LIST_HEAD(pgd_list);
 
 void vmalloc_sync_all(void)
 {
@@ -605,8 +605,7 @@
 			if (pgd_none(*pgd_ref))
 				continue;
 			spin_lock(&pgd_lock);
-			for (page = pgd_list; page;
-			     page = (struct page *)page->index) {
+			list_for_each_entry(page, &pgd_list, lru) {
 				pgd_t *pgd;
 				pgd = (pgd_t *)page_address(page) + pgd_index(address);
 				if (pgd_none(*pgd))
Index: linux-2.6.21-rc3/include/asm-x86_64/pgalloc.h
=================================--- linux-2.6.21-rc3.orig/include/asm-x86_64/pgalloc.h	2007-03-10 14:00:52.000000000 -0800
+++ linux-2.6.21-rc3/include/asm-x86_64/pgalloc.h	2007-03-10 14:00:53.000000000 -0800
@@ -7,6 +7,9 @@
 #include <linux/mm.h>
 #include <linux/quicklist.h>
 
+#define QUICK_PGD 0	/* We preserve special mappings over free */
+#define QUICK_PT 1	/* Other page table pages that are zero on free */
+
 #define pmd_populate_kernel(mm, pmd, pte) \
 		set_pmd(pmd, __pmd(_PAGE_TABLE | __pa(pte)))
 #define pud_populate(mm, pud, pmd) \
@@ -22,88 +25,77 @@
 static inline void pmd_free(pmd_t *pmd)
 {
 	BUG_ON((unsigned long)pmd & (PAGE_SIZE-1));
-	quicklist_free(0, NULL, pmd);
+	quicklist_free(QUICK_PT, NULL, pmd);
 }
 
 static inline pmd_t *pmd_alloc_one (struct mm_struct *mm, unsigned long addr)
 {
-	return (pmd_t *)quicklist_alloc(0, GFP_KERNEL|__GFP_REPEAT, NULL);
+	return (pmd_t *)quicklist_alloc(QUICK_PT, GFP_KERNEL|__GFP_REPEAT, NULL);
 }
 
 static inline pud_t *pud_alloc_one(struct mm_struct *mm, unsigned long addr)
 {
-	return (pud_t *)quicklist_alloc(0, GFP_KERNEL|__GFP_REPEAT, NULL);
+	return (pud_t *)quicklist_alloc(QUICK_PT, GFP_KERNEL|__GFP_REPEAT, NULL);
 }
 
 static inline void pud_free (pud_t *pud)
 {
 	BUG_ON((unsigned long)pud & (PAGE_SIZE-1));
-	quicklist_free(0, NULL, pud);
+	quicklist_free(QUICK_PT, NULL, pud);
 }
 
-static inline void pgd_list_add(pgd_t *pgd)
+static inline void pgd_ctor(void *x)
 {
+	unsigned boundary;
+	pgd_t *pgd = x;
 	struct page *page = virt_to_page(pgd);
 
+	/*
+	 * Copy kernel pointers in from init.
+	 */
+	boundary = pgd_index(__PAGE_OFFSET);
+	memcpy(pgd + boundary,
+		init_level4_pgt + boundary,
+		(PTRS_PER_PGD - boundary) * sizeof(pgd_t));
+
 	spin_lock(&pgd_lock);
-	page->index = (pgoff_t)pgd_list;
-	if (pgd_list)
-		pgd_list->private = (unsigned long)&page->index;
-	pgd_list = page;
-	page->private = (unsigned long)&pgd_list;
+	list_add(&page->lru, &pgd_list);
 	spin_unlock(&pgd_lock);
 }
 
-static inline void pgd_list_del(pgd_t *pgd)
+static inline void pgd_dtor(void *x)
 {
-	struct page *next, **pprev, *page = virt_to_page(pgd);
+	pgd_t *pgd = x;
+	struct page *page = virt_to_page(pgd);
 
 	spin_lock(&pgd_lock);
-	next = (struct page *)page->index;
-	pprev = (struct page **)page->private;
-	*pprev = next;
-	if (next)
-		next->private = (unsigned long)pprev;
+	list_del(&page->lru);
 	spin_unlock(&pgd_lock);
 }
 
+
 static inline pgd_t *pgd_alloc(struct mm_struct *mm)
 {
-	unsigned boundary;
-	pgd_t *pgd = (pgd_t *)quicklist_alloc(0, GFP_KERNEL|__GFP_REPEAT, NULL);
-	if (!pgd)
-		return NULL;
+	pgd_t *pgd = (pgd_t *)quicklist_alloc(QUICK_PGD,
+			 GFP_KERNEL|__GFP_REPEAT, pgd_ctor);
 
-	pgd_list_add(pgd);
-	/*
-	 * Copy kernel pointers in from init.
-	 * Could keep a freelist or slab cache of those because the kernel
-	 * part never changes.
-	 */
-	boundary = pgd_index(__PAGE_OFFSET);
-	memset(pgd, 0, boundary * sizeof(pgd_t));
-	memcpy(pgd + boundary,
-	       init_level4_pgt + boundary,
-	       (PTRS_PER_PGD - boundary) * sizeof(pgd_t));
 	return pgd;
 }
 
 static inline void pgd_free(pgd_t *pgd)
 {
 	BUG_ON((unsigned long)pgd & (PAGE_SIZE-1));
-	pgd_list_del(pgd);
-	memset(pgd, 0, PAGE_SIZE);
-	quicklist_free(0, NULL, pgd);
+	quicklist_free(QUICK_PGD, pgd_dtor, pgd);
 }
 
 static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address)
 {
-	return (pte_t *)quicklist_alloc(0, GFP_KERNEL|__GFP_REPEAT, NULL);
+	return (pte_t *)quicklist_alloc(QUICK_PT, GFP_KERNEL|__GFP_REPEAT, NULL);
 }
 
 static inline struct page *pte_alloc_one(struct mm_struct *mm, unsigned long address)
 {
-	void *p = (void *)quicklist_alloc(0, GFP_KERNEL|__GFP_REPEAT, NULL);
+	void *p = (void *)quicklist_alloc(QUICK_PT, GFP_KERNEL|__GFP_REPEAT, NULL);
 	if (!p)
 		return NULL;
 	return virt_to_page(p);
@@ -115,7 +107,7 @@
 static inline void pte_free_kernel(pte_t *pte)
 {
 	BUG_ON((unsigned long)pte & (PAGE_SIZE-1));
-	quicklist_free(0, NULL, pte);
+	quicklist_free(QUICK_PT, NULL, pte);
 }
 
 static inline void pte_free(struct page *pte)
@@ -130,6 +122,7 @@
 
 static inline void check_pgt_cache(void)
 {
-	quicklist_check(0, NULL);
+	quicklist_check(QUICK_PGD, pgd_dtor);
+	quicklist_check(QUICK_PT, NULL);
 }
 #endif /* _X86_64_PGALLOC_H */
Index: linux-2.6.21-rc3/include/asm-x86_64/pgtable.h
=================================--- linux-2.6.21-rc3.orig/include/asm-x86_64/pgtable.h	2007-03-10 14:00:29.000000000 -0800
+++ linux-2.6.21-rc3/include/asm-x86_64/pgtable.h	2007-03-10 14:02:18.000000000 -0800
@@ -403,7 +403,7 @@
 #define __swp_entry_to_pte(x)		((pte_t) { (x).val })
 
 extern spinlock_t pgd_lock;
-extern struct page *pgd_list;
+extern struct list_head pgd_list;
 void vmalloc_sync_all(void);
 
 #endif /* !__ASSEMBLY__ */
@@ -420,7 +420,6 @@
 #define HAVE_ARCH_UNMAPPED_AREA
 
 #define pgtable_cache_init()   do { } while (0)
-#define check_pgt_cache()      do { } while (0)
 
 #define PAGE_AGP    PAGE_KERNEL_NOCACHE
 #define HAVE_PAGE_AGP 1
