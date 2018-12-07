From: Christoph Hellwig <hch@lst.de>
Date: Fri, 07 Dec 2018 19:07:10 +0000
Subject: [PATCH 05/15] dma-direct: merge swiotlb_dma_ops into the dma_direct code
Message-Id: <20181207190720.18517-6-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20181207190720.18517-1-hch@lst.de>
In-Reply-To: <20181207190720.18517-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: iommu@lists.linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>, Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Tariq Toukan <tariqt@mellanox.com>, Ilias Apalodimas <ilias.apalodimas@linaro.org>, =?UTF-8?q?Toke=20H=C3=B8iland-J=C3=B8rgensen?= <toke@toke.dk>, Robin Murphy <robin.murphy@arm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Keith Busch <keith.busch@intel.com>, Jonathan Derrick <jonathan.derrick@intel.com>, linux-pci@vger.kernel.org, linux-ia64@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org

While the dma-direct code is (relatively) clean and simple we actually
have to use the swiotlb ops for the mapping on many architectures due
to devices with addressing limits.  Instead of keeping two
implementations around this commit allows the dma-direct
implementation to call the swiotlb bounce buffering functions and
thus share the guts of the mapping implementation.  This also
simplified the dma-mapping setup on a few architectures where we
don't have to differenciate which implementation to use.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/arm64/mm/dma-mapping.c          |   2 +-
 arch/ia64/hp/common/hwsw_iommu.c     |   2 +-
 arch/ia64/hp/common/sba_iommu.c      |   6 +-
 arch/ia64/kernel/dma-mapping.c       |   2 +-
 arch/mips/include/asm/dma-mapping.h  |   2 -
 arch/powerpc/kernel/dma-swiotlb.c    |  16 +-
 arch/riscv/include/asm/dma-mapping.h |  15 --
 arch/x86/kernel/pci-swiotlb.c        |   4 +-
 arch/x86/mm/mem_encrypt.c            |   7 -
 arch/x86/pci/sta2x11-fixup.c         |   1 -
 include/linux/dma-direct.h           |  12 ++
 include/linux/swiotlb.h              |  74 ++++-----
 kernel/dma/direct.c                  | 113 +++++++++----
 kernel/dma/swiotlb.c                 | 232 ++-------------------------
 14 files changed, 150 insertions(+), 338 deletions(-)
 delete mode 100644 arch/riscv/include/asm/dma-mapping.h

