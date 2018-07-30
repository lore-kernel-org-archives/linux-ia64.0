From: Christoph Hellwig <hch@lst.de>
Date: Mon, 30 Jul 2018 16:38:22 +0000
Subject: [PATCH 18/20] powerpc/dma-noncoherent: use generic dma_noncoherent_ops
Message-Id: <20180730163824.10064-19-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180730163824.10064-1-hch@lst.de>
In-Reply-To: <20180730163824.10064-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Robin Murphy <robin.murphy@arm.com>, linuxppc-dev@lists.ozlabs.org, iommu@lists.linux-foundation.org, linux-ia64@vger.kernel.org

The generic dma-noncoherent code provides all that is needed by powerpc.

Note that the cache maintainance in the existing code is a bit odd
as it implements both the sync_to_device and sync_to_cpu callouts,
but never flushes caches when unmapping.  This patch keeps both
directions arounds, which will lead to more flushing than the previous
implementation.  Someone more familar with the required CPUs should
eventually take a look and optimize the cache flush handling if needed.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/powerpc/Kconfig                   |  2 +-
 arch/powerpc/include/asm/dma-mapping.h | 29 -------------
 arch/powerpc/kernel/dma.c              | 59 +++-----------------------
 arch/powerpc/kernel/pci-common.c       |  5 ++-
 arch/powerpc/kernel/setup-common.c     |  4 ++
 arch/powerpc/mm/dma-noncoherent.c      | 52 +++++++++++++++++------
 arch/powerpc/platforms/44x/warp.c      |  2 +-
 arch/powerpc/platforms/Kconfig.cputype |  6 ++-
 8 files changed, 60 insertions(+), 99 deletions(-)

diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
index bbfa6a8df4da..33c6017ffce6 100644
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -129,7 +129,7 @@ config PPC
 	# Please keep this list sorted alphabetically.
 	#
 	select ARCH_HAS_DEVMEM_IS_ALLOWED
-	select ARCH_HAS_DMA_SET_COHERENT_MASK
+	select ARCH_HAS_DMA_SET_COHERENT_MASK if !NOT_COHERENT_CACHE
 	select ARCH_HAS_ELF_RANDOMIZE
 	select ARCH_HAS_FORTIFY_SOURCE
 	select ARCH_HAS_GCOV_PROFILE_ALL
diff --git a/arch/powerpc/include/asm/dma-mapping.h b/arch/powerpc/include/asm/dma-mapping.h
index f0bf7ac2686c..879c4efba785 100644
--- a/arch/powerpc/include/asm/dma-mapping.h
+++ b/arch/powerpc/include/asm/dma-mapping.h
@@ -19,40 +19,11 @@
 #include <asm/swiotlb.h>
 
 /* Some dma direct funcs must be visible for use in other dma_ops */
-extern void *__dma_nommu_alloc_coherent(struct device *dev, size_t size,
-					 dma_addr_t *dma_handle, gfp_t flag,
-					 unsigned long attrs);
-extern void __dma_nommu_free_coherent(struct device *dev, size_t size,
-				       void *vaddr, dma_addr_t dma_handle,
-				       unsigned long attrs);
 extern int dma_nommu_mmap_coherent(struct device *dev,
 				    struct vm_area_struct *vma,
 				    void *cpu_addr, dma_addr_t handle,
 				    size_t size, unsigned long attrs);
 
