From: Robin Holt <holt@sgi.com>
Date: Tue, 01 Mar 2005 16:35:49 +0000
Subject: [Patch 3/3 Try 3] Shrink page table quicklist based on free memory.
Message-Id: <20050301163549.GA32354@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Tony,

This patch shrinks the quicklist based upon free memory on the node
instead of the high/low water marks.  I have written it to enable
preemption periodically and recalculate the amount to shrink every
time we have freed enough pages that the quicklist size should have grown.
I retain the scan of free memory on the node as other processes may be
draining at the same time as we are adding.


Signed-off-by: Robin Holt <holt@sgi.com>


No noticable performance change on lmbench.  For completeness sake, here
are the before and after numbers:

Before:
Process fork+exit: 180.8065 microseconds
Process fork+exit: 182.4286 microseconds
Process fork+exit: 184.0333 microseconds
Process fork+exit: 183.3226 microseconds
Process fork+exit: 182.6333 microseconds
Process fork+exit: 183.4000 microseconds
Process fork+exit: 183.4667 microseconds
Process fork+exit: 182.1935 microseconds
Process fork+exit: 182.0667 microseconds
Process fork+exit: 183.7742 microseconds
Process fork+execve: 188.1667 microseconds
Process fork+execve: 188.6071 microseconds
Process fork+execve: 187.5333 microseconds
Process fork+execve: 188.9286 microseconds
Process fork+execve: 188.4333 microseconds
Process fork+execve: 187.6000 microseconds
Process fork+execve: 187.6333 microseconds
Process fork+execve: 188.5333 microseconds
Process fork+execve: 187.9655 microseconds
Process fork+execve: 186.3667 microseconds
After:
Process fork+exit: 182.3793 microseconds
Process fork+exit: 183.0667 microseconds
Process fork+exit: 182.9333 microseconds
Process fork+exit: 183.7742 microseconds
Process fork+exit: 182.9333 microseconds
Process fork+exit: 183.6774 microseconds
Process fork+exit: 182.2903 microseconds
Process fork+exit: 183.2667 microseconds
Process fork+exit: 181.0333 microseconds
Process fork+exit: 183.0000 microseconds
Process fork+execve: 187.9333 microseconds
Process fork+execve: 188.2000 microseconds
Process fork+execve: 188.5333 microseconds
Process fork+execve: 188.7333 microseconds
Process fork+execve: 189.0000 microseconds
Process fork+execve: 188.8667 microseconds
Process fork+execve: 187.3333 microseconds
Process fork+execve: 189.5172 microseconds
Process fork+execve: 188.4333 microseconds
Process fork+execve: 188.7667 microseconds

 init.c |   48 ++++++++++++++++++++++++------------------------
 1 files changed, 24 insertions(+), 24 deletions(-)


Index: linux-2.6/arch/ia64/mm/init.c
=================================--- linux-2.6.orig/arch/ia64/mm/init.c	2005-03-01 10:20:38.289030938 -0600
+++ linux-2.6/arch/ia64/mm/init.c	2005-03-01 10:20:38.374967413 -0600
@@ -50,24 +50,48 @@
 EXPORT_SYMBOL(vmem_map);
 #endif
 
-static int pgt_cache_water[2] = { 25, 50 };
-
 struct page *zero_page_memmap_ptr;		/* map entry for zero page */
 EXPORT_SYMBOL(zero_page_memmap_ptr);
 
+#define quicklist_size		local_cpu_data->pgtable_quicklist_size
+#define MIN_PGT_PAGES		25UL
+/* This value was chosen to prevent a large block of frees to hold off timer ticks */
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
 void
 check_pgt_cache (void)
 {
-	int low, high;
+	long pages_to_free;
 
-	low = pgt_cache_water[0];
-	high = pgt_cache_water[1];
+	if (unlikely(quicklist_size <= MIN_PGT_PAGES))
+		return;
 
 	preempt_disable();
-	if (local_cpu_data->pgtable_quicklist_size > (u64) high) {
-		do {
+	pages_to_free = quicklist_size - max_pgt_pages();
+	while (unlikely(pages_to_free > 0)) {
+		pages_to_free = min(pages_to_free, 1L << NODE_FREE_PAGES_SHIFT);
+		while (pages_to_free--) {
 			free_page((unsigned long)pgtable_quicklist_alloc());
-		} while (local_cpu_data->pgtable_quicklist_size > (u64) low);
+		}
+		preempt_enable();
+		preempt_disable();
+		pages_to_free = quicklist_size - max_pgt_pages();
 	}
 	preempt_enable();
 }
@@ -521,7 +545,6 @@
 mem_init (void)
 {
 	long reserved_pages, codesize, datasize, initsize;
-	unsigned long num_pgt_pages;
 	pg_data_t *pgdat;
 	int i;
 	static struct kcore_list kcore_mem, kcore_vmem, kcore_kernel;
@@ -563,19 +586,6 @@
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
