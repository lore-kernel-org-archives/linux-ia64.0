From: zhong jiang <zhongjiang@huawei.com>
Date: Fri, 10 Aug 2018 02:38:50 +0000
Subject: [PATCH] ia64:tioce_provider: Use kmemdup rather than implement the function
Message-Id: <1533868730-65425-1-git-send-email-zhongjiang@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com, fenghua.yu@intel.com
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

The kmemdup has implemented the function that kmalloc() + memcpy will
do. So just replace them to make the code concise.

Signed-off-by: zhong jiang <zhongjiang@huawei.com>
---
 arch/ia64/sn/pci/tioce_provider.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/ia64/sn/pci/tioce_provider.c b/arch/ia64/sn/pci/tioce_provider.c
index 3bd9abc..9ba61bc 100644
--- a/arch/ia64/sn/pci/tioce_provider.c
+++ b/arch/ia64/sn/pci/tioce_provider.c
@@ -1000,11 +1000,11 @@
 	 * Allocate kernel bus soft and copy from prom.
 	 */
 
-	tioce_common = kzalloc(sizeof(struct tioce_common), GFP_KERNEL);
+	tioce_common = kmemdup(prom_bussoft, sizeof(struct tioce_common),
+			       GFP_KERNEL);
 	if (!tioce_common)
 		return NULL;
 
-	memcpy(tioce_common, prom_bussoft, sizeof(struct tioce_common));
 	tioce_common->ce_pcibus.bs_base = (unsigned long)
 		ioremap(REGION_OFFSET(tioce_common->ce_pcibus.bs_base),
 			sizeof(struct tioce_common));
-- 
1.7.12.4
