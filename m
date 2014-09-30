From: Guenter Roeck <linux@roeck-us.net>
Date: Tue, 30 Sep 2014 18:00:56 +0000
Subject: [RFC PATCH 16/16] mfd: palmas: Register with kernel poweroff handler
Message-Id: <1412100056-15517-17-git-send-email-linux@roeck-us.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <1412100056-15517-1-git-send-email-linux@roeck-us.net>
In-Reply-To: <1412100056-15517-1-git-send-email-linux@roeck-us.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org

Register with kernel poweroff handler instead of setting pm_power_off
directly.

Cc: Samuel Ortiz <sameo@linux.intel.com>
Cc: Lee Jones <lee.jones@linaro.org>
Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
 drivers/mfd/palmas.c       | 30 +++++++++++++++++-------------
 include/linux/mfd/palmas.h |  3 +++
 2 files changed, 20 insertions(+), 13 deletions(-)

diff --git a/drivers/mfd/palmas.c b/drivers/mfd/palmas.c
index 28cb048..e8ef345a 100644
--- a/drivers/mfd/palmas.c
+++ b/drivers/mfd/palmas.c
@@ -19,6 +19,7 @@
 #include <linux/i2c.h>
 #include <linux/interrupt.h>
 #include <linux/irq.h>
+#include <linux/reboot.h>
 #include <linux/regmap.h>
 #include <linux/err.h>
 #include <linux/mfd/core.h>
@@ -425,20 +426,18 @@ static void palmas_dt_to_pdata(struct i2c_client *i2c,
 			"ti,system-power-controller");
 }
 
-static struct palmas *palmas_dev;
-static void palmas_power_off(void)
+static int palmas_power_off(struct notifier_block *this, unsigned long unused1,
+			    void *unused2)
 {
+	struct palmas *palmas = container_of(this, struct palmas, poweroff_nb);
 	unsigned int addr;
 	int ret, slave;
 
-	if (!palmas_dev)
-		return;
-
 	slave = PALMAS_BASE_TO_SLAVE(PALMAS_PMU_CONTROL_BASE);
 	addr = PALMAS_BASE_TO_REG(PALMAS_PMU_CONTROL_BASE, PALMAS_DEV_CTRL);
 
 	ret = regmap_update_bits(
-			palmas_dev->regmap[slave],
+			palmas->regmap[slave],
 			addr,
 			PALMAS_DEV_CTRL_DEV_ON,
 			0);
@@ -446,6 +445,8 @@ static void palmas_power_off(void)
 	if (ret)
 		pr_err("%s: Unable to write to DEV_CTRL_DEV_ON: %d\n",
 				__func__, ret);
+
+	return NOTIFY_DONE;
 }
 
 static unsigned int palmas_features = PALMAS_PMIC_FEATURE_SMPS10_BOOST;
@@ -668,9 +669,15 @@ no_irq:
 		ret = of_platform_populate(node, NULL, NULL, &i2c->dev);
 		if (ret < 0) {
 			goto err_irq;
-		} else if (pdata->pm_off && !pm_power_off) {
-			palmas_dev = palmas;
-			pm_power_off = palmas_power_off;
+		} else if (pdata->pm_off) {
+			palmas->poweroff_nb.notifier_call = palmas_power_off;
+			palmas->poweroff_nb.priority = 128;
+			ret = register_poweroff_handler(&palmas->poweroff_nb);
+			if (ret) {
+				dev_err(palmas->dev,
+					"cannot register poweroff handler");
+				ret = 0;
+			}
 		}
 	}
 
@@ -698,10 +705,7 @@ static int palmas_i2c_remove(struct i2c_client *i2c)
 			i2c_unregister_device(palmas->i2c_clients[i]);
 	}
 
-	if (palmas = palmas_dev) {
-		pm_power_off = NULL;
-		palmas_dev = NULL;
-	}
+	unregister_poweroff_handler(&palmas->poweroff_nb);
 
 	return 0;
 }
diff --git a/include/linux/mfd/palmas.h b/include/linux/mfd/palmas.h
index fb0390a..4715057 100644
--- a/include/linux/mfd/palmas.h
+++ b/include/linux/mfd/palmas.h
@@ -18,6 +18,7 @@
 
 #include <linux/usb/otg.h>
 #include <linux/leds.h>
+#include <linux/notifier.h>
 #include <linux/regmap.h>
 #include <linux/regulator/driver.h>
 #include <linux/extcon.h>
@@ -68,6 +69,8 @@ struct palmas {
 	struct i2c_client *i2c_clients[PALMAS_NUM_CLIENTS];
 	struct regmap *regmap[PALMAS_NUM_CLIENTS];
 
+	struct notifier_block poweroff_nb;
+
 	/* Stored chip id */
 	int id;
 
-- 
1.9.1

