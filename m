From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Sun, 26 Feb 2012 18:46:07 +0000
Subject: [PATCH] ia64: add unwind code for device_register to tiocx.c
Message-Id: <1330281967-16361-1-git-send-email-paul.gortmaker@windriver.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: jes@sgi.com, tony.luck@intel.com, fenghua.yu@intel.com
Cc: linux-ia64@vger.kernel.org, linux-next@vger.kernel.org, Paul Gortmaker <paul.gortmaker@windriver.com>

The device_register() is declared with must_check, causing this:

arch/ia64/sn/kernel/tiocx.c: In function 'cx_device_register':
arch/ia64/sn/kernel/tiocx.c:210:17: warning: ignoring return value of 'device_register', declared with attribute warn_unused_result

Check the return value, and free resources if it fails.

Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---

[seen in linux-next-20120224 tree; probably also happens in mainline]

diff --git a/arch/ia64/sn/kernel/tiocx.c b/arch/ia64/sn/kernel/tiocx.c
index c1bd1cf..2f406f5 100644
--- a/arch/ia64/sn/kernel/tiocx.c
+++ b/arch/ia64/sn/kernel/tiocx.c
@@ -191,6 +191,7 @@ cx_device_register(nasid_t nasid, int part_num, int mfg_num,
 		   struct hubdev_info *hubdev, int bt)
 {
 	struct cx_dev *cx_dev;
+	int r;
 
 	cx_dev = kzalloc(sizeof(struct cx_dev), GFP_KERNEL);
 	DBG("cx_dev= 0x%p\n", cx_dev);
@@ -207,7 +208,11 @@ cx_device_register(nasid_t nasid, int part_num, int mfg_num,
 	cx_dev->dev.bus = &tiocx_bus_type;
 	cx_dev->dev.release = tiocx_bus_release;
 	dev_set_name(&cx_dev->dev, "%d", cx_dev->cx_id.nasid);
-	device_register(&cx_dev->dev);
+	r = device_register(&cx_dev->dev);
+	if (r) {
+		kfree(cx_dev);
+		return r;
+	}
 	get_device(&cx_dev->dev);
 
 	device_create_file(&cx_dev->dev, &dev_attr_cxdev_control);
-- 
1.7.9.1

