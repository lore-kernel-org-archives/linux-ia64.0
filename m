From: Dmitry Osipenko <dmitry.osipenko@collabora.com>
Date: Mon, 09 May 2022 23:32:15 +0000
Subject: [PATCH v8 07/27] kernel/reboot: Add kernel_can_power_off()
Message-Id: <20220509233235.995021-8-dmitry.osipenko@collabora.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220509233235.995021-1-dmitry.osipenko@collabora.com>
In-Reply-To: <20220509233235.995021-1-dmitry.osipenko@collabora.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Thierry Reding <thierry.reding@gmail.com>, Jonathan Hunter <jonathanh@nvidia.com>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Guo Ren <guoren@kernel.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Greg Ungerer <gerg@linux-m68k.org>, Joshua Thompson <funaho@jurai.org>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, Sebastian Reichel <sre@kernel.org>, Linus Walleij <linus.walleij@linaro.org>, Philipp Zabel <p.zabel@pengutronix.de>, Greentime Hu <green.hu@gmail.com>, Vincent Chen <deanbo422@gmail.com>, "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>, Helge Deller <deller@gmx.de>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Paul Walmsley <paul.walmsley@sifive.com>, Palmer Dabbelt <palmer@dabbelt.com>, Albert Ou <aou@eecs.berkeley.edu>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, Stefano Stabellini <sstabellini@kernel.org>, "Rafael J. Wysocki" <rafael@kernel.org>, Len Brown <lenb@kernel.org>, Santosh Shilimkar <ssantosh@kernel.org>, Krzysztof Kozlowski <krzk@kernel.org>, Liam Girdwood <lgirdwood@gmail.com>, Mark Brown <broonie@kernel.org>, Pavel Machek <pavel@ucw.cz>, Lee Jones <lee.jones@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Guenter Roeck <linux@roeck-us.net>, Daniel Lezcano <daniel.lezcano@linaro.org>, Andy Shevchenko <andriy.shevchenko@linux.intel.com>, Ulf Hansson <ulf.hansson@linaro.org>, =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Cc: linux-kernel@vger.kernel.org, linux-csky@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linux-riscv@lists.infradead.org, linux-sh@vger.kernel.org, xen-devel@lists.xenproject.org, linux-acpi@vger.kernel.org, linux-pm@vger.kernel.org, linux-tegra@vger.kernel.org

Add kernel_can_power_off() helper that replaces open-coded checks of
the global pm_power_off variable. This is a necessary step towards
supporting chained power-off handlers.

Signed-off-by: Dmitry Osipenko <dmitry.osipenko@collabora.com>
---
 include/linux/reboot.h |  1 +
 kernel/reboot.c        | 14 +++++++++++++-
 2 files changed, 14 insertions(+), 1 deletion(-)

diff --git a/include/linux/reboot.h b/include/linux/reboot.h
index 6b951d68c0c7..c52f77ee4ddd 100644
--- a/include/linux/reboot.h
+++ b/include/linux/reboot.h
@@ -149,6 +149,7 @@ extern void kernel_restart_prepare(char *cmd);
 extern void kernel_restart(char *cmd);
 extern void kernel_halt(void);
 extern void kernel_power_off(void);
+extern bool kernel_can_power_off(void);
 
 void ctrl_alt_del(void);
 
diff --git a/kernel/reboot.c b/kernel/reboot.c
index eaede35f45e2..982e58c11ce8 100644
--- a/kernel/reboot.c
+++ b/kernel/reboot.c
@@ -523,6 +523,18 @@ void do_kernel_power_off(void)
 	atomic_notifier_call_chain(&power_off_handler_list, 0, NULL);
 }
 
+/**
+ *	kernel_can_power_off - check whether system can be powered off
+ *
+ *	Returns true if power-off handler is registered and system can be
+ *	powered off, false otherwise.
+ */
+bool kernel_can_power_off(void)
+{
+	return !atomic_notifier_call_chain_is_empty(&power_off_handler_list);
+}
+EXPORT_SYMBOL_GPL(kernel_can_power_off);
+
 /**
  *	kernel_power_off - power_off the system
  *
@@ -581,7 +593,7 @@ SYSCALL_DEFINE4(reboot, int, magic1, int, magic2, unsigned int, cmd,
 	/* Instead of trying to make the power_off code look like
 	 * halt when pm_power_off is not set do it the easy way.
 	 */
-	if ((cmd = LINUX_REBOOT_CMD_POWER_OFF) && !pm_power_off)
+	if ((cmd = LINUX_REBOOT_CMD_POWER_OFF) && !kernel_can_power_off())
 		cmd = LINUX_REBOOT_CMD_HALT;
 
 	mutex_lock(&system_transition_mutex);
-- 
2.35.1
