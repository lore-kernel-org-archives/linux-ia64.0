From: jbarnes@sgi.com (Jesse Barnes)
Date: Fri, 17 Oct 2003 17:48:34 +0000
Subject: [PATCH] fix topology initialization
Message-Id: <marc-linux-ia64-106641334730082@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Now that NUMA kernels are working we can properly initialze the topology
information so that /sys/devices/system/node* & friends aren't empty.

In doing this I found some circular dependencies, so I removed
nodedata.h and did some forward declarations because I figured cleaning
them up properly is something that can wait until after 2.6.

Jesse


diff -Nru a/arch/ia64/mm/numa.c b/arch/ia64/mm/numa.c
--- a/arch/ia64/mm/numa.c	Fri Oct 17 10:45:09 2003
+++ b/arch/ia64/mm/numa.c	Fri Oct 17 10:45:09 2003
@@ -11,12 +11,20 @@
  */
 
 #include <linux/config.h>
+#include <linux/cpu.h>
 #include <linux/kernel.h>
 #include <linux/mm.h>
+#include <linux/memblk.h>
+#include <linux/node.h>
 #include <linux/init.h>
 #include <linux/bootmem.h>
+#include <linux/topology.h>
 #include <asm/numa.h>
 
+struct memblk *sysfs_memblks;;
+struct node *sysfs_nodes;
+struct cpu *sysfs_cpus;
+
 /*
  * The following structures are usually initialized by ACPI or
  * similar mechanisms and describe the NUMA characteristics of the machine.
@@ -43,3 +51,42 @@
 
 	return (i < num_memblks) ? node_memblk[i].nid : (num_memblks ? -1 : 0);
 }
+
+int __init topology_init(void)
+{
+	int i, err = 0;
+
+	sysfs_nodes = kmalloc(sizeof(struct node) * numnodes, GFP_KERNEL);
+	if (!sysfs_nodes)
+		return -ENOMEM;
+
+	sysfs_memblks = kmalloc(sizeof(struct memblk) * num_memblks,
+				GFP_KERNEL);
+	if (!sysfs_memblks) {
+		kfree(sysfs_nodes);
+		return -ENOMEM;
+	}
+
+	sysfs_cpus = kmalloc(sizeof(struct cpu) * NR_CPUS, GFP_KERNEL);
+	if (!sysfs_cpus) {
+		kfree(sysfs_memblks);
+		kfree(sysfs_nodes);
+		return -ENOMEM;
+	}
+
+	for (i = 0; i < numnodes; i++)
+		err = register_node(&sysfs_nodes[i], i, 0);
+
+	for (i = 0; i < num_memblks; i++)
+		err = register_memblk(&sysfs_memblks[i], i,
+				      &sysfs_nodes[memblk_to_node(i)]);
+
+	for (i = 0; i < NR_CPUS; i++)
+		if (cpu_online(i))
+			err = register_cpu(&sysfs_cpus[i], i,
+					   &sysfs_nodes[cpu_to_node(i)]);
+
+	return err;
+}
+
+__initcall(topology_init);
diff -Nru a/arch/ia64/sn/kernel/bte.c b/arch/ia64/sn/kernel/bte.c
--- a/arch/ia64/sn/kernel/bte.c	Fri Oct 17 10:45:09 2003
+++ b/arch/ia64/sn/kernel/bte.c	Fri Oct 17 10:45:09 2003
@@ -39,7 +39,7 @@
 #include <asm/sn/sn_cpuid.h>
 #include <asm/sn/pda.h>
 #include <asm/sn/sn2/shubio.h>
-#include <asm/nodedata.h>
+#include <asm/mmzone.h>
 
 #include <linux/bootmem.h>
 #include <linux/string.h>
diff -Nru a/include/asm-ia64/mmzone.h b/include/asm-ia64/mmzone.h
--- a/include/asm-ia64/mmzone.h	Fri Oct 17 10:45:09 2003
+++ b/include/asm-ia64/mmzone.h	Fri Oct 17 10:45:09 2003
@@ -12,8 +12,9 @@
 #define _ASM_IA64_MMZONE_H
 
 #include <linux/config.h>
-#include <asm/page.h>
 #include <asm/meminit.h>
+#include <asm/page.h>
+#include <asm/percpu.h>
 
 #ifdef CONFIG_DISCONTIGMEM
 
@@ -32,6 +33,15 @@
 #define pfn_valid(pfn)		(((pfn) < max_low_pfn) && ia64_pfn_valid(pfn))
 #define page_to_pfn(page)	((unsigned long) (page - vmem_map))
 #define pfn_to_page(pfn)	(vmem_map + (pfn))
+
+struct ia64_node_data {
+	short			active_cpu_count;
+	short			node;
+	struct pglist_data	*pg_data_ptrs[NR_NODES];
+};
+
+#define local_node_data		(local_cpu_data->node_data)
+#define NODE_DATA(nid)		(local_node_data->pg_data_ptrs[nid])
 
 #endif /* CONFIG_DISCONTIGMEM */
 #endif /* _ASM_IA64_MMZONE_H */
