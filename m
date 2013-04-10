From: Hanjun Guo <guohanjun@huawei.com>
Date: Wed, 10 Apr 2013 10:23:00 +0000
Subject: [PATCH 3/4] ACPI: Untangle a return statement for better readability
Message-Id: <1365589381-5624-4-git-send-email-guohanjun@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1365589381-5624-1-git-send-email-guohanjun@huawei.com>
In-Reply-To: <1365589381-5624-1-git-send-email-guohanjun@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: kernel.openeuler@huawei.com
Cc: Toshi Kani <toshi.kani@hp.com>, Jiang Liu <jiang.liu@huawei.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

From: Thomas Renninger <trenn@suse.de>

mainline inclusion
from mainline-3.6
upstream commit f3946fb6e50b750d34f445188fa6746d14596afa
category: cleanup

This patch is cleanup patch, but the next bugfix patch is
upon it.

--------------------------------------------------------

No functional change.

Signed-off-by: Thomas Renninger <trenn@suse.de>
Signed-off-by: Len Brown <len.brown@intel.com>
Integrated-by: Hanjun Guo <guohanjun@huawei.com>
---
 drivers/acpi/numa.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/acpi/numa.c b/drivers/acpi/numa.c
index e56f3be..2a63993 100644
--- a/drivers/acpi/numa.c
+++ b/drivers/acpi/numa.c
@@ -304,8 +304,10 @@ int __init acpi_numa_init(void)
 
 	acpi_numa_arch_fixup();
 
-	if (cnt <= 0)
-		return cnt ?: -ENOENT;
+	if (cnt < 0)
+		return cnt;
+	else if (cnt = 0)
+		return -ENOENT;
 	return 0;
 }
 
-- 
1.6.0.2


