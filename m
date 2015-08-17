From: Christoph Hellwig <hch@lst.de>
Date: Mon, 17 Aug 2015 07:06:55 +0000
Subject: [PATCH 4/5] dma-mapping: consolidate dma_supported
Message-Id: <1439795216-32189-5-git-send-email-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <1439795216-32189-1-git-send-email-hch@lst.de>
In-Reply-To: <1439795216-32189-1-git-send-email-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: akpm@linux-foundation.org
Cc: arnd@arndb.de, linux@arm.linux.org.uk, catalin.marinas@arm.com, will.deacon@arm.com, ysato@users.sourceforge.jp, monstr@monstr.eu, jonas@southpole.se, cmetcalf@ezchip.com, gxt@mprc.pku.edu.cn, x86@kernel.org, linux-alpha@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org

Most architectures just call into ->dma_supported, but some also return 1
if the method is not present, or 0 if no dma ops are present (although
that should never happeb). Consolidate this more broad version into
common code.

Also fix h8300 which inorrectly always returned 0, which would have been
a problem if it's dma_set_mask implementation wasn't a similarly buggy
noop.

As a few architectures have much more elaborate implementations, we
still allow for arch overrides.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/alpha/include/asm/dma-mapping.h      |  5 -----
 arch/arm/include/asm/dma-mapping.h        |  6 +++---
 arch/arm64/include/asm/dma-mapping.h      |  6 ------
 arch/h8300/include/asm/dma-mapping.h      |  5 -----
 arch/hexagon/include/asm/dma-mapping.h    |  1 +
 arch/ia64/include/asm/dma-mapping.h       |  6 ------
 arch/microblaze/include/asm/dma-mapping.h | 13 +------------
 arch/mips/include/asm/dma-mapping.h       |  6 ------
 arch/openrisc/include/asm/dma-mapping.h   |  5 +++--
 arch/powerpc/include/asm/dma-mapping.h    | 11 -----------
 arch/s390/include/asm/dma-mapping.h       |  9 ---------
 arch/sh/include/asm/dma-mapping.h         | 10 ----------
 arch/sparc/include/asm/dma-mapping.h      |  1 +
 arch/tile/include/asm/dma-mapping.h       |  6 ------
 arch/unicore32/include/asm/dma-mapping.h  | 10 ----------
 arch/x86/include/asm/dma-mapping.h        |  4 +++-
 include/asm-generic/dma-mapping-common.h  | 13 +++++++++++++
 17 files changed, 25 insertions(+), 92 deletions(-)

diff --git a/arch/alpha/include/asm/dma-mapping.h b/arch/alpha/include/asm/dma-mapping.h
index 80ac3e8..9d763e5 100644
--- a/arch/alpha/include/asm/dma-mapping.h
+++ b/arch/alpha/include/asm/dma-mapping.h
@@ -12,11 +12,6 @@ static inline struct dma_map_ops *get_dma_ops(struct device *dev)
 
 #include <asm-generic/dma-mapping-common.h>
 
-static inline int dma_supported(struct device *dev, u64 mask)
-{
-	return get_dma_ops(dev)->dma_supported(dev, mask);
-}
-
 static inline int dma_set_mask(struct device *dev, u64 mask)
 {
 	return get_dma_ops(dev)->set_dma_mask(dev, mask);
diff --git a/arch/arm/include/asm/dma-mapping.h b/arch/arm/include/asm/dma-mapping.h
index b4f1b6b..199b080 100644
--- a/arch/arm/include/asm/dma-mapping.h
+++ b/arch/arm/include/asm/dma-mapping.h
@@ -38,12 +38,14 @@ static inline void set_dma_ops(struct device *dev, struct dma_map_ops *ops)
 	dev->archdata.dma_ops = ops;
 }
 
+#define HAVE_ARCH_DMA_SUPPORTED 1
+extern int dma_supported(struct device *dev, u64 mask);
+
 /*
  * Note that while the generic code provides dummy dma_{alloc,free}_noncoherent
  * implementations, we don't provide a dma_cache_sync function so drivers using
  * this API are highlighted with build warnings. 
  */
-
 #include <asm-generic/dma-mapping-common.h>
 
 static inline int dma_set_mask(struct device *dev, u64 mask)
@@ -172,8 +174,6 @@ static inline bool dma_capable(struct device *dev, dma_addr_t addr, size_t size)
 
 static inline void dma_mark_clean(void *addr, size_t size) { }
 
