From: holt@sgi.com
Date: Thu, 03 Apr 2008 20:17:13 +0000
Subject: [Patch 2/2] Minimize per_cpu reservations.
Message-Id: <20080403201711.942400353@attica.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


This attached patch significantly shrinks boot memory allocation on ia64.
It does this by not allocating per_cpu areas for cpus that can never
exist.

In the case where acpi does not have any numa node description of the
cpus, I defaulted to assigning the first 32 round-robin on the known
nodes..  For the !CONFIG_ACPI  I used for_each_possible_cpu().


Signed-off-by: Robin Holt <holt@sgi.com>

---

I tested all the different config options.  allyesconfig fails with
or without this patch so that was the one exception.  Otherwise,
allnoconfig, allmodconfig, deconfig, and configs/* all compiled.
Additionally, I booted the sn2- and defconfig both on altix and the
defconfig on a zx2000 with 2 cpus.  I would like it if somebody with
access to a simulator could build and boot this.  That is a different
code path which I have no means of checking.

Version 9:

Refactored so the early_cpu_possible_map is only used when
CONFIG_ACPI_NUMA.

Version 8:

Make the early_cpu_possible_map available for both contig.c and
discontig.c cases.  The contig.c case will be used for allocating the
mca stacks by a later patch.

Version 7:

Fixed up after the compute_pernodesize patch changed lines this
patch was anchored to.  Also fixed an extra cpu reservation that
was unintended.

Version 6:

I fixed up the build failure for the CONFIG_FLATMEM cases.

Version 5:

I went too quickly.  Shortly after I sent the last email, I got a reply
from HP saying 16 was their largest non-numa box.  I will therefore go
back to the 32 Tony and I discussed last Friday.

Version 4:

Changed the reservation of additional per_cpu space to round-robin on
the known nodes.

Cleaned up a copy other loops to use for_each_possible_early_cpu().

Changed the default number of cpus to 256 and also changed the lower
threshold to only apply when no early boot cpus are found.  This change
was prompted by an note from HP that they support 256 cpus.  They did
mention this is on a NUMA box, but I have not currently received a reply
as to whether the cpu locations are described in the ACPI tables.

Version 3:

I reworked this patch to use a cpumask to track the cpus we have seen.
It still initializes the .nid to NUMA_NO_NODE (-1).  The introcution of
a bitmask makes the scans much cleaner.

This patch could be using the cpu_possible_map instead of our own.
I was reluctant to do that, but there is nothing that prevents it.
Does anybody have an opinion?


Version 2 fixed a port bug.  It also introduces NUMA_NO_NODE for ia64.
This is a direct copy from x86.

One comment I have received is the hard-coded 4 described above should
probably be 8 or 16 to handle larger non-NUMA machines.  I originally
set it to 4 because my recollection was that, at most, you could have
four processors per FSB, but maybe that is just an SGI limitation.

How should this be set?  Should I be using a PAL call? processor model?
Limit by current FSB spec and adjust as new processors come along?


Using a patched SuSE SLES10 kernel with both the mca patch that Jack/Russ
submitted a couple days ago and the attached.

On a 2 cpu, 6GB system, NR_CPUS@96:
Before the patch:
Memory: 5687728k/6234784k available (5777k code, 579632k reserved, 10450k data,
672k init)
After both patches:
Memory: 6211984k/6235040k available (5552k code, 55376k reserved, 10418k data, 656k init)
90% savings on reserved.

On a 1 cpu, 1GB system, NR_CPUS@96 before 572,464K, after 37,456k for
a 93% savings.


Index: per_cpu_mca_v1/arch/ia64/kernel/setup.c
=================================--- per_cpu_mca_v1.orig/arch/ia64/kernel/setup.c	2008-03-19 14:53:30.166445469 -0500
+++ per_cpu_mca_v1/arch/ia64/kernel/setup.c	2008-03-19 15:00:59.594492851 -0500
@@ -493,6 +493,8 @@ setup_arch (char **cmdline_p)
 	acpi_table_init();
 # ifdef CONFIG_ACPI_NUMA
 	acpi_numa_init();
+	per_cpu_scan_finalize((cpus_weight(early_cpu_possible_map) = 0 ?
+		32 : cpus_weight(early_cpu_possible_map)), additional_cpus);
 # endif
 #else
 # ifdef CONFIG_SMP
Index: per_cpu_mca_v1/arch/ia64/mm/discontig.c
=================================--- per_cpu_mca_v1.orig/arch/ia64/mm/discontig.c	2008-03-19 15:00:57.522234487 -0500
+++ per_cpu_mca_v1/arch/ia64/mm/discontig.c	2008-03-19 15:00:59.606494347 -0500
@@ -104,7 +104,7 @@ static int __meminit early_nr_cpus_node(
 {
 	int cpu, n = 0;
 
-	for (cpu = 0; cpu < NR_CPUS; cpu++)
+	for_each_possible_early_cpu(cpu)
 		if (node = node_cpuid[cpu].nid)
 			n++;
 
@@ -143,7 +143,7 @@ static void *per_cpu_node_setup(void *cp
 #ifdef CONFIG_SMP
 	int cpu;
 
-	for (cpu = 0; cpu < NR_CPUS; cpu++) {
+	for_each_possible_early_cpu(cpu) {
 		if (node = node_cpuid[cpu].nid) {
 			memcpy(__va(cpu_data), __phys_per_cpu_start,
 			       __per_cpu_end - __per_cpu_start);
@@ -346,7 +346,7 @@ static void __init initialize_pernode_da
 
 #ifdef CONFIG_SMP
 	/* Set the node_data pointer for each per-cpu struct */
