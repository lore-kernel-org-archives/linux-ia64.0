From: Jack Steiner <steiner@sgi.com>
Date: Mon, 12 Sep 2005 17:15:43 +0000
Subject: [PATCH] - Cleanup use of various #defines related to nodes
Message-Id: <20050912171542.GA10992@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Some of the SN code & #defines related to compact nodes & IO discovery
have gotten stale over the years. This patch attempts to clean them up. 
Some of the various SN MAX_xxx #defines were also unclear & misused.

The primary changes are:

	- use MAX_NUMNODES. This is the generic linux #define for the number
	  of nodes that are known to the generic kernel. Arrays & loops
	  for constructs that are 1:1 with linux-defined nodes should
	  use the linux #define - not an SN equivalent. 

	- use MAX_COMPACT_NODES for MAX_NUMNODES + NUM_TIOS. This is the
	  number of nodes in the SSI system. Compact nodes are a hack to 
	  get around the IA64 architectural limit of 256 nodes. Large SGI
	  systems have more than 256 nodes. When we upgrade to ACPI3.0, 
	  I _hope_ that all nodes will be real nodes that are known to 
	  the generic kernel. That will allow us to delete the notion
	  of "compact nodes".

	- add MAX_NUMALINK_NODES for the total number of nodes that
	  are in the numalink domain - all partitions.

	- simplified (understandable) scan_for_ionodes()

	- small amount of cleanup related to cnodes
	

	Signed-off-by: Jack Steiner <steiner@sgi.com>

 arch/ia64/sn/kernel/io_init.c       |    4 
 arch/ia64/sn/kernel/setup.c         |  162 +++++++++++-------------------------
 arch/ia64/sn/kernel/sn2/sn_hwperf.c |    4 
 arch/ia64/sn/kernel/tiocx.c         |    5 -
 arch/ia64/sn/kernel/xpc_partition.c |    2 
 drivers/char/snsc.c                 |    4 
 include/asm-ia64/sn/arch.h          |   36 +++++---
 include/asm-ia64/sn/io.h            |    2 
 include/asm-ia64/sn/klconfig.h      |   34 -------
 include/asm-ia64/sn/sn_cpuid.h      |    3 
 include/asm-ia64/sn/sn_sal.h        |   12 --
 include/asm-ia64/sn/xp.h            |    2 
 12 files changed, 93 insertions(+), 177 deletions(-)


Index: linux/arch/ia64/sn/kernel/setup.c
=================================--- linux.orig/arch/ia64/sn/kernel/setup.c	2005-09-12 10:40:09.791149924 -0500
+++ linux/arch/ia64/sn/kernel/setup.c	2005-09-12 11:49:10.783319504 -0500
@@ -59,8 +59,6 @@ DEFINE_PER_CPU(struct pda_s, pda_percpu)
 
 #define MAX_PHYS_MEMORY		(1UL << IA64_MAX_PHYS_BITS)	/* Max physical address supported */
 
-lboard_t *root_lboard[MAX_COMPACT_NODES];
-
 extern void bte_init_node(nodepda_t *, cnodeid_t);
 
 extern void sn_timer_init(void);
@@ -97,15 +95,15 @@ u8 sn_region_size;
 EXPORT_SYMBOL(sn_region_size);
 int sn_prom_type;	/* 0=hardware, 1=medusa/realprom, 2=medusa/fakeprom */
 
-short physical_node_map[MAX_PHYSNODE_ID];
+short physical_node_map[MAX_NUMALINK_NODES];
 static unsigned long sn_prom_features[MAX_PROM_FEATURE_SETS];
 
 EXPORT_SYMBOL(physical_node_map);
 
-int numionodes;
+int num_cnodes;
 
 static void sn_init_pdas(char **);
-static void scan_for_ionodes(void);
+static void build_cnode_tables(void);
 
 static nodepda_t *nodepdaindr[MAX_COMPACT_NODES];
 
