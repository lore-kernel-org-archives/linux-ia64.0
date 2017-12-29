From: Christoph Hellwig <hch@lst.de>
Date: Fri, 29 Dec 2017 08:18:58 +0000
Subject: [PATCH 54/67] x86: remove sta2x11_dma_ops
Message-Id: <20171229081911.2802-55-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20171229081911.2802-1-hch@lst.de>
In-Reply-To: <20171229081911.2802-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: iommu@lists.linux-foundation.org
Cc: linux-alpha@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, adi-buildroot-devel@lists.sourceforge.net, linux-c6x-dev@linux-c6x.org, linux-cris-kernel@axis.com, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-metag@vger.kernel.org, Michal Simek <monstr@monstr.eu>, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, patches@groups.riscv.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, Guan Xuetao <gxt@mprc.pku.edu.cn>, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

Both the swiotlb and the dma-direct code already call into phys_to_dma
to translate the DMA address.  So the sta2x11 into phys_to_dma and
dma_to_phys are enough to handle this "special" device, and we can use
the plain old swiotlb ops.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/x86/include/asm/device.h |  3 +++
 arch/x86/pci/sta2x11-fixup.c  | 46 +++++--------------------------------------
 2 files changed, 8 insertions(+), 41 deletions(-)

diff --git a/arch/x86/include/asm/device.h b/arch/x86/include/asm/device.h
index 5e12c63b47aa..812bd6c5d602 100644
--- a/arch/x86/include/asm/device.h
+++ b/arch/x86/include/asm/device.h
@@ -6,6 +6,9 @@ struct dev_archdata {
 #if defined(CONFIG_INTEL_IOMMU) || defined(CONFIG_AMD_IOMMU)
 	void *iommu; /* hook for IOMMU specific extension */
 #endif
+#ifdef CONFIG_STA2X11
+	bool is_sta2x11 : 1;
+#endif
 };
 
 #if defined(CONFIG_X86_DEV_DMA_OPS) && defined(CONFIG_PCI_DOMAINS)
diff --git a/arch/x86/pci/sta2x11-fixup.c b/arch/x86/pci/sta2x11-fixup.c
index 15ad3025e439..7a5bafb76d77 100644
--- a/arch/x86/pci/sta2x11-fixup.c
+++ b/arch/x86/pci/sta2x11-fixup.c
@@ -159,43 +159,6 @@ static dma_addr_t a2p(dma_addr_t a, struct pci_dev *pdev)
 	return p;
 }
 
-/**
- * sta2x11_swiotlb_alloc_coherent - Allocate swiotlb bounce buffers
- *     returns virtual address. This is the only "special" function here.
- * @dev: PCI device
- * @size: Size of the buffer
- * @dma_handle: DMA address
- * @flags: memory flags
- */
-static void *sta2x11_swiotlb_alloc_coherent(struct device *dev,
-					    size_t size,
-					    dma_addr_t *dma_handle,
-					    gfp_t flags,
-					    unsigned long attrs)
-{
-	void *vaddr;
-
-	vaddr = swiotlb_alloc(dev, size, dma_handle, flags, attrs);
-	*dma_handle = p2a(*dma_handle, to_pci_dev(dev));
-	return vaddr;
-}
-
-/* We have our own dma_ops: the same as swiotlb but from alloc (above) */
-static const struct dma_map_ops sta2x11_dma_ops = {
-	.alloc = sta2x11_swiotlb_alloc_coherent,
-	.free = swiotlb_free,
-	.map_page = swiotlb_map_page,
-	.unmap_page = swiotlb_unmap_page,
-	.map_sg = swiotlb_map_sg_attrs,
-	.unmap_sg = swiotlb_unmap_sg_attrs,
-	.sync_single_for_cpu = swiotlb_sync_single_for_cpu,
-	.sync_single_for_device = swiotlb_sync_single_for_device,
-	.sync_sg_for_cpu = swiotlb_sync_sg_for_cpu,
-	.sync_sg_for_device = swiotlb_sync_sg_for_device,
-	.mapping_error = swiotlb_dma_mapping_error,
-	.dma_supported = dma_direct_supported,
-};
-
 /* At setup time, we use our own ops if the device is a ConneXt one */
 static void sta2x11_setup_pdev(struct pci_dev *pdev)
 {
@@ -205,7 +168,8 @@ static void sta2x11_setup_pdev(struct pci_dev *pdev)
 		return;
 	pci_set_consistent_dma_mask(pdev, STA2X11_AMBA_SIZE - 1);
 	pci_set_dma_mask(pdev, STA2X11_AMBA_SIZE - 1);
-	pdev->dev.dma_ops = &sta2x11_dma_ops;
+	pdev->dev.dma_ops = &swiotlb_dma_ops;
+	pdev->dev.archdata.is_sta2x11 = true;
 
 	/* We must enable all devices as master, for audio DMA to work */
 	pci_set_master(pdev);
@@ -225,7 +189,7 @@ bool dma_capable(struct device *dev, dma_addr_t addr, size_t size)
 {
 	struct sta2x11_mapping *map;
 
-	if (dev->dma_ops != &sta2x11_dma_ops) {
+	if (!dev->archdata.is_sta2x11) {
 		if (!dev->dma_mask)
 			return false;
 		return addr + size - 1 <= *dev->dma_mask;
@@ -249,7 +213,7 @@ bool dma_capable(struct device *dev, dma_addr_t addr, size_t size)
  */
 dma_addr_t __phys_to_dma(struct device *dev, phys_addr_t paddr)
 {
-	if (dev->dma_ops != &sta2x11_dma_ops)
+	if (!dev->archdata.is_sta2x11)
 		return paddr;
 	return p2a(paddr, to_pci_dev(dev));
 }
@@ -261,7 +225,7 @@ dma_addr_t __phys_to_dma(struct device *dev, phys_addr_t paddr)
  */
 phys_addr_t __dma_to_phys(struct device *dev, dma_addr_t daddr)
 {
-	if (dev->dma_ops != &sta2x11_dma_ops)
+	if (!dev->archdata.is_sta2x11)
 		return daddr;
 	return a2p(daddr, to_pci_dev(dev));
 }
-- 
2.14.2

