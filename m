From: Robin Holt <holt@sgi.com>
Date: Sat, 26 Feb 2005 14:27:16 +0000
Subject: [Patch 3/3] Shrink page table quicklist based on free memory.
Message-Id: <20050226142716.GG10965@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Tony,

This patch shrinks the quicklist based upon free memory on the node
instead of the high/low water marks.  I also limit the rate of drain from
the quicklist by 256 entries per pass.  The limit was placed because this
freeing is done with the preemption disabled and large frees have caused
unexpected bubbles in latency.  The 256 was chosen based on some test
runs which showed blips above the noise range with 4096 pages and that 256
pages resulted in the least amount of overshoot as processes were exiting.
Typical response at 128 would be periodic freeing of pages followed by
allocating at next startup.  With 256, this was nearly never observed.

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
=================================--- linux-2.6.orig/arch/ia64/mm/init.c	2005-02-26 08:12:42.787531829 -0600
+++ linux-2.6/arch/ia64/mm/init.c	2005-02-26 08:13:47.537757838 -0600
@@ -50,25 +50,39 @@
 EXPORT_SYMBOL(vmem_map);
 #endif
 
-static int pgt_cache_water[2] = { 25, 50 };
-
 struct page *zero_page_memmap_ptr;		/* map entry for zero page */
 EXPORT_SYMBOL(zero_page_memmap_ptr);
 
+#define quicklist_size		local_cpu_data->pgtable_quicklist_size
+#define MIN_PGT_PAGES		25UL
+/* This value was chosen to prevent a large block of frees to hold off timer ticks */
+#define PGT_FREES_PER_TICK	256
+
 void
 check_pgt_cache (void)
 {
-	int low, high;
+	u64 node_free_pages, max_pgt_pages;
+
+	if (quicklist_size <= MIN_PGT_PAGES)
+		return;
+
+#ifndef	CONFIG_NUMA
+	node_free_pages = nr_free_pages();
+#else
+	node_free_pages = nr_free_pages_pgdat(NODE_DATA(numa_node_id()));
+#endif
+	max_pgt_pages = node_free_pages >> 4;
+	max_pgt_pages = max(max_pgt_pages, MIN_PGT_PAGES);
 
-	low = pgt_cache_water[0];
-	high = pgt_cache_water[1];
+	if (quicklist_size <= max_pgt_pages)
+		return;
 
 	preempt_disable();
-	if (local_cpu_data->pgtable_quicklist_size > (u64) high) {
-		do {
-			free_page((unsigned long)pgtable_quicklist_alloc());
-		} while (local_cpu_data->pgtable_quicklist_size > (u64) low);
-	}
+	max_pgt_pages = min(max_pgt_pages, quicklist_size+256);
+
+	do {
+		free_page((unsigned long)pgtable_quicklist_alloc());
+	} while (quicklist_size > max_pgt_pages);
 	preempt_enable();
 }
 
@@ -521,7 +535,6 @@
 mem_init (void)
 {
 	long reserved_pages, codesize, datasize, initsize;
-	unsigned long num_pgt_pages;
 	pg_data_t *pgdat;
 	int i;
 	static struct kcore_list kcore_mem, kcore_vmem, kcore_kernel;
@@ -563,19 +576,6 @@
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
