From: Robin Holt <holt@sgi.com>
Date: Thu, 07 Feb 2008 23:59:49 +0000
Subject: [RFC] Reduce per_cpu allocations to minimum needed for boot.
Message-Id: <20080207235949.GB26564@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The attached patch significantly shrinks boot memory allocation on ia64.
It does this by not allocating per_cpu areas for cpus that can never
exist.

In the case where acpi does not have any numa node description of
the cpus, I defaulted to assigning the first 4 to node 0.  For the
!CONFIG_ACPI  I used for_each_possible_cpu().

Signed-off-by: Robin Holt <holt@sgi.com>

---

Using a patched SuSE SLES10 kernel with both the mca patch that Jack/Russ
submitted a couple days ago and the attached.

On a HP box with 2 cpu, 6GB system, NR_CPUS@96:
Before the patch:
Memory: 5687728k/6234784k available (5777k code, 579632k reserved, 10450k data, 672k init)
After both patches:
Memory: 6211984k/6235040k available (5552k code, 55376k reserved, 10418k data, 656k init)
90% savings on reserved.

On a HP box with 1 cpu, 1GB system, NR_CPUS@96 before 572,464K, after 37,456k for a 93% savings.


Index: per_cpu/arch/ia64/kernel/setup.c
=================================--- per_cpu.orig/arch/ia64/kernel/setup.c	2008-02-07 17:27:44.000000000 -0600
+++ per_cpu/arch/ia64/kernel/setup.c	2008-02-07 17:46:43.000000000 -0600
@@ -45,6 +45,7 @@
 #include <linux/cpufreq.h>
 #include <linux/kexec.h>
 #include <linux/crash_dump.h>
+#include <linux/numa.h>
 
 #include <asm/ia32.h>
 #include <asm/machvec.h>
@@ -466,6 +467,8 @@ int __init reserve_elfcorehdr(unsigned l
 void __init
 setup_arch (char **cmdline_p)
 {
+	int i;
+
 	unw_init();
 
 	ia64_patch_vtop((u64) __start___vtop_patchlist, (u64) __end___vtop_patchlist);
@@ -490,15 +493,25 @@ setup_arch (char **cmdline_p)
 	if (early_console_setup(*cmdline_p) = 0)
 		mark_bsp_online();
 
+
+	for (i=0; i<NR_CPUS; i++)
+		node_cpuid[i].nid = -1;
 #ifdef CONFIG_ACPI
 	/* Initialize the ACPI boot-time table parser */
 	acpi_table_init();
 # ifdef CONFIG_ACPI_NUMA
 	acpi_numa_init();
 # endif
+	if (node_cpuid[0].nid = -1) {
+		/* acpi found no cpus in the numa tables.  Assume 4 */
+		for (i=0; i<4; i++)
+			node_cpuid[i].nid = 0;
+	}
 #else
 # ifdef CONFIG_SMP
 	smp_build_cpu_map();	/* happens, e.g., with the Ski simulator */
+	for_each_possible_cpu(i)
+		node_cpuid[i].nid = 0;
 # endif
 #endif /* CONFIG_APCI_BOOT */
 
Index: per_cpu/arch/ia64/mm/discontig.c
=================================--- per_cpu.orig/arch/ia64/mm/discontig.c	2008-02-07 17:27:44.000000000 -0600
+++ per_cpu/arch/ia64/mm/discontig.c	2008-02-07 17:50:52.000000000 -0600
@@ -22,6 +22,7 @@
 #include <linux/acpi.h>
 #include <linux/efi.h>
 #include <linux/nodemask.h>
+#include <linux/smp.h>
 #include <asm/pgalloc.h>
 #include <asm/tlb.h>
 #include <asm/meminit.h>
@@ -143,6 +144,8 @@ static void *per_cpu_node_setup(void *cp
 	int cpu;
 
 	for (cpu = 0; cpu < NR_CPUS; cpu++) {
+		if (node_cpuid[cpu].nid = -1)
+			continue;
 		if (node = node_cpuid[cpu].nid) {
 			memcpy(__va(cpu_data), __phys_per_cpu_start,
 			       __per_cpu_end - __per_cpu_start);
@@ -346,6 +349,8 @@ static void __init initialize_pernode_da
 #ifdef CONFIG_SMP
 	/* Set the node_data pointer for each per-cpu struct */
 	for (cpu = 0; cpu < NR_CPUS; cpu++) {
+		if (node_cpuid[cpu].nid = -1)
+			continue;
 		node = node_cpuid[cpu].nid;
 		per_cpu(cpu_info, cpu).node_data = mem_data[node].node_data;
 	}
@@ -499,8 +504,11 @@ void __cpuinit *per_cpu_init(void)
 
 	if (first_time) {
 		first_time = 0;
-		for (cpu = 0; cpu < NR_CPUS; cpu++)
+		for (cpu = 0; cpu < NR_CPUS; cpu++) {
+			if (node_cpuid[cpu].nid = -1)
+				continue;
 			per_cpu(local_per_cpu_offset, cpu) = __per_cpu_offset[cpu];
+		}
 	}
 
 	return __per_cpu_start + __per_cpu_offset[smp_processor_id()];
Index: per_cpu/arch/ia64/kernel/acpi.c
=================================--- per_cpu.orig/arch/ia64/kernel/acpi.c	2008-02-07 17:27:44.000000000 -0600
+++ per_cpu/arch/ia64/kernel/acpi.c	2008-02-07 17:49:14.000000000 -0600
@@ -545,8 +545,11 @@ void __init acpi_numa_arch_fixup(void)
 	}
 
 	/* set logical node id in cpu structure */
-	for (i = 0; i < srat_num_cpus; i++)
+	for (i = 0; i < srat_num_cpus; i++) {
+		if (node_cpuid[i].nid = -1)
+			continue;
 		node_cpuid[i].nid = pxm_to_node(node_cpuid[i].nid);
+	}
 
 	printk(KERN_INFO "Number of logical nodes in system = %d\n",
 	       num_online_nodes());
Index: per_cpu/arch/ia64/kernel/numa.c
=================================--- per_cpu.orig/arch/ia64/kernel/numa.c	2008-02-07 17:27:44.000000000 -0600
+++ per_cpu/arch/ia64/kernel/numa.c	2008-02-07 17:44:53.000000000 -0600
@@ -74,6 +74,8 @@ void __init build_cpu_to_node_map(void)
 		cpus_clear(node_to_cpu_mask[node]);
 
 	for(cpu = 0; cpu < NR_CPUS; ++cpu) {
+		if (node_cpuid[i].nid = -1)
+			continue;
 		node = -1;
 		for (i = 0; i < NR_CPUS; ++i)
 			if (cpu_physical_id(cpu) = node_cpuid[i].phys_id) {
