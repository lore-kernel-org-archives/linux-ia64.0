From: Russ Anderson <rja@sgi.com>
Date: Fri, 02 May 2008 00:41:55 +0000
Subject: [PATCH 1/3] mm: Minor clean-up of page flags in mm/page_alloc.c
Message-Id: <20080502004155.GB12006@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Tony Luck <tony.luck@intel.com>, Christoph Lameter <clameter@sgi.com>, Russ Anderson <rja@sgi.com>

Minor source code cleanup of page flags in mm/page_alloc.c.  
There is no functional change.

Signed-off-by: Russ Anderson <rja@sgi.com>

---
 include/linux/mm.h |    8 ++++++++
 mm/page_alloc.c    |   34 +++-------------------------------
 2 files changed, 11 insertions(+), 31 deletions(-)

Index: linus/mm/page_alloc.c
=================================--- linus.orig/mm/page_alloc.c	2008-05-01 19:05:35.000000000 -0500
+++ linus/mm/page_alloc.c	2008-05-01 19:06:04.000000000 -0500
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
Index: linus/include/linux/mm.h
=================================--- linus.orig/include/linux/mm.h	2008-05-01 19:05:34.000000000 -0500
+++ linus/include/linux/mm.h	2008-05-01 19:06:04.000000000 -0500
@@ -210,6 +210,14 @@ struct inode;
  */
 #include <linux/page-flags.h>
 
+#define PAGE_FLAGS	(1 << PG_lru   | 1 << PG_private   | 1 << PG_locked | \
+			 1 << PG_buddy | 1 << PG_writeback | \
+			 1 << PG_slab  | 1 << PG_swapcache | 1 << PG_active)
+
+#define PAGE_FLAGS_RECLAIM      (PAGE_FLAGS | 1 << PG_reclaim | 1 << PG_dirty)
+#define PAGE_FLAGS_RESERVE	(PAGE_FLAGS | 1 << PG_reserved)
+#define PAGE_FLAGS_DIRTY	(PAGE_FLAGS | 1 << PG_reserved | 1 << PG_dirty)
+
 #ifdef CONFIG_DEBUG_VM
 #define VM_BUG_ON(cond) BUG_ON(cond)
 #else
-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
