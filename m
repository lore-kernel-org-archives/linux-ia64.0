From: dcn@sgi.com (Dean Nelson)
Date: Tue, 22 Mar 2005 16:00:09 +0000
Subject: [PATCH] move nodepda pointer out of pda
Message-Id: <42404109.mailxDBY116VQ1@aqua.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Remove the p_nodepda and p_subnodepda pointers from the pda_s structure.
And then define a new per-cpu pointer to the nodepda and export it so
that it can be accessed by kernel modules.

Signed-off-by: Dean Nelson <dcn@sgi.com>


Index: linux-2.6/include/asm-ia64/sn/nodepda.h
=================================--- linux-2.6.orig/include/asm-ia64/sn/nodepda.h	2005-03-22 08:30:51.277796541 -0600
+++ linux-2.6/include/asm-ia64/sn/nodepda.h	2005-03-22 08:44:56.084327032 -0600
@@ -13,7 +13,6 @@
 #include <asm/irq.h>
 #include <asm/sn/arch.h>
 #include <asm/sn/intr.h>
-#include <asm/sn/pda.h>
 #include <asm/sn/bte.h>
 
 /*
@@ -67,20 +66,18 @@
  * The next set of definitions provides this.
  * Routines are expected to use 
  *
- *	nodepda			-> to access node PDA for the node on which code is running
- *	subnodepda		-> to access subnode PDA for the subnode on which code is running
- *
- *	NODEPDA(cnode)		-> to access node PDA for cnodeid 
- *	SUBNODEPDA(cnode,sn)	-> to access subnode PDA for cnodeid/subnode
+ *	sn_nodepda   - to access node PDA for the node on which code is running
+ *	NODEPDA(cnodeid)   - to access node PDA for cnodeid 
  */
 
-#define	nodepda		pda->p_nodepda		/* Ptr to this node's PDA */
-#define	NODEPDA(cnode)		(nodepda->pernode_pdaindr[cnode])
+DECLARE_PER_CPU(struct nodepda_s *, __sn_nodepda);
+#define sn_nodepda		(__get_cpu_var(__sn_nodepda))
+#define	NODEPDA(cnodeid)	(sn_nodepda->pernode_pdaindr[cnodeid])
 
 /*
  * Check if given a compact node id the corresponding node has all the
  * cpus disabled. 
  */
-#define is_headless_node(cnode)		(nr_cpus_node(cnode) = 0)
+#define is_headless_node(cnodeid)	(nr_cpus_node(cnodeid) = 0)
 
 #endif /* _ASM_IA64_SN_NODEPDA_H */
