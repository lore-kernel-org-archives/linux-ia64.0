From: Robert Picco <Robert.Picco@hp.com>
Date: Tue, 24 Feb 2004 14:40:49 +0000
Subject: Re: CPU only nodes (no memory) patch for NUMA/DISCONTIG
Message-Id: <403B6271.7060902@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <403A583C.7010808@hp.com>
In-Reply-To: <403A583C.7010808@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger wrote:

>>>>>>On Mon, 23 Feb 2004 14:45:00 -0500, Robert Picco <Robert.Picco@hp.com> said:
>>>>>>            
>>>>>>
>
>  Robert> +	static DECLARE_BITMAP(nodes_with_mem, NR_NODES) __initdata;
>  Robert> +	static u8 numa_slit_fix[MAX_NUMNODES * MAX_NUMNODES] __initdata;
>  Robert> +	static int node_flip[NR_NODES] __initdata;
>
>Perhaps a comment would be in place as to why these are static?
>I assume they're to avoid inordinate stack-space consumption?  Also,
>the code won't be re-entrant which may be something worth pointing
>out in the comment for the function.
>  
>
Added commentary here.  There are additional comments in code which 
hopefully elucidates the algorithm.
Also I've addressed the other feedback.

thanks,

Bob

>Then there is my usual complaint about trailing white space.
>
>Otherwise, the patch is fine with me (though I don't think the code is
>easy to follow; there seem to be some non-obvious inversions in the
>meaning of the bitmap bits).
>
>	--david
>-
>To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>  
>

--- linux-2.6.3-orig/arch/ia64/mm/discontig.c	2004-02-23 14:50:56.000000000 -0500
+++ linux-2.6.3/arch/ia64/mm/discontig.c	2004-02-24 07:59:09.000000000 -0500
@@ -40,6 +40,125 @@
 
 static struct early_node_data mem_data[NR_NODES] __initdata;
 
+/**
+ * reassign_cpu_only_nodes - called from find_memory to move CPU only nodes to a memory node
+ *
+ * This function will move nodes with only CPUs (no memory)
+ * to a node with memory which is at the minimum numa_slit distance.
+ * Any reassigments will result in the compression of the nodes
+ * and renumbering the nid values where appropriate.
+ * The static declarations below are to avoid large stack size which
+ * makes the code not re-entrant.
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
+	 * For reassigned CPU nodes a nid can't be arrived at
+	 * until after this loop because the target nid's new
+	 * identity might not have been established yet. So
+	 * new nid values are fabricated above numnodes and
+	 * mapped back later to their true value.
+	 */
+	for (nid = 0, i = 0; i < numnodes; i++)  {
+		if (test_bit(i, (void *) nodes_with_mem)) {
+			/*
+			 * Save original nid value for numa_slit
+			 * fixup and node_cpuid reassignments.
+			 */
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
+				/* For nodes not being reassigned just fix the cpu's nid. */
+				if (cpunid < numnodes) {
+					node_cpuid[cpu].nid = cpunid;
+					continue;
+				}
+
+				/*
+				 * For nodes being reassigned, find best node by
+				 * numa_slit information and then make a temporary
+				 * nid value based on current nid and numnodes.
+				 */
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
+	/*
+	 * Fixup temporary nid values for CPU only nodes.
+	 */
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
+	/*
+	 * Fix numa_slit by compressing from larger
+	 * nid array to reduced nid array.
+	 */
+	for (i = 0; i < nnode; i++)
+		for (j = 0; j < nnode; j++)
+			numa_slit_fix[i * nnode + j] +				numa_slit[node_flip[i] * numnodes + node_flip[j]];
+			
+	memcpy(numa_slit, numa_slit_fix, sizeof (numa_slit));
+
+	numnodes = nnode;
+
+	return;
+}
+
 /*
  * To prevent cache aliasing effects, align per-node structures so that they
  * start at addresses that are strided by node number.
@@ -301,6 +420,9 @@
 	min_low_pfn = -1;
 	max_low_pfn = 0;
 
+	if (numnodes > 1)
+		reassign_cpu_only_nodes();
+
 	/* These actually end up getting called by call_pernode_memory() */
 	efi_memmap_walk(filter_rsvd_memory, build_node_maps);
 	efi_memmap_walk(filter_rsvd_memory, find_pernode_space);


