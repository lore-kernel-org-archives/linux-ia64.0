From: Christoph Hellwig <hch@lst.de>
Date: Fri, 29 Dec 2017 08:18:41 +0000
Subject: [PATCH 37/67] x86: use dma-direct
Message-Id: <20171229081911.2802-38-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20171229081911.2802-1-hch@lst.de>
In-Reply-To: <20171229081911.2802-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: iommu@lists.linux-foundation.org
Cc: linux-alpha@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, adi-buildroot-devel@lists.sourceforge.net, linux-c6x-dev@linux-c6x.org, linux-cris-kernel@axis.com, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-metag@vger.kernel.org, Michal Simek <monstr@monstr.eu>, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, patches@groups.riscv.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, Guan Xuetao <gxt@mprc.pku.edu.cn>, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

The generic dma-direct implementation is now functionally equivalent to
the x86 nommu dma_map implementation, so switch over to using it.

Note that the various iommu drivers are switched from x86_dma_supported
to dma_direct_supported to provide identical functionality, although the
checks looks fairly questionable for at least some of them.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/x86/Kconfig                   |  1 +
 arch/x86/include/asm/dma-mapping.h |  8 -----
 arch/x86/include/asm/iommu.h       |  3 --
 arch/x86/kernel/Makefile           |  2 +-
 arch/x86/kernel/amd_gart_64.c      |  7 ++--
 arch/x86/kernel/pci-calgary_64.c   |  3 +-
 arch/x86/kernel/pci-dma.c          | 66 +-------------------------------------
 arch/x86/kernel/pci-swiotlb.c      |  5 ++-
 arch/x86/pci/sta2x11-fixup.c       |  2 +-
 drivers/iommu/amd_iommu.c          |  7 ++--
 drivers/iommu/intel-iommu.c        |  3 +-
 11 files changed, 17 insertions(+), 90 deletions(-)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index f6f4328103c0..55ad01515075 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -83,6 +83,7 @@ config X86
 	select CLOCKSOURCE_VALIDATE_LAST_CYCLE
 	select CLOCKSOURCE_WATCHDOG
 	select DCACHE_WORD_ACCESS
+	select DMA_DIRECT_OPS
 	select EDAC_ATOMIC_SCRUB
 	select EDAC_SUPPORT
 	select GENERIC_CLOCKEVENTS
diff --git a/arch/x86/include/asm/dma-mapping.h b/arch/x86/include/asm/dma-mapping.h
index 545bf3721bc0..df9816b385eb 100644
--- a/arch/x86/include/asm/dma-mapping.h
+++ b/arch/x86/include/asm/dma-mapping.h
@@ -36,14 +36,6 @@ int arch_dma_supported(struct device *dev, u64 mask);
 bool arch_dma_alloc_attrs(struct device **dev, gfp_t *gfp);
 #define arch_dma_alloc_attrs arch_dma_alloc_attrs
 
