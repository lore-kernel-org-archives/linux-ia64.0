From: Sudeep Holla <sudeep.holla@arm.com>
Date: Tue, 19 Apr 2016 12:30:09 +0000
Subject: [PATCH v4 1/5] ACPI / processor_idle: introduce ARCH_SUPPORTS_ACPI_PROCESSOR_CSTATE
Message-Id: <1461069013-13292-2-git-send-email-sudeep.holla@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1461069013-13292-1-git-send-email-sudeep.holla@arm.com>
In-Reply-To: <1461069013-13292-1-git-send-email-sudeep.holla@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Rafael J. Wysocki" <rjw@rjwysocki.net>, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org
Cc: Sudeep Holla <sudeep.holla@arm.com>, Lorenzo Pieralisi <lorenzo.pieralisi@arm.com>, Al Stone <al.stone@linaro.org>, Prashanth Prakash <pprakash@codeaurora.org>, Ashwin Chaugule <ashwin.chaugule@linaro.org>, x86@kernel.org, linux-ia64@vger.kernel.org

ACPI 6.0 adds a new method to specify the CPU idle states(C-states)
called Low Power Idle(LPI) states. Since new architectures like ARM64
use only LPIs, introduce ARCH_SUPPORTS_ACPI_PROCESSOR_CSTATE to
encapsulate all the code supporting the old style C-states(_CST)

This patch will help to extend the processor_idle module to support
LPI.

Cc: x86@kernel.org
Cc: linux-ia64@vger.kernel.org
Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Signed-off-by: Sudeep Holla <sudeep.holla@arm.com>
---
 arch/ia64/Kconfig             |  1 +
 arch/x86/Kconfig              |  1 +
 drivers/acpi/Kconfig          |  3 ++
 drivers/acpi/processor_idle.c | 74 +++++++++++++++++++++++++++++--------------
 include/acpi/processor.h      |  3 +-
 5 files changed, 57 insertions(+), 25 deletions(-)

diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
index b534ebab36ea..717de2a146e2 100644
--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
@@ -16,6 +16,7 @@ config IA64
 	select PCI if (!IA64_HP_SIM)
 	select ACPI if (!IA64_HP_SIM)
 	select ACPI_SYSTEM_POWER_STATES_SUPPORT if ACPI
+	select ARCH_SUPPORTS_ACPI_PROCESSOR_CSTATE if ACPI
 	select ARCH_MIGHT_HAVE_ACPI_PDC if ACPI
 	select HAVE_UNSTABLE_SCHED_CLOCK
 	select HAVE_IDE
diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 2dc18605831f..eb03fd0d63b9 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -37,6 +37,7 @@ config X86
 	select ARCH_MIGHT_HAVE_ACPI_PDC		if ACPI
 	select ARCH_MIGHT_HAVE_PC_PARPORT
 	select ARCH_MIGHT_HAVE_PC_SERIO
+	select ARCH_SUPPORTS_ACPI_PROCESSOR_CSTATE if ACPI
 	select ARCH_SUPPORTS_ATOMIC_RMW
 	select ARCH_SUPPORTS_DEFERRED_STRUCT_PAGE_INIT
 	select ARCH_SUPPORTS_INT128		if X86_64
diff --git a/drivers/acpi/Kconfig b/drivers/acpi/Kconfig
index 82b96ee8624c..ec289078667c 100644
--- a/drivers/acpi/Kconfig
+++ b/drivers/acpi/Kconfig
@@ -48,6 +48,9 @@ config ACPI_LEGACY_TABLES_LOOKUP
 config ARCH_MIGHT_HAVE_ACPI_PDC
 	bool
 
+config ARCH_SUPPORTS_ACPI_PROCESSOR_CSTATE
+	bool
+
 config ACPI_GENERIC_GSI
 	bool
 
diff --git a/drivers/acpi/processor_idle.c b/drivers/acpi/processor_idle.c
index 444e3745c8b3..1f3fe54194b5 100644
--- a/drivers/acpi/processor_idle.c
+++ b/drivers/acpi/processor_idle.c
@@ -59,6 +59,12 @@ module_param(latency_factor, uint, 0644);
 
 static DEFINE_PER_CPU(struct cpuidle_device *, acpi_cpuidle_device);
 
+struct cpuidle_driver acpi_idle_driver = {
+	.name =		"acpi_idle",
+	.owner =	THIS_MODULE,
+};
+
+#ifdef CONFIG_ARCH_SUPPORTS_ACPI_PROCESSOR_CSTATE
 static
 DEFINE_PER_CPU(struct acpi_processor_cx * [CPUIDLE_STATE_MAX], acpi_cstate);
 