-extern int dma_supported(struct device *dev, u64 mask);
-
 extern int arm_dma_set_mask(struct device *dev, u64 dma_mask);
 
 /**
diff --git a/arch/arm64/include/asm/dma-mapping.h b/arch/arm64/include/asm/dma-mapping.h
index f45f444..f519a58 100644
--- a/arch/arm64/include/asm/dma-mapping.h
+++ b/arch/arm64/include/asm/dma-mapping.h
@@ -84,12 +84,6 @@ static inline phys_addr_t dma_to_phys(struct device *dev, dma_addr_t dev_addr)
 	return (phys_addr_t)dev_addr;
 }
 
-static inline int dma_supported(struct device *dev, u64 mask)
-{
-	struct dma_map_ops *ops = get_dma_ops(dev);
-	return ops->dma_supported(dev, mask);
-}
-
 static inline int dma_set_mask(struct device *dev, u64 mask)
 {
 	if (!dev->dma_mask || !dma_supported(dev, mask))
diff --git a/arch/h8300/include/asm/dma-mapping.h b/arch/h8300/include/asm/dma-mapping.h
index 5eef053..48d652e 100644
--- a/arch/h8300/include/asm/dma-mapping.h
+++ b/arch/h8300/include/asm/dma-mapping.h
@@ -10,11 +10,6 @@ static inline struct dma_map_ops *get_dma_ops(struct device *dev)
 
 #include <asm-generic/dma-mapping-common.h>
 
-static inline int dma_supported(struct device *dev, u64 mask)
-{
-	return 0;
-}
-
 static inline int dma_set_mask(struct device *dev, u64 mask)
 {
 	return 0;
diff --git a/arch/hexagon/include/asm/dma-mapping.h b/arch/hexagon/include/asm/dma-mapping.h
index e661192..36e8de7 100644
--- a/arch/hexagon/include/asm/dma-mapping.h
+++ b/arch/hexagon/include/asm/dma-mapping.h
@@ -43,6 +43,7 @@ static inline struct dma_map_ops *get_dma_ops(struct device *dev)
 	return dma_ops;
 }
 
+#define HAVE_ARCH_DMA_SUPPORTED 1
 extern int dma_supported(struct device *dev, u64 mask);
 extern int dma_set_mask(struct device *dev, u64 mask);
 extern int dma_is_consistent(struct device *dev, dma_addr_t dma_handle);
diff --git a/arch/ia64/include/asm/dma-mapping.h b/arch/ia64/include/asm/dma-mapping.h
index 27b713d..7982caa 100644
--- a/arch/ia64/include/asm/dma-mapping.h
+++ b/arch/ia64/include/asm/dma-mapping.h
@@ -27,12 +27,6 @@ extern void machvec_dma_sync_sg(struct device *, struct scatterlist *, int,
 
 #include <asm-generic/dma-mapping-common.h>
 
-static inline int dma_supported(struct device *dev, u64 mask)
-{
-	struct dma_map_ops *ops = platform_dma_get_ops(dev);
-	return ops->dma_supported(dev, mask);
-}
-
 static inline int
 dma_set_mask (struct device *dev, u64 mask)
 {
diff --git a/arch/microblaze/include/asm/dma-mapping.h b/arch/microblaze/include/asm/dma-mapping.h
index e5b8438..3b453c5 100644
--- a/arch/microblaze/include/asm/dma-mapping.h
+++ b/arch/microblaze/include/asm/dma-mapping.h
@@ -44,16 +44,7 @@ static inline struct dma_map_ops *get_dma_ops(struct device *dev)
 	return &dma_direct_ops;
 }
 
-static inline int dma_supported(struct device *dev, u64 mask)
-{
-	struct dma_map_ops *ops = get_dma_ops(dev);
-
-	if (unlikely(!ops))
-		return 0;
-	if (!ops->dma_supported)
-		return 1;
-	return ops->dma_supported(dev, mask);
-}
+#include <asm-generic/dma-mapping-common.h>
 
 static inline int dma_set_mask(struct device *dev, u64 dma_mask)
 {
@@ -69,8 +60,6 @@ static inline int dma_set_mask(struct device *dev, u64 dma_mask)
 	return 0;
 }
 
-#include <asm-generic/dma-mapping-common.h>
-
 static inline void __dma_sync(unsigned long paddr,
 			      size_t size, enum dma_data_direction direction)
 {
diff --git a/arch/mips/include/asm/dma-mapping.h b/arch/mips/include/asm/dma-mapping.h
index 158bb36..8bf8ec3 100644
--- a/arch/mips/include/asm/dma-mapping.h
+++ b/arch/mips/include/asm/dma-mapping.h
@@ -31,12 +31,6 @@ static inline void dma_mark_clean(void *addr, size_t size) {}
 
 #include <asm-generic/dma-mapping-common.h>
 
-static inline int dma_supported(struct device *dev, u64 mask)
-{
-	struct dma_map_ops *ops = get_dma_ops(dev);
-	return ops->dma_supported(dev, mask);
-}
-
 static inline int
 dma_set_mask(struct device *dev, u64 mask)
 {
diff --git a/arch/openrisc/include/asm/dma-mapping.h b/arch/openrisc/include/asm/dma-mapping.h
index 7dfe9d5..8fc08b8 100644
--- a/arch/openrisc/include/asm/dma-mapping.h
+++ b/arch/openrisc/include/asm/dma-mapping.h
@@ -35,14 +35,15 @@ static inline struct dma_map_ops *get_dma_ops(struct device *dev)
 	return &or1k_dma_map_ops;
 }
 
-#include <asm-generic/dma-mapping-common.h>
-
+#define HAVE_ARCH_DMA_SUPPORTED 1
 static inline int dma_supported(struct device *dev, u64 dma_mask)
 {
 	/* Support 32 bit DMA mask exclusively */
 	return dma_mask = DMA_BIT_MASK(32);
 }
 
