From: holt@sgi.com
Date: Mon, 17 Mar 2008 12:12:42 +0000
Subject: [Patch 2/3] Minimize per_cpu reservations.
Message-Id: <20080317121240.971569665@attica.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080213175520.520765195@attica.americas.sgi.com>
In-Reply-To: <20080213175520.520765195@attica.americas.sgi.com>
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
=================================--- per_cpu_mca_v1.orig/arch/ia64/kernel/setup.c	2008-02-21 15:05:45.604001274 -0600
+++ per_cpu_mca_v1/arch/ia64/kernel/setup.c	2008-03-17 06:20:52.087121093 -0500
@@ -45,6 +45,7 @@
 #include <linux/cpufreq.h>
 #include <linux/kexec.h>
 #include <linux/crash_dump.h>
+#include <linux/numa.h>
 
 #include <asm/ia32.h>
 #include <asm/machvec.h>
@@ -494,9 +495,12 @@ setup_arch (char **cmdline_p)
 # ifdef CONFIG_ACPI_NUMA
 	acpi_numa_init();
 # endif
+	per_cpu_scan_finalize((cpus_weight(early_cpu_possible_map) = 0 ?
+		32 : cpus_weight(early_cpu_possible_map)), additional_cpus);
 #else
 # ifdef CONFIG_SMP
 	smp_build_cpu_map();	/* happens, e.g., with the Ski simulator */
+	per_cpu_scan_finalize(num_possible_cpus(), additional_cpus);
 # endif
 #endif /* CONFIG_APCI_BOOT */
 
Index: per_cpu_mca_v1/arch/ia64/mm/discontig.c
=================================--- per_cpu_mca_v1.orig/arch/ia64/mm/discontig.c	2008-03-17 06:13:04.988923197 -0500
+++ per_cpu_mca_v1/arch/ia64/mm/discontig.c	2008-03-17 07:02:33.085979563 -0500
@@ -59,6 +59,8 @@ pg_data_t *pgdat_list[MAX_NUMNODES];
 	((((addr) + 1024*1024-1) & ~(1024*1024-1)) + 				\
 	     (((node)*PERCPU_PAGE_SIZE) & (MAX_NODE_ALIGN_OFFSET - 1)))
 
+cpumask_t early_cpu_possible_map = CPU_MASK_NONE;
+
 /**
  * build_node_maps - callback to setup bootmem structs for each node
  * @start: physical start of range
@@ -104,7 +106,7 @@ static int __meminit early_nr_cpus_node(
 {
 	int cpu, n = 0;
 
-	for (cpu = 0; cpu < NR_CPUS; cpu++)
+	for_each_possible_early_cpu(cpu)
 		if (node = node_cpuid[cpu].nid)
 			n++;
 
@@ -143,7 +145,7 @@ static void *per_cpu_node_setup(void *cp
 #ifdef CONFIG_SMP
 	int cpu;
 
-	for (cpu = 0; cpu < NR_CPUS; cpu++) {
+	for_each_possible_early_cpu(cpu) {
 		if (node = node_cpuid[cpu].nid) {
 			memcpy(__va(cpu_data), __phys_per_cpu_start,
 			       __per_cpu_end - __per_cpu_start);
@@ -346,7 +348,7 @@ static void __init initialize_pernode_da
 
 #ifdef CONFIG_SMP
 	/* Set the node_data pointer for each per-cpu struct */
-	for (cpu = 0; cpu < NR_CPUS; cpu++) {
+	for_each_possible_early_cpu(cpu) {
 		node = node_cpuid[cpu].nid;
 		per_cpu(cpu_info, cpu).node_data = mem_data[node].node_data;
 	}
@@ -494,13 +496,9 @@ void __cpuinit *per_cpu_init(void)
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
=================================--- per_cpu_mca_v1.orig/arch/ia64/kernel/acpi.c	2008-02-21 15:05:45.604001274 -0600
+++ per_cpu_mca_v1/arch/ia64/kernel/acpi.c	2008-03-17 06:13:05.100937156 -0500
@@ -482,6 +482,7 @@ acpi_numa_processor_affinity_init(struct
 	    (pa->apic_id << 8) | (pa->local_sapic_eid);
 	/* nid should be overridden as logical node id later */
 	node_cpuid[srat_num_cpus].nid = pxm;
+	cpu_set(srat_num_cpus, early_cpu_possible_map);
 	srat_num_cpus++;
 }
 
@@ -559,7 +560,7 @@ void __init acpi_numa_arch_fixup(void)
 	}
 
 	/* set logical node id in cpu structure */
