From: Christoph Hellwig <hch@lst.de>
Date: Wed, 01 Aug 2018 16:02:52 +0000
Subject: [PATCH 9/9] intel-iommu: mark intel_dma_ops static
Message-Id: <20180801160252.25629-10-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180801160252.25629-1-hch@lst.de>
In-Reply-To: <20180801160252.25629-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: David Woodhouse <dwmw2@infradead.org>, linux-ia64@vger.kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, iommu@lists.linux-foundation.org

ia64 currently explicitly assigns it to dma_ops, but that same work is
already done by intel_iommu_init a little later, so we can remove the
duplicate assignment and mark the variable static.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/ia64/kernel/pci-dma.c  | 4 ----
 drivers/iommu/intel-iommu.c | 2 +-
 2 files changed, 1 insertion(+), 5 deletions(-)

diff --git a/arch/ia64/kernel/pci-dma.c b/arch/ia64/kernel/pci-dma.c
index 5a5bf5a82ac2..fe988c49f01c 100644
--- a/arch/ia64/kernel/pci-dma.c
+++ b/arch/ia64/kernel/pci-dma.c
@@ -24,8 +24,6 @@ int force_iommu __read_mostly;
 
 int iommu_pass_through;
 
-extern struct dma_map_ops intel_dma_ops;
-
 static int __init pci_iommu_init(void)
 {
 	if (iommu_detected)
@@ -39,8 +37,6 @@ fs_initcall(pci_iommu_init);
 
 void __init pci_iommu_alloc(void)
 {
-	dma_ops = &intel_dma_ops;
-
 	/*
 	 * The order of these functions is important for
 	 * fall-back/fail-over reasons
diff --git a/drivers/iommu/intel-iommu.c b/drivers/iommu/intel-iommu.c
index 1be2609bd094..2da100e042fb 100644
--- a/drivers/iommu/intel-iommu.c
+++ b/drivers/iommu/intel-iommu.c
@@ -3889,7 +3889,7 @@ static int intel_mapping_error(struct device *dev, dma_addr_t dma_addr)
 	return !dma_addr;
 }
 
-const struct dma_map_ops intel_dma_ops = {
+static const struct dma_map_ops intel_dma_ops = {
 	.alloc = intel_alloc_coherent,
 	.free = intel_free_coherent,
 	.map_sg = intel_map_sg,
-- 
2.18.0

