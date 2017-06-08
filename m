From: Christoph Hellwig <hch@lst.de>
Date: Thu, 08 Jun 2017 13:25:45 +0000
Subject: [PATCH 20/44] sparc: implement ->mapping_error
Message-Id: <20170608132609.32662-21-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170608132609.32662-1-hch@lst.de>
In-Reply-To: <20170608132609.32662-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: x86@kernel.org, linux-arm-kernel@lists.infradead.org, xen-devel@lists.xenproject.org, linux-c6x-dev@linux-c6x.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, openrisc@lists.librecores.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, dmaengine@vger.kernel.org, linux-tegra@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-samsung-soc@vger.kernel.org, iommu@lists.linux-foundation.org, netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org

DMA_ERROR_CODE is going to go away, so don't rely on it.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/sparc/include/asm/dma-mapping.h |  2 --
 arch/sparc/kernel/iommu.c            | 12 +++++++++---
 arch/sparc/kernel/iommu_common.h     |  2 ++
 arch/sparc/kernel/pci_sun4v.c        | 14 ++++++++++----
 4 files changed, 21 insertions(+), 9 deletions(-)

diff --git a/arch/sparc/include/asm/dma-mapping.h b/arch/sparc/include/asm/dma-mapping.h
index 69cc627779f2..b8e8dfcd065d 100644
--- a/arch/sparc/include/asm/dma-mapping.h
+++ b/arch/sparc/include/asm/dma-mapping.h
@@ -5,8 +5,6 @@
 #include <linux/mm.h>
 #include <linux/dma-debug.h>
 
-#define DMA_ERROR_CODE	(~(dma_addr_t)0x0)
-
 #define HAVE_ARCH_DMA_SUPPORTED 1
 int dma_supported(struct device *dev, u64 mask);
 
diff --git a/arch/sparc/kernel/iommu.c b/arch/sparc/kernel/iommu.c
index c63ba99ca551..dafa316d978d 100644
--- a/arch/sparc/kernel/iommu.c
+++ b/arch/sparc/kernel/iommu.c
@@ -314,7 +314,7 @@ static dma_addr_t dma_4u_map_page(struct device *dev, struct page *page,
 bad_no_ctx:
 	if (printk_ratelimit())
 		WARN_ON(1);
-	return DMA_ERROR_CODE;
+	return SPARC_MAPPING_ERROR;
 }
 
 static void strbuf_flush(struct strbuf *strbuf, struct iommu *iommu,
@@ -547,7 +547,7 @@ static int dma_4u_map_sg(struct device *dev, struct scatterlist *sglist,
 
 	if (outcount < incount) {
 		outs = sg_next(outs);
-		outs->dma_address = DMA_ERROR_CODE;
+		outs->dma_address = SPARC_MAPPING_ERROR;
 		outs->dma_length = 0;
 	}
 
@@ -573,7 +573,7 @@ static int dma_4u_map_sg(struct device *dev, struct scatterlist *sglist,
 			iommu_tbl_range_free(&iommu->tbl, vaddr, npages,
 					     IOMMU_ERROR_CODE);
 
-			s->dma_address = DMA_ERROR_CODE;
+			s->dma_address = SPARC_MAPPING_ERROR;
 			s->dma_length = 0;
 		}
 		if (s = outs)
@@ -741,6 +741,11 @@ static void dma_4u_sync_sg_for_cpu(struct device *dev,
 	spin_unlock_irqrestore(&iommu->lock, flags);
 }
 
+static int dma_4u_mapping_error(struct device *dev, dma_addr_t dma_addr)
+{
+	return dma_addr = SPARC_MAPPING_ERROR;
+}
+
 static const struct dma_map_ops sun4u_dma_ops = {
 	.alloc			= dma_4u_alloc_coherent,
 	.free			= dma_4u_free_coherent,
@@ -750,6 +755,7 @@ static const struct dma_map_ops sun4u_dma_ops = {
 	.unmap_sg		= dma_4u_unmap_sg,
 	.sync_single_for_cpu	= dma_4u_sync_single_for_cpu,
 	.sync_sg_for_cpu	= dma_4u_sync_sg_for_cpu,
+	.mapping_error		= dma_4u_mapping_error,
 };
 
 const struct dma_map_ops *dma_ops = &sun4u_dma_ops;
diff --git a/arch/sparc/kernel/iommu_common.h b/arch/sparc/kernel/iommu_common.h
index 828493329f68..5ea5c192b1d9 100644
--- a/arch/sparc/kernel/iommu_common.h
+++ b/arch/sparc/kernel/iommu_common.h
@@ -47,4 +47,6 @@ static inline int is_span_boundary(unsigned long entry,
 	return iommu_is_span_boundary(entry, nr, shift, boundary_size);
 }
 
+#define SPARC_MAPPING_ERROR	(~(dma_addr_t)0x0)
+
 #endif /* _IOMMU_COMMON_H */
diff --git a/arch/sparc/kernel/pci_sun4v.c b/arch/sparc/kernel/pci_sun4v.c
index 68bec7c97cb8..8e2a56f4c03a 100644
--- a/arch/sparc/kernel/pci_sun4v.c
+++ b/arch/sparc/kernel/pci_sun4v.c
@@ -412,12 +412,12 @@ static dma_addr_t dma_4v_map_page(struct device *dev, struct page *page,
 bad:
 	if (printk_ratelimit())
 		WARN_ON(1);
-	return DMA_ERROR_CODE;
+	return SPARC_MAPPING_ERROR;
 
 iommu_map_fail:
 	local_irq_restore(flags);
 	iommu_tbl_range_free(tbl, bus_addr, npages, IOMMU_ERROR_CODE);
-	return DMA_ERROR_CODE;
+	return SPARC_MAPPING_ERROR;
 }
 
 static void dma_4v_unmap_page(struct device *dev, dma_addr_t bus_addr,
@@ -590,7 +590,7 @@ static int dma_4v_map_sg(struct device *dev, struct scatterlist *sglist,
 
 	if (outcount < incount) {
 		outs = sg_next(outs);
-		outs->dma_address = DMA_ERROR_CODE;
+		outs->dma_address = SPARC_MAPPING_ERROR;
 		outs->dma_length = 0;
 	}
 
@@ -607,7 +607,7 @@ static int dma_4v_map_sg(struct device *dev, struct scatterlist *sglist,
 			iommu_tbl_range_free(tbl, vaddr, npages,
 					     IOMMU_ERROR_CODE);
 			/* XXX demap? XXX */
-			s->dma_address = DMA_ERROR_CODE;
+			s->dma_address = SPARC_MAPPING_ERROR;
 			s->dma_length = 0;
 		}
 		if (s = outs)
@@ -669,6 +669,11 @@ static void dma_4v_unmap_sg(struct device *dev, struct scatterlist *sglist,
 	local_irq_restore(flags);
 }
 
+static int dma_4v_mapping_error(struct device *dev, dma_addr_t dma_addr)
+{
+	return dma_addr = SPARC_MAPPING_ERROR;
+}
+
 static const struct dma_map_ops sun4v_dma_ops = {
 	.alloc				= dma_4v_alloc_coherent,
 	.free				= dma_4v_free_coherent,
@@ -676,6 +681,7 @@ static const struct dma_map_ops sun4v_dma_ops = {
 	.unmap_page			= dma_4v_unmap_page,
 	.map_sg				= dma_4v_map_sg,
 	.unmap_sg			= dma_4v_unmap_sg,
+	.mapping_error			= dma_4v_mapping_error,
 };
 
 static void pci_sun4v_scan_bus(struct pci_pbm_info *pbm, struct device *parent)
-- 
2.11.0

