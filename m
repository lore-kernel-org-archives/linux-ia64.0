From: Christoph Lameter <clameter@sgi.com>
Date: Wed, 15 Dec 2004 02:34:13 +0000
Subject: [very very drafty] prezeroing to increase the page fault rate
Message-Id: <Pine.LNX.4.58.0412141832350.6975@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The page fault patches address the scalability of the fault handler
by aggregating requests (anticipatory prefaulting) or by reducing the locking
overhead (page fault scalability patches). However, the main time spend in
the page fault handler is by zeroing pages. The following patch
zeroes pages in the background through hardware (Altix Block Transfer Engine)
or via software when the system is idle. This increases the performance
of the page fault handler dramatically even for only a single thread:

2.6.10-rc3-bk7 (allocating 1 GB):

 Gb Rep Threads   User      System     Wall flt/cpu/s fault/wsec
  1   1    8    0.029s      1.373s   0.039s 46733.217 167449.984
  1   1    4    0.016s      1.152s   0.043s 56064.229 152067.012
  1   1    2    0.011s      1.074s   0.056s 60349.726 115679.719
  1   1    1    0.012s      0.708s   0.072s 90933.436  90849.200

with patch:

 Gb Rep Threads   User      System     Wall flt/cpu/s fault/wsec
  1   1    8    0.012s      0.759s   0.023s 84840.529 279197.309
  1   1    4    0.014s      0.307s   0.018s203360.588 354015.152
  1   1    2    0.021s      0.373s   0.023s166111.155 283594.162
  1   1    1    0.012s      0.200s   0.021s307839.729 306791.723

I have some spot results here that indicate that a single thread may
do up to 500000 faults a second with this patch alone.

The patches are not ready for prime time yet but I would like to get
some feedback on the approach taken. The patch will only work on IA64
for now and the BTE code is sometimes still doing funky things.

The patch introduces some new state information for pages on the free lists.
First, a zero bit to flag a page that has been zeroed. Second a lock
bit to lock the page during hardware or software zeroing.

This means also that a page may not always be able to be merged
or split by the buddy allocator. Thus page merging may have to be deferred
through a new "free_queue" in the zone structure.

The semantics for the list of free pages are also slightly changed. Zeroed
pages are always at the back of the list, unzeroed at the front. The system
may pick from the back or from the front depending on what type of page
is wanted. In order to use this mechanism all locations where a page
is acquired and then zeroed have been modified to use __GFP_ZERO
to request a zeroed page.

This also necessitates the introduction of a new queue in the pcp structure
for zeroed pages. Pages will be picked from that queue if the application
desires to have a zeroed page.

Hardware zeroing is started if pages are merged in the page
buddy allocator to an order greater than /proc/sys/vm/zero_order.

In the idle loop also a function idle_page_zero is called that picks
the highest order unzeroed page and zeroes it.

This typically results in almost all pages being zeroed at the end of the
bootup process. Any idle time may be used by the system to rezero
its memory and thus be able to speed up future memory allocation. It
will continually zero pages beyond a certain size if hardware support
is available.

Having memory zeroed also has a security aspect because information does
not linger for long in memory after the page that contains the information
has been deallocated.

In order to not negatively impact the system, page zeroing must be done in the
greatest chunks possible and possibly by hardware. The system always
selects the largest order for page to zero (and this necessitates the
introduction of the architecture specific function clear_pages()) in order
to have the highest efficiency. Zeroing pages may wipe out the processor
caches if not done by hardware.

The zeroing system typically discovers large chunks of unzeroed memory
and zeroes it during the startup phase of the system. Later typically
only smaller chunks of memory are processed.

Index: linux-2.6.9/arch/i386/kernel/process.c
=================================--- linux-2.6.9.orig/arch/i386/kernel/process.c	2004-12-13 11:18:42.000000000 -0800
+++ linux-2.6.9/arch/i386/kernel/process.c	2004-12-13 13:58:48.000000000 -0800
@@ -148,6 +148,10 @@
 	while (1) {
 		while (!need_resched()) {
 			void (*idle)(void);
+			void idle_page_zero(void);
+
+			idle_page_zero();
+
 			/*
 			 * Mark this as an RCU critical section so that
 			 * synchronize_kernel() in the unload path waits
Index: linux-2.6.9/include/linux/page-flags.h
=================================--- linux-2.6.9.orig/include/linux/page-flags.h	2004-10-18 14:54:39.000000000 -0700
+++ linux-2.6.9/include/linux/page-flags.h	2004-12-13 13:58:48.000000000 -0800
@@ -74,6 +74,7 @@
 #define PG_swapcache		16	/* Swap page: swp_entry_t in private */
 #define PG_mappedtodisk		17	/* Has blocks allocated on-disk */
 #define PG_reclaim		18	/* To be reclaimed asap */
+#define PG_zero			19	/* Page contains zeros (valid only on freelist) */


 /*
@@ -298,6 +299,11 @@
 #define PageSwapCache(page)	0
 #endif

+#define PageZero(page)		test_bit(PG_zero, &(page)->flags)
+#define SetPageZero(page)	set_bit(PG_zero, &(page)->flags)
+#define ClearPageZero(page)	clear_bit(PG_zero, &(page)->flags)
+#define TestClearPageZero(page)	test_and_clear_bit(PG_zero, &(page)->flags)
+
 struct page;	/* forward declaration */

 int test_clear_page_dirty(struct page *page);
Index: linux-2.6.9/arch/ia64/kernel/process.c
=================================--- linux-2.6.9.orig/arch/ia64/kernel/process.c	2004-12-10 12:42:27.000000000 -0800
+++ linux-2.6.9/arch/ia64/kernel/process.c	2004-12-13 13:58:48.000000000 -0800
@@ -238,7 +238,9 @@
 #endif
 		while (!need_resched()) {
 			void (*idle)(void);
+			void idle_page_zero(void);

+			idle_page_zero();
 			if (mark_idle)
 				(*mark_idle)(1);
 			/*
Index: linux-2.6.9/mm/page_alloc.c
=================================--- linux-2.6.9.orig/mm/page_alloc.c	2004-12-10 12:42:33.000000000 -0800
+++ linux-2.6.9/mm/page_alloc.c	2004-12-14 16:39:59.000000000 -0800
@@ -12,6 +12,7 @@
  *  Zone balancing, Kanoj Sarcar, SGI, Jan 2000
  *  Per cpu hot/cold page lists, bulk allocation, Martin J. Bligh, Sept 2002
  *          (lots of bits borrowed from Ingo Molnar & Andrew Morton)
+ *  Prezeroing of pages, Christoph Lameter, SGI, Dec 2004
  */

 #include <linux/config.h>
@@ -32,6 +33,7 @@
 #include <linux/sysctl.h>
 #include <linux/cpu.h>
 #include <linux/nodemask.h>
+#include <linux/zero.h>

 #include <asm/tlbflush.h>

@@ -43,6 +45,7 @@
 long nr_swap_pages;
 int numnodes = 1;
 int sysctl_lower_zone_protection = 0;
+unsigned int sysctl_zero_order = 5;

 EXPORT_SYMBOL(totalram_pages);
 EXPORT_SYMBOL(nr_swap_pages);
@@ -90,13 +93,32 @@
 			1 << PG_active	|
 			1 << PG_dirty	|
 			1 << PG_swapcache |
-			1 << PG_writeback);
+			1 << PG_writeback |
+			1 << PG_zero);
 	set_page_count(page, 0);
 	reset_page_mapcount(page);
 	page->mapping = NULL;
 	tainted |= TAINT_BAD_PAGE;
 }