@@ -140,19 +138,6 @@ char drive_info[4 * 16];
 #endif
 
 /*
- * Get nasid of current cpu early in boot before nodepda is initialized
- */
-static int
-boot_get_nasid(void)
-{
-	int nasid;
-
-	if (ia64_sn_get_sapic_info(get_sapicid(), &nasid, NULL, NULL))
-		BUG();
-	return nasid;
-}
-
-/*
  * This routine can only be used during init, since
  * smp_boot_data is an init data structure.
  * We have to use smp_boot_data.cpu_phys_id to find
@@ -223,7 +208,6 @@ void __init early_sn_setup(void)
 }
 
 extern int platform_intr_list[];
-extern nasid_t master_nasid;
 static int __initdata shub_1_1_found = 0;
 
 /*
@@ -269,7 +253,6 @@ static void __init sn_check_for_wars(voi
 void __init sn_setup(char **cmdline_p)
 {
 	long status, ticks_per_sec, drift;
-	int pxm;
 	u32 version = sn_sal_rev();
 	extern void sn_cpu_init(void);
 
@@ -300,11 +283,10 @@ void __init sn_setup(char **cmdline_p)
 
 	MAX_DMA_ADDRESS = PAGE_OFFSET + MAX_PHYS_MEMORY;
 
-	memset(physical_node_map, -1, sizeof(physical_node_map));
-	for (pxm = 0; pxm < MAX_PXM_DOMAINS; pxm++)
-		if (pxm_to_nid_map[pxm] != -1)
-			physical_node_map[pxm_to_nasid(pxm)] -			    pxm_to_nid_map[pxm];
+	/*
+	 * Build the tables for managing cnodes.
+	 */
+	build_cnode_tables();
 
 	/*
 	 * Old PROMs do not provide an ACPI FADT. Disable legacy keyboard
@@ -319,8 +301,6 @@ void __init sn_setup(char **cmdline_p)
 
 	printk("SGI SAL version %x.%02x\n", version >> 8, version & 0x00FF);
 
-	master_nasid = boot_get_nasid();
-
 	status  	    ia64_sal_freq_base(SAL_FREQ_BASE_REALTIME_CLOCK, &ticks_per_sec,
 			       &drift);
@@ -378,15 +358,6 @@ static void __init sn_init_pdas(char **c
 {
 	cnodeid_t cnode;
 
-	memset(sn_cnodeid_to_nasid, -1,
-			sizeof(__ia64_per_cpu_var(__sn_cnodeid_to_nasid)));
-	for_each_online_node(cnode)
-		sn_cnodeid_to_nasid[cnode] -				pxm_to_nasid(nid_to_pxm_map[cnode]);
-
-	numionodes = num_online_nodes();
-	scan_for_ionodes();
-
 	/*
 	 * Allocate & initalize the nodepda for each node.
 	 */
