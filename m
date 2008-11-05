From: Doug Chapman <doug.chapman@hp.com>
Date: Wed, 05 Nov 2008 22:57:52 +0000
Subject: [PATCH][IA64] fix boot panic caused by offline CPUs
Message-Id: <1225925872.1605.27.camel@oberon>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This fixes a regression introduced by 2c6e6db41f01b6b4eb98809350827c9678996698
"Minimize per_cpu reservations."  That patch incorrectly used information about
what CPUs are possible that was not yet initialized by ACPI.  The end result
was that per_cpu structures for offline CPUs were not initialized causing a
NULL pointer reference.

Since we cannot do the full acpi_boot_init() call any earlier, the simplest
fix is to just parse the MADT for SAPIC entries early to find the CPU
info.  This should also allow for some cleanup of the code added by the
"Minimize per_cpu reservations".  This patch just fixes the regressions, the
cleanup will come in a later patch.


Signed-off-by: Doug Chapman <doug.chapman@hp.com>
Signed-off-by: Alex Chiang <achiang@hp.com>
CC: Robin Holt <holt@sgi.com>

---

diff --git a/arch/ia64/kernel/acpi.c b/arch/ia64/kernel/acpi.c
index 0635015..bd7acc7 100644
--- a/arch/ia64/kernel/acpi.c
+++ b/arch/ia64/kernel/acpi.c
@@ -678,6 +678,30 @@ static int __init acpi_parse_fadt(struct acpi_table_header *table)
 	return 0;
 }
 
+int __init early_acpi_boot_init(void)
+{
+	int ret;
+
+	/*
+	 * do a partial walk of MADT to determine how many CPUs
+	 * we have including offline CPUs
+	 */
+	if (acpi_table_parse(ACPI_SIG_MADT, acpi_parse_madt)) {
+		printk(KERN_ERR PREFIX "Can't find MADT\n");
+		return 0;
+	}
+
+	ret = acpi_table_parse_madt(ACPI_MADT_TYPE_LOCAL_SAPIC,
+		acpi_parse_lsapic, NR_CPUS);
+	if (ret < 1)
+		printk(KERN_ERR PREFIX
+		       "Error parsing MADT - no LAPIC entries\n");
+
+	return 0;
+}
+
+
+
 int __init acpi_boot_init(void)
 {
 
@@ -701,11 +725,6 @@ int __init acpi_boot_init(void)
 		printk(KERN_ERR PREFIX
 		       "Error parsing LAPIC address override entry\n");
 
-	if (acpi_table_parse_madt(ACPI_MADT_TYPE_LOCAL_SAPIC, acpi_parse_lsapic, NR_CPUS)
-	    < 1)
-		printk(KERN_ERR PREFIX
-		       "Error parsing MADT - no LAPIC entries\n");
-
 	if (acpi_table_parse_madt(ACPI_MADT_TYPE_LOCAL_APIC_NMI, acpi_parse_lapic_nmi, 0)
 	    < 0)
 		printk(KERN_ERR PREFIX "Error parsing LAPIC NMI entry\n");
diff --git a/arch/ia64/kernel/setup.c b/arch/ia64/kernel/setup.c
index ae79117..bf441f4 100644
--- a/arch/ia64/kernel/setup.c
+++ b/arch/ia64/kernel/setup.c
@@ -561,8 +561,12 @@ setup_arch (char **cmdline_p)
 #ifdef CONFIG_ACPI
 	/* Initialize the ACPI boot-time table parser */
 	acpi_table_init();
+	early_acpi_boot_init();
 # ifdef CONFIG_ACPI_NUMA
 	acpi_numa_init();
+#ifdef CONFIG_ACPI_HOTPLUG_CPU
+	prefill_possible_map();
+#endif
 	per_cpu_scan_finalize((cpus_weight(early_cpu_possible_map) = 0 ?
 		32 : cpus_weight(early_cpu_possible_map)),
 		additional_cpus > 0 ? additional_cpus : 0);
@@ -853,9 +857,6 @@ void __init
 setup_per_cpu_areas (void)
 {
 	/* start_kernel() requires this... */
-#ifdef CONFIG_ACPI_HOTPLUG_CPU
-	prefill_possible_map();
-#endif
 }
 
 /*