+LIST_HEAD(init_zero);
+
+/*
+ * Attempt to zero a page via hardware support.
+ */
+int zero_page(struct free_area *area, struct page *p, int order)
+{
+	struct list_head *l;
+
+	list_for_each(l, &init_zero) {
+		struct zero_driver *d = list_entry(l, struct zero_driver, list);
+		if (d->start_bzero(p, order) = 0) {
+			return 1;
+		}
+	}
+	return 0;
+}
+
 #ifndef CONFIG_HUGETLB_PAGE
 #define prep_compound_page(page, order) do { } while (0)
 #define destroy_compound_page(page, order) do { } while (0)
@@ -179,6 +201,13 @@
  * -- wli
  */

+static inline void free_page_queue(struct zone *zone, struct page *p, int order)
+{
+	printk("free_page_queue: queuing page=%p order=%d\n", page_address(p), order);
+	p->index = order;
+	list_add_tail(&p->lru, &zone->free_queue);
+}
+
 static inline void __free_pages_bulk (struct page *page, struct page *base,
 		struct zone *zone, struct free_area *area, unsigned int order)
 {
@@ -192,7 +221,6 @@
 		BUG();
 	index = page_idx >> (1 + order);

-	zone->free_pages += 1 << order;
 	while (order < MAX_ORDER-1) {
 		struct page *buddy1, *buddy2;

@@ -208,14 +236,72 @@
 		buddy2 = base + page_idx;
 		BUG_ON(bad_range(zone, buddy1));
 		BUG_ON(bad_range(zone, buddy2));
+		if (unlikely(PageLocked(buddy1))) {
+
+			/* Restore the page map */
+			change_bit(index, area->map);
+
+			/*
+			 * Page is locked due to zeroing. Thus we cannot update the map.
+			 * Queue the page for later insertion and leave the buddy page alone
+			 */
+			printk(KERN_ERR "__free_pages_bulk: Locked buddy page %p\n", page_address(buddy1));
+			free_page_queue(zone, buddy2, order);
+			return;
+		}
 		list_del(&buddy1->lru);
+
+		if (unlikely(PageZero(buddy1) && PageZero(buddy2))) {
+			if (buddy1 < buddy2) {
+				SetPageZero(buddy1);
+				ClearPageZero(buddy2);
+			} else {
+				SetPageZero(buddy2);
+				ClearPageZero(buddy1);
+			}
+		} else {
+			ClearPageZero(buddy1);
+			ClearPageZero(buddy2);
+		}
+
 		mask <<= 1;
 		order++;
 		area++;
 		index >>= 1;
 		page_idx &= mask;
 	}
-	list_add(&(base + page_idx)->lru, &area->free_list);
+	if (PageZero(page) || (order > sysctl_zero_order && zero_page(area, page, order)))
+		list_add_tail(&(base + page_idx)->lru, &area->free_list);
+	else
+		list_add(&(base + page_idx)->lru, &area->free_list);
+}
+
+/*
+ * Called by __alloc_pages if memory gets tight to clear up the queue of pages
+ * not yet in the buddy allocator maps
+ */
+static void free_queue_free(struct zone *zone)
+{
+	unsigned long flags;
+	struct list_head *l, *n;
+
+	if (list_empty(&zone->free_queue))
+		return;
+
+	spin_lock_irqsave(&zone->lock, flags);
+	list_for_each_safe(l, n, &zone->free_queue) {
+		struct page *page = list_entry(l, struct page, lru);
+		int  order = page->index;
+
+		/* The page may still be in the process of being zeroed... */
+		if (!PageLocked(page)) {
+			printk(KERN_ERR "free_pages_bulk: freeing from free_queue %p. order=%ld\n", page_address(page), page->index);
+			list_del(&page->lru);
+			__free_pages_bulk(page, zone->zone_mem_map, zone,
+				zone->free_area + order, order);
+		}
+	}
+	spin_unlock_irqrestore(&zone->lock, flags);
 }

 static inline void free_pages_check(const char *function, struct page *page)
