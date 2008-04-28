From: Russ Anderson <rja@sgi.com>
Date: Mon, 28 Apr 2008 19:23:58 +0000
Subject: [PATCH 1/2] mm: Avoid putting a bad page back on the LRU
Message-Id: <20080428192358.GB14629@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Tony Luck <tony.luck@intel.com>, Christoph Lameter <clameter@sgi.com>, Russ Anderson <rja@sgi.com>

Prevent a page with a physical memory error from being placed back
on the LRU.  A new page flag bit is added.  PG_memerror is given
bit 32 and is only defined on 64 bit architectures.  This avoids
burning a page flag bit on 32 bit architectures.  "BadPages:" is
added to the output of /proc/meminfo to display the amount of memory 
marked bad (on 64 bit architectures).

Signed-off-by: Russ Anderson <rja@sgi.com>

---
 fs/proc/proc_misc.c        |    6 ++++++
 include/linux/kernel.h     |    1 +
 include/linux/page-flags.h |   23 +++++++++++++++++++++++
 include/linux/swap.h       |    1 +
 mm/migrate.c               |    3 +++
 mm/page_alloc.c            |   45 +++++++++++----------------------------------
 mm/swap.c                  |    4 ++++
 7 files changed, 49 insertions(+), 34 deletions(-)

Index: test/mm/swap.c
=================================--- test.orig/mm/swap.c	2008-04-25 15:22:11.204934760 -0500
+++ test/mm/swap.c	2008-04-25 15:42:02.806263586 -0500
@@ -208,6 +208,8 @@ void lru_cache_add(struct page *page)
 	struct pagevec *pvec = &get_cpu_var(lru_add_pvecs);
 
 	page_cache_get(page);
+	if (unlikely(PageMemError(page)))
+		return;		/* Don't add bad pages to the page list */
 	if (!pagevec_add(pvec, page))
 		__pagevec_lru_add(pvec);
 	put_cpu_var(lru_add_pvecs);
