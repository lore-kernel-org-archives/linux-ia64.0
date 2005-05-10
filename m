From: Jack Steiner <steiner@sgi.com>
Date: Tue, 10 May 2005 15:00:45 +0000
Subject: [PATCH] - new macros for SGI SN simulator
Message-Id: <20050510150045.GA6609@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Tony - please apply


This patch changes some macros that are used when running kernel on the
SGI simulator. All changes are contained in the SGI SN portion of the
tree.


	Signed-off-by: Jack Steiner <steiner@sgi.com>


 arch/ia64/sn/kernel/io_init.c   |    2 +-
 arch/ia64/sn/kernel/setup.c     |   25 ++++++++++++++++++-------
 include/asm-ia64/sn/simulator.h |   13 +++++++------
 include/asm-ia64/sn/sn_sal.h    |   10 ++++++++++
 4 files changed, 36 insertions(+), 14 deletions(-)



Index: linux/include/asm-ia64/sn/sn_sal.h
=================================--- linux.orig/include/asm-ia64/sn/sn_sal.h	2005-05-07 06:44:16.208518885 -0500
+++ linux/include/asm-ia64/sn/sn_sal.h	2005-05-10 09:44:27.353279267 -0500
@@ -115,6 +115,8 @@
 #define SAL_IROUTER_INTR_XMIT	SAL_CONSOLE_INTR_XMIT
 #define SAL_IROUTER_INTR_RECV	SAL_CONSOLE_INTR_RECV
 
+#define SN_SAL_FAKE_PROM			   0x02009999
+
 
 /*
  * SAL Error Codes
@@ -1052,4 +1054,12 @@ ia64_sn_bte_recovery(nasid_t nasid)
 	return (int) rv.status;
 }
 
+static inline int
+ia64_sn_is_fake_prom(void)
+{
+	struct ia64_sal_retval rv;
+	SAL_CALL_NOLOCK(rv, SN_SAL_FAKE_PROM, 0, 0, 0, 0, 0, 0, 0);
+	return (rv.status = 0);
+}
+
 #endif /* _ASM_IA64_SN_SN_SAL_H */
Index: linux/arch/ia64/sn/kernel/io_init.c
=================================--- linux.orig/arch/ia64/sn/kernel/io_init.c	2005-05-07 06:44:08.153921123 -0500
+++ linux/arch/ia64/sn/kernel/io_init.c	2005-05-10 09:44:27.355232368 -0500
@@ -382,7 +382,7 @@ static int __init sn_pci_init(void)
 	extern void register_sn_procfs(void);
 #endif
 
-	if (!ia64_platform_is("sn2") || IS_RUNNING_ON_SIMULATOR())
+	if (!ia64_platform_is("sn2") || IS_RUNNING_ON_FAKE_PROM())
 		return 0;
 
 	/*
Index: linux/arch/ia64/sn/kernel/setup.c
=================================--- linux.orig/arch/ia64/sn/kernel/setup.c	2005-05-10 09:43:17.579741351 -0500
+++ linux/arch/ia64/sn/kernel/setup.c	2005-05-10 09:50:14.892888127 -0500
@@ -89,6 +89,7 @@ u8 sn_coherency_id;
 EXPORT_SYMBOL(sn_coherency_id);
 u8 sn_region_size;
 EXPORT_SYMBOL(sn_region_size);
+int sn_prom_type;	/* 0=hardware, 1=medusa/realprom, 2=medusa/fakeprom */
 
 short physical_node_map[MAX_PHYSNODE_ID];
 
@@ -342,7 +343,7 @@ void __init sn_setup(char **cmdline_p)
 
 	ia64_mark_idle = &snidle;
 
-	/* 
+	/*
 	 * For the bootcpu, we do this here. All other cpus will make the
 	 * call as part of cpu_init in slave cpu initialization.
 	 */
