From: Christoph Hellwig <hch@lst.de>
Date: Thu, 22 Nov 2018 14:02:59 +0000
Subject: [PATCH 03/24] dma-mapping: provide a generic DMA_MAPPING_ERROR
Message-Id: <20181122140320.24080-4-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20181122140320.24080-1-hch@lst.de>
In-Reply-To: <20181122140320.24080-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: iommu@lists.linux-foundation.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Jon Mason <jdmason@kudzu.us>, Joerg Roedel <joro@8bytes.org>, David Woodhouse <dwmw2@infradead.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Robin Murphy <robin.murphy@arm.com>, x86@kernel.org, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, xen-devel@lists.xenproject.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

Error handling of the dma_map_single and dma_map_page APIs is a little
problematic at the moment, in that we use different encodings in the
returned dma_addr_t to indicate an error.  That means we require an
additional indirect call to figure out if a dma mapping call returned
an error, and a lot of boilerplate code to implement these semantics.

Instead return the maximum addressable value as the error.  As long
as we don't allow mapping single-byte ranges with single-byte alignment
this value can never be a valid return.  Additionaly if drivers do
not check the return value from the dma_map* routines this values means
they will generally not be pointed to actual memory.

Once the default value is added here we can start removing the
various mapping_error methods and just rely on this generic check.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 include/linux/dma-mapping.h | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/include/linux/dma-mapping.h b/include/linux/dma-mapping.h
index 15bd41447025..c323c539b7cb 100644
--- a/include/linux/dma-mapping.h
+++ b/include/linux/dma-mapping.h
@@ -133,6 +133,8 @@ struct dma_map_ops {
 	u64 (*get_required_mask)(struct device *dev);
 };
 
+#define DMA_MAPPING_ERROR		(~(dma_addr_t)0)
+
 extern const struct dma_map_ops dma_direct_ops;
 extern const struct dma_map_ops dma_virt_ops;
 
@@ -576,6 +578,10 @@ static inline int dma_mapping_error(struct device *dev, dma_addr_t dma_addr)
 	const struct dma_map_ops *ops = get_dma_ops(dev);
 
 	debug_dma_mapping_error(dev, dma_addr);
+
+	if (dma_addr = DMA_MAPPING_ERROR)
+		return 1;
+
 	if (ops->mapping_error)
 		return ops->mapping_error(dev, dma_addr);
 	return 0;
-- 
2.19.1
