From: Ian Campbell <ian.campbell@citrix.com>
Date: Mon, 01 Jun 2009 15:32:59 +0000
Subject: [PATCH 07/11] swiotlb: use dma_map_range
Message-Id: <1243870383-12954-8-git-send-email-ian.campbell@citrix.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1243870383-12954-1-git-send-email-ian.campbell@citrix.com>
In-Reply-To: <1243870383-12954-1-git-send-email-ian.campbell@citrix.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Ian Campbell <ian.campbell@citrix.com>, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, Jeremy Fitzhardinge <jeremy@goop.org>, Olaf Kirch <okir@suse.de>, Greg KH <gregkh@suse.de>, Tony Luck <tony.luck@intel.com>, Becky Bruce <beckyb@kernel.crashing.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Kumar Gala <galak@kernel.crashing.org>, x86@kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@ozlabs.org

This replaces usages of address_needs_mapping, range_needs_mapping and
is_buffer_dma_capable and the __weak architecture hooks to those
functions with a more flexible single function.

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Cc: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: Olaf Kirch <okir@suse.de>
Cc: Greg KH <gregkh@suse.de>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Becky Bruce <beckyb@kernel.crashing.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Kumar Gala <galak@kernel.crashing.org>
Cc: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: x86@kernel.org
Cc: linux-ia64@vger.kernel.org
Cc: linuxppc-dev@ozlabs.org
---
 arch/x86/kernel/pci-swiotlb.c |    5 ---
 include/linux/dma-mapping.h   |    5 ---
 include/linux/swiotlb.h       |    2 -
 lib/swiotlb.c                 |   59 +++++++++++++---------------------------
 4 files changed, 19 insertions(+), 52 deletions(-)

diff --git a/arch/x86/kernel/pci-swiotlb.c b/arch/x86/kernel/pci-swiotlb.c
index e89cf99..fdcc0e2 100644
--- a/arch/x86/kernel/pci-swiotlb.c
+++ b/arch/x86/kernel/pci-swiotlb.c
@@ -23,11 +23,6 @@ void *swiotlb_alloc(unsigned order, unsigned long nslabs)
 	return (void *)__get_free_pages(GFP_DMA | __GFP_NOWARN, order);
 }
 
-int __weak swiotlb_arch_range_needs_mapping(phys_addr_t paddr, size_t size)
-{
-	return 0;
-}
-
 static void *x86_swiotlb_alloc_coherent(struct device *hwdev, size_t size,
 					dma_addr_t *dma_handle, gfp_t flags)
 {
diff --git a/include/linux/dma-mapping.h b/include/linux/dma-mapping.h
index 8083b6a..85dafa1 100644
--- a/include/linux/dma-mapping.h
+++ b/include/linux/dma-mapping.h
@@ -96,11 +96,6 @@ static inline int is_device_dma_capable(struct device *dev)
 	return dev->dma_mask != NULL && *dev->dma_mask != DMA_MASK_NONE;
 }
 
-static inline int is_buffer_dma_capable(u64 mask, dma_addr_t addr, size_t size)
-{
-	return addr + size <= mask;
-}
-
 #ifdef CONFIG_HAS_DMA
 #include <asm/dma-mapping.h>
 #else
diff --git a/include/linux/swiotlb.h b/include/linux/swiotlb.h
index 954feec..1b56dbf 100644
--- a/include/linux/swiotlb.h
+++ b/include/linux/swiotlb.h
@@ -27,8 +27,6 @@ swiotlb_init(void);
 extern void *swiotlb_alloc_boot(size_t bytes, unsigned long nslabs);
 extern void *swiotlb_alloc(unsigned order, unsigned long nslabs);
 
-extern int swiotlb_arch_range_needs_mapping(phys_addr_t paddr, size_t size);
-
 extern void
 *swiotlb_alloc_coherent(struct device *hwdev, size_t size,
 			dma_addr_t *dma_handle, gfp_t flags);
diff --git a/lib/swiotlb.c b/lib/swiotlb.c
index baa1991..d37499b 100644
--- a/lib/swiotlb.c
+++ b/lib/swiotlb.c
@@ -135,17 +135,6 @@ void * __weak swiotlb_bus_to_virt(struct device *hwdev, dma_addr_t address)
 	return phys_to_virt(dma_to_phys(hwdev, address));
 }
 
-int __weak swiotlb_arch_address_needs_mapping(struct device *hwdev,
-					       dma_addr_t addr, size_t size)
-{
-	return !is_buffer_dma_capable(dma_get_mask(hwdev), addr, size);
-}
-
-int __weak swiotlb_arch_range_needs_mapping(phys_addr_t paddr, size_t size)
-{
-	return 0;
-}
-
 static void swiotlb_print_info(unsigned long bytes)
 {
 	phys_addr_t pstart, pend;
@@ -305,17 +294,6 @@ cleanup1:
 	return -ENOMEM;
 }
 
