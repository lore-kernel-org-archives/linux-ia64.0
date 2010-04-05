From: Joe Perches <joe@perches.com>
Date: Mon, 05 Apr 2010 19:05:31 +0000
Subject: [PATCH 01/11] arch/ia64/hp/common/sba_iommu.c: Rename dev_info to adi
Message-Id: <efbe5e3689b7668cb68a7e226af88129880e6d3c.1270493677.git.joe@perches.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20100304232928.2e45bdd1.akpm@linux-foundation.org>
In-Reply-To: <20100304232928.2e45bdd1.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

There is a macro called dev_info that prints struct device specific
information.  Having variables with the same name can be confusing and
prevents conversion of the macro to a function.

Rename the existing dev_info variables to something else in preparation
to converting the dev_info macro to a function.

Signed-off-by: Joe Perches <joe@perches.com>
---
 arch/ia64/hp/common/sba_iommu.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/arch/ia64/hp/common/sba_iommu.c b/arch/ia64/hp/common/sba_iommu.c
index e14c492..4ce8d13 100644
--- a/arch/ia64/hp/common/sba_iommu.c
+++ b/arch/ia64/hp/common/sba_iommu.c
@@ -2046,13 +2046,13 @@ acpi_sba_ioc_add(struct acpi_device *device)
 	struct ioc *ioc;
 	acpi_status status;
 	u64 hpa, length;
-	struct acpi_device_info *dev_info;
+	struct acpi_device_info *adi;
 
 	status = hp_acpi_csr_space(device->handle, &hpa, &length);
 	if (ACPI_FAILURE(status))
 		return 1;
 
-	status = acpi_get_object_info(device->handle, &dev_info);
+	status = acpi_get_object_info(device->handle, &adi);
 	if (ACPI_FAILURE(status))
 		return 1;
 
@@ -2060,13 +2060,13 @@ acpi_sba_ioc_add(struct acpi_device *device)
 	 * For HWP0001, only SBA appears in ACPI namespace.  It encloses the PCI
 	 * root bridges, and its CSR space includes the IOC function.
 	 */
-	if (strncmp("HWP0001", dev_info->hardware_id.string, 7) = 0) {
+	if (strncmp("HWP0001", adi->hardware_id.string, 7) = 0) {
 		hpa += ZX1_IOC_OFFSET;
 		/* zx1 based systems default to kernel page size iommu pages */
 		if (!iovp_shift)
 			iovp_shift = min(PAGE_SHIFT, 16);
 	}
-	kfree(dev_info);
+	kfree(adi);
 
 	/*
 	 * default anything not caught above or specified on cmdline to 4k
-- 
1.7.0.3.311.g6a6955

