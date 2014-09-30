From: Guenter Roeck <linux@roeck-us.net>
Date: Tue, 30 Sep 2014 18:00:55 +0000
Subject: [RFC PATCH 15/16] power/reset: restart-poweroff: Register with kernel poweroff handler
Message-Id: <1412100056-15517-16-git-send-email-linux@roeck-us.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <1412100056-15517-1-git-send-email-linux@roeck-us.net>
In-Reply-To: <1412100056-15517-1-git-send-email-linux@roeck-us.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org

Register with kernel poweroff handler instead of seting pm_power_off
directly.  Register as poweroff handler of last resort since the driver
does not really power off the system but executes a restart.

Cc: Sebastian Reichel <sre@kernel.org>
Cc: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Cc: David Woodhouse <dwmw2@infradead.org>
Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
 drivers/power/reset/restart-poweroff.c | 24 +++++++++++-------------
 1 file changed, 11 insertions(+), 13 deletions(-)

diff --git a/drivers/power/reset/restart-poweroff.c b/drivers/power/reset/restart-poweroff.c
index edd707e..82d058f 100644
--- a/drivers/power/reset/restart-poweroff.c
+++ b/drivers/power/reset/restart-poweroff.c
@@ -12,35 +12,33 @@
  */
 #include <linux/kernel.h>
 #include <linux/init.h>
+#include <linux/notifier.h>
 #include <linux/platform_device.h>
 #include <linux/of_platform.h>
 #include <linux/module.h>
 #include <linux/reboot.h>
-#include <asm/system_misc.h>
 
-static void restart_poweroff_do_poweroff(void)
+static int restart_poweroff_do_poweroff(struct notifier_block *this,
+					unsigned long unused1, void *unused2)
 {
 	reboot_mode = REBOOT_HARD;
 	machine_restart(NULL);
+
+	return NOTIFY_DONE;
 }
 
+static struct notifier_block restart_poweroff_handler = {
+	.notifier_call = restart_poweroff_do_poweroff,
+};
+
 static int restart_poweroff_probe(struct platform_device *pdev)
 {
-	/* If a pm_power_off function has already been added, leave it alone */
-	if (pm_power_off != NULL) {
-		dev_err(&pdev->dev,
-			"pm_power_off function already registered");
-		return -EBUSY;
-	}
-
-	pm_power_off = &restart_poweroff_do_poweroff;
-	return 0;
+	return register_restart_handler(&restart_poweroff_handler);
 }
 
 static int restart_poweroff_remove(struct platform_device *pdev)
 {
-	if (pm_power_off = &restart_poweroff_do_poweroff)
-		pm_power_off = NULL;
+	unregister_restart_handler(&restart_poweroff_handler);
 
 	return 0;
 }
-- 
1.9.1

