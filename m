From: Christoph Hellwig <hch@lst.de>
Date: Sun, 27 Aug 2017 16:10:30 +0000
Subject: [PATCH 10/12] xtensa: make dma_cache_sync a no-op
Message-Id: <20170827161032.22772-11-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170827161032.22772-1-hch@lst.de>
In-Reply-To: <20170827161032.22772-1-hch-jcswGhMUV9g@public.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: Chris Zankel <chris-YvXeqwSYzG2sTnJN9+BGXg@public.gmane.org>, Michal Simek <monstr-pSz03upnqPeHXe+LvDLADg@public.gmane.org>, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org, linux-sh-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, linux-xtensa-PjhNF2WwrV/0Sa2dR60CXw@public.gmane.org, x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Max Filippov <jcmvbkbc-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Guan Xuetao <gxt-TG0Ac1+ktVePQbnJrJN+5g@public.gmane.org>

xtensa does not implement DMA_ATTR_NON_CONSISTENT allocations, so it
doesn't make any sense to do any work in dma_cache_sync given that it
must be a no-op when dma_alloc_attrs returns coherent memory.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/xtensa/include/asm/dma-mapping.h |  6 ++++--
 arch/xtensa/kernel/pci-dma.c          | 23 -----------------------
 2 files changed, 4 insertions(+), 25 deletions(-)

diff --git a/arch/xtensa/include/asm/dma-mapping.h b/arch/xtensa/include/asm/dma-mapping.h
index 269738dc9d1d..353e0314d6ba 100644
--- a/arch/xtensa/include/asm/dma-mapping.h
+++ b/arch/xtensa/include/asm/dma-mapping.h
@@ -23,8 +23,10 @@ static inline const struct dma_map_ops *get_arch_dma_ops(struct bus_type *bus)
 	return &xtensa_dma_map_ops;
 }
 
-void dma_cache_sync(struct device *dev, void *vaddr, size_t size,
-		    enum dma_data_direction direction);
+static inline void dma_cache_sync(struct device *dev, void *vaddr, size_t size,
+		    enum dma_data_direction direction)
+{
+}
 
 static inline dma_addr_t phys_to_dma(struct device *dev, phys_addr_t paddr)
 {
diff --git a/arch/xtensa/kernel/pci-dma.c b/arch/xtensa/kernel/pci-dma.c
index cec86a1c2acc..623720a11143 100644
--- a/arch/xtensa/kernel/pci-dma.c
+++ b/arch/xtensa/kernel/pci-dma.c
@@ -26,29 +26,6 @@
 #include <asm/cacheflush.h>
 #include <asm/io.h>
 
-void dma_cache_sync(struct device *dev, void *vaddr, size_t size,
-		    enum dma_data_direction dir)
-{
-	switch (dir) {
-	case DMA_BIDIRECTIONAL:
-		__flush_invalidate_dcache_range((unsigned long)vaddr, size);
-		break;
-
-	case DMA_FROM_DEVICE:
-		__invalidate_dcache_range((unsigned long)vaddr, size);
-		break;
-
-	case DMA_TO_DEVICE:
-		__flush_dcache_range((unsigned long)vaddr, size);
-		break;
-
-	case DMA_NONE:
-		BUG();
-		break;
-	}
-}
-EXPORT_SYMBOL(dma_cache_sync);
-
 static void do_cache_op(dma_addr_t dma_handle, size_t size,
 			void (*fn)(unsigned long, unsigned long))
 {
-- 
2.11.0

