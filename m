From: Dmitry Osipenko <digetx@gmail.com>
Date: Wed, 27 Oct 2021 21:17:10 +0000
Subject: [PATCH v2 40/45] mfd: twl4030: Use devm_register_trivial_power_off_handler()
Message-Id: <20211027211715.12671-41-digetx@gmail.com>
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
 drivers/mfd/twl4030-power.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/mfd/twl4030-power.c b/drivers/mfd/twl4030-power.c
index 6b36932263ba..72df4735d628 100644
--- a/drivers/mfd/twl4030-power.c
+++ b/drivers/mfd/twl4030-power.c
@@ -29,6 +29,7 @@
 #include <linux/platform_device.h>
 #include <linux/of.h>
 #include <linux/of_device.h>
+#include <linux/reboot.h>
 
 #include <asm/mach-types.h>
 
@@ -923,7 +924,7 @@ static int twl4030_power_probe(struct platform_device *pdev)
 	}
 
 	/* Board has to be wired properly to use this feature */
-	if (twl4030_power_use_poweroff(pdata, node) && !pm_power_off) {
+	if (twl4030_power_use_poweroff(pdata, node)) {
 		/* Default for SEQ_OFFSYNC is set, lets ensure this */
 		err = twl_i2c_read_u8(TWL_MODULE_PM_MASTER, &val,
 				      TWL4030_PM_MASTER_CFG_P123_TRANSITION);
@@ -939,7 +940,12 @@ static int twl4030_power_probe(struct platform_device *pdev)
 			}
 		}
 
-		pm_power_off = twl4030_power_off;
+		err = devm_register_trivial_power_off_handler(&pdev->dev,
+							      twl4030_power_off);
+		if (err) {
+			dev_err(&pdev->dev, "Failed to register power-off handler\n");
+			goto relock;
+		}
 	}
 
 relock:
-- 
2.33.1
