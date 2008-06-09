From: Russ Anderson <rja@sgi.com>
Date: Mon, 09 Jun 2008 16:19:34 +0000
Subject: [PATCH 2/3] mm: Avoid putting a bad page back on the LRU v6
Message-Id: <20080609161933.GC14939@sgi.com>
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

If the migration of data off the old page fails, PG_memerror is
cleared and the page placed back on the LRU.  If the page gets
another correctable error another attempt will be made to
migrate it.


Signed-off-by: Russ Anderson <rja@sgi.com>

---
 include/linux/page-flags.h |   11 ++++++++++-
 mm/migrate.c               |   31 ++++++++++++++++++++++++++++++-
 mm/page_alloc.c            |   13 ++++++++-----
 3 files changed, 48 insertions(+), 7 deletions(-)

Index: linux-next/mm/page_alloc.c
=================================--- linux-next.orig/mm/page_alloc.c	2008-06-09 09:26:52.203578218 -0500
+++ linux-next/mm/page_alloc.c	2008-06-09 09:26:54.715891226 -0500
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
=================================--- linux-next.orig/mm/migrate.c	2008-06-09 09:26:46.226833574 -0500
+++ linux-next/mm/migrate.c	2008-06-09 09:26:54.739894217 -0500
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
=================================--- linux-next.orig/include/linux/page-flags.h	2008-06-09 09:26:52.223580710 -0500
+++ linux-next/include/linux/page-flags.h	2008-06-09 09:26:54.763897207 -0500
@@ -84,6 +84,7 @@ enum pageflags {
 	PG_private,		/* If pagecache, has fs-private data */
 	PG_writeback,		/* Page is under writeback */
 #ifdef CONFIG_PAGEFLAGS_EXTENDED
+	PG_memerror,		/* Page has a physical memory error */
 	PG_head,		/* A head page */
 	PG_tail,		/* A tail page */
 #else
@@ -308,9 +309,17 @@ static inline void __ClearPageTail(struc
 
 #endif /* !PAGEFLAGS_EXTENDED */
 
-#define PAGE_FLAGS	(1 << PG_lru   | 1 << PG_private   | 1 << PG_locked | \
+#define PAGE_FLAGS_BASE	(1 << PG_lru   | 1 << PG_private   | 1 << PG_locked | \
 			 1 << PG_buddy | 1 << PG_writeback | \
 			 1 << PG_slab  | 1 << PG_swapcache | 1 << PG_active)
+
+#ifdef CONFIG_PAGEFLAGS_EXTENDED
+PAGEFLAG(MemError, memerror)
+#define	PAGE_FLAGS	(PAGE_FLAGS_BASE | 1UL << PG_memerror)
+#else
+PAGEFLAG_FALSE(MemError)
+#define	PAGE_FLAGS	(PAGE_FLAGS_BASE)
+#endif
 
 /*
  * Flags checked in bad_page().  Pages on the free list should not have
-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
