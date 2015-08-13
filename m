From: Christoph Hellwig <hch@lst.de>
Date: Thu, 13 Aug 2015 15:04:08 +0000
Subject: [PATCH 5/5] dma-mapping: consolidate dma_set_mask
Message-Id: <1439478248-15183-6-git-send-email-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <1439478248-15183-1-git-send-email-hch@lst.de>
In-Reply-To: <1439478248-15183-1-git-send-email-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: akpm@linux-foundation.org
Cc: arnd@arndb.de, linux@arm.linux.org.uk, catalin.marinas@arm.com, will.deacon@arm.com, ysato@users.sourceforge.jp, monstr@monstr.eu, jonas@southpole.se, cmetcalf@ezchip.com, gxt@mprc.pku.edu.cn, x86@kernel.org, linux-alpha@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org

Almost everyone implements dma_set_mask the same way, although some time
that's hidden in ->set_dma_mask methods.

Move this implementation to common code, including a callout to override
the post-check action, and remove duplicate instaces in methods as well.

Unfortunately some architectures overload unrelated semantics like changing
the dma_ops into it so we still need to allow for an architecture override
for now.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/alpha/include/asm/dma-mapping.h      |  5 -----
 arch/alpha/kernel/pci-noop.c              | 10 ----------
 arch/alpha/kernel/pci_iommu.c             | 11 -----------
 arch/arm/common/dmabounce.c               |  9 ---------
 arch/arm/include/asm/dma-mapping.h        |  5 -----
 arch/arm/mm/dma-mapping.c                 | 16 ----------------
 arch/arm/xen/mm.c                         |  1 -
 arch/arm64/include/asm/dma-mapping.h      |  9 ---------
 arch/h8300/include/asm/dma-mapping.h      |  5 -----
 arch/hexagon/include/asm/dma-mapping.h    |  1 -
 arch/hexagon/kernel/dma.c                 | 11 -----------
 arch/ia64/include/asm/dma-mapping.h       |  9 ---------
 arch/microblaze/include/asm/dma-mapping.h | 14 --------------
 arch/mips/include/asm/dma-mapping.h       | 16 ----------------
 arch/openrisc/include/asm/dma-mapping.h   |  9 ---------
 arch/powerpc/include/asm/dma-mapping.h    |  4 +++-
 arch/powerpc/platforms/cell/iommu.c       |  3 ---
 arch/s390/include/asm/dma-mapping.h       |  2 --
 arch/s390/pci/pci_dma.c                   | 10 ----------
 arch/sh/include/asm/dma-mapping.h         | 14 --------------
 arch/sparc/include/asm/dma-mapping.h      |  5 +++--
 arch/tile/include/asm/dma-mapping.h       |  5 +++--
 arch/unicore32/include/asm/dma-mapping.h  | 10 ----------
 arch/x86/include/asm/dma-mapping.h        |  2 --
 arch/x86/kernel/pci-dma.c                 | 11 -----------
 drivers/xen/swiotlb-xen.c                 | 12 ------------
 include/asm-generic/dma-mapping-common.h  | 16 ++++++++++++++++
 include/xen/swiotlb-xen.h                 |  2 --
 28 files changed, 25 insertions(+), 202 deletions(-)

diff --git a/arch/alpha/include/asm/dma-mapping.h b/arch/alpha/include/asm/dma-mapping.h
index 9d763e5..72a8ca7 100644
--- a/arch/alpha/include/asm/dma-mapping.h
+++ b/arch/alpha/include/asm/dma-mapping.h
@@ -12,11 +12,6 @@ static inline struct dma_map_ops *get_dma_ops(struct device *dev)
 
 #include <asm-generic/dma-mapping-common.h>
 
-static inline int dma_set_mask(struct device *dev, u64 mask)
-{
-	return get_dma_ops(dev)->set_dma_mask(dev, mask);
-}
-
 #define dma_cache_sync(dev, va, size, dir)		  ((void)0)
 
 #endif	/* _ALPHA_DMA_MAPPING_H */
diff --git a/arch/alpha/kernel/pci-noop.c b/arch/alpha/kernel/pci-noop.c
index df24b76..2b1f4a1 100644
--- a/arch/alpha/kernel/pci-noop.c
+++ b/arch/alpha/kernel/pci-noop.c
@@ -166,15 +166,6 @@ static int alpha_noop_supported(struct device *dev, u64 mask)
 	return mask < 0x00ffffffUL ? 0 : 1;
 }
 
