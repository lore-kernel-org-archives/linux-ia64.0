From: al.stone@linaro.org
Date: Wed, 25 Feb 2015 00:36:19 +0000
Subject: [PATCH v3 3/9] ACPI: clean up checkpatch warnings for various bits of syntax
Message-Id: <1424824585-6405-4-git-send-email-al.stone@linaro.org>
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
osl.c, clean up a bunch of warnings for odd bits of syntax:

   -- remove CVS keyword markers
   -- remove a space from between a function name and an opening parenthesis
   -- clean up all but one line > 80 characters (one just looks silly if you
      make it less than 80)
   -- add blank lines after declarations in functions
   -- remove extraneous braces ({})

Signed-off-by: Al Stone <al.stone@linaro.org>
---
 drivers/acpi/osl.c | 75 ++++++++++++++++++++++++++++++++----------------------
 1 file changed, 44 insertions(+), 31 deletions(-)

diff --git a/drivers/acpi/osl.c b/drivers/acpi/osl.c
index 865317c..46317ff 100644
--- a/drivers/acpi/osl.c
+++ b/drivers/acpi/osl.c
@@ -1,5 +1,5 @@
 /*
- *  acpi_osl.c - OS-dependent functions ($Revision: 83 $)
+ *  acpi_osl.c - OS-dependent functions
  *
  *  Copyright (C) 2000       Andrew Henroid
  *  Copyright (C) 2001, 2002 Andy Grover <andrew.grover@intel.com>
@@ -161,7 +161,7 @@ static u32 acpi_osi_handler(acpi_string interface, u32 supported)
 	return supported;
 }
 
-static void __init acpi_request_region (struct acpi_generic_address *gas,
+static void __init acpi_request_region(struct acpi_generic_address *gas,
 	unsigned int length, char *desc)
 {
 	u64 addr;
@@ -180,33 +180,41 @@ static void __init acpi_request_region (struct acpi_generic_address *gas,
 
 static int __init acpi_reserve_resources(void)
 {
-	acpi_request_region(&acpi_gbl_FADT.xpm1a_event_block, acpi_gbl_FADT.pm1_event_length,
-		"ACPI PM1a_EVT_BLK");
+	acpi_request_region(&acpi_gbl_FADT.xpm1a_event_block,
+			    acpi_gbl_FADT.pm1_event_length,
+			    "ACPI PM1a_EVT_BLK");
 
-	acpi_request_region(&acpi_gbl_FADT.xpm1b_event_block, acpi_gbl_FADT.pm1_event_length,
-		"ACPI PM1b_EVT_BLK");
+	acpi_request_region(&acpi_gbl_FADT.xpm1b_event_block,
+			    acpi_gbl_FADT.pm1_event_length,
+			    "ACPI PM1b_EVT_BLK");
 
-	acpi_request_region(&acpi_gbl_FADT.xpm1a_control_block, acpi_gbl_FADT.pm1_control_length,
-		"ACPI PM1a_CNT_BLK");
+	acpi_request_region(&acpi_gbl_FADT.xpm1a_control_block,
+			    acpi_gbl_FADT.pm1_control_length,
+			    "ACPI PM1a_CNT_BLK");
 
-	acpi_request_region(&acpi_gbl_FADT.xpm1b_control_block, acpi_gbl_FADT.pm1_control_length,
-		"ACPI PM1b_CNT_BLK");
+	acpi_request_region(&acpi_gbl_FADT.xpm1b_control_block,
+			    acpi_gbl_FADT.pm1_control_length,
+			    "ACPI PM1b_CNT_BLK");
 
 	if (acpi_gbl_FADT.pm_timer_length = 4)
-		acpi_request_region(&acpi_gbl_FADT.xpm_timer_block, 4, "ACPI PM_TMR");
+		acpi_request_region(&acpi_gbl_FADT.xpm_timer_block, 4,
+				    "ACPI PM_TMR");
 
-	acpi_request_region(&acpi_gbl_FADT.xpm2_control_block, acpi_gbl_FADT.pm2_control_length,
-		"ACPI PM2_CNT_BLK");
+	acpi_request_region(&acpi_gbl_FADT.xpm2_control_block,
+			    acpi_gbl_FADT.pm2_control_length,
+			    "ACPI PM2_CNT_BLK");
 
 	/* Length of GPE blocks must be a non-negative multiple of 2 */
 
 	if (!(acpi_gbl_FADT.gpe0_block_length & 0x1))
 		acpi_request_region(&acpi_gbl_FADT.xgpe0_block,
-			       acpi_gbl_FADT.gpe0_block_length, "ACPI GPE0_BLK");
+				    acpi_gbl_FADT.gpe0_block_length,
+				    "ACPI GPE0_BLK");
 
 	if (!(acpi_gbl_FADT.gpe1_block_length & 0x1))
 		acpi_request_region(&acpi_gbl_FADT.xgpe1_block,
-			       acpi_gbl_FADT.gpe1_block_length, "ACPI GPE1_BLK");
+				    acpi_gbl_FADT.gpe1_block_length,
+				    "ACPI GPE1_BLK");
 
 	return 0;
 }
