From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 14 Dec 2004 21:06:27 +0000
Subject: [patch] more swiotlb fixes
Message-Id: <16831.21971.77310.127388@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Tony,

Here are a few more swiotlb fixes.  By code-inspection, I found that
unmap_single() may end up trying to memcpy() to a NULL pointer (this
would happen in response to a call to swiotlb_free_coherent() on a
mapped buffer.

Also, swiotlb_alloc_coherent() may have needlessly returned memory
that is out of reach of the device.

Finally, I changed swiotlb_dma_supported() so it returns a meaningful
value.

Since this affects several platforms and architecture, I'm OK to put
scheduled this for 2.6.11 rather than 2.6.10.

Thanks,

	--david

ia64: Fix swiotlb some more:

    - don't fault in unmap_single() when unmapping a coherent buffer.
    - make swiotlb_alloc_coherent() more resilient for devices with
      weird DMA masks
    - make swiotlb_dma_supported() return a useful value

Signed-off-by: David Mosberger-Tang <davidm@hpl.hp.com>

diff -Nru a/arch/ia64/lib/swiotlb.c b/arch/ia64/lib/swiotlb.c
--- a/arch/ia64/lib/swiotlb.c	2004-12-14 13:03:01 -08:00
+++ b/arch/ia64/lib/swiotlb.c	2004-12-14 13:03:01 -08:00
@@ -243,7 +243,7 @@
 	/*
 	 * First, sync the memory before unmapping the entry
 	 */
-	if ((dir = DMA_FROM_DEVICE) || (dir = DMA_BIDIRECTIONAL))
+	if (buffer && ((dir = DMA_FROM_DEVICE) || (dir = DMA_BIDIRECTIONAL)))
 		/*
 		 * bounce... copy the data back into the original buffer * and delete the
 		 * bounce buffer.
@@ -300,13 +300,27 @@
 {
 	unsigned long dev_addr;
 	void *ret;
+	int order = get_order(size);
 
 	/* XXX fix me: the DMA API should pass us an explicit DMA mask instead: */
 	flags |= GFP_DMA;
 
-	ret = (void *)__get_free_pages(flags, get_order(size));
+	ret = (void *)__get_free_pages(flags, order);
+	if (ret && address_needs_mapping(hwdev, virt_to_phys(ret))) {
+		/*
+		 * The allocated memory isn't reachable by the device.
+		 * Fall back on swiotlb_map_single().
+		 */
+		free_pages((unsigned long) ret, order);
+		ret = NULL;
+	}
 	if (!ret) {
-		 /* DMA_FROM_DEVICE is to avoid the memcpy in map_single */
+		/*
+		 * We are either out of memory or the device can't DMA
+		 * to GFP_DMA memory; fall back on
+		 * swiotlb_map_single(), which will grab memory from
+		 * the lowest available address range.
+		 */
 		dma_addr_t handle;
 		handle = swiotlb_map_single(NULL, NULL, size, DMA_FROM_DEVICE);
 		if (dma_mapping_error(handle))
@@ -586,7 +600,7 @@
 int
 swiotlb_dma_supported (struct device *hwdev, u64 mask)
 {
-	return 1;
+	return (virt_to_phys (io_tlb_end) - 1) <= mask;
 }
 
 EXPORT_SYMBOL(swiotlb_init);
