From: al.stone@linaro.org
Date: Fri, 23 Jan 2015 00:44:40 +0000
Subject: [PATCH 3/7] x86: ACPI: create arch-dependent version of acpi_osi_handler()
Message-Id: <1421973884-13029-4-git-send-email-al.stone@linaro.org>
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
dependent ACPI files.  This patch also moves the declaration of
acpi_os_handler() so that the x86 kernel should still compile.

NB: this patch may break compilation on ia64 or arm64 (if ACPI is enabled)
until an upcoming patch adds definitions of acpi_osi_handler() for those
architectures.

No functional change for x86.

Signed-off-by: Al Stone <al.stone@linaro.org>
---
 arch/x86/kernel/acpi/Makefile |   2 +-
 arch/x86/kernel/acpi/osi.c    | 100 ++++++++++++++++++++++++++++++++++++++++++
 drivers/acpi/osl.c            |  24 ----------
 include/linux/acpi.h          |   1 +
 4 files changed, 102 insertions(+), 25 deletions(-)
 create mode 100644 arch/x86/kernel/acpi/osi.c

diff --git a/arch/x86/kernel/acpi/Makefile b/arch/x86/kernel/acpi/Makefile
index 3242e59..e1359c9 100644
--- a/arch/x86/kernel/acpi/Makefile
+++ b/arch/x86/kernel/acpi/Makefile
@@ -1,4 +1,4 @@
-obj-$(CONFIG_ACPI)		+= boot.o
+obj-$(CONFIG_ACPI)		+= boot.o osi.o
 obj-$(CONFIG_ACPI_SLEEP)	+= sleep.o wakeup_$(BITS).o
 obj-$(CONFIG_ACPI_APEI)		+= apei.o
 
