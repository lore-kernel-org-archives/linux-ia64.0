From: Andrew Morton <akpm@osdl.org>
Date: Wed, 12 Apr 2006 20:20:04 +0000
Subject: Re: [PATCH 2.6.17-rc1-mm2] pg_uncached-is-ia64-only-fix
Message-Id: <20060412132004.121fb014.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1144859883.5229.6.camel@localhost.localdomain>
In-Reply-To: <1144859883.5229.6.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Lee Schermerhorn <Lee.Schermerhorn@hp.com> wrote:
>
> This patch restores the 64-bit system FLAGS_RESERVED to 32 and
>  moves the PG_uncached bit back down into the high order byte of
>  the low order flags word.

Yes, that's what the persent version of that patch does (I made it bit 31,
so 64-bit-only flags can work their way downwards).

It's a bit sad that we're using all 32 of the high-order bits.  We might
need to revisit that later, if flags get tighter.



From: Andrew Morton <akpm@osdl.org>

As Nick points out, only ia64 uses PG_uncached.  So we can push it up into the
higher bits of the lower half of page->flags and make room for another flag on
32-bit machines.

Cc: "Luck, Tony" <tony.luck@intel.com>
Cc: Jesse Barnes <jbarnes@sgi.com>
Cc: Jes Sorensen <jes@trained-monkey.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andy Whitcroft <apw@shadowen.org>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

diff -puN include/linux/page-flags.h~pg_uncached-is-ia64-only include/linux/page-flags.h
--- devel/include/linux/page-flags.h~pg_uncached-is-ia64-only	2006-04-09 23:08:43.000000000 -0700
+++ devel-akpm/include/linux/page-flags.h	2006-04-09 23:09:13.000000000 -0700
@@ -7,6 +7,8 @@
 
 #include <linux/percpu.h>
 #include <linux/cache.h>
+#include <linux/types.h>
+
 #include <asm/pgtable.h>
 
 /*
@@ -88,7 +90,17 @@
 #define PG_nosave_free		18	/* Free, should not be written */
 #define PG_buddy		19	/* Page is free, on buddy lists */
 
-#define PG_uncached		20	/* Page has been mapped as uncached */
+
+#if (BITS_PER_LONG > 32)
+/*
+ * 64-bit-only flags build down from bit 31
+ *
+ * 32 bit  -------------------------------| FIELDS |       FLAGS         |
+ * 64 bit  |           FIELDS             | ??????         FLAGS         |
+ *         63                            32                              0
+ */
+#define PG_uncached		31	/* Page has been mapped as uncached */
+#endif
 
 /*
  * Global page accounting.  One instance per CPU.  Only unsigned longs are

