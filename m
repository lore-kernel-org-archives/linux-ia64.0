From: j-nomura@ce.jp.nec.com
Date: Tue, 24 Feb 2004 09:20:28 +0000
Subject: fix zonelist ordering for NUMA
Message-Id: <20040224.182028.884032071.nomura@linux.bs1.fc.nec.co.jp>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="--Next_Part(Tue_Feb_24_18_20_28_2004_780)--"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

----Next_Part(Tue_Feb_24_18_20_28_2004_780)--
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Hello,

The attached patch makes use of arch-dependent info for building zonelist.
The patch uses ACPI SLIT for ia64.
Other arch may have their own method to determine the order.

This kind of ordering is very important for the NUMA system in which
the distance between nodes is not uniform.

The patch doing this was posted by Jesse Barnes in linux-ia64:
http://marc.theaimsgroup.com/?t=106383477500001&r=1&w=2
however, I couldn't find it in current tree...

The sorting can be extended to, for example, more fine grained round-robin
like Erich suggested. But let's start from the simple one.

Any comments?

Best regards.
--
NOMURA, Jun'ichi <j-nomura@ce.jp.nec.com>

----Next_Part(Tue_Feb_24_18_20_28_2004_780)--
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline; filename="ia64-numa-zoneordering.diff"

--- linux/mm/page_alloc.c	2004/02/18 07:25:09	1.1.1.25
+++ linux/mm/page_alloc.c	2004/02/24 09:02:29
@@ -1074,6 +1074,13 @@ static int __init build_zonelists_node(p
 	return j;
 }
 
+#ifndef HAVE_ARCH_SORTED_NODE_DATA
+/*
+ * By default, the order of node data is unchanged.
+ */
+#define SORTED_NODE_DATA(base, idx) NODE_DATA((base+idx)%numnodes)
+#endif
+
 static void __init build_zonelists(pg_data_t *pgdat)
 {
 	int i, j, k, node, local_node;
@@ -1100,12 +1107,12 @@ static void __init build_zonelists(pg_da
  		 * building the zones for node N, we make sure that the
  		 * zones coming right after the local ones are those from
  		 * node N+1 (modulo N)
+ 		 * Multi-level NUMA system can use arch-dependent node data
+		 * list. (e.g. sorted by distance)
  		 */
- 		for (node = local_node + 1; node < numnodes; node++)
- 			j = build_zonelists_node(NODE_DATA(node), zonelist, j, k);
- 		for (node = 0; node < local_node; node++)
- 			j = build_zonelists_node(NODE_DATA(node), zonelist, j, k);
+ 		for (node = 1; node < numnodes; node++)
+ 			j = build_zonelists_node(SORTED_NODE_DATA(local_node, node), zonelist, j, k);
  
 		zonelist->zones[j++] = NULL;
 	} 
--- linux/include/asm-ia64/numa.h	2004/02/18 07:21:42	1.1.1.8
+++ linux/include/asm-ia64/numa.h	2004/02/24 09:02:29
@@ -65,7 +65,11 @@ extern int paddr_to_nid(unsigned long pa
 
 #define local_nodeid (cpu_to_node_map[smp_processor_id()])
 
+#define HAVE_ARCH_SORTED_NODE_DATA
+#define SORTED_NODE_DATA(base, idx) NODE_DATA(nodes_by_distance[base][idx])
+extern int __initdata nodes_by_distance[MAX_NUMNODES][MAX_NUMNODES];
+
 #else /* !CONFIG_NUMA */
 
 #define paddr_to_nid(addr)	0
--- linux/arch/ia64/mm/discontig.c	2004/02/18 07:23:08	1.1.1.8
+++ linux/arch/ia64/mm/discontig.c	2004/02/24 09:02:29
@@ -47,6 +47,53 @@ static struct early_node_data mem_data[N
 #define NODEDATA_ALIGN(addr, node)						\
 	((((addr) + 1024*1024-1) & ~(1024*1024-1)) + (node)*PERCPU_PAGE_SIZE)
 
+/*
+ * node list sorted by distance
+ *
+ * For example, if the SLIT looks like below:
+ *     10 30 20
+ *     20 10 30
+ *     30 20 10
+ *
+ * nodes_by_distance[][] will be:
+ *      0  2  1
+ *      1  0  2
+ *      2  1  0
+ */
+int __initdata nodes_by_distance[MAX_NUMNODES][MAX_NUMNODES];
+
+/**
+ * build_sorted_node_list - build nodes_by_distance matrix from ACPI SLIT
+ *
+ * Called in early stage to create matrix for SORTED_NODE_DATA().
+ * The function depends on node_distance (=numa_slit) and numnodes.
+ */ 
+static void __init build_sorted_node_list(void)
+{
+	int i, j, k, n;
+	int dist, min, next_min;
+
+	for(i = 0; i < numnodes; i++) {
+		/* index 0 always points to self */
+		nodes_by_distance[i][0] = i;
+		/* sorting for node i */
+		for(j = 1, min = 0; j < numnodes; min = next_min) {
+			/* slit entry is u8 */
+			next_min = INT_MAX;
+			for(k = 0; k < numnodes; k++) {
+				n = (i+k)%numnodes; /* permutation */
+				dist = node_distance(i,n);
+				if (dist == min && i != n)
+					nodes_by_distance[i][j++] = n;
+				else if (dist > min && dist < next_min)
+					next_min = dist;
+			}
+			if (next_min == INT_MAX)
+				break;
+		}
+	}
+}
+
 /**
  * build_node_maps - callback to setup bootmem structs for each node
  * @start: physical start of range
@@ -333,6 +380,7 @@ void __init find_memory(void)
 
 	reserve_pernode_space();
 	initialize_pernode_data();
+	build_sorted_node_list();
 
 	max_pfn = max_low_pfn;
 

----Next_Part(Tue_Feb_24_18_20_28_2004_780)----
