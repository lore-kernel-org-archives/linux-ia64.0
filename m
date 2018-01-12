From: Christoph Hellwig <hch@lst.de>
Date: Fri, 12 Jan 2018 08:42:11 +0000
Subject: [PATCH 13/34] dma-mapping: move dma_mark_clean to dma-direct.h
Message-Id: <20180112084232.2857-14-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180112084232.2857-1-hch@lst.de>
In-Reply-To: <20180112084232.2857-1-hch-jcswGhMUV9g@public.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-sh-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sparclinux-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Guan Xuetao <gxt-TG0Ac1+ktVePQbnJrJN+5g@public.gmane.org>, linux-arch-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-c6x-dev-jPsnJVOj+W6hPH1hqNUYSQ@public.gmane.org, linux-hexagon-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, Konrad Rzeszutek Wilk <konrad-Gq0aWv8utHQdnm+yROfE0A@public.gmane.org>, linux-snps-arc-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-m68k-cunTk1MwBs8S/qaLPR03pWD2FQJk+8+b@public.gmane.org, patches-q3qR2WxjNRFS9aJRtSZj7A@public.gmane.org, linux-metag-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, Michal Simek <monstr-pSz03upnqPeHXe+LvDLADg@public.gmane.org>, linux-parisc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-cris-kernel-VrBV9hrLPhE@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-alpha-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org

And unlike the other helpers we don't require a <asm/dma-direct.h> as
this helper is a special case for ia64 only, and this keeps it as
simple as possible.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/arm/include/asm/dma-mapping.h       | 2 --
 arch/arm64/include/asm/dma-mapping.h     | 4 ----
 arch/ia64/Kconfig                        | 1 +
 arch/ia64/include/asm/dma.h              | 2 --
 arch/mips/include/asm/dma-mapping.h      | 2 --
 arch/powerpc/include/asm/swiotlb.h       | 2 --
 arch/tile/include/asm/dma-mapping.h      | 2 --
 arch/unicore32/include/asm/dma-mapping.h | 2 --
 arch/x86/include/asm/swiotlb.h           | 2 --
 include/linux/dma-direct.h               | 9 +++++++++
 10 files changed, 10 insertions(+), 18 deletions(-)

diff --git a/arch/arm/include/asm/dma-mapping.h b/arch/arm/include/asm/dma-mapping.h
index 5fb1b7fbdfbe..e5d9020c9ee1 100644
--- a/arch/arm/include/asm/dma-mapping.h
+++ b/arch/arm/include/asm/dma-mapping.h
@@ -109,8 +109,6 @@ static inline bool is_device_dma_coherent(struct device *dev)
 	return dev->archdata.dma_coherent;
 }
 
-static inline void dma_mark_clean(void *addr, size_t size) { }
-
 /**
  * arm_dma_alloc - allocate consistent memory for DMA
  * @dev: valid struct device pointer, or NULL for ISA and EISA-like devices
diff --git a/arch/arm64/include/asm/dma-mapping.h b/arch/arm64/include/asm/dma-mapping.h
index 400fa67d3b5a..b7847eb8a7bb 100644
--- a/arch/arm64/include/asm/dma-mapping.h
+++ b/arch/arm64/include/asm/dma-mapping.h
@@ -50,9 +50,5 @@ static inline bool is_device_dma_coherent(struct device *dev)
 	return dev->archdata.dma_coherent;
 }
 
-static inline void dma_mark_clean(void *addr, size_t size)
-{
-}
-
 #endif	/* __KERNEL__ */
 #endif	/* __ASM_DMA_MAPPING_H */
diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
index 49583c5a5d44..4d18fca885ee 100644
--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
@@ -33,6 +33,7 @@ config IA64
 	select HAVE_MEMBLOCK
 	select HAVE_MEMBLOCK_NODE_MAP
 	select HAVE_VIRT_CPU_ACCOUNTING
+	select ARCH_HAS_DMA_MARK_CLEAN
 	select ARCH_HAS_SG_CHAIN
 	select VIRT_TO_BUS
 	select ARCH_DISCARD_MEMBLOCK
diff --git a/arch/ia64/include/asm/dma.h b/arch/ia64/include/asm/dma.h
index 186850eec934..23604d6a2cb2 100644
--- a/arch/ia64/include/asm/dma.h
+++ b/arch/ia64/include/asm/dma.h
@@ -20,6 +20,4 @@ extern unsigned long MAX_DMA_ADDRESS;
 
 #define free_dma(x)
 
