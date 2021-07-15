From: Logan Gunthorpe <logang@deltatee.com>
Date: Thu, 15 Jul 2021 16:45:39 +0000
Subject: [PATCH v1 11/16] sparc/iommu: return error codes from .map_sg() ops
Message-Id: <20210715164544.6827-12-logang@deltatee.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210715164544.6827-1-logang@deltatee.com>
In-Reply-To: <20210715164544.6827-1-logang@deltatee.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, iommu@lists.linux-foundation.org, linux-parisc@vger.kernel.org, xen-devel@lists.xenproject.org
Cc: Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>, Robin Murphy <robin.murphy@arm.com>, Stephen Bates <sbates@raithlin.com>, Martin Oliveira <martin.oliveira@eideticom.com>, Logan Gunthorpe <logang@deltatee.com>, "David S. Miller" <davem@davemloft.net>, Niklas Schnelle <schnelle@linux.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>

From: Martin Oliveira <martin.oliveira@eideticom.com>

The .map_sg() op now expects an error code instead of zero on failure.

Returning an errno from __sbus_iommu_map_sg() results in
sbus_iommu_map_sg_gflush() and sbus_iommu_map_sg_pflush() returning an
errno, as those functions are wrappers around __sbus_iommu_map_sg().

Signed-off-by: Martin Oliveira <martin.oliveira@eideticom.com>
Signed-off-by: Logan Gunthorpe <logang@deltatee.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Niklas Schnelle <schnelle@linux.ibm.com>
Cc: Michael Ellerman <mpe@ellerman.id.au>
---
 arch/sparc/kernel/iommu.c     | 4 ++--
 arch/sparc/kernel/pci_sun4v.c | 4 ++--
 arch/sparc/mm/iommu.c         | 2 +-
 3 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/arch/sparc/kernel/iommu.c b/arch/sparc/kernel/iommu.c
index a034f571d869..0589acd34201 100644
--- a/arch/sparc/kernel/iommu.c
+++ b/arch/sparc/kernel/iommu.c
@@ -448,7 +448,7 @@ static int dma_4u_map_sg(struct device *dev, struct scatterlist *sglist,
 	iommu = dev->archdata.iommu;
 	strbuf = dev->archdata.stc;
 	if (nelems = 0 || !iommu)
-		return 0;
+		return -EINVAL;
 
 	spin_lock_irqsave(&iommu->lock, flags);
 
@@ -580,7 +580,7 @@ static int dma_4u_map_sg(struct device *dev, struct scatterlist *sglist,
 	}
 	spin_unlock_irqrestore(&iommu->lock, flags);
 
-	return 0;
+	return -EINVAL;
 }
 
 /* If contexts are being used, they are the same in all of the mappings
diff --git a/arch/sparc/kernel/pci_sun4v.c b/arch/sparc/kernel/pci_sun4v.c
index 9de57e88f7a1..d90e80fa5705 100644
--- a/arch/sparc/kernel/pci_sun4v.c
+++ b/arch/sparc/kernel/pci_sun4v.c
@@ -486,7 +486,7 @@ static int dma_4v_map_sg(struct device *dev, struct scatterlist *sglist,
 
 	iommu = dev->archdata.iommu;
 	if (nelems = 0 || !iommu)
-		return 0;
+		return -EINVAL;
 	atu = iommu->atu;
 
 	prot = HV_PCI_MAP_ATTR_READ;
@@ -619,7 +619,7 @@ static int dma_4v_map_sg(struct device *dev, struct scatterlist *sglist,
 	}
 	local_irq_restore(flags);
 
-	return 0;
+	return -EINVAL;
 }
 
 static void dma_4v_unmap_sg(struct device *dev, struct scatterlist *sglist,
diff --git a/arch/sparc/mm/iommu.c b/arch/sparc/mm/iommu.c
index 0c0342e5b10d..01ffcedd159c 100644
--- a/arch/sparc/mm/iommu.c
+++ b/arch/sparc/mm/iommu.c
@@ -256,7 +256,7 @@ static int __sbus_iommu_map_sg(struct device *dev, struct scatterlist *sgl,
 		sg->dma_address =__sbus_iommu_map_page(dev, sg_page(sg),
 				sg->offset, sg->length, per_page_flush);
 		if (sg->dma_address = DMA_MAPPING_ERROR)
-			return 0;
+			return -EINVAL;
 		sg->dma_length = sg->length;
 	}
 
-- 
2.20.1