@@ -389,7 +390,7 @@ static void __init sn_init_pdas(char **c
 		nodepdaindr[cnode]  		    alloc_bootmem_node(NODE_DATA(cnode), sizeof(nodepda_t));
 		memset(nodepdaindr[cnode], 0, sizeof(nodepda_t));
-		memset(nodepdaindr[cnode]->phys_cpuid, -1, 
+		memset(nodepdaindr[cnode]->phys_cpuid, -1,
 		    sizeof(nodepdaindr[cnode]->phys_cpuid));
 	}
 
@@ -419,7 +420,7 @@ static void __init sn_init_pdas(char **c
 	}
 
 	/*
-	 * Initialize the per node hubdev.  This includes IO Nodes and 
+	 * Initialize the per node hubdev.  This includes IO Nodes and
 	 * headless/memless nodes.
 	 */
 	for (cnode = 0; cnode < numionodes; cnode++) {
@@ -447,6 +448,14 @@ void __init sn_cpu_init(void)
 	int i;
 	static int wars_have_been_checked;
 
+	if (smp_processor_id() = 0 && IS_MEDUSA()) {
+		if (ia64_sn_is_fake_prom())
+			sn_prom_type = 2;
+		else
+			sn_prom_type = 1;
+		printk("Running on medusa with %s PROM\n", (sn_prom_type = 1) ? "real" : "fake");
+	}
+
 	memset(pda, 0, sizeof(pda));
 	if (ia64_sn_get_sn_info(0, &sn_hub_info->shub2, &sn_hub_info->nasid_bitmask, &sn_hub_info->nasid_shift,
 				&sn_system_size, &sn_sharing_domain_size, &sn_partition_id,
@@ -508,7 +517,7 @@ void __init sn_cpu_init(void)
 	 */
 	{
 		u64 pio1[] = {SH1_PIO_WRITE_STATUS_0, 0, SH1_PIO_WRITE_STATUS_1, 0};
-		u64 pio2[] = {SH2_PIO_WRITE_STATUS_0, SH2_PIO_WRITE_STATUS_1, 
+		u64 pio2[] = {SH2_PIO_WRITE_STATUS_0, SH2_PIO_WRITE_STATUS_1,
 			SH2_PIO_WRITE_STATUS_2, SH2_PIO_WRITE_STATUS_3};
 		u64 *pio;
 		pio = is_shub1() ? pio1 : pio2;
@@ -540,6 +549,10 @@ static void __init scan_for_ionodes(void
 	int nasid = 0;
 	lboard_t *brd;
 
+	/* fakeprom does not support klgraph */
+	if (IS_RUNNING_ON_FAKE_PROM())
+		return;
+
 	/* Setup ionodes with memory */
 	for (nasid = 0; nasid < MAX_PHYSNODE_ID; nasid += 2) {
 		char *klgraph_header;
@@ -551,8 +564,6 @@ static void __init scan_for_ionodes(void
 		cnodeid = -1;
 		klgraph_header = __va(ia64_sn_get_klconfig_addr(nasid));
 		if (!klgraph_header) {
-			if (IS_RUNNING_ON_SIMULATOR())
-				continue;
 			BUG();	/* All nodes must have klconfig tables! */
 		}
 		cnodeid = nasid_to_cnodeid(nasid);
@@ -622,7 +633,7 @@ nasid_slice_to_cpuid(int nasid, int slic
 {
 	long cpu;
 	
-	for (cpu=0; cpu < NR_CPUS; cpu++) 
+	for (cpu=0; cpu < NR_CPUS; cpu++)
 		if (nodepda->phys_cpuid[cpu].nasid = nasid && nodepda->phys_cpuid[cpu].slice = slice)
 			return cpu;
 
Index: linux/include/asm-ia64/sn/simulator.h
=================================--- linux.orig/include/asm-ia64/sn/simulator.h	2005-05-07 06:44:16.202659576 -0500
+++ linux/include/asm-ia64/sn/simulator.h	2005-05-10 09:44:27.362068219 -0500
@@ -10,16 +10,17 @@
 
 #include <linux/config.h>
 
-#ifdef CONFIG_IA64_SGI_SN_SIM
-
 #define SNMAGIC 0xaeeeeeee8badbeefL
-#define IS_RUNNING_ON_SIMULATOR() ({long sn; asm("mov %0=cpuid[%1]" : "=r"(sn) : "r"(2)); sn = SNMAGIC;})
-
-#define SIMULATOR_SLEEP()	asm("nop.i 0x8beef")
+#define IS_MEDUSA()			({long sn; asm("mov %0=cpuid[%1]" : "=r"(sn) : "r"(2)); sn = SNMAGIC;})
 
+#ifdef CONFIG_IA64_SGI_SN_SIM
+#define SIMULATOR_SLEEP()		asm("nop.i 0x8beef")
+#define IS_RUNNING_ON_SIMULATOR() 	(sn_prom_type)
+#define IS_RUNNING_ON_FAKE_PROM()	(sn_prom_type = 2)
+extern int sn_prom_type;		/* 0=hardware, 1=medusa/realprom, 2=medusa/fakeprom */
 #else
-
 #define IS_RUNNING_ON_SIMULATOR()	(0)
+#define IS_RUNNING_ON_FAKE_PROM()	(0)
 #define SIMULATOR_SLEEP()
 
 #endif
-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


