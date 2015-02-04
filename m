From: al.stone@linaro.org
Date: Wed, 04 Feb 2015 00:21:40 +0000
Subject: [PATCH v2 1/5] ACPI: move acpi_os_handler() so it can be made arch-dependent later
Message-Id: <1423009304-5007-2-git-send-email-al.stone@linaro.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1423009304-5007-1-git-send-email-al.stone@linaro.org>
In-Reply-To: <1423009304-5007-1-git-send-email-al.stone@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: rjw@rjwysocki.net, lenb@kernel.org, catalin.marinas@arm.com, will.deacon@arm.com, robert.moore@intel.com, tony.luck@intel.com, fenghua.yu@intel.com
Cc: linaro-kernel@lists.linaro.org, linux-ia64@vger.kernel.org, linaro-acpi@lists.linaro.org, patches@linaro.org, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-arm-kernel@lists.infradead.org, devel@acpica.org

From: Al Stone <al.stone@linaro.org>

In order to deprecate the use of _OSI for arm64 or other new architectures,
we need to make the default handler something we can change for various
platforms.  This patch moves the definition of acpi_osi_handler() -- the
function used by ACPICA as a callback for evaluating _OSI -- into a separate
file.  Subsequent patches will change which files get built so that we can
then build the version of _OSI we need for a particular architecture.

There is no functional change.

Signed-off-by: Al Stone <al.stone@linaro.org>
---
 drivers/acpi/Makefile |   2 +-
 drivers/acpi/osi.c    | 100 ++++++++++++++++++++++++++++++++++++++++++++++++++
 drivers/acpi/osl.c    |  24 ------------
 include/linux/acpi.h  |   1 +
 4 files changed, 102 insertions(+), 25 deletions(-)
 create mode 100644 drivers/acpi/osi.c

diff --git a/drivers/acpi/Makefile b/drivers/acpi/Makefile
index c346011..df348b3 100644
--- a/drivers/acpi/Makefile
+++ b/drivers/acpi/Makefile
@@ -18,7 +18,7 @@ obj-y				+= acpi.o \
 					acpica/
 
 # All the builtin files are in the "acpi." module_param namespace.
-acpi-y				+= osl.o utils.o reboot.o
+acpi-y				+= osl.o utils.o reboot.o osi.o
 acpi-y				+= nvs.o
 
 # Power management related files
diff --git a/drivers/acpi/osi.c b/drivers/acpi/osi.c
new file mode 100644
index 0000000..fff2b0c
--- /dev/null
+++ b/drivers/acpi/osi.c
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
