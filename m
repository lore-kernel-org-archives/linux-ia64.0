From: Guenter Roeck <linux@roeck-us.net>
Date: Tue, 07 Oct 2014 05:28:43 +0000
Subject: [PATCH 41/44] x86: pmc_atom: Register poweroff handler with kernel poweroff handler
Message-Id: <1412659726-29957-42-git-send-email-linux@roeck-us.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <1412659726-29957-1-git-send-email-linux@roeck-us.net>
In-Reply-To: <1412659726-29957-1-git-send-email-linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: adi-buildroot-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, devel-gWbeCf7V1WCQmaza687I9mD2FQJk+8+b@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, lguest-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, linux-acpi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-alpha-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-am33-list-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-cris-kernel-VrBV9hrLPhE@public.gmane.org, linux-efi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-hexagon-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-m32r-ja-rQhvJZKUsGBRYuoOT4C5/9i2O/JbrIOy@public.gmane.org, linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-tegra-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-xtensa-PjhNF2WwrV/0Sa2dR60CXw@public.gmane.org, openipmi-developer-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, user-mode-linux-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-c6x-dev-jPsnJVOj+W6hPH1hqNUYSQ@public.gmane.org, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-m68k-cunTk1MwBs8S/qaLPR03pWD2FQJk+8+b@public.gmane.org, linux-metag-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org, linux-parisc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-pm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-sh-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, xen-devel-GuqFBffKawtpuQazS67q72D2FQJk+8+b@public.gmane.org, Guenter Roeck <linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org>, Thomas

Register with kernel poweroff handler instead of setting pm_power_off
directly. Register with a low priority value of 64 to reflect that
the original code only sets pm_power_off if it was not already set.

Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: H. Peter Anvin <hpa@zytor.com>
Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
 arch/x86/kernel/pmc_atom.c | 20 +++++++++++++++++---
 1 file changed, 17 insertions(+), 3 deletions(-)

diff --git a/arch/x86/kernel/pmc_atom.c b/arch/x86/kernel/pmc_atom.c
index 0c424a6..79331a2 100644
--- a/arch/x86/kernel/pmc_atom.c
+++ b/arch/x86/kernel/pmc_atom.c
@@ -20,6 +20,8 @@
 #include <linux/pci.h>
 #include <linux/device.h>
 #include <linux/debugfs.h>
+#include <linux/notifier.h>
+#include <linux/pm.h>
 #include <linux/seq_file.h>
 #include <linux/io.h>
 
@@ -92,7 +94,8 @@ static inline void pmc_reg_write(struct pmc_dev *pmc, int reg_offset, u32 val)
 	writel(val, pmc->regmap + reg_offset);
 }
 
-static void pmc_power_off(void)
+static int pmc_power_off(struct notifier_block *this, unsigned long unused1,
+			 void *unused2)
 {
 	u16	pm1_cnt_port;
 	u32	pm1_cnt_value;
@@ -107,8 +110,15 @@ static void pmc_power_off(void)
 	pm1_cnt_value |= SLEEP_ENABLE;
 
 	outl(pm1_cnt_value, pm1_cnt_port);
+
+	return NOTIFY_DONE;
 }
 
+static struct notifier_block pmc_poweroff_nb = {
+	.notifier_call = pmc_power_off,
+	.priority = 64,
+};
+
 static void pmc_hw_reg_setup(struct pmc_dev *pmc)
 {
 	/*
@@ -247,8 +257,12 @@ static int pmc_setup_dev(struct pci_dev *pdev)
 	acpi_base_addr &= ACPI_BASE_ADDR_MASK;
 
 	/* Install power off function */
-	if (acpi_base_addr != 0 && pm_power_off = NULL)
-		pm_power_off = pmc_power_off;
+	if (acpi_base_addr != 0) {
+		ret = register_poweroff_handler(&pmc_poweroff_nb);
+		if (ret)
+			dev_err(&pdev->dev,
+				"Failed to install poweroff handler\n");
+	}
 
 	pci_read_config_dword(pdev, PMC_BASE_ADDR_OFFSET, &pmc->base_addr);
 	pmc->base_addr &= PMC_BASE_ADDR_MASK;
-- 
1.9.1

