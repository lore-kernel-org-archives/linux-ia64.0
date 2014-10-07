From: Guenter Roeck <linux@roeck-us.net>
Date: Tue, 07 Oct 2014 05:28:45 +0000
Subject: [PATCH 43/44] hwmon: (ab8500) Call kernel_power_off instead of pm_power_off
Message-Id: <1412659726-29957-44-git-send-email-linux@roeck-us.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <1412659726-29957-1-git-send-email-linux@roeck-us.net>
In-Reply-To: <1412659726-29957-1-git-send-email-linux@roeck-us.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: adi-buildroot-devel@lists.sourceforge.net, devel@driverdev.osuosl.org, devicetree@vger.kernel.org, lguest@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-alpha@vger.kernel.org, linux-am33-list@redhat.com, linux-cris-kernel@axis.com, linux-efi@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-m32r-ja@ml.linux-m32r.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-tegra@vger.kernel.org, linux-xtensa@linux-xtensa.org, openipmi-developer@lists.sourceforge.net, user-mode-linux-devel@lists.sourceforge.net, linux-arm-kernel@lists.infradead.org, linux-c6x-dev@linux-c6x.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-metag@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linux-pm@vger.kernel.org, linux-sh@vger.kernel.org, xen-devel@lists.xenproject.org, Guenter Roeck <linux@roeck-us.net>, Jean

Drivers should not call pm_power_off directly; it is not guaranteed
to be non-NULL. Call kernel_power_off instead.

Cc: Jean Delvare <jdelvare@suse.de>
Reviewed-by: Jean Delvare <jdelvare@suse.de>
Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
 drivers/hwmon/ab8500.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/hwmon/ab8500.c b/drivers/hwmon/ab8500.c
index d844dc8..8b6a4f4 100644
--- a/drivers/hwmon/ab8500.c
+++ b/drivers/hwmon/ab8500.c
@@ -6,7 +6,7 @@
  *
  * When the AB8500 thermal warning temperature is reached (threshold cannot
  * be changed by SW), an interrupt is set, and if no further action is taken
- * within a certain time frame, pm_power off will be called.
+ * within a certain time frame, kernel_power_off will be called.
  *
  * When AB8500 thermal shutdown temperature is reached a hardware shutdown of
  * the AB8500 will occur.
@@ -21,6 +21,7 @@
 #include <linux/module.h>
 #include <linux/platform_device.h>
 #include <linux/power/ab8500.h>
+#include <linux/reboot.h>
 #include <linux/slab.h>
 #include <linux/sysfs.h>
 #include "abx500.h"
@@ -106,7 +107,7 @@ static void ab8500_thermal_power_off(struct work_struct *work)
 
 	dev_warn(&abx500_data->pdev->dev, "Power off due to critical temp\n");
 
-	pm_power_off();
+	kernel_power_off();
 }
 
 static ssize_t ab8500_show_name(struct device *dev,
-- 
1.9.1

