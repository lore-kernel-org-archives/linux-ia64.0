From: Logan Gunthorpe <logang@deltatee.com>
Date: Fri, 23 Jul 2021 17:49:52 +0000
Subject: [PATCH v2 05/21] alpha: return error code from alpha_pci_map_sg()
Message-Id: <20210723175008.22410-6-logang@deltatee.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210723175008.22410-1-logang@deltatee.com>
In-Reply-To: <20210723175008.22410-1-logang@deltatee.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, iommu@lists.linux-foundation.org, linux-parisc@vger.kernel.org, xen-devel@lists.xenproject.org
Cc: Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>, Robin Murphy <robin.murphy@arm.com>, Stephen Bates <sbates@raithlin.com>, Martin Oliveira <martin.oliveira@eideticom.com>, Logan Gunthorpe <logang@deltatee.com>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>

From: Martin Oliveira <martin.oliveira@eideticom.com>

The .map_sg() op now expects an error code instead of zero on failure.

pci_map_single_1() can fail for different reasons, but since the only
supported type of error return is DMA_MAPPING_ERROR, we coalesce those
errors into EIO.

ENOMEM is returned when no page tables can be allocated.

Signed-off-by: Martin Oliveira <martin.oliveira@eideticom.com>
Signed-off-by: Logan Gunthorpe <logang@deltatee.com>
Cc: Richard Henderson <rth@twiddle.net>
Cc: Ivan Kokshaysky <ink@jurassic.park.msu.ru>
Cc: Matt Turner <mattst88@gmail.com>
---
 arch/alpha/kernel/pci_iommu.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/arch/alpha/kernel/pci_iommu.c b/arch/alpha/kernel/pci_iommu.c
index 35d7b3096d6e..21f9ac101324 100644
--- a/arch/alpha/kernel/pci_iommu.c
+++ b/arch/alpha/kernel/pci_iommu.c
@@ -649,7 +649,9 @@ static int alpha_pci_map_sg(struct device *dev, struct scatterlist *sg,
 		sg->dma_address
 		  = pci_map_single_1(pdev, SG_ENT_VIRT_ADDRESS(sg),
 				     sg->length, dac_allowed);
-		return sg->dma_address != DMA_MAPPING_ERROR;
+		if (sg->dma_address = DMA_MAPPING_ERROR)
+			return -EIO;
+		return 1;
 	}
 
 	start = sg;
@@ -685,8 +687,10 @@ static int alpha_pci_map_sg(struct device *dev, struct scatterlist *sg,
 	if (out < end)
 		out->dma_length = 0;
 
-	if (out - start = 0)
+	if (out - start = 0) {
 		printk(KERN_WARNING "pci_map_sg failed: no entries?\n");
+		return -ENOMEM;
+	}
 	DBGA("pci_map_sg: %ld entries\n", out - start);
 
 	return out - start;
@@ -699,7 +703,7 @@ static int alpha_pci_map_sg(struct device *dev, struct scatterlist *sg,
 	   entries.  Unmap them now.  */
 	if (out > start)
 		pci_unmap_sg(pdev, start, out - start, dir);
-	return 0;
+	return -ENOMEM;
 }
 
 /* Unmap a set of streaming mode DMA translations.  Again, cpu read
-- 
2.20.1
