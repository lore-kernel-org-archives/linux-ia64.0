From: Christoph Hellwig <hch@lst.de>
Date: Fri, 29 Dec 2017 08:18:54 +0000
Subject: [PATCH 50/67] swiotlb: refactor coherent buffer allocation
Message-Id: <20171229081911.2802-51-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20171229081911.2802-1-hch@lst.de>
In-Reply-To: <20171229081911.2802-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: iommu@lists.linux-foundation.org
Cc: linux-alpha@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, adi-buildroot-devel@lists.sourceforge.net, linux-c6x-dev@linux-c6x.org, linux-cris-kernel@axis.com, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-metag@vger.kernel.org, Michal Simek <monstr@monstr.eu>, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, patches@groups.riscv.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, Guan Xuetao <gxt@mprc.pku.edu.cn>, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

Factor out a new swiotlb_alloc_buffer helper that allocates DMA coherent
memory from the swiotlb bounce buffer.

This allows to simplify the swiotlb_alloc implemenation that uses
dma_direct_alloc to try to allocate a reachable buffer first.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 lib/swiotlb.c | 100 ++++++++++++++++++++++++++++++----------------------------
 1 file changed, 51 insertions(+), 49 deletions(-)

diff --git a/lib/swiotlb.c b/lib/swiotlb.c
index adb4dd0091fa..905eea6353a3 100644
--- a/lib/swiotlb.c
+++ b/lib/swiotlb.c
@@ -709,67 +709,69 @@ void swiotlb_tbl_sync_single(struct device *hwdev, phys_addr_t tlb_addr,
 }
 EXPORT_SYMBOL_GPL(swiotlb_tbl_sync_single);
 
+static void *
+swiotlb_alloc_buffer(struct device *dev, size_t size, dma_addr_t *dma_handle)
+{
+	phys_addr_t phys_addr;
+
+	if (swiotlb_force = SWIOTLB_NO_FORCE)
+		goto out_warn;
+
+	phys_addr = swiotlb_tbl_map_single(dev,
+			swiotlb_phys_to_dma(dev, io_tlb_start),
+			0, size, DMA_FROM_DEVICE, 0);
+	if (phys_addr = SWIOTLB_MAP_ERROR)
+		goto out_warn;
+
+	*dma_handle = swiotlb_phys_to_dma(dev, phys_addr);
+
+	/* Confirm address can be DMA'd by device */
+	if (*dma_handle + size - 1 > dev->coherent_dma_mask)
+		goto out_unmap;
+
+	memset(phys_to_virt(phys_addr), 0, size);
+	return phys_to_virt(phys_addr);
+
+out_unmap:
+	dev_warn(dev, "hwdev DMA mask = 0x%016Lx, dev_addr = 0x%016Lx\n",
+		(unsigned long long)dev->coherent_dma_mask,
+		(unsigned long long)*dma_handle);
+
+	/*
+	 * DMA_TO_DEVICE to avoid memcpy in unmap_single.
+	 * DMA_ATTR_SKIP_CPU_SYNC is optional.
+	 */
+	swiotlb_tbl_unmap_single(dev, phys_addr, size, DMA_TO_DEVICE,
+			DMA_ATTR_SKIP_CPU_SYNC);
+out_warn:
+	dev_warn(dev,
+		"swiotlb: coherent allocation failed, size=%zu\n", size);
+	dump_stack();
+	return NULL;
+}
+
 void *
 swiotlb_alloc_coherent(struct device *hwdev, size_t size,
 		       dma_addr_t *dma_handle, gfp_t flags)
 {
-	dma_addr_t dev_addr;
-	void *ret;
 	int order = get_order(size);
+	void *ret;
 
 	ret = (void *)__get_free_pages(flags, order);
 	if (ret) {
-		dev_addr = swiotlb_virt_to_bus(hwdev, ret);
-		if (dev_addr + size - 1 > hwdev->coherent_dma_mask) {
-			/*
-			 * The allocated memory isn't reachable by the device.
-			 */
-			free_pages((unsigned long) ret, order);
-			ret = NULL;
+		*dma_handle = swiotlb_virt_to_bus(hwdev, ret);
+		if (*dma_handle  + size - 1 <= hwdev->coherent_dma_mask) {
+			memset(ret, 0, size);
+			return ret;
 		}
-	}
-	if (!ret) {
+
 		/*
-		 * We are either out of memory or the device can't DMA to
-		 * GFP_DMA memory; fall back on map_single(), which
-		 * will grab memory from the lowest available address range.
+		 * The allocated memory isn't reachable by the device.
 		 */
-		phys_addr_t paddr = map_single(hwdev, 0, size,
-					       DMA_FROM_DEVICE, 0);
-		if (paddr = SWIOTLB_MAP_ERROR)
-			goto err_warn;
-
-		ret = phys_to_virt(paddr);
-		dev_addr = swiotlb_phys_to_dma(hwdev, paddr);
-
-		/* Confirm address can be DMA'd by device */
-		if (dev_addr + size - 1 > hwdev->coherent_dma_mask) {
-			printk("hwdev DMA mask = 0x%016Lx, dev_addr = 0x%016Lx\n",
-			       (unsigned long long)hwdev->coherent_dma_mask,
-			       (unsigned long long)dev_addr);
-
-			/*
-			 * DMA_TO_DEVICE to avoid memcpy in unmap_single.
-			 * The DMA_ATTR_SKIP_CPU_SYNC is optional.
-			 */
-			swiotlb_tbl_unmap_single(hwdev, paddr,
-						 size, DMA_TO_DEVICE,
-						 DMA_ATTR_SKIP_CPU_SYNC);
-			goto err_warn;
-		}
+		free_pages((unsigned long) ret, order);
 	}
 
-	*dma_handle = dev_addr;
-	memset(ret, 0, size);
-
-	return ret;
-
-err_warn:
-	pr_warn("swiotlb: coherent allocation failed for device %s size=%zu\n",
-		dev_name(hwdev), size);
-	dump_stack();
-
-	return NULL;
+	return swiotlb_alloc_buffer(hwdev, size, dma_handle);
 }
 EXPORT_SYMBOL(swiotlb_alloc_coherent);
 
@@ -1105,7 +1107,7 @@ void *swiotlb_alloc(struct device *dev, size_t size, dma_addr_t *dma_handle,
 
 	vaddr = dma_direct_alloc(dev, size, dma_handle, gfp, attrs);
 	if (!vaddr)
-		vaddr = swiotlb_alloc_coherent(dev, size, dma_handle, gfp);
+		vaddr = swiotlb_alloc_buffer(dev, size, dma_handle);
 	return vaddr;
 }
 
-- 
2.14.2

