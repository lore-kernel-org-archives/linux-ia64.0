From: Christoph Hellwig <hch@lst.de>
Date: Fri, 12 Jan 2018 08:42:10 +0000
Subject: [PATCH 12/34] dma-mapping: move swiotlb arch helpers to a new header
Message-Id: <20180112084232.2857-13-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180112084232.2857-1-hch@lst.de>
In-Reply-To: <20180112084232.2857-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: iommu@lists.linux-foundation.org
Cc: Konrad Rzeszutek Wilk <konrad@darnok.org>, linux-alpha@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-c6x-dev@linux-c6x.org, linux-cris-kernel@axis.com, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-metag@vger.kernel.org, Michal Simek <monstr@monstr.eu>, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, patches@groups.riscv.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, Guan Xuetao <gxt@mprc.pku.edu.cn>, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

phys_to_dma, dma_to_phys and dma_capable are helpers published by
architecture code for use of swiotlb and xen-swiotlb only.  Drivers are
not supposed to use these directly, but use the DMA API instead.

Move these to a new asm/dma-direct.h helper, included by a
linux/dma-direct.h wrapper that provides the default linear mapping
unless the architecture wants to override it.

In the MIPS case the existing dma-coherent.h is reused for now as
untangling it will take a bit of work.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Acked-by: Robin Murphy <robin.murphy@arm.com>
---
 MAINTAINERS                                        |  1 +
 arch/Kconfig                                       |  4 +++
 arch/arm/Kconfig                                   |  1 +
 arch/arm/include/asm/dma-direct.h                  | 36 ++++++++++++++++++++++
 arch/arm/include/asm/dma-mapping.h                 | 31 -------------------
 arch/arm64/include/asm/dma-mapping.h               | 22 -------------
 arch/arm64/mm/dma-mapping.c                        |  2 +-
 arch/ia64/include/asm/dma-mapping.h                | 18 -----------
 arch/mips/Kconfig                                  |  2 ++
 arch/mips/include/asm/dma-direct.h                 |  1 +
 arch/mips/include/asm/dma-mapping.h                |  8 -----
 .../include/asm/mach-cavium-octeon/dma-coherence.h |  8 +++++
 arch/mips/include/asm/mach-generic/dma-coherence.h | 12 --------
 .../include/asm/mach-loongson64/dma-coherence.h    |  8 +++++
 arch/powerpc/Kconfig                               |  1 +
 arch/powerpc/include/asm/dma-direct.h              | 29 +++++++++++++++++
 arch/powerpc/include/asm/dma-mapping.h             | 25 ---------------
 arch/tile/include/asm/dma-mapping.h                | 18 -----------
 arch/unicore32/include/asm/dma-mapping.h           | 18 -----------
 arch/x86/Kconfig                                   |  1 +
 arch/x86/include/asm/dma-direct.h                  | 30 ++++++++++++++++++
 arch/x86/include/asm/dma-mapping.h                 | 26 ----------------
 arch/x86/kernel/amd_gart_64.c                      |  1 +
 arch/x86/kernel/pci-dma.c                          |  2 +-
 arch/x86/kernel/pci-nommu.c                        |  2 +-
 arch/x86/kernel/pci-swiotlb.c                      |  2 +-
 arch/x86/mm/mem_encrypt.c                          |  2 +-
 arch/x86/pci/sta2x11-fixup.c                       |  1 +
 arch/xtensa/include/asm/dma-mapping.h              | 10 ------
 drivers/crypto/marvell/cesa.c                      |  1 +
 drivers/mtd/nand/qcom_nandc.c                      |  1 +
 drivers/xen/swiotlb-xen.c                          |  2 +-
 include/linux/dma-direct.h                         | 32 +++++++++++++++++++
 lib/swiotlb.c                                      |  2 +-
 34 files changed, 165 insertions(+), 195 deletions(-)
 create mode 100644 arch/arm/include/asm/dma-direct.h
 create mode 100644 arch/mips/include/asm/dma-direct.h
 create mode 100644 arch/powerpc/include/asm/dma-direct.h
 create mode 100644 arch/x86/include/asm/dma-direct.h
 create mode 100644 include/linux/dma-direct.h

diff --git a/MAINTAINERS b/MAINTAINERS
index 95c3fa1f520f..d2cfdcce1db5 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -4338,6 +4338,7 @@ F:	lib/dma-noop.c
 F:	lib/dma-virt.c
 F:	drivers/base/dma-mapping.c
 F:	drivers/base/dma-coherent.c
