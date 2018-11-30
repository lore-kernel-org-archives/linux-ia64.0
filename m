From: Christoph Hellwig <hch@lst.de>
Date: Fri, 30 Nov 2018 13:22:23 +0000
Subject: [PATCH 15/23] x86/amd_gart: remove the mapping_error dma_map_ops method
Message-Id: <20181130132231.16512-16-hch@lst.de>
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
 arch/x86/kernel/amd_gart_64.c | 39 ++++++-----------------------------
 1 file changed, 6 insertions(+), 33 deletions(-)

diff --git a/arch/x86/kernel/amd_gart_64.c b/arch/x86/kernel/amd_gart_64.c
index 3f9d1b4019bb..4e733de93f41 100644
--- a/arch/x86/kernel/amd_gart_64.c
+++ b/arch/x86/kernel/amd_gart_64.c
@@ -50,8 +50,6 @@ static unsigned long iommu_pages;	/* .. and in pages */
 
 static u32 *iommu_gatt_base;		/* Remapping table */
 
-static dma_addr_t bad_dma_addr;
-
 /*
  * If this is disabled the IOMMU will use an optimized flushing strategy
  * of only flushing when an mapping is reused. With it true the GART is
@@ -74,8 +72,6 @@ static u32 gart_unmapped_entry;
 	(((x) & 0xfffff000) | (((x) >> 32) << 4) | GPTE_VALID | GPTE_COHERENT)
 #define GPTE_DECODE(x) (((x) & 0xfffff000) | (((u64)(x) & 0xff0) << 28))
 
-#define EMERGENCY_PAGES 32 /* = 128KB */
-
 #ifdef CONFIG_AGP
 #define AGPEXTERN extern
 #else
@@ -184,14 +180,6 @@ static void iommu_full(struct device *dev, size_t size, int dir)
 	 */
 
 	dev_err(dev, "PCI-DMA: Out of IOMMU space for %lu bytes\n", size);
-
-	if (size > PAGE_SIZE*EMERGENCY_PAGES) {
-		if (dir = PCI_DMA_FROMDEVICE || dir = PCI_DMA_BIDIRECTIONAL)
-			panic("PCI-DMA: Memory would be corrupted\n");
-		if (dir = PCI_DMA_TODEVICE || dir = PCI_DMA_BIDIRECTIONAL)
-			panic(KERN_ERR
-				"PCI-DMA: Random memory would be DMAed\n");
-	}
 #ifdef CONFIG_IOMMU_LEAK
 	dump_leak();
 #endif
@@ -220,7 +208,7 @@ static dma_addr_t dma_map_area(struct device *dev, dma_addr_t phys_mem,
 	int i;
 
 	if (unlikely(phys_mem + size > GART_MAX_PHYS_ADDR))
-		return bad_dma_addr;
+		return DMA_MAPPING_ERROR;
 
 	iommu_page = alloc_iommu(dev, npages, align_mask);
 	if (iommu_page = -1) {
@@ -229,7 +217,7 @@ static dma_addr_t dma_map_area(struct device *dev, dma_addr_t phys_mem,
 		if (panic_on_overflow)
 			panic("dma_map_area overflow %lu bytes\n", size);
 		iommu_full(dev, size, dir);
-		return bad_dma_addr;
+		return DMA_MAPPING_ERROR;
 	}
 
 	for (i = 0; i < npages; i++) {
@@ -271,7 +259,7 @@ static void gart_unmap_page(struct device *dev, dma_addr_t dma_addr,
 	int npages;
 	int i;
 
-	if (dma_addr < iommu_bus_base + EMERGENCY_PAGES*PAGE_SIZE ||
+	if (dma_addr = DMA_MAPPING_ERROR ||
 	    dma_addr >= iommu_bus_base + iommu_size)
 		return;
 
@@ -315,7 +303,7 @@ static int dma_map_sg_nonforce(struct device *dev, struct scatterlist *sg,
 
 		if (nonforced_iommu(dev, addr, s->length)) {
 			addr = dma_map_area(dev, addr, s->length, dir, 0);
-			if (addr = bad_dma_addr) {
+			if (addr = DMA_MAPPING_ERROR) {
 				if (i > 0)
 					gart_unmap_sg(dev, sg, i, dir, 0);
 				nents = 0;
@@ -471,7 +459,7 @@ static int gart_map_sg(struct device *dev, struct scatterlist *sg, int nents,
 
 	iommu_full(dev, pages << PAGE_SHIFT, dir);
 	for_each_sg(sg, s, nents, i)
-		s->dma_address = bad_dma_addr;
+		s->dma_address = DMA_MAPPING_ERROR;
 	return 0;
 }
 
@@ -490,7 +478,7 @@ gart_alloc_coherent(struct device *dev, size_t size, dma_addr_t *dma_addr,
 	*dma_addr = dma_map_area(dev, virt_to_phys(vaddr), size,
 			DMA_BIDIRECTIONAL, (1UL << get_order(size)) - 1);
 	flush_gart();
-	if (unlikely(*dma_addr = bad_dma_addr))
+	if (unlikely(*dma_addr = DMA_MAPPING_ERROR))
 		goto out_free;
 	return vaddr;
 out_free:
@@ -507,11 +495,6 @@ gart_free_coherent(struct device *dev, size_t size, void *vaddr,
 	dma_direct_free_pages(dev, size, vaddr, dma_addr, attrs);
 }
 
-static int gart_mapping_error(struct device *dev, dma_addr_t dma_addr)
-{
-	return (dma_addr = bad_dma_addr);
-}
-
 static int no_agp;
 
 static __init unsigned long check_iommu_size(unsigned long aper, u64 aper_size)
@@ -695,7 +678,6 @@ static const struct dma_map_ops gart_dma_ops = {
 	.unmap_page			= gart_unmap_page,
 	.alloc				= gart_alloc_coherent,
 	.free				= gart_free_coherent,
-	.mapping_error			= gart_mapping_error,
 	.dma_supported			= dma_direct_supported,
 };
 
@@ -784,19 +766,12 @@ int __init gart_iommu_init(void)
 	}
 #endif
 
-	/*
-	 * Out of IOMMU space handling.
-	 * Reserve some invalid pages at the beginning of the GART.
-	 */
-	bitmap_set(iommu_gart_bitmap, 0, EMERGENCY_PAGES);
-
 	pr_info("PCI-DMA: Reserving %luMB of IOMMU area in the AGP aperture\n",
 	       iommu_size >> 20);
 
 	agp_memory_reserved	= iommu_size;
 	iommu_start		= aper_size - iommu_size;
 	iommu_bus_base		= info.aper_base + iommu_start;
-	bad_dma_addr		= iommu_bus_base;
 	iommu_gatt_base		= agp_gatt_table + (iommu_start>>PAGE_SHIFT);
 
 	/*
@@ -838,8 +813,6 @@ int __init gart_iommu_init(void)
 	if (!scratch)
 		panic("Cannot allocate iommu scratch page");
 	gart_unmapped_entry = GPTE_ENCODE(__pa(scratch));
-	for (i = EMERGENCY_PAGES; i < iommu_pages; i++)
-		iommu_gatt_base[i] = gart_unmapped_entry;
 
 	flush_gart();
 	dma_ops = &gart_dma_ops;
-- 
2.19.1
