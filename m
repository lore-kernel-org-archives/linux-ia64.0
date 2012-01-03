From: Gilad Ben-Yossef <gilad@benyossef.com>
Date: Tue, 03 Jan 2012 14:19:06 +0000
Subject: [RFC PATCH 2/9] ia64: avoid using on_each_cpu hard coded ret value
Message-Id: <1325600353-10895-3-git-send-email-gilad@benyossef.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1325600353-10895-1-git-send-email-gilad@benyossef.com>
In-Reply-To: <1325600353-10895-1-git-send-email-gilad@benyossef.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Gilad Ben-Yossef <gilad@benyossef.com>, Michal Nazarewicz <mina86@mina86.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

    on_each_cpu always returns a hard coded return code of zero.

    Removing all tests based on this return value saves run time
    cycles for compares and code bloat for branches.

Cc: Michal Nazarewicz <mina86@mina86.com>
CC: Tony Luck <tony.luck@intel.com>
CC: Fenghua Yu <fenghua.yu@intel.com>
CC: linux-ia64@vger.kernel.org
---
 arch/ia64/kernel/perfmon.c |   12 ++----------
 1 files changed, 2 insertions(+), 10 deletions(-)

diff --git a/arch/ia64/kernel/perfmon.c b/arch/ia64/kernel/perfmon.c
index 89accc6..eb7cfa5 100644
--- a/arch/ia64/kernel/perfmon.c
+++ b/arch/ia64/kernel/perfmon.c
@@ -6511,11 +6511,7 @@ pfm_install_alt_pmu_interrupt(pfm_intr_handler_desc_t *hdl)
 	}
 
 	/* save the current system wide pmu states */
-	ret = on_each_cpu(pfm_alt_save_pmu_state, NULL, 1);
-	if (ret) {
-		DPRINT(("on_each_cpu() failed: %d\n", ret));
-		goto cleanup_reserve;
-	}
+	on_each_cpu(pfm_alt_save_pmu_state, NULL, 1);
 
 	/* officially change to the alternate interrupt handler */
 	pfm_alt_intr_handler = hdl;
@@ -6542,7 +6538,6 @@ int
 pfm_remove_alt_pmu_interrupt(pfm_intr_handler_desc_t *hdl)
 {
 	int i;
-	int ret;
 
 	if (hdl = NULL) return -EINVAL;
 
@@ -6556,10 +6551,7 @@ pfm_remove_alt_pmu_interrupt(pfm_intr_handler_desc_t *hdl)
 
 	pfm_alt_intr_handler = NULL;
 
-	ret = on_each_cpu(pfm_alt_restore_pmu_state, NULL, 1);
-	if (ret) {
-		DPRINT(("on_each_cpu() failed: %d\n", ret));
-	}
+	on_each_cpu(pfm_alt_restore_pmu_state, NULL, 1);
 
 	for_each_online_cpu(i) {
 		pfm_unreserve_session(NULL, 1, i);
-- 
1.7.0.4

