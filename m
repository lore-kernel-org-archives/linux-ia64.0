From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Date: Wed, 12 Apr 2006 16:38:03 +0000
Subject: [PATCH 2.6.17-rc1-mm2] pg_uncached-is-ia64-only-fix
Message-Id: <1144859883.5229.6.camel@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

In 2.6.17-rc1-mm2, the patch 'pg_uncached-is-ia64-only.patch'
moves the ia64-only PG_uncached flag to the high order 32-bits
of the page flags, and reduces FLAGS_RESERVED to 24.  This 
latter change interacts with SPARSEMEM to push the nodes out
of the flags word.  ia64 actually needs all 32 high order
reserved bits to hold up to 1024 nodes in the flags along with
zone info and SPARSEMEM section index.  

For some reason that I have not investigated [this may be a bug
or a feature], pushing the node field out of the flags word
increases the size of the mm/page_alloc.o data region by ~32MB.  

before patch:size mm/page_alloc.o
   text    data     bss     dec     hex filename
  39506   10264   65548  115318   1c276 mm/page_alloc.o

after patch: size mm/page_alloc.o
   text    data     bss     dec     hex filename
  39650 33556504  65548 33661702  201a306 mm/page_alloc.o

So, 32MB is chump change on ia64 systems, but an unnecessary
waste.  The stated reason for the change was to "make room for
another flag on 32-bit machines."  32-bit machines themselves
reserve some bits of the page flags for zone and node info--
currently 9 bits.  So, we can use the upper ~8 bits of the low
order flags word for 64-bit only page flags.

This patch restores the 64-bit system FLAGS_RESERVED to 32 and
moves the PG_uncached bit back down into the high order byte of
the low order flags word.

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

Index: linux-2.6.17-rc1-mm2/include/linux/mmzone.h
=================================--- linux-2.6.17-rc1-mm2.orig/include/linux/mmzone.h	2006-04-12 12:07:22.000000000 -0400
+++ linux-2.6.17-rc1-mm2/include/linux/mmzone.h	2006-04-12 12:09:26.000000000 -0400
@@ -457,7 +457,7 @@ extern struct zone *next_zone(struct zon
 /*
  * with 64 bit flags field, there's plenty of room.
  */
-#define FLAGS_RESERVED		24
+#define FLAGS_RESERVED		32
 
 #else
 
Index: linux-2.6.17-rc1-mm2/include/linux/page-flags.h
=================================--- linux-2.6.17-rc1-mm2.orig/include/linux/page-flags.h	2006-04-12 12:07:22.000000000 -0400
+++ linux-2.6.17-rc1-mm2/include/linux/page-flags.h	2006-04-12 12:10:57.000000000 -0400
@@ -90,7 +90,7 @@
 #define PG_nosave_free		18	/* Free, should not be written */
 
 #if (BITS_PER_LONG > 32)
-#define PG_uncached		32	/* Page has been mapped as uncached */
+#define PG_uncached		24	/* Page has been mapped as uncached */
 #endif
 
 /*


