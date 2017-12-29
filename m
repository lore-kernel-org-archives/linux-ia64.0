From: Christoph Hellwig <hch@lst.de>
Date: Fri, 29 Dec 2017 08:18:56 +0000
Subject: [PATCH 52/67] dma-direct: handle the memory encryption bit in common code
Message-Id: <20171229081911.2802-53-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20171229081911.2802-1-hch@lst.de>
In-Reply-To: <20171229081911.2802-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: iommu@lists.linux-foundation.org
Cc: linux-alpha@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, adi-buildroot-devel@lists.sourceforge.net, linux-c6x-dev@linux-c6x.org, linux-cris-kernel@axis.com, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-metag@vger.kernel.org, Michal Simek <monstr@monstr.eu>, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, patches@groups.riscv.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, Guan Xuetao <gxt@mprc.pku.edu.cn>, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

G=D1=96ve the basic phys_to_dma and dma_to_phys helpers a __-prefix and add
the memory encryption mask to the non-prefixed versions.  Use the
__-prefixed versions directly instead of clearing the mask again in
various places.

With that in place the generic dma-direct routines can be used to
allocate non-encrypted bounce buffers, and the x86 SEV case can use
the generic swiotlb ops.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/arm/include/asm/dma-direct.h                  |  4 +-
 arch/mips/cavium-octeon/dma-octeon.c               | 10 +--
 .../include/asm/mach-cavium-octeon/dma-coherence.h |  4 +-
 .../include/asm/mach-loongson64/dma-coherence.h    | 10 +--
 arch/mips/loongson64/common/dma-swiotlb.c          |  4 +-
 arch/powerpc/include/asm/dma-direct.h              |  4 +-
 arch/x86/Kconfig                                   |  2 +-
 arch/x86/include/asm/dma-direct.h                  | 25 +-------
 arch/x86/mm/mem_encrypt.c                          | 73 +-----------------=
----
 arch/x86/pci/sta2x11-fixup.c                       |  6 +-
 include/linux/dma-direct.h                         | 23 ++++++-
 lib/dma-direct.c                                   | 24 +++++--
 lib/swiotlb.c                                      | 25 +++-----
 13 files changed, 76 insertions(+), 138 deletions(-)

diff --git a/arch/arm/include/asm/dma-direct.h b/arch/arm/include/asm/dma-d=
irect.h
index 5b0a8a421894..b67e5fc1fe43 100644
--- a/arch/arm/include/asm/dma-direct.h
+++ b/arch/arm/include/asm/dma-direct.h
@@ -2,13 +2,13 @@
 #ifndef ASM_ARM_DMA_DIRECT_H
 #define ASM_ARM_DMA_DIRECT_H 1
=20
-static inline dma_addr_t phys_to_dma(struct device *dev, phys_addr_t paddr)
+static inline dma_addr_t __phys_to_dma(struct device *dev, phys_addr_t pad=
dr)
 {
 	unsigned int offset =3D paddr & ~PAGE_MASK;
 	return pfn_to_dma(dev, __phys_to_pfn(paddr)) + offset;
 }
