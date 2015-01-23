From: al.stone@linaro.org
Date: Fri, 23 Jan 2015 00:44:41 +0000
Subject: [PATCH 4/7] ia64: ACPI: create arch-dependent version of acpi_osi_handler()
Message-Id: <1421973884-13029-5-git-send-email-al.stone@linaro.org>
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

No functional change for ia64.

Signed-off-by: Al Stone <al.stone@linaro.org>
---
 arch/ia64/kernel/acpi/Makefile |   2 +-
 arch/ia64/kernel/acpi/osi.c    | 119 +++++++++++++++++++++++++++++++++++++++++
 2 files changed, 120 insertions(+), 1 deletion(-)
 create mode 100644 arch/ia64/kernel/acpi/osi.c

diff --git a/arch/ia64/kernel/acpi/Makefile b/arch/ia64/kernel/acpi/Makefile
index 8c12745..475b530 100644
--- a/arch/ia64/kernel/acpi/Makefile
+++ b/arch/ia64/kernel/acpi/Makefile
@@ -1 +1 @@
-obj-$(CONFIG_ACPI)		+= acpi.o acpi-ext.o
+obj-$(CONFIG_ACPI)		+= acpi.o acpi-ext.o osi.o
diff --git a/arch/ia64/kernel/acpi/osi.c b/arch/ia64/kernel/acpi/osi.c
new file mode 100644
index 0000000..80dbc8a
--- /dev/null
+++ b/arch/ia64/kernel/acpi/osi.c
@@ -0,0 +1,119 @@
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
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/slab.h>
+#include <linux/mm.h>
+#include <linux/highmem.h>
+#include <linux/pci.h>
+#include <linux/interrupt.h>
+#include <linux/kmod.h>
+#include <linux/delay.h>
+#include <linux/workqueue.h>
+#include <linux/nmi.h>
+#include <linux/acpi.h>
+#include <linux/efi.h>
+#include <linux/ioport.h>
+#include <linux/list.h>
+#include <linux/jiffies.h>
+#include <linux/semaphore.h>
+
+#include <asm/io.h>
+#include <asm/uaccess.h>
+
+#include "internal.h"
+
+#define _COMPONENT		ACPI_OS_SERVICES
+ACPI_MODULE_NAME("osl");
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
-- 
2.1.0

