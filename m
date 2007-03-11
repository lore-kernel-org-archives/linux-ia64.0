From: Christoph Lameter <clameter@sgi.com>
Date: Sun, 11 Mar 2007 02:09:39 +0000
Subject: [QUICKLIST 3/6] i386: Use standard list manipulators for pgd_list
Message-Id: <20070311020939.19905.15885.sendpatchset@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070311020923.19905.49260.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20070311020923.19905.49260.sendpatchset@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: ak@suse.com, mpm@selenic.com, linux-ia64@vger.kernel.org, holt@sgi.com, Christoph Lameter <clameter@sgi.com>

i386: Use standard list macros.

Get rid of generating a list via page->index and page->private. Use
page->lru instead.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.21-rc3/arch/i386/mm/pgtable.c
=================================--- linux-2.6.21-rc3.orig/arch/i386/mm/pgtable.c	2007-03-10 17:42:08.000000000 -0800
+++ linux-2.6.21-rc3/arch/i386/mm/pgtable.c	2007-03-10 17:44:23.000000000 -0800
@@ -213,31 +213,12 @@ struct page *pte_alloc_one(struct mm_str
  * -- wli
  */
 DEFINE_SPINLOCK(pgd_lock);
-struct page *pgd_list;
-
-static inline void pgd_list_add(pgd_t *pgd)
-{
-	struct page *page = virt_to_page(pgd);
-	page->index = (unsigned long)pgd_list;
-	if (pgd_list)
-		set_page_private(pgd_list, (unsigned long)&page->index);
-	pgd_list = page;
-	set_page_private(page, (unsigned long)&pgd_list);
-}
-
-static inline void pgd_list_del(pgd_t *pgd)
-{
-	struct page *next, **pprev, *page = virt_to_page(pgd);
-	next = (struct page *)page->index;
-	pprev = (struct page **)page_private(page);
-	*pprev = next;
-	if (next)
-		set_page_private(next, (unsigned long)pprev);
-}
+LIST_HEAD(pgd_list);
 
 void pgd_ctor(void *pgd)
 {
 	unsigned long flags;
+	struct page *page = virt_to_page(pgd);
 
 	if (PTRS_PER_PMD = 1) {
 		memset(pgd, 0, USER_PTRS_PER_PGD*sizeof(pgd_t));
@@ -256,7 +237,7 @@ void pgd_ctor(void *pgd)
 			__pa(swapper_pg_dir) >> PAGE_SHIFT,
 			USER_PTRS_PER_PGD, PTRS_PER_PGD - USER_PTRS_PER_PGD);
 
-	pgd_list_add(pgd);
+	list_add(&page->lru, &pgd_list);
 	spin_unlock_irqrestore(&pgd_lock, flags);
 }
 
@@ -264,10 +245,11 @@ void pgd_ctor(void *pgd)
 void pgd_dtor(void *pgd)
 {
 	unsigned long flags; /* can be called from interrupt context */
+	struct page *page = virt_to_page(pgd);
 
 	paravirt_release_pd(__pa(pgd) >> PAGE_SHIFT);
 	spin_lock_irqsave(&pgd_lock, flags);
-	pgd_list_del(pgd);
+	list_del(&page->lru);
 	spin_unlock_irqrestore(&pgd_lock, flags);
 }
 
Index: linux-2.6.21-rc3/include/asm-i386/pgtable.h
=================================--- linux-2.6.21-rc3.orig/include/asm-i386/pgtable.h	2007-03-10 17:41:48.000000000 -0800
+++ linux-2.6.21-rc3/include/asm-i386/pgtable.h	2007-03-10 17:42:00.000000000 -0800
@@ -39,7 +39,7 @@ extern pgd_t swapper_pg_dir[1024];
 void check_pgt_cache(void);
 
 extern spinlock_t pgd_lock;
-extern struct page *pgd_list;
+extern struct list_head pgd_list;
 static inline void pgtable_cache_init(void) {};
 void paging_init(void);
 
Index: linux-2.6.21-rc3/arch/i386/mm/fault.c
=================================--- linux-2.6.21-rc3.orig/arch/i386/mm/fault.c	2007-03-10 17:48:04.000000000 -0800
+++ linux-2.6.21-rc3/arch/i386/mm/fault.c	2007-03-10 17:49:30.000000000 -0800
@@ -608,11 +608,10 @@ void vmalloc_sync_all(void)
 			struct page *page;
 
 			spin_lock_irqsave(&pgd_lock, flags);
-			for (page = pgd_list; page; page -					(struct page *)page->index)
+			list_for_each_entry(page, &pgd_list, lru)
 				if (!vmalloc_sync_one(page_address(page),
 								address)) {
-					BUG_ON(page != pgd_list);
+					BUG();
 					break;
 				}
 			spin_unlock_irqrestore(&pgd_lock, flags);
Index: linux-2.6.21-rc3/arch/i386/mm/pageattr.c
=================================--- linux-2.6.21-rc3.orig/arch/i386/mm/pageattr.c	2007-03-10 17:49:44.000000000 -0800
+++ linux-2.6.21-rc3/arch/i386/mm/pageattr.c	2007-03-10 17:50:14.000000000 -0800
@@ -95,7 +95,7 @@ static void set_pmd_pte(pte_t *kpte, uns
 		return;
 
 	spin_lock_irqsave(&pgd_lock, flags);
-	for (page = pgd_list; page; page = (struct page *)page->index) {
+	list_for_each_entry(page, &pgd_list, lru) {
 		pgd_t *pgd;
 		pud_t *pud;
 		pmd_t *pmd;
