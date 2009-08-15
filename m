From: Fenghua Yu <fenghua.yu@intel.com>
Date: Sat, 15 Aug 2009 00:33:00 +0000
Subject: [PATCH 2.6.30 stable] Bug Fix arch/ia64/kernel/pci-dma.c: fix recursive dma_supported() call in iomm
Message-Id: <20090815003259.GA18989@linux-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The commit 160c1d8e40866edfeae7d68816b7005d70acf391 introduced
dma_ops->dma_supported = iommu_dma_supported;
 
This dma_ops->dma_supported is first called in platform_dma_init() during kernel
boot. Then dma_ops->dma_supported will be called recursively in
iommu_dma_supported.
 
Kernel can not boot because kernel can not get out of iommu_dma_supported until
it runs out of stack memory.

This patch is in commit 51b89f7a6615eca184aa0b85db5781d931e9c8d1

Signed-off-by: Fenghua Yu <fenghua.yu@intel.com>

---
 
 arch/ia64/kernel/pci-dma.c |    5 -----
 1 files changed, 5 deletions(-)

diff --git a/arch/ia64/kernel/pci-dma.c b/arch/ia64/kernel/pci-dma.c
index 0569596..f6b1ff0 100644
--- a/arch/ia64/kernel/pci-dma.c
+++ b/arch/ia64/kernel/pci-dma.c
@@ -69,11 +69,6 @@ iommu_dma_init(void)
 
 int iommu_dma_supported(struct device *dev, u64 mask)
 {
-	struct dma_map_ops *ops = platform_dma_get_ops(dev);
-
-	if (ops->dma_supported)
-		return ops->dma_supported(dev, mask);
-
 	/* Copied from i386. Doesn't make much sense, because it will
 	   only work for pci_alloc_coherent.
 	   The caller just has to use GFP_DMA in this case. */
