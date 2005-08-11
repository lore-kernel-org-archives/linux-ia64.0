From: Jack Steiner <steiner@sgi.com>
Date: Thu, 11 Aug 2005 17:25:24 +0000
Subject: [PATCH 1/7] - New SN hardware support - addr_macros
Message-Id: <20050811172524.GA17747@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Update the SN address macros so that they work on both shub1 
and shub2. Most of the code to support shub2 was added last year
but this patch fixes a few bugs and adds macros to help generate
both processor-specific physical addresses & numalink physical
addresses. More cleanup & optimization will be done later.


	Signed-off-by: Jack Steiner <steiner@sgi.com>




Index: linux/include/asm-ia64/sn/addrs.h
=================================--- linux.orig/include/asm-ia64/sn/addrs.h	2005-08-09 16:01:56.796624102 -0500
+++ linux/include/asm-ia64/sn/addrs.h	2005-08-10 14:30:07.055771427 -0500
@@ -3,7 +3,7 @@
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
  *
- * Copyright (c) 1992-1999,2001-2004 Silicon Graphics, Inc. All rights reserved.
+ * Copyright (c) 1992-1999,2001-2005 Silicon Graphics, Inc. All rights reserved.
  */
 
 #ifndef _ASM_IA64_SN_ADDRS_H
@@ -126,6 +126,7 @@
 #define GLOBAL_MMR_PHYS_ADDR(n,a) (GLOBAL_PHYS_MMR_SPACE | REMOTE_ADDR(n,a))
 #define GLOBAL_CAC_ADDR(n,a)	(CAC_BASE | REMOTE_ADDR(n,a))
 #define CHANGE_NASID(n,x)	((void *)(((u64)(x) & ~NASID_MASK) | NASID_SPACE(n)))
+#define IS_TIO_NASID(n)		((n) & 1)
 
 
 /* non-II mmr's start at top of big window space (4G) */
@@ -155,10 +156,28 @@
  *           the chiplet id is zero.  If we implement TIO-TIO dma, we might need
  *           to insert a chiplet id into this macro.  However, it is our belief
  *           right now that this chiplet id will be ICE, which is also zero.
- *           Nasid starts on bit 40.
  */
-#define PHYS_TO_TIODMA(x)	( (((u64)(NASID_GET(x))) << 40) | NODE_OFFSET(x))
-#define PHYS_TO_DMA(x)          ( (((u64)(x) & NASID_MASK) >> 2) | NODE_OFFSET(x))
+#define SH1_TIO_PHYS_TO_DMA(x) 						\
+	((((u64)(NASID_GET(x))) << 40) | NODE_OFFSET(x))
+
+#define SH2_NETWORK_BANK_OFFSET(x) 					\
+        ((u64)(x) & ((1UL << (sn_hub_info->nasid_shift - 4)) -1))
+
+#define SH2_NETWORK_BANK_SELECT(x) 					\
+        ((((u64)(x) & (0x3UL << (sn_hub_info->nasid_shift - 4)))	\
+        	>> (sn_hub_info->nasid_shift - 4)) << 36)
+
+#define SH2_NETWORK_ADDRESS(x) 						\
+	(SH2_NETWORK_BANK_OFFSET(x) | SH2_NETWORK_BANK_SELECT(x))
+
+#define SH2_TIO_PHYS_TO_DMA(x) 						\
+        (((u64)(NASID_GET(x)) << 40) | 	SH2_NETWORK_ADDRESS(x))
+
+#define PHYS_TO_TIODMA(x)						\
+	(is_shub1() ? SH1_TIO_PHYS_TO_DMA(x) : SH2_TIO_PHYS_TO_DMA(x))
+
+#define PHYS_TO_DMA(x)							\
+	((((u64)(x) & NASID_MASK) >> 2) | NODE_OFFSET(x))
 
 
 /*
@@ -187,6 +206,7 @@
 #define RAW_NODE_SWIN_BASE(n, w)	(NODE_IO_BASE(n) + ((u64) (w) << SWIN_SIZE_BITS))
 #define BWIN_WIDGET_MASK		0x7
 #define BWIN_WINDOWNUM(x)		(((x) >> BWIN_SIZE_BITS) & BWIN_WIDGET_MASK)
+#define SH1_IS_BIG_WINDOW_ADDR(x)	((x) & BWIN_TOP)
 
 #define TIO_BWIN_WINDOW_SELECT_MASK	0x7
 #define TIO_BWIN_WINDOWNUM(x)		(((x) >> TIO_BWIN_SIZE_BITS) & TIO_BWIN_WINDOW_SELECT_MASK)
@@ -216,10 +236,6 @@
 #define TIO_SWIN_WIDGETNUM(x)		(((x)  >> TIO_SWIN_SIZE_BITS) & TIO_SWIN_WIDGET_MASK)
 
 
-#define TIO_IOSPACE_ADDR(n,x)					\
-	/* Move in the Chiplet ID for TIO Local Block MMR */	\
-	(REMOTE_ADDR(n,x) | 1UL << (NASID_SHIFT - 2))
-
 /*
  * The following macros produce the correct base virtual address for
  * the hub registers. The REMOTE_HUB_* macro produce
@@ -234,18 +250,40 @@
  *	Otherwise, the recommended approach is to use *_HUB_L() and *_HUB_S().
  *	They're always safe.
  */
