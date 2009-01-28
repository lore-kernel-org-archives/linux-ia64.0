From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Date: Wed, 28 Jan 2009 12:53:16 +0000
Subject: [PATCH -tip 1/3] IA64: fix swiotlb alloc_coherent for non DMA_64BIT_MASK devices
Message-Id: <1233147198-30299-1-git-send-email-fujita.tomonori@lab.ntt.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: mingo@elte.hu, tony.luck@intel.com
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, Yasunori Goto <y-goto@jp.fujitsu.com>

Before the dma ops unification, IA64 always uses GFP_DMA for
dma_alloc_coherent like:

#define dma_alloc_coherent(dev, size, handle, gfp)	\
	platform_dma_alloc_coherent(dev, size, handle, (gfp) | GFP_DMA)

This GFP_DMA enforcement doesn't make sense for IOMMUs since they can
do address translation to give addresses that devices can access
to. The IOMMU drivers ignore the zone flag. However, this is still
necessary for swiotlb since it can't do address translation.

We don't always need to use GFP_DMA for swiotlb. We need GFP_DMA for
devices incapable of 64bit DMA.

This patch is sorta updated version of:

http://marc.info/?l=linux-kernel&m2638215612705&w=2

Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Cc: Yasunori Goto <y-goto@jp.fujitsu.com>
---
 arch/ia64/kernel/pci-swiotlb.c |   10 +++++++++-
 1 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/arch/ia64/kernel/pci-swiotlb.c b/arch/ia64/kernel/pci-swiotlb.c
index 717ad4f..573f02c 100644
--- a/arch/ia64/kernel/pci-swiotlb.c
+++ b/arch/ia64/kernel/pci-swiotlb.c
@@ -13,8 +13,16 @@
 int swiotlb __read_mostly;
 EXPORT_SYMBOL(swiotlb);
 
+static void *ia64_swiotlb_alloc_coherent(struct device *dev, size_t size,
+					 dma_addr_t *dma_handle, gfp_t gfp)
+{
+	if (dev->coherent_dma_mask != DMA_64BIT_MASK)
+		gfp |= GFP_DMA;
+	return swiotlb_alloc_coherent(dev, size, dma_handle, gfp);
+}
+
 struct dma_map_ops swiotlb_dma_ops = {
-	.alloc_coherent = swiotlb_alloc_coherent,
+	.alloc_coherent = ia64_swiotlb_alloc_coherent,
 	.free_coherent = swiotlb_free_coherent,
 	.map_page = swiotlb_map_page,
 	.unmap_page = swiotlb_unmap_page,
-- 
1.6.0.6

