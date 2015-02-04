From: al.stone@linaro.org
Date: Wed, 04 Feb 2015 00:21:42 +0000
Subject: [PATCH v2 3/5] ACPI: add arch-specific compilation for _OSI and the blacklist
Message-Id: <1423009304-5007-4-git-send-email-al.stone@linaro.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1423009304-5007-1-git-send-email-al.stone@linaro.org>
In-Reply-To: <1423009304-5007-1-git-send-email-al.stone@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: rjw@rjwysocki.net, lenb@kernel.org, catalin.marinas@arm.com, will.deacon@arm.com, robert.moore@intel.com, tony.luck@intel.com, fenghua.yu@intel.com
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, devel@acpica.org, linux-arm-kernel@lists.infradead.org, linaro-acpi@lists.linaro.org, linaro-kernel@lists.linaro.org, patches@linaro.org

From: Al Stone <al.stone@linaro.org>

Now that all of the _OSI functionality has been separated out, we can
provide arch-specific functionality for it.  This also allows us to do
the same for the acpi_blacklisted() function.

Whether arch-specific functions are used or not now depends on the config
options CONFIG_ACPI_ARCH_SPECIFIC_OSI and CONFIG_ARCH_SPECIFIC_BLACKLIST.
By default, both are set false which causes the x86/ia64 versions to be
used, just as is done today.  Setting one or both of these options true
will cause architecture-specific implementations to be built instead; this
patch also provides arm64 implementations.

For x86/ia64, there is no functional change.

For arm64, any use of _OSI will issue a warning that it is deprecated.
All use of _OSI will return false -- i.e., it will return no useful
information to any firmware using it.  The ability to temporarily turn
on _OSI, or turn off _OSI, or affect it in other ways from the command
line is no longer available for arm64, either.  The blacklist for ACPI
on arm64 is empty.  This will, of course, require ACPI to be enabled
for arm64.

Signed-off-by: Al Stone <al.stone@linaro.org>
---
 drivers/acpi/Kconfig         | 22 ++++++++++++++++++++++
 drivers/acpi/Makefile        | 19 ++++++++++++++++++-
 drivers/acpi/blacklist-arm.c | 20 ++++++++++++++++++++
 drivers/acpi/blacklist.c     |  5 +++++
 drivers/acpi/osi-arm.c       | 25 +++++++++++++++++++++++++
 5 files changed, 90 insertions(+), 1 deletion(-)
 create mode 100644 drivers/acpi/blacklist-arm.c
 create mode 100644 drivers/acpi/osi-arm.c

diff --git a/drivers/acpi/Kconfig b/drivers/acpi/Kconfig
index 3e3bd35..4190940 100644
--- a/drivers/acpi/Kconfig
+++ b/drivers/acpi/Kconfig
@@ -369,6 +369,28 @@ config ACPI_REDUCED_HARDWARE_ONLY
 
 	  If you are unsure what to do, do not enable this option.
 
+config ACPI_ARCH_SPECIFIC_OSI
+	bool "Use an arch-specific _OSI implementation" if EXPERT
+	def_bool n
+	help
+	  If this option is set, the ACPI driver will use an
+	  implementation of _OSI that is specific to the target
+	  architecture, instead of the default implementation
+	  originally created for x86 and then used on ia64.
+
+	  If you are unsure what to do, do not enable this option.
+
+config ACPI_ARCH_SPECIFIC_BLACKLIST
+	bool "Use an arch-specific ACPI blacklist" if EXPERT
+	def_bool n
+	help
+	  If this option is set, the ACPI driver will use a blacklist
+	  that is specific to the target architecture, instead of the
+	  default implementation originally created for x86 and then
+	  used on ia64.
+
+	  If you are unsure what to do, do not enable this option.
+
 source "drivers/acpi/apei/Kconfig"
 
 config ACPI_EXTLOG