+F:	include/linux/dma-direct.h
 F:	include/linux/dma-mapping.h
 
 DME1737 HARDWARE MONITOR DRIVER
diff --git a/arch/Kconfig b/arch/Kconfig
index 400b9e1b2f27..3edf118ad777 100644
--- a/arch/Kconfig
+++ b/arch/Kconfig
@@ -938,6 +938,10 @@ config STRICT_MODULE_RWX
 	  and non-text memory will be made non-executable. This provides
 	  protection against certain security exploits (e.g. writing to text)
 
+# select if the architecture provides an asm/dma-direct.h header
+config ARCH_HAS_PHYS_TO_DMA
+	bool
+
 config ARCH_HAS_REFCOUNT
 	bool
 	help
diff --git a/arch/arm/Kconfig b/arch/arm/Kconfig
index 51c8df561077..00d889a37965 100644
--- a/arch/arm/Kconfig
+++ b/arch/arm/Kconfig
@@ -8,6 +8,7 @@ config ARM
 	select ARCH_HAS_DEVMEM_IS_ALLOWED
 	select ARCH_HAS_ELF_RANDOMIZE
 	select ARCH_HAS_SET_MEMORY
+	select ARCH_HAS_PHYS_TO_DMA
 	select ARCH_HAS_STRICT_KERNEL_RWX if MMU && !XIP_KERNEL
 	select ARCH_HAS_STRICT_MODULE_RWX if MMU
 	select ARCH_HAS_TICK_BROADCAST if GENERIC_CLOCKEVENTS_BROADCAST
diff --git a/arch/arm/include/asm/dma-direct.h b/arch/arm/include/asm/dma-direct.h
new file mode 100644
index 000000000000..5b0a8a421894
--- /dev/null
+++ b/arch/arm/include/asm/dma-direct.h
@@ -0,0 +1,36 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+#ifndef ASM_ARM_DMA_DIRECT_H
+#define ASM_ARM_DMA_DIRECT_H 1
+
+static inline dma_addr_t phys_to_dma(struct device *dev, phys_addr_t paddr)
+{
+	unsigned int offset = paddr & ~PAGE_MASK;
+	return pfn_to_dma(dev, __phys_to_pfn(paddr)) + offset;
+}
+
+static inline phys_addr_t dma_to_phys(struct device *dev, dma_addr_t dev_addr)
+{
+	unsigned int offset = dev_addr & ~PAGE_MASK;
+	return __pfn_to_phys(dma_to_pfn(dev, dev_addr)) + offset;
+}
+
+static inline bool dma_capable(struct device *dev, dma_addr_t addr, size_t size)
+{
+	u64 limit, mask;
+
+	if (!dev->dma_mask)
+		return 0;
+
+	mask = *dev->dma_mask;
+
+	limit = (mask + 1) & ~mask;
+	if (limit && size > limit)
+		return 0;
+
+	if ((addr | (addr + size - 1)) & ~mask)
+		return 0;
+
+	return 1;
+}
+
+#endif /* ASM_ARM_DMA_DIRECT_H */
diff --git a/arch/arm/include/asm/dma-mapping.h b/arch/arm/include/asm/dma-mapping.h
index daf837423a76..5fb1b7fbdfbe 100644
--- a/arch/arm/include/asm/dma-mapping.h
+++ b/arch/arm/include/asm/dma-mapping.h
@@ -109,37 +109,6 @@ static inline bool is_device_dma_coherent(struct device *dev)
 	return dev->archdata.dma_coherent;
 }
 
