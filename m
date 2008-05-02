From: Russ Anderson <rja@sgi.com>
Date: Fri, 02 May 2008 00:42:48 +0000
Subject: [PATCH 2/3] mm: Avoid putting a bad page back on the LRU v2
Message-Id: <20080502004248.GC12006@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Tony Luck <tony.luck@intel.com>, Christoph Lameter <clameter@sgi.com>, Russ Anderson <rja@sgi.com>

Prevent a page with a physical memory error from being placed back
on the LRU.  A new page flag (PG_memerror) is added on 64 bit
architectures.  

Signed-off-by: Russ Anderson <rja@sgi.com>

---
 include/linux/mm.h         |    8 +++++++-
 include/linux/page-flags.h |    8 ++++++++
 include/linux/swap.h       |    1 +
 mm/migrate.c               |    3 +++
 mm/page_alloc.c            |    9 +++++----
 mm/swap.c                  |    4 ++++
 6 files changed, 28 insertions(+), 5 deletions(-)

Index: linus/mm/page_alloc.c
=================================--- linus.orig/mm/page_alloc.c	2008-05-01 19:06:04.000000000 -0500
+++ linus/mm/page_alloc.c	2008-05-01 19:06:15.000000000 -0500
@@ -71,6 +71,7 @@ unsigned long totalram_pages __read_most
 unsigned long totalreserve_pages __read_mostly;
 long nr_swap_pages;
 int percpu_pagelist_fraction;
+unsigned int totalbad_pages;
 
 #ifdef CONFIG_HUGETLB_PAGE_SIZE_VARIABLE
 int pageblock_order __read_mostly;
@@ -602,10 +603,10 @@ static int prep_new_page(struct page *pa
 		bad_page(page);
 
 	/*
-	 * For now, we report if PG_reserved was found set, but do not
-	 * clear it, and do not allocate the page: as a safety net.
+	 * For now, we report if PG_reserved or PG_memerror was found set, but
+	 * do not clear it, and do not allocate the page: as a safety net.
 	 */
-	if (PageReserved(page))
+	if (PageReserved(page) || PageMemError(page))
 		return 1;
 
 	page->flags &= ~(1 << PG_uptodate | 1 << PG_error | 1 << PG_reclaim |
@@ -2474,7 +2475,7 @@ static void setup_zone_migrate_reserve(s
 		page = pfn_to_page(pfn);
 
 		/* Blocks with reserved pages will never free, skip them. */
-		if (PageReserved(page))
+		if (PageReserved(page) || PageMemError(page))
 			continue;
 
 		block_migratetype = get_pageblock_migratetype(page);
Index: linus/mm/swap.c
=================================--- linus.orig/mm/swap.c	2008-05-01 19:05:33.000000000 -0500
+++ linus/mm/swap.c	2008-05-01 19:06:15.000000000 -0500
@@ -195,6 +195,8 @@ void lru_cache_add(struct page *page)
 	struct pagevec *pvec = &get_cpu_var(lru_add_pvecs);
 
 	page_cache_get(page);
+	if (unlikely(PageMemError(page)))
+		return;		/* Don't add bad pages to the page list */
 	if (!pagevec_add(pvec, page))
 		__pagevec_lru_add(pvec);
 	put_cpu_var(lru_add_pvecs);
@@ -205,6 +207,8 @@ void lru_cache_add_active(struct page *p
 	struct pagevec *pvec = &get_cpu_var(lru_add_active_pvecs);
 
 	page_cache_get(page);
+	if (unlikely(PageMemError(page)))
+		return;		/* Don't add bad pages to the page list */
 	if (!pagevec_add(pvec, page))
 		__pagevec_lru_add_active(pvec);
 	put_cpu_var(lru_add_active_pvecs);
Index: linus/include/linux/swap.h
=================================--- linus.orig/include/linux/swap.h	2008-05-01 19:05:33.000000000 -0500
+++ linus/include/linux/swap.h	2008-05-01 19:06:15.000000000 -0500
@@ -165,6 +165,7 @@ extern unsigned long totalreserve_pages;
 extern long nr_swap_pages;
 extern unsigned int nr_free_buffer_pages(void);
 extern unsigned int nr_free_pagecache_pages(void);
+extern unsigned int totalbad_pages;
 
 /* Definition of global_page_state not available yet */
 #define nr_free_pages() global_page_state(NR_FREE_PAGES)
Index: linus/mm/migrate.c
=================================--- linus.orig/mm/migrate.c	2008-05-01 19:05:33.000000000 -0500
+++ linus/mm/migrate.c	2008-05-01 19:06:15.000000000 -0500
@@ -380,6 +380,7 @@ static void migrate_page_copy(struct pag
 		SetPageChecked(newpage);
 	if (PageMappedToDisk(page))
 		SetPageMappedToDisk(newpage);
+	/* Do not migrate PG_memerror to the new page */
 
 	if (PageDirty(page)) {
 		clear_page_dirty_for_io(page);
@@ -721,6 +722,8 @@ unlock:
  		 */
  		list_del(&page->lru);
  		move_to_lru(page);
+		if (PageMemError(page))
+			totalbad_pages++;
 	}
 
 move_newpage:
Index: linus/include/linux/page-flags.h
=================================--- linus.orig/include/linux/page-flags.h	2008-05-01 19:05:33.000000000 -0500
+++ linus/include/linux/page-flags.h	2008-05-01 19:06:15.000000000 -0500
@@ -84,6 +84,7 @@ enum pageflags {
 	PG_private,		/* If pagecache, has fs-private data */
 	PG_writeback,		/* Page is under writeback */
 #ifdef CONFIG_PAGEFLAGS_EXTENDED
+	PG_memerror,		/* Page has a physical memory error */
 	PG_head,		/* A head page */
 	PG_tail,		/* A tail page */
 #else
@@ -306,5 +307,12 @@ static inline void __ClearPageTail(struc
 }
 
 #endif /* !PAGEFLAGS_EXTENDED */
+
+#ifdef CONFIG_PAGEFLAGS_EXTENDED
+PAGEFLAG(MemError, memerror)
+#else
+#define PageMemError(page)	0
+#endif
+
 #endif /* !__GENERATING_BOUNDS_H */
 #endif	/* PAGE_FLAGS_H */
Index: linus/include/linux/mm.h
=================================--- linus.orig/include/linux/mm.h	2008-05-01 19:06:04.000000000 -0500
+++ linus/include/linux/mm.h	2008-05-01 19:06:15.000000000 -0500
@@ -210,9 +210,15 @@ struct inode;
  */
 #include <linux/page-flags.h>
 
-#define PAGE_FLAGS	(1 << PG_lru   | 1 << PG_private   | 1 << PG_locked | \
+#define PAGE_FLAGS_BASE	(1 << PG_lru   | 1 << PG_private   | 1 << PG_locked | \
 			 1 << PG_buddy | 1 << PG_writeback | \
 			 1 << PG_slab  | 1 << PG_swapcache | 1 << PG_active)
+
+#ifdef CONFIG_PAGEFLAGS_EXTENDED
+#define	PAGE_FLAGS	(PAGE_FLAGS_BASE | 1UL << PG_memerror)
+#else
+#define	PAGE_FLAGS	(PAGE_FLAGS_BASE)
+#endif
 
 #define PAGE_FLAGS_RECLAIM      (PAGE_FLAGS | 1 << PG_reclaim | 1 << PG_dirty)
 #define PAGE_FLAGS_RESERVE	(PAGE_FLAGS | 1 << PG_reserved)
-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
