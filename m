From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Wed, 01 Sep 2004 18:14:39 +0000
Subject: Re: [PATCH] CONFIG_SMP=n fixes redux
Message-Id: <200409011114.39909.jbarnes@engr.sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_PGhNBLjFQkHWD9B"
List-Id: <linux-ia64.vger.kernel.org>
References: <200408311744.16748.jbarnes@engr.sgi.com>
In-Reply-To: <200408311744.16748.jbarnes@engr.sgi.com>
To: linux-ia64@vger.kernel.org

--Boundary-00=_PGhNBLjFQkHWD9B
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Tuesday, August 31, 2004 5:44 pm, Jesse Barnes wrote:
> Today both Christoph and Alex mentioned that they thought this patch would
> be nice to have in the tree.  It allows a generic kernel to build and run
> when CONFIG_SMP=n.  I'd still like feedback about the per-cpu stuff though,
> in particular, this
>
> +#ifdef CONFIG_SMP
>         /* Set the node_data pointer for each per-cpu struct */
>         for (cpu = 0; cpu < NR_CPUS; cpu++) {
>                 node = node_cpuid[cpu].nid;
>                 per_cpu(cpu_info, cpu).node_data =
> mem_data[node].node_data; }
> +#else
> +       {
> +               struct cpuinfo_ia64 *cpu0_cpu_info;
> +               cpu = 0;
> +               node = node_cpuid[cpu].nid;
> +               cpu0_cpu_info = (struct cpuinfo_ia64
> *)(__phys_per_cpu_start + +                       ((char
> *)&per_cpu__cpu_info - __per_cpu_start)); +              
> cpu0_cpu_info->node_data = mem_data[node].node_data; +       }
> +#endif /* CONFIG_SMP */
>
> is really ugly.  Maybe I should take this opportunity to convert the early
> memory allocation code to using the bootmem allocator instead of
> backdooring it via find_pernode_space()?  I think that would mean we could
> share more code between the contig and discontigmem cases, but we'd also
> have to be careful to avoid cacheline aliasing.

The patch I posted here was incomplete (missing numa.c file).  This new one 
fixes the CONFIG_NUMA=n case too, but has led me to conclude that the whole 
thing is a big mess.  Our CONFIG_* variables aren't named very well and 
there's a lot of confusion between actual NUMA support routines (e.g. smart 
page allocation, distance tables, etc.) and simple memory layout information 
necessary for discontig support on ia64 boxes.

Jesse

--Boundary-00=_PGhNBLjFQkHWD9B
Content-Type: text/plain;
  charset="iso-8859-1";
  name="ia64-generic-config-fixes.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="ia64-generic-config-fixes.patch"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/09/01 11:11:28-07:00 jbarnes@tomahawk.engr.sgi.com 
