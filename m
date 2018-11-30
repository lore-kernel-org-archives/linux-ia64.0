From: Christoph Hellwig <hch@lst.de>
Date: Fri, 30 Nov 2018 13:22:22 +0000
Subject: [PATCH 14/23] ia64/sn: remove the mapping_error dma_map_ops method
Message-Id: <20181130132231.16512-15-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20181130132231.16512-1-hch@lst.de>
In-Reply-To: <20181130132231.16512-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: iommu@lists.linux-foundation.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Jon Mason <jdmason@kudzu.us>, Joerg Roedel <joro@8bytes.org>, David Woodhouse <dwmw2@infradead.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Robin Murphy <robin.murphy@arm.com>, x86@kernel.org, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, xen-devel@lists.xenproject.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

Return DMA_MAPPING_ERROR instead of 0 on a dma mapping failure and let
the core dma-mapping code handle the rest.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/ia64/sn/pci/pci_dma.c | 8 +-------
 1 file changed, 1 insertion(+), 7 deletions(-)

diff --git a/arch/ia64/sn/pci/pci_dma.c b/arch/ia64/sn/pci/pci_dma.c
index 4ce4ee4ef9f2..b7d42e4edc1f 100644
--- a/arch/ia64/sn/pci/pci_dma.c
+++ b/arch/ia64/sn/pci/pci_dma.c
@@ -196,7 +196,7 @@ static dma_addr_t sn_dma_map_page(struct device *dev, struct page *page,
 
 	if (!dma_addr) {
 		printk(KERN_ERR "%s: out of ATEs\n", __func__);
-		return 0;
+		return DMA_MAPPING_ERROR;
 	}
 	return dma_addr;
 }
@@ -314,11 +314,6 @@ static int sn_dma_map_sg(struct device *dev, struct scatterlist *sgl,
 	return nhwentries;
 }
 
-static int sn_dma_mapping_error(struct device *dev, dma_addr_t dma_addr)
-{
-	return 0;
-}
-
 static u64 sn_dma_get_required_mask(struct device *dev)
 {
 	return DMA_BIT_MASK(64);
@@ -441,7 +436,6 @@ static struct dma_map_ops sn_dma_ops = {
 	.unmap_page		= sn_dma_unmap_page,
 	.map_sg			= sn_dma_map_sg,
 	.unmap_sg		= sn_dma_unmap_sg,
-	.mapping_error		= sn_dma_mapping_error,
 	.dma_supported		= sn_dma_supported,
 	.get_required_mask	= sn_dma_get_required_mask,
 };
-- 
2.19.1
