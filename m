From: Guenter Roeck <linux@roeck-us.net>
Date: Tue, 07 Oct 2014 05:28:18 +0000
Subject: [PATCH 16/44] mfd: tps6586x: Register with kernel poweroff handler
Message-Id: <1412659726-29957-17-git-send-email-linux@roeck-us.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <1412659726-29957-1-git-send-email-linux@roeck-us.net>
In-Reply-To: <1412659726-29957-1-git-send-email-linux@roeck-us.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: adi-buildroot-devel@lists.sourceforge.net, devel@driverdev.osuosl.org, devicetree@vger.kernel.org, lguest@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-alpha@vger.kernel.org, linux-am33-list@redhat.com, linux-cris-kernel@axis.com, linux-efi@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-m32r-ja@ml.linux-m32r.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-tegra@vger.kernel.org, linux-xtensa@linux-xtensa.org, openipmi-developer@lists.sourceforge.net, user-mode-linux-devel@lists.sourceforge.net, linux-arm-kernel@lists.infradead.org, linux-c6x-dev@linux-c6x.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-metag@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linux-pm@vger.kernel.org, linux-sh@vger.kernel.org, xen-devel@lists.xenproject.org, Guenter Roeck <linux@roeck-us.net>, Samuel

Register with kernel poweroff handler instead of setting pm_power_off
directly. Register with a low priority value of 64 to reflect that
the original code only sets pm_power_off if it was not already set.

Cc: Samuel Ortiz <sameo@linux.intel.com>
Cc: Lee Jones <lee.jones@linaro.org>
Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
 drivers/mfd/tps6586x.c | 31 +++++++++++++++++++++++--------
 1 file changed, 23 insertions(+), 8 deletions(-)

diff --git a/drivers/mfd/tps6586x.c b/drivers/mfd/tps6586x.c
index 8e1dbc4..bc14509 100644
--- a/drivers/mfd/tps6586x.c
+++ b/drivers/mfd/tps6586x.c
@@ -21,10 +21,12 @@
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/mutex.h>
+#include <linux/notifier.h>
 #include <linux/slab.h>
 #include <linux/err.h>
 #include <linux/i2c.h>
 #include <linux/platform_device.h>
+#include <linux/pm.h>
 #include <linux/regmap.h>
 #include <linux/of.h>
 
@@ -133,6 +135,8 @@ struct tps6586x {
 	u32			irq_en;
 	u8			mask_reg[5];
 	struct irq_domain	*irq_domain;
+
+	struct notifier_block	poweroff_nb;
 };
 
 static inline struct tps6586x *dev_to_tps6586x(struct device *dev)
@@ -472,13 +476,18 @@ static const struct regmap_config tps6586x_regmap_config = {
 	.cache_type = REGCACHE_RBTREE,
 };
 
-static struct device *tps6586x_dev;
-static void tps6586x_power_off(void)
+static int tps6586x_power_off(struct notifier_block *this,
+			      unsigned long unused1, void *unused2)
 {
-	if (tps6586x_clr_bits(tps6586x_dev, TPS6586X_SUPPLYENE, EXITSLREQ_BIT))
-		return;
+	struct tps6586x *tps6586x = container_of(this, struct tps6586x,
+						 poweroff_nb);
+
+	if (tps6586x_clr_bits(tps6586x->dev, TPS6586X_SUPPLYENE, EXITSLREQ_BIT))
+		return NOTIFY_DONE;
 
-	tps6586x_set_bits(tps6586x_dev, TPS6586X_SUPPLYENE, SLEEP_MODE_BIT);
+	tps6586x_set_bits(tps6586x->dev, TPS6586X_SUPPLYENE, SLEEP_MODE_BIT);
+
+	return NOTIFY_DONE;
 }
 
 static void tps6586x_print_version(struct i2c_client *client, int version)
@@ -575,9 +584,13 @@ static int tps6586x_i2c_probe(struct i2c_client *client,
 		goto err_add_devs;
 	}
 
-	if (pdata->pm_off && !pm_power_off) {
-		tps6586x_dev = &client->dev;
-		pm_power_off = tps6586x_power_off;
+	if (pdata->pm_off) {
+		tps6586x->poweroff_nb.notifier_call = tps6586x_power_off;
+		tps6586x->poweroff_nb.priority = 64;
+		ret = register_poweroff_handler(&tps6586x->poweroff_nb);
+		if (ret)
+			dev_err(&client->dev,
+				"failed to register poweroff handler\n");
 	}
 
 	return 0;
@@ -594,6 +607,8 @@ static int tps6586x_i2c_remove(struct i2c_client *client)
 {
 	struct tps6586x *tps6586x = i2c_get_clientdata(client);
 
+	unregister_poweroff_handler(&tps6586x->poweroff_nb);
+
 	tps6586x_remove_subdevs(tps6586x);
 	mfd_remove_devices(tps6586x->dev);
 	if (client->irq)
-- 
1.9.1

