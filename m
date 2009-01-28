From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Date: Wed, 28 Jan 2009 12:53:18 +0000
Subject: [PATCH -tip 3/3] intel-iommu: make dma mapping functions static
Message-Id: <1233147198-30299-3-git-send-email-fujita.tomonori@lab.ntt.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <1233147198-30299-1-git-send-email-fujita.tomonori@lab.ntt.co.jp>
 <1233147198-30299-2-git-send-email-fujita.tomonori@lab.ntt.co.jp>
In-Reply-To: <1233147198-30299-2-git-send-email-fujita.tomonori@lab.ntt.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: mingo@elte.hu, tony.luck@intel.com
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, David Woodhouse <David.Woodhouse@intel.com>

The dma ops unification enables X86 and IA64 to share intel_dma_ops so
we can make dma mapping functions static. This also remove unused
intel_map_single().

Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Cc: David Woodhouse <David.Woodhouse@intel.com>
---
 drivers/pci/intel-iommu.c   |   29 +++++++++++------------------
 include/linux/intel-iommu.h |    9 ---------
 2 files changed, 11 insertions(+), 27 deletions(-)

diff --git a/drivers/pci/intel-iommu.c b/drivers/pci/intel-iommu.c
index 59de563..628f8b7 100644
--- a/drivers/pci/intel-iommu.c
+++ b/drivers/pci/intel-iommu.c
@@ -2283,13 +2283,6 @@ static dma_addr_t intel_map_page(struct device *dev, struct page *page,
 				  dir, to_pci_dev(dev)->dma_mask);
 }
 
-dma_addr_t intel_map_single(struct device *hwdev, phys_addr_t paddr,
-			    size_t size, int dir)
-{
-	return __intel_map_single(hwdev, paddr, size, dir,
-				  to_pci_dev(hwdev)->dma_mask);
-}
-
 static void flush_unmaps(void)
 {
 	int i, j;
@@ -2397,14 +2390,14 @@ static void intel_unmap_page(struct device *dev, dma_addr_t dev_addr,
 	}
 }
 
-void intel_unmap_single(struct device *dev, dma_addr_t dev_addr, size_t size,
-			int dir)
+static void intel_unmap_single(struct device *dev, dma_addr_t dev_addr, size_t size,
+			       int dir)
 {
 	intel_unmap_page(dev, dev_addr, size, dir, NULL);
 }
 
-void *intel_alloc_coherent(struct device *hwdev, size_t size,
-			   dma_addr_t *dma_handle, gfp_t flags)
+static void *intel_alloc_coherent(struct device *hwdev, size_t size,
+				  dma_addr_t *dma_handle, gfp_t flags)
 {
 	void *vaddr;
 	int order;
@@ -2427,8 +2420,8 @@ void *intel_alloc_coherent(struct device *hwdev, size_t size,
 	return NULL;
 }
 
-void intel_free_coherent(struct device *hwdev, size_t size, void *vaddr,
-			 dma_addr_t dma_handle)
+static void intel_free_coherent(struct device *hwdev, size_t size, void *vaddr,
+				dma_addr_t dma_handle)
 {
 	int order;
 
@@ -2441,9 +2434,9 @@ void intel_free_coherent(struct device *hwdev, size_t size, void *vaddr,
 
 #define SG_ENT_VIRT_ADDRESS(sg)	(sg_virt((sg)))
 
-void intel_unmap_sg(struct device *hwdev, struct scatterlist *sglist,
-		    int nelems, enum dma_data_direction dir,
-		    struct dma_attrs *attrs)
+static void intel_unmap_sg(struct device *hwdev, struct scatterlist *sglist,
+			   int nelems, enum dma_data_direction dir,
+			   struct dma_attrs *attrs)
 {
 	int i;
 	struct pci_dev *pdev = to_pci_dev(hwdev);
@@ -2500,8 +2493,8 @@ static int intel_nontranslate_map_sg(struct device *hddev,
 	return nelems;
 }
 
-int intel_map_sg(struct device *hwdev, struct scatterlist *sglist, int nelems,
-		 enum dma_data_direction dir, struct dma_attrs *attrs)
+static int intel_map_sg(struct device *hwdev, struct scatterlist *sglist, int nelems,
+			enum dma_data_direction dir, struct dma_attrs *attrs)
 {
 	void *addr;
 	int i;
diff --git a/include/linux/intel-iommu.h b/include/linux/intel-iommu.h
index a254db1..43412ae 100644
--- a/include/linux/intel-iommu.h
+++ b/include/linux/intel-iommu.h
@@ -330,13 +330,4 @@ extern int qi_flush_iotlb(struct intel_iommu *iommu, u16 did, u64 addr,
 
 extern void qi_submit_sync(struct qi_desc *desc, struct intel_iommu *iommu);
 
-extern void *intel_alloc_coherent(struct device *, size_t, dma_addr_t *, gfp_t);
-extern void intel_free_coherent(struct device *, size_t, void *, dma_addr_t);
-extern dma_addr_t intel_map_single(struct device *, phys_addr_t, size_t, int);
-extern void intel_unmap_single(struct device *, dma_addr_t, size_t, int);
-extern int intel_map_sg(struct device *, struct scatterlist *, int,
-			enum dma_data_direction, struct dma_attrs *);
-extern void intel_unmap_sg(struct device *, struct scatterlist *, int,
-			   enum dma_data_direction, struct dma_attrs *);
-
 #endif
-- 
1.6.0.6