@@ -231,6 +317,7 @@
 			1 << PG_reclaim	|
 			1 << PG_slab	|
 			1 << PG_swapcache |
+			1 << PG_zero |
 			1 << PG_writeback )))
 		bad_page(function, page);
 	if (PageDirty(page))
@@ -266,6 +353,7 @@
 		page = list_entry(list->prev, struct page, lru);
 		/* have to delete it as __free_pages_bulk list manipulates */
 		list_del(&page->lru);
+		zone->free_pages += 1 << order;
 		__free_pages_bulk(page, base, zone, area, order);
 		ret++;
 	}
@@ -316,7 +404,16 @@
 		high--;
 		size >>= 1;
 		BUG_ON(bad_range(zone, &page[size]));
-		list_add(&page[size].lru, &area->free_list);
+		/*
+		 * If the main page was zeroed then the
+		 * split off page is also and must be added to the
+		 * end of the list
+		 */
+		if (PageZero(page)) {
+			SetPageZero(page + size);
+			list_add_tail(&page[size].lru, &area->free_list);
+		} else
+			list_add(&page[size].lru, &area->free_list);
 		MARK_USED(index + size, high, area);
 	}
 	return page;
@@ -341,7 +438,7 @@
 /*
  * This page is about to be returned from the page allocator
  */
-static void prep_new_page(struct page *page, int order)
+static void prep_new_page(struct page *page, int order, int zero)
 {
 	if (page->mapping || page_mapped(page) ||
 	    (page->flags & (
@@ -355,18 +452,35 @@
 			1 << PG_writeback )))
 		bad_page(__FUNCTION__, page);

+	if (zero) {
+		if (PageHighMem(page)) {
+			int n = 1 << order;
+
+			while (n--> 0)
+				clear_highpage(page + n);
+		} else
+		if (!PageZero(page))
+			clear_pages(page_address(page), order);
+	}
+
 	page->flags &= ~(1 << PG_uptodate | 1 << PG_error |
 			1 << PG_referenced | 1 << PG_arch_1 |
-			1 << PG_checked | 1 << PG_mappedtodisk);
+			1 << PG_checked | 1 << PG_mappedtodisk |
+			1 << PG_zero);
 	page->private = 0;
 	set_page_refs(page, order);
 }

+/* Ways of removing a page from a queue */
+#define ALLOC_FRONT 0
+#define ALLOC_BACK 1
+#define ALLOC_ZERO 2
+
 /*
  * Do the hard work of removing an element from the buddy allocator.
  * Call me with the zone->lock already held.
  */
