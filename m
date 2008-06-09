From: Russ Anderson <rja@sgi.com>
Date: Mon, 09 Jun 2008 21:58:01 +0000
Subject: [PATCH 2/3] mm: Avoid putting a bad page back on the LRU v7
Message-Id: <20080609215801.GC9039@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080502004248.GC12006@sgi.com>
In-Reply-To: <20080502004248.GC12006@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Tony Luck <tony.luck@intel.com>, Christoph Lameter <clameter@sgi.com>, Russ Anderson <rja@sgi.com>

Prevent a page with a physical memory error from being placed back
on the LRU.  A new page flag (PG_memerror) is added if
CONFIG_PAGEFLAGS_EXTENDED is defined.

Signed-off-by: Russ Anderson <rja@sgi.com>
Reviewed-by: Christoph Lameter <clameter@sgi.com>

---
 include/linux/page-flags.h |   18 ++++++++++++++++--
 mm/migrate.c               |   31 ++++++++++++++++++++++++++++++-
 mm/page_alloc.c            |   13 ++++++++-----
 3 files changed, 54 insertions(+), 8 deletions(-)

Index: linux-next/mm/page_alloc.c
=================================--- linux-next.orig/mm/page_alloc.c	2008-06-09 16:52:13.714381779 -0500
+++ linux-next/mm/page_alloc.c	2008-06-09 16:52:21.119299155 -0500
@@ -602,10 +602,10 @@ static int prep_new_page(struct page *pa
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
@@ -2476,8 +2476,11 @@ static void setup_zone_migrate_reserve(s
 			continue;
 		page = pfn_to_page(pfn);
 
-		/* Blocks with reserved pages will never free, skip them. */
-		if (PageReserved(page))
+		/*
+		 * Blocks with reserved pages or memory errors will never
+		 * free, skip them.
+		 */
+		if (PageReserved(page) || PageMemError(page))
 			continue;
 
 		block_migratetype = get_pageblock_migratetype(page);
Index: linux-next/mm/migrate.c
=================================--- linux-next.orig/mm/migrate.c	2008-06-09 13:46:32.892124708 -0500
+++ linux-next/mm/migrate.c	2008-06-09 16:52:21.147302624 -0500
@@ -720,7 +720,25 @@ unlock:
  		 * restored.
  		 */
  		list_del(&page->lru);
- 		move_to_lru(page);
+		if (PageMemError(page))
+			if (rc = 0)
+				/*
+				 * A page with a memory error that has
+				 * been migrated will not be moved to
+				 * the LRU.
+				 */
+				goto move_newpage;
+			else
+				/*
+				 * The page failed to migrate and will not
+				 * be added to the bad page list.  Clearing
+				 * the error bit will allow another attempt
+				 * to migrate if it gets another correctable
+				 * error.
+				 */
+				ClearPageMemError(page);
+
+		move_to_lru(page);
 	}
 
 move_newpage:
@@ -790,6 +808,17 @@ int migrate_pages(struct list_head *from
 			}
 		}
 	}
+
+	if (rc != 0)
+		list_for_each_entry_safe(page, page2, from, lru)
+			if (PageMemError(page))
+				/*
+				 * The page failed to migrate.  Clearing
+				 * the error bit will allow another attempt
+				 * to migrate if it gets another correctable
+				 * error.
+				 */
+				ClearPageMemError(page);
 	rc = 0;
 out:
 	if (!swapwrite)
Index: linux-next/include/linux/page-flags.h
=================================--- linux-next.orig/include/linux/page-flags.h	2008-06-09 16:52:13.746385743 -0500
+++ linux-next/include/linux/page-flags.h	2008-06-09 16:52:21.171305598 -0500
@@ -84,6 +84,7 @@ enum pageflags {
 	PG_private,		/* If pagecache, has fs-private data */
 	PG_writeback,		/* Page is under writeback */
 #ifdef CONFIG_PAGEFLAGS_EXTENDED
+	PG_memerror,		/* Page has a physical memory error */
 	PG_head,		/* A head page */
 	PG_tail,		/* A tail page */
 #else
@@ -132,15 +133,21 @@ static inline int TestSetPage##uname(str
 static inline int TestClearPage##uname(struct page *page)		\
 		{ return test_and_clear_bit(PG_##lname, &page->flags); }
 
+#define PAGEFLAGMASK(uname, lname)					\
+static inline int PAGEMASK_##uname(void)				\
+		{ return (1 << PG_##lname); }
 
 #define PAGEFLAG(uname, lname) TESTPAGEFLAG(uname, lname)		\
-	SETPAGEFLAG(uname, lname) CLEARPAGEFLAG(uname, lname)
+	SETPAGEFLAG(uname, lname) CLEARPAGEFLAG(uname, lname)		\
+	PAGEFLAGMASK(uname, lname)
 
 #define __PAGEFLAG(uname, lname) TESTPAGEFLAG(uname, lname)		\
 	__SETPAGEFLAG(uname, lname)  __CLEARPAGEFLAG(uname, lname)
 
 #define PAGEFLAG_FALSE(uname) 						\
 static inline int Page##uname(struct page *page) 			\
+			{ return 0; }					\
+static inline int PAGEMASK_##uname(void)				\
 			{ return 0; }
 
 #define TESTSCFLAG(uname, lname)					\
@@ -308,9 +315,16 @@ static inline void __ClearPageTail(struc
 
 #endif /* !PAGEFLAGS_EXTENDED */
 
+#ifdef CONFIG_PAGEFLAGS_EXTENDED
+PAGEFLAG(MemError, memerror)
+#else
+PAGEFLAG_FALSE(MemError)
+#endif
+
 #define PAGE_FLAGS	(1 << PG_lru   | 1 << PG_private   | 1 << PG_locked | \
 			 1 << PG_buddy | 1 << PG_writeback | \
-			 1 << PG_slab  | 1 << PG_swapcache | 1 << PG_active)
+			 1 << PG_slab  | 1 << PG_swapcache | 1 << PG_active) |\
+			 PAGEMASK_MemError()
 
 /*
  * Flags checked in bad_page().  Pages on the free list should not have
-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
