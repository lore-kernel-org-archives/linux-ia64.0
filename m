From: j-nomura@ce.jp.nec.com
Date: Fri, 27 Feb 2004 12:19:58 +0000
Subject: Re: [Lse-tech] fix zonelist ordering for NUMA
Message-Id: <20040227.211958.304108906.nomura@linux.bs1.fc.nec.co.jp>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="--Next_Part(Fri_Feb_27_21_19_58_2004_652)--"
List-Id: <linux-ia64.vger.kernel.org>
References: <1077652196.26287.6.camel@arrakis>
In-Reply-To: <1077652196.26287.6.camel@arrakis>
To: linux-ia64@vger.kernel.org

----Next_Part(Fri_Feb_27_21_19_58_2004_652)--
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

I updated the patch.
This version of build_zonelists() is NUMA-specific one.
It will handle the situation Erich pointed out better.

For example, when the node_distance(i,j) looks like below: 

   10 15 15 15 20 20 20 20 
   15 10 15 15 20 20 20 20 
   15 15 10 15 20 20 20 20 
   15 15 15 10 20 20 20 20 
   20 20 20 20 10 15 15 15 
   20 20 20 20 15 10 15 15 
   20 20 20 20 15 15 10 15 
   20 20 20 20 15 15 15 10 

The previous patch generates zonelist in the following order:
   Node#00  0   1   2   3   4   5   6   7 
   Node#01  1   2   3   0   4   5   6   7 
   Node#02  2   3   0   1   4   5   6   7 
   Node#03  3   0   1   2   4   5   6   7 
   Node#04  4   5   6   7   0   1   2   3 
   Node#05  5   6   7   4   0   1   2   3 
   Node#06  6   7   4   5   0   1   2   3 
   Node#07  7   4   5   6   0   1   2   3 

With this patch, the order looks like:
   Node#00  0   1   2   3   4   5   6   7 
   Node#01  1   2   3   0   5   6   7   4 
   Node#02  2   3   0   1   6   7   4   5 
   Node#03  3   0   1   2   7   4   5   6 
   Node#04  4   5   6   7   0   1   2   3 
   Node#05  5   6   7   4   1   2   3   0 
   Node#06  6   7   4   5   2   3   0   1 
   Node#07  7   4   5   6   3   0   1   2 

Best regards.
--
NOMURA, Jun'ichi <j-nomura@ce.jp.nec.com>

----Next_Part(Fri_Feb_27_21_19_58_2004_652)--
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline; filename="numa-zonelist2.diff"

--- linux/mm/page_alloc.c	2004/02/18 07:25:09	1.1.1.25
+++ linux/mm/page_alloc.c	2004/02/27 10:55:52
@@ -1074,6 +1074,106 @@ static int __init build_zonelists_node(p
 	return j;
 }
 
