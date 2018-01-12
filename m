From: Christoph Hellwig <hch@lst.de>
Date: Fri, 12 Jan 2018 08:42:28 +0000
Subject: [PATCH 30/34] dma-direct: retry allocations using GFP_DMA for small masks
Message-Id: <20180112084232.2857-31-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180112084232.2857-1-hch@lst.de>
In-Reply-To: <20180112084232.2857-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: iommu@lists.linux-foundation.org
Cc: Konrad Rzeszutek Wilk <konrad@darnok.org>, linux-alpha@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-c6x-dev@linux-c6x.org, linux-cris-kernel@axis.com, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-metag@vger.kernel.org, Michal Simek <monstr@monstr.eu>, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, patches@groups.riscv.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, Guan Xuetao <gxt@mprc.pku.edu.cn>, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

If an attempt to allocate memory succeeded, but isn't inside the
supported DMA mask, retry the allocation with GFP_DMA set as a
last resort.

Based on the x86 code, but an off by one error in what is now
dma_coherent_ok has been fixed vs the x86 code.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 lib/dma-direct.c | 25 ++++++++++++++++++++++++-
 1 file changed, 24 insertions(+), 1 deletion(-)

diff --git a/lib/dma-direct.c b/lib/dma-direct.c
index 8f76032ebc3c..4e43c2bb7f5f 100644
--- a/lib/dma-direct.c
+++ b/lib/dma-direct.c
@@ -35,6 +35,11 @@ check_addr(struct device *dev, dma_addr_t dma_addr, size_t size,
 	return true;
 }
 
+static bool dma_coherent_ok(struct device *dev, phys_addr_t phys, size_t size)
+{
+	return phys_to_dma(dev, phys) + size - 1 <= dev->coherent_dma_mask;
+}
+
 static void *dma_direct_alloc(struct device *dev, size_t size,
 		dma_addr_t *dma_handle, gfp_t gfp, unsigned long attrs)
 {
@@ -48,11 +53,29 @@ static void *dma_direct_alloc(struct device *dev, size_t size,
 	if (dev->coherent_dma_mask <= DMA_BIT_MASK(32) && !(gfp & GFP_DMA))
 		gfp |= GFP_DMA32;
 
+again:
 	/* CMA can be used only in the context which permits sleeping */
-	if (gfpflags_allow_blocking(gfp))
+	if (gfpflags_allow_blocking(gfp)) {
 		page = dma_alloc_from_contiguous(dev, count, page_order, gfp);
+		if (page && !dma_coherent_ok(dev, page_to_phys(page), size)) {
+			dma_release_from_contiguous(dev, page, count);
+			page = NULL;
+		}
+	}
 	if (!page)
 		page = alloc_pages_node(dev_to_node(dev), gfp, page_order);
+
+	if (page && !dma_coherent_ok(dev, page_to_phys(page), size)) {
+		__free_pages(page, page_order);
+		page = NULL;
+
+		if (dev->coherent_dma_mask < DMA_BIT_MASK(32) &&
+		    !(gfp & GFP_DMA)) {
+			gfp = (gfp & ~GFP_DMA32) | GFP_DMA;
+			goto again;
+		}
+	}
+
 	if (!page)
 		return NULL;
 
-- 
2.14.2

