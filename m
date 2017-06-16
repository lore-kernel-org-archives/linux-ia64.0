From: Christoph Hellwig <hch@lst.de>
Date: Fri, 16 Jun 2017 18:10:49 +0000
Subject: [PATCH 34/44] arm: remove arch specific dma_supported implementation
Message-Id: <20170616181059.19206-35-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170616181059.19206-1-hch@lst.de>
In-Reply-To: <20170616181059.19206-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: x86@kernel.org, linux-arm-kernel@lists.infradead.org, xen-devel@lists.xenproject.org, linux-c6x-dev@linux-c6x.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, openrisc@lists.librecores.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, dmaengine@vger.kernel.org, linux-tegra@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-samsung-soc@vger.kernel.org, iommu@lists.linux-foundation.org, netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org

And instead wire it up as method for all the dma_map_ops instances.

Note that the code seems a little fishy for dmabounce and iommu, but
for now I'd like to preserve the existing behavior 1:1.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/arm/common/dmabounce.c        | 1 +
 arch/arm/include/asm/dma-iommu.h   | 2 ++
 arch/arm/include/asm/dma-mapping.h | 3 ---
 arch/arm/mm/dma-mapping.c          | 7 +++++--
 4 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/arch/arm/common/dmabounce.c b/arch/arm/common/dmabounce.c
index 4060378e0f14..6ecd5be5d37e 100644
--- a/arch/arm/common/dmabounce.c
+++ b/arch/arm/common/dmabounce.c
@@ -473,6 +473,7 @@ static const struct dma_map_ops dmabounce_ops = {
 	.sync_sg_for_device	= arm_dma_sync_sg_for_device,
 	.set_dma_mask		= dmabounce_set_mask,
 	.mapping_error		= dmabounce_mapping_error,
+	.dma_supported		= arm_dma_supported,
 };
 
 static int dmabounce_init_pool(struct dmabounce_pool *pool, struct device *dev,
diff --git a/arch/arm/include/asm/dma-iommu.h b/arch/arm/include/asm/dma-iommu.h
index 389a26a10ea3..c090ec675eac 100644
--- a/arch/arm/include/asm/dma-iommu.h
+++ b/arch/arm/include/asm/dma-iommu.h
@@ -35,5 +35,7 @@ int arm_iommu_attach_device(struct device *dev,
 					struct dma_iommu_mapping *mapping);
 void arm_iommu_detach_device(struct device *dev);
 
+int arm_dma_supported(struct device *dev, u64 mask);
+
 #endif /* __KERNEL__ */
 #endif
diff --git a/arch/arm/include/asm/dma-mapping.h b/arch/arm/include/asm/dma-mapping.h
index 52a8fd5a8edb..8dabcfdf4505 100644
--- a/arch/arm/include/asm/dma-mapping.h
+++ b/arch/arm/include/asm/dma-mapping.h
@@ -20,9 +20,6 @@ static inline const struct dma_map_ops *get_arch_dma_ops(struct bus_type *bus)
 	return &arm_dma_ops;
 }
 
-#define HAVE_ARCH_DMA_SUPPORTED 1
-extern int dma_supported(struct device *dev, u64 mask);
-
 #ifdef __arch_page_to_dma
 #error Please update to __arch_pfn_to_dma
 #endif
diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
index 8f2c5a8a98f0..b9677ada421f 100644
--- a/arch/arm/mm/dma-mapping.c
+++ b/arch/arm/mm/dma-mapping.c
@@ -199,6 +199,7 @@ const struct dma_map_ops arm_dma_ops = {
 	.sync_sg_for_cpu	= arm_dma_sync_sg_for_cpu,
 	.sync_sg_for_device	= arm_dma_sync_sg_for_device,
 	.mapping_error		= arm_dma_mapping_error,
+	.dma_supported		= arm_dma_supported,
 };
 EXPORT_SYMBOL(arm_dma_ops);
 
@@ -218,6 +219,7 @@ const struct dma_map_ops arm_coherent_dma_ops = {
 	.map_page		= arm_coherent_dma_map_page,
 	.map_sg			= arm_dma_map_sg,
 	.mapping_error		= arm_dma_mapping_error,
+	.dma_supported		= arm_dma_supported,
 };
 EXPORT_SYMBOL(arm_coherent_dma_ops);
 
@@ -1184,11 +1186,10 @@ void arm_dma_sync_sg_for_device(struct device *dev, struct scatterlist *sg,
  * during bus mastering, then you would pass 0x00ffffff as the mask
  * to this function.
  */
-int dma_supported(struct device *dev, u64 mask)
+int arm_dma_supported(struct device *dev, u64 mask)
 {
 	return __dma_supported(dev, mask, false);
 }
-EXPORT_SYMBOL(dma_supported);
 
 #define PREALLOC_DMA_DEBUG_ENTRIES	4096
 
@@ -2149,6 +2150,7 @@ const struct dma_map_ops iommu_ops = {
 	.unmap_resource		= arm_iommu_unmap_resource,
 
 	.mapping_error		= arm_dma_mapping_error,
+	.dma_supported		= arm_dma_supported,
 };
 
 const struct dma_map_ops iommu_coherent_ops = {
@@ -2167,6 +2169,7 @@ const struct dma_map_ops iommu_coherent_ops = {
 	.unmap_resource	= arm_iommu_unmap_resource,
 
 	.mapping_error		= arm_dma_mapping_error,
+	.dma_supported		= arm_dma_supported,
 };
 
 /**
-- 
2.11.0