-extern void *dma_generic_alloc_coherent(struct device *dev, size_t size,
-					dma_addr_t *dma_addr, gfp_t flag,
-					unsigned long attrs);
-
-extern void dma_generic_free_coherent(struct device *dev, size_t size,
-				      void *vaddr, dma_addr_t dma_addr,
-				      unsigned long attrs);
-
 static inline gfp_t dma_alloc_coherent_gfp_flags(struct device *dev, gfp_t gfp)
 {
 	if (dev->coherent_dma_mask <= DMA_BIT_MASK(24))
diff --git a/arch/x86/include/asm/iommu.h b/arch/x86/include/asm/iommu.h
index 1e5d5d92eb40..baedab8ac538 100644
--- a/arch/x86/include/asm/iommu.h
+++ b/arch/x86/include/asm/iommu.h
@@ -2,13 +2,10 @@
 #ifndef _ASM_X86_IOMMU_H
 #define _ASM_X86_IOMMU_H
 
-extern const struct dma_map_ops nommu_dma_ops;
 extern int force_iommu, no_iommu;
 extern int iommu_detected;
 extern int iommu_pass_through;
 
-int x86_dma_supported(struct device *dev, u64 mask);
-
 /* 10 seconds */
 #define DMAR_OPERATION_TIMEOUT ((cycles_t) tsc_khz*10*1000)
 
diff --git a/arch/x86/kernel/Makefile b/arch/x86/kernel/Makefile
index 81bb565f4497..beee4332e69b 100644
--- a/arch/x86/kernel/Makefile
+++ b/arch/x86/kernel/Makefile
@@ -54,7 +54,7 @@ obj-$(CONFIG_X86_ESPFIX64)	+= espfix_64.o
 obj-$(CONFIG_SYSFS)	+= ksysfs.o
 obj-y			+= bootflag.o e820.o
 obj-y			+= pci-dma.o quirks.o topology.o kdebugfs.o
-obj-y			+= alternative.o i8253.o pci-nommu.o hw_breakpoint.o
+obj-y			+= alternative.o i8253.o hw_breakpoint.o
 obj-y			+= tsc.o tsc_msr.o io_delay.o rtc.o
 obj-y			+= pci-iommu_table.o
 obj-y			+= resource.o
diff --git a/arch/x86/kernel/amd_gart_64.c b/arch/x86/kernel/amd_gart_64.c
index ecd486cb06ab..52e3abcf3e70 100644
--- a/arch/x86/kernel/amd_gart_64.c
+++ b/arch/x86/kernel/amd_gart_64.c
@@ -501,8 +501,7 @@ gart_alloc_coherent(struct device *dev, size_t size, dma_addr_t *dma_addr,
 		}
 		__free_pages(page, get_order(size));
 	} else
-		return dma_generic_alloc_coherent(dev, size, dma_addr, flag,
-						  attrs);
+		return dma_direct_alloc(dev, size, dma_addr, flag, attrs);
 
 	return NULL;
 }
@@ -513,7 +512,7 @@ gart_free_coherent(struct device *dev, size_t size, void *vaddr,
 		   dma_addr_t dma_addr, unsigned long attrs)
 {
 	gart_unmap_page(dev, dma_addr, size, DMA_BIDIRECTIONAL, 0);
-	dma_generic_free_coherent(dev, size, vaddr, dma_addr, attrs);
+	dma_direct_free(dev, size, vaddr, dma_addr, attrs);
 }
 
 static int gart_mapping_error(struct device *dev, dma_addr_t dma_addr)
@@ -705,7 +704,7 @@ static const struct dma_map_ops gart_dma_ops = {
 	.alloc				= gart_alloc_coherent,
 	.free				= gart_free_coherent,
 	.mapping_error			= gart_mapping_error,
-	.dma_supported			= x86_dma_supported,
+	.dma_supported			= dma_direct_supported,
 };
 
 static void gart_iommu_shutdown(void)
diff --git a/arch/x86/kernel/pci-calgary_64.c b/arch/x86/kernel/pci-calgary_64.c
index 35c461f21815..5647853053bd 100644
--- a/arch/x86/kernel/pci-calgary_64.c
+++ b/arch/x86/kernel/pci-calgary_64.c
@@ -33,6 +33,7 @@
 #include <linux/string.h>
 #include <linux/crash_dump.h>
 #include <linux/dma-mapping.h>
+#include <linux/dma-direct.h>
 #include <linux/bitmap.h>
 #include <linux/pci_ids.h>
 #include <linux/pci.h>
@@ -493,7 +494,7 @@ static const struct dma_map_ops calgary_dma_ops = {
 	.map_page = calgary_map_page,
 	.unmap_page = calgary_unmap_page,
 	.mapping_error = calgary_mapping_error,
-	.dma_supported = x86_dma_supported,
+	.dma_supported = dma_direct_supported,
 };
 
 static inline void __iomem * busno_to_bbar(unsigned char num)
diff --git a/arch/x86/kernel/pci-dma.c b/arch/x86/kernel/pci-dma.c
index b59820872ec7..db0b88ea8d1b 100644
--- a/arch/x86/kernel/pci-dma.c
+++ b/arch/x86/kernel/pci-dma.c
@@ -18,7 +18,7 @@
 
 static int forbid_dac __read_mostly;
 
