From: al.stone@linaro.org
Date: Fri, 23 Jan 2015 00:44:42 +0000
Subject: [PATCH 5/7] arm64: ACPI: create arch-dependent version of acpi_osi_handler()
Message-Id: <1421973884-13029-6-git-send-email-al.stone@linaro.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1421973884-13029-1-git-send-email-al.stone@linaro.org>
In-Reply-To: <1421973884-13029-1-git-send-email-al.stone@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com, fenghua.yu@intel.com, rjw@rjwysocki.net, catalin.marinas@arm.com, will.deacon@arm.com, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, lenb@kernel.org, robert.moore@intel.com
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-arm-kernel@lists.infradead.org, devel@acpica.org, linaro-acpi@lists.linaro.org, linaro-kernel@lists.linaro.org, patches@linaro.org

From: Al Stone <ahs3@redhat.com>

In order to deprecate the use of _OSI for arm64 or other new architectures,
we need to make the default handler something we can change for various
platforms.  This patch moves the definition of acpi_osi_handler() -- the
function used by ACPICA as a callback for evaluating _OSI -- into arch-
dependent ACPI files.  The declaration of acpi_os_handler() was moved in
a previous patch.

Previously, _OSI behaved on arm64 as it did on x86.  This patch changes
_OSI so that on arm64 it will issue a warning if invoked, and tell the
firmware that no features have been implemented (i.e., it will always
return false).

In some distant future version of ACPI where _OSI has been completely
deprecated, this implementation and all other architecture implementations
should be removed.

Signed-off-by: Al Stone <al.stone@linaro.org>
---
 arch/arm64/kernel/acpi/Makefile |  2 +-
 arch/arm64/kernel/acpi/osi.c    | 26 ++++++++++++++++++++++++++
 2 files changed, 27 insertions(+), 1 deletion(-)
 create mode 100644 arch/arm64/kernel/acpi/osi.c

diff --git a/arch/arm64/kernel/acpi/Makefile b/arch/arm64/kernel/acpi/Makefile
index e049f94..15a6172 100644
--- a/arch/arm64/kernel/acpi/Makefile
+++ b/arch/arm64/kernel/acpi/Makefile
@@ -1 +1 @@
-obj-$(CONFIG_ACPI)		+= acpi.o
+obj-$(CONFIG_ACPI)		+= acpi.o osi.o
diff --git a/arch/arm64/kernel/acpi/osi.c b/arch/arm64/kernel/acpi/osi.c
new file mode 100644
index 0000000..fa711dc
--- /dev/null
+++ b/arch/arm64/kernel/acpi/osi.c
@@ -0,0 +1,26 @@
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
+
-- 
2.1.0

