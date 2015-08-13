From: Christoph Hellwig <hch@lst.de>
Date: Thu, 13 Aug 2015 15:04:05 +0000
Subject: [PATCH 2/5] dma-mapping: consolidate dma_{alloc,free}_noncoherent
Message-Id: <1439478248-15183-3-git-send-email-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <1439478248-15183-1-git-send-email-hch@lst.de>
In-Reply-To: <1439478248-15183-1-git-send-email-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: akpm@linux-foundation.org
Cc: arnd@arndb.de, linux@arm.linux.org.uk, catalin.marinas@arm.com, will.deacon@arm.com, ysato@users.sourceforge.jp, monstr@monstr.eu, jonas@southpole.se, cmetcalf@ezchip.com, gxt@mprc.pku.edu.cn, x86@kernel.org, linux-alpha@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org

Most architectures do not support non-coherent allocations and either
define dma_{alloc,free}_noncoherent to their coherent versions or stub
them out.

Openrisc uses dma_{alloc,free}_attrs to implement them, and only Mips
implements them directly.

This patch moves the Openrisc version to common code, and handles the
DMA_ATTR_NON_CONSISTENT case in the mips dma_map_ops instance.

Note that actual non-coherent allocations require a dma_cache_sync
implementation, so if non-coherent allocations didn't work on
an architecture before this patch they still won't work after it.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/alpha/include/asm/dma-mapping.h      |  3 ---
 arch/arm/include/asm/dma-mapping.h        | 15 ---------------
 arch/arm64/include/asm/dma-mapping.h      | 14 --------------
 arch/h8300/include/asm/dma-mapping.h      |  3 ---
 arch/hexagon/include/asm/dma-mapping.h    |  3 ---
 arch/ia64/include/asm/dma-mapping.h       |  3 ---
 arch/microblaze/include/asm/dma-mapping.h |  3 ---
 arch/mips/include/asm/dma-mapping.h       |  6 ------
 arch/mips/mm/dma-default.c                | 20 +++++++++++++++-----
 arch/openrisc/include/asm/dma-mapping.h   | 20 --------------------
 arch/powerpc/include/asm/dma-mapping.h    |  3 ---
 arch/s390/include/asm/dma-mapping.h       |  3 ---
 arch/sh/include/asm/dma-mapping.h         |  3 ---
 arch/sparc/include/asm/dma-mapping.h      |  3 ---
 arch/tile/include/asm/dma-mapping.h       |  3 ---
 arch/unicore32/include/asm/dma-mapping.h  |  3 ---
 arch/x86/include/asm/dma-mapping.h        |  3 ---
 include/asm-generic/dma-mapping-common.h  | 18 ++++++++++++++++++
 18 files changed, 33 insertions(+), 96 deletions(-)

diff --git a/arch/alpha/include/asm/dma-mapping.h b/arch/alpha/include/asm/dma-mapping.h
index 9fef5bd..0552bf0 100644
--- a/arch/alpha/include/asm/dma-mapping.h
+++ b/arch/alpha/include/asm/dma-mapping.h
@@ -27,9 +27,6 @@ static inline int dma_set_mask(struct device *dev, u64 mask)
 	return get_dma_ops(dev)->set_dma_mask(dev, mask);
 }
 
-#define dma_alloc_noncoherent(d, s, h, f)	dma_alloc_coherent(d, s, h, f)
-#define dma_free_noncoherent(d, s, v, h)	dma_free_coherent(d, s, v, h)
-
 #define dma_cache_sync(dev, va, size, dir)		  ((void)0)
 
 #endif	/* _ALPHA_DMA_MAPPING_H */
diff --git a/arch/arm/include/asm/dma-mapping.h b/arch/arm/include/asm/dma-mapping.h
index 2ae3424..ab521d5 100644
--- a/arch/arm/include/asm/dma-mapping.h
+++ b/arch/arm/include/asm/dma-mapping.h
@@ -175,21 +175,6 @@ static inline int dma_mapping_error(struct device *dev, dma_addr_t dma_addr)
 	return dma_addr = DMA_ERROR_CODE;
 }
 
