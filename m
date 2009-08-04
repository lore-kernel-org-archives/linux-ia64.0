From: Fenghua Yu <fenghua.yu@intel.com>
Date: Tue, 04 Aug 2009 22:10:59 +0000
Subject: [PATCH 3/4] Bug Fix drivers/pci/intel-iommu.c: convert paddr to correct DMA pfn
Message-Id: <20090804221058.GA21448@linux-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <bug-504363-150293@bugzilla.redhat.com> <200908042017.n74KHsNw018095@bz-web1.app.phx.redhat.com>
In-Reply-To: <200908042017.n74KHsNw018095@bz-web1.app.phx.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Woodhouse <dwmw2@infradead.org>, Tony Luck <tony.luck@intel.com>
Cc: iommu@lists.linux-foundation.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Fenghua Yu <fenghua.yu@intel.com>

When calling domain_pfn_mapping(), paddr should be converted to DMA pfn
correctly instead just shift by VTD_PAGE_SHIFT.

This issue causes kernel panic on PAGE_SIZE>VTD_PAGE_SIZE platforms e.g. ia64
platforms.

Signed-off-by: Fenghua Yu <fenghua.yu@intel.com>

---

 drivers/pci/intel-iommu.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/pci/intel-iommu.c b/drivers/pci/intel-iommu.c
index bec29ed..54ee63d 100644
--- a/drivers/pci/intel-iommu.c
+++ b/drivers/pci/intel-iommu.c
@@ -2558,6 +2564,7 @@ static dma_addr_t __intel_map_single(struct device *hwdev, phys_addr_t paddr,
 	int prot = 0;
 	int ret;
 	struct intel_iommu *iommu;
+	unsigned long paddr_pfn = paddr >> PAGE_SHIFT;
 
 	BUG_ON(dir = DMA_NONE);
 
@@ -2592,7 +2599,7 @@ static dma_addr_t __intel_map_single(struct device *hwdev, phys_addr_t paddr,
 	 * is not a big problem
 	 */
 	ret = domain_pfn_mapping(domain, mm_to_dma_pfn(iova->pfn_lo),
-				 paddr >> VTD_PAGE_SHIFT, size, prot);
+				 mm_to_dma_pfn(paddr_pfn), size, prot);
 	if (ret)
 		goto error;
 