-static struct page *__rmqueue(struct zone *zone, unsigned int order)
+static struct page *__rmqueue(struct zone *zone, unsigned int order, int mode)
 {
 	struct free_area * area;
 	unsigned int current_order;
@@ -378,7 +492,18 @@
 		if (list_empty(&area->free_list))
 			continue;

-		page = list_entry(area->free_list.next, struct page, lru);
+		page = list_entry(
+				mode != ALLOC_FRONT ? area->free_list.prev: area->free_list.next,
+				struct page,
+				lru);
+
+		if (PageLocked(page))
+			/* Order is being zeroed. Do not disturb */
+			continue;
+
+		if (mode = ALLOC_ZERO && !PageZero(page))
+			/* Must return zero page and there is no zero page available */
+			continue;
 		list_del(&page->lru);
 		index = page - zone->zone_mem_map;
 		if (current_order != MAX_ORDER-1)
@@ -396,7 +521,7 @@
  * Returns the number of new pages which were placed at *list.
  */
 static int rmqueue_bulk(struct zone *zone, unsigned int order,
-			unsigned long count, struct list_head *list)
+			unsigned long count, struct list_head *list, int mode)
 {
 	unsigned long flags;
 	int i;
@@ -405,7 +530,7 @@

 	spin_lock_irqsave(&zone->lock, flags);
 	for (i = 0; i < count; ++i) {
-		page = __rmqueue(zone, order);
+		page = __rmqueue(zone, order, mode);
 		if (page = NULL)
 			break;
 		allocated++;
@@ -546,7 +671,8 @@
 {
 	unsigned long flags;
 	struct page *page = NULL;
-	int cold = !!(gfp_flags & __GFP_COLD);
+	int mode = (gfp_flags & __GFP_ZERO) ? ALLOC_BACK : ALLOC_FRONT;
+	int cold = !!(gfp_flags & __GFP_COLD) + 2*mode;

 	if (order = 0) {
 		struct per_cpu_pages *pcp;
@@ -555,7 +681,7 @@
 		local_irq_save(flags);
 		if (pcp->count <= pcp->low)
 			pcp->count += rmqueue_bulk(zone, 0,
-						pcp->batch, &pcp->list);
+						pcp->batch, &pcp->list, mode * 2);
 		if (pcp->count) {
 			page = list_entry(pcp->list.next, struct page, lru);
 			list_del(&page->lru);
@@ -567,14 +693,14 @@

 	if (page = NULL) {
 		spin_lock_irqsave(&zone->lock, flags);
-		page = __rmqueue(zone, order);
+		page = __rmqueue(zone, order, mode);
 		spin_unlock_irqrestore(&zone->lock, flags);
 	}

 	if (page != NULL) {
 		BUG_ON(bad_range(zone, page));
 		mod_page_state_zone(zone, pgalloc, 1 << order);
-		prep_new_page(page, order);
+		prep_new_page(page, order, mode);
 		if (order && (gfp_flags & __GFP_COMP))
 			prep_compound_page(page, order);
 	}
@@ -693,6 +819,7 @@

 	/* go through the zonelist yet one more time */
 	for (i = 0; (z = zones[i]) != NULL; i++) {
+		free_queue_free(z);
 		min = z->pages_min;
 		if (gfp_mask & __GFP_HIGH)
 			min /= 2;
@@ -767,12 +894,9 @@
 	 */
 	BUG_ON(gfp_mask & __GFP_HIGHMEM);

-	page = alloc_pages(gfp_mask, 0);
-	if (page) {
-		void *address = page_address(page);
-		clear_page(address);
-		return (unsigned long) address;
-	}
+	page = alloc_pages(gfp_mask | __GFP_ZERO, 0);
+	if (page)
+		return (unsigned long) page_address(page);
 	return 0;
 }

@@ -1030,6 +1154,7 @@

 #define K(x) ((x) << (PAGE_SHIFT-10))

+const char *temp[3] = { "hot", "cold", "zero" };
 /*
  * Show free area list (used inside shift_scroll-lock stuff)
  * We also calculate the percentage fragmentation. We do this by counting the
@@ -1062,10 +1187,10 @@

 			pageset = zone->pageset + cpu;

-			for (temperature = 0; temperature < 2; temperature++)
+			for (temperature = 0; temperature < 3; temperature++)
 				printk("cpu %d %s: low %d, high %d, batch %d\n",
 					cpu,
-					temperature ? "cold" : "hot",
+					temp[temperature],
 					pageset->pcp[temperature].low,
 					pageset->pcp[temperature].high,
 					pageset->pcp[temperature].batch);
@@ -1150,6 +1275,75 @@
 }

 /*
+ * Idle page zero takes a page off the front of the freelist
+ * and then hands it off to block zeroing agents.
+ * The cleared pages are added to the back of
+ * the freelist where the page allocator may pick them up.
+ *
+ * Page zeroing only works in zone 0 in order to insure that a numa cpu
+ * only clears its own memory space (This is true for SGI Altix but
+ * maybe there are other situations ?? )
+ */
+
+
+void idle_page_zero(void)
+{
+	struct zone *z;
+	struct free_area *area;
+	unsigned long flags;
+
+	if (sysctl_zero_order >= MAX_ORDER || system_state != SYSTEM_RUNNING)
+		return;
+
+	z = NODE_DATA(numa_node_id())->node_zones + 0;
+
+	local_irq_save(flags);
+	if (!spin_trylock(&z->lock)) {
+		/*
+		 * We can easily defer this so if someone is already holding the lock
+		 * be nice to them and let them do what they have to do
+		 */
+		local_irq_restore(flags);
+		return;
+	}
+	/*
+	 * Find order where we could do something. We always begin the
+	 * scan at the top. Lower pages may coalesce into higher orders
+	 * whereupon they may loose the zero page mark. Thus it is advantageous
+	 * always to zero the highest order we can find.
+	 */
+	for(area = z->free_area + MAX_ORDER - 1; area >= z->free_area; area--)
+		if (!list_empty(&area->free_list)) {
+			struct page *p = list_entry(area->free_list.next, struct page, lru);
+
+			if (!PageLocked(p) && !PageZero(p)) {
+				int order = area - z->free_area;
+
+				list_move_tail(&p->lru, &area->free_list);
+				if (zero_page(area, p, order))
+					goto out;
+
+				/* Unable to find a zeroing device that would
+				 * deal with this page so just do it on our own.
+				 * This will likely thrash our caches but the system
+				 * is idle after all and we can handle this with
+				 * minimal administrative overhead after dropping
+				 * the lock
+				 */
+				SetPageZero(p);
+				SetPageLocked(p);
+				spin_unlock_irqrestore(&z->lock, flags);
+				clear_pages(page_address(p), order);
+				smp_wmb();
+				ClearPageLocked(p);
+				return;
+			}
+		}
+out:
+	spin_unlock_irqrestore(&z->lock, flags);
+}
+
+/*
  * Builds allocation fallback zone lists.
  */
 static int __init build_zonelists_node(pg_data_t *pgdat, struct zonelist *zonelist, int j, int k)
@@ -1549,11 +1743,19 @@
 			pcp->high = 2 * batch;
 			pcp->batch = 1 * batch;
 			INIT_LIST_HEAD(&pcp->list);
+
+			pcp = &zone->pageset[cpu].pcp[2];	/* zero pages */
+			pcp->count = 0;
+			pcp->low = 0;
+			pcp->high = 2 * batch;
+			pcp->batch = 1 * batch;
+			INIT_LIST_HEAD(&pcp->list);
 		}
 		printk(KERN_DEBUG "  %s zone: %lu pages, LIFO batch:%lu\n",
 				zone_names[j], realsize, batch);
 		INIT_LIST_HEAD(&zone->active_list);
 		INIT_LIST_HEAD(&zone->inactive_list);
+		INIT_LIST_HEAD(&zone->free_queue);
 		zone->nr_scan_active = 0;
 		zone->nr_scan_inactive = 0;
 		zone->nr_active = 0;
Index: linux-2.6.9/include/linux/mmzone.h
=================================--- linux-2.6.9.orig/include/linux/mmzone.h	2004-12-10 12:42:33.000000000 -0800
+++ linux-2.6.9/include/linux/mmzone.h	2004-12-13 13:58:48.000000000 -0800
@@ -51,7 +51,7 @@
 };

 struct per_cpu_pageset {
-	struct per_cpu_pages pcp[2];	/* 0: hot.  1: cold */
+	struct per_cpu_pages pcp[3];	/* 0: hot.  1: cold  2: cold zeroed pages */
 #ifdef CONFIG_NUMA
 	unsigned long numa_hit;		/* allocated in intended node */
 	unsigned long numa_miss;	/* allocated in non intended node */
@@ -132,7 +132,7 @@
 	 */
 	spinlock_t		lock;
 	struct free_area	free_area[MAX_ORDER];
-
+	struct list_head	free_queue;		/* Queued pages not in maps yet */

 	ZONE_PADDING(_pad1_)

Index: linux-2.6.9/include/linux/gfp.h
=================================--- linux-2.6.9.orig/include/linux/gfp.h	2004-10-18 14:53:44.000000000 -0700
+++ linux-2.6.9/include/linux/gfp.h	2004-12-13 13:58:48.000000000 -0800
@@ -37,6 +37,7 @@
 #define __GFP_NORETRY	0x1000	/* Do not retry.  Might fail */
 #define __GFP_NO_GROW	0x2000	/* Slab internal usage */
 #define __GFP_COMP	0x4000	/* Add compound page metadata */
+#define __GFP_ZERO	0x8000	/* Return zeroed page on success */

 #define __GFP_BITS_SHIFT 16	/* Room for 16 __GFP_FOO bits */
 #define __GFP_BITS_MASK ((1 << __GFP_BITS_SHIFT) - 1)
@@ -52,6 +53,7 @@
 #define GFP_KERNEL	(__GFP_WAIT | __GFP_IO | __GFP_FS)
 #define GFP_USER	(__GFP_WAIT | __GFP_IO | __GFP_FS)
 #define GFP_HIGHUSER	(__GFP_WAIT | __GFP_IO | __GFP_FS | __GFP_HIGHMEM)
+#define GFP_HIGHZERO	(__GFP_WAIT | __GFP_IO | __GFP_FS | __GFP_HIGHMEM | __GFP_ZERO)

 /* Flag - indicates that the buffer will be suitable for DMA.  Ignored on some
    platforms, used as appropriate on others */
Index: linux-2.6.9/mm/memory.c
=================================--- linux-2.6.9.orig/mm/memory.c	2004-12-10 12:42:33.000000000 -0800
+++ linux-2.6.9/mm/memory.c	2004-12-13 13:58:48.000000000 -0800
@@ -1445,10 +1445,9 @@

 		if (unlikely(anon_vma_prepare(vma)))
 			goto no_mem;
-		page = alloc_page_vma(GFP_HIGHUSER, vma, addr);
+		page = alloc_page_vma(GFP_HIGHZERO, vma, addr);
 		if (!page)
 			goto no_mem;
-		clear_user_highpage(page, addr);

 		spin_lock(&mm->page_table_lock);
 		page_table = pte_offset_map(pmd, addr);
Index: linux-2.6.9/kernel/profile.c
=================================--- linux-2.6.9.orig/kernel/profile.c	2004-12-10 12:42:33.000000000 -0800
+++ linux-2.6.9/kernel/profile.c	2004-12-13 13:58:48.000000000 -0800
@@ -326,17 +326,15 @@
 		node = cpu_to_node(cpu);
 		per_cpu(cpu_profile_flip, cpu) = 0;
 		if (!per_cpu(cpu_profile_hits, cpu)[1]) {
-			page = alloc_pages_node(node, GFP_KERNEL, 0);
+			page = alloc_pages_node(node, GFP_KERNEL | __GFP_ZERO, 0);
 			if (!page)
 				return NOTIFY_BAD;
-			clear_highpage(page);
 			per_cpu(cpu_profile_hits, cpu)[1] = page_address(page);
 		}
 		if (!per_cpu(cpu_profile_hits, cpu)[0]) {
-			page = alloc_pages_node(node, GFP_KERNEL, 0);
+			page = alloc_pages_node(node, GFP_KERNEL | __GFP_ZERO, 0);
 			if (!page)
 				goto out_free;
-			clear_highpage(page);
 			per_cpu(cpu_profile_hits, cpu)[0] = page_address(page);
 		}
 		break;
@@ -510,16 +508,14 @@
 		int node = cpu_to_node(cpu);
 		struct page *page;

-		page = alloc_pages_node(node, GFP_KERNEL, 0);
+		page = alloc_pages_node(node, GFP_KERNEL | __GFP_ZERO, 0);
 		if (!page)
 			goto out_cleanup;
-		clear_highpage(page);
 		per_cpu(cpu_profile_hits, cpu)[1]
 				= (struct profile_hit *)page_address(page);
-		page = alloc_pages_node(node, GFP_KERNEL, 0);
+		page = alloc_pages_node(node, GFP_KERNEL | __GFP_ZERO, 0);
 		if (!page)
 			goto out_cleanup;
-		clear_highpage(page);
 		per_cpu(cpu_profile_hits, cpu)[0]
 				= (struct profile_hit *)page_address(page);
 	}
Index: linux-2.6.9/mm/shmem.c
=================================--- linux-2.6.9.orig/mm/shmem.c	2004-12-10 12:42:33.000000000 -0800
+++ linux-2.6.9/mm/shmem.c	2004-12-13 13:58:48.000000000 -0800
@@ -369,9 +369,8 @@
 		}

 		spin_unlock(&info->lock);
-		page = shmem_dir_alloc(mapping_gfp_mask(inode->i_mapping));
+		page = shmem_dir_alloc(mapping_gfp_mask(inode->i_mapping) | __GFP_ZERO);
 		if (page) {
-			clear_highpage(page);
 			page->nr_swapped = 0;
 		}
 		spin_lock(&info->lock);
@@ -910,7 +909,7 @@
 	pvma.vm_policy = mpol_shared_policy_lookup(&info->policy, idx);
 	pvma.vm_pgoff = idx;
 	pvma.vm_end = PAGE_SIZE;
-	page = alloc_page_vma(gfp, &pvma, 0);
+	page = alloc_page_vma(gfp | __GFP_ZERO, &pvma, 0);
 	mpol_free(pvma.vm_policy);
 	return page;
 }
