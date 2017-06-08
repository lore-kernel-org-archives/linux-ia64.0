From: Christoph Hellwig <hch@lst.de>
Date: Thu, 08 Jun 2017 13:25:54 +0000
Subject: [PATCH 29/44] dma-noop: remove dma_supported and mapping_error methods
Message-Id: <20170608132609.32662-30-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170608132609.32662-1-hch@lst.de>
In-Reply-To: <20170608132609.32662-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: x86@kernel.org, linux-arm-kernel@lists.infradead.org, xen-devel@lists.xenproject.org, linux-c6x-dev@linux-c6x.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, openrisc@lists.librecores.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, dmaengine@vger.kernel.org, linux-tegra@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-samsung-soc@vger.kernel.org, iommu@lists.linux-foundation.org, netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org

These just duplicate the default behavior if no method is provided.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 lib/dma-noop.c | 12 ------------
 1 file changed, 12 deletions(-)

diff --git a/lib/dma-noop.c b/lib/dma-noop.c
index de26c8b68f34..643a074f139d 100644
--- a/lib/dma-noop.c
+++ b/lib/dma-noop.c
@@ -54,23 +54,11 @@ static int dma_noop_map_sg(struct device *dev, struct scatterlist *sgl, int nent
 	return nents;
 }
 
-static int dma_noop_mapping_error(struct device *dev, dma_addr_t dma_addr)
-{
-	return 0;
-}
-
-static int dma_noop_supported(struct device *dev, u64 mask)
-{
-	return 1;
-}
-
 const struct dma_map_ops dma_noop_ops = {
 	.alloc			= dma_noop_alloc,
 	.free			= dma_noop_free,
 	.map_page		= dma_noop_map_page,
 	.map_sg			= dma_noop_map_sg,
-	.mapping_error		= dma_noop_mapping_error,
-	.dma_supported		= dma_noop_supported,
 };
 
 EXPORT_SYMBOL(dma_noop_ops);
-- 
2.11.0

