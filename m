From: Logan Gunthorpe <logang@deltatee.com>
Date: Thu, 29 Jul 2021 20:15:20 +0000
Subject: [PATCH v3 02/21] dma-direct: Return appropriate error code from dma_direct_map_sg()
Message-Id: <20210729201539.5602-3-logang@deltatee.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210729201539.5602-1-logang@deltatee.com>
In-Reply-To: <20210729201539.5602-1-logang@deltatee.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, iommu@lists.linux-foundation.org, linux-parisc@vger.kernel.org, xen-devel@lists.xenproject.org
Cc: Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>, Robin Murphy <robin.murphy@arm.com>, Stephen Bates <sbates@raithlin.com>, Martin Oliveira <martin.oliveira@eideticom.com>, Logan Gunthorpe <logang@deltatee.com>

Now that the map_sg() op expects error codes instead of return zero on
error, convert dma_direct_map_sg() to return an error code. Per the
documentation for dma_map_sgtable(), -EIO is returned due to an
DMA_MAPPING_ERROR with unknown cause.

Signed-off-by: Logan Gunthorpe <logang@deltatee.com>
---
 kernel/dma/direct.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/kernel/dma/direct.c b/kernel/dma/direct.c
index f737e3347059..f33ceb68aef2 100644
--- a/kernel/dma/direct.c
+++ b/kernel/dma/direct.c
@@ -411,7 +411,7 @@ int dma_direct_map_sg(struct device *dev, struct scatterlist *sgl, int nents,
 
 out_unmap:
 	dma_direct_unmap_sg(dev, sgl, i, dir, attrs | DMA_ATTR_SKIP_CPU_SYNC);
-	return 0;
+	return -EIO;
 }
 
 dma_addr_t dma_direct_map_resource(struct device *dev, phys_addr_t paddr,
-- 
2.20.1
