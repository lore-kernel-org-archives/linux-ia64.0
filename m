From: Christoph Hellwig <hch@lst.de>
Date: Sun, 27 Aug 2017 16:10:32 +0000
Subject: [PATCH 12/12] dma-mapping: turn dma_cache_sync into a dma_map_ops method
Message-Id: <20170827161032.22772-13-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170827161032.22772-1-hch@lst.de>
In-Reply-To: <20170827161032.22772-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: iommu@lists.linux-foundation.org
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Robin Murphy <robin.murphy@arm.com>, Michal Simek <monstr@monstr.eu>, David Howells <dhowells@redhat.com>, Guan Xuetao <gxt@mprc.pku.edu.cn>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, x86@kernel.org, linux-mips@linux-mips.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-xtensa@linux-xtensa.org, linux-sh@vger.kernel.org, linux-kernel@vger.kernel.org

After we removed all the dead wood it turns out only two architectures
actually implement dma_cache_sync as a no-op: mips and parisc.  Add
a cache_sync method to struct dma_map_ops and implement it for the
mips defualt DMA ops, and the parisc pa11 ops.

Note that arm, arc and openrisc support DMA_ATTR_NON_CONSISTENT, but
never provided a functional dma_cache_sync implementations, which
seems somewhat odd.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/alpha/include/asm/dma-mapping.h      |  2 --
 arch/cris/include/asm/dma-mapping.h       |  6 ------
 arch/frv/include/asm/dma-mapping.h        |  6 ------
 arch/hexagon/include/asm/dma-mapping.h    |  3 ---
 arch/ia64/include/asm/dma-mapping.h       |  6 ------
 arch/m32r/include/asm/dma-mapping.h       |  5 -----
 arch/m68k/include/asm/dma-mapping.h       |  6 ------
 arch/metag/include/asm/dma-mapping.h      | 10 ----------
 arch/microblaze/include/asm/dma-mapping.h |  5 -----
 arch/mips/include/asm/dma-mapping.h       |  3 ---
 arch/mips/mm/dma-default.c                |  7 +++----
 arch/mn10300/include/asm/dma-mapping.h    |  6 ------
 arch/nios2/include/asm/dma-mapping.h      |  9 ---------
 arch/parisc/include/asm/dma-mapping.h     |  8 --------
 arch/parisc/kernel/pci-dma.c              |  8 ++++++++
 arch/powerpc/include/asm/dma-mapping.h    |  5 -----
 arch/s390/include/asm/dma-mapping.h       |  5 -----
 arch/sh/include/asm/dma-mapping.h         |  6 ------
 arch/sparc/include/asm/dma-mapping.h      |  8 --------
 arch/tile/include/asm/dma-mapping.h       |  9 ---------
 arch/unicore32/include/asm/dma-mapping.h  |  5 -----
 arch/x86/include/asm/dma-mapping.h        |  6 ------
 arch/xtensa/include/asm/dma-mapping.h     |  5 -----
 include/linux/dma-mapping.h               | 13 +++++++++++++
 24 files changed, 24 insertions(+), 128 deletions(-)

diff --git a/arch/alpha/include/asm/dma-mapping.h b/arch/alpha/include/asm/dma-mapping.h
index 5d53666935e6..399a4f49355e 100644
--- a/arch/alpha/include/asm/dma-mapping.h
+++ b/arch/alpha/include/asm/dma-mapping.h
@@ -8,6 +8,4 @@ static inline const struct dma_map_ops *get_arch_dma_ops(struct bus_type *bus)
 	return dma_ops;
 }
 
-#define dma_cache_sync(dev, va, size, dir)		  ((void)0)
-
 #endif	/* _ALPHA_DMA_MAPPING_H */
diff --git a/arch/cris/include/asm/dma-mapping.h b/arch/cris/include/asm/dma-mapping.h
index 256169de3743..e30adde42beb 100644
--- a/arch/cris/include/asm/dma-mapping.h
+++ b/arch/cris/include/asm/dma-mapping.h
@@ -16,10 +16,4 @@ static inline const struct dma_map_ops *get_arch_dma_ops(struct bus_type *bus)
 }
 #endif
 
