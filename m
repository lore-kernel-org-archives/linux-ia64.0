From: dann frazier <dannf@debian.org>
Date: Thu, 06 Jan 2005 20:14:27 +0000
Subject: fixing 2.6.10 UP builds
Message-Id: <20050106201427.GA6009@jale>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Debian is putting together 2.6.10 packages, and we noticed that we still
need to forward port Jesse's patches.  Attached is the patch Ubuntu forward
ported, and Debian is including.  It would be great to get this merged upstream
so we don't need to port it for each release.

diff -Nru a/arch/ia64/kernel/Makefile b/arch/ia64/kernel/Makefile
--- a/arch/ia64/kernel/Makefile	2004-08-12 18:28:06 -07:00
+++ b/arch/ia64/kernel/Makefile	2004-08-12 18:28:06 -07:00
@@ -15,6 +15,7 @@
 obj-$(CONFIG_IOSAPIC)		+= iosapic.o
 obj-$(CONFIG_MODULES)		+= module.o
 obj-$(CONFIG_SMP)		+= smp.o smpboot.o domain.o
+obj-$(CONFIG_NUMA)		+= numa.o
 obj-$(CONFIG_PERFMON)		+= perfmon_default_smpl.o
 obj-$(CONFIG_IA64_CYCLONE)	+= cyclone.o
 
