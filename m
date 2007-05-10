From: Simon Horman <horms@verge.net.au>
Date: Thu, 10 May 2007 10:19:48 +0000
Subject: [request-for-test] [patch 3/3] Allow DISCONTIGMEM without NUMA
Message-Id: <20070510102033.518718217@tabatha.lab.ultramonkey.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This turned out to be less tedious that I had feared. The bulk of the
changes are in discontig.c, just making sure that things that don't exist
without NUMA aren't used.

The other changes mainly relate to making sure that NODE_DATA does exists
when CONFIG_NEED_MULTIPLE_NODES is set.

Boots on an HP RX2620, but I haven't done any further testing.

From: Simon Horman <horms@verge.net.au>

Index: linux-2.6/arch/ia64/mm/discontig.c
=================================--- linux-2.6.orig/arch/ia64/mm/discontig.c	2007-05-10 18:46:12.000000000 +0900
+++ linux-2.6/arch/ia64/mm/discontig.c	2007-05-10 18:47:01.000000000 +0900
@@ -27,6 +27,15 @@
 #include <asm/numa.h>
 #include <asm/sections.h>
 
+static int node_of_cpu (int cpu)
+{
+#ifdef CONFIG_NUMA
+	return node_cpuid[cpu].nid;
+#else
+	return 0;
+#endif
+}
+
 /*
  * Track per-node information needed to setup the boot memory allocator, the
  * per-node areas, and the real VM.
@@ -101,13 +110,17 @@ static int __init build_node_maps(unsign
  */
 static int __meminit early_nr_cpus_node(int node)
 {
+#ifdef CONFIG_NUMA
 	int cpu, n = 0;
 
 	for (cpu = 0; cpu < NR_CPUS; cpu++)
-		if (node = node_cpuid[cpu].nid)
+		if (node = node_of_cpu(cpu))
 			n++;
 
 	return n;
+#else
+	return NR_CPUS;
+#endif
 }
 
 /**
@@ -142,7 +155,7 @@ static void *per_cpu_node_setup(void *cp
 	int cpu;
 
 	for (cpu = 0; cpu < NR_CPUS; cpu++) {
-		if (node = node_cpuid[cpu].nid) {
+		if (node = node_of_cpu(cpu)) {
 			memcpy(__va(cpu_data), __phys_per_cpu_start,
 			       __per_cpu_end - __per_cpu_start);
 			__per_cpu_offset[cpu] = (char*)__va(cpu_data) -
@@ -345,14 +358,14 @@ static void __init initialize_pernode_da
 #ifdef CONFIG_SMP
 	/* Set the node_data pointer for each per-cpu struct */
 	for (cpu = 0; cpu < NR_CPUS; cpu++) {
-		node = node_cpuid[cpu].nid;
+		node = node_of_cpu(cpu);
 		per_cpu(cpu_info, cpu).node_data = mem_data[node].node_data;
 	}
 #else
 	{
 		struct cpuinfo_ia64 *cpu0_cpu_info;
 		cpu = 0;
-		node = node_cpuid[cpu].nid;
+		node = node_of_cpu(cpu);
 		cpu0_cpu_info = (struct cpuinfo_ia64 *)(__phys_per_cpu_start +
 			((char *)&per_cpu__cpu_info - __per_cpu_start));
 		cpu0_cpu_info->node_data = mem_data[node].node_data;
@@ -580,9 +593,12 @@ void show_mem(void)
  */
 void call_pernode_memory(unsigned long start, unsigned long len, void *arg)
 {
-	unsigned long rs, re, end = start + len;
+	unsigned long end = start + len;
 	void (*func)(unsigned long, unsigned long, int);
+#ifdef CONFIG_NUMA
+	unsigned long rs, re
 	int i;
+#endif
 
 	start = PAGE_ALIGN(start);
 	end &= PAGE_MASK;
@@ -591,6 +607,7 @@ void call_pernode_memory(unsigned long s
 
 	func = arg;
 
+#ifdef CONFIG_NUMA
 	if (!num_node_memblks) {
 		/* No SRAT table, so assume one node (node 0) */
 		(*func)(start, end - start, 0);
@@ -608,6 +625,9 @@ void call_pernode_memory(unsigned long s
 		if (re = end)
 			break;
 	}
+#else
+	(*func)(start, end - start, 0);
+#endif
 }
 
 /**
Index: linux-2.6/include/asm-ia64/nodedata.h
=================================--- linux-2.6.orig/include/asm-ia64/nodedata.h	2007-05-10 17:58:00.000000000 +0900
+++ linux-2.6/include/asm-ia64/nodedata.h	2007-05-10 18:59:07.000000000 +0900
@@ -16,7 +16,7 @@
 #include <asm/percpu.h>
 #include <asm/mmzone.h>
 
-#ifdef CONFIG_NUMA
+#ifdef CONFIG_NEED_MULTIPLE_NODES
 
 /*
  * Node Data. One of these structures is located on each node of a NUMA system.
@@ -58,6 +58,6 @@ struct ia64_node_data {
 	((struct ia64_node_data *)((u64)(pgdat) + 	\
 				   L1_CACHE_ALIGN(sizeof(struct pglist_data))))
 
-#endif /* CONFIG_NUMA */
+#endif /* !CONFIG_NEED_MULTIPLE_NODES */
 
 #endif /* _ASM_IA64_NODEDATA_H */
Index: linux-2.6/include/asm-ia64/processor.h
=================================--- linux-2.6.orig/include/asm-ia64/processor.h	2007-05-10 18:16:17.000000000 +0900
+++ linux-2.6/include/asm-ia64/processor.h	2007-05-10 18:47:01.000000000 +0900
@@ -75,9 +75,7 @@
 #include <asm/rse.h>
 #include <asm/unwind.h>
 #include <asm/atomic.h>
-#ifdef CONFIG_NUMA
 #include <asm/nodedata.h>
-#endif
 
 /* like above but expressed as bitfields for more efficient access: */
 struct ia64_psr {
@@ -160,7 +158,7 @@ struct cpuinfo_ia64 {
 	char vendor[16];
 	char *model_name;
 
-#ifdef CONFIG_NUMA
+#ifdef CONFIG_NEED_MULTIPLE_NODES
 	struct ia64_node_data *node_data;
 #endif
 };
Index: linux-2.6/include/asm-ia64/meminit.h
=================================--- linux-2.6.orig/include/asm-ia64/meminit.h	2007-05-10 18:01:02.000000000 +0900
+++ linux-2.6/include/asm-ia64/meminit.h	2007-05-10 18:47:01.000000000 +0900
@@ -48,7 +48,7 @@ extern int reserve_elfcorehdr(unsigned l
 #define GRANULEROUNDUP(n)	(((n)+IA64_GRANULE_SIZE-1) & ~(IA64_GRANULE_SIZE-1))
 #define ORDERROUNDDOWN(n)	((n) & ~((PAGE_SIZE<<MAX_ORDER)-1))
 
-#ifdef CONFIG_NUMA
+#ifdef CONFIG_NEED_MULTIPLE_NODES
   extern void call_pernode_memory (unsigned long start, unsigned long len, void *func);
 #else
 # define call_pernode_memory(start, len, func)	(*func)(start, len, 0)

-- 

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

