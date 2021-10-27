From: Dmitry Osipenko <digetx@gmail.com>
Date: Wed, 27 Oct 2021 21:16:58 +0000
Subject: [PATCH v2 28/45] mfd: rn5t618: Use devm_register_power_handler()
Message-Id: <20211027211715.12671-29-digetx@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20211027211715.12671-1-digetx@gmail.com>
In-Reply-To: <20211027211715.12671-1-digetx@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Thierry Reding <thierry.reding@gmail.com>, Jonathan Hunter <jonathanh@nvidia.com>, Lee Jones <lee.jones@linaro.org>, "Rafael J . Wysocki" <rafael@kernel.org>, Mark Brown <broonie@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Guenter Roeck <linux@roeck-us.net>, Russell King <linux@armlinux.org.uk>, Daniel Lezcano <daniel.lezcano@linaro.org>, Andy Shevchenko <andriy.shevchenko@linux.intel.com>, Ulf Hansson <ulf.hansson@linaro.org>
Cc: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Guo Ren <guoren@kernel.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Greg Ungerer <gerg@linux-m68k.org>, Joshua Thompson <funaho@jurai.org>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, Nick Hu <nickhu@andestech.com>, Greentime Hu <green.hu@gmail.com>, Vincent Chen <deanbo422@gmail.com>, "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>, Helge Deller <deller@gmx.de>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Paul Walmsley <paul.walmsley@sifive.com>, Palmer Dabbelt <palmer@dabbelt.com>, Albert Ou <aou@eecs.berkeley.edu>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, Stefano Stabellini <sstabellini@kernel.org>, Len Brown <lenb@kernel.org>, Santosh Shilimkar <ssantosh@kernel.org>, Krzysztof Kozlowski <krzysztof.kozlowski@canonical.com>, Linus Walleij <linus.walleij@linaro.org>, Chen-Yu Tsai <wens@csie.org>, =?UTF-8?q?Jonathan=20Neusch=C3=A4fer?= <j.neuschaefer@gmx.net>, Tony Lindgren <tony@atomide.com>, Liam Girdwood <lgirdwood@gmail.com>, Philipp Zabel <p.zabel@pengutronix.de>, Vladimir Zapolskiy <vz@mleia.com>, Avi Fishman <avifishman70@gmail.com>, Tomer Maimon <tmaimon77@gmail.com>, Tali Perry <tali.perry1@gmail.com>, Patrick Venture <venture@google.com>, Nancy Yuen <yuenn@google.com>, Benjamin Fair <benjaminfair@google.com>, Pavel Machek <pavel@ucw.cz>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-csky@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-sh@vger.kernel.org, xen-devel@lists.xenproject.org, linux-acpi@vger.kernel.org, linux-omap@vger.kernel.org, openbmc@lists.ozlabs.org, linux-tegra@vger.kernel.org, linux-pm@vger.kernel.org

Use devm_register_power_handler() that replaces global pm_power_off
variable and allows to register multiple power-off handlers. It also
provides restart-handler support, i.e. all in one API.

Signed-off-by: Dmitry Osipenko <digetx@gmail.com>
---
 drivers/mfd/rn5t618.c | 56 ++++++++++++++++---------------------------
 1 file changed, 21 insertions(+), 35 deletions(-)

diff --git a/drivers/mfd/rn5t618.c b/drivers/mfd/rn5t618.c
index 384acb459427..12d7b2339bbe 100644
--- a/drivers/mfd/rn5t618.c
+++ b/drivers/mfd/rn5t618.c
@@ -84,9 +84,6 @@ static const struct regmap_irq_chip rc5t619_irq_chip = {
 	.mask_invert = true,
 };
 
-static struct i2c_client *rn5t618_pm_power_off;
-static struct notifier_block rn5t618_restart_handler;
-
 static int rn5t618_irq_init(struct rn5t618 *rn5t618)
 {
 	const struct regmap_irq_chip *irq_chip = NULL;
@@ -115,7 +112,9 @@ static int rn5t618_irq_init(struct rn5t618 *rn5t618)
 	return ret;
 }
 
