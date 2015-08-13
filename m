From: Christoph Hellwig <hch@lst.de>
Date: Thu, 13 Aug 2015 15:04:04 +0000
Subject: [PATCH 1/5] dma-mapping: consolidate dma_{alloc,free}_{attrs,coherent}
Message-Id: <1439478248-15183-2-git-send-email-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <1439478248-15183-1-git-send-email-hch@lst.de>
In-Reply-To: <1439478248-15183-1-git-send-email-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: akpm@linux-foundation.org
Cc: arnd@arndb.de, linux@arm.linux.org.uk, catalin.marinas@arm.com, will.deacon@arm.com, ysato@users.sourceforge.jp, monstr@monstr.eu, jonas@southpole.se, cmetcalf@ezchip.com, gxt@mprc.pku.edu.cn, x86@kernel.org, linux-alpha@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org

The coherent DMA allocator works the same over all architectures supporting
dma_map operations.

This patch consolidates them and converges the minor differences:

 - the debug_dma helpers are now called from all architectures, including
   those that were previously missing them
 - dma_alloc_from_coherent and dma_release_from_coherent are now always
   called from the generic alloc/free routines instead of the ops
   dma-mapping-common.h always includes dma-coherent.h to get the defintions
   for them, or the stubs if the architecture doesn't support this feature
 - checks for ->alloc / ->free presence are removed.  There is only one
   magic instead of dma_map_ops without them (mic_dma_ops) and that one
   is x86 only anyway.

Besides that only x86 needs special treatment to replace a default devices
if none is passed and tweak the gfp_flags.  An optional arch hook is provided
for that.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/alpha/include/asm/dma-mapping.h      | 18 ----------
 arch/arm/include/asm/dma-mapping.h        | 29 ----------------
 arch/arm/mm/dma-mapping.c                 | 11 ------
 arch/arm64/include/asm/dma-mapping.h      | 33 ------------------
 arch/h8300/include/asm/dma-mapping.h      | 26 --------------
 arch/hexagon/include/asm/dma-mapping.h    | 33 ------------------
 arch/ia64/include/asm/dma-mapping.h       | 25 -------------
 arch/microblaze/include/asm/dma-mapping.h | 31 -----------------
 arch/mips/cavium-octeon/dma-octeon.c      |  8 -----
 arch/mips/include/asm/dma-mapping.h       | 31 -----------------
 arch/mips/loongson64/common/dma-swiotlb.c |  8 -----
 arch/mips/mm/dma-default.c                |  7 ----
 arch/mips/netlogic/common/nlm-dma.c       |  8 -----
 arch/openrisc/include/asm/dma-mapping.h   | 30 ----------------
 arch/powerpc/include/asm/dma-mapping.h    | 33 ------------------
 arch/s390/include/asm/dma-mapping.h       | 31 -----------------
 arch/sh/include/asm/dma-mapping.h         | 37 --------------------
 arch/sparc/include/asm/dma-mapping.h      | 26 --------------
 arch/tile/include/asm/dma-mapping.h       | 27 --------------
 arch/unicore32/include/asm/dma-mapping.h  | 24 -------------
 arch/x86/include/asm/dma-mapping.h        | 16 ++-------
 arch/x86/kernel/pci-dma.c                 | 49 +++++---------------------
 drivers/xen/swiotlb-xen.c                 |  6 ----
 include/asm-generic/dma-mapping-common.h  | 58 +++++++++++++++++++++++++++++++
 24 files changed, 70 insertions(+), 535 deletions(-)

diff --git a/arch/alpha/include/asm/dma-mapping.h b/arch/alpha/include/asm/dma-mapping.h
index dfa32f0..9fef5bd 100644
--- a/arch/alpha/include/asm/dma-mapping.h
+++ b/arch/alpha/include/asm/dma-mapping.h
@@ -12,24 +12,6 @@ static inline struct dma_map_ops *get_dma_ops(struct device *dev)
 
 #include <asm-generic/dma-mapping-common.h>
 
