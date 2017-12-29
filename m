From: Christoph Hellwig <hch@lst.de>
Date: Fri, 29 Dec 2017 08:18:09 +0000
Subject: [PATCH 05/67] dma-mapping: replace PCI_DMA_BUS_IS_PHYS with a flag in struct dma_map_ops
Message-Id: <20171229081911.2802-6-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20171229081911.2802-1-hch@lst.de>
In-Reply-To: <20171229081911.2802-1-hch-jcswGhMUV9g@public.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-sh-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sparclinux-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Guan Xuetao <gxt-TG0Ac1+ktVePQbnJrJN+5g@public.gmane.org>, linux-arch-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-c6x-dev-jPsnJVOj+W6hPH1hqNUYSQ@public.gmane.org, linux-hexagon-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, linux-snps-arc-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, adi-buildroot-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, linux-m68k-cunTk1MwBs8S/qaLPR03pWD2FQJk+8+b@public.gmane.org, patches-q3qR2WxjNRFS9aJRtSZj7A@public.gmane.org, linux-metag-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, Michal Simek <monstr-pSz03upnqPeHXe+LvDLADg@public.gmane.org>, linux-parisc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-cris-kernel-VrBV9hrLPhE@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-alpha-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org

The current PCI_DMA_BUS_IS_PHYS decided if a dma implementation is bound
by the dma mask in the device because it directly maps to a physical
address range (modulo an offset in the device), or if it is virtualized
by an iommu and can map any address (that includes virtual iommus like
swiotlb).  The problem with this scheme is that it is per-architecture and
not per dma_ops instance, and we are growing more and more setups that
have multiple different dma operations in use on a single system, for
which this scheme can't provide a correct answer.  Depending on the
architecture that means we either get a false positive or false negative
at the moment.

This patch instead extents the is_phys flag in struct dma_map_ops that
is currently only used by a few architectures to be used tree wide.

Note that this means that we now need a struct device parent in the
Scsi_Host or netdevice.  Every modern driver has these, but there might
still be a few outdated legacy drivers out there, which now won't make
an intelligent decision.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/alpha/include/asm/pci.h          |  5 -----
 arch/alpha/kernel/pci-noop.c          |  1 +
 arch/arc/include/asm/pci.h            |  6 ------
 arch/arc/mm/dma.c                     |  1 +
 arch/arm/include/asm/pci.h            |  7 -------
 arch/arm/mm/dma-mapping-nommu.c       |  1 +
 arch/arm/mm/dma-mapping.c             |  2 ++
 arch/arm64/include/asm/pci.h          |  5 -----
 arch/blackfin/kernel/dma-mapping.c    |  2 ++
 arch/c6x/kernel/dma.c                 |  1 +
 arch/cris/arch-v32/drivers/pci/dma.c  |  1 +
 arch/cris/include/asm/pci.h           |  6 ------
 arch/frv/mb93090-mb00/pci-dma-nommu.c |  1 +
 arch/frv/mb93090-mb00/pci-dma.c       |  1 +
 arch/h8300/include/asm/pci.h          |  2 --
 arch/h8300/kernel/dma.c               |  1 +
 arch/hexagon/kernel/dma.c             |  2 +-
 arch/ia64/hp/common/sba_iommu.c       |  3 ---
 arch/ia64/include/asm/pci.h           | 17 -----------------
 arch/ia64/kernel/setup.c              | 12 ------------
 arch/ia64/sn/kernel/io_common.c       |  5 -----
 arch/m68k/include/asm/pci.h           |  6 ------
 arch/m68k/kernel/dma.c                |  1 +
 arch/metag/kernel/dma.c               |  1 +
 arch/microblaze/include/asm/pci.h     |  6 ------
 arch/microblaze/kernel/dma.c          |  1 +
 arch/mips/include/asm/pci.h           |  7 -------
 arch/mips/mm/dma-default.c            |  1 +
 arch/mn10300/include/asm/pci.h        |  6 ------
 arch/mn10300/mm/dma-alloc.c           |  1 +
 arch/nios2/mm/dma-mapping.c           |  1 +
 arch/openrisc/kernel/dma.c            |  1 +
 arch/parisc/include/asm/pci.h         | 23 -----------------------
 arch/parisc/kernel/pci-dma.c          |  2 ++
 arch/parisc/kernel/setup.c            |  5 -----
 arch/powerpc/include/asm/pci.h        | 18 ------------------
 arch/powerpc/kernel/dma.c             |  1 +
 arch/riscv/include/asm/pci.h          |  3 ---
 arch/s390/include/asm/pci.h           |  2 --
 arch/s390/pci/pci_dma.c               |  3 ---
 arch/sh/include/asm/pci.h             |  6 ------
 arch/sh/kernel/dma-nommu.c            |  2 +-
 arch/sparc/include/asm/pci_32.h       |  4 ----
 arch/sparc/include/asm/pci_64.h       |  6 ------
 arch/sparc/kernel/ioport.c            |  1 +
 arch/tile/include/asm/pci.h           | 14 --------------
 arch/tile/kernel/pci-dma.c            |  2 ++
 arch/x86/include/asm/pci.h            |  2 --
 arch/x86/kernel/pci-nommu.c           |  2 +-
 arch/xtensa/include/asm/pci.h         |  7 -------
 arch/xtensa/kernel/pci-dma.c          |  1 +
 drivers/ide/ide-lib.c                 |  5 ++---
 drivers/ide/ide-probe.c               |  2 +-
 drivers/parisc/ccio-dma.c             |  2 --
 drivers/parisc/sba_iommu.c            |  2 --
 drivers/pci/host/vmd.c                |  1 +
 drivers/scsi/scsi_lib.c               | 14 ++++++--------
 include/asm-generic/pci.h             |  8 --------
 include/linux/dma-mapping.h           | 23 ++++++++++++++++++++++-
 lib/dma-noop.c                        |  1 +
 net/core/dev.c                        | 18 ++++++++----------
 tools/virtio/linux/dma-mapping.h      |  2 --
 62 files changed, 70 insertions(+), 226 deletions(-)

