From: Christoph Hellwig <hch@lst.de>
Date: Fri, 30 Nov 2018 13:22:12 +0000
Subject: [PATCH 04/23] powerpc/iommu: remove the mapping_error dma_map_ops method
Message-Id: <20181130132231.16512-5-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20181130132231.16512-1-hch@lst.de>
In-Reply-To: <20181130132231.16512-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: iommu@lists.linux-foundation.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Jon Mason <jdmason@kudzu.us>, Joerg Roedel <joro@8bytes.org>, David Woodhouse <dwmw2@infradead.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Robin Murphy <robin.murphy@arm.com>, x86@kernel.org, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, xen-devel@lists.xenproject.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

The powerpc iommu code already returns (~(dma_addr_t)0x0) on mapping
failures, so we can switch over to returning DMA_MAPPING_ERROR and let
the core dma-mapping code handle the rest.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/powerpc/include/asm/iommu.h     |  4 ----
 arch/powerpc/kernel/dma-iommu.c      |  6 ------
 arch/powerpc/kernel/iommu.c          | 28 ++++++++++++++--------------
 arch/powerpc/platforms/cell/iommu.c  |  1 -
 arch/powerpc/platforms/pseries/vio.c |  3 +--
 5 files changed, 15 insertions(+), 27 deletions(-)

diff --git a/arch/powerpc/include/asm/iommu.h b/arch/powerpc/include/asm/iommu.h
index 35db0cbc9222..55312990d1d2 100644
--- a/arch/powerpc/include/asm/iommu.h
+++ b/arch/powerpc/include/asm/iommu.h
@@ -143,8 +143,6 @@ struct scatterlist;
 
 #ifdef CONFIG_PPC64
 
-#define IOMMU_MAPPING_ERROR		(~(dma_addr_t)0x0)
-
 static inline void set_iommu_table_base(struct device *dev,
 					struct iommu_table *base)
 {
@@ -242,8 +240,6 @@ static inline int __init tce_iommu_bus_notifier_init(void)
 }
 #endif /* !CONFIG_IOMMU_API */
 
-int dma_iommu_mapping_error(struct device *dev, dma_addr_t dma_addr);
-
 #else
 
 static inline void *get_iommu_table_base(struct device *dev)
diff --git a/arch/powerpc/kernel/dma-iommu.c b/arch/powerpc/kernel/dma-iommu.c
index f9fe2080ceb9..5ebacf0fe41a 100644
--- a/arch/powerpc/kernel/dma-iommu.c
+++ b/arch/powerpc/kernel/dma-iommu.c
@@ -106,11 +106,6 @@ static u64 dma_iommu_get_required_mask(struct device *dev)
 	return mask;
 }
 
-int dma_iommu_mapping_error(struct device *dev, dma_addr_t dma_addr)
-{
-	return dma_addr = IOMMU_MAPPING_ERROR;
-}
-
 struct dma_map_ops dma_iommu_ops = {
 	.alloc			= dma_iommu_alloc_coherent,
 	.free			= dma_iommu_free_coherent,
@@ -121,6 +116,5 @@ struct dma_map_ops dma_iommu_ops = {
 	.map_page		= dma_iommu_map_page,
 	.unmap_page		= dma_iommu_unmap_page,
 	.get_required_mask	= dma_iommu_get_required_mask,
-	.mapping_error		= dma_iommu_mapping_error,
 };
 EXPORT_SYMBOL(dma_iommu_ops);
diff --git a/arch/powerpc/kernel/iommu.c b/arch/powerpc/kernel/iommu.c
index f0dc680e659a..ca7f73488c62 100644
--- a/arch/powerpc/kernel/iommu.c
+++ b/arch/powerpc/kernel/iommu.c
@@ -197,11 +197,11 @@ static unsigned long iommu_range_alloc(struct device *dev,
 	if (unlikely(npages = 0)) {
 		if (printk_ratelimit())
 			WARN_ON(1);
-		return IOMMU_MAPPING_ERROR;
+		return DMA_MAPPING_ERROR;
 	}
 
 	if (should_fail_iommu(dev))
-		return IOMMU_MAPPING_ERROR;
+		return DMA_MAPPING_ERROR;
 
 	/*
 	 * We don't need to disable preemption here because any CPU can
@@ -277,7 +277,7 @@ static unsigned long iommu_range_alloc(struct device *dev,
 		} else {
 			/* Give up */
 			spin_unlock_irqrestore(&(pool->lock), flags);
-			return IOMMU_MAPPING_ERROR;
+			return DMA_MAPPING_ERROR;
 		}
 	}
 
