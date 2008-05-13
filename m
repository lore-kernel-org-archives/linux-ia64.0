From: Russ Anderson <rja@sgi.com>
Date: Tue, 13 May 2008 23:02:20 +0000
Subject: [PATCH 1/3] mm: Minor clean-up of page flags in mm/page_alloc.c v4
Message-Id: <20080513230220.GB26722@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080502004155.GB12006@sgi.com>
In-Reply-To: <20080502004155.GB12006@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Tony Luck <tony.luck@intel.com>, Christoph Lameter <clameter@sgi.com>, Russ Anderson <rja@sgi.com>

Minor source code cleanup of page flags in mm/page_alloc.c.  
There is no functional change.

Signed-off-by: Russ Anderson <rja@sgi.com>

---
 include/linux/page-flags.h |    9 +++++++++
 mm/page_alloc.c            |   34 +++-------------------------------
 2 files changed, 12 insertions(+), 31 deletions(-)

Index: linus/mm/page_alloc.c
=================================--- linus.orig/mm/page_alloc.c	2008-05-12 14:23:07.711484337 -0500
+++ linus/mm/page_alloc.c	2008-05-13 10:26:46.513459253 -0500
@@ -237,16 +237,7 @@ static void bad_page(struct page *page)
 	printk(KERN_EMERG "Trying to fix it up, but a reboot is needed\n"
 		KERN_EMERG "Backtrace:\n");
 	dump_stack();
-	page->flags &= ~(1 << PG_lru	|
-			1 << PG_private |
-			1 << PG_locked	|
-			1 << PG_active	|
-			1 << PG_dirty	|
-			1 << PG_reclaim |
-			1 << PG_slab    |
-			1 << PG_swapcache |
-			1 << PG_writeback |
-			1 << PG_buddy );
+	page->flags &= ~(PAGE_FLAGS_RECLAIM);
 	set_page_count(page, 0);
 	reset_page_mapcount(page);
 	page->mapping = NULL;
@@ -463,16 +454,7 @@ static inline int free_pages_check(struc
 		(page->mapping != NULL)  |
 		(page_get_page_cgroup(page) != NULL) |
 		(page_count(page) != 0)  |
-		(page->flags & (
-			1 << PG_lru	|
-			1 << PG_private |
-			1 << PG_locked	|
-			1 << PG_active	|
-			1 << PG_slab	|
-			1 << PG_swapcache |
-			1 << PG_writeback |
-			1 << PG_reserved |
-			1 << PG_buddy ))))
+		(page->flags & (PAGE_FLAGS_RESERVE))))
 		bad_page(page);
 	if (PageDirty(page))
 		__ClearPageDirty(page);
@@ -616,17 +598,7 @@ static int prep_new_page(struct page *pa
 		(page->mapping != NULL)  |
 		(page_get_page_cgroup(page) != NULL) |
 		(page_count(page) != 0)  |
-		(page->flags & (
-			1 << PG_lru	|
-			1 << PG_private	|
-			1 << PG_locked	|
-			1 << PG_active	|
-			1 << PG_dirty	|
-			1 << PG_slab    |
-			1 << PG_swapcache |
-			1 << PG_writeback |
-			1 << PG_reserved |
-			1 << PG_buddy ))))
+		(page->flags & (PAGE_FLAGS_DIRTY))))
 		bad_page(page);
 
 	/*
Index: linus/include/linux/page-flags.h
=================================--- linus.orig/include/linux/page-flags.h	2008-05-12 14:23:07.711484337 -0500
+++ linus/include/linux/page-flags.h	2008-05-13 10:26:46.513459253 -0500
@@ -306,5 +306,14 @@ static inline void __ClearPageTail(struc
 }
 
 #endif /* !PAGEFLAGS_EXTENDED */
+
+#define PAGE_FLAGS	(1 << PG_lru   | 1 << PG_private   | 1 << PG_locked | \
+			 1 << PG_buddy | 1 << PG_writeback | \
+			 1 << PG_slab  | 1 << PG_swapcache | 1 << PG_active)
+
+#define PAGE_FLAGS_RECLAIM	(PAGE_FLAGS | 1 << PG_reclaim | 1 << PG_dirty)
+#define PAGE_FLAGS_RESERVE	(PAGE_FLAGS | 1 << PG_reserved)
+#define PAGE_FLAGS_DIRTY	(PAGE_FLAGS | 1 << PG_reserved | 1 << PG_dirty)
+
 #endif /* !__GENERATING_BOUNDS_H */
 #endif	/* PAGE_FLAGS_H */
-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
