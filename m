From: Christoph Hellwig <hch@lst.de>
Date: Fri, 30 Nov 2018 13:22:16 +0000
Subject: [PATCH 08/23] parisc/ccio: remove the mapping_error dma_map_ops method
Message-Id: <20181130132231.16512-9-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20181130132231.16512-1-hch@lst.de>
In-Reply-To: <20181130132231.16512-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: iommu@lists.linux-foundation.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Jon Mason <jdmason@kudzu.us>, Joerg Roedel <joro@8bytes.org>, David Woodhouse <dwmw2@infradead.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Robin Murphy <robin.murphy@arm.com>, x86@kernel.org, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, xen-devel@lists.xenproject.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

The CCIO iommu code already returns (~(dma_addr_t)0x0) on mapping
failures, so we can switch over to returning DMA_MAPPING_ERROR and let
the core dma-mapping code handle the rest.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 drivers/parisc/ccio-dma.c | 10 +---------
 1 file changed, 1 insertion(+), 9 deletions(-)

diff --git a/drivers/parisc/ccio-dma.c b/drivers/parisc/ccio-dma.c
index 701a7d6a74d5..714aac72df0e 100644
--- a/drivers/parisc/ccio-dma.c
+++ b/drivers/parisc/ccio-dma.c
@@ -110,8 +110,6 @@
 #define CMD_TLB_DIRECT_WRITE 35         /* IO_COMMAND for I/O TLB Writes     */
 #define CMD_TLB_PURGE        33         /* IO_COMMAND to Purge I/O TLB entry */
 
-#define CCIO_MAPPING_ERROR    (~(dma_addr_t)0)
-
 struct ioa_registers {
         /* Runway Supervisory Set */
         int32_t    unused1[12];
@@ -740,7 +738,7 @@ ccio_map_single(struct device *dev, void *addr, size_t size,
 	BUG_ON(!dev);
 	ioc = GET_IOC(dev);
 	if (!ioc)
-		return CCIO_MAPPING_ERROR;
+		return DMA_MAPPING_ERROR;
 
 	BUG_ON(size <= 0);
 
@@ -1021,11 +1019,6 @@ ccio_unmap_sg(struct device *dev, struct scatterlist *sglist, int nents,
 	DBG_RUN_SG("%s() DONE (nents %d)\n", __func__, nents);
 }
 
-static int ccio_mapping_error(struct device *dev, dma_addr_t dma_addr)
-{
-	return dma_addr = CCIO_MAPPING_ERROR;
-}
-
 static const struct dma_map_ops ccio_ops = {
 	.dma_supported =	ccio_dma_supported,
 	.alloc =		ccio_alloc,
@@ -1034,7 +1027,6 @@ static const struct dma_map_ops ccio_ops = {
 	.unmap_page =		ccio_unmap_page,
 	.map_sg = 		ccio_map_sg,
 	.unmap_sg = 		ccio_unmap_sg,
-	.mapping_error =	ccio_mapping_error,
 };
 
 #ifdef CONFIG_PROC_FS
-- 
2.19.1
