From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Fri, 13 Aug 2004 22:59:59 +0000
Subject: [PATCH] fix generic build when CONFIG_SMP=n
Message-Id: <200408131559.59229.jbarnes@engr.sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_vfUHBo3vWsX4NLP"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--Boundary-00=_vfUHBo3vWsX4NLP
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

This patch fixes the issues I saw with CONFIG_SMP=n when building a generic 
kernel with CONFIG_NUMA=y and CONFIG_DISCONTIGMEM=y.  It's still pretty 
rough, but I'd appreciate comments and testing on other platforms.  The 
per-cpu fixes are still pretty ugly--I'm sure I'm missing something that 
would make abstracting out per_cpu(cpu_info, cpu).node_data = 
mem_data[node].node_data much nicer looking.

Fixing the build of generic kernels w/o CONFIG_NUMA or CONFIG_DISCONTIGMEM is 
left as an exercise for the reader. :)

Thanks,
Jesse

--Boundary-00=_vfUHBo3vWsX4NLP
Content-Type: text/plain;
  charset="us-ascii";
  name="ia64-generic-no-smp-2.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="ia64-generic-no-smp-2.patch"

diff -Nru a/arch/ia64/kernel/Makefile b/arch/ia64/kernel/Makefile
--- a/arch/ia64/kernel/Makefile	2004-08-13 15:50:37 -07:00
+++ b/arch/ia64/kernel/Makefile	2004-08-13 15:50:37 -07:00
@@ -15,6 +15,7 @@
 obj-$(CONFIG_IOSAPIC)		+= iosapic.o
 obj-$(CONFIG_MODULES)		+= module.o
 obj-$(CONFIG_SMP)		+= smp.o smpboot.o
+obj-$(CONFIG_NUMA)		+= numa.o
 obj-$(CONFIG_PERFMON)		+= perfmon_default_smpl.o
 obj-$(CONFIG_IA64_CYCLONE)	+= cyclone.o
 
diff -Nru a/arch/ia64/kernel/acpi.c b/arch/ia64/kernel/acpi.c
--- a/arch/ia64/kernel/acpi.c	2004-08-13 15:50:37 -07:00
+++ b/arch/ia64/kernel/acpi.c	2004-08-13 15:50:37 -07:00
@@ -618,8 +618,10 @@
 			if (smp_boot_data.cpu_phys_id[cpu] != hard_smp_processor_id())
 				node_cpuid[i++].phys_id = smp_boot_data.cpu_phys_id[cpu];
 	}
-	build_cpu_to_node_map();
 # endif
+#endif
+#ifdef CONFIG_ACPI_NUMA
+	build_cpu_to_node_map();
 #endif
 	/* Make boot-up look pretty */
 	printk(KERN_INFO "%d CPUs available, %d CPUs total\n", available_cpus, total_cpus);
diff -Nru a/arch/ia64/kernel/numa.c b/arch/ia64/kernel/numa.c
--- /dev/null	Wed Dec 31 16:00:00 196900
+++ b/arch/ia64/kernel/numa.c	2004-08-13 15:50:37 -07:00
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
--- a/arch/ia64/kernel/setup.c	2004-08-13 15:50:37 -07:00
+++ b/arch/ia64/kernel/setup.c	2004-08-13 15:50:37 -07:00
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
--- a/arch/ia64/kernel/smpboot.c	2004-08-13 15:50:37 -07:00
+++ b/arch/ia64/kernel/smpboot.c	2004-08-13 15:50:37 -07:00
@@ -491,47 +491,6 @@
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
--- a/arch/ia64/mm/discontig.c	2004-08-13 15:50:37 -07:00
+++ b/arch/ia64/mm/discontig.c	2004-08-13 15:50:37 -07:00
@@ -225,6 +225,33 @@
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
+static void *per_cpu_node_setup(void *cpu_data, int node)
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
@@ -255,7 +282,7 @@
 static int __init find_pernode_space(unsigned long start, unsigned long len,
 				     int node)
 {
-	unsigned long epfn, cpu, cpus;
+	unsigned long epfn, cpus;
 	unsigned long pernodesize = 0, pernode, pages, mapsize;
 	void *cpu_data;
 	struct bootmem_data *bdp = &mem_data[node].bootmem_data;
@@ -305,20 +332,7 @@
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
@@ -384,8 +398,8 @@
  */
 static void __init initialize_pernode_data(void)
 {
-	int cpu, node;
 	pg_data_t *pgdat_list[NR_NODES];
+	int cpu, node;
 
 	for (node = 0; node < numnodes; node++)
 		pgdat_list[node] = mem_data[node].pgdat;
@@ -395,12 +409,22 @@
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
@@ -464,6 +488,7 @@
 	find_initrd();
 }
 
+#ifdef CONFIG_SMP
 /**
  * per_cpu_init - setup per-cpu variables
  *
@@ -474,15 +499,15 @@
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
diff -Nru a/include/asm-ia64/smp.h b/include/asm-ia64/smp.h
--- a/include/asm-ia64/smp.h	2004-08-13 15:50:37 -07:00
+++ b/include/asm-ia64/smp.h	2004-08-13 15:50:37 -07:00
@@ -126,6 +126,7 @@
 #else
 
 #define cpu_logical_id(cpuid)		0
+#define cpu_physical_id(i)	((ia64_getreg(_IA64_REG_CR_LID) >> 16) & 0xffff)
 
 #endif /* CONFIG_SMP */
 #endif /* _ASM_IA64_SMP_H */
diff -Nru a/include/asm-ia64/sn/sn_cpuid.h b/include/asm-ia64/sn/sn_cpuid.h
--- a/include/asm-ia64/sn/sn_cpuid.h	2004-08-13 15:50:37 -07:00
+++ b/include/asm-ia64/sn/sn_cpuid.h	2004-08-13 15:50:37 -07:00
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

--Boundary-00=_vfUHBo3vWsX4NLP--
