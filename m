From: Christoph Hellwig <hch@lst.de>
Date: Tue, 13 Aug 2019 07:25:13 +0000
Subject: [PATCH 27/28] ia64: remove CONFIG_SWIOTLB ifdefs
Message-Id: <20190813072514.23299-28-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190813072514.23299-1-hch@lst.de>
In-Reply-To: <20190813072514.23299-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Mike Travis <mike.travis@hpe.com>, Dimitri Sivanich <sivanich@hpe.com>
Cc: Arnd Bergmann <arnd@arndb.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-ia64@vger.kernel.org, linux-ide@vger.kernel.org, linux-scsi@vger.kernel.org, linux-kernel@vger.kernel.org

CONFIG_SWIOTLB is now unconditionally selected on ia64, so remove the
ifdefs.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/ia64/kernel/dma-mapping.c | 2 --
 arch/ia64/mm/init.c            | 2 --
 2 files changed, 4 deletions(-)

diff --git a/arch/ia64/kernel/dma-mapping.c b/arch/ia64/kernel/dma-mapping.c
index 53aaa8597920..4a3262795890 100644
--- a/arch/ia64/kernel/dma-mapping.c
+++ b/arch/ia64/kernel/dma-mapping.c
@@ -8,7 +8,6 @@ int iommu_detected __read_mostly;
 const struct dma_map_ops *dma_ops;
 EXPORT_SYMBOL(dma_ops);
 
-#ifdef CONFIG_SWIOTLB
 void *arch_dma_alloc(struct device *dev, size_t size,
 		dma_addr_t *dma_handle, gfp_t gfp, unsigned long attrs)
 {
@@ -26,4 +25,3 @@ long arch_dma_coherent_to_pfn(struct device *dev, void *cpu_addr,
 {
 	return page_to_pfn(virt_to_page(cpu_addr));
 }
-#endif
diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
index 1979cdb61d7c..678b98a09c85 100644
--- a/arch/ia64/mm/init.c
+++ b/arch/ia64/mm/init.c
@@ -68,7 +68,6 @@ __ia64_sync_icache_dcache (pte_t pte)
 	set_bit(PG_arch_1, &page->flags);	/* mark page as clean */
 }
 
-#ifdef CONFIG_SWIOTLB
 /*
  * Since DMA is i-cache coherent, any (complete) pages that were written via
  * DMA can be marked as "clean" so that lazy_mmu_prot_update() doesn't have to
@@ -83,7 +82,6 @@ void arch_sync_dma_for_cpu(struct device *dev, phys_addr_t paddr,
 		set_bit(PG_arch_1, &pfn_to_page(pfn)->flags);
 	} while (++pfn <= PHYS_PFN(paddr + size - 1));
 }
-#endif
 
 inline void
 ia64_set_rbs_bot (void)
-- 
2.20.1
