From: Christoph Hellwig <hch@lst.de>
Date: Fri, 07 Dec 2018 19:07:09 +0000
Subject: [PATCH 04/15] dma-direct: use dma_direct_map_page to implement dma_direct_map_sg
Message-Id: <20181207190720.18517-5-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20181207190720.18517-1-hch@lst.de>
In-Reply-To: <20181207190720.18517-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: iommu@lists.linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>, Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Tariq Toukan <tariqt@mellanox.com>, Ilias Apalodimas <ilias.apalodimas@linaro.org>, =?UTF-8?q?Toke=20H=C3=B8iland-J=C3=B8rgensen?= <toke@toke.dk>, Robin Murphy <robin.murphy@arm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Keith Busch <keith.busch@intel.com>, Jonathan Derrick <jonathan.derrick@intel.com>, linux-pci@vger.kernel.org, linux-ia64@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org

No need to duplicate the mapping logic.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 kernel/dma/direct.c | 14 +++++---------
 1 file changed, 5 insertions(+), 9 deletions(-)

diff --git a/kernel/dma/direct.c b/kernel/dma/direct.c
index edb24f94ea1e..d45306473c90 100644
--- a/kernel/dma/direct.c
+++ b/kernel/dma/direct.c
@@ -217,6 +217,7 @@ static void dma_direct_sync_single_for_device(struct device *dev,
 	arch_sync_dma_for_device(dev, dma_to_phys(dev, addr), size, dir);
 }
 
+#if defined(CONFIG_ARCH_HAS_SYNC_DMA_FOR_DEVICE)
 static void dma_direct_sync_sg_for_device(struct device *dev,
 		struct scatterlist *sgl, int nents, enum dma_data_direction dir)
 {
@@ -229,6 +230,7 @@ static void dma_direct_sync_sg_for_device(struct device *dev,
 	for_each_sg(sgl, sg, nents, i)
 		arch_sync_dma_for_device(dev, sg_phys(sg), sg->length, dir);
 }
+#endif
 
 #if defined(CONFIG_ARCH_HAS_SYNC_DMA_FOR_CPU) || \
     defined(CONFIG_ARCH_HAS_SYNC_DMA_FOR_CPU_ALL)
@@ -294,19 +296,13 @@ int dma_direct_map_sg(struct device *dev, struct scatterlist *sgl, int nents,
 	struct scatterlist *sg;
 
 	for_each_sg(sgl, sg, nents, i) {
-		BUG_ON(!sg_page(sg));
-
-		sg_dma_address(sg) = phys_to_dma(dev, sg_phys(sg));
-		if (unlikely(dev && !dma_capable(dev, sg_dma_address(sg),
-				sg->length))) {
-			report_addr(dev, sg_dma_address(sg), sg->length);
+		sg->dma_address = dma_direct_map_page(dev, sg_page(sg),
+				sg->offset, sg->length, dir, attrs);
+		if (sg->dma_address = DMA_MAPPING_ERROR)
 			return 0;
-		}
 		sg_dma_len(sg) = sg->length;
 	}
 
-	if (!(attrs & DMA_ATTR_SKIP_CPU_SYNC))
-		dma_direct_sync_sg_for_device(dev, sgl, nents, dir);
 	return nents;
 }
 
-- 
2.19.1