-static inline dma_addr_t phys_to_dma(struct device *dev, phys_addr_t paddr)
-{
-	unsigned int offset = paddr & ~PAGE_MASK;
-	return pfn_to_dma(dev, __phys_to_pfn(paddr)) + offset;
-}
-
-static inline phys_addr_t dma_to_phys(struct device *dev, dma_addr_t dev_addr)
-{
-	unsigned int offset = dev_addr & ~PAGE_MASK;
-	return __pfn_to_phys(dma_to_pfn(dev, dev_addr)) + offset;
-}
-
-static inline bool dma_capable(struct device *dev, dma_addr_t addr, size_t size)
-{
-	u64 limit, mask;
-
-	if (!dev->dma_mask)
-		return 0;
-
-	mask = *dev->dma_mask;
-
-	limit = (mask + 1) & ~mask;
-	if (limit && size > limit)
-		return 0;
-
-	if ((addr | (addr + size - 1)) & ~mask)
-		return 0;
-
-	return 1;
-}
-
 static inline void dma_mark_clean(void *addr, size_t size) { }
 
 /**
diff --git a/arch/arm64/include/asm/dma-mapping.h b/arch/arm64/include/asm/dma-mapping.h
index eada887a93bf..400fa67d3b5a 100644
--- a/arch/arm64/include/asm/dma-mapping.h
+++ b/arch/arm64/include/asm/dma-mapping.h
@@ -50,28 +50,6 @@ static inline bool is_device_dma_coherent(struct device *dev)
 	return dev->archdata.dma_coherent;
 }
 
-static inline dma_addr_t phys_to_dma(struct device *dev, phys_addr_t paddr)
-{
-	dma_addr_t dev_addr = (dma_addr_t)paddr;
-
-	return dev_addr - ((dma_addr_t)dev->dma_pfn_offset << PAGE_SHIFT);
-}
-
-static inline phys_addr_t dma_to_phys(struct device *dev, dma_addr_t dev_addr)
-{
-	phys_addr_t paddr = (phys_addr_t)dev_addr;
-
-	return paddr + ((phys_addr_t)dev->dma_pfn_offset << PAGE_SHIFT);
-}
-
-static inline bool dma_capable(struct device *dev, dma_addr_t addr, size_t size)
-{
-	if (!dev->dma_mask)
-		return false;
-
-	return addr + size - 1 <= *dev->dma_mask;
-}
-
 static inline void dma_mark_clean(void *addr, size_t size)
 {
 }
diff --git a/arch/arm64/mm/dma-mapping.c b/arch/arm64/mm/dma-mapping.c
index b45c5bcaeccb..f3a637b98487 100644
--- a/arch/arm64/mm/dma-mapping.c
+++ b/arch/arm64/mm/dma-mapping.c
@@ -24,7 +24,7 @@
 #include <linux/export.h>
 #include <linux/slab.h>
 #include <linux/genalloc.h>
-#include <linux/dma-mapping.h>
+#include <linux/dma-direct.h>
 #include <linux/dma-contiguous.h>
 #include <linux/vmalloc.h>
 #include <linux/swiotlb.h>
diff --git a/arch/ia64/include/asm/dma-mapping.h b/arch/ia64/include/asm/dma-mapping.h
index c1bab526a046..eabee56d995c 100644
--- a/arch/ia64/include/asm/dma-mapping.h
+++ b/arch/ia64/include/asm/dma-mapping.h
@@ -27,22 +27,4 @@ static inline const struct dma_map_ops *get_arch_dma_ops(struct bus_type *bus)
 	return platform_dma_get_ops(NULL);
 }
 
-static inline bool dma_capable(struct device *dev, dma_addr_t addr, size_t size)
-{
-	if (!dev->dma_mask)
-		return 0;
-
-	return addr + size - 1 <= *dev->dma_mask;
-}
-
-static inline dma_addr_t phys_to_dma(struct device *dev, phys_addr_t paddr)
-{
-	return paddr;
-}
-
-static inline phys_addr_t dma_to_phys(struct device *dev, dma_addr_t daddr)
-{
-	return daddr;
-}
-
 #endif /* _ASM_IA64_DMA_MAPPING_H */
diff --git a/arch/mips/Kconfig b/arch/mips/Kconfig
index 350a990fc719..4b0c26b2e9b7 100644
--- a/arch/mips/Kconfig
+++ b/arch/mips/Kconfig
@@ -429,6 +429,7 @@ config MACH_LOONGSON32
 
 config MACH_LOONGSON64
 	bool "Loongson-2/3 family of machines"
+	select ARCH_HAS_PHYS_TO_DMA
 	select SYS_SUPPORTS_ZBOOT
 	help
 	  This enables the support of Loongson-2/3 family of machines.
@@ -877,6 +878,7 @@ config MIKROTIK_RB532
 config CAVIUM_OCTEON_SOC
 	bool "Cavium Networks Octeon SoC based boards"
 	select CEVT_R4K
+	select ARCH_HAS_PHYS_TO_DMA
 	select ARCH_PHYS_ADDR_T_64BIT
 	select DMA_COHERENT
 	select SYS_SUPPORTS_64BIT_KERNEL
