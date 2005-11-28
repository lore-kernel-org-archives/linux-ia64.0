From: Yasunori Goto <y-goto@jp.fujitsu.com>
Date: Mon, 28 Nov 2005 11:36:10 +0000
Subject: [Patch] New zone ZONE_EASY_RECLAIM take 2[1/5]
Message-Id: <20051128200009.5D7A.Y-GOTO@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051128195854.5D78.Y-GOTO@jp.fujitsu.com>
In-Reply-To: <20051128195854.5D78.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-mm <linux-mm@kvack.org>, Linux Hotplug Memory Support <lhms-devel@lists.sourceforge.net>
Cc: Joel Schopp <jschopp@austin.ibm.com>, linux-ia64@vger.kernel.org

This defines __GFP flag for new zone with GFP_DMA32.


Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>

Index: new_zone_mm/include/linux/gfp.h
=================================--- new_zone_mm.orig/include/linux/gfp.h	2005-11-17 16:47:04.000000000 +0900
+++ new_zone_mm/include/linux/gfp.h	2005-11-17 17:29:16.000000000 +0900
@@ -16,10 +16,13 @@ struct vm_area_struct;
 #define __GFP_HIGHMEM	((__force gfp_t)0x02u)
 #ifdef CONFIG_DMA_IS_DMA32
 #define __GFP_DMA32	((__force gfp_t)0x01)	/* ZONE_DMA is ZONE_DMA32 */
+#define __GFP_EASY_RECLAIM ((__force gfp_t)0x04u)
 #elif BITS_PER_LONG < 64
 #define __GFP_DMA32	((__force gfp_t)0x00)	/* ZONE_NORMAL is ZONE_DMA32 */
+#define __GFP_EASY_RECLAIM ((__force gfp_t)0x04u)
 #else
 #define __GFP_DMA32	((__force gfp_t)0x04)	/* Has own ZONE_DMA32 */
+#define __GFP_EASY_RECLAIM ((__force gfp_t)0x08u)
 #endif
 
 /*
@@ -66,7 +69,7 @@ struct vm_area_struct;
 #define GFP_USER	(__GFP_VALID | __GFP_WAIT | __GFP_IO | __GFP_FS | \
 				__GFP_HARDWALL)
 #define GFP_HIGHUSER	(__GFP_VALID | __GFP_WAIT | __GFP_IO | __GFP_FS | \
-				__GFP_HIGHMEM | __GFP_HARDWALL)
+				__GFP_HIGHMEM | __GFP_HARDWALL | __GFP_EASY_RECLAIM)
 
 /* Flag - indicates that the buffer will be suitable for DMA.  Ignored on some
    platforms, used as appropriate on others */
Index: new_zone_mm/include/linux/mmzone.h
=================================--- new_zone_mm.orig/include/linux/mmzone.h	2005-11-17 16:47:04.000000000 +0900
+++ new_zone_mm/include/linux/mmzone.h	2005-11-17 17:29:01.000000000 +0900
@@ -92,7 +92,7 @@ struct per_cpu_pageset {
  * be 8 (2 ** 3) zonelists.  GFP_ZONETYPES defines the number of possible
  * combinations of zone modifiers in "zone modifier space".
  */
-#define GFP_ZONEMASK	0x03
+#define GFP_ZONEMASK	0x0f
 
 /*
  * As an optimisation any zone modifier bits which are only valid when

-- 
Yasunori Goto 