=20
-static inline phys_addr_t dma_to_phys(struct device *dev, dma_addr_t dev_a=
ddr)
+static inline phys_addr_t __dma_to_phys(struct device *dev, dma_addr_t dev=
_addr)
 {
 	unsigned int offset =3D dev_addr & ~PAGE_MASK;
 	return __pfn_to_phys(dma_to_pfn(dev, dev_addr)) + offset;
diff --git a/arch/mips/cavium-octeon/dma-octeon.c b/arch/mips/cavium-octeon=
/dma-octeon.c
index 5baf79fce643..6440ad3f9e3b 100644
--- a/arch/mips/cavium-octeon/dma-octeon.c
+++ b/arch/mips/cavium-octeon/dma-octeon.c
@@ -10,7 +10,7 @@
  * IP32 changes by Ilya.
  * Copyright (C) 2010 Cavium Networks, Inc.
  */
-#include <linux/dma-mapping.h>
+#include <linux/dma-direct.h>
 #include <linux/scatterlist.h>
 #include <linux/bootmem.h>
 #include <linux/export.h>
@@ -202,7 +202,7 @@ struct octeon_dma_map_ops {
 	phys_addr_t (*dma_to_phys)(struct device *dev, dma_addr_t daddr);
 };
=20
-dma_addr_t phys_to_dma(struct device *dev, phys_addr_t paddr)
+dma_addr_t __phys_to_dma(struct device *dev, phys_addr_t paddr)
 {
 	struct octeon_dma_map_ops *ops =3D container_of(get_dma_ops(dev),
 						      struct octeon_dma_map_ops,
@@ -210,9 +210,9 @@ dma_addr_t phys_to_dma(struct device *dev, phys_addr_t =
paddr)
=20
 	return ops->phys_to_dma(dev, paddr);
 }
-EXPORT_SYMBOL(phys_to_dma);
+EXPORT_SYMBOL(__phys_to_dma);
=20
-phys_addr_t dma_to_phys(struct device *dev, dma_addr_t daddr)
+phys_addr_t __dma_to_phys(struct device *dev, dma_addr_t daddr)
 {
 	struct octeon_dma_map_ops *ops =3D container_of(get_dma_ops(dev),
 						      struct octeon_dma_map_ops,
@@ -220,7 +220,7 @@ phys_addr_t dma_to_phys(struct device *dev, dma_addr_t =
daddr)
=20
 	return ops->dma_to_phys(dev, daddr);
 }
-EXPORT_SYMBOL(dma_to_phys);
+EXPORT_SYMBOL(__dma_to_phys);
=20
 static struct octeon_dma_map_ops octeon_linear_dma_map_ops =3D {
 	.dma_map_ops =3D {
diff --git a/arch/mips/include/asm/mach-cavium-octeon/dma-coherence.h b/arc=
h/mips/include/asm/mach-cavium-octeon/dma-coherence.h
index f00833acb626..6f8e024f4f97 100644
--- a/arch/mips/include/asm/mach-cavium-octeon/dma-coherence.h
+++ b/arch/mips/include/asm/mach-cavium-octeon/dma-coherence.h
@@ -69,8 +69,8 @@ static inline bool dma_capable(struct device *dev, dma_ad=
dr_t addr, size_t size)
 	return addr + size <=3D *dev->dma_mask;
 }
=20
-dma_addr_t phys_to_dma(struct device *dev, phys_addr_t paddr);
-phys_addr_t dma_to_phys(struct device *dev, dma_addr_t daddr);
+dma_addr_t __phys_to_dma(struct device *dev, phys_addr_t paddr);
+phys_addr_t __dma_to_phys(struct device *dev, dma_addr_t daddr);
=20
 struct dma_map_ops;
 extern const struct dma_map_ops *octeon_pci_dma_map_ops;
diff --git a/arch/mips/include/asm/mach-loongson64/dma-coherence.h b/arch/m=
ips/include/asm/mach-loongson64/dma-coherence.h
index 5cfda8f893e9..94fd224dddee 100644
--- a/arch/mips/include/asm/mach-loongson64/dma-coherence.h
+++ b/arch/mips/include/asm/mach-loongson64/dma-coherence.h
@@ -25,13 +25,13 @@ static inline bool dma_capable(struct device *dev, dma_=
addr_t addr, size_t size)
 	return addr + size <=3D *dev->dma_mask;
 }
=20
-extern dma_addr_t phys_to_dma(struct device *dev, phys_addr_t paddr);
-extern phys_addr_t dma_to_phys(struct device *dev, dma_addr_t daddr);
+extern dma_addr_t __phys_to_dma(struct device *dev, phys_addr_t paddr);
+extern phys_addr_t __dma_to_phys(struct device *dev, dma_addr_t daddr);
 static inline dma_addr_t plat_map_dma_mem(struct device *dev, void *addr,
 					  size_t size)
 {
 #ifdef CONFIG_CPU_LOONGSON3
-	return phys_to_dma(dev, virt_to_phys(addr));
+	return __phys_to_dma(dev, virt_to_phys(addr));
 #else
 	return virt_to_phys(addr) | 0x80000000;
 #endif
@@ -41,7 +41,7 @@ static inline dma_addr_t plat_map_dma_mem_page(struct dev=
ice *dev,
 					       struct page *page)
 {
 #ifdef CONFIG_CPU_LOONGSON3
-	return phys_to_dma(dev, page_to_phys(page));
+	return __phys_to_dma(dev, page_to_phys(page));
 #else
 	return page_to_phys(page) | 0x80000000;
 #endif
@@ -51,7 +51,7 @@ static inline unsigned long plat_dma_addr_to_phys(struct =
device *dev,
 	dma_addr_t dma_addr)
 {
 #if defined(CONFIG_CPU_LOONGSON3) && defined(CONFIG_64BIT)
-	return dma_to_phys(dev, dma_addr);
+	return __dma_to_phys(dev, dma_addr);
 #elif defined(CONFIG_CPU_LOONGSON2F) && defined(CONFIG_64BIT)
 	return (dma_addr > 0x8fffffff) ? dma_addr : (dma_addr & 0x0fffffff);
 #else
diff --git a/arch/mips/loongson64/common/dma-swiotlb.c b/arch/mips/loongson=
64/common/dma-swiotlb.c
index 15388c24a504..0a02ea70e39f 100644
--- a/arch/mips/loongson64/common/dma-swiotlb.c
+++ b/arch/mips/loongson64/common/dma-swiotlb.c
@@ -80,7 +80,7 @@ static int loongson_dma_supported(struct device *dev, u64=
 mask)
 	return swiotlb_dma_supported(dev, mask);
 }
=20
-dma_addr_t phys_to_dma(struct device *dev, phys_addr_t paddr)
+dma_addr_t __phys_to_dma(struct device *dev, phys_addr_t paddr)
 {
 	long nid;
 #ifdef CONFIG_PHYS48_TO_HT40
@@ -92,7 +92,7 @@ dma_addr_t phys_to_dma(struct device *dev, phys_addr_t pa=
ddr)
 	return paddr;
 }
=20
-phys_addr_t dma_to_phys(struct device *dev, dma_addr_t daddr)
+phys_addr_t __dma_to_phys(struct device *dev, dma_addr_t daddr)
 {
 	long nid;
 #ifdef CONFIG_PHYS48_TO_HT40
diff --git a/arch/powerpc/include/asm/dma-direct.h b/arch/powerpc/include/a=
sm/dma-direct.h
index a5b59c765426..7702875aabb7 100644
--- a/arch/powerpc/include/asm/dma-direct.h
+++ b/arch/powerpc/include/asm/dma-direct.h
@@ -17,12 +17,12 @@ static inline bool dma_capable(struct device *dev, dma_=
addr_t addr, size_t size)
 	return addr + size - 1 <=3D *dev->dma_mask;
 }
=20
-static inline dma_addr_t phys_to_dma(struct device *dev, phys_addr_t paddr)
+static inline dma_addr_t __phys_to_dma(struct device *dev, phys_addr_t pad=
dr)
 {
 	return paddr + get_dma_offset(dev);
 }
=20
-static inline phys_addr_t dma_to_phys(struct device *dev, dma_addr_t daddr)
+static inline phys_addr_t __dma_to_phys(struct device *dev, dma_addr_t dad=
dr)
 {
 	return daddr - get_dma_offset(dev);
 }
diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 55ad01515075..3f2076aba40e 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -54,7 +54,6 @@ config X86
 	select ARCH_HAS_FORTIFY_SOURCE
 	select ARCH_HAS_GCOV_PROFILE_ALL
 	select ARCH_HAS_KCOV			if X86_64
-	select ARCH_HAS_PHYS_TO_DMA
 	select ARCH_HAS_PMEM_API		if X86_64
 	# Causing hangs/crashes, see the commit that added this change for detail=
s.
 	select ARCH_HAS_REFCOUNT
@@ -675,6 +674,7 @@ config X86_SUPPORTS_MEMORY_FAILURE
 config STA2X11
 	bool "STA2X11 Companion Chip Support"
 	depends on X86_32_NON_STANDARD && PCI
+	select ARCH_HAS_PHYS_TO_DMA
 	select X86_DEV_DMA_OPS
 	select X86_DMA_REMAP
 	select SWIOTLB
diff --git a/arch/x86/include/asm/dma-direct.h b/arch/x86/include/asm/dma-d=
irect.h
index 1295bc622ebe..1a19251eaac9 100644
--- a/arch/x86/include/asm/dma-direct.h
+++ b/arch/x86/include/asm/dma-direct.h
@@ -2,29 +2,8 @@
 #ifndef ASM_X86_DMA_DIRECT_H
 #define ASM_X86_DMA_DIRECT_H 1
=20
-#include <linux/mem_encrypt.h>
-
-#ifdef CONFIG_X86_DMA_REMAP /* Platform code defines bridge-specific code =
*/
 bool dma_capable(struct device *dev, dma_addr_t addr, size_t size);
-dma_addr_t phys_to_dma(struct device *dev, phys_addr_t paddr);
-phys_addr_t dma_to_phys(struct device *dev, dma_addr_t daddr);
-#else
-static inline bool dma_capable(struct device *dev, dma_addr_t addr, size_t=
 size)
-{
-	if (!dev->dma_mask)
-		return 0;
-
-	return addr + size - 1 <=3D *dev->dma_mask;
-}
-
-static inline dma_addr_t phys_to_dma(struct device *dev, phys_addr_t paddr)
-{
-	return __sme_set(paddr);
-}
+dma_addr_t __phys_to_dma(struct device *dev, phys_addr_t paddr);
+phys_addr_t __dma_to_phys(struct device *dev, dma_addr_t daddr);
=20
-static inline phys_addr_t dma_to_phys(struct device *dev, dma_addr_t daddr)
-{
-	return __sme_clr(daddr);
-}
-#endif /* CONFIG_X86_DMA_REMAP */
 #endif /* ASM_X86_DMA_DIRECT_H */
diff --git a/arch/x86/mm/mem_encrypt.c b/arch/x86/mm/mem_encrypt.c
index 1c786e751b49..93de36cc3dd9 100644
--- a/arch/x86/mm/mem_encrypt.c
+++ b/arch/x86/mm/mem_encrypt.c
@@ -200,58 +200,6 @@ void __init sme_early_init(void)
 		swiotlb_force =3D SWIOTLB_FORCE;
 }
=20
-static void *sev_alloc(struct device *dev, size_t size, dma_addr_t *dma_ha=
ndle,
-		       gfp_t gfp, unsigned long attrs)
-{
-	unsigned int order;
-	struct page *page;
-	void *vaddr =3D NULL;
-
-	order =3D get_order(size);
-	page =3D alloc_pages_node(dev_to_node(dev), gfp, order);
-	if (page) {
-		dma_addr_t addr;
-
-		/*
-		 * Since we will be clearing the encryption bit, check the
-		 * mask with it already cleared.
-		 */
-		addr =3D __sme_clr(phys_to_dma(dev, page_to_phys(page)));
-		if ((addr + size) > dev->coherent_dma_mask) {
-			__free_pages(page, get_order(size));
-		} else {
-			vaddr =3D page_address(page);
-			*dma_handle =3D addr;
-		}
-	}
-
-	if (!vaddr)
-		vaddr =3D swiotlb_alloc_coherent(dev, size, dma_handle, gfp);
-
-	if (!vaddr)
-		return NULL;
-
-	/* Clear the SME encryption bit for DMA use if not swiotlb area */
-	if (!is_swiotlb_buffer(dma_to_phys(dev, *dma_handle))) {
-		set_memory_decrypted((unsigned long)vaddr, 1 << order);
-		memset(vaddr, 0, PAGE_SIZE << order);
-		*dma_handle =3D __sme_clr(*dma_handle);
-	}
-
-	return vaddr;
-}
-
-static void sev_free(struct device *dev, size_t size, void *vaddr,
-		     dma_addr_t dma_handle, unsigned long attrs)
-{
-	/* Set the SME encryption bit for re-use if not swiotlb area */
-	if (!is_swiotlb_buffer(dma_to_phys(dev, dma_handle)))
-		set_memory_encrypted((unsigned long)vaddr,
-				     1 << get_order(size));
-
-	swiotlb_free_coherent(dev, size, vaddr, dma_handle);
-}
-
 static void __init __set_clr_pte_enc(pte_t *kpte, int level, bool enc)
 {
 	pgprot_t old_prot, new_prot;
@@ -404,20 +352,6 @@ bool sev_active(void)
 }
 EXPORT_SYMBOL_GPL(sev_active);
=20
-static const struct dma_map_ops sev_dma_ops =3D {
-	.alloc                  =3D sev_alloc,
-	.free                   =3D sev_free,
-	.map_page               =3D swiotlb_map_page,
-	.unmap_page             =3D swiotlb_unmap_page,
-	.map_sg                 =3D swiotlb_map_sg_attrs,
-	.unmap_sg               =3D swiotlb_unmap_sg_attrs,
-	.sync_single_for_cpu    =3D swiotlb_sync_single_for_cpu,
-	.sync_single_for_device =3D swiotlb_sync_single_for_device,
-	.sync_sg_for_cpu        =3D swiotlb_sync_sg_for_cpu,
-	.sync_sg_for_device     =3D swiotlb_sync_sg_for_device,
-	.mapping_error          =3D swiotlb_dma_mapping_error,
-};
-
 /* Architecture __weak replacement functions */
 void __init mem_encrypt_init(void)
 {
@@ -428,12 +362,11 @@ void __init mem_encrypt_init(void)
 	swiotlb_update_mem_attributes();
=20
 	/*
-	 * With SEV, DMA operations cannot use encryption. New DMA ops
-	 * are required in order to mark the DMA areas as decrypted or
-	 * to use bounce buffers.
+	 * With SEV, DMA operations cannot use encryption, we need to use
+	 * SWIOTLB to bounce buffer DMA operation.
 	 */
 	if (sev_active())
-		dma_ops =3D &sev_dma_ops;
+		dma_ops =3D &swiotlb_dma_ops;
=20
 	/*
 	 * With SEV, we need to unroll the rep string I/O instructions.
diff --git a/arch/x86/pci/sta2x11-fixup.c b/arch/x86/pci/sta2x11-fixup.c
index 4b69b008d5aa..15ad3025e439 100644
--- a/arch/x86/pci/sta2x11-fixup.c
+++ b/arch/x86/pci/sta2x11-fixup.c
@@ -243,11 +243,11 @@ bool dma_capable(struct device *dev, dma_addr_t addr,=
 size_t size)
 }
=20
 /**
- * phys_to_dma - Return the DMA AMBA address used for this STA2x11 device
+ * __phys_to_dma - Return the DMA AMBA address used for this STA2x11 device
  * @dev: device for a PCI device
  * @paddr: Physical address
  */
-dma_addr_t phys_to_dma(struct device *dev, phys_addr_t paddr)
+dma_addr_t __phys_to_dma(struct device *dev, phys_addr_t paddr)
 {
 	if (dev->dma_ops !=3D &sta2x11_dma_ops)
 		return paddr;
@@ -259,7 +259,7 @@ dma_addr_t phys_to_dma(struct device *dev, phys_addr_t =
paddr)
  * @dev: device for a PCI device
  * @daddr: STA2x11 AMBA DMA address
  */
-phys_addr_t dma_to_phys(struct device *dev, dma_addr_t daddr)
+phys_addr_t __dma_to_phys(struct device *dev, dma_addr_t daddr)
 {
 	if (dev->dma_ops !=3D &sta2x11_dma_ops)
 		return daddr;
diff --git a/include/linux/dma-direct.h b/include/linux/dma-direct.h
index bcdb1a3e4b1f..e7f5ac7efcb5 100644
--- a/include/linux/dma-direct.h
+++ b/include/linux/dma-direct.h
@@ -3,18 +3,19 @@
 #define _LINUX_DMA_DIRECT_H 1
=20
 #include <linux/dma-mapping.h>
+#include <linux/mem_encrypt.h>
=20
 #ifdef CONFIG_ARCH_HAS_PHYS_TO_DMA
 #include <asm/dma-direct.h>
 #else
-static inline dma_addr_t phys_to_dma(struct device *dev, phys_addr_t paddr)
+static inline dma_addr_t __phys_to_dma(struct device *dev, phys_addr_t pad=
dr)
 {
 	dma_addr_t dev_addr =3D (dma_addr_t)paddr;
=20
 	return dev_addr - ((dma_addr_t)dev->dma_pfn_offset << PAGE_SHIFT);
 }
=20
-static inline phys_addr_t dma_to_phys(struct device *dev, dma_addr_t dev_a=
ddr)
+static inline phys_addr_t __dma_to_phys(struct device *dev, dma_addr_t dev=
_addr)
 {
 	phys_addr_t paddr =3D (phys_addr_t)dev_addr;
=20
@@ -30,6 +31,24 @@ static inline bool dma_capable(struct device *dev, dma_a=
ddr_t addr, size_t size)
 }
 #endif /* !CONFIG_ARCH_HAS_PHYS_TO_DMA */
=20
+/*
+ * If memory encryptition is supported, phys_to_dma will set the memory
+ * encryption bit in the DMA address, and dma_to_phys will clear it.
+ * The raw __phys_to_dma and __dma_to_phys should only be used on
+ * non-encrypted memory for special occasions like DMA coherent buffers.
+ */
+static __always_inline dma_addr_t phys_to_dma(struct device *dev,
+		phys_addr_t paddr)
+{
+	return __sme_set(__phys_to_dma(dev, paddr));
+}
+
+static __always_inline phys_addr_t dma_to_phys(struct device *dev,
+		dma_addr_t daddr)
+{
+	return __sme_clr(__dma_to_phys(dev, daddr));
+}
+
 #ifdef CONFIG_ARCH_HAS_DMA_MARK_CLEAN
 void dma_mark_clean(void *addr, size_t size);
 #else
diff --git a/lib/dma-direct.c b/lib/dma-direct.c
index 5bb289483efc..2e2dcb1ae0a1 100644
--- a/lib/dma-direct.c
+++ b/lib/dma-direct.c
@@ -9,6 +9,7 @@
 #include <linux/scatterlist.h>
 #include <linux/dma-contiguous.h>
 #include <linux/pfn.h>
+#include <linux/set_memory.h>
=20
 #define DIRECT_MAPPING_ERROR		0
=20
@@ -36,9 +37,13 @@ check_addr(struct device *dev, dma_addr_t dma_addr, size=
_t size,
 	return true;
 }
=20
+/*
+ * Since we will be clearing the encryption bit, check the mask with it al=
ready
+ * cleared.
+ */
 static bool dma_coherent_ok(struct device *dev, phys_addr_t phys, size_t s=
ize)
 {
-	return phys_to_dma(dev, phys) + size <=3D dev->coherent_dma_mask;
+	return __phys_to_dma(dev, phys) + size <=3D dev->coherent_dma_mask;
 }
=20
 void *dma_direct_alloc(struct device *dev, size_t size, dma_addr_t *dma_ha=
ndle,
@@ -47,6 +52,7 @@ void *dma_direct_alloc(struct device *dev, size_t size, d=
ma_addr_t *dma_handle,
 	unsigned int count =3D PAGE_ALIGN(size) >> PAGE_SHIFT;
 	int page_order =3D get_order(size);
 	struct page *page =3D NULL;
+	void *ret;
=20
 	/* GFP_DMA32 and GFP_DMA are no ops without the corresponding zones: */
 	if (dev->coherent_dma_mask < DMA_BIT_MASK(32))
@@ -79,19 +85,27 @@ void *dma_direct_alloc(struct device *dev, size_t size,=
 dma_addr_t *dma_handle,
=20
 	if (!page)
 		return NULL;
+	*dma_handle =3D __phys_to_dma(dev, page_to_phys(page));
+	ret =3D page_address(page);
=20
-	*dma_handle =3D phys_to_dma(dev, page_to_phys(page));
-	memset(page_address(page), 0, size);
-	return page_address(page);
+	/* Clear the memory encryption bit */
+	set_memory_decrypted((unsigned long)ret, page_order);
+
+	memset(ret, 0, size);
+	return ret;
 }
=20
 void dma_direct_free(struct device *dev, size_t size, void *cpu_addr,
 		dma_addr_t dma_addr, unsigned long attrs)
 {
 	unsigned int count =3D PAGE_ALIGN(size) >> PAGE_SHIFT;
+	unsigned int page_order =3D get_order(size);
+
+	/* Set the SME encryption bit for re-use */
+	set_memory_encrypted((unsigned long)cpu_addr, 1 << page_order);
=20
 	if (!dma_release_from_contiguous(dev, virt_to_page(cpu_addr), count))
-		free_pages((unsigned long)cpu_addr, get_order(size));
+		free_pages((unsigned long)cpu_addr, page_order);
 }
=20
 static dma_addr_t dma_direct_map_page(struct device *dev, struct page *pag=
e,
diff --git a/lib/swiotlb.c b/lib/swiotlb.c
index 905eea6353a3..85b2ad9299e3 100644
--- a/lib/swiotlb.c
+++ b/lib/swiotlb.c
@@ -158,13 +158,6 @@ unsigned long swiotlb_size_or_default(void)
=20
 void __weak swiotlb_set_mem_attributes(void *vaddr, unsigned long size) { }
=20
-/* For swiotlb, clear memory encryption mask from dma addresses */
-static dma_addr_t swiotlb_phys_to_dma(struct device *hwdev,
-				      phys_addr_t address)
-{
-	return __sme_clr(phys_to_dma(hwdev, address));
-}
-
 /* Note that this doesn't work with highmem page */
 static dma_addr_t swiotlb_virt_to_bus(struct device *hwdev,
 				      volatile void *address)
@@ -623,7 +616,7 @@ map_single(struct device *hwdev, phys_addr_t phys, size=
_t size,
 		return SWIOTLB_MAP_ERROR;
 	}
=20
-	start_dma_addr =3D swiotlb_phys_to_dma(hwdev, io_tlb_start);
+	start_dma_addr =3D __phys_to_dma(hwdev, io_tlb_start);
 	return swiotlb_tbl_map_single(hwdev, start_dma_addr, phys, size,
 				      dir, attrs);
 }
@@ -718,12 +711,12 @@ swiotlb_alloc_buffer(struct device *dev, size_t size,=
 dma_addr_t *dma_handle)
 		goto out_warn;
=20
 	phys_addr =3D swiotlb_tbl_map_single(dev,
-			swiotlb_phys_to_dma(dev, io_tlb_start),
+			__phys_to_dma(dev, io_tlb_start),
 			0, size, DMA_FROM_DEVICE, 0);
 	if (phys_addr =3D SWIOTLB_MAP_ERROR)
 		goto out_warn;
=20
-	*dma_handle =3D swiotlb_phys_to_dma(dev, phys_addr);
+	*dma_handle =3D __phys_to_dma(dev, phys_addr);
=20
 	/* Confirm address can be DMA'd by device */
 	if (*dma_handle + size - 1 > dev->coherent_dma_mask)
@@ -861,10 +854,10 @@ dma_addr_t swiotlb_map_page(struct device *dev, struc=
t page *page,
 	map =3D map_single(dev, phys, size, dir, attrs);
 	if (map =3D SWIOTLB_MAP_ERROR) {
 		swiotlb_full(dev, size, dir, 1);
-		return swiotlb_phys_to_dma(dev, io_tlb_overflow_buffer);
+		return __phys_to_dma(dev, io_tlb_overflow_buffer);
 	}
=20
-	dev_addr =3D swiotlb_phys_to_dma(dev, map);
+	dev_addr =3D __phys_to_dma(dev, map);
=20
 	/* Ensure that the address returned is DMA'ble */
 	if (dma_capable(dev, dev_addr, size))
@@ -873,7 +866,7 @@ dma_addr_t swiotlb_map_page(struct device *dev, struct =
page *page,
 	attrs |=3D DMA_ATTR_SKIP_CPU_SYNC;
 	swiotlb_tbl_unmap_single(dev, map, size, dir, attrs);
=20
-	return swiotlb_phys_to_dma(dev, io_tlb_overflow_buffer);
+	return __phys_to_dma(dev, io_tlb_overflow_buffer);
 }
 EXPORT_SYMBOL_GPL(swiotlb_map_page);
=20
@@ -1007,7 +1000,7 @@ swiotlb_map_sg_attrs(struct device *hwdev, struct sca=
tterlist *sgl, int nelems,
 				sg_dma_len(sgl) =3D 0;
 				return 0;
 			}
-			sg->dma_address =3D swiotlb_phys_to_dma(hwdev, map);
+			sg->dma_address =3D __phys_to_dma(hwdev, map);
 		} else
 			sg->dma_address =3D dev_addr;
 		sg_dma_len(sg) =3D sg->length;
@@ -1075,7 +1068,7 @@ EXPORT_SYMBOL(swiotlb_sync_sg_for_device);
 int
 swiotlb_dma_mapping_error(struct device *hwdev, dma_addr_t dma_addr)
 {
-	return (dma_addr =3D swiotlb_phys_to_dma(hwdev, io_tlb_overflow_buffer));
+	return (dma_addr =3D __phys_to_dma(hwdev, io_tlb_overflow_buffer));
 }
 EXPORT_SYMBOL(swiotlb_dma_mapping_error);
=20
@@ -1088,7 +1081,7 @@ EXPORT_SYMBOL(swiotlb_dma_mapping_error);
 int
 swiotlb_dma_supported(struct device *hwdev, u64 mask)
 {
-	return swiotlb_phys_to_dma(hwdev, io_tlb_end - 1) <=3D mask;
+	return __phys_to_dma(hwdev, io_tlb_end - 1) <=3D mask;
 }
 EXPORT_SYMBOL(swiotlb_dma_supported);
=20
--=20
2.14.2