-static inline int
-address_needs_mapping(struct device *hwdev, dma_addr_t addr, size_t size)
-{
-	return swiotlb_arch_address_needs_mapping(hwdev, addr, size);
-}
-
-static inline int range_needs_mapping(phys_addr_t paddr, size_t size)
-{
-	return swiotlb_force || swiotlb_arch_range_needs_mapping(paddr, size);
-}
-
 static int is_swiotlb_buffer(char *addr)
 {
 	return addr >= io_tlb_start && addr < io_tlb_end;
@@ -542,7 +520,7 @@ void *
 swiotlb_alloc_coherent(struct device *hwdev, size_t size,
 		       dma_addr_t *dma_handle, gfp_t flags)
 {
-	dma_addr_t dev_addr;
+	phys_addr_t phys;
 	void *ret;
 	int order = get_order(size);
 	u64 dma_mask = DMA_BIT_MASK(32);
@@ -551,9 +529,8 @@ swiotlb_alloc_coherent(struct device *hwdev, size_t size,
 		dma_mask = hwdev->coherent_dma_mask;
 
 	ret = (void *)__get_free_pages(flags, order);
-	if (ret &&
-	    !is_buffer_dma_capable(dma_mask, swiotlb_virt_to_bus(hwdev, ret),
-				   size)) {
+	if (ret && !dma_map_range(hwdev, dma_mask, virt_to_phys(ret),
+				  size, dma_handle)) {
 		/*
 		 * The allocated memory isn't reachable by the device.
 		 */
@@ -572,19 +549,19 @@ swiotlb_alloc_coherent(struct device *hwdev, size_t size,
 	}
 
 	memset(ret, 0, size);
-	dev_addr = swiotlb_virt_to_bus(hwdev, ret);
+	phys = virt_to_phys(ret);
 
 	/* Confirm address can be DMA'd by device */
-	if (!is_buffer_dma_capable(dma_mask, dev_addr, size)) {
-		printk("hwdev DMA mask = 0x%016Lx, dev_addr = 0x%016Lx\n",
+	if (!dma_map_range(hwdev, dma_mask, phys, size, dma_handle)) {
+		printk(KERN_WARNING "hwdev DMA mask = 0x%016Lx, "
+				    "physical addr = 0x%016Lx\n",
 		       (unsigned long long)dma_mask,
-		       (unsigned long long)dev_addr);
+		       (unsigned long long)phys);
 
 		/* DMA_TO_DEVICE to avoid memcpy in unmap_single */
 		do_unmap_single(hwdev, ret, size, DMA_TO_DEVICE);
 		return NULL;
 	}
-	*dma_handle = dev_addr;
 	return ret;
 }
 EXPORT_SYMBOL(swiotlb_alloc_coherent);
@@ -636,7 +613,7 @@ dma_addr_t swiotlb_map_page(struct device *dev, struct page *page,
 			    struct dma_attrs *attrs)
 {
 	phys_addr_t phys = page_to_phys(page) + offset;
-	dma_addr_t dev_addr = phys_to_dma(dev, phys);
+	dma_addr_t dev_addr;
 	void *map;
 
 	BUG_ON(dir = DMA_NONE);
@@ -645,8 +622,8 @@ dma_addr_t swiotlb_map_page(struct device *dev, struct page *page,
 	 * we can safely return the device addr and not worry about bounce
 	 * buffering it.
 	 */
-	if (!address_needs_mapping(dev, dev_addr, size) &&
-	    !range_needs_mapping(phys, size))
+	if (dma_map_range(dev, dma_get_mask(dev), phys, size, &dev_addr) &&
+	    !swiotlb_force)
 		return dev_addr;
 
 	/*
@@ -658,12 +635,12 @@ dma_addr_t swiotlb_map_page(struct device *dev, struct page *page,
 		map = io_tlb_overflow_buffer;
 	}
 
-	dev_addr = swiotlb_virt_to_bus(dev, map);
+	phys = virt_to_phys(map);
 
 	/*
 	 * Ensure that the address returned is DMA'ble
 	 */
-	if (address_needs_mapping(dev, dev_addr, size))
+	if (!dma_map_range(dev, dma_get_mask(dev), phys, size, &dev_addr))
 		panic("map_single: bounce buffer is not DMA'ble");
 
 	return dev_addr;
@@ -807,10 +784,11 @@ swiotlb_map_sg_attrs(struct device *hwdev, struct scatterlist *sgl, int nelems,
 
 	for_each_sg(sgl, sg, nelems, i) {
 		phys_addr_t paddr = sg_phys(sg);
-		dma_addr_t dev_addr = phys_to_dma(hwdev, paddr);
+		dma_addr_t uninitialized_var(dev_addr);
 
-		if (range_needs_mapping(paddr, sg->length) ||
-		    address_needs_mapping(hwdev, dev_addr, sg->length)) {
+		if (!dma_map_range(hwdev, dma_get_mask(hwdev), dev_addr,
+				   sg->length, &dev_addr) ||
+		    swiotlb_force) {
 			void *map = map_single(hwdev, sg_phys(sg),
 					       sg->length, dir);
 			if (!map) {
@@ -822,7 +800,8 @@ swiotlb_map_sg_attrs(struct device *hwdev, struct scatterlist *sgl, int nelems,
 				sgl[0].dma_length = 0;
 				return 0;
 			}
-			sg->dma_address = swiotlb_virt_to_bus(hwdev, map);
+			paddr = virt_to_phys(map);
+			sg->dma_address = phys_to_dma(hwdev, paddr);
 		} else
 			sg->dma_address = dev_addr;
 		sg->dma_length = sg->length;
-- 
1.5.6.5

