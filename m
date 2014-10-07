From: Guenter Roeck <linux@roeck-us.net>
Date: Tue, 07 Oct 2014 05:28:12 +0000
Subject: [PATCH 10/44] mfd: axp20x: Register with kernel poweroff handler
Message-Id: <1412659726-29957-11-git-send-email-linux@roeck-us.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <1412659726-29957-1-git-send-email-linux@roeck-us.net>
In-Reply-To: <1412659726-29957-1-git-send-email-linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: adi-buildroot-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, devel-gWbeCf7V1WCQmaza687I9mD2FQJk+8+b@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, lguest-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, linux-acpi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-alpha-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-am33-list-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-cris-kernel-VrBV9hrLPhE@public.gmane.org, linux-efi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-hexagon-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-m32r-ja-rQhvJZKUsGBRYuoOT4C5/9i2O/JbrIOy@public.gmane.org, linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-tegra-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-xtensa-PjhNF2WwrV/0Sa2dR60CXw@public.gmane.org, openipmi-developer-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, user-mode-linux-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-c6x-dev-jPsnJVOj+W6hPH1hqNUYSQ@public.gmane.org, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-m68k-cunTk1MwBs8S/qaLPR03pWD2FQJk+8+b@public.gmane.org, linux-metag-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org, linux-parisc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-pm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-sh-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, xen-devel-GuqFBffKawtpuQazS67q72D2FQJk+8+b@public.gmane.org, Guenter Roeck <linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org>

Register with kernel poweroff handler instead of setting pm_power_off
directly. Register with a low priority value of 64 to reflect that
the original code only sets pm_power_off if it was not already set.

Cc: Lee Jones <lee.jones@linaro.org>
Cc: Samuel Ortiz <sameo@linux.intel.com>
Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
 drivers/mfd/axp20x.c       | 30 +++++++++++++++++-------------
 include/linux/mfd/axp20x.h |  1 +
 2 files changed, 18 insertions(+), 13 deletions(-)

diff --git a/drivers/mfd/axp20x.c b/drivers/mfd/axp20x.c
index dee6539..238db4c 100644
--- a/drivers/mfd/axp20x.c
+++ b/drivers/mfd/axp20x.c
@@ -17,7 +17,8 @@
 #include <linux/interrupt.h>
 #include <linux/kernel.h>
 #include <linux/module.h>
-#include <linux/pm_runtime.h>
+#include <linux/notifier.h>
+#include <linux/pm.h>
 #include <linux/regmap.h>
 #include <linux/slab.h>
 #include <linux/regulator/consumer.h>
@@ -161,11 +162,16 @@ static struct mfd_cell axp20x_cells[] = {
 	},
 };
 
-static struct axp20x_dev *axp20x_pm_power_off;
-static void axp20x_power_off(void)
+static int axp20x_power_off(struct notifier_block *this, unsigned long unused1,
+			    void *unused2)
+
 {
-	regmap_write(axp20x_pm_power_off->regmap, AXP20X_OFF_CTRL,
-		     AXP20X_OFF);
+	struct axp20x_dev *axp20x = container_of(this, struct axp20x_dev,
+						 poweroff_nb);
+
+	regmap_write(axp20x->regmap, AXP20X_OFF_CTRL, AXP20X_OFF);
+
+	return NOTIFY_DONE;
 }
 
 static int axp20x_i2c_probe(struct i2c_client *i2c,
@@ -215,10 +221,11 @@ static int axp20x_i2c_probe(struct i2c_client *i2c,
 		return ret;
 	}
 
-	if (!pm_power_off) {
-		axp20x_pm_power_off = axp20x;
-		pm_power_off = axp20x_power_off;
-	}
+	axp20x->poweroff_nb.notifier_call = axp20x_power_off;
+	axp20x->poweroff_nb.priority = 64;
+	ret = register_poweroff_handler(&axp20x->poweroff_nb);
+	if (ret)
+		dev_err(&i2c->dev, "failed to register poweroff handler\n");
 
 	dev_info(&i2c->dev, "AXP20X driver loaded\n");
 
@@ -229,10 +236,7 @@ static int axp20x_i2c_remove(struct i2c_client *i2c)
 {
 	struct axp20x_dev *axp20x = i2c_get_clientdata(i2c);
 
-	if (axp20x = axp20x_pm_power_off) {
-		axp20x_pm_power_off = NULL;
-		pm_power_off = NULL;
-	}
+	unregister_poweroff_handler(&axp20x->poweroff_nb);
 
 	mfd_remove_devices(axp20x->dev);
 	regmap_del_irq_chip(axp20x->i2c_client->irq, axp20x->regmap_irqc);
diff --git a/include/linux/mfd/axp20x.h b/include/linux/mfd/axp20x.h
index d0e31a2..8f23b39 100644
--- a/include/linux/mfd/axp20x.h
+++ b/include/linux/mfd/axp20x.h
@@ -175,6 +175,7 @@ struct axp20x_dev {
 	struct regmap			*regmap;
 	struct regmap_irq_chip_data	*regmap_irqc;
 	long				variant;
+	struct notifier_block		poweroff_nb;
 };
 
 #endif /* __LINUX_MFD_AXP20X_H */
-- 
1.9.1

