From: Christoph Hellwig <hch@lst.de>
Date: Tue, 03 Oct 2017 10:43:08 +0000
Subject: [PATCH 08/11] unicore32: make dma_cache_sync a no-op
Message-Id: <20171003104311.10058-9-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20171003104311.10058-1-hch@lst.de>
In-Reply-To: <20171003104311.10058-1-hch-jcswGhMUV9g@public.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: Chris Zankel <chris-YvXeqwSYzG2sTnJN9+BGXg@public.gmane.org>, Michal Simek <monstr-pSz03upnqPeHXe+LvDLADg@public.gmane.org>, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org, linux-sh-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, linux-xtensa-PjhNF2WwrV/0Sa2dR60CXw@public.gmane.org, x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Max Filippov <jcmvbkbc-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Guan Xuetao <gxt-TG0Ac1+ktVePQbnJrJN+5g@public.gmane.org>

unicore32 does not implement DMA_ATTR_NON_CONSISTENT allocations, so it
doesn't make any sense to do any work in dma_cache_sync given that it
must be a no-op when dma_alloc_attrs returns coherent memory.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/unicore32/include/asm/cacheflush.h  |  9 ---------
 arch/unicore32/include/asm/dma-mapping.h | 17 -----------------
 arch/unicore32/mm/proc-syms.c            |  3 ---
 3 files changed, 29 deletions(-)

diff --git a/arch/unicore32/include/asm/cacheflush.h b/arch/unicore32/include/asm/cacheflush.h
index c0301e6c8b81..a5e08e2d5d6d 100644
--- a/arch/unicore32/include/asm/cacheflush.h
+++ b/arch/unicore32/include/asm/cacheflush.h
@@ -101,15 +101,6 @@ extern void __cpuc_coherent_user_range(unsigned long, unsigned long);
 extern void __cpuc_flush_dcache_area(void *, size_t);
 extern void __cpuc_flush_kern_dcache_area(void *addr, size_t size);
 
-/*
- * These are private to the dma-mapping API.  Do not use directly.
- * Their sole purpose is to ensure that data held in the cache
- * is visible to DMA, or data written by DMA to system memory is
- * visible to the CPU.
- */
-extern void __cpuc_dma_clean_range(unsigned long, unsigned long);
-extern void __cpuc_dma_flush_range(unsigned long, unsigned long);
-
 /*
  * Copy user data from/to a page which is mapped into a different
  * processes address space.  Really, we want to allow our "user
diff --git a/arch/unicore32/include/asm/dma-mapping.h b/arch/unicore32/include/asm/dma-mapping.h
index 518ba5848dd6..e949855bb794 100644
--- a/arch/unicore32/include/asm/dma-mapping.h
+++ b/arch/unicore32/include/asm/dma-mapping.h
@@ -18,9 +18,6 @@
 #include <linux/scatterlist.h>
 #include <linux/swiotlb.h>
 
-#include <asm/memory.h>
-#include <asm/cacheflush.h>
-
 extern const struct dma_map_ops swiotlb_dma_map_ops;
 
 static inline const struct dma_map_ops *get_arch_dma_ops(struct bus_type *bus)
@@ -51,20 +48,6 @@ static inline void dma_mark_clean(void *addr, size_t size) {}
 static inline void dma_cache_sync(struct device *dev, void *vaddr,
 		size_t size, enum dma_data_direction direction)
 {
-	unsigned long start = (unsigned long)vaddr;
-	unsigned long end   = start + size;
-
-	switch (direction) {
-	case DMA_NONE:
-		BUG();
-	case DMA_FROM_DEVICE:
-	case DMA_BIDIRECTIONAL:	/* writeback and invalidate */
-		__cpuc_dma_flush_range(start, end);
-		break;
-	case DMA_TO_DEVICE:		/* writeback only */
-		__cpuc_dma_clean_range(start, end);
-		break;
-	}
 }
 
 #endif /* __KERNEL__ */
diff --git a/arch/unicore32/mm/proc-syms.c b/arch/unicore32/mm/proc-syms.c
index 21c00fc85c99..df215fd6d639 100644
--- a/arch/unicore32/mm/proc-syms.c
+++ b/arch/unicore32/mm/proc-syms.c
@@ -20,6 +20,3 @@ EXPORT_SYMBOL(cpu_dcache_clean_area);
 EXPORT_SYMBOL(cpu_set_pte);
 
 EXPORT_SYMBOL(__cpuc_coherent_kern_range);
-
-EXPORT_SYMBOL(__cpuc_dma_flush_range);
-EXPORT_SYMBOL(__cpuc_dma_clean_range);
-- 
2.14.1

