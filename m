From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Date: Wed, 25 Apr 2018 14:56:45 +0000
Subject: [PATCH] IA64: tiocx: use put_device() instead of kfree()
Message-Id: <1bcbd268184312155aec041bdd87c775ddb7cd8f.1524667391.git.arvind.yadav.cs@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com, fenghua.yu@intel.com
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Never directly free @dev after calling device_register(), even
if it returned an error. Always use put_device() to give up the
reference initialized.

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
---
 arch/ia64/sn/kernel/tiocx.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/ia64/sn/kernel/tiocx.c b/arch/ia64/sn/kernel/tiocx.c
index 32d0380..fd515bc 100644
--- a/arch/ia64/sn/kernel/tiocx.c
+++ b/arch/ia64/sn/kernel/tiocx.c
@@ -209,7 +209,7 @@ cx_device_register(nasid_t nasid, int part_num, int mfg_num,
 	dev_set_name(&cx_dev->dev, "%d", cx_dev->cx_id.nasid);
 	r = device_register(&cx_dev->dev);
 	if (r) {
-		kfree(cx_dev);
+		put_device(&cx_dev->dev);
 		return r;
 	}
 	get_device(&cx_dev->dev);
-- 
2.7.4

