From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Date: Fri, 15 May 2009 03:55:03 +0000
Subject: [PATCH -tip 3/5] ia64: use asm-generic/dma-mapping-common.h
Message-Id: <1242359705-2117-4-git-send-email-fujita.tomonori@lab.ntt.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <1242359705-2117-1-git-send-email-fujita.tomonori@lab.ntt.co.jp>
In-Reply-To: <1242359705-2117-1-git-send-email-fujita.tomonori@lab.ntt.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: mingo@elte.hu, tony.luck@intel.com, linux-ia64@vger.kernel.org, fujita.tomonori@lab.ntt.co.jp, arnd@arndb.de, joerg.roedel@amd.com

Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Acked-by: Joerg Roedel <joerg.roedel@amd.com>
---
 arch/ia64/include/asm/dma-mapping.h |  102 +---------------------------------
 1 files changed, 3 insertions(+), 99 deletions(-)

diff --git a/arch/ia64/include/asm/dma-mapping.h b/arch/ia64/include/asm/dma-mapping.h
index 36c0009..2475c91 100644
--- a/arch/ia64/include/asm/dma-mapping.h
+++ b/arch/ia64/include/asm/dma-mapping.h
@@ -37,82 +37,10 @@ static inline void dma_free_coherent(struct device *dev, size_t size,
 #define dma_alloc_noncoherent(d, s, h, f) dma_alloc_coherent(d, s, h, f)
 #define dma_free_noncoherent(d, s, v, h) dma_free_coherent(d, s, v, h)
 
-static inline dma_addr_t dma_map_single_attrs(struct device *dev,
-					      void *caddr, size_t size,
-					      enum dma_data_direction dir,
-					      struct dma_attrs *attrs)
-{
-	struct dma_map_ops *ops = platform_dma_get_ops(dev);
-	return ops->map_page(dev, virt_to_page(caddr),
-			     (unsigned long)caddr & ~PAGE_MASK, size,
-			     dir, attrs);
-}
-
-static inline void dma_unmap_single_attrs(struct device *dev, dma_addr_t daddr,
-					  size_t size,
-					  enum dma_data_direction dir,
-					  struct dma_attrs *attrs)
-{
-	struct dma_map_ops *ops = platform_dma_get_ops(dev);
-	ops->unmap_page(dev, daddr, size, dir, attrs);
-}
-
-#define dma_map_single(d, a, s, r) dma_map_single_attrs(d, a, s, r, NULL)
-#define dma_unmap_single(d, a, s, r) dma_unmap_single_attrs(d, a, s, r, NULL)
-
-static inline int dma_map_sg_attrs(struct device *dev, struct scatterlist *sgl,
-				   int nents, enum dma_data_direction dir,
-				   struct dma_attrs *attrs)
-{
-	struct dma_map_ops *ops = platform_dma_get_ops(dev);
-	return ops->map_sg(dev, sgl, nents, dir, attrs);
-}
-
-static inline void dma_unmap_sg_attrs(struct device *dev,
-				      struct scatterlist *sgl, int nents,
-				      enum dma_data_direction dir,
-				      struct dma_attrs *attrs)
-{
-	struct dma_map_ops *ops = platform_dma_get_ops(dev);
-	ops->unmap_sg(dev, sgl, nents, dir, attrs);
-}
+#define get_dma_ops(dev) platform_dma_get_ops(dev)
+#define flush_write_buffers()
 
-#define dma_map_sg(d, s, n, r) dma_map_sg_attrs(d, s, n, r, NULL)
-#define dma_unmap_sg(d, s, n, r) dma_unmap_sg_attrs(d, s, n, r, NULL)
-
-static inline void dma_sync_single_for_cpu(struct device *dev, dma_addr_t daddr,
-					   size_t size,
-					   enum dma_data_direction dir)
-{
-	struct dma_map_ops *ops = platform_dma_get_ops(dev);
-	ops->sync_single_for_cpu(dev, daddr, size, dir);
-}
-
-static inline void dma_sync_sg_for_cpu(struct device *dev,
-				       struct scatterlist *sgl,
-				       int nents, enum dma_data_direction dir)
-{
-	struct dma_map_ops *ops = platform_dma_get_ops(dev);
-	ops->sync_sg_for_cpu(dev, sgl, nents, dir);
-}
-
-static inline void dma_sync_single_for_device(struct device *dev,
-					      dma_addr_t daddr,
-					      size_t size,
-					      enum dma_data_direction dir)
-{
-	struct dma_map_ops *ops = platform_dma_get_ops(dev);
-	ops->sync_single_for_device(dev, daddr, size, dir);
-}
-
-static inline void dma_sync_sg_for_device(struct device *dev,
-					  struct scatterlist *sgl,
-					  int nents,
-					  enum dma_data_direction dir)
-{
-	struct dma_map_ops *ops = platform_dma_get_ops(dev);
-	ops->sync_sg_for_device(dev, sgl, nents, dir);
-}
+#include <asm-generic/dma-mapping-common.h>
 
 static inline int dma_mapping_error(struct device *dev, dma_addr_t daddr)
 {
@@ -120,30 +48,6 @@ static inline int dma_mapping_error(struct device *dev, dma_addr_t daddr)
 	return ops->mapping_error(dev, daddr);
 }
 
-static inline dma_addr_t dma_map_page(struct device *dev, struct page *page,
-				      size_t offset, size_t size,
-				      enum dma_data_direction dir)
-{
-	struct dma_map_ops *ops = platform_dma_get_ops(dev);
-	return ops->map_page(dev, page, offset, size, dir, NULL);
-}
-
-static inline void dma_unmap_page(struct device *dev, dma_addr_t addr,
-				  size_t size, enum dma_data_direction dir)
-{
-	dma_unmap_single(dev, addr, size, dir);
-}
-
-/*
- * Rest of this file is part of the "Advanced DMA API".  Use at your own risk.
- * See Documentation/DMA-API.txt for details.
- */
-
-#define dma_sync_single_range_for_cpu(dev, dma_handle, offset, size, dir)	\
-	dma_sync_single_for_cpu(dev, dma_handle, size, dir)
-#define dma_sync_single_range_for_device(dev, dma_handle, offset, size, dir)	\
-	dma_sync_single_for_device(dev, dma_handle, size, dir)
-
 static inline int dma_supported(struct device *dev, u64 mask)
 {
 	struct dma_map_ops *ops = platform_dma_get_ops(dev);
-- 
1.6.0.6