-const struct dma_map_ops *dma_ops = &nommu_dma_ops;
+const struct dma_map_ops *dma_ops = &dma_direct_ops;
 EXPORT_SYMBOL(dma_ops);
 
 static int iommu_sac_force __read_mostly;
@@ -76,60 +76,6 @@ void __init pci_iommu_alloc(void)
 		}
 	}
 }
-void *dma_generic_alloc_coherent(struct device *dev, size_t size,
-				 dma_addr_t *dma_addr, gfp_t flag,
-				 unsigned long attrs)
-{
-	struct page *page;
-	unsigned int count = PAGE_ALIGN(size) >> PAGE_SHIFT;
-	dma_addr_t addr;
-
-again:
-	page = NULL;
-	/* CMA can be used only in the context which permits sleeping */
-	if (gfpflags_allow_blocking(flag)) {
-		page = dma_alloc_from_contiguous(dev, count, get_order(size),
-						 flag);
-		if (page) {
-			addr = phys_to_dma(dev, page_to_phys(page));
-			if (addr + size > dev->coherent_dma_mask) {
-				dma_release_from_contiguous(dev, page, count);
-				page = NULL;
-			}
-		}
-	}
-	/* fallback */
-	if (!page)
-		page = alloc_pages_node(dev_to_node(dev), flag, get_order(size));
-	if (!page)
-		return NULL;
-
-	addr = phys_to_dma(dev, page_to_phys(page));
-	if (addr + size > dev->coherent_dma_mask) {
-		__free_pages(page, get_order(size));
-
-		if (dev->coherent_dma_mask < DMA_BIT_MASK(32) &&
-		    !(flag & GFP_DMA)) {
-			flag = (flag & ~GFP_DMA32) | GFP_DMA;
-			goto again;
-		}
-
-		return NULL;
-	}
-	memset(page_address(page), 0, size);
-	*dma_addr = addr;
-	return page_address(page);
-}
-
-void dma_generic_free_coherent(struct device *dev, size_t size, void *vaddr,
-			       dma_addr_t dma_addr, unsigned long attrs)
-{
-	unsigned int count = PAGE_ALIGN(size) >> PAGE_SHIFT;
-	struct page *page = virt_to_page(vaddr);
-
-	if (!dma_release_from_contiguous(dev, page, count))
-		free_pages((unsigned long)vaddr, get_order(size));
-}
 
 bool arch_dma_alloc_attrs(struct device **dev, gfp_t *gfp)
 {
@@ -243,16 +189,6 @@ int arch_dma_supported(struct device *dev, u64 mask)
 }
 EXPORT_SYMBOL(arch_dma_supported);
 
