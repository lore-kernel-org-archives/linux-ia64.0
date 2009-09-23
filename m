From: Tejun Heo <tj@kernel.org>
Date: Wed, 23 Sep 2009 05:06:19 +0000
Subject: [PATCH 2/5] ia64: initialize cpu maps early
Message-Id: <1253682382-24740-3-git-send-email-tj@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1253682382-24740-1-git-send-email-tj@kernel.org>
In-Reply-To: <1253682382-24740-1-git-send-email-tj@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Nick Piggin <npiggin@suse.de>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64 <linux-ia64@vger.kernel.org>, Ingo Molnar <mingo@redhat.com>, Rusty Russell <rusty@rustcorp.com.au>, Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Tejun Heo <tj@kernel.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64 <linux-ia64@vger.kernel.org>

All information necessary to initialize cpu possible and present maps
are available once early_acpi_boot_init() is complete.  Reorganize
setup_arch() and acpi init functions such that,

* CPU information is printed after LAPIC entries are parsed in
  early_acpi_boot_init().

* smp_build_cpu_map() is called by setup_arch() instead of acpi
  functions.

* smp_build_cpu_map() is called once all CPU related information is
  available before memory is initialized.

This is primarily to allow find_memory() to use cpu maps but is also a
general cleanup.  Please note that with this change, the somewhat
ad-hoc early_cpu_possible_map defined and used for NUMA configurations
is probably unnecessary.  Something to clean up another day.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64 <linux-ia64@vger.kernel.org>
---
 arch/ia64/kernel/acpi.c  |   33 +++++++++++++++------------------
 arch/ia64/kernel/setup.c |   11 +++++------
 2 files changed, 20 insertions(+), 24 deletions(-)

diff --git a/arch/ia64/kernel/acpi.c b/arch/ia64/kernel/acpi.c
index baec6f0..40574ae 100644
--- a/arch/ia64/kernel/acpi.c
+++ b/arch/ia64/kernel/acpi.c
@@ -702,11 +702,23 @@ int __init early_acpi_boot_init(void)
 		printk(KERN_ERR PREFIX
 		       "Error parsing MADT - no LAPIC entries\n");
 
+#ifdef CONFIG_SMP
+	if (available_cpus = 0) {
+		printk(KERN_INFO "ACPI: Found 0 CPUS; assuming 1\n");
+		printk(KERN_INFO "CPU 0 (0x%04x)", hard_smp_processor_id());
+		smp_boot_data.cpu_phys_id[available_cpus] +		    hard_smp_processor_id();
+		available_cpus = 1;	/* We've got at least one of these, no? */
+	}
+	smp_boot_data.cpu_count = available_cpus;
+#endif
+	/* Make boot-up look pretty */
+	printk(KERN_INFO "%d CPUs available, %d CPUs total\n", available_cpus,
+	       total_cpus);
+
 	return 0;
 }
 
-
-
 int __init acpi_boot_init(void)
 {
 
@@ -769,18 +781,8 @@ int __init acpi_boot_init(void)
 	if (acpi_table_parse(ACPI_SIG_FADT, acpi_parse_fadt))
 		printk(KERN_ERR PREFIX "Can't find FADT\n");
 
+#ifdef CONFIG_ACPI_NUMA
 #ifdef CONFIG_SMP
-	if (available_cpus = 0) {
-		printk(KERN_INFO "ACPI: Found 0 CPUS; assuming 1\n");
-		printk(KERN_INFO "CPU 0 (0x%04x)", hard_smp_processor_id());
-		smp_boot_data.cpu_phys_id[available_cpus] -		    hard_smp_processor_id();
-		available_cpus = 1;	/* We've got at least one of these, no? */
-	}
-	smp_boot_data.cpu_count = available_cpus;
-
-	smp_build_cpu_map();
-# ifdef CONFIG_ACPI_NUMA
 	if (srat_num_cpus = 0) {
 		int cpu, i = 1;
 		for (cpu = 0; cpu < smp_boot_data.cpu_count; cpu++)
@@ -789,14 +791,9 @@ int __init acpi_boot_init(void)
 				node_cpuid[i++].phys_id  				    smp_boot_data.cpu_phys_id[cpu];
 	}
-# endif
 #endif
-#ifdef CONFIG_ACPI_NUMA
 	build_cpu_to_node_map();
 #endif
-	/* Make boot-up look pretty */
-	printk(KERN_INFO "%d CPUs available, %d CPUs total\n", available_cpus,
-	       total_cpus);
 	return 0;
 }
 
diff --git a/arch/ia64/kernel/setup.c b/arch/ia64/kernel/setup.c
index 1de86c9..5d77c1e 100644
--- a/arch/ia64/kernel/setup.c
+++ b/arch/ia64/kernel/setup.c
@@ -566,19 +566,18 @@ setup_arch (char **cmdline_p)
 	early_acpi_boot_init();
 # ifdef CONFIG_ACPI_NUMA
 	acpi_numa_init();
-#ifdef CONFIG_ACPI_HOTPLUG_CPU
+#  ifdef CONFIG_ACPI_HOTPLUG_CPU
 	prefill_possible_map();
-#endif
+#  endif
 	per_cpu_scan_finalize((cpus_weight(early_cpu_possible_map) = 0 ?
 		32 : cpus_weight(early_cpu_possible_map)),
 		additional_cpus > 0 ? additional_cpus : 0);
 # endif
-#else
-# ifdef CONFIG_SMP
-	smp_build_cpu_map();	/* happens, e.g., with the Ski simulator */
-# endif
 #endif /* CONFIG_APCI_BOOT */
 
+#ifdef CONFIG_SMP
+	smp_build_cpu_map();
+#endif
 	find_memory();
 
 	/* process SAL system table: */
-- 
1.6.4.2