-void dma_mark_clean(void *addr, size_t size);
-
 #endif /* _ASM_IA64_DMA_H */
diff --git a/arch/mips/include/asm/dma-mapping.h b/arch/mips/include/asm/dma-mapping.h
index 676c14cfc580..886e75a383f2 100644
--- a/arch/mips/include/asm/dma-mapping.h
+++ b/arch/mips/include/asm/dma-mapping.h
@@ -17,8 +17,6 @@ static inline const struct dma_map_ops *get_arch_dma_ops(struct bus_type *bus)
 	return mips_dma_map_ops;
 }
 
-static inline void dma_mark_clean(void *addr, size_t size) {}
-
 #define arch_setup_dma_ops arch_setup_dma_ops
 static inline void arch_setup_dma_ops(struct device *dev, u64 dma_base,
 				      u64 size, const struct iommu_ops *iommu,
diff --git a/arch/powerpc/include/asm/swiotlb.h b/arch/powerpc/include/asm/swiotlb.h
index 01d45a5fd00b..9341ee804d19 100644
--- a/arch/powerpc/include/asm/swiotlb.h
+++ b/arch/powerpc/include/asm/swiotlb.h
@@ -15,8 +15,6 @@
 
 extern const struct dma_map_ops swiotlb_dma_ops;
 
-static inline void dma_mark_clean(void *addr, size_t size) {}
-
 extern unsigned int ppc_swiotlb_enable;
 int __init swiotlb_setup_bus_notifier(void);
 
diff --git a/arch/tile/include/asm/dma-mapping.h b/arch/tile/include/asm/dma-mapping.h
index 75b8aaa4e70b..d25fce101fc0 100644
--- a/arch/tile/include/asm/dma-mapping.h
+++ b/arch/tile/include/asm/dma-mapping.h
@@ -44,8 +44,6 @@ static inline void set_dma_offset(struct device *dev, dma_addr_t off)
 	dev->archdata.dma_offset = off;
 }
 
-static inline void dma_mark_clean(void *addr, size_t size) {}
-
 #define HAVE_ARCH_DMA_SET_MASK 1
 int dma_set_mask(struct device *dev, u64 mask);
 
diff --git a/arch/unicore32/include/asm/dma-mapping.h b/arch/unicore32/include/asm/dma-mapping.h
index 5cb250bf2d8c..f2bfec273aa7 100644
--- a/arch/unicore32/include/asm/dma-mapping.h
+++ b/arch/unicore32/include/asm/dma-mapping.h
@@ -25,7 +25,5 @@ static inline const struct dma_map_ops *get_arch_dma_ops(struct bus_type *bus)
 	return &swiotlb_dma_map_ops;
 }
 
-static inline void dma_mark_clean(void *addr, size_t size) {}
-
 #endif /* __KERNEL__ */
 #endif
diff --git a/arch/x86/include/asm/swiotlb.h b/arch/x86/include/asm/swiotlb.h
index bdf9aed40403..1c6a6cb230ff 100644
--- a/arch/x86/include/asm/swiotlb.h
+++ b/arch/x86/include/asm/swiotlb.h
@@ -28,8 +28,6 @@ static inline void pci_swiotlb_late_init(void)
 }
 #endif
 
-static inline void dma_mark_clean(void *addr, size_t size) {}
-
 extern void *x86_swiotlb_alloc_coherent(struct device *hwdev, size_t size,
 					dma_addr_t *dma_handle, gfp_t flags,
 					unsigned long attrs);
diff --git a/include/linux/dma-direct.h b/include/linux/dma-direct.h
index 2cc1b6558944..10e924b7cba7 100644
--- a/include/linux/dma-direct.h
+++ b/include/linux/dma-direct.h
@@ -29,4 +29,13 @@ static inline bool dma_capable(struct device *dev, dma_addr_t addr, size_t size)
 	return addr + size - 1 <= *dev->dma_mask;
 }
 #endif /* !CONFIG_ARCH_HAS_PHYS_TO_DMA */
+
+#ifdef CONFIG_ARCH_HAS_DMA_MARK_CLEAN
+void dma_mark_clean(void *addr, size_t size);
+#else
+static inline void dma_mark_clean(void *addr, size_t size)
+{
+}
+#endif /* CONFIG_ARCH_HAS_DMA_MARK_CLEAN */
+
 #endif /* _LINUX_DMA_DIRECT_H */
-- 
2.14.2

