From: Jiang Liu <jiang.liu@linux.intel.com>
Date: Mon, 17 Feb 2014 07:37:37 +0000
Subject: [PATCH v2] IA64, sba_iommu: fix section mismatch
Message-Id: <1392622660-18595-1-git-send-email-jiang.liu@linux.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1392616684-8410-1-git-send-email-jiang.liu@linux.intel.com>
In-Reply-To: <1392616684-8410-1-git-send-email-jiang.liu@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Yijing Wang <wangyijing@huawei.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Jiang Liu <jiang.liu@linux.intel.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Fix the section mismatch warning by remove __init annotate for function
acpi_sba_ioc_add() because it may be called at runtime.

WARNING: vmlinux.o(.data+0x66ee0): Section mismatch in reference from the variable acpi_sba_ioc_handler to the function .init.text:acpi_sba_ioc_add()
The variable acpi_sba_ioc_handler references
the function __init acpi_sba_ioc_add()

Signed-off-by: Jiang Liu <jiang.liu@linux.intel.com>
---
 arch/ia64/hp/common/sba_iommu.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/arch/ia64/hp/common/sba_iommu.c b/arch/ia64/hp/common/sba_iommu.c
index 8e858b5..30c43d3 100644
--- a/arch/ia64/hp/common/sba_iommu.c
+++ b/arch/ia64/hp/common/sba_iommu.c
@@ -1596,7 +1596,7 @@ static void sba_unmap_sg_attrs(struct device *dev, struct scatterlist *sglist,
 *
 ***************************************************************/
 
-static void __init
+static void
 ioc_iova_init(struct ioc *ioc)
 {
 	int tcnfg;
@@ -1807,7 +1807,7 @@ static struct ioc_iommu ioc_iommu_info[] __initdata = {
 	{ SX2000_IOC_ID, "sx2000", NULL },
 };
 
-static struct ioc * __init
+static struct ioc *
 ioc_init(unsigned long hpa, void *handle)
 {
 	struct ioc *ioc;
@@ -2041,7 +2041,7 @@ sba_map_ioc_to_node(struct ioc *ioc, acpi_handle handle)
 #define sba_map_ioc_to_node(ioc, handle)
 #endif
 
-static int __init
+static int
 acpi_sba_ioc_add(struct acpi_device *device,
 		 const struct acpi_device_id *not_used)
 {
-- 
1.7.10.4

