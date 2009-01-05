From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Date: Mon, 05 Jan 2009 14:36:17 +0000
Subject: [PATCH 12/13] remove hwsw_dma_ops
Message-Id: <1231166178-20050-13-git-send-email-fujita.tomonori@lab.ntt.co.jp>
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
 <1231166178-20050-12-git-send-email-fujita.tomonori@lab.ntt.co.jp>
In-Reply-To: <1231166178-20050-12-git-send-email-fujita.tomonori@lab.ntt.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>

This removes remove hwsw_dma_ops (and hwsw_*
functions). hwsw_dma_get_ops can select swiotlb_dma_ops and
sba_dma_ops appropriately.

Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
---
 arch/ia64/hp/common/hwsw_iommu.c              |  183 ++-----------------------
 arch/ia64/include/asm/machvec_hpzx1_swiotlb.h |    2 +
 2 files changed, 14 insertions(+), 171 deletions(-)

diff --git a/arch/ia64/hp/common/hwsw_iommu.c b/arch/ia64/hp/common/hwsw_iommu.c
index 5cf750e..e5bbeba 100644
--- a/arch/ia64/hp/common/hwsw_iommu.c
+++ b/arch/ia64/hp/common/hwsw_iommu.c
@@ -17,55 +17,33 @@
 #include <linux/swiotlb.h>
 #include <asm/machvec.h>
 
+extern struct dma_mapping_ops sba_dma_ops, swiotlb_dma_ops;
+
 /* swiotlb declarations & definitions: */
 extern int swiotlb_late_init_with_default_size (size_t size);
 
-/* hwiommu declarations & definitions: */
-
-extern void *sba_alloc_coherent(struct device *, size_t, dma_addr_t *, gfp_t);
-extern void sba_free_coherent (struct device *, size_t, void *, dma_addr_t);
-extern dma_addr_t sba_map_single_attrs(struct device *, void *, size_t, int,
-				       struct dma_attrs *);
-extern void sba_unmap_single_attrs(struct device *, dma_addr_t, size_t, int,
-				   struct dma_attrs *);
-extern int sba_map_sg_attrs(struct device *, struct scatterlist *, int, int,
-			    struct dma_attrs *);
-extern void sba_unmap_sg_attrs(struct device *, struct scatterlist *, int, int,
-			       struct dma_attrs *);
-extern int sba_dma_supported (struct device *, u64);
-extern int sba_dma_mapping_error(struct device *, dma_addr_t);
-
-#define hwiommu_alloc_coherent		sba_alloc_coherent
-#define hwiommu_free_coherent		sba_free_coherent
-#define hwiommu_map_single_attrs	sba_map_single_attrs
-#define hwiommu_unmap_single_attrs	sba_unmap_single_attrs
-#define hwiommu_map_sg_attrs		sba_map_sg_attrs
-#define hwiommu_unmap_sg_attrs		sba_unmap_sg_attrs
-#define hwiommu_dma_supported		sba_dma_supported
-#define hwiommu_dma_mapping_error	sba_dma_mapping_error
-#define hwiommu_sync_single_for_cpu	machvec_dma_sync_single
-#define hwiommu_sync_sg_for_cpu		machvec_dma_sync_sg
-#define hwiommu_sync_single_for_device	machvec_dma_sync_single
-#define hwiommu_sync_sg_for_device	machvec_dma_sync_sg
-
-
 /*
  * Note: we need to make the determination of whether or not to use
  * the sw I/O TLB based purely on the device structure.  Anything else
  * would be unreliable or would be too intrusive.
  */
-static inline int
-use_swiotlb (struct device *dev)
+static inline int use_swiotlb(struct device *dev)
 {
-	return dev && dev->dma_mask && !hwiommu_dma_supported(dev, *dev->dma_mask);
+	return dev && dev->dma_mask &&
+		!sba_dma_ops.dma_supported_op(dev, *dev->dma_mask);
 }
 
