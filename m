From: Tony Luck <tony.luck@intel.com>
Date: Fri, 04 Jan 2019 21:03:08 +0000
Subject: [PATCH:Linus please apply] ia64: fix compile without swiotlb
Message-Id: <20190104210308.7657-1-tony.luck@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

From: Christoph Hellwig <hch@lst.de>

Some non-generic ia64 configs don't build swiotlb, and thus should not
pull in the generic non-coherent DMA infrastructure.

Fixes: 68c608345c ("swiotlb: remove dma_mark_clean")
Reported-by: Tony Luck <tony.luck@gmail.com>
Signed-off-by: Christoph Hellwig <hch@lst.de>
Signed-off-by: Tony Luck <tony.luck@intel.com>
---
 arch/ia64/Kconfig   | 2 +-
 arch/ia64/mm/init.c | 2 ++
 2 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
index ccd56f5df8cd..8d7396bd1790 100644
--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
@@ -31,7 +31,7 @@ config IA64
 	select HAVE_MEMBLOCK_NODE_MAP
 	select HAVE_VIRT_CPU_ACCOUNTING
 	select ARCH_HAS_DMA_COHERENT_TO_PFN if SWIOTLB
-	select ARCH_HAS_SYNC_DMA_FOR_CPU
+	select ARCH_HAS_SYNC_DMA_FOR_CPU if SWIOTLB
 	select VIRT_TO_BUS
 	select ARCH_DISCARD_MEMBLOCK
 	select GENERIC_IRQ_PROBE
diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
index 055382622f07..29d841525ca1 100644
--- a/arch/ia64/mm/init.c
+++ b/arch/ia64/mm/init.c
@@ -67,6 +67,7 @@ __ia64_sync_icache_dcache (pte_t pte)
 	set_bit(PG_arch_1, &page->flags);	/* mark page as clean */
 }
 
+#ifdef CONFIG_SWIOTLB
 /*
  * Since DMA is i-cache coherent, any (complete) pages that were written via
  * DMA can be marked as "clean" so that lazy_mmu_prot_update() doesn't have to
@@ -81,6 +82,7 @@ void arch_sync_dma_for_cpu(struct device *dev, phys_addr_t paddr,
 		set_bit(PG_arch_1, &pfn_to_page(pfn)->flags);
 	} while (++pfn <= PHYS_PFN(paddr + size - 1));
 }
+#endif
 
 inline void
 ia64_set_rbs_bot (void)
-- 
2.19.1
