From: Sinan Kaya <okaya@codeaurora.org>
Date: Thu, 17 Mar 2016 22:02:16 +0000
Subject: [PATCH 2/3] swiotlb: prefix dma_to_phys and phys_to_dma functions
Message-Id: <1458252137-24497-2-git-send-email-okaya@codeaurora.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1458252137-24497-1-git-send-email-okaya@codeaurora.org>
In-Reply-To: <1458252137-24497-1-git-send-email-okaya@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org, timur@codeaurora.org, cov@codeaurora.org, nwatters@codeaurora.org
Cc: Sinan Kaya <okaya@codeaurora.org>, Russell King <linux@arm.linux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Ralf Baechle <ralf@linux-mips.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Chris Metcalf <cmetcalf@ezchip.com>, Guan Xuetao <gxt@mprc.pku.edu.cn>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Bjorn Helgaas <bhelgaas@google.com>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Valentin Rothberg <valentinrothberg@gmail.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Joe Perches <joe@perches.com>, "Suthikulpanit, Suravee" <Suravee.Suthikulpanit@amd.com>, Robin Murphy <robin.murphy@arm.com>, Arnd Bergmann <arnd@arndb.de>, Jisheng Zhang <jszhang@marvell.com>, Dean Nelson <dnelson@redhat.com>, Guenter Roeck <linux@roeck-us.net>, Aaro Koskinen <aaro.koskinen@iki.fi>, Florian Fainelli <f.fainelli@gmail.com>, Huacai Chen <chenhc@lemote.com>, Denys Vlasenko <dvlasenk@redhat.com>, Akinobu Mita <akinobu.mita@gmail.com>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, linux-pci@vger.kernel.org, linux-xtensa@linux-xtensa.org

Prefixing dma_to_phys and phys_to_dma API with swiotlb so that
they are no longer part of the DMA API. These APIs do not exist
on all architectures and breaks compatibility.

In preparation for the clean up, also make the ARCH implementation
known by defining swiotlb_phys_do_dma and swiotlb_dma_to_phys.

Signed-off-by: Sinan Kaya <okaya@codeaurora.org>
---
 arch/arm/include/asm/dma-mapping.h                 |  8 ++-
 arch/arm64/include/asm/dma-mapping.h               |  9 ++-
 arch/arm64/mm/dma-mapping.c                        | 75 ++++++++++++++--------
 arch/ia64/include/asm/dma-mapping.h                |  8 ++-
 arch/mips/cavium-octeon/dma-octeon.c               |  8 +--
 .../include/asm/mach-cavium-octeon/dma-coherence.h |  7 +-
 arch/mips/include/asm/mach-generic/dma-coherence.h |  8 ++-
 .../include/asm/mach-loongson64/dma-coherence.h    | 14 ++--
 arch/mips/loongson64/common/dma-swiotlb.c          |  4 +-
 arch/powerpc/include/asm/dma-mapping.h             |  8 ++-
 arch/tile/include/asm/dma-mapping.h                |  8 ++-
 arch/unicore32/include/asm/dma-mapping.h           |  8 ++-
 arch/x86/include/asm/dma-mapping.h                 | 15 +++--
 arch/x86/kernel/pci-swiotlb.c                      |  2 +-
 arch/x86/pci/sta2x11-fixup.c                       | 10 +--
 arch/xtensa/include/asm/dma-mapping.h              |  8 ++-
 lib/swiotlb.c                                      | 28 ++++----
 17 files changed, 150 insertions(+), 78 deletions(-)

diff --git a/arch/arm/include/asm/dma-mapping.h b/arch/arm/include/asm/dma-mapping.h
index 6ad1ced..e176689 100644
--- a/arch/arm/include/asm/dma-mapping.h
+++ b/arch/arm/include/asm/dma-mapping.h
@@ -129,17 +129,21 @@ static inline bool is_device_dma_coherent(struct device *dev)
 	return dev->archdata.dma_coherent;
 }
 
-static inline dma_addr_t phys_to_dma(struct device *dev, phys_addr_t paddr)
+static inline dma_addr_t swiotlb_phys_to_dma(struct device *dev,
+					     phys_addr_t paddr)
 {
 	unsigned int offset = paddr & ~PAGE_MASK;
 	return pfn_to_dma(dev, __phys_to_pfn(paddr)) + offset;
 }
+#define swiotlb_phys_to_dma swiotlb_phys_to_dma
 
-static inline phys_addr_t dma_to_phys(struct device *dev, dma_addr_t dev_addr)
+static inline phys_addr_t swiotlb_dma_to_phys(struct device *dev,
+					      dma_addr_t dev_addr)
 {
 	unsigned int offset = dev_addr & ~PAGE_MASK;
 	return __pfn_to_phys(dma_to_pfn(dev, dev_addr)) + offset;
 }
+#define swiotlb_dma_to_phys swiotlb_dma_to_phys
 
 static inline bool dma_capable(struct device *dev, dma_addr_t addr, size_t size)
 {
diff --git a/arch/arm64/include/asm/dma-mapping.h b/arch/arm64/include/asm/dma-mapping.h
index ba437f0..39f21e8 100644
--- a/arch/arm64/include/asm/dma-mapping.h
+++ b/arch/arm64/include/asm/dma-mapping.h
@@ -64,15 +64,19 @@ static inline bool is_device_dma_coherent(struct device *dev)
 	return dev->archdata.dma_coherent;
 }
 
