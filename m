From: Dmitry Osipenko <digetx@gmail.com>
Date: Wed, 27 Oct 2021 21:17:09 +0000
Subject: [PATCH v2 39/45] mfd: dm355evm_msp: Use devm_register_trivial_power_off_handler()
Message-Id: <20211027211715.12671-40-digetx@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20211027211715.12671-1-digetx@gmail.com>
In-Reply-To: <20211027211715.12671-1-digetx@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Thierry Reding <thierry.reding@gmail.com>, Jonathan Hunter <jonathanh@nvidia.com>, Lee Jones <lee.jones@linaro.org>, "Rafael J . Wysocki" <rafael@kernel.org>, Mark Brown <broonie@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Guenter Roeck <linux@roeck-us.net>, Russell King <linux@armlinux.org.uk>, Daniel Lezcano <daniel.lezcano@linaro.org>, Andy Shevchenko <andriy.shevchenko@linux.intel.com>, Ulf Hansson <ulf.hansson@linaro.org>
Cc: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Guo Ren <guoren@kernel.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Greg Ungerer <gerg@linux-m68k.org>, Joshua Thompson <funaho@jurai.org>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, Nick Hu <nickhu@andestech.com>, Greentime Hu <green.hu@gmail.com>, Vincent Chen <deanbo422@gmail.com>, "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>, Helge Deller <deller@gmx.de>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Paul Walmsley <paul.walmsley@sifive.com>, Palmer Dabbelt <palmer@dabbelt.com>, Albert Ou <aou@eecs.berkeley.edu>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, Stefano Stabellini <sstabellini@kernel.org>, Len Brown <lenb@kernel.org>, Santosh Shilimkar <ssantosh@kernel.org>, Krzysztof Kozlowski <krzysztof.kozlowski@canonical.com>, Linus Walleij <linus.walleij@linaro.org>, Chen-Yu Tsai <wens@csie.org>, =?UTF-8?q?Jonathan=20Neusch=C3=A4fer?= <j.neuschaefer@gmx.net>, Tony Lindgren <tony@atomide.com>, Liam Girdwood <lgirdwood@gmail.com>, Philipp Zabel <p.zabel@pengutronix.de>, Vladimir Zapolskiy <vz@mleia.com>, Avi Fishman <avifishman70@gmail.com>, Tomer Maimon <tmaimon77@gmail.com>, Tali Perry <tali.perry1@gmail.com>, Patrick Venture <venture@google.com>, Nancy Yuen <yuenn@google.com>, Benjamin Fair <benjaminfair@google.com>, Pavel Machek <pavel@ucw.cz>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-csky@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-sh@vger.kernel.org, xen-devel@lists.xenproject.org, linux-acpi@vger.kernel.org, linux-omap@vger.kernel.org, openbmc@lists.ozlabs.org, linux-tegra@vger.kernel.org, linux-pm@vger.kernel.org

Use devm_register_trivial_power_off_handler() that replaces global
pm_power_off variable and allows to register multiple power-off handlers.

Signed-off-by: Dmitry Osipenko <digetx@gmail.com>
---
 drivers/mfd/dm355evm_msp.c | 20 +++++++++++++-------
 1 file changed, 13 insertions(+), 7 deletions(-)

diff --git a/drivers/mfd/dm355evm_msp.c b/drivers/mfd/dm355evm_msp.c
index 54fb6cbd2aa0..5ee830f65589 100644
--- a/drivers/mfd/dm355evm_msp.c
+++ b/drivers/mfd/dm355evm_msp.c
@@ -8,6 +8,7 @@
 #include <linux/init.h>
 #include <linux/mutex.h>
 #include <linux/platform_device.h>
+#include <linux/reboot.h>
 #include <linux/clk.h>
 #include <linux/module.h>
 #include <linux/err.h>
@@ -375,11 +376,10 @@ static void dm355evm_power_off(void)
 	dm355evm_command(MSP_COMMAND_POWEROFF);
 }
 
-static int dm355evm_msp_remove(struct i2c_client *client)
+static void dm355evm_msp_remove(void *data)
 {
-	pm_power_off = NULL;
+	/* FIXME remove children ... */
 	msp430 = NULL;
-	return 0;
 }
 
 static int
@@ -392,6 +392,11 @@ dm355evm_msp_probe(struct i2c_client *client, const struct i2c_device_id *id)
 		return -EBUSY;
 	msp430 = client;
 
+	status = devm_add_action_or_reset(&client->dev, dm355evm_msp_remove,
+					  NULL);
+	if (status < 0)
+		goto fail;
+
 	/* display revision status; doubles as sanity check */
 	status = dm355evm_msp_read(DM355EVM_MSP_FIRMREV);
 	if (status < 0)
@@ -416,13 +421,15 @@ dm355evm_msp_probe(struct i2c_client *client, const struct i2c_device_id *id)
 		goto fail;
 
 	/* PM hookup */
-	pm_power_off = dm355evm_power_off;
+	status = devm_register_trivial_power_off_handler(&client->dev,
+							 dm355evm_power_off);
+	if (status)
+		dev_err(&client->dev, "failed to register power-off handler: %d",
+			status);
 
 	return 0;
 
 fail:
-	/* FIXME remove children ... */
-	dm355evm_msp_remove(client);
 	return status;
 }
 
@@ -436,7 +443,6 @@ static struct i2c_driver dm355evm_msp_driver = {
 	.driver.name	= "dm355evm_msp",
 	.id_table	= dm355evm_msp_ids,
 	.probe		= dm355evm_msp_probe,
-	.remove		= dm355evm_msp_remove,
 };
 
 static int __init dm355evm_msp_init(void)
-- 
2.33.1
