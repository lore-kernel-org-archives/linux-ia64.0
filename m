From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Date: Fri, 10 Jul 2009 01:04:52 +0000
Subject: [PATCH 03/15] swiotlb: remove swiotlb_arch_range_needs_mapping
Message-Id: <1247187904-31999-4-git-send-email-fujita.tomonori@lab.ntt.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <1247187904-31999-1-git-send-email-fujita.tomonori@lab.ntt.co.jp>
In-Reply-To: <1247187904-31999-1-git-send-email-fujita.tomonori@lab.ntt.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: linux-ia64@vger.kernel.org, linuxppc-dev@ozlabs.org, benh@kernel.crashing.org, tony.luck@intel.com, x86@kernel.org, fujita.tomonori@lab.ntt.co.jp, beckyb@kernel.crashing.org

Nobody uses swiotlb_arch_range_needs_mapping().

Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
---
 arch/x86/kernel/pci-swiotlb.c |    5 -----
 include/linux/swiotlb.h       |    2 --
 lib/swiotlb.c                 |   15 ++-------------
 3 files changed, 2 insertions(+), 20 deletions(-)

diff --git a/arch/x86/kernel/pci-swiotlb.c b/arch/x86/kernel/pci-swiotlb.c
index ea675cf..165bd7f 100644
--- a/arch/x86/kernel/pci-swiotlb.c
+++ b/arch/x86/kernel/pci-swiotlb.c
@@ -23,11 +23,6 @@ phys_addr_t swiotlb_bus_to_phys(struct device *hwdev, dma_addr_t baddr)
 	return baddr;
 }
 
-int __weak swiotlb_arch_range_needs_mapping(phys_addr_t paddr, size_t size)
-{
-	return 0;
-}
-
 static void *x86_swiotlb_alloc_coherent(struct device *hwdev, size_t size,
 					dma_addr_t *dma_handle, gfp_t flags)
 {
diff --git a/include/linux/swiotlb.h b/include/linux/swiotlb.h
index 6bc5094..a977da2 100644
--- a/include/linux/swiotlb.h
+++ b/include/linux/swiotlb.h
@@ -28,8 +28,6 @@ extern dma_addr_t swiotlb_phys_to_bus(struct device *hwdev,
 extern phys_addr_t swiotlb_bus_to_phys(struct device *hwdev,
 				       dma_addr_t address);
 
-extern int swiotlb_arch_range_needs_mapping(phys_addr_t paddr, size_t size);
-
 extern void
 *swiotlb_alloc_coherent(struct device *hwdev, size_t size,
 			dma_addr_t *dma_handle, gfp_t flags);
diff --git a/lib/swiotlb.c b/lib/swiotlb.c
index 3c4c21c..dc1cd1f 100644
--- a/lib/swiotlb.c
+++ b/lib/swiotlb.c
@@ -141,11 +141,6 @@ int __weak swiotlb_arch_address_needs_mapping(struct device *hwdev,
 	return !is_buffer_dma_capable(dma_get_mask(hwdev), addr, size);
 }
 
-int __weak swiotlb_arch_range_needs_mapping(phys_addr_t paddr, size_t size)
-{
-	return 0;
-}
-
 static void swiotlb_print_info(unsigned long bytes)
 {
 	phys_addr_t pstart, pend;
@@ -312,11 +307,6 @@ address_needs_mapping(struct device *hwdev, dma_addr_t addr, size_t size)
 	return swiotlb_arch_address_needs_mapping(hwdev, addr, size);
 }
 
-static inline int range_needs_mapping(phys_addr_t paddr, size_t size)
-{
-	return swiotlb_force || swiotlb_arch_range_needs_mapping(paddr, size);
-}
-
 static int is_swiotlb_buffer(char *addr)
 {
 	return addr >= io_tlb_start && addr < io_tlb_end;
@@ -646,8 +636,7 @@ dma_addr_t swiotlb_map_page(struct device *dev, struct page *page,
 	 * we can safely return the device addr and not worry about bounce
 	 * buffering it.
 	 */
-	if (!address_needs_mapping(dev, dev_addr, size) &&
-	    !range_needs_mapping(phys, size))
+	if (!address_needs_mapping(dev, dev_addr, size) && !swiotlb_force)
 		return dev_addr;
 
 	/*
@@ -810,7 +799,7 @@ swiotlb_map_sg_attrs(struct device *hwdev, struct scatterlist *sgl, int nelems,
 		phys_addr_t paddr = sg_phys(sg);
 		dma_addr_t dev_addr = swiotlb_phys_to_bus(hwdev, paddr);
 
-		if (range_needs_mapping(paddr, sg->length) ||
+		if (swiotlb_force ||
 		    address_needs_mapping(hwdev, dev_addr, sg->length)) {
 			void *map = map_single(hwdev, sg_phys(sg),
 					       sg->length, dir);
-- 
1.6.0.6

