From: Fenghua Yu <fenghua.yu@intel.com>
Date: Tue, 04 Aug 2009 22:10:24 +0000
Subject: [PATCH 2/4] Bug Fix drivers/pci/intel-iommu.c: secure sg_next() calling
Message-Id: <20090804221024.GA21406@linux-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <BAE9DCEF64577A439B3A37F36F9B691C0339372B@orsmsx418.amr.corp.intel.com> <617E1C2C70743745A92448908E030B2A02AD5AD7@scsmsx411.amr.corp.intel.com>
In-Reply-To: <617E1C2C70743745A92448908E030B2A02AD5AD7@scsmsx411.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Woodhouse <dwmw2@infradead.org>, Tony Luck <tony.luck@intel.com>
Cc: iommu@lists.linux-foundation.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Fenghua Yu <fenghua.yu@intel.com>

sg_next() is called only when sg is not NULL. This solves a kernel panic on
some platforms (e.g. ia64).

Signed-off-by: Fenghua Yu <fenghua.yu@intel.com>

---

 drivers/pci/intel-iommu.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/pci/intel-iommu.c b/drivers/pci/intel-iommu.c
index bec29ed..54ee63d 100644
--- a/drivers/pci/intel-iommu.c
+++ b/drivers/pci/intel-iommu.c
@@ -1705,8 +1715,12 @@ static int __domain_mapping(struct dmar_domain *domain, unsigned long iov_pfn,
 		iov_pfn++;
 		pteval += VTD_PAGE_SIZE;
 		sg_res--;
-		if (!sg_res)
-			sg = sg_next(sg);
+		if (!sg_res) {
+			if (sg)
+				sg = sg_next(sg);
+			else
+				return 0;
+		}
 	}
 	return 0;
 }
