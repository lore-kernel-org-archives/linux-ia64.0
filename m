From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 14 Dec 2004 18:21:00 +0000
Subject: [patch] fix bug in DMA-zone initialization
Message-Id: <16831.12044.183669.712504@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Tony,

Below is a patch that fixes count_dma_pages().  Without this fix, only
memory areas entirely below MAX_DMA_ADDRESS are counted as DMA-pages.
While it doesn't really make a difference in practice (MAX_DMA_ADDRESS
is equal to ~0UL on zx1), it's clearly not what was intended to be
there.  I found the bug only because I briefly experimented with
lowering MAX_DMA_ADDRESS.

Thanks,

	--david

Signed-off-by: David Mosberger-Tang <davidm@hpl.hp.com>

=== arch/ia64/mm/contig.c 1.9 vs edited ==--- 1.9/arch/ia64/mm/contig.c	2004-10-05 11:19:51 -07:00
+++ edited/arch/ia64/mm/contig.c	2004-12-13 23:38:44 -08:00
@@ -214,8 +214,8 @@
 {
 	unsigned long *count = arg;
 
-	if (end <= MAX_DMA_ADDRESS)
-		*count += (end - start) >> PAGE_SHIFT;
+	if (start < MAX_DMA_ADDRESS)
+		*count += (min(end, MAX_DMA_ADDRESS) - start) >> PAGE_SHIFT;
 	return 0;
 }
 #endif
