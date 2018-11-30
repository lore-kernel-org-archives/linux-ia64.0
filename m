From: Christoph Hellwig <hch@lst.de>
Date: Fri, 30 Nov 2018 13:22:13 +0000
Subject: [PATCH 05/23] mips/jazz: remove the mapping_error dma_map_ops method
Message-Id: <20181130132231.16512-6-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20181130132231.16512-1-hch@lst.de>
In-Reply-To: <20181130132231.16512-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: iommu@lists.linux-foundation.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Jon Mason <jdmason@kudzu.us>, Joerg Roedel <joro@8bytes.org>, David Woodhouse <dwmw2@infradead.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Robin Murphy <robin.murphy@arm.com>, x86@kernel.org, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, xen-devel@lists.xenproject.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

The Jazz iommu code already returns (~(dma_addr_t)0x0) on mapping
failures, so we can switch over to returning DMA_MAPPING_ERROR and
let the core dma-mapping code handle the rest.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/mips/include/asm/jazzdma.h |  6 ------
 arch/mips/jazz/jazzdma.c        | 16 +++++-----------
 2 files changed, 5 insertions(+), 17 deletions(-)

diff --git a/arch/mips/include/asm/jazzdma.h b/arch/mips/include/asm/jazzdma.h
index d913439c738c..d13f940022d5 100644
--- a/arch/mips/include/asm/jazzdma.h
+++ b/arch/mips/include/asm/jazzdma.h
@@ -39,12 +39,6 @@ extern int vdma_get_enable(int channel);
 #define VDMA_PAGE(a)		((unsigned int)(a) >> 12)
 #define VDMA_OFFSET(a)		((unsigned int)(a) & (VDMA_PAGESIZE-1))
 
-/*
- * error code returned by vdma_alloc()
- * (See also arch/mips/kernel/jazzdma.c)
- */
-#define VDMA_ERROR		0xffffffff
-
 /*
  * VDMA pagetable entry description
  */
diff --git a/arch/mips/jazz/jazzdma.c b/arch/mips/jazz/jazzdma.c
index 4c41ed0a637e..6256d35dbf4d 100644
--- a/arch/mips/jazz/jazzdma.c
+++ b/arch/mips/jazz/jazzdma.c
@@ -104,12 +104,12 @@ unsigned long vdma_alloc(unsigned long paddr, unsigned long size)
 		if (vdma_debug)
 			printk("vdma_alloc: Invalid physical address: %08lx\n",
 			       paddr);
-		return VDMA_ERROR;	/* invalid physical address */
+		return DMA_MAPPING_ERROR;	/* invalid physical address */
 	}
 	if (size > 0x400000 || size = 0) {
 		if (vdma_debug)
 			printk("vdma_alloc: Invalid size: %08lx\n", size);
-		return VDMA_ERROR;	/* invalid physical address */
+		return DMA_MAPPING_ERROR;	/* invalid physical address */
 	}
 
 	spin_lock_irqsave(&vdma_lock, flags);
@@ -123,7 +123,7 @@ unsigned long vdma_alloc(unsigned long paddr, unsigned long size)
 		       first < VDMA_PGTBL_ENTRIES) first++;
 		if (first + pages > VDMA_PGTBL_ENTRIES) {	/* nothing free */
 			spin_unlock_irqrestore(&vdma_lock, flags);
-			return VDMA_ERROR;
+			return DMA_MAPPING_ERROR;
 		}
 
 		last = first + 1;
@@ -569,7 +569,7 @@ static void *jazz_dma_alloc(struct device *dev, size_t size,
 		return NULL;
 
 	*dma_handle = vdma_alloc(virt_to_phys(ret), size);
-	if (*dma_handle = VDMA_ERROR) {
+	if (*dma_handle = DMA_MAPPING_ERROR) {
 		dma_direct_free_pages(dev, size, ret, *dma_handle, attrs);
 		return NULL;
 	}
@@ -620,7 +620,7 @@ static int jazz_dma_map_sg(struct device *dev, struct scatterlist *sglist,
 			arch_sync_dma_for_device(dev, sg_phys(sg), sg->length,
 				dir);
 		sg->dma_address = vdma_alloc(sg_phys(sg), sg->length);
-		if (sg->dma_address = VDMA_ERROR)
+		if (sg->dma_address = DMA_MAPPING_ERROR)
 			return 0;
 		sg_dma_len(sg) = sg->length;
 	}
@@ -674,11 +674,6 @@ static void jazz_dma_sync_sg_for_cpu(struct device *dev,
 		arch_sync_dma_for_cpu(dev, sg_phys(sg), sg->length, dir);
 }
 
-static int jazz_dma_mapping_error(struct device *dev, dma_addr_t dma_addr)
-{
-	return dma_addr = VDMA_ERROR;
-}
-
 const struct dma_map_ops jazz_dma_ops = {
 	.alloc			= jazz_dma_alloc,
 	.free			= jazz_dma_free,
@@ -692,6 +687,5 @@ const struct dma_map_ops jazz_dma_ops = {
 	.sync_sg_for_device	= jazz_dma_sync_sg_for_device,
 	.dma_supported		= dma_direct_supported,
 	.cache_sync		= arch_dma_cache_sync,
-	.mapping_error		= jazz_dma_mapping_error,
 };
 EXPORT_SYMBOL(jazz_dma_ops);
-- 
2.19.1