@@ -926,7 +925,7 @@
 shmem_alloc_page(unsigned long gfp,struct shmem_inode_info *info,
 				 unsigned long idx)
 {
-	return alloc_page(gfp);
+	return alloc_page(gfp) | __GFP_ZERO;
 }
 #endif

@@ -1135,7 +1134,6 @@

 		info->alloced++;
 		spin_unlock(&info->lock);
-		clear_highpage(filepage);
 		flush_dcache_page(filepage);
 		SetPageUptodate(filepage);
 	}
Index: linux-2.6.9/mm/hugetlb.c
=================================--- linux-2.6.9.orig/mm/hugetlb.c	2004-10-18 14:54:37.000000000 -0700
+++ linux-2.6.9/mm/hugetlb.c	2004-12-13 13:58:48.000000000 -0800
@@ -77,7 +77,6 @@
 struct page *alloc_huge_page(void)
 {
 	struct page *page;
-	int i;

 	spin_lock(&hugetlb_lock);
 	page = dequeue_huge_page();
@@ -88,8 +87,7 @@
 	spin_unlock(&hugetlb_lock);
 	set_page_count(page, 1);
 	page[1].mapping = (void *)free_huge_page;
-	for (i = 0; i < (HPAGE_SIZE/PAGE_SIZE); ++i)
-		clear_highpage(&page[i]);
+	clear_pages(page_address(page), HUGETLB_PAGE_ORDER);
 	return page;
 }

