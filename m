From: Christoph Hellwig <hch@lst.de>
Date: Tue, 03 Oct 2017 10:43:05 +0000
Subject: [PATCH 05/11] microblaze: make dma_cache_sync a no-op
Message-Id: <20171003104311.10058-6-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20171003104311.10058-1-hch@lst.de>
In-Reply-To: <20171003104311.10058-1-hch-jcswGhMUV9g@public.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: Chris Zankel <chris-YvXeqwSYzG2sTnJN9+BGXg@public.gmane.org>, Michal Simek <monstr-pSz03upnqPeHXe+LvDLADg@public.gmane.org>, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org, linux-sh-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, linux-xtensa-PjhNF2WwrV/0Sa2dR60CXw@public.gmane.org, x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Max Filippov <jcmvbkbc-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Guan Xuetao <gxt-TG0Ac1+ktVePQbnJrJN+5g@public.gmane.org>

microblaze does not implement DMA_ATTR_NON_CONSISTENT allocations, so it
doesn't make any sense to do any work in dma_cache_sync given that it
must be a no-op when dma_alloc_attrs returns coherent memory.

This also allows moving __dma_sync out of the microblaze asm/dma-mapping.h
and thus greatly reduce the amount of includes there.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/microblaze/include/asm/dma-mapping.h | 34 -------------------------------
 arch/microblaze/kernel/dma.c              | 17 ++++++++++++++++
 2 files changed, 17 insertions(+), 34 deletions(-)

diff --git a/arch/microblaze/include/asm/dma-mapping.h b/arch/microblaze/include/asm/dma-mapping.h
index e15cd2f76e23..ad448e4aedb6 100644
--- a/arch/microblaze/include/asm/dma-mapping.h
+++ b/arch/microblaze/include/asm/dma-mapping.h
@@ -15,22 +15,6 @@
 #ifndef _ASM_MICROBLAZE_DMA_MAPPING_H
 #define _ASM_MICROBLAZE_DMA_MAPPING_H
 
-/*
- * See Documentation/DMA-API-HOWTO.txt and
- * Documentation/DMA-API.txt for documentation.
- */
-
-#include <linux/types.h>
-#include <linux/cache.h>
-#include <linux/mm.h>
-#include <linux/scatterlist.h>
-#include <linux/dma-debug.h>
-#include <asm/io.h>
-#include <asm/cacheflush.h>
-
-#define __dma_alloc_coherent(dev, gfp, size, handle)	NULL
-#define __dma_free_coherent(size, addr)		((void)0)
-
 /*
  * Available generic sets of operations
  */
@@ -41,27 +25,9 @@ static inline const struct dma_map_ops *get_arch_dma_ops(struct bus_type *bus)
 	return &dma_direct_ops;
 }
 
-static inline void __dma_sync(unsigned long paddr,
-			      size_t size, enum dma_data_direction direction)
-{
-	switch (direction) {
-	case DMA_TO_DEVICE:
-	case DMA_BIDIRECTIONAL:
-		flush_dcache_range(paddr, paddr + size);
-		break;
-	case DMA_FROM_DEVICE:
-		invalidate_dcache_range(paddr, paddr + size);
-		break;
-	default:
-		BUG();
-	}
-}
-
 static inline void dma_cache_sync(struct device *dev, void *vaddr, size_t size,
 		enum dma_data_direction direction)
 {
-	BUG_ON(direction = DMA_NONE);
-	__dma_sync(virt_to_phys(vaddr), size, (int)direction);
 }
 
 #endif	/* _ASM_MICROBLAZE_DMA_MAPPING_H */
diff --git a/arch/microblaze/kernel/dma.c b/arch/microblaze/kernel/dma.c
index 94700c5270a9..e52b684f8ea2 100644
--- a/arch/microblaze/kernel/dma.c
+++ b/arch/microblaze/kernel/dma.c
@@ -12,6 +12,7 @@
 #include <linux/dma-debug.h>
 #include <linux/export.h>
 #include <linux/bug.h>
+#include <asm/cacheflush.h>
 
 #define NOT_COHERENT_CACHE
 
@@ -51,6 +52,22 @@ static void dma_direct_free_coherent(struct device *dev, size_t size,
 #endif
 }
 
+static inline void __dma_sync(unsigned long paddr,
+			      size_t size, enum dma_data_direction direction)
+{
+	switch (direction) {
+	case DMA_TO_DEVICE:
+	case DMA_BIDIRECTIONAL:
+		flush_dcache_range(paddr, paddr + size);
+		break;
+	case DMA_FROM_DEVICE:
+		invalidate_dcache_range(paddr, paddr + size);
+		break;
+	default:
+		BUG();
+	}
+}
+
 static int dma_direct_map_sg(struct device *dev, struct scatterlist *sgl,
 			     int nents, enum dma_data_direction direction,
 			     unsigned long attrs)
-- 
2.14.1

