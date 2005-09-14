From: Jack Steiner <steiner@sgi.com>
Date: Wed, 14 Sep 2005 16:29:38 +0000
Subject: [PATCH] - Increase max allowed kmalloc size for very large systems
Message-Id: <20050914162937.GA30596@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-mm@kvack.org
Cc: linux-ia64@vger.kernel.org


I'm in the process of changing IA64 to support (at least boot) with
up to 1024p. One of the issues is that kmalloc is being called to
allocate structures that exceed the sizes allowed in kmalloc_sizes.h.

Specifically, the workqueue code allocates a structure with 
a size a few bytes +  NR_CPUS * CACHE_LINE_SIZE (128 bytes on IA64). This
is over the limit allowed by kmalloc_sizes.h. Although workqueues
could be changed to eliminate this specific problem, I expect other places
will encounter the same limit. 

For now, I'm proposing that kmalloc_sizes.h be modified to allow allocation of
larger structures if NR_CPUS exceeds 512. This makes the change a noop
on all current platforms.

Does anyone see any problems with this approach???

	Signed-off-by: Jack Steiner <steiner@sgi.com>




Index: linux/include/linux/kmalloc_sizes.h
=================================--- linux.orig/include/linux/kmalloc_sizes.h	2005-09-12 10:40:20.749999533 -0500
+++ linux/include/linux/kmalloc_sizes.h	2005-09-14 10:47:04.479120684 -0500
@@ -19,8 +19,10 @@
 	CACHE(32768)
 	CACHE(65536)
 	CACHE(131072)
-#ifndef CONFIG_MMU
+#if (NR_CPUS > 512) || !defined(CONFIG_MMU) 
 	CACHE(262144)
+#endif
+#ifndef CONFIG_MMU
 	CACHE(524288)
 	CACHE(1048576)
 #ifdef CONFIG_LARGE_ALLOCS
-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


