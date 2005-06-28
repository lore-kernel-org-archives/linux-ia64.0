From: Jack Steiner <steiner@sgi.com>
Date: Tue, 28 Jun 2005 16:58:38 +0000
Subject: [PATCH] - Updated macros for SGI simulator
Message-Id: <20050628165837.GA25940@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

We need to update the kernel support for medusa. 

Currently, there is 1 macro for testing whether the kernel is running on the 
simulator. This works ok if you are running on medusa and using the fake PROM.
Now that we have started to run kernels using the REAL PROM, we need a few changes.
Some places in the kernel need to determine whether it is running on hardware,
medusa with real PROM, or medusa with fake PROM. 

An example is the code that initializes the IO infrastructure. The fakeprom does
not support the SAL calls required to initialize the IO tables; the real PROM
(even when running on medusa) does support the SAL calls.

The changes are trivial and there is very little possible of unforseen sideeffects.
All changes are in the SN-specific part of the tree.

 arch/ia64/sn/kernel/io_init.c   |    2 +-
 arch/ia64/sn/kernel/setup.c     |   11 ++++++++++-
 include/asm-ia64/sn/simulator.h |   13 +++++++------
 include/asm-ia64/sn/sn_sal.h    |   11 +++++++++++
 4 files changed, 29 insertions(+), 8 deletions(-)


 Signed-off-by: Jack Steiner <steiner@sgi.com>


Index: linux/include/asm-ia64/sn/sn_sal.h
=================================--- linux.orig/include/asm-ia64/sn/sn_sal.h	2005-06-27 08:27:58.682403803 -0500
+++ linux/include/asm-ia64/sn/sn_sal.h	2005-06-28 11:47:16.801424471 -0500
@@ -80,6 +80,9 @@
 #define SN_SAL_BTE_RECOVER			   0x02000061
 #define SN_SAL_IOIF_GET_PCI_TOPOLOGY	           0x02000062
 
+#define SN_SAL_FAKE_PROM			   0x02009999	// defined in fakeprom ONLY!!
+
+
 /*
  * Service-specific constants
  */
@@ -1105,4 +1108,12 @@ ia64_sn_bte_recovery(nasid_t nasid)
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
=================================--- linux.orig/arch/ia64/sn/kernel/io_init.c	2005-06-27 08:27:50.069216187 -0500
+++ linux/arch/ia64/sn/kernel/io_init.c	2005-06-28 11:42:36.648191948 -0500
@@ -384,7 +384,7 @@ static int __init sn_pci_init(void)
 	extern void register_sn_procfs(void);
 #endif
 
-	if (!ia64_platform_is("sn2") || IS_RUNNING_ON_SIMULATOR())
+	if (!ia64_platform_is("sn2") || IS_RUNNING_ON_FAKE_PROM())
 		return 0;
 
 	/*
Index: linux/arch/ia64/sn/kernel/setup.c
=================================--- linux.orig/arch/ia64/sn/kernel/setup.c	2005-06-27 08:27:50.072145843 -0500
+++ linux/arch/ia64/sn/kernel/setup.c	2005-06-28 11:42:36.649168412 -0500
@@ -95,6 +95,7 @@ u8 sn_coherency_id;
 EXPORT_SYMBOL(sn_coherency_id);
 u8 sn_region_size;
 EXPORT_SYMBOL(sn_region_size);
+int sn_prom_type;	/* 0=hardware, 1=medusa/realprom, 2=medusa/fakeprom */
 
 short physical_node_map[MAX_PHYSNODE_ID];
 
@@ -455,6 +456,14 @@ void __init sn_cpu_init(void)
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
@@ -563,7 +572,7 @@ static void __init scan_for_ionodes(void
 		cnodeid = -1;
 		klgraph_header = __va(ia64_sn_get_klconfig_addr(nasid));
 		if (!klgraph_header) {
-			if (IS_RUNNING_ON_SIMULATOR())
+			if (IS_RUNNING_ON_FAKE_PROM())
 				continue;
 			BUG();	/* All nodes must have klconfig tables! */
 		}
Index: linux/include/asm-ia64/sn/simulator.h
=================================--- linux.orig/include/asm-ia64/sn/simulator.h	2005-06-27 08:27:58.679474147 -0500
+++ linux/include/asm-ia64/sn/simulator.h	2005-06-28 11:42:36.650144875 -0500
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