diff --git a/arch/mips/include/asm/dma-direct.h b/arch/mips/include/asm/dma-direct.h
new file mode 100644
index 000000000000..f32f15530aba
--- /dev/null
+++ b/arch/mips/include/asm/dma-direct.h
@@ -0,0 +1 @@
+#include <asm/dma-coherence.h>
diff --git a/arch/mips/include/asm/dma-mapping.h b/arch/mips/include/asm/dma-mapping.h
index 5c334ac15945..676c14cfc580 100644
--- a/arch/mips/include/asm/dma-mapping.h
+++ b/arch/mips/include/asm/dma-mapping.h
@@ -17,14 +17,6 @@ static inline const struct dma_map_ops *get_arch_dma_ops(struct bus_type *bus)
 	return mips_dma_map_ops;
 }
 
-static inline bool dma_capable(struct device *dev, dma_addr_t addr, size_t size)
-{
-	if (!dev->dma_mask)
-		return false;
-
-	return addr + size - 1 <= *dev->dma_mask;
-}
-
 static inline void dma_mark_clean(void *addr, size_t size) {}
 
 #define arch_setup_dma_ops arch_setup_dma_ops
diff --git a/arch/mips/include/asm/mach-cavium-octeon/dma-coherence.h b/arch/mips/include/asm/mach-cavium-octeon/dma-coherence.h
index 9110988b92a1..138edf6b5b48 100644
--- a/arch/mips/include/asm/mach-cavium-octeon/dma-coherence.h
+++ b/arch/mips/include/asm/mach-cavium-octeon/dma-coherence.h
@@ -61,6 +61,14 @@ static inline void plat_post_dma_flush(struct device *dev)
 {
 }
 
+static inline bool dma_capable(struct device *dev, dma_addr_t addr, size_t size)
+{
+	if (!dev->dma_mask)
+		return false;
+
+	return addr + size - 1 <= *dev->dma_mask;
+}
+
 dma_addr_t phys_to_dma(struct device *dev, phys_addr_t paddr);
 phys_addr_t dma_to_phys(struct device *dev, dma_addr_t daddr);
 
diff --git a/arch/mips/include/asm/mach-generic/dma-coherence.h b/arch/mips/include/asm/mach-generic/dma-coherence.h
index 61addb1677e9..8ad7a40ca786 100644
--- a/arch/mips/include/asm/mach-generic/dma-coherence.h
+++ b/arch/mips/include/asm/mach-generic/dma-coherence.h
@@ -70,16 +70,4 @@ static inline void plat_post_dma_flush(struct device *dev)
 }
 #endif
 
-#ifdef CONFIG_SWIOTLB
-static inline dma_addr_t phys_to_dma(struct device *dev, phys_addr_t paddr)
-{
-	return paddr;
-}
-
-static inline phys_addr_t dma_to_phys(struct device *dev, dma_addr_t daddr)
-{
-	return daddr;
-}
-#endif
-
 #endif /* __ASM_MACH_GENERIC_DMA_COHERENCE_H */
diff --git a/arch/mips/include/asm/mach-loongson64/dma-coherence.h b/arch/mips/include/asm/mach-loongson64/dma-coherence.h
index 1602a9e9e8c2..b1b575f5c6c1 100644
--- a/arch/mips/include/asm/mach-loongson64/dma-coherence.h
+++ b/arch/mips/include/asm/mach-loongson64/dma-coherence.h
@@ -17,6 +17,14 @@
 
 struct device;
 