+#include <asm-generic/dma-mapping-common.h>
+
 static inline int dma_set_mask(struct device *dev, u64 dma_mask)
 {
 	if (!dev->dma_mask || !dma_supported(dev, dma_mask))
diff --git a/arch/powerpc/include/asm/dma-mapping.h b/arch/powerpc/include/asm/dma-mapping.h
index 72d05ab..e2ff85c 100644
--- a/arch/powerpc/include/asm/dma-mapping.h
+++ b/arch/powerpc/include/asm/dma-mapping.h
@@ -124,17 +124,6 @@ static inline void set_dma_offset(struct device *dev, dma_addr_t off)
 
 #include <asm-generic/dma-mapping-common.h>
 
-static inline int dma_supported(struct device *dev, u64 mask)
-{
-	struct dma_map_ops *dma_ops = get_dma_ops(dev);
-
-	if (unlikely(dma_ops = NULL))
-		return 0;
-	if (dma_ops->dma_supported = NULL)
-		return 1;
-	return dma_ops->dma_supported(dev, mask);
-}
-
 extern int dma_set_mask(struct device *dev, u64 dma_mask);
 extern int __dma_set_mask(struct device *dev, u64 dma_mask);
 extern u64 __dma_get_required_mask(struct device *dev);
diff --git a/arch/s390/include/asm/dma-mapping.h b/arch/s390/include/asm/dma-mapping.h
index 3c29329..1f42489 100644
--- a/arch/s390/include/asm/dma-mapping.h
+++ b/arch/s390/include/asm/dma-mapping.h
@@ -27,15 +27,6 @@ static inline void dma_cache_sync(struct device *dev, void *vaddr, size_t size,
 
 #include <asm-generic/dma-mapping-common.h>
 
-static inline int dma_supported(struct device *dev, u64 mask)
-{
-	struct dma_map_ops *dma_ops = get_dma_ops(dev);
-
-	if (dma_ops->dma_supported = NULL)
-		return 1;
-	return dma_ops->dma_supported(dev, mask);
-}
-
 static inline bool dma_capable(struct device *dev, dma_addr_t addr, size_t size)
 {
 	if (!dev->dma_mask)
diff --git a/arch/sh/include/asm/dma-mapping.h b/arch/sh/include/asm/dma-mapping.h
index 98308c4..088f6e5 100644
--- a/arch/sh/include/asm/dma-mapping.h
+++ b/arch/sh/include/asm/dma-mapping.h
@@ -13,16 +13,6 @@ static inline struct dma_map_ops *get_dma_ops(struct device *dev)
 
 #include <asm-generic/dma-mapping-common.h>
 
-static inline int dma_supported(struct device *dev, u64 mask)
-{
-	struct dma_map_ops *ops = get_dma_ops(dev);
-
-	if (ops->dma_supported)
-		return ops->dma_supported(dev, mask);
-
-	return 1;
-}
-
 static inline int dma_set_mask(struct device *dev, u64 mask)
 {
 	struct dma_map_ops *ops = get_dma_ops(dev);
diff --git a/arch/sparc/include/asm/dma-mapping.h b/arch/sparc/include/asm/dma-mapping.h
index 5069d13..184651b 100644
--- a/arch/sparc/include/asm/dma-mapping.h
+++ b/arch/sparc/include/asm/dma-mapping.h
@@ -7,6 +7,7 @@
 
 #define DMA_ERROR_CODE	(~(dma_addr_t)0x0)
 
+#define HAVE_ARCH_DMA_SUPPORTED 1
 int dma_supported(struct device *dev, u64 mask);
 
 static inline void dma_cache_sync(struct device *dev, void *vaddr, size_t size,
diff --git a/arch/tile/include/asm/dma-mapping.h b/arch/tile/include/asm/dma-mapping.h
index f8f7a05..559ed4a 100644
--- a/arch/tile/include/asm/dma-mapping.h
+++ b/arch/tile/include/asm/dma-mapping.h
@@ -75,12 +75,6 @@ static inline bool dma_capable(struct device *dev, dma_addr_t addr, size_t size)
 }
 
 static inline int
-dma_supported(struct device *dev, u64 mask)
-{
-	return get_dma_ops(dev)->dma_supported(dev, mask);
-}
-
-static inline int
 dma_set_mask(struct device *dev, u64 mask)
 {
 	struct dma_map_ops *dma_ops = get_dma_ops(dev);
diff --git a/arch/unicore32/include/asm/dma-mapping.h b/arch/unicore32/include/asm/dma-mapping.h
index 175d7e3..21231c1 100644
--- a/arch/unicore32/include/asm/dma-mapping.h
+++ b/arch/unicore32/include/asm/dma-mapping.h
@@ -28,16 +28,6 @@ static inline struct dma_map_ops *get_dma_ops(struct device *dev)
 	return &swiotlb_dma_map_ops;
 }
 
-static inline int dma_supported(struct device *dev, u64 mask)
-{
-	struct dma_map_ops *dma_ops = get_dma_ops(dev);
-
-	if (unlikely(dma_ops = NULL))
-		return 0;
-
-	return dma_ops->dma_supported(dev, mask);
-}
-
 #include <asm-generic/dma-mapping-common.h>
 
 static inline bool dma_capable(struct device *dev, dma_addr_t addr, size_t size)
diff --git a/arch/x86/include/asm/dma-mapping.h b/arch/x86/include/asm/dma-mapping.h
index bbca62e..b1fbf58 100644
--- a/arch/x86/include/asm/dma-mapping.h
+++ b/arch/x86/include/asm/dma-mapping.h
@@ -43,9 +43,11 @@ static inline struct dma_map_ops *get_dma_ops(struct device *dev)
 bool arch_dma_alloc_attrs(struct device **dev, gfp_t *gfp);
 #define arch_dma_alloc_attrs arch_dma_alloc_attrs
 
+#define HAVE_ARCH_DMA_SUPPORTED 1
+extern int dma_supported(struct device *hwdev, u64 mask);
+
 #include <asm-generic/dma-mapping-common.h>
 
-extern int dma_supported(struct device *hwdev, u64 mask);
 extern int dma_set_mask(struct device *dev, u64 mask);
 
 extern void *dma_generic_alloc_coherent(struct device *dev, size_t size,
diff --git a/include/asm-generic/dma-mapping-common.h b/include/asm-generic/dma-mapping-common.h
index cdaa241..67fa6bc 100644
--- a/include/asm-generic/dma-mapping-common.h
+++ b/include/asm-generic/dma-mapping-common.h
@@ -327,4 +327,17 @@ static inline int dma_mapping_error(struct device *dev, dma_addr_t dma_addr)
 #endif
 }
 
+#ifndef HAVE_ARCH_DMA_SUPPORTED
+static inline int dma_supported(struct device *dev, u64 mask)
+{
+	struct dma_map_ops *ops = get_dma_ops(dev);
+
+	if (!ops)
+		return 0;
+	if (!ops->dma_supported)
+		return 1;
+	return ops->dma_supported(dev, mask);
+}
+#endif
+
 #endif
-- 
1.9.1

