From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Date: Mon, 05 Jan 2009 14:36:18 +0000
Subject: [PATCH 13/13] make sba DMA mapping functions static
Message-Id: <1231166178-20050-14-git-send-email-fujita.tomonori@lab.ntt.co.jp>
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
 <1231166178-20050-13-git-send-email-fujita.tomonori@lab.ntt.co.jp>
In-Reply-To: <1231166178-20050-13-git-send-email-fujita.tomonori@lab.ntt.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>

Now we don't need to export these DMA mapping functions.

Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
---
 arch/ia64/hp/common/sba_iommu.c |   34 ++++++++++++----------------------
 1 files changed, 12 insertions(+), 22 deletions(-)

diff --git a/arch/ia64/hp/common/sba_iommu.c b/arch/ia64/hp/common/sba_iommu.c
index e82870a..29e7206 100644
--- a/arch/ia64/hp/common/sba_iommu.c
+++ b/arch/ia64/hp/common/sba_iommu.c
@@ -909,7 +909,7 @@ sba_mark_invalid(struct ioc *ioc, dma_addr_t iova, size_t byte_cnt)
  *
  * See Documentation/DMA-mapping.txt
  */
-dma_addr_t
+static dma_addr_t
 sba_map_single_attrs(struct device *dev, void *addr, size_t size, int dir,
 		     struct dma_attrs *attrs)
 {
@@ -991,7 +991,6 @@ sba_map_single_attrs(struct device *dev, void *addr, size_t size, int dir,
 #endif
 	return SBA_IOVA(ioc, iovp, offset);
 }
-EXPORT_SYMBOL(sba_map_single_attrs);
 
 #ifdef ENABLE_MARK_CLEAN
 static SBA_INLINE void
@@ -1027,8 +1026,8 @@ sba_mark_clean(struct ioc *ioc, dma_addr_t iova, size_t size)
  *
  * See Documentation/DMA-mapping.txt
  */
-void sba_unmap_single_attrs(struct device *dev, dma_addr_t iova, size_t size,
-			    int dir, struct dma_attrs *attrs)
+static void sba_unmap_single_attrs(struct device *dev, dma_addr_t iova, size_t size,
+				   int dir, struct dma_attrs *attrs)
 {
 	struct ioc *ioc;
 #if DELAYED_RESOURCE_CNT > 0
@@ -1095,7 +1094,6 @@ void sba_unmap_single_attrs(struct device *dev, dma_addr_t iova, size_t size,
 	spin_unlock_irqrestore(&ioc->res_lock, flags);
 #endif /* DELAYED_RESOURCE_CNT = 0 */
 }
-EXPORT_SYMBOL(sba_unmap_single_attrs);
 
 /**
  * sba_alloc_coherent - allocate/map shared mem for DMA
@@ -1105,7 +1103,7 @@ EXPORT_SYMBOL(sba_unmap_single_attrs);
  *
  * See Documentation/DMA-mapping.txt
  */
-void *
+static void *
 sba_alloc_coherent (struct device *dev, size_t size, dma_addr_t *dma_handle, gfp_t flags)
 {
 	struct ioc *ioc;
@@ -1168,7 +1166,8 @@ sba_alloc_coherent (struct device *dev, size_t size, dma_addr_t *dma_handle, gfp
  *
  * See Documentation/DMA-mapping.txt
  */
-void sba_free_coherent (struct device *dev, size_t size, void *vaddr, dma_addr_t dma_handle)
+static void sba_free_coherent (struct device *dev, size_t size, void *vaddr,
+			       dma_addr_t dma_handle)
 {
 	sba_unmap_single_attrs(dev, dma_handle, size, 0, NULL);
 	free_pages((unsigned long) vaddr, get_order(size));
@@ -1423,8 +1422,8 @@ sba_coalesce_chunks(struct ioc *ioc, struct device *dev,
  *
  * See Documentation/DMA-mapping.txt
  */
-int sba_map_sg_attrs(struct device *dev, struct scatterlist *sglist, int nents,
-		     int dir, struct dma_attrs *attrs)
+static int sba_map_sg_attrs(struct device *dev, struct scatterlist *sglist,
+			    int nents, int dir, struct dma_attrs *attrs)
 {
 	struct ioc *ioc;
 	int coalesced, filled = 0;
@@ -1503,7 +1502,6 @@ int sba_map_sg_attrs(struct device *dev, struct scatterlist *sglist, int nents,
 
 	return filled;
 }
-EXPORT_SYMBOL(sba_map_sg_attrs);
 
 /**
  * sba_unmap_sg_attrs - unmap Scatter/Gather list
@@ -1515,8 +1513,8 @@ EXPORT_SYMBOL(sba_map_sg_attrs);
  *
  * See Documentation/DMA-mapping.txt
  */
-void sba_unmap_sg_attrs(struct device *dev, struct scatterlist *sglist,
-			int nents, int dir, struct dma_attrs *attrs)
+static void sba_unmap_sg_attrs(struct device *dev, struct scatterlist *sglist,
+			       int nents, int dir, struct dma_attrs *attrs)
 {
 #ifdef ASSERT_PDIR_SANITY
 	struct ioc *ioc;
@@ -1552,7 +1550,6 @@ void sba_unmap_sg_attrs(struct device *dev, struct scatterlist *sglist,
 #endif
 
 }
-EXPORT_SYMBOL(sba_unmap_sg_attrs);
 
 /**************************************************************
 *
@@ -2143,15 +2140,13 @@ nosbagart(char *str)
 	return 1;
 }
 
-int
-sba_dma_supported (struct device *dev, u64 mask)
+static int sba_dma_supported (struct device *dev, u64 mask)
 {
 	/* make sure it's at least 32bit capable */
 	return ((mask & 0xFFFFFFFFUL) = 0xFFFFFFFFUL);
 }
 
-int
-sba_dma_mapping_error(struct device *dev, dma_addr_t dma_addr)
+static int sba_dma_mapping_error(struct device *dev, dma_addr_t dma_addr)
 {
 	return 0;
 }
@@ -2181,11 +2176,6 @@ sba_page_override(char *str)
 
 __setup("sbapagesize=",sba_page_override);
 
-EXPORT_SYMBOL(sba_dma_mapping_error);
-EXPORT_SYMBOL(sba_dma_supported);
-EXPORT_SYMBOL(sba_alloc_coherent);
-EXPORT_SYMBOL(sba_free_coherent);
-
 struct dma_mapping_ops sba_dma_ops = {
 	.alloc_coherent		= sba_alloc_coherent,
 	.free_coherent		= sba_free_coherent,
-- 
1.6.0.6

