From: al.stone@linaro.org
Date: Fri, 23 Jan 2015 00:44:43 +0000
Subject: [PATCH 6/7] x86: ia64: arm64: ACPI: move _OSI support functions to arch-dependent locations
Message-Id: <1421973884-13029-7-git-send-email-al.stone@linaro.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1421973884-13029-1-git-send-email-al.stone@linaro.org>
In-Reply-To: <1421973884-13029-1-git-send-email-al.stone@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com, fenghua.yu@intel.com, rjw@rjwysocki.net, catalin.marinas@arm.com, will.deacon@arm.com, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, lenb@kernel.org, robert.moore@intel.com
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-arm-kernel@lists.infradead.org, devel@acpica.org, linaro-acpi@lists.linaro.org, linaro-kernel@lists.linaro.org, patches@linaro.org

From: Al Stone <ahs3@redhat.com>

Having moved the _OSI callback function needed by ACPICA from
drivers/acpi to arch-dependent locations, we now move all the
remaining _OSI support functions to arch-dependent files.

This patch is much larger than I had wanted it to be; several of the
functions that implemented acpi_osi* command line options, or did the
set up of the interfaces to be provided by _OSI, shared a static struct.
Hence, I ended up moving a bunch of code at once rather than perhaps a
function at a time.

Further, ACPI blacklisting for x86 (the only architecture using it) used
some of the same _OSI functions.  So, it got moved to x86-specific
locations as well.

For x86, there should be no functional change; only the code locations
have really changed.

Even though this patch primarily changes x86-specific files, doing so
has the effect of changing functionality for other architectures that
can use ACPI.

For ia64, there is no more checking of the blacklist; it wasn't used in
the past, however, so its just removing a useless function call.  All
other functionality should be unchanged.

For arm64, any use of _OSI will issue a warning that it is deprecated.
All use of _OSI will return false -- i.e., it will return no useful
information to any firmware using it.  The ability to temporarily turn
on _OSI, or turn off _OSI, or affect it in other ways from the command
line is no longer available for arm64, either.

Signed-off-by: Al Stone <al.stone@linaro.org>
---
 arch/x86/kernel/acpi/Makefile    |   2 +-
 arch/x86/kernel/acpi/blacklist.c | 327 +++++++++++++++++++++++++++++++++++++++
 arch/x86/kernel/acpi/boot.c      |   5 +-
 arch/x86/kernel/acpi/osi.c       | 157 ++++++++++++++++++-
 drivers/acpi/Makefile            |   1 -
 drivers/acpi/blacklist.c         | 323 --------------------------------------
 drivers/acpi/osl.c               | 193 -----------------------
 include/linux/acpi.h             |   3 -
 8 files changed, 488 insertions(+), 523 deletions(-)
 create mode 100644 arch/x86/kernel/acpi/blacklist.c
 delete mode 100644 drivers/acpi/blacklist.c

diff --git a/arch/x86/kernel/acpi/Makefile b/arch/x86/kernel/acpi/Makefile
index e1359c9..11000b7 100644
--- a/arch/x86/kernel/acpi/Makefile
+++ b/arch/x86/kernel/acpi/Makefile
@@ -1,4 +1,4 @@
-obj-$(CONFIG_ACPI)		+= boot.o osi.o
+obj-$(CONFIG_ACPI)		+= boot.o osi.o blacklist.o
 obj-$(CONFIG_ACPI_SLEEP)	+= sleep.o wakeup_$(BITS).o
 obj-$(CONFIG_ACPI_APEI)		+= apei.o
 
