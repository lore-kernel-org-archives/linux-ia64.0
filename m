From: Tony Luck <tony.luck@intel.com>
Date: Wed, 22 Aug 2018 20:39:21 +0000
Subject: [PATCH] ia64: Fix allnoconfig section mismatch for ioc_init/ioc_iommu_info
Message-Id: <20180822203921.30244-1-tony.luck@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This has been broken for an embarassingly long time (since v4.4).

Just needs a couple of __init tags on functions to make the sections
match up.

Signed-off-by: Tony Luck <tony.luck@intel.com>
---
 arch/ia64/hp/common/sba_iommu.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/ia64/hp/common/sba_iommu.c b/arch/ia64/hp/common/sba_iommu.c
index ee5b652d320a..671ce1e3f6f2 100644
--- a/arch/ia64/hp/common/sba_iommu.c
+++ b/arch/ia64/hp/common/sba_iommu.c
@@ -1805,7 +1805,7 @@ static struct ioc_iommu ioc_iommu_info[] __initdata = {
 	{ SX2000_IOC_ID, "sx2000", NULL },
 };
 
-static void ioc_init(unsigned long hpa, struct ioc *ioc)
+static void __init ioc_init(unsigned long hpa, struct ioc *ioc)
 {
 	struct ioc_iommu *info;
 
@@ -2002,7 +2002,7 @@ sba_map_ioc_to_node(struct ioc *ioc, acpi_handle handle)
 #endif
 }
 
-static void acpi_sba_ioc_add(struct ioc *ioc)
+static void __init acpi_sba_ioc_add(struct ioc *ioc)
 {
 	acpi_handle handle = ioc->handle;
 	acpi_status status;
-- 
2.17.1