-/*
- * Dummy noncoherent implementation.  We don't provide a dma_cache_sync
- * function so drivers using this API are highlighted with build warnings.
- */
-static inline void *dma_alloc_noncoherent(struct device *dev, size_t size,
-		dma_addr_t *handle, gfp_t gfp)
-{
-	return NULL;
-}
-
-static inline void dma_free_noncoherent(struct device *dev, size_t size,
-		void *cpu_addr, dma_addr_t handle)
-{
-}
-
 extern int dma_supported(struct device *dev, u64 mask);
 
 extern int arm_dma_set_mask(struct device *dev, u64 dma_mask);
diff --git a/arch/arm64/include/asm/dma-mapping.h b/arch/arm64/include/asm/dma-mapping.h
index 5e11b3f..178e60b 100644
--- a/arch/arm64/include/asm/dma-mapping.h
+++ b/arch/arm64/include/asm/dma-mapping.h
@@ -118,19 +118,5 @@ static inline void dma_mark_clean(void *addr, size_t size)
 {
 }
 
-/*
- * There is no dma_cache_sync() implementation, so just return NULL here.
- */
-static inline void *dma_alloc_noncoherent(struct device *dev, size_t size,
-					  dma_addr_t *handle, gfp_t flags)
-{
-	return NULL;
-}
-
-static inline void dma_free_noncoherent(struct device *dev, size_t size,
-					void *cpu_addr, dma_addr_t handle)
-{
-}
-
 #endif	/* __KERNEL__ */
 #endif	/* __ASM_DMA_MAPPING_H */
diff --git a/arch/h8300/include/asm/dma-mapping.h b/arch/h8300/include/asm/dma-mapping.h
index 826aa9b..72465ce 100644
--- a/arch/h8300/include/asm/dma-mapping.h
+++ b/arch/h8300/include/asm/dma-mapping.h
@@ -20,9 +20,6 @@ static inline int dma_set_mask(struct device *dev, u64 mask)
 	return 0;
 }
 