-#ifdef CONFIG_NOT_COHERENT_CACHE
-/*
- * DMA-consistent mapping functions for PowerPCs that don't support
- * cache snooping.  These allocate/free a region of uncached mapped
- * memory space for use with DMA devices.  Alternatively, you could
- * allocate the space "normally" and use the cache management functions
- * to ensure it is consistent.
- */
-struct device;
-extern void __dma_sync(void *vaddr, size_t size, int direction);
-extern void __dma_sync_page(struct page *page, unsigned long offset,
-				 size_t size, int direction);
-extern unsigned long __dma_get_coherent_pfn(unsigned long cpu_addr);
-
-#else /* ! CONFIG_NOT_COHERENT_CACHE */
-/*
- * Cache coherent cores.
- */
-
-#define __dma_sync(addr, size, rw)		((void)0)
-#define __dma_sync_page(pg, off, sz, rw)	((void)0)
-
-#endif /* ! CONFIG_NOT_COHERENT_CACHE */
 
 static inline unsigned long device_to_mask(struct device *dev)
 {
diff --git a/arch/powerpc/kernel/dma.c b/arch/powerpc/kernel/dma.c
index 2b90a403cdac..b2e88075b2ea 100644
--- a/arch/powerpc/kernel/dma.c
+++ b/arch/powerpc/kernel/dma.c
@@ -36,12 +36,7 @@ static void *dma_nommu_alloc_coherent(struct device *dev, size_t size,
 	 * we can really use the direct ops
 	 */
 	if (dma_direct_supported(dev, dev->coherent_dma_mask))
-#ifdef CONFIG_NOT_COHERENT_CACHE
-		return __dma_nommu_alloc_coherent(dev, size, dma_handle,
-						   flag, attrs);
-#else
 		return dma_direct_alloc(dev, size, dma_handle, flag, attrs);
-#endif
 
 	/* Ok we can't ... do we have an iommu ? If not, fail */
 	iommu = get_iommu_table_base(dev);
@@ -62,12 +57,7 @@ static void dma_nommu_free_coherent(struct device *dev, size_t size,
 
 	/* See comments in dma_nommu_alloc_coherent() */
 	if (dma_direct_supported(dev, dev->coherent_dma_mask))
-#ifdef CONFIG_NOT_COHERENT_CACHE
-		return __dma_nommu_free_coherent(dev, size, vaddr, dma_handle,
-						  attrs);
-#else
 		return dma_direct_free(dev, size, vaddr, dma_handle, attrs);
-#endif
 
 	/* Maybe we used an iommu ... */
 	iommu = get_iommu_table_base(dev);
@@ -84,14 +74,8 @@ int dma_nommu_mmap_coherent(struct device *dev, struct vm_area_struct *vma,
 			     void *cpu_addr, dma_addr_t handle, size_t size,
 			     unsigned long attrs)
 {
-	unsigned long pfn;
+	unsigned long pfn = page_to_pfn(virt_to_page(cpu_addr));
 
-#ifdef CONFIG_NOT_COHERENT_CACHE
-	vma->vm_page_prot = pgprot_noncached(vma->vm_page_prot);
-	pfn = __dma_get_coherent_pfn((unsigned long)cpu_addr);
-#else
-	pfn = page_to_pfn(virt_to_page(cpu_addr));
-#endif
 	return remap_pfn_range(vma, vma->vm_start,
 			       pfn + vma->vm_pgoff,
 			       vma->vm_end - vma->vm_start,
@@ -108,17 +92,13 @@ static int dma_nommu_map_sg(struct device *dev, struct scatterlist *sgl,
 	for_each_sg(sgl, sg, nents, i) {
 		sg->dma_address = phys_to_dma(dev, sg_phys(sg));
 		sg->dma_length = sg->length;
-
-		if (attrs & DMA_ATTR_SKIP_CPU_SYNC)
-			continue;
-
-		__dma_sync_page(sg_page(sg), sg->offset, sg->length, direction);
 	}
 
 	return nents;
 }
 
-static u64 dma_nommu_get_required_mask(struct device *dev)
+/* note: needs to be called arch_get_required_mask for dma-noncoherent.c */
+u64 arch_get_required_mask(struct device *dev)
 {
 	u64 end, mask;
 
@@ -137,32 +117,9 @@ static inline dma_addr_t dma_nommu_map_page(struct device *dev,
 					     enum dma_data_direction dir,
 					     unsigned long attrs)
 {
-	if (!(attrs & DMA_ATTR_SKIP_CPU_SYNC))
-		__dma_sync_page(page, offset, size, dir);
-
 	return phys_to_dma(dev, page_to_phys(page)) + offset;
 }
 
-#ifdef CONFIG_NOT_COHERENT_CACHE
-static inline void dma_nommu_sync_sg(struct device *dev,
-		struct scatterlist *sgl, int nents,
-		enum dma_data_direction direction)
-{
-	struct scatterlist *sg;
-	int i;
-
-	for_each_sg(sgl, sg, nents, i)
-		__dma_sync_page(sg_page(sg), sg->offset, sg->length, direction);
-}
-
-static inline void dma_nommu_sync_single(struct device *dev,
-					  dma_addr_t dma_handle, size_t size,
-					  enum dma_data_direction direction)
-{
-	__dma_sync(bus_to_virt(dma_handle), size, direction);
-}
-#endif
-
 const struct dma_map_ops dma_nommu_ops = {
 	.alloc				= dma_nommu_alloc_coherent,
 	.free				= dma_nommu_free_coherent,
@@ -170,15 +127,10 @@ const struct dma_map_ops dma_nommu_ops = {
 	.map_sg				= dma_nommu_map_sg,
 	.dma_supported			= dma_direct_supported,
 	.map_page			= dma_nommu_map_page,
-	.get_required_mask		= dma_nommu_get_required_mask,
-#ifdef CONFIG_NOT_COHERENT_CACHE
-	.sync_single_for_cpu 		= dma_nommu_sync_single,
-	.sync_single_for_device 	= dma_nommu_sync_single,
-	.sync_sg_for_cpu 		= dma_nommu_sync_sg,
-	.sync_sg_for_device 		= dma_nommu_sync_sg,
-#endif
+	.get_required_mask		= arch_get_required_mask,
 };
 
+#ifndef CONFIG_NOT_COHERENT_CACHE
 int dma_set_coherent_mask(struct device *dev, u64 mask)
 {
 	if (!dma_supported(dev, mask)) {
@@ -197,6 +149,7 @@ int dma_set_coherent_mask(struct device *dev, u64 mask)
 	return 0;
 }
 EXPORT_SYMBOL(dma_set_coherent_mask);
+#endif
 
 int dma_set_mask(struct device *dev, u64 dma_mask)
 {
diff --git a/arch/powerpc/kernel/pci-common.c b/arch/powerpc/kernel/pci-common.c
index fe9733ffffaa..898ffb636b75 100644
--- a/arch/powerpc/kernel/pci-common.c
+++ b/arch/powerpc/kernel/pci-common.c
@@ -59,8 +59,11 @@ static DECLARE_BITMAP(phb_bitmap, MAX_PHBS);
 resource_size_t isa_mem_base;
 EXPORT_SYMBOL(isa_mem_base);
 
-
+#ifdef CONFIG_NOT_COHERENT_CACHE
+static const struct dma_map_ops *pci_dma_ops = &dma_noncoherent_ops;
+#else
 static const struct dma_map_ops *pci_dma_ops = &dma_nommu_ops;
+#endif
 
 void set_pci_dma_ops(const struct dma_map_ops *dma_ops)
 {
diff --git a/arch/powerpc/kernel/setup-common.c b/arch/powerpc/kernel/setup-common.c
index 40b44bb53a4e..2488826fa543 100644
--- a/arch/powerpc/kernel/setup-common.c
+++ b/arch/powerpc/kernel/setup-common.c
@@ -792,7 +792,11 @@ void arch_setup_pdev_archdata(struct platform_device *pdev)
 {
 	pdev->archdata.dma_mask = DMA_BIT_MASK(32);
 	pdev->dev.dma_mask = &pdev->archdata.dma_mask;
+#ifdef CONFIG_NOT_COHERENT_CACHE
+	set_dma_ops(&pdev->dev, &dma_noncoherent_ops);
+#else
  	set_dma_ops(&pdev->dev, &dma_nommu_ops);
+#endif
 }
 
 static __init void print_system_info(void)
diff --git a/arch/powerpc/mm/dma-noncoherent.c b/arch/powerpc/mm/dma-noncoherent.c
index cfc48a253707..1ceea32c0112 100644
--- a/arch/powerpc/mm/dma-noncoherent.c
+++ b/arch/powerpc/mm/dma-noncoherent.c
@@ -30,6 +30,7 @@
 #include <linux/types.h>
 #include <linux/highmem.h>
 #include <linux/dma-direct.h>
+#include <linux/dma-noncoherent.h>
 #include <linux/export.h>
 
 #include <asm/tlbflush.h>
@@ -151,8 +152,8 @@ static struct ppc_vm_region *ppc_vm_region_find(struct ppc_vm_region *head, unsi
  * Allocate DMA-coherent memory space and return both the kernel remapped
  * virtual and bus address for that space.
  */
-void *__dma_nommu_alloc_coherent(struct device *dev, size_t size,
-		dma_addr_t *dma_handle, gfp_t gfp, unsigned long attrs)
+void *arch_dma_alloc(struct device *dev, size_t size, dma_addr_t *dma_handle,
+		gfp_t gfp, unsigned long attrs)
 {
 	struct page *page;
 	struct ppc_vm_region *c;
@@ -253,7 +254,7 @@ void *__dma_nommu_alloc_coherent(struct device *dev, size_t size,
 /*
  * free a page as defined by the above mapping.
  */
-void __dma_nommu_free_coherent(struct device *dev, size_t size, void *vaddr,
+void arch_dma_free(struct device *dev, size_t size, void *vaddr,
 		dma_addr_t dma_handle, unsigned long attrs)
 {
 	struct ppc_vm_region *c;
@@ -313,7 +314,7 @@ void __dma_nommu_free_coherent(struct device *dev, size_t size, void *vaddr,
 /*
  * make an area consistent.
  */
-void __dma_sync(void *vaddr, size_t size, int direction)
+static void __dma_sync(void *vaddr, size_t size, int direction)
 {
 	unsigned long start = (unsigned long)vaddr;
 	unsigned long end   = start + size;
@@ -339,7 +340,6 @@ void __dma_sync(void *vaddr, size_t size, int direction)
 		break;
 	}
 }
-EXPORT_SYMBOL(__dma_sync);
 
 #ifdef CONFIG_HIGHMEM
 /*
@@ -382,23 +382,36 @@ static inline void __dma_sync_page_highmem(struct page *page,
  * __dma_sync_page makes memory consistent. identical to __dma_sync, but
  * takes a struct page instead of a virtual address
  */
-void __dma_sync_page(struct page *page, unsigned long offset,
-	size_t size, int direction)
+static void __dma_sync_page(phys_addr_t paddr, size_t size, int dir)
 {
+	struct page *page = pfn_to_page(paddr >> PAGE_SHIFT);
+	unsigned offset = paddr & ~PAGE_MASK;
+
 #ifdef CONFIG_HIGHMEM
-	__dma_sync_page_highmem(page, offset, size, direction);
+	__dma_sync_page_highmem(page, offset, size, dir);
 #else
 	unsigned long start = (unsigned long)page_address(page) + offset;
-	__dma_sync((void *)start, size, direction);
+	__dma_sync((void *)start, size, dir);
 #endif
 }
-EXPORT_SYMBOL(__dma_sync_page);
+
+void arch_sync_dma_for_device(struct device *dev, phys_addr_t paddr,
+		size_t size, enum dma_data_direction dir)
+{
+	__dma_sync_page(paddr, size, dir);
+}
+
+void arch_sync_dma_for_cpu(struct device *dev, phys_addr_t paddr,
+		size_t size, enum dma_data_direction dir)
+{
+	__dma_sync_page(paddr, size, dir);
+}
 
 /*
- * Return the PFN for a given cpu virtual address returned by
- * __dma_nommu_alloc_coherent. This is used by dma_mmap_coherent()
+ * Return the PFN for a given cpu virtual address returned by __arch_dma_alloc.
+ * This is used by dma_mmap_coherent()
  */
-unsigned long __dma_get_coherent_pfn(unsigned long cpu_addr)
+static unsigned long __dma_get_coherent_pfn(unsigned long cpu_addr)
 {
 	/* This should always be populated, so we don't test every
 	 * level. If that fails, we'll have a nice crash which
@@ -413,3 +426,16 @@ unsigned long __dma_get_coherent_pfn(unsigned long cpu_addr)
 		return 0;
 	return pte_pfn(*ptep);
 }
+
+int arch_dma_mmap(struct device *dev, struct vm_area_struct *vma,
+			     void *cpu_addr, dma_addr_t handle, size_t size,
+			     unsigned long attrs)
+{
+	unsigned long pfn = __dma_get_coherent_pfn((unsigned long)cpu_addr);
+
+	vma->vm_page_prot = pgprot_noncached(vma->vm_page_prot);
+	return remap_pfn_range(vma, vma->vm_start,
+			       pfn + vma->vm_pgoff,
+			       vma->vm_end - vma->vm_start,
+			       vma->vm_page_prot);
+}
diff --git a/arch/powerpc/platforms/44x/warp.c b/arch/powerpc/platforms/44x/warp.c
index 7e4f8ca19ce8..c0e6fb270d59 100644
--- a/arch/powerpc/platforms/44x/warp.c
+++ b/arch/powerpc/platforms/44x/warp.c
@@ -47,7 +47,7 @@ static int __init warp_probe(void)
 	if (!of_machine_is_compatible("pika,warp"))
 		return 0;
 
-	/* For __dma_nommu_alloc_coherent */
+	/* For arch_dma_alloc */
 	ISA_DMA_THRESHOLD = ~0L;
 
 	return 1;
diff --git a/arch/powerpc/platforms/Kconfig.cputype b/arch/powerpc/platforms/Kconfig.cputype
index a2578bf8d560..9d83f54ccf11 100644
--- a/arch/powerpc/platforms/Kconfig.cputype
+++ b/arch/powerpc/platforms/Kconfig.cputype
@@ -387,7 +387,11 @@ config NOT_COHERENT_CACHE
 	depends on 4xx || PPC_8xx || E200 || PPC_MPC512x || GAMECUBE_COMMON
 	default n if PPC_47x
 	default y
-	select NEED_DMA_MAP_STATE
+	select ARCH_HAS_SYNC_DMA_FOR_DEVICE
+	select ARCH_HAS_SYNC_DMA_FOR_CPU
+	select DMA_NONCOHERENT_GET_REQUIRED
+	select DMA_NONCOHERENT_MMAP
+	select DMA_NONCOHERENT_OPS
 
 config CHECK_CACHE_COHERENCY
 	bool
-- 
2.18.0

