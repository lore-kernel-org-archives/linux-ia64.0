From: Colin Ngam <cngam@sgi.com>
Date: Tue, 10 May 2005 16:12:01 +0000
Subject: [PATCH 2.6.12 0/0] Altix only: Fix TIO IOSPACE MMR Addres Generation.
Message-Id: <20050510161201.12511.76484.65526@attica.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Hi Tony,

This patches provides support on Shub2 for the separate TIO IOSPACE MMR.  This 
patch is SN specific.

Thanks.

Signed-off-by: Colin Ngam <cngam@sgi.com>

Index: linux-2.6/include/asm-ia64/sn/addrs.h
=================================--- linux-2.6.orig/include/asm-ia64/sn/addrs.h	2005-05-10 09:44:04.375051969 -0500
+++ linux-2.6/include/asm-ia64/sn/addrs.h	2005-05-10 09:49:09.558738992 -0500
@@ -216,6 +216,10 @@
 #define TIO_SWIN_WIDGETNUM(x)		(((x)  >> TIO_SWIN_SIZE_BITS) & TIO_SWIN_WIDGET_MASK)
 
 
+#define TIO_IOSPACE_ADDR(n,x)					\
+	/* Move in the Chiplet ID for TIO Local Block MMR */	\
+	(REMOTE_ADDR(n,x) | 1UL << (NASID_SHIFT - 2))
+
 /*
  * The following macros produce the correct base virtual address for
  * the hub registers. The REMOTE_HUB_* macro produce
@@ -233,13 +237,16 @@
 #define REMOTE_HUB_ADDR(n,x)						\
 	((n & 1) ?							\
 	/* TIO: */							\
-	((volatile u64 *)(GLOBAL_MMR_ADDR(n,x)))			\
-	: /* SHUB: */							\
-	(((x) & BWIN_TOP) ? ((volatile u64 *)(GLOBAL_MMR_ADDR(n,x)))\
+	(is_shub2() ?							\
+	/* TIO on Shub2 */						\
+	(volatile u64 *)(TIO_IOSPACE_ADDR(n,x))				\
+	: /* TIO on shub1 */						\
+	(volatile u64 *)(GLOBAL_MMR_ADDR(n,x)))				\
+									\
+	: /* SHUB1 and SHUB2 MMRs: */					\
+	(((x) & BWIN_TOP) ? ((volatile u64 *)(GLOBAL_MMR_ADDR(n,x)))	\
 	: ((volatile u64 *)(NODE_SWIN_BASE(n,1) + 0x800000 + (x)))))
 
-
-
 #define HUB_L(x)			(*((volatile typeof(*x) *)x))
 #define	HUB_S(x,d)			(*((volatile typeof(*x) *)x) = (d))
 
