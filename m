From: Mathias Krause <minipli@googlemail.com>
Date: Sun, 19 Jul 2015 15:05:41 +0000
Subject: [PATCH 1/3] ACPI / ia64: Get rid of the acpi_map_cpu() wrapper
Message-Id: <1437318343-13152-2-git-send-email-minipli@googlemail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The __cpuinit annotation was dropped from acpi_processor_set_pdc()
in commit fe7bf106ebc2 ("acpi: delete __cpuinit usage from all acpi
files"), vanishing the need for the __ref annotated acpi_map_cpu()
wrapper.

Signed-off-by: Mathias Krause <minipli@googlemail.com>
Cc: "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 arch/ia64/kernel/acpi.c |    8 +-------
 1 file changed, 1 insertion(+), 7 deletions(-)

diff --git a/arch/ia64/kernel/acpi.c b/arch/ia64/kernel/acpi.c
index b1698bc042c8..c706e24f6b2d 100644
--- a/arch/ia64/kernel/acpi.c
+++ b/arch/ia64/kernel/acpi.c
@@ -865,7 +865,7 @@ __init void prefill_possible_map(void)
 		set_cpu_possible(i, true);
 }
 
-static int _acpi_map_lsapic(acpi_handle handle, int physid, int *pcpu)
+int acpi_map_cpu(acpi_handle handle, phys_cpuid_t physid, int *pcpu)
 {
 	cpumask_t tmp_map;
 	int cpu;
@@ -885,12 +885,6 @@ static int _acpi_map_lsapic(acpi_handle handle, int physid, int *pcpu)
 	*pcpu = cpu;
 	return (0);
 }
-
-/* wrapper to silence section mismatch warning */
-int __ref acpi_map_cpu(acpi_handle handle, phys_cpuid_t physid, int *pcpu)
-{
-	return _acpi_map_lsapic(handle, physid, pcpu);
-}
 EXPORT_SYMBOL(acpi_map_cpu);
 
 int acpi_unmap_cpu(int cpu)
-- 
1.7.10.4

