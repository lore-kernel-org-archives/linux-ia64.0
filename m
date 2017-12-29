From: Christoph Hellwig <hch@lst.de>
Date: Fri, 29 Dec 2017 08:18:13 +0000
Subject: [PATCH 09/67] arc: remove CONFIG_ARC_PLAT_NEEDS_PHYS_TO_DMA
Message-Id: <20171229081911.2802-10-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20171229081911.2802-1-hch@lst.de>
In-Reply-To: <20171229081911.2802-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: iommu@lists.linux-foundation.org
Cc: linux-alpha@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, adi-buildroot-devel@lists.sourceforge.net, linux-c6x-dev@linux-c6x.org, linux-cris-kernel@axis.com, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-metag@vger.kernel.org, Michal Simek <monstr@monstr.eu>, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, patches@groups.riscv.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, Guan Xuetao <gxt@mprc.pku.edu.cn>, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

We always use the stub definitions, so remove the unused other code.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/arc/Kconfig                   |  3 ---
 arch/arc/include/asm/dma-mapping.h |  7 -------
 arch/arc/mm/dma.c                  | 14 +++++++-------
 3 files changed, 7 insertions(+), 17 deletions(-)

diff --git a/arch/arc/Kconfig b/arch/arc/Kconfig
index 9d5fd00d9e91..f3a80cf164cc 100644
--- a/arch/arc/Kconfig
+++ b/arch/arc/Kconfig
@@ -463,9 +463,6 @@ config ARCH_PHYS_ADDR_T_64BIT
 config ARCH_DMA_ADDR_T_64BIT
 	bool
 
-config ARC_PLAT_NEEDS_PHYS_TO_DMA
-	bool
-
 config ARC_KVADDR_SIZE
 	int "Kernel Virtual Address Space size (MB)"
 	range 0 512
diff --git a/arch/arc/include/asm/dma-mapping.h b/arch/arc/include/asm/dma-mapping.h
index 94285031c4fb..7a16824bfe98 100644
--- a/arch/arc/include/asm/dma-mapping.h
+++ b/arch/arc/include/asm/dma-mapping.h
@@ -11,13 +11,6 @@
 #ifndef ASM_ARC_DMA_MAPPING_H
 #define ASM_ARC_DMA_MAPPING_H
 
-#ifndef CONFIG_ARC_PLAT_NEEDS_PHYS_TO_DMA
-#define plat_dma_to_phys(dev, dma_handle) ((phys_addr_t)(dma_handle))
-#define plat_phys_to_dma(dev, paddr) ((dma_addr_t)(paddr))
-#else
-#include <plat/dma.h>
-#endif
-
 extern const struct dma_map_ops arc_dma_ops;
 
 static inline const struct dma_map_ops *get_arch_dma_ops(struct bus_type *bus)
diff --git a/arch/arc/mm/dma.c b/arch/arc/mm/dma.c
index fad18261ef6a..1d405b86250c 100644
--- a/arch/arc/mm/dma.c
+++ b/arch/arc/mm/dma.c
@@ -60,7 +60,7 @@ static void *arc_dma_alloc(struct device *dev, size_t size,
 	/* This is linear addr (0x8000_0000 based) */
 	paddr = page_to_phys(page);
 
-	*dma_handle = plat_phys_to_dma(dev, paddr);
+	*dma_handle = paddr;
 
 	/* This is kernel Virtual address (0x7000_0000 based) */
 	if (need_kvaddr) {
@@ -92,7 +92,7 @@ static void *arc_dma_alloc(struct device *dev, size_t size,
 static void arc_dma_free(struct device *dev, size_t size, void *vaddr,
 		dma_addr_t dma_handle, unsigned long attrs)
 {
-	phys_addr_t paddr = plat_dma_to_phys(dev, dma_handle);
+	phys_addr_t paddr = dma_handle;
 	struct page *page = virt_to_page(paddr);
 	int is_non_coh = 1;
 
@@ -111,7 +111,7 @@ static int arc_dma_mmap(struct device *dev, struct vm_area_struct *vma,
 {
 	unsigned long user_count = vma_pages(vma);
 	unsigned long count = PAGE_ALIGN(size) >> PAGE_SHIFT;
-	unsigned long pfn = __phys_to_pfn(plat_dma_to_phys(dev, dma_addr));
+	unsigned long pfn = __phys_to_pfn(dma_addr);
 	unsigned long off = vma->vm_pgoff;
 	int ret = -ENXIO;
 
@@ -175,7 +175,7 @@ static dma_addr_t arc_dma_map_page(struct device *dev, struct page *page,
 	if (!(attrs & DMA_ATTR_SKIP_CPU_SYNC))
 		_dma_cache_sync(paddr, size, dir);
 
-	return plat_phys_to_dma(dev, paddr);
+	return paddr;
 }
 
 /*
@@ -190,7 +190,7 @@ static void arc_dma_unmap_page(struct device *dev, dma_addr_t handle,
 			       size_t size, enum dma_data_direction dir,
 			       unsigned long attrs)
 {
-	phys_addr_t paddr = plat_dma_to_phys(dev, handle);
+	phys_addr_t paddr = handle;
 
 	if (!(attrs & DMA_ATTR_SKIP_CPU_SYNC))
 		_dma_cache_sync(paddr, size, dir);
@@ -224,13 +224,13 @@ static void arc_dma_unmap_sg(struct device *dev, struct scatterlist *sg,
 static void arc_dma_sync_single_for_cpu(struct device *dev,
 		dma_addr_t dma_handle, size_t size, enum dma_data_direction dir)
 {
-	_dma_cache_sync(plat_dma_to_phys(dev, dma_handle), size, DMA_FROM_DEVICE);
+	_dma_cache_sync(dma_handle, size, DMA_FROM_DEVICE);
 }
 
 static void arc_dma_sync_single_for_device(struct device *dev,
 		dma_addr_t dma_handle, size_t size, enum dma_data_direction dir)
 {
-	_dma_cache_sync(plat_dma_to_phys(dev, dma_handle), size, DMA_TO_DEVICE);
+	_dma_cache_sync(dma_handle, size, DMA_TO_DEVICE);
 }
 
 static void arc_dma_sync_sg_for_cpu(struct device *dev,
-- 
2.14.2

