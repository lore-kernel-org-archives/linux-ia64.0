From: dcn@sgi.com (Dean Nelson)
Date: Mon, 21 Mar 2005 19:40:50 +0000
Subject: [PATCH] move cnodeid_to_nasid_table out of pda
Message-Id: <423F2342.mailxGRL11RVD3@aqua.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Another step in the effort to eliminate the SN pda structure.
This patch moves the cnodeid_to_nasid_table field out of the pda,
making it a standalone per-cpu data item, and exports it so it can
be accessed by kernel modules.

Signed-off-by: Dean Nelson <dcn@sgi.com>


Index: linux-2.6/include/asm-ia64/sn/pda.h
=================================--- linux-2.6.orig/include/asm-ia64/sn/pda.h	2005-03-21 09:33:28.657196704 -0600
+++ linux-2.6/include/asm-ia64/sn/pda.h	2005-03-21 09:33:28.783171960 -0600
@@ -49,7 +49,6 @@
 
 	unsigned long	sn_soft_irr[4];
 	unsigned long	sn_in_service_ivecs[4];
-	short		cnodeid_to_nasid_table[MAX_NUMNODES];
 	int		sn_lb_int_war_ticks;
 	int		sn_last_irq;
 	int		sn_first_irq;
Index: linux-2.6/include/asm-ia64/sn/sn_cpuid.h
=================================--- linux-2.6.orig/include/asm-ia64/sn/sn_cpuid.h	2005-03-21 09:33:28.503877981 -0600
+++ linux-2.6/include/asm-ia64/sn/sn_cpuid.h	2005-03-21 10:06:22.752760405 -0600
@@ -4,7 +4,7 @@
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
  *
- * Copyright (C) 2000-2004 Silicon Graphics, Inc. All rights reserved.
+ * Copyright (C) 2000-2005 Silicon Graphics, Inc. All rights reserved.
  */
 
 
@@ -123,11 +123,8 @@
 
 /*
  * cnodeid_to_nasid - convert a cnodeid to a NASID
- *	Macro relies on pg_data for a node being on the node itself.
- *	Just extract the NASID from the pointer.
- *
  */
-#define cnodeid_to_nasid(cnodeid)	pda->cnodeid_to_nasid_table[cnodeid]
+#define cnodeid_to_nasid(cnodeid)	(sn_cnodeid_to_nasid[cnodeid])
  
 /*
  * nasid_to_cnodeid - convert a NASID to a cnodeid
Index: linux-2.6/include/asm-ia64/sn/arch.h
=================================--- linux-2.6.orig/include/asm-ia64/sn/arch.h	2005-03-21 09:33:28.540986971 -0600
+++ linux-2.6/include/asm-ia64/sn/arch.h	2005-03-21 10:55:47.249275028 -0600
@@ -5,7 +5,7 @@
  *
  * SGI specific setup.
  *
- * Copyright (C) 1995-1997,1999,2001-2004 Silicon Graphics, Inc.  All rights reserved.
+ * Copyright (C) 1995-1997,1999,2001-2005 Silicon Graphics, Inc.  All rights reserved.
  * Copyright (C) 1999 Ralf Baechle (ralf@gnu.org)
  */
 #ifndef _ASM_IA64_SN_ARCH_H
@@ -47,6 +47,15 @@
 #define MAX_COMPACT_NODES	2048
 #define CPUS_PER_NODE		4
 
+
+/*
+ * Compact node ID to nasid mappings kept in the per-cpu data areas of each
+ * cpu.
+ */
+DECLARE_PER_CPU(short, __sn_cnodeid_to_nasid[MAX_NUMNODES]);
+#define sn_cnodeid_to_nasid	(&__get_cpu_var(__sn_cnodeid_to_nasid[0]))
+
+
 extern void sn_flush_all_caches(long addr, long bytes);
 
 #endif /* _ASM_IA64_SN_ARCH_H */
