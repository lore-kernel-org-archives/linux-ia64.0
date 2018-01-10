From: Christoph Hellwig <hch@lst.de>
Date: Wed, 10 Jan 2018 08:00:14 +0000
Subject: [PATCH 20/33] dma-mapping: clear harmful GFP_* flags in common code
Message-Id: <20180110080027.13879-21-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180110080027.13879-1-hch@lst.de>
In-Reply-To: <20180110080027.13879-1-hch-jcswGhMUV9g@public.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-sh-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sparclinux-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Guan Xuetao <gxt-TG0Ac1+ktVePQbnJrJN+5g@public.gmane.org>, linux-arch-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-c6x-dev-jPsnJVOj+W6hPH1hqNUYSQ@public.gmane.org, linux-hexagon-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, Konrad Rzeszutek Wilk <konrad-Gq0aWv8utHQdnm+yROfE0A@public.gmane.org>, linux-snps-arc-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-m68k-cunTk1MwBs8S/qaLPR03pWD2FQJk+8+b@public.gmane.org, patches-q3qR2WxjNRFS9aJRtSZj7A@public.gmane.org, linux-metag-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, Michal Simek <monstr-pSz03upnqPeHXe+LvDLADg@public.gmane.org>, linux-parisc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-cris-kernel-VrBV9hrLPhE@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-alpha-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org

Lift the code from x86 so that we behave consistently.  In the future we
should probably warn if any of these is set.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Acked-by: Jesper Nilsson <jesper.nilsson@axis.com>
Acked-by: Geert Uytterhoeven <geert@linux-m68k.org> [m68k]
---
 arch/cris/arch-v32/drivers/pci/dma.c      | 3 ---
 arch/h8300/kernel/dma.c                   | 3 ---
 arch/m68k/kernel/dma.c                    | 2 --
 arch/mips/cavium-octeon/dma-octeon.c      | 3 ---
 arch/mips/loongson64/common/dma-swiotlb.c | 3 ---
 arch/mips/mm/dma-default.c                | 3 ---
 arch/mips/netlogic/common/nlm-dma.c       | 3 ---
 arch/mn10300/mm/dma-alloc.c               | 3 ---
 arch/nios2/mm/dma-mapping.c               | 3 ---
 arch/powerpc/kernel/dma.c                 | 3 ---
 arch/x86/kernel/pci-dma.c                 | 2 --
 include/linux/dma-mapping.h               | 7 +++++++
 12 files changed, 7 insertions(+), 31 deletions(-)