-static inline void
-dma_cache_sync(struct device *dev, void *vaddr, size_t size,
-	       enum dma_data_direction direction)
-{
-}
-
 #endif
diff --git a/arch/frv/include/asm/dma-mapping.h b/arch/frv/include/asm/dma-mapping.h
index da0e5c9744c4..da24ae943f02 100644
--- a/arch/frv/include/asm/dma-mapping.h
+++ b/arch/frv/include/asm/dma-mapping.h
@@ -14,10 +14,4 @@ static inline const struct dma_map_ops *get_arch_dma_ops(struct bus_type *bus)
 	return &frv_dma_ops;
 }
 
-static inline
-void dma_cache_sync(struct device *dev, void *vaddr, size_t size,
-		    enum dma_data_direction direction)
-{
-}
-
 #endif  /* _ASM_DMA_MAPPING_H */
diff --git a/arch/hexagon/include/asm/dma-mapping.h b/arch/hexagon/include/asm/dma-mapping.h
index 463dbc18f853..5208de242e79 100644
--- a/arch/hexagon/include/asm/dma-mapping.h
+++ b/arch/hexagon/include/asm/dma-mapping.h
@@ -37,9 +37,6 @@ static inline const struct dma_map_ops *get_arch_dma_ops(struct bus_type *bus)
 	return dma_ops;
 }
 
-extern void dma_cache_sync(struct device *dev, void *vaddr, size_t size,
-			   enum dma_data_direction direction);
-
 static inline bool dma_capable(struct device *dev, dma_addr_t addr, size_t size)
 {
 	if (!dev->dma_mask)
diff --git a/arch/ia64/include/asm/dma-mapping.h b/arch/ia64/include/asm/dma-mapping.h
index 99dfc1aa9d3c..9e5b5df76ff8 100644
--- a/arch/ia64/include/asm/dma-mapping.h
+++ b/arch/ia64/include/asm/dma-mapping.h
@@ -44,10 +44,4 @@ static inline phys_addr_t dma_to_phys(struct device *dev, dma_addr_t daddr)
 	return daddr;
 }
 
-static inline void
-dma_cache_sync (struct device *dev, void *vaddr, size_t size,
-	enum dma_data_direction dir)
-{
-}
-
 #endif /* _ASM_IA64_DMA_MAPPING_H */
diff --git a/arch/m32r/include/asm/dma-mapping.h b/arch/m32r/include/asm/dma-mapping.h
index aff3ae8b62f7..9e993daed7a0 100644
--- a/arch/m32r/include/asm/dma-mapping.h
+++ b/arch/m32r/include/asm/dma-mapping.h
@@ -13,11 +13,6 @@ static inline const struct dma_map_ops *get_arch_dma_ops(struct bus_type *bus)
 	return &dma_noop_ops;
 }
 
-static inline void dma_cache_sync(struct device *dev, void *vaddr, size_t size,
-				  enum dma_data_direction direction)
-{
-}
-
 static inline bool dma_capable(struct device *dev, dma_addr_t addr, size_t size)
 {
 	if (!dev->dma_mask)
diff --git a/arch/m68k/include/asm/dma-mapping.h b/arch/m68k/include/asm/dma-mapping.h
index 9210e470771b..9a0d559fcc13 100644
--- a/arch/m68k/include/asm/dma-mapping.h
+++ b/arch/m68k/include/asm/dma-mapping.h
@@ -8,10 +8,4 @@ static inline const struct dma_map_ops *get_arch_dma_ops(struct bus_type *bus)
         return &m68k_dma_ops;
 }
 
-static inline void dma_cache_sync(struct device *dev, void *vaddr, size_t size,
-				  enum dma_data_direction dir)
-{
-	/* we use coherent allocation, so not much to do here. */
-}
-
 #endif  /* _M68K_DMA_MAPPING_H */
