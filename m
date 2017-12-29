From: Christoph Hellwig <hch@lst.de>
Date: Fri, 29 Dec 2017 08:19:04 +0000
Subject: [PATCH 60/67] tile: replace ZONE_DMA with ZONE_DMA32
Message-Id: <20171229081911.2802-61-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20171229081911.2802-1-hch@lst.de>
In-Reply-To: <20171229081911.2802-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: iommu@lists.linux-foundation.org
Cc: linux-alpha@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, adi-buildroot-devel@lists.sourceforge.net, linux-c6x-dev@linux-c6x.org, linux-cris-kernel@axis.com, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-metag@vger.kernel.org, Michal Simek <monstr@monstr.eu>, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, patches@groups.riscv.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, Guan Xuetao <gxt@mprc.pku.edu.cn>, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

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
index 9072e2c25e59..a9b48520eeb9 100644
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
 
@@ -515,7 +515,7 @@ static void *tile_swiotlb_alloc_coherent(struct device *dev, size_t size,
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