diff --git a/arch/alpha/include/asm/pci.h b/arch/alpha/include/asm/pci.h
index b9ec55351924..cf6bc1e64d66 100644
--- a/arch/alpha/include/asm/pci.h
+++ b/arch/alpha/include/asm/pci.h
@@ -56,11 +56,6 @@ struct pci_controller {
 
 /* IOMMU controls.  */
 
-/* The PCI address space does not equal the physical memory address space.
-   The networking and block device layers use this boolean for bounce buffer
-   decisions.  */
-#define PCI_DMA_BUS_IS_PHYS  0
-
 /* TODO: integrate with include/asm-generic/pci.h ? */
 static inline int pci_get_legacy_ide_irq(struct pci_dev *dev, int channel)
 {
diff --git a/arch/alpha/kernel/pci-noop.c b/arch/alpha/kernel/pci-noop.c
index b995987b1557..d3208254b269 100644
--- a/arch/alpha/kernel/pci-noop.c
+++ b/arch/alpha/kernel/pci-noop.c
@@ -132,6 +132,7 @@ const struct dma_map_ops alpha_noop_ops = {
 	.map_sg			= dma_noop_map_sg,
 	.mapping_error		= dma_noop_mapping_error,
 	.dma_supported		= alpha_noop_supported,
+	.is_phys		= true,
 };
 
 const struct dma_map_ops *dma_ops = &alpha_noop_ops;
diff --git a/arch/arc/include/asm/pci.h b/arch/arc/include/asm/pci.h
index ba56c23c1b20..4ff53c041c64 100644
--- a/arch/arc/include/asm/pci.h
+++ b/arch/arc/include/asm/pci.h
@@ -16,12 +16,6 @@
 #define PCIBIOS_MIN_MEM 0x100000
 
 #define pcibios_assign_all_busses()	1
-/*
- * The PCI address space does equal the physical memory address space.
- * The networking and block device layers use this boolean for bounce
- * buffer decisions.
- */
-#define PCI_DMA_BUS_IS_PHYS	1
 
 #endif /* __KERNEL__ */
 
diff --git a/arch/arc/mm/dma.c b/arch/arc/mm/dma.c
index e9d93604ad0f..fad18261ef6a 100644
--- a/arch/arc/mm/dma.c
+++ b/arch/arc/mm/dma.c
@@ -274,5 +274,6 @@ const struct dma_map_ops arc_dma_ops = {
 	.sync_sg_for_cpu	= arc_dma_sync_sg_for_cpu,
 	.sync_sg_for_device	= arc_dma_sync_sg_for_device,
 	.dma_supported		= arc_dma_supported,
+	.is_phys		= true,
 };
 EXPORT_SYMBOL(arc_dma_ops);
diff --git a/arch/arm/include/asm/pci.h b/arch/arm/include/asm/pci.h
index 960d9dc4f380..05b2eb2dc76f 100644
--- a/arch/arm/include/asm/pci.h
+++ b/arch/arm/include/asm/pci.h
@@ -22,13 +22,6 @@ static inline int pci_proc_domain(struct pci_bus *bus)
 }
 #endif /* CONFIG_PCI_DOMAINS */
 
-/*
- * The PCI address space does equal the physical memory address space.
- * The networking and block device layers use this boolean for bounce
- * buffer decisions.
- */
-#define PCI_DMA_BUS_IS_PHYS     (1)
-
 #define HAVE_PCI_MMAP
 #define ARCH_GENERIC_PCI_MMAP_RESOURCE
 
diff --git a/arch/arm/mm/dma-mapping-nommu.c b/arch/arm/mm/dma-mapping-nommu.c
index 6db5fc26d154..1cced700e45a 100644
--- a/arch/arm/mm/dma-mapping-nommu.c
+++ b/arch/arm/mm/dma-mapping-nommu.c
@@ -208,6 +208,7 @@ const struct dma_map_ops arm_nommu_dma_ops = {
 	.sync_single_for_cpu	= arm_nommu_dma_sync_single_for_cpu,
 	.sync_sg_for_device	= arm_nommu_dma_sync_sg_for_device,
 	.sync_sg_for_cpu	= arm_nommu_dma_sync_sg_for_cpu,
+	.is_phys		= true,
 };
 EXPORT_SYMBOL(arm_nommu_dma_ops);
 
diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
index ada8eb206a90..8e120e2d9cac 100644
--- a/arch/arm/mm/dma-mapping.c
+++ b/arch/arm/mm/dma-mapping.c
@@ -200,6 +200,7 @@ const struct dma_map_ops arm_dma_ops = {
 	.sync_sg_for_device	= arm_dma_sync_sg_for_device,
 	.mapping_error		= arm_dma_mapping_error,
 	.dma_supported		= arm_dma_supported,
+	.is_phys		= true,
 };
 EXPORT_SYMBOL(arm_dma_ops);
 
@@ -220,6 +221,7 @@ const struct dma_map_ops arm_coherent_dma_ops = {
 	.map_sg			= arm_dma_map_sg,
 	.mapping_error		= arm_dma_mapping_error,
 	.dma_supported		= arm_dma_supported,
+	.is_phys		= true,
 };
 EXPORT_SYMBOL(arm_coherent_dma_ops);
 
diff --git a/arch/arm64/include/asm/pci.h b/arch/arm64/include/asm/pci.h
index 8747f7c5e0e7..9e690686e8aa 100644
--- a/arch/arm64/include/asm/pci.h
+++ b/arch/arm64/include/asm/pci.h
@@ -18,11 +18,6 @@
 #define pcibios_assign_all_busses() \
 	(pci_has_flag(PCI_REASSIGN_ALL_BUS))
 
-/*
- * PCI address space differs from physical memory address space
- */
-#define PCI_DMA_BUS_IS_PHYS	(0)
-
 #define ARCH_GENERIC_PCI_MMAP_RESOURCE	1
 
 extern int isa_dma_bridge_buggy;
diff --git a/arch/blackfin/kernel/dma-mapping.c b/arch/blackfin/kernel/dma-mapping.c
index 477bb29a7987..362902a2a418 100644
--- a/arch/blackfin/kernel/dma-mapping.c
+++ b/arch/blackfin/kernel/dma-mapping.c
@@ -168,5 +168,7 @@ const struct dma_map_ops bfin_dma_ops = {
 
 	.sync_single_for_device	= bfin_dma_sync_single_for_device,
 	.sync_sg_for_device	= bfin_dma_sync_sg_for_device,
+
+	.is_phys		= true,
 };
 EXPORT_SYMBOL(bfin_dma_ops);
diff --git a/arch/c6x/kernel/dma.c b/arch/c6x/kernel/dma.c
index 9fff8be75f58..a526dddeeac1 100644
--- a/arch/c6x/kernel/dma.c
+++ b/arch/c6x/kernel/dma.c
@@ -134,6 +134,7 @@ const struct dma_map_ops c6x_dma_ops = {
 	.sync_single_for_cpu	= c6x_dma_sync_single_for_cpu,
 	.sync_sg_for_device	= c6x_dma_sync_sg_for_device,
 	.sync_sg_for_cpu	= c6x_dma_sync_sg_for_cpu,
+	.is_phys		= true,
 };
 EXPORT_SYMBOL(c6x_dma_ops);
 
diff --git a/arch/cris/arch-v32/drivers/pci/dma.c b/arch/cris/arch-v32/drivers/pci/dma.c
index dbbd3816cc0b..aa16ce27e036 100644
--- a/arch/cris/arch-v32/drivers/pci/dma.c
+++ b/arch/cris/arch-v32/drivers/pci/dma.c
@@ -76,5 +76,6 @@ const struct dma_map_ops v32_dma_ops = {
 	.map_page		= v32_dma_map_page,
 	.map_sg                 = v32_dma_map_sg,
 	.dma_supported		= v32_dma_supported,
+	.is_phys		= true,
 };
 EXPORT_SYMBOL(v32_dma_ops);
diff --git a/arch/cris/include/asm/pci.h b/arch/cris/include/asm/pci.h
index dcfef6407ae6..eb1f7f172f4b 100644
--- a/arch/cris/include/asm/pci.h
+++ b/arch/cris/include/asm/pci.h
@@ -27,12 +27,6 @@
 #include <linux/string.h>
 #include <asm/io.h>
 
-/* The PCI address space does equal the physical memory
- * address space.  The networking and block device layers use
- * this boolean for bounce buffer decisions.
- */
-#define PCI_DMA_BUS_IS_PHYS	(1)
-
 #define HAVE_PCI_MMAP
 #define ARCH_GENERIC_PCI_MMAP_RESOURCE
 
diff --git a/arch/frv/mb93090-mb00/pci-dma-nommu.c b/arch/frv/mb93090-mb00/pci-dma-nommu.c
index 4a96de7f0af4..d58d701619e5 100644
--- a/arch/frv/mb93090-mb00/pci-dma-nommu.c
+++ b/arch/frv/mb93090-mb00/pci-dma-nommu.c
@@ -172,5 +172,6 @@ const struct dma_map_ops frv_dma_ops = {
 	.sync_single_for_device	= frv_dma_sync_single_for_device,
 	.sync_sg_for_device	= frv_dma_sync_sg_for_device,
 	.dma_supported		= frv_dma_supported,
+	.is_phys		= true,
 };
 EXPORT_SYMBOL(frv_dma_ops);
diff --git a/arch/frv/mb93090-mb00/pci-dma.c b/arch/frv/mb93090-mb00/pci-dma.c
index e7130abc0dae..8c2e9a40e57e 100644
--- a/arch/frv/mb93090-mb00/pci-dma.c
+++ b/arch/frv/mb93090-mb00/pci-dma.c
@@ -114,5 +114,6 @@ const struct dma_map_ops frv_dma_ops = {
 	.sync_single_for_device	= frv_dma_sync_single_for_device,
 	.sync_sg_for_device	= frv_dma_sync_sg_for_device,
 	.dma_supported		= frv_dma_supported,
+	.is_phys		= true,
 };
 EXPORT_SYMBOL(frv_dma_ops);
diff --git a/arch/h8300/include/asm/pci.h b/arch/h8300/include/asm/pci.h
index 7c9e55d62215..d4d345a52092 100644
--- a/arch/h8300/include/asm/pci.h
+++ b/arch/h8300/include/asm/pci.h
@@ -15,6 +15,4 @@ static inline void pcibios_penalize_isa_irq(int irq, int active)
 	/* We don't do dynamic PCI IRQ allocation */
 }
 
