From: Christoph Hellwig <hch@lst.de>
Date: Mon, 17 Aug 2015 07:06:56 +0000
Subject: [PATCH 5/5] dma-mapping: consolidate dma_set_mask
Message-Id: <1439795216-32189-6-git-send-email-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <1439795216-32189-1-git-send-email-hch@lst.de>
In-Reply-To: <1439795216-32189-1-git-send-email-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: akpm@linux-foundation.org
Cc: arnd@arndb.de, linux@arm.linux.org.uk, catalin.marinas@arm.com, will.deacon@arm.com, ysato@users.sourceforge.jp, monstr@monstr.eu, jonas@southpole.se, cmetcalf@ezchip.com, gxt@mprc.pku.edu.cn, x86@kernel.org, linux-alpha@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org

Almost everyone implements dma_set_mask the same way, although some time
that's hidden in ->set_dma_mask methods.

This patch consolidates those into a common implementation that either
calls ->set_dma_mask if present or otherwise uses the default
implementation.  Some architectures used to only call ->set_dma_mask
after the initial checks, and those instance have been fixed to do the
full work.  h8300 implemented dma_set_mask bogusly as a no-ops and has
been fixed.

Unfortunately some architectures overload unrelated semantics like changing
the dma_ops into it so we still need to allow for an architecture override
for now.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/alpha/include/asm/dma-mapping.h      |  5 -----
 arch/alpha/kernel/pci-noop.c              | 10 ----------
 arch/alpha/kernel/pci_iommu.c             | 11 -----------
 arch/arm/include/asm/dma-mapping.h        |  5 -----
 arch/arm64/include/asm/dma-mapping.h      |  9 ---------
 arch/h8300/include/asm/dma-mapping.h      |  5 -----
 arch/hexagon/include/asm/dma-mapping.h    |  1 -
 arch/hexagon/kernel/dma.c                 | 11 -----------
 arch/ia64/include/asm/dma-mapping.h       |  9 ---------
 arch/microblaze/include/asm/dma-mapping.h | 14 --------------
 arch/mips/include/asm/dma-mapping.h       | 16 ----------------
 arch/mips/loongson64/common/dma-swiotlb.c |  3 +++
 arch/openrisc/include/asm/dma-mapping.h   |  9 ---------
 arch/powerpc/include/asm/dma-mapping.h    |  4 +++-
 arch/s390/include/asm/dma-mapping.h       |  2 --
 arch/s390/pci/pci_dma.c                   | 10 ----------
 arch/sh/include/asm/dma-mapping.h         | 14 --------------
 arch/sparc/include/asm/dma-mapping.h      |  4 +++-
 arch/tile/include/asm/dma-mapping.h       |  6 ++++--
 arch/unicore32/include/asm/dma-mapping.h  | 10 ----------
 arch/x86/include/asm/dma-mapping.h        |  2 --
 arch/x86/kernel/pci-dma.c                 | 11 -----------
 include/asm-generic/dma-mapping-common.h  | 15 +++++++++++++++
 23 files changed, 28 insertions(+), 158 deletions(-)

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
diff --git a/arch/arm/include/asm/dma-mapping.h b/arch/arm/include/asm/dma-mapping.h
index 199b080..906a60e 100644
--- a/arch/arm/include/asm/dma-mapping.h
+++ b/arch/arm/include/asm/dma-mapping.h
@@ -48,11 +48,6 @@ extern int dma_supported(struct device *dev, u64 mask);
  */
 #include <asm-generic/dma-mapping-common.h>
 
