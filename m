From: Zi Yan <zi.yan@sent.com>
Date: Thu, 06 May 2021 15:26:20 +0000
Subject: [RFC PATCH 4/7] mm: pageblock: allow set/unset migratetype for partial pageblock
Message-Id: <20210506152623.178731-5-zi.yan@sent.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210506152623.178731-1-zi.yan@sent.com>
In-Reply-To: <20210506152623.178731-1-zi.yan@sent.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Hildenbrand <david@redhat.com>, Oscar Salvador <osalvador@suse.de>
Cc: Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Thomas Gleixner <tglx@linutronix.de>, x86@kernel.org, Andy Lutomirski <luto@kernel.org>, "Rafael J . Wysocki" <rafael@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@kernel.org>, Anshuman Khandual <anshuman.khandual@arm.com>, Michal Hocko <mhocko@suse.com>, Dan Williams <dan.j.williams@intel.com>, Wei Yang <richard.weiyang@linux.alibaba.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, Zi Yan <ziy@nvidia.com>

From: Zi Yan <ziy@nvidia.com>

When we online subsections and pageblock size is larger than
a subsection, we should be able to change migratetype for partial
pageblocks. We also change the assumption that all pageblocks are in
a whole.

Signed-off-by: Zi Yan <ziy@nvidia.com>
---
 include/linux/page-isolation.h |  8 ++++++--
 mm/page_alloc.c                | 27 ++++++++++++++++++---------
 mm/page_isolation.c            | 26 ++++++++++++++------------
 3 files changed, 38 insertions(+), 23 deletions(-)

diff --git a/include/linux/page-isolation.h b/include/linux/page-isolation.h
index 572458016331..308b540865b7 100644
--- a/include/linux/page-isolation.h
+++ b/include/linux/page-isolation.h
@@ -33,11 +33,15 @@ static inline bool is_migrate_isolate(int migratetype)
 #define MEMORY_OFFLINE	0x1
 #define REPORT_FAILURE	0x2
 
-struct page *has_unmovable_pages(struct zone *zone, struct page *page,
-				 int migratetype, int flags);
+struct page *has_unmovable_pages(struct zone *zone, unsigned long start_pfn,
+				 unsigned long end_pfn, int migratetype,
+				 int flags);
 void set_pageblock_migratetype(struct page *page, int migratetype);
 int move_freepages_block(struct zone *zone, struct page *page,
 				int migratetype, int *num_movable);
+int move_freepages(struct zone *zone,
+			  unsigned long start_pfn, unsigned long end_pfn,
+			  int migratetype, int *num_movable);
 
 /*
  * Changes migrate type in [start_pfn, end_pfn) to be MIGRATE_ISOLATE.
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 72bb4a300e03..bc410f45c355 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2433,7 +2433,7 @@ static inline struct page *__rmqueue_cma_fallback(struct zone *zone,
  * Note that start_page and end_pages are not aligned on a pageblock
  * boundary. If alignment is required, use move_freepages_block()
  */
