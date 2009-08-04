From: Fenghua Yu <fenghua.yu@intel.com>
Date: Tue, 04 Aug 2009 22:11:20 +0000
Subject: [PATCH 4/4] Bug Fix drivers/pci/intel-iommu.c: convert pfn_lo to VTD page address when calling iommu
Message-Id: <20090804221119.GA21544@linux-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <bug-504363-150293@bugzilla.redhat.com> <200908042017.n74KHsNw018095@bz-web1.app.phx.redhat.com>
In-Reply-To: <200908042017.n74KHsNw018095@bz-web1.app.phx.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Woodhouse <dwmw2@infradead.org>, Tony Luck <tony.luck@intel.com>
Cc: iommu@lists.linux-foundation.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Fenghua Yu <fenghua.yu@intel.com>

The iova->pfn_lo should be converted to VTD page address before it's passed to
iommu_flush_dev_iotlb().

This issue may cause DMA failure on PAGE_SIZE>VTD_PAGE_SIZE platforms e.g. ia64
platforms.

Signed-off-by: Fenghua Yu <fenghua.yu@intel.com>

---

 drivers/pci/intel-iommu.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/pci/intel-iommu.c b/drivers/pci/intel-iommu.c
index bec29ed..54ee63d 100644
--- a/drivers/pci/intel-iommu.c
+++ b/drivers/pci/intel-iommu.c
@@ -2647,7 +2654,7 @@ static void flush_unmaps(void)
 			mask = (iova->pfn_hi - iova->pfn_lo + 1) << PAGE_SHIFT;
 			mask = ilog2(mask >> VTD_PAGE_SHIFT);
 			iommu_flush_dev_iotlb(deferred_flush[i].domain[j],
-					iova->pfn_lo << PAGE_SHIFT, mask);
+					iova->pfn_lo << VTD_PAGE_SHIFT, mask);
 			__free_iova(&deferred_flush[i].domain[j]->iovad, iova);
 		}
 		deferred_flush[i].next = 0;
