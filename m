From: Colin King <colin.king@canonical.com>
Date: Fri, 02 Mar 2018 09:10:30 +0000
Subject: [PATCH] ia64/err-inject: fix spelling mistake: "capapbilities" -> "capabilities"
Message-Id: <20180302091030.25897-1-colin.king@canonical.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

Trivial fix to spelling mistake in debug message text.

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 arch/ia64/kernel/err_inject.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/ia64/kernel/err_inject.c b/arch/ia64/kernel/err_inject.c
index 85bba43e7d5d..34e460bd8a95 100644
--- a/arch/ia64/kernel/err_inject.c
+++ b/arch/ia64/kernel/err_inject.c
@@ -117,7 +117,7 @@ store_call_start(struct device *dev, struct device_attribute *attr,
 
 #ifdef ERR_INJ_DEBUG
 	printk(KERN_DEBUG "Returns: status=%d,\n", (int)status[cpu]);
-	printk(KERN_DEBUG "capapbilities=%lx,\n", capabilities[cpu]);
+	printk(KERN_DEBUG "capabilities=%lx,\n", capabilities[cpu]);
 	printk(KERN_DEBUG "resources=%lx\n", resources[cpu]);
 #endif
 	return size;
-- 
2.15.1