-static inline dma_addr_t phys_to_dma(struct device *dev, phys_addr_t paddr)
+static inline dma_addr_t swiotlb_phys_to_dma(struct device *dev,
+					     phys_addr_t paddr)
 {
 	return (dma_addr_t)paddr;
 }
+#define swiotlb_phys_to_dma swiotlb_phys_to_dma
 
-static inline phys_addr_t dma_to_phys(struct device *dev, dma_addr_t dev_addr)
+static inline phys_addr_t swiotlb_dma_to_phys(struct device *dev,
+					      dma_addr_t dev_addr)
 {
 	return (phys_addr_t)dev_addr;
 }
+#define swiotlb_dma_to_phys swiotlb_dma_to_phys
 
 static inline bool dma_capable(struct device *dev, dma_addr_t addr, size_t size)
 {
@@ -88,3 +92,4 @@ static inline void dma_mark_clean(void *addr, size_t size)
 
 #endif	/* __KERNEL__ */
 #endif	/* __ASM_DMA_MAPPING_H */
+
diff --git a/arch/arm64/mm/dma-mapping.c b/arch/arm64/mm/dma-mapping.c
index a6e757c..ada00c3 100644
--- a/arch/arm64/mm/dma-mapping.c
+++ b/arch/arm64/mm/dma-mapping.c
@@ -107,7 +107,7 @@ static void *__dma_alloc_coherent(struct device *dev, size_t size,
 		if (!page)
 			return NULL;
 
-		*dma_handle = phys_to_dma(dev, page_to_phys(page));
+		*dma_handle = swiotlb_phys_to_dma(dev, page_to_phys(page));
 		addr = page_address(page);
 		memset(addr, 0, size);
 		return addr;
@@ -121,7 +121,7 @@ static void __dma_free_coherent(struct device *dev, size_t size,
 				struct dma_attrs *attrs)
 {
 	bool freed;
-	phys_addr_t paddr = dma_to_phys(dev, dma_handle);
+	phys_addr_t paddr = swiotlb_dma_to_phys(dev, dma_handle);
 
 	if (dev = NULL) {
 		WARN_ONCE(1, "Use an actual device structure for DMA allocation\n");
@@ -151,7 +151,8 @@ static void *__dma_alloc(struct device *dev, size_t size,
 		void *addr = __alloc_from_pool(size, &page, flags);
 
 		if (addr)
-			*dma_handle = phys_to_dma(dev, page_to_phys(page));
+			*dma_handle = swiotlb_phys_to_dma(dev,
+							  page_to_phys(page));
 
 		return addr;
 	}
@@ -187,7 +188,7 @@ static void __dma_free(struct device *dev, size_t size,
 		       void *vaddr, dma_addr_t dma_handle,
 		       struct dma_attrs *attrs)
 {
-	void *swiotlb_addr = phys_to_virt(dma_to_phys(dev, dma_handle));
+	void *swiotlb_addr = phys_to_virt(swiotlb_dma_to_phys(dev, dma_handle));
 
 	size = PAGE_ALIGN(size);
 
@@ -208,7 +209,8 @@ static dma_addr_t __swiotlb_map_page(struct device *dev, struct page *page,
 
 	dev_addr = swiotlb_map_page(dev, page, offset, size, dir, attrs);
 	if (!is_device_dma_coherent(dev))
-		__dma_map_area(phys_to_virt(dma_to_phys(dev, dev_addr)), size, dir);
+		__dma_map_area(phys_to_virt(swiotlb_dma_to_phys(dev, dev_addr)),
+			       size, dir);
 
 	return dev_addr;
 }
@@ -218,8 +220,11 @@ static void __swiotlb_unmap_page(struct device *dev, dma_addr_t dev_addr,
 				 size_t size, enum dma_data_direction dir,
 				 struct dma_attrs *attrs)
 {
-	if (!is_device_dma_coherent(dev))
-		__dma_unmap_area(phys_to_virt(dma_to_phys(dev, dev_addr)), size, dir);
+	if (!is_device_dma_coherent(dev)) {
+		phys_addr_t phys = swiotlb_dma_to_phys(dev, dev_addr);
+
+		__dma_unmap_area(phys_to_virt(phys), size, dir);
+	}
 	swiotlb_unmap_page(dev, dev_addr, size, dir, attrs);
 }
 
@@ -232,9 +237,12 @@ static int __swiotlb_map_sg_attrs(struct device *dev, struct scatterlist *sgl,
 
 	ret = swiotlb_map_sg_attrs(dev, sgl, nelems, dir, attrs);
 	if (!is_device_dma_coherent(dev))
-		for_each_sg(sgl, sg, ret, i)
-			__dma_map_area(phys_to_virt(dma_to_phys(dev, sg->dma_address)),
-				       sg->length, dir);
+		for_each_sg(sgl, sg, ret, i) {
+			dma_addr_t dma = sg->dma_address;
+			phys_addr_t phys = swiotlb_dma_to_phys(dev, dma);
+
+			__dma_map_area(phys_to_virt(phys), sg->length, dir);
+		}
 
 	return ret;
 }
@@ -248,9 +256,12 @@ static void __swiotlb_unmap_sg_attrs(struct device *dev,
 	int i;
 
 	if (!is_device_dma_coherent(dev))
-		for_each_sg(sgl, sg, nelems, i)
-			__dma_unmap_area(phys_to_virt(dma_to_phys(dev, sg->dma_address)),
-					 sg->length, dir);
+		for_each_sg(sgl, sg, nelems, i) {
+			dma_addr_t dma = sg->dma_address;
+			phys_addr_t phys = swiotlb_dma_to_phys(dev, dma);
+
+			__dma_unmap_area(phys_to_virt(phys), sg->length, dir);
+		}
 	swiotlb_unmap_sg_attrs(dev, sgl, nelems, dir, attrs);
 }
 
@@ -258,8 +269,11 @@ static void __swiotlb_sync_single_for_cpu(struct device *dev,
 					  dma_addr_t dev_addr, size_t size,
 					  enum dma_data_direction dir)
 {
-	if (!is_device_dma_coherent(dev))
-		__dma_unmap_area(phys_to_virt(dma_to_phys(dev, dev_addr)), size, dir);
+	if (!is_device_dma_coherent(dev)) {
+		phys_addr_t phys = swiotlb_dma_to_phys(dev, dev_addr);
+
+		__dma_unmap_area(phys_to_virt(phys), size, dir);
+	}
 	swiotlb_sync_single_for_cpu(dev, dev_addr, size, dir);
 }
 
@@ -269,7 +283,8 @@ static void __swiotlb_sync_single_for_device(struct device *dev,
 {
 	swiotlb_sync_single_for_device(dev, dev_addr, size, dir);
 	if (!is_device_dma_coherent(dev))
-		__dma_map_area(phys_to_virt(dma_to_phys(dev, dev_addr)), size, dir);
+		__dma_map_area(phys_to_virt(swiotlb_dma_to_phys(dev, dev_addr)),
+			       size, dir);
 }
 
 static void __swiotlb_sync_sg_for_cpu(struct device *dev,
@@ -280,9 +295,12 @@ static void __swiotlb_sync_sg_for_cpu(struct device *dev,
 	int i;
 
 	if (!is_device_dma_coherent(dev))
-		for_each_sg(sgl, sg, nelems, i)
-			__dma_unmap_area(phys_to_virt(dma_to_phys(dev, sg->dma_address)),
-					 sg->length, dir);
+		for_each_sg(sgl, sg, nelems, i) {
+			dma_addr_t dma = sg->dma_address;
+			phys_addr_t phys = swiotlb_dma_to_phys(dev, dma);
+
+			__dma_unmap_area(phys_to_virt(phys), sg->length, dir);
+		}
 	swiotlb_sync_sg_for_cpu(dev, sgl, nelems, dir);
 }
 
@@ -295,9 +313,12 @@ static void __swiotlb_sync_sg_for_device(struct device *dev,
 
 	swiotlb_sync_sg_for_device(dev, sgl, nelems, dir);
 	if (!is_device_dma_coherent(dev))
-		for_each_sg(sgl, sg, nelems, i)
-			__dma_map_area(phys_to_virt(dma_to_phys(dev, sg->dma_address)),
-				       sg->length, dir);
+		for_each_sg(sgl, sg, nelems, i) {
+			dma_addr_t dma = sg->dma_address;
+			phys_addr_t phys = swiotlb_dma_to_phys(dev, dma);
+
+			__dma_map_area(phys_to_virt(phys), sg->length, dir);
+		}
 }
 
 static int __swiotlb_mmap(struct device *dev,
@@ -309,7 +330,7 @@ static int __swiotlb_mmap(struct device *dev,
 	unsigned long nr_vma_pages = (vma->vm_end - vma->vm_start) >>
 					PAGE_SHIFT;
 	unsigned long nr_pages = PAGE_ALIGN(size) >> PAGE_SHIFT;
-	unsigned long pfn = dma_to_phys(dev, dma_addr) >> PAGE_SHIFT;
+	unsigned long pfn = swiotlb_dma_to_phys(dev, dma_addr) >> PAGE_SHIFT;
 	unsigned long off = vma->vm_pgoff;
 
 	vma->vm_page_prot = __get_dma_pgprot(attrs, vma->vm_page_prot,
@@ -334,9 +355,11 @@ static int __swiotlb_get_sgtable(struct device *dev, struct sg_table *sgt,
 {
 	int ret = sg_alloc_table(sgt, 1, GFP_KERNEL);
 
-	if (!ret)
-		sg_set_page(sgt->sgl, phys_to_page(dma_to_phys(dev, handle)),
-			    PAGE_ALIGN(size), 0);
+	if (!ret) {
+		phys_addr_t phys = swiotlb_dma_to_phys(dev, handle);
+
+		sg_set_page(sgt->sgl, phys_to_page(phys), PAGE_ALIGN(size), 0);
+	}
 
 	return ret;
 }
diff --git a/arch/ia64/include/asm/dma-mapping.h b/arch/ia64/include/asm/dma-mapping.h
index d472805..a8736b9 100644
--- a/arch/ia64/include/asm/dma-mapping.h
+++ b/arch/ia64/include/asm/dma-mapping.h
@@ -33,15 +33,19 @@ static inline bool dma_capable(struct device *dev, dma_addr_t addr, size_t size)
 	return addr + size - 1 <= *dev->dma_mask;
 }
 
-static inline dma_addr_t phys_to_dma(struct device *dev, phys_addr_t paddr)
+static inline dma_addr_t swiotlb_phys_to_dma(struct device *dev,
+					     phys_addr_t paddr)
 {
 	return paddr;
 }
+#define swiotlb_phys_to_dma swiotlb_phys_to_dma
 
-static inline phys_addr_t dma_to_phys(struct device *dev, dma_addr_t daddr)
+static inline phys_addr_t swiotlb_dma_to_phys(struct device *dev,
+					      dma_addr_t daddr)
 {
 	return daddr;
 }
+#define swiotlb_dma_to_phys swiotlb_dma_to_phys
 
 static inline void
 dma_cache_sync (struct device *dev, void *vaddr, size_t size,
diff --git a/arch/mips/cavium-octeon/dma-octeon.c b/arch/mips/cavium-octeon/dma-octeon.c
index 2cd45f5..9ea7e9b 100644
--- a/arch/mips/cavium-octeon/dma-octeon.c
+++ b/arch/mips/cavium-octeon/dma-octeon.c
@@ -210,7 +210,7 @@ struct octeon_dma_map_ops {
 	phys_addr_t (*dma_to_phys)(struct device *dev, dma_addr_t daddr);
 };
 
-dma_addr_t phys_to_dma(struct device *dev, phys_addr_t paddr)
+dma_addr_t swiotlb_phys_to_dma(struct device *dev, phys_addr_t paddr)
 {
 	struct octeon_dma_map_ops *ops = container_of(get_dma_ops(dev),
 						      struct octeon_dma_map_ops,
@@ -218,9 +218,9 @@ dma_addr_t phys_to_dma(struct device *dev, phys_addr_t paddr)
 
 	return ops->phys_to_dma(dev, paddr);
 }
-EXPORT_SYMBOL(phys_to_dma);
+EXPORT_SYMBOL(swiotlb_phys_to_dma);
 
-phys_addr_t dma_to_phys(struct device *dev, dma_addr_t daddr)
+phys_addr_t swiotlb_dma_to_phys(struct device *dev, dma_addr_t daddr)
 {
 	struct octeon_dma_map_ops *ops = container_of(get_dma_ops(dev),
 						      struct octeon_dma_map_ops,
@@ -228,7 +228,7 @@ phys_addr_t dma_to_phys(struct device *dev, dma_addr_t daddr)
 
 	return ops->dma_to_phys(dev, daddr);
 }
-EXPORT_SYMBOL(dma_to_phys);
+EXPORT_SYMBOL(swiotlb_dma_to_phys);
 
 static struct octeon_dma_map_ops octeon_linear_dma_map_ops = {
 	.dma_map_ops = {
diff --git a/arch/mips/include/asm/mach-cavium-octeon/dma-coherence.h b/arch/mips/include/asm/mach-cavium-octeon/dma-coherence.h
index 460042e..5f0f13a 100644
--- a/arch/mips/include/asm/mach-cavium-octeon/dma-coherence.h
+++ b/arch/mips/include/asm/mach-cavium-octeon/dma-coherence.h
@@ -61,8 +61,11 @@ static inline void plat_post_dma_flush(struct device *dev)
 {
 }
 
-dma_addr_t phys_to_dma(struct device *dev, phys_addr_t paddr);
-phys_addr_t dma_to_phys(struct device *dev, dma_addr_t daddr);
+dma_addr_t swiotlb_phys_to_dma(struct device *dev, phys_addr_t paddr);
+#define swiotlb_phys_to_dma swiotlb_phys_to_dma
+
+phys_addr_t swiotlb_dma_to_phys(struct device *dev, dma_addr_t daddr);
+#define swiotlb_dma_to_phys swiotlb_dma_to_phys
 
 struct dma_map_ops;
 extern struct dma_map_ops *octeon_pci_dma_map_ops;
diff --git a/arch/mips/include/asm/mach-generic/dma-coherence.h b/arch/mips/include/asm/mach-generic/dma-coherence.h
index 0f8a354..54fde22 100644
--- a/arch/mips/include/asm/mach-generic/dma-coherence.h
+++ b/arch/mips/include/asm/mach-generic/dma-coherence.h
@@ -59,15 +59,19 @@ static inline void plat_post_dma_flush(struct device *dev)
 #endif
 
 #ifdef CONFIG_SWIOTLB
-static inline dma_addr_t phys_to_dma(struct device *dev, phys_addr_t paddr)
+static inline dma_addr_t swiotlb_phys_to_dma(struct device *dev,
+					     phys_addr_t paddr)
 {
 	return paddr;
 }
+#define swiotlb_phys_to_dma swiotlb_phys_to_dma
 
-static inline phys_addr_t dma_to_phys(struct device *dev, dma_addr_t daddr)
+static inline phys_addr_t swiotlb_dma_to_phys(struct device *dev,
+					      dma_addr_t daddr)
 {
 	return daddr;
 }
+#define swiotlb_dma_to_phys swiotlb_dma_to_phys
 #endif
 
 #endif /* __ASM_MACH_GENERIC_DMA_COHERENCE_H */
diff --git a/arch/mips/include/asm/mach-loongson64/dma-coherence.h b/arch/mips/include/asm/mach-loongson64/dma-coherence.h
index 1602a9e..26fe763 100644
--- a/arch/mips/include/asm/mach-loongson64/dma-coherence.h
+++ b/arch/mips/include/asm/mach-loongson64/dma-coherence.h
@@ -17,13 +17,17 @@
 
 struct device;
 
-extern dma_addr_t phys_to_dma(struct device *dev, phys_addr_t paddr);
-extern phys_addr_t dma_to_phys(struct device *dev, dma_addr_t daddr);
+extern dma_addr_t swiotlb_phys_to_dma(struct device *dev, phys_addr_t paddr);
+#define swiotlb_phys_to_dma swiotlb_phys_to_dma
+
+extern phys_addr_t swiotlb_dma_to_phys(struct device *dev, dma_addr_t daddr);
+#define swiotlb_dma_to_phys swiotlb_dma_to_phys
+
 static inline dma_addr_t plat_map_dma_mem(struct device *dev, void *addr,
 					  size_t size)
 {
 #ifdef CONFIG_CPU_LOONGSON3
-	return phys_to_dma(dev, virt_to_phys(addr));
+	return swiotlb_phys_to_dma(dev, virt_to_phys(addr));
 #else
 	return virt_to_phys(addr) | 0x80000000;
 #endif
@@ -33,7 +37,7 @@ static inline dma_addr_t plat_map_dma_mem_page(struct device *dev,
 					       struct page *page)
 {
 #ifdef CONFIG_CPU_LOONGSON3
-	return phys_to_dma(dev, page_to_phys(page));
+	return swiotlb_phys_to_dma(dev, page_to_phys(page));
 #else
 	return page_to_phys(page) | 0x80000000;
 #endif
@@ -43,7 +47,7 @@ static inline unsigned long plat_dma_addr_to_phys(struct device *dev,
 	dma_addr_t dma_addr)
 {
 #if defined(CONFIG_CPU_LOONGSON3) && defined(CONFIG_64BIT)
-	return dma_to_phys(dev, dma_addr);
+	return swiotlb_dma_to_phys(dev, dma_addr);
 #elif defined(CONFIG_CPU_LOONGSON2F) && defined(CONFIG_64BIT)
 	return (dma_addr > 0x8fffffff) ? dma_addr : (dma_addr & 0x0fffffff);
 #else
diff --git a/arch/mips/loongson64/common/dma-swiotlb.c b/arch/mips/loongson64/common/dma-swiotlb.c
index 4ffa6fc..88ef4cf 100644
--- a/arch/mips/loongson64/common/dma-swiotlb.c
+++ b/arch/mips/loongson64/common/dma-swiotlb.c
@@ -98,7 +98,7 @@ static int loongson_dma_set_mask(struct device *dev, u64 mask)
 	return 0;
 }
 
-dma_addr_t phys_to_dma(struct device *dev, phys_addr_t paddr)
+dma_addr_t swiotlb_phys_to_dma(struct device *dev, phys_addr_t paddr)
 {
 	long nid;
 #ifdef CONFIG_PHYS48_TO_HT40
@@ -110,7 +110,7 @@ dma_addr_t phys_to_dma(struct device *dev, phys_addr_t paddr)
 	return paddr;
 }
 
-phys_addr_t dma_to_phys(struct device *dev, dma_addr_t daddr)
+phys_addr_t swiotlb_dma_to_phys(struct device *dev, dma_addr_t daddr)
 {
 	long nid;
 #ifdef CONFIG_PHYS48_TO_HT40
diff --git a/arch/powerpc/include/asm/dma-mapping.h b/arch/powerpc/include/asm/dma-mapping.h
index 77816ac..3a9d6f2 100644
--- a/arch/powerpc/include/asm/dma-mapping.h
+++ b/arch/powerpc/include/asm/dma-mapping.h
@@ -143,15 +143,19 @@ static inline bool dma_capable(struct device *dev, dma_addr_t addr, size_t size)
 	return addr + size - 1 <= *dev->dma_mask;
 }
 
-static inline dma_addr_t phys_to_dma(struct device *dev, phys_addr_t paddr)
+static inline dma_addr_t swiotlb_phys_to_dma(struct device *dev,
+					     phys_addr_t paddr)
 {
 	return paddr + get_dma_offset(dev);
 }
+#define swiotlb_phys_to_dma swiotlb_phys_to_dma
 
-static inline phys_addr_t dma_to_phys(struct device *dev, dma_addr_t daddr)
+static inline phys_addr_t swiotlb_dma_to_phys(struct device *dev,
+					      dma_addr_t daddr)
 {
 	return daddr - get_dma_offset(dev);
 }
+#define swiotlb_dma_to_phys swiotlb_dma_to_phys
 
 #define ARCH_HAS_DMA_MMAP_COHERENT
 
diff --git a/arch/tile/include/asm/dma-mapping.h b/arch/tile/include/asm/dma-mapping.h
index 01ceb4a..87c205a 100644
--- a/arch/tile/include/asm/dma-mapping.h
+++ b/arch/tile/include/asm/dma-mapping.h
@@ -47,15 +47,19 @@ static inline void set_dma_offset(struct device *dev, dma_addr_t off)
 	dev->archdata.dma_offset = off;
 }
 
-static inline dma_addr_t phys_to_dma(struct device *dev, phys_addr_t paddr)
+static inline dma_addr_t swiotlb_phys_to_dma(struct device *dev,
+					     phys_addr_t paddr)
 {
 	return paddr;
 }
+#define swiotlb_phys_to_dma swiotlb_phys_to_dma
 
-static inline phys_addr_t dma_to_phys(struct device *dev, dma_addr_t daddr)
+static inline phys_addr_t swiotlb_dma_to_phys(struct device *dev,
+					      dma_addr_t daddr)
 {
 	return daddr;
 }
+#define swiotlb_dma_to_phys swiotlb_dma_to_phys
 
 static inline void dma_mark_clean(void *addr, size_t size) {}
 
diff --git a/arch/unicore32/include/asm/dma-mapping.h b/arch/unicore32/include/asm/dma-mapping.h
index 4749854..762cdd8 100644
--- a/arch/unicore32/include/asm/dma-mapping.h
+++ b/arch/unicore32/include/asm/dma-mapping.h
@@ -36,15 +36,19 @@ static inline bool dma_capable(struct device *dev, dma_addr_t addr, size_t size)
 	return 1;
 }
 
-static inline dma_addr_t phys_to_dma(struct device *dev, phys_addr_t paddr)
+static inline dma_addr_t swiotlb_phys_to_dma(struct device *dev,
+					     phys_addr_t paddr)
 {
 	return paddr;
 }
+#define swiotlb_phys_to_dma swiotlb_phys_to_dma
 
-static inline phys_addr_t dma_to_phys(struct device *dev, dma_addr_t daddr)
+static inline phys_addr_t swiotlb_dma_to_phys(struct device *dev,
+					      dma_addr_t daddr)
 {
 	return daddr;
 }
+#define swiotlb_dma_to_phys swiotlb_dma_to_phys
 
 static inline void dma_mark_clean(void *addr, size_t size) {}
 
diff --git a/arch/x86/include/asm/dma-mapping.h b/arch/x86/include/asm/dma-mapping.h
index 3a27b93..be8b76e 100644
--- a/arch/x86/include/asm/dma-mapping.h
+++ b/arch/x86/include/asm/dma-mapping.h
@@ -56,8 +56,11 @@ extern void dma_generic_free_coherent(struct device *dev, size_t size,
 
 #ifdef CONFIG_X86_DMA_REMAP /* Platform code defines bridge-specific code */
 extern bool dma_capable(struct device *dev, dma_addr_t addr, size_t size);
-extern dma_addr_t phys_to_dma(struct device *dev, phys_addr_t paddr);
-extern phys_addr_t dma_to_phys(struct device *dev, dma_addr_t daddr);
+extern dma_addr_t swiotlb_phys_to_dma(struct device *dev, phys_addr_t paddr);
+#define swiotlb_phys_to_dma swiotlb_phys_to_dma
+
+extern phys_addr_t swiotlb_dma_to_phys(struct device *dev, dma_addr_t daddr);
+#define swiotlb_dma_to_phys swiotlb_dma_to_phys
 #else
 
 static inline bool dma_capable(struct device *dev, dma_addr_t addr, size_t size)
@@ -68,15 +71,19 @@ static inline bool dma_capable(struct device *dev, dma_addr_t addr, size_t size)
 	return addr + size - 1 <= *dev->dma_mask;
 }
 
-static inline dma_addr_t phys_to_dma(struct device *dev, phys_addr_t paddr)
+static inline dma_addr_t swiotlb_phys_to_dma(struct device *dev,
+					     phys_addr_t paddr)
 {
 	return paddr;
 }
+#define swiotlb_phys_to_dma swiotlb_phys_to_dma
 
-static inline phys_addr_t dma_to_phys(struct device *dev, dma_addr_t daddr)
+static inline phys_addr_t swiotlb_dma_to_phys(struct device *dev,
+					      dma_addr_t daddr)
 {
 	return daddr;
 }
+#define swiotlb_dma_to_phys swiotlb_dma_to_phys
 #endif /* CONFIG_X86_DMA_REMAP */
 
 static inline void
diff --git a/arch/x86/kernel/pci-swiotlb.c b/arch/x86/kernel/pci-swiotlb.c
index 7c577a1..9333fbd 100644
--- a/arch/x86/kernel/pci-swiotlb.c
+++ b/arch/x86/kernel/pci-swiotlb.c
@@ -39,7 +39,7 @@ void x86_swiotlb_free_coherent(struct device *dev, size_t size,
 				      void *vaddr, dma_addr_t dma_addr,
 				      struct dma_attrs *attrs)
 {
-	if (is_swiotlb_buffer(dma_to_phys(dev, dma_addr)))
+	if (is_swiotlb_buffer(swiotlb_dma_to_phys(dev, dma_addr)))
 		swiotlb_free_coherent(dev, size, vaddr, dma_addr);
 	else
 		dma_generic_free_coherent(dev, size, vaddr, dma_addr, attrs);
diff --git a/arch/x86/pci/sta2x11-fixup.c b/arch/x86/pci/sta2x11-fixup.c
index 5ceda85..6df3eb4 100644
--- a/arch/x86/pci/sta2x11-fixup.c
+++ b/arch/x86/pci/sta2x11-fixup.c
@@ -241,11 +241,12 @@ bool dma_capable(struct device *dev, dma_addr_t addr, size_t size)
 }
 
 /**
- * phys_to_dma - Return the DMA AMBA address used for this STA2x11 device
+ * swiotlb_phys_to_dma - Return the DMA AMBA address used for this
+ *	STA2x11 device
  * @dev: device for a PCI device
  * @paddr: Physical address
  */
-dma_addr_t phys_to_dma(struct device *dev, phys_addr_t paddr)
+dma_addr_t swiotlb_phys_to_dma(struct device *dev, phys_addr_t paddr)
 {
 	if (dev->archdata.dma_ops != &sta2x11_dma_ops)
 		return paddr;
@@ -253,11 +254,12 @@ dma_addr_t phys_to_dma(struct device *dev, phys_addr_t paddr)
 }
 
 /**
- * dma_to_phys - Return the physical address used for this STA2x11 DMA address
+ * swiotlb_dma_to_phys - Return the physical address used for this
+ *	STA2x11 DMA address
  * @dev: device for a PCI device
  * @daddr: STA2x11 AMBA DMA address
  */
-phys_addr_t dma_to_phys(struct device *dev, dma_addr_t daddr)
+phys_addr_t swiotlb_dma_to_phys(struct device *dev, dma_addr_t daddr)
 {
 	if (dev->archdata.dma_ops != &sta2x11_dma_ops)
 		return daddr;
diff --git a/arch/xtensa/include/asm/dma-mapping.h b/arch/xtensa/include/asm/dma-mapping.h
index 3fc1170..b0d725d 100644
--- a/arch/xtensa/include/asm/dma-mapping.h
+++ b/arch/xtensa/include/asm/dma-mapping.h
@@ -31,14 +31,18 @@ static inline struct dma_map_ops *get_dma_ops(struct device *dev)
 void dma_cache_sync(struct device *dev, void *vaddr, size_t size,
 		    enum dma_data_direction direction);
 
-static inline dma_addr_t phys_to_dma(struct device *dev, phys_addr_t paddr)
+static inline dma_addr_t swiotlb_phys_to_dma(struct device *dev,
+					     phys_addr_t paddr)
 {
 	return (dma_addr_t)paddr;
 }
+#define swiotlb_phys_to_dma swiotlb_phys_to_dma
 
-static inline phys_addr_t dma_to_phys(struct device *dev, dma_addr_t daddr)
+static inline phys_addr_t swiotlb_dma_to_phys(struct device *dev,
+					      dma_addr_t daddr)
 {
 	return (phys_addr_t)daddr;
 }
+#define swiotlb_dma_to_phys swiotlb_dma_to_phys
 
 #endif	/* _XTENSA_DMA_MAPPING_H */
diff --git a/lib/swiotlb.c b/lib/swiotlb.c
index 76f29ec..5aadeca 100644
--- a/lib/swiotlb.c
+++ b/lib/swiotlb.c
@@ -135,7 +135,7 @@ unsigned long swiotlb_size_or_default(void)
 static dma_addr_t swiotlb_virt_to_bus(struct device *hwdev,
 				      volatile void *address)
 {
-	return phys_to_dma(hwdev, virt_to_phys(address));
+	return swiotlb_phys_to_dma(hwdev, virt_to_phys(address));
 }
 
 static bool no_iotlb_memory;
@@ -541,7 +541,7 @@ static phys_addr_t
 map_single(struct device *hwdev, phys_addr_t phys, size_t size,
 	   enum dma_data_direction dir)
 {
-	dma_addr_t start_dma_addr = phys_to_dma(hwdev, io_tlb_start);
+	dma_addr_t start_dma_addr = swiotlb_phys_to_dma(hwdev, io_tlb_start);
 
 	return swiotlb_tbl_map_single(hwdev, start_dma_addr, phys, size, dir);
 }
@@ -659,7 +659,7 @@ swiotlb_alloc_coherent(struct device *hwdev, size_t size,
 			goto err_warn;
 
 		ret = phys_to_virt(paddr);
-		dev_addr = phys_to_dma(hwdev, paddr);
+		dev_addr = swiotlb_phys_to_dma(hwdev, paddr);
 
 		/* Confirm address can be DMA'd by device */
 		if (dev_addr + size - 1 > dma_mask) {
@@ -692,7 +692,7 @@ void
 swiotlb_free_coherent(struct device *hwdev, size_t size, void *vaddr,
 		      dma_addr_t dev_addr)
 {
-	phys_addr_t paddr = dma_to_phys(hwdev, dev_addr);
+	phys_addr_t paddr = swiotlb_dma_to_phys(hwdev, dev_addr);
 
 	WARN_ON(irqs_disabled());
 	if (!is_swiotlb_buffer(paddr))
@@ -741,7 +741,7 @@ dma_addr_t swiotlb_map_page(struct device *dev, struct page *page,
 			    struct dma_attrs *attrs)
 {
 	phys_addr_t map, phys = page_to_phys(page) + offset;
-	dma_addr_t dev_addr = phys_to_dma(dev, phys);
+	dma_addr_t dev_addr = swiotlb_phys_to_dma(dev, phys);
 
 	BUG_ON(dir = DMA_NONE);
 	/*
@@ -758,15 +758,15 @@ dma_addr_t swiotlb_map_page(struct device *dev, struct page *page,
 	map = map_single(dev, phys, size, dir);
 	if (map = SWIOTLB_MAP_ERROR) {
 		swiotlb_full(dev, size, dir, 1);
-		return phys_to_dma(dev, io_tlb_overflow_buffer);
+		return swiotlb_phys_to_dma(dev, io_tlb_overflow_buffer);
 	}
 
-	dev_addr = phys_to_dma(dev, map);
+	dev_addr = swiotlb_phys_to_dma(dev, map);
 
 	/* Ensure that the address returned is DMA'ble */
 	if (!dma_capable(dev, dev_addr, size)) {
 		swiotlb_tbl_unmap_single(dev, map, size, dir);
-		return phys_to_dma(dev, io_tlb_overflow_buffer);
+		return swiotlb_phys_to_dma(dev, io_tlb_overflow_buffer);
 	}
 
 	return dev_addr;
@@ -784,7 +784,7 @@ EXPORT_SYMBOL_GPL(swiotlb_map_page);
 static void unmap_single(struct device *hwdev, dma_addr_t dev_addr,
 			 size_t size, enum dma_data_direction dir)
 {
-	phys_addr_t paddr = dma_to_phys(hwdev, dev_addr);
+	phys_addr_t paddr = swiotlb_dma_to_phys(hwdev, dev_addr);
 
 	BUG_ON(dir = DMA_NONE);
 
@@ -828,7 +828,7 @@ swiotlb_sync_single(struct device *hwdev, dma_addr_t dev_addr,
 		    size_t size, enum dma_data_direction dir,
 		    enum dma_sync_target target)
 {
-	phys_addr_t paddr = dma_to_phys(hwdev, dev_addr);
+	phys_addr_t paddr = swiotlb_dma_to_phys(hwdev, dev_addr);
 
 	BUG_ON(dir = DMA_NONE);
 
@@ -886,7 +886,7 @@ swiotlb_map_sg_attrs(struct device *hwdev, struct scatterlist *sgl, int nelems,
 
 	for_each_sg(sgl, sg, nelems, i) {
 		phys_addr_t paddr = sg_phys(sg);
-		dma_addr_t dev_addr = phys_to_dma(hwdev, paddr);
+		dma_addr_t dev_addr = swiotlb_phys_to_dma(hwdev, paddr);
 
 		if (swiotlb_force ||
 		    !dma_capable(hwdev, dev_addr, sg->length)) {
@@ -901,7 +901,7 @@ swiotlb_map_sg_attrs(struct device *hwdev, struct scatterlist *sgl, int nelems,
 				sg_dma_len(sgl) = 0;
 				return 0;
 			}
-			sg->dma_address = phys_to_dma(hwdev, map);
+			sg->dma_address = swiotlb_phys_to_dma(hwdev, map);
 		} else
 			sg->dma_address = dev_addr;
 		sg_dma_len(sg) = sg->length;
@@ -984,7 +984,7 @@ EXPORT_SYMBOL(swiotlb_sync_sg_for_device);
 int
 swiotlb_dma_mapping_error(struct device *hwdev, dma_addr_t dma_addr)
 {
-	return (dma_addr = phys_to_dma(hwdev, io_tlb_overflow_buffer));
+	return (dma_addr = swiotlb_phys_to_dma(hwdev, io_tlb_overflow_buffer));
 }
 EXPORT_SYMBOL(swiotlb_dma_mapping_error);
 
@@ -997,6 +997,6 @@ EXPORT_SYMBOL(swiotlb_dma_mapping_error);
 int
 swiotlb_dma_supported(struct device *hwdev, u64 mask)
 {
-	return phys_to_dma(hwdev, io_tlb_end - 1) <= mask;
+	return swiotlb_phys_to_dma(hwdev, io_tlb_end - 1) <= mask;
 }
 EXPORT_SYMBOL(swiotlb_dma_supported);
-- 
1.8.2.1