diff --git a/arch/arm64/mm/dma-mapping.c b/arch/arm64/mm/dma-mapping.c
index 4c0f498069e8..e4effbb243b1 100644
--- a/arch/arm64/mm/dma-mapping.c
+++ b/arch/arm64/mm/dma-mapping.c
@@ -549,7 +549,7 @@ void arch_setup_dma_ops(struct device *dev, u64 dma_base, u64 size,
 			const struct iommu_ops *iommu, bool coherent)
 {
 	if (!dev->dma_ops)
-		dev->dma_ops = &swiotlb_dma_ops;
+		dev->dma_ops = &dma_direct_ops;
 
 	dev->dma_coherent = coherent;
 	__iommu_setup_dma_ops(dev, dma_base, size, iommu);
diff --git a/arch/ia64/hp/common/hwsw_iommu.c b/arch/ia64/hp/common/hwsw_iommu.c
index 58969039bed2..f40ca499b246 100644
--- a/arch/ia64/hp/common/hwsw_iommu.c
+++ b/arch/ia64/hp/common/hwsw_iommu.c
@@ -38,7 +38,7 @@ static inline int use_swiotlb(struct device *dev)
 const struct dma_map_ops *hwsw_dma_get_ops(struct device *dev)
 {
 	if (use_swiotlb(dev))
-		return &swiotlb_dma_ops;
+		return &dma_direct_ops;
 	return &sba_dma_ops;
 }
 EXPORT_SYMBOL(hwsw_dma_get_ops);
diff --git a/arch/ia64/hp/common/sba_iommu.c b/arch/ia64/hp/common/sba_iommu.c
index 0d21c0b5b23d..5ee74820a0f6 100644
--- a/arch/ia64/hp/common/sba_iommu.c
+++ b/arch/ia64/hp/common/sba_iommu.c
@@ -2065,8 +2065,6 @@ static int __init acpi_sba_ioc_init_acpi(void)
 /* This has to run before acpi_scan_init(). */
 arch_initcall(acpi_sba_ioc_init_acpi);
 
-extern const struct dma_map_ops swiotlb_dma_ops;
-
 static int __init
 sba_init(void)
 {
@@ -2080,7 +2078,7 @@ sba_init(void)
 	 * a successful kdump kernel boot is to use the swiotlb.
 	 */
 	if (is_kdump_kernel()) {
-		dma_ops = &swiotlb_dma_ops;
+		dma_ops = &dma_direct_ops;
 		if (swiotlb_late_init_with_default_size(64 * (1<<20)) != 0)
 			panic("Unable to initialize software I/O TLB:"
 				  " Try machvec=dig boot option");
@@ -2102,7 +2100,7 @@ sba_init(void)
 		 * If we didn't find something sba_iommu can claim, we
 		 * need to setup the swiotlb and switch to the dig machvec.
 		 */
-		dma_ops = &swiotlb_dma_ops;
+		dma_ops = &dma_direct_ops;
 		if (swiotlb_late_init_with_default_size(64 * (1<<20)) != 0)
 			panic("Unable to find SBA IOMMU or initialize "
 			      "software I/O TLB: Try machvec=dig boot option");
diff --git a/arch/ia64/kernel/dma-mapping.c b/arch/ia64/kernel/dma-mapping.c
index 36dd6aa6d759..80cd3e1ea95a 100644
--- a/arch/ia64/kernel/dma-mapping.c
+++ b/arch/ia64/kernel/dma-mapping.c
@@ -36,7 +36,7 @@ long arch_dma_coherent_to_pfn(struct device *dev, void *cpu_addr,
 
 void __init swiotlb_dma_init(void)
 {
-	dma_ops = &swiotlb_dma_ops;
+	dma_ops = &dma_direct_ops;
 	swiotlb_init(1);
 }
 #endif
diff --git a/arch/mips/include/asm/dma-mapping.h b/arch/mips/include/asm/dma-mapping.h
index b4c477eb46ce..69f914667f3e 100644
--- a/arch/mips/include/asm/dma-mapping.h
+++ b/arch/mips/include/asm/dma-mapping.h
@@ -10,8 +10,6 @@ static inline const struct dma_map_ops *get_arch_dma_ops(struct bus_type *bus)
 {
 #if defined(CONFIG_MACH_JAZZ)
 	return &jazz_dma_ops;
-#elif defined(CONFIG_SWIOTLB)
-	return &swiotlb_dma_ops;
 #else
 	return &dma_direct_ops;
 #endif
diff --git a/arch/powerpc/kernel/dma-swiotlb.c b/arch/powerpc/kernel/dma-swiotlb.c
index 3d8df2cf8be9..430a7d0aa2cb 100644
--- a/arch/powerpc/kernel/dma-swiotlb.c
+++ b/arch/powerpc/kernel/dma-swiotlb.c
@@ -50,15 +50,15 @@ const struct dma_map_ops powerpc_swiotlb_dma_ops = {
 	.alloc = __dma_nommu_alloc_coherent,
 	.free = __dma_nommu_free_coherent,
 	.mmap = dma_nommu_mmap_coherent,
-	.map_sg = swiotlb_map_sg_attrs,
-	.unmap_sg = swiotlb_unmap_sg_attrs,
+	.map_sg = dma_direct_map_sg,
+	.unmap_sg = dma_direct_unmap_sg,
 	.dma_supported = swiotlb_dma_supported,
-	.map_page = swiotlb_map_page,
-	.unmap_page = swiotlb_unmap_page,
-	.sync_single_for_cpu = swiotlb_sync_single_for_cpu,
-	.sync_single_for_device = swiotlb_sync_single_for_device,
-	.sync_sg_for_cpu = swiotlb_sync_sg_for_cpu,
-	.sync_sg_for_device = swiotlb_sync_sg_for_device,
+	.map_page = dma_direct_map_page,
+	.unmap_page = dma_direct_unmap_page,
+	.sync_single_for_cpu = dma_direct_sync_single_for_cpu,
+	.sync_single_for_device = dma_direct_sync_single_for_device,
+	.sync_sg_for_cpu = dma_direct_sync_sg_for_cpu,
+	.sync_sg_for_device = dma_direct_sync_sg_for_device,
 	.get_required_mask = swiotlb_powerpc_get_required,
 };
 
diff --git a/arch/riscv/include/asm/dma-mapping.h b/arch/riscv/include/asm/dma-mapping.h
deleted file mode 100644
index 8facc1c8fa05..000000000000
--- a/arch/riscv/include/asm/dma-mapping.h
+++ /dev/null
@@ -1,15 +0,0 @@
-// SPDX-License-Identifier: GPL-2.0
-#ifndef _RISCV_ASM_DMA_MAPPING_H
-#define _RISCV_ASM_DMA_MAPPING_H 1
-
-#ifdef CONFIG_SWIOTLB
-#include <linux/swiotlb.h>
-static inline const struct dma_map_ops *get_arch_dma_ops(struct bus_type *bus)
-{
-	return &swiotlb_dma_ops;
-}
-#else
-#include <asm-generic/dma-mapping.h>
-#endif /* CONFIG_SWIOTLB */
-
-#endif /* _RISCV_ASM_DMA_MAPPING_H */
diff --git a/arch/x86/kernel/pci-swiotlb.c b/arch/x86/kernel/pci-swiotlb.c
index bd08b9e1c9e2..5f5302028a9a 100644
--- a/arch/x86/kernel/pci-swiotlb.c
+++ b/arch/x86/kernel/pci-swiotlb.c
@@ -62,10 +62,8 @@ IOMMU_INIT(pci_swiotlb_detect_4gb,
 
 void __init pci_swiotlb_init(void)
 {
-	if (swiotlb) {
+	if (swiotlb)
 		swiotlb_init(0);
-		dma_ops = &swiotlb_dma_ops;
-	}
 }
 
 void __init pci_swiotlb_late_init(void)
diff --git a/arch/x86/mm/mem_encrypt.c b/arch/x86/mm/mem_encrypt.c
index 006f373f54ab..385afa2b9e17 100644
--- a/arch/x86/mm/mem_encrypt.c
+++ b/arch/x86/mm/mem_encrypt.c
@@ -380,13 +380,6 @@ void __init mem_encrypt_init(void)
 	/* Call into SWIOTLB to update the SWIOTLB DMA buffers */
 	swiotlb_update_mem_attributes();
 
-	/*
-	 * With SEV, DMA operations cannot use encryption, we need to use
-	 * SWIOTLB to bounce buffer DMA operation.
-	 */
-	if (sev_active())
-		dma_ops = &swiotlb_dma_ops;
-
 	/*
 	 * With SEV, we need to unroll the rep string I/O instructions.
 	 */
diff --git a/arch/x86/pci/sta2x11-fixup.c b/arch/x86/pci/sta2x11-fixup.c
index 7a5bafb76d77..3cdafea55ab6 100644
--- a/arch/x86/pci/sta2x11-fixup.c
+++ b/arch/x86/pci/sta2x11-fixup.c
@@ -168,7 +168,6 @@ static void sta2x11_setup_pdev(struct pci_dev *pdev)
 		return;
 	pci_set_consistent_dma_mask(pdev, STA2X11_AMBA_SIZE - 1);
 	pci_set_dma_mask(pdev, STA2X11_AMBA_SIZE - 1);
-	pdev->dev.dma_ops = &swiotlb_dma_ops;
 	pdev->dev.archdata.is_sta2x11 = true;
 
 	/* We must enable all devices as master, for audio DMA to work */
diff --git a/include/linux/dma-direct.h b/include/linux/dma-direct.h
index 1aa73f4907ae..3b0a3ea3876d 100644
--- a/include/linux/dma-direct.h
+++ b/include/linux/dma-direct.h
@@ -63,7 +63,19 @@ void __dma_direct_free_pages(struct device *dev, size_t size, struct page *page)
 dma_addr_t dma_direct_map_page(struct device *dev, struct page *page,
 		unsigned long offset, size_t size, enum dma_data_direction dir,
 		unsigned long attrs);
+void dma_direct_unmap_page(struct device *dev, dma_addr_t addr,
+		size_t size, enum dma_data_direction dir, unsigned long attrs);
 int dma_direct_map_sg(struct device *dev, struct scatterlist *sgl, int nents,
 		enum dma_data_direction dir, unsigned long attrs);
+void dma_direct_unmap_sg(struct device *dev, struct scatterlist *sgl,
+		int nents, enum dma_data_direction dir, unsigned long attrs);
+void dma_direct_sync_single_for_device(struct device *dev,
+		dma_addr_t addr, size_t size, enum dma_data_direction dir);
+void dma_direct_sync_sg_for_device(struct device *dev,
+		struct scatterlist *sgl, int nents, enum dma_data_direction dir);
+void dma_direct_sync_single_for_cpu(struct device *dev,
+		dma_addr_t addr, size_t size, enum dma_data_direction dir);
+void dma_direct_sync_sg_for_cpu(struct device *dev,
+		struct scatterlist *sgl, int nents, enum dma_data_direction dir);
 int dma_direct_supported(struct device *dev, u64 mask);
 #endif /* _LINUX_DMA_DIRECT_H */
diff --git a/include/linux/swiotlb.h b/include/linux/swiotlb.h
index 14aec0b70dd9..7c007ed7505f 100644
--- a/include/linux/swiotlb.h
+++ b/include/linux/swiotlb.h
@@ -16,8 +16,6 @@ enum swiotlb_force {
 	SWIOTLB_NO_FORCE,	/* swiotlb=noforce */
 };
 
-extern enum swiotlb_force swiotlb_force;
-
 /*
  * Maximum allowable number of contiguous slabs to map,
  * must be a power of 2.  What is the appropriate value ?
@@ -62,56 +60,44 @@ extern void swiotlb_tbl_sync_single(struct device *hwdev,
 				    size_t size, enum dma_data_direction dir,
 				    enum dma_sync_target target);
 
-/* Accessory functions. */
-
-extern dma_addr_t swiotlb_map_page(struct device *dev, struct page *page,
-				   unsigned long offset, size_t size,
-				   enum dma_data_direction dir,
-				   unsigned long attrs);
-extern void swiotlb_unmap_page(struct device *hwdev, dma_addr_t dev_addr,
-			       size_t size, enum dma_data_direction dir,
-			       unsigned long attrs);
-
-extern int
-swiotlb_map_sg_attrs(struct device *hwdev, struct scatterlist *sgl, int nelems,
-		     enum dma_data_direction dir,
-		     unsigned long attrs);
-
-extern void
-swiotlb_unmap_sg_attrs(struct device *hwdev, struct scatterlist *sgl,
-		       int nelems, enum dma_data_direction dir,
-		       unsigned long attrs);
-
-extern void
-swiotlb_sync_single_for_cpu(struct device *hwdev, dma_addr_t dev_addr,
-			    size_t size, enum dma_data_direction dir);
-
-extern void
-swiotlb_sync_sg_for_cpu(struct device *hwdev, struct scatterlist *sg,
-			int nelems, enum dma_data_direction dir);
-
-extern void
-swiotlb_sync_single_for_device(struct device *hwdev, dma_addr_t dev_addr,
-			       size_t size, enum dma_data_direction dir);
-
-extern void
-swiotlb_sync_sg_for_device(struct device *hwdev, struct scatterlist *sg,
-			   int nelems, enum dma_data_direction dir);
-
 extern int
 swiotlb_dma_supported(struct device *hwdev, u64 mask);
 
 #ifdef CONFIG_SWIOTLB
-extern void __init swiotlb_exit(void);
+extern enum swiotlb_force swiotlb_force;
+extern phys_addr_t io_tlb_start, io_tlb_end;
+
+static inline bool is_swiotlb_buffer(phys_addr_t paddr)
+{
+	return paddr >= io_tlb_start && paddr < io_tlb_end;
+}
+
+bool swiotlb_map(struct device *dev, phys_addr_t *phys, dma_addr_t *dma_addr,
+		size_t size, enum dma_data_direction dir, unsigned long attrs);
+void __init swiotlb_exit(void);
 unsigned int swiotlb_max_segment(void);
 #else
-static inline void swiotlb_exit(void) { }
-static inline unsigned int swiotlb_max_segment(void) { return 0; }
-#endif
+#define swiotlb_force SWIOTLB_NO_FORCE
+static inline bool is_swiotlb_buffer(phys_addr_t paddr)
+{
+	return false;
+}
+static inline bool swiotlb_map(struct device *dev, phys_addr_t *phys,
+		dma_addr_t *dma_addr, size_t size, enum dma_data_direction dir,
+		unsigned long attrs)
+{
+	return false;
+}
+static inline void swiotlb_exit(void)
+{
+}
+static inline unsigned int swiotlb_max_segment(void)
+{
+	return 0;
+}
+#endif /* CONFIG_SWIOTLB */
 
 extern void swiotlb_print_info(void);
 extern void swiotlb_set_max_segment(unsigned int);
 
-extern const struct dma_map_ops swiotlb_dma_ops;
-
 #endif /* __LINUX_SWIOTLB_H */
diff --git a/kernel/dma/direct.c b/kernel/dma/direct.c
index d45306473c90..85d8286a0ba2 100644
--- a/kernel/dma/direct.c
+++ b/kernel/dma/direct.c
@@ -13,6 +13,7 @@
 #include <linux/dma-noncoherent.h>
 #include <linux/pfn.h>
 #include <linux/set_memory.h>
+#include <linux/swiotlb.h>
 
 /*
  * Most architectures use ZONE_DMA for the first 16 Megabytes, but
@@ -209,69 +210,110 @@ void dma_direct_free(struct device *dev, size_t size,
 		dma_direct_free_pages(dev, size, cpu_addr, dma_addr, attrs);
 }
 
-static void dma_direct_sync_single_for_device(struct device *dev,
+#if defined(CONFIG_ARCH_HAS_SYNC_DMA_FOR_DEVICE) || \
+    defined(CONFIG_SWIOTLB)
+void dma_direct_sync_single_for_device(struct device *dev,
 		dma_addr_t addr, size_t size, enum dma_data_direction dir)
 {
-	if (dev_is_dma_coherent(dev))
-		return;
-	arch_sync_dma_for_device(dev, dma_to_phys(dev, addr), size, dir);
+	phys_addr_t paddr = dma_to_phys(dev, addr);
+
+	if (unlikely(is_swiotlb_buffer(paddr)))
+		swiotlb_tbl_sync_single(dev, paddr, size, dir, SYNC_FOR_DEVICE);
+
+	if (!dev_is_dma_coherent(dev))
+		arch_sync_dma_for_device(dev, paddr, size, dir);
 }
 
-#if defined(CONFIG_ARCH_HAS_SYNC_DMA_FOR_DEVICE)
-static void dma_direct_sync_sg_for_device(struct device *dev,
+void dma_direct_sync_sg_for_device(struct device *dev,
 		struct scatterlist *sgl, int nents, enum dma_data_direction dir)
 {
 	struct scatterlist *sg;
 	int i;
 
-	if (dev_is_dma_coherent(dev))
-		return;
+	for_each_sg(sgl, sg, nents, i) {
+		if (unlikely(is_swiotlb_buffer(sg_phys(sg))))
+			swiotlb_tbl_sync_single(dev, sg_phys(sg), sg->length,
+					dir, SYNC_FOR_DEVICE);
 
-	for_each_sg(sgl, sg, nents, i)
-		arch_sync_dma_for_device(dev, sg_phys(sg), sg->length, dir);
+		if (!dev_is_dma_coherent(dev))
+			arch_sync_dma_for_device(dev, sg_phys(sg), sg->length,
+					dir);
+	}
 }
 #endif
 
 #if defined(CONFIG_ARCH_HAS_SYNC_DMA_FOR_CPU) || \
-    defined(CONFIG_ARCH_HAS_SYNC_DMA_FOR_CPU_ALL)
-static void dma_direct_sync_single_for_cpu(struct device *dev,
+    defined(CONFIG_ARCH_HAS_SYNC_DMA_FOR_CPU_ALL) || \
+    defined(CONFIG_SWIOTLB)
+void dma_direct_sync_single_for_cpu(struct device *dev,
 		dma_addr_t addr, size_t size, enum dma_data_direction dir)
 {
-	if (dev_is_dma_coherent(dev))
-		return;
-	arch_sync_dma_for_cpu(dev, dma_to_phys(dev, addr), size, dir);
-	arch_sync_dma_for_cpu_all(dev);
+	phys_addr_t paddr = dma_to_phys(dev, addr);
+
+	if (!dev_is_dma_coherent(dev)) {
+		arch_sync_dma_for_cpu(dev, paddr, size, dir);
+		arch_sync_dma_for_cpu_all(dev);
+	}
+
+	if (unlikely(is_swiotlb_buffer(paddr)))
+		swiotlb_tbl_sync_single(dev, paddr, size, dir, SYNC_FOR_CPU);
 }
 
-static void dma_direct_sync_sg_for_cpu(struct device *dev,
+void dma_direct_sync_sg_for_cpu(struct device *dev,
 		struct scatterlist *sgl, int nents, enum dma_data_direction dir)
 {
 	struct scatterlist *sg;
 	int i;
 
-	if (dev_is_dma_coherent(dev))
-		return;
+	for_each_sg(sgl, sg, nents, i) {
+		if (!dev_is_dma_coherent(dev))
+			arch_sync_dma_for_cpu(dev, sg_phys(sg), sg->length, dir);
+	
+		if (unlikely(is_swiotlb_buffer(sg_phys(sg))))
+			swiotlb_tbl_sync_single(dev, sg_phys(sg), sg->length, dir,
+					SYNC_FOR_CPU);
+	}
 
-	for_each_sg(sgl, sg, nents, i)
-		arch_sync_dma_for_cpu(dev, sg_phys(sg), sg->length, dir);
-	arch_sync_dma_for_cpu_all(dev);
+	if (!dev_is_dma_coherent(dev))
+		arch_sync_dma_for_cpu_all(dev);
 }
 
-static void dma_direct_unmap_page(struct device *dev, dma_addr_t addr,
+void dma_direct_unmap_page(struct device *dev, dma_addr_t addr,
 		size_t size, enum dma_data_direction dir, unsigned long attrs)
 {
+	phys_addr_t phys = dma_to_phys(dev, addr);
+
 	if (!(attrs & DMA_ATTR_SKIP_CPU_SYNC))
 		dma_direct_sync_single_for_cpu(dev, addr, size, dir);
+
+	if (unlikely(is_swiotlb_buffer(phys)))
+		swiotlb_tbl_unmap_single(dev, phys, size, dir, attrs);
 }
 
-static void dma_direct_unmap_sg(struct device *dev, struct scatterlist *sgl,
+void dma_direct_unmap_sg(struct device *dev, struct scatterlist *sgl,
+		int nents, enum dma_data_direction dir, unsigned long attrs)
+{
+	struct scatterlist *sg;
+	int i;
+
+	for_each_sg(sgl, sg, nents, i)
+		dma_direct_unmap_page(dev, sg->dma_address, sg_dma_len(sg), dir,
+			     attrs);
+}
+#else
+void dma_direct_unmap_sg(struct device *dev, struct scatterlist *sgl,
 		int nents, enum dma_data_direction dir, unsigned long attrs)
 {
-	if (!(attrs & DMA_ATTR_SKIP_CPU_SYNC))
-		dma_direct_sync_sg_for_cpu(dev, sgl, nents, dir);
 }
 #endif
 
+static inline bool dma_direct_possible(struct device *dev, dma_addr_t dma_addr,
+		size_t size)
+{
+	return swiotlb_force != SWIOTLB_FORCE &&
+		(!dev || dma_capable(dev, dma_addr, size));
+}
+
 dma_addr_t dma_direct_map_page(struct device *dev, struct page *page,
 		unsigned long offset, size_t size, enum dma_data_direction dir,
 		unsigned long attrs)
@@ -279,13 +321,14 @@ dma_addr_t dma_direct_map_page(struct device *dev, struct page *page,
 	phys_addr_t phys = page_to_phys(page) + offset;
 	dma_addr_t dma_addr = phys_to_dma(dev, phys);
 
-	if (unlikely(dev && !dma_capable(dev, dma_addr, size))) {
+	if (unlikely(!dma_direct_possible(dev, dma_addr, size)) &&
+	    !swiotlb_map(dev, &phys, &dma_addr, size, dir, attrs)) {
 		report_addr(dev, dma_addr, size);
 		return DMA_MAPPING_ERROR;
 	}
 
-	if (!(attrs & DMA_ATTR_SKIP_CPU_SYNC))
-		dma_direct_sync_single_for_device(dev, dma_addr, size, dir);
+	if (!dev_is_dma_coherent(dev) && !(attrs & DMA_ATTR_SKIP_CPU_SYNC))
+		arch_sync_dma_for_device(dev, phys, size, dir);
 	return dma_addr;
 }
 
@@ -299,11 +342,15 @@ int dma_direct_map_sg(struct device *dev, struct scatterlist *sgl, int nents,
 		sg->dma_address = dma_direct_map_page(dev, sg_page(sg),
 				sg->offset, sg->length, dir, attrs);
 		if (sg->dma_address = DMA_MAPPING_ERROR)
-			return 0;
+			goto out_unmap;
 		sg_dma_len(sg) = sg->length;
 	}
 
 	return nents;
+
+out_unmap:
+	dma_direct_unmap_sg(dev, sgl, i, dir, attrs | DMA_ATTR_SKIP_CPU_SYNC);
+	return 0;
 }
 
 /*
@@ -331,12 +378,14 @@ const struct dma_map_ops dma_direct_ops = {
 	.free			= dma_direct_free,
 	.map_page		= dma_direct_map_page,
 	.map_sg			= dma_direct_map_sg,
-#if defined(CONFIG_ARCH_HAS_SYNC_DMA_FOR_DEVICE)
+#if defined(CONFIG_ARCH_HAS_SYNC_DMA_FOR_DEVICE) || \
+    defined(CONFIG_SWIOTLB)
 	.sync_single_for_device	= dma_direct_sync_single_for_device,
 	.sync_sg_for_device	= dma_direct_sync_sg_for_device,
 #endif
 #if defined(CONFIG_ARCH_HAS_SYNC_DMA_FOR_CPU) || \
-    defined(CONFIG_ARCH_HAS_SYNC_DMA_FOR_CPU_ALL)
+    defined(CONFIG_ARCH_HAS_SYNC_DMA_FOR_CPU_ALL) || \
+    defined(CONFIG_SWIOTLB)
 	.sync_single_for_cpu	= dma_direct_sync_single_for_cpu,
 	.sync_sg_for_cpu	= dma_direct_sync_sg_for_cpu,
 	.unmap_page		= dma_direct_unmap_page,
diff --git a/kernel/dma/swiotlb.c b/kernel/dma/swiotlb.c
index 2e126bac5d7d..d6361776dc5c 100644
--- a/kernel/dma/swiotlb.c
+++ b/kernel/dma/swiotlb.c
@@ -21,7 +21,6 @@
 
 #include <linux/cache.h>
 #include <linux/dma-direct.h>
-#include <linux/dma-noncoherent.h>
 #include <linux/mm.h>
 #include <linux/export.h>
 #include <linux/spinlock.h>
@@ -65,7 +64,7 @@ enum swiotlb_force swiotlb_force;
  * swiotlb_tbl_sync_single_*, to see if the memory was in fact allocated by this
  * API.
  */
-static phys_addr_t io_tlb_start, io_tlb_end;
+phys_addr_t io_tlb_start, io_tlb_end;
 
 /*
  * The number of IO TLB blocks (in groups of 64) between io_tlb_start and
@@ -383,11 +382,6 @@ void __init swiotlb_exit(void)
 	max_segment = 0;
 }
 
-static int is_swiotlb_buffer(phys_addr_t paddr)
-{
-	return paddr >= io_tlb_start && paddr < io_tlb_end;
-}
-
 /*
  * Bounce: copy the swiotlb buffer back to the original dma location
  */
@@ -623,221 +617,36 @@ void swiotlb_tbl_sync_single(struct device *hwdev, phys_addr_t tlb_addr,
 	}
 }
 
-static dma_addr_t swiotlb_bounce_page(struct device *dev, phys_addr_t *phys,
+/*
+ * Create a swiotlb mapping for the buffer at @phys, and in case of DMAing
+ * to the device copy the data into it as well.
+ */
+bool swiotlb_map(struct device *dev, phys_addr_t *phys, dma_addr_t *dma_addr,
 		size_t size, enum dma_data_direction dir, unsigned long attrs)
 {
-	dma_addr_t dma_addr;
+	trace_swiotlb_bounced(dev, *dma_addr, size, swiotlb_force);
 
 	if (unlikely(swiotlb_force = SWIOTLB_NO_FORCE)) {
 		dev_warn_ratelimited(dev,
 			"Cannot do DMA to address %pa\n", phys);
-		return DMA_MAPPING_ERROR;
+		return false;
 	}
 
 	/* Oh well, have to allocate and map a bounce buffer. */
 	*phys = swiotlb_tbl_map_single(dev, __phys_to_dma(dev, io_tlb_start),
 			*phys, size, dir, attrs);
 	if (*phys = DMA_MAPPING_ERROR)
-		return DMA_MAPPING_ERROR;
+		return false;
 
 	/* Ensure that the address returned is DMA'ble */
-	dma_addr = __phys_to_dma(dev, *phys);
-	if (unlikely(!dma_capable(dev, dma_addr, size))) {
+	*dma_addr = __phys_to_dma(dev, *phys);
+	if (unlikely(!dma_capable(dev, *dma_addr, size))) {
 		swiotlb_tbl_unmap_single(dev, *phys, size, dir,
 			attrs | DMA_ATTR_SKIP_CPU_SYNC);
-		return DMA_MAPPING_ERROR;
-	}
-
-	return dma_addr;
-}
-
-/*
- * Map a single buffer of the indicated size for DMA in streaming mode.  The
- * physical address to use is returned.
- *
- * Once the device is given the dma address, the device owns this memory until
- * either swiotlb_unmap_page or swiotlb_dma_sync_single is performed.
- */
-dma_addr_t swiotlb_map_page(struct device *dev, struct page *page,
-			    unsigned long offset, size_t size,
-			    enum dma_data_direction dir,
-			    unsigned long attrs)
-{
-	phys_addr_t phys = page_to_phys(page) + offset;
-	dma_addr_t dev_addr = phys_to_dma(dev, phys);
-
-	BUG_ON(dir = DMA_NONE);
-	/*
-	 * If the address happens to be in the device's DMA window,
-	 * we can safely return the device addr and not worry about bounce
-	 * buffering it.
-	 */
-	if (!dma_capable(dev, dev_addr, size) ||
-	    swiotlb_force = SWIOTLB_FORCE) {
-		trace_swiotlb_bounced(dev, dev_addr, size, swiotlb_force);
-		dev_addr = swiotlb_bounce_page(dev, &phys, size, dir, attrs);
+		return false;
 	}
 
-	if (!dev_is_dma_coherent(dev) &&
-	    (attrs & DMA_ATTR_SKIP_CPU_SYNC) = 0 &&
-	    dev_addr != DMA_MAPPING_ERROR)
-		arch_sync_dma_for_device(dev, phys, size, dir);
-
-	return dev_addr;
-}
-
-/*
- * Unmap a single streaming mode DMA translation.  The dma_addr and size must
- * match what was provided for in a previous swiotlb_map_page call.  All
- * other usages are undefined.
- *
- * After this call, reads by the cpu to the buffer are guaranteed to see
- * whatever the device wrote there.
- */
-void swiotlb_unmap_page(struct device *hwdev, dma_addr_t dev_addr,
-			size_t size, enum dma_data_direction dir,
-			unsigned long attrs)
-{
-	phys_addr_t paddr = dma_to_phys(hwdev, dev_addr);
-
-	BUG_ON(dir = DMA_NONE);
-
-	if (!dev_is_dma_coherent(hwdev) &&
-	    (attrs & DMA_ATTR_SKIP_CPU_SYNC) = 0)
-		arch_sync_dma_for_cpu(hwdev, paddr, size, dir);
-
-	if (is_swiotlb_buffer(paddr))
-		swiotlb_tbl_unmap_single(hwdev, paddr, size, dir, attrs);
-}
-
-/*
- * Make physical memory consistent for a single streaming mode DMA translation
- * after a transfer.
- *
- * If you perform a swiotlb_map_page() but wish to interrogate the buffer
- * using the cpu, yet do not wish to teardown the dma mapping, you must
- * call this function before doing so.  At the next point you give the dma
- * address back to the card, you must first perform a
- * swiotlb_dma_sync_for_device, and then the device again owns the buffer
- */
-static void
-swiotlb_sync_single(struct device *hwdev, dma_addr_t dev_addr,
-		    size_t size, enum dma_data_direction dir,
-		    enum dma_sync_target target)
-{
-	phys_addr_t paddr = dma_to_phys(hwdev, dev_addr);
-
-	BUG_ON(dir = DMA_NONE);
-
-	if (!dev_is_dma_coherent(hwdev) && target = SYNC_FOR_CPU)
-		arch_sync_dma_for_cpu(hwdev, paddr, size, dir);
-
-	if (is_swiotlb_buffer(paddr))
-		swiotlb_tbl_sync_single(hwdev, paddr, size, dir, target);
-
-	if (!dev_is_dma_coherent(hwdev) && target = SYNC_FOR_DEVICE)
-		arch_sync_dma_for_device(hwdev, paddr, size, dir);
-}
-
-void
-swiotlb_sync_single_for_cpu(struct device *hwdev, dma_addr_t dev_addr,
-			    size_t size, enum dma_data_direction dir)
-{
-	swiotlb_sync_single(hwdev, dev_addr, size, dir, SYNC_FOR_CPU);
-}
-
-void
-swiotlb_sync_single_for_device(struct device *hwdev, dma_addr_t dev_addr,
-			       size_t size, enum dma_data_direction dir)
-{
-	swiotlb_sync_single(hwdev, dev_addr, size, dir, SYNC_FOR_DEVICE);
-}
-
-/*
- * Map a set of buffers described by scatterlist in streaming mode for DMA.
- * This is the scatter-gather version of the above swiotlb_map_page
- * interface.  Here the scatter gather list elements are each tagged with the
- * appropriate dma address and length.  They are obtained via
- * sg_dma_{address,length}(SG).
- *
- * Device ownership issues as mentioned above for swiotlb_map_page are the
- * same here.
- */
-int
-swiotlb_map_sg_attrs(struct device *dev, struct scatterlist *sgl, int nelems,
-		     enum dma_data_direction dir, unsigned long attrs)
-{
-	struct scatterlist *sg;
-	int i;
-
-	for_each_sg(sgl, sg, nelems, i) {
-		sg->dma_address = swiotlb_map_page(dev, sg_page(sg), sg->offset,
-				sg->length, dir, attrs);
-		if (sg->dma_address = DMA_MAPPING_ERROR)
-			goto out_error;
-		sg_dma_len(sg) = sg->length;
-	}
-
-	return nelems;
-
-out_error:
-	swiotlb_unmap_sg_attrs(dev, sgl, i, dir,
-			attrs | DMA_ATTR_SKIP_CPU_SYNC);
-	sg_dma_len(sgl) = 0;
-	return 0;
-}
-
-/*
- * Unmap a set of streaming mode DMA translations.  Again, cpu read rules
- * concerning calls here are the same as for swiotlb_unmap_page() above.
- */
-void
-swiotlb_unmap_sg_attrs(struct device *hwdev, struct scatterlist *sgl,
-		       int nelems, enum dma_data_direction dir,
-		       unsigned long attrs)
-{
-	struct scatterlist *sg;
-	int i;
-
-	BUG_ON(dir = DMA_NONE);
-
-	for_each_sg(sgl, sg, nelems, i)
-		swiotlb_unmap_page(hwdev, sg->dma_address, sg_dma_len(sg), dir,
-			     attrs);
-}
-
-/*
- * Make physical memory consistent for a set of streaming mode DMA translations
- * after a transfer.
- *
- * The same as swiotlb_sync_single_* but for a scatter-gather list, same rules
- * and usage.
- */
-static void
-swiotlb_sync_sg(struct device *hwdev, struct scatterlist *sgl,
-		int nelems, enum dma_data_direction dir,
-		enum dma_sync_target target)
-{
-	struct scatterlist *sg;
-	int i;
-
-	for_each_sg(sgl, sg, nelems, i)
-		swiotlb_sync_single(hwdev, sg->dma_address,
-				    sg_dma_len(sg), dir, target);
-}
-
-void
-swiotlb_sync_sg_for_cpu(struct device *hwdev, struct scatterlist *sg,
-			int nelems, enum dma_data_direction dir)
-{
-	swiotlb_sync_sg(hwdev, sg, nelems, dir, SYNC_FOR_CPU);
-}
-
-void
-swiotlb_sync_sg_for_device(struct device *hwdev, struct scatterlist *sg,
-			   int nelems, enum dma_data_direction dir)
-{
-	swiotlb_sync_sg(hwdev, sg, nelems, dir, SYNC_FOR_DEVICE);
+	return true;
 }
 
 /*
@@ -851,18 +660,3 @@ swiotlb_dma_supported(struct device *hwdev, u64 mask)
 {
 	return __phys_to_dma(hwdev, io_tlb_end - 1) <= mask;
 }
-
-const struct dma_map_ops swiotlb_dma_ops = {
-	.alloc			= dma_direct_alloc,
-	.free			= dma_direct_free,
-	.sync_single_for_cpu	= swiotlb_sync_single_for_cpu,
-	.sync_single_for_device	= swiotlb_sync_single_for_device,
-	.sync_sg_for_cpu	= swiotlb_sync_sg_for_cpu,
-	.sync_sg_for_device	= swiotlb_sync_sg_for_device,
-	.map_sg			= swiotlb_map_sg_attrs,
-	.unmap_sg		= swiotlb_unmap_sg_attrs,
-	.map_page		= swiotlb_map_page,
-	.unmap_page		= swiotlb_unmap_page,
-	.dma_supported		= dma_direct_supported,
-};
-EXPORT_SYMBOL(swiotlb_dma_ops);
-- 
2.19.1
