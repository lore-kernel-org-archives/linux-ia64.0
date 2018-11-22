From: Christoph Hellwig <hch@lst.de>
Date: Thu, 22 Nov 2018 14:02:58 +0000
Subject: [PATCH 02/24] swiotlb: Skip cache maintenance on map error
Message-Id: <20181122140320.24080-3-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20181122140320.24080-1-hch@lst.de>
In-Reply-To: <20181122140320.24080-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: iommu@lists.linux-foundation.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Jon Mason <jdmason@kudzu.us>, Joerg Roedel <joro@8bytes.org>, David Woodhouse <dwmw2@infradead.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Robin Murphy <robin.murphy@arm.com>, x86@kernel.org, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, xen-devel@lists.xenproject.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

From: Robin Murphy <robin.murphy@arm.com>

If swiotlb_bounce_page() failed, calling arch_sync_dma_for_device() may
lead to such delights as performing cache maintenance on whatever
address phys_to_virt(SWIOTLB_MAP_ERROR) looks like, which is typically
outside the kernel memory map and goes about as well as expected.

Don't do that.

Fixes: a4a4330db46a ("swiotlb: add support for non-coherent DMA")
Tested-by: John Stultz <john.stultz@linaro.org>
Signed-off-by: Robin Murphy <robin.murphy@arm.com>
Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 kernel/dma/swiotlb.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/kernel/dma/swiotlb.c b/kernel/dma/swiotlb.c
index 5731daa09a32..045930e32c0e 100644
--- a/kernel/dma/swiotlb.c
+++ b/kernel/dma/swiotlb.c
@@ -679,7 +679,8 @@ dma_addr_t swiotlb_map_page(struct device *dev, struct page *page,
 	}
 
 	if (!dev_is_dma_coherent(dev) &&
-	    (attrs & DMA_ATTR_SKIP_CPU_SYNC) = 0)
+	    (attrs & DMA_ATTR_SKIP_CPU_SYNC) = 0 &&
+	    dev_addr != DIRECT_MAPPING_ERROR)
 		arch_sync_dma_for_device(dev, phys, size, dir);
 
 	return dev_addr;
-- 
2.19.1
