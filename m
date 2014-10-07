From: Guenter Roeck <linux@roeck-us.net>
Date: Tue, 07 Oct 2014 05:28:15 +0000
Subject: [PATCH 13/44] mfd: max8907: Register with kernel poweroff handler
Message-Id: <1412659726-29957-14-git-send-email-linux@roeck-us.net>
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

Note that this patch fixes a problem on driver unload as side effect:
The old code did not restore or clean up pm_power_off on remove,
meaning the pointer was left in an undefined state.

Cc: Lee Jones <lee.jones@linaro.org>
Cc: Samuel Ortiz <sameo@linux.intel.com>
Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
 drivers/mfd/max8907.c       | 24 ++++++++++++++++++------
 include/linux/mfd/max8907.h |  2 ++
 2 files changed, 20 insertions(+), 6 deletions(-)

diff --git a/drivers/mfd/max8907.c b/drivers/mfd/max8907.c
index 232749c..b8cddc1 100644
--- a/drivers/mfd/max8907.c
+++ b/drivers/mfd/max8907.c
@@ -19,6 +19,7 @@
 #include <linux/module.h>
 #include <linux/of.h>
 #include <linux/of_device.h>
+#include <linux/pm.h>
 #include <linux/regmap.h>
 #include <linux/slab.h>
 
@@ -177,11 +178,16 @@ static const struct regmap_irq_chip max8907_rtc_irq_chip = {
 	.num_irqs = ARRAY_SIZE(max8907_rtc_irqs),
 };
 
-static struct max8907 *max8907_pm_off;
-static void max8907_power_off(void)
+static int max8907_power_off(struct notifier_block *this, unsigned long unused1,
+			     void *unused2)
 {
-	regmap_update_bits(max8907_pm_off->regmap_gen, MAX8907_REG_RESET_CNFG,
+	struct max8907 *max8907 = container_of(this, struct max8907,
+					       poweroff_nb);
+
+	regmap_update_bits(max8907->regmap_gen, MAX8907_REG_RESET_CNFG,
 			MAX8907_MASK_POWER_OFF, MAX8907_MASK_POWER_OFF);
+
+	return NOTIFY_DONE;
 }
 
 static int max8907_i2c_probe(struct i2c_client *i2c,
@@ -267,9 +273,13 @@ static int max8907_i2c_probe(struct i2c_client *i2c,
 		goto err_add_devices;
 	}
 
-	if (pm_off && !pm_power_off) {
-		max8907_pm_off = max8907;
-		pm_power_off = max8907_power_off;
+	if (pm_off) {
+		max8907->poweroff_nb.notifier_call = max8907_power_off;
+		max8907->poweroff_nb.priority = 64;
+		ret = register_poweroff_handler(&max8907->poweroff_nb);
+		if (ret)
+			dev_err(&i2c->dev,
+				"Failed to register poweroff handler");
 	}
 
 	return 0;
@@ -293,6 +303,8 @@ static int max8907_i2c_remove(struct i2c_client *i2c)
 {
 	struct max8907 *max8907 = i2c_get_clientdata(i2c);
 
+	unregister_poweroff_handler(&max8907->poweroff_nb);
+
 	mfd_remove_devices(max8907->dev);
 
 	regmap_del_irq_chip(max8907->i2c_gen->irq, max8907->irqc_rtc);
diff --git a/include/linux/mfd/max8907.h b/include/linux/mfd/max8907.h
index b06f7a6..016428e 100644
--- a/include/linux/mfd/max8907.h
+++ b/include/linux/mfd/max8907.h
@@ -13,6 +13,7 @@
 #define __LINUX_MFD_MAX8907_H
 
 #include <linux/mutex.h>
+#include <linux/notifier.h>
 #include <linux/pm.h>
 
 #define MAX8907_GEN_I2C_ADDR		(0x78 >> 1)
@@ -247,6 +248,7 @@ struct max8907 {
 	struct regmap_irq_chip_data	*irqc_chg;
 	struct regmap_irq_chip_data	*irqc_on_off;
 	struct regmap_irq_chip_data	*irqc_rtc;
+	struct notifier_block		poweroff_nb;
 };
 
 #endif
-- 
1.9.1

