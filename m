From: Jack Steiner <steiner@sgi.com>
Date: Tue, 26 Oct 2004 11:46:49 +0000
Subject: [PATCH] - Update asm-ia64/sn/sn_cpuid.h macros
Message-Id: <20041026114649.GA12741@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Tony - please apply


SGI SN code currently makes assumptions about the bits in the LID
register. These assumptions do not conform to the bit specifications
from Intel. For example, SN currently assumes that bits [28:16] of 
the LID contain the physical node ID of a node.

This patch eliminates these assumptions. A SAL call is now used to translate
LID values to the NASID/subnode/slice values that are needed for SN
platforms. The results of the SAL call are saved in the SN nodepda.

----

Signed-off-by: Jack Steiner <steiner@sgi.com>


----



================ arch/ia64/sn/kernel/irq.c ==================
--- linux_base/arch/ia64/sn/kernel/irq.c	2004-10-22 11:36:31 -05:00
+++ linux/arch/ia64/sn/kernel/irq.c	2004-10-23 21:37:44 -05:00
@@ -79,7 +79,7 @@ static void sn_ack_irq(unsigned int irq)
 	int nasid;
 
 	irq = irq & 0xff;
-	nasid = smp_physical_node_id();
+	nasid = get_nasid();
 	event_occurred  	    HUB_L((uint64_t *) GLOBAL_MMR_ADDR(nasid, SH_EVENT_OCCURRED));
 	if (event_occurred & SH_EVENT_OCCURRED_UART_INT_MASK) {
@@ -109,7 +109,7 @@ static void sn_end_irq(unsigned int irq)
 
 	ivec = irq & 0xff;
 	if (ivec = SGI_UART_VECTOR) {
-		nasid = smp_physical_node_id();
+		nasid = get_nasid();
 		event_occurred = HUB_L((uint64_t *) GLOBAL_MMR_ADDR
 				       (nasid, SH_EVENT_OCCURRED));
 		/* If the UART bit is set here, we may have received an 
@@ -141,8 +141,8 @@ static void sn_set_affinity_irq(unsigned
 
 	cpuid = first_cpu(mask);
 	cpuphys = cpu_physical_id(cpuid);
-	t_nasid = cpu_physical_id_to_nasid(cpuphys);
-	t_slice = cpu_physical_id_to_slice(cpuphys);
+	t_nasid = cpuid_to_nasid(cpuid);
+	t_slice = cpuid_to_slice(cpuid);
 
 	while (sn_irq_info) {
 		int status;
================ arch/ia64/sn/kernel/setup.c ==================
--- linux_base/arch/ia64/sn/kernel/setup.c	2004-10-22 11:36:31 -05:00
+++ linux/arch/ia64/sn/kernel/setup.c	2004-10-25 16:26:55 -05:00
@@ -128,6 +128,19 @@ char drive_info[4 * 16];
 #endif
 
 /*
+ * Get nasid of current cpu early in boot before nodepda is initialized
+ */
+static int
+boot_get_nasid(void)
+{
+	int nasid;
+
+	if (ia64_sn_get_sapic_info(get_sapicid(), &nasid, NULL, NULL))
+		BUG();
+	return nasid;
+}
+
+/*
  * This routine can only be used during init, since
  * smp_boot_data is an init data structure.
  * We have to use smp_boot_data.cpu_phys_id to find
@@ -197,7 +210,7 @@ void __init early_sn_setup(void)
 
 	if (IS_RUNNING_ON_SIMULATOR()) {
 		master_node_bedrock_address = (u64 __iomem *)
-			REMOTE_HUB(get_nasid(), SH_JUNK_BUS_UART0);
+			REMOTE_HUB(boot_get_nasid(), SH_JUNK_BUS_UART0);
 		printk(KERN_DEBUG "early_sn_setup: setting "
 		       "master_node_bedrock_address to 0x%p\n",
 		       master_node_bedrock_address);
@@ -297,7 +310,7 @@ void __init sn_setup(char **cmdline_p)
 		panic("PROM version too old\n");
 	}
 
-	master_nasid = get_nasid();
+	master_nasid = boot_get_nasid();
 
 	status  	    ia64_sal_freq_base(SAL_FREQ_BASE_REALTIME_CLOCK, &ticks_per_sec,
@@ -314,7 +327,7 @@ void __init sn_setup(char **cmdline_p)
 
 	if (IS_RUNNING_ON_SIMULATOR()) {
 		master_node_bedrock_address = (u64 __iomem *)
-			REMOTE_HUB(get_nasid(), SH_JUNK_BUS_UART0);
+			REMOTE_HUB(boot_get_nasid(), SH_JUNK_BUS_UART0);
 		printk(KERN_DEBUG "sn_setup: setting "
 		       "master_node_bedrock_address to 0x%p\n",
 		       master_node_bedrock_address);
@@ -372,6 +385,8 @@ void __init sn_init_pdas(char **cmdline_
 		nodepdaindr[cnode]  		    alloc_bootmem_node(NODE_DATA(cnode), sizeof(nodepda_t));
 		memset(nodepdaindr[cnode], 0, sizeof(nodepda_t));
+		memset(nodepdaindr[cnode]->phys_cpuid, -1, 
+		    sizeof(nodepdaindr[cnode]->phys_cpuid));
 	}
 
 	/*
@@ -422,8 +437,10 @@ void __init sn_cpu_init(void)
 	int cpuid;
 	int cpuphyid;
 	int nasid;
+	int subnode;
 	int slice;
 	int cnode;
+	int i;
 	static int wars_have_been_checked;
 
 	/*
@@ -434,10 +451,20 @@ void __init sn_cpu_init(void)
 		return;
 
 	cpuid = smp_processor_id();
-	cpuphyid = ((ia64_getreg(_IA64_REG_CR_LID) >> 16) & 0xffff);
-	nasid = cpu_physical_id_to_nasid(cpuphyid);
+	cpuphyid = get_sapicid();
+
+	if (ia64_sn_get_sapic_info(cpuphyid, &nasid, &subnode, &slice))
+		BUG();
+
+	for (i=0; i < NR_NODES; i++) {
+		if (nodepdaindr[i]) {
+			nodepdaindr[i]->phys_cpuid[cpuid].nasid = nasid;
+			nodepdaindr[i]->phys_cpuid[cpuid].slice = slice;
+			nodepdaindr[i]->phys_cpuid[cpuid].subnode = subnode;
+		}
+	}
+
 	cnode = nasid_to_cnodeid(nasid);
-	slice = cpu_physical_id_to_slice(cpuphyid);
 
 	memset(pda, 0, sizeof(pda));
 	pda->p_nodepda = nodepdaindr[cnode];
@@ -574,4 +601,16 @@ static void __init scan_for_ionodes(void
 		}
 	}
 
+}
+
+int
+nasid_slice_to_cpuid(int nasid, int slice)
+{
+	long cpu;
+	
+	for (cpu=0; cpu < NR_CPUS; cpu++) 
+		if (nodepda->phys_cpuid[cpu].nasid = nasid && nodepda->phys_cpuid[cpu].slice = slice)
+			return cpu;
+
+	return -1;
 }
================ arch/ia64/sn/kernel/sn2/sn2_smp.c ==================
--- linux_base/arch/ia64/sn/kernel/sn2/sn2_smp.c	2004-10-22 11:36:31 -05:00
+++ linux/arch/ia64/sn/kernel/sn2/sn2_smp.c	2004-10-23 21:34:42 -05:00
@@ -32,6 +32,7 @@
 #include <asm/hw_irq.h>
 #include <asm/current.h>
 #include <asm/sn/sn_cpuid.h>
+#include <asm/sn/sn_sal.h>
 #include <asm/sn/addrs.h>
 #include <asm/sn/shub_mmr.h>
 #include <asm/sn/nodepda.h>
@@ -136,7 +137,7 @@ sn2_global_tlb_purge(unsigned long start
 	ptc0 = (long *)GLOBAL_MMR_PHYS_ADDR(0, SH_PTC_0);
 	ptc1 = (long *)GLOBAL_MMR_PHYS_ADDR(0, SH_PTC_1);
 
-	mynasid = smp_physical_node_id();
+	mynasid = get_nasid();
 
 	spin_lock_irqsave(&sn2_global_ptc_lock, flags);
 
@@ -205,6 +206,7 @@ void sn2_ptc_deadlock_recovery(unsigned 
 
 /**
  * sn_send_IPI_phys - send an IPI to a Nasid and slice
+ * @nasid: nasid to receive the interrupt (may be outside partition)
  * @physid: physical cpuid to receive the interrupt.
  * @vector: command to send
  * @delivery_mode: delivery mechanism
@@ -219,15 +221,12 @@ void sn2_ptc_deadlock_recovery(unsigned 
  * %IA64_IPI_DM_NMI - pend an NMI
  * %IA64_IPI_DM_INIT - pend an INIT interrupt
  */
-void sn_send_IPI_phys(long physid, int vector, int delivery_mode)
+void sn_send_IPI_phys(int nasid, long physid, int vector, int delivery_mode)
 {
-	long nasid, slice, val;
+	long val;
 	unsigned long flags = 0;
 	volatile long *p;
 
-	nasid = cpu_physical_id_to_nasid(physid);
-	slice = cpu_physical_id_to_slice(physid);
-
 	p = (long *)GLOBAL_MMR_PHYS_ADDR(nasid, SH_IPI_INT);
 	val = (1UL << SH_IPI_INT_SEND_SHFT) |
 	    (physid << SH_IPI_INT_PID_SHFT) |
@@ -268,8 +267,14 @@ EXPORT_SYMBOL(sn_send_IPI_phys);
 void sn2_send_IPI(int cpuid, int vector, int delivery_mode, int redirect)
 {
 	long physid;
+	int nasid;
 
 	physid = cpu_physical_id(cpuid);
+	nasid = cpuid_to_nasid(cpuid);
+
+	/* the following is used only when starting cpus at boot time */
+	if (unlikely(nasid = -1))
+		ia64_sn_get_sapic_info(physid, &nasid, NULL, NULL);
 
-	sn_send_IPI_phys(physid, vector, delivery_mode);
+	sn_send_IPI_phys(nasid, physid, vector, delivery_mode);
 }
================ arch/ia64/sn/kernel/sn2/sn_proc_fs.c ==================
--- linux_base/arch/ia64/sn/kernel/sn2/sn_proc_fs.c	2004-10-22 11:36:31 -05:00
+++ linux/arch/ia64/sn/kernel/sn2/sn_proc_fs.c	2004-10-23 07:06:26 -05:00
@@ -80,7 +80,8 @@ static int sn_force_interrupt_open(struc
 
 static int coherence_id_show(struct seq_file *s, void *p)
 {
-	seq_printf(s, "%d\n", cpuid_to_coherence_id(smp_processor_id()));
+	seq_printf(s, "%d\n", partition_coherence_id());
+
 	return 0;
 }
 
================ include/asm-ia64/sn/sn_cpuid.h ==================
--- linux_base/include/asm-ia64/sn/sn_cpuid.h	2004-10-22 11:36:41 -05:00
+++ linux/include/asm-ia64/sn/sn_cpuid.h	2004-10-25 16:28:05 -05:00
@@ -7,6 +7,7 @@
  * Copyright (C) 2000-2004 Silicon Graphics, Inc. All rights reserved.
  */
 
+
 #ifndef _ASM_IA64_SN_SN_CPUID_H
 #define _ASM_IA64_SN_SN_CPUID_H
 
@@ -35,9 +36,6 @@
  *		the boot cpu is 0.
  *			smp_processor_id() returns the cpuid of the current cpu.
  *
- *	   CPUNUM - On IA64, a cpunum and cpuid are the same. This is NOT true
- *		on other architectures like IA32.
- *
  * 	   CPU_PHYSICAL_ID (also known as HARD_PROCESSOR_ID)
  *		This is the same as 31:24 of the processor LID register
  *			hard_smp_processor_id()- cpu_physical_id of current processor
@@ -45,16 +43,16 @@
  *			cpu_logical_id(phy_id) - convert a <physical_cpuid> to a <cpuid> 
  *				* not real efficient - don't use in perf critical code
  *
- *         LID - processor defined register (see PRM V2).
+ *         SLICE - a number in the range of 0 - 3 (typically) that represents the
+ *		cpu number on a brick.
  *
- *           On SN2
- *		31:28 - id   Contains 0-3 to identify the cpu on the node
- *		27:16 - eid  Contains the NASID
+ *	   SUBNODE - (almost obsolete) the number of the FSB that a cpu is
+ *		connected to. This is also the same as the PI number. Usually 0 or 1.
  *
+ *	NOTE!!!: the value of the bits in the cpu physical id (SAPICid or LID) of a cpu has no 
+ *	significance. The SAPIC id (LID) is a 16-bit cookie that has meaning only to the PROM.
  *
  *
- * The following assumes the following mappings for LID register values:
- *
  * The macros convert between cpu physical ids & slice/nasid/cnodeid.
  * These terms are described below:
  *
@@ -83,19 +81,11 @@
  */
 
 #ifndef CONFIG_SMP
-#define cpu_logical_id(cpu)				0
+#define cpu_logical_id(cpu)			0
 #define cpu_physical_id(cpuid)			((ia64_getreg(_IA64_REG_CR_LID) >> 16) & 0xffff)
 #endif
 
-/*
- * macros for some of these exist in sn/addrs.h & sn/arch.h, etc. However, 
- * trying #include these files here causes circular dependencies.
- */
-#define cpu_physical_id_to_nasid(cpi)		((cpi) &0xfff)
-#define cpu_physical_id_to_slice(cpi)		((cpi>>12) & 3)
-#define cpu_physical_id_to_coherence_id(cpi)	(((cpi) & 0x600) >> 9)
-#define get_nasid()				((ia64_getreg(_IA64_REG_CR_LID) >> 16) & 0xfff)
-#define get_slice()				((ia64_getreg(_IA64_REG_CR_LID) >> 28) & 0xf)
+
 #define get_node_number(addr)			(((unsigned long)(addr)>>38) & 0x7ff)
 
 /*
@@ -103,43 +93,35 @@
  * 
  * NOTE: on non-MP systems, only cpuid 0 exists
  */
-#define id_eid_to_cpu_physical_id(id,eid)	 	(((id)<<8) | (eid))
-
-#define nasid_slice_to_cpuid(nasid,slice)		(cpu_logical_id(nasid_slice_to_cpu_physical_id((nasid),(slice))))
-
-#define nasid_slice_to_cpu_physical_id(nasid, slice)	(((slice)<<12) | (nasid))
 
-/*
- * The following table/struct  is used for managing PTC coherency domains.
- */
-typedef struct {
-	u8	domain;
-	u8	reserved;
-	u16	sapicid;
-} sn_sapicid_info_t;
-
-extern sn_sapicid_info_t	sn_sapicid_info[];	/* indexed by cpuid */
 extern short physical_node_map[];			/* indexed by nasid to get cnode */
 
-
 /*
- * cpuid_to_slice  - convert a cpuid to the slice that it resides on
- *  There are 4 cpus per node. This function returns 0 .. 3)
+ * Macros for retrieving info about current cpu
  */
-#define cpuid_to_slice(cpuid)		(cpu_physical_id_to_slice(cpu_physical_id(cpuid)))
-
+#define get_nasid()			(nodepda->phys_cpuid[smp_processor_id()].nasid)
+#define get_subnode()			(nodepda->phys_cpuid[smp_processor_id()].subnode)
+#define get_slice()			(nodepda->phys_cpuid[smp_processor_id()].slice)
+#define get_cnode()			(nodepda->phys_cpuid[smp_processor_id()].cnode)
+#define get_sapicid()			((ia64_getreg(_IA64_REG_CR_LID) >> 16) & 0xffff)
 
 /*
- * cpuid_to_nasid  - convert a cpuid to the NASID that it resides on
+ * Macros for retrieving info about an arbitrary cpu
+ *	cpuid - logical cpu id
  */
-#define cpuid_to_nasid(cpuid)		(cpu_physical_id_to_nasid(cpu_physical_id(cpuid)))
+#define cpuid_to_nasid(cpuid)		(nodepda->phys_cpuid[cpuid].nasid)
+#define cpuid_to_subnode(cpuid)		(nodepda->phys_cpuid[cpuid].subnode)
+#define cpuid_to_slice(cpuid)		(nodepda->phys_cpuid[cpuid].slice)
+#define cpuid_to_cnodeid(cpuid)		(physical_node_map[cpuid_to_nasid(cpuid)])
 
 
 /*
- * cpuid_to_cnodeid  - convert a cpuid to the cnode that it resides on
+ * Dont use the following in performance critical code. They require scans
+ * of potentially large tables.
  */
-#define cpuid_to_cnodeid(cpuid)		(physical_node_map[cpuid_to_nasid(cpuid)])
-
+extern int nasid_slice_to_cpuid(int, int);
+#define nasid_slice_to_cpu_physical_id(nasid, slice)			\
+	cpu_physical_id(nasid_slice_to_cpuid(nasid, slice))
 
 /*
  * cnodeid_to_nasid - convert a cnodeid to a NASID
@@ -149,36 +131,15 @@ extern short physical_node_map[];			/* i
  */
 #define cnodeid_to_nasid(cnodeid)	pda->cnodeid_to_nasid_table[cnodeid]
  
-
 /*
  * nasid_to_cnodeid - convert a NASID to a cnodeid
  */
 #define nasid_to_cnodeid(nasid)		(physical_node_map[nasid])
 
-
-/*
- * cnode_slice_to_cpuid - convert a codeid & slice to a cpuid
- */
-
-#define cnode_slice_to_cpuid(cnodeid,slice) (nasid_slice_to_cpuid(cnodeid_to_nasid(cnodeid),(slice)))
- 
-
 /*
- * cpuid_to_subnode - convert a cpuid to the subnode it resides on.
- *   slice 0 & 1 are on subnode 0
- *   slice 2 & 3 are on subnode 1.
+ * partition_coherence_id - cget the coherence ID of the current partition
  */
-#define cpuid_to_subnode(cpuid)		((cpuid_to_slice(cpuid)<2) ? 0 : 1)
- 
-
-#define smp_physical_node_id()			(cpuid_to_nasid(smp_processor_id()))
-
-/*
- * cpuid_to_coherence_id - convert a cpuid to the coherence domain id it
- * resides on
- */
-#define cpuid_to_coherence_id(cpuid)    cpu_physical_id_to_coherence_id(cpu_physical_id(cpuid))
-
+#define partition_coherence_id()	(get_nasid() >> 9)
 
 #endif /* _ASM_IA64_SN_SN_CPUID_H */
 
================ include/asm-ia64/sn/intr.h ==================
--- linux_base/include/asm-ia64/sn/intr.h	2004-10-22 11:36:41 -05:00
+++ linux/include/asm-ia64/sn/intr.h	2004-10-23 07:07:13 -05:00
@@ -43,7 +43,7 @@ struct sn_irq_info {
 	int		irq_share_cnt;	/* num devices sharing IRQ   */
 };
 
-extern void sn_send_IPI_phys(long, int, int);
+extern void sn_send_IPI_phys(int, long, int, int);
 
 #define CPU_VECTOR_TO_IRQ(cpuid,vector) (vector)
 
================ include/asm-ia64/sn/nodepda.h ==================
--- linux_base/include/asm-ia64/sn/nodepda.h	2004-10-22 11:36:41 -05:00
+++ linux/include/asm-ia64/sn/nodepda.h	2004-10-23 07:09:34 -05:00
@@ -30,6 +30,12 @@
  * This structure provides a convenient way of keeping together 
  * all per-node data structures. 
  */
+struct phys_cpuid {
+	short			nasid;
+	char			subnode;
+	char			slice;
+};
+
 struct nodepda_s {
 	void 		*pdinfo;	/* Platform-dependent per-node info */
 	spinlock_t		bist_lock;
@@ -46,6 +52,10 @@ struct nodepda_s {
 	 */
 	struct nodepda_s	*pernode_pdaindr[MAX_COMPACT_NODES]; 
 
+	/*
+	 * Array of physical cpu identifiers. Indexed by cpuid.
+	 */
+	struct phys_cpuid	phys_cpuid[NR_CPUS];
 };
 
 typedef struct nodepda_s nodepda_t;
================ include/asm-ia64/sn/sn_sal.h ==================
--- linux_base/include/asm-ia64/sn/sn_sal.h	2004-10-22 11:36:41 -05:00
+++ linux/include/asm-ia64/sn/sn_sal.h	2004-10-23 07:15:31 -05:00
@@ -31,6 +31,7 @@
 #define  SN_SAL_NO_FAULT_ZONE_VIRTUAL		   0x02000010
 #define  SN_SAL_NO_FAULT_ZONE_PHYSICAL		   0x02000011
 #define  SN_SAL_PRINT_ERROR			   0x02000012
+#define  SN_SAL_GET_SAPIC_INFO                     0x02009999	//ZZZZ fix
 #define  SN_SAL_SET_ERROR_HANDLING_FEATURES	   0x0200001a	// reentrant
 #define  SN_SAL_GET_FIT_COMPT			   0x0200001b	// reentrant
 #define  SN_SAL_CONSOLE_PUTC                       0x02000021
@@ -843,6 +844,37 @@ ia64_sn_irtr_init(nasid_t nasid, void *b
 	return (int) rv.status;
 }
 
+/*
+ * Returns the nasid, subnode & slice corresponding to a SAPIC ID
+ */
+static inline u64
+ia64_sn_get_sapic_info(int sapicid, int *nasid, int *subnode, int *slice)
+{
+	struct ia64_sal_retval ret_stuff;
+
+	ret_stuff.status = 0;
+	ret_stuff.v0 = 0;
+	ret_stuff.v1 = 0;
+	ret_stuff.v2 = 0;
+	SAL_CALL_NOLOCK(ret_stuff, SN_SAL_GET_SAPIC_INFO, sapicid, 0, 0, 0, 0, 0, 0);
+
+/***** BEGIN HACK - temp til new proms available ********/
+	if (ret_stuff.status = SALRET_NOT_IMPLEMENTED) {
+		if (nasid) *nasid = sapicid & 0xfff;
+		if (subnode) *subnode = (sapicid >> 13) & 1;
+		if (slice) *slice = (sapicid >> 12) & 3;
+		return 0;
+	}
+/***** END HACK *******/
+
+	if (ret_stuff.status < 0)
+		return ret_stuff.status;
+
+	if (nasid) *nasid = (int) ret_stuff.v0;
+	if (subnode) *subnode = (int) ret_stuff.v1;
+	if (slice) *slice = (int) ret_stuff.v2;
+	return 0;
+}
 /*
  * This is the access point to the Altix PROM hardware performance
  * and status monitoring interface. For info on using this, see
-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


