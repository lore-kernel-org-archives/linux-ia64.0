From: Christoph Hellwig <hch@lst.de>
Date: Fri, 30 Nov 2018 13:22:11 +0000
Subject: [PATCH 03/23] arm: remove the mapping_error dma_map_ops method
Message-Id: <20181130132231.16512-4-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20181130132231.16512-1-hch@lst.de>
In-Reply-To: <20181130132231.16512-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: iommu@lists.linux-foundation.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Jon Mason <jdmason@kudzu.us>, Joerg Roedel <joro@8bytes.org>, David Woodhouse <dwmw2@infradead.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Robin Murphy <robin.murphy@arm.com>, x86@kernel.org, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, xen-devel@lists.xenproject.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

Arm already returns (~(dma_addr_t)0x0) on mapping failures, so we can
switch over to returning DMA_MAPPING_ERROR and let the core dma-mapping
code handle the rest.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/arm/common/dmabounce.c      | 12 +++-------
 arch/arm/include/asm/dma-iommu.h |  2 --
 arch/arm/mm/dma-mapping.c        | 39 ++++++++++++--------------------
 3 files changed, 18 insertions(+), 35 deletions(-)

diff --git a/arch/arm/common/dmabounce.c b/arch/arm/common/dmabounce.c
index 9a92de63426f..5ba4622030ca 100644
--- a/arch/arm/common/dmabounce.c
+++ b/arch/arm/common/dmabounce.c
@@ -257,7 +257,7 @@ static inline dma_addr_t map_single(struct device *dev, void *ptr, size_t size,
 	if (buf = NULL) {
 		dev_err(dev, "%s: unable to map unsafe buffer %p!\n",
 		       __func__, ptr);
-		return ARM_MAPPING_ERROR;
+		return DMA_MAPPING_ERROR;
 	}
 
 	dev_dbg(dev, "%s: unsafe buffer %p (dma=%#x) mapped to %p (dma=%#x)\n",
@@ -327,7 +327,7 @@ static dma_addr_t dmabounce_map_page(struct device *dev, struct page *page,
 
 	ret = needs_bounce(dev, dma_addr, size);
 	if (ret < 0)
-		return ARM_MAPPING_ERROR;
+		return DMA_MAPPING_ERROR;
 
 	if (ret = 0) {
 		arm_dma_ops.sync_single_for_device(dev, dma_addr, size, dir);
@@ -336,7 +336,7 @@ static dma_addr_t dmabounce_map_page(struct device *dev, struct page *page,
 
 	if (PageHighMem(page)) {
 		dev_err(dev, "DMA buffer bouncing of HIGHMEM pages is not supported\n");
-		return ARM_MAPPING_ERROR;
+		return DMA_MAPPING_ERROR;
 	}
 
 	return map_single(dev, page_address(page) + offset, size, dir, attrs);
@@ -453,11 +453,6 @@ static int dmabounce_dma_supported(struct device *dev, u64 dma_mask)
 	return arm_dma_ops.dma_supported(dev, dma_mask);
 }
 
-static int dmabounce_mapping_error(struct device *dev, dma_addr_t dma_addr)
-{
-	return arm_dma_ops.mapping_error(dev, dma_addr);
-}
-
 static const struct dma_map_ops dmabounce_ops = {
 	.alloc			= arm_dma_alloc,
 	.free			= arm_dma_free,
@@ -472,7 +467,6 @@ static const struct dma_map_ops dmabounce_ops = {
 	.sync_sg_for_cpu	= arm_dma_sync_sg_for_cpu,
 	.sync_sg_for_device	= arm_dma_sync_sg_for_device,
 	.dma_supported		= dmabounce_dma_supported,
-	.mapping_error		= dmabounce_mapping_error,
 };
 
 static int dmabounce_init_pool(struct dmabounce_pool *pool, struct device *dev,
diff --git a/arch/arm/include/asm/dma-iommu.h b/arch/arm/include/asm/dma-iommu.h
index 6821f1249300..772f48ef84b7 100644
--- a/arch/arm/include/asm/dma-iommu.h
+++ b/arch/arm/include/asm/dma-iommu.h
@@ -9,8 +9,6 @@
 #include <linux/dma-debug.h>
 #include <linux/kref.h>
 
-#define ARM_MAPPING_ERROR		(~(dma_addr_t)0x0)
-
 struct dma_iommu_mapping {
 	/* iommu specific data */
 	struct iommu_domain	*domain;
diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
index 661fe48ab78d..2cfb17bad1e6 100644
--- a/arch/arm/mm/dma-mapping.c
+++ b/arch/arm/mm/dma-mapping.c
@@ -179,11 +179,6 @@ static void arm_dma_sync_single_for_device(struct device *dev,
 	__dma_page_cpu_to_dev(page, offset, size, dir);
 }
 
-static int arm_dma_mapping_error(struct device *dev, dma_addr_t dma_addr)
-{
-	return dma_addr = ARM_MAPPING_ERROR;
-}
-
 const struct dma_map_ops arm_dma_ops = {
 	.alloc			= arm_dma_alloc,
 	.free			= arm_dma_free,
@@ -197,7 +192,6 @@ const struct dma_map_ops arm_dma_ops = {
 	.sync_single_for_device	= arm_dma_sync_single_for_device,
 	.sync_sg_for_cpu	= arm_dma_sync_sg_for_cpu,
 	.sync_sg_for_device	= arm_dma_sync_sg_for_device,
-	.mapping_error		= arm_dma_mapping_error,
 	.dma_supported		= arm_dma_supported,
 };
 EXPORT_SYMBOL(arm_dma_ops);
@@ -217,7 +211,6 @@ const struct dma_map_ops arm_coherent_dma_ops = {
 	.get_sgtable		= arm_dma_get_sgtable,
 	.map_page		= arm_coherent_dma_map_page,
 	.map_sg			= arm_dma_map_sg,
-	.mapping_error		= arm_dma_mapping_error,
 	.dma_supported		= arm_dma_supported,
 };
 EXPORT_SYMBOL(arm_coherent_dma_ops);
@@ -774,7 +767,7 @@ static void *__dma_alloc(struct device *dev, size_t size, dma_addr_t *handle,
 	gfp &= ~(__GFP_COMP);
 	args.gfp = gfp;
 
-	*handle = ARM_MAPPING_ERROR;
+	*handle = DMA_MAPPING_ERROR;
 	allowblock = gfpflags_allow_blocking(gfp);
 	cma = allowblock ? dev_get_cma_area(dev) : false;
 
@@ -1217,7 +1210,7 @@ static inline dma_addr_t __alloc_iova(struct dma_iommu_mapping *mapping,
 	if (i = mapping->nr_bitmaps) {
 		if (extend_iommu_mapping(mapping)) {
 			spin_unlock_irqrestore(&mapping->lock, flags);
-			return ARM_MAPPING_ERROR;
+			return DMA_MAPPING_ERROR;
 		}
 
 		start = bitmap_find_next_zero_area(mapping->bitmaps[i],
@@ -1225,7 +1218,7 @@ static inline dma_addr_t __alloc_iova(struct dma_iommu_mapping *mapping,
 
 		if (start > mapping->bits) {
 			spin_unlock_irqrestore(&mapping->lock, flags);
-			return ARM_MAPPING_ERROR;
+			return DMA_MAPPING_ERROR;
 		}
 
 		bitmap_set(mapping->bitmaps[i], start, count);
@@ -1409,7 +1402,7 @@ __iommu_create_mapping(struct device *dev, struct page **pages, size_t size,
 	int i;
 
 	dma_addr = __alloc_iova(mapping, size);
-	if (dma_addr = ARM_MAPPING_ERROR)
+	if (dma_addr = DMA_MAPPING_ERROR)
 		return dma_addr;
 
 	iova = dma_addr;
@@ -1436,7 +1429,7 @@ __iommu_create_mapping(struct device *dev, struct page **pages, size_t size,
 fail:
 	iommu_unmap(mapping->domain, dma_addr, iova-dma_addr);
 	__free_iova(mapping, dma_addr, size);
-	return ARM_MAPPING_ERROR;
+	return DMA_MAPPING_ERROR;
 }
 
 static int __iommu_remove_mapping(struct device *dev, dma_addr_t iova, size_t size)
@@ -1497,7 +1490,7 @@ static void *__iommu_alloc_simple(struct device *dev, size_t size, gfp_t gfp,
 		return NULL;
 
 	*handle = __iommu_create_mapping(dev, &page, size, attrs);
-	if (*handle = ARM_MAPPING_ERROR)
+	if (*handle = DMA_MAPPING_ERROR)
 		goto err_mapping;
 
 	return addr;
@@ -1525,7 +1518,7 @@ static void *__arm_iommu_alloc_attrs(struct device *dev, size_t size,
 	struct page **pages;
 	void *addr = NULL;
 
-	*handle = ARM_MAPPING_ERROR;
+	*handle = DMA_MAPPING_ERROR;
 	size = PAGE_ALIGN(size);
 
 	if (coherent_flag  = COHERENT || !gfpflags_allow_blocking(gfp))
@@ -1546,7 +1539,7 @@ static void *__arm_iommu_alloc_attrs(struct device *dev, size_t size,
 		return NULL;
 
 	*handle = __iommu_create_mapping(dev, pages, size, attrs);
-	if (*handle = ARM_MAPPING_ERROR)
+	if (*handle = DMA_MAPPING_ERROR)
 		goto err_buffer;
 
 	if (attrs & DMA_ATTR_NO_KERNEL_MAPPING)
@@ -1696,10 +1689,10 @@ static int __map_sg_chunk(struct device *dev, struct scatterlist *sg,
 	int prot;
 
 	size = PAGE_ALIGN(size);
-	*handle = ARM_MAPPING_ERROR;
+	*handle = DMA_MAPPING_ERROR;
 
 	iova_base = iova = __alloc_iova(mapping, size);
-	if (iova = ARM_MAPPING_ERROR)
+	if (iova = DMA_MAPPING_ERROR)
 		return -ENOMEM;
 
 	for (count = 0, s = sg; count < (size >> PAGE_SHIFT); s = sg_next(s)) {
@@ -1739,7 +1732,7 @@ static int __iommu_map_sg(struct device *dev, struct scatterlist *sg, int nents,
 	for (i = 1; i < nents; i++) {
 		s = sg_next(s);
 
-		s->dma_address = ARM_MAPPING_ERROR;
+		s->dma_address = DMA_MAPPING_ERROR;
 		s->dma_length = 0;
 
 		if (s->offset || (size & ~PAGE_MASK) || size + s->length > max) {
@@ -1914,7 +1907,7 @@ static dma_addr_t arm_coherent_iommu_map_page(struct device *dev, struct page *p
 	int ret, prot, len = PAGE_ALIGN(size + offset);
 
 	dma_addr = __alloc_iova(mapping, len);
-	if (dma_addr = ARM_MAPPING_ERROR)
+	if (dma_addr = DMA_MAPPING_ERROR)
 		return dma_addr;
 
 	prot = __dma_info_to_prot(dir, attrs);
@@ -1926,7 +1919,7 @@ static dma_addr_t arm_coherent_iommu_map_page(struct device *dev, struct page *p
 	return dma_addr + offset;
 fail:
 	__free_iova(mapping, dma_addr, len);
-	return ARM_MAPPING_ERROR;
+	return DMA_MAPPING_ERROR;
 }
 
 /**
@@ -2020,7 +2013,7 @@ static dma_addr_t arm_iommu_map_resource(struct device *dev,
 	size_t len = PAGE_ALIGN(size + offset);
 
 	dma_addr = __alloc_iova(mapping, len);
-	if (dma_addr = ARM_MAPPING_ERROR)
+	if (dma_addr = DMA_MAPPING_ERROR)
 		return dma_addr;
 
 	prot = __dma_info_to_prot(dir, attrs) | IOMMU_MMIO;
@@ -2032,7 +2025,7 @@ static dma_addr_t arm_iommu_map_resource(struct device *dev,
 	return dma_addr + offset;
 fail:
 	__free_iova(mapping, dma_addr, len);
-	return ARM_MAPPING_ERROR;
+	return DMA_MAPPING_ERROR;
 }
 
 /**
@@ -2105,7 +2098,6 @@ const struct dma_map_ops iommu_ops = {
 	.map_resource		= arm_iommu_map_resource,
 	.unmap_resource		= arm_iommu_unmap_resource,
 
-	.mapping_error		= arm_dma_mapping_error,
 	.dma_supported		= arm_dma_supported,
 };
 
@@ -2124,7 +2116,6 @@ const struct dma_map_ops iommu_coherent_ops = {
 	.map_resource	= arm_iommu_map_resource,
 	.unmap_resource	= arm_iommu_unmap_resource,
 
-	.mapping_error		= arm_dma_mapping_error,
 	.dma_supported		= arm_dma_supported,
 };
 
-- 
2.19.1
