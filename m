From: Levente Kurusa <levex@linux.com>
Date: Thu, 19 Dec 2013 15:03:29 +0000
Subject: [PATCH 18/38] ia64: kernel: add missing put_device call
Message-Id: <1387465429-3568-19-git-send-email-levex@linux.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1387465429-3568-2-git-send-email-levex@linux.com>
In-Reply-To: <1387465429-3568-2-git-send-email-levex@linux.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: LKML <linux-kernel@vger.kernel.org>
Cc: Levente Kurusa <levex@linux.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Jiri Kosina <jkosina@suse.cz>, linux-ia64@vger.kernel.org

This is required so that we give up the last reference to the device.
Removed kfree() as put_device() will result in tiocx_bus_release called.

Signed-off-by: Levente Kurusa <levex@linux.com>
---
 arch/ia64/sn/kernel/tiocx.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/ia64/sn/kernel/tiocx.c b/arch/ia64/sn/kernel/tiocx.c
index e35f648..6f369cc 100644
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
1.8.3.1

