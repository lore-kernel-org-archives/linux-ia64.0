From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Date: Fri, 10 Jul 2009 01:04:50 +0000
Subject: [PATCH 01/15] swiotlb: remove unused swiotlb_alloc_boot()
Message-Id: <1247187904-31999-2-git-send-email-fujita.tomonori@lab.ntt.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <1247187904-31999-1-git-send-email-fujita.tomonori@lab.ntt.co.jp>
In-Reply-To: <1247187904-31999-1-git-send-email-fujita.tomonori@lab.ntt.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: linux-ia64@vger.kernel.org, linuxppc-dev@ozlabs.org, benh@kernel.crashing.org, tony.luck@intel.com, x86@kernel.org, fujita.tomonori@lab.ntt.co.jp, beckyb@kernel.crashing.org

Nobody uses swiotlb_alloc_boot().

Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
---
 arch/x86/kernel/pci-swiotlb.c |    5 -----
 include/linux/swiotlb.h       |    2 --
 lib/swiotlb.c                 |    7 +------
 3 files changed, 1 insertions(+), 13 deletions(-)

diff --git a/arch/x86/kernel/pci-swiotlb.c b/arch/x86/kernel/pci-swiotlb.c
index 6af96ee..0ac7cd5 100644
--- a/arch/x86/kernel/pci-swiotlb.c
+++ b/arch/x86/kernel/pci-swiotlb.c
@@ -13,11 +13,6 @@
 
 int swiotlb __read_mostly;
 
-void * __init swiotlb_alloc_boot(size_t size, unsigned long nslabs)
-{
-	return alloc_bootmem_low_pages(size);
-}
-
 void *swiotlb_alloc(unsigned order, unsigned long nslabs)
 {
 	return (void *)__get_free_pages(GFP_DMA | __GFP_NOWARN, order);
diff --git a/include/linux/swiotlb.h b/include/linux/swiotlb.h
index cb1a663..94db704 100644
--- a/include/linux/swiotlb.h
+++ b/include/linux/swiotlb.h
@@ -14,7 +14,6 @@ struct scatterlist;
  */
 #define IO_TLB_SEGSIZE	128
 
-
 /*
  * log of the size of each IO TLB slab.  The number of slabs is command line
  * controllable.
@@ -24,7 +23,6 @@ struct scatterlist;
 extern void
 swiotlb_init(void);
 
-extern void *swiotlb_alloc_boot(size_t bytes, unsigned long nslabs);
 extern void *swiotlb_alloc(unsigned order, unsigned long nslabs);
 
 extern dma_addr_t swiotlb_phys_to_bus(struct device *hwdev,
diff --git a/lib/swiotlb.c b/lib/swiotlb.c
index bffe6d7..9edfdd4 100644
--- a/lib/swiotlb.c
+++ b/lib/swiotlb.c
@@ -114,11 +114,6 @@ setup_io_tlb_npages(char *str)
 __setup("swiotlb=", setup_io_tlb_npages);
 /* make io_tlb_overflow tunable too? */
 
-void * __weak __init swiotlb_alloc_boot(size_t size, unsigned long nslabs)
-{
-	return alloc_bootmem_low_pages(size);
-}
-
 void * __weak swiotlb_alloc(unsigned order, unsigned long nslabs)
 {
 	return (void *)__get_free_pages(GFP_DMA | __GFP_NOWARN, order);
@@ -189,7 +184,7 @@ swiotlb_init_with_default_size(size_t default_size)
 	/*
 	 * Get IO TLB memory from the low pages
 	 */
-	io_tlb_start = swiotlb_alloc_boot(bytes, io_tlb_nslabs);
+	io_tlb_start = alloc_bootmem_low_pages(bytes);
 	if (!io_tlb_start)
 		panic("Cannot allocate SWIOTLB buffer");
 	io_tlb_end = io_tlb_start + bytes;
-- 
1.6.0.6