@@ -804,11 +810,6 @@ static void acpi_idle_enter_freeze(struct cpuidle_device *dev,
 	acpi_idle_do_entry(cx);
 }
 
-struct cpuidle_driver acpi_idle_driver = {
-	.name =		"acpi_idle",
-	.owner =	THIS_MODULE,
-};
-
 /**
  * acpi_processor_setup_cpuidle_cx - prepares and configures CPUIDLE
  * device i.e. per-cpu data
@@ -925,6 +926,49 @@ static int acpi_processor_setup_cpuidle_states(struct acpi_processor *pr)
 	return 0;
 }
 
+static inline void acpi_processor_cstate_first_run_checks(void)
+{
+	static int first_run;
+
+	if (first_run)
+		return;
+	dmi_check_system(processor_power_dmi_table);
+	max_cstate = acpi_processor_cstate_check(max_cstate);
+	if (max_cstate < ACPI_C_STATES_MAX)
+		pr_notice("ACPI: processor limited to max C-state %d\n",
+			  max_cstate);
+	first_run++;
+
+	if (acpi_gbl_FADT.cst_control && !nocst) {
+		status = acpi_os_write_port(acpi_gbl_FADT.smi_command,
+					    acpi_gbl_FADT.cst_control, 8);
+		if (ACPI_FAILURE(status))
+			ACPI_EXCEPTION((AE_INFO, status,
+					"Notifying BIOS of _CST ability failed"));
+	}
+}
+#else
+
+static inline int disabled_by_idle_boot_param(void) { return 0; }
+static inline void acpi_processor_cstate_first_run_checks(void) { }
+static int acpi_processor_get_power_info(struct acpi_processor *pr)
+{
+	return -ENODEV;
+}
+
+static int acpi_processor_setup_cpuidle_cx(struct acpi_processor *pr,
+					   struct cpuidle_device *dev)
+{
+	return -EINVAL;
+}
+
+static int acpi_processor_setup_cpuidle_states(struct acpi_processor *pr)
+{
+	return -EINVAL;
+}
+
+#endif
+
 int acpi_processor_hotplug(struct acpi_processor *pr)
 {
 	int ret = 0;
@@ -1018,29 +1062,11 @@ int acpi_processor_power_init(struct acpi_processor *pr)
 	acpi_status status;
 	int retval;
 	struct cpuidle_device *dev;
-	static int first_run;
 
 	if (disabled_by_idle_boot_param())
 		return 0;
 
-	if (!first_run) {
-		dmi_check_system(processor_power_dmi_table);
-		max_cstate = acpi_processor_cstate_check(max_cstate);
-		if (max_cstate < ACPI_C_STATES_MAX)
-			printk(KERN_NOTICE
-			       "ACPI: processor limited to max C-state %d\n",
-			       max_cstate);
-		first_run++;
-	}
-
-	if (acpi_gbl_FADT.cst_control && !nocst) {
-		status -		    acpi_os_write_port(acpi_gbl_FADT.smi_command, acpi_gbl_FADT.cst_control, 8);
-		if (ACPI_FAILURE(status)) {
-			ACPI_EXCEPTION((AE_INFO, status,
-					"Notifying BIOS of _CST ability failed"));
-		}
-	}
+	acpi_processor_cstate_first_run_checks();
 
 	acpi_processor_get_power_info(pr);
 	pr->flags.power_setup_done = 1;
diff --git a/include/acpi/processor.h b/include/acpi/processor.h
index 6f1805dd5d3c..50f2423d31fa 100644
--- a/include/acpi/processor.h
+++ b/include/acpi/processor.h
@@ -242,7 +242,8 @@ extern int acpi_processor_get_performance_info(struct acpi_processor *pr);
 DECLARE_PER_CPU(struct acpi_processor *, processors);
 extern struct acpi_processor_errata errata;
 
-#ifdef ARCH_HAS_POWER_INIT
+#if defined(ARCH_HAS_POWER_INIT) && \
+	defined(CONFIG_ARCH_SUPPORTS_ACPI_PROCESSOR_CSTATE)
 void acpi_processor_power_init_bm_check(struct acpi_processor_flags *flags,
 					unsigned int cpu);
 int acpi_processor_ffh_cstate_probe(unsigned int cpu,
-- 
1.9.1

