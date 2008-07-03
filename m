From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Thu, 03 Jul 2008 07:10:53 +0000
Subject: [PATCH] xen: remove load_cr3() from manage.c for ia64 support.
Message-Id: <20080703071053.GC15683%yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: jeremy@goop.org
Cc: linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, linux-ia64@vger.kernel.org, xen-devel@lists.xensource.com, xen-ia64-devel@lists.xensource.com

remove load_cr3() from manage.c. It is unncessary and x86 dependent.

Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 drivers/xen/manage.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/xen/manage.c b/drivers/xen/manage.c
index 2bb268e..e8db90c 100644
--- a/drivers/xen/manage.c
+++ b/drivers/xen/manage.c
@@ -39,8 +39,6 @@ static int xen_suspend(void *data)
 
 	BUG_ON(!irqs_disabled());
 
-	load_cr3(swapper_pg_dir);
-
 	err = device_power_down(PMSG_SUSPEND);
 	if (err) {
 		printk(KERN_ERR "xen_suspend: device_power_down failed: %d\n",
-- 
1.5.3

