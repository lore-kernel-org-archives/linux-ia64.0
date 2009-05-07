From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Date: Thu, 07 May 2009 04:35:45 +0000
Subject: [PATCH -tip 2/5] x86: use asm-generic/dma-mapping.h
Message-Id: <1241670948-5818-3-git-send-email-fujita.tomonori@lab.ntt.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <1241670948-5818-1-git-send-email-fujita.tomonori@lab.ntt.co.jp>
In-Reply-To: <1241670948-5818-1-git-send-email-fujita.tomonori@lab.ntt.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: mingo@elte.hu, tony.luck@intel.com, linux-ia64@vger.kernel.org, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>

Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
---
 arch/x86/Kconfig                   |    1 +
 arch/x86/include/asm/dma-mapping.h |  174 +-----------------------------------
 2 files changed, 3 insertions(+), 172 deletions(-)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index fa4d702..13d26ce 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -47,6 +47,7 @@ config X86
 	select HAVE_KERNEL_BZIP2
 	select HAVE_KERNEL_LZMA
 	select HAVE_ARCH_KMEMCHECK
+	select HAVE_DMA_ATTRS
 
 config OUTPUT_FORMAT
 	string
diff --git a/arch/x86/include/asm/dma-mapping.h b/arch/x86/include/asm/dma-mapping.h
index 916cbb6..2c1cbd8 100644
--- a/arch/x86/include/asm/dma-mapping.h
+++ b/arch/x86/include/asm/dma-mapping.h
@@ -33,6 +33,8 @@ static inline struct dma_map_ops *get_dma_ops(struct device *dev)
 #endif
 }
 