#   config fixes
# 
# arch/ia64/kernel/numa.c
#   2004/09/01 11:11:18-07:00 jbarnes@tomahawk.engr.sgi.com +57 -0
# 
# include/linux/acpi.h
#   2004/09/01 11:11:18-07:00 jbarnes@tomahawk.engr.sgi.com +4 -0
#   config fixes
# 
# include/asm-ia64/sn/sn_cpuid.h
#   2004/09/01 11:11:18-07:00 jbarnes@tomahawk.engr.sgi.com +0 -4
#   config fixes
# 
# include/asm-ia64/smp.h
#   2004/09/01 11:11:18-07:00 jbarnes@tomahawk.engr.sgi.com +1 -0
#   config fixes
# 
# include/asm-ia64/processor.h
#   2004/09/01 11:11:18-07:00 jbarnes@tomahawk.engr.sgi.com +1 -3
#   config fixes
# 
# include/asm-ia64/numa.h
#   2004/09/01 11:11:18-07:00 jbarnes@tomahawk.engr.sgi.com +1 -8
#   config fixes
# 
# include/asm-ia64/acpi.h
#   2004/09/01 11:11:18-07:00 jbarnes@tomahawk.engr.sgi.com +1 -0
#   config fixes
# 
# drivers/acpi/numa.c
#   2004/09/01 11:11:18-07:00 jbarnes@tomahawk.engr.sgi.com +0 -2
#   config fixes
# 
# drivers/acpi/Kconfig
#   2004/09/01 11:11:18-07:00 jbarnes@tomahawk.engr.sgi.com +0 -1
#   config fixes
# 
# arch/ia64/sn/kernel/setup.c
#   2004/09/01 11:11:18-07:00 jbarnes@tomahawk.engr.sgi.com +1 -0
#   config fixes
# 
# arch/ia64/mm/numa.c
#   2004/09/01 11:11:18-07:00 jbarnes@tomahawk.engr.sgi.com +0 -7
#   config fixes
# 
# arch/ia64/mm/discontig.c
#   2004/09/01 11:11:18-07:00 jbarnes@tomahawk.engr.sgi.com +62 -31
#   config fixes
# 
# arch/ia64/kernel/smpboot.c
#   2004/09/01 11:11:18-07:00 jbarnes@tomahawk.engr.sgi.com +0 -41
#   config fixes
# 
# arch/ia64/kernel/setup.c
#   2004/09/01 11:11:18-07:00 jbarnes@tomahawk.engr.sgi.com +0 -2
#   config fixes
# 
# arch/ia64/kernel/numa.c
#   2004/09/01 11:11:18-07:00 jbarnes@tomahawk.engr.sgi.com +0 -0
#   BitKeeper file /home/jbarnes/working/linux-2.5-numa/arch/ia64/kernel/numa.c
# 
# arch/ia64/kernel/acpi.c
#   2004/09/01 11:11:18-07:00 jbarnes@tomahawk.engr.sgi.com +21 -3
#   config fixes
# 
# arch/ia64/kernel/Makefile
#   2004/09/01 11:11:18-07:00 jbarnes@tomahawk.engr.sgi.com +1 -0
#   config fixes
# 
# arch/ia64/Kconfig
#   2004/09/01 11:11:18-07:00 jbarnes@tomahawk.engr.sgi.com +0 -2
#   config fixes
# 
diff -Nru a/arch/ia64/Kconfig b/arch/ia64/Kconfig
--- a/arch/ia64/Kconfig	2004-09-01 11:12:45 -07:00
+++ b/arch/ia64/Kconfig	2004-09-01 11:12:45 -07:00
@@ -44,8 +44,6 @@
 
 config IA64_GENERIC
 	bool "generic"
-	select NUMA
-	select ACPI_NUMA
 	select VIRTUAL_MEM_MAP
 	select DISCONTIGMEM
 	help
diff -Nru a/arch/ia64/kernel/Makefile b/arch/ia64/kernel/Makefile
--- a/arch/ia64/kernel/Makefile	2004-09-01 11:12:45 -07:00
+++ b/arch/ia64/kernel/Makefile	2004-09-01 11:12:45 -07:00
@@ -15,6 +15,7 @@
 obj-$(CONFIG_IOSAPIC)		+= iosapic.o
 obj-$(CONFIG_MODULES)		+= module.o
 obj-$(CONFIG_SMP)		+= smp.o smpboot.o
+obj-$(CONFIG_NUMA)		+= numa.o
 obj-$(CONFIG_PERFMON)		+= perfmon_default_smpl.o
 obj-$(CONFIG_IA64_CYCLONE)	+= cyclone.o
 
diff -Nru a/arch/ia64/kernel/acpi.c b/arch/ia64/kernel/acpi.c
--- a/arch/ia64/kernel/acpi.c	2004-09-01 11:12:45 -07:00
+++ b/arch/ia64/kernel/acpi.c	2004-09-01 11:12:45 -07:00
@@ -359,6 +359,17 @@
 /* maps to convert between proximity domain and logical node ID */
 int __initdata pxm_to_nid_map[MAX_PXM_DOMAINS];
 int __initdata nid_to_pxm_map[MAX_NUMNODES];
