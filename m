From: Robin Holt <holt@sgi.com>
Date: Thu, 03 Mar 2005 21:28:33 +0000
Subject: [Patch 3/3] Shrink quicklist based upon node free memory.
Message-Id: <20050303212833.GC947@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050302184312.GD16517@lnx-holt.americas.sgi.com>
In-Reply-To: <20050302184312.GD16517@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Tony,

This patch shrinks the quicklist based upon free memory on the node
instead of the high/low water marks.  I have written it to enable
preemption periodically and recalculate the amount to shrink every time
we have freed enough pages that the quicklist size should have grown.
I rescan the nodes zones each pass because other processess may be
draining node memory at the same time as we are adding.

Signed-off-by: Robin Holt <holt@sgi.com>


No noticable performance change on lmbench.  For completeness sake, here
are the before and after numbers:

Before:
Process fork+exit: 182.2333 microseconds
Process fork+execve: 692.7500 microseconds
Process fork+/bin/sh -c: 2905.5000 microseconds

After:
Process fork+exit: 181.1935 microseconds
Process fork+execve: 690.0000 microseconds
Process fork+/bin/sh -c: 2945.0000 microseconds

 init.c |   60 ++++++++++++++++++++++++++++++++++++++----------------------
 1 files changed, 38 insertions(+), 22 deletions(-)

Index: linux-2.6/arch/ia64/mm/init.c
=================================--- linux-2.6.orig/arch/ia64/mm/init.c	2005-03-03 06:54:17.278432345 -0600
+++ linux-2.6/arch/ia64/mm/init.c	2005-03-03 07:08:05.805152594 -0600
@@ -53,24 +53,54 @@
 EXPORT_SYMBOL(vmem_map);
 #endif
 
-static int pgt_cache_water[2] = { 25, 50 };
-
 struct page *zero_page_memmap_ptr;		/* map entry for zero page */
 EXPORT_SYMBOL(zero_page_memmap_ptr);
 
+#define MIN_PGT_PAGES		25UL
+#define NODE_FREE_PAGES_SHIFT	4
+
+static inline long
+max_pgt_pages (void)
+{
+	u64 node_free_pages, max_pgt_pages;
+
+#ifndef	CONFIG_NUMA
+	node_free_pages = nr_free_pages();
+#else
+	node_free_pages = nr_free_pages_pgdat(NODE_DATA(numa_node_id()));
+#endif
+	max_pgt_pages = node_free_pages >> NODE_FREE_PAGES_SHIFT;
+	max_pgt_pages = max(max_pgt_pages, MIN_PGT_PAGES);
+	return max_pgt_pages;
+}
+
+
+static inline long
+min_pages_to_free (void)
+{
+	long pages_to_free;
+
+	pages_to_free = pgtable_quicklist_size - max_pgt_pages();
+	pages_to_free = min(pages_to_free, 1L << NODE_FREE_PAGES_SHIFT);
+	return pages_to_free;
+}
+
+
 void
 check_pgt_cache (void)
 {
-	int low, high;
+	long pages_to_free;
 
-	low = pgt_cache_water[0];
-	high = pgt_cache_water[1];
+	if (unlikely(pgtable_quicklist_size <= MIN_PGT_PAGES))
+		return;
 
 	preempt_disable();
-	if (pgtable_quicklist_size > (u64) high) {
-		do {
+	while (unlikely((pages_to_free=min_pages_to_free()) > 0)) {
+		while (pages_to_free--) {
 			free_page((unsigned long)pgtable_quicklist_alloc());
-		} while (pgtable_quicklist_size > (u64) low);
+		}
+		preempt_enable();
+		preempt_disable();
 	}
 	preempt_enable();
 }
@@ -524,7 +554,6 @@
 mem_init (void)
 {
 	long reserved_pages, codesize, datasize, initsize;
-	unsigned long num_pgt_pages;
 	pg_data_t *pgdat;
 	int i;
 	static struct kcore_list kcore_mem, kcore_vmem, kcore_kernel;
@@ -570,19 +599,6 @@
 	       reserved_pages << (PAGE_SHIFT - 10), datasize >> 10, initsize >> 10);
 
 	/*
-	 * Allow for enough (cached) page table pages so that we can map the entire memory
-	 * at least once.  Each task also needs a couple of page tables pages, so add in a
-	 * fudge factor for that (don't use "threads-max" here; that would be wrong!).
-	 * Don't allow the cache to be more than 10% of total memory, though.
-	 */
-#	define NUM_TASKS	500	/* typical number of tasks */
-	num_pgt_pages = nr_free_pages() / PTRS_PER_PGD + NUM_TASKS;
-	if (num_pgt_pages > nr_free_pages() / 10)
-		num_pgt_pages = nr_free_pages() / 10;
-	if (num_pgt_pages > (u64) pgt_cache_water[1])
-		pgt_cache_water[1] = num_pgt_pages;
-
-	/*
 	 * For fsyscall entrpoints with no light-weight handler, use the ordinary
 	 * (heavy-weight) handler, but mark it by setting bit 0, so the fsyscall entry
 	 * code can tell them apart.
