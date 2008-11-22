From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Date: Sat, 22 Nov 2008 12:58:47 +0000
Subject: [PATCH] IA64: fix VT-d dma_mapping_error
Message-Id: <20081122215822A.fujita.tomonori@lab.ntt.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com, dwmw2@infradead.org, fenghua.yu@intel.com
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu

Hmm, IA64 VT-d dma_mapping_error() is broken?

Subject: [PATCH] IA64: fix VT-d dma_mapping_error
From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>

IA64 VT-d dma_mapping_error always says that the dma mapping is
successful even though intel_map_single() could fail.

VT-d uses X86 dependent dma_mapping_error() code. This patch adds
VT-d's own dma_mapping_error() that works for both X86_64 and IA64.

Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
---
 arch/ia64/dig/dig_vtd_iommu.c |    2 +-
 drivers/pci/intel-iommu.c     |    6 ++++++
 include/linux/intel-iommu.h   |    1 +
 3 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/arch/ia64/dig/dig_vtd_iommu.c b/arch/ia64/dig/dig_vtd_iommu.c
index 1c8a079..e663eac 100644
--- a/arch/ia64/dig/dig_vtd_iommu.c
+++ b/arch/ia64/dig/dig_vtd_iommu.c
@@ -54,6 +54,6 @@ EXPORT_SYMBOL_GPL(vtd_unmap_sg_attrs);
 int
 vtd_dma_mapping_error(struct device *dev, dma_addr_t dma_addr)
 {
-	return 0;
+	return intel_dma_mapping_error(dev, dma_addr);
 }
 EXPORT_SYMBOL_GPL(vtd_dma_mapping_error);
diff --git a/drivers/pci/intel-iommu.c b/drivers/pci/intel-iommu.c
index 5c8baa4..5289fc1 100644
--- a/drivers/pci/intel-iommu.c
+++ b/drivers/pci/intel-iommu.c
@@ -2157,6 +2157,11 @@ int intel_map_sg(struct device *hwdev, struct scatterlist *sglist, int nelems,
 	return nelems;
 }
 
+int intel_dma_mapping_error(struct device *hwdev, dma_addr_t dma_addr)
+{
+	return !dma_addr;
+}
+
 static struct dma_mapping_ops intel_dma_ops = {
 	.alloc_coherent = intel_alloc_coherent,
 	.free_coherent = intel_free_coherent,
@@ -2164,6 +2169,7 @@ static struct dma_mapping_ops intel_dma_ops = {
 	.unmap_single = intel_unmap_single,
 	.map_sg = intel_map_sg,
 	.unmap_sg = intel_unmap_sg,
+	.mapping_error = intel_dma_mapping_error,
 };
 
 static inline int iommu_domain_cache_init(void)
diff --git a/include/linux/intel-iommu.h b/include/linux/intel-iommu.h
index 3d017cf..027e75e 100644
--- a/include/linux/intel-iommu.h
+++ b/include/linux/intel-iommu.h
@@ -359,5 +359,6 @@ extern dma_addr_t intel_map_single(struct device *, phys_addr_t, size_t, int);
 extern void intel_unmap_single(struct device *, dma_addr_t, size_t, int);
 extern int intel_map_sg(struct device *, struct scatterlist *, int, int);
 extern void intel_unmap_sg(struct device *, struct scatterlist *, int, int);
+extern int intel_dma_mapping_error(struct device *, dma_addr_t);
 
 #endif
-- 
1.5.6.5

