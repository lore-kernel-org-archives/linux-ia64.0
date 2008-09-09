From: Robin Holt <holt@sgi.com>
Date: Tue, 09 Sep 2008 15:34:44 +0000
Subject: [Patch] fix up bte.h
Message-Id: <20080909153444.GC23082@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

bte.h expects a #define of L1_CACHE_MASK which is currently only
in bte.c.  This small patch gets bte.h to include cleanly and makes
BTE_UNALIGNED_COPY not report errors.

Signed-off-by: Robin Holt <holt@sgi.com>


Index: mmu_v17_xpmem_v004-2/include/asm-ia64/sn/bte.h
=================================--- mmu_v17_xpmem_v004-2.orig/arch/ia64/include/asm/sn/bte.h	2008-05-17 20:50:00.000000000 -0500
+++ mmu_v17_xpmem_v004-2/arch/ia64/include/asm/sn/bte.h	2008-05-17 20:53:46.000000000 -0500
@@ -223,10 +223,11 @@ extern void bte_error_handler(unsigned l
  * until the transfer is complete.  In order to get the asynch
  * version of bte_copy, you must perform this check yourself.
  */
-#define BTE_UNALIGNED_COPY(src, dest, len, mode)                        \
-	(((len & L1_CACHE_MASK) || (src & L1_CACHE_MASK) ||             \
-	  (dest & L1_CACHE_MASK)) ?                                     \
-	 bte_unaligned_copy(src, dest, len, mode) :              	\
+#define BTE_UNALIGNED_COPY(src, dest, len, mode)			\
+	(((len & (L1_CACHE_BYTES - 1)) ||				\
+	  (src & (L1_CACHE_BYTES - 1)) ||				\
+	  (dest & (L1_CACHE_BYTES - 1))) ?				\
+	 bte_unaligned_copy(src, dest, len, mode) :			\
 	 bte_copy(src, dest, len, mode, NULL))
 
 
