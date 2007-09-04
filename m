From: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Date: Tue, 04 Sep 2007 20:04:29 +0000
Subject: [PATCH] slub - Use local_t protection
Message-Id: <20070904200429.GD8157@Krystal>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070827202203.GB5653@Krystal> <Pine.LNX.4.64.0708271324001.5884@schroedinger.engr.sgi.com> <20070827203913.GA7416@Krystal> <Pine.LNX.4.64.0708271401070.6435@schroedinger.engr.sgi.com> <20070827211003.GA10627@Krystal> <Pine.LNX.4.64.0708271421130.6566@schroedinger.engr.sgi.com> <20070827213845.GB9748@Krystal> <Pine.LNX.4.64.0708271510020.8783@schroedinger.engr.sgi.com> <20070827222715.GA16982@Krystal> <Pine.LNX.4.64.0708271811200.10344@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0708271811200.10344@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>
Cc: Peter Zijlstra <peterz@infradead.org>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, mingo@redhat.com, linux-ia64@vger.kernel.org

slub - Use local_t protection

Use local_enter/local_exit for protection in the fast path.

Depends on the cmpxchg_local slub patch.

Signed-off-by: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
CC: Christoph Lameter <clameter@sgi.com>
---
 mm/slub.c |   18 ++++++++++--------
 1 file changed, 10 insertions(+), 8 deletions(-)

Index: linux-2.6-lttng/mm/slub.c
=================================--- linux-2.6-lttng.orig/mm/slub.c	2007-09-04 15:47:20.000000000 -0400
+++ linux-2.6-lttng/mm/slub.c	2007-09-04 15:52:07.000000000 -0400
@@ -1456,7 +1456,6 @@ static void *__slab_alloc(struct kmem_ca
 	unsigned long flags;
 
 	local_irq_save(flags);
-	put_cpu_no_resched();
 	if (!c->page)
 		/* Slab was flushed */
 		goto new_slab;
@@ -1480,7 +1479,6 @@ load_freelist:
 out:
 	slab_unlock(c->page);
 	local_irq_restore(flags);
-	preempt_check_resched();
 	if (unlikely((gfpflags & __GFP_ZERO)))
 		memset(object, 0, c->objsize);
 	return object;
@@ -1524,7 +1522,6 @@ new_slab:
 		goto load_freelist;
 	}
 	local_irq_restore(flags);
-	preempt_check_resched();
 	return NULL;
 debug:
 	object = c->page->freelist;
@@ -1552,8 +1549,10 @@ static void __always_inline *slab_alloc(
 {
 	void **object;
 	struct kmem_cache_cpu *c;
+	unsigned long flags;
 
-	c = get_cpu_slab(s, get_cpu());
+	local_enter(flags);
+	c = get_cpu_slab(s, smp_processor_id());
 redo:
 	object = c->freelist;
 	if (unlikely(!object))
@@ -1566,12 +1565,13 @@ redo:
 		object[c->offset]) != object))
 			goto redo;
 
-	put_cpu();
+	local_exit(flags);
 	if (unlikely((gfpflags & __GFP_ZERO)))
 		memset(object, 0, c->objsize);
 
 	return object;
 slow:
+	local_exit(flags);
 	return __slab_alloc(s, gfpflags, node, addr, c);
 
 }
@@ -1605,7 +1605,6 @@ static void __slab_free(struct kmem_cach
 	void **object = (void *)x;
 	unsigned long flags;
 
-	put_cpu();
 	local_irq_save(flags);
 	slab_lock(page);
 
@@ -1670,10 +1669,12 @@ static void __always_inline slab_free(st
 	void **object = (void *)x;
 	void **freelist;
 	struct kmem_cache_cpu *c;
+	unsigned long flags;
 
 	debug_check_no_locks_freed(object, s->objsize);
 
-	c = get_cpu_slab(s, get_cpu());
+	local_enter(flags);
+	c = get_cpu_slab(s, smp_processor_id());
 	if (unlikely(c->node < 0))
 		goto slow;
 redo:
@@ -1687,9 +1688,10 @@ redo:
 							!= freelist))
 		goto redo;
 
-	put_cpu();
+	local_exit(flags);
 	return;
 slow:
+	local_exit(flags);
 	__slab_free(s, page, x, addr, c->offset);
 }

-- 
Mathieu Desnoyers
Computer Engineering Ph.D. Student, Ecole Polytechnique de Montreal
OpenPGP key fingerprint: 8CD5 52C3 8E3C 4140 715F  BA06 3F25 A8FE 3BAE 9A68