-struct dma_mapping_ops hwsw_dma_ops;
+struct dma_mapping_ops *hwsw_dma_get_ops(struct device *dev)
+{
+	if (use_swiotlb(dev))
+		return &swiotlb_dma_ops;
+	return &sba_dma_ops;
+}
+EXPORT_SYMBOL(hwsw_dma_get_ops);
 
 void __init
 hwsw_init (void)
 {
-	dma_ops = &hwsw_dma_ops;
 	/* default to a smallish 2MB sw I/O TLB */
 	if (swiotlb_late_init_with_default_size (2 * (1<<20)) != 0) {
 #ifdef CONFIG_IA64_GENERIC
@@ -78,140 +56,3 @@ hwsw_init (void)
 #endif
 	}
 }
-
-void *
-hwsw_alloc_coherent (struct device *dev, size_t size, dma_addr_t *dma_handle, gfp_t flags)
-{
-	if (use_swiotlb(dev))
-		return swiotlb_alloc_coherent(dev, size, dma_handle, flags);
-	else
-		return hwiommu_alloc_coherent(dev, size, dma_handle, flags);
-}
-
-void
-hwsw_free_coherent (struct device *dev, size_t size, void *vaddr, dma_addr_t dma_handle)
-{
-	if (use_swiotlb(dev))
-		swiotlb_free_coherent(dev, size, vaddr, dma_handle);
-	else
-		hwiommu_free_coherent(dev, size, vaddr, dma_handle);
-}
-
-dma_addr_t
-hwsw_map_single_attrs(struct device *dev, void *addr, size_t size, int dir,
-		       struct dma_attrs *attrs)
-{
-	if (use_swiotlb(dev))
-		return swiotlb_map_single_attrs(dev, addr, size, dir, attrs);
-	else
-		return hwiommu_map_single_attrs(dev, addr, size, dir, attrs);
-}
-EXPORT_SYMBOL(hwsw_map_single_attrs);
-
-void
-hwsw_unmap_single_attrs(struct device *dev, dma_addr_t iova, size_t size,
-			 int dir, struct dma_attrs *attrs)
-{
-	if (use_swiotlb(dev))
-		return swiotlb_unmap_single_attrs(dev, iova, size, dir, attrs);
-	else
-		return hwiommu_unmap_single_attrs(dev, iova, size, dir, attrs);
-}
-EXPORT_SYMBOL(hwsw_unmap_single_attrs);
-
-int
-hwsw_map_sg_attrs(struct device *dev, struct scatterlist *sglist, int nents,
-		   int dir, struct dma_attrs *attrs)
-{
-	if (use_swiotlb(dev))
-		return swiotlb_map_sg_attrs(dev, sglist, nents, dir, attrs);
-	else
-		return hwiommu_map_sg_attrs(dev, sglist, nents, dir, attrs);
-}
-EXPORT_SYMBOL(hwsw_map_sg_attrs);
-
-void
-hwsw_unmap_sg_attrs(struct device *dev, struct scatterlist *sglist, int nents,
-		     int dir, struct dma_attrs *attrs)
-{
-	if (use_swiotlb(dev))
-		return swiotlb_unmap_sg_attrs(dev, sglist, nents, dir, attrs);
-	else
-		return hwiommu_unmap_sg_attrs(dev, sglist, nents, dir, attrs);
-}
-EXPORT_SYMBOL(hwsw_unmap_sg_attrs);
-
-void
-hwsw_sync_single_for_cpu (struct device *dev, dma_addr_t addr, size_t size, int dir)
-{
-	if (use_swiotlb(dev))
-		swiotlb_sync_single_for_cpu(dev, addr, size, dir);
-	else
-		hwiommu_sync_single_for_cpu(dev, addr, size, dir);
-}
-
-void
-hwsw_sync_sg_for_cpu (struct device *dev, struct scatterlist *sg, int nelems, int dir)
-{
-	if (use_swiotlb(dev))
-		swiotlb_sync_sg_for_cpu(dev, sg, nelems, dir);
-	else
-		hwiommu_sync_sg_for_cpu(dev, sg, nelems, dir);
-}
-
-void
-hwsw_sync_single_for_device (struct device *dev, dma_addr_t addr, size_t size, int dir)
-{
-	if (use_swiotlb(dev))
-		swiotlb_sync_single_for_device(dev, addr, size, dir);
-	else
-		hwiommu_sync_single_for_device(dev, addr, size, dir);
-}
-
-void
-hwsw_sync_sg_for_device (struct device *dev, struct scatterlist *sg, int nelems, int dir)
-{
-	if (use_swiotlb(dev))
-		swiotlb_sync_sg_for_device(dev, sg, nelems, dir);
-	else
-		hwiommu_sync_sg_for_device(dev, sg, nelems, dir);
-}
-
-int
-hwsw_dma_supported (struct device *dev, u64 mask)
-{
-	if (hwiommu_dma_supported(dev, mask))
-		return 1;
-	return swiotlb_dma_supported(dev, mask);
-}
-
-int
-hwsw_dma_mapping_error(struct device *dev, dma_addr_t dma_addr)
-{
-	return hwiommu_dma_mapping_error(dev, dma_addr) ||
-		swiotlb_dma_mapping_error(dev, dma_addr);
-}
-
-EXPORT_SYMBOL(hwsw_dma_mapping_error);
-EXPORT_SYMBOL(hwsw_dma_supported);
-EXPORT_SYMBOL(hwsw_alloc_coherent);
-EXPORT_SYMBOL(hwsw_free_coherent);
-EXPORT_SYMBOL(hwsw_sync_single_for_cpu);
-EXPORT_SYMBOL(hwsw_sync_single_for_device);
-EXPORT_SYMBOL(hwsw_sync_sg_for_cpu);
-EXPORT_SYMBOL(hwsw_sync_sg_for_device);
-
-struct dma_mapping_ops hwsw_dma_ops = {
-	.alloc_coherent		= hwsw_alloc_coherent,
-	.free_coherent		= hwsw_free_coherent,
-	.map_single_attrs	= hwsw_map_single_attrs,
-	.unmap_single_attrs	= hwsw_unmap_single_attrs,
-	.map_sg_attrs		= hwsw_map_sg_attrs,
-	.unmap_sg_attrs		= hwsw_unmap_sg_attrs,
-	.sync_single_for_cpu	= hwsw_sync_single_for_cpu,
-	.sync_sg_for_cpu	= hwsw_sync_sg_for_cpu,
-	.sync_single_for_device	= hwsw_sync_single_for_device,
-	.sync_sg_for_device	= hwsw_sync_sg_for_device,
-	.dma_supported_op	= hwsw_dma_supported,
-	.mapping_error		= hwsw_dma_mapping_error,
-};
diff --git a/arch/ia64/include/asm/machvec_hpzx1_swiotlb.h b/arch/ia64/include/asm/machvec_hpzx1_swiotlb.h
index 48c3a35..1091ac3 100644
--- a/arch/ia64/include/asm/machvec_hpzx1_swiotlb.h
+++ b/arch/ia64/include/asm/machvec_hpzx1_swiotlb.h
@@ -2,6 +2,7 @@
 #define _ASM_IA64_MACHVEC_HPZX1_SWIOTLB_h
 
 extern ia64_mv_setup_t				dig_setup;
+extern ia64_mv_dma_get_ops			hwsw_dma_get_ops;
 
 /*
  * This stuff has dual use!
@@ -13,5 +14,6 @@ extern ia64_mv_setup_t				dig_setup;
 #define platform_name				"hpzx1_swiotlb"
 #define platform_setup				dig_setup
 #define platform_dma_init			machvec_noop
+#define platform_dma_get_ops			hwsw_dma_get_ops
 
 #endif /* _ASM_IA64_MACHVEC_HPZX1_SWIOTLB_h */
-- 
1.6.0.6

