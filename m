From: "Martin K. Petersen" <mkp@wildopensource.com>
Date: Thu, 14 Oct 2004 16:50:43 +0000
Subject: [PATCH] General purpose zeroed page slab
Message-Id: <yq1oej5s0po.fsf@wilson.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, akpm@osdl.org, tony.luck@intel.com


A while back Bill Irwin converted the page table code on ppc64 to use
a zeroed page slab.  I recently did the same on ia64 and got a
significant performance improvement in terms of fault time (4 usec ->
700 nsec).

This cache needs to be initialized fairly early on and so far we've
called it from pgtable_cache_init() on both archs.  However, Tony Luck
thought it might be useful to have a general purpose slab cache with
zeroed pages.  And other architectures might decide to use it for
their page tables too.

Consequently here's a patch that puts this functionality in slab.c.

Signed-off-by: Martin K. Petersen <mkp@wildopensource.com>

-- 
Martin K. Petersen	Wild Open Source, Inc.
mkp@wildopensource.com	http://www.wildopensource.com/

diff -urN -X /usr/people/mkp/bin/dontdiff linux-pristine/include/linux/slab.h zero-slab/include/linux/slab.h
--- linux-pristine/include/linux/slab.h	2004-10-11 14:57:20.000000000 -0700
+++ zero-slab/include/linux/slab.h	2004-10-13 17:49:29.000000000 -0700
@@ -115,6 +115,7 @@
 extern kmem_cache_t	*signal_cachep;
 extern kmem_cache_t	*sighand_cachep;
 extern kmem_cache_t	*bio_cachep;
+extern kmem_cache_t	*zero_page_cachep;
 
 extern atomic_t slab_reclaim_pages;
 
diff -urN -X /usr/people/mkp/bin/dontdiff linux-pristine/mm/slab.c zero-slab/mm/slab.c
--- linux-pristine/mm/slab.c	2004-10-11 14:57:20.000000000 -0700
+++ zero-slab/mm/slab.c	2004-10-13 17:49:57.000000000 -0700
@@ -716,6 +716,13 @@
 
 static struct notifier_block cpucache_notifier = { &cpuup_callback, NULL, 0 };
 
+kmem_cache_t *zero_page_cachep;
+
+static void zero_page_ctor(void *pte, kmem_cache_t *cache, unsigned long flags)
+{
+	memset(pte, 0, PAGE_SIZE);
+}
+
 /* Initialisation.
  * Called after the gfp() functions have been enabled, and before smp_init().
  */
@@ -837,6 +844,16 @@
 	/* The reap timers are started later, with a module init call:
 	 * That part of the kernel is not yet operational.
 	 */
+
+	/* General purpose cache of zeroed pages */
+	zero_page_cachep = kmem_cache_create("zero_page_cache",
+					     PAGE_SIZE, 0,
+					     SLAB_HWCACHE_ALIGN | 
+					     SLAB_MUST_HWCACHE_ALIGN,
+					     zero_page_ctor,
+					     NULL);
+	if (!zero_page_cachep)
+		panic("could not create zero_page_cache!\n");
 }
 
 static int __init cpucache_init(void)