diff --git a/arch/metag/include/asm/dma-mapping.h b/arch/metag/include/asm/dma-mapping.h
index ea573be2b6d0..340265dcf839 100644
--- a/arch/metag/include/asm/dma-mapping.h
+++ b/arch/metag/include/asm/dma-mapping.h
@@ -8,14 +8,4 @@ static inline const struct dma_map_ops *get_arch_dma_ops(struct bus_type *bus)
 	return &metag_dma_ops;
 }
 
-/*
- * dma_alloc_attrs() always returns non-cacheable memory, so there's no need to
- * do any flushing here.
- */
-static inline void
-dma_cache_sync(struct device *dev, void *vaddr, size_t size,
-	       enum dma_data_direction direction)
-{
-}
-
 #endif
diff --git a/arch/microblaze/include/asm/dma-mapping.h b/arch/microblaze/include/asm/dma-mapping.h
index ad448e4aedb6..6b9ea39405b8 100644
--- a/arch/microblaze/include/asm/dma-mapping.h
+++ b/arch/microblaze/include/asm/dma-mapping.h
@@ -25,9 +25,4 @@ static inline const struct dma_map_ops *get_arch_dma_ops(struct bus_type *bus)
 	return &dma_direct_ops;
 }
 
-static inline void dma_cache_sync(struct device *dev, void *vaddr, size_t size,
-		enum dma_data_direction direction)
-{
-}
-
 #endif	/* _ASM_MICROBLAZE_DMA_MAPPING_H */
diff --git a/arch/mips/include/asm/dma-mapping.h b/arch/mips/include/asm/dma-mapping.h
index aba71385f9d1..6ea1439430a2 100644
--- a/arch/mips/include/asm/dma-mapping.h
+++ b/arch/mips/include/asm/dma-mapping.h
@@ -26,9 +26,6 @@ static inline bool dma_capable(struct device *dev, dma_addr_t addr, size_t size)
 
 static inline void dma_mark_clean(void *addr, size_t size) {}
 
-extern void dma_cache_sync(struct device *dev, void *vaddr, size_t size,
-	       enum dma_data_direction direction);
-
 #define arch_setup_dma_ops arch_setup_dma_ops
 static inline void arch_setup_dma_ops(struct device *dev, u64 dma_base,
 				      u64 size, const struct iommu_ops *iommu,
diff --git a/arch/mips/mm/dma-default.c b/arch/mips/mm/dma-default.c
index 8e78251eccc2..e69073f32a71 100644
--- a/arch/mips/mm/dma-default.c
+++ b/arch/mips/mm/dma-default.c
@@ -419,7 +419,7 @@ int mips_dma_supported(struct device *dev, u64 mask)
 	return plat_dma_supported(dev, mask);
 }
 