diff -Nru a/include/asm-ia64/nodedata.h b/include/asm-ia64/nodedata.h
--- a/include/asm-ia64/nodedata.h	Fri Oct 17 10:45:09 2003
+++ /dev/null	Wed Dec 31 16:00:00 1969
@@ -1,52 +0,0 @@
-/*
- * This file is subject to the terms and conditions of the GNU General Public
- * License.  See the file "COPYING" in the main directory of this archive
- * for more details.
- *
- * Copyright (c) 2000 Silicon Graphics, Inc.  All rights reserved.
- * Copyright (c) 2002 NEC Corp.
- * Copyright (c) 2002 Erich Focht <efocht@ess.nec.de>
- * Copyright (c) 2002 Kimio Suganuma <k-suganuma@da.jp.nec.com>
- */
-#ifndef _ASM_IA64_NODEDATA_H
-#define _ASM_IA64_NODEDATA_H
-
-#include <linux/config.h>
-#include <linux/numa.h>
-
-#include <asm/percpu.h>
-#include <asm/mmzone.h>
-
-#ifdef CONFIG_DISCONTIGMEM
-
-/*
- * Node Data. One of these structures is located on each node of a NUMA system.
- */
-
-struct pglist_data;
-struct ia64_node_data {
-	short			active_cpu_count;
-	short			node;
-	struct pglist_data	*pg_data_ptrs[NR_NODES];
-};
-
-
-/*
- * Return a pointer to the node_data structure for the executing cpu.
- */
-#define local_node_data		(local_cpu_data->node_data)
-
-/*
- * Given a node id, return a pointer to the pg_data_t for the node.
- *
- * NODE_DATA 	- should be used in all code not related to system
- *		  initialization. It uses pernode data structures to minimize
- *		  offnode memory references. However, these structure are not 
- *		  present during boot. This macro can be used once cpu_init
- *		  completes.
- */
-#define NODE_DATA(nid)		(local_node_data->pg_data_ptrs[nid])
-
-#endif /* CONFIG_DISCONTIGMEM */
-
-#endif /* _ASM_IA64_NODEDATA_H */
diff -Nru a/include/asm-ia64/processor.h b/include/asm-ia64/processor.h
--- a/include/asm-ia64/processor.h	Fri Oct 17 10:45:09 2003
+++ b/include/asm-ia64/processor.h	Fri Oct 17 10:45:09 2003
@@ -95,9 +95,6 @@
 #include <asm/rse.h>
 #include <asm/unwind.h>
 #include <asm/atomic.h>
-#ifdef CONFIG_NUMA
-#include <asm/nodedata.h>
-#endif
 
 /* like above but expressed as bitfields for more efficient access: */
 struct ia64_psr {
diff -Nru a/include/asm-ia64/sn/sn_cpuid.h b/include/asm-ia64/sn/sn_cpuid.h
--- a/include/asm-ia64/sn/sn_cpuid.h	Fri Oct 17 10:45:09 2003
+++ b/include/asm-ia64/sn/sn_cpuid.h	Fri Oct 17 10:45:09 2003
@@ -17,7 +17,6 @@
 #include <linux/mmzone.h>
 #include <asm/sn/types.h>
 #include <asm/current.h>
-#include <asm/nodedata.h>
 #include <asm/sn/pda.h>
 
 
diff -Nru a/include/asm-ia64/topology.h b/include/asm-ia64/topology.h
--- a/include/asm-ia64/topology.h	Fri Oct 17 10:45:09 2003
+++ b/include/asm-ia64/topology.h	Fri Oct 17 10:45:09 2003
@@ -13,6 +13,7 @@
 #ifndef _ASM_IA64_TOPOLOGY_H
 #define _ASM_IA64_TOPOLOGY_H
 
+#include <linux/config.h>
 #include <asm/acpi.h>
 #include <asm/numa.h>
 #include <asm/smp.h>
@@ -63,5 +64,12 @@
 #endif /* CONFIG_NUMA */
 
 #include <asm-generic/topology.h>
+
+struct memblk;
+struct node;
+struct cpu;
+extern struct memblk *sysfs_memblks;
+extern struct node *sysfs_nodes;
+extern struct cpu *sysfs_cpus;
 
 #endif /* _ASM_IA64_TOPOLOGY_H */