+static inline bool dma_capable(struct device *dev, dma_addr_t addr, size_t size)
+{
+	if (!dev->dma_mask)
+		return false;
+
+	return addr + size - 1 <= *dev->dma_mask;
+}
+
 extern dma_addr_t phys_to_dma(struct device *dev, phys_addr_t paddr);
 extern phys_addr_t dma_to_phys(struct device *dev, dma_addr_t daddr);
 static inline dma_addr_t plat_map_dma_mem(struct device *dev, void *addr,
diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
index c51e6ce42e7a..887285eb684a 100644
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -139,6 +139,7 @@ config PPC
 	select ARCH_HAS_ELF_RANDOMIZE
 	select ARCH_HAS_FORTIFY_SOURCE
 	select ARCH_HAS_GCOV_PROFILE_ALL
+	select ARCH_HAS_PHYS_TO_DMA
 	select ARCH_HAS_PMEM_API                if PPC64
 	select ARCH_HAS_SCALED_CPUTIME		if VIRT_CPU_ACCOUNTING_NATIVE
 	select ARCH_HAS_SG_CHAIN
diff --git a/arch/powerpc/include/asm/dma-direct.h b/arch/powerpc/include/asm/dma-direct.h
new file mode 100644
index 000000000000..a5b59c765426
--- /dev/null
+++ b/arch/powerpc/include/asm/dma-direct.h
@@ -0,0 +1,29 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+#ifndef ASM_POWERPC_DMA_DIRECT_H
+#define ASM_POWERPC_DMA_DIRECT_H 1
+
+static inline bool dma_capable(struct device *dev, dma_addr_t addr, size_t size)
+{
+#ifdef CONFIG_SWIOTLB
+	struct dev_archdata *sd = &dev->archdata;
+
+	if (sd->max_direct_dma_addr && addr + size > sd->max_direct_dma_addr)
+		return false;
+#endif
+
+	if (!dev->dma_mask)
+		return false;
+
+	return addr + size - 1 <= *dev->dma_mask;
+}
+
+static inline dma_addr_t phys_to_dma(struct device *dev, phys_addr_t paddr)
+{
+	return paddr + get_dma_offset(dev);
+}
+
+static inline phys_addr_t dma_to_phys(struct device *dev, dma_addr_t daddr)
+{
+	return daddr - get_dma_offset(dev);
+}
+#endif /* ASM_POWERPC_DMA_DIRECT_H */
diff --git a/arch/powerpc/include/asm/dma-mapping.h b/arch/powerpc/include/asm/dma-mapping.h
index 592c7f418aa0..f6ab51205a85 100644
--- a/arch/powerpc/include/asm/dma-mapping.h
+++ b/arch/powerpc/include/asm/dma-mapping.h
@@ -112,31 +112,6 @@ extern int dma_set_mask(struct device *dev, u64 dma_mask);
 
 extern u64 __dma_get_required_mask(struct device *dev);
 
-static inline bool dma_capable(struct device *dev, dma_addr_t addr, size_t size)
-{
-#ifdef CONFIG_SWIOTLB
-	struct dev_archdata *sd = &dev->archdata;
-
-	if (sd->max_direct_dma_addr && addr + size > sd->max_direct_dma_addr)
-		return false;
-#endif
-
-	if (!dev->dma_mask)
-		return false;
-
-	return addr + size - 1 <= *dev->dma_mask;
-}
-
-static inline dma_addr_t phys_to_dma(struct device *dev, phys_addr_t paddr)
-{
-	return paddr + get_dma_offset(dev);
-}
-
-static inline phys_addr_t dma_to_phys(struct device *dev, dma_addr_t daddr)
-{
-	return daddr - get_dma_offset(dev);
-}
-
 #define ARCH_HAS_DMA_MMAP_COHERENT
 
 #endif /* __KERNEL__ */
diff --git a/arch/tile/include/asm/dma-mapping.h b/arch/tile/include/asm/dma-mapping.h
index 97ad62878290..75b8aaa4e70b 100644
--- a/arch/tile/include/asm/dma-mapping.h
+++ b/arch/tile/include/asm/dma-mapping.h
@@ -44,26 +44,8 @@ static inline void set_dma_offset(struct device *dev, dma_addr_t off)
 	dev->archdata.dma_offset = off;
 }
 
-static inline dma_addr_t phys_to_dma(struct device *dev, phys_addr_t paddr)
-{
-	return paddr;
-}
-
-static inline phys_addr_t dma_to_phys(struct device *dev, dma_addr_t daddr)
-{
-	return daddr;
-}
-
 static inline void dma_mark_clean(void *addr, size_t size) {}
 
-static inline bool dma_capable(struct device *dev, dma_addr_t addr, size_t size)
-{
-	if (!dev->dma_mask)
-		return 0;
-
-	return addr + size - 1 <= *dev->dma_mask;
-}
-
 #define HAVE_ARCH_DMA_SET_MASK 1
 int dma_set_mask(struct device *dev, u64 mask);
 
diff --git a/arch/unicore32/include/asm/dma-mapping.h b/arch/unicore32/include/asm/dma-mapping.h
index ac608c2f6af6..5cb250bf2d8c 100644
--- a/arch/unicore32/include/asm/dma-mapping.h
+++ b/arch/unicore32/include/asm/dma-mapping.h
@@ -25,24 +25,6 @@ static inline const struct dma_map_ops *get_arch_dma_ops(struct bus_type *bus)
 	return &swiotlb_dma_map_ops;
 }
 
