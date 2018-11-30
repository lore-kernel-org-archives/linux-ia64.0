From: Christoph Hellwig <hch@lst.de>
Date: Fri, 30 Nov 2018 13:22:27 +0000
Subject: [PATCH 19/23] iommu/vt-d: remove the mapping_error dma_map_ops method
Message-Id: <20181130132231.16512-20-hch@lst.de>
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
 drivers/iommu/intel-iommu.c | 12 +++---------
 1 file changed, 3 insertions(+), 9 deletions(-)

diff --git a/drivers/iommu/intel-iommu.c b/drivers/iommu/intel-iommu.c
index 66b4444398ae..0ad67d65bbce 100644
--- a/drivers/iommu/intel-iommu.c
+++ b/drivers/iommu/intel-iommu.c
@@ -3617,7 +3617,7 @@ static dma_addr_t __intel_map_page(struct device *dev, struct page *page,
 
 	domain = get_valid_domain_for_dev(dev);
 	if (!domain)
-		return 0;
+		return DMA_MAPPING_ERROR;
 
 	iommu = domain_get_iommu(domain);
 	size = aligned_nrpages(paddr, size);
@@ -3655,7 +3655,7 @@ static dma_addr_t __intel_map_page(struct device *dev, struct page *page,
 		free_iova_fast(&domain->iovad, iova_pfn, dma_to_mm_pfn(size));
 	pr_err("Device %s request: %zx@%llx dir %d --- failed\n",
 		dev_name(dev), size, (unsigned long long)paddr, dir);
-	return 0;
+	return DMA_MAPPING_ERROR;
 }
 
 static dma_addr_t intel_map_page(struct device *dev, struct page *page,
@@ -3756,7 +3756,7 @@ static void *intel_alloc_coherent(struct device *dev, size_t size,
 
 	*dma_handle = __intel_map_page(dev, page, 0, size, DMA_BIDIRECTIONAL,
 				       dev->coherent_dma_mask);
-	if (*dma_handle)
+	if (*dma_handle != DMA_MAPPING_ERROR)
 		return page_address(page);
 	if (!dma_release_from_contiguous(dev, page, size >> PAGE_SHIFT))
 		__free_pages(page, order);
@@ -3865,11 +3865,6 @@ static int intel_map_sg(struct device *dev, struct scatterlist *sglist, int nele
 	return nelems;
 }
 
-static int intel_mapping_error(struct device *dev, dma_addr_t dma_addr)
-{
-	return !dma_addr;
-}
-
 static const struct dma_map_ops intel_dma_ops = {
 	.alloc = intel_alloc_coherent,
 	.free = intel_free_coherent,
@@ -3877,7 +3872,6 @@ static const struct dma_map_ops intel_dma_ops = {
 	.unmap_sg = intel_unmap_sg,
 	.map_page = intel_map_page,
 	.unmap_page = intel_unmap_page,
-	.mapping_error = intel_mapping_error,
 	.dma_supported = dma_direct_supported,
 };
 
-- 
2.19.1
