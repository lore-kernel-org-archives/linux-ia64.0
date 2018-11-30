From: Christoph Hellwig <hch@lst.de>
Date: Fri, 30 Nov 2018 13:22:24 +0000
Subject: [PATCH 16/23] x86/calgary: remove the mapping_error dma_map_ops method
Message-Id: <20181130132231.16512-17-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20181130132231.16512-1-hch@lst.de>
In-Reply-To: <20181130132231.16512-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: iommu@lists.linux-foundation.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Jon Mason <jdmason@kudzu.us>, Joerg Roedel <joro@8bytes.org>, David Woodhouse <dwmw2@infradead.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Robin Murphy <robin.murphy@arm.com>, x86@kernel.org, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, xen-devel@lists.xenproject.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

Return DMA_MAPPING_ERROR instead of the magic bad_dma_addr on a dma
mapping failure and let the core dma-mapping code handle the rest.

Remove the magic EMERGENCY_PAGES that the bad_dma_addr gets redirected to.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/x86/kernel/pci-calgary_64.c | 29 +++++++----------------------
 1 file changed, 7 insertions(+), 22 deletions(-)

diff --git a/arch/x86/kernel/pci-calgary_64.c b/arch/x86/kernel/pci-calgary_64.c
index bbfc8b1e9104..e76ec1b8ed1f 100644
--- a/arch/x86/kernel/pci-calgary_64.c
+++ b/arch/x86/kernel/pci-calgary_64.c
@@ -51,8 +51,6 @@
 #include <asm/x86_init.h>
 #include <asm/iommu_table.h>
 
-#define CALGARY_MAPPING_ERROR	0
-
 #ifdef CONFIG_CALGARY_IOMMU_ENABLED_BY_DEFAULT
 int use_calgary __read_mostly = 1;
 #else
@@ -157,8 +155,6 @@ static const unsigned long phb_debug_offsets[] = {
 
 #define PHB_DEBUG_STUFF_OFFSET	0x0020
 
-#define EMERGENCY_PAGES 32 /* = 128KB */
-
 unsigned int specified_table_size = TCE_TABLE_SIZE_UNSPECIFIED;
 static int translate_empty_slots __read_mostly = 0;
 static int calgary_detected __read_mostly = 0;
@@ -255,7 +251,7 @@ static unsigned long iommu_range_alloc(struct device *dev,
 			if (panic_on_overflow)
 				panic("Calgary: fix the allocator.\n");
 			else
-				return CALGARY_MAPPING_ERROR;
+				return DMA_MAPPING_ERROR;
 		}
 	}
 
@@ -274,11 +270,10 @@ static dma_addr_t iommu_alloc(struct device *dev, struct iommu_table *tbl,
 	dma_addr_t ret;
 
 	entry = iommu_range_alloc(dev, tbl, npages);
-
-	if (unlikely(entry = CALGARY_MAPPING_ERROR)) {
+	if (unlikely(entry = DMA_MAPPING_ERROR)) {
 		pr_warn("failed to allocate %u pages in iommu %p\n",
 			npages, tbl);
-		return CALGARY_MAPPING_ERROR;
+		return DMA_MAPPING_ERROR;
 	}
 
 	/* set the return dma address */
@@ -298,8 +293,7 @@ static void iommu_free(struct iommu_table *tbl, dma_addr_t dma_addr,
 	unsigned long flags;
 
 	/* were we called with bad_dma_address? */
-	badend = CALGARY_MAPPING_ERROR + (EMERGENCY_PAGES * PAGE_SIZE);
-	if (unlikely(dma_addr < badend)) {
+	if (unlikely(dma_addr = DMA_MAPPING_ERROR)) {
 		WARN(1, KERN_ERR "Calgary: driver tried unmapping bad DMA "
 		       "address 0x%Lx\n", dma_addr);
 		return;
@@ -383,7 +377,7 @@ static int calgary_map_sg(struct device *dev, struct scatterlist *sg,
 		npages = iommu_num_pages(vaddr, s->length, PAGE_SIZE);
 
 		entry = iommu_range_alloc(dev, tbl, npages);
-		if (entry = CALGARY_MAPPING_ERROR) {
+		if (entry = DMA_MAPPING_ERROR) {
 			/* makes sure unmap knows to stop */
 			s->dma_length = 0;
 			goto error;
@@ -401,7 +395,7 @@ static int calgary_map_sg(struct device *dev, struct scatterlist *sg,
 error:
 	calgary_unmap_sg(dev, sg, nelems, dir, 0);
 	for_each_sg(sg, s, nelems, i) {
-		sg->dma_address = CALGARY_MAPPING_ERROR;
+		sg->dma_address = DMA_MAPPING_ERROR;
 		sg->dma_length = 0;
 	}
 	return 0;
@@ -454,7 +448,7 @@ static void* calgary_alloc_coherent(struct device *dev, size_t size,
 
 	/* set up tces to cover the allocated range */
 	mapping = iommu_alloc(dev, tbl, ret, npages, DMA_BIDIRECTIONAL);
-	if (mapping = CALGARY_MAPPING_ERROR)
+	if (mapping = DMA_MAPPING_ERROR)
 		goto free;
 	*dma_handle = mapping;
 	return ret;
@@ -479,11 +473,6 @@ static void calgary_free_coherent(struct device *dev, size_t size,
 	free_pages((unsigned long)vaddr, get_order(size));
 }
 
-static int calgary_mapping_error(struct device *dev, dma_addr_t dma_addr)
-{
-	return dma_addr = CALGARY_MAPPING_ERROR;
-}
-
 static const struct dma_map_ops calgary_dma_ops = {
 	.alloc = calgary_alloc_coherent,
 	.free = calgary_free_coherent,
@@ -491,7 +480,6 @@ static const struct dma_map_ops calgary_dma_ops = {
 	.unmap_sg = calgary_unmap_sg,
 	.map_page = calgary_map_page,
 	.unmap_page = calgary_unmap_page,
-	.mapping_error = calgary_mapping_error,
 	.dma_supported = dma_direct_supported,
 };
 
@@ -739,9 +727,6 @@ static void __init calgary_reserve_regions(struct pci_dev *dev)
 	u64 start;
 	struct iommu_table *tbl = pci_iommu(dev->bus);
 
-	/* reserve EMERGENCY_PAGES from bad_dma_address and up */
-	iommu_range_reserve(tbl, CALGARY_MAPPING_ERROR, EMERGENCY_PAGES);
-
 	/* avoid the BIOS/VGA first 640KB-1MB region */
 	/* for CalIOC2 - avoid the entire first MB */
 	if (is_calgary(dev->device)) {
-- 
2.19.1
