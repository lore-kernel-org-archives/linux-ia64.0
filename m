From: Christoph Hellwig <hch@lst.de>
Date: Fri, 07 Dec 2018 19:07:12 +0000
Subject: [PATCH 07/15] dma-mapping: merge dma_unmap_page_attrs and dma_unmap_single_attrs
Message-Id: <20181207190720.18517-8-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20181207190720.18517-1-hch@lst.de>
In-Reply-To: <20181207190720.18517-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: iommu@lists.linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>, Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Tariq Toukan <tariqt@mellanox.com>, Ilias Apalodimas <ilias.apalodimas@linaro.org>, =?UTF-8?q?Toke=20H=C3=B8iland-J=C3=B8rgensen?= <toke@toke.dk>, Robin Murphy <robin.murphy@arm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Keith Busch <keith.busch@intel.com>, Jonathan Derrick <jonathan.derrick@intel.com>, linux-pci@vger.kernel.org, linux-ia64@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org

The two functions are exactly the same, so don't bother implementing
them twice.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 include/linux/dma-mapping.h | 19 ++++++-------------
 1 file changed, 6 insertions(+), 13 deletions(-)

diff --git a/include/linux/dma-mapping.h b/include/linux/dma-mapping.h
index 8916499d2805..3b431cc58794 100644
--- a/include/linux/dma-mapping.h
+++ b/include/linux/dma-mapping.h
@@ -253,6 +253,12 @@ static inline void dma_unmap_single_attrs(struct device *dev, dma_addr_t addr,
 	debug_dma_unmap_page(dev, addr, size, dir, true);
 }
 
+static inline void dma_unmap_page_attrs(struct device *dev, dma_addr_t addr,
+		size_t size, enum dma_data_direction dir, unsigned long attrs)
+{
+	return dma_unmap_single_attrs(dev, addr, size, dir, attrs);
+}
+
 /*
  * dma_maps_sg_attrs returns 0 on error and > 0 on success.
  * It should never return a value < 0.
@@ -300,19 +306,6 @@ static inline dma_addr_t dma_map_page_attrs(struct device *dev,
 	return addr;
 }
 
-static inline void dma_unmap_page_attrs(struct device *dev,
-					dma_addr_t addr, size_t size,
-					enum dma_data_direction dir,
-					unsigned long attrs)
-{
-	const struct dma_map_ops *ops = get_dma_ops(dev);
-
-	BUG_ON(!valid_dma_direction(dir));
-	if (ops->unmap_page)
-		ops->unmap_page(dev, addr, size, dir, attrs);
-	debug_dma_unmap_page(dev, addr, size, dir, false);
-}
-
 static inline dma_addr_t dma_map_resource(struct device *dev,
 					  phys_addr_t phys_addr,
 					  size_t size,
-- 
2.19.1