@@ -402,7 +373,7 @@ static void __init sn_init_pdas(char **c
 	/*
 	 * Allocate & initialize nodepda for TIOs.  For now, put them on node 0.
 	 */
-	for (cnode = num_online_nodes(); cnode < numionodes; cnode++) {
+	for (cnode = num_online_nodes(); cnode < num_cnodes; cnode++) {
 		nodepdaindr[cnode]  		    alloc_bootmem_node(NODE_DATA(0), sizeof(nodepda_t));
 		memset(nodepdaindr[cnode], 0, sizeof(nodepda_t));
@@ -411,7 +382,7 @@ static void __init sn_init_pdas(char **c
 	/*
 	 * Now copy the array of nodepda pointers to each nodepda.
 	 */
-	for (cnode = 0; cnode < numionodes; cnode++)
+	for (cnode = 0; cnode < num_cnodes; cnode++)
 		memcpy(nodepdaindr[cnode]->pernode_pdaindr, nodepdaindr,
 		       sizeof(nodepdaindr));
 
@@ -428,7 +399,7 @@ static void __init sn_init_pdas(char **c
 	 * Initialize the per node hubdev.  This includes IO Nodes and
 	 * headless/memless nodes.
 	 */
-	for (cnode = 0; cnode < numionodes; cnode++) {
+	for (cnode = 0; cnode < num_cnodes; cnode++) {
 		hubdev_init_node(nodepdaindr[cnode], cnode);
 	}
 }
@@ -553,87 +524,58 @@ void __init sn_cpu_init(void)
 }
 
 /*
- * Scan klconfig for ionodes.  Add the nasids to the
- * physical_node_map and the pda and increment numionodes.
+ * Build tables for converting between NASIDs and cnodes.
  */
+static inline int __init board_needs_cnode(int type)
+{
+	return (type = KLTYPE_SNIA || type = KLTYPE_TIO);
+}
 
-static void __init scan_for_ionodes(void)
+void __init build_cnode_tables(void)
 {
-	int nasid = 0;
+	int nasid;
+	int node;
 	lboard_t *brd;
 
-	/* fakeprom does not support klgraph */
-	if (IS_RUNNING_ON_FAKE_PROM())
-		return;
-
-	/* Setup ionodes with memory */
-	for (nasid = 0; nasid < MAX_PHYSNODE_ID; nasid += 2) {
-		char *klgraph_header;
-		cnodeid_t cnodeid;
-
-		if (physical_node_map[nasid] = -1)
-			continue;
-
-		cnodeid = -1;
-		klgraph_header = __va(ia64_sn_get_klconfig_addr(nasid));
-		if (!klgraph_header) {
-			BUG();	/* All nodes must have klconfig tables! */
-		}
-		cnodeid = nasid_to_cnodeid(nasid);
-		root_lboard[cnodeid] = (lboard_t *)
-		    NODE_OFFSET_TO_LBOARD((nasid),
-					  ((kl_config_hdr_t
-					    *) (klgraph_header))->
-					  ch_board_info);
-	}
-
-	/* Scan headless/memless IO Nodes. */
-	for (nasid = 0; nasid < MAX_PHYSNODE_ID; nasid += 2) {
-		/* if there's no nasid, don't try to read the klconfig on the node */
-		if (physical_node_map[nasid] = -1)
-			continue;
-		brd = find_lboard_any((lboard_t *)
-				      root_lboard[nasid_to_cnodeid(nasid)],
-				      KLTYPE_SNIA);
-		if (brd) {
-			brd = KLCF_NEXT_ANY(brd);	/* Skip this node's lboard */
-			if (!brd)
-				continue;
-		}
+	memset(physical_node_map, -1, sizeof(physical_node_map));
+	memset(sn_cnodeid_to_nasid, -1,
+			sizeof(__ia64_per_cpu_var(__sn_cnodeid_to_nasid)));
 
-		brd = find_lboard_any(brd, KLTYPE_SNIA);
+	/*
+	 * First populate the tables with C/M bricks. This ensures that
+	 * cnode = node for all C & M bricks.
+	 */
+	for_each_online_node(node) {
+		nasid = pxm_to_nasid(nid_to_pxm_map[node]);
+		sn_cnodeid_to_nasid[node] = nasid;
+		physical_node_map[nasid] = node;
+	}
 
-		while (brd) {
-			sn_cnodeid_to_nasid[numionodes] = brd->brd_nasid;
-			physical_node_map[brd->brd_nasid] = numionodes;
-			root_lboard[numionodes] = brd;
-			numionodes++;
-			brd = KLCF_NEXT_ANY(brd);
-			if (!brd)
-				break;
+	/*
+	 * num_cnodes is total number of C/M/TIO bricks. Because of the 256 node
+	 * limit on the number of nodes, we can't use the generic node numbers 
+	 * for this. Note that num_cnodes is incremented below as TIOs or
+	 * headless/memoryless nodes are discovered.
+	 */
+	num_cnodes = num_online_nodes();
 
-			brd = find_lboard_any(brd, KLTYPE_SNIA);
-		}
-	}
+	/* fakeprom does not support klgraph */
+	if (IS_RUNNING_ON_FAKE_PROM())
+		return;
 
-	/* Scan for TIO nodes. */
-	for (nasid = 0; nasid < MAX_PHYSNODE_ID; nasid += 2) {
-		/* if there's no nasid, don't try to read the klconfig on the node */
-		if (physical_node_map[nasid] = -1)
-			continue;
-		brd = find_lboard_any((lboard_t *)
-				      root_lboard[nasid_to_cnodeid(nasid)],
-				      KLTYPE_TIO);
+	/* Find TIOs & headless/memoryless nodes and add them to the tables */
+	for_each_online_node(node) {
+		kl_config_hdr_t *klgraph_header;
+		nasid = cnodeid_to_nasid(node);
+		if ((klgraph_header = ia64_sn_get_klconfig_addr(nasid)) = NULL)
+			BUG();
+		brd = NODE_OFFSET_TO_LBOARD(nasid, klgraph_header->ch_board_info);
 		while (brd) {
-			sn_cnodeid_to_nasid[numionodes] = brd->brd_nasid;
-			physical_node_map[brd->brd_nasid] = numionodes;
-			root_lboard[numionodes] = brd;
-			numionodes++;
-			brd = KLCF_NEXT_ANY(brd);
-			if (!brd)
-				break;
-
-			brd = find_lboard_any(brd, KLTYPE_TIO);
+			if (board_needs_cnode(brd->brd_type) && physical_node_map[brd->brd_nasid] < 0) {
+				sn_cnodeid_to_nasid[num_cnodes] = brd->brd_nasid;
+				physical_node_map[brd->brd_nasid] = num_cnodes++;
+			}
+			brd = find_lboard_next(brd);
 		}
 	}
 }
Index: linux/arch/ia64/sn/kernel/xpc_partition.c
=================================--- linux.orig/arch/ia64/sn/kernel/xpc_partition.c	2005-09-12 10:40:09.804820413 -0500
+++ linux/arch/ia64/sn/kernel/xpc_partition.c	2005-09-12 11:49:10.787225351 -0500
@@ -44,7 +44,7 @@ static u64 xpc_sh2_IPI_access3;
 
 
 /* original protection values for each node */
-u64 xpc_prot_vec[MAX_COMPACT_NODES];
+u64 xpc_prot_vec[MAX_NUMNODES];
 
 
 /* this partition's reserved page */
Index: linux/include/asm-ia64/sn/arch.h
=================================--- linux.orig/include/asm-ia64/sn/arch.h	2005-09-12 10:40:18.784378552 -0500
+++ linux/include/asm-ia64/sn/arch.h	2005-09-12 11:49:10.803825201 -0500
@@ -18,6 +18,32 @@
 #include <asm/sn/sn_cpuid.h>
 
 /*
+ * This is the maximum number of NUMALINK nodes that can be part of a single
+ * SSI kernel. This number includes C-brick, M-bricks, and TIOs. Nodes in
+ * remote partitions are NOT included in this number.
+ * The number of compact nodes cannot exceed size of a coherency domain.
+ * The purpose of this define is to specify a node count that includes
+ * all C/M/TIO nodes in an SSI system.
+ *
+ * SGI system can currently support up to 256 C/M nodes plus additional TIO nodes.
+ *
+ * 	Note: ACPI20 has an architectural limit of 256 nodes. When we upgrade
+ * 	to ACPI3.0, this limit will be removed. The notion of "compact nodes"
+ * 	should be deleted and TIOs should be included in MAX_NUMNODES.
+ */
+#define MAX_COMPACT_NODES	512
+
+/*
+ * Maximum number of nodes in all partitions and in all coherency domains.
+ * This is the total number of nodes accessible in the numalink fabric. It
+ * includes all C & M bricks, plus all TIOs.
+ *
+ * This value is also the value of the maximum number of NASIDs in the numalink
+ * fabric.
+ */
+#define MAX_NUMALINK_NODES	2048
+
+/*
  * The following defines attributes of the HUB chip. These attributes are
  * frequently referenced. They are kept in the per-cpu data areas of each cpu.
  * They are kept together in a struct to minimize cache misses.
@@ -41,15 +67,6 @@ DECLARE_PER_CPU(struct sn_hub_info_s, __
 
 
 /*
- * This is the maximum number of nodes that can be part of a kernel.
- * Effectively, it's the maximum number of compact node ids (cnodeid_t).
- * This is not necessarily the same as MAX_NASIDS.
- */
-#define MAX_COMPACT_NODES	2048
-#define CPUS_PER_NODE		4
-
-
-/*
  * Compact node ID to nasid mappings kept in the per-cpu data areas of each
  * cpu.
  */
@@ -57,7 +74,6 @@ DECLARE_PER_CPU(short, __sn_cnodeid_to_n
 #define sn_cnodeid_to_nasid	(&__get_cpu_var(__sn_cnodeid_to_nasid[0]))
 
 
-
 extern u8 sn_partition_id;
 extern u8 sn_system_size;
 extern u8 sn_sharing_domain_size;
Index: linux/include/asm-ia64/sn/klconfig.h
=================================--- linux.orig/include/asm-ia64/sn/klconfig.h	2005-09-12 10:40:18.786331479 -0500
+++ linux/include/asm-ia64/sn/klconfig.h	2005-09-12 11:49:10.805778125 -0500
@@ -208,19 +208,6 @@ typedef struct lboard_s {
 	klconf_off_t	brd_next_same;    /* Next BOARD with same nasid */
 } lboard_t;
 
-#define KLCF_NUM_COMPS(_brd)	((_brd)->brd_numcompts)
-#define NODE_OFFSET_TO_KLINFO(n,off)    ((klinfo_t*) TO_NODE_CAC(n,off))
-#define KLCF_NEXT(_brd)         \
-        ((_brd)->brd_next_same ?     \
-         (NODE_OFFSET_TO_LBOARD((_brd)->brd_next_same_host, (_brd)->brd_next_same)): NULL)
-#define KLCF_NEXT_ANY(_brd)         \
-        ((_brd)->brd_next_any ?     \
-         (NODE_OFFSET_TO_LBOARD(NASID_GET(_brd), (_brd)->brd_next_any)): NULL)
-#define KLCF_COMP(_brd, _ndx)   \
-                ((((_brd)->brd_compts[(_ndx)]) = 0) ? 0 : \
-			(NODE_OFFSET_TO_KLINFO(NASID_GET(_brd), (_brd)->brd_compts[(_ndx)])))
-
-
 /*
  * Generic info structure. This stores common info about a 
  * component.
@@ -249,24 +236,11 @@ typedef struct klinfo_s {               
 } klinfo_t ;
 
 
-static inline lboard_t *find_lboard_any(lboard_t * start, unsigned char brd_type)
+static inline lboard_t *find_lboard_next(lboard_t * brd)
 {
-        /* Search all boards stored on this node. */
-
-        while (start) {
-                if (start->brd_type = brd_type)
-                        return start;
-                start = KLCF_NEXT_ANY(start);
-        }
-        /* Didn't find it. */
-        return (lboard_t *) NULL;
+	if (brd && brd->brd_next_any)
+		return NODE_OFFSET_TO_LBOARD(NASID_GET(brd), brd->brd_next_any);
+        return NULL;
 }
 
-
-/* external declarations of Linux kernel functions. */
-
-extern lboard_t *root_lboard[];
-extern klinfo_t *find_component(lboard_t *brd, klinfo_t *kli, unsigned char type);
-extern klinfo_t *find_first_component(lboard_t *brd, unsigned char type);
-
 #endif /* _ASM_IA64_SN_KLCONFIG_H */
Index: linux/include/asm-ia64/sn/sn_sal.h
=================================--- linux.orig/include/asm-ia64/sn/sn_sal.h	2005-09-12 10:40:18.798049041 -0500
+++ linux/include/asm-ia64/sn/sn_sal.h	2005-09-12 11:49:10.808707510 -0500
@@ -206,26 +206,16 @@ ia64_sn_get_master_baseio_nasid(void)
 	return ret_stuff.v0;
 }
 
-static inline char *
+static inline void *
 ia64_sn_get_klconfig_addr(nasid_t nasid)
 {
 	struct ia64_sal_retval ret_stuff;
-	int cnodeid;
 
-	cnodeid = nasid_to_cnodeid(nasid);
 	ret_stuff.status = 0;
 	ret_stuff.v0 = 0;
 	ret_stuff.v1 = 0;
 	ret_stuff.v2 = 0;
 	SAL_CALL(ret_stuff, SN_SAL_GET_KLCONFIG_ADDR, (u64)nasid, 0, 0, 0, 0, 0, 0);
-
-	/*
-	 * We should panic if a valid cnode nasid does not produce
-	 * a klconfig address.
-	 */
-	if (ret_stuff.status != 0) {
-		panic("ia64_sn_get_klconfig_addr: Returned error %lx\n", ret_stuff.status);
-	}
 	return ret_stuff.v0 ? __va(ret_stuff.v0) : NULL;
 }
 
Index: linux/include/asm-ia64/sn/xp.h
=================================--- linux.orig/include/asm-ia64/sn/xp.h	2005-09-12 10:40:18.801954895 -0500
+++ linux/include/asm-ia64/sn/xp.h	2005-09-12 11:49:10.811636896 -0500
@@ -49,7 +49,7 @@
  * C-brick nasids, thus the need for bitmaps which don't account for
  * odd-numbered (non C-brick) nasids.
  */
-#define XP_MAX_PHYSNODE_ID	(MAX_PHYSNODE_ID / 2)
+#define XP_MAX_PHYSNODE_ID	(MAX_NUMALINK_NODES / 2)
 #define XP_NASID_MASK_BYTES	((XP_MAX_PHYSNODE_ID + 7) / 8)
 #define XP_NASID_MASK_WORDS	((XP_MAX_PHYSNODE_ID + 63) / 64)
 
Index: linux/arch/ia64/sn/kernel/sn2/sn_hwperf.c
=================================--- linux.orig/arch/ia64/sn/kernel/sn2/sn_hwperf.c	2005-09-12 10:40:09.796032242 -0500
+++ linux/arch/ia64/sn/kernel/sn2/sn_hwperf.c	2005-09-12 11:49:10.817495666 -0500
@@ -476,8 +476,8 @@ static int sn_topology_show(struct seq_f
 				for_each_online_cpu(j) {
 					seq_printf(s, j ? ":%d" : ", dist %d",
 						node_distance(
-						    cpuid_to_cnodeid(i),
-						    cpuid_to_cnodeid(j)));
+						    cpu_to_node(i),
+						    cpu_to_node(j)));
 				}
 				seq_putc(s, '\n');
 			}
Index: linux/include/asm-ia64/sn/sn_cpuid.h
=================================--- linux.orig/include/asm-ia64/sn/sn_cpuid.h	2005-09-12 10:40:18.797072577 -0500
+++ linux/include/asm-ia64/sn/sn_cpuid.h	2005-09-12 11:49:10.820425052 -0500
@@ -105,7 +105,6 @@ extern short physical_node_map[];	/* ind
 #define cpuid_to_nasid(cpuid)		(sn_nodepda->phys_cpuid[cpuid].nasid)
 #define cpuid_to_subnode(cpuid)		(sn_nodepda->phys_cpuid[cpuid].subnode)
 #define cpuid_to_slice(cpuid)		(sn_nodepda->phys_cpuid[cpuid].slice)
-#define cpuid_to_cnodeid(cpuid)		(physical_node_map[cpuid_to_nasid(cpuid)])
 
 
 /*
@@ -113,8 +112,6 @@ extern short physical_node_map[];	/* ind
  * of potentially large tables.
  */
 extern int nasid_slice_to_cpuid(int, int);
-#define nasid_slice_to_cpu_physical_id(nasid, slice)			\
-	cpu_physical_id(nasid_slice_to_cpuid(nasid, slice))
 
 /*
  * cnodeid_to_nasid - convert a cnodeid to a NASID
Index: linux/arch/ia64/sn/kernel/io_init.c
=================================--- linux.orig/arch/ia64/sn/kernel/io_init.c	2005-09-12 10:40:09.787244070 -0500
+++ linux/arch/ia64/sn/kernel/io_init.c	2005-09-12 11:49:10.824330899 -0500
@@ -22,8 +22,6 @@
 #include "xtalk/hubdev.h"
 #include "xtalk/xwidgetdev.h"
 
-nasid_t master_nasid = INVALID_NASID;	/* Partition Master */
-
 static struct list_head sn_sysdata_list;
 
 /* sysdata list struct */
@@ -165,7 +163,7 @@ static void sn_fixup_ionodes(void)
 	 * Get SGI Specific HUB chipset information.
 	 * Inform Prom that this kernel can support domain bus numbering.
 	 */
-	for (i = 0; i < numionodes; i++) {
+	for (i = 0; i < num_cnodes; i++) {
 		hubdev = (struct hubdev_info *)(NODEPDA(i)->pdinfo);
 		nasid = cnodeid_to_nasid(i);
 		hubdev->max_segment_number = 0xffffffff;
Index: linux/drivers/char/snsc.c
=================================--- linux.orig/drivers/char/snsc.c	2005-09-12 10:40:12.941221102 -0500
+++ linux/drivers/char/snsc.c	2005-09-12 11:49:10.830189669 -0500
@@ -377,7 +377,7 @@ scdrv_init(void)
 	dev_t first_dev, dev;
 	nasid_t event_nasid = ia64_sn_get_console_nasid();
 
-	if (alloc_chrdev_region(&first_dev, 0, numionodes,
+	if (alloc_chrdev_region(&first_dev, 0, num_cnodes,
 				SYSCTL_BASENAME) < 0) {
 		printk("%s: failed to register SN system controller device\n",
 		       __FUNCTION__);
@@ -385,7 +385,7 @@ scdrv_init(void)
 	}
 	snsc_class = class_create(THIS_MODULE, SYSCTL_BASENAME);
 
-	for (cnode = 0; cnode < numionodes; cnode++) {
+	for (cnode = 0; cnode < num_cnodes; cnode++) {
 			geoid = cnodeid_get_geoid(cnode);
 			devnamep = devname;
 			format_module_id(devnamep, geo_module(geoid),
Index: linux/include/asm-ia64/sn/io.h
=================================--- linux.orig/include/asm-ia64/sn/io.h	2005-09-12 10:40:18.786331479 -0500
+++ linux/include/asm-ia64/sn/io.h	2005-09-12 11:49:10.833119055 -0500
@@ -14,7 +14,7 @@
 extern void * sn_io_addr(unsigned long port) __attribute_const__; /* Forward definition */
 extern void __sn_mmiowb(void); /* Forward definition */
 
-extern int numionodes;
+extern int num_cnodes;
 
 #define __sn_mf_a()   ia64_mfa()
 
Index: linux/arch/ia64/sn/kernel/tiocx.c
=================================--- linux.orig/arch/ia64/sn/kernel/tiocx.c	2005-09-12 10:40:09.798961632 -0500
+++ linux/arch/ia64/sn/kernel/tiocx.c	2005-09-12 11:52:12.035139096 -0500
@@ -489,12 +489,11 @@ static int __init tiocx_init(void)
 
 	bus_register(&tiocx_bus_type);
 
-	for (cnodeid = 0; cnodeid < MAX_COMPACT_NODES; cnodeid++) {
+	for (cnodeid = 0; cnodeid < num_cnodes; cnodeid++) {
 		nasid_t nasid;
 		int bt;
 
-		if ((nasid = cnodeid_to_nasid(cnodeid)) < 0)
-			break;	/* No more nasids .. bail out of loop */
+		nasid = cnodeid_to_nasid(cnodeid);
 
 		if ((nasid & 0x1) && is_fpga_tio(nasid, &bt)) {
 			struct hubdev_info *hubdev;
-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