diff --git a/arch/x86/kernel/acpi/blacklist.c b/arch/x86/kernel/acpi/blacklist.c
new file mode 100644
index 0000000..ecc04b3
--- /dev/null
+++ b/arch/x86/kernel/acpi/blacklist.c
@@ -0,0 +1,327 @@
+/*
+ *  blacklist.c
+ *
+ *  Check to see if the given machine has a known bad ACPI BIOS
+ *  or if the BIOS is too old.
+ *  Check given machine against acpi_osi_dmi_table[].
+ *
+ *  Copyright (C) 2004 Len Brown <len.brown@intel.com>
+ *  Copyright (C) 2002 Andy Grover <andrew.grover@intel.com>
+ *
+ * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
+ *
+ *  This program is free software; you can redistribute it and/or modify
+ *  it under the terms of the GNU General Public License as published by
+ *  the Free Software Foundation; either version 2 of the License, or (at
+ *  your option) any later version.
+ *
+ *  This program is distributed in the hope that it will be useful, but
+ *  WITHOUT ANY WARRANTY; without even the implied warranty of
+ *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ *  General Public License for more details.
+ *
+ *  You should have received a copy of the GNU General Public License along
+ *  with this program; if not, write to the Free Software Foundation, Inc.,
+ *  59 Temple Place, Suite 330, Boston, MA 02111-1307 USA.
+ *
+ * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
+ */
+
+#include <linux/kernel.h>
+#include <linux/init.h>
+#include <linux/acpi.h>
+#include <linux/dmi.h>
+
+extern void __init acpi_dmi_osi_linux(int enable,
+				      const struct dmi_system_id *d);
+extern void __init acpi_osi_setup(char *str);
+
+#define PREFIX		"ACPI: "
+
+enum acpi_blacklist_predicates {
+	all_versions,
+	less_than_or_equal,
+	equal,
+	greater_than_or_equal,
+};
+
+struct acpi_blacklist_item {
+	char oem_id[7];
+	char oem_table_id[9];
+	u32 oem_revision;
+	char *table;
+	enum acpi_blacklist_predicates oem_revision_predicate;
+	char *reason;
+	u32 is_critical_error;
+};
+
+static struct dmi_system_id acpi_osi_dmi_table[] __initdata;
+
+/*
+ * POLICY: If *anything* doesn't work, put it on the blacklist.
+ *	   If they are critical errors, mark it critical, and abort driver load.
+ */
+static struct acpi_blacklist_item acpi_blacklist[] __initdata = {
+	/* Compaq Presario 1700 */
+	{"PTLTD ", "  DSDT  ", 0x06040000, ACPI_SIG_DSDT, less_than_or_equal,
+	 "Multiple problems", 1},
+	/* Sony FX120, FX140, FX150? */
+	{"SONY  ", "U0      ", 0x20010313, ACPI_SIG_DSDT, less_than_or_equal,
+	 "ACPI driver problem", 1},
+	/* Compaq Presario 800, Insyde BIOS */
+	{"INT440", "SYSFexxx", 0x00001001, ACPI_SIG_DSDT, less_than_or_equal,
+	 "Does not use _REG to protect EC OpRegions", 1},
+	/* IBM 600E - _ADR should return 7, but it returns 1 */
+	{"IBM   ", "TP600E  ", 0x00000105, ACPI_SIG_DSDT, less_than_or_equal,
+	 "Incorrect _ADR", 1},
+
+	{""}
+};
+
+int __init acpi_blacklisted(void)
+{
+	int i = 0;
+	int blacklisted = 0;
+	struct acpi_table_header table_header;
+
+	while (acpi_blacklist[i].oem_id[0] != '\0') {
+		if (acpi_get_table_header(acpi_blacklist[i].table, 0, &table_header)) {
+			i++;
+			continue;
+		}
+
+		if (strncmp(acpi_blacklist[i].oem_id, table_header.oem_id, 6)) {
+			i++;
+			continue;
+		}
+
+		if (strncmp
+		    (acpi_blacklist[i].oem_table_id, table_header.oem_table_id,
+		     8)) {
+			i++;
+			continue;
+		}
+
+		if ((acpi_blacklist[i].oem_revision_predicate = all_versions)
+		    || (acpi_blacklist[i].oem_revision_predicate =
+			less_than_or_equal
+			&& table_header.oem_revision <+			acpi_blacklist[i].oem_revision)
+		    || (acpi_blacklist[i].oem_revision_predicate =
+			greater_than_or_equal
+			&& table_header.oem_revision >+			acpi_blacklist[i].oem_revision)
+		    || (acpi_blacklist[i].oem_revision_predicate = equal
+			&& table_header.oem_revision =
+			acpi_blacklist[i].oem_revision)) {
+
+			printk(KERN_ERR PREFIX
+			       "Vendor \"%6.6s\" System \"%8.8s\" "
+			       "Revision 0x%x has a known ACPI BIOS problem.\n",
+			       acpi_blacklist[i].oem_id,
+			       acpi_blacklist[i].oem_table_id,
+			       acpi_blacklist[i].oem_revision);
+
+			printk(KERN_ERR PREFIX
+			       "Reason: %s. This is a %s error\n",
+			       acpi_blacklist[i].reason,
+			       (acpi_blacklist[i].
+				is_critical_error ? "non-recoverable" :
+				"recoverable"));
+
+			blacklisted = acpi_blacklist[i].is_critical_error;
+			break;
+		} else {
+			i++;
+		}
+	}
+
+	dmi_check_system(acpi_osi_dmi_table);
+
+	return blacklisted;
+}
+#ifdef CONFIG_DMI
+static int __init dmi_enable_osi_linux(const struct dmi_system_id *d)
+{
+	acpi_dmi_osi_linux(1, d);	/* enable */
+	return 0;
+}
+static int __init dmi_disable_osi_vista(const struct dmi_system_id *d)
+{
+	printk(KERN_NOTICE PREFIX "DMI detected: %s\n", d->ident);
+	acpi_osi_setup("!Windows 2006");
+	acpi_osi_setup("!Windows 2006 SP1");
+	acpi_osi_setup("!Windows 2006 SP2");
+	return 0;
+}
+static int __init dmi_disable_osi_win7(const struct dmi_system_id *d)
+{
+	printk(KERN_NOTICE PREFIX "DMI detected: %s\n", d->ident);
+	acpi_osi_setup("!Windows 2009");
+	return 0;
+}
+static int __init dmi_disable_osi_win8(const struct dmi_system_id *d)
+{
+	printk(KERN_NOTICE PREFIX "DMI detected: %s\n", d->ident);
+	acpi_osi_setup("!Windows 2012");
+	return 0;
+}
+
+static struct dmi_system_id acpi_osi_dmi_table[] __initdata = {
+	{
+	.callback = dmi_disable_osi_vista,
+	.ident = "Fujitsu Siemens",
+	.matches = {
+		     DMI_MATCH(DMI_SYS_VENDOR, "FUJITSU SIEMENS"),
+		     DMI_MATCH(DMI_PRODUCT_NAME, "ESPRIMO Mobile V5505"),
+		},
+	},
+	{
+	/*
+	 * There have a NVIF method in MSI GX723 DSDT need call by Nvidia
+	 * driver (e.g. nouveau) when user press brightness hotkey.
+	 * Currently, nouveau driver didn't do the job and it causes there
+	 * have a infinite while loop in DSDT when user press hotkey.
+	 * We add MSI GX723's dmi information to this table for workaround
+	 * this issue.
+	 * Will remove MSI GX723 from the table after nouveau grows support.
+	 */
+	.callback = dmi_disable_osi_vista,
+	.ident = "MSI GX723",
+	.matches = {
+		     DMI_MATCH(DMI_SYS_VENDOR, "Micro-Star International"),
+		     DMI_MATCH(DMI_PRODUCT_NAME, "GX723"),
+		},
+	},
+	{
+	.callback = dmi_disable_osi_vista,
+	.ident = "Sony VGN-NS10J_S",
+	.matches = {
+		     DMI_MATCH(DMI_SYS_VENDOR, "Sony Corporation"),
+		     DMI_MATCH(DMI_PRODUCT_NAME, "VGN-NS10J_S"),
+		},
+	},
+	{
+	.callback = dmi_disable_osi_vista,
+	.ident = "Sony VGN-SR290J",
+	.matches = {
+		     DMI_MATCH(DMI_SYS_VENDOR, "Sony Corporation"),
+		     DMI_MATCH(DMI_PRODUCT_NAME, "VGN-SR290J"),
+		},
+	},
+	{
+	.callback = dmi_disable_osi_vista,
+	.ident = "VGN-NS50B_L",
+	.matches = {
+		     DMI_MATCH(DMI_SYS_VENDOR, "Sony Corporation"),
+		     DMI_MATCH(DMI_PRODUCT_NAME, "VGN-NS50B_L"),
+		},
+	},
+	{
+	.callback = dmi_disable_osi_vista,
+	.ident = "Toshiba Satellite L355",
+	.matches = {
+		     DMI_MATCH(DMI_SYS_VENDOR, "TOSHIBA"),
+		     DMI_MATCH(DMI_PRODUCT_VERSION, "Satellite L355"),
+		},
+	},
+	{
+	.callback = dmi_disable_osi_win7,
+	.ident = "ASUS K50IJ",
+	.matches = {
+		     DMI_MATCH(DMI_SYS_VENDOR, "ASUSTeK Computer Inc."),
+		     DMI_MATCH(DMI_PRODUCT_NAME, "K50IJ"),
+		},
+	},
+	{
+	.callback = dmi_disable_osi_vista,
+	.ident = "Toshiba P305D",
+	.matches = {
+		     DMI_MATCH(DMI_SYS_VENDOR, "TOSHIBA"),
+		     DMI_MATCH(DMI_PRODUCT_NAME, "Satellite P305D"),
+		},
+	},
+	{
+	.callback = dmi_disable_osi_vista,
+	.ident = "Toshiba NB100",
+	.matches = {
+		     DMI_MATCH(DMI_SYS_VENDOR, "TOSHIBA"),
+		     DMI_MATCH(DMI_PRODUCT_NAME, "NB100"),
+		},
+	},
+
+	/*
+	 * The wireless hotkey does not work on those machines when
+	 * returning true for _OSI("Windows 2012")
+	 */
+	{
+	.callback = dmi_disable_osi_win8,
+	.ident = "Dell Inspiron 7737",
+	.matches = {
+		    DMI_MATCH(DMI_SYS_VENDOR, "Dell Inc."),
+		    DMI_MATCH(DMI_PRODUCT_NAME, "Inspiron 7737"),
+		},
+	},
+	{
+	.callback = dmi_disable_osi_win8,
+	.ident = "Dell Inspiron 7537",
+	.matches = {
+		    DMI_MATCH(DMI_SYS_VENDOR, "Dell Inc."),
+		    DMI_MATCH(DMI_PRODUCT_NAME, "Inspiron 7537"),
+		},
+	},
+	{
+	.callback = dmi_disable_osi_win8,
+	.ident = "Dell Inspiron 5437",
+	.matches = {
+		    DMI_MATCH(DMI_SYS_VENDOR, "Dell Inc."),
+		    DMI_MATCH(DMI_PRODUCT_NAME, "Inspiron 5437"),
+		},
+	},
+	{
+	.callback = dmi_disable_osi_win8,
+	.ident = "Dell Inspiron 3437",
+	.matches = {
+		    DMI_MATCH(DMI_SYS_VENDOR, "Dell Inc."),
+		    DMI_MATCH(DMI_PRODUCT_NAME, "Inspiron 3437"),
+		},
+	},
+	{
+	.callback = dmi_disable_osi_win8,
+	.ident = "Dell Vostro 3446",
+	.matches = {
+		    DMI_MATCH(DMI_SYS_VENDOR, "Dell Inc."),
+		    DMI_MATCH(DMI_PRODUCT_NAME, "Vostro 3446"),
+		},
+	},
+	{
+	.callback = dmi_disable_osi_win8,
+	.ident = "Dell Vostro 3546",
+	.matches = {
+		    DMI_MATCH(DMI_SYS_VENDOR, "Dell Inc."),
+		    DMI_MATCH(DMI_PRODUCT_NAME, "Vostro 3546"),
+		},
+	},
+
+	/*
+	 * BIOS invocation of _OSI(Linux) is almost always a BIOS bug.
+	 * Linux ignores it, except for the machines enumerated below.
+	 */
+
+	/*
+	 * Without this this EEEpc exports a non working WMI interface, with
+	 * this it exports a working "good old" eeepc_laptop interface, fixing
+	 * both brightness control, and rfkill not working.
+	 */
+	{
+	.callback = dmi_enable_osi_linux,
+	.ident = "Asus EEE PC 1015PX",
+	.matches = {
+		     DMI_MATCH(DMI_SYS_VENDOR, "ASUSTeK Computer INC."),
+		     DMI_MATCH(DMI_PRODUCT_NAME, "1015PX"),
+		},
+	},
+	{}
+};
+
+#endif /* CONFIG_DMI */
diff --git a/arch/x86/kernel/acpi/boot.c b/arch/x86/kernel/acpi/boot.c
index d162636..4773f55 100644
--- a/arch/x86/kernel/acpi/boot.c
+++ b/arch/x86/kernel/acpi/boot.c
@@ -47,6 +47,9 @@
 #include <asm/i8259.h>
 
 #include "sleep.h" /* To include x86_acpi_suspend_lowlevel */
