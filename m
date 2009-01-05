From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Date: Mon, 05 Jan 2009 14:36:16 +0000
Subject: [PATCH 11/13] add dma_get_ops to struct ia64_machine_vector
Message-Id: <1231166178-20050-12-git-send-email-fujita.tomonori@lab.ntt.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <1231166178-20050-1-git-send-email-fujita.tomonori@lab.ntt.co.jp>
 <1231166178-20050-2-git-send-email-fujita.tomonori@lab.ntt.co.jp>
 <1231166178-20050-3-git-send-email-fujita.tomonori@lab.ntt.co.jp>
 <1231166178-20050-4-git-send-email-fujita.tomonori@lab.ntt.co.jp>
 <1231166178-20050-5-git-send-email-fujita.tomonori@lab.ntt.co.jp>
 <1231166178-20050-6-git-send-email-fujita.tomonori@lab.ntt.co.jp>
 <1231166178-20050-7-git-send-email-fujita.tomonori@lab.ntt.co.jp>
 <1231166178-20050-8-git-send-email-fujita.tomonori@lab.ntt.co.jp>
 <1231166178-20050-9-git-send-email-fujita.tomonori@lab.ntt.co.jp>
 <1231166178-20050-10-git-send-email-fujita.tomonori@lab.ntt.co.jp>
 <1231166178-20050-11-git-send-email-fujita.tomonori@lab.ntt.co.jp>
In-Reply-To: <1231166178-20050-11-git-send-email-fujita.tomonori@lab.ntt.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>

This adds dma_get_ops hook to struct ia64_machine_vector. We use
dma_get_ops() in arch/ia64/kernel/dma-mapping.c, which simply returns
the global dma_ops. This is for removing hwsw_dma_ops.

Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
---
 arch/ia64/include/asm/dma-mapping.h |   41 ++++++++++++++++++++--------------
 arch/ia64/include/asm/machvec.h     |    8 ++++++
 arch/ia64/kernel/dma-mapping.c      |    6 +++++
 arch/ia64/kernel/pci-dma.c          |    2 +-
 4 files changed, 39 insertions(+), 18 deletions(-)

diff --git a/arch/ia64/include/asm/dma-mapping.h b/arch/ia64/include/asm/dma-mapping.h
index 5298f40..bac3159 100644
--- a/arch/ia64/include/asm/dma-mapping.h
+++ b/arch/ia64/include/asm/dma-mapping.h
@@ -68,13 +68,15 @@ extern void set_iommu_machvec(void);
 static inline void *dma_alloc_coherent(struct device *dev, size_t size,
 				       dma_addr_t *daddr, gfp_t gfp)
 {
-	return dma_ops->alloc_coherent(dev, size, daddr, gfp | GFP_DMA);
+	struct dma_mapping_ops *ops = platform_dma_get_ops(dev);
+	return ops->alloc_coherent(dev, size, daddr, gfp | GFP_DMA);
 }
 
 static inline void dma_free_coherent(struct device *dev, size_t size,
 				     void *caddr, dma_addr_t daddr)
 {
-	dma_ops->free_coherent(dev, size, caddr, daddr);
+	struct dma_mapping_ops *ops = platform_dma_get_ops(dev);
+	ops->free_coherent(dev, size, caddr, daddr);
 }
 
 #define dma_alloc_noncoherent(d, s, h, f) dma_alloc_coherent(d, s, h, f)