diff --git a/arch/cris/arch-v32/drivers/pci/dma.c b/arch/cris/arch-v32/drivers/pci/dma.c
index dbbd3816cc0b..8c3802244ef3 100644
--- a/arch/cris/arch-v32/drivers/pci/dma.c
+++ b/arch/cris/arch-v32/drivers/pci/dma.c
@@ -22,9 +22,6 @@ static void *v32_dma_alloc(struct device *dev, size_t size,
 {
 	void *ret;
 
-	/* ignore region specifiers */
-	gfp &= ~(__GFP_DMA | __GFP_HIGHMEM);
-
 	if (dev = NULL || (dev->coherent_dma_mask < 0xffffffff))
 		gfp |= GFP_DMA;
 
diff --git a/arch/h8300/kernel/dma.c b/arch/h8300/kernel/dma.c
index 225dd0a188dc..d44ba5db4ac3 100644
--- a/arch/h8300/kernel/dma.c
+++ b/arch/h8300/kernel/dma.c
@@ -16,9 +16,6 @@ static void *dma_alloc(struct device *dev, size_t size,
 {
 	void *ret;
 
-	/* ignore region specifiers */
-	gfp &= ~(__GFP_DMA | __GFP_HIGHMEM);
-
 	if (dev = NULL || (*dev->dma_mask < 0xffffffff))
 		gfp |= GFP_DMA;
 	ret = (void *)__get_free_pages(gfp, get_order(size));
diff --git a/arch/m68k/kernel/dma.c b/arch/m68k/kernel/dma.c
index 87ef73a93856..c01b9b8f97bf 100644
--- a/arch/m68k/kernel/dma.c
+++ b/arch/m68k/kernel/dma.c
@@ -76,8 +76,6 @@ static void *m68k_dma_alloc(struct device *dev, size_t size,
 		dma_addr_t *dma_handle, gfp_t gfp, unsigned long attrs)
 {
 	void *ret;
-	/* ignore region specifiers */
-	gfp &= ~(__GFP_DMA | __GFP_HIGHMEM);
 
 	if (dev = NULL || (*dev->dma_mask < 0xffffffff))
 		gfp |= GFP_DMA;
diff --git a/arch/mips/cavium-octeon/dma-octeon.c b/arch/mips/cavium-octeon/dma-octeon.c
index c64bd87f0b6e..5baf79fce643 100644
--- a/arch/mips/cavium-octeon/dma-octeon.c
+++ b/arch/mips/cavium-octeon/dma-octeon.c
@@ -161,9 +161,6 @@ static void *octeon_dma_alloc_coherent(struct device *dev, size_t size,
 {
 	void *ret;
 
-	/* ignore region specifiers */
-	gfp &= ~(__GFP_DMA | __GFP_DMA32 | __GFP_HIGHMEM);
-
 	if (IS_ENABLED(CONFIG_ZONE_DMA) && dev = NULL)
 		gfp |= __GFP_DMA;
 	else if (IS_ENABLED(CONFIG_ZONE_DMA) &&
diff --git a/arch/mips/loongson64/common/dma-swiotlb.c b/arch/mips/loongson64/common/dma-swiotlb.c
index ef07740cee61..15388c24a504 100644
--- a/arch/mips/loongson64/common/dma-swiotlb.c
+++ b/arch/mips/loongson64/common/dma-swiotlb.c
@@ -15,9 +15,6 @@ static void *loongson_dma_alloc_coherent(struct device *dev, size_t size,
 {
 	void *ret;
 
-	/* ignore region specifiers */
-	gfp &= ~(__GFP_DMA | __GFP_DMA32 | __GFP_HIGHMEM);
-
 	if ((IS_ENABLED(CONFIG_ISA) && dev = NULL) ||
 	    (IS_ENABLED(CONFIG_ZONE_DMA) &&
 	     dev->coherent_dma_mask < DMA_BIT_MASK(32)))
diff --git a/arch/mips/mm/dma-default.c b/arch/mips/mm/dma-default.c
index e3e94d05f0fd..237532e89919 100644
--- a/arch/mips/mm/dma-default.c
+++ b/arch/mips/mm/dma-default.c
@@ -93,9 +93,6 @@ static gfp_t massage_gfp_flags(const struct device *dev, gfp_t gfp)
 {
 	gfp_t dma_flag;
 
-	/* ignore region specifiers */
-	gfp &= ~(__GFP_DMA | __GFP_DMA32 | __GFP_HIGHMEM);
-
 #ifdef CONFIG_ISA
 	if (dev = NULL)
 		dma_flag = __GFP_DMA;
diff --git a/arch/mips/netlogic/common/nlm-dma.c b/arch/mips/netlogic/common/nlm-dma.c
index 0ec9d9da6d51..49c975b6aa28 100644
--- a/arch/mips/netlogic/common/nlm-dma.c
+++ b/arch/mips/netlogic/common/nlm-dma.c
@@ -47,9 +47,6 @@ static char *nlm_swiotlb;
 static void *nlm_dma_alloc_coherent(struct device *dev, size_t size,
 	dma_addr_t *dma_handle, gfp_t gfp, unsigned long attrs)
 {
-	/* ignore region specifiers */
-	gfp &= ~(__GFP_DMA | __GFP_DMA32 | __GFP_HIGHMEM);
-
 #ifdef CONFIG_ZONE_DMA32
 	if (dev->coherent_dma_mask <= DMA_BIT_MASK(32))
 		gfp |= __GFP_DMA32;
diff --git a/arch/mn10300/mm/dma-alloc.c b/arch/mn10300/mm/dma-alloc.c
index 86108d2496b3..e3910d4db102 100644
--- a/arch/mn10300/mm/dma-alloc.c
+++ b/arch/mn10300/mm/dma-alloc.c
@@ -37,9 +37,6 @@ static void *mn10300_dma_alloc(struct device *dev, size_t size,
 		goto done;
 	}
 
-	/* ignore region specifiers */
-	gfp &= ~(__GFP_DMA | __GFP_HIGHMEM);
-
 	if (dev = NULL || dev->coherent_dma_mask < 0xffffffff)
 		gfp |= GFP_DMA;
 
diff --git a/arch/nios2/mm/dma-mapping.c b/arch/nios2/mm/dma-mapping.c
index 7040c1adbb5e..4be815519dd4 100644
--- a/arch/nios2/mm/dma-mapping.c
+++ b/arch/nios2/mm/dma-mapping.c
@@ -63,9 +63,6 @@ static void *nios2_dma_alloc(struct device *dev, size_t size,
 {
 	void *ret;
 
-	/* ignore region specifiers */
-	gfp &= ~(__GFP_DMA | __GFP_HIGHMEM);
-
 	/* optimized page clearing */
 	gfp |= __GFP_ZERO;
 
diff --git a/arch/powerpc/kernel/dma.c b/arch/powerpc/kernel/dma.c
index 6d5d04ccf3b4..76079841d3d0 100644
--- a/arch/powerpc/kernel/dma.c
+++ b/arch/powerpc/kernel/dma.c
@@ -105,9 +105,6 @@ void *__dma_nommu_alloc_coherent(struct device *dev, size_t size,
 	};
 #endif /* CONFIG_FSL_SOC */
 
-	/* ignore region specifiers */
-	flag  &= ~(__GFP_HIGHMEM);
-
 	page = alloc_pages_node(node, flag, get_order(size));
 	if (page = NULL)
 		return NULL;
diff --git a/arch/x86/kernel/pci-dma.c b/arch/x86/kernel/pci-dma.c
index 8439e6de6156..61a8f1cb3829 100644
--- a/arch/x86/kernel/pci-dma.c
+++ b/arch/x86/kernel/pci-dma.c
@@ -87,7 +87,6 @@ void *dma_generic_alloc_coherent(struct device *dev, size_t size,
 
 	dma_mask = dma_alloc_coherent_mask(dev, flag);
 
-	flag &= ~__GFP_ZERO;
 again:
 	page = NULL;
 	/* CMA can be used only in the context which permits sleeping */
@@ -139,7 +138,6 @@ bool arch_dma_alloc_attrs(struct device **dev, gfp_t *gfp)
 	if (!*dev)
 		*dev = &x86_dma_fallback_dev;
 
-	*gfp &= ~(__GFP_DMA | __GFP_HIGHMEM | __GFP_DMA32);
 	*gfp = dma_alloc_coherent_gfp_flags(*dev, *gfp);
 
 	if (!is_device_dma_capable(*dev))
diff --git a/include/linux/dma-mapping.h b/include/linux/dma-mapping.h
index 9f28b2fa329e..88bcb1a8211d 100644
--- a/include/linux/dma-mapping.h
+++ b/include/linux/dma-mapping.h
@@ -518,6 +518,13 @@ static inline void *dma_alloc_attrs(struct device *dev, size_t size,
 	if (dma_alloc_from_dev_coherent(dev, size, dma_handle, &cpu_addr))
 		return cpu_addr;
 
+	/*
+	 * Let the implementation decide on the zone to allocate from, and
+	 * decide on the way of zeroing the memory given that the memory
+	 * returned should always be zeroed.
+	 */
+	flag &= ~(__GFP_DMA | __GFP_DMA32 | __GFP_HIGHMEM | __GFP_ZERO);
+
 	if (!arch_dma_alloc_attrs(&dev, &flag))
 		return NULL;
 	if (!ops->alloc)
-- 
2.14.2

