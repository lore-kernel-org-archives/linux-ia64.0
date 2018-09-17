From: Christoph Hellwig <hch@lst.de>
Date: Mon, 17 Sep 2018 17:10:25 +0000
Subject: [PATCH 3/9] ia64: remove iommu_dma_supported
Message-Id: <20180917171031.3853-4-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The generic dma_direct_supported helper already used by intel-iommu on
x86 does a better job than the ia64 reimplementation.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/ia64/kernel/pci-dma.c  | 13 -------------
 drivers/iommu/intel-iommu.c |  2 --
 2 files changed, 15 deletions(-)

diff --git a/arch/ia64/kernel/pci-dma.c b/arch/ia64/kernel/pci-dma.c
index 50b6ad282a90..3c2884bef3d4 100644
--- a/arch/ia64/kernel/pci-dma.c
+++ b/arch/ia64/kernel/pci-dma.c
@@ -51,18 +51,6 @@ iommu_dma_init(void)
 	return;
 }
 
-int iommu_dma_supported(struct device *dev, u64 mask)
-{
-	/* Copied from i386. Doesn't make much sense, because it will
-	   only work for pci_alloc_coherent.
-	   The caller just has to use GFP_DMA in this case. */
-	if (mask < DMA_BIT_MASK(24))
-		return 0;
-
-	return 1;
-}
-EXPORT_SYMBOL(iommu_dma_supported);
-
 void __init pci_iommu_alloc(void)
 {
 	dma_ops = &intel_dma_ops;
@@ -71,7 +59,6 @@ void __init pci_iommu_alloc(void)
 	intel_dma_ops.sync_sg_for_cpu = machvec_dma_sync_sg;
 	intel_dma_ops.sync_single_for_device = machvec_dma_sync_single;
 	intel_dma_ops.sync_sg_for_device = machvec_dma_sync_sg;
-	intel_dma_ops.dma_supported = iommu_dma_supported;
 
 	/*
 	 * The order of these functions is important for
diff --git a/drivers/iommu/intel-iommu.c b/drivers/iommu/intel-iommu.c
index 5f3f10cf9d9d..e72efef97924 100644
--- a/drivers/iommu/intel-iommu.c
+++ b/drivers/iommu/intel-iommu.c
@@ -3903,9 +3903,7 @@ const struct dma_map_ops intel_dma_ops = {
 	.map_page = intel_map_page,
 	.unmap_page = intel_unmap_page,
 	.mapping_error = intel_mapping_error,
-#ifdef CONFIG_X86
 	.dma_supported = dma_direct_supported,
-#endif
 };
 
 static inline int iommu_domain_cache_init(void)
-- 
2.18.0
