From: Ashok Raj <ashok.raj@intel.com>
Date: Tue, 14 Feb 2006 23:01:12 +0000
Subject: [patch 2/2] Count disabled cpus as potential hot-pluggable CPUs
Message-Id: <20060214230622.472226988@csdlinux-2.jf.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Have a facility to account for potentially hot-pluggable CPUs. ACPI doesnt
give a determinstic method to find hot-pluggable CPUs. Hence we use 2 methods
to assist.

- BIOS can mark potentially hot-pluggable CPUs as disabled in the MADT tables.
- User can specify the number of hot-pluggable CPUs via parameter
  additional_cpus=X

The option is enabled only if ACPI_CONFIG_HOTPLUG_CPU=y which enables the
physical hotplug option. Without which user can still use logical onlining 
and offlining of CPUs by enabling CONFIG_HOTPLUG_CPU=y

Adds more bits to cpu_possible_map for potentially hot-pluggable cpus.

Signed-off-by: Ashok Raj <ashok.raj@intel.com>
------------------------------------------------------
 arch/ia64/kernel/acpi.c  |   56 +++++++++++++++++++++++++++++++++++++++++++++++
 arch/ia64/kernel/setup.c |    4 +++
 include/asm-ia64/acpi.h  |    2 +
 3 files changed, 62 insertions(+)

Index: linux-2.6.16-rc3-mm1/arch/ia64/kernel/acpi.c
=================================--- linux-2.6.16-rc3-mm1.orig/arch/ia64/kernel/acpi.c
+++ linux-2.6.16-rc3-mm1/arch/ia64/kernel/acpi.c
@@ -760,6 +760,62 @@ int acpi_map_cpu2node(acpi_handle handle
 	return (0);
 }
 
+int additional_cpus __initdata = -1;
+
+static __init int setup_additional_cpus(char *s)
+{
+	if (s)
+		additional_cpus = simple_strtol(s, NULL, 0);
+
+	return 0;
+}
+
+early_param("additional_cpus", setup_additional_cpus);
+
+/*
+ * cpu_possible_map should be static, it cannot change as cpu's
+ * are onlined, or offlined. The reason is per-cpu data-structures
+ * are allocated by some modules at init time, and dont expect to
+ * do this dynamically on cpu arrival/departure.
+ * cpu_present_map on the other hand can change dynamically.
+ * In case when cpu_hotplug is not compiled, then we resort to current
+ * behaviour, which is cpu_possible = cpu_present.
+ * - Ashok Raj
+ *
+ * Three ways to find out the number of additional hotplug CPUs:
+ * - If the BIOS specified disabled CPUs in ACPI/mptables use that.
+ * - The user can overwrite it with additional_cpus=NUM
+ * - Otherwise don't reserve additional CPUs.
+ */
+__init void prefill_possible_map(void)
+{
+	int i;
+	int possible, disabled_cpus;
+
+	disabled_cpus = total_cpus - available_cpus;
+ 	if (additional_cpus = -1) {
+ 		if (disabled_cpus > 0) {
+ 			possible = total_cpus;
+			additional_cpus = disabled_cpus;
+		}
+ 		else {
+			possible = available_cpus;
+			additional_cpus = 0;
+		}
+ 	} else {
+		possible = available_cpus + additional_cpus;
+	}
+	if (possible > NR_CPUS)
+		possible = NR_CPUS;
+
+	printk(KERN_INFO "SMP: Allowing %d CPUs, %d hotplug CPUs\n",
+		possible,
+	        max_t(int, additional_cpus, 0));
+
+	for (i = 0; i < possible; i++)
+		cpu_set(i, cpu_possible_map);
+}
+
 int acpi_map_lsapic(acpi_handle handle, int *pcpu)
 {
 	struct acpi_buffer buffer = { ACPI_ALLOCATE_BUFFER, NULL };
Index: linux-2.6.16-rc3-mm1/include/asm-ia64/acpi.h
=================================--- linux-2.6.16-rc3-mm1.orig/include/asm-ia64/acpi.h
+++ linux-2.6.16-rc3-mm1/include/asm-ia64/acpi.h
@@ -106,6 +106,8 @@ extern unsigned int can_cpei_retarget(vo
 extern unsigned int is_cpu_cpei_target(unsigned int cpu);
 extern void set_cpei_target_cpu(unsigned int cpu);
 extern unsigned int get_cpei_target_cpu(void);
+extern void prefill_possible_map(void);
+extern int additional_cpus;
 
 extern u16 ia64_acpiid_to_sapicid[];
 
Index: linux-2.6.16-rc3-mm1/arch/ia64/kernel/setup.c
=================================--- linux-2.6.16-rc3-mm1.orig/arch/ia64/kernel/setup.c
+++ linux-2.6.16-rc3-mm1/arch/ia64/kernel/setup.c
@@ -430,6 +430,7 @@ setup_arch (char **cmdline_p)
 	if (early_console_setup(*cmdline_p) = 0)
 		mark_bsp_online();
 
+	parse_early_param();
 #ifdef CONFIG_ACPI
 	/* Initialize the ACPI boot-time table parser */
 	acpi_table_init();
@@ -688,6 +689,9 @@ void
 setup_per_cpu_areas (void)
 {
 	/* start_kernel() requires this... */
+#ifdef CONFIG_ACPI_HOTPLUG_CPU
+	prefill_possible_map();
+#endif
 }
 
 /*

--