-	for (i = 0; i < srat_num_cpus; i++)
+	for_each_possible_early_cpu(i)
 		node_cpuid[i].nid = pxm_to_node(node_cpuid[i].nid);
 
 	printk(KERN_INFO "Number of logical nodes in system = %d\n",
Index: per_cpu_mca_v1/arch/ia64/kernel/numa.c
=================================--- per_cpu_mca_v1.orig/arch/ia64/kernel/numa.c	2008-02-21 15:05:45.604001274 -0600
+++ per_cpu_mca_v1/arch/ia64/kernel/numa.c	2008-03-17 06:13:05.128940646 -0500
@@ -73,7 +73,7 @@ void __init build_cpu_to_node_map(void)
 	for(node=0; node < MAX_NUMNODES; node++)
 		cpus_clear(node_to_cpu_mask[node]);
 
-	for(cpu = 0; cpu < NR_CPUS; ++cpu) {
+	for_each_possible_early_cpu(cpu) {
 		node = -1;
 		for (i = 0; i < NR_CPUS; ++i)
 			if (cpu_physical_id(cpu) = node_cpuid[i].phys_id) {
Index: per_cpu_mca_v1/include/asm-ia64/acpi.h
=================================--- per_cpu_mca_v1.orig/include/asm-ia64/acpi.h	2008-02-21 15:05:45.604001274 -0600
+++ per_cpu_mca_v1/include/asm-ia64/acpi.h	2008-03-17 06:13:05.168945632 -0500
@@ -115,7 +115,11 @@ extern unsigned int is_cpu_cpei_target(u
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
Index: per_cpu_mca_v1/include/asm-ia64/numa.h
=================================--- per_cpu_mca_v1.orig/include/asm-ia64/numa.h	2008-02-21 15:05:45.604001274 -0600
+++ per_cpu_mca_v1/include/asm-ia64/numa.h	2008-03-17 07:03:06.490137152 -0500
@@ -11,6 +11,9 @@
 #ifndef _ASM_IA64_NUMA_H
 #define _ASM_IA64_NUMA_H
 
+extern cpumask_t early_cpu_possible_map;
+#define for_each_possible_early_cpu(cpu)  \
+	for_each_cpu_mask((cpu), early_cpu_possible_map)
 
 #ifdef CONFIG_NUMA
 
@@ -22,6 +25,8 @@
 
 #include <asm/mmzone.h>
 
+#define NUMA_NO_NODE	-1
+
 extern u16 cpu_to_node_map[NR_CPUS] __cacheline_aligned;
 extern cpumask_t node_to_cpu_mask[MAX_NUMNODES] __cacheline_aligned;
 extern pg_data_t *pgdat_list[MAX_NUMNODES];
@@ -68,13 +73,40 @@ extern int paddr_to_nid(unsigned long pa
 extern void map_cpu_to_node(int cpu, int nid);
 extern void unmap_cpu_from_node(int cpu, int nid);
 
-
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
 #else /* !CONFIG_NUMA */
 #define map_cpu_to_node(cpu, nid)	do{}while(0)
 #define unmap_cpu_from_node(cpu, nid)	do{}while(0)
 
 #define paddr_to_nid(addr)	0
 
+static inline void per_cpu_scan_finalize(int min_cpus, int reserve_cpus)
+{
+	int cpu;
+
+	for(cpu = 0; cpu < (min_cpus + reserve_cpus); cpu++)
+		cpu_set(cpu, early_cpu_possible_map);
+}
 #endif /* CONFIG_NUMA */
 
 #endif /* _ASM_IA64_NUMA_H */
Index: per_cpu_mca_v1/arch/ia64/mm/numa.c
=================================--- per_cpu_mca_v1.orig/arch/ia64/mm/numa.c	2008-02-21 15:05:45.604001274 -0600
+++ per_cpu_mca_v1/arch/ia64/mm/numa.c	2008-03-17 06:36:37.492711911 -0500
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
Index: per_cpu_mca_v1/arch/ia64/mm/contig.c
=================================--- per_cpu_mca_v1.orig/arch/ia64/mm/contig.c	2008-03-17 06:52:50.000000000 -0500
+++ per_cpu_mca_v1/arch/ia64/mm/contig.c	2008-03-17 07:02:33.085979563 -0500
@@ -30,6 +30,8 @@
 static unsigned long max_gap;
 #endif
 
+cpumask_t early_cpu_possible_map = CPU_MASK_NONE;
+
 /**
  * show_mem - give short summary of memory stats
  *

-- 
