From: Dmitry Osipenko <dmitry.osipenko@collabora.com>
Date: Mon, 09 May 2022 23:32:12 +0000
Subject: [PATCH v8 04/27] kernel/reboot: Wrap legacy power-off callbacks into sys-off handlers
Message-Id: <20220509233235.995021-5-dmitry.osipenko@collabora.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220509233235.995021-1-dmitry.osipenko@collabora.com>
In-Reply-To: <20220509233235.995021-1-dmitry.osipenko@collabora.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Thierry Reding <thierry.reding@gmail.com>, Jonathan Hunter <jonathanh@nvidia.com>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Guo Ren <guoren@kernel.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Greg Ungerer <gerg@linux-m68k.org>, Joshua Thompson <funaho@jurai.org>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, Sebastian Reichel <sre@kernel.org>, Linus Walleij <linus.walleij@linaro.org>, Philipp Zabel <p.zabel@pengutronix.de>, Greentime Hu <green.hu@gmail.com>, Vincent Chen <deanbo422@gmail.com>, "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>, Helge Deller <deller@gmx.de>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Paul Walmsley <paul.walmsley@sifive.com>, Palmer Dabbelt <palmer@dabbelt.com>, Albert Ou <aou@eecs.berkeley.edu>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, Stefano Stabellini <sstabellini@kernel.org>, "Rafael J. Wysocki" <rafael@kernel.org>, Len Brown <lenb@kernel.org>, Santosh Shilimkar <ssantosh@kernel.org>, Krzysztof Kozlowski <krzk@kernel.org>, Liam Girdwood <lgirdwood@gmail.com>, Mark Brown <broonie@kernel.org>, Pavel Machek <pavel@ucw.cz>, Lee Jones <lee.jones@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Guenter Roeck <linux@roeck-us.net>, Daniel Lezcano <daniel.lezcano@linaro.org>, Andy Shevchenko <andriy.shevchenko@linux.intel.com>, Ulf Hansson <ulf.hansson@linaro.org>, =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Cc: linux-kernel@vger.kernel.org, linux-csky@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linux-riscv@lists.infradead.org, linux-sh@vger.kernel.org, xen-devel@lists.xenproject.org, linux-acpi@vger.kernel.org, linux-pm@vger.kernel.org, linux-tegra@vger.kernel.org

Wrap legacy power-off callbacks into sys-off handlers in order to
support co-existence of both legacy and new callbacks while we're
in process of upgrading legacy callbacks to the new API.

Signed-off-by: Dmitry Osipenko <dmitry.osipenko@collabora.com>
---
 kernel/reboot.c | 44 ++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 42 insertions(+), 2 deletions(-)

diff --git a/kernel/reboot.c b/kernel/reboot.c
index 672a658f21ee..2fb0357d9483 100644
--- a/kernel/reboot.c
+++ b/kernel/reboot.c
@@ -463,6 +463,47 @@ int devm_register_sys_off_handler(struct device *dev,
 }
 EXPORT_SYMBOL_GPL(devm_register_sys_off_handler);
 
+static int legacy_pm_power_off_prepare(struct sys_off_data *data)
+{
+	if (pm_power_off_prepare)
+		pm_power_off_prepare();
+
+	return NOTIFY_DONE;
+}
+
+static int legacy_pm_power_off(struct sys_off_data *data)
+{
+	if (pm_power_off)
+		pm_power_off();
+
+	return NOTIFY_DONE;
+}
+
+/*
+ * Register sys-off handlers for legacy PM callbacks. This allows legacy
+ * PM callbacks co-exist with the new sys-off API.
+ *
+ * TODO: Remove legacy handlers once all legacy PM users will be switched
+ *       to the sys-off based APIs.
+ */
+static int __init legacy_pm_init(void)
+{
+	register_sys_off_handler(SYS_OFF_MODE_POWER_OFF_PREPARE,
+				 SYS_OFF_PRIO_DEFAULT,
+				 legacy_pm_power_off_prepare, NULL);
+
+	register_sys_off_handler(SYS_OFF_MODE_POWER_OFF, SYS_OFF_PRIO_DEFAULT,
+				 legacy_pm_power_off, NULL);
+
+	return 0;
+}
+core_initcall(legacy_pm_init);
+
+static void do_kernel_power_off_prepare(void)
+{
+	blocking_notifier_call_chain(&power_off_prep_handler_list, 0, NULL);
+}
+
 /**
  *	kernel_power_off - power_off the system
  *
@@ -471,8 +512,7 @@ EXPORT_SYMBOL_GPL(devm_register_sys_off_handler);
 void kernel_power_off(void)
 {
 	kernel_shutdown_prepare(SYSTEM_POWER_OFF);
-	if (pm_power_off_prepare)
-		pm_power_off_prepare();
+	do_kernel_power_off_prepare();
 	migrate_to_reboot_cpu();
 	syscore_shutdown();
 	pr_emerg("Power down\n");
-- 
2.35.1
