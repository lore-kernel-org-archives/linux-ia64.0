From: akpm@linux-foundation.org
Date: Tue, 06 Feb 2007 00:20:00 +0000
Subject: [patch 03/13] ia64: swiotlb bug fixes
Message-Id: <200702060021.l160L48p004187@shell0.pdx.osdl.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

From: "Jan Beulich" <jbeulich@novell.com>

This patch fixes
- marking I-cache clean of pages DMAed to now only done for IA64
- broken multiple inclusion in include/asm-x86_64/swiotlb.h
- missing call to mark_clean in swiotlb_sync_sg()
- a (perhaps only theoretical) issue in swiotlb_dma_supported() when
  io_tlb_end is exactly at the end of memory

Signed-off-by: Jan Beulich <jbeulich@novell.com>
Cc: "Luck, Tony" <tony.luck@intel.com>
Cc: Andi Kleen <ak@suse.de>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 arch/ia64/mm/init.c          |   19 +++++++++++++++++++
 include/asm-ia64/dma.h       |    2 ++
 include/asm-x86_64/swiotlb.h |    7 ++++---
 lib/swiotlb.c                |   33 ++++++++-------------------------
 4 files changed, 33 insertions(+), 28 deletions(-)

diff -puN arch/ia64/mm/init.c~ia64-swiotlb-bug-fixes arch/ia64/mm/init.c
--- a/arch/ia64/mm/init.c~ia64-swiotlb-bug-fixes
+++ a/arch/ia64/mm/init.c
@@ -128,6 +128,25 @@ lazy_mmu_prot_update (pte_t pte)
 	set_bit(PG_arch_1, &page->flags);	/* mark page as clean */
 }
 
