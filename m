From: Stoyan Gaydarov <sgayda2@uiuc.edu>
Date: Wed, 22 Jul 2009 03:02:32 +0000
Subject: [PATCH 6/7] [ia64] ARRAY_SIZE changes
Message-Id: <1248231753-8344-7-git-send-email-sgayda2@uiuc.edu>
List-Id: <linux-ia64.vger.kernel.org>
References: <1248231753-8344-1-git-send-email-sgayda2@uiuc.edu>
 <1248231753-8344-2-git-send-email-sgayda2@uiuc.edu>
 <1248231753-8344-3-git-send-email-sgayda2@uiuc.edu>
 <1248231753-8344-4-git-send-email-sgayda2@uiuc.edu>
 <1248231753-8344-5-git-send-email-sgayda2@uiuc.edu>
 <1248231753-8344-6-git-send-email-sgayda2@uiuc.edu>
In-Reply-To: <1248231753-8344-6-git-send-email-sgayda2@uiuc.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Stoyan Gaydarov <sgayda2@uiuc.edu>, tony.luck@intel.com, fenghua.yu@intel.com, linux-ia64@vger.kernel.org

These changes were a direct result of using a semantic patch
More information can be found at http://www.emn.fr/x-info/coccinelle/

Signed-off-by: Stoyan Gaydarov <sgayda2@uiuc.edu>
---
 arch/ia64/kernel/perfmon.c |    2 +-
 arch/ia64/xen/xen_pv_ops.c |    3 +--
 2 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/arch/ia64/kernel/perfmon.c b/arch/ia64/kernel/perfmon.c
index f178270..15e8fbb 100644
--- a/arch/ia64/kernel/perfmon.c
+++ b/arch/ia64/kernel/perfmon.c
@@ -4693,7 +4693,7 @@ static pfm_cmd_desc_t pfm_cmd_tab[]={
 /* 32 */PFM_CMD(pfm_write_ibrs, PFM_CMD_PCLRWS, PFM_CMD_ARG_MANY, pfarg_dbreg_t, NULL),
 /* 33 */PFM_CMD(pfm_write_dbrs, PFM_CMD_PCLRWS, PFM_CMD_ARG_MANY, pfarg_dbreg_t, NULL)
 };
-#define PFM_CMD_COUNT	(sizeof(pfm_cmd_tab)/sizeof(pfm_cmd_desc_t))
+#define PFM_CMD_COUNT	ARRAY_SIZE(pfm_cmd_tab)
 
 static int
 pfm_check_task_state(pfm_context_t *ctx, int cmd, unsigned long flags)
diff --git a/arch/ia64/xen/xen_pv_ops.c b/arch/ia64/xen/xen_pv_ops.c
index 5e2270a..3ce0fdb 100644
--- a/arch/ia64/xen/xen_pv_ops.c
+++ b/arch/ia64/xen/xen_pv_ops.c
@@ -1102,8 +1102,7 @@ __initdata_or_module  static unsigned long __init_or_module
 xen_patch_bundle(void *sbundle, void *ebundle, unsigned long type)
 {
-	const unsigned long nelems = sizeof(xen_patch_bundle_elems) /
-		sizeof(xen_patch_bundle_elems[0]);
+	const unsigned long nelems = ARRAY_SIZE(xen_patch_bundle_elems);
 	unsigned long used;
 	const struct paravirt_patch_bundle_elem *found;
 
-- 
1.6.3.3

