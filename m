From: Dmitry Osipenko <dmitry.osipenko@collabora.com>
Date: Mon, 09 May 2022 23:32:16 +0000
Subject: [PATCH v8 08/27] kernel/reboot: Add register_platform_power_off()
Message-Id: <20220509233235.995021-9-dmitry.osipenko@collabora.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220509233235.995021-1-dmitry.osipenko@collabora.com>
In-Reply-To: <20220509233235.995021-1-dmitry.osipenko@collabora.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Thierry Reding <thierry.reding@gmail.com>, Jonathan Hunter <jonathanh@nvidia.com>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Guo Ren <guoren@kernel.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Greg Ungerer <gerg@linux-m68k.org>, Joshua Thompson <funaho@jurai.org>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, Sebastian Reichel <sre@kernel.org>, Linus Walleij <linus.walleij@linaro.org>, Philipp Zabel <p.zabel@pengutronix.de>, Greentime Hu <green.hu@gmail.com>, Vincent Chen <deanbo422@gmail.com>, "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>, Helge Deller <deller@gmx.de>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Paul Walmsley <paul.walmsley@sifive.com>, Palmer Dabbelt <palmer@dabbelt.com>, Albert Ou <aou@eecs.berkeley.edu>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, Stefano Stabellini <sstabellini@kernel.org>, "Rafael J. Wysocki" <rafael@kernel.org>, Len Brown <lenb@kernel.org>, Santosh Shilimkar <ssantosh@kernel.org>, Krzysztof Kozlowski <krzk@kernel.org>, Liam Girdwood <lgirdwood@gmail.com>, Mark Brown <broonie@kernel.org>, Pavel Machek <pavel@ucw.cz>, Lee Jones <lee.jones@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Guenter Roeck <linux@roeck-us.net>, Daniel Lezcano <daniel.lezcano@linaro.org>, Andy Shevchenko <andriy.shevchenko@linux.intel.com>, Ulf Hansson <ulf.hansson@linaro.org>, =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Cc: linux-kernel@vger.kernel.org, linux-csky@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linux-riscv@lists.infradead.org, linux-sh@vger.kernel.org, xen-devel@lists.xenproject.org, linux-acpi@vger.kernel.org, linux-pm@vger.kernel.org, linux-tegra@vger.kernel.org

Add platform-level registration helpers that will ease transition of the
arch/platform power-off callbacks to the new sys-off based API, allowing
us to remove the global pm_power_off variable in the future.

Signed-off-by: Dmitry Osipenko <dmitry.osipenko@collabora.com>
---
 include/linux/reboot.h |  3 +++
 kernel/reboot.c        | 55 ++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 58 insertions(+)

diff --git a/include/linux/reboot.h b/include/linux/reboot.h
index c52f77ee4ddd..f185b64faae0 100644
--- a/include/linux/reboot.h
+++ b/include/linux/reboot.h
@@ -141,6 +141,9 @@ int devm_register_sys_off_handler(struct device *dev,
 				  int (*callback)(struct sys_off_data *data),
 				  void *cb_data);
 
+int register_platform_power_off(void (*power_off)(void));
+void unregister_platform_power_off(void (*power_off)(void));
+
 /*
  * Architecture independent implemenations of sys_reboot commands.
  */
diff --git a/kernel/reboot.c b/kernel/reboot.c
index 982e58c11ce8..e74103f2a801 100644
--- a/kernel/reboot.c
+++ b/kernel/reboot.c
@@ -469,6 +469,61 @@ int devm_register_sys_off_handler(struct device *dev,
 }
 EXPORT_SYMBOL_GPL(devm_register_sys_off_handler);
 
+static struct sys_off_handler *platform_power_off_handler;
+
+static int platform_power_off_notify(struct sys_off_data *data)
+{
+	void (*platform_power_power_off_cb)(void) = data->cb_data;
+
+	platform_power_power_off_cb();
+
+	return NOTIFY_DONE;
+}
+
+/**
+ *	register_platform_power_off - Register platform-level power-off callback
+ *	@power_off: Power-off callback
+ *
+ *	Registers power-off callback that will be called as last step
+ *	of the power-off sequence. This callback is expected to be invoked
+ *	for the last resort. Only one platform power-off callback is allowed
+ *	to be registered at a time.
+ *
+ *	Returns zero on success, or error code on failure.
+ */
+int register_platform_power_off(void (*power_off)(void))
+{
+	struct sys_off_handler *handler;
+
+	handler = register_sys_off_handler(SYS_OFF_MODE_POWER_OFF,
+					   SYS_OFF_PRIO_PLATFORM,
+					   platform_power_off_notify,
+					   power_off);
+	if (IS_ERR(handler))
+		return PTR_ERR(handler);
+
+	platform_power_off_handler = handler;
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(register_platform_power_off);
+
+/**
+ *	unregister_platform_power_off - Unregister platform-level power-off callback
+ *	@power_off: Power-off callback
+ *
+ *	Unregisters previously registered platform power-off callback.
+ */
+void unregister_platform_power_off(void (*power_off)(void))
+{
+	if (platform_power_off_handler &&
+	    platform_power_off_handler->cb_data = power_off) {
+		unregister_sys_off_handler(platform_power_off_handler);
+		platform_power_off_handler = NULL;
+	}
+}
+EXPORT_SYMBOL_GPL(unregister_platform_power_off);
+
 static int legacy_pm_power_off_prepare(struct sys_off_data *data)
 {
 	if (pm_power_off_prepare)
-- 
2.35.1