-	for (cpu = 0; cpu < NR_CPUS; cpu++) {
+	for_each_possible_early_cpu(cpu) {
 		node = node_cpuid[cpu].nid;
 		per_cpu(cpu_info, cpu).node_data = mem_data[node].node_data;
 	}
@@ -494,13 +494,9 @@ void __cpuinit *per_cpu_init(void)
 	int cpu;
 	static int first_time = 1;
 
-
-	if (smp_processor_id() != 0)
-		return __per_cpu_start + __per_cpu_offset[smp_processor_id()];
-
 	if (first_time) {
 		first_time = 0;
-		for (cpu = 0; cpu < NR_CPUS; cpu++)
+		for_each_possible_early_cpu(cpu)
 			per_cpu(local_per_cpu_offset, cpu) = __per_cpu_offset[cpu];
 	}
 
Index: per_cpu_mca_v1/arch/ia64/kernel/acpi.c
=================================--- per_cpu_mca_v1.orig/arch/ia64/kernel/acpi.c	2008-03-19 14:53:30.166445469 -0500
+++ per_cpu_mca_v1/arch/ia64/kernel/acpi.c	2008-03-19 15:00:59.630497340 -0500
@@ -423,6 +423,7 @@ static u32 __devinitdata pxm_flag[PXM_FL
 #define pxm_bit_set(bit)	(set_bit(bit,(void *)pxm_flag))
 #define pxm_bit_test(bit)	(test_bit(bit,(void *)pxm_flag))
 static struct acpi_table_slit __initdata *slit_table;
+cpumask_t early_cpu_possible_map = CPU_MASK_NONE;
 
 static int get_processor_proximity_domain(struct acpi_srat_cpu_affinity *pa)
 {
@@ -482,6 +483,7 @@ acpi_numa_processor_affinity_init(struct
 	    (pa->apic_id << 8) | (pa->local_sapic_eid);
 	/* nid should be overridden as logical node id later */
 	node_cpuid[srat_num_cpus].nid = pxm;
+	cpu_set(srat_num_cpus, early_cpu_possible_map);
 	srat_num_cpus++;
 }
 
@@ -559,7 +561,7 @@ void __init acpi_numa_arch_fixup(void)
 	}
 
 	/* set logical node id in cpu structure */
-	for (i = 0; i < srat_num_cpus; i++)
+	for_each_possible_early_cpu(i)
 		node_cpuid[i].nid = pxm_to_node(node_cpuid[i].nid);
 
 	printk(KERN_INFO "Number of logical nodes in system = %d\n",
Index: per_cpu_mca_v1/arch/ia64/kernel/numa.c
=================================--- per_cpu_mca_v1.orig/arch/ia64/kernel/numa.c	2008-03-19 14:53:30.166445469 -0500
+++ per_cpu_mca_v1/arch/ia64/kernel/numa.c	2008-03-19 15:00:59.646499335 -0500
@@ -73,7 +73,7 @@ void __init build_cpu_to_node_map(void)
 	for(node=0; node < MAX_NUMNODES; node++)
 		cpus_clear(node_to_cpu_mask[node]);
 
-	for(cpu = 0; cpu < NR_CPUS; ++cpu) {
+	for_each_possible_early_cpu(cpu) {
 		node = -1;
 		for (i = 0; i < NR_CPUS; ++i)
 			if (cpu_physical_id(cpu) = node_cpuid[i].phys_id) {
Index: per_cpu_mca_v1/include/asm-ia64/acpi.h
=================================--- per_cpu_mca_v1.orig/include/asm-ia64/acpi.h	2008-03-19 14:53:30.170445968 -0500
+++ per_cpu_mca_v1/include/asm-ia64/acpi.h	2008-03-19 15:00:59.666501829 -0500
@@ -35,6 +35,7 @@
 #include <linux/init.h>
 #include <linux/numa.h>
 #include <asm/system.h>
+#include <asm/numa.h>
 
 #define COMPILER_DEPENDENT_INT64	long
 #define COMPILER_DEPENDENT_UINT64	unsigned long
@@ -115,7 +116,11 @@ extern unsigned int is_cpu_cpei_target(u
 extern void set_cpei_target_cpu(unsigned int cpu);
 extern unsigned int get_cpei_target_cpu(void);
 extern void prefill_possible_map(void);
+#ifdef CONFIG_ACPI_HOTPLUG_CPU
 extern int additional_cpus;
+#else
+#define additional_cpus 0
+#endif
 
 #ifdef CONFIG_ACPI_NUMA
 #if MAX_NUMNODES > 256
@@ -129,6 +134,34 @@ extern int __initdata nid_to_pxm_map[MAX
 
 #define acpi_unlazy_tlb(x)
 
+#ifdef CONFIG_ACPI_NUMA
+extern cpumask_t early_cpu_possible_map;
+#define for_each_possible_early_cpu(cpu)  \
+	for_each_cpu_mask((cpu), early_cpu_possible_map)
+
+static inline void per_cpu_scan_finalize(int min_cpus, int reserve_cpus)
+{
+	int low_cpu, high_cpu;
+	int cpu;
+	int next_nid = 0;
+
+	low_cpu = cpus_weight(early_cpu_possible_map);
+
+	high_cpu = max(low_cpu, min_cpus);
+	high_cpu = min(high_cpu + reserve_cpus, NR_CPUS);
+
+	for (cpu = low_cpu; cpu < high_cpu; cpu++) {
+		cpu_set(cpu, early_cpu_possible_map);
+		if (node_cpuid[cpu].nid = NUMA_NO_NODE) {
+			node_cpuid[cpu].nid = next_nid;
+			next_nid++;
+			if (next_nid >= num_online_nodes())
+				next_nid = 0;
+		}
+	}
+}
+#endif /* CONFIG_ACPI_NUMA */
+
 #endif /*__KERNEL__*/
 
 #endif /*_ASM_ACPI_H*/
Index: per_cpu_mca_v1/include/asm-ia64/numa.h
=================================--- per_cpu_mca_v1.orig/include/asm-ia64/numa.h	2008-03-19 14:53:30.170445968 -0500
+++ per_cpu_mca_v1/include/asm-ia64/numa.h	2008-03-19 15:00:59.682503824 -0500
@@ -22,6 +22,8 @@
 
 #include <asm/mmzone.h>
 
+#define NUMA_NO_NODE	-1
+
 extern u16 cpu_to_node_map[NR_CPUS] __cacheline_aligned;
 extern cpumask_t node_to_cpu_mask[MAX_NUMNODES] __cacheline_aligned;
 extern pg_data_t *pgdat_list[MAX_NUMNODES];
Index: per_cpu_mca_v1/arch/ia64/mm/numa.c
=================================--- per_cpu_mca_v1.orig/arch/ia64/mm/numa.c	2008-03-19 14:53:30.170445968 -0500
+++ per_cpu_mca_v1/arch/ia64/mm/numa.c	2008-03-19 15:00:59.706506817 -0500
@@ -27,7 +27,9 @@
  */
 int num_node_memblks;
 struct node_memblk_s node_memblk[NR_NODE_MEMBLKS];
-struct node_cpuid_s node_cpuid[NR_CPUS];
+struct node_cpuid_s node_cpuid[NR_CPUS] +	{ [0 ... NR_CPUS-1] = { .phys_id = 0, .nid = NUMA_NO_NODE } };
+
 /*
  * This is a matrix with "distances" between nodes, they should be
  * proportional to the memory access latency ratios.

-- 
