From: j-nomura@ce.jp.nec.com
Date: Wed, 25 Feb 2004 10:59:33 +0000
Subject: Re: [Lse-tech] fix zonelist ordering for NUMA
Message-Id: <20040225.195933.719894652.nomura@linux.bs1.fc.nec.co.jp>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="--Next_Part(Wed_Feb_25_19_59_33_2004_453)--"
List-Id: <linux-ia64.vger.kernel.org>
References: <1077652196.26287.6.camel@arrakis>
In-Reply-To: <1077652196.26287.6.camel@arrakis>
To: linux-ia64@vger.kernel.org

----Next_Part(Wed_Feb_25_19_59_33_2004_453)--
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

I cleaned up the patch based on the comments from Jesse and Matthew.

>   1) make it arch independent
>      this means having arch code populate a SLIT-like table for use by
>      the generic zonelist building code

I moved the whole function to mm/page_alloc.c.

>   3) some systems have pgdats w/o any CPUs associated with them, they
>      need to be dealt with differently than regular nodes, maybe as
>      extensions to an existing node

Headless node is prefered over the nodes with same distance.

>   2) handle the cases that Erich talked about a bit better

Any idea for doing it in generic way?

Best regards.
--
NOMURA, Jun'ichi <j-nomura@ce.jp.nec.com>

----Next_Part(Wed_Feb_25_19_59_33_2004_453)--
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline; filename="numa-zonelist.diff"

--- linux/mm/page_alloc.c	2004/02/18 07:25:09	1.1.1.25
+++ linux/mm/page_alloc.c	2004/02/25 10:28:35
@@ -1074,9 +1074,63 @@ static int __init build_zonelists_node(p
 	return j;
 }
 
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
+#ifndef node_distance
+#define node_distance(from,to) (1)
+#endif
+#define PENALTY_FOR_NODE_WITH_CPUS  (1)
+
+static int __init find_next_best_node(int node, void *used_node_mask)
+{
+	int i, n, val;
+	int min_val = INT_MAX;
+	int best_node = -1;
+
+	for(i = 0; i < numnodes; i++) {
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
 static void __init build_zonelists(pg_data_t *pgdat)
 {
 	int i, j, k, node, local_node;
+	DECLARE_BITMAP(used_mask, MAX_NUMNODES);
 
 	local_node = pgdat->node_id;
 	for (i = 0; i < MAX_NR_ZONES; i++) {
@@ -1092,19 +1146,9 @@ static void __init build_zonelists(pg_da
 		if (i & __GFP_DMA)
 			k = ZONE_DMA;
 
- 		j = build_zonelists_node(pgdat, zonelist, j, k);
- 		/*
- 		 * Now we build the zonelist so that it contains the zones
- 		 * of all the other nodes.
- 		 * We don't want to pressure a particular node, so when
- 		 * building the zones for node N, we make sure that the
- 		 * zones coming right after the local ones are those from
- 		 * node N+1 (modulo N)
- 		 */
- 		for (node = local_node + 1; node < numnodes; node++)
- 			j = build_zonelists_node(NODE_DATA(node), zonelist, j, k);
- 		for (node = 0; node < local_node; node++)
- 			j = build_zonelists_node(NODE_DATA(node), zonelist, j, k);
+		CLEAR_BITMAP(used_mask, MAX_NUMNODES);
+		while((node = find_next_best_node(local_node, used_mask)) >= 0)
+	 		j = build_zonelists_node(NODE_DATA(node), zonelist, j, k);
  
 		zonelist->zones[j++] = NULL;
 	} 

----Next_Part(Wed_Feb_25_19_59_33_2004_453)----