@@ -218,6 +220,8 @@ void lru_cache_add_active(struct page *p
 	struct pagevec *pvec = &get_cpu_var(lru_add_active_pvecs);
 
 	page_cache_get(page);
+	if (unlikely(PageMemError(page)))
+		return;		/* Don't add bad pages to the page list */
 	if (!pagevec_add(pvec, page))
 		__pagevec_lru_add_active(pvec);
 	put_cpu_var(lru_add_active_pvecs);
Index: test/mm/page_alloc.c
=================================--- test.orig/mm/page_alloc.c	2008-04-25 15:22:11.196933787 -0500
+++ test/mm/page_alloc.c	2008-04-25 15:42:02.818265056 -0500
@@ -70,6 +70,7 @@ unsigned long totalram_pages __read_most
 unsigned long totalreserve_pages __read_mostly;
 long nr_swap_pages;
 int percpu_pagelist_fraction;
+unsigned int totalbad_pages;
 
 #ifdef CONFIG_HUGETLB_PAGE_SIZE_VARIABLE
 int pageblock_order __read_mostly;
@@ -236,16 +237,7 @@ static void bad_page(struct page *page)
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
@@ -462,16 +454,7 @@ static inline int free_pages_check(struc
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
@@ -612,24 +595,14 @@ static int prep_new_page(struct page *pa
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
-	 * For now, we report if PG_reserved was found set, but do not
-	 * clear it, and do not allocate the page: as a safety net.
+	 * For now, we report if PG_reserved or PG_memerror was found set, but
+	 * do not clear it, and do not allocate the page: as a safety net.
 	 */
-	if (PageReserved(page))
+	if (PageReserved(page) || PageMemError(page))
 		return 1;
 
 	page->flags &= ~(1 << PG_uptodate | 1 << PG_error | 1 << PG_readahead |
@@ -1762,6 +1735,7 @@ void si_meminfo(struct sysinfo *val)
 	val->totalhigh = totalhigh_pages;
 	val->freehigh = nr_free_highpages();
 	val->mem_unit = PAGE_SIZE;
+	val->badpages = totalbad_pages;
 }
 
 EXPORT_SYMBOL(si_meminfo);
@@ -2478,6 +2452,9 @@ static void setup_zone_migrate_reserve(s
 
 		/* Blocks with reserved pages will never free, skip them. */
 		if (PageReserved(page))
+			continue;
+		/* Blocks with error pages will never free, skip them. */
+		if (PageMemError(page))
 			continue;
 
 		block_migratetype = get_pageblock_migratetype(page);
Index: test/include/linux/kernel.h
=================================--- test.orig/include/linux/kernel.h	2008-04-25 15:22:07.640501421 -0500
+++ test/include/linux/kernel.h	2008-04-25 15:42:02.826266036 -0500
@@ -412,6 +412,7 @@ struct sysinfo {
 	unsigned long totalhigh;	/* Total high memory size */
 	unsigned long freehigh;		/* Available high memory size */
 	unsigned int mem_unit;		/* Memory unit size in bytes */
+	unsigned int badpages;		/* Number of bad (PG_memerror) pages */
 	char _f[20-2*sizeof(long)-sizeof(int)];	/* Padding: libc5 uses this.. */
 };
 
Index: test/include/linux/swap.h
=================================--- test.orig/include/linux/swap.h	2008-04-25 15:22:08.040550056 -0500
+++ test/include/linux/swap.h	2008-04-25 15:42:02.854269468 -0500
@@ -165,6 +165,7 @@ extern unsigned long totalreserve_pages;
 extern long nr_swap_pages;
 extern unsigned int nr_free_buffer_pages(void);
 extern unsigned int nr_free_pagecache_pages(void);
+extern unsigned int totalbad_pages;
 
 /* Definition of global_page_state not available yet */
 #define nr_free_pages() global_page_state(NR_FREE_PAGES)
Index: test/mm/migrate.c
=================================--- test.orig/mm/migrate.c	2008-04-25 15:22:11.192933300 -0500
+++ test/mm/migrate.c	2008-04-28 13:27:48.686601486 -0500
@@ -368,6 +368,7 @@ static void migrate_page_copy(struct pag
 {
 	copy_highpage(newpage, page);
 
+	/* Do not migrate PG_memerror to the new page */
 	if (PageError(page))
 		SetPageError(newpage);
 	if (PageReferenced(page))
@@ -714,6 +715,8 @@ unlock:
  		 */
  		list_del(&page->lru);
  		move_to_lru(page);
+		if (PageMemError(page))
+			totalbad_pages++;
 	}
 
 move_newpage:
Index: test/fs/proc/proc_misc.c
=================================--- test.orig/fs/proc/proc_misc.c	2008-04-25 15:22:04.684142013 -0500
+++ test/fs/proc/proc_misc.c	2008-04-25 15:42:02.890273879 -0500
@@ -179,6 +179,9 @@ static int meminfo_read_proc(char *page,
 		"PageTables:   %8lu kB\n"
 		"NFS_Unstable: %8lu kB\n"
 		"Bounce:       %8lu kB\n"
+#if (BITS_PER_LONG > 32)
+		"BadPages:     %8u kB\n"
+#endif
 		"CommitLimit:  %8lu kB\n"
 		"Committed_AS: %8lu kB\n"
 		"VmallocTotal: %8lu kB\n"
@@ -210,6 +213,9 @@ static int meminfo_read_proc(char *page,
 		K(global_page_state(NR_PAGETABLE)),
 		K(global_page_state(NR_UNSTABLE_NFS)),
 		K(global_page_state(NR_BOUNCE)),
+#if (BITS_PER_LONG > 32)
+		K(i.badpages),
+#endif
 		K(allowed),
 		K(committed),
 		(unsigned long)VMALLOC_TOTAL >> 10,
Index: test/include/linux/page-flags.h
=================================--- test.orig/include/linux/page-flags.h	2008-04-25 15:22:07.868529143 -0500
+++ test/include/linux/page-flags.h	2008-04-25 15:42:02.914276820 -0500
@@ -48,6 +48,9 @@
  * PG_buddy is set to indicate that the page is free and in the buddy system
  * (see mm/page_alloc.c).
  *
+ * PG_memerror indicates a physical memory error on the page.  The page
+ * should not be reused (ie put on the LRU).
+ *
  */
 
 /*
@@ -106,6 +109,7 @@
  *         63                            32                              0
  */
 #define PG_uncached		31	/* Page has been mapped as uncached */
+#define PG_memerror		32	/* Page has a physical memory error */
 #endif
 
 /*
@@ -307,5 +311,24 @@ static inline void set_page_writeback(st
 {
 	test_set_page_writeback(page);
 }
+
+#if (BITS_PER_LONG > 32)
+#define PageMemError(page)	test_bit(PG_memerror, &(page)->flags)
+#define SetPageMemError(page)	set_bit(PG_memerror, &(page)->flags)
+#define ClearPageMemError(page)	clear_bit(PG_memerror, &(page)->flags)
+#define PAGE_FLAGS	(1 << PG_lru   | 1 << PG_private   | 1 << PG_locked | \
+			 1 << PG_buddy | 1 << PG_writeback | \
+			 1 << PG_slab  | 1 << PG_swapcache | 1 << PG_active | \
+			 1UL << PG_memerror)
+#else
+#define PageMemError(page)	0
+#define PAGE_FLAGS	(1 << PG_lru   | 1 << PG_private   | 1 << PG_locked | \
+			 1 << PG_buddy | 1 << PG_writeback | \
+			 1 << PG_slab  | 1 << PG_swapcache | 1 << PG_active)
+#endif
+#define PAGE_FLAGS_RECLAIM	(PAGE_FLAGS | 1 << PG_reclaim | 1 << PG_dirty)
+#define PAGE_FLAGS_RESERVE	(PAGE_FLAGS | 1 << PG_reserved)
+#define PAGE_FLAGS_DIRTY	(PAGE_FLAGS | 1 << PG_reserved | 1 << PG_dirty)
+
 
 #endif	/* PAGE_FLAGS_H */
-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
