From: Christoph Hellwig <hch@lst.de>
Date: Mon, 30 Jul 2018 16:38:21 +0000
Subject: [PATCH 17/20] powerpc/dma-swiotlb: use generic swiotlb_dma_ops
Message-Id: <20180730163824.10064-18-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180730163824.10064-1-hch@lst.de>
In-Reply-To: <20180730163824.10064-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Robin Murphy <robin.murphy@arm.com>, linuxppc-dev@lists.ozlabs.org, iommu@lists.linux-foundation.org, linux-ia64@vger.kernel.org

These are identical to the arch specific ones, so remove them.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/powerpc/include/asm/dma-direct.h |  4 ++++
 arch/powerpc/include/asm/swiotlb.h    |  2 --
 arch/powerpc/kernel/dma-swiotlb.c     | 28 ++-------------------------
 arch/powerpc/sysdev/fsl_pci.c         |  2 +-
 4 files changed, 7 insertions(+), 29 deletions(-)

diff --git a/arch/powerpc/include/asm/dma-direct.h b/arch/powerpc/include/asm/dma-direct.h
index 0fba19445ae8..657f84ddb20d 100644
--- a/arch/powerpc/include/asm/dma-direct.h
+++ b/arch/powerpc/include/asm/dma-direct.h
@@ -30,4 +30,8 @@ static inline phys_addr_t __dma_to_phys(struct device *dev, dma_addr_t daddr)
 		return daddr - PCI_DRAM_OFFSET;
 	return daddr - dev->archdata.dma_offset;
 }
+
+u64 swiotlb_powerpc_get_required(struct device *dev);
+#define swiotlb_get_required_mask swiotlb_powerpc_get_required
+
 #endif /* ASM_POWERPC_DMA_DIRECT_H */
diff --git a/arch/powerpc/include/asm/swiotlb.h b/arch/powerpc/include/asm/swiotlb.h
index f65ecf57b66c..1d8c1da26ab3 100644
--- a/arch/powerpc/include/asm/swiotlb.h
+++ b/arch/powerpc/include/asm/swiotlb.h
@@ -13,8 +13,6 @@
 
 #include <linux/swiotlb.h>
 
-extern const struct dma_map_ops powerpc_swiotlb_dma_ops;
-
 extern unsigned int ppc_swiotlb_enable;
 int __init swiotlb_setup_bus_notifier(void);
 
diff --git a/arch/powerpc/kernel/dma-swiotlb.c b/arch/powerpc/kernel/dma-swiotlb.c
index 25986fcd1e5e..0c269de61f39 100644
--- a/arch/powerpc/kernel/dma-swiotlb.c
+++ b/arch/powerpc/kernel/dma-swiotlb.c
@@ -24,7 +24,7 @@
 
 unsigned int ppc_swiotlb_enable;
 
-static u64 swiotlb_powerpc_get_required(struct device *dev)
+u64 swiotlb_powerpc_get_required(struct device *dev)
 {
 	u64 end, mask, max_direct_dma_addr = dev->archdata.max_direct_dma_addr;
 
@@ -38,30 +38,6 @@ static u64 swiotlb_powerpc_get_required(struct device *dev)
 	return mask;
 }
 
-/*
- * At the moment, all platforms that use this code only require
- * swiotlb to be used if we're operating on HIGHMEM.  Since
- * we don't ever call anything other than map_sg, unmap_sg,
- * map_page, and unmap_page on highmem, use normal dma_ops
- * for everything else.
- */
-const struct dma_map_ops powerpc_swiotlb_dma_ops = {
-	.alloc = dma_direct_alloc,
-	.free = dma_direct_free,
-	.mmap = dma_nommu_mmap_coherent,
-	.map_sg = swiotlb_map_sg_attrs,
-	.unmap_sg = swiotlb_unmap_sg_attrs,
-	.dma_supported = swiotlb_dma_supported,
-	.map_page = swiotlb_map_page,
-	.unmap_page = swiotlb_unmap_page,
-	.sync_single_for_cpu = swiotlb_sync_single_for_cpu,
-	.sync_single_for_device = swiotlb_sync_single_for_device,
-	.sync_sg_for_cpu = swiotlb_sync_sg_for_cpu,
-	.sync_sg_for_device = swiotlb_sync_sg_for_device,
-	.mapping_error = swiotlb_dma_mapping_error,
-	.get_required_mask = swiotlb_powerpc_get_required,
-};
-
 void pci_dma_dev_setup_swiotlb(struct pci_dev *pdev)
 {
 	struct pci_controller *hose;
@@ -88,7 +64,7 @@ static int ppc_swiotlb_bus_notify(struct notifier_block *nb,
 
 	/* May need to bounce if the device can't address all of DRAM */
 	if ((dma_get_mask(dev) + 1) < memblock_end_of_DRAM())
-		set_dma_ops(dev, &powerpc_swiotlb_dma_ops);
+		set_dma_ops(dev, &swiotlb_dma_ops);
 
 	return NOTIFY_DONE;
 }
diff --git a/arch/powerpc/sysdev/fsl_pci.c b/arch/powerpc/sysdev/fsl_pci.c
index 918be816b097..daf44bc0108d 100644
--- a/arch/powerpc/sysdev/fsl_pci.c
+++ b/arch/powerpc/sysdev/fsl_pci.c
@@ -118,7 +118,7 @@ static void setup_swiotlb_ops(struct pci_controller *hose)
 {
 	if (ppc_swiotlb_enable) {
 		hose->controller_ops.dma_dev_setup = pci_dma_dev_setup_swiotlb;
-		set_pci_dma_ops(&powerpc_swiotlb_dma_ops);
+		set_pci_dma_ops(&swiotlb_dma_ops);
 	}
 }
 #else
-- 
2.18.0

