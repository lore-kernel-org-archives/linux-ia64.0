From: Jack Steiner <steiner@sgi.com>
Date: Wed, 31 May 2006 13:58:08 +0000
Subject: [PATCH] - SN topology fix for large systems
Message-Id: <20060531135808.GA5918@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

There is an SN bug in sn_hwperf.c that affects systems with 1024n or 1024p.
The bug manifests itself 2 ways: IO interrupts are not always 
targeted to the nearest node, and 2) the "cat /proc/sgi_sn/sn_topology"
commands fails with "cannot allocate memory". 

The code is using the wrong macros for validating node numbers.

	Signed-off-by: Jack Steiner <steiner@sgi.com>


Index: linux/arch/ia64/sn/kernel/sn2/sn_hwperf.c
=================================--- linux.orig/arch/ia64/sn/kernel/sn2/sn_hwperf.c	2006-05-31 08:37:44.097288260 -0500
+++ linux/arch/ia64/sn/kernel/sn2/sn_hwperf.c	2006-05-31 08:55:48.427238545 -0500
@@ -51,6 +51,8 @@ static nasid_t sn_hwperf_master_nasid = 
 static int sn_hwperf_init(void);
 static DECLARE_MUTEX(sn_hwperf_init_mutex);
 
+#define cnode_possible(n)	((n) < num_cnodes)
+
 static int sn_hwperf_enum_objects(int *nobj, struct sn_hwperf_object_info **ret)
 {
 	int e;
@@ -127,14 +129,14 @@ static int sn_hwperf_geoid_to_cnode(char
 		}
 	}
 
-	return node_possible(cnode) ? cnode : -1;
+	return cnode_possible(cnode) ? cnode : -1;
 }
 
 static int sn_hwperf_obj_to_cnode(struct sn_hwperf_object_info * obj)
 {
 	if (!SN_HWPERF_IS_NODE(obj) && !SN_HWPERF_IS_IONODE(obj))
 		BUG();
-	if (!obj->sn_hwp_this_part)
+	if (SN_HWPERF_FOREIGN(obj))
 		return -1;
 	return sn_hwperf_geoid_to_cnode(obj->location);
 }
@@ -199,12 +201,12 @@ static void print_pci_topology(struct se
 
 static inline int sn_hwperf_has_cpus(cnodeid_t node)
 {
-	return node_online(node) && nr_cpus_node(node);
+	return node < MAX_NUMNODES && node_online(node) && nr_cpus_node(node);
 }
 
 static inline int sn_hwperf_has_mem(cnodeid_t node)
 {
-	return node_online(node) && NODE_DATA(node)->node_present_pages;
+	return node < MAX_NUMNODES && node_online(node) && NODE_DATA(node)->node_present_pages;
 }
 
 static struct sn_hwperf_object_info *
@@ -237,7 +239,7 @@ static int sn_hwperf_get_nearest_node_ob
 	int found_mem = 0;
 	int found_cpu = 0;
 
-	if (!node_possible(node))
+	if (!cnode_possible(node))
 		return -EINVAL;
 
 	if (sn_hwperf_has_cpus(node)) {
@@ -442,7 +444,7 @@ static int sn_topology_show(struct seq_f
 	seq_printf(s, "%s %d %s %s asic %s", slabname, ordinal, obj->location,
 		obj->sn_hwp_this_part ? "local" : "shared", obj->name);
 
-	if (!SN_HWPERF_IS_NODE(obj) && !SN_HWPERF_IS_IONODE(obj))
+	if (ordinal < 0 || (!SN_HWPERF_IS_NODE(obj) && !SN_HWPERF_IS_IONODE(obj)))
 		seq_putc(s, '\n');
 	else {
 		cnodeid_t near_mem = -1;
@@ -468,22 +470,24 @@ static int sn_topology_show(struct seq_f
 		/*
 		 * CPUs on this node, if any
 		 */
-		cpumask = node_to_cpumask(ordinal);
-		for_each_online_cpu(i) {
-			if (cpu_isset(i, cpumask)) {
-				slice = 'a' + cpuid_to_slice(i);
-				c = cpu_data(i);
-				seq_printf(s, "cpu %d %s%c local"
-					" freq %luMHz, arch ia64",
-					i, obj->location, slice,
-					c->proc_freq / 1000000);
-				for_each_online_cpu(j) {
-					seq_printf(s, j ? ":%d" : ", dist %d",
-						node_distance(
-						    cpu_to_node(i),
-						    cpu_to_node(j)));
+		if (!SN_HWPERF_IS_IONODE(obj)) {
+			cpumask = node_to_cpumask(ordinal);
+			for_each_online_cpu(i) {
+				if (cpu_isset(i, cpumask)) {
+					slice = 'a' + cpuid_to_slice(i);
+					c = cpu_data(i);
+					seq_printf(s, "cpu %d %s%c local"
+						" freq %luMHz, arch ia64",
+						i, obj->location, slice,
+						c->proc_freq / 1000000);
+					for_each_online_cpu(j) {
+						seq_printf(s, j ? ":%d" : ", dist %d",
+							node_distance(
+						    	cpu_to_node(i),
+						    	cpu_to_node(j)));
+					}
+					seq_putc(s, '\n');
 				}
-				seq_putc(s, '\n');
 			}
 		}
 	}
@@ -523,7 +527,7 @@ static int sn_topology_show(struct seq_f
 			if (obj->sn_hwp_this_part && p->sn_hwp_this_part)
 				/* both ends local to this partition */
 				seq_puts(s, " local");
-			else if (!obj->sn_hwp_this_part && !p->sn_hwp_this_part)
+			else if (SN_HWPERF_FOREIGN(p))
 				/* both ends of the link in foreign partiton */
 				seq_puts(s, " foreign");
 			else
@@ -776,7 +780,7 @@ sn_hwperf_ioctl(struct inode *in, struct
 
 	case SN_HWPERF_GET_NODE_NASID:
 		if (a.sz != sizeof(u64) ||
-		   (node = a.arg) < 0 || !node_possible(node)) {
+		   (node = a.arg) < 0 || !cnode_possible(node)) {
 			r = -EINVAL;
 			goto error;
 		}