-static inline bool dma_capable(struct device *dev, dma_addr_t addr, size_t size)
-{
-	if (dev && dev->dma_mask)
-		return addr + size - 1 <= *dev->dma_mask;
-
-	return 1;
-}
-
-static inline dma_addr_t phys_to_dma(struct device *dev, phys_addr_t paddr)
-{
-	return paddr;
-}
-
-static inline phys_addr_t dma_to_phys(struct device *dev, dma_addr_t daddr)
-{
-	return daddr;
-}
-
 static inline void dma_mark_clean(void *addr, size_t size) {}
 
 #endif /* __KERNEL__ */
diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index d4fc98c50378..f6f4328103c0 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -54,6 +54,7 @@ config X86
 	select ARCH_HAS_FORTIFY_SOURCE
 	select ARCH_HAS_GCOV_PROFILE_ALL
 	select ARCH_HAS_KCOV			if X86_64
+	select ARCH_HAS_PHYS_TO_DMA
 	select ARCH_HAS_PMEM_API		if X86_64
 	# Causing hangs/crashes, see the commit that added this change for details.
 	select ARCH_HAS_REFCOUNT
diff --git a/arch/x86/include/asm/dma-direct.h b/arch/x86/include/asm/dma-direct.h
new file mode 100644
index 000000000000..1295bc622ebe
--- /dev/null
+++ b/arch/x86/include/asm/dma-direct.h
@@ -0,0 +1,30 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+#ifndef ASM_X86_DMA_DIRECT_H
+#define ASM_X86_DMA_DIRECT_H 1
+
+#include <linux/mem_encrypt.h>
+
+#ifdef CONFIG_X86_DMA_REMAP /* Platform code defines bridge-specific code */
+bool dma_capable(struct device *dev, dma_addr_t addr, size_t size);
+dma_addr_t phys_to_dma(struct device *dev, phys_addr_t paddr);
+phys_addr_t dma_to_phys(struct device *dev, dma_addr_t daddr);
+#else
+static inline bool dma_capable(struct device *dev, dma_addr_t addr, size_t size)
+{
+	if (!dev->dma_mask)
+		return 0;
+
+	return addr + size - 1 <= *dev->dma_mask;
+}
+
+static inline dma_addr_t phys_to_dma(struct device *dev, phys_addr_t paddr)
+{
+	return __sme_set(paddr);
+}
+
+static inline phys_addr_t dma_to_phys(struct device *dev, dma_addr_t daddr)
+{
+	return __sme_clr(daddr);
+}
+#endif /* CONFIG_X86_DMA_REMAP */
+#endif /* ASM_X86_DMA_DIRECT_H */
diff --git a/arch/x86/include/asm/dma-mapping.h b/arch/x86/include/asm/dma-mapping.h
index 0350d99bb8fd..dfdc9357a349 100644
--- a/arch/x86/include/asm/dma-mapping.h
+++ b/arch/x86/include/asm/dma-mapping.h
@@ -12,7 +12,6 @@
 #include <asm/io.h>
 #include <asm/swiotlb.h>
 #include <linux/dma-contiguous.h>
-#include <linux/mem_encrypt.h>
 
 #ifdef CONFIG_ISA
 # define ISA_DMA_BIT_MASK DMA_BIT_MASK(24)
@@ -42,31 +41,6 @@ extern void dma_generic_free_coherent(struct device *dev, size_t size,
 				      void *vaddr, dma_addr_t dma_addr,
 				      unsigned long attrs);
 
