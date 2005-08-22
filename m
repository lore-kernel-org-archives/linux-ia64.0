From: Greg Edwards <edwardsg@sgi.com>
Date: Mon, 22 Aug 2005 16:56:40 +0000
Subject: Re: clean up sn2 region definitions
Message-Id: <20050822165640.GA27798@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050819215218.GA21689@sgi.com>
In-Reply-To: <20050819215218.GA21689@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Clean up some duplicate region definitions in sn2 code.  Requires Peter's
patch:

Rationalise Region Definitions
http://marc.theaimsgroup.com/?l=linux-ia64&m2424745806814&w=2

Signed-off-by: Greg Edwards <edwardsg@sgi.com>


 include/asm-ia64/page.h     |    4 ++--
 include/asm-ia64/sn/addrs.h |   33 ++++++++++++---------------------
 2 files changed, 14 insertions(+), 23 deletions(-)

Index: git-linus/include/asm-ia64/sn/addrs.h
=================================--- git-linus.orig/include/asm-ia64/sn/addrs.h	2005-08-22 11:04:29.433021279 -0500
+++ git-linus/include/asm-ia64/sn/addrs.h	2005-08-22 11:36:05.949306622 -0500
@@ -65,7 +65,6 @@
 
 #define NASID_MASK              ((u64)NASID_BITMASK << NASID_SHIFT)
 #define AS_MASK			((u64)AS_BITMASK << AS_SHIFT)
-#define REGION_BITS		0xe000000000000000UL
 
 
 /*
@@ -79,38 +78,30 @@
 #define AS_CAC_SPACE		(AS_CAC_VAL << AS_SHIFT)
 
 
-/*
- * Base addresses for various address ranges.
- */
-#define CACHED			0xe000000000000000UL
-#define UNCACHED                0xc000000000000000UL
-#define UNCACHED_PHYS           0x8000000000000000UL
-
-
 /* 
  * Virtual Mode Local & Global MMR space.  
  */
 #define SH1_LOCAL_MMR_OFFSET	0x8000000000UL
 #define SH2_LOCAL_MMR_OFFSET	0x0200000000UL
 #define LOCAL_MMR_OFFSET	(is_shub2() ? SH2_LOCAL_MMR_OFFSET : SH1_LOCAL_MMR_OFFSET)
-#define LOCAL_MMR_SPACE		(UNCACHED | LOCAL_MMR_OFFSET)
-#define LOCAL_PHYS_MMR_SPACE	(UNCACHED_PHYS | LOCAL_MMR_OFFSET)
+#define LOCAL_MMR_SPACE		(__IA64_UNCACHED_OFFSET | LOCAL_MMR_OFFSET)
+#define LOCAL_PHYS_MMR_SPACE	(RGN_BASE(RGN_HPAGE) | LOCAL_MMR_OFFSET)
 
 #define SH1_GLOBAL_MMR_OFFSET	0x0800000000UL
 #define SH2_GLOBAL_MMR_OFFSET	0x0300000000UL
 #define GLOBAL_MMR_OFFSET	(is_shub2() ? SH2_GLOBAL_MMR_OFFSET : SH1_GLOBAL_MMR_OFFSET)
-#define GLOBAL_MMR_SPACE	(UNCACHED | GLOBAL_MMR_OFFSET)
+#define GLOBAL_MMR_SPACE	(__IA64_UNCACHED_OFFSET | GLOBAL_MMR_OFFSET)
 
 /*
  * Physical mode addresses
  */
-#define GLOBAL_PHYS_MMR_SPACE	(UNCACHED_PHYS | GLOBAL_MMR_OFFSET)
+#define GLOBAL_PHYS_MMR_SPACE	(RGN_BASE(RGN_HPAGE) | GLOBAL_MMR_OFFSET)
 
 
 /*
  * Clear region & AS bits.
  */
-#define TO_PHYS_MASK		(~(REGION_BITS | AS_MASK))
+#define TO_PHYS_MASK		(~(RGN_BITS | AS_MASK))
 
 
 /*
@@ -134,10 +125,10 @@
 /*
  * general address defines
  */
-#define CAC_BASE		(CACHED   | AS_CAC_SPACE)
-#define AMO_BASE		(UNCACHED | AS_AMO_SPACE)
-#define AMO_PHYS_BASE		(UNCACHED_PHYS | AS_AMO_SPACE)
-#define GET_BASE		(CACHED   | AS_GET_SPACE)
+#define CAC_BASE		(PAGE_OFFSET | AS_CAC_SPACE)
+#define AMO_BASE		(__IA64_UNCACHED_OFFSET | AS_AMO_SPACE)
+#define AMO_PHYS_BASE		(RGN_BASE(RGN_HPAGE) | AS_AMO_SPACE)
+#define GET_BASE		(PAGE_OFFSET | AS_GET_SPACE)
 
 /*
  * Convert Memory addresses between various addressing modes.
@@ -164,8 +155,8 @@
 /*
  * Macros to test for address type.
  */
-#define IS_AMO_ADDRESS(x)	(((u64)(x) & (REGION_BITS | AS_MASK)) = AMO_BASE)
-#define IS_AMO_PHYS_ADDRESS(x)	(((u64)(x) & (REGION_BITS | AS_MASK)) = AMO_PHYS_BASE)
+#define IS_AMO_ADDRESS(x)	(((u64)(x) & (RGN_BITS | AS_MASK)) = AMO_BASE)
+#define IS_AMO_PHYS_ADDRESS(x)	(((u64)(x) & (RGN_BITS | AS_MASK)) = AMO_PHYS_BASE)
 
 
 /*
@@ -180,7 +171,7 @@
 #define TIO_SWIN_BASE(n, w) 		(TIO_IO_BASE(n) + \
 					    ((u64) (w) << TIO_SWIN_SIZE_BITS))
 #define NODE_IO_BASE(n)			(GLOBAL_MMR_SPACE | NASID_SPACE(n))
-#define TIO_IO_BASE(n)                  (UNCACHED | NASID_SPACE(n))
+#define TIO_IO_BASE(n)                  (__IA64_UNCACHED_OFFSET | NASID_SPACE(n))
 #define BWIN_SIZE			(1UL << BWIN_SIZE_BITS)
 #define NODE_BWIN_BASE0(n)		(NODE_IO_BASE(n) + BWIN_SIZE)
 #define NODE_BWIN_BASE(n, w)		(NODE_BWIN_BASE0(n) + ((u64) (w) << BWIN_SIZE_BITS))
Index: git-linus/include/asm-ia64/page.h
=================================--- git-linus.orig/include/asm-ia64/page.h	2005-08-22 11:04:47.017198369 -0500
+++ git-linus/include/asm-ia64/page.h	2005-08-22 11:40:46.383166216 -0500
@@ -17,9 +17,9 @@
  * Different regions are assigned to different purposes.
  */
 #define RGN_SHIFT	(61)
-#define RGN_BASE(r)  (__IA64_UL_CONST(r)<<RGN_SHIFT)
+#define RGN_BASE(r)	(__IA64_UL_CONST(r)<<RGN_SHIFT)
+#define RGN_BITS	(RGN_BASE(-1))
 
-#define KHIGH -1	/* high three bits of Kernel virtual address */
 #define RGN_KERNEL	7	/* Identity mapped region */
 #define RGN_UNCACHED    6	/* Identity mapped I/O region */
 #define RGN_GATE	5	/* Gate page, Kernel text, etc */
