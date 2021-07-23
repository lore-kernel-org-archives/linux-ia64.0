From: Logan Gunthorpe <logang@deltatee.com>
Date: Fri, 23 Jul 2021 17:49:59 +0000
Subject: [PATCH v2 12/21] s390/pci: return error code from s390_dma_map_sg()
Message-Id: <20210723175008.22410-13-logang@deltatee.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210723175008.22410-1-logang@deltatee.com>
In-Reply-To: <20210723175008.22410-1-logang@deltatee.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, iommu@lists.linux-foundation.org, linux-parisc@vger.kernel.org, xen-devel@lists.xenproject.org
Cc: Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>, Robin Murphy <robin.murphy@arm.com>, Stephen Bates <sbates@raithlin.com>, Martin Oliveira <martin.oliveira@eideticom.com>, Logan Gunthorpe <logang@deltatee.com>, Niklas Schnelle <schnelle@linux.ibm.com>, Gerald Schaefer <gerald.schaefer@linux.ibm.com>, Heiko Carstens <hca@linux.ibm.com>, Vasily Gorbik <gor@linux.ibm.com>, Christian Borntraeger <borntraeger@de.ibm.com>

From: Martin Oliveira <martin.oliveira@eideticom.com>

The .map_sg() op now expects an error code instead of zero on failure.

So propagate the error from __s390_dma_map_sg() up. __s390_dma_map_sg()
returns either -ENOMEM on allocation failure or -EINVAL which is
the same as what's expected by dma_map_sgtable().

Signed-off-by: Martin Oliveira <martin.oliveira@eideticom.com>
Signed-off-by: Logan Gunthorpe <logang@deltatee.com>
Acked-by: Niklas Schnelle <schnelle@linux.ibm.com>
Cc: Gerald Schaefer <gerald.schaefer@linux.ibm.com>
Cc: Heiko Carstens <hca@linux.ibm.com>
Cc: Vasily Gorbik <gor@linux.ibm.com>
Cc: Christian Borntraeger <borntraeger@de.ibm.com>
---
 arch/s390/pci/pci_dma.c | 12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/arch/s390/pci/pci_dma.c b/arch/s390/pci/pci_dma.c
index ebc9a49523aa..c78b02012764 100644
--- a/arch/s390/pci/pci_dma.c
+++ b/arch/s390/pci/pci_dma.c
@@ -487,7 +487,7 @@ static int s390_dma_map_sg(struct device *dev, struct scatterlist *sg,
 	unsigned int max = dma_get_max_seg_size(dev);
 	unsigned int size = s->offset + s->length;
 	unsigned int offset = s->offset;
-	int count = 0, i;
+	int count = 0, i, ret;
 
 	for (i = 1; i < nr_elements; i++) {
 		s = sg_next(s);
@@ -497,8 +497,9 @@ static int s390_dma_map_sg(struct device *dev, struct scatterlist *sg,
 
 		if (s->offset || (size & ~PAGE_MASK) ||
 		    size + s->length > max) {
-			if (__s390_dma_map_sg(dev, start, size,
-					      &dma->dma_address, dir))
+			ret = __s390_dma_map_sg(dev, start, size,
+						&dma->dma_address, dir);
+			if (ret)
 				goto unmap;
 
 			dma->dma_address += offset;
@@ -511,7 +512,8 @@ static int s390_dma_map_sg(struct device *dev, struct scatterlist *sg,
 		}
 		size += s->length;
 	}
-	if (__s390_dma_map_sg(dev, start, size, &dma->dma_address, dir))
+	ret = __s390_dma_map_sg(dev, start, size, &dma->dma_address, dir);
+	if (ret)
 		goto unmap;
 
 	dma->dma_address += offset;
@@ -523,7 +525,7 @@ static int s390_dma_map_sg(struct device *dev, struct scatterlist *sg,
 		s390_dma_unmap_pages(dev, sg_dma_address(s), sg_dma_len(s),
 				     dir, attrs);
 
-	return 0;
+	return ret;
 }
 
 static void s390_dma_unmap_sg(struct device *dev, struct scatterlist *sg,
-- 
2.20.1
