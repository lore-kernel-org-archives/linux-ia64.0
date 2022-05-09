From: Dmitry Osipenko <dmitry.osipenko@collabora.com>
Date: Mon, 09 May 2022 23:32:32 +0000
Subject: [PATCH v8 24/27] reboot: Remove pm_power_off_prepare()
Message-Id: <20220509233235.995021-25-dmitry.osipenko@collabora.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220509233235.995021-1-dmitry.osipenko@collabora.com>
In-Reply-To: <20220509233235.995021-1-dmitry.osipenko@collabora.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Thierry Reding <thierry.reding@gmail.com>, Jonathan Hunter <jonathanh@nvidia.com>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Guo Ren <guoren@kernel.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Greg Ungerer <gerg@linux-m68k.org>, Joshua Thompson <funaho@jurai.org>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, Sebastian Reichel <sre@kernel.org>, Linus Walleij <linus.walleij@linaro.org>, Philipp Zabel <p.zabel@pengutronix.de>, Greentime Hu <green.hu@gmail.com>, Vincent Chen <deanbo422@gmail.com>, "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>, Helge Deller <deller@gmx.de>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Paul Walmsley <paul.walmsley@sifive.com>, Palmer Dabbelt <palmer@dabbelt.com>, Albert Ou <aou@eecs.berkeley.edu>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, Stefano Stabellini <sstabellini@kernel.org>, "Rafael J. Wysocki" <rafael@kernel.org>, Len Brown <lenb@kernel.org>, Santosh Shilimkar <ssantosh@kernel.org>, Krzysztof Kozlowski <krzk@kernel.org>, Liam Girdwood <lgirdwood@gmail.com>, Mark Brown <broonie@kernel.org>, Pavel Machek <pavel@ucw.cz>, Lee Jones <lee.jones@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Guenter Roeck <linux@roeck-us.net>, Daniel Lezcano <daniel.lezcano@linaro.org>, Andy Shevchenko <andriy.shevchenko@linux.intel.com>, Ulf Hansson <ulf.hansson@linaro.org>, =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Cc: linux-kernel@vger.kernel.org, linux-csky@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linux-riscv@lists.infradead.org, linux-sh@vger.kernel.org, xen-devel@lists.xenproject.org, linux-acpi@vger.kernel.org, linux-pm@vger.kernel.org, linux-tegra@vger.kernel.org

All pm_power_off_prepare() users were converted to sys-off handler API.
Remove the obsolete global callback variable.

Signed-off-by: Dmitry Osipenko <dmitry.osipenko@collabora.com>
---
 include/linux/pm.h |  1 -
 kernel/reboot.c    | 19 -------------------
 2 files changed, 20 deletions(-)

diff --git a/include/linux/pm.h b/include/linux/pm.h
index 70ec69d8bafd..871c9c49ec9d 100644
--- a/include/linux/pm.h
+++ b/include/linux/pm.h
@@ -21,7 +21,6 @@
  * Callbacks for platform drivers to implement.
  */
 extern void (*pm_power_off)(void);
-extern void (*pm_power_off_prepare)(void);
 
 struct device; /* we have a circular dep with device.h */
 #ifdef CONFIG_VT_CONSOLE_SLEEP
diff --git a/kernel/reboot.c b/kernel/reboot.c
index e74103f2a801..66033e12e8eb 100644
--- a/kernel/reboot.c
+++ b/kernel/reboot.c
@@ -63,13 +63,6 @@ struct sys_off_handler {
  */
 void __weak (*pm_power_off)(void);
 
-/*
- * If set, this is used for preparing the system to power off.
- */
-
-void (*pm_power_off_prepare)(void);
-EXPORT_SYMBOL_GPL(pm_power_off_prepare);
-
 /**
  *	emergency_restart - reboot the system
  *
@@ -524,14 +517,6 @@ void unregister_platform_power_off(void (*power_off)(void))
 }
 EXPORT_SYMBOL_GPL(unregister_platform_power_off);
 
-static int legacy_pm_power_off_prepare(struct sys_off_data *data)
-{
-	if (pm_power_off_prepare)
-		pm_power_off_prepare();
-
-	return NOTIFY_DONE;
-}
-
 static int legacy_pm_power_off(struct sys_off_data *data)
 {
 	if (pm_power_off)
@@ -549,10 +534,6 @@ static int legacy_pm_power_off(struct sys_off_data *data)
  */
 static int __init legacy_pm_init(void)
 {
-	register_sys_off_handler(SYS_OFF_MODE_POWER_OFF_PREPARE,
-				 SYS_OFF_PRIO_DEFAULT,
-				 legacy_pm_power_off_prepare, NULL);
-
 	register_sys_off_handler(SYS_OFF_MODE_POWER_OFF, SYS_OFF_PRIO_DEFAULT,
 				 legacy_pm_power_off, NULL);
 
-- 
2.35.1