-#define dma_alloc_coherent(d,s,h,f)	dma_alloc_attrs(d,s,h,f,NULL)
-
-static inline void *dma_alloc_attrs(struct device *dev, size_t size,
-				    dma_addr_t *dma_handle, gfp_t gfp,
-				    struct dma_attrs *attrs)
-{
-	return get_dma_ops(dev)->alloc(dev, size, dma_handle, gfp, attrs);
-}
-
-#define dma_free_coherent(d,s,c,h) dma_free_attrs(d,s,c,h,NULL)
-
-static inline void dma_free_attrs(struct device *dev, size_t size,
-				  void *vaddr, dma_addr_t dma_handle,
-				  struct dma_attrs *attrs)
-{
-	get_dma_ops(dev)->free(dev, size, vaddr, dma_handle, attrs);
-}
-
 static inline int dma_mapping_error(struct device *dev, dma_addr_t dma_addr)
 {
 	return get_dma_ops(dev)->mapping_error(dev, dma_addr);
diff --git a/arch/arm/include/asm/dma-mapping.h b/arch/arm/include/asm/dma-mapping.h
index b52101d..2ae3424 100644
--- a/arch/arm/include/asm/dma-mapping.h
+++ b/arch/arm/include/asm/dma-mapping.h
@@ -8,7 +8,6 @@
 #include <linux/dma-attrs.h>
 #include <linux/dma-debug.h>
 
-#include <asm-generic/dma-coherent.h>
 #include <asm/memory.h>
 
 #include <xen/xen.h>
@@ -209,21 +208,6 @@ extern int arm_dma_set_mask(struct device *dev, u64 dma_mask);
 extern void *arm_dma_alloc(struct device *dev, size_t size, dma_addr_t *handle,
 			   gfp_t gfp, struct dma_attrs *attrs);
 
-#define dma_alloc_coherent(d, s, h, f) dma_alloc_attrs(d, s, h, f, NULL)
-
-static inline void *dma_alloc_attrs(struct device *dev, size_t size,
-				       dma_addr_t *dma_handle, gfp_t flag,
-				       struct dma_attrs *attrs)
-{
-	struct dma_map_ops *ops = get_dma_ops(dev);
-	void *cpu_addr;
-	BUG_ON(!ops);
-
-	cpu_addr = ops->alloc(dev, size, dma_handle, flag, attrs);
-	debug_dma_alloc_coherent(dev, size, *dma_handle, cpu_addr);
-	return cpu_addr;
-}
-
 /**
  * arm_dma_free - free memory allocated by arm_dma_alloc
  * @dev: valid struct device pointer, or NULL for ISA and EISA-like devices
@@ -241,19 +225,6 @@ static inline void *dma_alloc_attrs(struct device *dev, size_t size,
 extern void arm_dma_free(struct device *dev, size_t size, void *cpu_addr,
 			 dma_addr_t handle, struct dma_attrs *attrs);
 
-#define dma_free_coherent(d, s, c, h) dma_free_attrs(d, s, c, h, NULL)
-
-static inline void dma_free_attrs(struct device *dev, size_t size,
-				     void *cpu_addr, dma_addr_t dma_handle,
-				     struct dma_attrs *attrs)
-{
-	struct dma_map_ops *ops = get_dma_ops(dev);
-	BUG_ON(!ops);
-
-	debug_dma_free_coherent(dev, size, cpu_addr, dma_handle);
-	ops->free(dev, size, cpu_addr, dma_handle, attrs);
-}
-
 /**
  * arm_dma_mmap - map a coherent DMA allocation into user space
  * @dev: valid struct device pointer, or NULL for ISA and EISA-like devices
diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
index cba12f3..e556e0e 100644
--- a/arch/arm/mm/dma-mapping.c
+++ b/arch/arm/mm/dma-mapping.c
@@ -671,10 +671,6 @@ void *arm_dma_alloc(struct device *dev, size_t size, dma_addr_t *handle,
 		    gfp_t gfp, struct dma_attrs *attrs)
 {
 	pgprot_t prot = __get_dma_pgprot(attrs, PAGE_KERNEL);
-	void *memory;
-
-	if (dma_alloc_from_coherent(dev, size, handle, &memory))
-		return memory;
 
 	return __dma_alloc(dev, size, handle, gfp, prot, false,
 			   attrs, __builtin_return_address(0));
@@ -684,10 +680,6 @@ static void *arm_coherent_dma_alloc(struct device *dev, size_t size,
 	dma_addr_t *handle, gfp_t gfp, struct dma_attrs *attrs)
 {
 	pgprot_t prot = __get_dma_pgprot(attrs, PAGE_KERNEL);
-	void *memory;
-
-	if (dma_alloc_from_coherent(dev, size, handle, &memory))
-		return memory;
 
 	return __dma_alloc(dev, size, handle, gfp, prot, true,
 			   attrs, __builtin_return_address(0));
@@ -748,9 +740,6 @@ static void __arm_dma_free(struct device *dev, size_t size, void *cpu_addr,
 	struct page *page = pfn_to_page(dma_to_pfn(dev, handle));
 	bool want_vaddr = !dma_get_attr(DMA_ATTR_NO_KERNEL_MAPPING, attrs);
 
-	if (dma_release_from_coherent(dev, get_order(size), cpu_addr))
-		return;
-
 	size = PAGE_ALIGN(size);
 
 	if (is_coherent || nommu()) {
diff --git a/arch/arm64/include/asm/dma-mapping.h b/arch/arm64/include/asm/dma-mapping.h
index f0d6d0b..5e11b3f 100644
--- a/arch/arm64/include/asm/dma-mapping.h
+++ b/arch/arm64/include/asm/dma-mapping.h
@@ -22,8 +22,6 @@
 #include <linux/types.h>
 #include <linux/vmalloc.h>
 
-#include <asm-generic/dma-coherent.h>
-
 #include <xen/xen.h>
 #include <asm/xen/hypervisor.h>
 
@@ -120,37 +118,6 @@ static inline void dma_mark_clean(void *addr, size_t size)
 {
 }
 
-#define dma_alloc_coherent(d, s, h, f)	dma_alloc_attrs(d, s, h, f, NULL)
-#define dma_free_coherent(d, s, h, f)	dma_free_attrs(d, s, h, f, NULL)
-
-static inline void *dma_alloc_attrs(struct device *dev, size_t size,
-				    dma_addr_t *dma_handle, gfp_t flags,
-				    struct dma_attrs *attrs)
-{
-	struct dma_map_ops *ops = get_dma_ops(dev);
-	void *vaddr;
-
-	if (dma_alloc_from_coherent(dev, size, dma_handle, &vaddr))
-		return vaddr;
-
-	vaddr = ops->alloc(dev, size, dma_handle, flags, attrs);
-	debug_dma_alloc_coherent(dev, size, *dma_handle, vaddr);
-	return vaddr;
-}
-
-static inline void dma_free_attrs(struct device *dev, size_t size,
-				  void *vaddr, dma_addr_t dev_addr,
-				  struct dma_attrs *attrs)
-{
-	struct dma_map_ops *ops = get_dma_ops(dev);
-
-	if (dma_release_from_coherent(dev, get_order(size), vaddr))
-		return;
-
-	debug_dma_free_coherent(dev, size, vaddr, dev_addr);
-	ops->free(dev, size, vaddr, dev_addr, attrs);
-}
-
 /*
  * There is no dma_cache_sync() implementation, so just return NULL here.
  */
diff --git a/arch/h8300/include/asm/dma-mapping.h b/arch/h8300/include/asm/dma-mapping.h
index 6e67a909..826aa9b 100644
--- a/arch/h8300/include/asm/dma-mapping.h
+++ b/arch/h8300/include/asm/dma-mapping.h
@@ -1,8 +1,6 @@
 #ifndef _H8300_DMA_MAPPING_H
 #define _H8300_DMA_MAPPING_H
 
-#include <asm-generic/dma-coherent.h>
-
 extern struct dma_map_ops h8300_dma_map_ops;
 
 static inline struct dma_map_ops *get_dma_ops(struct device *dev)
@@ -25,30 +23,6 @@ static inline int dma_set_mask(struct device *dev, u64 mask)
 #define dma_alloc_noncoherent(d, s, h, f) dma_alloc_coherent(d, s, h, f)
 #define dma_free_noncoherent(d, s, v, h) dma_free_coherent(d, s, v, h)
 
-#define dma_alloc_coherent(d, s, h, f) dma_alloc_attrs(d, s, h, f, NULL)
-
-static inline void *dma_alloc_attrs(struct device *dev, size_t size,
-				    dma_addr_t *dma_handle, gfp_t flag,
-				    struct dma_attrs *attrs)
-{
-	struct dma_map_ops *ops = get_dma_ops(dev);
-	void *memory;
-
-	memory = ops->alloc(dev, size, dma_handle, flag, attrs);
-	return memory;
-}
-
-#define dma_free_coherent(d, s, c, h) dma_free_attrs(d, s, c, h, NULL)
-
-static inline void dma_free_attrs(struct device *dev, size_t size,
-				  void *cpu_addr, dma_addr_t dma_handle,
-				  struct dma_attrs *attrs)
-{
-	struct dma_map_ops *ops = get_dma_ops(dev);
-
-	ops->free(dev, size, cpu_addr, dma_handle, attrs);
-}
-
 static inline int dma_mapping_error(struct device *dev, dma_addr_t dma_addr)
 {
 	return 0;
diff --git a/arch/hexagon/include/asm/dma-mapping.h b/arch/hexagon/include/asm/dma-mapping.h
index 1696542..c20d3ca 100644
--- a/arch/hexagon/include/asm/dma-mapping.h
+++ b/arch/hexagon/include/asm/dma-mapping.h
@@ -70,37 +70,4 @@ static inline int dma_mapping_error(struct device *dev, dma_addr_t dma_addr)
 	return (dma_addr = bad_dma_address);
 }
 
-#define dma_alloc_coherent(d,s,h,f)	dma_alloc_attrs(d,s,h,f,NULL)
-
-static inline void *dma_alloc_attrs(struct device *dev, size_t size,
-				    dma_addr_t *dma_handle, gfp_t flag,
-				    struct dma_attrs *attrs)
-{
-	void *ret;
-	struct dma_map_ops *ops = get_dma_ops(dev);
-
-	BUG_ON(!dma_ops);
-
-	ret = ops->alloc(dev, size, dma_handle, flag, attrs);
-
-	debug_dma_alloc_coherent(dev, size, *dma_handle, ret);
-
-	return ret;
-}
-
-#define dma_free_coherent(d,s,c,h) dma_free_attrs(d,s,c,h,NULL)
-
-static inline void dma_free_attrs(struct device *dev, size_t size,
-				  void *cpu_addr, dma_addr_t dma_handle,
-				  struct dma_attrs *attrs)
-{
-	struct dma_map_ops *dma_ops = get_dma_ops(dev);
-
-	BUG_ON(!dma_ops);
-
-	dma_ops->free(dev, size, cpu_addr, dma_handle, attrs);
-
-	debug_dma_free_coherent(dev, size, cpu_addr, dma_handle);
-}
-
 #endif
diff --git a/arch/ia64/include/asm/dma-mapping.h b/arch/ia64/include/asm/dma-mapping.h
index cf3ab7e..d36f83c 100644
--- a/arch/ia64/include/asm/dma-mapping.h
+++ b/arch/ia64/include/asm/dma-mapping.h
@@ -23,31 +23,6 @@ extern void machvec_dma_sync_single(struct device *, dma_addr_t, size_t,
 extern void machvec_dma_sync_sg(struct device *, struct scatterlist *, int,
 				enum dma_data_direction);
 
-#define dma_alloc_coherent(d,s,h,f)	dma_alloc_attrs(d,s,h,f,NULL)
-
-static inline void *dma_alloc_attrs(struct device *dev, size_t size,
-				    dma_addr_t *daddr, gfp_t gfp,
-				    struct dma_attrs *attrs)
-{
-	struct dma_map_ops *ops = platform_dma_get_ops(dev);
-	void *caddr;
-
-	caddr = ops->alloc(dev, size, daddr, gfp, attrs);
-	debug_dma_alloc_coherent(dev, size, *daddr, caddr);
-	return caddr;
-}
-
-#define dma_free_coherent(d,s,c,h) dma_free_attrs(d,s,c,h,NULL)
-
-static inline void dma_free_attrs(struct device *dev, size_t size,
-				  void *caddr, dma_addr_t daddr,
-				  struct dma_attrs *attrs)
-{
-	struct dma_map_ops *ops = platform_dma_get_ops(dev);
-	debug_dma_free_coherent(dev, size, caddr, daddr);
-	ops->free(dev, size, caddr, daddr, attrs);
-}
-
 #define dma_alloc_noncoherent(d, s, h, f) dma_alloc_coherent(d, s, h, f)
 #define dma_free_noncoherent(d, s, v, h) dma_free_coherent(d, s, v, h)
 
diff --git a/arch/microblaze/include/asm/dma-mapping.h b/arch/microblaze/include/asm/dma-mapping.h
index ab35372..801dbe2 100644
--- a/arch/microblaze/include/asm/dma-mapping.h
+++ b/arch/microblaze/include/asm/dma-mapping.h
@@ -27,7 +27,6 @@
 #include <linux/dma-debug.h>
 #include <linux/dma-attrs.h>
 #include <asm/io.h>
-#include <asm-generic/dma-coherent.h>
 #include <asm/cacheflush.h>
 
 #define DMA_ERROR_CODE		(~(dma_addr_t)0x0)
@@ -102,36 +101,6 @@ static inline int dma_mapping_error(struct device *dev, dma_addr_t dma_addr)
 #define dma_alloc_noncoherent(d, s, h, f) dma_alloc_coherent(d, s, h, f)
 #define dma_free_noncoherent(d, s, v, h) dma_free_coherent(d, s, v, h)
 
-#define dma_alloc_coherent(d, s, h, f) dma_alloc_attrs(d, s, h, f, NULL)
-
-static inline void *dma_alloc_attrs(struct device *dev, size_t size,
-				    dma_addr_t *dma_handle, gfp_t flag,
-				    struct dma_attrs *attrs)
-{
-	struct dma_map_ops *ops = get_dma_ops(dev);
-	void *memory;
-
-	BUG_ON(!ops);
-
-	memory = ops->alloc(dev, size, dma_handle, flag, attrs);
-
-	debug_dma_alloc_coherent(dev, size, *dma_handle, memory);
-	return memory;
-}
-
-#define dma_free_coherent(d,s,c,h) dma_free_attrs(d, s, c, h, NULL)
-
-static inline void dma_free_attrs(struct device *dev, size_t size,
-				  void *cpu_addr, dma_addr_t dma_handle,
-				  struct dma_attrs *attrs)
-{
-	struct dma_map_ops *ops = get_dma_ops(dev);
-
-	BUG_ON(!ops);
-	debug_dma_free_coherent(dev, size, cpu_addr, dma_handle);
-	ops->free(dev, size, cpu_addr, dma_handle, attrs);
-}
-
 static inline void dma_cache_sync(struct device *dev, void *vaddr, size_t size,
 		enum dma_data_direction direction)
 {
diff --git a/arch/mips/cavium-octeon/dma-octeon.c b/arch/mips/cavium-octeon/dma-octeon.c
index d8960d4..2cd45f5 100644
--- a/arch/mips/cavium-octeon/dma-octeon.c
+++ b/arch/mips/cavium-octeon/dma-octeon.c
@@ -161,9 +161,6 @@ static void *octeon_dma_alloc_coherent(struct device *dev, size_t size,
 {
 	void *ret;
 
-	if (dma_alloc_from_coherent(dev, size, dma_handle, &ret))
-		return ret;
-
 	/* ignore region specifiers */
 	gfp &= ~(__GFP_DMA | __GFP_DMA32 | __GFP_HIGHMEM);
 
@@ -194,11 +191,6 @@ static void *octeon_dma_alloc_coherent(struct device *dev, size_t size,
 static void octeon_dma_free_coherent(struct device *dev, size_t size,
 	void *vaddr, dma_addr_t dma_handle, struct dma_attrs *attrs)
 {
-	int order = get_order(size);
-
-	if (dma_release_from_coherent(dev, order, vaddr))
-		return;
-
 	swiotlb_free_coherent(dev, size, vaddr, dma_handle);
 }
 
diff --git a/arch/mips/include/asm/dma-mapping.h b/arch/mips/include/asm/dma-mapping.h
index 360b338..b197595 100644
--- a/arch/mips/include/asm/dma-mapping.h
+++ b/arch/mips/include/asm/dma-mapping.h
@@ -4,7 +4,6 @@
 #include <linux/scatterlist.h>
 #include <asm/dma-coherence.h>
 #include <asm/cache.h>
-#include <asm-generic/dma-coherent.h>
 
 #ifndef CONFIG_SGI_IP27 /* Kludge to fix 2.6.39 build for IP27 */
 #include <dma-coherence.h>
@@ -65,36 +64,6 @@ dma_set_mask(struct device *dev, u64 mask)
 extern void dma_cache_sync(struct device *dev, void *vaddr, size_t size,
 	       enum dma_data_direction direction);
 
-#define dma_alloc_coherent(d,s,h,f)	dma_alloc_attrs(d,s,h,f,NULL)
-
-static inline void *dma_alloc_attrs(struct device *dev, size_t size,
-				    dma_addr_t *dma_handle, gfp_t gfp,
-				    struct dma_attrs *attrs)
-{
-	void *ret;
-	struct dma_map_ops *ops = get_dma_ops(dev);
-
-	ret = ops->alloc(dev, size, dma_handle, gfp, attrs);
-
-	debug_dma_alloc_coherent(dev, size, *dma_handle, ret);
-
-	return ret;
-}
-
-#define dma_free_coherent(d,s,c,h) dma_free_attrs(d,s,c,h,NULL)
-
-static inline void dma_free_attrs(struct device *dev, size_t size,
-				  void *vaddr, dma_addr_t dma_handle,
-				  struct dma_attrs *attrs)
-{
-	struct dma_map_ops *ops = get_dma_ops(dev);
-
-	ops->free(dev, size, vaddr, dma_handle, attrs);
-
-	debug_dma_free_coherent(dev, size, vaddr, dma_handle);
-}
-
-
 void *dma_alloc_noncoherent(struct device *dev, size_t size,
 			   dma_addr_t *dma_handle, gfp_t flag);
 
diff --git a/arch/mips/loongson64/common/dma-swiotlb.c b/arch/mips/loongson64/common/dma-swiotlb.c
index 2c6b989..ef9da3b 100644
--- a/arch/mips/loongson64/common/dma-swiotlb.c
+++ b/arch/mips/loongson64/common/dma-swiotlb.c
@@ -14,9 +14,6 @@ static void *loongson_dma_alloc_coherent(struct device *dev, size_t size,
 {
 	void *ret;
 
-	if (dma_alloc_from_coherent(dev, size, dma_handle, &ret))
-		return ret;
-
 	/* ignore region specifiers */
 	gfp &= ~(__GFP_DMA | __GFP_DMA32 | __GFP_HIGHMEM);
 
@@ -46,11 +43,6 @@ static void *loongson_dma_alloc_coherent(struct device *dev, size_t size,
 static void loongson_dma_free_coherent(struct device *dev, size_t size,
 		void *vaddr, dma_addr_t dma_handle, struct dma_attrs *attrs)
 {
-	int order = get_order(size);
-
-	if (dma_release_from_coherent(dev, order, vaddr))
-		return;
-
 	swiotlb_free_coherent(dev, size, vaddr, dma_handle);
 }
 
diff --git a/arch/mips/mm/dma-default.c b/arch/mips/mm/dma-default.c
index eeaf024..8cad422 100644
--- a/arch/mips/mm/dma-default.c
+++ b/arch/mips/mm/dma-default.c
@@ -137,9 +137,6 @@ static void *mips_dma_alloc_coherent(struct device *dev, size_t size,
 	struct page *page = NULL;
 	unsigned int count = PAGE_ALIGN(size) >> PAGE_SHIFT;
 
-	if (dma_alloc_from_coherent(dev, size, dma_handle, &ret))
-		return ret;
-
 	gfp = massage_gfp_flags(dev, gfp);
 
 	if (IS_ENABLED(CONFIG_DMA_CMA) && !(gfp & GFP_ATOMIC))
@@ -176,13 +173,9 @@ static void mips_dma_free_coherent(struct device *dev, size_t size, void *vaddr,
 	dma_addr_t dma_handle, struct dma_attrs *attrs)
 {
 	unsigned long addr = (unsigned long) vaddr;
-	int order = get_order(size);
 	unsigned int count = PAGE_ALIGN(size) >> PAGE_SHIFT;
 	struct page *page = NULL;
 
-	if (dma_release_from_coherent(dev, order, vaddr))
-		return;
-
 	plat_unmap_dma_mem(dev, dma_handle, size, DMA_BIDIRECTIONAL);
 
 	if (!plat_device_is_coherent(dev) && !hw_coherentio)
diff --git a/arch/mips/netlogic/common/nlm-dma.c b/arch/mips/netlogic/common/nlm-dma.c
index f3d4ae8..3e4f3bb 100644
--- a/arch/mips/netlogic/common/nlm-dma.c
+++ b/arch/mips/netlogic/common/nlm-dma.c
@@ -49,9 +49,6 @@ static void *nlm_dma_alloc_coherent(struct device *dev, size_t size,
 {
 	void *ret;
 
-	if (dma_alloc_from_coherent(dev, size, dma_handle, &ret))
-		return ret;
-
 	/* ignore region specifiers */
 	gfp &= ~(__GFP_DMA | __GFP_DMA32 | __GFP_HIGHMEM);
 
@@ -69,11 +66,6 @@ static void *nlm_dma_alloc_coherent(struct device *dev, size_t size,
 static void nlm_dma_free_coherent(struct device *dev, size_t size,
 	void *vaddr, dma_addr_t dma_handle, struct dma_attrs *attrs)
 {
-	int order = get_order(size);
-
-	if (dma_release_from_coherent(dev, order, vaddr))
-		return;
-
 	swiotlb_free_coherent(dev, size, vaddr, dma_handle);
 }
 
diff --git a/arch/openrisc/include/asm/dma-mapping.h b/arch/openrisc/include/asm/dma-mapping.h
index fab8628..a81d6f6 100644
--- a/arch/openrisc/include/asm/dma-mapping.h
+++ b/arch/openrisc/include/asm/dma-mapping.h
@@ -23,7 +23,6 @@
  */
 
 #include <linux/dma-debug.h>
-#include <asm-generic/dma-coherent.h>
 #include <linux/kmemcheck.h>
 #include <linux/dma-mapping.h>
 
@@ -38,35 +37,6 @@ static inline struct dma_map_ops *get_dma_ops(struct device *dev)
 
 #include <asm-generic/dma-mapping-common.h>
 
-#define dma_alloc_coherent(d,s,h,f) dma_alloc_attrs(d,s,h,f,NULL) 
-
-static inline void *dma_alloc_attrs(struct device *dev, size_t size,
-				    dma_addr_t *dma_handle, gfp_t gfp,
-				    struct dma_attrs *attrs)
-{
-	struct dma_map_ops *ops = get_dma_ops(dev);
-	void *memory;
-
-	memory = ops->alloc(dev, size, dma_handle, gfp, attrs);
-
-	debug_dma_alloc_coherent(dev, size, *dma_handle, memory);
-
-	return memory;
-}
-
-#define dma_free_coherent(d,s,c,h) dma_free_attrs(d,s,c,h,NULL)
-
-static inline void dma_free_attrs(struct device *dev, size_t size,
-				  void *cpu_addr, dma_addr_t dma_handle,
-				  struct dma_attrs *attrs)
-{
-	struct dma_map_ops *ops = get_dma_ops(dev);
-
-	debug_dma_free_coherent(dev, size, cpu_addr, dma_handle);
-
-	ops->free(dev, size, cpu_addr, dma_handle, attrs);
-}
-
 static inline void *dma_alloc_noncoherent(struct device *dev, size_t size,
 					  dma_addr_t *dma_handle, gfp_t gfp)
 {
diff --git a/arch/powerpc/include/asm/dma-mapping.h b/arch/powerpc/include/asm/dma-mapping.h
index 9103687..846c630 100644
--- a/arch/powerpc/include/asm/dma-mapping.h
+++ b/arch/powerpc/include/asm/dma-mapping.h
@@ -137,39 +137,6 @@ extern int dma_set_mask(struct device *dev, u64 dma_mask);
 extern int __dma_set_mask(struct device *dev, u64 dma_mask);
 extern u64 __dma_get_required_mask(struct device *dev);
 
-#define dma_alloc_coherent(d,s,h,f)	dma_alloc_attrs(d,s,h,f,NULL)
-
-static inline void *dma_alloc_attrs(struct device *dev, size_t size,
-				    dma_addr_t *dma_handle, gfp_t flag,
-				    struct dma_attrs *attrs)
-{
-	struct dma_map_ops *dma_ops = get_dma_ops(dev);
-	void *cpu_addr;
-
-	BUG_ON(!dma_ops);
-
-	cpu_addr = dma_ops->alloc(dev, size, dma_handle, flag, attrs);
-
-	debug_dma_alloc_coherent(dev, size, *dma_handle, cpu_addr);
-
-	return cpu_addr;
-}
-
-#define dma_free_coherent(d,s,c,h) dma_free_attrs(d,s,c,h,NULL)
-
-static inline void dma_free_attrs(struct device *dev, size_t size,
-				  void *cpu_addr, dma_addr_t dma_handle,
-				  struct dma_attrs *attrs)
-{
-	struct dma_map_ops *dma_ops = get_dma_ops(dev);
-
-	BUG_ON(!dma_ops);
-
-	debug_dma_free_coherent(dev, size, cpu_addr, dma_handle);
-
-	dma_ops->free(dev, size, cpu_addr, dma_handle, attrs);
-}
-
 static inline int dma_mapping_error(struct device *dev, dma_addr_t dma_addr)
 {
 	struct dma_map_ops *dma_ops = get_dma_ops(dev);
diff --git a/arch/s390/include/asm/dma-mapping.h b/arch/s390/include/asm/dma-mapping.h
index 9d39596..c29c9c7 100644
--- a/arch/s390/include/asm/dma-mapping.h
+++ b/arch/s390/include/asm/dma-mapping.h
@@ -56,35 +56,4 @@ static inline int dma_mapping_error(struct device *dev, dma_addr_t dma_addr)
 	return dma_addr = DMA_ERROR_CODE;
 }
 
-#define dma_alloc_coherent(d, s, h, f) dma_alloc_attrs(d, s, h, f, NULL)
-
-static inline void *dma_alloc_attrs(struct device *dev, size_t size,
-				    dma_addr_t *dma_handle, gfp_t flags,
-				    struct dma_attrs *attrs)
-{
-	struct dma_map_ops *ops = get_dma_ops(dev);
-	void *cpu_addr;
-
-	BUG_ON(!ops);
-
-	cpu_addr = ops->alloc(dev, size, dma_handle, flags, attrs);
-	debug_dma_alloc_coherent(dev, size, *dma_handle, cpu_addr);
-
-	return cpu_addr;
-}
-
-#define dma_free_coherent(d, s, c, h) dma_free_attrs(d, s, c, h, NULL)
-
-static inline void dma_free_attrs(struct device *dev, size_t size,
-				  void *cpu_addr, dma_addr_t dma_handle,
-				  struct dma_attrs *attrs)
-{
-	struct dma_map_ops *ops = get_dma_ops(dev);
-
-	BUG_ON(!ops);
-
-	debug_dma_free_coherent(dev, size, cpu_addr, dma_handle);
-	ops->free(dev, size, cpu_addr, dma_handle, attrs);
-}
-
 #endif /* _ASM_S390_DMA_MAPPING_H */
diff --git a/arch/sh/include/asm/dma-mapping.h b/arch/sh/include/asm/dma-mapping.h
index b437f2c..3c78059 100644
--- a/arch/sh/include/asm/dma-mapping.h
+++ b/arch/sh/include/asm/dma-mapping.h
@@ -9,7 +9,6 @@ static inline struct dma_map_ops *get_dma_ops(struct device *dev)
 	return dma_ops;
 }
 
-#include <asm-generic/dma-coherent.h>
 #include <asm-generic/dma-mapping-common.h>
 
 static inline int dma_supported(struct device *dev, u64 mask)
@@ -53,42 +52,6 @@ static inline int dma_mapping_error(struct device *dev, dma_addr_t dma_addr)
 	return dma_addr = 0;
 }
 
-#define dma_alloc_coherent(d,s,h,f)	dma_alloc_attrs(d,s,h,f,NULL)
-
-static inline void *dma_alloc_attrs(struct device *dev, size_t size,
-				    dma_addr_t *dma_handle, gfp_t gfp,
-				    struct dma_attrs *attrs)
-{
-	struct dma_map_ops *ops = get_dma_ops(dev);
-	void *memory;
-
-	if (dma_alloc_from_coherent(dev, size, dma_handle, &memory))
-		return memory;
-	if (!ops->alloc)
-		return NULL;
-
-	memory = ops->alloc(dev, size, dma_handle, gfp, attrs);
-	debug_dma_alloc_coherent(dev, size, *dma_handle, memory);
-
-	return memory;
-}
-
-#define dma_free_coherent(d,s,c,h) dma_free_attrs(d,s,c,h,NULL)
-
-static inline void dma_free_attrs(struct device *dev, size_t size,
-				  void *vaddr, dma_addr_t dma_handle,
-				  struct dma_attrs *attrs)
-{
-	struct dma_map_ops *ops = get_dma_ops(dev);
-
-	if (dma_release_from_coherent(dev, get_order(size), vaddr))
-		return;
-
-	debug_dma_free_coherent(dev, size, vaddr, dma_handle);
-	if (ops->free)
-		ops->free(dev, size, vaddr, dma_handle, attrs);
-}
-
 /* arch/sh/mm/consistent.c */
 extern void *dma_generic_alloc_coherent(struct device *dev, size_t size,
 					dma_addr_t *dma_addr, gfp_t flag,
diff --git a/arch/sparc/include/asm/dma-mapping.h b/arch/sparc/include/asm/dma-mapping.h
index 7e064c6..a8c6784 100644
--- a/arch/sparc/include/asm/dma-mapping.h
+++ b/arch/sparc/include/asm/dma-mapping.h
@@ -41,32 +41,6 @@ static inline struct dma_map_ops *get_dma_ops(struct device *dev)
 
 #include <asm-generic/dma-mapping-common.h>
 
-#define dma_alloc_coherent(d,s,h,f)	dma_alloc_attrs(d,s,h,f,NULL)
-
-static inline void *dma_alloc_attrs(struct device *dev, size_t size,
-				    dma_addr_t *dma_handle, gfp_t flag,
-				    struct dma_attrs *attrs)
-{
-	struct dma_map_ops *ops = get_dma_ops(dev);
-	void *cpu_addr;
-
-	cpu_addr = ops->alloc(dev, size, dma_handle, flag, attrs);
-	debug_dma_alloc_coherent(dev, size, *dma_handle, cpu_addr);
-	return cpu_addr;
-}
-
-#define dma_free_coherent(d,s,c,h) dma_free_attrs(d,s,c,h,NULL)
-
-static inline void dma_free_attrs(struct device *dev, size_t size,
-				  void *cpu_addr, dma_addr_t dma_handle,
-				  struct dma_attrs *attrs)
-{
-	struct dma_map_ops *ops = get_dma_ops(dev);
-
-	debug_dma_free_coherent(dev, size, cpu_addr, dma_handle);
-	ops->free(dev, size, cpu_addr, dma_handle, attrs);
-}
-
 static inline int dma_mapping_error(struct device *dev, dma_addr_t dma_addr)
 {
 	debug_dma_mapping_error(dev, dma_addr);
diff --git a/arch/tile/include/asm/dma-mapping.h b/arch/tile/include/asm/dma-mapping.h
index 1eae359..4aba10e 100644
--- a/arch/tile/include/asm/dma-mapping.h
+++ b/arch/tile/include/asm/dma-mapping.h
@@ -116,34 +116,7 @@ dma_set_mask(struct device *dev, u64 mask)
 	return 0;
 }
 
-static inline void *dma_alloc_attrs(struct device *dev, size_t size,
-				    dma_addr_t *dma_handle, gfp_t flag,
-				    struct dma_attrs *attrs)
-{
-	struct dma_map_ops *dma_ops = get_dma_ops(dev);
-	void *cpu_addr;
-
-	cpu_addr = dma_ops->alloc(dev, size, dma_handle, flag, attrs);
-
-	debug_dma_alloc_coherent(dev, size, *dma_handle, cpu_addr);
-
-	return cpu_addr;
-}
-
-static inline void dma_free_attrs(struct device *dev, size_t size,
-				  void *cpu_addr, dma_addr_t dma_handle,
-				  struct dma_attrs *attrs)
-{
-	struct dma_map_ops *dma_ops = get_dma_ops(dev);
-
-	debug_dma_free_coherent(dev, size, cpu_addr, dma_handle);
-
-	dma_ops->free(dev, size, cpu_addr, dma_handle, attrs);
-}
-
-#define dma_alloc_coherent(d, s, h, f) dma_alloc_attrs(d, s, h, f, NULL)
 #define dma_alloc_noncoherent(d, s, h, f) dma_alloc_attrs(d, s, h, f, NULL)
-#define dma_free_coherent(d, s, v, h) dma_free_attrs(d, s, v, h, NULL)
 #define dma_free_noncoherent(d, s, v, h) dma_free_attrs(d, s, v, h, NULL)
 
 /*
diff --git a/arch/unicore32/include/asm/dma-mapping.h b/arch/unicore32/include/asm/dma-mapping.h
index 366460a..5294d03 100644
--- a/arch/unicore32/include/asm/dma-mapping.h
+++ b/arch/unicore32/include/asm/dma-mapping.h
@@ -18,8 +18,6 @@
 #include <linux/scatterlist.h>
 #include <linux/swiotlb.h>
 
-#include <asm-generic/dma-coherent.h>
-
 #include <asm/memory.h>
 #include <asm/cacheflush.h>
 
@@ -82,28 +80,6 @@ static inline int dma_set_mask(struct device *dev, u64 dma_mask)
 	return 0;
 }
 
-#define dma_alloc_coherent(d,s,h,f)	dma_alloc_attrs(d,s,h,f,NULL)
-
-static inline void *dma_alloc_attrs(struct device *dev, size_t size,
-				    dma_addr_t *dma_handle, gfp_t flag,
-				    struct dma_attrs *attrs)
-{
-	struct dma_map_ops *dma_ops = get_dma_ops(dev);
-
-	return dma_ops->alloc(dev, size, dma_handle, flag, attrs);
-}
-
-#define dma_free_coherent(d,s,c,h) dma_free_attrs(d,s,c,h,NULL)
-
-static inline void dma_free_attrs(struct device *dev, size_t size,
-				  void *cpu_addr, dma_addr_t dma_handle,
-				  struct dma_attrs *attrs)
-{
-	struct dma_map_ops *dma_ops = get_dma_ops(dev);
-
-	dma_ops->free(dev, size, cpu_addr, dma_handle, attrs);
-}
-
 #define dma_alloc_noncoherent(d, s, h, f) dma_alloc_coherent(d, s, h, f)
 #define dma_free_noncoherent(d, s, v, h) dma_free_coherent(d, s, v, h)
 
diff --git a/arch/x86/include/asm/dma-mapping.h b/arch/x86/include/asm/dma-mapping.h
index 1f5b728..f9b1b6c 100644
--- a/arch/x86/include/asm/dma-mapping.h
+++ b/arch/x86/include/asm/dma-mapping.h
@@ -12,7 +12,6 @@
 #include <linux/dma-attrs.h>
 #include <asm/io.h>
 #include <asm/swiotlb.h>
-#include <asm-generic/dma-coherent.h>
 #include <linux/dma-contiguous.h>
 
 #ifdef CONFIG_ISA
@@ -41,6 +40,9 @@ static inline struct dma_map_ops *get_dma_ops(struct device *dev)
 #endif
 }
 
+bool arch_dma_alloc_attrs(struct device **dev, gfp_t *gfp);
+#define arch_dma_alloc_attrs arch_dma_alloc_attrs
+
 #include <asm-generic/dma-mapping-common.h>
 
 /* Make sure we keep the same behaviour */
@@ -125,16 +127,4 @@ static inline gfp_t dma_alloc_coherent_gfp_flags(struct device *dev, gfp_t gfp)
        return gfp;
 }
 
-#define dma_alloc_coherent(d,s,h,f)	dma_alloc_attrs(d,s,h,f,NULL)
-
-void *
-dma_alloc_attrs(struct device *dev, size_t size, dma_addr_t *dma_handle,
-		gfp_t gfp, struct dma_attrs *attrs);
-
-#define dma_free_coherent(d,s,c,h) dma_free_attrs(d,s,c,h,NULL)
-
-void dma_free_attrs(struct device *dev, size_t size,
-		    void *vaddr, dma_addr_t bus,
-		    struct dma_attrs *attrs);
-
 #endif
diff --git a/arch/x86/kernel/pci-dma.c b/arch/x86/kernel/pci-dma.c
index 353972c..bd23971 100644
--- a/arch/x86/kernel/pci-dma.c
+++ b/arch/x86/kernel/pci-dma.c
@@ -140,50 +140,19 @@ void dma_generic_free_coherent(struct device *dev, size_t size, void *vaddr,
 		free_pages((unsigned long)vaddr, get_order(size));
 }
 
-void *dma_alloc_attrs(struct device *dev, size_t size, dma_addr_t *dma_handle,
-		      gfp_t gfp, struct dma_attrs *attrs)
+bool arch_dma_alloc_attrs(struct device **dev, gfp_t *gfp)
 {
-	struct dma_map_ops *ops = get_dma_ops(dev);
-	void *memory;
-
-	gfp &= ~(__GFP_DMA | __GFP_HIGHMEM | __GFP_DMA32);
-
-	if (dma_alloc_from_coherent(dev, size, dma_handle, &memory))
-		return memory;
-
-	if (!dev)
-		dev = &x86_dma_fallback_dev;
-
-	if (!is_device_dma_capable(dev))
-		return NULL;
-
-	if (!ops->alloc)
-		return NULL;
-
-	memory = ops->alloc(dev, size, dma_handle,
-			    dma_alloc_coherent_gfp_flags(dev, gfp), attrs);
-	debug_dma_alloc_coherent(dev, size, *dma_handle, memory);
-
-	return memory;
-}
-EXPORT_SYMBOL(dma_alloc_attrs);
-
-void dma_free_attrs(struct device *dev, size_t size,
-		    void *vaddr, dma_addr_t bus,
-		    struct dma_attrs *attrs)
-{
-	struct dma_map_ops *ops = get_dma_ops(dev);
-
-	WARN_ON(irqs_disabled());       /* for portability */
+	*gfp = dma_alloc_coherent_gfp_flags(*dev, *gfp);
+	*gfp &= ~(__GFP_DMA | __GFP_HIGHMEM | __GFP_DMA32);
 
-	if (dma_release_from_coherent(dev, get_order(size), vaddr))
-		return;
+	if (!*dev)
+		*dev = &x86_dma_fallback_dev;
+	if (!is_device_dma_capable(*dev))
+		return false;
+	return true;
 
-	debug_dma_free_coherent(dev, size, vaddr, bus);
-	if (ops->free)
-		ops->free(dev, size, vaddr, bus, attrs);
 }
-EXPORT_SYMBOL(dma_free_attrs);
+EXPORT_SYMBOL(arch_dma_alloc_attrs);
 
 /*
  * See <Documentation/x86/x86_64/boot-options.txt> for the iommu kernel
diff --git a/drivers/xen/swiotlb-xen.c b/drivers/xen/swiotlb-xen.c
index 4c54932..da1029e 100644
--- a/drivers/xen/swiotlb-xen.c
+++ b/drivers/xen/swiotlb-xen.c
@@ -311,9 +311,6 @@ xen_swiotlb_alloc_coherent(struct device *hwdev, size_t size,
 	*/
 	flags &= ~(__GFP_DMA | __GFP_HIGHMEM);
 
-	if (dma_alloc_from_coherent(hwdev, size, dma_handle, &ret))
-		return ret;
-
 	/* On ARM this function returns an ioremap'ped virtual address for
 	 * which virt_to_phys doesn't return the corresponding physical
 	 * address. In fact on ARM virt_to_phys only works for kernel direct
@@ -356,9 +353,6 @@ xen_swiotlb_free_coherent(struct device *hwdev, size_t size, void *vaddr,
 	phys_addr_t phys;
 	u64 dma_mask = DMA_BIT_MASK(32);
 
-	if (dma_release_from_coherent(hwdev, order, vaddr))
-		return;
-
 	if (hwdev && hwdev->coherent_dma_mask)
 		dma_mask = hwdev->coherent_dma_mask;
 
diff --git a/include/asm-generic/dma-mapping-common.h b/include/asm-generic/dma-mapping-common.h
index 940d5ec..56dd9ea 100644
--- a/include/asm-generic/dma-mapping-common.h
+++ b/include/asm-generic/dma-mapping-common.h
@@ -6,6 +6,7 @@
 #include <linux/scatterlist.h>
 #include <linux/dma-debug.h>
 #include <linux/dma-attrs.h>
+#include <asm-generic/dma-coherent.h>
 
 static inline dma_addr_t dma_map_single_attrs(struct device *dev, void *ptr,
 					      size_t size,
@@ -237,4 +238,61 @@ dma_get_sgtable_attrs(struct device *dev, struct sg_table *sgt, void *cpu_addr,
 
 #define dma_get_sgtable(d, t, v, h, s) dma_get_sgtable_attrs(d, t, v, h, s, NULL)
 
+#ifndef arch_dma_alloc_attrs
+#define arch_dma_alloc_attrs(dev, flag)	(true)
+#endif
+
+static inline void *dma_alloc_attrs(struct device *dev, size_t size,
+				       dma_addr_t *dma_handle, gfp_t flag,
+				       struct dma_attrs *attrs)
+{
+	struct dma_map_ops *ops = get_dma_ops(dev);
+	void *cpu_addr;
+
+	BUG_ON(!ops);
+
+	if (dma_alloc_from_coherent(dev, size, dma_handle, &cpu_addr))
+		return cpu_addr;
+
+	if (!arch_dma_alloc_attrs(&dev, &flag))
+		return NULL;
+	if (!ops->alloc)
+		return NULL;
+
+	cpu_addr = ops->alloc(dev, size, dma_handle, flag, attrs);
+	debug_dma_alloc_coherent(dev, size, *dma_handle, cpu_addr);
+	return cpu_addr;
+}
+
+static inline void dma_free_attrs(struct device *dev, size_t size,
+				     void *cpu_addr, dma_addr_t dma_handle,
+				     struct dma_attrs *attrs)
+{
+	struct dma_map_ops *ops = get_dma_ops(dev);
+
+	BUG_ON(!ops);
+	WARN_ON(irqs_disabled());
+
+	if (dma_release_from_coherent(dev, get_order(size), cpu_addr))
+		return;
+
+	if (!ops->free)
+		return;
+
+	debug_dma_free_coherent(dev, size, cpu_addr, dma_handle);
+	ops->free(dev, size, cpu_addr, dma_handle, attrs);
+}
+
+static inline void *dma_alloc_coherent(struct device *dev, size_t size,
+		dma_addr_t *dma_handle, gfp_t flag)
+{
+	return dma_alloc_attrs(dev, size, dma_handle, flag, NULL);
+}
+
+static inline void dma_free_coherent(struct device *dev, size_t size,
+		void *cpu_addr, dma_addr_t dma_handle)
+{
+	return dma_free_attrs(dev, size, cpu_addr, dma_handle, NULL);
+}
+
 #endif
-- 
1.9.1

