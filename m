From: Robin Holt <holt@sgi.com>
Date: Wed, 04 Feb 2009 00:40:59 +0000
Subject: [Patch] bte_copy of BTE_MAX_XFER trips BUG_ON.
Message-Id: <20090204004059.GM8559@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Dean Nelson <dcn@sgi.com>, Russ Anderson <rja@sgi.com>


BTE_MAX_XFER is wrong.  It is one greater than the number of cache
lines the BTE is actually able to transfer.  If you request a transfer
of exactly BTE_MAX_XFER size, you trip a very cryptic BUG_ON() which
should certainly be made more clear.

This patch fixes that constant and also cleans up the BUG_ON()s in
arch/ia64/sn/kernel/bte.c to test one condition per line.

Signed-off-by: Robin Holt <holt@sgi.com>

---

 arch/ia64/include/asm/sn/bte.h |    2 +-
 arch/ia64/sn/kernel/bte.c      |    7 ++++---
 2 files changed, 5 insertions(+), 4 deletions(-)

Index: bte_max_xfer_fix/arch/ia64/include/asm/sn/bte.h
=================================--- bte_max_xfer_fix.orig/arch/ia64/include/asm/sn/bte.h	2009-02-03 18:07:26.000000000 -0600
+++ bte_max_xfer_fix/arch/ia64/include/asm/sn/bte.h	2009-02-03 18:09:38.749729353 -0600
@@ -39,7 +39,7 @@
 /* BTE status register only supports 16 bits for length field */
 #define BTE_LEN_BITS (16)
 #define BTE_LEN_MASK ((1 << BTE_LEN_BITS) - 1)
-#define BTE_MAX_XFER ((1 << BTE_LEN_BITS) * L1_CACHE_BYTES)
+#define BTE_MAX_XFER (BTE_LEN_MASK << L1_CACHE_SHIFT)
 
 
 /* Define hardware */
Index: bte_max_xfer_fix/arch/ia64/sn/kernel/bte.c
=================================--- bte_max_xfer_fix.orig/arch/ia64/sn/kernel/bte.c	2009-02-03 18:07:26.000000000 -0600
+++ bte_max_xfer_fix/arch/ia64/sn/kernel/bte.c	2009-02-03 18:15:42.854040475 -0600
@@ -97,9 +97,10 @@ bte_result_t bte_copy(u64 src, u64 dest,
 		return BTE_SUCCESS;
 	}
 
-	BUG_ON((len & L1_CACHE_MASK) ||
-		 (src & L1_CACHE_MASK) || (dest & L1_CACHE_MASK));
-	BUG_ON(!(len < ((BTE_LEN_MASK + 1) << L1_CACHE_SHIFT)));
+	BUG_ON(len & L1_CACHE_MASK);
+	BUG_ON(src & L1_CACHE_MASK);
+	BUG_ON(dest & L1_CACHE_MASK);
+	BUG_ON(len > BTE_MAX_XFER);
 
 	/*
 	 * Start with interface corresponding to cpu number
