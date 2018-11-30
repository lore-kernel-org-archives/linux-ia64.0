From: Christoph Hellwig <hch@lst.de>
Date: Fri, 30 Nov 2018 13:22:26 +0000
Subject: [PATCH 18/23] iommu/intel: small map_page cleanup
Message-Id: <20181130132231.16512-19-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20181130132231.16512-1-hch@lst.de>
In-Reply-To: <20181130132231.16512-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: iommu@lists.linux-foundation.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Jon Mason <jdmason@kudzu.us>, Joerg Roedel <joro@8bytes.org>, David Woodhouse <dwmw2@infradead.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Robin Murphy <robin.murphy@arm.com>, x86@kernel.org, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, xen-devel@lists.xenproject.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

Pass the page + offset to the low-level __iommu_map_single helper
(which gets renamed to fit the new calling conventions) as both
callers have the page at hand.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 drivers/iommu/intel-iommu.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/iommu/intel-iommu.c b/drivers/iommu/intel-iommu.c
index 41a4b8808802..66b4444398ae 100644
--- a/drivers/iommu/intel-iommu.c
+++ b/drivers/iommu/intel-iommu.c
@@ -3597,9 +3597,11 @@ static int iommu_no_mapping(struct device *dev)
 	return 0;
 }
 
-static dma_addr_t __intel_map_single(struct device *dev, phys_addr_t paddr,
-				     size_t size, int dir, u64 dma_mask)
+static dma_addr_t __intel_map_page(struct device *dev, struct page *page,
+				   unsigned long offset, size_t size, int dir,
+				   u64 dma_mask)
 {
+	phys_addr_t paddr = page_to_phys(page) + offset;
 	struct dmar_domain *domain;
 	phys_addr_t start_paddr;
 	unsigned long iova_pfn;
@@ -3661,8 +3663,7 @@ static dma_addr_t intel_map_page(struct device *dev, struct page *page,
 				 enum dma_data_direction dir,
 				 unsigned long attrs)
 {
-	return __intel_map_single(dev, page_to_phys(page) + offset, size,
-				  dir, *dev->dma_mask);
+	return __intel_map_page(dev, page, offset, size, dir, *dev->dma_mask);
 }
 
 static void intel_unmap(struct device *dev, dma_addr_t dev_addr, size_t size)
@@ -3753,9 +3754,8 @@ static void *intel_alloc_coherent(struct device *dev, size_t size,
 		return NULL;
 	memset(page_address(page), 0, size);
 
-	*dma_handle = __intel_map_single(dev, page_to_phys(page), size,
-					 DMA_BIDIRECTIONAL,
-					 dev->coherent_dma_mask);
+	*dma_handle = __intel_map_page(dev, page, 0, size, DMA_BIDIRECTIONAL,
+				       dev->coherent_dma_mask);
 	if (*dma_handle)
 		return page_address(page);
 	if (!dma_release_from_contiguous(dev, page, size >> PAGE_SHIFT))
-- 
2.19.1
