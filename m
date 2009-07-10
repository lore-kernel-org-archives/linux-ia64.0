From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Date: Fri, 10 Jul 2009 01:04:51 +0000
Subject: [PATCH 02/15] swiotlb: remove unused swiotlb_alloc()
Message-Id: <1247187904-31999-3-git-send-email-fujita.tomonori@lab.ntt.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <1247187904-31999-1-git-send-email-fujita.tomonori@lab.ntt.co.jp>
In-Reply-To: <1247187904-31999-1-git-send-email-fujita.tomonori@lab.ntt.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: linux-ia64@vger.kernel.org, linuxppc-dev@ozlabs.org, benh@kernel.crashing.org, tony.luck@intel.com, x86@kernel.org, fujita.tomonori@lab.ntt.co.jp, beckyb@kernel.crashing.org

Nobody uses swiotlb_alloc().

Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
---
 arch/x86/kernel/pci-swiotlb.c |    5 -----
 include/linux/swiotlb.h       |    2 --
 lib/swiotlb.c                 |    8 ++------
 3 files changed, 2 insertions(+), 13 deletions(-)

diff --git a/arch/x86/kernel/pci-swiotlb.c b/arch/x86/kernel/pci-swiotlb.c
index 0ac7cd5..ea675cf 100644
--- a/arch/x86/kernel/pci-swiotlb.c
+++ b/arch/x86/kernel/pci-swiotlb.c
@@ -13,11 +13,6 @@
 
 int swiotlb __read_mostly;
 
-void *swiotlb_alloc(unsigned order, unsigned long nslabs)
-{
-	return (void *)__get_free_pages(GFP_DMA | __GFP_NOWARN, order);
-}
-
 dma_addr_t swiotlb_phys_to_bus(struct device *hwdev, phys_addr_t paddr)
 {
 	return paddr;
diff --git a/include/linux/swiotlb.h b/include/linux/swiotlb.h
index 94db704..6bc5094 100644
--- a/include/linux/swiotlb.h
+++ b/include/linux/swiotlb.h
@@ -23,8 +23,6 @@ struct scatterlist;
 extern void
 swiotlb_init(void);
 
-extern void *swiotlb_alloc(unsigned order, unsigned long nslabs);
-
 extern dma_addr_t swiotlb_phys_to_bus(struct device *hwdev,
 				      phys_addr_t address);
 extern phys_addr_t swiotlb_bus_to_phys(struct device *hwdev,
diff --git a/lib/swiotlb.c b/lib/swiotlb.c
index 9edfdd4..3c4c21c 100644
--- a/lib/swiotlb.c
+++ b/lib/swiotlb.c
@@ -114,11 +114,6 @@ setup_io_tlb_npages(char *str)
 __setup("swiotlb=", setup_io_tlb_npages);
 /* make io_tlb_overflow tunable too? */
 
-void * __weak swiotlb_alloc(unsigned order, unsigned long nslabs)
-{
-	return (void *)__get_free_pages(GFP_DMA | __GFP_NOWARN, order);
-}
-
 dma_addr_t __weak swiotlb_phys_to_bus(struct device *hwdev, phys_addr_t paddr)
 {
 	return paddr;
@@ -240,7 +235,8 @@ swiotlb_late_init_with_default_size(size_t default_size)
 	bytes = io_tlb_nslabs << IO_TLB_SHIFT;
 
 	while ((SLABS_PER_PAGE << order) > IO_TLB_MIN_SLABS) {
-		io_tlb_start = swiotlb_alloc(order, io_tlb_nslabs);
+		io_tlb_start = (void *)__get_free_pages(GFP_DMA | __GFP_NOWARN,
+							order);
 		if (io_tlb_start)
 			break;
 		order--;
-- 
1.6.0.6

