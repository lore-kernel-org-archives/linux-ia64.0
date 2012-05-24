From: Alessandro Rubini <rubini@gnudd.com>
Date: Thu, 24 May 2012 11:44:22 +0000
Subject: [PATCH] swiotlb: add "dma_attrs" argument to alloc and free, to match dma_map_ops
Message-Id: <20120524114422.GA25950@mail.gnudd.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: x86@kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, Giancarlo Asnaghi <giancarlo.asnaghi@st.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Ralf Baechle <ralf@linux-mips.org>, Guan Xuetao <gxt@mprc.pku.edu.cn>, Thomas Gleixner <tglx@linutronix.de>, Kyungmin Park <kyungmin.park@samsung.com>, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

The alloc and free pointers within "struct dma_map_ops" receive a
pointer to dma_attrs that was not present in the generic swiotlb
functions.  For this reason, a few files had a local wrapper for the
free function that just removes the attrs argument before calling the
generic function.

This patch adds the extra argument to generic functions and removes
such wrappers when they are no more needed.  This also fixes a
compiler warning for sta2x11-fixup.c, that would have required yet
another wrapper.

Signed-off-by: Alessandro Rubini <rubini@gnudd.com>
Acked-by: Giancarlo Asnaghi <giancarlo.asnaghi@st.com>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: Ralf Baechle <ralf@linux-mips.org>
Cc: Guan Xuetao <gxt@mprc.pku.edu.cn>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Kyungmin Park <kyungmin.park@samsung.com>
Cc: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
---
 arch/ia64/kernel/pci-swiotlb.c       |   11 ++---------
 arch/mips/cavium-octeon/dma-octeon.c |    4 ++--
 arch/unicore32/mm/dma-swiotlb.c      |   22 ++--------------------
 arch/x86/kernel/pci-swiotlb.c        |   11 ++---------
 arch/x86/pci/sta2x11-fixup.c         |    3 ++-
 include/linux/swiotlb.h              |    7 ++++---
 lib/swiotlb.c                        |    5 +++--
 7 files changed, 17 insertions(+), 46 deletions(-)

