From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Date: Mon, 05 Jan 2009 14:36:13 +0000
Subject: [PATCH 08/13] convert the DMA API to use dma_ops
Message-Id: <1231166178-20050-9-git-send-email-fujita.tomonori@lab.ntt.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <1231166178-20050-1-git-send-email-fujita.tomonori@lab.ntt.co.jp>
 <1231166178-20050-2-git-send-email-fujita.tomonori@lab.ntt.co.jp>
 <1231166178-20050-3-git-send-email-fujita.tomonori@lab.ntt.co.jp>
 <1231166178-20050-4-git-send-email-fujita.tomonori@lab.ntt.co.jp>
 <1231166178-20050-5-git-send-email-fujita.tomonori@lab.ntt.co.jp>
 <1231166178-20050-6-git-send-email-fujita.tomonori@lab.ntt.co.jp>
 <1231166178-20050-7-git-send-email-fujita.tomonori@lab.ntt.co.jp>
 <1231166178-20050-8-git-send-email-fujita.tomonori@lab.ntt.co.jp>
In-Reply-To: <1231166178-20050-8-git-send-email-fujita.tomonori@lab.ntt.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>

This writes asm/dma-mapping.h to convert the DMA API to use dma_ops.

Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
---
 arch/ia64/include/asm/dma-mapping.h |  113 ++++++++++++++++++++++++-----------
 1 files changed, 77 insertions(+), 36 deletions(-)

diff --git a/arch/ia64/include/asm/dma-mapping.h b/arch/ia64/include/asm/dma-mapping.h
index eeb2aa3..5298f40 100644
--- a/arch/ia64/include/asm/dma-mapping.h
+++ b/arch/ia64/include/asm/dma-mapping.h
@@ -65,52 +65,92 @@ extern struct dma_mapping_ops *dma_ops;
 extern struct ia64_machine_vector ia64_mv;
 extern void set_iommu_machvec(void);
 
-#define dma_alloc_coherent(dev, size, handle, gfp)	\
-	platform_dma_alloc_coherent(dev, size, handle, (gfp) | GFP_DMA)
+static inline void *dma_alloc_coherent(struct device *dev, size_t size,
+				       dma_addr_t *daddr, gfp_t gfp)
+{
+	return dma_ops->alloc_coherent(dev, size, daddr, gfp | GFP_DMA);
+}
 
-/* coherent mem. is cheap */
-static inline void *
-dma_alloc_noncoherent(struct device *dev, size_t size, dma_addr_t *dma_handle,
-		      gfp_t flag)
+static inline void dma_free_coherent(struct device *dev, size_t size,
+				     void *caddr, dma_addr_t daddr)
 {
-	return dma_alloc_coherent(dev, size, dma_handle, flag);
+	dma_ops->free_coherent(dev, size, caddr, daddr);
 }
-#define dma_free_coherent	platform_dma_free_coherent
-static inline void
-dma_free_noncoherent(struct device *dev, size_t size, void *cpu_addr,
-		     dma_addr_t dma_handle)
+
+#define dma_alloc_noncoherent(d, s, h, f) dma_alloc_coherent(d, s, h, f)
+#define dma_free_noncoherent(d, s, v, h) dma_free_coherent(d, s, v, h)
+
+static inline dma_addr_t dma_map_single_attrs(struct device *dev,
+					      void *caddr, size_t size,
+					      enum dma_data_direction dir,
+					      struct dma_attrs *attrs)
+{
+	return dma_ops->map_single_attrs(dev, caddr, size, dir, attrs);
+}
+
+static inline void dma_unmap_single_attrs(struct device *dev, dma_addr_t daddr,
+					  size_t size,
+					  enum dma_data_direction dir,
+					  struct dma_attrs *attrs)
 {
-	dma_free_coherent(dev, size, cpu_addr, dma_handle);
+	dma_ops->unmap_single_attrs(dev, daddr, size, dir, attrs);
 }
-#define dma_map_single_attrs	platform_dma_map_single_attrs
-static inline dma_addr_t dma_map_single(struct device *dev, void *cpu_addr,
-					size_t size, int dir)
+
+#define dma_map_single(d, a, s, r) dma_map_single_attrs(d, a, s, r, NULL)
+#define dma_unmap_single(d, a, s, r) dma_unmap_single_attrs(d, a, s, r, NULL)
+
+static inline int dma_map_sg_attrs(struct device *dev, struct scatterlist *sgl,
+				   int nents, enum dma_data_direction dir,
+				   struct dma_attrs *attrs)
 {
-	return dma_map_single_attrs(dev, cpu_addr, size, dir, NULL);
+	return dma_ops->map_sg_attrs(dev, sgl, nents, dir, attrs);
 }
