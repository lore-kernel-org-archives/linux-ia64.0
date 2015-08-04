From: Sudeep Holla <sudeep.holla@arm.com>
Date: Tue, 04 Aug 2015 17:46:44 +0000
Subject: [PATCH 2/4] ACPI / sleep: move acpi_processor_sleep to sleep.c
Message-Id: <1438710406-3822-3-git-send-email-sudeep.holla@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1438710406-3822-1-git-send-email-sudeep.holla@arm.com>
In-Reply-To: <1438710406-3822-1-git-send-email-sudeep.holla@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-acpi@vger.kernel.org, "Rafael J. Wysocki" <rjw@rjwysocki.net>
Cc: Sudeep Holla <sudeep.holla@arm.com>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, x86@kernel.org

acpi_processor_sleep is neither related nor used by CPUIdle framework.
It's used in system suspend/resume path as a syscore operation. It makes
more sense to move it to acpi/sleep.c where all the S-state transition
(a.k.a. Linux system suspend/hiberate) related code are present.

Also make it depend on CONFIG_ACPI_SYSTEM_POWER_STATES_SUPPORT so that
it's not compiled on architecture like ARM64 where S-states are not
yet defined in ACPI.

Signed-off-by: Sudeep Holla <sudeep.holla@arm.com>
Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>
---
 drivers/acpi/processor_idle.c | 37 -------------------------------------
 drivers/acpi/sleep.c          | 37 +++++++++++++++++++++++++++++++++++++
 include/acpi/processor.h      |  2 +-
 3 files changed, 38 insertions(+), 38 deletions(-)

diff --git a/drivers/acpi/processor_idle.c b/drivers/acpi/processor_idle.c
index d540f42c9232..18d4de846490 100644
--- a/drivers/acpi/processor_idle.c
+++ b/drivers/acpi/processor_idle.c
@@ -34,7 +34,6 @@
 #include <linux/sched.h>       /* need_resched() */
 #include <linux/tick.h>
 #include <linux/cpuidle.h>
-#include <linux/syscore_ops.h>
 #include <acpi/processor.h>
 
 /*
@@ -198,42 +197,6 @@ static void lapic_timer_state_broadcast(struct acpi_processor *pr,
 
 #endif
 
-#ifdef CONFIG_PM_SLEEP
-static u32 saved_bm_rld;
-
-static int acpi_processor_suspend(void)
-{
-	acpi_read_bit_register(ACPI_BITREG_BUS_MASTER_RLD, &saved_bm_rld);
-	return 0;
-}
-
-static void acpi_processor_resume(void)
-{
-	u32 resumed_bm_rld = 0;
-
-	acpi_read_bit_register(ACPI_BITREG_BUS_MASTER_RLD, &resumed_bm_rld);
-	if (resumed_bm_rld = saved_bm_rld)
-		return;
-
-	acpi_write_bit_register(ACPI_BITREG_BUS_MASTER_RLD, saved_bm_rld);
-}
-
-static struct syscore_ops acpi_processor_syscore_ops = {
-	.suspend = acpi_processor_suspend,
-	.resume = acpi_processor_resume,
-};
-
-void acpi_processor_syscore_init(void)
-{
-	register_syscore_ops(&acpi_processor_syscore_ops);
-}
-
-void acpi_processor_syscore_exit(void)
-{
-	unregister_syscore_ops(&acpi_processor_syscore_ops);
-}
-#endif /* CONFIG_PM_SLEEP */
-
 #if defined(CONFIG_X86)
 static void tsc_check_state(int state)
 {
diff --git a/drivers/acpi/sleep.c b/drivers/acpi/sleep.c
index 2f0d4db40a9e..cfea056e3d82 100644
--- a/drivers/acpi/sleep.c
+++ b/drivers/acpi/sleep.c
@@ -19,6 +19,7 @@
 #include <linux/reboot.h>
 #include <linux/acpi.h>
 #include <linux/module.h>
+#include <linux/syscore_ops.h>
 #include <asm/io.h>
 #include <trace/events/power.h>
 
@@ -672,6 +673,42 @@ static void acpi_sleep_suspend_setup(void)
 static inline void acpi_sleep_suspend_setup(void) {}
 #endif /* !CONFIG_SUSPEND */
 
+#ifdef CONFIG_PM_SLEEP
+static u32 saved_bm_rld;
+
+static int acpi_processor_suspend(void)
+{
+	acpi_read_bit_register(ACPI_BITREG_BUS_MASTER_RLD, &saved_bm_rld);
+	return 0;
+}
+
+static void acpi_processor_resume(void)
+{
+	u32 resumed_bm_rld = 0;
+
+	acpi_read_bit_register(ACPI_BITREG_BUS_MASTER_RLD, &resumed_bm_rld);
+	if (resumed_bm_rld = saved_bm_rld)
+		return;
+
+	acpi_write_bit_register(ACPI_BITREG_BUS_MASTER_RLD, saved_bm_rld);
+}
+
+static struct syscore_ops acpi_processor_syscore_ops = {
+	.suspend = acpi_processor_suspend,
+	.resume = acpi_processor_resume,
+};
+
+void acpi_processor_syscore_init(void)
+{
+	register_syscore_ops(&acpi_processor_syscore_ops);
+}
+
+void acpi_processor_syscore_exit(void)
+{
+	unregister_syscore_ops(&acpi_processor_syscore_ops);
+}
+#endif /* CONFIG_PM_SLEEP */
+
 #ifdef CONFIG_HIBERNATION
 static unsigned long s4_hardware_signature;
 static struct acpi_table_facs *facs;
diff --git a/include/acpi/processor.h b/include/acpi/processor.h
index 2669cae4a0c8..4c464d67ba09 100644
--- a/include/acpi/processor.h
+++ b/include/acpi/processor.h
@@ -338,7 +338,7 @@ int acpi_processor_cst_has_changed(struct acpi_processor *pr);
 int acpi_processor_hotplug(struct acpi_processor *pr);
 extern struct cpuidle_driver acpi_idle_driver;
 
-#ifdef CONFIG_PM_SLEEP
+#if defined(CONFIG_PM_SLEEP) && defined(CONFIG_ACPI_SYSTEM_POWER_STATES_SUPPORT)
 void acpi_processor_syscore_init(void);
 void acpi_processor_syscore_exit(void);
 #else
-- 
1.9.1

