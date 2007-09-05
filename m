From: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Date: Wed, 05 Sep 2007 13:06:12 +0000
Subject: Re: [PATCH] slub - Use local_t protection
Message-Id: <20070905130612.GC11880@Krystal>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070827203913.GA7416@Krystal> <Pine.LNX.4.64.0708271401070.6435@schroedinger.engr.sgi.com> <20070827211003.GA10627@Krystal> <Pine.LNX.4.64.0708271421130.6566@schroedinger.engr.sgi.com> <20070827213845.GB9748@Krystal> <Pine.LNX.4.64.0708271510020.8783@schroedinger.engr.sgi.com> <20070827222715.GA16982@Krystal> <Pine.LNX.4.64.0708271811200.10344@schroedinger.engr.sgi.com> <20070904200429.GD8157@Krystal> <Pine.LNX.4.64.0709041344040.6376@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0709041344040.6376@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>
Cc: Peter Zijlstra <peterz@infradead.org>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, mingo@redhat.com, linux-ia64@vger.kernel.org

slub - Use local_t protection

Use local_enter/local_exit for protection in the fast path.

Depends on the cmpxchg_local slub patch.

Changelog:
Add new primitives to switch from local critical section to interrupt disabled
section.

Signed-off-by: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
CC: Christoph Lameter <clameter@sgi.com>
---
 mm/slub.c |   55 ++++++++++++++++++++++++++++++++-----------------------
 1 file changed, 32 insertions(+), 23 deletions(-)

Index: linux-2.6-lttng/mm/slub.c
=================================--- linux-2.6-lttng.orig/mm/slub.c	2007-09-05 09:01:00.000000000 -0400
+++ linux-2.6-lttng/mm/slub.c	2007-09-05 09:05:34.000000000 -0400
@@ -1065,9 +1065,6 @@ static struct page *new_slab(struct kmem
 
 	BUG_ON(flags & GFP_SLAB_BUG_MASK);
 
-	if (flags & __GFP_WAIT)
-		local_irq_enable();
-
 	page = allocate_slab(s,
 		flags & (GFP_RECLAIM_MASK | GFP_CONSTRAINT_MASK), node);
 	if (!page)
@@ -1100,8 +1097,6 @@ static struct page *new_slab(struct kmem
 	page->freelist = start;
 	page->inuse = 0;
 out:
-	if (flags & __GFP_WAIT)
-		local_irq_disable();
 	return page;
 }
 
@@ -1455,8 +1450,7 @@ static void *__slab_alloc(struct kmem_ca
 	struct page *new;
 	unsigned long flags;
 
-	local_irq_save(flags);
-	put_cpu_no_resched();
+	local_nest_irq_save(flags);
 	if (!c->page)
 		/* Slab was flushed */
 		goto new_slab;
@@ -1479,8 +1473,7 @@ load_freelist:
 	c->freelist = object[c->offset];
 out:
 	slab_unlock(c->page);
-	local_irq_restore(flags);
-	preempt_check_resched();
+	local_nest_irq_restore(flags);
 	if (unlikely((gfpflags & __GFP_ZERO)))
 		memset(object, 0, c->objsize);
 	return object;
@@ -1494,8 +1487,16 @@ new_slab:
 		c->page = new;
 		goto load_freelist;
 	}
-
+	if (gfpflags & __GFP_WAIT) {
+		local_nest_irq_enable();
+		local_exit();
+	}
 	new = new_slab(s, gfpflags, node);
+	if (gfpflags & __GFP_WAIT) {
+		local_enter();
+		local_nest_irq_disable();
+	}
+
 	if (new) {
 		c = get_cpu_slab(s, smp_processor_id());
 		if (c->page) {
@@ -1523,8 +1524,7 @@ new_slab:
 		c->page = new;
 		goto load_freelist;
 	}
-	local_irq_restore(flags);
-	preempt_check_resched();
+	local_nest_irq_restore(flags);
 	return NULL;
 debug:
 	object = c->page->freelist;
@@ -1552,8 +1552,11 @@ static void __always_inline *slab_alloc(
 {
 	void **object;
 	struct kmem_cache_cpu *c;
+	unsigned long flags;
+	void *ret;
 
-	c = get_cpu_slab(s, get_cpu());
+	local_enter_save(flags);
+	c = get_cpu_slab(s, smp_processor_id());
 redo:
 	object = c->freelist;
 	if (unlikely(!object))
@@ -1566,14 +1569,15 @@ redo:
 		object[c->offset]) != object))
 			goto redo;
 
-	put_cpu();
+	local_exit_restore(flags);
 	if (unlikely((gfpflags & __GFP_ZERO)))
 		memset(object, 0, c->objsize);
 
 	return object;
 slow:
-	return __slab_alloc(s, gfpflags, node, addr, c);
-
+	ret = __slab_alloc(s, gfpflags, node, addr, c);
+	local_exit_restore(flags);
+	return ret;
 }
 
 void *kmem_cache_alloc(struct kmem_cache *s, gfp_t gfpflags)
@@ -1605,8 +1609,7 @@ static void __slab_free(struct kmem_cach
 	void **object = (void *)x;
 	unsigned long flags;
 
-	put_cpu();
-	local_irq_save(flags);
+	local_nest_irq_save(flags);
 	slab_lock(page);
 
 	if (unlikely(SlabDebug(page)))
@@ -1632,7 +1635,7 @@ checks_ok:
 
 out_unlock:
 	slab_unlock(page);
-	local_irq_restore(flags);
+	local_nest_irq_restore(flags);
 	return;
 
 slab_empty:
@@ -1643,7 +1646,7 @@ slab_empty:
 		remove_partial(s, page);
 
 	slab_unlock(page);
-	local_irq_restore(flags);
+	local_nest_irq_restore(flags);
 	discard_slab(s, page);
 	return;
 
@@ -1670,10 +1673,12 @@ static void __always_inline slab_free(st
 	void **object = (void *)x;
 	void **freelist;
 	struct kmem_cache_cpu *c;
+	unsigned long flags;
 
 	debug_check_no_locks_freed(object, s->objsize);
 
-	c = get_cpu_slab(s, get_cpu());
+	local_enter_save(flags);
+	c = get_cpu_slab(s, smp_processor_id());
 	if (unlikely(c->node < 0))
 		goto slow;
 redo:
@@ -1687,10 +1692,11 @@ redo:
 							!= freelist))
 		goto redo;
 
-	put_cpu();
+	local_exit_restore(flags);
 	return;
 slow:
 	__slab_free(s, page, x, addr, c->offset);
+	local_exit_restore(flags);
 }
 
 void kmem_cache_free(struct kmem_cache *s, void *x)
@@ -2026,8 +2032,11 @@ static struct kmem_cache_node *early_kme
 
 	BUG_ON(kmalloc_caches->size < sizeof(struct kmem_cache_node));
 
+	if (gfpflags & __GFP_WAIT)
+		local_irq_enable();
 	page = new_slab(kmalloc_caches, gfpflags, node);
-
+	if (gfpflags & __GFP_WAIT)
+		local_irq_disable();
 	BUG_ON(!page);
 	if (page_to_nid(page) != node) {
 		printk(KERN_ERR "SLUB: Unable to allocate memory from "
-- 
Mathieu Desnoyers
Computer Engineering Ph.D. Student, Ecole Polytechnique de Montreal
OpenPGP key fingerprint: 8CD5 52C3 8E3C 4140 715F  BA06 3F25 A8FE 3BAE 9A68
