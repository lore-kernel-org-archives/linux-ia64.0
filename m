From: Christoph Hellwig <hch@lst.de>
Date: Fri, 07 Dec 2018 19:07:08 +0000
Subject: [PATCH 03/15] dma-direct: improve addressability error reporting
Message-Id: <20181207190720.18517-4-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20181207190720.18517-1-hch@lst.de>
In-Reply-To: <20181207190720.18517-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: iommu@lists.linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>, Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Tariq Toukan <tariqt@mellanox.com>, Ilias Apalodimas <ilias.apalodimas@linaro.org>, =?UTF-8?q?Toke=20H=C3=B8iland-J=C3=B8rgensen?= <toke@toke.dk>, Robin Murphy <robin.murphy@arm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Keith Busch <keith.busch@intel.com>, Jonathan Derrick <jonathan.derrick@intel.com>, linux-pci@vger.kernel.org, linux-ia64@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org

Only report report a DMA addressability report once to avoid spewing the
kernel log with repeated message.  Also provide a stack trace to make it
easy to find the actual caller that caused the problem.

Last but not least move the actual check into the fast path and only
leave the error reporting in a helper.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 kernel/dma/direct.c | 36 +++++++++++++++---------------------
 1 file changed, 15 insertions(+), 21 deletions(-)

diff --git a/kernel/dma/direct.c b/kernel/dma/direct.c
index 308f88a750c8..edb24f94ea1e 100644
--- a/kernel/dma/direct.c
+++ b/kernel/dma/direct.c
@@ -30,27 +30,16 @@ static inline bool force_dma_unencrypted(void)
 	return sev_active();
 }
 
-static bool
-check_addr(struct device *dev, dma_addr_t dma_addr, size_t size,
-		const char *caller)
+static void report_addr(struct device *dev, dma_addr_t dma_addr, size_t size)
 {
-	if (unlikely(dev && !dma_capable(dev, dma_addr, size))) {
-		if (!dev->dma_mask) {
-			dev_err(dev,
-				"%s: call on device without dma_mask\n",
-				caller);
-			return false;
-		}
-
-		if (*dev->dma_mask >= DMA_BIT_MASK(32) || dev->bus_dma_mask) {
-			dev_err(dev,
-				"%s: overflow %pad+%zu of device mask %llx bus mask %llx\n",
-				caller, &dma_addr, size,
-				*dev->dma_mask, dev->bus_dma_mask);
-		}
-		return false;
+	if (!dev->dma_mask) {
+		dev_err_once(dev, "DMA map on device without dma_mask\n");
+	} else if (*dev->dma_mask >= DMA_BIT_MASK(32) || dev->bus_dma_mask) {
+		dev_err_once(dev,
+			"overflow %pad+%zu of DMA mask %llx bus mask %llx\n",
+			&dma_addr, size, *dev->dma_mask, dev->bus_dma_mask);
 	}
-	return true;
+	WARN_ON_ONCE(1);
 }
 
 static inline dma_addr_t phys_to_dma_direct(struct device *dev,
@@ -288,8 +277,10 @@ dma_addr_t dma_direct_map_page(struct device *dev, struct page *page,
 	phys_addr_t phys = page_to_phys(page) + offset;
 	dma_addr_t dma_addr = phys_to_dma(dev, phys);
 
-	if (!check_addr(dev, dma_addr, size, __func__))
+	if (unlikely(dev && !dma_capable(dev, dma_addr, size))) {
+		report_addr(dev, dma_addr, size);
 		return DMA_MAPPING_ERROR;
+	}
 
 	if (!(attrs & DMA_ATTR_SKIP_CPU_SYNC))
 		dma_direct_sync_single_for_device(dev, dma_addr, size, dir);
@@ -306,8 +297,11 @@ int dma_direct_map_sg(struct device *dev, struct scatterlist *sgl, int nents,
 		BUG_ON(!sg_page(sg));
 
 		sg_dma_address(sg) = phys_to_dma(dev, sg_phys(sg));
-		if (!check_addr(dev, sg_dma_address(sg), sg->length, __func__))
+		if (unlikely(dev && !dma_capable(dev, sg_dma_address(sg),
+				sg->length))) {
+			report_addr(dev, sg_dma_address(sg), sg->length);
 			return 0;
+		}
 		sg_dma_len(sg) = sg->length;
 	}
 
-- 
2.19.1