-void dma_cache_sync(struct device *dev, void *vaddr, size_t size,
+static void mips_dma_cache_sync(struct device *dev, void *vaddr, size_t size,
 			 enum dma_data_direction direction)
 {
 	BUG_ON(direction = DMA_NONE);
@@ -428,8 +428,6 @@ void dma_cache_sync(struct device *dev, void *vaddr, size_t size,
 		__dma_sync_virtual(vaddr, size, direction);
 }
 
-EXPORT_SYMBOL(dma_cache_sync);
-
 static const struct dma_map_ops mips_default_dma_map_ops = {
 	.alloc = mips_dma_alloc_coherent,
 	.free = mips_dma_free_coherent,
@@ -443,7 +441,8 @@ static const struct dma_map_ops mips_default_dma_map_ops = {
 	.sync_sg_for_cpu = mips_dma_sync_sg_for_cpu,
 	.sync_sg_for_device = mips_dma_sync_sg_for_device,
 	.mapping_error = mips_dma_mapping_error,
-	.dma_supported = mips_dma_supported
+	.dma_supported = mips_dma_supported,
+	.cache_sync = mips_dma_cache_sync,
 };
 
 const struct dma_map_ops *mips_dma_map_ops = &mips_default_dma_map_ops;
diff --git a/arch/mn10300/include/asm/dma-mapping.h b/arch/mn10300/include/asm/dma-mapping.h
index dc24163b190f..439e474ed6d7 100644
--- a/arch/mn10300/include/asm/dma-mapping.h
+++ b/arch/mn10300/include/asm/dma-mapping.h
@@ -18,10 +18,4 @@ static inline const struct dma_map_ops *get_arch_dma_ops(struct bus_type *bus)
 	return &mn10300_dma_ops;
 }
 
-static inline
-void dma_cache_sync(void *vaddr, size_t size,
-		    enum dma_data_direction direction)
-{
-}
-
 #endif
diff --git a/arch/nios2/include/asm/dma-mapping.h b/arch/nios2/include/asm/dma-mapping.h
index f8dc62222741..6ceb92251da0 100644
--- a/arch/nios2/include/asm/dma-mapping.h
+++ b/arch/nios2/include/asm/dma-mapping.h
@@ -17,13 +17,4 @@ static inline const struct dma_map_ops *get_arch_dma_ops(struct bus_type *bus)
 	return &nios2_dma_ops;
 }
 
-/*
- * dma_alloc_attrs() always returns non-cacheable memory, so there's no need to
- * do any flushing here.
- */
-static inline void dma_cache_sync(struct device *dev, void *vaddr, size_t size,
-				  enum dma_data_direction direction)
-{
-}
-
 #endif /* _ASM_NIOS2_DMA_MAPPING_H */
diff --git a/arch/parisc/include/asm/dma-mapping.h b/arch/parisc/include/asm/dma-mapping.h
index 2b16282add69..cb26bbd71d8a 100644
--- a/arch/parisc/include/asm/dma-mapping.h
+++ b/arch/parisc/include/asm/dma-mapping.h
@@ -32,14 +32,6 @@ static inline const struct dma_map_ops *get_arch_dma_ops(struct bus_type *bus)
 	return hppa_dma_ops;
 }
 
