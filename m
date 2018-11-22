From: Christoph Hellwig <hch@lst.de>
Date: Thu, 22 Nov 2018 14:03:04 +0000
Subject: [PATCH 08/24] s390: remove the mapping_error dma_map_ops method
Message-Id: <20181122140320.24080-9-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20181122140320.24080-1-hch@lst.de>
In-Reply-To: <20181122140320.24080-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: iommu@lists.linux-foundation.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Jon Mason <jdmason@kudzu.us>, Joerg Roedel <joro@8bytes.org>, David Woodhouse <dwmw2@infradead.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Robin Murphy <robin.murphy@arm.com>, x86@kernel.org, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, xen-devel@lists.xenproject.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

S390 already returns (~(dma_addr_t)0x0) on mapping failures, so we can
switch over to returning DMA_MAPPING_ERROR and let the core dma-mapping
code handle the rest.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/s390/pci/pci_dma.c | 18 +++++-------------
 1 file changed, 5 insertions(+), 13 deletions(-)

diff --git a/arch/s390/pci/pci_dma.c b/arch/s390/pci/pci_dma.c
index d387a0fbdd7e..346ba382193a 100644
--- a/arch/s390/pci/pci_dma.c
+++ b/arch/s390/pci/pci_dma.c
@@ -15,8 +15,6 @@
 #include <linux/pci.h>
 #include <asm/pci_dma.h>
 
-#define S390_MAPPING_ERROR		(~(dma_addr_t) 0x0)
-
 static struct kmem_cache *dma_region_table_cache;
 static struct kmem_cache *dma_page_table_cache;
 static int s390_iommu_strict;
@@ -301,7 +299,7 @@ static dma_addr_t dma_alloc_address(struct device *dev, int size)
 
 out_error:
 	spin_unlock_irqrestore(&zdev->iommu_bitmap_lock, flags);
-	return S390_MAPPING_ERROR;
+	return DMA_MAPPING_ERROR;
 }
 
 static void dma_free_address(struct device *dev, dma_addr_t dma_addr, int size)
@@ -349,7 +347,7 @@ static dma_addr_t s390_dma_map_pages(struct device *dev, struct page *page,
 	/* This rounds up number of pages based on size and offset */
 	nr_pages = iommu_num_pages(pa, size, PAGE_SIZE);
 	dma_addr = dma_alloc_address(dev, nr_pages);
-	if (dma_addr = S390_MAPPING_ERROR) {
+	if (dma_addr = DMA_MAPPING_ERROR) {
 		ret = -ENOSPC;
 		goto out_err;
 	}
@@ -372,7 +370,7 @@ static dma_addr_t s390_dma_map_pages(struct device *dev, struct page *page,
 out_err:
 	zpci_err("map error:\n");
 	zpci_err_dma(ret, pa);
-	return S390_MAPPING_ERROR;
+	return DMA_MAPPING_ERROR;
 }
 
 static void s390_dma_unmap_pages(struct device *dev, dma_addr_t dma_addr,
@@ -449,7 +447,7 @@ static int __s390_dma_map_sg(struct device *dev, struct scatterlist *sg,
 	int ret;
 
 	dma_addr_base = dma_alloc_address(dev, nr_pages);
-	if (dma_addr_base = S390_MAPPING_ERROR)
+	if (dma_addr_base = DMA_MAPPING_ERROR)
 		return -ENOMEM;
 
 	dma_addr = dma_addr_base;
@@ -496,7 +494,7 @@ static int s390_dma_map_sg(struct device *dev, struct scatterlist *sg,
 	for (i = 1; i < nr_elements; i++) {
 		s = sg_next(s);
 
-		s->dma_address = S390_MAPPING_ERROR;
+		s->dma_address = DMA_MAPPING_ERROR;
 		s->dma_length = 0;
 
 		if (s->offset || (size & ~PAGE_MASK) ||
@@ -546,11 +544,6 @@ static void s390_dma_unmap_sg(struct device *dev, struct scatterlist *sg,
 	}
 }
 	
-static int s390_mapping_error(struct device *dev, dma_addr_t dma_addr)
-{
-	return dma_addr = S390_MAPPING_ERROR;
-}
-
 int zpci_dma_init_device(struct zpci_dev *zdev)
 {
 	int rc;
@@ -675,7 +668,6 @@ const struct dma_map_ops s390_pci_dma_ops = {
 	.unmap_sg	= s390_dma_unmap_sg,
 	.map_page	= s390_dma_map_pages,
 	.unmap_page	= s390_dma_unmap_pages,
-	.mapping_error	= s390_mapping_error,
 	/* dma_supported is unconditionally true without a callback */
 };
 EXPORT_SYMBOL_GPL(s390_pci_dma_ops);
-- 
2.19.1
