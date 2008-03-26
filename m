From: Dean Nelson <dcn@sgi.com>
Date: Wed, 26 Mar 2008 16:48:15 +0000
Subject: [Patch 1/5] add multi-page allocation to the uncached allocator -v2
Message-Id: <20080326164815.GB20663@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080326163823.GA25653@sgi.com>
In-Reply-To: <20080326163823.GA25653@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: jes@sgi.com, tony.luck@intel.com, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Enable the uncached allocator to allocate multiple pages of contiguous
uncached memory.
 
Signed-off-by: Dean Nelson <dcn@sgi.com>
 
---
 
 arch/ia64/kernel/uncached.c |   21 ++++++++++++---------
 drivers/char/mspec.c        |   12 ++++++------
 include/asm-ia64/uncached.h |    4 ++--
 3 files changed, 20 insertions(+), 17 deletions(-)

Index: linux-2.6/arch/ia64/kernel/uncached.c
=================================--- linux-2.6.orig/arch/ia64/kernel/uncached.c	2007-10-04 06:52:20.000000000 -0500
+++ linux-2.6/arch/ia64/kernel/uncached.c	2007-11-08 12:14:31.408258515 -0600
@@ -177,12 +177,13 @@
  * uncached_alloc_page
  *
  * @starting_nid: node id of node to start with, or -1
+ * @n_pages: number of contiguous pages to allocate
  *
- * Allocate 1 uncached page. Allocates on the requested node. If no
- * uncached pages are available on the requested node, roundrobin starting
- * with the next higher node.
+ * Allocate the specified number of contiguous uncached pages on the
+ * the requested node. If not enough contiguous uncached pages are available
+ * on the requested node, roundrobin starting with the next higher node.
  */
-unsigned long uncached_alloc_page(int starting_nid)
+unsigned long uncached_alloc_page(int starting_nid, int n_pages)
 {
 	unsigned long uc_addr;
 	struct uncached_pool *uc_pool;
@@ -202,7 +203,8 @@
 		if (uc_pool->pool = NULL)
 			continue;
 		do {
-			uc_addr = gen_pool_alloc(uc_pool->pool, PAGE_SIZE);
+			uc_addr = gen_pool_alloc(uc_pool->pool,
+						 n_pages * PAGE_SIZE);
 			if (uc_addr != 0)
 				return uc_addr;
 		} while (uncached_add_chunk(uc_pool, nid) = 0);
@@ -217,11 +219,12 @@
 /*
  * uncached_free_page
  *
- * @uc_addr: uncached address of page to free
+ * @uc_addr: uncached address of first page to free
+ * @n_pages: number of contiguous pages to free
  *
- * Free a single uncached page.
+ * Free the specified number of uncached pages.
  */
-void uncached_free_page(unsigned long uc_addr)
+void uncached_free_page(unsigned long uc_addr, int n_pages)
 {
 	int nid = paddr_to_nid(uc_addr - __IA64_UNCACHED_OFFSET);
 	struct gen_pool *pool = uncached_pools[nid].pool;
@@ -232,7 +235,7 @@
 	if ((uc_addr & (0XFUL << 60)) != __IA64_UNCACHED_OFFSET)
 		panic("uncached_free_page invalid address %lx\n", uc_addr);
 
-	gen_pool_free(pool, uc_addr, PAGE_SIZE);
+	gen_pool_free(pool, uc_addr, n_pages * PAGE_SIZE);
 }
 EXPORT_SYMBOL(uncached_free_page);
 
Index: linux-2.6/drivers/char/mspec.c
=================================--- linux-2.6.orig/drivers/char/mspec.c	2007-10-04 06:52:21.000000000 -0500
+++ linux-2.6/drivers/char/mspec.c	2007-11-08 12:07:17.458415225 -0600
@@ -180,7 +180,7 @@
 		my_page = vdata->maddr[index];
 		vdata->maddr[index] = 0;
 		if (!mspec_zero_block(my_page, PAGE_SIZE))
-			uncached_free_page(my_page);
+			uncached_free_page(my_page, 1);
 		else
 			printk(KERN_WARNING "mspec_close(): "
 			       "failed to zero page %ld\n", my_page);
@@ -209,7 +209,7 @@
 	index = (address - vdata->vm_start) >> PAGE_SHIFT;
 	maddr = (volatile unsigned long) vdata->maddr[index];
 	if (maddr = 0) {
-		maddr = uncached_alloc_page(numa_node_id());
+		maddr = uncached_alloc_page(numa_node_id(), 1);
 		if (maddr = 0)
 			return NOPFN_OOM;
 
@@ -218,7 +218,7 @@
 			vdata->count++;
 			vdata->maddr[index] = maddr;
 		} else {
-			uncached_free_page(maddr);
+			uncached_free_page(maddr, 1);
 			maddr = vdata->maddr[index];
 		}
 		spin_unlock(&vdata->lock);
@@ -367,7 +367,7 @@
 				int nasid;
 				unsigned long phys;
 
-				scratch_page[nid] = uncached_alloc_page(nid);
+				scratch_page[nid] = uncached_alloc_page(nid, 1);
 				if (scratch_page[nid] = 0)
 					goto free_scratch_pages;
 				phys = __pa(scratch_page[nid]);
@@ -414,7 +414,7 @@
  free_scratch_pages:
 	for_each_node(nid) {
 		if (scratch_page[nid] != 0)
-			uncached_free_page(scratch_page[nid]);
+			uncached_free_page(scratch_page[nid], 1);
 	}
 	return ret;
 }
@@ -431,7 +431,7 @@
 
 		for_each_node(nid) {
 			if (scratch_page[nid] != 0)
-				uncached_free_page(scratch_page[nid]);
+				uncached_free_page(scratch_page[nid], 1);
 		}
 	}
 }
Index: linux-2.6/include/asm-ia64/uncached.h
=================================--- linux-2.6.orig/include/asm-ia64/uncached.h	2007-10-04 06:52:25.000000000 -0500
+++ linux-2.6/include/asm-ia64/uncached.h	2007-11-08 12:05:00.633469891 -0600
@@ -8,5 +8,5 @@
  * Prototypes for the uncached page allocator
  */
 
-extern unsigned long uncached_alloc_page(int nid);
-extern void uncached_free_page(unsigned long);
+extern unsigned long uncached_alloc_page(int, int);
+extern void uncached_free_page(unsigned long, int);
