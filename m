From: Logan Gunthorpe <logang@deltatee.com>
Date: Thu, 29 Jul 2021 20:15:39 +0000
Subject: [PATCH v3 21/21] dma-mapping: Disallow .map_sg operations from returning zero on error
Message-Id: <20210729201539.5602-22-logang@deltatee.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210729201539.5602-1-logang@deltatee.com>
In-Reply-To: <20210729201539.5602-1-logang@deltatee.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, iommu@lists.linux-foundation.org, linux-parisc@vger.kernel.org, xen-devel@lists.xenproject.org
Cc: Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>, Robin Murphy <robin.murphy@arm.com>, Stephen Bates <sbates@raithlin.com>, Martin Oliveira <martin.oliveira@eideticom.com>, Logan Gunthorpe <logang@deltatee.com>

Now that all the .map_sg operations have been converted to returning
proper error codes, drop the code to handle a zero return value,
add a warning if a zero is returned.

Signed-off-by: Logan Gunthorpe <logang@deltatee.com>
---
 kernel/dma/mapping.c | 8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/kernel/dma/mapping.c b/kernel/dma/mapping.c
index 9f0bb56eb9aa..cbcbdc877458 100644
--- a/kernel/dma/mapping.c
+++ b/kernel/dma/mapping.c
@@ -196,8 +196,8 @@ static int __dma_map_sg_attrs(struct device *dev, struct scatterlist *sg,
 
 	if (ents > 0)
 		debug_dma_map_sg(dev, sg, nents, ents, dir);
-	else if (WARN_ON_ONCE(ents != -EINVAL && ents != -ENOMEM &&
-			      ents != -EIO && ents != 0))
+	else if (WARN_ON_ONCE((ents != -EINVAL && ents != -ENOMEM &&
+			       ents != -EIO) || ents = 0))
 		return -EIO;
 
 	return ents;
@@ -262,9 +262,7 @@ int dma_map_sgtable(struct device *dev, struct sg_table *sgt,
 	int nents;
 
 	nents = __dma_map_sg_attrs(dev, sgt->sgl, sgt->orig_nents, dir, attrs);
-	if (nents = 0)
-		return -EIO;
-	else if (nents < 0)
+	if (nents < 0)
 		return nents;
 
 	sgt->nents = nents;
-- 
2.20.1
