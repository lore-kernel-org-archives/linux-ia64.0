From: Christoph Hellwig <hch@lst.de>
Date: Wed, 12 Aug 2015 07:05:34 +0000
Subject: [PATCH 15/31] sparc32/iommu: handle page-less SG entries
Message-Id: <1439363150-8661-16-git-send-email-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <1439363150-8661-1-git-send-email-hch@lst.de>
In-Reply-To: <1439363150-8661-1-git-send-email-hch-jcswGhMUV9g@public.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org
Cc: dan.j.williams-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, vgupta-HKixBCOQz3hWk0Htik3J/w@public.gmane.org, hskinnemoen-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, egtvedt-BrfabpQBY5qlHtIdYg32fQ@public.gmane.org, realmz6-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, monstr-pSz03upnqPeHXe+LvDLADg@public.gmane.org, x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, dwmw2-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, alex.williamson-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, grundler-6jwH94ZQLHl74goWV3ctuw@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arch-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-alpha-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-metag-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org, linux-parisc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sparclinux-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-xtensa-PjhNF2WwrV/0Sa2dR60CXw@public.gmane.org, linux-nvdimm-y27Ovi1pjclAfugRpC6u6w@public.gmane.org, linux-media-u79uwXL29TY76Z2rM5mHXA@public.gmane.org

Pass a PFN to iommu_get_one instad of calculating it locall from a
page structure so that we don't need pages for every address we can
DMA to or from.

Also further restrict the cache flushing as we now have a non-highmem
way of not kernel virtual mapped physical addresses.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/sparc/mm/iommu.c | 17 +++++++++--------
 1 file changed, 9 insertions(+), 8 deletions(-)

diff --git a/arch/sparc/mm/iommu.c b/arch/sparc/mm/iommu.c
index 491511d..3ed53d7 100644
--- a/arch/sparc/mm/iommu.c
+++ b/arch/sparc/mm/iommu.c
@@ -174,7 +174,7 @@ static void iommu_flush_iotlb(iopte_t *iopte, unsigned int niopte)
 	}
 }
 
-static u32 iommu_get_one(struct device *dev, struct page *page, int npages)
+static u32 iommu_get_one(struct device *dev, unsigned long pfn, int npages)
 {
 	struct iommu_struct *iommu = dev->archdata.iommu;
 	int ioptex;
@@ -183,7 +183,7 @@ static u32 iommu_get_one(struct device *dev, struct page *page, int npages)
 	int i;
 
 	/* page color = pfn of page */
-	ioptex = bit_map_string_get(&iommu->usemap, npages, page_to_pfn(page));
+	ioptex = bit_map_string_get(&iommu->usemap, npages, pfn);
 	if (ioptex < 0)
 		panic("iommu out");
 	busa0 = iommu->start + (ioptex << PAGE_SHIFT);
@@ -192,11 +192,11 @@ static u32 iommu_get_one(struct device *dev, struct page *page, int npages)
 	busa = busa0;
 	iopte = iopte0;
 	for (i = 0; i < npages; i++) {
-		iopte_val(*iopte) = MKIOPTE(page_to_pfn(page), IOPERM);
+		iopte_val(*iopte) = MKIOPTE(pfn, IOPERM);
 		iommu_invalidate_page(iommu->regs, busa);
 		busa += PAGE_SIZE;
 		iopte++;
-		page++;
+		pfn++;
 	}
 
 	iommu_flush_iotlb(iopte0, npages);
@@ -214,7 +214,7 @@ static u32 iommu_get_scsi_one(struct device *dev, char *vaddr, unsigned int len)
 	off = (unsigned long)vaddr & ~PAGE_MASK;
 	npages = (off + len + PAGE_SIZE-1) >> PAGE_SHIFT;
 	page = virt_to_page((unsigned long)vaddr & PAGE_MASK);
-	busa = iommu_get_one(dev, page, npages);
+	busa = iommu_get_one(dev, page_to_pfn(page), npages);
 	return busa + off;
 }
 
@@ -243,7 +243,7 @@ static void iommu_get_scsi_sgl_gflush(struct device *dev, struct scatterlist *sg
 	while (sz != 0) {
 		--sz;
 		n = (sg->length + sg->offset + PAGE_SIZE-1) >> PAGE_SHIFT;
-		sg->dma_address = iommu_get_one(dev, sg_page(sg), n) + sg->offset;
+		sg->dma_address = iommu_get_one(dev, sg_pfn(sg), n) + sg->offset;
 		sg->dma_length = sg->length;
 		sg = sg_next(sg);
 	}
@@ -264,7 +264,8 @@ static void iommu_get_scsi_sgl_pflush(struct device *dev, struct scatterlist *sg
 		 * XXX Is this a good assumption?
 		 * XXX What if someone else unmaps it here and races us?
 		 */
-		if ((page = (unsigned long) page_address(sg_page(sg))) != 0) {
+		if (sg_has_page(sg) &&
+		    (page = (unsigned long) page_address(sg_page(sg))) != 0) {
 			for (i = 0; i < n; i++) {
 				if (page != oldpage) {	/* Already flushed? */
 					flush_page_for_dma(page);
@@ -274,7 +275,7 @@ static void iommu_get_scsi_sgl_pflush(struct device *dev, struct scatterlist *sg
 			}
 		}
 
-		sg->dma_address = iommu_get_one(dev, sg_page(sg), n) + sg->offset;
+		sg->dma_address = iommu_get_one(dev, sg_pfn(sg), n) + sg->offset;
 		sg->dma_length = sg->length;
 		sg = sg_next(sg);
 	}
-- 
1.9.1