-static void rn5t618_trigger_poweroff_sequence(bool repower)
+static void
+rn5t618_trigger_poweroff_sequence(struct i2c_client *rn5t618_pm_power_off,
+				  bool repower)
 {
 	int ret;
 
@@ -151,25 +150,31 @@ static void rn5t618_trigger_poweroff_sequence(bool repower)
 	dev_alert(&rn5t618_pm_power_off->dev, "Failed to shutdown (err = %d)\n", ret);
 }
 
-static void rn5t618_power_off(void)
+static void rn5t618_power_off(struct power_off_data *data)
 {
-	rn5t618_trigger_poweroff_sequence(false);
+	struct i2c_client *client = data->cb_data;
+
+	rn5t618_trigger_poweroff_sequence(client, false);
 }
 
-static int rn5t618_restart(struct notifier_block *this,
-			    unsigned long mode, void *cmd)
+static void rn5t618_restart(struct restart_data *data)
 {
-	rn5t618_trigger_poweroff_sequence(true);
+	struct i2c_client *client = data->cb_data;
+
+	rn5t618_trigger_poweroff_sequence(client, true);
 
 	/*
 	 * Re-power factor detection on PMIC side is not instant. 1ms
 	 * proved to be enough time until reset takes effect.
 	 */
 	mdelay(1);
-
-	return NOTIFY_DONE;
 }
 
+static struct power_handler rn5t618_power_handler = {
+	.restart_cb = rn5t618_restart,
+	.restart_priority = RESTART_PRIO_HIGH,
+};
+
 static const struct of_device_id rn5t618_of_match[] = {
 	{ .compatible = "ricoh,rn5t567", .data = (void *)RN5T567 },
 	{ .compatible = "ricoh,rn5t618", .data = (void *)RN5T618 },
@@ -221,38 +226,20 @@ static int rn5t618_i2c_probe(struct i2c_client *i2c)
 		return ret;
 	}
 
-	rn5t618_pm_power_off = i2c;
-	if (of_device_is_system_power_controller(i2c->dev.of_node)) {
-		if (!pm_power_off)
-			pm_power_off = rn5t618_power_off;
-		else
-			dev_warn(&i2c->dev, "Poweroff callback already assigned\n");
-	}
+	if (of_device_is_system_power_controller(i2c->dev.of_node))
+		rn5t618_power_handler.power_off_cb = rn5t618_power_off;
 
-	rn5t618_restart_handler.notifier_call = rn5t618_restart;
-	rn5t618_restart_handler.priority = 192;
+	rn5t618_power_handler.cb_data = i2c;
 
-	ret = register_restart_handler(&rn5t618_restart_handler);
+	ret = devm_register_power_handler(&i2c->dev, &rn5t618_power_handler);
 	if (ret) {
-		dev_err(&i2c->dev, "cannot register restart handler, %d\n", ret);
+		dev_err(&i2c->dev, "failed to register power handler: %d\n", ret);
 		return ret;
 	}
 
 	return rn5t618_irq_init(priv);
 }
 
-static int rn5t618_i2c_remove(struct i2c_client *i2c)
-{
-	if (i2c = rn5t618_pm_power_off) {
-		rn5t618_pm_power_off = NULL;
-		pm_power_off = NULL;
-	}
-
-	unregister_restart_handler(&rn5t618_restart_handler);
-
-	return 0;
-}
-
 static int __maybe_unused rn5t618_i2c_suspend(struct device *dev)
 {
 	struct rn5t618 *priv = dev_get_drvdata(dev);
@@ -284,7 +271,6 @@ static struct i2c_driver rn5t618_i2c_driver = {
 		.pm = &rn5t618_i2c_dev_pm_ops,
 	},
 	.probe_new = rn5t618_i2c_probe,
-	.remove = rn5t618_i2c_remove,
 };
 
 module_i2c_driver(rn5t618_i2c_driver);
-- 
2.33.1
