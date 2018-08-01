From: Christoph Hellwig <hch@lst.de>
Date: Wed, 01 Aug 2018 16:02:50 +0000
Subject: [PATCH 7/9] ia64/sn2: remove no-ops dma sync methods
Message-Id: <20180801160252.25629-8-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180801160252.25629-1-hch@lst.de>
In-Reply-To: <20180801160252.25629-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: David Woodhouse <dwmw2@infradead.org>, linux-ia64@vger.kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, iommu@lists.linux-foundation.org

These do nothing but duplicating an assert that would have triggered
earlier on setting the dma mask, so remove them.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/ia64/sn/pci/pci_dma.c | 29 -----------------------------
 1 file changed, 29 deletions(-)

diff --git a/arch/ia64/sn/pci/pci_dma.c b/arch/ia64/sn/pci/pci_dma.c
index 74c934a997bb..3b944fba0a3e 100644
--- a/arch/ia64/sn/pci/pci_dma.c
+++ b/arch/ia64/sn/pci/pci_dma.c
@@ -314,31 +314,6 @@ static int sn_dma_map_sg(struct device *dev, struct scatterlist *sgl,
 	return nhwentries;
 }
 
-static void sn_dma_sync_single_for_cpu(struct device *dev, dma_addr_t dma_handle,
-				       size_t size, enum dma_data_direction dir)
-{
-	BUG_ON(!dev_is_pci(dev));
-}
-
-static void sn_dma_sync_single_for_device(struct device *dev, dma_addr_t dma_handle,
-					  size_t size,
-					  enum dma_data_direction dir)
-{
-	BUG_ON(!dev_is_pci(dev));
-}
-
-static void sn_dma_sync_sg_for_cpu(struct device *dev, struct scatterlist *sg,
-				   int nelems, enum dma_data_direction dir)
-{
-	BUG_ON(!dev_is_pci(dev));
-}
-
-static void sn_dma_sync_sg_for_device(struct device *dev, struct scatterlist *sg,
-				      int nelems, enum dma_data_direction dir)
-{
-	BUG_ON(!dev_is_pci(dev));
-}
-
 static int sn_dma_mapping_error(struct device *dev, dma_addr_t dma_addr)
 {
 	return 0;
@@ -467,10 +442,6 @@ static struct dma_map_ops sn_dma_ops = {
 	.unmap_page		= sn_dma_unmap_page,
 	.map_sg			= sn_dma_map_sg,
 	.unmap_sg		= sn_dma_unmap_sg,
-	.sync_single_for_cpu 	= sn_dma_sync_single_for_cpu,
-	.sync_sg_for_cpu	= sn_dma_sync_sg_for_cpu,
-	.sync_single_for_device = sn_dma_sync_single_for_device,
-	.sync_sg_for_device	= sn_dma_sync_sg_for_device,
 	.mapping_error		= sn_dma_mapping_error,
 	.dma_supported		= sn_dma_supported,
 };
-- 
2.18.0

