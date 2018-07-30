From: Christoph Hellwig <hch@lst.de>
Date: Mon, 30 Jul 2018 16:38:23 +0000
Subject: [PATCH 19/20] powerpc/dma: use the generic dma-direct map_page and map_sg routines
Message-Id: <20180730163824.10064-20-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180730163824.10064-1-hch@lst.de>
In-Reply-To: <20180730163824.10064-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Robin Murphy <robin.murphy@arm.com>, linuxppc-dev@lists.ozlabs.org, iommu@lists.linux-foundation.org, linux-ia64@vger.kernel.org

These are indentical except for additional error checking, so migrate
to the common code, and wire up the get_mapping_error method as well.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/powerpc/kernel/dma.c | 32 ++++----------------------------
 1 file changed, 4 insertions(+), 28 deletions(-)

diff --git a/arch/powerpc/kernel/dma.c b/arch/powerpc/kernel/dma.c
index b2e88075b2ea..08b12cbd7abf 100644
--- a/arch/powerpc/kernel/dma.c
+++ b/arch/powerpc/kernel/dma.c
@@ -82,21 +82,6 @@ int dma_nommu_mmap_coherent(struct device *dev, struct vm_area_struct *vma,
 			       vma->vm_page_prot);
 }
 
-static int dma_nommu_map_sg(struct device *dev, struct scatterlist *sgl,
-			     int nents, enum dma_data_direction direction,
-			     unsigned long attrs)
-{
-	struct scatterlist *sg;
-	int i;
-
-	for_each_sg(sgl, sg, nents, i) {
-		sg->dma_address = phys_to_dma(dev, sg_phys(sg));
-		sg->dma_length = sg->length;
-	}
-
-	return nents;
-}
-
 /* note: needs to be called arch_get_required_mask for dma-noncoherent.c */
 u64 arch_get_required_mask(struct device *dev)
 {
@@ -110,24 +95,15 @@ u64 arch_get_required_mask(struct device *dev)
 	return mask;
 }
 
-static inline dma_addr_t dma_nommu_map_page(struct device *dev,
-					     struct page *page,
-					     unsigned long offset,
-					     size_t size,
-					     enum dma_data_direction dir,
-					     unsigned long attrs)
-{
-	return phys_to_dma(dev, page_to_phys(page)) + offset;
-}
-
 const struct dma_map_ops dma_nommu_ops = {
 	.alloc				= dma_nommu_alloc_coherent,
 	.free				= dma_nommu_free_coherent,
 	.mmap				= dma_nommu_mmap_coherent,
-	.map_sg				= dma_nommu_map_sg,
-	.dma_supported			= dma_direct_supported,
-	.map_page			= dma_nommu_map_page,
+	.map_sg				= dma_direct_map_sg,
+	.map_page			= dma_direct_map_page,
 	.get_required_mask		= arch_get_required_mask,
+	.dma_supported			= dma_direct_supported,
+	.mapping_error			= dma_direct_mapping_error,
 };
 
 #ifndef CONFIG_NOT_COHERENT_CACHE
-- 
2.18.0

