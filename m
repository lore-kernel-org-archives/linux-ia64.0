From: Christoph Hellwig <hch@lst.de>
Date: Mon, 30 Jul 2018 16:38:06 +0000
Subject: [PATCH 02/20] kernel/dma/direct: refine dma_direct_alloc zone selection
Message-Id: <20180730163824.10064-3-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180730163824.10064-1-hch@lst.de>
In-Reply-To: <20180730163824.10064-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Robin Murphy <robin.murphy@arm.com>, linuxppc-dev@lists.ozlabs.org, iommu@lists.linux-foundation.org, linux-ia64@vger.kernel.org

We need to take the DMA offset and encryption bit into account when selecting
a zone.  Add a helper that takes those into account and use it.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 kernel/dma/direct.c | 16 ++++++++++++----
 1 file changed, 12 insertions(+), 4 deletions(-)

diff --git a/kernel/dma/direct.c b/kernel/dma/direct.c
index d32d4f0d2c0c..c2c1df8827f2 100644
--- a/kernel/dma/direct.c
+++ b/kernel/dma/direct.c
@@ -58,6 +58,14 @@ static bool dma_coherent_ok(struct device *dev, phys_addr_t phys, size_t size)
 	return addr + size - 1 <= dev->coherent_dma_mask;
 }
 
+static bool dma_coherent_below(struct device *dev, u64 mask)
+{
+	dma_addr_t addr = force_dma_unencrypted() ?
+		__phys_to_dma(dev, mask) : phys_to_dma(dev, mask);
+
+	return dev->coherent_dma_mask <= addr;
+}
+
 void *dma_direct_alloc(struct device *dev, size_t size, dma_addr_t *dma_handle,
 		gfp_t gfp, unsigned long attrs)
 {
@@ -70,9 +78,9 @@ void *dma_direct_alloc(struct device *dev, size_t size, dma_addr_t *dma_handle,
 	gfp &= ~__GFP_ZERO;
 
 	/* GFP_DMA32 and GFP_DMA are no ops without the corresponding zones: */
-	if (dev->coherent_dma_mask <= DMA_BIT_MASK(ARCH_ZONE_DMA_BITS))
+	if (dma_coherent_below(dev, DMA_BIT_MASK(ARCH_ZONE_DMA_BITS)))
 		gfp |= GFP_DMA;
-	if (dev->coherent_dma_mask <= DMA_BIT_MASK(32) && !(gfp & GFP_DMA))
+	if (dma_coherent_below(dev, DMA_BIT_MASK(32) && !(gfp & GFP_DMA)))
 		gfp |= GFP_DMA32;
 
 again:
@@ -92,14 +100,14 @@ void *dma_direct_alloc(struct device *dev, size_t size, dma_addr_t *dma_handle,
 		page = NULL;
 
 		if (IS_ENABLED(CONFIG_ZONE_DMA32) &&
-		    dev->coherent_dma_mask < DMA_BIT_MASK(64) &&
+		    dma_coherent_below(dev, DMA_BIT_MASK(64)) &&
 		    !(gfp & (GFP_DMA32 | GFP_DMA))) {
 			gfp |= GFP_DMA32;
 			goto again;
 		}
 
 		if (IS_ENABLED(CONFIG_ZONE_DMA) &&
-		    dev->coherent_dma_mask < DMA_BIT_MASK(32) &&
+		    dma_coherent_below(dev, DMA_BIT_MASK(32)) &&
 		    !(gfp & GFP_DMA)) {
 			gfp = (gfp & ~GFP_DMA32) | GFP_DMA;
 			goto again;
-- 
2.18.0