@@ -215,6 +223,7 @@ device_initcall(acpi_reserve_resources);
 void acpi_os_printf(const char *fmt, ...)
 {
 	va_list args;
+
 	va_start(args, fmt);
 	acpi_os_vprintf(fmt, args);
 	va_end(args);
@@ -227,11 +236,10 @@ void acpi_os_vprintf(const char *fmt, va_list args)
 	vsprintf(buffer, fmt, args);
 
 #ifdef ENABLE_DEBUGGER
-	if (acpi_in_debugger) {
+	if (acpi_in_debugger)
 		kdb_printf("%s", buffer);
-	} else {
+	else
 		pr_cont("%s", buffer);
-	}
 #else
 	pr_cont("%s", buffer);
 #endif
@@ -879,6 +887,7 @@ void acpi_os_stall(u32 us)
 u64 acpi_os_get_timer(void)
 {
 	u64 time_ns = ktime_to_ns(ktime_get());
+
 	do_div(time_ns, 100);
 	return time_ns;
 }
@@ -891,15 +900,14 @@ acpi_status acpi_os_read_port(acpi_io_address port, u32 *value, u32 width)
 		value = &dummy;
 
 	*value = 0;
-	if (width <= 8) {
+	if (width <= 8)
 		*(u8 *) value = inb(port);
-	} else if (width <= 16) {
+	else if (width <= 16)
 		*(u16 *) value = inw(port);
-	} else if (width <= 32) {
+	else if (width <= 32)
 		*(u32 *) value = inl(port);
-	} else {
+	else
 		BUG();
-	}
 
 	return AE_OK;
 }
@@ -908,15 +916,14 @@ EXPORT_SYMBOL(acpi_os_read_port);
 
 acpi_status acpi_os_write_port(acpi_io_address port, u32 value, u32 width)
 {
-	if (width <= 8) {
+	if (width <= 8)
 		outb(value, port);
-	} else if (width <= 16) {
+	else if (width <= 16)
 		outw(value, port);
-	} else if (width <= 32) {
+	else if (width <= 32)
 		outl(value, port);
-	} else {
+	else
 		BUG();
-	}
 
 	return AE_OK;
 }
@@ -932,6 +939,7 @@ static inline u64 read64(const volatile void __iomem *addr)
 static inline u64 read64(const volatile void __iomem *addr)
 {
 	u64 l, h;
+
 	l = readl(addr);
 	h = readl(addr+4);
 	return l | (h << 32);
@@ -1116,8 +1124,8 @@ static void acpi_os_execute_deferred(struct work_struct *work)
  *
  * RETURN:      Status
  *
- * DESCRIPTION: Depending on type, either queues function for deferred execution or
- *              immediately executes function on a separate thread.
+ * DESCRIPTION: Depending on type, either queues function for deferred
+ *		execution or immediately executes function on a separate thread.
  *
  ******************************************************************************/
 
@@ -1128,6 +1136,7 @@ acpi_status acpi_os_execute(acpi_execute_type type,
 	struct acpi_os_dpc *dpc;
 	struct workqueue_struct *queue;
 	int ret;
+
 	ACPI_DEBUG_PRINT((ACPI_DB_EXEC,
 			  "Scheduling function [%p(%p)] for deferred execution.\n",
 			  function, context));
@@ -1199,7 +1208,8 @@ struct acpi_hp_work {
 
 static void acpi_hotplug_work_fn(struct work_struct *work)
 {
-	struct acpi_hp_work *hpw = container_of(work, struct acpi_hp_work, work);
+	struct acpi_hp_work *hpw = container_of(work, struct acpi_hp_work,
+						work);
 
 	acpi_os_wait_events_complete();
 	acpi_device_hotplug(hpw->adev, hpw->src);
@@ -1693,6 +1703,7 @@ void acpi_os_delete_lock(acpi_spinlock handle)
 acpi_cpu_flags acpi_os_acquire_lock(acpi_spinlock lockp)
 {
 	acpi_cpu_flags flags;
+
 	spin_lock_irqsave(lockp, flags);
 	return flags;
 }
@@ -1869,6 +1880,7 @@ acpi_status acpi_os_prepare_sleep(u8 sleep_state, u32 pm1a_control,
 				  u32 pm1b_control)
 {
 	int rc = 0;
+
 	if (__acpi_os_prepare_sleep)
 		rc = __acpi_os_prepare_sleep(sleep_state,
 					     pm1a_control, pm1b_control);
@@ -1890,6 +1902,7 @@ acpi_status acpi_os_prepare_extended_sleep(u8 sleep_state, u32 val_a,
 				  u32 val_b)
 {
 	int rc = 0;
+
 	if (__acpi_os_prepare_extended_sleep)
 		rc = __acpi_os_prepare_extended_sleep(sleep_state,
 					     val_a, val_b);
-- 
2.1.0

