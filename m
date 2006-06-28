From: dcn@sgi.com (Dean Nelson)
Date: Wed, 28 Jun 2006 18:50:09 +0000
Subject: [Patch] make uncached allocator more node aware
Message-Id: <44A2CF61.mailx84S199TB6@aqua.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The uncached allocator has a function, uncached_get_new_chunk(), that needs
to be serialized on a per node basis. It also has a global variable,
allocated_granules, which should be defined on a per node basis and protected
by that serialization. Additionally, all error returns from functions called
(like ia64_pal_mc_drain()) should be handled appropriately.

Signed-off-by: Dean Nelson <dcn@sgi.com>


Index: linux-2.6/arch/ia64/kernel/uncached.c
=================================--- linux-2.6.orig/arch/ia64/kernel/uncached.c	2006-04-26 11:05:15.000000000 -0500
+++ linux-2.6/arch/ia64/kernel/uncached.c	2006-04-28 07:24:33.660111084 -0500
@@ -32,32 +32,38 @@
 
 extern void __init efi_memmap_walk_uc(efi_freemem_callback_t, void *);
 
-#define MAX_UNCACHED_GRANULES	5
-static int allocated_granules;
+struct uncached_pool {
+	struct gen_pool *pool;
+	struct mutex add_chunk_mutex;	/* serialize adding a converted chunk */
+	int nchunks_added;		/* #of converted chunks added to pool */
+	atomic_t status;		/* smp called function's return status*/
+};
+
+#define MAX_CONVERTED_CHUNKS_PER_NODE	2
 
-struct gen_pool *uncached_pool[MAX_NUMNODES];
+struct uncached_pool uncached_pools[MAX_NUMNODES];
 
 
 static void uncached_ipi_visibility(void *data)
 {
 	int status;
+	struct uncached_pool *uc_pool = (struct uncached_pool *)data;
 
 	status = ia64_pal_prefetch_visibility(PAL_VISIBILITY_PHYSICAL);
 	if ((status != PAL_VISIBILITY_OK) &&
 	    (status != PAL_VISIBILITY_OK_REMOTE_NEEDED))
-		printk(KERN_DEBUG "pal_prefetch_visibility() returns %i on "
-		       "CPU %i\n", status, raw_smp_processor_id());
+		atomic_inc(&uc_pool->status);
 }
 
 
 static void uncached_ipi_mc_drain(void *data)
 {
 	int status;
+	struct uncached_pool *uc_pool = (struct uncached_pool *)data;
 
 	status = ia64_pal_mc_drain();
-	if (status)
-		printk(KERN_WARNING "ia64_pal_mc_drain() failed with %i on "
-		       "CPU %i\n", status, raw_smp_processor_id());
+	if (status != PAL_STATUS_SUCCESS)
+		atomic_inc(&uc_pool->status);
 }
 
 
@@ -70,21 +76,34 @@
  * This is accomplished by first allocating a granule of cached memory pages
  * and then converting them to uncached memory pages.
  */