-#define PCI_DMA_BUS_IS_PHYS	(1)
-
 #endif /* _ASM_H8300_PCI_H */
diff --git a/arch/h8300/kernel/dma.c b/arch/h8300/kernel/dma.c
index 225dd0a188dc..0e92214310c4 100644
--- a/arch/h8300/kernel/dma.c
+++ b/arch/h8300/kernel/dma.c
@@ -65,5 +65,6 @@ const struct dma_map_ops h8300_dma_map_ops = {
 	.free = dma_free,
 	.map_page = map_page,
 	.map_sg = map_sg,
+	.is_phys = true,
 };
 EXPORT_SYMBOL(h8300_dma_map_ops);
diff --git a/arch/hexagon/kernel/dma.c b/arch/hexagon/kernel/dma.c
index 546792d176a4..3683bb9c05a2 100644
--- a/arch/hexagon/kernel/dma.c
+++ b/arch/hexagon/kernel/dma.c
@@ -207,7 +207,7 @@ const struct dma_map_ops hexagon_dma_ops = {
 	.sync_single_for_cpu = hexagon_sync_single_for_cpu,
 	.sync_single_for_device = hexagon_sync_single_for_device,
 	.mapping_error	= hexagon_mapping_error,
-	.is_phys	= 1,
+	.is_phys	= true,
 };
 
 void __init hexagon_dma_init(void)
diff --git a/arch/ia64/hp/common/sba_iommu.c b/arch/ia64/hp/common/sba_iommu.c
index aec4a3354abe..6f05aba9012f 100644
--- a/arch/ia64/hp/common/sba_iommu.c
+++ b/arch/ia64/hp/common/sba_iommu.c
@@ -1845,9 +1845,6 @@ static void ioc_init(unsigned long hpa, struct ioc *ioc)
 	ioc_resource_init(ioc);
 	ioc_sac_init(ioc);
 