-static int alpha_noop_set_mask(struct device *dev, u64 mask)
-{
-	if (!dev->dma_mask || !dma_supported(dev, mask))
-		return -EIO;
-
-	*dev->dma_mask = mask;
-	return 0;
-}
-
 struct dma_map_ops alpha_noop_ops = {
 	.alloc			= alpha_noop_alloc_coherent,
 	.free			= alpha_noop_free_coherent,
@@ -182,7 +173,6 @@ struct dma_map_ops alpha_noop_ops = {
 	.map_sg			= alpha_noop_map_sg,
 	.mapping_error		= alpha_noop_mapping_error,
 	.dma_supported		= alpha_noop_supported,
-	.set_dma_mask		= alpha_noop_set_mask,
 };
 
 struct dma_map_ops *dma_ops = &alpha_noop_ops;
diff --git a/arch/alpha/kernel/pci_iommu.c b/arch/alpha/kernel/pci_iommu.c
index eddee77..8969bf2 100644
--- a/arch/alpha/kernel/pci_iommu.c
+++ b/arch/alpha/kernel/pci_iommu.c
@@ -939,16 +939,6 @@ static int alpha_pci_mapping_error(struct device *dev, dma_addr_t dma_addr)
 	return dma_addr = 0;
 }
 
-static int alpha_pci_set_mask(struct device *dev, u64 mask)
-{
-	if (!dev->dma_mask ||
-	    !pci_dma_supported(alpha_gendev_to_pci(dev), mask))
-		return -EIO;
-
-	*dev->dma_mask = mask;
-	return 0;
-}
-
 struct dma_map_ops alpha_pci_ops = {
 	.alloc			= alpha_pci_alloc_coherent,
 	.free			= alpha_pci_free_coherent,
@@ -958,7 +948,6 @@ struct dma_map_ops alpha_pci_ops = {
 	.unmap_sg		= alpha_pci_unmap_sg,
 	.mapping_error		= alpha_pci_mapping_error,
 	.dma_supported		= alpha_pci_supported,
-	.set_dma_mask		= alpha_pci_set_mask,
 };
 
 struct dma_map_ops *dma_ops = &alpha_pci_ops;
diff --git a/arch/arm/common/dmabounce.c b/arch/arm/common/dmabounce.c
index 1143c4d..260f52a 100644
--- a/arch/arm/common/dmabounce.c
+++ b/arch/arm/common/dmabounce.c
@@ -440,14 +440,6 @@ static void dmabounce_sync_for_device(struct device *dev,
 	arm_dma_ops.sync_single_for_device(dev, handle, size, dir);
 }
 
-static int dmabounce_set_mask(struct device *dev, u64 dma_mask)
-{
-	if (dev->archdata.dmabounce)
-		return 0;
-
-	return arm_dma_ops.set_dma_mask(dev, dma_mask);
-}
-
 static struct dma_map_ops dmabounce_ops = {
 	.alloc			= arm_dma_alloc,
 	.free			= arm_dma_free,
@@ -461,7 +453,6 @@ static struct dma_map_ops dmabounce_ops = {
 	.unmap_sg		= arm_dma_unmap_sg,
 	.sync_sg_for_cpu	= arm_dma_sync_sg_for_cpu,
 	.sync_sg_for_device	= arm_dma_sync_sg_for_device,
-	.set_dma_mask		= dmabounce_set_mask,
 };
 
 static int dmabounce_init_pool(struct dmabounce_pool *pool, struct device *dev,
diff --git a/arch/arm/include/asm/dma-mapping.h b/arch/arm/include/asm/dma-mapping.h
index b90d247..5f4262ea 100644
--- a/arch/arm/include/asm/dma-mapping.h
+++ b/arch/arm/include/asm/dma-mapping.h
@@ -43,11 +43,6 @@ extern int dma_supported(struct device *dev, u64 mask);
 
 #include <asm-generic/dma-mapping-common.h>
 
-static inline int dma_set_mask(struct device *dev, u64 mask)
-{
-	return get_dma_ops(dev)->set_dma_mask(dev, mask);
-}
-
 #ifdef __arch_page_to_dma
 #error Please update to __arch_pfn_to_dma
 #endif
diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
index e556e0e..00b1e75 100644
--- a/arch/arm/mm/dma-mapping.c
+++ b/arch/arm/mm/dma-mapping.c
@@ -140,7 +140,6 @@ struct dma_map_ops arm_dma_ops = {
 	.sync_single_for_device	= arm_dma_sync_single_for_device,
 	.sync_sg_for_cpu	= arm_dma_sync_sg_for_cpu,
 	.sync_sg_for_device	= arm_dma_sync_sg_for_device,
-	.set_dma_mask		= arm_dma_set_mask,
 };
 EXPORT_SYMBOL(arm_dma_ops);
 
@@ -159,7 +158,6 @@ struct dma_map_ops arm_coherent_dma_ops = {
 	.get_sgtable		= arm_dma_get_sgtable,
 	.map_page		= arm_coherent_dma_map_page,
 	.map_sg			= arm_dma_map_sg,
-	.set_dma_mask		= arm_dma_set_mask,
 };
 EXPORT_SYMBOL(arm_coherent_dma_ops);
 
@@ -1001,16 +999,6 @@ int dma_supported(struct device *dev, u64 mask)
 }
 EXPORT_SYMBOL(dma_supported);
 
-int arm_dma_set_mask(struct device *dev, u64 dma_mask)
-{
-	if (!dev->dma_mask || !dma_supported(dev, dma_mask))
-		return -EIO;
-
-	*dev->dma_mask = dma_mask;
-
-	return 0;
-}
-
 #define PREALLOC_DMA_DEBUG_ENTRIES	4096
 
 static int __init dma_debug_do_init(void)
@@ -1852,8 +1840,6 @@ struct dma_map_ops iommu_ops = {
 	.unmap_sg		= arm_iommu_unmap_sg,
 	.sync_sg_for_cpu	= arm_iommu_sync_sg_for_cpu,
 	.sync_sg_for_device	= arm_iommu_sync_sg_for_device,
-
-	.set_dma_mask		= arm_dma_set_mask,
 };
 
 struct dma_map_ops iommu_coherent_ops = {
@@ -1867,8 +1853,6 @@ struct dma_map_ops iommu_coherent_ops = {
 
 	.map_sg		= arm_coherent_iommu_map_sg,
 	.unmap_sg	= arm_coherent_iommu_unmap_sg,
-
-	.set_dma_mask	= arm_dma_set_mask,
 };
 
 /**
diff --git a/arch/arm/xen/mm.c b/arch/arm/xen/mm.c
index 03e75fe..b7bcf17 100644
--- a/arch/arm/xen/mm.c
+++ b/arch/arm/xen/mm.c
@@ -179,7 +179,6 @@ static struct dma_map_ops xen_swiotlb_dma_ops = {
 	.map_page = xen_swiotlb_map_page,
 	.unmap_page = xen_swiotlb_unmap_page,
 	.dma_supported = xen_swiotlb_dma_supported,
-	.set_dma_mask = xen_swiotlb_set_dma_mask,
 };
 
 int __init xen_mm_init(void)
diff --git a/arch/arm64/include/asm/dma-mapping.h b/arch/arm64/include/asm/dma-mapping.h
index f519a58..cfdb34b 100644
--- a/arch/arm64/include/asm/dma-mapping.h
+++ b/arch/arm64/include/asm/dma-mapping.h
@@ -84,15 +84,6 @@ static inline phys_addr_t dma_to_phys(struct device *dev, dma_addr_t dev_addr)
 	return (phys_addr_t)dev_addr;
 }
 
-static inline int dma_set_mask(struct device *dev, u64 mask)
-{
-	if (!dev->dma_mask || !dma_supported(dev, mask))
-		return -EIO;
-	*dev->dma_mask = mask;
-
-	return 0;
-}
-
 static inline bool dma_capable(struct device *dev, dma_addr_t addr, size_t size)
 {
 	if (!dev->dma_mask)
diff --git a/arch/h8300/include/asm/dma-mapping.h b/arch/h8300/include/asm/dma-mapping.h
index 48d652e..d9b5b80 100644
--- a/arch/h8300/include/asm/dma-mapping.h
+++ b/arch/h8300/include/asm/dma-mapping.h
@@ -10,9 +10,4 @@ static inline struct dma_map_ops *get_dma_ops(struct device *dev)
 
 #include <asm-generic/dma-mapping-common.h>
 
-static inline int dma_set_mask(struct device *dev, u64 mask)
-{
-	return 0;
-}
-
 #endif
diff --git a/arch/hexagon/include/asm/dma-mapping.h b/arch/hexagon/include/asm/dma-mapping.h
index 36e8de7..268fde8 100644
--- a/arch/hexagon/include/asm/dma-mapping.h
+++ b/arch/hexagon/include/asm/dma-mapping.h
@@ -45,7 +45,6 @@ static inline struct dma_map_ops *get_dma_ops(struct device *dev)
 
 #define HAVE_ARCH_DMA_SUPPORTED 1
 extern int dma_supported(struct device *dev, u64 mask);
-extern int dma_set_mask(struct device *dev, u64 mask);
 extern int dma_is_consistent(struct device *dev, dma_addr_t dma_handle);
 extern void dma_cache_sync(struct device *dev, void *vaddr, size_t size,
 			   enum dma_data_direction direction);
diff --git a/arch/hexagon/kernel/dma.c b/arch/hexagon/kernel/dma.c
index b74f9ba..9e3ddf7 100644
--- a/arch/hexagon/kernel/dma.c
+++ b/arch/hexagon/kernel/dma.c
@@ -44,17 +44,6 @@ int dma_supported(struct device *dev, u64 mask)
 }
 EXPORT_SYMBOL(dma_supported);
 
-int dma_set_mask(struct device *dev, u64 mask)
-{
-	if (!dev->dma_mask || !dma_supported(dev, mask))
-		return -EIO;
-
-	*dev->dma_mask = mask;
-
-	return 0;
-}
-EXPORT_SYMBOL(dma_set_mask);
-
 static struct gen_pool *coherent_pool;
 
 
diff --git a/arch/ia64/include/asm/dma-mapping.h b/arch/ia64/include/asm/dma-mapping.h
index 7982caa..9beccf8 100644
--- a/arch/ia64/include/asm/dma-mapping.h
+++ b/arch/ia64/include/asm/dma-mapping.h
@@ -27,15 +27,6 @@ extern void machvec_dma_sync_sg(struct device *, struct scatterlist *, int,
 
 #include <asm-generic/dma-mapping-common.h>
 
-static inline int
-dma_set_mask (struct device *dev, u64 mask)
-{
-	if (!dev->dma_mask || !dma_supported(dev, mask))
-		return -EIO;
-	*dev->dma_mask = mask;
-	return 0;
-}
-
 static inline bool dma_capable(struct device *dev, dma_addr_t addr, size_t size)
 {
 	if (!dev->dma_mask)
diff --git a/arch/microblaze/include/asm/dma-mapping.h b/arch/microblaze/include/asm/dma-mapping.h
index 0aa5d8a..24b1297 100644
--- a/arch/microblaze/include/asm/dma-mapping.h
+++ b/arch/microblaze/include/asm/dma-mapping.h
@@ -44,20 +44,6 @@ static inline struct dma_map_ops *get_dma_ops(struct device *dev)
 	return &dma_direct_ops;
 }
 
-static inline int dma_set_mask(struct device *dev, u64 dma_mask)
-{
-	struct dma_map_ops *ops = get_dma_ops(dev);
-
-	if (unlikely(ops = NULL))
-		return -EIO;
-	if (ops->set_dma_mask)
-		return ops->set_dma_mask(dev, dma_mask);
-	if (!dev->dma_mask || !dma_supported(dev, dma_mask))
-		return -EIO;
-	*dev->dma_mask = dma_mask;
-	return 0;
-}
-
 #include <asm-generic/dma-mapping-common.h>
 
 static inline void __dma_sync(unsigned long paddr,
diff --git a/arch/mips/include/asm/dma-mapping.h b/arch/mips/include/asm/dma-mapping.h
index 8bf8ec3..e604f76 100644
--- a/arch/mips/include/asm/dma-mapping.h
+++ b/arch/mips/include/asm/dma-mapping.h
@@ -31,22 +31,6 @@ static inline void dma_mark_clean(void *addr, size_t size) {}
 
 #include <asm-generic/dma-mapping-common.h>
 
-static inline int
-dma_set_mask(struct device *dev, u64 mask)
-{
-	struct dma_map_ops *ops = get_dma_ops(dev);
-
-	if(!dev->dma_mask || !dma_supported(dev, mask))
-		return -EIO;
-
-	if (ops->set_dma_mask)
-		return ops->set_dma_mask(dev, mask);
-
-	*dev->dma_mask = mask;
-
-	return 0;
-}
-
 extern void dma_cache_sync(struct device *dev, void *vaddr, size_t size,
 	       enum dma_data_direction direction);
 
diff --git a/arch/openrisc/include/asm/dma-mapping.h b/arch/openrisc/include/asm/dma-mapping.h
index 8fc08b8..413bfcf 100644
--- a/arch/openrisc/include/asm/dma-mapping.h
+++ b/arch/openrisc/include/asm/dma-mapping.h
@@ -44,13 +44,4 @@ static inline int dma_supported(struct device *dev, u64 dma_mask)
 
 #include <asm-generic/dma-mapping-common.h>
 
-static inline int dma_set_mask(struct device *dev, u64 dma_mask)
-{
-	if (!dev->dma_mask || !dma_supported(dev, dma_mask))
-		return -EIO;
-
-	*dev->dma_mask = dma_mask;
-
-	return 0;
-}
 #endif	/* __ASM_OPENRISC_DMA_MAPPING_H */
diff --git a/arch/powerpc/include/asm/dma-mapping.h b/arch/powerpc/include/asm/dma-mapping.h
index e2ff85c..6dd7a0e 100644
--- a/arch/powerpc/include/asm/dma-mapping.h
+++ b/arch/powerpc/include/asm/dma-mapping.h
@@ -122,9 +122,11 @@ static inline void set_dma_offset(struct device *dev, dma_addr_t off)
 /* this will be removed soon */
 #define flush_write_buffers()
 
+#define HAVE_ARCH_DMA_SET_MASK 1
+extern int dma_set_mask(struct device *dev, u64 dma_mask);
+
 #include <asm-generic/dma-mapping-common.h>
 
-extern int dma_set_mask(struct device *dev, u64 dma_mask);
 extern int __dma_set_mask(struct device *dev, u64 dma_mask);
 extern u64 __dma_get_required_mask(struct device *dev);
 
diff --git a/arch/powerpc/platforms/cell/iommu.c b/arch/powerpc/platforms/cell/iommu.c
index 14a582b..55c60f4 100644
--- a/arch/powerpc/platforms/cell/iommu.c
+++ b/arch/powerpc/platforms/cell/iommu.c
@@ -958,9 +958,6 @@ out:
 
 static int dma_set_mask_and_switch(struct device *dev, u64 dma_mask)
 {
-	if (!dev->dma_mask || !dma_supported(dev, dma_mask))
-		return -EIO;
-
 	if (dma_mask = DMA_BIT_MASK(64) &&
 		cell_iommu_get_fixed_address(dev) != OF_BAD_ADDR)
 	{
diff --git a/arch/s390/include/asm/dma-mapping.h b/arch/s390/include/asm/dma-mapping.h
index 1f42489..b3fd54d 100644
--- a/arch/s390/include/asm/dma-mapping.h
+++ b/arch/s390/include/asm/dma-mapping.h
@@ -18,8 +18,6 @@ static inline struct dma_map_ops *get_dma_ops(struct device *dev)
 	return &s390_dma_ops;
 }
 
-extern int dma_set_mask(struct device *dev, u64 mask);
-
 static inline void dma_cache_sync(struct device *dev, void *vaddr, size_t size,
 				  enum dma_data_direction direction)
 {
diff --git a/arch/s390/pci/pci_dma.c b/arch/s390/pci/pci_dma.c
index 6fd8d58..ad5a1b4 100644
--- a/arch/s390/pci/pci_dma.c
+++ b/arch/s390/pci/pci_dma.c
@@ -262,16 +262,6 @@ out:
 	spin_unlock_irqrestore(&zdev->iommu_bitmap_lock, flags);
 }
 
-int dma_set_mask(struct device *dev, u64 mask)
-{
-	if (!dev->dma_mask || !dma_supported(dev, mask))
-		return -EIO;
-
-	*dev->dma_mask = mask;
-	return 0;
-}
-EXPORT_SYMBOL_GPL(dma_set_mask);
-
 static dma_addr_t s390_dma_map_pages(struct device *dev, struct page *page,
 				     unsigned long offset, size_t size,
 				     enum dma_data_direction direction,
diff --git a/arch/sh/include/asm/dma-mapping.h b/arch/sh/include/asm/dma-mapping.h
index 088f6e5..a3745a3 100644
--- a/arch/sh/include/asm/dma-mapping.h
+++ b/arch/sh/include/asm/dma-mapping.h
@@ -13,20 +13,6 @@ static inline struct dma_map_ops *get_dma_ops(struct device *dev)
 
 #include <asm-generic/dma-mapping-common.h>
 
-static inline int dma_set_mask(struct device *dev, u64 mask)
-{
-	struct dma_map_ops *ops = get_dma_ops(dev);
-
-	if (!dev->dma_mask || !dma_supported(dev, mask))
-		return -EIO;
-	if (ops->set_dma_mask)
-		return ops->set_dma_mask(dev, mask);
-
-	*dev->dma_mask = mask;
-
-	return 0;
-}
-
 void dma_cache_sync(struct device *dev, void *vaddr, size_t size,
 		    enum dma_data_direction dir);
 
diff --git a/arch/sparc/include/asm/dma-mapping.h b/arch/sparc/include/asm/dma-mapping.h
index 184651b..c643170 100644
--- a/arch/sparc/include/asm/dma-mapping.h
+++ b/arch/sparc/include/asm/dma-mapping.h
@@ -37,8 +37,7 @@ static inline struct dma_map_ops *get_dma_ops(struct device *dev)
 	return dma_ops;
 }
 
-#include <asm-generic/dma-mapping-common.h>
-
+#define HAVE_ARCH_DMA_SET_MASK 1
 static inline int dma_set_mask(struct device *dev, u64 mask)
 {
 #ifdef CONFIG_PCI
@@ -52,4 +51,6 @@ static inline int dma_set_mask(struct device *dev, u64 mask)
 	return -EINVAL;
 }
 
+#include <asm-generic/dma-mapping-common.h>
+
 #endif
diff --git a/arch/tile/include/asm/dma-mapping.h b/arch/tile/include/asm/dma-mapping.h
index 559ed4a..ed0d4ed 100644
--- a/arch/tile/include/asm/dma-mapping.h
+++ b/arch/tile/include/asm/dma-mapping.h
@@ -59,8 +59,6 @@ static inline phys_addr_t dma_to_phys(struct device *dev, dma_addr_t daddr)
 
 static inline void dma_mark_clean(void *addr, size_t size) {}
 
-#include <asm-generic/dma-mapping-common.h>
-
 static inline void set_dma_ops(struct device *dev, struct dma_map_ops *ops)
 {
 	dev->archdata.dma_ops = ops;
@@ -74,6 +72,7 @@ static inline bool dma_capable(struct device *dev, dma_addr_t addr, size_t size)
 	return addr + size - 1 <= *dev->dma_mask;
 }
 
+#define HAVE_ARCH_DMA_SET_MASK 1
 static inline int
 dma_set_mask(struct device *dev, u64 mask)
 {
@@ -103,6 +102,8 @@ dma_set_mask(struct device *dev, u64 mask)
 	return 0;
 }
 
+#include <asm-generic/dma-mapping-common.h>
+
 /*
  * dma_alloc_noncoherent() is #defined to return coherent memory,
  * so there's no need to do any flushing here.
diff --git a/arch/unicore32/include/asm/dma-mapping.h b/arch/unicore32/include/asm/dma-mapping.h
index 21231c1..8140e05 100644
--- a/arch/unicore32/include/asm/dma-mapping.h
+++ b/arch/unicore32/include/asm/dma-mapping.h
@@ -50,16 +50,6 @@ static inline phys_addr_t dma_to_phys(struct device *dev, dma_addr_t daddr)
 
 static inline void dma_mark_clean(void *addr, size_t size) {}
 
-static inline int dma_set_mask(struct device *dev, u64 dma_mask)
-{
-	if (!dev->dma_mask || !dma_supported(dev, dma_mask))
-		return -EIO;
-
-	*dev->dma_mask = dma_mask;
-
-	return 0;
-}
-
 static inline void dma_cache_sync(struct device *dev, void *vaddr,
 		size_t size, enum dma_data_direction direction)
 {
diff --git a/arch/x86/include/asm/dma-mapping.h b/arch/x86/include/asm/dma-mapping.h
index b1fbf58..953b726 100644
--- a/arch/x86/include/asm/dma-mapping.h
+++ b/arch/x86/include/asm/dma-mapping.h
@@ -48,8 +48,6 @@ extern int dma_supported(struct device *hwdev, u64 mask);
 
 #include <asm-generic/dma-mapping-common.h>
 
-extern int dma_set_mask(struct device *dev, u64 mask);
-
 extern void *dma_generic_alloc_coherent(struct device *dev, size_t size,
 					dma_addr_t *dma_addr, gfp_t flag,
 					struct dma_attrs *attrs);
diff --git a/arch/x86/kernel/pci-dma.c b/arch/x86/kernel/pci-dma.c
index bd23971..84b8ef8 100644
--- a/arch/x86/kernel/pci-dma.c
+++ b/arch/x86/kernel/pci-dma.c
@@ -58,17 +58,6 @@ EXPORT_SYMBOL(x86_dma_fallback_dev);
 /* Number of entries preallocated for DMA-API debugging */
 #define PREALLOC_DMA_DEBUG_ENTRIES       65536
 
-int dma_set_mask(struct device *dev, u64 mask)
-{
-	if (!dev->dma_mask || !dma_supported(dev, mask))
-		return -EIO;
-
-	*dev->dma_mask = mask;
-
-	return 0;
-}
-EXPORT_SYMBOL(dma_set_mask);
-
 void __init pci_iommu_alloc(void)
 {
 	struct iommu_table_entry *p;
diff --git a/drivers/xen/swiotlb-xen.c b/drivers/xen/swiotlb-xen.c
index da1029e..0fff76b 100644
--- a/drivers/xen/swiotlb-xen.c
+++ b/drivers/xen/swiotlb-xen.c
@@ -668,15 +668,3 @@ xen_swiotlb_dma_supported(struct device *hwdev, u64 mask)
 	return xen_virt_to_bus(xen_io_tlb_end - 1) <= mask;
 }
 EXPORT_SYMBOL_GPL(xen_swiotlb_dma_supported);
-
-int
-xen_swiotlb_set_dma_mask(struct device *dev, u64 dma_mask)
-{
-	if (!dev->dma_mask || !xen_swiotlb_dma_supported(dev, dma_mask))
-		return -EIO;
-
-	*dev->dma_mask = dma_mask;
-
-	return 0;
-}
-EXPORT_SYMBOL_GPL(xen_swiotlb_set_dma_mask);
diff --git a/include/asm-generic/dma-mapping-common.h b/include/asm-generic/dma-mapping-common.h
index 67fa6bc..ca65214 100644
--- a/include/asm-generic/dma-mapping-common.h
+++ b/include/asm-generic/dma-mapping-common.h
@@ -340,4 +340,20 @@ static inline int dma_supported(struct device *dev, u64 mask)
 }
 #endif
 
+#ifndef HAVE_ARCH_DMA_SET_MASK
+static inline int dma_set_mask(struct device *dev, u64 mask)
+{
+	struct dma_map_ops *ops = get_dma_ops(dev);
+
+	if (!dev->dma_mask || !dma_supported(dev, mask))
+		return -EIO;
+
+	if (ops->set_dma_mask)
+		return ops->set_dma_mask(dev, mask);
+
+	*dev->dma_mask = mask;
+	return 0;
+}
+#endif
+
 #endif
diff --git a/include/xen/swiotlb-xen.h b/include/xen/swiotlb-xen.h
index 8b2eb93..4d81ccc 100644
--- a/include/xen/swiotlb-xen.h
+++ b/include/xen/swiotlb-xen.h
@@ -56,6 +56,4 @@ xen_swiotlb_dma_mapping_error(struct device *hwdev, dma_addr_t dma_addr);
 extern int
 xen_swiotlb_dma_supported(struct device *hwdev, u64 mask);
 
-extern int
-xen_swiotlb_set_dma_mask(struct device *dev, u64 dma_mask);
 #endif /* __LINUX_SWIOTLB_XEN_H */
-- 
1.9.1

