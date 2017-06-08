From: Christoph Hellwig <hch@lst.de>
Date: Thu, 08 Jun 2017 13:25:50 +0000
Subject: [PATCH 25/44] arm: implement ->mapping_error
Message-Id: <20170608132609.32662-26-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170608132609.32662-1-hch@lst.de>
In-Reply-To: <20170608132609.32662-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: x86@kernel.org, linux-arm-kernel@lists.infradead.org, xen-devel@lists.xenproject.org, linux-c6x-dev@linux-c6x.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, openrisc@lists.librecores.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, dmaengine@vger.kernel.org, linux-tegra@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-samsung-soc@vger.kernel.org, iommu@lists.linux-foundation.org, netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org

DMA_ERROR_CODE is going to go away, so don't rely on it.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/arm/common/dmabounce.c        | 16 ++++++++++++---
 arch/arm/include/asm/dma-iommu.h   |  2 ++
 arch/arm/include/asm/dma-mapping.h |  1 -
 arch/arm/mm/dma-mapping.c          | 41 ++++++++++++++++++++++++--------------
 4 files changed, 41 insertions(+), 19 deletions(-)

diff --git a/arch/arm/common/dmabounce.c b/arch/arm/common/dmabounce.c
index 9b1b7be2ec0e..bad457395ff1 100644
--- a/arch/arm/common/dmabounce.c
+++ b/arch/arm/common/dmabounce.c
@@ -33,6 +33,7 @@
 #include <linux/scatterlist.h>
 
 #include <asm/cacheflush.h>
+#include <asm/dma-iommu.h>
 
 #undef STATS
 
