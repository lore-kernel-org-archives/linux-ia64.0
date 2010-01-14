From: Christoph Lameter <cl@linux-foundation.org>
Date: Thu, 14 Jan 2010 15:18:40 +0000
Subject: Re: SLUB ia64 linux-next crash bisected to 756dee75
Message-Id: <alpine.DEB.2.00.1001140917110.14164@router.home>
List-Id: <linux-ia64.vger.kernel.org>
References: <20100113002923.GF2985@ldl.fc.hp.com>
In-Reply-To: <20100113002923.GF2985@ldl.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alex Chiang <achiang@hp.com>
Cc: penberg@cs.helsinki.fi, linux-ia64@vger.kernel.org, linux-mm@kvack.org

Try this


Subject: [SLUB] Size kmalloc_percpu correctly

We need kmalloc_percpu for all kmalloc caches not just for each shift
value.

Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

---
 mm/slub.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6/mm/slub.c
=================================--- linux-2.6.orig/mm/slub.c	2010-01-14 09:16:12.000000000 -0600
+++ linux-2.6/mm/slub.c	2010-01-14 09:16:27.000000000 -0600
@@ -2086,7 +2086,7 @@ init_kmem_cache_node(struct kmem_cache_n
 #endif
 }

-static DEFINE_PER_CPU(struct kmem_cache_cpu, kmalloc_percpu[SLUB_PAGE_SHIFT]);
+static DEFINE_PER_CPU(struct kmem_cache_cpu, kmalloc_percpu[KMALLOC_CACHES]);

 static inline int alloc_kmem_cache_cpus(struct kmem_cache *s, gfp_t flags)
 {