Index: linux-2.6/arch/ia64/sn/kernel/setup.c
=================================--- linux-2.6.orig/arch/ia64/sn/kernel/setup.c	2005-03-21 09:33:28.548799390 -0600
+++ linux-2.6/arch/ia64/sn/kernel/setup.c	2005-03-21 11:02:47.545462823 -0600
@@ -3,7 +3,7 @@
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
  *
- * Copyright (C) 1999,2001-2004 Silicon Graphics, Inc. All rights reserved.
+ * Copyright (C) 1999,2001-2005 Silicon Graphics, Inc. All rights reserved.
  */
 
 #include <linux/config.h>
@@ -72,6 +72,9 @@
 DEFINE_PER_CPU(struct sn_hub_info_s, __sn_hub_info);
 EXPORT_PER_CPU_SYMBOL(__sn_hub_info);
 
+DEFINE_PER_CPU(short, __sn_cnodeid_to_nasid[MAX_NUMNODES]);
+EXPORT_PER_CPU_SYMBOL(__sn_cnodeid_to_nasid);
+
 partid_t sn_partid = -1;
 EXPORT_SYMBOL(sn_partid);
 char sn_system_serial_number_string[128];
@@ -364,11 +367,11 @@
 {
 	cnodeid_t cnode;
 
-	memset(pda->cnodeid_to_nasid_table, -1,
-	       sizeof(pda->cnodeid_to_nasid_table));
+	memset(sn_cnodeid_to_nasid, -1,
+			sizeof(__ia64_per_cpu_var(__sn_cnodeid_to_nasid)));
 	for_each_online_node(cnode)
-		pda->cnodeid_to_nasid_table[cnode] -		    pxm_to_nasid(nid_to_pxm_map[cnode]);
+		sn_cnodeid_to_nasid[cnode] +				pxm_to_nasid(nid_to_pxm_map[cnode]);
 
 	numionodes = num_online_nodes();
 	scan_for_ionodes();
@@ -477,15 +480,18 @@
 	pda->idle_flag = 0;
 
 	if (cpuid != 0) {
-		memcpy(pda->cnodeid_to_nasid_table,
-		       pdacpu(0)->cnodeid_to_nasid_table,
-		       sizeof(pda->cnodeid_to_nasid_table));
+		/* copy cpu 0's sn_cnodeid_to_nasid table to this cpu's */
+		memcpy(sn_cnodeid_to_nasid,
+		       (&per_cpu(__sn_cnodeid_to_nasid, 0)),
+		       sizeof(__ia64_per_cpu_var(__sn_cnodeid_to_nasid)));
 	}
 
 	/*
 	 * Check for WARs.
 	 * Only needs to be done once, on BSP.
-	 * Has to be done after loop above, because it uses pda.cnodeid_to_nasid_table[i].
+	 * Has to be done after loop above, because it uses this cpu's
+	 * sn_cnodeid_to_nasid table which was just initialized if this
+	 * isn't cpu 0.
 	 * Has to be done before assignment below.
 	 */
 	if (!wars_have_been_checked) {
@@ -571,8 +577,7 @@
 		brd = find_lboard_any(brd, KLTYPE_SNIA);
 
 		while (brd) {
-			pda->cnodeid_to_nasid_table[numionodes] -			    brd->brd_nasid;
+			sn_cnodeid_to_nasid[numionodes] = brd->brd_nasid;
 			physical_node_map[brd->brd_nasid] = numionodes;
 			root_lboard[numionodes] = brd;
 			numionodes++;
@@ -593,8 +598,7 @@
 				      root_lboard[nasid_to_cnodeid(nasid)],
 				      KLTYPE_TIO);
 		while (brd) {
-			pda->cnodeid_to_nasid_table[numionodes] -			    brd->brd_nasid;
+			sn_cnodeid_to_nasid[numionodes] = brd->brd_nasid;
 			physical_node_map[brd->brd_nasid] = numionodes;
 			root_lboard[numionodes] = brd;
 			numionodes++;
@@ -605,7 +609,6 @@
 			brd = find_lboard_any(brd, KLTYPE_TIO);
 		}
 	}
-
 }
 
 int
