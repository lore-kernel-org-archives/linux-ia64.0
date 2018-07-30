From: Christoph Hellwig <hch@lst.de>
Date: Mon, 30 Jul 2018 16:38:05 +0000
Subject: [PATCH 01/20] kernel/dma/direct: take DMA offset into account in dma_direct_supported
Message-Id: <20180730163824.10064-2-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180730163824.10064-1-hch@lst.de>
In-Reply-To: <20180730163824.10064-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Robin Murphy <robin.murphy@arm.com>, linuxppc-dev@lists.ozlabs.org, iommu@lists.linux-foundation.org, linux-ia64@vger.kernel.org

When a device has a DMA offset the dma capable result will change due
to the difference between the physical and DMA address.  Take that into
account.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 kernel/dma/direct.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/kernel/dma/direct.c b/kernel/dma/direct.c
index 8be8106270c2..d32d4f0d2c0c 100644
--- a/kernel/dma/direct.c
+++ b/kernel/dma/direct.c
@@ -167,7 +167,7 @@ int dma_direct_map_sg(struct device *dev, struct scatterlist *sgl, int nents,
 int dma_direct_supported(struct device *dev, u64 mask)
 {
 #ifdef CONFIG_ZONE_DMA
-	if (mask < DMA_BIT_MASK(ARCH_ZONE_DMA_BITS))
+	if (mask < phys_to_dma(dev, DMA_BIT_MASK(ARCH_ZONE_DMA_BITS)))
 		return 0;
 #else
 	/*
@@ -176,14 +176,14 @@ int dma_direct_supported(struct device *dev, u64 mask)
 	 * memory, or by providing a ZONE_DMA32.  If neither is the case, the
 	 * architecture needs to use an IOMMU instead of the direct mapping.
 	 */
-	if (mask < DMA_BIT_MASK(32))
+	if (mask < phys_to_dma(dev, DMA_BIT_MASK(32)))
 		return 0;
 #endif
 	/*
 	 * Various PCI/PCIe bridges have broken support for > 32bit DMA even
 	 * if the device itself might support it.
 	 */
-	if (dev->dma_32bit_limit && mask > DMA_BIT_MASK(32))
+	if (dev->dma_32bit_limit && mask > phys_to_dma(dev, DMA_BIT_MASK(32)))
 		return 0;
 	return 1;
 }
-- 
2.18.0

