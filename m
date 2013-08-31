From: Hanjun Guo <hanjun.guo@linaro.org>
Date: Sat, 31 Aug 2013 10:15:56 +0000
Subject: [PATCH 1/6] ACPI / processor: Introduce apic_id in struct processor to save parsed APIC id
Message-Id: <1377944162-18574-1-git-send-email-hanjun.guo@linaro.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, Ingo Molnar <mingo@redhat.com>, linux-acpi@vger.kernel.org, x86@kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, patches@linaro.org, linaro-kernel@lists.linaro.org, linaro-acpi@lists.linaro.org, Jiang Liu <jiang.liu@huawei.com>, Hanjun Guo <hanjun.guo@linaro.org>

From: Jiang Liu <jiang.liu@huawei.com>

For cpu hot add, we evaluate _MAT or parse MADT twice to get APIC id,
here is the code logic:
acpi_processor_add()
	acpi_processor_get_info()
		acpi_get_cpuid() will evaluate _MAT or parse MADT;
	acpi_processor_hotadd_init()
		acpi_map_lsapic() will evaluate _MAT again;

This can be done more effectively, this patch introduces apic_id in struct
processor to save parsed APIC id, and then we can use it and remove the
duplicated _MAT evaluation.

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Signed-off-by: Hanjun Guo <hanjun.guo@linaro.org>
---
 drivers/acpi/acpi_processor.c |    3 ++-
 drivers/acpi/processor_core.c |   26 +++++++++++++++++++++-----
 include/acpi/processor.h      |    3 +++
 3 files changed, 26 insertions(+), 6 deletions(-)

diff --git a/drivers/acpi/acpi_processor.c b/drivers/acpi/acpi_processor.c
index f29e06e..d5a6c81 100644
--- a/drivers/acpi/acpi_processor.c
+++ b/drivers/acpi/acpi_processor.c
@@ -270,7 +270,8 @@ static int acpi_processor_get_info(struct acpi_device *device)
 		device_declaration = 1;
 		pr->acpi_id = value;
 	}
-	cpu_index = acpi_get_cpuid(pr->handle, device_declaration, pr->acpi_id);
+	pr->apic_id = acpi_get_apicid(pr->handle, device_declaration, pr->acpi_id);
+	cpu_index = acpi_map_cpuid(pr->apic_id, pr->acpi_id);
 
 	/* Handle UP system running SMP kernel, with no LAPIC in MADT */
 	if (!cpu0_initialized && (cpu_index = -1) &&
diff --git a/drivers/acpi/processor_core.c b/drivers/acpi/processor_core.c
index cf34d90..b3171f3 100644
--- a/drivers/acpi/processor_core.c
+++ b/drivers/acpi/processor_core.c
@@ -162,16 +162,23 @@ exit:
 	return apic_id;
 }
 
-int acpi_get_cpuid(acpi_handle handle, int type, u32 acpi_id)
+int acpi_get_apicid(acpi_handle handle, int type, u32 acpi_id)
 {
-#ifdef CONFIG_SMP
-	int i;
-#endif
-	int apic_id = -1;
+	int apic_id;
 
 	apic_id = map_mat_entry(handle, type, acpi_id);
 	if (apic_id = -1)
 		apic_id = map_madt_entry(type, acpi_id);
+
+	return apic_id;
+}
+
+int acpi_map_cpuid(int apic_id, u32 acpi_id)
+{
+#ifdef CONFIG_SMP
+	int i;
+#endif
+
 	if (apic_id = -1) {
 		/*
 		 * On UP processor, there is no _MAT or MADT table.
@@ -211,6 +218,15 @@ int acpi_get_cpuid(acpi_handle handle, int type, u32 acpi_id)
 #endif
 	return -1;
 }
+
+int acpi_get_cpuid(acpi_handle handle, int type, u32 acpi_id)
+{
+	int apic_id;
+
+	apic_id = acpi_get_apicid(handle, type, acpi_id);
+
+	return acpi_map_cpuid(apic_id, acpi_id);
+}
 EXPORT_SYMBOL_GPL(acpi_get_cpuid);
 
 static bool __init processor_physically_present(acpi_handle handle)
diff --git a/include/acpi/processor.h b/include/acpi/processor.h
index 66096d0..7816e45 100644
--- a/include/acpi/processor.h
+++ b/include/acpi/processor.h
@@ -199,6 +199,7 @@ struct acpi_processor_flags {
 struct acpi_processor {
 	acpi_handle handle;
 	u32 acpi_id;
+	u32 apic_id;
 	u32 id;
 	u32 pblk;
 	int performance_platform_limit;
@@ -314,6 +315,8 @@ static inline int acpi_processor_get_bios_limit(int cpu, unsigned int *limit)
 
 /* in processor_core.c */
 void acpi_processor_set_pdc(acpi_handle handle);
+int acpi_get_apicid(acpi_handle, int type, u32 acpi_id);
+int acpi_map_cpuid(int apic_id, u32 acpi_id);
 int acpi_get_cpuid(acpi_handle, int type, u32 acpi_id);
 
 /* in processor_throttling.c */
-- 
1.7.9.5

