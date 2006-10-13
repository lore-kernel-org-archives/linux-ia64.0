From: Russ Anderson <rja@sgi.com>
Date: Fri, 13 Oct 2006 03:25:58 +0000
Subject: [patch] Mixed Madison and Montecito system support
Message-Id: <200610130325.k9D3PwIo17962445@clink.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

[patch] Mixed Madison and Montecito system support

When booting on systems with both Madison and Montecitos (mixing HT
and non HT CPUs), the message "ia64_pal_logical_to_phys failed with -1"
is printed.  This is due to an optimization that assumes that all the
CPUs have similar characteristics (number of cores, number of threads)
as the boot CPU.  This patch removes that optimization, so that each 
CPU is checked for its characteristics.

Signed-off-by: Russ Anderson (rja@sgi.com)

---
 arch/ia64/kernel/setup.c       |   38 --------------------------------------
 arch/ia64/kernel/smpboot.c     |   10 +++-------
 include/asm-i386/topology.h    |    2 +-
 include/asm-ia64/smp.h         |    2 --
 include/asm-ia64/topology.h    |    2 +-
 include/asm-powerpc/topology.h |    2 +-
 include/asm-sparc64/topology.h |    2 +-
 include/asm-x86_64/topology.h  |    2 +-
 kernel/sched.c                 |    9 ++++++---
 9 files changed, 14 insertions(+), 55 deletions(-)

Index: test/arch/ia64/kernel/setup.c
=================================--- test.orig/arch/ia64/kernel/setup.c	2006-10-12 10:58:27.178207151 -0500
+++ test/arch/ia64/kernel/setup.c	2006-10-12 10:59:37.826927987 -0500
@@ -361,34 +361,6 @@ mark_bsp_online (void)
 #endif
 }
 
