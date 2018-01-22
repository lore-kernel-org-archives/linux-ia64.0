From: Davidlohr Bueso <dave@stgolabs.net>
Date: Mon, 22 Jan 2018 17:21:37 +0000
Subject: [PATCH] ia64/err-inject: Use get_user_pages_fast()
Message-Id: <20180122172137.26849-1-dave@stgolabs.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com, fenghua.yu@intel.com
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, dave@stgolabs.net, Davidlohr Bueso <dbueso@suse.de>

At the point of sysfs callback, the call to gup is
done without mmap_sem (or any lock for that matter).
This is racy. As such, use the get_user_pages_fast()
alternative and safely avoid taking the lock, if possible.

Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
---
 arch/ia64/kernel/err_inject.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/ia64/kernel/err_inject.c b/arch/ia64/kernel/err_inject.c
index 85bba43e7d5d..658a8e06a69b 100644
--- a/arch/ia64/kernel/err_inject.c
+++ b/arch/ia64/kernel/err_inject.c
@@ -142,7 +142,7 @@ store_virtual_to_phys(struct device *dev, struct device_attribute *attr,
 	u64 virt_addr=simple_strtoull(buf, NULL, 16);
 	int ret;
 
-	ret = get_user_pages(virt_addr, 1, FOLL_WRITE, NULL, NULL);
+	ret = get_user_pages_fast(virt_addr, 1, FOLL_WRITE, NULL);
 	if (ret<=0) {
 #ifdef ERR_INJ_DEBUG
 		printk("Virtual address %lx is not existing.\n",virt_addr);
-- 
2.13.6