-static inline int dma_set_mask(struct device *dev, u64 mask)
-{
-	return get_dma_ops(dev)->set_dma_mask(dev, mask);
-}
-
 #ifdef __arch_page_to_dma
 #error Please update to __arch_pfn_to_dma
 #endif
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
index 3b453c5..24b1297 100644
--- a/arch/microblaze/include/asm/dma-mapping.h
+++ b/arch/microblaze/include/asm/dma-mapping.h
@@ -46,20 +46,6 @@ static inline struct dma_map_ops *get_dma_ops(struct device *dev)
 
 #include <asm-generic/dma-mapping-common.h>
 
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
 static inline void __dma_sync(unsigned long paddr,
 			      size_t size, enum dma_data_direction direction)
 {
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
 
diff --git a/arch/mips/loongson64/common/dma-swiotlb.c b/arch/mips/loongson64/common/dma-swiotlb.c
index ef9da3b..4ffa6fc 100644
--- a/arch/mips/loongson64/common/dma-swiotlb.c
+++ b/arch/mips/loongson64/common/dma-swiotlb.c
@@ -85,6 +85,9 @@ static void loongson_dma_sync_sg_for_device(struct device *dev,
 
 static int loongson_dma_set_mask(struct device *dev, u64 mask)
 {
+	if (!dev->dma_mask || !dma_supported(dev, mask))
+		return -EIO;
+
 	if (mask > DMA_BIT_MASK(loongson_sysconf.dma_mask_bits)) {
 		*dev->dma_mask = DMA_BIT_MASK(loongson_sysconf.dma_mask_bits);
 		return -EIO;
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
index 184651b..a21da59 100644
--- a/arch/sparc/include/asm/dma-mapping.h
+++ b/arch/sparc/include/asm/dma-mapping.h
@@ -37,7 +37,7 @@ static inline struct dma_map_ops *get_dma_ops(struct device *dev)
 	return dma_ops;
 }
 
-#include <asm-generic/dma-mapping-common.h>
+#define HAVE_ARCH_DMA_SET_MASK 1
 
 static inline int dma_set_mask(struct device *dev, u64 mask)
 {
@@ -52,4 +52,6 @@ static inline int dma_set_mask(struct device *dev, u64 mask)
 	return -EINVAL;
 }
 
+#include <asm-generic/dma-mapping-common.h>
+
 #endif
diff --git a/arch/tile/include/asm/dma-mapping.h b/arch/tile/include/asm/dma-mapping.h
index 559ed4a..96ac6cc 100644
--- a/arch/tile/include/asm/dma-mapping.h
+++ b/arch/tile/include/asm/dma-mapping.h
@@ -59,8 +59,6 @@ static inline phys_addr_t dma_to_phys(struct device *dev, dma_addr_t daddr)
 
 static inline void dma_mark_clean(void *addr, size_t size) {}
 
-#include <asm-generic/dma-mapping-common.h>
-
 static inline void set_dma_ops(struct device *dev, struct dma_map_ops *ops)
 {
 	dev->archdata.dma_ops = ops;
@@ -74,6 +72,10 @@ static inline bool dma_capable(struct device *dev, dma_addr_t addr, size_t size)
 	return addr + size - 1 <= *dev->dma_mask;
 }
 
+#define HAVE_ARCH_DMA_SET_MASK 1
+
+#include <asm-generic/dma-mapping-common.h>
+
 static inline int
 dma_set_mask(struct device *dev, u64 mask)
 {
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
diff --git a/include/asm-generic/dma-mapping-common.h b/include/asm-generic/dma-mapping-common.h
index 67fa6bc..b1bc954 100644
--- a/include/asm-generic/dma-mapping-common.h
+++ b/include/asm-generic/dma-mapping-common.h
@@ -340,4 +340,19 @@ static inline int dma_supported(struct device *dev, u64 mask)
 }
 #endif
 
+#ifndef HAVE_ARCH_DMA_SET_MASK
+static inline int dma_set_mask(struct device *dev, u64 mask)
+{
+	struct dma_map_ops *ops = get_dma_ops(dev);
+
+	if (ops->set_dma_mask)
+		return ops->set_dma_mask(dev, mask);
+
+	if (!dev->dma_mask || !dma_supported(dev, mask))
+		return -EIO;
+	*dev->dma_mask = mask;
+	return 0;
+}
+#endif
+
 #endif
-- 
1.9.1