Index: linux-2.6.9/arch/ia64/lib/Makefile
=================================--- linux-2.6.9.orig/arch/ia64/lib/Makefile	2004-10-18 14:55:28.000000000 -0700
+++ linux-2.6.9/arch/ia64/lib/Makefile	2004-12-13 13:58:48.000000000 -0800
@@ -6,7 +6,7 @@

 lib-y := __divsi3.o __udivsi3.o __modsi3.o __umodsi3.o			\
 	__divdi3.o __udivdi3.o __moddi3.o __umoddi3.o			\
-	bitop.o checksum.o clear_page.o csum_partial_copy.o copy_page.o	\
+	bitop.o checksum.o clear_page.o clear_pages.o csum_partial_copy.o copy_page.o	\
 	clear_user.o strncpy_from_user.o strlen_user.o strnlen_user.o	\
 	flush.o ip_fast_csum.o do_csum.o				\
 	memset.o strlen.o swiotlb.o
Index: linux-2.6.9/include/asm-ia64/page.h
=================================--- linux-2.6.9.orig/include/asm-ia64/page.h	2004-10-18 14:53:21.000000000 -0700
+++ linux-2.6.9/include/asm-ia64/page.h	2004-12-13 13:58:48.000000000 -0800
@@ -57,6 +57,7 @@
 #  define STRICT_MM_TYPECHECKS

 extern void clear_page (void *page);
+extern void clear_pages (void *page, int order);
 extern void copy_page (void *to, void *from);

 /*
Index: linux-2.6.9/arch/ia64/lib/clear_pages.S
=================================--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6.9/arch/ia64/lib/clear_pages.S	2004-12-13 13:58:48.000000000 -0800
@@ -0,0 +1,84 @@
+/*
+ * Copyright (C) 1999-2002 Hewlett-Packard Co
+ *	Stephane Eranian <eranian@hpl.hp.com>
+ *	David Mosberger-Tang <davidm@hpl.hp.com>
+ * Copyright (C) 2002 Ken Chen <kenneth.w.chen@intel.com>
+ *
+ * 1/06/01 davidm	Tuned for Itanium.
+ * 2/12/02 kchen	Tuned for both Itanium and McKinley
+ * 3/08/02 davidm	Some more tweaking
+ * 12/10/04 clameter	Make it work on pages of order size
+ */
+#include <linux/config.h>
+
+#include <asm/asmmacro.h>
+#include <asm/page.h>
+
+#ifdef CONFIG_ITANIUM
+# define L3_LINE_SIZE	64	// Itanium L3 line size
+# define PREFETCH_LINES	9	// magic number
+#else
+# define L3_LINE_SIZE	128	// McKinley L3 line size
+# define PREFETCH_LINES	12	// magic number
+#endif
+
+#define saved_lc	r2
+#define dst_fetch	r3
+#define dst1		r8
+#define dst2		r9
+#define dst3		r10
+#define dst4		r11
+
+#define dst_last	r31
+#define totsize		r14
+
+GLOBAL_ENTRY(clear_pages)
+	.prologue
+	.regstk 2,0,0,0
+	mov r16 = PAGE_SIZE/L3_LINE_SIZE	// main loop count
+	mov totsize = PAGE_SIZE
+	.save ar.lc, saved_lc
+	mov saved_lc = ar.lc
+	;;
+	.body
+	adds dst1 = 16, in0
+	mov ar.lc = (PREFETCH_LINES - 1)
+	mov dst_fetch = in0
+	adds dst2 = 32, in0
+	shl r16 = r16, in1
+	shl totsize = totsize, in1
+	;;
+.fetch:	stf.spill.nta [dst_fetch] = f0, L3_LINE_SIZE
+	adds dst3 = 48, in0		// executing this multiple times is harmless
+	br.cloop.sptk.few .fetch
+	add r16 = -1,r16
+	add dst_last = totsize, dst_fetch
+	adds dst4 = 64, in0
+	;;
+	mov ar.lc = r16			// one L3 line per iteration
+	adds dst_last = -PREFETCH_LINES*L3_LINE_SIZE, dst_last
+	;;
+#ifdef CONFIG_ITANIUM
+	// Optimized for Itanium
+1:	stf.spill.nta [dst1] = f0, 64
+	stf.spill.nta [dst2] = f0, 64
+	cmp.lt p8,p0=dst_fetch, dst_last
+	;;
+#else
+	// Optimized for McKinley
+1:	stf.spill.nta [dst1] = f0, 64
+	stf.spill.nta [dst2] = f0, 64
+	stf.spill.nta [dst3] = f0, 64
+	stf.spill.nta [dst4] = f0, 128
+	cmp.lt p8,p0=dst_fetch, dst_last
+	;;
+	stf.spill.nta [dst1] = f0, 64
+	stf.spill.nta [dst2] = f0, 64
+#endif
+	stf.spill.nta [dst3] = f0, 64
+(p8)	stf.spill.nta [dst_fetch] = f0, L3_LINE_SIZE
+	br.cloop.sptk.few 1b
+	;;
+	mov ar.lc = saved_lc		// restore lc
+	br.ret.sptk.many rp
+END(clear_pages)
Index: linux-2.6.9/kernel/sysctl.c
=================================--- linux-2.6.9.orig/kernel/sysctl.c	2004-12-10 12:42:33.000000000 -0800
+++ linux-2.6.9/kernel/sysctl.c	2004-12-13 21:28:29.000000000 -0800
@@ -67,6 +67,7 @@
 extern int printk_ratelimit_jiffies;
 extern int printk_ratelimit_burst;
 extern int pid_max_min, pid_max_max;
