From: Christoph Hellwig <hch@lst.de>
Date: Fri, 29 Dec 2017 08:18:26 +0000
Subject: [PATCH 22/67] dma-mapping: clear harmful GFP_* flags in common code
Message-Id: <20171229081911.2802-23-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20171229081911.2802-1-hch@lst.de>
In-Reply-To: <20171229081911.2802-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: iommu@lists.linux-foundation.org
Cc: linux-alpha@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, adi-buildroot-devel@lists.sourceforge.net, linux-c6x-dev@linux-c6x.org, linux-cris-kernel@axis.com, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-metag@vger.kernel.org, Michal Simek <monstr@monstr.eu>, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, patches@groups.riscv.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, Guan Xuetao <gxt@mprc.pku.edu.cn>, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

Life the code from x86 so that we behave consistently.  In the future we
should probably warn if any of these is set.

Signed-off-by: Christoph Hellwig <hch@lst.de>
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
index aa16ce27e036..c7e3056885d3 100644
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
index 0e92214310c4..4e27b74df973 100644
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
index e0167418072b..2f3492e8295c 100644
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
index 3cd93e0c7a29..6f6b1399e98e 100644
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
index 55876a87c247..2629f1f4b04e 100644
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
index 599bcc09c9e7..9e54f8cb3459 100644
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
index 5d49da094a93..1723001d5de1 100644
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
index 2779d544485c..fd5197af882a 100644
--- a/include/linux/dma-mapping.h
+++ b/include/linux/dma-mapping.h
@@ -525,6 +525,13 @@ static inline void *dma_alloc_attrs(struct device *dev, size_t size,
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

