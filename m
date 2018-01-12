From: Christoph Hellwig <hch@lst.de>
Date: Fri, 12 Jan 2018 08:42:29 +0000
Subject: [PATCH 31/34] dma-direct: make dma_direct_{alloc,free} available to other implementations
Message-Id: <20180112084232.2857-32-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180112084232.2857-1-hch@lst.de>
In-Reply-To: <20180112084232.2857-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: iommu@lists.linux-foundation.org
Cc: Konrad Rzeszutek Wilk <konrad@darnok.org>, linux-alpha@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-c6x-dev@linux-c6x.org, linux-cris-kernel@axis.com, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-metag@vger.kernel.org, Michal Simek <monstr@monstr.eu>, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, patches@groups.riscv.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, Guan Xuetao <gxt@mprc.pku.edu.cn>, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

So that they don't need to indirect through the operation vector.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Vladimir Murzin <vladimir.murzin@arm.com>
---
 arch/arm/mm/dma-mapping-nommu.c | 9 +++------
 include/linux/dma-direct.h      | 5 +++++
 lib/dma-direct.c                | 6 +++---
 3 files changed, 11 insertions(+), 9 deletions(-)

diff --git a/arch/arm/mm/dma-mapping-nommu.c b/arch/arm/mm/dma-mapping-nommu.c
index 4d8042521e89..619f24a42d09 100644
--- a/arch/arm/mm/dma-mapping-nommu.c
+++ b/arch/arm/mm/dma-mapping-nommu.c
@@ -11,7 +11,7 @@
 
 #include <linux/export.h>
 #include <linux/mm.h>
-#include <linux/dma-mapping.h>
+#include <linux/dma-direct.h>
 #include <linux/scatterlist.h>
 
 #include <asm/cachetype.h>
@@ -39,7 +39,6 @@ static void *arm_nommu_dma_alloc(struct device *dev, size_t size,
 				 unsigned long attrs)
 
 {
-	const struct dma_map_ops *ops = &dma_direct_ops;
 	void *ret;
 
 	/*
@@ -48,7 +47,7 @@ static void *arm_nommu_dma_alloc(struct device *dev, size_t size,
 	 */
 
 	if (attrs & DMA_ATTR_NON_CONSISTENT)
-		return ops->alloc(dev, size, dma_handle, gfp, attrs);
+		return dma_direct_alloc(dev, size, dma_handle, gfp, attrs);
 
 	ret = dma_alloc_from_global_coherent(size, dma_handle);
 
@@ -70,10 +69,8 @@ static void arm_nommu_dma_free(struct device *dev, size_t size,
 			       void *cpu_addr, dma_addr_t dma_addr,
 			       unsigned long attrs)
 {
-	const struct dma_map_ops *ops = &dma_direct_ops;
-
 	if (attrs & DMA_ATTR_NON_CONSISTENT) {
-		ops->free(dev, size, cpu_addr, dma_addr, attrs);
+		dma_direct_free(dev, size, cpu_addr, dma_addr, attrs);
 	} else {
 		int ret = dma_release_from_global_coherent(get_order(size),
 							   cpu_addr);
diff --git a/include/linux/dma-direct.h b/include/linux/dma-direct.h
index 10e924b7cba7..4788bf0bf683 100644
--- a/include/linux/dma-direct.h
+++ b/include/linux/dma-direct.h
@@ -38,4 +38,9 @@ static inline void dma_mark_clean(void *addr, size_t size)
 }
 #endif /* CONFIG_ARCH_HAS_DMA_MARK_CLEAN */
 
+void *dma_direct_alloc(struct device *dev, size_t size, dma_addr_t *dma_handle,
+		gfp_t gfp, unsigned long attrs);
+void dma_direct_free(struct device *dev, size_t size, void *cpu_addr,
+		dma_addr_t dma_addr, unsigned long attrs);
+
 #endif /* _LINUX_DMA_DIRECT_H */
diff --git a/lib/dma-direct.c b/lib/dma-direct.c
index 4e43c2bb7f5f..784a68dfdbe3 100644
--- a/lib/dma-direct.c
+++ b/lib/dma-direct.c
@@ -40,8 +40,8 @@ static bool dma_coherent_ok(struct device *dev, phys_addr_t phys, size_t size)
 	return phys_to_dma(dev, phys) + size - 1 <= dev->coherent_dma_mask;
 }
 
-static void *dma_direct_alloc(struct device *dev, size_t size,
-		dma_addr_t *dma_handle, gfp_t gfp, unsigned long attrs)
+void *dma_direct_alloc(struct device *dev, size_t size, dma_addr_t *dma_handle,
+		gfp_t gfp, unsigned long attrs)
 {
 	unsigned int count = PAGE_ALIGN(size) >> PAGE_SHIFT;
 	int page_order = get_order(size);
@@ -84,7 +84,7 @@ static void *dma_direct_alloc(struct device *dev, size_t size,
 	return page_address(page);
 }
 
-static void dma_direct_free(struct device *dev, size_t size, void *cpu_addr,
+void dma_direct_free(struct device *dev, size_t size, void *cpu_addr,
 		dma_addr_t dma_addr, unsigned long attrs)
 {
 	unsigned int count = PAGE_ALIGN(size) >> PAGE_SHIFT;
-- 
2.14.2

