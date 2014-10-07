From: Guenter Roeck <linux@roeck-us.net>
Date: Tue, 07 Oct 2014 05:28:22 +0000
Subject: [PATCH 20/44] power/reset: restart-poweroff: Register with kernel poweroff handler
Message-Id: <1412659726-29957-21-git-send-email-linux@roeck-us.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <1412659726-29957-1-git-send-email-linux@roeck-us.net>
In-Reply-To: <1412659726-29957-1-git-send-email-linux@roeck-us.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: linux-m32r-ja@ml.linux-m32r.org, linux-mips@linux-mips.org, linux-efi@vger.kernel.org, linux-ia64@vger.kernel.org, linux-xtensa@linux-xtensa.org, devel@driverdev.osuosl.org, linux-s390@vger.kernel.org, lguest@lists.ozlabs.org, linux-c6x-dev@linux-c6x.org, Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>, linux-hexagon@vger.kernel.org, linux-sh@vger.kernel.org, linux-acpi@vger.kernel.org, xen-devel@lists.xenproject.org, Guenter Roeck <linux@roeck-us.net>, devicetree@vger.kernel.org, user-mode-linux-devel@lists.sourceforge.net, linux-pm@vger.kernel.org, adi-buildroot-devel@lists.sourceforge.net, linux-m68k@lists.linux-m68k.org, linux-am33-list@redhat.com, linux-tegra@vger.kernel.org, openipmi-developer@lists.sourceforge.net, linux-metag@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-parisc@vger.kernel.org, linux-cris-kernel@axis.com, David Woodhouse <dwmw2@infr>

Register with kernel poweroff handler instead of seting pm_power_off
directly.  Register as poweroff handler of last resort since the driver
does not really power off the system but executes a restart.

Cc: Sebastian Reichel <sre@kernel.org>
Cc: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Cc: David Woodhouse <dwmw2@infradead.org>
Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
 drivers/power/reset/restart-poweroff.c | 25 ++++++++++++-------------
 1 file changed, 12 insertions(+), 13 deletions(-)

diff --git a/drivers/power/reset/restart-poweroff.c b/drivers/power/reset/restart-poweroff.c
index edd707e..5437697 100644
--- a/drivers/power/reset/restart-poweroff.c
+++ b/drivers/power/reset/restart-poweroff.c
@@ -12,35 +12,34 @@
  */
 #include <linux/kernel.h>
 #include <linux/init.h>
+#include <linux/notifier.h>
 #include <linux/platform_device.h>
 #include <linux/of_platform.h>
 #include <linux/module.h>
+#include <linux/pm.h>
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
+	return register_poweroff_handler(&restart_poweroff_handler);
 }
 
 static int restart_poweroff_remove(struct platform_device *pdev)
 {
-	if (pm_power_off = &restart_poweroff_do_poweroff)
-		pm_power_off = NULL;
+	unregister_poweroff_handler(&restart_poweroff_handler);
 
 	return 0;
 }
-- 
1.9.1

