From: Christoph Hellwig <hch@lst.de>
Date: Thu, 08 Jun 2017 13:26:07 +0000
Subject: [PATCH 42/44] powerpc/cell: use the dma_supported method for ops switching
Message-Id: <20170608132609.32662-43-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170608132609.32662-1-hch@lst.de>
In-Reply-To: <20170608132609.32662-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: x86@kernel.org, linux-arm-kernel@lists.infradead.org, xen-devel@lists.xenproject.org, linux-c6x-dev@linux-c6x.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, openrisc@lists.librecores.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, dmaengine@vger.kernel.org, linux-tegra@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-samsung-soc@vger.kernel.org, iommu@lists.linux-foundation.org, netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org

Besides removing the last instance of the set_dma_mask method this also
reduced the code duplication.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/powerpc/platforms/cell/iommu.c | 25 +++++++++----------------
 1 file changed, 9 insertions(+), 16 deletions(-)

diff --git a/arch/powerpc/platforms/cell/iommu.c b/arch/powerpc/platforms/cell/iommu.c
index 497bfbdbd967..29d4f96ed33e 100644
--- a/arch/powerpc/platforms/cell/iommu.c
+++ b/arch/powerpc/platforms/cell/iommu.c
@@ -644,20 +644,14 @@ static void dma_fixed_unmap_sg(struct device *dev, struct scatterlist *sg,
 				   direction, attrs);
 }
 
-static int dma_fixed_dma_supported(struct device *dev, u64 mask)
-{
-	return mask = DMA_BIT_MASK(64);
-}
-
-static int dma_set_mask_and_switch(struct device *dev, u64 dma_mask);
+static int dma_suported_and_switch(struct device *dev, u64 dma_mask);
 
 static const struct dma_map_ops dma_iommu_fixed_ops = {
 	.alloc          = dma_fixed_alloc_coherent,
 	.free           = dma_fixed_free_coherent,
 	.map_sg         = dma_fixed_map_sg,
 	.unmap_sg       = dma_fixed_unmap_sg,
-	.dma_supported  = dma_fixed_dma_supported,
-	.set_dma_mask   = dma_set_mask_and_switch,
+	.dma_supported  = dma_suported_and_switch,
 	.map_page       = dma_fixed_map_page,
 	.unmap_page     = dma_fixed_unmap_page,
 	.mapping_error	= dma_iommu_mapping_error,
@@ -952,11 +946,8 @@ static u64 cell_iommu_get_fixed_address(struct device *dev)
 	return dev_addr;
 }
 
-static int dma_set_mask_and_switch(struct device *dev, u64 dma_mask)
+static int dma_suported_and_switch(struct device *dev, u64 dma_mask)
 {
-	if (!dev->dma_mask || !dma_supported(dev, dma_mask))
-		return -EIO;
-
 	if (dma_mask = DMA_BIT_MASK(64) &&
 	    cell_iommu_get_fixed_address(dev) != OF_BAD_ADDR) {
 		u64 addr = cell_iommu_get_fixed_address(dev) +
@@ -965,14 +956,16 @@ static int dma_set_mask_and_switch(struct device *dev, u64 dma_mask)
 		dev_dbg(dev, "iommu: fixed addr = %llx\n", addr);
 		set_dma_ops(dev, &dma_iommu_fixed_ops);
 		set_dma_offset(dev, addr);
-	} else {
+		return 1;
+	}
+
+	if (dma_iommu_dma_supported(dev, dma_mask)) {
 		dev_dbg(dev, "iommu: not 64-bit, using default ops\n");
 		set_dma_ops(dev, get_pci_dma_ops());
 		cell_dma_dev_setup(dev);
+		return 1;
 	}
 
-	*dev->dma_mask = dma_mask;
-
 	return 0;
 }
 
@@ -1127,7 +1120,7 @@ static int __init cell_iommu_fixed_mapping_init(void)
 		cell_iommu_setup_window(iommu, np, dbase, dsize, 0);
 	}
 
-	dma_iommu_ops.set_dma_mask = dma_set_mask_and_switch;
+	dma_iommu_ops.dma_supported = dma_suported_and_switch;
 	set_pci_dma_ops(&dma_iommu_ops);
 
 	return 0;
-- 
2.11.0