+#ifdef CONFIG_NUMA
+#define MAX_NODE_LOAD (numnodes)
+static int __initdata node_load[MAX_NUMNODES];
+/**
+ * find_next_best_node - find the next node that should appear in a given
+ *    node's fallback list
+ * @node: node whose fallback list we're appending
+ * @used_node_mask: pointer to the bitmap of already used nodes
+ *
+ * We use a number of factors to determine which is the next node that should
+ * appear on a given node's fallback list.  The node should not have appeared
+ * already in @node's fallback list, and it should be the next closest node
+ * according to the distance array (which contains arbitrary distance values
+ * from each node to each node in the system), and should also prefer nodes
+ * with no CPUs, since presumably they'll have very little allocation pressure
+ * on them otherwise.
+ * It returns -1 if no node is found.
+ */
+static int __init find_next_best_node(int node, void *used_node_mask)
+{
+	int i, n, val;
+	int min_val = INT_MAX;
+	int best_node = -1;
+
+	for (i = 0; i < numnodes; i++) {
+		/* Start from local node */
+		n = (node+i)%numnodes;
+
+		/* Don't want a node to appear more than once */
+		if (test_bit(n, used_node_mask))
+			continue;
+
+		/* Use the distance array to find the distance */
+		val = node_distance(node, n);
+
+		/* Give preference to headless and unused nodes */
+		if (node_to_cpumask(n))
+			val += PENALTY_FOR_NODE_WITH_CPUS;
+
+		/* Slight preference for less loaded node */
+		val *= (MAX_NODE_LOAD*MAX_NUMNODES);
+		val += node_load[n];
+
+		if (val < min_val) {
+			min_val = val;
+			best_node = n;
+		}
+	}
+
+	if (best_node >= 0)
+		set_bit(best_node, used_node_mask);
+
+	return best_node;
+}
+
+static void __init build_zonelists(pg_data_t *pgdat)
+{
+	int i, j, k, node, local_node;
+	int prev_node, load;
+	struct zonelist *zonelist;
+	DECLARE_BITMAP(used_mask, MAX_NUMNODES);
+
+	/* initialize zonelists */
+	for (i = 0; i < MAX_NR_ZONES; i++) {
+		zonelist = pgdat->node_zonelists + i;
+		memset(zonelist, 0, sizeof(*zonelist));
+		zonelist->zones[0] = NULL;
+	}
+
+	/* NUMA-aware ordering of nodes */
+	local_node = pgdat->node_id;
+	load = numnodes;
+	prev_node = local_node;
+	CLEAR_BITMAP(used_mask, MAX_NUMNODES);
+	while ((node = find_next_best_node(local_node, used_mask)) >= 0) {
+		/*
+		 * We don't want to pressure a particular node.
+		 * So adding penalty to the first node in same
+		 * distance group to make it round-robin.
+		 */
+		if (node_distance(local_node, node) != node_distance(local_node, prev_node))
+			node_load[node] += load;
+		prev_node = node;
+		load--;
+		for (i = 0; i < MAX_NR_ZONES; i++) {
+			zonelist = pgdat->node_zonelists + i;
+			for (j = 0; zonelist->zones[j] != NULL; j++);
+			
+			k = ZONE_NORMAL;
+			if (i & __GFP_HIGHMEM)
+				k = ZONE_HIGHMEM;
+			if (i & __GFP_DMA)
+				k = ZONE_DMA;
+
+	 		j = build_zonelists_node(NODE_DATA(node), zonelist, j, k);
+			zonelist->zones[j] = NULL;
+		}
+	}
+}
+#else
 static void __init build_zonelists(pg_data_t *pgdat)
 {
 	int i, j, k, node, local_node;
@@ -1109,7 +1209,8 @@ static void __init build_zonelists(pg_da
 		zonelist->zones[j++] = NULL;
 	} 
 }
+#endif
 
 void __init build_all_zonelists(void)
 {
--- linux/include/asm-generic/topology.h	2004/02/18 07:21:59	1.1.1.5
+++ linux/include/asm-generic/topology.h	2004/02/27 10:55:52
@@ -44,6 +44,12 @@
 #ifndef pcibus_to_cpumask
 #define pcibus_to_cpumask(bus)	(cpu_online_map)
 #endif
+#ifndef node_distance
+#define node_distance(from,to)	(from != to)
+#endif
+#ifndef PENALTY_FOR_NODE_WITH_CPUS
+#define PENALTY_FOR_NODE_WITH_CPUS	(1)
+#endif
 
 /* Cross-node load balancing interval. */
 #ifndef NODE_BALANCE_RATE
Index: linux/include/asm-i386/topology.h
===================================================================
RCS file: /home/cvsadm/cvsroot/linux2.5/linux/include/asm-i386/topology.h,v
retrieving revision 1.1.1.6
diff -u -p -u -p -r1.1.1.6 topology.h
--- linux/include/asm-i386/topology.h	2004/02/18 07:22:14	1.1.1.6
+++ linux/include/asm-i386/topology.h	2004/02/27 10:55:52
@@ -66,6 +66,12 @@ static inline cpumask_t pcibus_to_cpumas
 	return node_to_cpumask(mp_bus_id_to_node[bus]);
 }
 
+/* Node-to-Node distance */
+static inline int node_distance(int from, int to)
+{
+	return (from != to);
+}
+
 /* Cross-node load balancing interval. */
 #define NODE_BALANCE_RATE 100
 

----Next_Part(Fri_Feb_27_21_19_58_2004_652)----