@@ -309,13 +309,13 @@ static dma_addr_t iommu_alloc(struct device *dev, struct iommu_table *tbl,
 			      unsigned long attrs)
 {
 	unsigned long entry;
-	dma_addr_t ret = IOMMU_MAPPING_ERROR;
+	dma_addr_t ret = DMA_MAPPING_ERROR;
 	int build_fail;
 
 	entry = iommu_range_alloc(dev, tbl, npages, NULL, mask, align_order);
 
-	if (unlikely(entry = IOMMU_MAPPING_ERROR))
-		return IOMMU_MAPPING_ERROR;
+	if (unlikely(entry = DMA_MAPPING_ERROR))
+		return DMA_MAPPING_ERROR;
 
 	entry += tbl->it_offset;	/* Offset into real TCE table */
 	ret = entry << tbl->it_page_shift;	/* Set the return dma address */
@@ -327,12 +327,12 @@ static dma_addr_t iommu_alloc(struct device *dev, struct iommu_table *tbl,
 
 	/* tbl->it_ops->set() only returns non-zero for transient errors.
 	 * Clean up the table bitmap in this case and return
-	 * IOMMU_MAPPING_ERROR. For all other errors the functionality is
+	 * DMA_MAPPING_ERROR. For all other errors the functionality is
 	 * not altered.
 	 */
 	if (unlikely(build_fail)) {
 		__iommu_free(tbl, ret, npages);
-		return IOMMU_MAPPING_ERROR;
+		return DMA_MAPPING_ERROR;
 	}
 
 	/* Flush/invalidate TLB caches if necessary */
@@ -477,7 +477,7 @@ int ppc_iommu_map_sg(struct device *dev, struct iommu_table *tbl,
 		DBG("  - vaddr: %lx, size: %lx\n", vaddr, slen);
 
 		/* Handle failure */
-		if (unlikely(entry = IOMMU_MAPPING_ERROR)) {
+		if (unlikely(entry = DMA_MAPPING_ERROR)) {
 			if (!(attrs & DMA_ATTR_NO_WARN) &&
 			    printk_ratelimit())
 				dev_info(dev, "iommu_alloc failed, tbl %p "
@@ -544,7 +544,7 @@ int ppc_iommu_map_sg(struct device *dev, struct iommu_table *tbl,
 	 */
 	if (outcount < incount) {
 		outs = sg_next(outs);
-		outs->dma_address = IOMMU_MAPPING_ERROR;
+		outs->dma_address = DMA_MAPPING_ERROR;
 		outs->dma_length = 0;
 	}
 
@@ -562,7 +562,7 @@ int ppc_iommu_map_sg(struct device *dev, struct iommu_table *tbl,
 			npages = iommu_num_pages(s->dma_address, s->dma_length,
 						 IOMMU_PAGE_SIZE(tbl));
 			__iommu_free(tbl, vaddr, npages);
-			s->dma_address = IOMMU_MAPPING_ERROR;
+			s->dma_address = DMA_MAPPING_ERROR;
 			s->dma_length = 0;
 		}
 		if (s = outs)
@@ -776,7 +776,7 @@ dma_addr_t iommu_map_page(struct device *dev, struct iommu_table *tbl,
 			  unsigned long mask, enum dma_data_direction direction,
 			  unsigned long attrs)
 {
-	dma_addr_t dma_handle = IOMMU_MAPPING_ERROR;
+	dma_addr_t dma_handle = DMA_MAPPING_ERROR;
 	void *vaddr;
 	unsigned long uaddr;
 	unsigned int npages, align;
@@ -796,7 +796,7 @@ dma_addr_t iommu_map_page(struct device *dev, struct iommu_table *tbl,
 		dma_handle = iommu_alloc(dev, tbl, vaddr, npages, direction,
 					 mask >> tbl->it_page_shift, align,
 					 attrs);
-		if (dma_handle = IOMMU_MAPPING_ERROR) {
+		if (dma_handle = DMA_MAPPING_ERROR) {
 			if (!(attrs & DMA_ATTR_NO_WARN) &&
 			    printk_ratelimit())  {
 				dev_info(dev, "iommu_alloc failed, tbl %p "
@@ -868,7 +868,7 @@ void *iommu_alloc_coherent(struct device *dev, struct iommu_table *tbl,
 	io_order = get_iommu_order(size, tbl);
 	mapping = iommu_alloc(dev, tbl, ret, nio_pages, DMA_BIDIRECTIONAL,
 			      mask >> tbl->it_page_shift, io_order, 0);
-	if (mapping = IOMMU_MAPPING_ERROR) {
+	if (mapping = DMA_MAPPING_ERROR) {
 		free_pages((unsigned long)ret, order);
 		return NULL;
 	}
diff --git a/arch/powerpc/platforms/cell/iommu.c b/arch/powerpc/platforms/cell/iommu.c
index 12352a58072a..af2a3c15e0ec 100644
--- a/arch/powerpc/platforms/cell/iommu.c
+++ b/arch/powerpc/platforms/cell/iommu.c
@@ -654,7 +654,6 @@ static const struct dma_map_ops dma_iommu_fixed_ops = {
 	.dma_supported  = dma_suported_and_switch,
 	.map_page       = dma_fixed_map_page,
 	.unmap_page     = dma_fixed_unmap_page,
-	.mapping_error	= dma_iommu_mapping_error,
 };
 
 static void cell_dma_dev_setup(struct device *dev)
diff --git a/arch/powerpc/platforms/pseries/vio.c b/arch/powerpc/platforms/pseries/vio.c
index 88f1ad1d6309..a29ad7db918a 100644
--- a/arch/powerpc/platforms/pseries/vio.c
+++ b/arch/powerpc/platforms/pseries/vio.c
@@ -519,7 +519,7 @@ static dma_addr_t vio_dma_iommu_map_page(struct device *dev, struct page *page,
 {
 	struct vio_dev *viodev = to_vio_dev(dev);
 	struct iommu_table *tbl;
-	dma_addr_t ret = IOMMU_MAPPING_ERROR;
+	dma_addr_t ret = DMA_MAPPING_ERROR;
 
 	tbl = get_iommu_table_base(dev);
 	if (vio_cmo_alloc(viodev, roundup(size, IOMMU_PAGE_SIZE(tbl)))) {
@@ -625,7 +625,6 @@ static const struct dma_map_ops vio_dma_mapping_ops = {
 	.unmap_page        = vio_dma_iommu_unmap_page,
 	.dma_supported     = vio_dma_iommu_dma_supported,
 	.get_required_mask = vio_dma_get_required_mask,
-	.mapping_error	   = dma_iommu_mapping_error,
 };
 
 /**
-- 
2.19.1