+extern unsigned int sysctl_zero_order;

 #if defined(CONFIG_X86_LOCAL_APIC) && defined(CONFIG_X86)
 int unknown_nmi_panic;
@@ -816,6 +817,15 @@
 		.strategy	= &sysctl_jiffies,
 	},
 #endif
+	{
+		.ctl_name	= VM_ZERO_ORDER,
+		.procname	= "zero_order",
+		.data		= &sysctl_zero_order,
+		.maxlen		= sizeof(sysctl_zero_order),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec,
+		.strategy	= &sysctl_intvec,
+	},
 	{ .ctl_name = 0 }
 };

Index: linux-2.6.9/include/linux/sysctl.h
=================================--- linux-2.6.9.orig/include/linux/sysctl.h	2004-12-10 12:42:33.000000000 -0800
+++ linux-2.6.9/include/linux/sysctl.h	2004-12-13 20:42:35.000000000 -0800
@@ -168,6 +168,7 @@
 	VM_VFS_CACHE_PRESSURE&, /* dcache/icache reclaim pressure */
 	VM_LEGACY_VA_LAYOUT', /* legacy/compatibility virtual address space layout */
 	VM_SWAP_TOKEN_TIMEOUT(, /* default time for token time out */
+	VM_ZERO_ORDER),	/* idle page zeroing */
 };


Index: linux-2.6.9/include/linux/zero.h
=================================--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6.9/include/linux/zero.h	2004-12-14 11:40:58.000000000 -0800
@@ -0,0 +1,27 @@
+#ifndef _LINUX_ZERO_H
+#define _LINUX_ZERO_H
+
+/*
+ * Definitions for drivers that allow the zeroing of memory
+ * without
+ * Christoph Lameter, December 2004.
+ */
+
+struct zero_driver {
+        int (*start_bzero)(struct page *p, int order);
+        struct list_head list;
+};
+
+extern struct list_head init_zero;
+
+/* Registering and unregistering zero drivers */
+static inline void register_zero_driver(struct zero_driver *z)
+{
+	list_add(&z->list, &init_zero);
+}
+
+static inline void unregister_zero_driver(struct zero_driver *z)
+{
+	list_del(&z->list);
+}
+#endif
Index: linux-2.6.9/include/asm-ia64/sn/bte.h
=================================--- linux-2.6.9.orig/include/asm-ia64/sn/bte.h	2004-12-10 12:42:32.000000000 -0800
+++ linux-2.6.9/include/asm-ia64/sn/bte.h	2004-12-14 17:35:45.000000000 -0800
@@ -115,6 +115,7 @@
 	int bte_error_count;	/* Number of errors encountered     */
 	int bte_num;		/* 0 --> BTE0, 1 --> BTE1           */
 	int cleanup_active;	/* Interface is locked for cleanup  */
+	struct page *zp;	/* Page being zeroed 		    */
 	volatile bte_result_t bh_error;	/* error while processing   */
 	volatile u64 *most_rcnt_na;
 };
Index: linux-2.6.9/arch/ia64/sn/kernel/bte.c
=================================--- linux-2.6.9.orig/arch/ia64/sn/kernel/bte.c	2004-12-13 21:36:19.000000000 -0800
+++ linux-2.6.9/arch/ia64/sn/kernel/bte.c	2004-12-14 18:19:07.000000000 -0800
@@ -20,6 +20,8 @@
 #include <linux/bootmem.h>
 #include <linux/string.h>
 #include <linux/sched.h>
+#include <linux/mm.h>
+#include <linux/zero.h>

 #include <asm/sn/bte.h>

@@ -30,7 +32,7 @@
 /* two interfaces on two btes */
 #define MAX_INTERFACES_TO_TRY		4

-static struct bteinfo_s *bte_if_on_node(nasid_t nasid, int interface)
+static inline struct bteinfo_s *bte_if_on_node(nasid_t nasid, int interface)
 {
 	nodepda_t *tmp_nodepda;

@@ -39,6 +41,14 @@

 }

