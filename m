From: Christoph Hellwig <hch@lst.de>
Date: Fri, 30 Nov 2018 13:22:19 +0000
Subject: [PATCH 11/23] alpha: remove the mapping_error dma_map_ops method
Message-Id: <20181130132231.16512-12-hch@lst.de>
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
 arch/alpha/kernel/pci_iommu.c | 14 ++++----------
 1 file changed, 4 insertions(+), 10 deletions(-)

diff --git a/arch/alpha/kernel/pci_iommu.c b/arch/alpha/kernel/pci_iommu.c
index 46e08e0d9181..e1716e0d92fd 100644
--- a/arch/alpha/kernel/pci_iommu.c
+++ b/arch/alpha/kernel/pci_iommu.c
@@ -291,7 +291,7 @@ pci_map_single_1(struct pci_dev *pdev, void *cpu_addr, size_t size,
 	   use direct_map above, it now must be considered an error. */
 	if (! alpha_mv.mv_pci_tbi) {
 		printk_once(KERN_WARNING "pci_map_single: no HW sg\n");
-		return 0;
+		return DMA_MAPPING_ERROR;
 	}
 
 	arena = hose->sg_pci;
@@ -307,7 +307,7 @@ pci_map_single_1(struct pci_dev *pdev, void *cpu_addr, size_t size,
 	if (dma_ofs < 0) {
 		printk(KERN_WARNING "pci_map_single failed: "
 		       "could not allocate dma page tables\n");
-		return 0;
+		return DMA_MAPPING_ERROR;
 	}
 
 	paddr &= PAGE_MASK;
@@ -455,7 +455,7 @@ static void *alpha_pci_alloc_coherent(struct device *dev, size_t size,
 	memset(cpu_addr, 0, size);
 
 	*dma_addrp = pci_map_single_1(pdev, cpu_addr, size, 0);
-	if (*dma_addrp = 0) {
+	if (*dma_addrp = DMA_MAPPING_ERROR) {
 		free_pages((unsigned long)cpu_addr, order);
 		if (alpha_mv.mv_pci_tbi || (gfp & GFP_DMA))
 			return NULL;
@@ -671,7 +671,7 @@ static int alpha_pci_map_sg(struct device *dev, struct scatterlist *sg,
 		sg->dma_address
 		  = pci_map_single_1(pdev, SG_ENT_VIRT_ADDRESS(sg),
 				     sg->length, dac_allowed);
-		return sg->dma_address != 0;
+		return sg->dma_address != DMA_MAPPING_ERROR;
 	}
 
 	start = sg;
@@ -935,11 +935,6 @@ iommu_unbind(struct pci_iommu_arena *arena, long pg_start, long pg_count)
 	return 0;
 }
 
-static int alpha_pci_mapping_error(struct device *dev, dma_addr_t dma_addr)
-{
-	return dma_addr = 0;
-}
-
 const struct dma_map_ops alpha_pci_ops = {
 	.alloc			= alpha_pci_alloc_coherent,
 	.free			= alpha_pci_free_coherent,
@@ -947,7 +942,6 @@ const struct dma_map_ops alpha_pci_ops = {
 	.unmap_page		= alpha_pci_unmap_page,
 	.map_sg			= alpha_pci_map_sg,
 	.unmap_sg		= alpha_pci_unmap_sg,
-	.mapping_error		= alpha_pci_mapping_error,
 	.dma_supported		= alpha_pci_supported,
 };
 EXPORT_SYMBOL(alpha_pci_ops);
-- 
2.19.1
