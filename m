From: Christoph Hellwig <hch@lst.de>
Date: Wed, 10 Jan 2018 08:09:32 +0000
Subject: [PATCH 22/22] arm64: use swiotlb_alloc and swiotlb_free
Message-Id: <20180110080932.14157-23-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180110080932.14157-1-hch@lst.de>
In-Reply-To: <20180110080932.14157-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: iommu@lists.linux-foundation.org
Cc: Konrad Rzeszutek Wilk <konrad@darnok.org>, Michal Simek <monstr@monstr.eu>, Guan Xuetao <gxt@mprc.pku.edu.cn>, =?UTF-8?q?Christian=20K=C3=B6nig?= <ckoenig.leichtzumerken@gmail.com>, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

The generic swiotlb_alloc and swiotlb_free routines already take care
of CMA allocations and adding GFP_DMA32 where needed, so use them
instead of the arm specific helpers.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/arm64/Kconfig          |  1 +
 arch/arm64/mm/dma-mapping.c | 46 +++------------------------------------------
 2 files changed, 4 insertions(+), 43 deletions(-)

diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index 6b6985f15d02..53205c02b18a 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -59,6 +59,7 @@ config ARM64
 	select COMMON_CLK
 	select CPU_PM if (SUSPEND || CPU_IDLE)
 	select DCACHE_WORD_ACCESS
+	select DMA_DIRECT_OPS
 	select EDAC_SUPPORT
 	select FRAME_POINTER
 	select GENERIC_ALLOCATOR
diff --git a/arch/arm64/mm/dma-mapping.c b/arch/arm64/mm/dma-mapping.c
index 0d641875b20e..a96ec0181818 100644
--- a/arch/arm64/mm/dma-mapping.c
+++ b/arch/arm64/mm/dma-mapping.c
@@ -91,46 +91,6 @@ static int __free_from_pool(void *start, size_t size)
 	return 1;
 }
 
-static void *__dma_alloc_coherent(struct device *dev, size_t size,
-				  dma_addr_t *dma_handle, gfp_t flags,
-				  unsigned long attrs)
-{
-	if (IS_ENABLED(CONFIG_ZONE_DMA32) &&
-	    dev->coherent_dma_mask <= DMA_BIT_MASK(32))
-		flags |= GFP_DMA32;
-	if (dev_get_cma_area(dev) && gfpflags_allow_blocking(flags)) {
-		struct page *page;
-		void *addr;
-
-		page = dma_alloc_from_contiguous(dev, size >> PAGE_SHIFT,
-						 get_order(size), flags);
-		if (!page)
-			return NULL;
-
-		*dma_handle = phys_to_dma(dev, page_to_phys(page));
-		addr = page_address(page);
-		memset(addr, 0, size);
-		return addr;
-	} else {
-		return swiotlb_alloc_coherent(dev, size, dma_handle, flags);
-	}
-}
-
-static void __dma_free_coherent(struct device *dev, size_t size,
-				void *vaddr, dma_addr_t dma_handle,
-				unsigned long attrs)
-{
-	bool freed;
-	phys_addr_t paddr = dma_to_phys(dev, dma_handle);
-
-
-	freed = dma_release_from_contiguous(dev,
-					phys_to_page(paddr),
-					size >> PAGE_SHIFT);
-	if (!freed)
-		swiotlb_free_coherent(dev, size, vaddr, dma_handle);
-}
-
 static void *__dma_alloc(struct device *dev, size_t size,
 			 dma_addr_t *dma_handle, gfp_t flags,
 			 unsigned long attrs)
@@ -152,7 +112,7 @@ static void *__dma_alloc(struct device *dev, size_t size,
 		return addr;
 	}
 
-	ptr = __dma_alloc_coherent(dev, size, dma_handle, flags, attrs);
+	ptr = swiotlb_alloc(dev, size, dma_handle, flags, attrs);
 	if (!ptr)
 		goto no_mem;
 
@@ -173,7 +133,7 @@ static void *__dma_alloc(struct device *dev, size_t size,
 	return coherent_ptr;
 
 no_map:
-	__dma_free_coherent(dev, size, ptr, *dma_handle, attrs);
+	swiotlb_free(dev, size, ptr, *dma_handle, attrs);
 no_mem:
 	return NULL;
 }
@@ -191,7 +151,7 @@ static void __dma_free(struct device *dev, size_t size,
 			return;
 		vunmap(vaddr);
 	}
-	__dma_free_coherent(dev, size, swiotlb_addr, dma_handle, attrs);
+	swiotlb_free(dev, size, swiotlb_addr, dma_handle, attrs);
 }
 
 static dma_addr_t __swiotlb_map_page(struct device *dev, struct page *page,
-- 
2.14.2