+/* Shub1 TIO & MMR addressing macros */
+#define SH1_TIO_IOSPACE_ADDR(n,x)					\
+	GLOBAL_MMR_ADDR(n,x)
+
+#define SH1_REMOTE_BWIN_MMR(n,x)					\
+	GLOBAL_MMR_ADDR(n,x)
+
+#define SH1_REMOTE_SWIN_MMR(n,x)					\
+	(NODE_SWIN_BASE(n,1) + 0x800000UL + (x))
+
+#define SH1_REMOTE_MMR(n,x)						\
+	(SH1_IS_BIG_WINDOW_ADDR(x) ? SH1_REMOTE_BWIN_MMR(n,x) :		\
+	 	SH1_REMOTE_SWIN_MMR(n,x))
+
+/* Shub1 TIO & MMR addressing macros */
+#define SH2_TIO_IOSPACE_ADDR(n,x)					\
+	((UNCACHED | REMOTE_ADDR(n,x) | 1UL << (NASID_SHIFT - 2)))
+
+#define SH2_REMOTE_MMR(n,x)						\
+	GLOBAL_MMR_ADDR(n,x)
+
+
+/* TIO & MMR addressing macros that work on both shub1 & shub2 */
+#define TIO_IOSPACE_ADDR(n,x)						\
+	((u64 *)(is_shub1() ? SH1_TIO_IOSPACE_ADDR(n,x) :		\
+		 SH2_TIO_IOSPACE_ADDR(n,x)))
+
+#define SH_REMOTE_MMR(n,x)						\
+	(is_shub1() ? SH1_REMOTE_MMR(n,x) : SH2_REMOTE_MMR(n,x))
+
 #define REMOTE_HUB_ADDR(n,x)						\
-	((n & 1) ?							\
-	/* TIO: */							\
-	(is_shub2() ?							\
-	/* TIO on Shub2 */						\
-	(volatile u64 *)(TIO_IOSPACE_ADDR(n,x))				\
-	: /* TIO on shub1 */						\
-	(volatile u64 *)(GLOBAL_MMR_ADDR(n,x)))				\
-									\
-	: /* SHUB1 and SHUB2 MMRs: */					\
-	(((x) & BWIN_TOP) ? ((volatile u64 *)(GLOBAL_MMR_ADDR(n,x)))	\
-	: ((volatile u64 *)(NODE_SWIN_BASE(n,1) + 0x800000 + (x)))))
+	(IS_TIO_NASID(n) ?  ((volatile u64*)TIO_IOSPACE_ADDR(n,x)) :	\
+	 ((volatile u64*)SH_REMOTE_MMR(n,x)))
+
 
 #define HUB_L(x)			(*((volatile typeof(*x) *)x))
 #define	HUB_S(x,d)			(*((volatile typeof(*x) *)x) = (d))
-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


