From: Christoph Hellwig <hch@lst.de>
Date: Thu, 22 Nov 2018 14:03:18 +0000
Subject: [PATCH 22/24] iommu/dma-iommu: remove the mapping_error dma_map_ops method
Message-Id: <20181122140320.24080-23-hch@lst.de>
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
 arch/arm64/mm/dma-mapping.c |  7 +++----
 drivers/iommu/dma-iommu.c   | 23 ++++++++---------------
 include/linux/dma-iommu.h   |  1 -
 3 files changed, 11 insertions(+), 20 deletions(-)

diff --git a/arch/arm64/mm/dma-mapping.c b/arch/arm64/mm/dma-mapping.c
index fdc26ea5036c..4cc70029cf8d 100644
--- a/arch/arm64/mm/dma-mapping.c
+++ b/arch/arm64/mm/dma-mapping.c
@@ -397,7 +397,7 @@ static void *__iommu_alloc_attrs(struct device *dev, size_t size,
 			return NULL;
 
 		*handle = iommu_dma_map_page(dev, page, 0, iosize, ioprot);
-		if (iommu_dma_mapping_error(dev, *handle)) {
+		if (*handle = DMA_MAPPING_ERROR) {
 			if (coherent)
 				__free_pages(page, get_order(size));
 			else
@@ -414,7 +414,7 @@ static void *__iommu_alloc_attrs(struct device *dev, size_t size,
 			return NULL;
 
 		*handle = iommu_dma_map_page(dev, page, 0, iosize, ioprot);
-		if (iommu_dma_mapping_error(dev, *handle)) {
+		if (*handle = DMA_MAPPING_ERROR) {
 			dma_release_from_contiguous(dev, page,
 						    size >> PAGE_SHIFT);
 			return NULL;
@@ -574,7 +574,7 @@ static dma_addr_t __iommu_map_page(struct device *dev, struct page *page,
 	dma_addr_t dev_addr = iommu_dma_map_page(dev, page, offset, size, prot);
 
 	if (!coherent && !(attrs & DMA_ATTR_SKIP_CPU_SYNC) &&
-	    !iommu_dma_mapping_error(dev, dev_addr))
+	    dev_addr != DMA_MAPPING_ERROR)
 		__dma_map_area(page_address(page) + offset, size, dir);
 
 	return dev_addr;
@@ -657,7 +657,6 @@ static const struct dma_map_ops iommu_dma_ops = {
 	.sync_sg_for_device = __iommu_sync_sg_for_device,
 	.map_resource = iommu_dma_map_resource,
 	.unmap_resource = iommu_dma_unmap_resource,
-	.mapping_error = iommu_dma_mapping_error,
 };
 
 static int __init __iommu_dma_init(void)
diff --git a/drivers/iommu/dma-iommu.c b/drivers/iommu/dma-iommu.c
index d1b04753b204..60c7e9e9901e 100644
--- a/drivers/iommu/dma-iommu.c
+++ b/drivers/iommu/dma-iommu.c
@@ -32,8 +32,6 @@
 #include <linux/scatterlist.h>
 #include <linux/vmalloc.h>
 
-#define IOMMU_MAPPING_ERROR	0
-
 struct iommu_dma_msi_page {
 	struct list_head	list;
 	dma_addr_t		iova;
@@ -523,7 +521,7 @@ void iommu_dma_free(struct device *dev, struct page **pages, size_t size,
 {
 	__iommu_dma_unmap(iommu_get_dma_domain(dev), *handle, size);
 	__iommu_dma_free_pages(pages, PAGE_ALIGN(size) >> PAGE_SHIFT);
-	*handle = IOMMU_MAPPING_ERROR;
+	*handle = DMA_MAPPING_ERROR;
 }
 
 /**
@@ -556,7 +554,7 @@ struct page **iommu_dma_alloc(struct device *dev, size_t size, gfp_t gfp,
 	dma_addr_t iova;
 	unsigned int count, min_size, alloc_sizes = domain->pgsize_bitmap;
 
-	*handle = IOMMU_MAPPING_ERROR;
+	*handle = DMA_MAPPING_ERROR;
 
 	min_size = alloc_sizes & -alloc_sizes;
 	if (min_size < PAGE_SIZE) {
@@ -649,11 +647,11 @@ static dma_addr_t __iommu_dma_map(struct device *dev, phys_addr_t phys,
 
 	iova = iommu_dma_alloc_iova(domain, size, dma_get_mask(dev), dev);
 	if (!iova)
-		return IOMMU_MAPPING_ERROR;
+		return DMA_MAPPING_ERROR;
 
 	if (iommu_map(domain, iova, phys - iova_off, size, prot)) {
 		iommu_dma_free_iova(cookie, iova, size);
-		return IOMMU_MAPPING_ERROR;
+		return DMA_MAPPING_ERROR;
 	}
 	return iova + iova_off;
 }
@@ -694,7 +692,7 @@ static int __finalise_sg(struct device *dev, struct scatterlist *sg, int nents,
 
 		s->offset += s_iova_off;
 		s->length = s_length;
-		sg_dma_address(s) = IOMMU_MAPPING_ERROR;
+		sg_dma_address(s) = DMA_MAPPING_ERROR;
 		sg_dma_len(s) = 0;
 
 		/*
@@ -737,11 +735,11 @@ static void __invalidate_sg(struct scatterlist *sg, int nents)
 	int i;
 
 	for_each_sg(sg, s, nents, i) {
-		if (sg_dma_address(s) != IOMMU_MAPPING_ERROR)
+		if (sg_dma_address(s) != DMA_MAPPING_ERROR)
 			s->offset += sg_dma_address(s);
 		if (sg_dma_len(s))
 			s->length = sg_dma_len(s);
-		sg_dma_address(s) = IOMMU_MAPPING_ERROR;
+		sg_dma_address(s) = DMA_MAPPING_ERROR;
 		sg_dma_len(s) = 0;
 	}
 }
@@ -858,11 +856,6 @@ void iommu_dma_unmap_resource(struct device *dev, dma_addr_t handle,
 	__iommu_dma_unmap(iommu_get_dma_domain(dev), handle, size);
 }
 
-int iommu_dma_mapping_error(struct device *dev, dma_addr_t dma_addr)
-{
-	return dma_addr = IOMMU_MAPPING_ERROR;
-}
-
 static struct iommu_dma_msi_page *iommu_dma_get_msi_page(struct device *dev,
 		phys_addr_t msi_addr, struct iommu_domain *domain)
 {
@@ -882,7 +875,7 @@ static struct iommu_dma_msi_page *iommu_dma_get_msi_page(struct device *dev,
 		return NULL;
 
 	iova = __iommu_dma_map(dev, msi_addr, size, prot, domain);
-	if (iommu_dma_mapping_error(dev, iova))
+	if (iova = DMA_MAPPING_ERROR)
 		goto out_free_page;
 
 	INIT_LIST_HEAD(&msi_page->list);
diff --git a/include/linux/dma-iommu.h b/include/linux/dma-iommu.h
index e8ca5e654277..e760dc5d1fa8 100644
--- a/include/linux/dma-iommu.h
+++ b/include/linux/dma-iommu.h
@@ -69,7 +69,6 @@ dma_addr_t iommu_dma_map_resource(struct device *dev, phys_addr_t phys,
 		size_t size, enum dma_data_direction dir, unsigned long attrs);
 void iommu_dma_unmap_resource(struct device *dev, dma_addr_t handle,
 		size_t size, enum dma_data_direction dir, unsigned long attrs);
-int iommu_dma_mapping_error(struct device *dev, dma_addr_t dma_addr);
 
 /* The DMA API isn't _quite_ the whole story, though... */
 void iommu_dma_map_msi_msg(int irq, struct msi_msg *msg);
-- 
2.19.1