+#include <asm-generic/dma-mapping.h>
+
 /* Make sure we keep the same behaviour */
 static inline int dma_mapping_error(struct device *dev, dma_addr_t dma_addr)
 {
@@ -53,178 +55,6 @@ extern int dma_set_mask(struct device *dev, u64 mask);
 extern void *dma_generic_alloc_coherent(struct device *dev, size_t size,
 					dma_addr_t *dma_addr, gfp_t flag);
 
-static inline dma_addr_t
-dma_map_single(struct device *hwdev, void *ptr, size_t size,
-	       enum dma_data_direction dir)
-{
-	struct dma_map_ops *ops = get_dma_ops(hwdev);
-	dma_addr_t addr;
-
-	kmemcheck_mark_initialized(ptr, size);
-	BUG_ON(!valid_dma_direction(dir));
-	addr = ops->map_page(hwdev, virt_to_page(ptr),
-			     (unsigned long)ptr & ~PAGE_MASK, size,
-			     dir, NULL);
-	debug_dma_map_page(hwdev, virt_to_page(ptr),
-			   (unsigned long)ptr & ~PAGE_MASK, size,
-			   dir, addr, true);
-	return addr;
-}
-
-static inline void
-dma_unmap_single(struct device *dev, dma_addr_t addr, size_t size,
-		 enum dma_data_direction dir)
-{
-	struct dma_map_ops *ops = get_dma_ops(dev);
-
-	BUG_ON(!valid_dma_direction(dir));
-	if (ops->unmap_page)
-		ops->unmap_page(dev, addr, size, dir, NULL);
-	debug_dma_unmap_page(dev, addr, size, dir, true);
-}
-
-static inline int
-dma_map_sg(struct device *hwdev, struct scatterlist *sg,
-	   int nents, enum dma_data_direction dir)
-{
-	struct dma_map_ops *ops = get_dma_ops(hwdev);
-	int ents;
-
-	struct scatterlist *s;
-	int i;
-
-	for_each_sg(sg, s, nents, i)
-		kmemcheck_mark_initialized(sg_virt(s), s->length);
-	BUG_ON(!valid_dma_direction(dir));
-	ents = ops->map_sg(hwdev, sg, nents, dir, NULL);
-	debug_dma_map_sg(hwdev, sg, nents, ents, dir);
-
-	return ents;
-}
-
-static inline void
-dma_unmap_sg(struct device *hwdev, struct scatterlist *sg, int nents,
-	     enum dma_data_direction dir)
-{
-	struct dma_map_ops *ops = get_dma_ops(hwdev);
-
-	BUG_ON(!valid_dma_direction(dir));
-	debug_dma_unmap_sg(hwdev, sg, nents, dir);
-	if (ops->unmap_sg)
-		ops->unmap_sg(hwdev, sg, nents, dir, NULL);
-}
-
-static inline void
-dma_sync_single_for_cpu(struct device *hwdev, dma_addr_t dma_handle,
-			size_t size, enum dma_data_direction dir)
-{
-	struct dma_map_ops *ops = get_dma_ops(hwdev);
-
-	BUG_ON(!valid_dma_direction(dir));
-	if (ops->sync_single_for_cpu)
-		ops->sync_single_for_cpu(hwdev, dma_handle, size, dir);
-	debug_dma_sync_single_for_cpu(hwdev, dma_handle, size, dir);
-	flush_write_buffers();
-}
-
-static inline void
-dma_sync_single_for_device(struct device *hwdev, dma_addr_t dma_handle,
-			   size_t size, enum dma_data_direction dir)
-{
-	struct dma_map_ops *ops = get_dma_ops(hwdev);
-
-	BUG_ON(!valid_dma_direction(dir));
-	if (ops->sync_single_for_device)
-		ops->sync_single_for_device(hwdev, dma_handle, size, dir);
-	debug_dma_sync_single_for_device(hwdev, dma_handle, size, dir);
-	flush_write_buffers();
-}
-
-static inline void
-dma_sync_single_range_for_cpu(struct device *hwdev, dma_addr_t dma_handle,
-			      unsigned long offset, size_t size,
-			      enum dma_data_direction dir)
-{
-	struct dma_map_ops *ops = get_dma_ops(hwdev);
-
-	BUG_ON(!valid_dma_direction(dir));
-	if (ops->sync_single_range_for_cpu)
-		ops->sync_single_range_for_cpu(hwdev, dma_handle, offset,
-					       size, dir);
-	debug_dma_sync_single_range_for_cpu(hwdev, dma_handle,
-					    offset, size, dir);
-	flush_write_buffers();
-}
-
-static inline void
-dma_sync_single_range_for_device(struct device *hwdev, dma_addr_t dma_handle,
-				 unsigned long offset, size_t size,
-				 enum dma_data_direction dir)
-{
-	struct dma_map_ops *ops = get_dma_ops(hwdev);
-
-	BUG_ON(!valid_dma_direction(dir));
-	if (ops->sync_single_range_for_device)
-		ops->sync_single_range_for_device(hwdev, dma_handle,
-						  offset, size, dir);
-	debug_dma_sync_single_range_for_device(hwdev, dma_handle,
-					       offset, size, dir);
-	flush_write_buffers();
-}
-
-static inline void
-dma_sync_sg_for_cpu(struct device *hwdev, struct scatterlist *sg,
-		    int nelems, enum dma_data_direction dir)
-{
-	struct dma_map_ops *ops = get_dma_ops(hwdev);
-
-	BUG_ON(!valid_dma_direction(dir));
-	if (ops->sync_sg_for_cpu)
-		ops->sync_sg_for_cpu(hwdev, sg, nelems, dir);
-	debug_dma_sync_sg_for_cpu(hwdev, sg, nelems, dir);
-	flush_write_buffers();
-}
-
-static inline void
-dma_sync_sg_for_device(struct device *hwdev, struct scatterlist *sg,
-		       int nelems, enum dma_data_direction dir)
-{
-	struct dma_map_ops *ops = get_dma_ops(hwdev);
-
-	BUG_ON(!valid_dma_direction(dir));
-	if (ops->sync_sg_for_device)
-		ops->sync_sg_for_device(hwdev, sg, nelems, dir);
-	debug_dma_sync_sg_for_device(hwdev, sg, nelems, dir);
-
-	flush_write_buffers();
-}
-
-static inline dma_addr_t dma_map_page(struct device *dev, struct page *page,
-				      size_t offset, size_t size,
-				      enum dma_data_direction dir)
-{
-	struct dma_map_ops *ops = get_dma_ops(dev);
-	dma_addr_t addr;
-
-	kmemcheck_mark_initialized(page_address(page) + offset, size);
-	BUG_ON(!valid_dma_direction(dir));
-	addr = ops->map_page(dev, page, offset, size, dir, NULL);
-	debug_dma_map_page(dev, page, offset, size, dir, addr, false);
-
-	return addr;
-}
-
-static inline void dma_unmap_page(struct device *dev, dma_addr_t addr,
-				  size_t size, enum dma_data_direction dir)
-{
-	struct dma_map_ops *ops = get_dma_ops(dev);
-
-	BUG_ON(!valid_dma_direction(dir));
-	if (ops->unmap_page)
-		ops->unmap_page(dev, addr, size, dir, NULL);
-	debug_dma_unmap_page(dev, addr, size, dir, false);
-}
-
 static inline void
 dma_cache_sync(struct device *dev, void *vaddr, size_t size,
 	enum dma_data_direction dir)
-- 
1.6.0.6