-static inline void
-dma_cache_sync(struct device *dev, void *vaddr, size_t size,
-	       enum dma_data_direction direction)
-{
-	if (hppa_dma_ops->sync_single_for_cpu)
-		flush_kernel_dcache_range((unsigned long)vaddr, size);
-}
-
 static inline void *
 parisc_walk_tree(struct device *dev)
 {
diff --git a/arch/parisc/kernel/pci-dma.c b/arch/parisc/kernel/pci-dma.c
index 5f0067a62738..ee43e9f73ad3 100644
--- a/arch/parisc/kernel/pci-dma.c
+++ b/arch/parisc/kernel/pci-dma.c
@@ -572,6 +572,12 @@ static void pa11_dma_sync_sg_for_device(struct device *dev, struct scatterlist *
 		flush_kernel_vmap_range(sg_virt(sg), sg->length);
 }
 
+static void pa11_dma_cache_sync(struct device *dev, void *vaddr, size_t size,
+	       enum dma_data_direction direction)
+{
+	flush_kernel_dcache_range((unsigned long)vaddr, size);
+}
+
 const struct dma_map_ops pcxl_dma_ops = {
 	.dma_supported =	pa11_dma_supported,
 	.alloc =		pa11_dma_alloc,
@@ -584,6 +590,7 @@ const struct dma_map_ops pcxl_dma_ops = {
 	.sync_single_for_device = pa11_dma_sync_single_for_device,
 	.sync_sg_for_cpu =	pa11_dma_sync_sg_for_cpu,
 	.sync_sg_for_device =	pa11_dma_sync_sg_for_device,
+	.cache_sync =		pa11_dma_cache_sync,
 };
 
 static void *pcx_dma_alloc(struct device *dev, size_t size,
@@ -620,4 +627,5 @@ const struct dma_map_ops pcx_dma_ops = {
 	.sync_single_for_device = pa11_dma_sync_single_for_device,
 	.sync_sg_for_cpu =	pa11_dma_sync_sg_for_cpu,
 	.sync_sg_for_device =	pa11_dma_sync_sg_for_device,
+	.cache_sync =		pa11_dma_cache_sync,
 };
diff --git a/arch/powerpc/include/asm/dma-mapping.h b/arch/powerpc/include/asm/dma-mapping.h
index 320846442bfb..2e43c2ef7632 100644
--- a/arch/powerpc/include/asm/dma-mapping.h
+++ b/arch/powerpc/include/asm/dma-mapping.h
@@ -141,10 +141,5 @@ static inline phys_addr_t dma_to_phys(struct device *dev, dma_addr_t daddr)
 
 #define ARCH_HAS_DMA_MMAP_COHERENT
 
-static inline void dma_cache_sync(struct device *dev, void *vaddr, size_t size,
-		enum dma_data_direction direction)
-{
-}
-
 #endif /* __KERNEL__ */
 #endif	/* _ASM_DMA_MAPPING_H */
diff --git a/arch/s390/include/asm/dma-mapping.h b/arch/s390/include/asm/dma-mapping.h
index 512ad0eaa11a..b17304b13de5 100644
--- a/arch/s390/include/asm/dma-mapping.h
+++ b/arch/s390/include/asm/dma-mapping.h
@@ -15,11 +15,6 @@ static inline const struct dma_map_ops *get_arch_dma_ops(struct bus_type *bus)
 	return &dma_noop_ops;
 }
 
-static inline void dma_cache_sync(struct device *dev, void *vaddr, size_t size,
-				  enum dma_data_direction direction)
-{
-}
-
 static inline bool dma_capable(struct device *dev, dma_addr_t addr, size_t size)
 {
 	if (!dev->dma_mask)
diff --git a/arch/sh/include/asm/dma-mapping.h b/arch/sh/include/asm/dma-mapping.h
index b46194ecef17..e89df111c017 100644
--- a/arch/sh/include/asm/dma-mapping.h
+++ b/arch/sh/include/asm/dma-mapping.h
@@ -9,12 +9,6 @@ static inline const struct dma_map_ops *get_arch_dma_ops(struct bus_type *bus)
 	return dma_ops;
 }
 
-static inline void dma_cache_sync(struct device *dev, void *vaddr, size_t size,
-		    enum dma_data_direction dir)
-{
-}
-
-/* arch/sh/mm/consistent.c */
 extern void *dma_generic_alloc_coherent(struct device *dev, size_t size,
 					dma_addr_t *dma_addr, gfp_t flag,
 					unsigned long attrs);
diff --git a/arch/sparc/include/asm/dma-mapping.h b/arch/sparc/include/asm/dma-mapping.h
index 60bf1633d554..b298ed45cb23 100644
--- a/arch/sparc/include/asm/dma-mapping.h
+++ b/arch/sparc/include/asm/dma-mapping.h
@@ -5,14 +5,6 @@
 #include <linux/mm.h>
 #include <linux/dma-debug.h>
 
-static inline void dma_cache_sync(struct device *dev, void *vaddr, size_t size,
-				  enum dma_data_direction dir)
-{
-	/* Since dma_{alloc,free}_noncoherent() allocated coherent memory, this
-	 * routine can be a nop.
-	 */
-}
-
 extern const struct dma_map_ops *dma_ops;
 extern const struct dma_map_ops pci32_dma_ops;
 
diff --git a/arch/tile/include/asm/dma-mapping.h b/arch/tile/include/asm/dma-mapping.h
index 7061dc8af43a..97ad62878290 100644
--- a/arch/tile/include/asm/dma-mapping.h
+++ b/arch/tile/include/asm/dma-mapping.h
@@ -67,13 +67,4 @@ static inline bool dma_capable(struct device *dev, dma_addr_t addr, size_t size)
 #define HAVE_ARCH_DMA_SET_MASK 1
 int dma_set_mask(struct device *dev, u64 mask);
 
-/*
- * dma_alloc_attrs() always returns non-cacheable memory, so there's no need to
- * do any flushing here.
- */
-static inline void dma_cache_sync(struct device *dev, void *vaddr, size_t size,
-				  enum dma_data_direction direction)
-{
-}
-
 #endif /* _ASM_TILE_DMA_MAPPING_H */
diff --git a/arch/unicore32/include/asm/dma-mapping.h b/arch/unicore32/include/asm/dma-mapping.h
index e949855bb794..ac608c2f6af6 100644
--- a/arch/unicore32/include/asm/dma-mapping.h
+++ b/arch/unicore32/include/asm/dma-mapping.h
@@ -45,10 +45,5 @@ static inline phys_addr_t dma_to_phys(struct device *dev, dma_addr_t daddr)
 
 static inline void dma_mark_clean(void *addr, size_t size) {}
 
-static inline void dma_cache_sync(struct device *dev, void *vaddr,
-		size_t size, enum dma_data_direction direction)
-{
-}
-
 #endif /* __KERNEL__ */
 #endif
diff --git a/arch/x86/include/asm/dma-mapping.h b/arch/x86/include/asm/dma-mapping.h
index 04877267ad18..cdc1ab17eb62 100644
--- a/arch/x86/include/asm/dma-mapping.h
+++ b/arch/x86/include/asm/dma-mapping.h
@@ -66,12 +66,6 @@ static inline phys_addr_t dma_to_phys(struct device *dev, dma_addr_t daddr)
 }
 #endif /* CONFIG_X86_DMA_REMAP */
 
-static inline void
-dma_cache_sync(struct device *dev, void *vaddr, size_t size,
-	enum dma_data_direction dir)
-{
-}
-
 static inline unsigned long dma_alloc_coherent_mask(struct device *dev,
 						    gfp_t gfp)
 {
diff --git a/arch/xtensa/include/asm/dma-mapping.h b/arch/xtensa/include/asm/dma-mapping.h
index 353e0314d6ba..153bf2370988 100644
--- a/arch/xtensa/include/asm/dma-mapping.h
+++ b/arch/xtensa/include/asm/dma-mapping.h
@@ -23,11 +23,6 @@ static inline const struct dma_map_ops *get_arch_dma_ops(struct bus_type *bus)
 	return &xtensa_dma_map_ops;
 }
 
-static inline void dma_cache_sync(struct device *dev, void *vaddr, size_t size,
-		    enum dma_data_direction direction)
-{
-}
-
 static inline dma_addr_t phys_to_dma(struct device *dev, phys_addr_t paddr)
 {
 	return (dma_addr_t)paddr;
diff --git a/include/linux/dma-mapping.h b/include/linux/dma-mapping.h
index 4c98cc96971f..ca73ba27ae79 100644
--- a/include/linux/dma-mapping.h
+++ b/include/linux/dma-mapping.h
@@ -125,6 +125,8 @@ struct dma_map_ops {
 	void (*sync_sg_for_device)(struct device *dev,
 				   struct scatterlist *sg, int nents,
 				   enum dma_data_direction dir);
+	void (*cache_sync)(struct device *dev, void *vaddr, size_t size,
+			enum dma_data_direction direction);
 	int (*mapping_error)(struct device *dev, dma_addr_t dma_addr);
 	int (*dma_supported)(struct device *dev, u64 mask);
 #ifdef ARCH_HAS_DMA_GET_REQUIRED_MASK
@@ -435,6 +437,17 @@ dma_sync_sg_for_device(struct device *dev, struct scatterlist *sg,
 #define dma_map_page(d, p, o, s, r) dma_map_page_attrs(d, p, o, s, r, 0)
 #define dma_unmap_page(d, a, s, r) dma_unmap_page_attrs(d, a, s, r, 0)
 
+static inline void
+dma_cache_sync(struct device *dev, void *vaddr, size_t size,
+		enum dma_data_direction dir)
+{
+	const struct dma_map_ops *ops = get_dma_ops(dev);
+
+	BUG_ON(!valid_dma_direction(dir));
+	if (ops->cache_sync)
+		ops->cache_sync(dev, vaddr, size, dir);
+}
+
 extern int dma_common_mmap(struct device *dev, struct vm_area_struct *vma,
 			   void *cpu_addr, dma_addr_t dma_addr, size_t size);
 
-- 
2.11.0