+static inline void bte_bzero_complete(struct bteinfo_s *bte) {
+	if (bte->zp) {
+		printk(KERN_WARNING "bzero: completed %p\n",page_address(bte->zp));
+		ClearPageLocked(bte->zp);
+		*bte->most_rcnt_na = BTE_WORD_AVAILABLE;
+		bte->zp = NULL;
+	}
+}
 /************************************************************************
  * Block Transfer Engine copy related functions.
  *
@@ -132,13 +142,13 @@
 			if (bte = NULL) {
 				continue;
 			}
-
 			if (spin_trylock(&bte->spinlock)) {
 				if (!(*bte->most_rcnt_na & BTE_WORD_AVAILABLE) ||
 				    (BTE_LNSTAT_LOAD(bte) & BTE_ACTIVE)) {
 					/* Got the lock but BTE still busy */
 					spin_unlock(&bte->spinlock);
 				} else {
+					bte_bzero_complete(bte);
 					/* we got the lock and it's not busy */
 					break;
 				}
@@ -448,6 +458,94 @@
 		mynodepda->bte_if[i].bte_num = i;
 		mynodepda->bte_if[i].cleanup_active = 0;
 		mynodepda->bte_if[i].bh_error = 0;
+		mynodepda->bte_if[i].zp = NULL;
+	}
+}
+
+static inline void check_bzero_complete(void)
+{
+	unsigned long irq_flags;
+	struct bteinfo_s *bte;
+
+	/* CPU 0 (per node) uses bte0 , CPU 1 uses bte1 */
+	bte = bte_if_on_node(get_nasid(), cpuid_to_subnode(smp_processor_id()));
+
+	if (!bte->zp)
+		return;
+	local_irq_save(irq_flags);
+	if (!spin_trylock(&bte->spinlock)) {
+		local_irq_restore(irq_flags);
+		return;
+	}
+	if (*bte->most_rcnt_na = BTE_WORD_BUSY ||
+            (BTE_LNSTAT_LOAD(bte) & BTE_ACTIVE)) {
+                spin_unlock_irqrestore(&bte->spinlock, irq_flags);
+		return;
+	}
+	bte_bzero_complete(bte);
+	spin_unlock_irqrestore(&bte->spinlock, irq_flags);
+}
+
+static int bte_start_bzero(struct page *p, int order)
+{
+	struct bteinfo_s *bte;
+	unsigned int len = PAGE_SIZE << order;
+	unsigned long irq_flags;
+
+
+	/* Check limitations.
+		1. System must be running (weird things happen during bootup)
+		2. Size >128KB. Smaller requests cause too much bte traffic
+	 */
+	if (len > BTE_MAX_XFER ||
+	    order < 4 ||
+	    system_state != SYSTEM_RUNNING) {
+		check_bzero_complete();
+		return EINVAL;
+	}
+
+	/* CPU 0 (per node) uses bte0 , CPU 1 uses bte1 */
+	bte = bte_if_on_node(get_nasid(), cpuid_to_subnode(smp_processor_id()));
+	local_irq_save(irq_flags);
+
+	if (!spin_trylock(&bte->spinlock)) {
+		local_irq_restore(irq_flags);
+		printk(KERN_INFO "bzero: bte spinlock locked\n");
+		return EBUSY;
 	}

+	/* Complete any pending bzero notification */
+	bte_bzero_complete(bte);
+
+	if (bte->zp ||
+	    !(*bte->most_rcnt_na & BTE_WORD_AVAILABLE) ||
+	    (BTE_LNSTAT_LOAD(bte) & BTE_ACTIVE)) {
+		/* Got the lock but BTE still busy */
+		spin_unlock_irqrestore(&bte->spinlock, irq_flags);
+		return EBUSY;
+	}
+	printk(KERN_INFO "bzero: start address=%p length=%d\n", page_address(p), len);
+	bte->most_rcnt_na = &bte->notify;
+	*bte->most_rcnt_na = BTE_WORD_BUSY;
+	bte->zp = p;
+	SetPageLocked(p);
+	SetPageZero(p);
+	BTE_LNSTAT_STORE(bte, IBLS_BUSY | ((len >> L1_CACHE_SHIFT) & BTE_LEN_MASK));
+	BTE_SRC_STORE(bte, TO_PHYS(ia64_tpa(page_address(p))));
+	BTE_DEST_STORE(bte, 0);
+	BTE_NOTIF_STORE(bte,
+			TO_PHYS(ia64_tpa((unsigned long)bte->most_rcnt_na)));
+	BTE_CTRL_STORE(bte, BTE_ZERO_FILL);
+
+	spin_unlock_irqrestore(&bte->spinlock, irq_flags);
+	return 0;
+
+}
+
+static struct zero_driver bte_bzero = {
+	.start_bzero = bte_start_bzero
+};
+
+void sn_bte_bzero_init(void) {
+	register_zero_driver(&bte_bzero);
 }
Index: linux-2.6.9/arch/ia64/sn/kernel/setup.c
=================================--- linux-2.6.9.orig/arch/ia64/sn/kernel/setup.c	2004-12-10 12:42:27.000000000 -0800
+++ linux-2.6.9/arch/ia64/sn/kernel/setup.c	2004-12-14 12:32:15.000000000 -0800
@@ -243,6 +243,7 @@
 	int pxm;
 	int major = sn_sal_rev_major(), minor = sn_sal_rev_minor();
 	extern void sn_cpu_init(void);
+	extern void sn_bte_bzero_init(void);

 	/*
 	 * If the generic code has enabled vga console support - lets
@@ -333,6 +334,7 @@
 	screen_info = sn_screen_info;

 	sn_timer_init();
+	sn_bte_bzero_init();
 }

 /**

