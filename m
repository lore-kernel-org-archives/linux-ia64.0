From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Mon, 11 Apr 2005 19:38:53 +0000
Subject: [PATCH] make CONFIG_IA64_GENERIC=y && CONFIG_SMP=n work
Message-Id: <200504111238.53982.jbarnes@engr.sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_NJtWCLA243zoNI4"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--Boundary-00=_NJtWCLA243zoNI4
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Here's the latest version of this patch.  There's an unrelated problem with 
the TOT tree right now that prevents me from booting all the way, but it gets 
far enough to give me at least some confidence in this patch.  I've compile 
tested and partially booted CONFIG_IA64_SGI_SN2=y and CONFIG_IA64_GENERIC=y, 
CONFIG_SMP=n configurations.

The patch fixes some compile problems when CONFIG_SMP is disabled and 
refactors out some of the kernel NUMA stuff into its own file that we can use 
for additional code later.  Some ugliness in discontig.c remains, however.

Comments, testing, and/or merging upstream appreciated :).

 arch/ia64/kernel/Makefile      |    1
 arch/ia64/kernel/acpi.c        |    4 ++
 arch/ia64/kernel/numa.c        |   57 +++++++++++++++++++++++++++++++++++++++
 arch/ia64/kernel/smpboot.c     |   41 ----------------------------
 arch/ia64/mm/discontig.c       |   58 ++++++++++++++++++++++++++-------------
 include/asm-ia64/sn/sn_cpuid.h |    4 --
 6 files changed, 102 insertions(+), 63 deletions(-)

Jesse

P.S. I didn't include the fix for mmtimer.c && CONFIG_SMP=n here, Christoph 
can you fix it?
drivers/char/mmtimer.c: In function `mmtimer_tasklet':
drivers/char/mmtimer.c:488: error: structure has no member named `write_lock'

--Boundary-00=_NJtWCLA243zoNI4
Content-Type: text/plain;
  charset="us-ascii";
  name="ia64-generic-no-smp-6.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="ia64-generic-no-smp-6.patch"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/04/11 12:27:24-07:00 jbarnes@tomahawk.engr.sgi.com 
#   CONFIG_SMP=n support for generic kernels
# 
# arch/ia64/kernel/numa.c
#   2005/04/11 12:27:11-07:00 jbarnes@tomahawk.engr.sgi.com +57 -0
# 
# include/asm-ia64/sn/sn_cpuid.h
#   2005/04/11 12:27:11-07:00 jbarnes@tomahawk.engr.sgi.com +0 -4
#   CONFIG_SMP=n support for generic kernels
# 
# arch/ia64/mm/discontig.c
#   2005/04/11 12:27:11-07:00 jbarnes@tomahawk.engr.sgi.com +41 -17
#   CONFIG_SMP=n support for generic kernels
# 
# arch/ia64/kernel/smpboot.c
#   2005/04/11 12:27:11-07:00 jbarnes@tomahawk.engr.sgi.com +0 -41
#   CONFIG_SMP=n support for generic kernels
# 
# arch/ia64/kernel/numa.c
#   2005/04/11 12:27:11-07:00 jbarnes@tomahawk.engr.sgi.com +0 -0
#   BitKeeper file /home/jbarnes/working/linux-2.5-ia64-no-smp/arch/ia64/kernel/numa.c
# 
# arch/ia64/kernel/acpi.c
#   2005/04/11 12:27:11-07:00 jbarnes@tomahawk.engr.sgi.com +3 -1
#   CONFIG_SMP=n support for generic kernels
# 
# arch/ia64/kernel/Makefile
#   2005/04/11 12:27:11-07:00 jbarnes@tomahawk.engr.sgi.com +1 -0
#   CONFIG_SMP=n support for generic kernels
# 
diff -Nru a/arch/ia64/kernel/Makefile b/arch/ia64/kernel/Makefile
--- a/arch/ia64/kernel/Makefile	2005-04-11 12:28:22 -07:00
+++ b/arch/ia64/kernel/Makefile	2005-04-11 12:28:22 -07:00
@@ -17,6 +17,7 @@
 obj-$(CONFIG_IOSAPIC)		+= iosapic.o
 obj-$(CONFIG_MODULES)		+= module.o
 obj-$(CONFIG_SMP)		+= smp.o smpboot.o domain.o
+obj-$(CONFIG_NUMA)		+= numa.o
 obj-$(CONFIG_PERFMON)		+= perfmon_default_smpl.o
 obj-$(CONFIG_IA64_CYCLONE)	+= cyclone.o
 obj-$(CONFIG_IA64_MCA_RECOVERY)	+= mca_recovery.o