-static int move_freepages(struct zone *zone,
+int move_freepages(struct zone *zone,
 			  unsigned long start_pfn, unsigned long end_pfn,
 			  int migratetype, int *num_movable)
 {
@@ -6328,6 +6328,7 @@ void __meminit memmap_init_range(unsigned long size, int nid, unsigned long zone
 {
 	unsigned long pfn, end_pfn = start_pfn + size;
 	struct page *page;
+	bool set_migratetype = false;
 
 	if (highest_memmap_pfn < end_pfn - 1)
 		highest_memmap_pfn = end_pfn - 1;
@@ -6374,10 +6375,16 @@ void __meminit memmap_init_range(unsigned long size, int nid, unsigned long zone
 		 */
 		if (IS_ALIGNED(pfn, pageblock_nr_pages)) {
 			set_pageblock_migratetype(page, migratetype);
+			set_migratetype = true;
 			cond_resched();
 		}
 		pfn++;
 	}
+	/* in case the range is smaller than a pageblock */
+	if (!set_migratetype && context == MEMINIT_HOTPLUG) {
+		page = pfn_to_page(start_pfn);
+		set_pageblock_migratetype(page, migratetype);
+	}
 }
 
 #ifdef CONFIG_ZONE_DEVICE
@@ -8524,12 +8531,14 @@ void *__init alloc_large_system_hash(const char *tablename,
  * cannot get removed (e.g., via memory unplug) concurrently.
  *
  */
-struct page *has_unmovable_pages(struct zone *zone, struct page *page,
-				 int migratetype, int flags)
+struct page *has_unmovable_pages(struct zone *zone, unsigned long start_pfn,
+				 unsigned long end_pfn, int migratetype,
+				 int flags)
 {
 	unsigned long iter = 0;
-	unsigned long pfn = page_to_pfn(page);
-	unsigned long offset = pfn % pageblock_nr_pages;
+	unsigned long pfn = start_pfn;
+	struct page *page = pfn_to_page(pfn);
+
 
 	if (is_migrate_cma_page(page)) {
 		/*
@@ -8543,11 +8552,11 @@ struct page *has_unmovable_pages(struct zone *zone, struct page *page,
 		return page;
 	}
 
-	for (; iter < pageblock_nr_pages - offset; iter++) {
-		if (!pfn_valid_within(pfn + iter))
+	for (pfn = start_pfn; pfn < end_pfn; pfn++) {
+		if (!pfn_valid_within(pfn))
 			continue;
 
-		page = pfn_to_page(pfn + iter);
+		page = pfn_to_page(pfn);
 
 		/*
 		 * Both, bootmem allocations and memory holes are marked
@@ -8596,7 +8605,7 @@ struct page *has_unmovable_pages(struct zone *zone, struct page *page,
 		 */
 		if (!page_ref_count(page)) {
 			if (PageBuddy(page))
-				iter += (1 << buddy_order(page)) - 1;
+				pfn += (1 << buddy_order(page)) - 1;
 			continue;
 		}
 
diff --git a/mm/page_isolation.c b/mm/page_isolation.c
index bddf788f45bf..c1b9b8848382 100644
--- a/mm/page_isolation.c
+++ b/mm/page_isolation.c
@@ -15,8 +15,10 @@
 #define CREATE_TRACE_POINTS
 #include <trace/events/page_isolation.h>
 
-static int set_migratetype_isolate(struct page *page, int migratetype, int isol_flags)
+static int set_migratetype_isolate(unsigned long start_pfn, unsigned long end_pfn,
+				   int migratetype, int isol_flags)
 {
+	struct page *page = pfn_to_page(start_pfn);
 	struct zone *zone = page_zone(page);
 	struct page *unmovable;
 	unsigned long flags;
@@ -37,15 +39,14 @@ static int set_migratetype_isolate(struct page *page, int migratetype, int isol_
 	 * FIXME: Now, memory hotplug doesn't call shrink_slab() by itself.
 	 * We just check MOVABLE pages.
 	 */
-	unmovable = has_unmovable_pages(zone, page, migratetype, isol_flags);
+	unmovable = has_unmovable_pages(zone, start_pfn, end_pfn, migratetype, isol_flags);
 	if (!unmovable) {
 		unsigned long nr_pages;
 		int mt = get_pageblock_migratetype(page);
 
 		set_pageblock_migratetype(page, MIGRATE_ISOLATE);
 		zone->nr_isolate_pageblock++;
-		nr_pages = move_freepages_block(zone, page, MIGRATE_ISOLATE,
-									NULL);
+		nr_pages = move_freepages(zone, start_pfn, end_pfn, MIGRATE_ISOLATE, NULL);
 
 		__mod_zone_freepage_state(zone, -nr_pages, mt);
 		spin_unlock_irqrestore(&zone->lock, flags);
@@ -64,7 +65,8 @@ static int set_migratetype_isolate(struct page *page, int migratetype, int isol_
 	return -EBUSY;
 }
 
-static void unset_migratetype_isolate(struct page *page, unsigned migratetype)
+static void unset_migratetype_isolate(unsigned long start_pfn, unsigned long end_pfn,
+				unsigned migratetype)
 {
 	struct zone *zone;
 	unsigned long flags, nr_pages;
@@ -72,6 +74,7 @@ static void unset_migratetype_isolate(struct page *page, unsigned migratetype)
 	unsigned int order;
 	unsigned long pfn, buddy_pfn;
 	struct page *buddy;
+	struct page *page = pfn_to_page(start_pfn);
 
 	zone = page_zone(page);
 	spin_lock_irqsave(&zone->lock, flags);
@@ -112,7 +115,7 @@ static void unset_migratetype_isolate(struct page *page, unsigned migratetype)
 	 * allocation.
 	 */
 	if (!isolated_page) {
-		nr_pages = move_freepages_block(zone, page, migratetype, NULL);
+		nr_pages = move_freepages(zone, start_pfn, end_pfn, migratetype, NULL);
 		__mod_zone_freepage_state(zone, nr_pages, migratetype);
 	}
 	set_pageblock_migratetype(page, migratetype);
@@ -195,7 +198,8 @@ int start_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
 	     pfn += pageblock_nr_pages) {
 		page = __first_valid_page(pfn, pageblock_nr_pages);
 		if (page) {
-			if (set_migratetype_isolate(page, migratetype, flags)) {
+			if (set_migratetype_isolate(pfn, min(end_pfn, pfn + pageblock_nr_pages),
+				migratetype, flags)) {
 				undo_pfn = pfn;
 				goto undo;
 			}
@@ -209,7 +213,8 @@ int start_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
 		struct page *page = pfn_to_online_page(pfn);
 		if (!page)
 			continue;
-		unset_migratetype_isolate(page, migratetype);
+		unset_migratetype_isolate(pfn, min(pfn + pageblock_nr_pages, undo_pfn),
+					migratetype);
 	}
 
 	return -EBUSY;
@@ -224,16 +229,13 @@ void undo_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
 	unsigned long pfn;
 	struct page *page;
 
-	BUG_ON(!IS_ALIGNED(start_pfn, pageblock_nr_pages));
-	BUG_ON(!IS_ALIGNED(end_pfn, pageblock_nr_pages));
-
 	for (pfn = start_pfn;
 	     pfn < end_pfn;
 	     pfn += pageblock_nr_pages) {
 		page = __first_valid_page(pfn, pageblock_nr_pages);
 		if (!page || !is_migrate_isolate_page(page))
 			continue;
-		unset_migratetype_isolate(page, migratetype);
+		unset_migratetype_isolate(pfn, min(pfn + pageblock_nr_pages, end_pfn), migratetype);
 	}
 }
 /*
-- 
2.30.2
