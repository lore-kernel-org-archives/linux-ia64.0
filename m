From: Christoph Hellwig <hch@lst.de>
Date: Thu, 22 Nov 2018 14:03:11 +0000
Subject: [PATCH 15/24] ia64/sba_iommu: remove the mapping_error dma_map_ops method
Message-Id: <20181122140320.24080-16-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20181122140320.24080-1-hch@lst.de>
In-Reply-To: <20181122140320.24080-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: iommu@lists.linux-foundation.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Jon Mason <jdmason@kudzu.us>, Joerg Roedel <joro@8bytes.org>, David Woodhouse <dwmw2@infradead.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Robin Murphy <robin.murphy@arm.com>, x86@kernel.org, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, xen-devel@lists.xenproject.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

Return DMA_MAPPING_ERROR instead of 0 on a dma mapping failure and let
the core dma-mapping code handle the rest.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/ia64/hp/common/sba_iommu.c | 8 +-------
 1 file changed, 1 insertion(+), 7 deletions(-)

diff --git a/arch/ia64/hp/common/sba_iommu.c b/arch/ia64/hp/common/sba_iommu.c
index b953282d4704..0316af2cb426 100644
--- a/arch/ia64/hp/common/sba_iommu.c
+++ b/arch/ia64/hp/common/sba_iommu.c
@@ -974,7 +974,7 @@ static dma_addr_t sba_map_page(struct device *dev, struct page *page,
 
 	pide = sba_alloc_range(ioc, dev, size);
 	if (pide < 0)
-		return 0;
+		return DMA_MAPPING_ERROR;
 
 	iovp = (dma_addr_t) pide << iovp_shift;
 
@@ -2151,11 +2151,6 @@ static int sba_dma_supported (struct device *dev, u64 mask)
 	return ((mask & 0xFFFFFFFFUL) = 0xFFFFFFFFUL);
 }
 
-static int sba_dma_mapping_error(struct device *dev, dma_addr_t dma_addr)
-{
-	return 0;
-}
-
 __setup("nosbagart", nosbagart);
 
 static int __init
@@ -2189,7 +2184,6 @@ const struct dma_map_ops sba_dma_ops = {
 	.map_sg			= sba_map_sg_attrs,
 	.unmap_sg		= sba_unmap_sg_attrs,
 	.dma_supported		= sba_dma_supported,
-	.mapping_error		= sba_dma_mapping_error,
 };
 
 void sba_dma_init(void)
-- 
2.19.1
