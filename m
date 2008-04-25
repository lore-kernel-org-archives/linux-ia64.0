From: Dean Nelson <dcn@sgi.com>
Date: Fri, 25 Apr 2008 20:22:19 +0000
Subject: [PATCH] allocate multiple contiguous pages via uncached allocator -v3
Message-Id: <20080425202219.GC13773@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080422005004.0F97711C419@aqua.americas.sgi.com>
In-Reply-To: <20080422005004.0F97711C419@aqua.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: jes@sgi.com, tony.luck@intel.com
Cc: matthew@wil.cx, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Enable the uncached allocator to allocate multiple pages of contiguous
uncached memory.
 
Signed-off-by: Dean Nelson <dcn@sgi.com>
 
---

This version of this patch adds the argument names to the prototype statements
in the header file.
 
 arch/ia64/kernel/uncached.c         |   23 +++++++++++++----------
 drivers/char/mspec.c                |   12 ++++++------
 drivers/misc/sgi-xp/xpc_partition.c |    4 ++--
 include/asm-ia64/uncached.h         |    6 +++---
 4 files changed, 24 insertions(+), 21 deletions(-)

Index: linux-2.6/arch/ia64/kernel/uncached.c
=================================--- linux-2.6.orig/arch/ia64/kernel/uncached.c	2008-04-25 13:20:33.305200359 -0500
+++ linux-2.6/arch/ia64/kernel/uncached.c	2008-04-25 15:12:00.470227278 -0500
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2001-2006 Silicon Graphics, Inc.  All rights reserved.
+ * Copyright (C) 2001-2008 Silicon Graphics, Inc.  All rights reserved.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of version 2 of the GNU General Public License
@@ -177,12 +177,13 @@ failed:
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
@@ -202,7 +203,8 @@ unsigned long uncached_alloc_page(int st
 		if (uc_pool->pool = NULL)
 			continue;
 		do {
-			uc_addr = gen_pool_alloc(uc_pool->pool, PAGE_SIZE);
+			uc_addr = gen_pool_alloc(uc_pool->pool,
+						 n_pages * PAGE_SIZE);
 			if (uc_addr != 0)
 				return uc_addr;
 		} while (uncached_add_chunk(uc_pool, nid) = 0);
@@ -217,11 +219,12 @@ EXPORT_SYMBOL(uncached_alloc_page);
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
@@ -232,7 +235,7 @@ void uncached_free_page(unsigned long uc
 	if ((uc_addr & (0XFUL << 60)) != __IA64_UNCACHED_OFFSET)
 		panic("uncached_free_page invalid address %lx\n", uc_addr);
 
-	gen_pool_free(pool, uc_addr, PAGE_SIZE);
+	gen_pool_free(pool, uc_addr, n_pages * PAGE_SIZE);
 }
 EXPORT_SYMBOL(uncached_free_page);
 
Index: linux-2.6/drivers/char/mspec.c
=================================--- linux-2.6.orig/drivers/char/mspec.c	2008-04-25 13:20:33.305200359 -0500
+++ linux-2.6/drivers/char/mspec.c	2008-04-25 13:25:06.793568744 -0500
@@ -180,7 +180,7 @@ mspec_close(struct vm_area_struct *vma)
 		my_page = vdata->maddr[index];
 		vdata->maddr[index] = 0;
 		if (!mspec_zero_block(my_page, PAGE_SIZE))
-			uncached_free_page(my_page);
+			uncached_free_page(my_page, 1);
 		else
 			printk(KERN_WARNING "mspec_close(): "
 			       "failed to zero page %ld\n", my_page);
@@ -209,7 +209,7 @@ mspec_nopfn(struct vm_area_struct *vma, 
 	index = (address - vdata->vm_start) >> PAGE_SHIFT;
 	maddr = (volatile unsigned long) vdata->maddr[index];
 	if (maddr = 0) {
-		maddr = uncached_alloc_page(numa_node_id());
+		maddr = uncached_alloc_page(numa_node_id(), 1);
 		if (maddr = 0)
 			return NOPFN_OOM;
 
@@ -218,7 +218,7 @@ mspec_nopfn(struct vm_area_struct *vma, 
 			vdata->count++;
 			vdata->maddr[index] = maddr;
 		} else {
-			uncached_free_page(maddr);
+			uncached_free_page(maddr, 1);
 			maddr = vdata->maddr[index];
 		}
 		spin_unlock(&vdata->lock);
@@ -367,7 +367,7 @@ mspec_init(void)
 				int nasid;
 				unsigned long phys;
 
-				scratch_page[nid] = uncached_alloc_page(nid);
+				scratch_page[nid] = uncached_alloc_page(nid, 1);
 				if (scratch_page[nid] = 0)
 					goto free_scratch_pages;
 				phys = __pa(scratch_page[nid]);
@@ -414,7 +414,7 @@ mspec_init(void)
  free_scratch_pages:
 	for_each_node(nid) {
 		if (scratch_page[nid] != 0)
-			uncached_free_page(scratch_page[nid]);
+			uncached_free_page(scratch_page[nid], 1);
 	}
 	return ret;
 }
@@ -431,7 +431,7 @@ mspec_exit(void)
 
 		for_each_node(nid) {
 			if (scratch_page[nid] != 0)
-				uncached_free_page(scratch_page[nid]);
+				uncached_free_page(scratch_page[nid], 1);
 		}
 	}
 }
Index: linux-2.6/include/asm-ia64/uncached.h
=================================--- linux-2.6.orig/include/asm-ia64/uncached.h	2008-04-25 13:20:33.305200359 -0500
+++ linux-2.6/include/asm-ia64/uncached.h	2008-04-25 15:12:13.587833507 -0500
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2001-2005 Silicon Graphics, Inc.  All rights reserved.
+ * Copyright (C) 2001-2008 Silicon Graphics, Inc.  All rights reserved.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of version 2 of the GNU General Public License
@@ -8,5 +8,5 @@
  * Prototypes for the uncached page allocator
  */
 
-extern unsigned long uncached_alloc_page(int nid);
-extern void uncached_free_page(unsigned long);
+extern unsigned long uncached_alloc_page(int starting_nid, int n_pages);
+extern void uncached_free_page(unsigned long uc_addr, int n_pages);
Index: linux-2.6/drivers/misc/sgi-xp/xpc_partition.c
=================================--- linux-2.6.orig/drivers/misc/sgi-xp/xpc_partition.c	2008-04-25 13:12:02.000000000 -0500
+++ linux-2.6/drivers/misc/sgi-xp/xpc_partition.c	2008-04-25 13:28:24.340999346 -0500
@@ -211,7 +211,7 @@ xpc_rsvd_page_init(void)
 	 */
 	amos_page = xpc_vars->amos_page;
 	if (amos_page = NULL) {
-		amos_page = (AMO_t *)TO_AMO(uncached_alloc_page(0));
+		amos_page = (AMO_t *)TO_AMO(uncached_alloc_page(0, 1));
 		if (amos_page = NULL) {
 			dev_err(xpc_part, "can't allocate page of AMOs\n");
 			return NULL;
@@ -230,7 +230,7 @@ xpc_rsvd_page_init(void)
 				dev_err(xpc_part, "can't change memory "
 					"protections\n");
 				uncached_free_page(__IA64_UNCACHED_OFFSET |
-						   TO_PHYS((u64)amos_page));
+						   TO_PHYS((u64)amos_page), 1);
 				return NULL;
 			}
 		}
