From: Fenghua Yu <fenghua.yu@intel.com>
Date: Tue, 04 Aug 2009 22:09:37 +0000
Subject: [PATCH 1/4] Bug Fix drivers/pci/intel-iommu.c: correct sglist size calculation
Message-Id: <20090804220937.GA17945@linux-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0908021044540.15557@ask.diku.dk>
In-Reply-To: <Pine.LNX.4.64.0908021044540.15557@ask.diku.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Woodhouse <dwmw2@infradead.org>, Tony Luck <tony.luck@intel.com>
Cc: iommu@lists.linux-foundation.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Fenghua Yu <fenghua.yu@intel.com>

When calculating a scatter gather list size in intel_map_sg(), the size of an sg
entry should be based on sg->addr, sg->offset, and sg->length instead of just
sg->offset and sg->length.

And the size of a scatter gather list should be passed to domain_sg_mapping()
directly because it has been aligned to VTD_PAGE_SIZE already.

Because of the issue, system can not boot when PAGE_SIZE>VTD_PAGE_SIZE e.g.
on ia64 platforms.

Signed-off-by: Fenghua Yu <fenghua.yu@intel.com>

---

 drivers/pci/intel-iommu.c |   28 ++++++++++++++++------------
 1 files changed, 16 insertions(+), 12 deletions(-)

diff --git a/drivers/pci/intel-iommu.c b/drivers/pci/intel-iommu.c
index bec29ed..54ee63d 100644
--- a/drivers/pci/intel-iommu.c
+++ b/drivers/pci/intel-iommu.c
@@ -1645,6 +1645,15 @@ static int domain_context_mapped(struct pci_dev *pdev)
 					     tmp->devfn);
 }
 
+/* Returns a number of VTD pages, but aligned to MM page size */
+static inline unsigned long aligned_nrpages(unsigned long host_addr,
+					    size_t size)
+{
+	host_addr &= ~PAGE_MASK;
+	return PAGE_ALIGN(host_addr + size) >> VTD_PAGE_SHIFT;
+}
+
+
 static int __domain_mapping(struct dmar_domain *domain, unsigned long iov_pfn,
 			    struct scatterlist *sg, unsigned long phys_pfn,
 			    unsigned long nr_pages, int prot)
@@ -1672,7 +1681,8 @@ static int __domain_mapping(struct dmar_domain *domain, unsigned long iov_pfn,
 		uint64_t tmp;
 
 		if (!sg_res) {
-			sg_res = (sg->offset + sg->length + VTD_PAGE_SIZE - 1) >> VTD_PAGE_SHIFT;
+			dma_addr_t addr = sg_phys(sg);
+			sg_res = aligned_nrpages(addr, sg->length);
 			sg->dma_address = ((dma_addr_t)iov_pfn << VTD_PAGE_SHIFT) + sg->offset;
 			sg->dma_length = sg->length;
 			pteval = page_to_phys(sg_page(sg)) | prot;
@@ -2411,14 +2425,6 @@ error:
 	return ret;
 }
 
-/* Returns a number of VTD pages, but aligned to MM page size */
-static inline unsigned long aligned_nrpages(unsigned long host_addr,
-					    size_t size)
-{
-	host_addr &= ~PAGE_MASK;
-	return PAGE_ALIGN(host_addr + size) >> VTD_PAGE_SHIFT;
-}
-
 /* This takes a number of _MM_ pages, not VTD pages */
 static struct iova *intel_alloc_iova(struct device *dev,
 				     struct dmar_domain *domain,
@@ -2861,8 +2868,10 @@ static int intel_map_sg(struct device *hwdev, struct scatterlist *sglist, int ne
 
 	iommu = domain_get_iommu(domain);
 
-	for_each_sg(sglist, sg, nelems, i)
-		size += aligned_nrpages(sg->offset, sg->length);
+	for_each_sg(sglist, sg, nelems, i) {
+		dma_addr_t addr = sg_phys(sg);
+		size += aligned_nrpages(addr, sg->length);
+	}
 
 	iova = intel_alloc_iova(hwdev, domain, dma_to_mm_pfn(size),
 				pdev->dma_mask);
@@ -2883,7 +2892,7 @@ static int intel_map_sg(struct device *hwdev, struct scatterlist *sglist, int ne
 
 	start_vpfn = mm_to_dma_pfn(iova->pfn_lo);
 
-	ret = domain_sg_mapping(domain, start_vpfn, sglist, mm_to_dma_pfn(size), prot);
+	ret = domain_sg_mapping(domain, start_vpfn, sglist, size, prot);
 	if (unlikely(ret)) {
 		/*  clear the page */
 		dma_pte_clear_range(domain, start_vpfn,
