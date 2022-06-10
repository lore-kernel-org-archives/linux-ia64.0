From: Li kunyu <kunyu@nfschina.com>
Date: Fri, 10 Jun 2022 10:44:23 +0000
Subject: [PATCH] x86: Change the return type of acpi_map_cpu2node to void
Message-Id: <20220610104423.201739-1-kunyu@nfschina.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220610103644.201245-1-kunyu@nfschina.com>
In-Reply-To: <20220610103644.201245-1-kunyu@nfschina.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: chenhuacai@kernel.org, rafael@kernel.org, len.brown@intel.com, pavel@ucw.cz, mingo@redhat.com, bp@alien8.de
Cc: tglx@linutronix.de, dave.hansen@linux.intel.com, x86@kernel.org, hpa@zytor.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-pm@vger.kernel.org, Li kunyu <kunyu@nfschina.com>

Reduce eax register calls by removing unused return values.

Signed-off-by: Li kunyu <kunyu@nfschina.com>
---
 arch/ia64/kernel/acpi.c      | 3 +--
 arch/loongarch/kernel/acpi.c | 3 +--
 arch/x86/kernel/acpi/boot.c  | 3 +--
 3 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/arch/ia64/kernel/acpi.c b/arch/ia64/kernel/acpi.c
index 96d13cb7c19f..2665cc873f0a 100644
--- a/arch/ia64/kernel/acpi.c
+++ b/arch/ia64/kernel/acpi.c
@@ -712,7 +712,7 @@ int acpi_isa_irq_to_gsi(unsigned isa_irq, u32 *gsi)
  *  ACPI based hotplug CPU support
  */
 #ifdef CONFIG_ACPI_HOTPLUG_CPU
-int acpi_map_cpu2node(acpi_handle handle, int cpu, int physid)
+void acpi_map_cpu2node(acpi_handle handle, int cpu, int physid)
 {
 #ifdef CONFIG_ACPI_NUMA
 	/*
@@ -725,7 +725,6 @@ int acpi_map_cpu2node(acpi_handle handle, int cpu, int physid)
 	node_cpuid[cpu].phys_id = physid;
 	node_cpuid[cpu].nid = acpi_get_node(handle);
 #endif
-	return 0;
 }
 
 int additional_cpus __initdata = -1;
diff --git a/arch/loongarch/kernel/acpi.c b/arch/loongarch/kernel/acpi.c
index b16c3dea5eeb..369b49343563 100644
--- a/arch/loongarch/kernel/acpi.c
+++ b/arch/loongarch/kernel/acpi.c
@@ -282,7 +282,7 @@ void __init arch_reserve_mem_area(acpi_physical_address addr, size_t size)
 
 #include <acpi/processor.h>
 
-static int __ref acpi_map_cpu2node(acpi_handle handle, int cpu, int physid)
+static void __ref acpi_map_cpu2node(acpi_handle handle, int cpu, int physid)
 {
 #ifdef CONFIG_ACPI_NUMA
 	int nid;
@@ -295,7 +295,6 @@ static int __ref acpi_map_cpu2node(acpi_handle handle, int cpu, int physid)
 		cpumask_set_cpu(cpu, cpumask_of_node(nid));
 	}
 #endif
-	return 0;
 }
 
 int acpi_map_cpu(acpi_handle handle, phys_cpuid_t physid, u32 acpi_id, int *pcpu)
diff --git a/arch/x86/kernel/acpi/boot.c b/arch/x86/kernel/acpi/boot.c
index 907cc98b1938..d63ec3ea3be3 100644
--- a/arch/x86/kernel/acpi/boot.c
+++ b/arch/x86/kernel/acpi/boot.c
@@ -799,7 +799,7 @@ static void __init acpi_set_irq_model_ioapic(void)
 #ifdef CONFIG_ACPI_HOTPLUG_CPU
 #include <acpi/processor.h>
 
-static int acpi_map_cpu2node(acpi_handle handle, int cpu, int physid)
+static void acpi_map_cpu2node(acpi_handle handle, int cpu, int physid)
 {
 #ifdef CONFIG_ACPI_NUMA
 	int nid;
@@ -810,7 +810,6 @@ static int acpi_map_cpu2node(acpi_handle handle, int cpu, int physid)
 		numa_set_node(cpu, nid);
 	}
 #endif
-	return 0;
 }
 
 int acpi_map_cpu(acpi_handle handle, phys_cpuid_t physid, u32 acpi_id,
-- 
2.18.2
