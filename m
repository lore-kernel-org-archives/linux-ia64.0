From: Keith Owens <kaos@sgi.com>
Date: Fri, 13 Feb 2004 06:45:53 +0000
Subject: [patch] 2.6.3-rc2 Correct ifdef for srat_num_cpus
Message-Id: <6343.1076654753@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The definition of srat_num_cpus is wrapped in #ifdef CONFIG_ACPI_NUMA,
make its usage match.

Index: 3-rc2.4/arch/ia64/kernel/acpi.c
--- 3-rc2.4/arch/ia64/kernel/acpi.c Tue, 10 Feb 2004 15:29:40 +1100 kaos (linux-2.6/Z/c/40_acpi.c 1.1.1.1.1.3 644)
+++ 3-rc2.4(w)/arch/ia64/kernel/acpi.c Fri, 13 Feb 2004 17:42:42 +1100 kaos (linux-2.6/Z/c/40_acpi.c 1.1.1.1.1.3 644)
@@ -589,7 +589,7 @@ acpi_boot_init (void)
 	smp_boot_data.cpu_count = available_cpus;
 
 	smp_build_cpu_map();
-# ifdef CONFIG_NUMA
+# ifdef CONFIG_ACPI_NUMA
 	if (srat_num_cpus = 0) {
 		int cpu, i = 1;
 		for (cpu = 0; cpu < smp_boot_data.cpu_count; cpu++)

