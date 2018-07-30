From: Christoph Hellwig <hch@lst.de>
Date: Mon, 30 Jul 2018 16:38:20 +0000
Subject: [PATCH 16/20] powerpc/dma: use dma_direct_{alloc,free}
Message-Id: <20180730163824.10064-17-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180730163824.10064-1-hch@lst.de>
In-Reply-To: <20180730163824.10064-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Robin Murphy <robin.murphy@arm.com>, linuxppc-dev@lists.ozlabs.org, iommu@lists.linux-foundation.org, linux-ia64@vger.kernel.org

These do the same functionality as the existing helpers, but do it
simpler, and also allow the (optional) use of CMA.

Note that the swiotlb code now calls into the dma_direct code directly,
given that it doesn't work with noncoherent caches at all, and isn't called
when we have an iommu either, so the iommu special case in
dma_nommu_alloc_coherent isn't required for swiotlb.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/powerpc/include/asm/pgtable.h |  1 -
 arch/powerpc/kernel/dma-swiotlb.c  |  4 +-
 arch/powerpc/kernel/dma.c          | 78 ++++--------------------------
 arch/powerpc/mm/mem.c              | 19 --------
 4 files changed, 11 insertions(+), 91 deletions(-)

diff --git a/arch/powerpc/include/asm/pgtable.h b/arch/powerpc/include/asm/pgtable.h
index 14c79a7dc855..123de4958d2e 100644
--- a/arch/powerpc/include/asm/pgtable.h
+++ b/arch/powerpc/include/asm/pgtable.h
@@ -38,7 +38,6 @@ extern unsigned long empty_zero_page[];
 extern pgd_t swapper_pg_dir[];
 
 void limit_zone_pfn(enum zone_type zone, unsigned long max_pfn);
