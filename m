From: Christoph Hellwig <hch@lst.de>
Date: Thu, 22 Nov 2018 14:03:20 +0000
Subject: [PATCH 24/24] dma-mapping: remove the mapping_error dma_map_ops method
Message-Id: <20181122140320.24080-25-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20181122140320.24080-1-hch@lst.de>
In-Reply-To: <20181122140320.24080-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: iommu@lists.linux-foundation.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Jon Mason <jdmason@kudzu.us>, Joerg Roedel <joro@8bytes.org>, David Woodhouse <dwmw2@infradead.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Robin Murphy <robin.murphy@arm.com>, x86@kernel.org, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, xen-devel@lists.xenproject.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

No users left except for vmd which just forwards it.  Also switch
dma_mapping_error to an explicit bool return value.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 drivers/pci/controller/vmd.c |  6 ------
 include/linux/dma-mapping.h  | 13 ++-----------
 2 files changed, 2 insertions(+), 17 deletions(-)

diff --git a/drivers/pci/controller/vmd.c b/drivers/pci/controller/vmd.c
index e50b0b5815ff..98ce79eac128 100644
--- a/drivers/pci/controller/vmd.c
+++ b/drivers/pci/controller/vmd.c
@@ -394,11 +394,6 @@ static void vmd_sync_sg_for_device(struct device *dev, struct scatterlist *sg,
 	vmd_dma_ops(dev)->sync_sg_for_device(to_vmd_dev(dev), sg, nents, dir);
 }
 
-static int vmd_mapping_error(struct device *dev, dma_addr_t addr)
-{
-	return vmd_dma_ops(dev)->mapping_error(to_vmd_dev(dev), addr);
-}
-
 static int vmd_dma_supported(struct device *dev, u64 mask)
 {
 	return vmd_dma_ops(dev)->dma_supported(to_vmd_dev(dev), mask);
@@ -446,7 +441,6 @@ static void vmd_setup_dma_ops(struct vmd_dev *vmd)
 	ASSIGN_VMD_DMA_OPS(source, dest, sync_single_for_device);
 	ASSIGN_VMD_DMA_OPS(source, dest, sync_sg_for_cpu);
 	ASSIGN_VMD_DMA_OPS(source, dest, sync_sg_for_device);
-	ASSIGN_VMD_DMA_OPS(source, dest, mapping_error);
 	ASSIGN_VMD_DMA_OPS(source, dest, dma_supported);
 	ASSIGN_VMD_DMA_OPS(source, dest, get_required_mask);
 	add_dma_domain(domain);
diff --git a/include/linux/dma-mapping.h b/include/linux/dma-mapping.h
index c323c539b7cb..c250e2ca6dfc 100644
--- a/include/linux/dma-mapping.h
+++ b/include/linux/dma-mapping.h
@@ -128,7 +128,6 @@ struct dma_map_ops {
 				   enum dma_data_direction dir);
 	void (*cache_sync)(struct device *dev, void *vaddr, size_t size,
 			enum dma_data_direction direction);
-	int (*mapping_error)(struct device *dev, dma_addr_t dma_addr);
 	int (*dma_supported)(struct device *dev, u64 mask);
 	u64 (*get_required_mask)(struct device *dev);
 };
@@ -573,18 +572,10 @@ static inline void dma_free_coherent(struct device *dev, size_t size,
 	return dma_free_attrs(dev, size, cpu_addr, dma_handle, 0);
 }
 
-static inline int dma_mapping_error(struct device *dev, dma_addr_t dma_addr)
+static inline bool dma_mapping_error(struct device *dev, dma_addr_t dma_addr)
 {
-	const struct dma_map_ops *ops = get_dma_ops(dev);
-
 	debug_dma_mapping_error(dev, dma_addr);
-
-	if (dma_addr = DMA_MAPPING_ERROR)
-		return 1;
-
-	if (ops->mapping_error)
-		return ops->mapping_error(dev, dma_addr);
-	return 0;
+	return dma_addr = DMA_MAPPING_ERROR;
 }
 
 static inline void dma_check_mask(struct device *dev, u64 mask)
-- 
2.19.1