diff -Nru a/arch/ia64/kernel/acpi.c b/arch/ia64/kernel/acpi.c
--- a/arch/ia64/kernel/acpi.c	2005-04-11 12:28:22 -07:00
+++ b/arch/ia64/kernel/acpi.c	2005-04-11 12:28:22 -07:00
@@ -642,8 +642,10 @@
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
+++ b/arch/ia64/kernel/numa.c	2005-04-11 12:28:22 -07:00
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
+	for (node = 0; node < MAX_NUMNODES; node++)
+		cpus_clear(node_to_cpu_mask[node]);
+
+	for (cpu = 0; cpu < NR_CPUS; cpu++) {
+		node = -1;
+		for (i = 0; i < NR_CPUS; i++)
+			if (cpu_physical_id(cpu) == node_cpuid[i].phys_id) {
+				node = node_cpuid[i].nid;
+				break;
+			}
+		cpu_to_node_map[cpu] = (node >= 0) ? node : 0;
+		if (node >= 0)
+			cpu_set(cpu, node_to_cpu_mask[node]);
+	}
+}
diff -Nru a/arch/ia64/kernel/smpboot.c b/arch/ia64/kernel/smpboot.c
--- a/arch/ia64/kernel/smpboot.c	2005-04-11 12:28:22 -07:00
+++ b/arch/ia64/kernel/smpboot.c	2005-04-11 12:28:22 -07:00
@@ -463,47 +463,6 @@
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
--- a/arch/ia64/mm/discontig.c	2005-04-11 12:28:22 -07:00
+++ b/arch/ia64/mm/discontig.c	2005-04-11 12:28:22 -07:00
@@ -4,7 +4,7 @@
  * Copyright (c) 2001 Tony Luck <tony.luck@intel.com>
  * Copyright (c) 2002 NEC Corp.
  * Copyright (c) 2002 Kimio Suganuma <k-suganuma@da.jp.nec.com>
- * Copyright (c) 2004 Silicon Graphics, Inc
+ * Copyright (c) 2004-2005 Silicon Graphics, Inc
  *	Russ Anderson <rja@sgi.com>
  *	Jesse Barnes <jbarnes@sgi.com>
  *	Jack Steiner <steiner@sgi.com>
@@ -274,6 +274,31 @@
 }
 
 /**
+ * per_cpu_node_setup - setup per-cpu areas on each node
+ * @cpu_data: per-cpu area on this node
+ * @node: node to setup
+ *
+ * Copy the static per-cpu data into the region we just set aside and then
+ * setup __per_cpu_offset for each CPU on this node.
+ */
+static void per_cpu_node_setup(void *cpu_data, int node)
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
+}
+
+/**
  * find_pernode_space - allocate memory for memory map and per-node structures
  * @start: physical start of range
  * @len: length of range
@@ -304,7 +329,7 @@
 static int __init find_pernode_space(unsigned long start, unsigned long len,
 				     int node)
 {
-	unsigned long epfn, cpu, cpus, phys_cpus;
+	unsigned long epfn, cpus, phys_cpus;
 	unsigned long pernodesize = 0, pernode, pages, mapsize;
 	void *cpu_data;
 	struct bootmem_data *bdp = &mem_data[node].bootmem_data;
@@ -357,20 +382,7 @@
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
+		per_cpu_node_setup(cpu_data, node);
 	}
 
 	return 0;
@@ -447,12 +459,22 @@
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
@@ -519,6 +541,7 @@
 	find_initrd();
 }
 
+#ifdef CONFIG_SMP
 /**
  * per_cpu_init - setup per-cpu variables
  *
@@ -538,6 +561,7 @@
 
 	return __per_cpu_start + __per_cpu_offset[smp_processor_id()];
 }
+#endif /* CONFIG_SMP */
 
 /**
  * show_mem - give short summary of memory stats
diff -Nru a/include/asm-ia64/sn/sn_cpuid.h b/include/asm-ia64/sn/sn_cpuid.h
--- a/include/asm-ia64/sn/sn_cpuid.h	2005-04-11 12:28:22 -07:00
+++ b/include/asm-ia64/sn/sn_cpuid.h	2005-04-11 12:28:22 -07:00
@@ -81,10 +81,6 @@
  *
  */
 
-#ifndef CONFIG_SMP
-#define cpu_physical_id(cpuid)			((ia64_getreg(_IA64_REG_CR_LID) >> 16) & 0xffff)
-#endif
-
 
 #define get_node_number(addr)			NASID_GET(addr)
 

--Boundary-00=_NJtWCLA243zoNI4--
