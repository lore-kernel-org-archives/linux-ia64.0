From: Christoph Hellwig <hch@lst.de>
Date: Mon, 30 Jul 2018 16:38:24 +0000
Subject: [PATCH 20/20] powerpc/dma: remove dma_nommu_mmap_coherent
Message-Id: <20180730163824.10064-21-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180730163824.10064-1-hch@lst.de>
In-Reply-To: <20180730163824.10064-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Robin Murphy <robin.murphy@arm.com>, linuxppc-dev@lists.ozlabs.org, iommu@lists.linux-foundation.org, linux-ia64@vger.kernel.org

The remaining implementation for coherent caches is functionally
identical to the default provided in common code.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/powerpc/include/asm/dma-mapping.h |  7 -------
 arch/powerpc/kernel/dma-iommu.c        |  1 -
 arch/powerpc/kernel/dma.c              | 13 -------------
 arch/powerpc/platforms/pseries/vio.c   |  1 -
 4 files changed, 22 deletions(-)

diff --git a/arch/powerpc/include/asm/dma-mapping.h b/arch/powerpc/include/asm/dma-mapping.h
index 879c4efba785..e62e23aa3714 100644
--- a/arch/powerpc/include/asm/dma-mapping.h
+++ b/arch/powerpc/include/asm/dma-mapping.h
@@ -18,13 +18,6 @@
 #include <asm/io.h>
 #include <asm/swiotlb.h>
 
-/* Some dma direct funcs must be visible for use in other dma_ops */
-extern int dma_nommu_mmap_coherent(struct device *dev,
-				    struct vm_area_struct *vma,
-				    void *cpu_addr, dma_addr_t handle,
-				    size_t size, unsigned long attrs);
-
-
 static inline unsigned long device_to_mask(struct device *dev)
 {
 	if (dev->dma_mask && *dev->dma_mask)
diff --git a/arch/powerpc/kernel/dma-iommu.c b/arch/powerpc/kernel/dma-iommu.c
index f9fe2080ceb9..bf5234e1f71b 100644
--- a/arch/powerpc/kernel/dma-iommu.c
+++ b/arch/powerpc/kernel/dma-iommu.c
@@ -114,7 +114,6 @@ int dma_iommu_mapping_error(struct device *dev, dma_addr_t dma_addr)
 struct dma_map_ops dma_iommu_ops = {
 	.alloc			= dma_iommu_alloc_coherent,
 	.free			= dma_iommu_free_coherent,
-	.mmap			= dma_nommu_mmap_coherent,
 	.map_sg			= dma_iommu_map_sg,
 	.unmap_sg		= dma_iommu_unmap_sg,
 	.dma_supported		= dma_iommu_dma_supported,
diff --git a/arch/powerpc/kernel/dma.c b/arch/powerpc/kernel/dma.c
index 08b12cbd7abf..5b71c9d1b8cc 100644
--- a/arch/powerpc/kernel/dma.c
+++ b/arch/powerpc/kernel/dma.c
@@ -70,18 +70,6 @@ static void dma_nommu_free_coherent(struct device *dev, size_t size,
 	iommu_free_coherent(iommu, size, vaddr, dma_handle);
 }
 
-int dma_nommu_mmap_coherent(struct device *dev, struct vm_area_struct *vma,
-			     void *cpu_addr, dma_addr_t handle, size_t size,
-			     unsigned long attrs)
-{
-	unsigned long pfn = page_to_pfn(virt_to_page(cpu_addr));
-
-	return remap_pfn_range(vma, vma->vm_start,
-			       pfn + vma->vm_pgoff,
-			       vma->vm_end - vma->vm_start,
-			       vma->vm_page_prot);
-}
-
 /* note: needs to be called arch_get_required_mask for dma-noncoherent.c */
 u64 arch_get_required_mask(struct device *dev)
 {
@@ -98,7 +86,6 @@ u64 arch_get_required_mask(struct device *dev)
 const struct dma_map_ops dma_nommu_ops = {
 	.alloc				= dma_nommu_alloc_coherent,
 	.free				= dma_nommu_free_coherent,
-	.mmap				= dma_nommu_mmap_coherent,
 	.map_sg				= dma_direct_map_sg,
 	.map_page			= dma_direct_map_page,
 	.get_required_mask		= arch_get_required_mask,
diff --git a/arch/powerpc/platforms/pseries/vio.c b/arch/powerpc/platforms/pseries/vio.c
index 49e04ec19238..51d564313bd0 100644
--- a/arch/powerpc/platforms/pseries/vio.c
+++ b/arch/powerpc/platforms/pseries/vio.c
@@ -618,7 +618,6 @@ static u64 vio_dma_get_required_mask(struct device *dev)
 static const struct dma_map_ops vio_dma_mapping_ops = {
 	.alloc             = vio_dma_iommu_alloc_coherent,
 	.free              = vio_dma_iommu_free_coherent,
-	.mmap		   = dma_nommu_mmap_coherent,
 	.map_sg            = vio_dma_iommu_map_sg,
 	.unmap_sg          = vio_dma_iommu_unmap_sg,
 	.map_page          = vio_dma_iommu_map_page,
-- 
2.18.0