+
+/*
+ * The following structures are usually initialized by ACPI or
+ * similar mechanisms and describe the NUMA characteristics of the machine.
+ */
+int num_node_memblks;
+struct node_memblk_s node_memblk[NR_NODE_MEMBLKS];
+struct node_cpuid_s node_cpuid[NR_CPUS];
+
+#ifdef CONFIG_NUMA
+
 static struct acpi_table_slit __initdata *slit_table;
 
 /*
@@ -380,6 +391,7 @@
 	}
 	slit_table = slit;
 }
+#endif
 
 void __init
 acpi_numa_processor_affinity_init (struct acpi_table_processor_affinity *pa)
@@ -434,7 +446,10 @@
 void __init
 acpi_numa_arch_fixup (void)
 {
-	int i, j, node_from, node_to;
+	int i, j;
+#ifdef CONFIG_NUMA
+	int node_from, node_to;
+#endif
 
 	/* If there's no SRAT, fix the phys_id */
 	if (srat_num_cpus == 0) {
@@ -475,7 +490,7 @@
 
 	printk(KERN_INFO "Number of logical nodes in system = %d\n", numnodes);
 	printk(KERN_INFO "Number of memory chunks in system = %d\n", num_node_memblks);
-
+#ifdef CONFIG_NUMA
 	if (!slit_table) return;
 	memset(numa_slit, -1, sizeof(numa_slit));
 	for (i=0; i<slit_table->localities; i++) {
@@ -490,6 +505,7 @@
 				slit_table->entry[i*slit_table->localities + j];
 		}
 	}
+#endif
 
 #ifdef SLIT_DEBUG
 	printk("ACPI 2.0 SLIT locality table:\n");
@@ -624,8 +640,10 @@
 			if (smp_boot_data.cpu_phys_id[cpu] != hard_smp_processor_id())
 				node_cpuid[i++].phys_id = smp_boot_data.cpu_phys_id[cpu];
 	}
-	build_cpu_to_node_map();
 # endif
+#endif
+#ifdef CONFIG_NUMA
+	build_cpu_to_node_map();
 #endif
 	/* Make boot-up look pretty */
 	printk(KERN_INFO "%d CPUs available, %d CPUs total\n", available_cpus, total_cpus);
diff -Nru a/arch/ia64/kernel/numa.c b/arch/ia64/kernel/numa.c
--- /dev/null	Wed Dec 31 16:00:00 196900
+++ b/arch/ia64/kernel/numa.c	2004-09-01 11:12:45 -07:00
@@ -0,0 +1,57 @@
+/*
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
+ *
+ * ia64 kernel NUMA specific stuff
+ *
+ * Copyright (C) 2002 Erich Focht <efocht@ess.nec.de>
+ * Copyright (C) 2004 Silicon Graphics, Inc.
+ *   Jesse Barnes <jbarnes@sgi.com>
+ */
+#include <linux/config.h>
+#include <linux/topology.h>
+#include <linux/module.h>
+#include <asm/processor.h>
+#include <asm/smp.h>
+
+u8 cpu_to_node_map[NR_CPUS] __cacheline_aligned;
+EXPORT_SYMBOL(cpu_to_node_map);
+
+cpumask_t node_to_cpu_mask[MAX_NUMNODES] __cacheline_aligned;
+
+/**
+ * build_cpu_to_node_map - setup cpu to node and node to cpumask arrays
+ *
+ * Build cpu to node mapping and initialize the per node cpu masks using
+ * info from the node_cpuid array handed to us by ACPI.
+ */
+void __init build_cpu_to_node_map(void)
+{
+	int cpu, i, node;
+
+	for(node=0; node < MAX_NUMNODES; node++)
+		cpus_clear(node_to_cpu_mask[node]);
+
+	for(cpu = 0; cpu < NR_CPUS; ++cpu) {
+		node = -1;
+		for (i = 0; i < NR_CPUS; ++i)
+			if (cpu_physical_id(cpu) == node_cpuid[i].phys_id) {
+				node = node_cpuid[i].nid;
+				break;
+			}
+		cpu_to_node_map[cpu] = (node >= 0) ? node : 0;
+		if (node >= 0)
+			cpu_set(cpu, node_to_cpu_mask[node]);
+	}
+}
diff -Nru a/arch/ia64/kernel/setup.c b/arch/ia64/kernel/setup.c
--- a/arch/ia64/kernel/setup.c	2004-09-01 11:12:45 -07:00
+++ b/arch/ia64/kernel/setup.c	2004-09-01 11:12:45 -07:00
@@ -317,11 +317,9 @@
 	machvec_init(acpi_get_sysname());
 #endif
 
-#ifdef CONFIG_SMP
 	/* If we register an early console, allow CPU 0 to printk */
 	if (!early_console_setup())
 		cpu_set(smp_processor_id(), cpu_online_map);
-#endif
 
 #ifdef CONFIG_ACPI_BOOT
 	/* Initialize the ACPI boot-time table parser */
