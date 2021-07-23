From: Logan Gunthorpe <logang@deltatee.com>
Date: Fri, 23 Jul 2021 17:50:03 +0000
Subject: [PATCH v2 16/21] parisc: return error code from .map_sg() ops
Message-Id: <20210723175008.22410-17-logang@deltatee.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210723175008.22410-1-logang@deltatee.com>
In-Reply-To: <20210723175008.22410-1-logang@deltatee.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, iommu@lists.linux-foundation.org, linux-parisc@vger.kernel.org, xen-devel@lists.xenproject.org
Cc: Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>, Robin Murphy <robin.murphy@arm.com>, Stephen Bates <sbates@raithlin.com>, Martin Oliveira <martin.oliveira@eideticom.com>, Logan Gunthorpe <logang@deltatee.com>, "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>, Helge Deller <deller@gmx.de>

From: Martin Oliveira <martin.oliveira@eideticom.com>

The .map_sg() op now expects an error code instead of zero on failure.
Return -EINVAL if the ioc cannot be obtained.

Signed-off-by: Martin Oliveira <martin.oliveira@eideticom.com>
Signed-off-by: Logan Gunthorpe <logang@deltatee.com>
Cc: "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>
Cc: Helge Deller <deller@gmx.de>
---
 drivers/parisc/ccio-dma.c  | 2 +-
 drivers/parisc/sba_iommu.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/parisc/ccio-dma.c b/drivers/parisc/ccio-dma.c
index b5f9ee81a46c..452e72b7bd01 100644
--- a/drivers/parisc/ccio-dma.c
+++ b/drivers/parisc/ccio-dma.c
@@ -918,7 +918,7 @@ ccio_map_sg(struct device *dev, struct scatterlist *sglist, int nents,
 	BUG_ON(!dev);
 	ioc = GET_IOC(dev);
 	if (!ioc)
-		return 0;
+		return -EINVAL;
 	
 	DBG_RUN_SG("%s() START %d entries\n", __func__, nents);
 
diff --git a/drivers/parisc/sba_iommu.c b/drivers/parisc/sba_iommu.c
index dce4cdf786cd..e60690d38d67 100644
--- a/drivers/parisc/sba_iommu.c
+++ b/drivers/parisc/sba_iommu.c
@@ -947,7 +947,7 @@ sba_map_sg(struct device *dev, struct scatterlist *sglist, int nents,
 
 	ioc = GET_IOC(dev);
 	if (!ioc)
-		return 0;
+		return -EINVAL;
 
 	/* Fast path single entry scatterlists. */
 	if (nents = 1) {
-- 
2.20.1
