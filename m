From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Wed, 01 Sep 2004 00:44:16 +0000
Subject: [PATCH] CONFIG_SMP=n fixes redux
Message-Id: <200408311744.16748.jbarnes@engr.sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_gtRNBu7cYAgbajt"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--Boundary-00=_gtRNBu7cYAgbajt
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Today both Christoph and Alex mentioned that they thought this patch would be 
nice to have in the tree.  It allows a generic kernel to build and run when 
CONFIG_SMP=n.  I'd still like feedback about the per-cpu stuff though, in 
particular, this

+#ifdef CONFIG_SMP
        /* Set the node_data pointer for each per-cpu struct */
        for (cpu = 0; cpu < NR_CPUS; cpu++) {
                node = node_cpuid[cpu].nid;
                per_cpu(cpu_info, cpu).node_data = mem_data[node].node_data;
        }
+#else
+       {
+               struct cpuinfo_ia64 *cpu0_cpu_info;
+               cpu = 0;
+               node = node_cpuid[cpu].nid;
+               cpu0_cpu_info = (struct cpuinfo_ia64 *)(__phys_per_cpu_start +
+                       ((char *)&per_cpu__cpu_info - __per_cpu_start));
+               cpu0_cpu_info->node_data = mem_data[node].node_data;
+       }
+#endif /* CONFIG_SMP */

is really ugly.  Maybe I should take this opportunity to convert the early 
memory allocation code to using the bootmem allocator instead of backdooring 
it via find_pernode_space()?  I think that would mean we could share more 
code between the contig and discontigmem cases, but we'd also have to be 
careful to avoid cacheline aliasing.

Thanks,
Jesse

--Boundary-00=_gtRNBu7cYAgbajt
Content-Type: text/plain;
  charset="us-ascii";
  name="ia64-generic-no-smp-3.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="ia64-generic-no-smp-3.patch"

===== arch/ia64/kernel/Makefile 1.34 vs edited =====
--- 1.34/arch/ia64/kernel/Makefile	2004-08-16 07:51:35 -07:00
+++ edited/arch/ia64/kernel/Makefile	2004-08-31 17:33:30 -07:00
@@ -15,6 +15,7 @@
 obj-$(CONFIG_IOSAPIC)		+= iosapic.o
 obj-$(CONFIG_MODULES)		+= module.o
 obj-$(CONFIG_SMP)		+= smp.o smpboot.o
+obj-$(CONFIG_NUMA)		+= numa.o
 obj-$(CONFIG_PERFMON)		+= perfmon_default_smpl.o
 obj-$(CONFIG_IA64_CYCLONE)	+= cyclone.o
 
===== arch/ia64/kernel/acpi.c 1.74 vs edited =====
--- 1.74/arch/ia64/kernel/acpi.c	2004-08-05 21:40:29 -07:00
+++ edited/arch/ia64/kernel/acpi.c	2004-08-31 17:33:31 -07:00
@@ -624,8 +624,10 @@
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
===== arch/ia64/kernel/setup.c 1.79 vs edited =====
--- 1.79/arch/ia64/kernel/setup.c	2004-08-04 11:08:05 -07:00
+++ edited/arch/ia64/kernel/setup.c	2004-08-31 17:33:32 -07:00
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
===== arch/ia64/kernel/smpboot.c 1.60 vs edited =====
--- 1.60/arch/ia64/kernel/smpboot.c	2004-08-24 02:08:43 -07:00
+++ edited/arch/ia64/kernel/smpboot.c	2004-08-31 17:33:33 -07:00
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
===== arch/ia64/mm/discontig.c 1.18 vs edited =====
--- 1.18/arch/ia64/mm/discontig.c	2004-08-26 23:30:29 -07:00
+++ edited/arch/ia64/mm/discontig.c	2004-08-31 17:33:33 -07:00
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
===== include/asm-ia64/smp.h 1.18 vs edited =====
--- 1.18/include/asm-ia64/smp.h	2004-06-21 13:44:12 -07:00
+++ edited/include/asm-ia64/smp.h	2004-08-31 17:33:34 -07:00
@@ -126,6 +126,7 @@
 #else
 
 #define cpu_logical_id(cpuid)		0
+#define cpu_physical_id(i)	((ia64_getreg(_IA64_REG_CR_LID) >> 16) & 0xffff)
 
 #endif /* CONFIG_SMP */
 #endif /* _ASM_IA64_SMP_H */
===== include/asm-ia64/sn/sn_cpuid.h 1.10 vs edited =====
--- 1.10/include/asm-ia64/sn/sn_cpuid.h	2004-08-18 11:00:37 -07:00
+++ edited/include/asm-ia64/sn/sn_cpuid.h	2004-08-31 17:33:35 -07:00
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

--Boundary-00=_gtRNBu7cYAgbajt--