diff --git a/arch/x86/kernel/acpi/osi.c b/arch/x86/kernel/acpi/osi.c
new file mode 100644
index 0000000..fff2b0c
--- /dev/null
+++ b/arch/x86/kernel/acpi/osi.c
@@ -0,0 +1,100 @@
+/*
+ *  osi.c - _OSI implementation (moved from drivers/acpi/osl.c)
+ *
+ *  Copyright (C) 2000       Andrew Henroid
+ *  Copyright (C) 2001, 2002 Andy Grover <andrew.grover@intel.com>
+ *  Copyright (C) 2001, 2002 Paul Diefenbaugh <paul.s.diefenbaugh@intel.com>
+ *  Copyright (c) 2008 Intel Corporation
+ *   Author: Matthew Wilcox <willy@linux.intel.com>
+ *
+ * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
+ *
+ *  This program is free software; you can redistribute it and/or modify
+ *  it under the terms of the GNU General Public License as published by
+ *  the Free Software Foundation; either version 2 of the License, or
+ *  (at your option) any later version.
+ *
+ *  This program is distributed in the hope that it will be useful,
+ *  but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ *  GNU General Public License for more details.
+ *
+ *  You should have received a copy of the GNU General Public License
+ *  along with this program; if not, write to the Free Software
+ *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ *
+ * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
+ *
+ */
+
+#include <linux/acpi.h>
+
+#define _COMPONENT		ACPI_OS_SERVICES
+ACPI_MODULE_NAME("osl");
+
+#define PREFIX			"ACPI: "
+
+/*
+ * The story of _OSI(Linux)
+ *
+ * From pre-history through Linux-2.6.22,
+ * Linux responded TRUE upon a BIOS OSI(Linux) query.
+ *
+ * Unfortunately, reference BIOS writers got wind of this
+ * and put OSI(Linux) in their example code, quickly exposing
+ * this string as ill-conceived and opening the door to
+ * an un-bounded number of BIOS incompatibilities.
+ *
+ * For example, OSI(Linux) was used on resume to re-POST a
+ * video card on one system, because Linux at that time
+ * could not do a speedy restore in its native driver.
+ * But then upon gaining quick native restore capability,
+ * Linux has no way to tell the BIOS to skip the time-consuming
+ * POST -- putting Linux at a permanent performance disadvantage.
+ * On another system, the BIOS writer used OSI(Linux)
+ * to infer native OS support for IPMI!  On other systems,
+ * OSI(Linux) simply got in the way of Linux claiming to
+ * be compatible with other operating systems, exposing
+ * BIOS issues such as skipped device initialization.
+ *
+ * So "Linux" turned out to be a really poor chose of
+ * OSI string, and from Linux-2.6.23 onward we respond FALSE.
+ *
+ * BIOS writers should NOT query _OSI(Linux) on future systems.
+ * Linux will complain on the console when it sees it, and return FALSE.
+ * To get Linux to return TRUE for your system  will require
+ * a kernel source update to add a DMI entry,
+ * or boot with "acpi_osi=Linux"
+ */
+
+static struct osi_linux {
+	unsigned int	enable:1;
+	unsigned int	dmi:1;
+	unsigned int	cmdline:1;
+	unsigned int	default_disabling:1;
+} osi_linux = {0, 0, 0, 0};
+
+u32 acpi_osi_handler(acpi_string interface, u32 supported)
+{
+	if (!strcmp("Linux", interface)) {
+
+		printk_once(KERN_NOTICE FW_BUG PREFIX
+			"BIOS _OSI(Linux) query %s%s\n",
+			osi_linux.enable ? "honored" : "ignored",
+			osi_linux.cmdline ? " via cmdline" :
+			osi_linux.dmi ? " via DMI" : "");
+	}
+
+	if (!strcmp("Darwin", interface)) {
+		/*
+		 * Apple firmware will behave poorly if it receives positive
+		 * answers to "Darwin" and any other OS. Respond positively
+		 * to Darwin and then disable all other vendor strings.
+		 */
+		acpi_update_interfaces(ACPI_DISABLE_ALL_VENDOR_STRINGS);
+		supported = ACPI_UINT32_MAX;
+	}
+
+	return supported;
+}
+
diff --git a/drivers/acpi/osl.c b/drivers/acpi/osl.c
index f9eeae8..c7f1cd6 100644
--- a/drivers/acpi/osl.c
+++ b/drivers/acpi/osl.c
@@ -141,30 +141,6 @@ static struct osi_linux {
 	unsigned int	default_disabling:1;
 } osi_linux = {0, 0, 0, 0};
 
-static u32 acpi_osi_handler(acpi_string interface, u32 supported)
-{
-	if (!strcmp("Linux", interface)) {
-
-		printk_once(KERN_NOTICE FW_BUG PREFIX
-			"BIOS _OSI(Linux) query %s%s\n",
-			osi_linux.enable ? "honored" : "ignored",
-			osi_linux.cmdline ? " via cmdline" :
-			osi_linux.dmi ? " via DMI" : "");
-	}
-
-	if (!strcmp("Darwin", interface)) {
-		/*
-		 * Apple firmware will behave poorly if it receives positive
-		 * answers to "Darwin" and any other OS. Respond positively
-		 * to Darwin and then disable all other vendor strings.
-		 */
-		acpi_update_interfaces(ACPI_DISABLE_ALL_VENDOR_STRINGS);
-		supported = ACPI_UINT32_MAX;
-	}
-
-	return supported;
-}
-
 static void __init acpi_request_region (struct acpi_generic_address *gas,
 	unsigned int length, char *desc)
 {
diff --git a/include/linux/acpi.h b/include/linux/acpi.h
index 87f365e..ec18ab0 100644
--- a/include/linux/acpi.h
+++ b/include/linux/acpi.h
@@ -271,6 +271,7 @@ static inline int acpi_video_display_switch_support(void)
 extern int acpi_blacklisted(void);
 extern void acpi_dmi_osi_linux(int enable, const struct dmi_system_id *d);
 extern void acpi_osi_setup(char *str);
+extern u32 acpi_osi_handler(acpi_string interface, u32 supported);
 
 #ifdef CONFIG_ACPI_NUMA
 int acpi_get_node(acpi_handle handle);
-- 
2.1.0

