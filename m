From: Christoph Hellwig <hch@lst.de>
Date: Fri, 07 Dec 2018 19:07:07 +0000
Subject: [PATCH 02/15] swiotlb: remove dma_mark_clean
Message-Id: <20181207190720.18517-3-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20181207190720.18517-1-hch@lst.de>
In-Reply-To: <20181207190720.18517-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: iommu@lists.linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>, Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Tariq Toukan <tariqt@mellanox.com>, Ilias Apalodimas <ilias.apalodimas@linaro.org>, =?UTF-8?q?Toke=20H=C3=B8iland-J=C3=B8rgensen?= <toke@toke.dk>, Robin Murphy <robin.murphy@arm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Keith Busch <keith.busch@intel.com>, Jonathan Derrick <jonathan.derrick@intel.com>, linux-pci@vger.kernel.org, linux-ia64@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org

Instead of providing a special dma_mark_clean hook just for ia64, switch
ia64 to use the normal arch_sync_dma_for_cpu hooks instead.

This means that we now also set the PG_arch_1 bit for pages in the
swiotlb buffer, which isn't stricly needed as we will never execute code
out of the swiotlb buffer, but otherwise harmless.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/ia64/Kconfig              |  3 ++-
 arch/ia64/kernel/dma-mapping.c | 20 +++++++++++++++++++-
 arch/ia64/mm/init.c            | 18 +++++++-----------
 drivers/xen/swiotlb-xen.c      | 20 +-------------------
 include/linux/dma-direct.h     |  8 --------
 kernel/dma/swiotlb.c           | 18 +-----------------
 6 files changed, 30 insertions(+), 57 deletions(-)

diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
index d6f203658994..c587e3316c38 100644
--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
@@ -28,7 +28,8 @@ config IA64
 	select HAVE_ARCH_TRACEHOOK
 	select HAVE_MEMBLOCK_NODE_MAP
 	select HAVE_VIRT_CPU_ACCOUNTING
-	select ARCH_HAS_DMA_MARK_CLEAN
+	select ARCH_HAS_DMA_COHERENT_TO_PFN
+	select ARCH_HAS_SYNC_DMA_FOR_CPU
 	select VIRT_TO_BUS
 	select ARCH_DISCARD_MEMBLOCK
 	select GENERIC_IRQ_PROBE
diff --git a/arch/ia64/kernel/dma-mapping.c b/arch/ia64/kernel/dma-mapping.c
index 7a471d8d67d4..36dd6aa6d759 100644
--- a/arch/ia64/kernel/dma-mapping.c
+++ b/arch/ia64/kernel/dma-mapping.c
@@ -1,5 +1,5 @@
 // SPDX-License-Identifier: GPL-2.0
-#include <linux/dma-mapping.h>
+#include <linux/dma-direct.h>
 #include <linux/swiotlb.h>
 #include <linux/export.h>
 
@@ -16,6 +16,24 @@ const struct dma_map_ops *dma_get_ops(struct device *dev)
 EXPORT_SYMBOL(dma_get_ops);
 
 #ifdef CONFIG_SWIOTLB
