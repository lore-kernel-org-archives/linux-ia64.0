From: Christoph Lameter <clameter@sgi.com>
Date: Sun, 11 Mar 2007 02:09:54 +0000
Subject: [QUICKLIST 6/6] slub: remove special casing for PAGE_SIZE slabs
Message-Id: <20070311020954.19905.90199.sendpatchset@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070311020923.19905.49260.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20070311020923.19905.49260.sendpatchset@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: ak@suse.com, linux-ia64@vger.kernel.org, holt@sgi.com, Christoph Lameter <clameter@sgi.com>, mpm@selenic.com

Slub: Remove special casing for page sized slabs

After we have used quicklist so that arches can avoid using the slab
allocator to manage page table pages we can now remove the special
casing from slub.

This is against SLUB V5

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.21-rc3/mm/slub.c
=================================--- linux-2.6.21-rc3.orig/mm/slub.c	2007-03-09 21:23:39.000000000 -0800
+++ linux-2.6.21-rc3/mm/slub.c	2007-03-09 21:24:23.000000000 -0800
@@ -1236,16 +1236,6 @@
 	int order;
 	int rem;
 
-	/*
-	 * If this is an order 0 page then there are no issues with
-	 * fragmentation. We can then create a slab with a single object.
-	 * We need this to support the i386 arch code that uses our
-	 * freelist field (index field) for a list pointer. We neveri
-	 * touch the freelist pointer if we just have one object
-	 */
-	if (size = PAGE_SIZE)
-		return 0;
-
 	for (order = max(slub_min_order, fls(size - 1) - PAGE_SHIFT);
 			order < MAX_ORDER; order++) {
 		unsigned long slab_size = PAGE_SIZE << order;
@@ -1386,15 +1376,6 @@
 
 	tentative_size = ALIGN(size, calculate_alignment(align, flags));
 
-	/*
-	 * PAGE_SIZE slabs are special in that they are passed through
-	 * to the page allocator. Do not do any debugging in order to avoid
-	 * increasing the size of the object.
-	 */
-	if (size = PAGE_SIZE)
-		flags &= ~(SLAB_RED_ZONE| SLAB_DEBUG_FREE | \
-			SLAB_STORE_USER | SLAB_POISON | __OBJECT_POISON);
-
 	s->name = name;
 	s->ctor = ctor;
 	s->dtor = dtor;