diff -Nru a/arch/ia64/kernel/smpboot.c b/arch/ia64/kernel/smpboot.c
--- a/arch/ia64/kernel/smpboot.c	2004-09-01 11:12:45 -07:00
+++ b/arch/ia64/kernel/smpboot.c	2004-09-01 11:12:45 -07:00
@@ -478,47 +478,6 @@
 	}
 }
 
-#ifdef CONFIG_NUMA
-
-/* on which node is each logical CPU (one cacheline even for 64 CPUs) */
-u8 cpu_to_node_map[NR_CPUS] __cacheline_aligned;
-EXPORT_SYMBOL(cpu_to_node_map);
-/* which logical CPUs are on which nodes */
-cpumask_t node_to_cpu_mask[MAX_NUMNODES] __cacheline_aligned;
-
-/*
- * Build cpu to node mapping and initialize the per node cpu masks.
- */
-void __init
-build_cpu_to_node_map (void)
-{
-	int cpu, i, node;
-
-	for(node=0; node<MAX_NUMNODES; node++)
-		cpus_clear(node_to_cpu_mask[node]);
-	for(cpu = 0; cpu < NR_CPUS; ++cpu) {
-		/*
-		 * All Itanium NUMA platforms I know use ACPI, so maybe we
-		 * can drop this ifdef completely.                    [EF]
-		 */
-#ifdef CONFIG_ACPI_NUMA
-		node = -1;
-		for (i = 0; i < NR_CPUS; ++i)
-			if (cpu_physical_id(cpu) == node_cpuid[i].phys_id) {
-				node = node_cpuid[i].nid;
-				break;
-			}
-#else
-#		error Fixme: Dunno how to build CPU-to-node map.
-#endif
-		cpu_to_node_map[cpu] = (node >= 0) ? node : 0;
-		if (node >= 0)
-			cpu_set(cpu, node_to_cpu_mask[node]);
-	}
-}
-
-#endif /* CONFIG_NUMA */
-
 /*
  * Cycle through the APs sending Wakeup IPIs to boot each.
  */
diff -Nru a/arch/ia64/mm/discontig.c b/arch/ia64/mm/discontig.c
--- a/arch/ia64/mm/discontig.c	2004-09-01 11:12:45 -07:00
+++ b/arch/ia64/mm/discontig.c	2004-09-01 11:12:45 -07:00
@@ -9,7 +9,7 @@
 /*
  * Platform initialization for Discontig Memory
  */
-
+#include <linux/config.h>
 #include <linux/kernel.h>
 #include <linux/mm.h>
 #include <linux/swap.h>
@@ -40,6 +40,7 @@
 
 static struct early_node_data mem_data[NR_NODES] __initdata;
 
+#ifdef CONFIG_NUMA
 /**
  * reassign_cpu_only_nodes - called from find_memory to move CPU-only nodes to a memory node
  *
@@ -161,13 +162,16 @@
 
 	return;
 }
+#else
+static void __init reassign_cpu_only_nodes(void) { }
+#endif /* CONFIG_NUMA */
 
 /*
  * To prevent cache aliasing effects, align per-node structures so that they
  * start at addresses that are strided by node number.
  */
-#define NODEDATA_ALIGN(addr, node)						\
-	((((addr) + 1024*1024-1) & ~(1024*1024-1)) + (node)*PERCPU_PAGE_SIZE)
+#define NODEDATA_ALIGN(addr, node) ((((addr) + 1024*1024-1) & \
+	~(1024*1024-1)) + (node)*PERCPU_PAGE_SIZE)
 
 /**
  * build_node_maps - callback to setup bootmem structs for each node
@@ -213,7 +217,7 @@
  * acpi_boot_init() (which builds the node_to_cpu_mask array) hasn't been
  * called yet.
  */