-#define dma_alloc_noncoherent(d, s, h, f) dma_alloc_coherent(d, s, h, f)
-#define dma_free_noncoherent(d, s, v, h) dma_free_coherent(d, s, v, h)
-
 static inline int dma_mapping_error(struct device *dev, dma_addr_t dma_addr)
 {
 	return 0;
diff --git a/arch/hexagon/include/asm/dma-mapping.h b/arch/hexagon/include/asm/dma-mapping.h
index c20d3ca..58d2d8f 100644
--- a/arch/hexagon/include/asm/dma-mapping.h
+++ b/arch/hexagon/include/asm/dma-mapping.h
@@ -34,9 +34,6 @@ extern int bad_dma_address;
 
 extern struct dma_map_ops *dma_ops;
 
-#define dma_alloc_noncoherent(d, s, h, f) dma_alloc_coherent(d, s, h, f)
-#define dma_free_noncoherent(d, s, v, h) dma_free_coherent(d, s, v, h)
-
 static inline struct dma_map_ops *get_dma_ops(struct device *dev)
 {
 	if (unlikely(dev = NULL))
diff --git a/arch/ia64/include/asm/dma-mapping.h b/arch/ia64/include/asm/dma-mapping.h
index d36f83c..a925ff0 100644
--- a/arch/ia64/include/asm/dma-mapping.h
+++ b/arch/ia64/include/asm/dma-mapping.h
@@ -23,9 +23,6 @@ extern void machvec_dma_sync_single(struct device *, dma_addr_t, size_t,
 extern void machvec_dma_sync_sg(struct device *, struct scatterlist *, int,
 				enum dma_data_direction);
 
-#define dma_alloc_noncoherent(d, s, h, f) dma_alloc_coherent(d, s, h, f)
-#define dma_free_noncoherent(d, s, v, h) dma_free_coherent(d, s, v, h)
-
 #define get_dma_ops(dev) platform_dma_get_ops(dev)
 
 #include <asm-generic/dma-mapping-common.h>
diff --git a/arch/microblaze/include/asm/dma-mapping.h b/arch/microblaze/include/asm/dma-mapping.h
index 801dbe2..bc81625 100644
--- a/arch/microblaze/include/asm/dma-mapping.h
+++ b/arch/microblaze/include/asm/dma-mapping.h
@@ -98,9 +98,6 @@ static inline int dma_mapping_error(struct device *dev, dma_addr_t dma_addr)
 	return (dma_addr = DMA_ERROR_CODE);
 }
 
-#define dma_alloc_noncoherent(d, s, h, f) dma_alloc_coherent(d, s, h, f)
-#define dma_free_noncoherent(d, s, v, h) dma_free_coherent(d, s, v, h)
-
 static inline void dma_cache_sync(struct device *dev, void *vaddr, size_t size,
 		enum dma_data_direction direction)
 {
diff --git a/arch/mips/include/asm/dma-mapping.h b/arch/mips/include/asm/dma-mapping.h
index b197595..709b2ba 100644
--- a/arch/mips/include/asm/dma-mapping.h
+++ b/arch/mips/include/asm/dma-mapping.h
@@ -64,10 +64,4 @@ dma_set_mask(struct device *dev, u64 mask)
 extern void dma_cache_sync(struct device *dev, void *vaddr, size_t size,
 	       enum dma_data_direction direction);
 
-void *dma_alloc_noncoherent(struct device *dev, size_t size,
-			   dma_addr_t *dma_handle, gfp_t flag);
-
-void dma_free_noncoherent(struct device *dev, size_t size,
-			 void *vaddr, dma_addr_t dma_handle);
-
 #endif /* _ASM_DMA_MAPPING_H */
diff --git a/arch/mips/mm/dma-default.c b/arch/mips/mm/dma-default.c
index 8cad422..a5ae290 100644
--- a/arch/mips/mm/dma-default.c
+++ b/arch/mips/mm/dma-default.c
@@ -112,7 +112,7 @@ static gfp_t massage_gfp_flags(const struct device *dev, gfp_t gfp)
 	return gfp | dma_flag;
 }
 
-void *dma_alloc_noncoherent(struct device *dev, size_t size,
+static void *mips_dma_alloc_noncoherent(struct device *dev, size_t size,
 	dma_addr_t * dma_handle, gfp_t gfp)
 {
 	void *ret;
@@ -128,7 +128,6 @@ void *dma_alloc_noncoherent(struct device *dev, size_t size,
 
 	return ret;
 }
-EXPORT_SYMBOL(dma_alloc_noncoherent);
 
 static void *mips_dma_alloc_coherent(struct device *dev, size_t size,
 	dma_addr_t * dma_handle, gfp_t gfp, struct dma_attrs *attrs)
@@ -137,6 +136,13 @@ static void *mips_dma_alloc_coherent(struct device *dev, size_t size,
 	struct page *page = NULL;
 	unsigned int count = PAGE_ALIGN(size) >> PAGE_SHIFT;
 
+	/*
+	 * XXX: seems like the coherent and non-coherent implementations could
+	 * be consolidated.
+	 */
+	if (dma_get_attr(DMA_ATTR_NON_CONSISTENT, attrs))
+		return mips_dma_alloc_noncoherent(dev, size, dma_handle, gfp);
+
 	gfp = massage_gfp_flags(dev, gfp);
 
 	if (IS_ENABLED(CONFIG_DMA_CMA) && !(gfp & GFP_ATOMIC))
@@ -161,13 +167,12 @@ static void *mips_dma_alloc_coherent(struct device *dev, size_t size,
 }
 
 
-void dma_free_noncoherent(struct device *dev, size_t size, void *vaddr,
-	dma_addr_t dma_handle)
+static void mips_dma_free_noncoherent(struct device *dev, size_t size,
+		void *vaddr, dma_addr_t dma_handle)
 {
 	plat_unmap_dma_mem(dev, dma_handle, size, DMA_BIDIRECTIONAL);
 	free_pages((unsigned long) vaddr, get_order(size));
 }
-EXPORT_SYMBOL(dma_free_noncoherent);
 
 static void mips_dma_free_coherent(struct device *dev, size_t size, void *vaddr,
 	dma_addr_t dma_handle, struct dma_attrs *attrs)
@@ -176,6 +181,11 @@ static void mips_dma_free_coherent(struct device *dev, size_t size, void *vaddr,
 	unsigned int count = PAGE_ALIGN(size) >> PAGE_SHIFT;
 	struct page *page = NULL;
 
+	if (dma_get_attr(DMA_ATTR_NON_CONSISTENT, attrs)) {
+		mips_dma_free_noncoherent(dev, size, vaddr, dma_handle);
+		return;
+	}
+
 	plat_unmap_dma_mem(dev, dma_handle, size, DMA_BIDIRECTIONAL);
 
 	if (!plat_device_is_coherent(dev) && !hw_coherentio)
diff --git a/arch/openrisc/include/asm/dma-mapping.h b/arch/openrisc/include/asm/dma-mapping.h
index a81d6f6..57722528 100644
--- a/arch/openrisc/include/asm/dma-mapping.h
+++ b/arch/openrisc/include/asm/dma-mapping.h
@@ -37,26 +37,6 @@ static inline struct dma_map_ops *get_dma_ops(struct device *dev)
 
 #include <asm-generic/dma-mapping-common.h>
 
-static inline void *dma_alloc_noncoherent(struct device *dev, size_t size,
-					  dma_addr_t *dma_handle, gfp_t gfp)
-{
-	struct dma_attrs attrs;
-
-	dma_set_attr(DMA_ATTR_NON_CONSISTENT, &attrs);
-
-	return dma_alloc_attrs(dev, size, dma_handle, gfp, &attrs);
-}
-
-static inline void dma_free_noncoherent(struct device *dev, size_t size,
-					 void *cpu_addr, dma_addr_t dma_handle)
-{
-	struct dma_attrs attrs;
-
-	dma_set_attr(DMA_ATTR_NON_CONSISTENT, &attrs);
-
-	dma_free_attrs(dev, size, cpu_addr, dma_handle, &attrs);
-}
-
 static inline int dma_supported(struct device *dev, u64 dma_mask)
 {
 	/* Support 32 bit DMA mask exclusively */
diff --git a/arch/powerpc/include/asm/dma-mapping.h b/arch/powerpc/include/asm/dma-mapping.h
index 846c630..dec0260 100644
--- a/arch/powerpc/include/asm/dma-mapping.h
+++ b/arch/powerpc/include/asm/dma-mapping.h
@@ -177,9 +177,6 @@ static inline phys_addr_t dma_to_phys(struct device *dev, dma_addr_t daddr)
 	return daddr - get_dma_offset(dev);
 }
 
-#define dma_alloc_noncoherent(d, s, h, f) dma_alloc_coherent(d, s, h, f)
-#define dma_free_noncoherent(d, s, v, h) dma_free_coherent(d, s, v, h)
-
 #define ARCH_HAS_DMA_MMAP_COHERENT
 
 static inline void dma_cache_sync(struct device *dev, void *vaddr, size_t size,
diff --git a/arch/s390/include/asm/dma-mapping.h b/arch/s390/include/asm/dma-mapping.h
index c29c9c7..b729efe 100644
--- a/arch/s390/include/asm/dma-mapping.h
+++ b/arch/s390/include/asm/dma-mapping.h
@@ -25,9 +25,6 @@ static inline void dma_cache_sync(struct device *dev, void *vaddr, size_t size,
 {
 }
 
-#define dma_alloc_noncoherent(d, s, h, f) dma_alloc_coherent(d, s, h, f)
-#define dma_free_noncoherent(d, s, v, h) dma_free_coherent(d, s, v, h)
-
 #include <asm-generic/dma-mapping-common.h>
 
 static inline int dma_supported(struct device *dev, u64 mask)
diff --git a/arch/sh/include/asm/dma-mapping.h b/arch/sh/include/asm/dma-mapping.h
index 3c78059..2c3fa2c 100644
--- a/arch/sh/include/asm/dma-mapping.h
+++ b/arch/sh/include/asm/dma-mapping.h
@@ -38,9 +38,6 @@ static inline int dma_set_mask(struct device *dev, u64 mask)
 void dma_cache_sync(struct device *dev, void *vaddr, size_t size,
 		    enum dma_data_direction dir);
 
-#define dma_alloc_noncoherent(d, s, h, f) dma_alloc_coherent(d, s, h, f)
-#define dma_free_noncoherent(d, s, v, h) dma_free_coherent(d, s, v, h)
-
 static inline int dma_mapping_error(struct device *dev, dma_addr_t dma_addr)
 {
 	struct dma_map_ops *ops = get_dma_ops(dev);
diff --git a/arch/sparc/include/asm/dma-mapping.h b/arch/sparc/include/asm/dma-mapping.h
index a8c6784..2564edc 100644
--- a/arch/sparc/include/asm/dma-mapping.h
+++ b/arch/sparc/include/asm/dma-mapping.h
@@ -9,9 +9,6 @@
 
 int dma_supported(struct device *dev, u64 mask);
 
-#define dma_alloc_noncoherent(d, s, h, f) dma_alloc_coherent(d, s, h, f)
-#define dma_free_noncoherent(d, s, v, h) dma_free_coherent(d, s, v, h)
-
 static inline void dma_cache_sync(struct device *dev, void *vaddr, size_t size,
 				  enum dma_data_direction dir)
 {
diff --git a/arch/tile/include/asm/dma-mapping.h b/arch/tile/include/asm/dma-mapping.h
index 4aba10e..e982dfa 100644
--- a/arch/tile/include/asm/dma-mapping.h
+++ b/arch/tile/include/asm/dma-mapping.h
@@ -116,9 +116,6 @@ dma_set_mask(struct device *dev, u64 mask)
 	return 0;
 }
 
-#define dma_alloc_noncoherent(d, s, h, f) dma_alloc_attrs(d, s, h, f, NULL)
-#define dma_free_noncoherent(d, s, v, h) dma_free_attrs(d, s, v, h, NULL)
-
 /*
  * dma_alloc_noncoherent() is #defined to return coherent memory,
  * so there's no need to do any flushing here.
diff --git a/arch/unicore32/include/asm/dma-mapping.h b/arch/unicore32/include/asm/dma-mapping.h
index 5294d03..636e942 100644
--- a/arch/unicore32/include/asm/dma-mapping.h
+++ b/arch/unicore32/include/asm/dma-mapping.h
@@ -80,9 +80,6 @@ static inline int dma_set_mask(struct device *dev, u64 dma_mask)
 	return 0;
 }
 
-#define dma_alloc_noncoherent(d, s, h, f) dma_alloc_coherent(d, s, h, f)
-#define dma_free_noncoherent(d, s, v, h) dma_free_coherent(d, s, v, h)
-
 static inline void dma_cache_sync(struct device *dev, void *vaddr,
 		size_t size, enum dma_data_direction direction)
 {
diff --git a/arch/x86/include/asm/dma-mapping.h b/arch/x86/include/asm/dma-mapping.h
index f9b1b6c..7e47e4d 100644
--- a/arch/x86/include/asm/dma-mapping.h
+++ b/arch/x86/include/asm/dma-mapping.h
@@ -56,9 +56,6 @@ static inline int dma_mapping_error(struct device *dev, dma_addr_t dma_addr)
 	return (dma_addr = DMA_ERROR_CODE);
 }
 
-#define dma_alloc_noncoherent(d, s, h, f) dma_alloc_coherent(d, s, h, f)
-#define dma_free_noncoherent(d, s, v, h) dma_free_coherent(d, s, v, h)
-
 extern int dma_supported(struct device *hwdev, u64 mask);
 extern int dma_set_mask(struct device *dev, u64 mask);
 
diff --git a/include/asm-generic/dma-mapping-common.h b/include/asm-generic/dma-mapping-common.h
index 56dd9ea..ec321dd 100644
--- a/include/asm-generic/dma-mapping-common.h
+++ b/include/asm-generic/dma-mapping-common.h
@@ -295,4 +295,22 @@ static inline void dma_free_coherent(struct device *dev, size_t size,
 	return dma_free_attrs(dev, size, cpu_addr, dma_handle, NULL);
 }
 
+static inline void *dma_alloc_noncoherent(struct device *dev, size_t size,
+		dma_addr_t *dma_handle, gfp_t gfp)
+{
+	DEFINE_DMA_ATTRS(attrs);
+
+	dma_set_attr(DMA_ATTR_NON_CONSISTENT, &attrs);
+	return dma_alloc_attrs(dev, size, dma_handle, gfp, &attrs);
+}
+
+static inline void dma_free_noncoherent(struct device *dev, size_t size,
+		void *cpu_addr, dma_addr_t dma_handle)
+{
+	DEFINE_DMA_ATTRS(attrs);
+
+	dma_set_attr(DMA_ATTR_NON_CONSISTENT, &attrs);
+	dma_free_attrs(dev, size, cpu_addr, dma_handle, &attrs);
+}
+
 #endif
-- 
1.9.1

