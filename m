From: al.stone@linaro.org
Date: Wed, 25 Feb 2015 00:36:18 +0000
Subject: [PATCH v3 2/9] ACPI: clear up warnings on use of printk reported by checkpatch.pl
Message-Id: <1424824585-6405-3-git-send-email-al.stone@linaro.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1424824585-6405-1-git-send-email-al.stone@linaro.org>
In-Reply-To: <1424824585-6405-1-git-send-email-al.stone@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: rjw@rjwysocki.net, lenb@kernel.org, catalin.marinas@arm.com, will.deacon@arm.com, robert.moore@intel.com, tony.luck@intel.com, fenghua.yu@intel.com
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, devel@acpica.org, linux-arm-kernel@lists.infradead.org, linaro-acpi@lists.linaro.org, linaro-kernel@lists.linaro.org, patches@linaro.org

From: Al Stone <al.stone@linaro.org>

In preparation for later splitting out some of the arch-dependent code from
osl.c, clear up all the warnings reported by checkpatch.pl where pr_* should
be used instead of printk(KERN_* ...).

Signed-off-by: Al Stone <al.stone@linaro.org>
---
 drivers/acpi/osl.c | 46 +++++++++++++++++++---------------------------
 1 file changed, 19 insertions(+), 27 deletions(-)

