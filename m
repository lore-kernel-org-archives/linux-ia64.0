From: Alex Williamson <alex.williamson@hp.com>
Date: Tue, 31 Aug 2004 21:38:18 +0000
Subject: [PATCH] fixup pxm_to_nid_map
Message-Id: <1093988299.4620.37.camel@tdi>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


   I'd like to be able to use pxm_to_nid_map in several places to
discover proximity domain to node id associations.  Unfortunately, after
reassign_cpu_only_nodes() plays with the node space, the pxm_to_nid_map
doesn't necessarily reflect reality.  This fixes up the table so it's
still valid.  Note that nid_to_pxm_map is still potentially broken, but
has a one-to-many problem if the above function combines several
proximity domains into a single node.  Thanks to Bob Picco for the base
patch.

Signed-off-by: Alex Williamson <alex.williamson@hp.com>

=== arch/ia64/mm/discontig.c 1.18 vs edited ==--- 1.18/arch/ia64/mm/discontig.c	2004-08-27 00:30:29 -06:00
+++ edited/arch/ia64/mm/discontig.c	2004-08-31 14:44:45 -06:00
@@ -53,11 +53,12 @@
 static void __init reassign_cpu_only_nodes(void)
 {
 	struct node_memblk_s *p;
-	int i, j, k, nnode, nid, cpu, cpunid;
+	int i, j, k, nnode, nid, cpu, cpunid, pxm;
 	u8 cslit, slit;
 	static DECLARE_BITMAP(nodes_with_mem, NR_NODES) __initdata;
 	static u8 numa_slit_fix[MAX_NUMNODES * MAX_NUMNODES] __initdata;
 	static int node_flip[NR_NODES] __initdata;
+	static int old_nid_map[NR_CPUS] __initdata;
 
 	for (nnode = 0, p = &node_memblk[0]; p < &node_memblk[num_node_memblks]; p++)
 		if (!test_bit(p->nid, (void *) nodes_with_mem)) {
@@ -104,9 +105,14 @@
 
 		for (cpu = 0; cpu < NR_CPUS; cpu++)
 			if (node_cpuid[cpu].nid = i) {
-				/* For nodes not being reassigned just fix the cpu's nid. */
+				/*
+				 * For nodes not being reassigned just
+				 * fix the cpu's nid and reverse pxm map
+				 */
 				if (cpunid < numnodes) {
-					node_cpuid[cpu].nid = cpunid;
+					pxm = nid_to_pxm_map[i];
+					pxm_to_nid_map[pxm] +					          node_cpuid[cpu].nid = cpunid;
 					continue;
 				}
 
@@ -126,6 +132,8 @@
 						}
 					}
 
+				/* save old nid map so we can update the pxm */
+				old_nid_map[cpu] = node_cpuid[cpu].nid;
 				node_cpuid[cpu].nid = k;
 			}
 	}
@@ -134,14 +142,19 @@
 	 * Fixup temporary nid values for CPU-only nodes.
 	 */
 	for (cpu = 0; cpu < NR_CPUS; cpu++)
-		if (node_cpuid[cpu].nid = (numnodes + numnodes))
-			node_cpuid[cpu].nid = nnode - 1;
-		else
-			for (i = 0; i < nnode; i++)
-				if (node_flip[i] = (node_cpuid[cpu].nid - numnodes)) {
-					node_cpuid[cpu].nid = i;
-					break;
-				}
+		if (node_cpuid[cpu].nid = (numnodes + numnodes)) {
+			pxm = nid_to_pxm_map[old_nid_map[cpu]];
+			pxm_to_nid_map[pxm] = node_cpuid[cpu].nid = nnode - 1;
+		} else {
+			for (i = 0; i < nnode; i++) {
+				if (node_flip[i] != (node_cpuid[cpu].nid - numnodes))
+					continue;
+
+				pxm = nid_to_pxm_map[old_nid_map[cpu]];
+				pxm_to_nid_map[pxm] = node_cpuid[cpu].nid = i;
+				break;
+			}
+		}
 
 	/*
 	 * Fix numa_slit by compressing from larger