@@ -85,7 +87,8 @@ static inline dma_addr_t dma_map_single_attrs(struct device *dev,
 					      enum dma_data_direction dir,
 					      struct dma_attrs *attrs)
 {
-	return dma_ops->map_single_attrs(dev, caddr, size, dir, attrs);
+	struct dma_mapping_ops *ops = platform_dma_get_ops(dev);
+	return ops->map_single_attrs(dev, caddr, size, dir, attrs);
 }
 
 static inline void dma_unmap_single_attrs(struct device *dev, dma_addr_t daddr,
@@ -93,7 +96,8 @@ static inline void dma_unmap_single_attrs(struct device *dev, dma_addr_t daddr,
 					  enum dma_data_direction dir,
 					  struct dma_attrs *attrs)
 {
-	dma_ops->unmap_single_attrs(dev, daddr, size, dir, attrs);
+	struct dma_mapping_ops *ops = platform_dma_get_ops(dev);
+	ops->unmap_single_attrs(dev, daddr, size, dir, attrs);
 }
 
 #define dma_map_single(d, a, s, r) dma_map_single_attrs(d, a, s, r, NULL)
@@ -103,7 +107,8 @@ static inline int dma_map_sg_attrs(struct device *dev, struct scatterlist *sgl,
 				   int nents, enum dma_data_direction dir,
 				   struct dma_attrs *attrs)
 {
-	return dma_ops->map_sg_attrs(dev, sgl, nents, dir, attrs);
+	struct dma_mapping_ops *ops = platform_dma_get_ops(dev);
+	return ops->map_sg_attrs(dev, sgl, nents, dir, attrs);
 }
 
 static inline void dma_unmap_sg_attrs(struct device *dev,
@@ -111,7 +116,8 @@ static inline void dma_unmap_sg_attrs(struct device *dev,
 				      enum dma_data_direction dir,
 				      struct dma_attrs *attrs)
 {
-	dma_ops->unmap_sg_attrs(dev, sgl, nents, dir, attrs);
+	struct dma_mapping_ops *ops = platform_dma_get_ops(dev);
+	ops->unmap_sg_attrs(dev, sgl, nents, dir, attrs);
 }
 
 #define dma_map_sg(d, s, n, r) dma_map_sg_attrs(d, s, n, r, NULL)
@@ -121,14 +127,16 @@ static inline void dma_sync_single_for_cpu(struct device *dev, dma_addr_t daddr,
 					   size_t size,
 					   enum dma_data_direction dir)
 {
-	dma_ops->sync_single_for_cpu(dev, daddr, size, dir);
+	struct dma_mapping_ops *ops = platform_dma_get_ops(dev);
+	ops->sync_single_for_cpu(dev, daddr, size, dir);
 }
 
 static inline void dma_sync_sg_for_cpu(struct device *dev,
 				       struct scatterlist *sgl,
 				       int nents, enum dma_data_direction dir)
 {
-	dma_ops->sync_sg_for_cpu(dev, sgl, nents, dir);
+	struct dma_mapping_ops *ops = platform_dma_get_ops(dev);
+	ops->sync_sg_for_cpu(dev, sgl, nents, dir);
 }
 
 static inline void dma_sync_single_for_device(struct device *dev,
@@ -136,7 +144,8 @@ static inline void dma_sync_single_for_device(struct device *dev,
 					      size_t size,
 					      enum dma_data_direction dir)
 {
-	dma_ops->sync_single_for_device(dev, daddr, size, dir);
+	struct dma_mapping_ops *ops = platform_dma_get_ops(dev);
+	ops->sync_single_for_device(dev, daddr, size, dir);
 }
 
 static inline void dma_sync_sg_for_device(struct device *dev,
@@ -144,12 +153,14 @@ static inline void dma_sync_sg_for_device(struct device *dev,
 					  int nents,
 					  enum dma_data_direction dir)
 {
-	dma_ops->sync_sg_for_device(dev, sgl, nents, dir);
+	struct dma_mapping_ops *ops = platform_dma_get_ops(dev);
+	ops->sync_sg_for_device(dev, sgl, nents, dir);
 }
 
 static inline int dma_mapping_error(struct device *dev, dma_addr_t daddr)
 {
-	return dma_ops->mapping_error(dev, daddr);
+	struct dma_mapping_ops *ops = platform_dma_get_ops(dev);
+	return ops->mapping_error(dev, daddr);
 }
 
 #define dma_map_page(dev, pg, off, size, dir)				\
@@ -169,7 +180,8 @@ static inline int dma_mapping_error(struct device *dev, dma_addr_t daddr)
 
 static inline int dma_supported(struct device *dev, u64 mask)
 {
-	return dma_ops->dma_supported_op(dev, mask);
+	struct dma_mapping_ops *ops = platform_dma_get_ops(dev);
+	return ops->dma_supported_op(dev, mask);
 }
 
 static inline int
@@ -196,9 +208,4 @@ dma_cache_sync (struct device *dev, void *vaddr, size_t size,
 
 #define dma_is_consistent(d, h)	(1)	/* all we do is coherent memory... */
 
-static inline struct dma_mapping_ops *get_dma_ops(struct device *dev)
-{
-	return dma_ops;
-}
-
 #endif /* _ASM_IA64_DMA_MAPPING_H */
diff --git a/arch/ia64/include/asm/machvec.h b/arch/ia64/include/asm/machvec.h
index 6be3010..95e1708 100644
--- a/arch/ia64/include/asm/machvec.h
+++ b/arch/ia64/include/asm/machvec.h
@@ -45,6 +45,7 @@ typedef void ia64_mv_kernel_launch_event_t(void);
 
 /* DMA-mapping interface: */
 typedef void ia64_mv_dma_init (void);
+typedef struct dma_mapping_ops *ia64_mv_dma_get_ops(struct device *);
 
 /*
  * WARNING: The legacy I/O space is _architected_.  Platforms are
@@ -130,6 +131,7 @@ extern void machvec_tlb_migrate_finish (struct mm_struct *);
 #  define platform_global_tlb_purge	ia64_mv.global_tlb_purge
 #  define platform_tlb_migrate_finish	ia64_mv.tlb_migrate_finish
 #  define platform_dma_init		ia64_mv.dma_init
+#  define platform_dma_get_ops		ia64_mv.dma_get_ops
 #  define platform_irq_to_vector	ia64_mv.irq_to_vector
 #  define platform_local_vector_to_irq	ia64_mv.local_vector_to_irq
 #  define platform_pci_get_legacy_mem	ia64_mv.pci_get_legacy_mem
@@ -172,6 +174,7 @@ struct ia64_machine_vector {
 	ia64_mv_global_tlb_purge_t *global_tlb_purge;
 	ia64_mv_tlb_migrate_finish_t *tlb_migrate_finish;
 	ia64_mv_dma_init *dma_init;
+	ia64_mv_dma_get_ops *dma_get_ops;
 	ia64_mv_irq_to_vector *irq_to_vector;
 	ia64_mv_local_vector_to_irq *local_vector_to_irq;
 	ia64_mv_pci_get_legacy_mem_t *pci_get_legacy_mem;
@@ -210,6 +213,7 @@ struct ia64_machine_vector {
 	platform_global_tlb_purge,		\
 	platform_tlb_migrate_finish,		\
 	platform_dma_init,			\
+	platform_dma_get_ops,			\
 	platform_irq_to_vector,			\
 	platform_local_vector_to_irq,		\
 	platform_pci_get_legacy_mem,		\
@@ -246,6 +250,7 @@ extern void machvec_init_from_cmdline(const char *cmdline);
 # endif /* CONFIG_IA64_GENERIC */
 
 extern void swiotlb_dma_init(void);
+extern struct dma_mapping_ops *dma_get_ops(struct device *);
 
 /*
  * Define default versions so we can extend machvec for new platforms without having
@@ -279,6 +284,9 @@ extern void swiotlb_dma_init(void);
 #ifndef platform_dma_init
 # define platform_dma_init		swiotlb_dma_init
 #endif
+#ifndef platform_dma_get_ops
+# define platform_dma_get_ops		dma_get_ops
+#endif
 #ifndef platform_irq_to_vector
 # define platform_irq_to_vector		__ia64_irq_to_vector
 #endif
diff --git a/arch/ia64/kernel/dma-mapping.c b/arch/ia64/kernel/dma-mapping.c
index 876665a..427f696 100644
--- a/arch/ia64/kernel/dma-mapping.c
+++ b/arch/ia64/kernel/dma-mapping.c
@@ -2,3 +2,9 @@
 
 struct dma_mapping_ops *dma_ops;
 EXPORT_SYMBOL(dma_ops);
+
+struct dma_mapping_ops *dma_get_ops(struct device *dev)
+{
+	return dma_ops;
+}
+EXPORT_SYMBOL(dma_get_ops);
diff --git a/arch/ia64/kernel/pci-dma.c b/arch/ia64/kernel/pci-dma.c
index 1c1224b..640669e 100644
--- a/arch/ia64/kernel/pci-dma.c
+++ b/arch/ia64/kernel/pci-dma.c
@@ -81,7 +81,7 @@ iommu_dma_init(void)
 
 int iommu_dma_supported(struct device *dev, u64 mask)
 {
-	struct dma_mapping_ops *ops = get_dma_ops(dev);
+	struct dma_mapping_ops *ops = platform_dma_get_ops(dev);
 
 	if (ops->dma_supported_op)
 		return ops->dma_supported_op(dev, mask);
-- 
1.6.0.6

