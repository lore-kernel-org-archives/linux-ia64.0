From: Christoph Hellwig <hch@lst.de>
Date: Wed, 12 Aug 2015 07:05:30 +0000
Subject: [PATCH 11/31] sparc/iommu: handle page-less SG entries
Message-Id: <1439363150-8661-12-git-send-email-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <1439363150-8661-1-git-send-email-hch@lst.de>
In-Reply-To: <1439363150-8661-1-git-send-email-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: torvalds@linux-foundation.org, axboe@kernel.dk
Cc: dan.j.williams@intel.com, vgupta@synopsys.com, hskinnemoen@gmail.com, egtvedt@samfundet.no, realmz6@gmail.com, dhowells@redhat.com, monstr@monstr.eu, x86@kernel.org, dwmw2@infradead.org, alex.williamson@redhat.com, grundler@parisc-linux.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-metag@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-nvdimm@ml01.01.org, linux-media@vger.kernel.org

Use sg_phys() instead of __pa(sg_virt(sg)) so that we don't
require a kernel virtual address.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/sparc/kernel/iommu.c        | 2 +-
 arch/sparc/kernel/iommu_common.h | 4 +---
 arch/sparc/kernel/pci_sun4v.c    | 2 +-
 3 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/arch/sparc/kernel/iommu.c b/arch/sparc/kernel/iommu.c
index 5320689..2ad89d2 100644
--- a/arch/sparc/kernel/iommu.c
+++ b/arch/sparc/kernel/iommu.c
@@ -486,7 +486,7 @@ static int dma_4u_map_sg(struct device *dev, struct scatterlist *sglist,
 			continue;
 		}
 		/* Allocate iommu entries for that segment */
-		paddr = (unsigned long) SG_ENT_PHYS_ADDRESS(s);
+		paddr = sg_phys(s);
 		npages = iommu_num_pages(paddr, slen, IO_PAGE_SIZE);
 		entry = iommu_tbl_range_alloc(dev, &iommu->tbl, npages,
 					      &handle, (unsigned long)(-1), 0);
diff --git a/arch/sparc/kernel/iommu_common.h b/arch/sparc/kernel/iommu_common.h
index b40cec2..8e2c211 100644
--- a/arch/sparc/kernel/iommu_common.h
+++ b/arch/sparc/kernel/iommu_common.h
@@ -33,15 +33,13 @@
  */
 #define IOMMU_PAGE_SHIFT		13
 
-#define SG_ENT_PHYS_ADDRESS(SG)	(__pa(sg_virt((SG))))
-
 static inline int is_span_boundary(unsigned long entry,
 				   unsigned long shift,
 				   unsigned long boundary_size,
 				   struct scatterlist *outs,
 				   struct scatterlist *sg)
 {
-	unsigned long paddr = SG_ENT_PHYS_ADDRESS(outs);
+	unsigned long paddr = sg_phys(outs);
 	int nr = iommu_num_pages(paddr, outs->dma_length + sg->length,
 				 IO_PAGE_SIZE);
 
diff --git a/arch/sparc/kernel/pci_sun4v.c b/arch/sparc/kernel/pci_sun4v.c
index d2fe57d..a7a6e41 100644
--- a/arch/sparc/kernel/pci_sun4v.c
+++ b/arch/sparc/kernel/pci_sun4v.c
@@ -370,7 +370,7 @@ static int dma_4v_map_sg(struct device *dev, struct scatterlist *sglist,
 			continue;
 		}
 		/* Allocate iommu entries for that segment */
-		paddr = (unsigned long) SG_ENT_PHYS_ADDRESS(s);
+		paddr = sg_phys(s);
 		npages = iommu_num_pages(paddr, slen, IO_PAGE_SIZE);
 		entry = iommu_tbl_range_alloc(dev, &iommu->tbl, npages,
 					      &handle, (unsigned long)(-1), 0);
-- 
1.9.1