-	if ((long) ~iovp_mask > (long) ia64_max_iommu_merge_mask)
-		ia64_max_iommu_merge_mask = ~iovp_mask;
-
 	printk(KERN_INFO PFX
 		"%s %d.%d HPA 0x%lx IOVA space %dMb at 0x%lx\n",
 		ioc->name, (ioc->rev >> 4) & 0xF, ioc->rev & 0xF,
diff --git a/arch/ia64/include/asm/pci.h b/arch/ia64/include/asm/pci.h
index b1d04e8bafc8..780e8744ba85 100644
--- a/arch/ia64/include/asm/pci.h
+++ b/arch/ia64/include/asm/pci.h
@@ -30,23 +30,6 @@ struct pci_vector_struct {
 #define PCIBIOS_MIN_IO		0x1000
 #define PCIBIOS_MIN_MEM		0x10000000
 
-/*
- * PCI_DMA_BUS_IS_PHYS should be set to 1 if there is _necessarily_ a direct
- * correspondence between device bus addresses and CPU physical addresses.
- * Platforms with a hardware I/O MMU _must_ turn this off to suppress the
- * bounce buffer handling code in the block and network device layers.
- * Platforms with separate bus address spaces _must_ turn this off and provide
- * a device DMA mapping implementation that takes care of the necessary
- * address translation.
- *
- * For now, the ia64 platforms which may have separate/multiple bus address
- * spaces all have I/O MMUs which support the merging of physically
- * discontiguous buffers, so we can use that as the sole factor to determine
- * the setting of PCI_DMA_BUS_IS_PHYS.
- */
-extern unsigned long ia64_max_iommu_merge_mask;
-#define PCI_DMA_BUS_IS_PHYS	(ia64_max_iommu_merge_mask = ~0UL)
-
 #define HAVE_PCI_MMAP
 #define ARCH_GENERIC_PCI_MMAP_RESOURCE
 #define arch_can_pci_mmap_wc()	1
diff --git a/arch/ia64/kernel/setup.c b/arch/ia64/kernel/setup.c
index dee56bcb993d..ad43cbf70628 100644
--- a/arch/ia64/kernel/setup.c
+++ b/arch/ia64/kernel/setup.c
@@ -123,18 +123,6 @@ unsigned long ia64_i_cache_stride_shift = ~0;
 #define	CACHE_STRIDE_SHIFT	5
 unsigned long ia64_cache_stride_shift = ~0;
 
-/*
- * The merge_mask variable needs to be set to (max(iommu_page_size(iommu)) - 1).  This
- * mask specifies a mask of address bits that must be 0 in order for two buffers to be
- * mergeable by the I/O MMU (i.e., the end address of the first buffer and the start
- * address of the second buffer must be aligned to (merge_mask+1) in order to be
- * mergeable).  By default, we assume there is no I/O MMU which can merge physically
- * discontiguous buffers, so we set the merge_mask to ~0UL, which corresponds to a iommu
- * page-size of 2^64.
- */
-unsigned long ia64_max_iommu_merge_mask = ~0UL;
-EXPORT_SYMBOL(ia64_max_iommu_merge_mask);
-
 /*
  * We use a special marker for the end of memory and it uses the extra (+1) slot
  */
diff --git a/arch/ia64/sn/kernel/io_common.c b/arch/ia64/sn/kernel/io_common.c
index 11f2275570fb..8479e9a7ce16 100644
--- a/arch/ia64/sn/kernel/io_common.c
+++ b/arch/ia64/sn/kernel/io_common.c
@@ -480,11 +480,6 @@ sn_io_early_init(void)
 	tioca_init_provider();
 	tioce_init_provider();
 
-	/*
-	 * This is needed to avoid bounce limit checks in the blk layer
-	 */
-	ia64_max_iommu_merge_mask = ~PAGE_MASK;
-
 	sn_irq_lh_init();
 	INIT_LIST_HEAD(&sn_sysdata_list);
 	sn_init_cpei_timer();
diff --git a/arch/m68k/include/asm/pci.h b/arch/m68k/include/asm/pci.h
index ef26fae8cf0b..5a4bc223743b 100644
--- a/arch/m68k/include/asm/pci.h
+++ b/arch/m68k/include/asm/pci.h
@@ -4,12 +4,6 @@
 
 #include <asm-generic/pci.h>
 
-/* The PCI address space does equal the physical memory
- * address space.  The networking and block device layers use
- * this boolean for bounce buffer decisions.
- */
-#define PCI_DMA_BUS_IS_PHYS	(1)
-
 #define	pcibios_assign_all_busses()	1
 
 #define	PCIBIOS_MIN_IO		0x00000100
diff --git a/arch/m68k/kernel/dma.c b/arch/m68k/kernel/dma.c
index 87ef73a93856..e0167418072b 100644
--- a/arch/m68k/kernel/dma.c
+++ b/arch/m68k/kernel/dma.c
@@ -165,5 +165,6 @@ const struct dma_map_ops m68k_dma_ops = {
 	.map_sg			= m68k_dma_map_sg,
 	.sync_single_for_device	= m68k_dma_sync_single_for_device,
 	.sync_sg_for_device	= m68k_dma_sync_sg_for_device,
+	.is_phys		= true,
 };
 EXPORT_SYMBOL(m68k_dma_ops);
diff --git a/arch/metag/kernel/dma.c b/arch/metag/kernel/dma.c
index f0ab3a498328..16cb4df51b8a 100644
--- a/arch/metag/kernel/dma.c
+++ b/arch/metag/kernel/dma.c
@@ -584,5 +584,6 @@ const struct dma_map_ops metag_dma_ops = {
 	.sync_single_for_cpu	= metag_dma_sync_single_for_cpu,
 	.sync_sg_for_cpu	= metag_dma_sync_sg_for_cpu,
 	.mmap			= metag_dma_mmap,
+	.is_phys		= true,
 };
 EXPORT_SYMBOL(metag_dma_ops);
diff --git a/arch/microblaze/include/asm/pci.h b/arch/microblaze/include/asm/pci.h
index 114b93488193..00478965f932 100644
--- a/arch/microblaze/include/asm/pci.h
+++ b/arch/microblaze/include/asm/pci.h
@@ -61,12 +61,6 @@ extern int pci_mmap_legacy_page_range(struct pci_bus *bus,
 
 #define HAVE_PCI_LEGACY	1
 
-/* The PCI address space does equal the physical memory
- * address space (no IOMMU).  The IDE and SCSI device layers use
- * this boolean for bounce buffer decisions.
- */
-#define PCI_DMA_BUS_IS_PHYS     (1)
-
 extern void pcibios_claim_one_bus(struct pci_bus *b);
 
 extern void pcibios_finish_adding_to_bus(struct pci_bus *bus);
diff --git a/arch/microblaze/kernel/dma.c b/arch/microblaze/kernel/dma.c
index 990bf9ea0ec6..2a9a0ec14c46 100644
--- a/arch/microblaze/kernel/dma.c
+++ b/arch/microblaze/kernel/dma.c
@@ -216,6 +216,7 @@ const struct dma_map_ops dma_direct_ops = {
 	.sync_single_for_device		= dma_direct_sync_single_for_device,
 	.sync_sg_for_cpu		= dma_direct_sync_sg_for_cpu,
 	.sync_sg_for_device		= dma_direct_sync_sg_for_device,
+	.is_phys	= true,
 };
 EXPORT_SYMBOL(dma_direct_ops);
 
diff --git a/arch/mips/include/asm/pci.h b/arch/mips/include/asm/pci.h
index 2339f42f047a..436099883022 100644
--- a/arch/mips/include/asm/pci.h
+++ b/arch/mips/include/asm/pci.h
@@ -121,13 +121,6 @@ extern unsigned long PCIBIOS_MIN_MEM;
 #include <linux/string.h>
 #include <asm/io.h>
 
-/*
- * The PCI address space does equal the physical memory address space.
- * The networking and block device layers use this boolean for bounce
- * buffer decisions.
- */
-#define PCI_DMA_BUS_IS_PHYS     (1)
-
 #ifdef CONFIG_PCI_DOMAINS_GENERIC
 static inline int pci_proc_domain(struct pci_bus *bus)
 {
diff --git a/arch/mips/mm/dma-default.c b/arch/mips/mm/dma-default.c
index e3e94d05f0fd..3cd93e0c7a29 100644
--- a/arch/mips/mm/dma-default.c
+++ b/arch/mips/mm/dma-default.c
@@ -407,6 +407,7 @@ static const struct dma_map_ops mips_default_dma_map_ops = {
 	.mapping_error = mips_dma_mapping_error,
 	.dma_supported = mips_dma_supported,
 	.cache_sync = mips_dma_cache_sync,
+	.is_phys = true,
 };
 
 const struct dma_map_ops *mips_dma_map_ops = &mips_default_dma_map_ops;
diff --git a/arch/mn10300/include/asm/pci.h b/arch/mn10300/include/asm/pci.h
index 5b75a1b2c4f6..6132966bdf30 100644
--- a/arch/mn10300/include/asm/pci.h
+++ b/arch/mn10300/include/asm/pci.h
@@ -57,12 +57,6 @@ extern void unit_pci_init(void);
 #include <linux/string.h>
 #include <asm/io.h>
 
-/* The PCI address space does equal the physical memory
- * address space.  The networking and block device layers use
- * this boolean for bounce buffer decisions.
- */
-#define PCI_DMA_BUS_IS_PHYS	(1)
-
 /* Return the index of the PCI controller for device. */
 static inline int pci_controller_num(struct pci_dev *dev)
 {
diff --git a/arch/mn10300/mm/dma-alloc.c b/arch/mn10300/mm/dma-alloc.c
index 86108d2496b3..55876a87c247 100644
--- a/arch/mn10300/mm/dma-alloc.c
+++ b/arch/mn10300/mm/dma-alloc.c
@@ -128,4 +128,5 @@ const struct dma_map_ops mn10300_dma_ops = {
 	.map_sg			= mn10300_dma_map_sg,
 	.sync_single_for_device	= mn10300_dma_sync_single_for_device,
 	.sync_sg_for_device	= mn10300_dma_sync_sg_for_device,
+	.is_phys		= true,
 };
diff --git a/arch/nios2/mm/dma-mapping.c b/arch/nios2/mm/dma-mapping.c
index 7040c1adbb5e..599bcc09c9e7 100644
--- a/arch/nios2/mm/dma-mapping.c
+++ b/arch/nios2/mm/dma-mapping.c
@@ -203,5 +203,6 @@ const struct dma_map_ops nios2_dma_ops = {
 	.sync_single_for_cpu	= nios2_dma_sync_single_for_cpu,
 	.sync_sg_for_cpu	= nios2_dma_sync_sg_for_cpu,
 	.sync_sg_for_device	= nios2_dma_sync_sg_for_device,
+	.is_phys		= true,
 };
 EXPORT_SYMBOL(nios2_dma_ops);
diff --git a/arch/openrisc/kernel/dma.c b/arch/openrisc/kernel/dma.c
index a945f00011b4..7faad429d3dc 100644
--- a/arch/openrisc/kernel/dma.c
+++ b/arch/openrisc/kernel/dma.c
@@ -245,6 +245,7 @@ const struct dma_map_ops or1k_dma_map_ops = {
 	.unmap_sg = or1k_unmap_sg,
 	.sync_single_for_cpu = or1k_sync_single_for_cpu,
 	.sync_single_for_device = or1k_sync_single_for_device,
+	.is_phys = true,
 };
 EXPORT_SYMBOL(or1k_dma_map_ops);
 
diff --git a/arch/parisc/include/asm/pci.h b/arch/parisc/include/asm/pci.h
index 96b7deec512d..3328fd17c19d 100644
--- a/arch/parisc/include/asm/pci.h
+++ b/arch/parisc/include/asm/pci.h
@@ -87,29 +87,6 @@ struct pci_hba_data {
 #define PCI_F_EXTEND		0UL
 #endif /* !CONFIG_64BIT */
 
-/*
- * If the PCI device's view of memory is the same as the CPU's view of memory,
- * PCI_DMA_BUS_IS_PHYS is true.  The networking and block device layers use
- * this boolean for bounce buffer decisions.
- */
-#ifdef CONFIG_PA20
-/* All PA-2.0 machines have an IOMMU. */
-#define PCI_DMA_BUS_IS_PHYS	0
-#define parisc_has_iommu()	do { } while (0)
-#else
-
-#if defined(CONFIG_IOMMU_CCIO) || defined(CONFIG_IOMMU_SBA)
-extern int parisc_bus_is_phys; 	/* in arch/parisc/kernel/setup.c */
-#define PCI_DMA_BUS_IS_PHYS	parisc_bus_is_phys
-#define parisc_has_iommu()	do { parisc_bus_is_phys = 0; } while (0)
-#else
-#define PCI_DMA_BUS_IS_PHYS	1
-#define parisc_has_iommu()	do { } while (0)
-#endif
-
-#endif	/* !CONFIG_PA20 */
-
-
 /*
 ** Most PCI devices (eg Tulip, NCR720) also export the same registers
 ** to both MMIO and I/O port space.  Due to poor performance of I/O Port
diff --git a/arch/parisc/kernel/pci-dma.c b/arch/parisc/kernel/pci-dma.c
index c0dfd892f70c..6ad9aed3d025 100644
--- a/arch/parisc/kernel/pci-dma.c
+++ b/arch/parisc/kernel/pci-dma.c
@@ -591,6 +591,7 @@ const struct dma_map_ops pcxl_dma_ops = {
 	.sync_sg_for_cpu =	pa11_dma_sync_sg_for_cpu,
 	.sync_sg_for_device =	pa11_dma_sync_sg_for_device,
 	.cache_sync =		pa11_dma_cache_sync,
+	.is_phys =		true,
 };
 
 static void *pcx_dma_alloc(struct device *dev, size_t size,
@@ -628,4 +629,5 @@ const struct dma_map_ops pcx_dma_ops = {
 	.sync_sg_for_cpu =	pa11_dma_sync_sg_for_cpu,
 	.sync_sg_for_device =	pa11_dma_sync_sg_for_device,
 	.cache_sync =		pa11_dma_cache_sync,
+	.is_phys =		true,
 };
diff --git a/arch/parisc/kernel/setup.c b/arch/parisc/kernel/setup.c
index 0e9675f857a5..8d3a7b80ac42 100644
--- a/arch/parisc/kernel/setup.c
+++ b/arch/parisc/kernel/setup.c
@@ -58,11 +58,6 @@ struct proc_dir_entry * proc_runway_root __read_mostly = NULL;
 struct proc_dir_entry * proc_gsc_root __read_mostly = NULL;
 struct proc_dir_entry * proc_mckinley_root __read_mostly = NULL;
 
-#if !defined(CONFIG_PA20) && (defined(CONFIG_IOMMU_CCIO) || defined(CONFIG_IOMMU_SBA))
-int parisc_bus_is_phys __read_mostly = 1;	/* Assume no IOMMU is present */
-EXPORT_SYMBOL(parisc_bus_is_phys);
-#endif
-
 void __init setup_cmdline(char **cmdline_p)
 {
 	extern unsigned int boot_args[];
diff --git a/arch/powerpc/include/asm/pci.h b/arch/powerpc/include/asm/pci.h
index 8dc32eacc97c..04c1347e2c51 100644
--- a/arch/powerpc/include/asm/pci.h
+++ b/arch/powerpc/include/asm/pci.h
@@ -91,24 +91,6 @@ extern int pci_mmap_legacy_page_range(struct pci_bus *bus,
 
 #define HAVE_PCI_LEGACY	1
 
-#ifdef CONFIG_PPC64
-
-/* The PCI address space does not equal the physical memory address
- * space (we have an IOMMU).  The IDE and SCSI device layers use
- * this boolean for bounce buffer decisions.
- */
-#define PCI_DMA_BUS_IS_PHYS	(0)
-
-#else /* 32-bit */
-
-/* The PCI address space does equal the physical memory
- * address space (no IOMMU).  The IDE and SCSI device layers use
- * this boolean for bounce buffer decisions.
- */
-#define PCI_DMA_BUS_IS_PHYS     (1)
-
-#endif /* CONFIG_PPC64 */
-
 extern void pcibios_claim_one_bus(struct pci_bus *b);
 
 extern void pcibios_finish_adding_to_bus(struct pci_bus *bus);
diff --git a/arch/powerpc/kernel/dma.c b/arch/powerpc/kernel/dma.c
index 4194bbbbdb10..df0e7bb97ab5 100644
--- a/arch/powerpc/kernel/dma.c
+++ b/arch/powerpc/kernel/dma.c
@@ -290,6 +290,7 @@ const struct dma_map_ops dma_direct_ops = {
 	.sync_sg_for_cpu 		= dma_direct_sync_sg,
 	.sync_sg_for_device 		= dma_direct_sync_sg,
 #endif
+	.is_phys			= true,
 };
 EXPORT_SYMBOL(dma_direct_ops);
 
diff --git a/arch/riscv/include/asm/pci.h b/arch/riscv/include/asm/pci.h
index 0f2fc9ef20fc..b3638c505728 100644
--- a/arch/riscv/include/asm/pci.h
+++ b/arch/riscv/include/asm/pci.h
@@ -26,9 +26,6 @@
 /* RISC-V shim does not initialize PCI bus */
 #define pcibios_assign_all_busses() 1
 
-/* We do not have an IOMMU */
-#define PCI_DMA_BUS_IS_PHYS 1
-
 extern int isa_dma_bridge_buggy;
 
 #ifdef CONFIG_PCI
diff --git a/arch/s390/include/asm/pci.h b/arch/s390/include/asm/pci.h
index 12fe3591034f..94f8db468c9b 100644
--- a/arch/s390/include/asm/pci.h
+++ b/arch/s390/include/asm/pci.h
@@ -2,8 +2,6 @@
 #ifndef __ASM_S390_PCI_H
 #define __ASM_S390_PCI_H
 
-/* must be set before including asm-generic/pci.h */
-#define PCI_DMA_BUS_IS_PHYS (0)
 /* must be set before including pci_clp.h */
 #define PCI_BAR_COUNT	6
 
diff --git a/arch/s390/pci/pci_dma.c b/arch/s390/pci/pci_dma.c
index f7aa5a77827e..90826e2010da 100644
--- a/arch/s390/pci/pci_dma.c
+++ b/arch/s390/pci/pci_dma.c
@@ -668,9 +668,6 @@ const struct dma_map_ops s390_pci_dma_ops = {
 	.map_page	= s390_dma_map_pages,
 	.unmap_page	= s390_dma_unmap_pages,
 	.mapping_error	= s390_mapping_error,
-	/* if we support direct DMA this must be conditional */
-	.is_phys	= 0,
-	/* dma_supported is unconditionally true without a callback */
 };
 EXPORT_SYMBOL_GPL(s390_pci_dma_ops);
 
diff --git a/arch/sh/include/asm/pci.h b/arch/sh/include/asm/pci.h
index 0033f0df2b3b..10a36b1cf2ea 100644
--- a/arch/sh/include/asm/pci.h
+++ b/arch/sh/include/asm/pci.h
@@ -71,12 +71,6 @@ extern unsigned long PCIBIOS_MIN_IO, PCIBIOS_MIN_MEM;
  * SuperH has everything mapped statically like x86.
  */
 
-/* The PCI address space does equal the physical memory
- * address space.  The networking and block device layers use
- * this boolean for bounce buffer decisions.
- */
-#define PCI_DMA_BUS_IS_PHYS	(dma_ops->is_phys)
-
 #ifdef CONFIG_PCI
 /*
  * None of the SH PCI controllers support MWI, it is always treated as a
diff --git a/arch/sh/kernel/dma-nommu.c b/arch/sh/kernel/dma-nommu.c
index 62b485107eae..a2ef7f19610d 100644
--- a/arch/sh/kernel/dma-nommu.c
+++ b/arch/sh/kernel/dma-nommu.c
@@ -75,7 +75,7 @@ const struct dma_map_ops nommu_dma_ops = {
 	.sync_single_for_device	= nommu_sync_single_for_device,
 	.sync_sg_for_device	= nommu_sync_sg_for_device,
 #endif
-	.is_phys		= 1,
+	.is_phys		= true,
 };
 
 void __init no_iommu_init(void)
diff --git a/arch/sparc/include/asm/pci_32.h b/arch/sparc/include/asm/pci_32.h
index 98917e48727d..cfc0ee9476c6 100644
--- a/arch/sparc/include/asm/pci_32.h
+++ b/arch/sparc/include/asm/pci_32.h
@@ -17,10 +17,6 @@
 
 #define PCI_IRQ_NONE		0xffffffff
 
-/* Dynamic DMA mapping stuff.
- */
-#define PCI_DMA_BUS_IS_PHYS	(0)
-
 #endif /* __KERNEL__ */
 
 #ifndef CONFIG_LEON_PCI
diff --git a/arch/sparc/include/asm/pci_64.h b/arch/sparc/include/asm/pci_64.h
index 671274e36cfa..fac77813402c 100644
--- a/arch/sparc/include/asm/pci_64.h
+++ b/arch/sparc/include/asm/pci_64.h
@@ -17,12 +17,6 @@
 
 #define PCI_IRQ_NONE		0xffffffff
 
-/* The PCI address space does not equal the physical memory
- * address space.  The networking and block device layers use
- * this boolean for bounce buffer decisions.
- */
-#define PCI_DMA_BUS_IS_PHYS	(0)
-
 /* PCI IOMMU mapping bypass support. */
 
 /* PCI 64-bit addressing works for all slots on all controller
diff --git a/arch/sparc/kernel/ioport.c b/arch/sparc/kernel/ioport.c
index 7eeef80c02f7..a401e8e0579d 100644
--- a/arch/sparc/kernel/ioport.c
+++ b/arch/sparc/kernel/ioport.c
@@ -656,6 +656,7 @@ const struct dma_map_ops pci32_dma_ops = {
 	.sync_single_for_device	= pci32_sync_single_for_device,
 	.sync_sg_for_cpu	= pci32_sync_sg_for_cpu,
 	.sync_sg_for_device	= pci32_sync_sg_for_device,
+	.is_phys		= true,
 };
 EXPORT_SYMBOL(pci32_dma_ops);
 
diff --git a/arch/tile/include/asm/pci.h b/arch/tile/include/asm/pci.h
index fe3de505b024..8b910e3f0620 100644
--- a/arch/tile/include/asm/pci.h
+++ b/arch/tile/include/asm/pci.h
@@ -52,13 +52,6 @@ static inline void pci_iounmap(struct pci_dev *dev, void __iomem *addr) {}
 
 #define	TILE_NUM_PCIE	2
 
-/*
- * The hypervisor maps the entirety of CPA-space as bus addresses, so
- * bus addresses are physical addresses.  The networking and block
- * device layers use this boolean for bounce buffer decisions.
- */
-#define PCI_DMA_BUS_IS_PHYS     1
-
 /* generic pci stuff */
 #include <asm-generic/pci.h>
 
@@ -185,13 +178,6 @@ extern int num_trio_shims;
 
 extern void pci_iounmap(struct pci_dev *dev, void __iomem *);
 
-/*
- * The PCI address space does not equal the physical memory address
- * space (we have an IOMMU). The IDE and SCSI device layers use this
- * boolean for bounce buffer decisions.
- */
-#define PCI_DMA_BUS_IS_PHYS     0
-
 #endif /* __tilegx__ */
 
 int __init tile_pci_init(void);
diff --git a/arch/tile/kernel/pci-dma.c b/arch/tile/kernel/pci-dma.c
index f2abedc8a080..9072e2c25e59 100644
--- a/arch/tile/kernel/pci-dma.c
+++ b/arch/tile/kernel/pci-dma.c
@@ -328,6 +328,7 @@ static const struct dma_map_ops tile_default_dma_map_ops = {
 	.sync_single_for_device = tile_dma_sync_single_for_device,
 	.sync_sg_for_cpu = tile_dma_sync_sg_for_cpu,
 	.sync_sg_for_device = tile_dma_sync_sg_for_device,
+	.is_phys = true,
 };
 
 const struct dma_map_ops *tile_dma_map_ops = &tile_default_dma_map_ops;
@@ -501,6 +502,7 @@ static const struct dma_map_ops tile_pci_default_dma_map_ops = {
 	.sync_single_for_device = tile_pci_dma_sync_single_for_device,
 	.sync_sg_for_cpu = tile_pci_dma_sync_sg_for_cpu,
 	.sync_sg_for_device = tile_pci_dma_sync_sg_for_device,
+	.is_phys = true,
 };
 
 const struct dma_map_ops *gx_pci_dma_map_ops = &tile_pci_default_dma_map_ops;
diff --git a/arch/x86/include/asm/pci.h b/arch/x86/include/asm/pci.h
index d32175e30259..fecde74ff549 100644
--- a/arch/x86/include/asm/pci.h
+++ b/arch/x86/include/asm/pci.h
@@ -118,8 +118,6 @@ void native_restore_msi_irqs(struct pci_dev *dev);
 #define native_teardown_msi_irq		NULL
 #endif
 
-#define PCI_DMA_BUS_IS_PHYS (dma_ops->is_phys)
-
 #endif  /* __KERNEL__ */
 
 #ifdef CONFIG_X86_64
diff --git a/arch/x86/kernel/pci-nommu.c b/arch/x86/kernel/pci-nommu.c
index c78df78b5ccd..8ac9d1fe0373 100644
--- a/arch/x86/kernel/pci-nommu.c
+++ b/arch/x86/kernel/pci-nommu.c
@@ -84,7 +84,7 @@ const struct dma_map_ops nommu_dma_ops = {
 	.free			= dma_generic_free_coherent,
 	.map_sg			= nommu_map_sg,
 	.map_page		= nommu_map_page,
-	.is_phys		= 1,
 	.mapping_error		= nommu_mapping_error,
 	.dma_supported		= x86_dma_supported,
+	.is_phys		= true,
 };
diff --git a/arch/xtensa/include/asm/pci.h b/arch/xtensa/include/asm/pci.h
index 5c83798e3b2e..7949349294c7 100644
--- a/arch/xtensa/include/asm/pci.h
+++ b/arch/xtensa/include/asm/pci.h
@@ -37,13 +37,6 @@ extern struct pci_controller* pcibios_alloc_controller(void);
 #include <linux/string.h>
 #include <asm/io.h>
 
-/* The PCI address space does equal the physical memory address space.
- * The networking and block device layers use this boolean for bounce buffer
- * decisions.
- */
-
-#define PCI_DMA_BUS_IS_PHYS	(1)
-
 /* Tell drivers/pci/proc.c that we have pci_mmap_page_range() */
 #define HAVE_PCI_MMAP		1
 #define arch_can_pci_mmap_io()	1
diff --git a/arch/xtensa/kernel/pci-dma.c b/arch/xtensa/kernel/pci-dma.c
index 623720a11143..4a51996d2919 100644
--- a/arch/xtensa/kernel/pci-dma.c
+++ b/arch/xtensa/kernel/pci-dma.c
@@ -239,6 +239,7 @@ const struct dma_map_ops xtensa_dma_map_ops = {
 	.sync_sg_for_cpu = xtensa_sync_sg_for_cpu,
 	.sync_sg_for_device = xtensa_sync_sg_for_device,
 	.mapping_error = xtensa_dma_mapping_error,
+	.is_phys = true,
 };
 EXPORT_SYMBOL(xtensa_dma_map_ops);
 
diff --git a/drivers/ide/ide-lib.c b/drivers/ide/ide-lib.c
index e1180fa46196..0cdd661ddee0 100644
--- a/drivers/ide/ide-lib.c
+++ b/drivers/ide/ide-lib.c
@@ -17,13 +17,12 @@
 
 void ide_toggle_bounce(ide_drive_t *drive, int on)
 {
+	struct device *dev = drive->hwif ? drive->hwif->dev : NULL;
 	u64 addr = BLK_BOUNCE_HIGH;	/* dma64_addr_t */
 
-	if (!PCI_DMA_BUS_IS_PHYS) {
+	if (dev && !dma_is_phys(dev)) {
 		addr = BLK_BOUNCE_ANY;
 	} else if (on && drive->media = ide_disk) {
-		struct device *dev = drive->hwif->dev;
-
 		if (dev && dev->dma_mask)
 			addr = *dev->dma_mask;
 	}
diff --git a/drivers/ide/ide-probe.c b/drivers/ide/ide-probe.c
index 17fd55af4d92..7fe4d751e6cf 100644
--- a/drivers/ide/ide-probe.c
+++ b/drivers/ide/ide-probe.c
@@ -796,7 +796,7 @@ static int ide_init_queue(ide_drive_t *drive)
 	 * This will be fixed once we teach pci_map_sg() about our boundary
 	 * requirements, hopefully soon. *FIXME*
 	 */
-	if (!PCI_DMA_BUS_IS_PHYS)
+	if (hwif->dev && !dma_is_phys(hwif->dev))
 		max_sg_entries >>= 1;
 #endif /* CONFIG_PCI */
 
diff --git a/drivers/parisc/ccio-dma.c b/drivers/parisc/ccio-dma.c
index acba1f56af3e..2b129d8525d5 100644
--- a/drivers/parisc/ccio-dma.c
+++ b/drivers/parisc/ccio-dma.c
@@ -1596,8 +1596,6 @@ static int __init ccio_probe(struct parisc_device *dev)
 	}
 #endif
 	ioc_count++;
-
-	parisc_has_iommu();
 	return 0;
 }
 
diff --git a/drivers/parisc/sba_iommu.c b/drivers/parisc/sba_iommu.c
index 0a9c762a70fa..a58c586ebd81 100644
--- a/drivers/parisc/sba_iommu.c
+++ b/drivers/parisc/sba_iommu.c
@@ -2017,8 +2017,6 @@ static int __init sba_driver_callback(struct parisc_device *dev)
 	proc_create("sba_iommu", 0, root, &sba_proc_fops);
 	proc_create("sba_iommu-bitmap", 0, root, &sba_proc_bitmap_fops);
 #endif
-
-	parisc_has_iommu();
 	return 0;
 }
 
diff --git a/drivers/pci/host/vmd.c b/drivers/pci/host/vmd.c
index 509893bc3e63..5bb03ad9ed21 100644
--- a/drivers/pci/host/vmd.c
+++ b/drivers/pci/host/vmd.c
@@ -428,6 +428,7 @@ static void vmd_setup_dma_ops(struct vmd_dev *vmd)
 #ifdef ARCH_HAS_DMA_GET_REQUIRED_MASK
 	ASSIGN_VMD_DMA_OPS(source, dest, get_required_mask);
 #endif
+	dest->is_phys = source->is_phys;
 	add_dma_domain(domain);
 }
 #undef ASSIGN_VMD_DMA_OPS
diff --git a/drivers/scsi/scsi_lib.c b/drivers/scsi/scsi_lib.c
index d9ca1dfab154..2644214a92ca 100644
--- a/drivers/scsi/scsi_lib.c
+++ b/drivers/scsi/scsi_lib.c
@@ -2105,16 +2105,14 @@ static u64 scsi_calculate_bounce_limit(struct Scsi_Host *shost)
 
 	if (shost->unchecked_isa_dma)
 		return BLK_BOUNCE_ISA;
-	/*
-	 * Platforms with virtual-DMA translation
-	 * hardware have no practical limit.
-	 */
-	if (!PCI_DMA_BUS_IS_PHYS)
-		return BLK_BOUNCE_ANY;
 
 	host_dev = scsi_get_device(shost);
-	if (host_dev && host_dev->dma_mask)
-		bounce_limit = (u64)dma_max_pfn(host_dev) << PAGE_SHIFT;
+	if (host_dev) {
+		if (!dma_is_phys(host_dev))
+			return BLK_BOUNCE_ANY;
+		if (host_dev->dma_mask)
+			bounce_limit = (u64)dma_max_pfn(host_dev) << PAGE_SHIFT;
+	}
 
 	return bounce_limit;
 }
diff --git a/include/asm-generic/pci.h b/include/asm-generic/pci.h
index 830d7659289b..6bb3cd3d695a 100644
--- a/include/asm-generic/pci.h
+++ b/include/asm-generic/pci.h
@@ -14,12 +14,4 @@ static inline int pci_get_legacy_ide_irq(struct pci_dev *dev, int channel)
 }
 #endif /* HAVE_ARCH_PCI_GET_LEGACY_IDE_IRQ */
 
-/*
- * By default, assume that no iommu is in use and that the PCI
- * space is mapped to address physical 0.
- */
-#ifndef PCI_DMA_BUS_IS_PHYS
-#define PCI_DMA_BUS_IS_PHYS	(1)
-#endif
-
 #endif /* _ASM_GENERIC_PCI_H */
diff --git a/include/linux/dma-mapping.h b/include/linux/dma-mapping.h
index d84951865be7..e77e2dec4723 100644
--- a/include/linux/dma-mapping.h
+++ b/include/linux/dma-mapping.h
@@ -133,7 +133,14 @@ struct dma_map_ops {
 #ifdef ARCH_HAS_DMA_GET_REQUIRED_MASK
 	u64 (*get_required_mask)(struct device *dev);
 #endif
-	int is_phys;
+
+	/*
+	 * If is_phys is true, the dma_map_ops implementation only does a
+	 * linear mapping from physical to DMA address, and can only address
+	 * memory up to dma_max_pfn().  If is_phys is false DMA is possible
+	 * to any physical address.
+	 */
+	bool is_phys;
 };
 
 extern const struct dma_map_ops dma_noop_ops;
@@ -689,6 +696,20 @@ static inline int dma_set_seg_boundary(struct device *dev, unsigned long mask)
 	return -EIO;
 }
 
+#ifdef CONFIG_HAS_DMA
+static inline bool dma_is_phys(struct device *dev)
+{
+	const struct dma_map_ops *ops = get_dma_ops(dev);
+
+	return ops && ops->is_phys;
+}
+#else
+static inline bool dma_is_phys(struct device *dev)
+{
+	return false;
+}
+#endif
+
 #ifndef dma_max_pfn
 static inline unsigned long dma_max_pfn(struct device *dev)
 {
diff --git a/lib/dma-noop.c b/lib/dma-noop.c
index a10185b0c2d4..c3728a0551f5 100644
--- a/lib/dma-noop.c
+++ b/lib/dma-noop.c
@@ -63,6 +63,7 @@ const struct dma_map_ops dma_noop_ops = {
 	.free			= dma_noop_free,
 	.map_page		= dma_noop_map_page,
 	.map_sg			= dma_noop_map_sg,
+	.is_phys		= true,
 };
 
 EXPORT_SYMBOL(dma_noop_ops);
diff --git a/net/core/dev.c b/net/core/dev.c
index 01ee854454a8..ddf45f9217d4 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2830,6 +2830,7 @@ EXPORT_SYMBOL(netdev_rx_csum_fault);
 static int illegal_highdma(struct net_device *dev, struct sk_buff *skb)
 {
 #ifdef CONFIG_HIGHMEM
+	struct device *pdev = dev->dev.parent;
 	int i;
 
 	if (!(dev->features & NETIF_F_HIGHDMA)) {
@@ -2841,18 +2842,15 @@ static int illegal_highdma(struct net_device *dev, struct sk_buff *skb)
 		}
 	}
 
-	if (PCI_DMA_BUS_IS_PHYS) {
-		struct device *pdev = dev->dev.parent;
+	if (!pdev || !dma_is_phys(pdev))
+		return 0;
 
-		if (!pdev)
-			return 0;
-		for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
-			skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
-			dma_addr_t addr = page_to_phys(skb_frag_page(frag));
+	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
+		skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
+		dma_addr_t addr = page_to_phys(skb_frag_page(frag));
 
-			if (!pdev->dma_mask || addr + PAGE_SIZE - 1 > *pdev->dma_mask)
-				return 1;
-		}
+		if (!pdev->dma_mask || addr + PAGE_SIZE - 1 > *pdev->dma_mask)
+			return 1;
 	}
 #endif
 	return 0;
diff --git a/tools/virtio/linux/dma-mapping.h b/tools/virtio/linux/dma-mapping.h
index 1571e24e9494..f91aeb5fe571 100644
--- a/tools/virtio/linux/dma-mapping.h
+++ b/tools/virtio/linux/dma-mapping.h
@@ -6,8 +6,6 @@
 # error Virtio userspace code does not support CONFIG_HAS_DMA
 #endif
 
-#define PCI_DMA_BUS_IS_PHYS 1
-
 enum dma_data_direction {
 	DMA_BIDIRECTIONAL = 0,
 	DMA_TO_DEVICE = 1,
-- 
2.14.2

