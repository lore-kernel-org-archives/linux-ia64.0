From: Vitaly Kuznetsov <vkuznets@redhat.com>
Date: Mon, 06 Feb 2017 17:01:51 +0000
Subject: [PATCH] x86/acpi: keep x86_cpu_to_acpiid mapping valid on cpu hotplug
Message-Id: <20170206170151.25542-1-vkuznets@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: x86@kernel.org
Cc: linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Jones <drjones@redhat.com>

We may or may not have all possible CPUs in MADT on boot but in any case
we're overwriting x86_cpu_to_acpiid mapping with U32_MAX when
acpi_register_lapic() is called again on the CPU hotplug path:
acpi_processor_hotadd_init() -> acpi_map_cpu() -> acpi_register_lapic().

As we have the required acpi_id information in acpi_processor_hotadd_init()
propagate it to acpi_map_cpu() to always keep x86_cpu_to_acpiid mapping
valid.

Reported-by: Andrew Jones <drjones@redhat.com>
Signed-off-by: Vitaly Kuznetsov <vkuznets@redhat.com>
---
 arch/ia64/kernel/acpi.c       | 3 ++-
 arch/x86/kernel/acpi/boot.c   | 5 +++--
 drivers/acpi/acpi_processor.c | 4 ++--
 include/linux/acpi.h          | 3 ++-
 4 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/arch/ia64/kernel/acpi.c b/arch/ia64/kernel/acpi.c
index 9273e03..7508c30 100644
--- a/arch/ia64/kernel/acpi.c
+++ b/arch/ia64/kernel/acpi.c
@@ -887,7 +887,8 @@ static int _acpi_map_lsapic(acpi_handle handle, int physid, int *pcpu)
 }
 
 /* wrapper to silence section mismatch warning */
-int __ref acpi_map_cpu(acpi_handle handle, phys_cpuid_t physid, int *pcpu)
+int __ref acpi_map_cpu(acpi_handle handle, phys_cpuid_t physid, u32 acpi_id,
+		       int *pcpu)
 {
 	return _acpi_map_lsapic(handle, physid, pcpu);
 }
diff --git a/arch/x86/kernel/acpi/boot.c b/arch/x86/kernel/acpi/boot.c
index 64422f8..04bc5f3 100644
--- a/arch/x86/kernel/acpi/boot.c
+++ b/arch/x86/kernel/acpi/boot.c
@@ -723,11 +723,12 @@ int acpi_map_cpu2node(acpi_handle handle, int cpu, int physid)
 	return 0;
 }
 
-int acpi_map_cpu(acpi_handle handle, phys_cpuid_t physid, int *pcpu)
+int acpi_map_cpu(acpi_handle handle, phys_cpuid_t physid, u32 acpi_id,
+		 int *pcpu)
 {
 	int cpu;
 
-	cpu = acpi_register_lapic(physid, U32_MAX, ACPI_MADT_ENABLED);
+	cpu = acpi_register_lapic(physid, acpi_id, ACPI_MADT_ENABLED);
 	if (cpu < 0) {
 		pr_info(PREFIX "Unable to map lapic to logical cpu number\n");
 		return cpu;
diff --git a/drivers/acpi/acpi_processor.c b/drivers/acpi/acpi_processor.c
index 3de3b6b..4467a80 100644
--- a/drivers/acpi/acpi_processor.c
+++ b/drivers/acpi/acpi_processor.c
@@ -165,7 +165,7 @@ static int acpi_processor_errata(void)
 
 #ifdef CONFIG_ACPI_HOTPLUG_CPU
 int __weak acpi_map_cpu(acpi_handle handle,
-		phys_cpuid_t physid, int *pcpu)
+		phys_cpuid_t physid, u32 acpi_id, int *pcpu)
 {
 	return -ENODEV;
 }
@@ -203,7 +203,7 @@ static int acpi_processor_hotadd_init(struct acpi_processor *pr)
 	cpu_maps_update_begin();
 	cpu_hotplug_begin();
 
-	ret = acpi_map_cpu(pr->handle, pr->phys_id, &pr->id);
+	ret = acpi_map_cpu(pr->handle, pr->phys_id, pr->acpi_id, &pr->id);
 	if (ret)
 		goto out;
 
diff --git a/include/linux/acpi.h b/include/linux/acpi.h
index 5b36974..6ab47e9 100644
--- a/include/linux/acpi.h
+++ b/include/linux/acpi.h
@@ -291,7 +291,8 @@ bool acpi_processor_validate_proc_id(int proc_id);
 
 #ifdef CONFIG_ACPI_HOTPLUG_CPU
 /* Arch dependent functions for cpu hotplug support */
-int acpi_map_cpu(acpi_handle handle, phys_cpuid_t physid, int *pcpu);
+int acpi_map_cpu(acpi_handle handle, phys_cpuid_t physid, u32 acpi_id,
+		 int *pcpu);
 int acpi_unmap_cpu(int cpu);
 int acpi_map_cpu2node(acpi_handle handle, int cpu, int physid);
 #endif /* CONFIG_ACPI_HOTPLUG_CPU */
-- 
2.9.3

