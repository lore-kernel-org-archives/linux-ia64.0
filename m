From: Fenghua Yu <fenghua.yu@intel.com>
Date: Wed, 13 May 2009 23:13:51 +0000
Subject: [PATCH] Fix Intel IOMMU Compilation Warnings on IA64
Message-Id: <20090513231351.GA22386@linux-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090327212241.234500000@intel.com> <20090327212321.070229000@intel.com> <20090416001957.GA1527@linux-os.sc.intel.com> <1240135508.3589.75.camel@macbook.infradead.org> <A6AD88C3F2289247BE726C37303E1EB8A4DF7DB1@orsmsx505.amr.corp.intel.com>
In-Reply-To: <A6AD88C3F2289247BE726C37303E1EB8A4DF7DB1@orsmsx505.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 'David Woodhouse' <dwmw2@infradead.org>, 'Tony Luck' <tony.luck@intel.com>
Cc: 'lkml' <linux-kernel@vger.kernel.org>, 'iommu' <iommu@lists.linux-foundation.org>, 'ia64' <linux-ia64@vger.kernel.org>

Compiling kernel on IA64 reports two warnings in intel-iommu.c:

drivers/pci/intel-iommu.c:3150: warning: format ?%llx? expects type ?long long unsigned int?, but argument 4 has type ?u64?
drivers/pci/intel-iommu.c: In function ?intel_iommu_map_range?:
drivers/pci/intel-iommu.c:3201: warning: format ?%llx? expects type ?long long unsigned int?, but argument 4 has type ?u64?

The warnings are fixed by adding type cast unsigned long long.

Signed-off-by: Fenghua Yu <fegnhua.yu@intel.com>

---

 intel-iommu.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/pci/intel-iommu.c b/drivers/pci/intel-iommu.c
index a563fbe..6f8cc21 100644
--- a/drivers/pci/intel-iommu.c
+++ b/drivers/pci/intel-iommu.c
@@ -3147,7 +3147,8 @@ static int intel_iommu_attach_device(struct iommu_domain *domain,
 	if (end < dmar_domain->max_addr) {
 		printk(KERN_ERR "%s: iommu agaw (%d) is not "
 		       "sufficient for the mapped address (%llx)\n",
-		       __func__, iommu->agaw, dmar_domain->max_addr);
+		       __func__, iommu->agaw,
+		       (unsigned long long)dmar_domain->max_addr);
 		return -EFAULT;
 	}
 
@@ -3198,7 +3199,8 @@ static int intel_iommu_map_range(struct iommu_domain *domain,
 		if (end < max_addr) {
 			printk(KERN_ERR "%s: iommu agaw (%d) is not "
 			       "sufficient for the mapped address (%llx)\n",
-			       __func__, min_agaw, max_addr);
+			       __func__, min_agaw,
+			       (unsigned long long)max_addr);
 			return -EFAULT;
 		}
 		dmar_domain->max_addr = max_addr;