diff --git a/arch/ia64/kernel/pci-swiotlb.c b/arch/ia64/kernel/pci-swiotlb.c
index 939260a..cc034c2 100644
--- a/arch/ia64/kernel/pci-swiotlb.c
+++ b/arch/ia64/kernel/pci-swiotlb.c
@@ -20,19 +20,12 @@ static void *ia64_swiotlb_alloc_coherent(struct device *dev, size_t size,
 {
 	if (dev->coherent_dma_mask != DMA_BIT_MASK(64))
 		gfp |= GFP_DMA;
-	return swiotlb_alloc_coherent(dev, size, dma_handle, gfp);
-}
-
-static void ia64_swiotlb_free_coherent(struct device *dev, size_t size,
-				       void *vaddr, dma_addr_t dma_addr,
-				       struct dma_attrs *attrs)
-{
-	swiotlb_free_coherent(dev, size, vaddr, dma_addr);
+	return swiotlb_alloc_coherent(dev, size, dma_handle, gfp, attrs);
 }
 
 struct dma_map_ops swiotlb_dma_ops = {
 	.alloc = ia64_swiotlb_alloc_coherent,
-	.free = ia64_swiotlb_free_coherent,
+	.free = swiotlb_free_coherent,
 	.map_page = swiotlb_map_page,
 	.unmap_page = swiotlb_unmap_page,
 	.map_sg = swiotlb_map_sg_attrs,
diff --git a/arch/mips/cavium-octeon/dma-octeon.c b/arch/mips/cavium-octeon/dma-octeon.c
index 41dd0088..df70600 100644
--- a/arch/mips/cavium-octeon/dma-octeon.c
+++ b/arch/mips/cavium-octeon/dma-octeon.c
@@ -184,7 +184,7 @@ static void *octeon_dma_alloc_coherent(struct device *dev, size_t size,
 	/* Don't invoke OOM killer */
 	gfp |= __GFP_NORETRY;
 
-	ret = swiotlb_alloc_coherent(dev, size, dma_handle, gfp);
+	ret = swiotlb_alloc_coherent(dev, size, dma_handle, gfp, attrs);
 
 	mb();
 
@@ -199,7 +199,7 @@ static void octeon_dma_free_coherent(struct device *dev, size_t size,
 	if (dma_release_from_coherent(dev, order, vaddr))
 		return;
 
-	swiotlb_free_coherent(dev, size, vaddr, dma_handle);
+	swiotlb_free_coherent(dev, size, vaddr, dma_handle, attrs);
 }
 
 static dma_addr_t octeon_unity_phys_to_dma(struct device *dev, phys_addr_t paddr)
diff --git a/arch/unicore32/mm/dma-swiotlb.c b/arch/unicore32/mm/dma-swiotlb.c
index 16c08b2..86eaae7 100644
--- a/arch/unicore32/mm/dma-swiotlb.c
+++ b/arch/unicore32/mm/dma-swiotlb.c
@@ -8,32 +8,14 @@
  * Free Software Foundation;  either version 2 of the  License, or (at your
  * option) any later version.
  */
-#include <linux/pci.h>
-#include <linux/cache.h>
-#include <linux/module.h>
 #include <linux/dma-mapping.h>
 #include <linux/swiotlb.h>
-#include <linux/bootmem.h>
 
 #include <asm/dma.h>
 
-static void *unicore_swiotlb_alloc_coherent(struct device *dev, size_t size,
-					    dma_addr_t *dma_handle, gfp_t flags,
-					    struct dma_attrs *attrs)
-{
-	return swiotlb_alloc_coherent(dev, size, dma_handle, flags);
-}
-
-static void unicore_swiotlb_free_coherent(struct device *dev, size_t size,
-					  void *vaddr, dma_addr_t dma_addr,
-					  struct dma_attrs *attrs)
-{
-	swiotlb_free_coherent(dev, size, vaddr, dma_addr);
-}
-
 struct dma_map_ops swiotlb_dma_map_ops = {
-	.alloc = unicore_swiotlb_alloc_coherent,
-	.free = unicore_swiotlb_free_coherent,
+	.alloc = swiotlb_alloc_coherent,
+	.free = swiotlb_free_coherent,
 	.map_sg = swiotlb_map_sg_attrs,
 	.unmap_sg = swiotlb_unmap_sg_attrs,
 	.dma_supported = swiotlb_dma_supported,
diff --git a/arch/x86/kernel/pci-swiotlb.c b/arch/x86/kernel/pci-swiotlb.c
index 6c483ba..fa462a3 100644
--- a/arch/x86/kernel/pci-swiotlb.c
+++ b/arch/x86/kernel/pci-swiotlb.c
@@ -25,20 +25,13 @@ static void *x86_swiotlb_alloc_coherent(struct device *hwdev, size_t size,
 	if (vaddr)
 		return vaddr;
 
-	return swiotlb_alloc_coherent(hwdev, size, dma_handle, flags);
-}
-
-static void x86_swiotlb_free_coherent(struct device *dev, size_t size,
-				      void *vaddr, dma_addr_t dma_addr,
-				      struct dma_attrs *attrs)
-{
-	swiotlb_free_coherent(dev, size, vaddr, dma_addr);
+	return swiotlb_alloc_coherent(hwdev, size, dma_handle, flags, attrs);
 }
 
 static struct dma_map_ops swiotlb_dma_ops = {
 	.mapping_error = swiotlb_dma_mapping_error,
 	.alloc = x86_swiotlb_alloc_coherent,
-	.free = x86_swiotlb_free_coherent,
+	.free = swiotlb_free_coherent,
 	.sync_single_for_cpu = swiotlb_sync_single_for_cpu,
 	.sync_single_for_device = swiotlb_sync_single_for_device,
 	.sync_sg_for_cpu = swiotlb_sync_sg_for_cpu,
diff --git a/arch/x86/pci/sta2x11-fixup.c b/arch/x86/pci/sta2x11-fixup.c
index 9d8a509..5aaa434 100644
--- a/arch/x86/pci/sta2x11-fixup.c
+++ b/arch/x86/pci/sta2x11-fixup.c
@@ -175,7 +175,8 @@ static void *sta2x11_swiotlb_alloc_coherent(struct device *dev,
 
 	vaddr = dma_generic_alloc_coherent(dev, size, dma_handle, flags, attrs);
 	if (!vaddr)
-		vaddr = swiotlb_alloc_coherent(dev, size, dma_handle, flags);
+		vaddr = swiotlb_alloc_coherent(dev, size, dma_handle, flags,
+					       attrs);
 	*dma_handle = p2a(*dma_handle, to_pci_dev(dev));
 	return vaddr;
 }
diff --git a/include/linux/swiotlb.h b/include/linux/swiotlb.h
index e872526..5abe3fd 100644
--- a/include/linux/swiotlb.h
+++ b/include/linux/swiotlb.h
@@ -50,11 +50,12 @@ extern void swiotlb_bounce(phys_addr_t phys, char *dma_addr, size_t size,
 
 extern void
 *swiotlb_alloc_coherent(struct device *hwdev, size_t size,
-			dma_addr_t *dma_handle, gfp_t flags);
+			dma_addr_t *dma_handle, gfp_t flags,
+			struct dma_attrs *attrs);
 
 extern void
-swiotlb_free_coherent(struct device *hwdev, size_t size,
-		      void *vaddr, dma_addr_t dma_handle);
+swiotlb_free_coherent(struct device *hwdev, size_t size, void *vaddr,
+		      dma_addr_t dma_handle, struct dma_attrs *attrs);
 
 extern dma_addr_t swiotlb_map_page(struct device *dev, struct page *page,
 				   unsigned long offset, size_t size,
diff --git a/lib/swiotlb.c b/lib/swiotlb.c
index 45bc1f8..476b553 100644
--- a/lib/swiotlb.c
+++ b/lib/swiotlb.c
@@ -563,7 +563,8 @@ EXPORT_SYMBOL_GPL(swiotlb_tbl_sync_single);
 
 void *
 swiotlb_alloc_coherent(struct device *hwdev, size_t size,
-		       dma_addr_t *dma_handle, gfp_t flags)
+		       dma_addr_t *dma_handle, gfp_t flags,
+		       struct dma_attrs *attrs)
 {
 	dma_addr_t dev_addr;
 	void *ret;
@@ -612,7 +613,7 @@ EXPORT_SYMBOL(swiotlb_alloc_coherent);
 
 void
 swiotlb_free_coherent(struct device *hwdev, size_t size, void *vaddr,
-		      dma_addr_t dev_addr)
+		      dma_addr_t dev_addr, struct dma_attrs *attrs)
 {
 	phys_addr_t paddr = dma_to_phys(hwdev, dev_addr);
 
-- 
1.7.7.2
