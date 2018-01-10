From: Christoph Hellwig <hch@lst.de>
Date: Wed, 10 Jan 2018 08:09:28 +0000
Subject: [PATCH 18/22] tile: use generic swiotlb_ops
Message-Id: <20180110080932.14157-19-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180110080932.14157-1-hch@lst.de>
In-Reply-To: <20180110080932.14157-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: iommu@lists.linux-foundation.org
Cc: Konrad Rzeszutek Wilk <konrad@darnok.org>, Michal Simek <monstr@monstr.eu>, Guan Xuetao <gxt@mprc.pku.edu.cn>, =?UTF-8?q?Christian=20K=C3=B6nig?= <ckoenig.leichtzumerken@gmail.com>, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

These are identical to the tile ops, and would also support CMA
if enabled on tile.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/tile/Kconfig          |  1 +
 arch/tile/kernel/pci-dma.c | 36 +++---------------------------------
 2 files changed, 4 insertions(+), 33 deletions(-)

diff --git a/arch/tile/Kconfig b/arch/tile/Kconfig
index 30c586686f29..ef9d403cbbe4 100644
--- a/arch/tile/Kconfig
+++ b/arch/tile/Kconfig
@@ -261,6 +261,7 @@ config NEED_SG_DMA_LENGTH
 config SWIOTLB
 	bool
 	default TILEGX
+	select DMA_DIRECT_OPS
 	select IOMMU_HELPER
 	select NEED_SG_DMA_LENGTH
 	select ARCH_HAS_DMA_SET_COHERENT_MASK
diff --git a/arch/tile/kernel/pci-dma.c b/arch/tile/kernel/pci-dma.c
index a267fa740048..6a1efe5543fa 100644
--- a/arch/tile/kernel/pci-dma.c
+++ b/arch/tile/kernel/pci-dma.c
@@ -509,39 +509,9 @@ EXPORT_SYMBOL(gx_pci_dma_map_ops);
 /* PCI DMA mapping functions for legacy PCI devices */
 
 #ifdef CONFIG_SWIOTLB
-static void *tile_swiotlb_alloc_coherent(struct device *dev, size_t size,
-					 dma_addr_t *dma_handle, gfp_t gfp,
-					 unsigned long attrs)
-{
-	gfp |= GFP_DMA32;
-	return swiotlb_alloc_coherent(dev, size, dma_handle, gfp);
-}
-
-static void tile_swiotlb_free_coherent(struct device *dev, size_t size,
-				       void *vaddr, dma_addr_t dma_addr,
-				       unsigned long attrs)
-{
-	swiotlb_free_coherent(dev, size, vaddr, dma_addr);
-}
-
-static const struct dma_map_ops pci_swiotlb_dma_ops = {
-	.alloc = tile_swiotlb_alloc_coherent,
-	.free = tile_swiotlb_free_coherent,
-	.map_page = swiotlb_map_page,
-	.unmap_page = swiotlb_unmap_page,
-	.map_sg = swiotlb_map_sg_attrs,
-	.unmap_sg = swiotlb_unmap_sg_attrs,
-	.sync_single_for_cpu = swiotlb_sync_single_for_cpu,
-	.sync_single_for_device = swiotlb_sync_single_for_device,
-	.sync_sg_for_cpu = swiotlb_sync_sg_for_cpu,
-	.sync_sg_for_device = swiotlb_sync_sg_for_device,
-	.dma_supported = swiotlb_dma_supported,
-	.mapping_error = swiotlb_dma_mapping_error,
-};
-
 static const struct dma_map_ops pci_hybrid_dma_ops = {
-	.alloc = tile_swiotlb_alloc_coherent,
-	.free = tile_swiotlb_free_coherent,
+	.alloc = swiotlb_alloc,
+	.free = swiotlb_free,
 	.map_page = tile_pci_dma_map_page,
 	.unmap_page = tile_pci_dma_unmap_page,
 	.map_sg = tile_pci_dma_map_sg,
@@ -552,7 +522,7 @@ static const struct dma_map_ops pci_hybrid_dma_ops = {
 	.sync_sg_for_device = tile_pci_dma_sync_sg_for_device,
 };
 
-const struct dma_map_ops *gx_legacy_pci_dma_map_ops = &pci_swiotlb_dma_ops;
+const struct dma_map_ops *gx_legacy_pci_dma_map_ops = &swiotlb_dma_ops;
 const struct dma_map_ops *gx_hybrid_pci_dma_map_ops = &pci_hybrid_dma_ops;
 #else
 const struct dma_map_ops *gx_legacy_pci_dma_map_ops;
-- 
2.14.2