-int dma_pfn_limit_to_zone(u64 pfn_limit);
 extern void paging_init(void);
 
 /*
diff --git a/arch/powerpc/kernel/dma-swiotlb.c b/arch/powerpc/kernel/dma-swiotlb.c
index f6e0701c5303..25986fcd1e5e 100644
--- a/arch/powerpc/kernel/dma-swiotlb.c
+++ b/arch/powerpc/kernel/dma-swiotlb.c
@@ -46,8 +46,8 @@ static u64 swiotlb_powerpc_get_required(struct device *dev)
  * for everything else.
  */
 const struct dma_map_ops powerpc_swiotlb_dma_ops = {
-	.alloc = __dma_nommu_alloc_coherent,
-	.free = __dma_nommu_free_coherent,
+	.alloc = dma_direct_alloc,
+	.free = dma_direct_free,
 	.mmap = dma_nommu_mmap_coherent,
 	.map_sg = swiotlb_map_sg_attrs,
 	.unmap_sg = swiotlb_unmap_sg_attrs,
diff --git a/arch/powerpc/kernel/dma.c b/arch/powerpc/kernel/dma.c
index 2cfc45acbb52..2b90a403cdac 100644
--- a/arch/powerpc/kernel/dma.c
+++ b/arch/powerpc/kernel/dma.c
@@ -26,75 +26,6 @@
  * can set archdata.dma_data to an unsigned long holding the offset. By
  * default the offset is PCI_DRAM_OFFSET.
  */
-
-static u64 __maybe_unused get_pfn_limit(struct device *dev)
-{
-	u64 pfn = (dev->coherent_dma_mask >> PAGE_SHIFT) + 1;
-	struct dev_archdata __maybe_unused *sd = &dev->archdata;
-
-#ifdef CONFIG_SWIOTLB
-	if (sd->max_direct_dma_addr && dev->dma_ops = &powerpc_swiotlb_dma_ops)
-		pfn = min_t(u64, pfn, sd->max_direct_dma_addr >> PAGE_SHIFT);
-#endif
-
-	return pfn;
-}
-
-#ifndef CONFIG_NOT_COHERENT_CACHE
-void *__dma_nommu_alloc_coherent(struct device *dev, size_t size,
-				  dma_addr_t *dma_handle, gfp_t flag,
-				  unsigned long attrs)
-{
-	void *ret;
-	struct page *page;
-	int node = dev_to_node(dev);
-#ifdef CONFIG_FSL_SOC
-	u64 pfn = get_pfn_limit(dev);
-	int zone;
-
-	/*
-	 * This code should be OK on other platforms, but we have drivers that
-	 * don't set coherent_dma_mask. As a workaround we just ifdef it. This
-	 * whole routine needs some serious cleanup.
-	 */
-
-	zone = dma_pfn_limit_to_zone(pfn);
-	if (zone < 0) {
-		dev_err(dev, "%s: No suitable zone for pfn %#llx\n",
-			__func__, pfn);
-		return NULL;
-	}
-
-	switch (zone) {
-	case ZONE_DMA:
-		flag |= GFP_DMA;
-		break;
-#ifdef CONFIG_ZONE_DMA32
-	case ZONE_DMA32:
-		flag |= GFP_DMA32;
-		break;
-#endif
-	};
-#endif /* CONFIG_FSL_SOC */
-
-	page = alloc_pages_node(node, flag, get_order(size));
-	if (page = NULL)
-		return NULL;
-	ret = page_address(page);
-	memset(ret, 0, size);
-	*dma_handle = phys_to_dma(dev,__pa(ret));
-
-	return ret;
-}
-
-void __dma_nommu_free_coherent(struct device *dev, size_t size,
-				void *vaddr, dma_addr_t dma_handle,
-				unsigned long attrs)
-{
-	free_pages((unsigned long)vaddr, get_order(size));
-}
-#endif /* !CONFIG_NOT_COHERENT_CACHE */
-
 static void *dma_nommu_alloc_coherent(struct device *dev, size_t size,
 				       dma_addr_t *dma_handle, gfp_t flag,
 				       unsigned long attrs)
@@ -105,8 +36,12 @@ static void *dma_nommu_alloc_coherent(struct device *dev, size_t size,
 	 * we can really use the direct ops
 	 */
 	if (dma_direct_supported(dev, dev->coherent_dma_mask))
+#ifdef CONFIG_NOT_COHERENT_CACHE
 		return __dma_nommu_alloc_coherent(dev, size, dma_handle,
 						   flag, attrs);
+#else
+		return dma_direct_alloc(dev, size, dma_handle, flag, attrs);
+#endif
 
 	/* Ok we can't ... do we have an iommu ? If not, fail */
 	iommu = get_iommu_table_base(dev);
@@ -127,8 +62,13 @@ static void dma_nommu_free_coherent(struct device *dev, size_t size,
 
 	/* See comments in dma_nommu_alloc_coherent() */
 	if (dma_direct_supported(dev, dev->coherent_dma_mask))
+#ifdef CONFIG_NOT_COHERENT_CACHE
 		return __dma_nommu_free_coherent(dev, size, vaddr, dma_handle,
 						  attrs);
+#else
+		return dma_direct_free(dev, size, vaddr, dma_handle, attrs);
+#endif
+
 	/* Maybe we used an iommu ... */
 	iommu = get_iommu_table_base(dev);
 
diff --git a/arch/powerpc/mm/mem.c b/arch/powerpc/mm/mem.c
index 5c8530d0c611..ec8ed9d7abef 100644
--- a/arch/powerpc/mm/mem.c
+++ b/arch/powerpc/mm/mem.c
@@ -276,25 +276,6 @@ void __init limit_zone_pfn(enum zone_type zone, unsigned long pfn_limit)
 	}
 }
 
-/*
- * Find the least restrictive zone that is entirely below the
- * specified pfn limit.  Returns < 0 if no suitable zone is found.
- *
- * pfn_limit must be u64 because it can exceed 32 bits even on 32-bit
- * systems -- the DMA limit can be higher than any possible real pfn.
- */
-int dma_pfn_limit_to_zone(u64 pfn_limit)
-{
-	int i;
-
-	for (i = TOP_ZONE; i >= 0; i--) {
-		if (max_zone_pfns[i] <= pfn_limit)
-			return i;
-	}
-
-	return -EPERM;
-}
-
 /*
  * paging_init() sets up the page tables - in fact we've already done this.
  */
-- 
2.18.0