-int x86_dma_supported(struct device *dev, u64 mask)
-{
-	/* Copied from i386. Doesn't make much sense, because it will
-	   only work for pci_alloc_coherent.
-	   The caller just has to use GFP_DMA in this case. */
-	if (mask < DMA_BIT_MASK(24))
-		return 0;
-	return 1;
-}
-
 static int __init pci_iommu_init(void)
 {
 	struct iommu_table_entry *p;
diff --git a/arch/x86/kernel/pci-swiotlb.c b/arch/x86/kernel/pci-swiotlb.c
index 9d3e35c33d94..7a11a3e4f697 100644
--- a/arch/x86/kernel/pci-swiotlb.c
+++ b/arch/x86/kernel/pci-swiotlb.c
@@ -30,8 +30,7 @@ void *x86_swiotlb_alloc_coherent(struct device *hwdev, size_t size,
 	 */
 	flags |= __GFP_NOWARN;
 
-	vaddr = dma_generic_alloc_coherent(hwdev, size, dma_handle, flags,
-					   attrs);
+	vaddr = dma_direct_alloc(hwdev, size, dma_handle, flags, attrs);
 	if (vaddr)
 		return vaddr;
 
@@ -45,7 +44,7 @@ void x86_swiotlb_free_coherent(struct device *dev, size_t size,
 	if (is_swiotlb_buffer(dma_to_phys(dev, dma_addr)))
 		swiotlb_free_coherent(dev, size, vaddr, dma_addr);
 	else
-		dma_generic_free_coherent(dev, size, vaddr, dma_addr, attrs);
+		dma_direct_free(dev, size, vaddr, dma_addr, attrs);
 }
 
 static const struct dma_map_ops swiotlb_dma_ops = {
diff --git a/arch/x86/pci/sta2x11-fixup.c b/arch/x86/pci/sta2x11-fixup.c
index 75577c1490c4..6c712fe11bdc 100644
--- a/arch/x86/pci/sta2x11-fixup.c
+++ b/arch/x86/pci/sta2x11-fixup.c
@@ -193,7 +193,7 @@ static const struct dma_map_ops sta2x11_dma_ops = {
 	.sync_sg_for_cpu = swiotlb_sync_sg_for_cpu,
 	.sync_sg_for_device = swiotlb_sync_sg_for_device,
 	.mapping_error = swiotlb_dma_mapping_error,
-	.dma_supported = x86_dma_supported,
+	.dma_supported = dma_direct_supported,
 };
 
 /* At setup time, we use our own ops if the device is a ConneXt one */
diff --git a/drivers/iommu/amd_iommu.c b/drivers/iommu/amd_iommu.c
index 7d5eb004091d..ea4734de5357 100644
--- a/drivers/iommu/amd_iommu.c
+++ b/drivers/iommu/amd_iommu.c
@@ -28,6 +28,7 @@
 #include <linux/debugfs.h>
 #include <linux/scatterlist.h>
 #include <linux/dma-mapping.h>
+#include <linux/dma-direct.h>
 #include <linux/iommu-helper.h>
 #include <linux/iommu.h>
 #include <linux/delay.h>
@@ -2182,7 +2183,7 @@ static int amd_iommu_add_device(struct device *dev)
 				dev_name(dev));
 
 		iommu_ignore_device(dev);
-		dev->dma_ops = &nommu_dma_ops;
+		dev->dma_ops = &dma_direct_ops;
 		goto out;
 	}
 	init_iommu_group(dev);
@@ -2667,7 +2668,7 @@ static void free_coherent(struct device *dev, size_t size,
  */
 static int amd_iommu_dma_supported(struct device *dev, u64 mask)
 {
-	if (!x86_dma_supported(dev, mask))
+	if (!dma_direct_supported(dev, mask))
 		return 0;
 	return check_device(dev);
 }
@@ -2781,7 +2782,7 @@ int __init amd_iommu_init_dma_ops(void)
 	 * continue to be SWIOTLB.
 	 */
 	if (!swiotlb)
-		dma_ops = &nommu_dma_ops;
+		dma_ops = &dma_direct_ops;
 
 	if (amd_iommu_unmap_flush)
 		pr_info("AMD-Vi: IO/TLB flush on unmap enabled\n");
diff --git a/drivers/iommu/intel-iommu.c b/drivers/iommu/intel-iommu.c
index 4a2de34895ec..921caf4f0c3e 100644
--- a/drivers/iommu/intel-iommu.c
+++ b/drivers/iommu/intel-iommu.c
@@ -45,6 +45,7 @@
 #include <linux/pci-ats.h>
 #include <linux/memblock.h>
 #include <linux/dma-contiguous.h>
+#include <linux/dma-direct.h>
 #include <linux/crash_dump.h>
 #include <asm/irq_remapping.h>
 #include <asm/cacheflush.h>
@@ -3872,7 +3873,7 @@ const struct dma_map_ops intel_dma_ops = {
 	.unmap_page = intel_unmap_page,
 	.mapping_error = intel_mapping_error,
 #ifdef CONFIG_X86
-	.dma_supported = x86_dma_supported,
+	.dma_supported = dma_direct_supported,
 #endif
 };
 
-- 
2.14.2