diff --git a/drivers/acpi/Makefile b/drivers/acpi/Makefile
index df348b3..beefb17 100644
--- a/drivers/acpi/Makefile
+++ b/drivers/acpi/Makefile
@@ -18,9 +18,26 @@ obj-y				+= acpi.o \
 					acpica/
 
 # All the builtin files are in the "acpi." module_param namespace.
-acpi-y				+= osl.o utils.o reboot.o osi.o
+acpi-y				+= osl.o utils.o reboot.o
 acpi-y				+= nvs.o
 
+# _OSI related files
+ifeq ($(CONFIG_ACPI_ARCH_SPECIFIC_OSI), y)
+ifeq ($(ARCH), arm64)
+acpi-y				+= osi-arm.o
+endif
+else # X86, IA64
+acpi-y				+= osi.o
+endif
+
+ifeq ($(CONFIG_ACPI_ARCH_SPECIFIC_BLACKLIST), y)
+ifeq ($(ARCH), arm64)
+acpi-y				+= blacklist-arm.o
+endif
+else # X86, IA64
+acpi-y				+= blacklist.o
+endif
+
 # Power management related files
 acpi-y				+= wakeup.o
 ifeq ($(ARCH), arm64)
diff --git a/drivers/acpi/blacklist-arm.c b/drivers/acpi/blacklist-arm.c
new file mode 100644
index 0000000..1be6a56
--- /dev/null
+++ b/drivers/acpi/blacklist-arm.c
@@ -0,0 +1,20 @@
+/*
+ *  ARM64 Specific ACPI Blacklist Support
+ *
+ *  Copyright (C) 2015, Linaro Ltd.
+ *	Author: Al Stone <al.stone@linaro.org>
+ *
+ *  This program is free software; you can redistribute it and/or modify
+ *  it under the terms of the GNU General Public License version 2 as
+ *  published by the Free Software Foundation.
+ */
+
+#define pr_fmt(fmt) "ACPI: " fmt
+
+#include <linux/acpi.h>
+
+/* The arm64 ACPI blacklist is currently empty.  */
+int __init acpi_blacklisted(void)
+{
+	return 0;
+}
diff --git a/drivers/acpi/blacklist.c b/drivers/acpi/blacklist.c
index 3931e19..222c82d 100644
--- a/drivers/acpi/blacklist.c
+++ b/drivers/acpi/blacklist.c
@@ -34,9 +34,14 @@
 
 #include "internal.h"
 
+#ifdef CONFIG_ACPI_ARCH_SPECIFIC_OSI
+void __init acpi_dmi_osi_linux(int enable, const struct dmi_system_id *d) { }
+void __init acpi_osi_setup(char *str) { }
+#else
 extern void __init acpi_dmi_osi_linux(int enable,
 				      const struct dmi_system_id *d);
 extern void __init acpi_osi_setup(char *str);
+#endif
 
 enum acpi_blacklist_predicates {
 	all_versions,
diff --git a/drivers/acpi/osi-arm.c b/drivers/acpi/osi-arm.c
new file mode 100644
index 0000000..bb351f4
--- /dev/null
+++ b/drivers/acpi/osi-arm.c
@@ -0,0 +1,25 @@
+/*
+ *  ARM64 Specific ACPI _OSI Support
+ *
+ *  Copyright (C) 2015, Linaro Ltd.
+ *	Author: Al Stone <al.stone@linaro.org>
+ *
+ *  This program is free software; you can redistribute it and/or modify
+ *  it under the terms of the GNU General Public License version 2 as
+ *  published by the Free Software Foundation.
+ */
+
+#define pr_fmt(fmt) "ACPI: " fmt
+
+#include <linux/acpi.h>
+
+/*
+ * Consensus is to deprecate _OSI for all new ACPI-supported architectures.
+ * So, for arm64, reduce _OSI to a warning message, and tell the firmware
+ * nothing of value.
+ */
+u32 acpi_osi_handler(acpi_string interface, u32 supported)
+{
+	pr_warn("_OSI was called, but is deprecated for this architecture.\n");
+	return false;
+}
-- 
2.1.0