+
+extern int __init acpi_blacklisted(void);
+
 static int __initdata acpi_force = 0;
 int acpi_disabled;
 EXPORT_SYMBOL(acpi_disabled);
@@ -1502,7 +1505,7 @@ void __init acpi_boot_table_init(void)
 	 * If acpi_disabled, bail out
 	 */
 	if (acpi_disabled)
-		return; 
+		return;
 
 	/*
 	 * Initialize the ACPI boot-time table parser.
diff --git a/arch/x86/kernel/acpi/osi.c b/arch/x86/kernel/acpi/osi.c
index fff2b0c..761c29e 100644
--- a/arch/x86/kernel/acpi/osi.c
+++ b/arch/x86/kernel/acpi/osi.c
@@ -34,6 +34,8 @@ ACPI_MODULE_NAME("osl");
 
 #define PREFIX			"ACPI: "
 
+static void __init acpi_osi_setup_late(void);
+
 /*
  * The story of _OSI(Linux)
  *
@@ -72,10 +74,14 @@ static struct osi_linux {
 	unsigned int	dmi:1;
 	unsigned int	cmdline:1;
 	unsigned int	default_disabling:1;
-} osi_linux = {0, 0, 0, 0};
+	unsigned int	interfaces_added:1;
+} osi_linux = {0, 0, 0, 0, 0};
 
 u32 acpi_osi_handler(acpi_string interface, u32 supported)
 {
+	if (!osi_linux.interfaces_added)
+		acpi_osi_setup_late();
+
 	if (!strcmp("Linux", interface)) {
 
 		printk_once(KERN_NOTICE FW_BUG PREFIX
@@ -98,3 +104,152 @@ u32 acpi_osi_handler(acpi_string interface, u32 supported)
 	return supported;
 }
 
+#define	OSI_STRING_LENGTH_MAX 64	/* arbitrary */
+#define	OSI_STRING_ENTRIES_MAX 16	/* arbitrary */
+
+struct osi_setup_entry {
+	char string[OSI_STRING_LENGTH_MAX];
+	bool enable;
+};
+
+static struct osi_setup_entry
+		osi_setup_entries[OSI_STRING_ENTRIES_MAX] = {
+	{"Module Device", true},
+	{"Processor Device", true},
+	{"3.0 _SCP Extensions", true},
+	{"Processor Aggregator Device", true},
+};
+
+void __init acpi_osi_setup(char *str)
+{
+	struct osi_setup_entry *osi;
+	bool enable = true;
+	int i;
+
+	if (!acpi_gbl_create_osi_method)
+		return;
+
+	if (str = NULL || *str = '\0') {
+		printk(KERN_INFO PREFIX "_OSI method disabled\n");
+		acpi_gbl_create_osi_method = FALSE;
+		return;
+	}
+
+	if (*str = '!') {
+		str++;
+		if (*str = '\0') {
+			osi_linux.default_disabling = 1;
+			return;
+		} else if (*str = '*') {
+			acpi_update_interfaces(ACPI_DISABLE_ALL_STRINGS);
+			for (i = 0; i < OSI_STRING_ENTRIES_MAX; i++) {
+				osi = &osi_setup_entries[i];
+				osi->enable = false;
+			}
+			return;
+		}
+		enable = false;
+	}
+
+	for (i = 0; i < OSI_STRING_ENTRIES_MAX; i++) {
+		osi = &osi_setup_entries[i];
+		if (!strcmp(osi->string, str)) {
+			osi->enable = enable;
+			break;
+		} else if (osi->string[0] = '\0') {
+			osi->enable = enable;
+			strncpy(osi->string, str, OSI_STRING_LENGTH_MAX);
+			break;
+		}
+	}
+}
+
+static void __init set_osi_linux(unsigned int enable)
+{
+	if (osi_linux.enable != enable)
+		osi_linux.enable = enable;
+
+	if (osi_linux.enable)
+		acpi_osi_setup("Linux");
+	else
+		acpi_osi_setup("!Linux");
+
+	return;
+}
+
+static void __init acpi_cmdline_osi_linux(unsigned int enable)
+{
+	osi_linux.cmdline = 1;	/* cmdline set the default and override DMI */
+	osi_linux.dmi = 0;
+	set_osi_linux(enable);
+
+	return;
+}
+
+void __init acpi_dmi_osi_linux(int enable, const struct dmi_system_id *d)
+{
+	printk(KERN_NOTICE PREFIX "DMI detected: %s\n", d->ident);
+
+	if (enable = -1)
+		return;
+
+	osi_linux.dmi = 1;	/* DMI knows that this box asks OSI(Linux) */
+	set_osi_linux(enable);
+
+	return;
+}
+
+/*
+ * Modify the list of "OS Interfaces" reported to BIOS via _OSI
+ *
+ * empty string disables _OSI
+ * string starting with '!' disables that string
+ * otherwise string is added to list, augmenting built-in strings
+ */
+static void __init acpi_osi_setup_late(void)
+{
+	struct osi_setup_entry *osi;
+	char *str;
+	int i;
+	acpi_status status;
+
+	if (osi_linux.default_disabling) {
+		status = acpi_update_interfaces(ACPI_DISABLE_ALL_VENDOR_STRINGS);
+
+		if (ACPI_SUCCESS(status))
+			printk(KERN_INFO PREFIX "Disabled all _OSI OS vendors\n");
+	}
+
+	for (i = 0; i < OSI_STRING_ENTRIES_MAX; i++) {
+		osi = &osi_setup_entries[i];
+		str = osi->string;
+
+		if (*str = '\0')
+			break;
+		if (osi->enable) {
+			status = acpi_install_interface(str);
+
+			if (ACPI_SUCCESS(status))
+				printk(KERN_INFO PREFIX "Added _OSI(%s)\n", str);
+		} else {
+			status = acpi_remove_interface(str);
+
+			if (ACPI_SUCCESS(status))
+				printk(KERN_INFO PREFIX "Deleted _OSI(%s)\n", str);
+		}
+	}
+}
+
+static int __init osi_setup(char *str)
+{
+	if (str && !strcmp("Linux", str))
+		acpi_cmdline_osi_linux(1);
+	else if (str && !strcmp("!Linux", str))
+		acpi_cmdline_osi_linux(0);
+	else
+		acpi_osi_setup(str);
+
+	return 1;
+}
+
+__setup("acpi_osi=", osi_setup);
diff --git a/drivers/acpi/Makefile b/drivers/acpi/Makefile
index c346011..3fc0ad3 100644
--- a/drivers/acpi/Makefile
+++ b/drivers/acpi/Makefile
@@ -9,7 +9,6 @@ ccflags-$(CONFIG_ACPI_DEBUG)	+= -DACPI_DEBUG_OUTPUT
 # ACPI Boot-Time Table Parsing
 #
 obj-y				+= tables.o
