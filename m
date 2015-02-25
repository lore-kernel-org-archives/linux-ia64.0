From: al.stone@linaro.org
Date: Wed, 25 Feb 2015 00:36:22 +0000
Subject: [PATCH v3 6/9] ACPI: move _OSI support functions to allow arch-dependent implementation
Message-Id: <1424824585-6405-7-git-send-email-al.stone@linaro.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1424824585-6405-1-git-send-email-al.stone@linaro.org>
In-Reply-To: <1424824585-6405-1-git-send-email-al.stone@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: rjw@rjwysocki.net, lenb@kernel.org, catalin.marinas@arm.com, will.deacon@arm.com, robert.moore@intel.com, tony.luck@intel.com, fenghua.yu@intel.com
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, devel@acpica.org, linux-arm-kernel@lists.infradead.org, linaro-acpi@lists.linaro.org, linaro-kernel@lists.linaro.org, patches@linaro.org

From: Al Stone <al.stone@linaro.org>

Having moved the _OSI callback function needed by ACPICA from
drivers/acpi/osl.c to drivers/acpi/osi.c, we now move all the
remaining _OSI support functions to osi.c.

This patch is much larger than I had wanted it to be; several of the
functions that implemented acpi_osi* command line options, or did the
set up of the interfaces to be provided by _OSI, shared a static struct.
Hence, I ended up moving a bunch of code at once rather than perhaps a
function at a time.

With this patch, all the _OSI-associated code has now been moved
to osi.c, and we next change the build so that we can make the
_OSI implementation arch-dependent.

There is no functional change.

Signed-off-by: Al Stone <al.stone@linaro.org>
---
 drivers/acpi/osi.c   | 152 ++++++++++++++++++++++++++++++++++++++++-
 drivers/acpi/osl.c   | 187 ---------------------------------------------------
 include/linux/acpi.h |   5 +-
 3 files changed, 154 insertions(+), 190 deletions(-)

diff --git a/drivers/acpi/osi.c b/drivers/acpi/osi.c
index f23aa70..9943b7a 100644
--- a/drivers/acpi/osi.c
+++ b/drivers/acpi/osi.c
@@ -30,6 +30,8 @@ ACPI_MODULE_NAME("osi");
 
 #define PREFIX			"ACPI: "
 
+static void __init acpi_osi_setup_late(void);
+
 /*
  * The story of _OSI(Linux)
  *
@@ -68,10 +70,14 @@ static struct osi_linux {
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
 
 		pr_notice_once(FW_BUG PREFIX
@@ -93,3 +99,147 @@ u32 acpi_osi_handler(acpi_string interface, u32 supported)
 
 	return supported;
 }
+
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
+		pr_info(PREFIX "_OSI method disabled\n");
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
+}
+
+static void __init acpi_cmdline_osi_linux(unsigned int enable)
+{
+	osi_linux.cmdline = 1;	/* cmdline set the default and override DMI */
+	osi_linux.dmi = 0;
+	set_osi_linux(enable);
+}
+
+void __init acpi_dmi_osi_linux(int enable, const struct dmi_system_id *d)
+{
+	pr_notice(PREFIX "DMI detected: %s\n", d->ident);
+
+	if (enable = -1)
+		return;
+
+	osi_linux.dmi = 1;	/* DMI knows that this box asks OSI(Linux) */
+	set_osi_linux(enable);
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
+			pr_info(PREFIX "Disabled all _OSI OS vendors\n");
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
+				pr_info(PREFIX "Added _OSI(%s)\n", str);
+		} else {
+			status = acpi_remove_interface(str);
+
+			if (ACPI_SUCCESS(status))
+				pr_info(PREFIX "Deleted _OSI(%s)\n", str);
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
diff --git a/drivers/acpi/osl.c b/drivers/acpi/osl.c
index 823a08f..1eb5813e 100644
--- a/drivers/acpi/osl.c
+++ b/drivers/acpi/osl.c
@@ -94,48 +94,6 @@ struct acpi_ioremap {
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
 static void __init acpi_request_region(struct acpi_generic_address *gas,
 	unsigned int length, char *desc)
 {
@@ -1392,150 +1350,6 @@ static int __init acpi_os_name_setup(char *str)
 
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
-		pr_info(PREFIX "_OSI method disabled\n");
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
-}
-
-static void __init acpi_cmdline_osi_linux(unsigned int enable)
-{
-	osi_linux.cmdline = 1;	/* cmdline set the default and override DMI */
-	osi_linux.dmi = 0;
-	set_osi_linux(enable);
-}
-
-void __init acpi_dmi_osi_linux(int enable, const struct dmi_system_id *d)
-{
-	pr_notice(PREFIX "DMI detected: %s\n", d->ident);
-
-	if (enable = -1)
-		return;
-
-	osi_linux.dmi = 1;	/* DMI knows that this box asks OSI(Linux) */
-	set_osi_linux(enable);
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
-			pr_info(PREFIX "Disabled all _OSI OS vendors\n");
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
-				pr_info(PREFIX "Added _OSI(%s)\n", str);
-		} else {
-			status = acpi_remove_interface(str);
-
-			if (ACPI_SUCCESS(status))
-				pr_info(PREFIX "Deleted _OSI(%s)\n", str);
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
@@ -1816,7 +1630,6 @@ acpi_status __init acpi_os_initialize1(void)
 	BUG_ON(!kacpi_notify_wq);
 	BUG_ON(!kacpi_hotplug_wq);
 	acpi_install_interface_handler(acpi_osi_handler);
-	acpi_osi_setup_late();
 	return AE_OK;
 }
 
diff --git a/include/linux/acpi.h b/include/linux/acpi.h
index a7c402a..71cdeb6 100644
--- a/include/linux/acpi.h
+++ b/include/linux/acpi.h
@@ -279,8 +279,9 @@ static inline int acpi_video_display_switch_support(void)
 #endif /* defined(CONFIG_ACPI_VIDEO) || defined(CONFIG_ACPI_VIDEO_MODULE) */
 
 extern int acpi_blacklisted(void);
-extern void acpi_dmi_osi_linux(int enable, const struct dmi_system_id *d);
-extern void acpi_osi_setup(char *str);
+extern void __init acpi_dmi_osi_linux(int enable,
+				      const struct dmi_system_id *d);
+extern void __init acpi_osi_setup(char *str);
 extern u32 acpi_osi_handler(acpi_string interface, u32 supported);
 
 #ifdef CONFIG_ACPI_NUMA
-- 
2.1.0