Index: linux-2.6/include/asm-ia64/sn/pda.h
=================================--- linux-2.6.orig/include/asm-ia64/sn/pda.h	2005-03-22 08:30:51.277796541 -0600
+++ linux-2.6/include/asm-ia64/sn/pda.h	2005-03-22 08:31:54.704863833 -0600
@@ -24,14 +24,6 @@
 
 typedef struct pda_s {
 
-	/* Having a pointer in the begining of PDA tends to increase
-	 * the chance of having this pointer in cache. (Yes something
-	 * else gets pushed out). Doing this reduces the number of memory
-	 * access to all nodepda variables to be one
-	 */
-	struct nodepda_s *p_nodepda;		/* Pointer to Per node PDA */
-	struct subnodepda_s *p_subnodepda;	/* Pointer to CPU  subnode PDA */
-
 	/*
 	 * Support for SN LEDs
 	 */
Index: linux-2.6/arch/ia64/sn/kernel/setup.c
=================================--- linux-2.6.orig/arch/ia64/sn/kernel/setup.c	2005-03-22 08:30:51.278773093 -0600
+++ linux-2.6/arch/ia64/sn/kernel/setup.c	2005-03-22 08:53:45.031336470 -0600
@@ -75,6 +75,9 @@
 DEFINE_PER_CPU(short, __sn_cnodeid_to_nasid[MAX_NUMNODES]);
 EXPORT_PER_CPU_SYMBOL(__sn_cnodeid_to_nasid);
 
+DEFINE_PER_CPU(struct nodepda_s *, __sn_nodepda);
+EXPORT_PER_CPU_SYMBOL(__sn_nodepda);
+
 partid_t sn_partid = -1;
 EXPORT_SYMBOL(sn_partid);
 char sn_system_serial_number_string[128];
@@ -471,7 +474,8 @@
 
 	cnode = nasid_to_cnodeid(nasid);
 
-	pda->p_nodepda = nodepdaindr[cnode];
+	sn_nodepda = nodepdaindr[cnode];
+
 	pda->led_address  	    (typeof(pda->led_address)) (LED0 + (slice << LED_CPU_SHIFT));
 	pda->led_state = LED_ALWAYS_SET;
@@ -617,7 +621,8 @@
 	long cpu;
 	
 	for (cpu=0; cpu < NR_CPUS; cpu++) 
-		if (nodepda->phys_cpuid[cpu].nasid = nasid && nodepda->phys_cpuid[cpu].slice = slice)
+		if (cpuid_to_nasid(cpu) = nasid &&
+					cpuid_to_slice(cpu) = slice)
 			return cpu;
 
 	return -1;
Index: linux-2.6/include/asm-ia64/sn/sn_cpuid.h
=================================--- linux-2.6.orig/include/asm-ia64/sn/sn_cpuid.h	2005-03-22 08:25:09.969861289 -0600
+++ linux-2.6/include/asm-ia64/sn/sn_cpuid.h	2005-03-22 08:47:12.532938412 -0600
@@ -92,24 +92,24 @@
  * NOTE: on non-MP systems, only cpuid 0 exists
  */
 
-extern short physical_node_map[];			/* indexed by nasid to get cnode */
+extern short physical_node_map[];	/* indexed by nasid to get cnode */
 
 /*
  * Macros for retrieving info about current cpu
  */
-#define get_nasid()			(nodepda->phys_cpuid[smp_processor_id()].nasid)
-#define get_subnode()			(nodepda->phys_cpuid[smp_processor_id()].subnode)
-#define get_slice()			(nodepda->phys_cpuid[smp_processor_id()].slice)
-#define get_cnode()			(nodepda->phys_cpuid[smp_processor_id()].cnode)
-#define get_sapicid()			((ia64_getreg(_IA64_REG_CR_LID) >> 16) & 0xffff)
+#define get_nasid()	(sn_nodepda->phys_cpuid[smp_processor_id()].nasid)
+#define get_subnode()	(sn_nodepda->phys_cpuid[smp_processor_id()].subnode)
+#define get_slice()	(sn_nodepda->phys_cpuid[smp_processor_id()].slice)
+#define get_cnode()	(sn_nodepda->phys_cpuid[smp_processor_id()].cnode)
+#define get_sapicid()	((ia64_getreg(_IA64_REG_CR_LID) >> 16) & 0xffff)
 
 /*
  * Macros for retrieving info about an arbitrary cpu
  *	cpuid - logical cpu id
  */
-#define cpuid_to_nasid(cpuid)		(nodepda->phys_cpuid[cpuid].nasid)
-#define cpuid_to_subnode(cpuid)		(nodepda->phys_cpuid[cpuid].subnode)
-#define cpuid_to_slice(cpuid)		(nodepda->phys_cpuid[cpuid].slice)
+#define cpuid_to_nasid(cpuid)		(sn_nodepda->phys_cpuid[cpuid].nasid)
+#define cpuid_to_subnode(cpuid)		(sn_nodepda->phys_cpuid[cpuid].subnode)
+#define cpuid_to_slice(cpuid)		(sn_nodepda->phys_cpuid[cpuid].slice)
 #define cpuid_to_cnodeid(cpuid)		(physical_node_map[cpuid_to_nasid(cpuid)])
 
 