-#define dma_map_sg_attrs	platform_dma_map_sg_attrs
-static inline int dma_map_sg(struct device *dev, struct scatterlist *sgl,
-			     int nents, int dir)
+
+static inline void dma_unmap_sg_attrs(struct device *dev,
+				      struct scatterlist *sgl, int nents,
+				      enum dma_data_direction dir,
+				      struct dma_attrs *attrs)
 {
-	return dma_map_sg_attrs(dev, sgl, nents, dir, NULL);
+	dma_ops->unmap_sg_attrs(dev, sgl, nents, dir, attrs);
 }
-#define dma_unmap_single_attrs	platform_dma_unmap_single_attrs
-static inline void dma_unmap_single(struct device *dev, dma_addr_t cpu_addr,
-				    size_t size, int dir)
+
+#define dma_map_sg(d, s, n, r) dma_map_sg_attrs(d, s, n, r, NULL)
+#define dma_unmap_sg(d, s, n, r) dma_unmap_sg_attrs(d, s, n, r, NULL)
+
+static inline void dma_sync_single_for_cpu(struct device *dev, dma_addr_t daddr,
+					   size_t size,
+					   enum dma_data_direction dir)
 {
-	return dma_unmap_single_attrs(dev, cpu_addr, size, dir, NULL);
+	dma_ops->sync_single_for_cpu(dev, daddr, size, dir);
 }
-#define dma_unmap_sg_attrs	platform_dma_unmap_sg_attrs
-static inline void dma_unmap_sg(struct device *dev, struct scatterlist *sgl,
-				int nents, int dir)
+
+static inline void dma_sync_sg_for_cpu(struct device *dev,
+				       struct scatterlist *sgl,
+				       int nents, enum dma_data_direction dir)
 {
-	return dma_unmap_sg_attrs(dev, sgl, nents, dir, NULL);
+	dma_ops->sync_sg_for_cpu(dev, sgl, nents, dir);
+}
+
+static inline void dma_sync_single_for_device(struct device *dev,
+					      dma_addr_t daddr,
+					      size_t size,
+					      enum dma_data_direction dir)
+{
+	dma_ops->sync_single_for_device(dev, daddr, size, dir);
+}
+
+static inline void dma_sync_sg_for_device(struct device *dev,
+					  struct scatterlist *sgl,
+					  int nents,
+					  enum dma_data_direction dir)
+{
+	dma_ops->sync_sg_for_device(dev, sgl, nents, dir);
+}
+
+static inline int dma_mapping_error(struct device *dev, dma_addr_t daddr)
+{
+	return dma_ops->mapping_error(dev, daddr);
 }
-#define dma_sync_single_for_cpu	platform_dma_sync_single_for_cpu
-#define dma_sync_sg_for_cpu	platform_dma_sync_sg_for_cpu
-#define dma_sync_single_for_device platform_dma_sync_single_for_device
-#define dma_sync_sg_for_device	platform_dma_sync_sg_for_device
-#define dma_mapping_error	platform_dma_mapping_error
 
 #define dma_map_page(dev, pg, off, size, dir)				\
 	dma_map_single(dev, page_address(pg) + (off), (size), (dir))
@@ -127,7 +167,10 @@ static inline void dma_unmap_sg(struct device *dev, struct scatterlist *sgl,
 #define dma_sync_single_range_for_device(dev, dma_handle, offset, size, dir)	\
 	dma_sync_single_for_device(dev, dma_handle, size, dir)
 
-#define dma_supported		platform_dma_supported
+static inline int dma_supported(struct device *dev, u64 mask)
+{
+	return dma_ops->dma_supported_op(dev, mask);
+}
 
 static inline int
 dma_set_mask (struct device *dev, u64 mask)
@@ -158,6 +201,4 @@ static inline struct dma_mapping_ops *get_dma_ops(struct device *dev)
 	return dma_ops;
 }
 
-
-
 #endif /* _ASM_IA64_DMA_MAPPING_H */
-- 
1.6.0.6

