From: Christoph Hellwig <hch@lst.de>
Date: Mon, 17 Sep 2018 17:10:30 +0000
Subject: [PATCH 8/9] ia64: remove machvec_dma_sync_{single,sg}
Message-Id: <20180917171031.3853-9-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The original form of these was added (to the HP zx1 platform only) by
the following bitkeeper commit (by the way of the historic.git tree):

commit 66b99421d118a5ddd98a72913670b0fcf0a38d45
Author: Andrew Morton <akpm@osdl.org>
Date:   Sat Mar 13 17:05:37 2004 -0800

    [PATCH] DMA: Fill gaping hole in DMA API interfaces.

    From: "David S. Miller" <davem@redhat.com>

The commit does not explain why we'd need the memory barrier on ia64,
it never included the swiotlb or SGI IOMMU based platforms, and also
failed to address the map/unmap parts of the dma mapping interface,
which should provide the same ordering semantics and actually are
commonly used.  The conclusion of this is that they were added in
error and should be removed.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/ia64/hp/common/sba_iommu.c     |  4 ----
 arch/ia64/include/asm/dma-mapping.h |  5 -----
 arch/ia64/kernel/machvec.c          | 16 ----------------
 arch/ia64/kernel/pci-dma.c          |  5 -----
 4 files changed, 30 deletions(-)

diff --git a/arch/ia64/hp/common/sba_iommu.c b/arch/ia64/hp/common/sba_iommu.c
index 671ce1e3f6f2..e8a93b07283e 100644
--- a/arch/ia64/hp/common/sba_iommu.c
+++ b/arch/ia64/hp/common/sba_iommu.c
@@ -2207,10 +2207,6 @@ const struct dma_map_ops sba_dma_ops = {
 	.unmap_page		= sba_unmap_page,
 	.map_sg			= sba_map_sg_attrs,
 	.unmap_sg		= sba_unmap_sg_attrs,
-	.sync_single_for_cpu	= machvec_dma_sync_single,
-	.sync_sg_for_cpu	= machvec_dma_sync_sg,
-	.sync_single_for_device	= machvec_dma_sync_single,
-	.sync_sg_for_device	= machvec_dma_sync_sg,
 	.dma_supported		= sba_dma_supported,
 	.mapping_error		= sba_dma_mapping_error,
 };
diff --git a/arch/ia64/include/asm/dma-mapping.h b/arch/ia64/include/asm/dma-mapping.h
index 76e4d6632d68..2b8cd4a6d958 100644
--- a/arch/ia64/include/asm/dma-mapping.h
+++ b/arch/ia64/include/asm/dma-mapping.h
@@ -16,11 +16,6 @@ extern const struct dma_map_ops *dma_ops;
 extern struct ia64_machine_vector ia64_mv;
 extern void set_iommu_machvec(void);
 
-extern void machvec_dma_sync_single(struct device *, dma_addr_t, size_t,
-				    enum dma_data_direction);
-extern void machvec_dma_sync_sg(struct device *, struct scatterlist *, int,
-				enum dma_data_direction);
-
 static inline const struct dma_map_ops *get_arch_dma_ops(struct bus_type *bus)
 {
 	return platform_dma_get_ops(NULL);
diff --git a/arch/ia64/kernel/machvec.c b/arch/ia64/kernel/machvec.c
index 7bfe98859911..1b604d02250b 100644
--- a/arch/ia64/kernel/machvec.c
+++ b/arch/ia64/kernel/machvec.c
@@ -73,19 +73,3 @@ machvec_timer_interrupt (int irq, void *dev_id)
 {
 }
 EXPORT_SYMBOL(machvec_timer_interrupt);
-
-void
-machvec_dma_sync_single(struct device *hwdev, dma_addr_t dma_handle, size_t size,
-			enum dma_data_direction dir)
-{
-	mb();
-}
-EXPORT_SYMBOL(machvec_dma_sync_single);
-
-void
-machvec_dma_sync_sg(struct device *hwdev, struct scatterlist *sg, int n,
-		    enum dma_data_direction dir)
-{
-	mb();
-}
-EXPORT_SYMBOL(machvec_dma_sync_sg);
diff --git a/arch/ia64/kernel/pci-dma.c b/arch/ia64/kernel/pci-dma.c
index afb43677f9ca..5a5bf5a82ac2 100644
--- a/arch/ia64/kernel/pci-dma.c
+++ b/arch/ia64/kernel/pci-dma.c
@@ -41,11 +41,6 @@ void __init pci_iommu_alloc(void)
 {
 	dma_ops = &intel_dma_ops;
 
-	intel_dma_ops.sync_single_for_cpu = machvec_dma_sync_single;
-	intel_dma_ops.sync_sg_for_cpu = machvec_dma_sync_sg;
-	intel_dma_ops.sync_single_for_device = machvec_dma_sync_single;
-	intel_dma_ops.sync_sg_for_device = machvec_dma_sync_sg;
-
 	/*
 	 * The order of these functions is important for
 	 * fall-back/fail-over reasons
-- 
2.18.0
