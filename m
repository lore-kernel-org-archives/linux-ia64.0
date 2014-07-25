From: Mark Salter <msalter@redhat.com>
Date: Fri, 25 Jul 2014 20:00:21 +0000
Subject: [PATCH v2] rtc: ia64: allow other architectures to use EFI RTC
Message-Id: <1406318421.27055.29.camel@deneb.redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1402685430-32591-1-git-send-email-msalter@redhat.com>
In-Reply-To: <1402685430-32591-1-git-send-email-msalter@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alessandro Zummo <a.zummo@towertech.it>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org, rtc-linux@googlegroups.com, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>

Currently, the rtc-efi driver is restricted to ia64 only.  Newer
architectures with EFI support may want to also use that driver. This
patch moves the platform device setup from ia64 into drivers/rtc and allow
any architecture with CONFIG_EFI=y to use the rtc-efi driver.

This is v2 of the patch to fix a boot problem with kernels building in
rtc-efi but not being booted via EFI. In that case, runtime services are
not available so there is no point in registering the platform device.

Signed-off-by: Mark Salter <msalter@redhat.com>
Cc: Alessandro Zummo <a.zummo@towertech.it>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 arch/ia64/kernel/time.c        | 15 ---------------
 drivers/rtc/Kconfig            |  2 +-
 drivers/rtc/Makefile           |  4 ++++
 drivers/rtc/rtc-efi-platform.c | 31 +++++++++++++++++++++++++++++++
 4 files changed, 36 insertions(+), 16 deletions(-)
 create mode 100644 drivers/rtc/rtc-efi-platform.c

diff --git a/arch/ia64/kernel/time.c b/arch/ia64/kernel/time.c
index 71c52bc..a149c67 100644
--- a/arch/ia64/kernel/time.c
+++ b/arch/ia64/kernel/time.c
@@ -384,21 +384,6 @@ static struct irqaction timer_irqaction = {
 	.name =		"timer"
 };
 
-static struct platform_device rtc_efi_dev = {
-	.name = "rtc-efi",
-	.id = -1,
-};
-
-static int __init rtc_init(void)
-{
-	if (platform_device_register(&rtc_efi_dev) < 0)
-		printk(KERN_ERR "unable to register rtc device...\n");
-
-	/* not necessarily an error */
-	return 0;
-}
-module_init(rtc_init);
-
 void read_persistent_clock(struct timespec *ts)
 {
 	efi_gettimeofday(ts);
diff --git a/drivers/rtc/Kconfig b/drivers/rtc/Kconfig
index 0754f5c..4478a59 100644
--- a/drivers/rtc/Kconfig
+++ b/drivers/rtc/Kconfig
@@ -789,7 +789,7 @@ config RTC_DRV_DA9063
 
 config RTC_DRV_EFI
 	tristate "EFI RTC"
-	depends on IA64
+	depends on EFI
 	help
 	  If you say yes here you will get support for the EFI
 	  Real Time Clock.
diff --git a/drivers/rtc/Makefile b/drivers/rtc/Makefile
index 70347d0..f1dfc36 100644
--- a/drivers/rtc/Makefile
+++ b/drivers/rtc/Makefile
@@ -10,6 +10,10 @@ obj-$(CONFIG_RTC_SYSTOHC)	+= systohc.o
 obj-$(CONFIG_RTC_CLASS)		+= rtc-core.o
 rtc-core-y			:= class.o interface.o
 
+ifdef CONFIG_RTC_DRV_EFI
+rtc-core-y			+= rtc-efi-platform.o
+endif
+
 rtc-core-$(CONFIG_RTC_INTF_DEV)	+= rtc-dev.o
 rtc-core-$(CONFIG_RTC_INTF_PROC) += rtc-proc.o
 rtc-core-$(CONFIG_RTC_INTF_SYSFS) += rtc-sysfs.o
diff --git a/drivers/rtc/rtc-efi-platform.c b/drivers/rtc/rtc-efi-platform.c
new file mode 100644
index 0000000..b40fbe3
--- /dev/null
+++ b/drivers/rtc/rtc-efi-platform.c
@@ -0,0 +1,31 @@
+/*
+ * Moved from arch/ia64/kernel/time.c
+ *
+ * Copyright (C) 1998-2003 Hewlett-Packard Co
+ *	Stephane Eranian <eranian@hpl.hp.com>
+ *	David Mosberger <davidm@hpl.hp.com>
+ * Copyright (C) 1999 Don Dugger <don.dugger@intel.com>
+ * Copyright (C) 1999-2000 VA Linux Systems
+ * Copyright (C) 1999-2000 Walt Drummond <drummond@valinux.com>
+ */
+#include <linux/init.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/efi.h>
+#include <linux/platform_device.h>
+
+static struct platform_device rtc_efi_dev = {
+	.name = "rtc-efi",
+	.id = -1,
+};
+
+static int __init rtc_init(void)
+{
+	if (efi_enabled(EFI_RUNTIME_SERVICES))
+		if (platform_device_register(&rtc_efi_dev) < 0)
+			pr_err("unable to register rtc device...\n");
+
+	/* not necessarily an error */
+	return 0;
+}
+module_init(rtc_init);
-- 
1.8.3.1



