From: Robert Picco <Robert.Picco@hp.com>
Date: Mon, 23 Feb 2004 19:45:00 +0000
Subject: CPU only nodes (no memory) patch for NUMA/DISCONTIG
Message-Id: <403A583C.7010808@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David:

Jesse has reviewed this for me and we are in agreement.  CPU only nodes 
are moved to a node with memory which is at the closest relative 
distance per the SLIT information.  Any node reassignments will result 
in the compression of the nodes and renumbering the nid values where 
appropriate.

There is hope our firmware folks will handle interleaved memory 
correctly in regards to SLIT and PXM.  There should be more data on this 
later in the week.  No matter what the outcome of a firmware change,  
the patch will work.

Bob

--- linux-2.6.3-orig/arch/ia64/mm/discontig.c	2004-02-17 22:59:19.000000000 -0500
+++ linux-2.6.3/arch/ia64/mm/discontig.c	2004-02-23 11:02:06.000000000 -0500
@@ -41,6 +41,99 @@
 static struct early_node_data mem_data[NR_NODES] __initdata;
 
 /*
+ * This function will move nodes with only CPUs (no memory)
+ * to a node with memory which is at the minimum numa_slit distance.
+ * Any reassigments will result in the compression of the nodes
+ * and renumbering the nid values where appropriate.
+ */
+static void __init reassign_cpu_only_nodes(void)
+{
+	struct node_memblk_s *p;
+	int i, j, k, nnode, nid, cpu, cpunid;
+	u8 cslit, slit;
+	static DECLARE_BITMAP(nodes_with_mem, NR_NODES) __initdata;
+	static u8 numa_slit_fix[MAX_NUMNODES * MAX_NUMNODES] __initdata;
+	static int node_flip[NR_NODES] __initdata;
+
+	for (nnode = 0, p = &node_memblk[0]; p < &node_memblk[num_node_memblks]; p++) 
+		if (!test_bit(p->nid, (void *) nodes_with_mem)) {
+			set_bit(p->nid, (void *) nodes_with_mem);
+			nnode++;
+		}
+	
+	/*
+	 * All nids with memory.
+	 */
+	if (nnode = numnodes) 
+		return;
+
+	/*
+	 * Change nids and attempt to migrate CPU only nodes
+	 * to the best numa_slit (closest neighbor) possible.
+	 */
+	for (nid = 0, i = 0; i < numnodes; i++)  {
+		if (test_bit(i, (void *) nodes_with_mem)) {
+			node_flip[nid] = i;
+
+			if (i = nid) {
+				nid++;
+				continue;
+			}
+
+			for (p = &node_memblk[0]; p < &node_memblk[num_node_memblks]; p++)
+				if (p->nid = i)
+					p->nid = nid;
+
+			cpunid = nid;
+			nid++;
+		} else
+			cpunid = numnodes;
+			
+		for (cpu = 0; cpu < NR_CPUS; cpu++) 
+			if (node_cpuid[cpu].nid = i) {
+				if (cpunid < numnodes) {
+					node_cpuid[cpu].nid = cpunid;
+					continue;
+				}
+
+				for (slit = 0xff, k = numnodes + numnodes, j = 0; j < numnodes; j++)
+					if (i = j)
+						continue;
+					else if (test_bit(j, (void *) nodes_with_mem)) {
+						cslit = numa_slit[i * numnodes + j];
+						if (cslit < slit) {
+							k = numnodes + j;
+							slit = cslit;
+						}
+					}
+
+				node_cpuid[cpu].nid = k;
+			}
+	}
+
+	for (cpu = 0; cpu < NR_CPUS; cpu++)
+		if (node_cpuid[cpu].nid = (numnodes + numnodes))
+			node_cpuid[cpu].nid = nnode - 1;
+		else
+			for (i = 0; i < nnode; i++)
+				if (node_flip[i] = (node_cpuid[cpu].nid - numnodes)) {
+					node_cpuid[cpu].nid = i;
+					break;
+				}
+
+	for (i = 0; i < nnode; i++)
+		for (j = 0; j < nnode; j++)
+			numa_slit_fix[i * nnode + j] = 
+				numa_slit[node_flip[i] * numnodes + node_flip[j]];
+			
+	memcpy(numa_slit, numa_slit_fix, sizeof (numa_slit));
+
+	numnodes = nnode;
+
+	return;
+}
+
+/*
  * To prevent cache aliasing effects, align per-node structures so that they
  * start at addresses that are strided by node number.
  */
@@ -301,6 +394,9 @@
 	min_low_pfn = -1;
 	max_low_pfn = 0;
 
+	if (numnodes > 1) 
+		reassign_cpu_only_nodes();
+
 	/* These actually end up getting called by call_pernode_memory() */
 	efi_memmap_walk(filter_rsvd_memory, build_node_maps);
 	efi_memmap_walk(filter_rsvd_memory, find_pernode_space);