-static int uncached_add_chunk(struct gen_pool *pool, int nid)
+static int uncached_add_chunk(struct uncached_pool *uc_pool, int nid)
 {
 	struct page *page;
-	int status, i;
+	int status, i, nchunks_added = uc_pool->nchunks_added;
 	unsigned long c_addr, uc_addr;
 
-	if (allocated_granules >= MAX_UNCACHED_GRANULES)
+	if (mutex_lock_interruptible(&uc_pool->add_chunk_mutex) != 0)
+		return -1;	/* interrupted by a signal */
+
+	if (uc_pool->nchunks_added > nchunks_added) {
+		/* someone added a new chunk while we were waiting */
+		mutex_unlock(&uc_pool->add_chunk_mutex);
+		return 0;
+	}
+
+	if (uc_pool->nchunks_added >= MAX_CONVERTED_CHUNKS_PER_NODE) {
+		mutex_unlock(&uc_pool->add_chunk_mutex);
 		return -1;
+	}
 
 	/* attempt to allocate a granule's worth of cached memory pages */
 
 	page = alloc_pages_node(nid, GFP_KERNEL | __GFP_ZERO,
 				IA64_GRANULE_SHIFT-PAGE_SHIFT);
-	if (!page)
+	if (!page) {
+		mutex_unlock(&uc_pool->add_chunk_mutex);
 		return -1;
+	}
 
 	/* convert the memory pages from cached to uncached */
 
@@ -102,11 +121,14 @@
 	flush_tlb_kernel_range(uc_addr, uc_adddr + IA64_GRANULE_SIZE);
 
 	status = ia64_pal_prefetch_visibility(PAL_VISIBILITY_PHYSICAL);
-	if (!status) {
-		status = smp_call_function(uncached_ipi_visibility, NULL, 0, 1);
-		if (status)
+	if (status = PAL_VISIBILITY_OK_REMOTE_NEEDED) {
+		atomic_set(&uc_pool->status, 0);
+		status = smp_call_function(uncached_ipi_visibility, uc_pool,
+					   0, 1);
+		if (status || atomic_read(&uc_pool->status))
 			goto failed;
-	}
+	} else if (status != PAL_VISIBILITY_OK)
+		goto failed;
 
 	preempt_disable();
 
@@ -120,20 +142,24 @@
 
 	preempt_enable();
 
-	ia64_pal_mc_drain();
-	status = smp_call_function(uncached_ipi_mc_drain, NULL, 0, 1);
-	if (status)
+	status = ia64_pal_mc_drain();
+	if (status != PAL_STATUS_SUCCESS)
+		goto failed;
+	atomic_set(&uc_pool->status, 0);
+	status = smp_call_function(uncached_ipi_mc_drain, uc_pool, 0, 1);
+	if (status || atomic_read(&uc_pool->status))
 		goto failed;
 
 	/*
 	 * The chunk of memory pages has been converted to uncached so now we
 	 * can add it to the pool.
 	 */
-	status = gen_pool_add(pool, uc_addr, IA64_GRANULE_SIZE, nid);
+	status = gen_pool_add(uc_pool->pool, uc_addr, IA64_GRANULE_SIZE, nid);
 	if (status)
 		goto failed;
 
-	allocated_granules++;
+	uc_pool->nchunks_added++;
+	mutex_unlock(&uc_pool->add_chunk_mutex);
 	return 0;
 
 	/* failed to convert or add the chunk so give it back to the kernel */
@@ -142,6 +168,7 @@
 		ClearPageUncached(&page[i]);
 
 	free_pages(c_addr, IA64_GRANULE_SHIFT-PAGE_SHIFT);
+	mutex_unlock(&uc_pool->add_chunk_mutex);
 	return -1;
 }
 
@@ -158,7 +185,7 @@
 unsigned long uncached_alloc_page(int starting_nid)
 {
 	unsigned long uc_addr;
-	struct gen_pool *pool;
+	struct uncached_pool *uc_pool;
 	int nid;
 
 	if (unlikely(starting_nid >= MAX_NUMNODES))
@@ -171,14 +198,14 @@
 	do {
 		if (!node_online(nid))
 			continue;
-		pool = uncached_pool[nid];
-		if (pool = NULL)
+		uc_pool = &uncached_pools[nid];
+		if (uc_pool->pool = NULL)
 			continue;
 		do {
-			uc_addr = gen_pool_alloc(pool, PAGE_SIZE);
+			uc_addr = gen_pool_alloc(uc_pool->pool, PAGE_SIZE);
 			if (uc_addr != 0)
 				return uc_addr;
-		} while (uncached_add_chunk(pool, nid) = 0);
+		} while (uncached_add_chunk(uc_pool, nid) = 0);
 
 	} while ((nid = (nid + 1) % MAX_NUMNODES) != starting_nid);
 
@@ -197,7 +224,7 @@
 void uncached_free_page(unsigned long uc_addr)
 {
 	int nid = paddr_to_nid(uc_addr - __IA64_UNCACHED_OFFSET);
-	struct gen_pool *pool = uncached_pool[nid];
+	struct gen_pool *pool = uncached_pools[nid].pool;
 
 	if (unlikely(pool = NULL))
 		return;
@@ -224,7 +251,7 @@
 					unsigned long uc_end, void *arg)
 {
 	int nid = paddr_to_nid(uc_start - __IA64_UNCACHED_OFFSET);
-	struct gen_pool *pool = uncached_pool[nid];
+	struct gen_pool *pool = uncached_pools[nid].pool;
 	size_t size = uc_end - uc_start;
 
 	touch_softlockup_watchdog();
@@ -242,7 +269,8 @@
 	int nid;
 
 	for_each_online_node(nid) {
-		uncached_pool[nid] = gen_pool_create(PAGE_SHIFT, nid);
+		uncached_pools[nid].pool = gen_pool_create(PAGE_SHIFT, nid);
+		mutex_init(&uncached_pools[nid].add_chunk_mutex);
 	}
 
 	efi_memmap_walk_uc(uncached_build_memmap, NULL);
