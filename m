From: al.stone@linaro.org
Date: Wed, 25 Feb 2015 00:36:24 +0000
Subject: [PATCH v3 8/9] ACPI: arm64: use an arch-specific ACPI _OSI method and ACPI blacklist
Message-Id: <1424824585-6405-9-git-send-email-al.stone@linaro.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1424824585-6405-1-git-send-email-al.stone@linaro.org>
In-Reply-To: <1424824585-6405-1-git-send-email-al.stone@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: rjw@rjwysocki.net, lenb@kernel.org, catalin.marinas@arm.com, will.deacon@arm.com, robert.moore@intel.com, tony.luck@intel.com, fenghua.yu@intel.com
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, devel@acpica.org, linux-arm-kernel@lists.infradead.org, linaro-acpi@lists.linaro.org, linaro-kernel@lists.linaro.org, patches@linaro.org

From: Al Stone <al.stone@linaro.org>

Now that all of the _OSI functionality has been separated out, we can
provide arch-specific functionality for it.  This also allows us to do
the same for the acpi_blacklisted() function.  We also make sure the
defaults for the arm64 kernel are set so that the arch-specific _OSI
method and blacklist are always used for ACPI.

For arm64, any use of _OSI will issue a warning that it is deprecated.
All use of _OSI will return false -- i.e., it will return no useful
information to any firmware using it.  The ability to temporarily turn
on _OSI, or turn off _OSI, or affect it in other ways from the command
line is no longer available for arm64, either.  The blacklist for ACPI
on arm64 is empty.  This will, of course, require ACPI to be enabled
for arm64.

Signed-off-by: Al Stone <al.stone@linaro.org>
---
 arch/arm64/Kconfig                 |  1 +
 arch/arm64/kernel/Makefile         |  2 +-
 arch/arm64/kernel/acpi-blacklist.c | 20 ++++++++++++++++++++
 arch/arm64/kernel/acpi-osi.c       | 25 +++++++++++++++++++++++++
 4 files changed, 47 insertions(+), 1 deletion(-)
 create mode 100644 arch/arm64/kernel/acpi-blacklist.c
 create mode 100644 arch/arm64/kernel/acpi-osi.c

diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index 3f08727..e441d28 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -7,6 +7,7 @@ config ARM64
 	select ARCH_HAS_SG_CHAIN
 	select ARCH_HAS_TICK_BROADCAST if GENERIC_CLOCKEVENTS_BROADCAST
 	select ARCH_USE_CMPXCHG_LOCKREF
+	select ARCH_SPECIFIC_ACPI_OSI if ACPI
 	select ARCH_SUPPORTS_ATOMIC_RMW
 	select ARCH_WANT_OPTIONAL_GPIOLIB
 	select ARCH_WANT_COMPAT_IPC_PARSE_VERSION
diff --git a/arch/arm64/kernel/Makefile b/arch/arm64/kernel/Makefile
index 79bdd3b..b5e1268 100644
--- a/arch/arm64/kernel/Makefile
+++ b/arch/arm64/kernel/Makefile
@@ -35,7 +35,7 @@ arm64-obj-$(CONFIG_KGDB)		+= kgdb.o
 arm64-obj-$(CONFIG_EFI)			+= efi.o efi-stub.o efi-entry.o
 arm64-obj-$(CONFIG_PCI)			+= pci.o
 arm64-obj-$(CONFIG_ARMV8_DEPRECATED)	+= armv8_deprecated.o
-arm64-obj-$(CONFIG_ACPI)		+= acpi.o
+arm64-obj-$(CONFIG_ACPI)		+= acpi.o acpi-osi.o acpi-blacklist.o
 
 obj-y					+= $(arm64-obj-y) vdso/
 obj-m					+= $(arm64-obj-m)
diff --git a/arch/arm64/kernel/acpi-blacklist.c b/arch/arm64/kernel/acpi-blacklist.c
new file mode 100644
index 0000000..1be6a56
--- /dev/null
+++ b/arch/arm64/kernel/acpi-blacklist.c
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
diff --git a/arch/arm64/kernel/acpi-osi.c b/arch/arm64/kernel/acpi-osi.c
new file mode 100644
index 0000000..bb351f4
--- /dev/null
+++ b/arch/arm64/kernel/acpi-osi.c
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

