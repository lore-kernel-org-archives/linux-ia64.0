From: Christoph Hellwig <hch@lst.de>
Date: Fri, 29 Dec 2017 08:19:03 +0000
Subject: [PATCH 59/67] unicore32: use generic swiotlb_ops
Message-Id: <20171229081911.2802-60-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20171229081911.2802-1-hch@lst.de>
In-Reply-To: <20171229081911.2802-1-hch-jcswGhMUV9g@public.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: linux-alpha-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-snps-arc-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, adi-buildroot-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, linux-c6x-dev-jPsnJVOj+W6hPH1hqNUYSQ@public.gmane.org, linux-cris-kernel-VrBV9hrLPhE@public.gmane.org, linux-hexagon-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-m68k-cunTk1MwBs8S/qaLPR03pWD2FQJk+8+b@public.gmane.org, linux-metag-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Michal Simek <monstr-pSz03upnqPeHXe+LvDLADg@public.gmane.org>, linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org, linux-parisc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, patches-q3qR2WxjNRFS9aJRtSZj7A@public.gmane.org, linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-sh-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sparclinux-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Guan Xuetao <gxt-TG0Ac1+ktVePQbnJrJN+5g@public.gmane.org>, x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, linux-arch-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org

These are identical to the unicore32 ops, and would also support CMA
if enabled on unicore32.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/unicore32/include/asm/dma-mapping.h |  9 +-----
 arch/unicore32/mm/Kconfig                |  1 +
 arch/unicore32/mm/Makefile               |  2 --
 arch/unicore32/mm/dma-swiotlb.c          | 48 --------------------------------
 4 files changed, 2 insertions(+), 58 deletions(-)
 delete mode 100644 arch/unicore32/mm/dma-swiotlb.c

diff --git a/arch/unicore32/include/asm/dma-mapping.h b/arch/unicore32/include/asm/dma-mapping.h
index f2bfec273aa7..790bc2ef4af2 100644
--- a/arch/unicore32/include/asm/dma-mapping.h
+++ b/arch/unicore32/include/asm/dma-mapping.h
@@ -12,18 +12,11 @@
 #ifndef __UNICORE_DMA_MAPPING_H__
 #define __UNICORE_DMA_MAPPING_H__
 
-#ifdef __KERNEL__
-
-#include <linux/mm_types.h>
-#include <linux/scatterlist.h>
 #include <linux/swiotlb.h>
 
-extern const struct dma_map_ops swiotlb_dma_map_ops;
-
 static inline const struct dma_map_ops *get_arch_dma_ops(struct bus_type *bus)
 {
-	return &swiotlb_dma_map_ops;
+	return &swiotlb_dma_ops;
 }
 
-#endif /* __KERNEL__ */
 #endif
diff --git a/arch/unicore32/mm/Kconfig b/arch/unicore32/mm/Kconfig
index c256460cd363..e9154a59d561 100644
--- a/arch/unicore32/mm/Kconfig
+++ b/arch/unicore32/mm/Kconfig
@@ -42,6 +42,7 @@ config CPU_TLB_SINGLE_ENTRY_DISABLE
 
 config SWIOTLB
 	def_bool y
+	select DMA_DIRECT_OPS
 
 config IOMMU_HELPER
 	def_bool SWIOTLB
diff --git a/arch/unicore32/mm/Makefile b/arch/unicore32/mm/Makefile
index 681c0ef5ec9e..8106260583ab 100644
--- a/arch/unicore32/mm/Makefile
+++ b/arch/unicore32/mm/Makefile
@@ -6,8 +6,6 @@
 obj-y				:= extable.o fault.o init.o pgd.o mmu.o
 obj-y				+= flush.o ioremap.o
 
-obj-$(CONFIG_SWIOTLB)		+= dma-swiotlb.o
-
 obj-$(CONFIG_MODULES)		+= proc-syms.o
 
 obj-$(CONFIG_ALIGNMENT_TRAP)	+= alignment.o
diff --git a/arch/unicore32/mm/dma-swiotlb.c b/arch/unicore32/mm/dma-swiotlb.c
deleted file mode 100644
index 525413d6690e..000000000000
--- a/arch/unicore32/mm/dma-swiotlb.c
+++ /dev/null
@@ -1,48 +0,0 @@
-/*
- * Contains routines needed to support swiotlb for UniCore32.
- *
- * Copyright (C) 2010 Guan Xuetao
- *
- * This program is free software; you can redistribute  it and/or modify it
- * under  the terms of  the GNU General  Public License as published by the
- * Free Software Foundation;  either version 2 of the  License, or (at your
- * option) any later version.
- */
-#include <linux/pci.h>
-#include <linux/cache.h>
-#include <linux/module.h>
-#include <linux/dma-mapping.h>
-#include <linux/swiotlb.h>
-#include <linux/bootmem.h>
-
-#include <asm/dma.h>
-
-static void *unicore_swiotlb_alloc_coherent(struct device *dev, size_t size,
-					    dma_addr_t *dma_handle, gfp_t flags,
-					    unsigned long attrs)
-{
-	return swiotlb_alloc_coherent(dev, size, dma_handle, flags);
-}
-
-static void unicore_swiotlb_free_coherent(struct device *dev, size_t size,
-					  void *vaddr, dma_addr_t dma_addr,
-					  unsigned long attrs)
-{
-	swiotlb_free_coherent(dev, size, vaddr, dma_addr);
-}
-
-const struct dma_map_ops swiotlb_dma_map_ops = {
-	.alloc = unicore_swiotlb_alloc_coherent,
-	.free = unicore_swiotlb_free_coherent,
-	.map_sg = swiotlb_map_sg_attrs,
-	.unmap_sg = swiotlb_unmap_sg_attrs,
-	.dma_supported = swiotlb_dma_supported,
-	.map_page = swiotlb_map_page,
-	.unmap_page = swiotlb_unmap_page,
-	.sync_single_for_cpu = swiotlb_sync_single_for_cpu,
-	.sync_single_for_device = swiotlb_sync_single_for_device,
-	.sync_sg_for_cpu = swiotlb_sync_sg_for_cpu,
-	.sync_sg_for_device = swiotlb_sync_sg_for_device,
-	.mapping_error = swiotlb_dma_mapping_error,
-};
-EXPORT_SYMBOL(swiotlb_dma_map_ops);
-- 
2.14.2

