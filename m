From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Date: Wed, 28 Jan 2009 12:53:17 +0000
Subject: [PATCH -tip 2/3] IA64: fix VT-d dma_mapping_error
Message-Id: <1233147198-30299-2-git-send-email-fujita.tomonori@lab.ntt.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <1233147198-30299-1-git-send-email-fujita.tomonori@lab.ntt.co.jp>
In-Reply-To: <1233147198-30299-1-git-send-email-fujita.tomonori@lab.ntt.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: mingo@elte.hu, tony.luck@intel.com
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, David Woodhouse <David.Woodhouse@intel.com>

dma_mapping_error is used to see if dma_map_single and dma_map_page
succeed. IA64 VT-d dma_mapping_error always says that dma_map_single
is successful even though it could fail. Note that X86 VT-d works
properly in this regard.

This patch fixes IA64 VT-d dma_mapping_error by adding VT-d's own
dma_mapping_error() that works for both X86_64 and IA64. VT-d uses
zero as an error dma address so VT-d's dma_mapping_error returns 1 if
a passed dma address is zero (as x86's VT-d dma_mapping_error does
now).

Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Cc: David Woodhouse <David.Woodhouse@intel.com>
---
 arch/ia64/kernel/pci-dma.c |    6 ------
 drivers/pci/intel-iommu.c  |    6 ++++++
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/arch/ia64/kernel/pci-dma.c b/arch/ia64/kernel/pci-dma.c
index a647f11..e4cb443 100644
--- a/arch/ia64/kernel/pci-dma.c
+++ b/arch/ia64/kernel/pci-dma.c
@@ -99,11 +99,6 @@ int iommu_dma_supported(struct device *dev, u64 mask)
 }
 EXPORT_SYMBOL(iommu_dma_supported);
 
-static int vtd_dma_mapping_error(struct device *dev, dma_addr_t dma_addr)
-{
-	return 0;
-}
-
 void __init pci_iommu_alloc(void)
 {
 	dma_ops = &intel_dma_ops;
@@ -113,7 +108,6 @@ void __init pci_iommu_alloc(void)
 	dma_ops->sync_single_for_device = machvec_dma_sync_single;
 	dma_ops->sync_sg_for_device = machvec_dma_sync_sg;
 	dma_ops->dma_supported = iommu_dma_supported;
-	dma_ops->mapping_error = vtd_dma_mapping_error;
 
 	/*
 	 * The order of these functions is important for
diff --git a/drivers/pci/intel-iommu.c b/drivers/pci/intel-iommu.c
index c933980..59de563 100644
--- a/drivers/pci/intel-iommu.c
+++ b/drivers/pci/intel-iommu.c
@@ -2581,6 +2581,11 @@ int intel_map_sg(struct device *hwdev, struct scatterlist *sglist, int nelems,
 	return nelems;
 }
 
+static int intel_mapping_error(struct device *dev, dma_addr_t dma_addr)
+{
+	return !dma_addr;
+}
+
 struct dma_map_ops intel_dma_ops = {
 	.alloc_coherent = intel_alloc_coherent,
 	.free_coherent = intel_free_coherent,
@@ -2588,6 +2593,7 @@ struct dma_map_ops intel_dma_ops = {
 	.unmap_sg = intel_unmap_sg,
 	.map_page = intel_map_page,
 	.unmap_page = intel_unmap_page,
+	.mapping_error = intel_mapping_error,
 };
 
 static inline int iommu_domain_cache_init(void)
-- 
1.6.0.6