-static int early_nr_cpus_node(int node)
+static int __init early_nr_cpus_node(int node)
 {
 	int cpu, n = 0;
 
@@ -225,6 +229,33 @@
 }
 
 /**
+ * per_cpu_node_setup - setup per-cpu areas on each node
+ * @cpu_data: per-cpu area on this node
+ * @node: node to setup
+ *
+ * Copy the static per-cpu data into the region we just set aside and then
+ * setup __per_cpu_offset for each CPU on this node.  Return a pointer to
+ * the end of the area.
+ */
+static void __init *per_cpu_node_setup(void *cpu_data, int node)
+{
+#ifdef CONFIG_SMP
+	int cpu;
+
+	for (cpu = 0; cpu < NR_CPUS; cpu++) {
+		if (node == node_cpuid[cpu].nid) {
+			memcpy(__va(cpu_data), __phys_per_cpu_start,
+			       __per_cpu_end - __per_cpu_start);
+			__per_cpu_offset[cpu] = (char*)__va(cpu_data) -
+				__per_cpu_start;
+			cpu_data += PERCPU_PAGE_SIZE;
+		}
+	}
+#endif
+	return cpu_data;
+}
+
+/**
  * find_pernode_space - allocate memory for memory map and per-node structures
  * @start: physical start of range
  * @len: length of range
@@ -255,7 +286,7 @@
 static int __init find_pernode_space(unsigned long start, unsigned long len,
 				     int node)
 {
-	unsigned long epfn, cpu, cpus;
+	unsigned long epfn, cpus;
 	unsigned long pernodesize = 0, pernode, pages, mapsize;
 	void *cpu_data;
 	struct bootmem_data *bdp = &mem_data[node].bootmem_data;
@@ -305,20 +336,7 @@
 		mem_data[node].pgdat->bdata = bdp;
 		pernode += L1_CACHE_ALIGN(sizeof(pg_data_t));
 
-		/*
-		 * Copy the static per-cpu data into the region we
-		 * just set aside and then setup __per_cpu_offset
-		 * for each CPU on this node.
-		 */
-		for (cpu = 0; cpu < NR_CPUS; cpu++) {
-			if (node == node_cpuid[cpu].nid) {
-				memcpy(__va(cpu_data), __phys_per_cpu_start,
-				       __per_cpu_end - __per_cpu_start);
-				__per_cpu_offset[cpu] = (char*)__va(cpu_data) -
-					__per_cpu_start;
-				cpu_data += PERCPU_PAGE_SIZE;
-			}
-		}
+		cpu_data = per_cpu_node_setup(cpu_data, node);
 	}
 
 	return 0;
@@ -384,8 +402,8 @@
  */
 static void __init initialize_pernode_data(void)
 {
-	int cpu, node;
 	pg_data_t *pgdat_list[NR_NODES];
+	int cpu, node;
 
 	for (node = 0; node < numnodes; node++)
 		pgdat_list[node] = mem_data[node].pgdat;
@@ -395,12 +413,22 @@
 		memcpy(mem_data[node].node_data->pg_data_ptrs, pgdat_list,
 		       sizeof(pgdat_list));
 	}
-
+#ifdef CONFIG_SMP
 	/* Set the node_data pointer for each per-cpu struct */
 	for (cpu = 0; cpu < NR_CPUS; cpu++) {
 		node = node_cpuid[cpu].nid;
 		per_cpu(cpu_info, cpu).node_data = mem_data[node].node_data;
 	}
+#else
+	{
+		struct cpuinfo_ia64 *cpu0_cpu_info;
+		cpu = 0;
+		node = node_cpuid[cpu].nid;
+		cpu0_cpu_info = (struct cpuinfo_ia64 *)(__phys_per_cpu_start +
+			((char *)&per_cpu__cpu_info - __per_cpu_start));
+		cpu0_cpu_info->node_data = mem_data[node].node_data;
+	}
+#endif /* CONFIG_SMP */
 }
 
 /**
@@ -464,25 +492,26 @@
 	find_initrd();
 }
 
+#ifdef CONFIG_SMP
 /**
  * per_cpu_init - setup per-cpu variables
  *
  * find_pernode_space() does most of this already, we just need to set
  * local_per_cpu_offset
  */
-void *per_cpu_init(void)
+void __init *per_cpu_init(void)
 {
 	int cpu;
 
-	if (smp_processor_id() == 0) {
-		for (cpu = 0; cpu < NR_CPUS; cpu++) {
-			per_cpu(local_per_cpu_offset, cpu) =
-				__per_cpu_offset[cpu];
-		}
-	}
+	if (smp_processor_id() != 0)
+		return __per_cpu_start + __per_cpu_offset[smp_processor_id()];
+
+	for (cpu = 0; cpu < NR_CPUS; cpu++)
+		per_cpu(local_per_cpu_offset, cpu) = __per_cpu_offset[cpu];
 
 	return __per_cpu_start + __per_cpu_offset[smp_processor_id()];
 }