+void *arch_dma_alloc(struct device *dev, size_t size,
+		dma_addr_t *dma_handle, gfp_t gfp, unsigned long attrs)
+{
+	return dma_direct_alloc_pages(dev, size, dma_handle, gfp, attrs);
+}
+
+void arch_dma_free(struct device *dev, size_t size, void *cpu_addr,
+		dma_addr_t dma_addr, unsigned long attrs)
+{
+	dma_direct_free_pages(dev, size, cpu_addr, dma_addr, attrs);
+}
+
+long arch_dma_coherent_to_pfn(struct device *dev, void *cpu_addr,
+		dma_addr_t dma_addr)
+{
+	return page_to_pfn(virt_to_page(cpu_addr));
+}
+
 void __init swiotlb_dma_init(void)
 {
 	dma_ops = &swiotlb_dma_ops;
diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
index d5e12ff1d73c..2c51733f1dfd 100644
--- a/arch/ia64/mm/init.c
+++ b/arch/ia64/mm/init.c
@@ -71,18 +71,14 @@ __ia64_sync_icache_dcache (pte_t pte)
  * DMA can be marked as "clean" so that lazy_mmu_prot_update() doesn't have to
  * flush them when they get mapped into an executable vm-area.
  */
-void
-dma_mark_clean(void *addr, size_t size)
+void arch_sync_dma_for_cpu(struct device *dev, phys_addr_t paddr,
+		size_t size, enum dma_data_direction dir)
 {
-	unsigned long pg_addr, end;
-
-	pg_addr = PAGE_ALIGN((unsigned long) addr);
-	end = (unsigned long) addr + size;
-	while (pg_addr + PAGE_SIZE <= end) {
-		struct page *page = virt_to_page(pg_addr);
-		set_bit(PG_arch_1, &page->flags);
-		pg_addr += PAGE_SIZE;
-	}
+	unsigned long pfn = __phys_to_pfn(paddr);
+
+	do {
+		set_bit(PG_arch_1, &pfn_to_page(pfn)->flags);
+	} while (++pfn <= __phys_to_pfn(paddr + size - 1));
 }
 
 inline void
diff --git a/drivers/xen/swiotlb-xen.c b/drivers/xen/swiotlb-xen.c
index 833e80b46eb2..989cf872b98c 100644
--- a/drivers/xen/swiotlb-xen.c
+++ b/drivers/xen/swiotlb-xen.c
@@ -441,21 +441,8 @@ static void xen_unmap_single(struct device *hwdev, dma_addr_t dev_addr,
 	xen_dma_unmap_page(hwdev, dev_addr, size, dir, attrs);
 
 	/* NOTE: We use dev_addr here, not paddr! */
-	if (is_xen_swiotlb_buffer(dev_addr)) {
+	if (is_xen_swiotlb_buffer(dev_addr))
 		swiotlb_tbl_unmap_single(hwdev, paddr, size, dir, attrs);
-		return;
-	}
-
-	if (dir != DMA_FROM_DEVICE)
-		return;
-
-	/*
-	 * phys_to_virt doesn't work with hihgmem page but we could
-	 * call dma_mark_clean() with hihgmem page here. However, we
-	 * are fine since dma_mark_clean() is null on POWERPC. We can
-	 * make dma_mark_clean() take a physical address if necessary.
-	 */
-	dma_mark_clean(phys_to_virt(paddr), size);
 }
 
 static void xen_swiotlb_unmap_page(struct device *hwdev, dma_addr_t dev_addr,
@@ -493,11 +480,6 @@ xen_swiotlb_sync_single(struct device *hwdev, dma_addr_t dev_addr,
 
 	if (target = SYNC_FOR_DEVICE)
 		xen_dma_sync_single_for_device(hwdev, dev_addr, size, dir);
-
-	if (dir != DMA_FROM_DEVICE)
-		return;
-
-	dma_mark_clean(phys_to_virt(paddr), size);
 }
 
 void
diff --git a/include/linux/dma-direct.h b/include/linux/dma-direct.h
index 6e5a47ae7d64..1aa73f4907ae 100644
--- a/include/linux/dma-direct.h
+++ b/include/linux/dma-direct.h
@@ -48,14 +48,6 @@ static inline phys_addr_t dma_to_phys(struct device *dev, dma_addr_t daddr)
 	return __sme_clr(__dma_to_phys(dev, daddr));
 }
 
-#ifdef CONFIG_ARCH_HAS_DMA_MARK_CLEAN
-void dma_mark_clean(void *addr, size_t size);
-#else
-static inline void dma_mark_clean(void *addr, size_t size)
-{
-}
-#endif /* CONFIG_ARCH_HAS_DMA_MARK_CLEAN */
-
 u64 dma_direct_get_required_mask(struct device *dev);
 void *dma_direct_alloc(struct device *dev, size_t size, dma_addr_t *dma_handle,
 		gfp_t gfp, unsigned long attrs);
diff --git a/kernel/dma/swiotlb.c b/kernel/dma/swiotlb.c
index 19ba8e473d71..2e126bac5d7d 100644
--- a/kernel/dma/swiotlb.c
+++ b/kernel/dma/swiotlb.c
@@ -706,21 +706,8 @@ void swiotlb_unmap_page(struct device *hwdev, dma_addr_t dev_addr,
 	    (attrs & DMA_ATTR_SKIP_CPU_SYNC) = 0)
 		arch_sync_dma_for_cpu(hwdev, paddr, size, dir);
 
-	if (is_swiotlb_buffer(paddr)) {
+	if (is_swiotlb_buffer(paddr))
 		swiotlb_tbl_unmap_single(hwdev, paddr, size, dir, attrs);
-		return;
-	}
-
-	if (dir != DMA_FROM_DEVICE)
-		return;
-
-	/*
-	 * phys_to_virt doesn't work with hihgmem page but we could
-	 * call dma_mark_clean() with hihgmem page here. However, we
-	 * are fine since dma_mark_clean() is null on POWERPC. We can
-	 * make dma_mark_clean() take a physical address if necessary.
-	 */
-	dma_mark_clean(phys_to_virt(paddr), size);
 }
 
 /*
@@ -750,9 +737,6 @@ swiotlb_sync_single(struct device *hwdev, dma_addr_t dev_addr,
 
 	if (!dev_is_dma_coherent(hwdev) && target = SYNC_FOR_DEVICE)
 		arch_sync_dma_for_device(hwdev, paddr, size, dir);
-
-	if (!is_swiotlb_buffer(paddr) && dir = DMA_FROM_DEVICE)
-		dma_mark_clean(phys_to_virt(paddr), size);
 }
 
 void
-- 
2.19.1
