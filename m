From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Date: Mon, 08 Sep 2008 09:10:13 +0000
Subject: [PATCH 4/5] x86: dma_alloc_coherent sets gfp flags properly
Message-Id: <1220865014-1169-5-git-send-email-fujita.tomonori@lab.ntt.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <1220865014-1169-1-git-send-email-fujita.tomonori@lab.ntt.co.jp>
 <1220865014-1169-2-git-send-email-fujita.tomonori@lab.ntt.co.jp>
 <1220865014-1169-3-git-send-email-fujita.tomonori@lab.ntt.co.jp>
 <1220865014-1169-4-git-send-email-fujita.tomonori@lab.ntt.co.jp>
In-Reply-To: <1220865014-1169-4-git-send-email-fujita.tomonori@lab.ntt.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: mingo@redhat.com, joerg.roedel@amd.com, tony.luck@intel.com, linux-ia64@vger.kernel.org, iommu@lists.linux-foundation.org, fujita.tomonori@lab.ntt.co.jp

Non real IOMMU implemenations (which doesn't do virtual mappings,
e.g. swiotlb, pci-nommu, etc) need to use proper gfp flags and
dma_mask to allocate pages in their own dma_alloc_coherent()
(allocated page need to be suitable for device's coherent_dma_mask).

This patch makes dma_alloc_coherent do this job so that IOMMUs don't
need to take care of it any more.

Real IOMMU implemenataions can simply ignore the gfp flags.

Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
---
 arch/x86/kernel/pci-nommu.c   |   19 ++-----------------
 include/asm-x86/dma-mapping.h |   32 ++++++++++++++++++++++++++++----
 2 files changed, 30 insertions(+), 21 deletions(-)

diff --git a/arch/x86/kernel/pci-nommu.c b/arch/x86/kernel/pci-nommu.c
index ada1c87..8e398b5 100644
--- a/arch/x86/kernel/pci-nommu.c
+++ b/arch/x86/kernel/pci-nommu.c
@@ -80,26 +80,11 @@ nommu_alloc_coherent(struct device *hwdev, size_t size,
 	int node;
 	struct page *page;
 
-	gfp |= __GFP_ZERO;
-
-	dma_mask = hwdev->coherent_dma_mask;
-	if (!dma_mask)
-		dma_mask = *(hwdev->dma_mask);
+	dma_mask = dma_alloc_coherent_mask(hwdev, gfp);
 
-	if (dma_mask < DMA_24BIT_MASK)
-		return NULL;
+	gfp |= __GFP_ZERO;
 
 	node = dev_to_node(hwdev);
-
-#ifdef CONFIG_X86_64
-	if (dma_mask <= DMA_32BIT_MASK && !(gfp & GFP_DMA))
-		gfp |= GFP_DMA32;
-#endif
-
-	/* No alloc-free penalty for ISA devices */
-	if (dma_mask = DMA_24BIT_MASK)
-		gfp |= GFP_DMA;
-
 again:
 	page = alloc_pages_node(node, gfp, get_order(size));
 	if (!page)
diff --git a/include/asm-x86/dma-mapping.h b/include/asm-x86/dma-mapping.h
index 9d6dcf4..a072ae6 100644
--- a/include/asm-x86/dma-mapping.h
+++ b/include/asm-x86/dma-mapping.h
@@ -241,6 +241,29 @@ static inline int dma_get_cache_alignment(void)
 	return boot_cpu_data.x86_clflush_size;
 }
 
+static inline unsigned long dma_alloc_coherent_mask(struct device *dev,
+						    gfp_t gfp)
+{
+	unsigned long dma_mask = 0;
+
+	dma_mask = dev->coherent_dma_mask;
+	if (!dma_mask)
+		dma_mask = (gfp & GFP_DMA) ? DMA_24BIT_MASK : DMA_32BIT_MASK;
+
+	return dma_mask;
+}
+
+static inline gfp_t dma_alloc_coherent_gfp_flags(struct device *dev, gfp_t gfp)
+{
+	unsigned long dma_mask = dma_alloc_coherent_mask(dev, gfp);
+
+#ifdef CONFIG_X86_64
+	if (dma_mask <= DMA_32BIT_MASK && !(gfp & GFP_DMA))
+		gfp |= GFP_DMA32;
+#endif
+       return gfp;
+}
+
 static inline void *
 dma_alloc_coherent(struct device *dev, size_t size, dma_addr_t *dma_handle,
 		gfp_t gfp)
@@ -261,10 +284,11 @@ dma_alloc_coherent(struct device *dev, size_t size, dma_addr_t *dma_handle,
 	if (!dev->dma_mask)
 		return NULL;
 
-	if (ops->alloc_coherent)
-		return ops->alloc_coherent(dev, size,
-				dma_handle, gfp);
-	return NULL;
+	if (!ops->alloc_coherent)
+		return NULL;
+
+	return ops->alloc_coherent(dev, size, dma_handle,
+				   dma_alloc_coherent_gfp_flags(dev, gfp));
 }
 
 static inline void dma_free_coherent(struct device *dev, size_t size,
-- 
1.5.5.GIT