diff -Nru a/arch/ia64/kernel/numa.c b/arch/ia64/kernel/numa.c
--- /dev/null	Wed Dec 31 16:00:00 196900
+++ b/arch/ia64/kernel/numa.c	2004-08-12 18:28:06 -07:00
@@ -0,0 +1,46 @@
+#include <linux/config.h>
+#include <linux/topology.h>
+#include <linux/module.h>
+#include <asm/processor.h>
+#include <asm/smp.h>
+
+#ifdef CONFIG_NUMA
+
+/* on which node is each logical CPU (one cacheline even for 64 CPUs) */
+u8 cpu_to_node_map[NR_CPUS] __cacheline_aligned;
+EXPORT_SYMBOL(cpu_to_node_map);
+/* which logical CPUs are on which nodes */
+cpumask_t node_to_cpu_mask[MAX_NUMNODES] __cacheline_aligned;
+
+/*
+ * Build cpu to node mapping and initialize the per node cpu masks.
+ */
+void __init
+build_cpu_to_node_map (void)
+{
+	int cpu, i, node;
+
+	for(node=0; node<MAX_NUMNODES; node++)
+		cpus_clear(node_to_cpu_mask[node]);
+	for(cpu = 0; cpu < NR_CPUS; ++cpu) {
+		/*
+		 * All Itanium NUMA platforms I know use ACPI, so maybe we
+		 * can drop this ifdef completely.                    [EF]
+		 */
+#ifdef CONFIG_ACPI_NUMA
+		node = -1;
+		for (i = 0; i < NR_CPUS; ++i)
+			if (cpu_physical_id(cpu) = node_cpuid[i].phys_id) {
+				node = node_cpuid[i].nid;
+				break;
+			}
+#else
+#		error Fixme: Dunno how to build CPU-to-node map.
+#endif
+		cpu_to_node_map[cpu] = (node >= 0) ? node : 0;
+		if (node >= 0)
+			cpu_set(cpu, node_to_cpu_mask[node]);
+	}
+}
+
+#endif /* CONFIG_NUMA */
diff -Nru a/arch/ia64/kernel/smpboot.c b/arch/ia64/kernel/smpboot.c
--- a/arch/ia64/kernel/smpboot.c	2004-08-12 18:28:06 -07:00
+++ b/arch/ia64/kernel/smpboot.c	2004-08-12 18:28:06 -07:00
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
-			if (cpu_physical_id(cpu) = node_cpuid[i].phys_id) {
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
--- a/arch/ia64/mm/discontig.c	2004-08-12 18:28:06 -07:00
+++ b/arch/ia64/mm/discontig.c	2004-08-12 18:28:06 -07:00
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
+		if (node = node_cpuid[cpu].nid) {
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
-			if (node = node_cpuid[cpu].nid) {
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
@@ -464,6 +478,7 @@
 	find_initrd();
 }
 
+#ifdef CONFIG_SMP
 /**
  * per_cpu_init - setup per-cpu variables
  *
@@ -483,6 +498,7 @@
 
 	return __per_cpu_start + __per_cpu_offset[smp_processor_id()];
 }
+#endif /* CONFIG_SMP */
 
 /**
  * show_mem - give short summary of memory stats
@@ -80,12 +80,6 @@
  *
  */
 
-#ifndef CONFIG_SMP
-#define cpu_logical_id(cpu)			0
-#define cpu_physical_id(cpuid)			((ia64_getreg(_IA64_REG_CR_LID) >> 16) & 0xffff)
-#endif
-
-
 #define get_node_number(addr)			(((unsigned long)(addr)>>38) & 0x7ff)
 
 /*
diff -Nru a/include/asm-ia64/smp.h b/include/asm-ia64/smp.h
--- a/include/asm-ia64/smp.h	2004-08-12 18:28:06 -07:00
+++ b/include/asm-ia64/smp.h	2004-08-12 18:28:06 -07:00
@@ -126,6 +126,7 @@
 #else
 
 #define cpu_logical_id(cpuid)		0
+#define cpu_physical_id(i)	((ia64_getreg(_IA64_REG_CR_LID) >> 16) & 0xffff)
 
 #endif /* CONFIG_SMP */
 #endif /* _ASM_IA64_SMP_H */
diff -urN kernel-source-2.6.8.defconfig/arch/ia64/kernel/acpi.c kernel-source-2.6.8.newupfix.defconfig/arch/ia64/kernel/acpi.c
--- kernel-source-2.6.8.defconfig/arch/ia64/kernel/acpi.c	2004-08-13 23:36:58.000000000 -0600
+++ kernel-source-2.6.8.newupfix.defconfig/arch/ia64/kernel/acpi.c	2004-08-15 15:49:38.000000000 -0600
@@ -618,9 +618,11 @@
 			if (smp_boot_data.cpu_phys_id[cpu] != hard_smp_processor_id())
 				node_cpuid[i++].phys_id = smp_boot_data.cpu_phys_id[cpu];
 	}
-	build_cpu_to_node_map();
 # endif
 #endif
+#ifdef CONFIG_ACPI_NUMA
+	build_cpu_to_node_map();
+#endif
 	/* Make boot-up look pretty */
 	printk(KERN_INFO "%d CPUs available, %d CPUs total\n", available_cpus, total_cpus);
 	return 0;
diff -urN kernel-source-2.6.8.defconfig/arch/ia64/kernel/cyclone.c kernel-source-2.6.8.newupfix.defconfig/arch/ia64/kernel/cyclone.c
--- kernel-source-2.6.8.defconfig/arch/ia64/kernel/cyclone.c	2004-08-14 13:07:37.000000000 -0600
+++ kernel-source-2.6.8.newupfix.defconfig/arch/ia64/kernel/cyclone.c	2004-08-15 15:49:31.000000000 -0600
@@ -1,8 +1,6 @@
-#include <linux/module.h>
 #include <linux/smp.h>
 #include <linux/time.h>
 #include <linux/errno.h>
-#include <asm/io.h>
 
 /* IBM Summit (EXA) Cyclone counter code*/
 #define CYCLONE_CBAR_ADDR 0xFEB00CD0
diff -urN kernel-source-2.6.8.defconfig/arch/ia64/kernel/numa.c kernel-source-2.6.8.newupfix.defconfig/arch/ia64/kernel/numa.c
--- kernel-source-2.6.8.defconfig/arch/ia64/kernel/numa.c	2004-08-14 13:07:37.000000000 -0600
+++ kernel-source-2.6.8.newupfix.defconfig/arch/ia64/kernel/numa.c	2004-08-15 15:49:38.000000000 -0600
@@ -1,46 +1,57 @@
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
 #include <linux/config.h>
 #include <linux/topology.h>
 #include <linux/module.h>
 #include <asm/processor.h>
 #include <asm/smp.h>
 
-#ifdef CONFIG_NUMA
-
-/* on which node is each logical CPU (one cacheline even for 64 CPUs) */
 u8 cpu_to_node_map[NR_CPUS] __cacheline_aligned;
 EXPORT_SYMBOL(cpu_to_node_map);
-/* which logical CPUs are on which nodes */
+
 cpumask_t node_to_cpu_mask[MAX_NUMNODES] __cacheline_aligned;
 
-/*
- * Build cpu to node mapping and initialize the per node cpu masks.
+/**
+ * build_cpu_to_node_map - setup cpu to node and node to cpumask arrays
+ *
+ * Build cpu to node mapping and initialize the per node cpu masks using
+ * info from the node_cpuid array handed to us by ACPI.
  */
-void __init
-build_cpu_to_node_map (void)
+void __init build_cpu_to_node_map(void)
 {
 	int cpu, i, node;
 
-	for(node=0; node<MAX_NUMNODES; node++)
+	for(node=0; node < MAX_NUMNODES; node++)
 		cpus_clear(node_to_cpu_mask[node]);
+
 	for(cpu = 0; cpu < NR_CPUS; ++cpu) {
-		/*
-		 * All Itanium NUMA platforms I know use ACPI, so maybe we
-		 * can drop this ifdef completely.                    [EF]
-		 */
-#ifdef CONFIG_ACPI_NUMA
 		node = -1;
 		for (i = 0; i < NR_CPUS; ++i)
 			if (cpu_physical_id(cpu) = node_cpuid[i].phys_id) {
 				node = node_cpuid[i].nid;
 				break;
 			}
-#else
-#		error Fixme: Dunno how to build CPU-to-node map.
-#endif
 		cpu_to_node_map[cpu] = (node >= 0) ? node : 0;
 		if (node >= 0)
 			cpu_set(cpu, node_to_cpu_mask[node]);
 	}
 }
-
-#endif /* CONFIG_NUMA */
diff -urN kernel-source-2.6.8.defconfig/arch/ia64/kernel/setup.c kernel-source-2.6.8.newupfix.defconfig/arch/ia64/kernel/setup.c
--- kernel-source-2.6.8.defconfig/arch/ia64/kernel/setup.c	2004-08-13 23:36:17.000000000 -0600
+++ kernel-source-2.6.8.newupfix.defconfig/arch/ia64/kernel/setup.c	2004-08-15 15:49:38.000000000 -0600
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
diff -urN kernel-source-2.6.8.defconfig/arch/ia64/mm/discontig.c kernel-source-2.6.8.newupfix.defconfig/arch/ia64/mm/discontig.c
--- kernel-source-2.6.8.defconfig/arch/ia64/mm/discontig.c	2004-08-14 13:07:37.000000000 -0600
+++ kernel-source-2.6.8.newupfix.defconfig/arch/ia64/mm/discontig.c	2004-08-15 15:49:38.000000000 -0600
@@ -398,8 +398,8 @@
  */
 static void __init initialize_pernode_data(void)
 {
-	int cpu, node;
 	pg_data_t *pgdat_list[NR_NODES];
+	int cpu, node;
 
 	for (node = 0; node < numnodes; node++)
 		pgdat_list[node] = mem_data[node].pgdat;
@@ -409,12 +409,22 @@
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
@@ -489,12 +499,11 @@
 {
 	int cpu;
 
-	if (smp_processor_id() = 0) {
-		for (cpu = 0; cpu < NR_CPUS; cpu++) {
-			per_cpu(local_per_cpu_offset, cpu) -				__per_cpu_offset[cpu];
-		}
-	}
+	if (smp_processor_id() != 0)
+		return __per_cpu_start + __per_cpu_offset[smp_processor_id()];
+
+	for (cpu = 0; cpu < NR_CPUS; cpu++)
+		per_cpu(local_per_cpu_offset, cpu) = __per_cpu_offset[cpu];
 
 	return __per_cpu_start + __per_cpu_offset[smp_processor_id()];
 }