-#ifdef CONFIG_SMP
-static void __init
-check_for_logical_procs (void)
-{
-	pal_logical_to_physical_t info;
-	s64 status;
-
-	status = ia64_pal_logical_to_phys(0, &info);
-	if (status = -1) {
-		printk(KERN_INFO "No logical to physical processor mapping "
-		       "available\n");
-		return;
-	}
-	if (status) {
-		printk(KERN_ERR "ia64_pal_logical_to_phys failed with %ld\n",
-		       status);
-		return;
-	}
-	/*
-	 * Total number of siblings that BSP has.  Though not all of them 
-	 * may have booted successfully. The correct number of siblings 
-	 * booted is in info.overview_num_log.
-	 */
-	smp_num_siblings = info.overview_tpc;
-	smp_num_cpucores = info.overview_cpp;
-}
-#endif
-
 static __initdata int nomca;
 static __init int setup_nomca(char *s)
 {
@@ -443,16 +415,6 @@ setup_arch (char **cmdline_p)
 
 	cpu_set(0, cpu_sibling_map[0]);
 	cpu_set(0, cpu_core_map[0]);
-
-	check_for_logical_procs();
-	if (smp_num_cpucores > 1)
-		printk(KERN_INFO
-		       "cpu package is Multi-Core capable: number of cores=%d\n",
-		       smp_num_cpucores);
-	if (smp_num_siblings > 1)
-		printk(KERN_INFO
-		       "cpu package is Multi-Threading capable: number of siblings=%d\n",
-		       smp_num_siblings);
 #endif
 
 	cpu_init();	/* initialize the bootstrap CPU */
Index: test/arch/ia64/kernel/smpboot.c
=================================--- test.orig/arch/ia64/kernel/smpboot.c	2006-10-12 10:58:27.178207151 -0500
+++ test/arch/ia64/kernel/smpboot.c	2006-10-12 10:59:37.826927987 -0500
@@ -139,8 +139,6 @@ EXPORT_SYMBOL(cpu_possible_map);
 
 cpumask_t cpu_core_map[NR_CPUS] __cacheline_aligned;
 cpumask_t cpu_sibling_map[NR_CPUS] __cacheline_aligned;
-int smp_num_siblings = 1;
-int smp_num_cpucores = 1;
 
 /* which logical CPU number maps to which CPU (physical APIC ID) */
 volatile int ia64_cpu_to_sapicid[NR_CPUS];
@@ -858,12 +856,10 @@ identify_siblings(struct cpuinfo_ia64 *c
 	u16 pltid;
 	pal_logical_to_physical_t info;
 
-	if (smp_num_cpucores = 1 && smp_num_siblings = 1)
-		return;
-
 	if ((status = ia64_pal_logical_to_phys(-1, &info)) != PAL_STATUS_SUCCESS) {
-		printk(KERN_ERR "ia64_pal_logical_to_phys failed with %ld\n",
-		       status);
+		if (status != PAL_STATUS_UNIMPLEMENTED)
+			printk(KERN_ERR "ia64_pal_logical_to_phys failed with %ld\n",
+					status);
 		return;
 	}
 	if ((status = ia64_sal_physical_id_info(&pltid)) != PAL_STATUS_SUCCESS) {
Index: test/include/asm-ia64/smp.h
=================================--- test.orig/include/asm-ia64/smp.h	2006-10-12 10:58:27.186208139 -0500
+++ test/include/asm-ia64/smp.h	2006-10-12 10:59:37.826927987 -0500
@@ -57,8 +57,6 @@ extern char no_int_routing __devinitdata
 extern cpumask_t cpu_online_map;
 extern cpumask_t cpu_core_map[NR_CPUS];
 extern cpumask_t cpu_sibling_map[NR_CPUS];
-extern int smp_num_siblings;
-extern int smp_num_cpucores;
 extern void __iomem *ipi_base_addr;
 extern unsigned char smp_int_redirect;
 
Index: test/include/asm-ia64/topology.h
=================================--- test.orig/include/asm-ia64/topology.h	2006-10-12 10:58:27.186208139 -0500
+++ test/include/asm-ia64/topology.h	2006-10-12 10:59:37.826927987 -0500
@@ -112,7 +112,7 @@ void build_cpu_to_node_map(void);
 #define topology_core_id(cpu)			(cpu_data(cpu)->core_id)
 #define topology_core_siblings(cpu)		(cpu_core_map[cpu])
 #define topology_thread_siblings(cpu)		(cpu_sibling_map[cpu])
-#define smt_capable() 				(smp_num_siblings > 1)
+#define smt_capable(cpu) 			(cpu_data(cpu)->threads_per_core > 1)
 #endif
 
 #include <asm-generic/topology.h>
Index: test/kernel/sched.c
=================================--- test.orig/kernel/sched.c	2006-10-12 10:58:27.186208139 -0500
+++ test/kernel/sched.c	2006-10-12 10:59:37.830928481 -0500
@@ -6621,12 +6621,15 @@ static ssize_t sched_power_savings_store
 
 int sched_create_sysfs_power_savings_entries(struct sysdev_class *cls)
 {
-	int err = 0;
+	int err = 0, c;
 
 #ifdef CONFIG_SCHED_SMT
-	if (smt_capable())
-		err = sysfs_create_file(&cls->kset.kobj,
+	for_each_online_cpu(c)
+		if (smt_capable(c)) {
+			err = sysfs_create_file(&cls->kset.kobj,
 					&attr_sched_smt_power_savings.attr);
+			break;
+		}
 #endif
 #ifdef CONFIG_SCHED_MC
 	if (!err && mc_capable())
Index: test/include/asm-i386/topology.h
=================================--- test.orig/include/asm-i386/topology.h	2006-09-27 09:47:54.000000000 -0500
+++ test/include/asm-i386/topology.h	2006-10-12 15:17:26.056408743 -0500
@@ -114,7 +114,7 @@ extern cpumask_t cpu_coregroup_map(int c
 
 #ifdef CONFIG_SMP
 #define mc_capable()	(boot_cpu_data.x86_max_cores > 1)
-#define smt_capable()	(smp_num_siblings > 1)
+#define smt_capable(cpu)	(smp_num_siblings > 1)
 #endif
 
 #endif /* _ASM_I386_TOPOLOGY_H */
Index: test/include/asm-powerpc/topology.h
=================================--- test.orig/include/asm-powerpc/topology.h	2006-09-27 09:47:54.000000000 -0500
+++ test/include/asm-powerpc/topology.h	2006-10-12 15:18:01.448786707 -0500
@@ -95,7 +95,7 @@ static inline void sysfs_remove_device_f
 
 #ifdef CONFIG_SMP
 #include <asm/cputable.h>
-#define smt_capable() 		(cpu_has_feature(CPU_FTR_SMT))
+#define smt_capable(cpu) 		(cpu_has_feature(CPU_FTR_SMT))
 #endif
 
 #endif /* __KERNEL__ */
Index: test/include/asm-sparc64/topology.h
=================================--- test.orig/include/asm-sparc64/topology.h	2006-09-27 09:47:54.000000000 -0500
+++ test/include/asm-sparc64/topology.h	2006-10-12 15:18:28.728160970 -0500
@@ -2,7 +2,7 @@
 #define _ASM_SPARC64_TOPOLOGY_H
 
 #include <asm/spitfire.h>
-#define smt_capable()	(tlb_type = hypervisor)
+#define smt_capable(cpu)	(tlb_type = hypervisor)
 
 #include <asm-generic/topology.h>
 
Index: test/include/asm-x86_64/topology.h
=================================--- test.orig/include/asm-x86_64/topology.h	2006-09-27 09:47:54.000000000 -0500
+++ test/include/asm-x86_64/topology.h	2006-10-12 15:19:00.968148668 -0500
@@ -60,7 +60,7 @@ extern int __node_distance(int, int);
 #define topology_core_siblings(cpu)		(cpu_core_map[cpu])
 #define topology_thread_siblings(cpu)		(cpu_sibling_map[cpu])
 #define mc_capable()			(boot_cpu_data.x86_max_cores > 1)
-#define smt_capable() 			(smp_num_siblings > 1)
+#define smt_capable(cpu) 			(smp_num_siblings > 1)
 #endif
 
 #include <asm-generic/topology.h>
-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
