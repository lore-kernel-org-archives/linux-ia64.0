From: Christoph Hellwig <hch@lst.de>
Date: Wed, 10 Jan 2018 08:09:27 +0000
Subject: [PATCH 17/22] tile: replace ZONE_DMA with ZONE_DMA32
Message-Id: <20180110080932.14157-18-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180110080932.14157-1-hch@lst.de>
In-Reply-To: <20180110080932.14157-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: iommu@lists.linux-foundation.org
Cc: Konrad Rzeszutek Wilk <konrad@darnok.org>, Michal Simek <monstr@monstr.eu>, Guan Xuetao <gxt@mprc.pku.edu.cn>, =?UTF-8?q?Christian=20K=C3=B6nig?= <ckoenig.leichtzumerken@gmail.com>, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

tile uses ZONE_DMA for allocations below 32-bits.  These days we
name the zone for that ZONE_DMA32, which will allow to use the
dma-direct and generic swiotlb code as-is, so rename it.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/tile/Kconfig          | 2 +-
 arch/tile/kernel/pci-dma.c | 4 ++--
 arch/tile/kernel/setup.c   | 8 ++++----
 3 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/arch/tile/Kconfig b/arch/tile/Kconfig
index 02f269cfa538..30c586686f29 100644
--- a/arch/tile/Kconfig
+++ b/arch/tile/Kconfig
@@ -249,7 +249,7 @@ config HIGHMEM
 
 	  If unsure, say "true".
 
-config ZONE_DMA
+config ZONE_DMA32
 	def_bool y
 
 config IOMMU_HELPER
diff --git a/arch/tile/kernel/pci-dma.c b/arch/tile/kernel/pci-dma.c
index f2abedc8a080..a267fa740048 100644
--- a/arch/tile/kernel/pci-dma.c
+++ b/arch/tile/kernel/pci-dma.c
@@ -54,7 +54,7 @@ static void *tile_dma_alloc_coherent(struct device *dev, size_t size,
 	 * which case we will return NULL.  But such devices are uncommon.
 	 */
 	if (dma_mask <= DMA_BIT_MASK(32)) {
-		gfp |= GFP_DMA;
+		gfp |= GFP_DMA32;
 		node = 0;
 	}
 
@@ -513,7 +513,7 @@ static void *tile_swiotlb_alloc_coherent(struct device *dev, size_t size,
 					 dma_addr_t *dma_handle, gfp_t gfp,
 					 unsigned long attrs)
 {
-	gfp |= GFP_DMA;
+	gfp |= GFP_DMA32;
 	return swiotlb_alloc_coherent(dev, size, dma_handle, gfp);
 }
 
diff --git a/arch/tile/kernel/setup.c b/arch/tile/kernel/setup.c
index ad83c1e66dbd..eb4e198f6f93 100644
--- a/arch/tile/kernel/setup.c
+++ b/arch/tile/kernel/setup.c
@@ -814,11 +814,11 @@ static void __init zone_sizes_init(void)
 #endif
 
 		if (start < dma_end) {
-			zones_size[ZONE_DMA] = min(zones_size[ZONE_NORMAL],
+			zones_size[ZONE_DMA32] = min(zones_size[ZONE_NORMAL],
 						   dma_end - start);
-			zones_size[ZONE_NORMAL] -= zones_size[ZONE_DMA];
+			zones_size[ZONE_NORMAL] -= zones_size[ZONE_DMA32];
 		} else {
-			zones_size[ZONE_DMA] = 0;
+			zones_size[ZONE_DMA32] = 0;
 		}
 
 		/* Take zone metadata from controller 0 if we're isolnode. */
@@ -830,7 +830,7 @@ static void __init zone_sizes_init(void)
 		       PFN_UP(node_percpu[i]));
 
 		/* Track the type of memory on each node */
-		if (zones_size[ZONE_NORMAL] || zones_size[ZONE_DMA])
+		if (zones_size[ZONE_NORMAL] || zones_size[ZONE_DMA32])
 			node_set_state(i, N_NORMAL_MEMORY);
 #ifdef CONFIG_HIGHMEM
 		if (end != start)
-- 
2.14.2