-#ifdef CONFIG_X86_DMA_REMAP /* Platform code defines bridge-specific code */
-extern bool dma_capable(struct device *dev, dma_addr_t addr, size_t size);
-extern dma_addr_t phys_to_dma(struct device *dev, phys_addr_t paddr);
-extern phys_addr_t dma_to_phys(struct device *dev, dma_addr_t daddr);
-#else
-
-static inline bool dma_capable(struct device *dev, dma_addr_t addr, size_t size)
-{
-	if (!dev->dma_mask)
-		return 0;
-
-	return addr + size - 1 <= *dev->dma_mask;
-}
-
-static inline dma_addr_t phys_to_dma(struct device *dev, phys_addr_t paddr)
-{
-	return __sme_set(paddr);
-}
-
-static inline phys_addr_t dma_to_phys(struct device *dev, dma_addr_t daddr)
-{
-	return __sme_clr(daddr);
-}
-#endif /* CONFIG_X86_DMA_REMAP */
-
 static inline unsigned long dma_alloc_coherent_mask(struct device *dev,
 						    gfp_t gfp)
 {
diff --git a/arch/x86/kernel/amd_gart_64.c b/arch/x86/kernel/amd_gart_64.c
index cc0e8bc0ea3f..ecd486cb06ab 100644
--- a/arch/x86/kernel/amd_gart_64.c
+++ b/arch/x86/kernel/amd_gart_64.c
@@ -31,6 +31,7 @@
 #include <linux/io.h>
 #include <linux/gfp.h>
 #include <linux/atomic.h>
+#include <linux/dma-direct.h>
 #include <asm/mtrr.h>
 #include <asm/pgtable.h>
 #include <asm/proto.h>
diff --git a/arch/x86/kernel/pci-dma.c b/arch/x86/kernel/pci-dma.c
index 599d7462eccc..8439e6de6156 100644
--- a/arch/x86/kernel/pci-dma.c
+++ b/arch/x86/kernel/pci-dma.c
@@ -1,5 +1,5 @@
 // SPDX-License-Identifier: GPL-2.0
-#include <linux/dma-mapping.h>
+#include <linux/dma-direct.h>
 #include <linux/dma-debug.h>
 #include <linux/dmar.h>
 #include <linux/export.h>
diff --git a/arch/x86/kernel/pci-nommu.c b/arch/x86/kernel/pci-nommu.c
index b0caae27e1b7..618285e475c6 100644
--- a/arch/x86/kernel/pci-nommu.c
+++ b/arch/x86/kernel/pci-nommu.c
@@ -1,7 +1,7 @@
 // SPDX-License-Identifier: GPL-2.0
 /* Fallback functions when the main IOMMU code is not compiled in. This
    code is roughly equivalent to i386. */
-#include <linux/dma-mapping.h>
+#include <linux/dma-direct.h>
 #include <linux/scatterlist.h>
 #include <linux/string.h>
 #include <linux/gfp.h>
diff --git a/arch/x86/kernel/pci-swiotlb.c b/arch/x86/kernel/pci-swiotlb.c
index 53bd05ea90d8..9d3e35c33d94 100644
--- a/arch/x86/kernel/pci-swiotlb.c
+++ b/arch/x86/kernel/pci-swiotlb.c
@@ -6,7 +6,7 @@
 #include <linux/init.h>
 #include <linux/swiotlb.h>
 #include <linux/bootmem.h>
-#include <linux/dma-mapping.h>
+#include <linux/dma-direct.h>
 #include <linux/mem_encrypt.h>
 
 #include <asm/iommu.h>
diff --git a/arch/x86/mm/mem_encrypt.c b/arch/x86/mm/mem_encrypt.c
index 391b13402e40..09532c935da0 100644
--- a/arch/x86/mm/mem_encrypt.c
+++ b/arch/x86/mm/mem_encrypt.c
@@ -15,7 +15,7 @@
 #include <linux/linkage.h>
 #include <linux/init.h>
 #include <linux/mm.h>
-#include <linux/dma-mapping.h>
+#include <linux/dma-direct.h>
 #include <linux/swiotlb.h>
 #include <linux/mem_encrypt.h>
 
diff --git a/arch/x86/pci/sta2x11-fixup.c b/arch/x86/pci/sta2x11-fixup.c
index 53d600217973..75577c1490c4 100644
--- a/arch/x86/pci/sta2x11-fixup.c
+++ b/arch/x86/pci/sta2x11-fixup.c
@@ -26,6 +26,7 @@
 #include <linux/pci_ids.h>
 #include <linux/export.h>
 #include <linux/list.h>
+#include <linux/dma-direct.h>
 #include <asm/iommu.h>
 
 #define STA2X11_SWIOTLB_SIZE (4*1024*1024)
diff --git a/arch/xtensa/include/asm/dma-mapping.h b/arch/xtensa/include/asm/dma-mapping.h
index 153bf2370988..44098800dad7 100644
--- a/arch/xtensa/include/asm/dma-mapping.h
+++ b/arch/xtensa/include/asm/dma-mapping.h
@@ -23,14 +23,4 @@ static inline const struct dma_map_ops *get_arch_dma_ops(struct bus_type *bus)
 	return &xtensa_dma_map_ops;
 }
 
