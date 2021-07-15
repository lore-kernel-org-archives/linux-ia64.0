From: Logan Gunthorpe <logang@deltatee.com>
Date: Thu, 15 Jul 2021 16:45:44 +0000
Subject: [PATCH v1 16/16] dma-mapping: Disallow .map_sg operations from returning zero on error
Message-Id: <20210715164544.6827-17-logang@deltatee.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210715164544.6827-1-logang@deltatee.com>
In-Reply-To: <20210715164544.6827-1-logang@deltatee.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, iommu@lists.linux-foundation.org, linux-parisc@vger.kernel.org, xen-devel@lists.xenproject.org
Cc: Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>, Robin Murphy <robin.murphy@arm.com>, Stephen Bates <sbates@raithlin.com>, Martin Oliveira <martin.oliveira@eideticom.com>, Logan Gunthorpe <logang@deltatee.com>

Now that all the .map_sg operations have been converted to returning
proper error codes, drop the code to handle a zero return value,
add a warning if a zero is returned and update the comment for the
map_sg operation.

Signed-off-by: Logan Gunthorpe <logang@deltatee.com>
---
 include/linux/dma-map-ops.h | 8 +++-----
 kernel/dma/mapping.c        | 6 +++---
 2 files changed, 6 insertions(+), 8 deletions(-)

diff --git a/include/linux/dma-map-ops.h b/include/linux/dma-map-ops.h
index eaa969be8284..f299bc1e317b 100644
--- a/include/linux/dma-map-ops.h
+++ b/include/linux/dma-map-ops.h
@@ -42,11 +42,9 @@ struct dma_map_ops {
 			unsigned long attrs);
 	/*
 	 * map_sg should return a negative error code on error.
-	 * dma_map_sgtable() will return the error code returned and convert
-	 * a zero return (for legacy implementations) into -EINVAL.
-	 *
-	 * dma_map_sg() will always return zero on any negative or zero
-	 * return to satisfy its own calling convention.
+	 * dma_map_sgtable() will return the error code returned by the
+	 * operation and dma_map_sg() will always convert any error to zero
+	 * to satisfy its own calling convention.
 	 */
 	int (*map_sg)(struct device *dev, struct scatterlist *sg, int nents,
 			enum dma_data_direction dir, unsigned long attrs);
diff --git a/kernel/dma/mapping.c b/kernel/dma/mapping.c
index 30f89d244566..978a6a16aaf7 100644
--- a/kernel/dma/mapping.c
+++ b/kernel/dma/mapping.c
@@ -194,6 +194,8 @@ static int __dma_map_sg_attrs(struct device *dev, struct scatterlist *sg,
 	else
 		ents = ops->map_sg(dev, sg, nents, dir, attrs);
 
+	WARN_ON_ONCE(ents = 0);
+
 	if (ents > 0)
 		debug_dma_map_sg(dev, sg, nents, ents, dir);
 
@@ -251,9 +253,7 @@ int dma_map_sgtable(struct device *dev, struct sg_table *sgt,
 	int nents;
 
 	nents = __dma_map_sg_attrs(dev, sgt->sgl, sgt->orig_nents, dir, attrs);
-	if (nents = 0)
-		return -EINVAL;
-	else if (nents < 0)
+	if (nents < 0)
 		return nents;
 
 	sgt->nents = nents;
-- 
2.20.1