+/*
+ * Since DMA is i-cache coherent, any (complete) pages that were written via
+ * DMA can be marked as "clean" so that lazy_mmu_prot_update() doesn't have to
+ * flush them when they get mapped into an executable vm-area.
+ */
+void
+dma_mark_clean(void *addr, size_t size)
+{
+	unsigned long pg_addr, end;
+
+	pg_addr = PAGE_ALIGN((unsigned long) addr);
+	end = (unsigned long) addr + size;
+	while (pg_addr + PAGE_SIZE <= end) {
+		struct page *page = virt_to_page(pg_addr);
+		set_bit(PG_arch_1, &page->flags);
+		pg_addr += PAGE_SIZE;
+	}
+}
+
 inline void
 ia64_set_rbs_bot (void)
 {
diff -puN include/asm-ia64/dma.h~ia64-swiotlb-bug-fixes include/asm-ia64/dma.h
--- a/include/asm-ia64/dma.h~ia64-swiotlb-bug-fixes
+++ a/include/asm-ia64/dma.h
@@ -19,4 +19,6 @@ extern unsigned long MAX_DMA_ADDRESS;
 
 #define free_dma(x)
 
+void dma_mark_clean(void *addr, size_t size);
+
 #endif /* _ASM_IA64_DMA_H */
diff -puN include/asm-x86_64/swiotlb.h~ia64-swiotlb-bug-fixes include/asm-x86_64/swiotlb.h
--- a/include/asm-x86_64/swiotlb.h~ia64-swiotlb-bug-fixes
+++ a/include/asm-x86_64/swiotlb.h
@@ -1,6 +1,5 @@
 #ifndef _ASM_SWIOTLB_H
-#define _ASM_SWTIOLB_H 1
-
+#define _ASM_SWIOTLB_H 1
 
 #include <asm/dma-mapping.h>
 
@@ -52,4 +51,6 @@ extern int swiotlb;
 
 extern void pci_swiotlb_init(void);
 
-#endif /* _ASM_SWTIOLB_H */
+static inline void dma_mark_clean(void *addr, size_t size) {}
+
+#endif /* _ASM_SWIOTLB_H */
diff -puN lib/swiotlb.c~ia64-swiotlb-bug-fixes lib/swiotlb.c
--- a/lib/swiotlb.c~ia64-swiotlb-bug-fixes
+++ a/lib/swiotlb.c
@@ -558,25 +558,6 @@ swiotlb_map_single(struct device *hwdev,
 }
 
 /*
- * Since DMA is i-cache coherent, any (complete) pages that were written via
- * DMA can be marked as "clean" so that lazy_mmu_prot_update() doesn't have to
- * flush them when they get mapped into an executable vm-area.
- */
-static void
-mark_clean(void *addr, size_t size)
-{
-	unsigned long pg_addr, end;
-
-	pg_addr = PAGE_ALIGN((unsigned long) addr);
-	end = (unsigned long) addr + size;
-	while (pg_addr + PAGE_SIZE <= end) {
-		struct page *page = virt_to_page(pg_addr);
-		set_bit(PG_arch_1, &page->flags);
-		pg_addr += PAGE_SIZE;
-	}
-}
-
-/*
  * Unmap a single streaming mode DMA translation.  The dma_addr and size must
  * match what was provided for in a previous swiotlb_map_single call.  All
  * other usages are undefined.
@@ -594,7 +575,7 @@ swiotlb_unmap_single(struct device *hwde
 	if (dma_addr >= io_tlb_start && dma_addr < io_tlb_end)
 		unmap_single(hwdev, dma_addr, size, dir);
 	else if (dir = DMA_FROM_DEVICE)
-		mark_clean(dma_addr, size);
+		dma_mark_clean(dma_addr, size);
 }
 
 /*
@@ -617,7 +598,7 @@ swiotlb_sync_single(struct device *hwdev
 	if (dma_addr >= io_tlb_start && dma_addr < io_tlb_end)
 		sync_single(hwdev, dma_addr, size, dir, target);
 	else if (dir = DMA_FROM_DEVICE)
-		mark_clean(dma_addr, size);
+		dma_mark_clean(dma_addr, size);
 }
 
 void
@@ -648,7 +629,7 @@ swiotlb_sync_single_range(struct device 
 	if (dma_addr >= io_tlb_start && dma_addr < io_tlb_end)
 		sync_single(hwdev, dma_addr, size, dir, target);
 	else if (dir = DMA_FROM_DEVICE)
-		mark_clean(dma_addr, size);
+		dma_mark_clean(dma_addr, size);
 }
 
 void
@@ -698,7 +679,6 @@ swiotlb_map_sg(struct device *hwdev, str
 		dev_addr = virt_to_phys(addr);
 		if (swiotlb_force || address_needs_mapping(hwdev, dev_addr)) {
 			void *map = map_single(hwdev, addr, sg->length, dir);
-			sg->dma_address = virt_to_bus(map);
 			if (!map) {
 				/* Don't panic here, we expect map_sg users
 				   to do proper error handling. */
@@ -707,6 +687,7 @@ swiotlb_map_sg(struct device *hwdev, str
 				sg[0].dma_length = 0;
 				return 0;
 			}
+			sg->dma_address = virt_to_bus(map);
 		} else
 			sg->dma_address = dev_addr;
 		sg->dma_length = sg->length;
@@ -730,7 +711,7 @@ swiotlb_unmap_sg(struct device *hwdev, s
 		if (sg->dma_address != SG_ENT_PHYS_ADDRESS(sg))
 			unmap_single(hwdev, (void *) phys_to_virt(sg->dma_address), sg->dma_length, dir);
 		else if (dir = DMA_FROM_DEVICE)
-			mark_clean(SG_ENT_VIRT_ADDRESS(sg), sg->dma_length);
+			dma_mark_clean(SG_ENT_VIRT_ADDRESS(sg), sg->dma_length);
 }
 
 /*
@@ -752,6 +733,8 @@ swiotlb_sync_sg(struct device *hwdev, st
 		if (sg->dma_address != SG_ENT_PHYS_ADDRESS(sg))
 			sync_single(hwdev, phys_to_virt(sg->dma_address),
 				    sg->dma_length, dir, target);
+		else if (dir = DMA_FROM_DEVICE)
+			dma_mark_clean(SG_ENT_VIRT_ADDRESS(sg), sg->dma_length);
 }
 
 void
@@ -783,7 +766,7 @@ swiotlb_dma_mapping_error(dma_addr_t dma
 int
 swiotlb_dma_supported (struct device *hwdev, u64 mask)
 {
-	return (virt_to_phys (io_tlb_end) - 1) <= mask;
+	return virt_to_phys(io_tlb_end - 1) <= mask;
 }
 
 EXPORT_SYMBOL(swiotlb_init);
_