@@ -256,7 +257,7 @@ static inline dma_addr_t map_single(struct device *dev, void *ptr, size_t size,
 	if (buf = NULL) {
 		dev_err(dev, "%s: unable to map unsafe buffer %p!\n",
 		       __func__, ptr);
-		return DMA_ERROR_CODE;
+		return ARM_MAPPING_ERROR;
 	}
 
 	dev_dbg(dev, "%s: unsafe buffer %p (dma=%#x) mapped to %p (dma=%#x)\n",
@@ -326,7 +327,7 @@ static dma_addr_t dmabounce_map_page(struct device *dev, struct page *page,
 
 	ret = needs_bounce(dev, dma_addr, size);
 	if (ret < 0)
-		return DMA_ERROR_CODE;
+		return ARM_MAPPING_ERROR;
 
 	if (ret = 0) {
 		arm_dma_ops.sync_single_for_device(dev, dma_addr, size, dir);
@@ -335,7 +336,7 @@ static dma_addr_t dmabounce_map_page(struct device *dev, struct page *page,
 
 	if (PageHighMem(page)) {
 		dev_err(dev, "DMA buffer bouncing of HIGHMEM pages is not supported\n");
-		return DMA_ERROR_CODE;
+		return ARM_MAPPING_ERROR;
 	}
 
 	return map_single(dev, page_address(page) + offset, size, dir, attrs);
@@ -452,6 +453,14 @@ static int dmabounce_set_mask(struct device *dev, u64 dma_mask)
 	return arm_dma_ops.set_dma_mask(dev, dma_mask);
 }
 
+static int dmabounce_mapping_error(struct device *dev, dma_addr_t dma_addr)
+{
+	if (dev->archdata.dmabounce)
+		return 0;
+
+	return arm_dma_ops.mapping_error(dev, dma_addr);
+}
+
 static const struct dma_map_ops dmabounce_ops = {
 	.alloc			= arm_dma_alloc,
 	.free			= arm_dma_free,
@@ -466,6 +475,7 @@ static const struct dma_map_ops dmabounce_ops = {
 	.sync_sg_for_cpu	= arm_dma_sync_sg_for_cpu,
 	.sync_sg_for_device	= arm_dma_sync_sg_for_device,
 	.set_dma_mask		= dmabounce_set_mask,
+	.mapping_error		= dmabounce_mapping_error,
 };
 
 static int dmabounce_init_pool(struct dmabounce_pool *pool, struct device *dev,
diff --git a/arch/arm/include/asm/dma-iommu.h b/arch/arm/include/asm/dma-iommu.h
index 2ef282f96651..389a26a10ea3 100644
--- a/arch/arm/include/asm/dma-iommu.h
+++ b/arch/arm/include/asm/dma-iommu.h
@@ -9,6 +9,8 @@
 #include <linux/kmemcheck.h>
 #include <linux/kref.h>
 
+#define ARM_MAPPING_ERROR		(~(dma_addr_t)0x0)
+
 struct dma_iommu_mapping {
 	/* iommu specific data */
 	struct iommu_domain	*domain;
diff --git a/arch/arm/include/asm/dma-mapping.h b/arch/arm/include/asm/dma-mapping.h
index 680d3f3889e7..52a8fd5a8edb 100644
--- a/arch/arm/include/asm/dma-mapping.h
+++ b/arch/arm/include/asm/dma-mapping.h
@@ -12,7 +12,6 @@
 #include <xen/xen.h>
 #include <asm/xen/hypervisor.h>
 
-#define DMA_ERROR_CODE	(~(dma_addr_t)0x0)
 extern const struct dma_map_ops arm_dma_ops;
 extern const struct dma_map_ops arm_coherent_dma_ops;
 
diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
index c742dfd2967b..2dbc94b5fe5c 100644
--- a/arch/arm/mm/dma-mapping.c
+++ b/arch/arm/mm/dma-mapping.c
@@ -180,6 +180,11 @@ static void arm_dma_sync_single_for_device(struct device *dev,
 	__dma_page_cpu_to_dev(page, offset, size, dir);
 }
 
+static int arm_dma_mapping_error(struct device *dev, dma_addr_t dma_addr)
+{
+	return dma_addr = ARM_MAPPING_ERROR;
+}
+
 const struct dma_map_ops arm_dma_ops = {
 	.alloc			= arm_dma_alloc,
 	.free			= arm_dma_free,
@@ -193,6 +198,7 @@ const struct dma_map_ops arm_dma_ops = {
 	.sync_single_for_device	= arm_dma_sync_single_for_device,
 	.sync_sg_for_cpu	= arm_dma_sync_sg_for_cpu,
 	.sync_sg_for_device	= arm_dma_sync_sg_for_device,
+	.mapping_error		= arm_dma_mapping_error,
 };
 EXPORT_SYMBOL(arm_dma_ops);
 
@@ -211,6 +217,7 @@ const struct dma_map_ops arm_coherent_dma_ops = {
 	.get_sgtable		= arm_dma_get_sgtable,
 	.map_page		= arm_coherent_dma_map_page,
 	.map_sg			= arm_dma_map_sg,
+	.mapping_error		= arm_dma_mapping_error,
 };
 EXPORT_SYMBOL(arm_coherent_dma_ops);
 
@@ -799,7 +806,7 @@ static void *__dma_alloc(struct device *dev, size_t size, dma_addr_t *handle,
 	gfp &= ~(__GFP_COMP);
 	args.gfp = gfp;
 
-	*handle = DMA_ERROR_CODE;
+	*handle = ARM_MAPPING_ERROR;
 	allowblock = gfpflags_allow_blocking(gfp);
 	cma = allowblock ? dev_get_cma_area(dev) : false;
 
@@ -1254,7 +1261,7 @@ static inline dma_addr_t __alloc_iova(struct dma_iommu_mapping *mapping,
 	if (i = mapping->nr_bitmaps) {
 		if (extend_iommu_mapping(mapping)) {
 			spin_unlock_irqrestore(&mapping->lock, flags);
-			return DMA_ERROR_CODE;
+			return ARM_MAPPING_ERROR;
 		}
 
 		start = bitmap_find_next_zero_area(mapping->bitmaps[i],
@@ -1262,7 +1269,7 @@ static inline dma_addr_t __alloc_iova(struct dma_iommu_mapping *mapping,
 
 		if (start > mapping->bits) {
 			spin_unlock_irqrestore(&mapping->lock, flags);
-			return DMA_ERROR_CODE;
+			return ARM_MAPPING_ERROR;
 		}
 
 		bitmap_set(mapping->bitmaps[i], start, count);
@@ -1445,7 +1452,7 @@ __iommu_create_mapping(struct device *dev, struct page **pages, size_t size,
 	int i;
 
 	dma_addr = __alloc_iova(mapping, size);
-	if (dma_addr = DMA_ERROR_CODE)
+	if (dma_addr = ARM_MAPPING_ERROR)
 		return dma_addr;
 
 	iova = dma_addr;
@@ -1472,7 +1479,7 @@ __iommu_create_mapping(struct device *dev, struct page **pages, size_t size,
 fail:
 	iommu_unmap(mapping->domain, dma_addr, iova-dma_addr);
 	__free_iova(mapping, dma_addr, size);
-	return DMA_ERROR_CODE;
+	return ARM_MAPPING_ERROR;
 }
 
 static int __iommu_remove_mapping(struct device *dev, dma_addr_t iova, size_t size)
@@ -1533,7 +1540,7 @@ static void *__iommu_alloc_simple(struct device *dev, size_t size, gfp_t gfp,
 		return NULL;
 
 	*handle = __iommu_create_mapping(dev, &page, size, attrs);
-	if (*handle = DMA_ERROR_CODE)
+	if (*handle = ARM_MAPPING_ERROR)
 		goto err_mapping;
 
 	return addr;
@@ -1561,7 +1568,7 @@ static void *__arm_iommu_alloc_attrs(struct device *dev, size_t size,
 	struct page **pages;
 	void *addr = NULL;
 
-	*handle = DMA_ERROR_CODE;
+	*handle = ARM_MAPPING_ERROR;
 	size = PAGE_ALIGN(size);
 
 	if (coherent_flag  = COHERENT || !gfpflags_allow_blocking(gfp))
@@ -1582,7 +1589,7 @@ static void *__arm_iommu_alloc_attrs(struct device *dev, size_t size,
 		return NULL;
 
 	*handle = __iommu_create_mapping(dev, pages, size, attrs);
-	if (*handle = DMA_ERROR_CODE)
+	if (*handle = ARM_MAPPING_ERROR)
 		goto err_buffer;
 
 	if (attrs & DMA_ATTR_NO_KERNEL_MAPPING)
@@ -1732,10 +1739,10 @@ static int __map_sg_chunk(struct device *dev, struct scatterlist *sg,
 	int prot;
 
 	size = PAGE_ALIGN(size);
-	*handle = DMA_ERROR_CODE;
+	*handle = ARM_MAPPING_ERROR;
 
 	iova_base = iova = __alloc_iova(mapping, size);
-	if (iova = DMA_ERROR_CODE)
+	if (iova = ARM_MAPPING_ERROR)
 		return -ENOMEM;
 
 	for (count = 0, s = sg; count < (size >> PAGE_SHIFT); s = sg_next(s)) {
@@ -1775,7 +1782,7 @@ static int __iommu_map_sg(struct device *dev, struct scatterlist *sg, int nents,
 	for (i = 1; i < nents; i++) {
 		s = sg_next(s);
 
-		s->dma_address = DMA_ERROR_CODE;
+		s->dma_address = ARM_MAPPING_ERROR;
 		s->dma_length = 0;
 
 		if (s->offset || (size & ~PAGE_MASK) || size + s->length > max) {
@@ -1950,7 +1957,7 @@ static dma_addr_t arm_coherent_iommu_map_page(struct device *dev, struct page *p
 	int ret, prot, len = PAGE_ALIGN(size + offset);
 
 	dma_addr = __alloc_iova(mapping, len);
-	if (dma_addr = DMA_ERROR_CODE)
+	if (dma_addr = ARM_MAPPING_ERROR)
 		return dma_addr;
 
 	prot = __dma_info_to_prot(dir, attrs);
@@ -1962,7 +1969,7 @@ static dma_addr_t arm_coherent_iommu_map_page(struct device *dev, struct page *p
 	return dma_addr + offset;
 fail:
 	__free_iova(mapping, dma_addr, len);
-	return DMA_ERROR_CODE;
+	return ARM_MAPPING_ERROR;
 }
 
 /**
@@ -2056,7 +2063,7 @@ static dma_addr_t arm_iommu_map_resource(struct device *dev,
 	size_t len = PAGE_ALIGN(size + offset);
 
 	dma_addr = __alloc_iova(mapping, len);
-	if (dma_addr = DMA_ERROR_CODE)
+	if (dma_addr = ARM_MAPPING_ERROR)
 		return dma_addr;
 
 	prot = __dma_info_to_prot(dir, attrs) | IOMMU_MMIO;
@@ -2068,7 +2075,7 @@ static dma_addr_t arm_iommu_map_resource(struct device *dev,
 	return dma_addr + offset;
 fail:
 	__free_iova(mapping, dma_addr, len);
-	return DMA_ERROR_CODE;
+	return ARM_MAPPING_ERROR;
 }
 
 /**
@@ -2140,6 +2147,8 @@ const struct dma_map_ops iommu_ops = {
 
 	.map_resource		= arm_iommu_map_resource,
 	.unmap_resource		= arm_iommu_unmap_resource,
+
+	.mapping_error		= arm_dma_mapping_error,
 };
 
 const struct dma_map_ops iommu_coherent_ops = {
@@ -2156,6 +2165,8 @@ const struct dma_map_ops iommu_coherent_ops = {
 
 	.map_resource	= arm_iommu_map_resource,
 	.unmap_resource	= arm_iommu_unmap_resource,
+
+	.mapping_error		= arm_dma_mapping_error,
 };
 
 /**
-- 
2.11.0

