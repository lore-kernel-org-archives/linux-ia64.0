From: Christoph Hellwig <hch@lst.de>
Date: Fri, 30 Nov 2018 13:22:17 +0000
Subject: [PATCH 09/23] parisc/sba_iommu: remove the mapping_error dma_map_ops method
Message-Id: <20181130132231.16512-10-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20181130132231.16512-1-hch@lst.de>
In-Reply-To: <20181130132231.16512-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: iommu@lists.linux-foundation.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Jon Mason <jdmason@kudzu.us>, Joerg Roedel <joro@8bytes.org>, David Woodhouse <dwmw2@infradead.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Robin Murphy <robin.murphy@arm.com>, x86@kernel.org, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, xen-devel@lists.xenproject.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

The SBA iommu code already returns (~(dma_addr_t)0x0) on mapping
failures, so we can switch over to returning DMA_MAPPING_ERROR and let
the core dma-mapping code handle the rest.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 drivers/parisc/sba_iommu.c | 10 +---------
 1 file changed, 1 insertion(+), 9 deletions(-)

diff --git a/drivers/parisc/sba_iommu.c b/drivers/parisc/sba_iommu.c
index c1e599a429af..452d306ce5cb 100644
--- a/drivers/parisc/sba_iommu.c
+++ b/drivers/parisc/sba_iommu.c
@@ -93,8 +93,6 @@
 
 #define DEFAULT_DMA_HINT_REG	0
 
-#define SBA_MAPPING_ERROR    (~(dma_addr_t)0)
-
 struct sba_device *sba_list;
 EXPORT_SYMBOL_GPL(sba_list);
 
@@ -725,7 +723,7 @@ sba_map_single(struct device *dev, void *addr, size_t size,
 
 	ioc = GET_IOC(dev);
 	if (!ioc)
-		return SBA_MAPPING_ERROR;
+		return DMA_MAPPING_ERROR;
 
 	/* save offset bits */
 	offset = ((dma_addr_t) (long) addr) & ~IOVP_MASK;
@@ -1080,11 +1078,6 @@ sba_unmap_sg(struct device *dev, struct scatterlist *sglist, int nents,
 
 }
 
-static int sba_mapping_error(struct device *dev, dma_addr_t dma_addr)
-{
-	return dma_addr = SBA_MAPPING_ERROR;
-}
-
 static const struct dma_map_ops sba_ops = {
 	.dma_supported =	sba_dma_supported,
 	.alloc =		sba_alloc,
@@ -1093,7 +1086,6 @@ static const struct dma_map_ops sba_ops = {
 	.unmap_page =		sba_unmap_page,
 	.map_sg =		sba_map_sg,
 	.unmap_sg =		sba_unmap_sg,
-	.mapping_error =	sba_mapping_error,
 };
 
 
-- 
2.19.1
