From: Christoph Hellwig <hch@lst.de>
Date: Thu, 22 Nov 2018 14:03:15 +0000
Subject: [PATCH 19/24] iommu: remove the mapping_error dma_map_ops method
Message-Id: <20181122140320.24080-20-hch@lst.de>
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

Note that the existing code used AMD_IOMMU_MAPPING_ERROR to check from
a 0 return from the IOVA allocator, which is replaced with an explicit
0 as in the implementation and other users of that interface.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 drivers/iommu/amd_iommu.c | 18 +++++-------------
 1 file changed, 5 insertions(+), 13 deletions(-)

diff --git a/drivers/iommu/amd_iommu.c b/drivers/iommu/amd_iommu.c
index 1167ff0416cf..c5d6c7c42b0a 100644
--- a/drivers/iommu/amd_iommu.c
+++ b/drivers/iommu/amd_iommu.c
@@ -55,8 +55,6 @@
 #include "amd_iommu_types.h"
 #include "irq_remapping.h"
 
-#define AMD_IOMMU_MAPPING_ERROR	0
-
 #define CMD_SET_TYPE(cmd, t) ((cmd)->data[1] |= ((t) << 28))
 
 #define LOOP_TIMEOUT	100000
@@ -2339,7 +2337,7 @@ static dma_addr_t __map_single(struct device *dev,
 	paddr &= PAGE_MASK;
 
 	address = dma_ops_alloc_iova(dev, dma_dom, pages, dma_mask);
-	if (address = AMD_IOMMU_MAPPING_ERROR)
+	if (!address)
 		goto out;
 
 	prot = dir2prot(direction);
@@ -2376,7 +2374,7 @@ static dma_addr_t __map_single(struct device *dev,
 
 	dma_ops_free_iova(dma_dom, address, pages);
 
-	return AMD_IOMMU_MAPPING_ERROR;
+	return DMA_MAPPING_ERROR;
 }
 
 /*
@@ -2427,7 +2425,7 @@ static dma_addr_t map_page(struct device *dev, struct page *page,
 	if (PTR_ERR(domain) = -EINVAL)
 		return (dma_addr_t)paddr;
 	else if (IS_ERR(domain))
-		return AMD_IOMMU_MAPPING_ERROR;
+		return DMA_MAPPING_ERROR;
 
 	dma_mask = *dev->dma_mask;
 	dma_dom = to_dma_ops_domain(domain);
@@ -2504,7 +2502,7 @@ static int map_sg(struct device *dev, struct scatterlist *sglist,
 	npages = sg_num_pages(dev, sglist, nelems);
 
 	address = dma_ops_alloc_iova(dev, dma_dom, npages, dma_mask);
-	if (address = AMD_IOMMU_MAPPING_ERROR)
+	if (address = DMA_MAPPING_ERROR)
 		goto out_err;
 
 	prot = dir2prot(direction);
@@ -2627,7 +2625,7 @@ static void *alloc_coherent(struct device *dev, size_t size,
 	*dma_addr = __map_single(dev, dma_dom, page_to_phys(page),
 				 size, DMA_BIDIRECTIONAL, dma_mask);
 
-	if (*dma_addr = AMD_IOMMU_MAPPING_ERROR)
+	if (*dma_addr = DMA_MAPPING_ERROR)
 		goto out_free;
 
 	return page_address(page);
@@ -2678,11 +2676,6 @@ static int amd_iommu_dma_supported(struct device *dev, u64 mask)
 	return check_device(dev);
 }
 
-static int amd_iommu_mapping_error(struct device *dev, dma_addr_t dma_addr)
-{
-	return dma_addr = AMD_IOMMU_MAPPING_ERROR;
-}
-
 static const struct dma_map_ops amd_iommu_dma_ops = {
 	.alloc		= alloc_coherent,
 	.free		= free_coherent,
@@ -2691,7 +2684,6 @@ static const struct dma_map_ops amd_iommu_dma_ops = {
 	.map_sg		= map_sg,
 	.unmap_sg	= unmap_sg,
 	.dma_supported	= amd_iommu_dma_supported,
-	.mapping_error	= amd_iommu_mapping_error,
 };
 
 static int init_reserved_iova_ranges(void)
-- 
2.19.1
