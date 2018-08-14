From: zhong jiang <zhongjiang@huawei.com>
Date: Tue, 14 Aug 2018 10:35:22 +0000
Subject: [PATCH v2] ia64: Use ARRAY_SIZE to replace its implementation
Message-Id: <1534242922-29258-1-git-send-email-zhongjiang@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com, fenghua.yu@intel.com
Cc: dhowells@redhat.com, rppt@linux.vnet.ibm.com, golf@perches.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

We prefer to ARRAY_SIZE rather than duplicating its implementation.
And just one place use the #define variable, therefore, remove
PFM_CMD_COUNT definition altogether.

Signed-off-by: zhong jiang <zhongjiang@huawei.com>
---
v1->v2:
  -  According to Joe's suggestion. remove the #define variable,
     and use ARRAY_SIZE to replace directly.

 arch/ia64/kernel/perfmon.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/arch/ia64/kernel/perfmon.c b/arch/ia64/kernel/perfmon.c
index a9d4dc6..bfe0094c 100644
--- a/arch/ia64/kernel/perfmon.c
+++ b/arch/ia64/kernel/perfmon.c
@@ -4645,7 +4645,6 @@ static char *pfmfs_dname(struct dentry *dentry, char *buffer, int buflen)
 /* 32 */PFM_CMD(pfm_write_ibrs, PFM_CMD_PCLRWS, PFM_CMD_ARG_MANY, pfarg_dbreg_t, NULL),
 /* 33 */PFM_CMD(pfm_write_dbrs, PFM_CMD_PCLRWS, PFM_CMD_ARG_MANY, pfarg_dbreg_t, NULL)
 };
-#define PFM_CMD_COUNT	(sizeof(pfm_cmd_tab)/sizeof(pfm_cmd_desc_t))
 
 static int
 pfm_check_task_state(pfm_context_t *ctx, int cmd, unsigned long flags)
@@ -4770,7 +4769,7 @@ static char *pfmfs_dname(struct dentry *dentry, char *buffer, int buflen)
 	 */
 	if (unlikely(pmu_conf = NULL)) return -ENOSYS;
 
-	if (unlikely(cmd < 0 || cmd >= PFM_CMD_COUNT)) {
+	if (unlikely(cmd < 0 || cmd >= ARRAY_SIZE(pfm_cmd_tab))) {
 		DPRINT(("invalid cmd=%d\n", cmd));
 		return -EINVAL;
 	}
-- 
1.7.12.4
