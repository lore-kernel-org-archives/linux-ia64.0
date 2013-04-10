From: Hanjun Guo <guohanjun@huawei.com>
Date: Wed, 10 Apr 2013 10:22:58 +0000
Subject: [PATCH 1/4] cpuidle: fix error handling in __cpuidle_register_device
Message-Id: <1365589381-5624-2-git-send-email-guohanjun@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1365589381-5624-1-git-send-email-guohanjun@huawei.com>
In-Reply-To: <1365589381-5624-1-git-send-email-guohanjun@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: kernel.openeuler@huawei.com
Cc: Toshi Kani <toshi.kani@hp.com>, Jiang Liu <jiang.liu@huawei.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

From: Colin Cross <ccross@android.com>

mainline inclusion
from mainline-3.6
upstream commit 3af272ab75c7a0c7fa5ae5507724d961f7e7718b
category: bugfix

--------------------------------------------------------

Fix the error handling in __cpuidle_register_device to include
the missing list_del.  Move it to a label, which will simplify
the error handling when coupled states are added.

Reviewed-by: Santosh Shilimkar <santosh.shilimkar@ti.com>
Tested-by: Santosh Shilimkar <santosh.shilimkar@ti.com>
Reviewed-by: Kevin Hilman <khilman@ti.com>
Tested-by: Kevin Hilman <khilman@ti.com>
Signed-off-by: Colin Cross <ccross@android.com>
Reviewed-by: Rafael J. Wysocki <rjw@sisk.pl>
Signed-off-by: Len Brown <len.brown@intel.com>
Integrated-by: Hanjun Guo <guohanjun@huawei.com>
---
 drivers/cpuidle/cpuidle.c |   13 +++++++++----
 1 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/drivers/cpuidle/cpuidle.c b/drivers/cpuidle/cpuidle.c
index 2f0083a..7407a98 100644
--- a/drivers/cpuidle/cpuidle.c
+++ b/drivers/cpuidle/cpuidle.c
@@ -387,13 +387,18 @@ static int __cpuidle_register_device(struct cpuidle_device *dev)
 
 	per_cpu(cpuidle_devices, dev->cpu) = dev;
 	list_add(&dev->device_list, &cpuidle_detected_devices);
-	if ((ret = cpuidle_add_sysfs(cpu_dev))) {
-		module_put(cpuidle_driver->owner);
-		return ret;
-	}
+	ret = cpuidle_add_sysfs(cpu_dev);
+	if (ret)
+		goto err_sysfs;
 
 	dev->registered = 1;
 	return 0;
+
+err_sysfs:
+	list_del(&dev->device_list);
+	per_cpu(cpuidle_devices, dev->cpu) = NULL;
+	module_put(cpuidle_driver->owner);
+	return ret;
 }
 
 /**
-- 
1.6.0.2