-obj-$(CONFIG_X86)		+= blacklist.o
 
 #
 # ACPI Core Subsystem (Interpreter)
diff --git a/drivers/acpi/blacklist.c b/drivers/acpi/blacklist.c
deleted file mode 100644
index 9b693d5..0000000
--- a/drivers/acpi/blacklist.c
+++ /dev/null
@@ -1,323 +0,0 @@
-/*
- *  blacklist.c
- *
- *  Check to see if the given machine has a known bad ACPI BIOS
- *  or if the BIOS is too old.
- *  Check given machine against acpi_osi_dmi_table[].
- *
- *  Copyright (C) 2004 Len Brown <len.brown@intel.com>
- *  Copyright (C) 2002 Andy Grover <andrew.grover@intel.com>
- *
- * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- *
- *  This program is free software; you can redistribute it and/or modify
- *  it under the terms of the GNU General Public License as published by
- *  the Free Software Foundation; either version 2 of the License, or (at
- *  your option) any later version.
- *
- *  This program is distributed in the hope that it will be useful, but
- *  WITHOUT ANY WARRANTY; without even the implied warranty of
- *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- *  General Public License for more details.
- *
- *  You should have received a copy of the GNU General Public License along
- *  with this program; if not, write to the Free Software Foundation, Inc.,
- *  59 Temple Place, Suite 330, Boston, MA 02111-1307 USA.
- *
- * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- */
-
-#include <linux/kernel.h>
-#include <linux/init.h>
-#include <linux/acpi.h>
-#include <linux/dmi.h>
-
-#include "internal.h"
-
-enum acpi_blacklist_predicates {
-	all_versions,
-	less_than_or_equal,
-	equal,
-	greater_than_or_equal,
-};
-
-struct acpi_blacklist_item {
-	char oem_id[7];
-	char oem_table_id[9];
-	u32 oem_revision;
-	char *table;
-	enum acpi_blacklist_predicates oem_revision_predicate;
-	char *reason;
-	u32 is_critical_error;
-};
-
-static struct dmi_system_id acpi_osi_dmi_table[] __initdata;
-
-/*
- * POLICY: If *anything* doesn't work, put it on the blacklist.
- *	   If they are critical errors, mark it critical, and abort driver load.
- */
-static struct acpi_blacklist_item acpi_blacklist[] __initdata = {
-	/* Compaq Presario 1700 */
-	{"PTLTD ", "  DSDT  ", 0x06040000, ACPI_SIG_DSDT, less_than_or_equal,
-	 "Multiple problems", 1},
-	/* Sony FX120, FX140, FX150? */
-	{"SONY  ", "U0      ", 0x20010313, ACPI_SIG_DSDT, less_than_or_equal,
-	 "ACPI driver problem", 1},
-	/* Compaq Presario 800, Insyde BIOS */
-	{"INT440", "SYSFexxx", 0x00001001, ACPI_SIG_DSDT, less_than_or_equal,
-	 "Does not use _REG to protect EC OpRegions", 1},
-	/* IBM 600E - _ADR should return 7, but it returns 1 */
-	{"IBM   ", "TP600E  ", 0x00000105, ACPI_SIG_DSDT, less_than_or_equal,
-	 "Incorrect _ADR", 1},
-
-	{""}
-};
-
-int __init acpi_blacklisted(void)
-{
-	int i = 0;
-	int blacklisted = 0;
-	struct acpi_table_header table_header;
-
-	while (acpi_blacklist[i].oem_id[0] != '\0') {
-		if (acpi_get_table_header(acpi_blacklist[i].table, 0, &table_header)) {
-			i++;
-			continue;
-		}
-
-		if (strncmp(acpi_blacklist[i].oem_id, table_header.oem_id, 6)) {
-			i++;
-			continue;
-		}
-
-		if (strncmp
-		    (acpi_blacklist[i].oem_table_id, table_header.oem_table_id,
-		     8)) {
-			i++;
-			continue;
-		}
-
-		if ((acpi_blacklist[i].oem_revision_predicate = all_versions)
-		    || (acpi_blacklist[i].oem_revision_predicate =
-			less_than_or_equal
-			&& table_header.oem_revision <-			acpi_blacklist[i].oem_revision)
-		    || (acpi_blacklist[i].oem_revision_predicate =
-			greater_than_or_equal
-			&& table_header.oem_revision >-			acpi_blacklist[i].oem_revision)
-		    || (acpi_blacklist[i].oem_revision_predicate = equal
-			&& table_header.oem_revision =
-			acpi_blacklist[i].oem_revision)) {
-
-			printk(KERN_ERR PREFIX
-			       "Vendor \"%6.6s\" System \"%8.8s\" "
-			       "Revision 0x%x has a known ACPI BIOS problem.\n",
-			       acpi_blacklist[i].oem_id,
-			       acpi_blacklist[i].oem_table_id,
-			       acpi_blacklist[i].oem_revision);
-
-			printk(KERN_ERR PREFIX
-			       "Reason: %s. This is a %s error\n",
-			       acpi_blacklist[i].reason,
-			       (acpi_blacklist[i].
-				is_critical_error ? "non-recoverable" :
-				"recoverable"));
-
-			blacklisted = acpi_blacklist[i].is_critical_error;
-			break;
-		} else {
-			i++;
-		}
-	}
-
-	dmi_check_system(acpi_osi_dmi_table);
-
-	return blacklisted;
-}
-#ifdef CONFIG_DMI
-static int __init dmi_enable_osi_linux(const struct dmi_system_id *d)
-{
-	acpi_dmi_osi_linux(1, d);	/* enable */
-	return 0;
-}
-static int __init dmi_disable_osi_vista(const struct dmi_system_id *d)
-{
-	printk(KERN_NOTICE PREFIX "DMI detected: %s\n", d->ident);
-	acpi_osi_setup("!Windows 2006");
-	acpi_osi_setup("!Windows 2006 SP1");
-	acpi_osi_setup("!Windows 2006 SP2");
-	return 0;
-}
-static int __init dmi_disable_osi_win7(const struct dmi_system_id *d)
-{
-	printk(KERN_NOTICE PREFIX "DMI detected: %s\n", d->ident);
-	acpi_osi_setup("!Windows 2009");
-	return 0;
-}
-static int __init dmi_disable_osi_win8(const struct dmi_system_id *d)
-{
-	printk(KERN_NOTICE PREFIX "DMI detected: %s\n", d->ident);
-	acpi_osi_setup("!Windows 2012");
-	return 0;
-}
-
-static struct dmi_system_id acpi_osi_dmi_table[] __initdata = {
-	{
-	.callback = dmi_disable_osi_vista,
-	.ident = "Fujitsu Siemens",
-	.matches = {
-		     DMI_MATCH(DMI_SYS_VENDOR, "FUJITSU SIEMENS"),
-		     DMI_MATCH(DMI_PRODUCT_NAME, "ESPRIMO Mobile V5505"),
-		},
-	},
-	{
-	/*
-	 * There have a NVIF method in MSI GX723 DSDT need call by Nvidia
-	 * driver (e.g. nouveau) when user press brightness hotkey.
-	 * Currently, nouveau driver didn't do the job and it causes there
-	 * have a infinite while loop in DSDT when user press hotkey.
-	 * We add MSI GX723's dmi information to this table for workaround
-	 * this issue.
-	 * Will remove MSI GX723 from the table after nouveau grows support.
-	 */
-	.callback = dmi_disable_osi_vista,
-	.ident = "MSI GX723",
-	.matches = {
-		     DMI_MATCH(DMI_SYS_VENDOR, "Micro-Star International"),
-		     DMI_MATCH(DMI_PRODUCT_NAME, "GX723"),
-		},
-	},
-	{
-	.callback = dmi_disable_osi_vista,
-	.ident = "Sony VGN-NS10J_S",
-	.matches = {
-		     DMI_MATCH(DMI_SYS_VENDOR, "Sony Corporation"),
-		     DMI_MATCH(DMI_PRODUCT_NAME, "VGN-NS10J_S"),
-		},
-	},
-	{
-	.callback = dmi_disable_osi_vista,
-	.ident = "Sony VGN-SR290J",
-	.matches = {
-		     DMI_MATCH(DMI_SYS_VENDOR, "Sony Corporation"),
-		     DMI_MATCH(DMI_PRODUCT_NAME, "VGN-SR290J"),
-		},
-	},
-	{
-	.callback = dmi_disable_osi_vista,
-	.ident = "VGN-NS50B_L",
-	.matches = {
-		     DMI_MATCH(DMI_SYS_VENDOR, "Sony Corporation"),
-		     DMI_MATCH(DMI_PRODUCT_NAME, "VGN-NS50B_L"),
-		},
-	},
-	{
-	.callback = dmi_disable_osi_vista,
-	.ident = "Toshiba Satellite L355",
-	.matches = {
-		     DMI_MATCH(DMI_SYS_VENDOR, "TOSHIBA"),
-		     DMI_MATCH(DMI_PRODUCT_VERSION, "Satellite L355"),
-		},
-	},
-	{
-	.callback = dmi_disable_osi_win7,
-	.ident = "ASUS K50IJ",
-	.matches = {
-		     DMI_MATCH(DMI_SYS_VENDOR, "ASUSTeK Computer Inc."),
-		     DMI_MATCH(DMI_PRODUCT_NAME, "K50IJ"),
-		},
-	},
-	{
-	.callback = dmi_disable_osi_vista,
-	.ident = "Toshiba P305D",
-	.matches = {
-		     DMI_MATCH(DMI_SYS_VENDOR, "TOSHIBA"),
-		     DMI_MATCH(DMI_PRODUCT_NAME, "Satellite P305D"),
-		},
-	},
-	{
-	.callback = dmi_disable_osi_vista,
-	.ident = "Toshiba NB100",
-	.matches = {
-		     DMI_MATCH(DMI_SYS_VENDOR, "TOSHIBA"),
-		     DMI_MATCH(DMI_PRODUCT_NAME, "NB100"),
-		},
-	},
-
-	/*
-	 * The wireless hotkey does not work on those machines when
-	 * returning true for _OSI("Windows 2012")
-	 */
-	{
-	.callback = dmi_disable_osi_win8,
-	.ident = "Dell Inspiron 7737",
-	.matches = {
-		    DMI_MATCH(DMI_SYS_VENDOR, "Dell Inc."),
-		    DMI_MATCH(DMI_PRODUCT_NAME, "Inspiron 7737"),
-		},
-	},
-	{
-	.callback = dmi_disable_osi_win8,
-	.ident = "Dell Inspiron 7537",
-	.matches = {
-		    DMI_MATCH(DMI_SYS_VENDOR, "Dell Inc."),
-		    DMI_MATCH(DMI_PRODUCT_NAME, "Inspiron 7537"),
-		},
-	},
-	{
-	.callback = dmi_disable_osi_win8,
-	.ident = "Dell Inspiron 5437",
-	.matches = {
-		    DMI_MATCH(DMI_SYS_VENDOR, "Dell Inc."),
-		    DMI_MATCH(DMI_PRODUCT_NAME, "Inspiron 5437"),
-		},
-	},
-	{
-	.callback = dmi_disable_osi_win8,
-	.ident = "Dell Inspiron 3437",
-	.matches = {
-		    DMI_MATCH(DMI_SYS_VENDOR, "Dell Inc."),
-		    DMI_MATCH(DMI_PRODUCT_NAME, "Inspiron 3437"),
-		},
-	},
-	{
-	.callback = dmi_disable_osi_win8,
-	.ident = "Dell Vostro 3446",
-	.matches = {
-		    DMI_MATCH(DMI_SYS_VENDOR, "Dell Inc."),
-		    DMI_MATCH(DMI_PRODUCT_NAME, "Vostro 3446"),
-		},
-	},
-	{
-	.callback = dmi_disable_osi_win8,
-	.ident = "Dell Vostro 3546",
-	.matches = {
-		    DMI_MATCH(DMI_SYS_VENDOR, "Dell Inc."),
-		    DMI_MATCH(DMI_PRODUCT_NAME, "Vostro 3546"),
-		},
-	},
-
-	/*
-	 * BIOS invocation of _OSI(Linux) is almost always a BIOS bug.
-	 * Linux ignores it, except for the machines enumerated below.
-	 */
-
-	/*
-	 * Without this this EEEpc exports a non working WMI interface, with
-	 * this it exports a working "good old" eeepc_laptop interface, fixing
-	 * both brightness control, and rfkill not working.
-	 */
-	{
-	.callback = dmi_enable_osi_linux,
-	.ident = "Asus EEE PC 1015PX",
-	.matches = {
-		     DMI_MATCH(DMI_SYS_VENDOR, "ASUSTeK Computer INC."),
-		     DMI_MATCH(DMI_PRODUCT_NAME, "1015PX"),
-		},
-	},
-	{}
-};
-
-#endif /* CONFIG_DMI */
diff --git a/drivers/acpi/osl.c b/drivers/acpi/osl.c
index c7f1cd6..a0c9940 100644
--- a/drivers/acpi/osl.c
+++ b/drivers/acpi/osl.c
@@ -99,48 +99,6 @@ struct acpi_ioremap {
 static LIST_HEAD(acpi_ioremaps);
 static DEFINE_MUTEX(acpi_ioremap_lock);
 
-static void __init acpi_osi_setup_late(void);
-
-/*
- * The story of _OSI(Linux)
- *
- * From pre-history through Linux-2.6.22,
- * Linux responded TRUE upon a BIOS OSI(Linux) query.
- *
- * Unfortunately, reference BIOS writers got wind of this
- * and put OSI(Linux) in their example code, quickly exposing
- * this string as ill-conceived and opening the door to
- * an un-bounded number of BIOS incompatibilities.
- *
- * For example, OSI(Linux) was used on resume to re-POST a
- * video card on one system, because Linux at that time
- * could not do a speedy restore in its native driver.
- * But then upon gaining quick native restore capability,
- * Linux has no way to tell the BIOS to skip the time-consuming
- * POST -- putting Linux at a permanent performance disadvantage.
- * On another system, the BIOS writer used OSI(Linux)
- * to infer native OS support for IPMI!  On other systems,
- * OSI(Linux) simply got in the way of Linux claiming to
- * be compatible with other operating systems, exposing
- * BIOS issues such as skipped device initialization.
- *
- * So "Linux" turned out to be a really poor chose of
- * OSI string, and from Linux-2.6.23 onward we respond FALSE.
- *
- * BIOS writers should NOT query _OSI(Linux) on future systems.
- * Linux will complain on the console when it sees it, and return FALSE.
- * To get Linux to return TRUE for your system  will require
- * a kernel source update to add a DMI entry,
- * or boot with "acpi_osi=Linux"
- */
-
-static struct osi_linux {
-	unsigned int	enable:1;
-	unsigned int	dmi:1;
-	unsigned int	cmdline:1;
-	unsigned int	default_disabling:1;
-} osi_linux = {0, 0, 0, 0};
-
 static void __init acpi_request_region (struct acpi_generic_address *gas,
 	unsigned int length, char *desc)
 {
@@ -1394,156 +1352,6 @@ static int __init acpi_os_name_setup(char *str)
 
 __setup("acpi_os_name=", acpi_os_name_setup);
 
-#define	OSI_STRING_LENGTH_MAX 64	/* arbitrary */
-#define	OSI_STRING_ENTRIES_MAX 16	/* arbitrary */
-
-struct osi_setup_entry {
-	char string[OSI_STRING_LENGTH_MAX];
-	bool enable;
-};
-
-static struct osi_setup_entry
-		osi_setup_entries[OSI_STRING_ENTRIES_MAX] __initdata = {
-	{"Module Device", true},
-	{"Processor Device", true},
-	{"3.0 _SCP Extensions", true},
-	{"Processor Aggregator Device", true},
-};
-
-void __init acpi_osi_setup(char *str)
-{
-	struct osi_setup_entry *osi;
-	bool enable = true;
-	int i;
-
-	if (!acpi_gbl_create_osi_method)
-		return;
-
-	if (str = NULL || *str = '\0') {
-		printk(KERN_INFO PREFIX "_OSI method disabled\n");
-		acpi_gbl_create_osi_method = FALSE;
-		return;
-	}
-
-	if (*str = '!') {
-		str++;
-		if (*str = '\0') {
-			osi_linux.default_disabling = 1;
-			return;
-		} else if (*str = '*') {
-			acpi_update_interfaces(ACPI_DISABLE_ALL_STRINGS);
-			for (i = 0; i < OSI_STRING_ENTRIES_MAX; i++) {
-				osi = &osi_setup_entries[i];
-				osi->enable = false;
-			}
-			return;
-		}
-		enable = false;
-	}
-
-	for (i = 0; i < OSI_STRING_ENTRIES_MAX; i++) {
-		osi = &osi_setup_entries[i];
-		if (!strcmp(osi->string, str)) {
-			osi->enable = enable;
-			break;
-		} else if (osi->string[0] = '\0') {
-			osi->enable = enable;
-			strncpy(osi->string, str, OSI_STRING_LENGTH_MAX);
-			break;
-		}
-	}
-}
-
-static void __init set_osi_linux(unsigned int enable)
-{
-	if (osi_linux.enable != enable)
-		osi_linux.enable = enable;
-
-	if (osi_linux.enable)
-		acpi_osi_setup("Linux");
-	else
-		acpi_osi_setup("!Linux");
-
-	return;
-}
-
-static void __init acpi_cmdline_osi_linux(unsigned int enable)
-{
-	osi_linux.cmdline = 1;	/* cmdline set the default and override DMI */
-	osi_linux.dmi = 0;
-	set_osi_linux(enable);
-
-	return;
-}
-
-void __init acpi_dmi_osi_linux(int enable, const struct dmi_system_id *d)
-{
-	printk(KERN_NOTICE PREFIX "DMI detected: %s\n", d->ident);
-
-	if (enable = -1)
-		return;
-
-	osi_linux.dmi = 1;	/* DMI knows that this box asks OSI(Linux) */
-	set_osi_linux(enable);
-
-	return;
-}
-
-/*
- * Modify the list of "OS Interfaces" reported to BIOS via _OSI
- *
- * empty string disables _OSI
- * string starting with '!' disables that string
- * otherwise string is added to list, augmenting built-in strings
- */
-static void __init acpi_osi_setup_late(void)
-{
-	struct osi_setup_entry *osi;
-	char *str;
-	int i;
-	acpi_status status;
-
-	if (osi_linux.default_disabling) {
-		status = acpi_update_interfaces(ACPI_DISABLE_ALL_VENDOR_STRINGS);
-
-		if (ACPI_SUCCESS(status))
-			printk(KERN_INFO PREFIX "Disabled all _OSI OS vendors\n");
-	}
-
-	for (i = 0; i < OSI_STRING_ENTRIES_MAX; i++) {
-		osi = &osi_setup_entries[i];
-		str = osi->string;
-
-		if (*str = '\0')
-			break;
-		if (osi->enable) {
-			status = acpi_install_interface(str);
-
-			if (ACPI_SUCCESS(status))
-				printk(KERN_INFO PREFIX "Added _OSI(%s)\n", str);
-		} else {
-			status = acpi_remove_interface(str);
-
-			if (ACPI_SUCCESS(status))
-				printk(KERN_INFO PREFIX "Deleted _OSI(%s)\n", str);
-		}
-	}
-}
-
-static int __init osi_setup(char *str)
-{
-	if (str && !strcmp("Linux", str))
-		acpi_cmdline_osi_linux(1);
-	else if (str && !strcmp("!Linux", str))
-		acpi_cmdline_osi_linux(0);
-	else
-		acpi_osi_setup(str);
-
-	return 1;
-}
-
-__setup("acpi_osi=", osi_setup);
-
 /*
  * Disable the auto-serialization of named objects creation methods.
  *
@@ -1828,7 +1636,6 @@ acpi_status __init acpi_os_initialize1(void)
 	BUG_ON(!kacpi_notify_wq);
 	BUG_ON(!kacpi_hotplug_wq);
 	acpi_install_interface_handler(acpi_osi_handler);
-	acpi_osi_setup_late();
 	return AE_OK;
 }
 
diff --git a/include/linux/acpi.h b/include/linux/acpi.h
index ec18ab0..b345015 100644
--- a/include/linux/acpi.h
+++ b/include/linux/acpi.h
@@ -268,9 +268,6 @@ static inline int acpi_video_display_switch_support(void)
 
 #endif /* defined(CONFIG_ACPI_VIDEO) || defined(CONFIG_ACPI_VIDEO_MODULE) */
 
-extern int acpi_blacklisted(void);
-extern void acpi_dmi_osi_linux(int enable, const struct dmi_system_id *d);
-extern void acpi_osi_setup(char *str);
 extern u32 acpi_osi_handler(acpi_string interface, u32 supported);
 
 #ifdef CONFIG_ACPI_NUMA
-- 
2.1.0