-static inline dma_addr_t phys_to_dma(struct device *dev, phys_addr_t paddr)
-{
-	return (dma_addr_t)paddr;
-}
-
-static inline phys_addr_t dma_to_phys(struct device *dev, dma_addr_t daddr)
-{
-	return (phys_addr_t)daddr;
-}
-
 #endif	/* _XTENSA_DMA_MAPPING_H */
diff --git a/drivers/crypto/marvell/cesa.c b/drivers/crypto/marvell/cesa.c
index 293832488cc9..3a0c40081ffb 100644
--- a/drivers/crypto/marvell/cesa.c
+++ b/drivers/crypto/marvell/cesa.c
@@ -24,6 +24,7 @@
 #include <linux/scatterlist.h>
 #include <linux/slab.h>
 #include <linux/module.h>
+#include <linux/dma-direct.h> /* XXX: drivers shall never use this directly! */
 #include <linux/clk.h>
 #include <linux/of.h>
 #include <linux/of_platform.h>
diff --git a/drivers/mtd/nand/qcom_nandc.c b/drivers/mtd/nand/qcom_nandc.c
index 2656c1ac5646..411cdfd12a85 100644
--- a/drivers/mtd/nand/qcom_nandc.c
+++ b/drivers/mtd/nand/qcom_nandc.c
@@ -23,6 +23,7 @@
 #include <linux/of_device.h>
 #include <linux/delay.h>
 #include <linux/dma/qcom_bam_dma.h>
+#include <linux/dma-direct.h> /* XXX: drivers shall never use this directly! */
 
 /* NANDc reg offsets */
 #define	NAND_FLASH_CMD			0x00
diff --git a/drivers/xen/swiotlb-xen.c b/drivers/xen/swiotlb-xen.c
index 82fc54f8eb77..5bb72d3f8337 100644
--- a/drivers/xen/swiotlb-xen.c
+++ b/drivers/xen/swiotlb-xen.c
@@ -36,7 +36,7 @@
 #define pr_fmt(fmt) "xen:" KBUILD_MODNAME ": " fmt
 
 #include <linux/bootmem.h>
-#include <linux/dma-mapping.h>
+#include <linux/dma-direct.h>
 #include <linux/export.h>
 #include <xen/swiotlb-xen.h>
 #include <xen/page.h>
diff --git a/include/linux/dma-direct.h b/include/linux/dma-direct.h
new file mode 100644
index 000000000000..2cc1b6558944
--- /dev/null
+++ b/include/linux/dma-direct.h
@@ -0,0 +1,32 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+#ifndef _LINUX_DMA_DIRECT_H
+#define _LINUX_DMA_DIRECT_H 1
+
+#include <linux/dma-mapping.h>
+
+#ifdef CONFIG_ARCH_HAS_PHYS_TO_DMA
+#include <asm/dma-direct.h>
+#else
+static inline dma_addr_t phys_to_dma(struct device *dev, phys_addr_t paddr)
+{
+	dma_addr_t dev_addr = (dma_addr_t)paddr;
+
+	return dev_addr - ((dma_addr_t)dev->dma_pfn_offset << PAGE_SHIFT);
+}
+
+static inline phys_addr_t dma_to_phys(struct device *dev, dma_addr_t dev_addr)
+{
+	phys_addr_t paddr = (phys_addr_t)dev_addr;
+
+	return paddr + ((phys_addr_t)dev->dma_pfn_offset << PAGE_SHIFT);
+}
+
+static inline bool dma_capable(struct device *dev, dma_addr_t addr, size_t size)
+{
+	if (!dev->dma_mask)
+		return false;
+
+	return addr + size - 1 <= *dev->dma_mask;
+}
+#endif /* !CONFIG_ARCH_HAS_PHYS_TO_DMA */
+#endif /* _LINUX_DMA_DIRECT_H */
diff --git a/lib/swiotlb.c b/lib/swiotlb.c
index cea19aaf303c..6583f3512386 100644
--- a/lib/swiotlb.c
+++ b/lib/swiotlb.c
@@ -18,7 +18,7 @@
  */
 
 #include <linux/cache.h>
-#include <linux/dma-mapping.h>
+#include <linux/dma-direct.h>
 #include <linux/mm.h>
 #include <linux/export.h>
 #include <linux/spinlock.h>
-- 
2.14.2

