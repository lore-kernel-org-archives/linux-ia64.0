From: Christoph Lameter <clameter@sgi.com>
Date: Tue, 05 Sep 2006 18:56:51 +0000
Subject: SGI SN: Do not request DMA memory for BTE
Message-Id: <Pine.LNX.4.64.0609051156220.4442@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The GFP_DMA option usually does nothing on SN2 since all of memory is in thei
DMA zone and the BTE has always been capable of addressing all of memory.
So there is no need to get memory from a restricted range of memory (which
is what GFP_DMA is for).

Remove useless __GFP_DMA option.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.18-rc5/arch/ia64/sn/kernel/bte.c
=================================--- linux-2.6.18-rc5.orig/arch/ia64/sn/kernel/bte.c	2006-08-27 20:41:48.000000000 -0700
+++ linux-2.6.18-rc5/arch/ia64/sn/kernel/bte.c	2006-09-05 11:53:24.222878124 -0700
@@ -277,8 +277,7 @@ bte_result_t bte_unaligned_copy(u64 src,
 	}
 
 	/* temporary buffer used during unaligned transfers */
-	bteBlock_unaligned = kmalloc(len + 3 * L1_CACHE_BYTES,
-				     GFP_KERNEL | GFP_DMA);
+	bteBlock_unaligned = kmalloc(len + 3 * L1_CACHE_BYTES, GFP_KERNEL);
 	if (bteBlock_unaligned = NULL) {
 		return BTEFAIL_NOTAVAIL;
 	}
