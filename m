From: Christoph Hellwig <hch@lst.de>
Date: Mon, 30 Jul 2018 16:38:07 +0000
Subject: [PATCH 03/20] dma-mapping: make the get_required_mask method available unconditionally
Message-Id: <20180730163824.10064-4-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180730163824.10064-1-hch@lst.de>
In-Reply-To: <20180730163824.10064-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Robin Murphy <robin.murphy@arm.com>, linuxppc-dev@lists.ozlabs.org, iommu@lists.linux-foundation.org, linux-ia64@vger.kernel.org

This save some duplication for ia64.  In the long run this method will
need some additional work including moving over to kernel/dma, but that
will require some additional prep work, so let's do this minimal change
for now.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 drivers/base/platform.c     | 11 ++++++++++-
 include/linux/dma-mapping.h |  2 --
 2 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/drivers/base/platform.c b/drivers/base/platform.c
index dff82a3c2caa..921ddb0c051b 100644
--- a/drivers/base/platform.c
+++ b/drivers/base/platform.c
@@ -1180,7 +1180,7 @@ int __init platform_bus_init(void)
 }
 
 #ifndef ARCH_HAS_DMA_GET_REQUIRED_MASK
-u64 dma_get_required_mask(struct device *dev)
+static u64 default_dma_get_required_mask(struct device *dev)
 {
 	u32 low_totalram = ((max_pfn - 1) << PAGE_SHIFT);
 	u32 high_totalram = ((max_pfn - 1) >> (32 - PAGE_SHIFT));
@@ -1198,6 +1198,15 @@ u64 dma_get_required_mask(struct device *dev)
 	}
 	return mask;
 }
+
+u64 dma_get_required_mask(struct device *dev)
+{
+	const struct dma_map_ops *ops = get_dma_ops(dev);
+
+	if (ops->get_required_mask)
+		return ops->get_required_mask(dev);
+	return default_dma_get_required_mask(dev);
+}
 EXPORT_SYMBOL_GPL(dma_get_required_mask);
 #endif
 
diff --git a/include/linux/dma-mapping.h b/include/linux/dma-mapping.h
index f9cc309507d9..00d3065e1510 100644
--- a/include/linux/dma-mapping.h
+++ b/include/linux/dma-mapping.h
@@ -130,9 +130,7 @@ struct dma_map_ops {
 			enum dma_data_direction direction);
 	int (*mapping_error)(struct device *dev, dma_addr_t dma_addr);
 	int (*dma_supported)(struct device *dev, u64 mask);
-#ifdef ARCH_HAS_DMA_GET_REQUIRED_MASK
 	u64 (*get_required_mask)(struct device *dev);
-#endif
 };
 
 extern const struct dma_map_ops dma_direct_ops;
-- 
2.18.0

