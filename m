From: Christoph Hellwig <hch@lst.de>
Date: Wed, 12 Aug 2015 07:05:36 +0000
Subject: [PATCH 17/31] ia64/sba_iommu: remove sba_sg_address
Message-Id: <1439363150-8661-18-git-send-email-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <1439363150-8661-1-git-send-email-hch@lst.de>
In-Reply-To: <1439363150-8661-1-git-send-email-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: torvalds@linux-foundation.org, axboe@kernel.dk
Cc: dan.j.williams@intel.com, vgupta@synopsys.com, hskinnemoen@gmail.com, egtvedt@samfundet.no, realmz6@gmail.com, dhowells@redhat.com, monstr@monstr.eu, x86@kernel.org, dwmw2@infradead.org, alex.williamson@redhat.com, grundler@parisc-linux.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-metag@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-nvdimm@ml01.01.org, linux-media@vger.kernel.org

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/ia64/hp/common/sba_iommu.c | 22 ++++++++++------------
 1 file changed, 10 insertions(+), 12 deletions(-)

diff --git a/arch/ia64/hp/common/sba_iommu.c b/arch/ia64/hp/common/sba_iommu.c
index 344387a..9e5aa8e 100644
--- a/arch/ia64/hp/common/sba_iommu.c
+++ b/arch/ia64/hp/common/sba_iommu.c
@@ -248,8 +248,6 @@ static int reserve_sba_gart = 1;
 static SBA_INLINE void sba_mark_invalid(struct ioc *, dma_addr_t, size_t);
 static SBA_INLINE void sba_free_range(struct ioc *, dma_addr_t, size_t);
 
-#define sba_sg_address(sg)	sg_virt((sg))
-
 #ifdef FULL_VALID_PDIR
 static u64 prefetch_spill_page;
 #endif
@@ -397,7 +395,7 @@ sba_dump_sg( struct ioc *ioc, struct scatterlist *startsg, int nents)
 	while (nents-- > 0) {
 		printk(KERN_DEBUG " %d : DMA %08lx/%05x CPU %p\n", nents,
 		       startsg->dma_address, startsg->dma_length,
-		       sba_sg_address(startsg));
+		       sg_virt(startsg));
 		startsg = sg_next(startsg);
 	}
 }
@@ -409,7 +407,7 @@ sba_check_sg( struct ioc *ioc, struct scatterlist *startsg, int nents)
 	int the_nents = nents;
 
 	while (the_nents-- > 0) {
-		if (sba_sg_address(the_sg) = 0x0UL)
+		if (sg_virt(the_sg) = 0x0UL)
 			sba_dump_sg(NULL, startsg, nents);
 		the_sg = sg_next(the_sg);
 	}
@@ -1243,11 +1241,11 @@ sba_fill_pdir(
 		if (dump_run_sg)
 			printk(" %2d : %08lx/%05x %p\n",
 				nents, startsg->dma_address, cnt,
-				sba_sg_address(startsg));
+				sg_virt(startsg));
 #else
 		DBG_RUN_SG(" %d : %08lx/%05x %p\n",
 				nents, startsg->dma_address, cnt,
-				sba_sg_address(startsg));
+				sg_virt(startsg));
 #endif
 		/*
 		** Look for the start of a new DMA stream
@@ -1267,7 +1265,7 @@ sba_fill_pdir(
 		** Look for a VCONTIG chunk
 		*/
 		if (cnt) {
-			unsigned long vaddr = (unsigned long) sba_sg_address(startsg);
+			unsigned long vaddr = (unsigned long) sg_virt(startsg);
 			ASSERT(pdirp);
 
 			/* Since multiple Vcontig blocks could make up
@@ -1335,7 +1333,7 @@ sba_coalesce_chunks(struct ioc *ioc, struct device *dev,
 	int idx;
 
 	while (nents > 0) {
-		unsigned long vaddr = (unsigned long) sba_sg_address(startsg);
+		unsigned long vaddr = (unsigned long) sg_virt(startsg);
 
 		/*
 		** Prepare for first/next DMA stream
@@ -1380,7 +1378,7 @@ sba_coalesce_chunks(struct ioc *ioc, struct device *dev,
 			**
 			** append the next transaction?
 			*/
-			vaddr = (unsigned long) sba_sg_address(startsg);
+			vaddr = (unsigned long) sg_virt(startsg);
 			if  (vcontig_end = vaddr)
 			{
 				vcontig_len += startsg->length;
@@ -1479,7 +1477,7 @@ static int sba_map_sg_attrs(struct device *dev, struct scatterlist *sglist,
 	if (likely((ioc->dma_mask & ~to_pci_dev(dev)->dma_mask) = 0)) {
 		for_each_sg(sglist, sg, nents, filled) {
 			sg->dma_length = sg->length;
-			sg->dma_address = virt_to_phys(sba_sg_address(sg));
+			sg->dma_address = virt_to_phys(sg_virt(sg));
 		}
 		return filled;
 	}
@@ -1487,7 +1485,7 @@ static int sba_map_sg_attrs(struct device *dev, struct scatterlist *sglist,
 	/* Fast path single entry scatterlists. */
 	if (nents = 1) {
 		sglist->dma_length = sglist->length;
-		sglist->dma_address = sba_map_single_attrs(dev, sba_sg_address(sglist), sglist->length, dir, attrs);
+		sglist->dma_address = sba_map_single_attrs(dev, sg_virt(sglist), sglist->length, dir, attrs);
 		return 1;
 	}
 
@@ -1563,7 +1561,7 @@ static void sba_unmap_sg_attrs(struct device *dev, struct scatterlist *sglist,
 #endif
 
 	DBG_RUN_SG("%s() START %d entries,  %p,%x\n",
-		   __func__, nents, sba_sg_address(sglist), sglist->length);
+		   __func__, nents, sg_virt(sglist), sglist->length);
 
 #ifdef ASSERT_PDIR_SANITY
 	ioc = GET_IOC(dev);
-- 
1.9.1