diff --git a/drivers/acpi/osl.c b/drivers/acpi/osl.c
index 1dc3a3b..865317c 100644
--- a/drivers/acpi/osl.c
+++ b/drivers/acpi/osl.c
@@ -141,7 +141,7 @@ static u32 acpi_osi_handler(acpi_string interface, u32 supported)
 {
 	if (!strcmp("Linux", interface)) {
 
-		printk_once(KERN_NOTICE FW_BUG PREFIX
+		pr_notice_once(FW_BUG PREFIX
 			"BIOS _OSI(Linux) query %s%s\n",
 			osi_linux.enable ? "honored" : "ignored",
 			osi_linux.cmdline ? " via cmdline" :
@@ -230,10 +230,10 @@ void acpi_os_vprintf(const char *fmt, va_list args)
 	if (acpi_in_debugger) {
 		kdb_printf("%s", buffer);
 	} else {
-		printk(KERN_CONT "%s", buffer);
+		pr_cont("%s", buffer);
 	}
 #else
-	printk(KERN_CONT "%s", buffer);
+	pr_cont("%s", buffer);
 #endif
 }
 
@@ -261,8 +261,7 @@ acpi_physical_address __init acpi_os_get_root_pointer(void)
 		else if (efi.acpi != EFI_INVALID_TABLE_ADDR)
 			return efi.acpi;
 		else {
-			printk(KERN_ERR PREFIX
-			       "System description tables not found\n");
+			pr_err(PREFIX "System description tables not found\n");
 			return 0;
 		}
 	} else if (IS_ENABLED(CONFIG_ACPI_LEGACY_TABLES_LOOKUP)) {
@@ -372,7 +371,7 @@ acpi_os_map_iomem(acpi_physical_address phys, acpi_size size)
 	acpi_size pg_sz;
 
 	if (phys > ULONG_MAX) {
-		printk(KERN_ERR PREFIX "Cannot map memory that high\n");
+		pr_err(PREFIX "Cannot map memory that high\n");
 		return NULL;
 	}
 
@@ -546,8 +545,8 @@ acpi_os_predefined_override(const struct acpi_predefined_names *init_val,
 
 	*new_val = NULL;
 	if (!memcmp(init_val->name, "_OS_", 4) && strlen(acpi_os_name)) {
-		printk(KERN_INFO PREFIX "Overriding _OS definition to '%s'\n",
-		       acpi_os_name);
+		pr_info(PREFIX "Overriding _OS definition to '%s'\n",
+			acpi_os_name);
 		*new_val = acpi_os_name;
 	}
 
@@ -824,15 +823,14 @@ acpi_os_install_interrupt_handler(u32 gsi, acpi_osd_handler handler,
 		return AE_ALREADY_ACQUIRED;
 
 	if (acpi_gsi_to_irq(gsi, &irq) < 0) {
-		printk(KERN_ERR PREFIX "SCI (ACPI GSI %d) not registered\n",
-		       gsi);
+		pr_err(PREFIX "SCI (ACPI GSI %d) not registered\n", gsi);
 		return AE_OK;
 	}
 
 	acpi_irq_handler = handler;
 	acpi_irq_context = context;
 	if (request_irq(irq, acpi_irq, IRQF_SHARED, "acpi", acpi_irq)) {
-		printk(KERN_ERR PREFIX "SCI (IRQ%d) allocation failed\n", irq);
+		pr_err(PREFIX "SCI (IRQ%d) allocation failed\n", irq);
 		acpi_irq_handler = NULL;
 		return AE_NOT_ACQUIRED;
 	}
@@ -1173,8 +1171,7 @@ acpi_status acpi_os_execute(acpi_execute_type type,
 	ret = queue_work_on(0, queue, &dpc->work);
 
 	if (!ret) {
-		printk(KERN_ERR PREFIX
-			  "Call to queue_work() failed.\n");
+		pr_err(PREFIX "Call to queue_work() failed.\n");
 		status = AE_ERROR;
 		kfree(dpc);
 	}
@@ -1371,7 +1368,7 @@ acpi_status acpi_os_signal(u32 function, void *info)
 {
 	switch (function) {
 	case ACPI_SIGNAL_FATAL:
-		printk(KERN_ERR PREFIX "Fatal opcode executed\n");
+		pr_err(PREFIX "Fatal opcode executed\n");
 		break;
 	case ACPI_SIGNAL_BREAKPOINT:
 		/*
@@ -1440,7 +1437,7 @@ void __init acpi_osi_setup(char *str)
 		return;
 
 	if (str = NULL || *str = '\0') {
-		printk(KERN_INFO PREFIX "_OSI method disabled\n");
+		pr_info(PREFIX "_OSI method disabled\n");
 		acpi_gbl_create_osi_method = FALSE;
 		return;
 	}
@@ -1498,7 +1495,7 @@ static void __init acpi_cmdline_osi_linux(unsigned int enable)
 
 void __init acpi_dmi_osi_linux(int enable, const struct dmi_system_id *d)
 {
-	printk(KERN_NOTICE PREFIX "DMI detected: %s\n", d->ident);
+	pr_notice(PREFIX "DMI detected: %s\n", d->ident);
 
 	if (enable = -1)
 		return;
@@ -1527,7 +1524,7 @@ static void __init acpi_osi_setup_late(void)
 		status = acpi_update_interfaces(ACPI_DISABLE_ALL_VENDOR_STRINGS);
 
 		if (ACPI_SUCCESS(status))
-			printk(KERN_INFO PREFIX "Disabled all _OSI OS vendors\n");
+			pr_info(PREFIX "Disabled all _OSI OS vendors\n");
 	}
 
 	for (i = 0; i < OSI_STRING_ENTRIES_MAX; i++) {
@@ -1540,12 +1537,12 @@ static void __init acpi_osi_setup_late(void)
 			status = acpi_install_interface(str);
 
 			if (ACPI_SUCCESS(status))
-				printk(KERN_INFO PREFIX "Added _OSI(%s)\n", str);
+				pr_info(PREFIX "Added _OSI(%s)\n", str);
 		} else {
 			status = acpi_remove_interface(str);
 
 			if (ACPI_SUCCESS(status))
-				printk(KERN_INFO PREFIX "Deleted _OSI(%s)\n", str);
+				pr_info(PREFIX "Deleted _OSI(%s)\n", str);
 		}
 	}
 }
@@ -1646,12 +1643,8 @@ int acpi_check_resource_conflict(const struct resource *res)
 	if (clash) {
 		if (acpi_enforce_resources != ENFORCE_RESOURCES_NO) {
 			if (acpi_enforce_resources = ENFORCE_RESOURCES_LAX)
-				printk(KERN_NOTICE "ACPI: This conflict may"
-				       " cause random problems and system"
-				       " instability\n");
-			printk(KERN_INFO "ACPI: If an ACPI driver is available"
-			       " for this device, you should use it instead of"
-			       " the native driver\n");
+				pr_notice("ACPI: This conflict may cause random problems and system instability\n");
+			pr_info("ACPI: If an ACPI driver is available for this device, you should use it instead of the native driver\n");
 		}
 		if (acpi_enforce_resources = ENFORCE_RESOURCES_STRICT)
 			return -EBUSY;
@@ -1810,8 +1803,7 @@ early_param("acpi_no_static_ssdt", acpi_no_static_ssdt_setup);
 
 static int __init acpi_disable_return_repair(char *s)
 {
-	printk(KERN_NOTICE PREFIX
-	       "ACPI: Predefined validation mechanism disabled\n");
+	pr_notice(PREFIX "ACPI: Predefined validation mechanism disabled\n");
 	acpi_gbl_disable_auto_repair = TRUE;
 
 	return 1;
-- 
2.1.0

