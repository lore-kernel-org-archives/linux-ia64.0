From: Christoph Hellwig <hch@lst.de>
Date: Fri, 29 Dec 2017 08:19:11 +0000
Subject: [PATCH 67/67] swiotlb: remove various exports
Message-Id: <20171229081911.2802-68-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20171229081911.2802-1-hch@lst.de>
In-Reply-To: <20171229081911.2802-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: iommu@lists.linux-foundation.org
Cc: linux-alpha@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, adi-buildroot-devel@lists.sourceforge.net, linux-c6x-dev@linux-c6x.org, linux-cris-kernel@axis.com, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-metag@vger.kernel.org, Michal Simek <monstr@monstr.eu>, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, patches@groups.riscv.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, Guan Xuetao <gxt@mprc.pku.edu.cn>, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

All these symbols are only used by arch dma_ops implementations or
xen-swiotlb.  None of which can be modular.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 lib/swiotlb.c | 13 -------------
 1 file changed, 13 deletions(-)

diff --git a/lib/swiotlb.c b/lib/swiotlb.c
index 77a40b508db8..823e1055a394 100644
--- a/lib/swiotlb.c
+++ b/lib/swiotlb.c
@@ -591,7 +591,6 @@ phys_addr_t swiotlb_tbl_map_single(struct device *hwdev,
 
 	return tlb_addr;
 }
-EXPORT_SYMBOL_GPL(swiotlb_tbl_map_single);
 
 /*
  * Allocates bounce buffer and returns its kernel virtual address.
@@ -661,7 +660,6 @@ void swiotlb_tbl_unmap_single(struct device *hwdev, phys_addr_t tlb_addr,
 	}
 	spin_unlock_irqrestore(&io_tlb_lock, flags);
 }
-EXPORT_SYMBOL_GPL(swiotlb_tbl_unmap_single);
 
 void swiotlb_tbl_sync_single(struct device *hwdev, phys_addr_t tlb_addr,
 			     size_t size, enum dma_data_direction dir,
@@ -693,7 +691,6 @@ void swiotlb_tbl_sync_single(struct device *hwdev, phys_addr_t tlb_addr,
 		BUG();
 	}
 }
-EXPORT_SYMBOL_GPL(swiotlb_tbl_sync_single);
 
 static void *
 swiotlb_alloc_buffer(struct device *dev, size_t size, dma_addr_t *dma_handle)
@@ -827,7 +824,6 @@ dma_addr_t swiotlb_map_page(struct device *dev, struct page *page,
 
 	return __phys_to_dma(dev, io_tlb_overflow_buffer);
 }
-EXPORT_SYMBOL_GPL(swiotlb_map_page);
 
 /*
  * Unmap a single streaming mode DMA translation.  The dma_addr and size must
@@ -868,7 +864,6 @@ void swiotlb_unmap_page(struct device *hwdev, dma_addr_t dev_addr,
 {
 	unmap_single(hwdev, dev_addr, size, dir, attrs);
 }
-EXPORT_SYMBOL_GPL(swiotlb_unmap_page);
 
 /*
  * Make physical memory consistent for a single streaming mode DMA translation
@@ -906,7 +901,6 @@ swiotlb_sync_single_for_cpu(struct device *hwdev, dma_addr_t dev_addr,
 {
 	swiotlb_sync_single(hwdev, dev_addr, size, dir, SYNC_FOR_CPU);
 }
-EXPORT_SYMBOL(swiotlb_sync_single_for_cpu);
 
 void
 swiotlb_sync_single_for_device(struct device *hwdev, dma_addr_t dev_addr,
@@ -914,7 +908,6 @@ swiotlb_sync_single_for_device(struct device *hwdev, dma_addr_t dev_addr,
 {
 	swiotlb_sync_single(hwdev, dev_addr, size, dir, SYNC_FOR_DEVICE);
 }
-EXPORT_SYMBOL(swiotlb_sync_single_for_device);
 
 /*
  * Map a set of buffers described by scatterlist in streaming mode for DMA.
@@ -966,7 +959,6 @@ swiotlb_map_sg_attrs(struct device *hwdev, struct scatterlist *sgl, int nelems,
 	}
 	return nelems;
 }
-EXPORT_SYMBOL(swiotlb_map_sg_attrs);
 
 /*
  * Unmap a set of streaming mode DMA translations.  Again, cpu read rules
@@ -986,7 +978,6 @@ swiotlb_unmap_sg_attrs(struct device *hwdev, struct scatterlist *sgl,
 		unmap_single(hwdev, sg->dma_address, sg_dma_len(sg), dir,
 			     attrs);
 }
-EXPORT_SYMBOL(swiotlb_unmap_sg_attrs);
 
 /*
  * Make physical memory consistent for a set of streaming mode DMA translations
@@ -1014,7 +1005,6 @@ swiotlb_sync_sg_for_cpu(struct device *hwdev, struct scatterlist *sg,
 {
 	swiotlb_sync_sg(hwdev, sg, nelems, dir, SYNC_FOR_CPU);
 }
-EXPORT_SYMBOL(swiotlb_sync_sg_for_cpu);
 
 void
 swiotlb_sync_sg_for_device(struct device *hwdev, struct scatterlist *sg,
@@ -1022,14 +1012,12 @@ swiotlb_sync_sg_for_device(struct device *hwdev, struct scatterlist *sg,
 {
 	swiotlb_sync_sg(hwdev, sg, nelems, dir, SYNC_FOR_DEVICE);
 }
-EXPORT_SYMBOL(swiotlb_sync_sg_for_device);
 
 int
 swiotlb_dma_mapping_error(struct device *hwdev, dma_addr_t dma_addr)
 {
 	return (dma_addr = __phys_to_dma(hwdev, io_tlb_overflow_buffer));
 }
-EXPORT_SYMBOL(swiotlb_dma_mapping_error);
 
 /*
  * Return whether the given device DMA address mask can be supported
@@ -1042,7 +1030,6 @@ swiotlb_dma_supported(struct device *hwdev, u64 mask)
 {
 	return __phys_to_dma(hwdev, io_tlb_end - 1) <= mask;
 }
-EXPORT_SYMBOL(swiotlb_dma_supported);
 
 #ifdef CONFIG_DMA_DIRECT_OPS
 void *swiotlb_alloc(struct device *dev, size_t size, dma_addr_t *dma_handle,
-- 
2.14.2