+#endif /* CONFIG_SMP */
 
 /**
  * show_mem - give short summary of memory stats
@@ -533,7 +562,8 @@
  * Take this opportunity to round the start address up and the end address
  * down to page boundaries.
  */
-void call_pernode_memory(unsigned long start, unsigned long len, void *arg)
+void __init call_pernode_memory(unsigned long start, unsigned long len,
+				void *arg)
 {
 	unsigned long rs, re, end = start + len;
 	void (*func)(unsigned long, unsigned long, int);
@@ -577,7 +607,8 @@
  * for each piece of usable memory and will setup these values for each node.
  * Very similar to build_maps().
  */
-static int count_node_pages(unsigned long start, unsigned long len, int node)
+static int __init count_node_pages(unsigned long start, unsigned long len,
+				   int node)
 {
 	unsigned long end = start + len;
 
@@ -602,7 +633,7 @@
  * paging_init() sets up the page tables for each node of the system and frees
  * the bootmem allocator memory for general use.
  */
-void paging_init(void)
+void __init paging_init(void)
 {
 	unsigned long max_dma;
 	unsigned long zones_size[MAX_NR_ZONES];
diff -Nru a/arch/ia64/mm/numa.c b/arch/ia64/mm/numa.c
--- a/arch/ia64/mm/numa.c	2004-09-01 11:12:45 -07:00
+++ b/arch/ia64/mm/numa.c	2004-09-01 11:12:45 -07:00
@@ -24,13 +24,6 @@
 static struct cpu *sysfs_cpus;
 
 /*
- * The following structures are usually initialized by ACPI or
- * similar mechanisms and describe the NUMA characteristics of the machine.
- */
-int num_node_memblks;
-struct node_memblk_s node_memblk[NR_NODE_MEMBLKS];
-struct node_cpuid_s node_cpuid[NR_CPUS];
-/*
  * This is a matrix with "distances" between nodes, they should be
  * proportional to the memory access latency ratios.
  */
diff -Nru a/arch/ia64/sn/kernel/setup.c b/arch/ia64/sn/kernel/setup.c
--- a/arch/ia64/sn/kernel/setup.c	2004-09-01 11:12:45 -07:00
+++ b/arch/ia64/sn/kernel/setup.c	2004-09-01 11:12:45 -07:00
@@ -29,6 +29,7 @@
 #include <linux/sched.h>
 #include <linux/root_dev.h>
 
+#include <asm/acpi.h>
 #include <asm/io.h>
 #include <asm/sal.h>
 #include <asm/machvec.h>
diff -Nru a/drivers/acpi/Kconfig b/drivers/acpi/Kconfig
--- a/drivers/acpi/Kconfig	2004-09-01 11:12:45 -07:00
+++ b/drivers/acpi/Kconfig	2004-09-01 11:12:45 -07:00
@@ -142,7 +142,6 @@
 config ACPI_NUMA
 	bool "NUMA support"
 	depends on ACPI_INTERPRETER
-	depends on NUMA
 	depends on IA64
 	default y if IA64_GENERIC || IA64_SGI_SN2
 
diff -Nru a/drivers/acpi/numa.c b/drivers/acpi/numa.c
--- a/drivers/acpi/numa.c	2004-09-01 11:12:45 -07:00
+++ b/drivers/acpi/numa.c	2004-09-01 11:12:45 -07:00
@@ -95,9 +95,7 @@
 	localities = (u32) slit->localities;
 
 	printk(KERN_INFO PREFIX "SLIT localities %ux%u\n", localities, localities);
-
 	acpi_numa_slit_init(slit);
-
 	return 0;
 }
 
diff -Nru a/include/asm-ia64/acpi.h b/include/asm-ia64/acpi.h
--- a/include/asm-ia64/acpi.h	2004-09-01 11:12:45 -07:00
+++ b/include/asm-ia64/acpi.h	2004-09-01 11:12:45 -07:00
@@ -30,6 +30,7 @@
 
 #ifdef __KERNEL__
 
+#include <linux/config.h>
 #include <linux/init.h>
 #include <linux/numa.h>
 #include <asm/system.h>
diff -Nru a/include/asm-ia64/numa.h b/include/asm-ia64/numa.h
--- a/include/asm-ia64/numa.h	2004-09-01 11:12:45 -07:00
+++ b/include/asm-ia64/numa.h	2004-09-01 11:12:45 -07:00
@@ -12,9 +12,6 @@
 #define _ASM_IA64_NUMA_H
 
 #include <linux/config.h>
-
-#ifdef CONFIG_NUMA
-
 #include <linux/cache.h>
 #include <linux/cpumask.h>
 #include <linux/numa.h>
@@ -58,17 +55,13 @@
  * proportional to the memory access latency ratios.
  */
 
+#ifdef CONFIG_NUMA
 extern u8 numa_slit[MAX_NUMNODES * MAX_NUMNODES];
 #define node_distance(from,to) (numa_slit[(from) * numnodes + (to)])
-
 extern int paddr_to_nid(unsigned long paddr);
-
 #define local_nodeid (cpu_to_node_map[smp_processor_id()])
-
 #else /* !CONFIG_NUMA */
-
 #define paddr_to_nid(addr)	0
-
 #endif /* CONFIG_NUMA */
 
 #endif /* _ASM_IA64_NUMA_H */
diff -Nru a/include/asm-ia64/processor.h b/include/asm-ia64/processor.h
--- a/include/asm-ia64/processor.h	2004-09-01 11:12:45 -07:00
+++ b/include/asm-ia64/processor.h	2004-09-01 11:12:45 -07:00
@@ -88,9 +88,7 @@
 #include <asm/rse.h>
 #include <asm/unwind.h>
 #include <asm/atomic.h>
-#ifdef CONFIG_NUMA
 #include <asm/nodedata.h>
-#endif
 
 /* like above but expressed as bitfields for more efficient access: */
 struct ia64_psr {
@@ -168,7 +166,7 @@
 	__u8 archrev;
 	char vendor[16];
 
-#ifdef CONFIG_NUMA
+#ifdef CONFIG_DISCONTIGMEM
 	struct ia64_node_data *node_data;
 #endif
 };
diff -Nru a/include/asm-ia64/smp.h b/include/asm-ia64/smp.h
--- a/include/asm-ia64/smp.h	2004-09-01 11:12:45 -07:00
+++ b/include/asm-ia64/smp.h	2004-09-01 11:12:45 -07:00
@@ -126,6 +126,7 @@
 #else
 
 #define cpu_logical_id(cpuid)		0
+#define cpu_physical_id(i)	((ia64_getreg(_IA64_REG_CR_LID) >> 16) & 0xffff)
 
 #endif /* CONFIG_SMP */
 #endif /* _ASM_IA64_SMP_H */
diff -Nru a/include/asm-ia64/sn/sn_cpuid.h b/include/asm-ia64/sn/sn_cpuid.h
--- a/include/asm-ia64/sn/sn_cpuid.h	2004-09-01 11:12:45 -07:00
+++ b/include/asm-ia64/sn/sn_cpuid.h	2004-09-01 11:12:45 -07:00
@@ -83,10 +83,6 @@
  *
  */
 
-#ifndef CONFIG_SMP
-#define cpu_physical_id(cpuid)			((ia64_getreg(_IA64_REG_CR_LID) >> 16) & 0xffff)
-#endif
-
 /*
  * macros for some of these exist in sn/addrs.h & sn/arch.h, etc. However, 
  * trying #include these files here causes circular dependencies.
diff -Nru a/include/linux/acpi.h b/include/linux/acpi.h
--- a/include/linux/acpi.h	2004-09-01 11:12:45 -07:00
+++ b/include/linux/acpi.h	2004-09-01 11:12:45 -07:00
@@ -391,7 +391,11 @@
 void acpi_table_print_srat_entry (acpi_table_entry_header *srat);
 
 /* the following four functions are architecture-dependent */
+#ifdef CONFIG_NUMA
 void acpi_numa_slit_init (struct acpi_table_slit *slit);
+#else
+static inline void acpi_numa_slit_init(struct acpi_table_slit *slit) { }
+#endif
 void acpi_numa_processor_affinity_init (struct acpi_table_processor_affinity *pa);
 void acpi_numa_memory_affinity_init (struct acpi_table_memory_affinity *ma);
 void acpi_numa_arch_fixup(void);

--Boundary-00=_PGhNBLjFQkHWD9B--
