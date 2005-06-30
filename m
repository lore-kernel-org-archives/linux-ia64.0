From: Bob Picco <bob.picco@hp.com>
Date: Thu, 30 Jun 2005 16:51:48 +0000
Subject: [PATCH] memory-less-nodes repost
Message-Id: <20050630165148.GM25758@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Tony,

This is a repost of memory-less-node patch submitted back in early May. There
isn't any change.  This iteration was tested for memory less
nodes and all nodes populated with memory.  An rx2600 boot test was also made.
There shouldn't be further testing required by SGI because of testing Greg did
on the previous identical patch.  This patch is required before ia64 SPARSEMEM
can be sent to -mm because of a minor patch conflict.

Below are the details of the original post and the current patch.
The original thread is at:
http://marc.theaimsgroup.com/?l=linux-ia64&m1530710817786&w=2

thanks,

bob

I reworked how nodes with only CPUs are treated.  The patch below seems
simpler to me and has eliminated the complicated routine
reassign_cpu_only_nodes.  There isn't any longer the requirement
to modify ACPI NUMA information which was in large part the
complexity introduced in reassign_cpu_only_nodes. 

This patch will produce a different number of nodes. For example,
reassign_cpu_only_nodes would reduce two CPUonly nodes and one memory node
configuration to one memory+CPUs node configuration.  This patch
doesn't change the number of nodes which means the user will see three.  Two
nodes without memory and one node with all the memory.

While doing this patch, I noticed that early_nr_phys_cpus_node isn't serving
any useful purpose.  It is called once in find_pernode_space but the value
isn't used to computer pernode space.  

Signed-off-by: bob.picco <bob.picco@hp.com>

 discontig.c |  394 +++++++++++++++++++++++++-----------------------------------
 init.c      |    5 
 2 files changed, 170 insertions(+), 229 deletions(-)

Index: linux-aegl-2.6.git-patches/arch/ia64/mm/discontig.c
=================================--- linux-aegl-2.6.git-patches.orig/arch/ia64/mm/discontig.c	2005-06-28 15:27:26.000000000 -0400
+++ linux-aegl-2.6.git-patches/arch/ia64/mm/discontig.c	2005-06-28 15:48:21.000000000 -0400
@@ -44,150 +44,7 @@ struct early_node_data {
 };
 
 static struct early_node_data mem_data[MAX_NUMNODES] __initdata;
-
-/**
- * reassign_cpu_only_nodes - called from find_memory to move CPU-only nodes to a memory node
- *
- * This function will move nodes with only CPUs (no memory)
- * to a node with memory which is at the minimum numa_slit distance.
- * Any reassigments will result in the compression of the nodes
- * and renumbering the nid values where appropriate.
- * The static declarations below are to avoid large stack size which
- * makes the code not re-entrant.
- */
-static void __init reassign_cpu_only_nodes(void)
-{
-	struct node_memblk_s *p;
-	int i, j, k, nnode, nid, cpu, cpunid, pxm;
-	u8 cslit, slit;
-	static DECLARE_BITMAP(nodes_with_mem, MAX_NUMNODES) __initdata;
-	static u8 numa_slit_fix[MAX_NUMNODES * MAX_NUMNODES] __initdata;
-	static int node_flip[MAX_NUMNODES] __initdata;
-	static int old_nid_map[NR_CPUS] __initdata;
-
-	for (nnode = 0, p = &node_memblk[0]; p < &node_memblk[num_node_memblks]; p++)
-		if (!test_bit(p->nid, (void *) nodes_with_mem)) {
-			set_bit(p->nid, (void *) nodes_with_mem);
-			nnode++;
-		}
-
-	/*
-	 * All nids with memory.
-	 */
-	if (nnode = num_online_nodes())
-		return;
-
-	/*
-	 * Change nids and attempt to migrate CPU-only nodes
-	 * to the best numa_slit (closest neighbor) possible.
-	 * For reassigned CPU nodes a nid can't be arrived at
-	 * until after this loop because the target nid's new
-	 * identity might not have been established yet. So
-	 * new nid values are fabricated above num_online_nodes() and
-	 * mapped back later to their true value.
-	 */
-	/* MCD - This code is a bit complicated, but may be unnecessary now.
-	 * We can now handle much more interesting node-numbering.
-	 * The old requirement that 0 <= nid <= numnodes <= MAX_NUMNODES
-	 * and that there be no holes in the numbering 0..numnodes
-	 * has become simply 0 <= nid <= MAX_NUMNODES.
-	 */
-	nid = 0;
-	for_each_online_node(i)  {
-		if (test_bit(i, (void *) nodes_with_mem)) {
-			/*
-			 * Save original nid value for numa_slit
-			 * fixup and node_cpuid reassignments.
-			 */
-			node_flip[nid] = i;
-
-			if (i = nid) {
-				nid++;
-				continue;
-			}
-
-			for (p = &node_memblk[0]; p < &node_memblk[num_node_memblks]; p++)
-				if (p->nid = i)
-					p->nid = nid;
-
-			cpunid = nid;
-			nid++;
-		} else
-			cpunid = MAX_NUMNODES;
-
-		for (cpu = 0; cpu < NR_CPUS; cpu++)
-			if (node_cpuid[cpu].nid = i) {
-				/*
-				 * For nodes not being reassigned just
-				 * fix the cpu's nid and reverse pxm map
-				 */
-				if (cpunid < MAX_NUMNODES) {
-					pxm = nid_to_pxm_map[i];
-					pxm_to_nid_map[pxm] -					          node_cpuid[cpu].nid = cpunid;
-					continue;
-				}
-
-				/*
-				 * For nodes being reassigned, find best node by
-				 * numa_slit information and then make a temporary
-				 * nid value based on current nid and num_online_nodes().
-				 */
-				slit = 0xff;
-				k = 2*num_online_nodes();
-				for_each_online_node(j) {
-					if (i = j)
-						continue;
-					else if (test_bit(j, (void *) nodes_with_mem)) {
-						cslit = numa_slit[i * num_online_nodes() + j];
-						if (cslit < slit) {
-							k = num_online_nodes() + j;
-							slit = cslit;
-						}
-					}
-				}
-
-				/* save old nid map so we can update the pxm */
-				old_nid_map[cpu] = node_cpuid[cpu].nid;
-				node_cpuid[cpu].nid = k;
-			}
-	}
-
-	/*
-	 * Fixup temporary nid values for CPU-only nodes.
-	 */
-	for (cpu = 0; cpu < NR_CPUS; cpu++)
-		if (node_cpuid[cpu].nid = (2*num_online_nodes())) {
-			pxm = nid_to_pxm_map[old_nid_map[cpu]];
-			pxm_to_nid_map[pxm] = node_cpuid[cpu].nid = nnode - 1;
-		} else {
-			for (i = 0; i < nnode; i++) {
-				if (node_flip[i] != (node_cpuid[cpu].nid - num_online_nodes()))
-					continue;
-
-				pxm = nid_to_pxm_map[old_nid_map[cpu]];
-				pxm_to_nid_map[pxm] = node_cpuid[cpu].nid = i;
-				break;
-			}
-		}
-
-	/*
-	 * Fix numa_slit by compressing from larger
-	 * nid array to reduced nid array.
-	 */
-	for (i = 0; i < nnode; i++)
-		for (j = 0; j < nnode; j++)
-			numa_slit_fix[i * nnode + j] -				numa_slit[node_flip[i] * num_online_nodes() + node_flip[j]];
-
-	memcpy(numa_slit, numa_slit_fix, sizeof (numa_slit));
-
-	nodes_clear(node_online_map);
-	for (i = 0; i < nnode; i++)
-		node_set_online(i);
-
-	return;
-}
+static nodemask_t memory_less_mask __initdata;
 
 /*
  * To prevent cache aliasing effects, align per-node structures so that they
@@ -233,46 +90,88 @@ static int __init build_node_maps(unsign
 }
 
 /**
- * early_nr_phys_cpus_node - return number of physical cpus on a given node
+ * early_nr_cpus_node - return number of cpus on a given node
  * @node: node to check
  *
- * Count the number of physical cpus on @node.  These are cpus that actually
- * exist.  We can't use nr_cpus_node() yet because
+ * Count the number of cpus on @node.  We can't use nr_cpus_node() yet because
  * acpi_boot_init() (which builds the node_to_cpu_mask array) hasn't been
- * called yet.
+ * called yet.  Note that node 0 will also count all non-existent cpus.
  */
-static int early_nr_phys_cpus_node(int node)
+static int __init early_nr_cpus_node(int node)
 {
 	int cpu, n = 0;
 
 	for (cpu = 0; cpu < NR_CPUS; cpu++)
 		if (node = node_cpuid[cpu].nid)
-			if ((cpu = 0) || node_cpuid[cpu].phys_id)
-				n++;
+			n++;
 
 	return n;
 }
 
+/**
+ * compute_pernodesize - compute size of pernode data
+ * @node: the node id.
+ */
+static unsigned long __init compute_pernodesize(int node)
+{
+	unsigned long pernodesize = 0, cpus;
+
+	cpus = early_nr_cpus_node(node);
+	pernodesize += PERCPU_PAGE_SIZE * cpus;
+	pernodesize += node * L1_CACHE_BYTES;
+	pernodesize += L1_CACHE_ALIGN(sizeof(pg_data_t));
+	pernodesize += L1_CACHE_ALIGN(sizeof(struct ia64_node_data));
+	pernodesize = PAGE_ALIGN(pernodesize);
+	return pernodesize;
+}
 
 /**
- * early_nr_cpus_node - return number of cpus on a given node
- * @node: node to check
- *
- * Count the number of cpus on @node.  We can't use nr_cpus_node() yet because
- * acpi_boot_init() (which builds the node_to_cpu_mask array) hasn't been
- * called yet.  Note that node 0 will also count all non-existent cpus.
+ * fill_pernode - initialize pernode data.
+ * @node: the node id.
+ * @pernode: physical address of pernode data
+ * @pernodesize: size of the pernode data
  */
-static int early_nr_cpus_node(int node)
+static void __init fill_pernode(int node, unsigned long pernode,
+	unsigned long pernodesize)
 {
-	int cpu, n = 0;
+	void *cpu_data;
+	int cpus = early_nr_cpus_node(node), cpu;
+	struct bootmem_data *bdp = &mem_data[node].bootmem_data;
 
-	for (cpu = 0; cpu < NR_CPUS; cpu++)
-		if (node = node_cpuid[cpu].nid)
-			n++;
+	mem_data[node].pernode_addr = pernode;
+	mem_data[node].pernode_size = pernodesize;
+	memset(__va(pernode), 0, pernodesize);
+
+	cpu_data = (void *)pernode;
+	pernode += PERCPU_PAGE_SIZE * cpus;
+	pernode += node * L1_CACHE_BYTES;
 
-	return n;
-}
+	mem_data[node].pgdat = __va(pernode);
+	pernode += L1_CACHE_ALIGN(sizeof(pg_data_t));
+
+	mem_data[node].node_data = __va(pernode);
+	pernode += L1_CACHE_ALIGN(sizeof(struct ia64_node_data));
 
+	mem_data[node].pgdat->bdata = bdp;
+	pernode += L1_CACHE_ALIGN(sizeof(pg_data_t));
+
+	/*
+	 * Copy the static per-cpu data into the region we
+	 * just set aside and then setup __per_cpu_offset
+	 * for each CPU on this node.
+	 */
+	for (cpu = 0; cpu < NR_CPUS; cpu++) {
+		if (node = node_cpuid[cpu].nid) {
+			memcpy(__va(cpu_data), __phys_per_cpu_start,
+			       __per_cpu_end - __per_cpu_start);
+			__per_cpu_offset[cpu] = (char*)__va(cpu_data) -
+				__per_cpu_start;
+			cpu_data += PERCPU_PAGE_SIZE;
+		}
+	}
+
+	return;
+}
 /**
  * find_pernode_space - allocate memory for memory map and per-node structures
  * @start: physical start of range
@@ -304,9 +203,8 @@ static int early_nr_cpus_node(int node)
 static int __init find_pernode_space(unsigned long start, unsigned long len,
 				     int node)
 {
-	unsigned long epfn, cpu, cpus, phys_cpus;
+	unsigned long epfn;
 	unsigned long pernodesize = 0, pernode, pages, mapsize;
-	void *cpu_data;
 	struct bootmem_data *bdp = &mem_data[node].bootmem_data;
 
 	epfn = (start + len) >> PAGE_SHIFT;
@@ -329,49 +227,12 @@ static int __init find_pernode_space(uns
 	 * Calculate total size needed, incl. what's necessary
 	 * for good alignment and alias prevention.
 	 */
-	cpus = early_nr_cpus_node(node);
-	phys_cpus = early_nr_phys_cpus_node(node);
-	pernodesize += PERCPU_PAGE_SIZE * cpus;
-	pernodesize += node * L1_CACHE_BYTES;
-	pernodesize += L1_CACHE_ALIGN(sizeof(pg_data_t));
-	pernodesize += L1_CACHE_ALIGN(sizeof(struct ia64_node_data));
-	pernodesize = PAGE_ALIGN(pernodesize);
+	pernodesize = compute_pernodesize(node);
 	pernode = NODEDATA_ALIGN(start, node);
 
 	/* Is this range big enough for what we want to store here? */
-	if (start + len > (pernode + pernodesize + mapsize)) {
-		mem_data[node].pernode_addr = pernode;
-		mem_data[node].pernode_size = pernodesize;
-		memset(__va(pernode), 0, pernodesize);
-
-		cpu_data = (void *)pernode;
-		pernode += PERCPU_PAGE_SIZE * cpus;
-		pernode += node * L1_CACHE_BYTES;
-
-		mem_data[node].pgdat = __va(pernode);
-		pernode += L1_CACHE_ALIGN(sizeof(pg_data_t));
-
-		mem_data[node].node_data = __va(pernode);
-		pernode += L1_CACHE_ALIGN(sizeof(struct ia64_node_data));
-
-		mem_data[node].pgdat->bdata = bdp;
-		pernode += L1_CACHE_ALIGN(sizeof(pg_data_t));
-
-		/*
-		 * Copy the static per-cpu data into the region we
-		 * just set aside and then setup __per_cpu_offset
-		 * for each CPU on this node.
-		 */
-		for (cpu = 0; cpu < NR_CPUS; cpu++) {
-			if (node = node_cpuid[cpu].nid) {
-				memcpy(__va(cpu_data), __phys_per_cpu_start,
-				       __per_cpu_end - __per_cpu_start);
-				__per_cpu_offset[cpu] = (char*)__va(cpu_data) -
-					__per_cpu_start;
-				cpu_data += PERCPU_PAGE_SIZE;
-			}
-		}
-	}
+	if (start + len > (pernode + pernodesize + mapsize))
+		fill_pernode(node, pernode, pernodesize);
 
 	return 0;
 }
@@ -411,6 +272,9 @@ static void __init reserve_pernode_space
 	for_each_online_node(node) {
 		pg_data_t *pdp = mem_data[node].pgdat;
 
+		if (node_isset(node, memory_less_mask))
+			continue;
+
 		bdp = pdp->bdata;
 
 		/* First the bootmem_map itself */
@@ -456,6 +320,83 @@ static void __init initialize_pernode_da
 }
 
 /**
+ * memory_less_node_alloc - * attempt to allocate memory on the best NUMA slit
+ * 	node but fall back to any other node when __alloc_bootmem_node fails
+ *	for best.
+ * @nid: node id
+ * @pernodesize: size of this node's pernode data
+ * @align: alignment to use for this node's pernode data
+ */
+static void __init *memory_less_node_alloc(int nid, unsigned long pernodesize,
+	unsigned long align)
+{
+	void *ptr = NULL;
+	u8 best = 0xff;
+	int bestnode = -1, node;
+
+	for_each_online_node(node) {
+		if (node_isset(node, memory_less_mask))
+			continue;
+		else if (node_distance(nid, node) < best) {
+			best = node_distance(nid, node);
+			bestnode = node;
+		}
+	}
+
+	ptr = __alloc_bootmem_node(mem_data[bestnode].pgdat,
+		pernodesize, align, __pa(MAX_DMA_ADDRESS));
+
+	if (!ptr)
+		panic("NO memory for memory less node\n");
+	return ptr;
+}
+
+/**
+ * pgdat_insert - insert the pgdat into global pgdat_list
+ * @pgdat: the pgdat for a node.
+ */
+static void __init pgdat_insert(pg_data_t *pgdat)
+{
+	pg_data_t *prev = NULL, *next;
+
+	for_each_pgdat(next)
+		if (pgdat->node_id < next->node_id)
+			break;
+		else
+			prev = next;
+
+	if (prev) {
+		prev->pgdat_next = pgdat;
+		pgdat->pgdat_next = next;
+	} else {
+		pgdat->pgdat_next = pgdat_list;
+		pgdat_list = pgdat;
+	}
+
+	return;
+}
+
+/**
+ * memory_less_nodes - allocate and initialize CPU only nodes pernode
+ *	information.
+ */
+static void __init memory_less_nodes(void)
+{
+	unsigned long pernodesize;
+	void *pernode;
+	int node;
+
+	for_each_node_mask(node, memory_less_mask) {
+		pernodesize = compute_pernodesize(node);
+		pernode = memory_less_node_alloc(node, pernodesize,
+			(node) ? (node * PERCPU_PAGE_SIZE) : (1024*1024));
+		fill_pernode(node, __pa(pernode), pernodesize);
+	}
+
+	return;
+}
+
+/**
  * find_memory - walk the EFI memory map and setup the bootmem allocator
  *
  * Called early in boot to setup the bootmem allocator, and to
@@ -472,16 +413,19 @@ void __init find_memory(void)
 		node_set_online(0);
 	}
 
+	nodes_or(memory_less_mask, memory_less_mask, node_online_map);
 	min_low_pfn = -1;
 	max_low_pfn = 0;
 
-	if (num_online_nodes() > 1)
-		reassign_cpu_only_nodes();
-
 	/* These actually end up getting called by call_pernode_memory() */
 	efi_memmap_walk(filter_rsvd_memory, build_node_maps);
 	efi_memmap_walk(filter_rsvd_memory, find_pernode_space);
 
+	for_each_online_node(node)
+		if (mem_data[node].bootmem_data.node_low_pfn) {
+			node_clear(node, memory_less_mask);
+			mem_data[node].min_pfn = ~0UL;
+		}
 	/*
 	 * Initialize the boot memory maps in reverse order since that's
 	 * what the bootmem allocator expects
@@ -492,17 +436,14 @@ void __init find_memory(void)
 
 		if (!node_online(node))
 			continue;
+		else if (node_isset(node, memory_less_mask))
+			continue;
 
 		bdp = &mem_data[node].bootmem_data;
 		pernode = mem_data[node].pernode_addr;
 		pernodesize = mem_data[node].pernode_size;
 		map = pernode + pernodesize;
 
-		/* Sanity check... */
-		if (!pernode)
-			panic("pernode space for node %d "
-			      "could not be allocated!", node);
-
 		init_bootmem_node(mem_data[node].pgdat,
 				  map>>PAGE_SHIFT,
 				  bdp->node_boot_start>>PAGE_SHIFT,
@@ -512,6 +453,7 @@ void __init find_memory(void)
 	efi_memmap_walk(filter_rsvd_memory, free_node_bootmem);
 
 	reserve_pernode_space();
+	memory_less_nodes();
 	initialize_pernode_data();
 
 	max_pfn = max_low_pfn;
@@ -680,12 +622,13 @@ void __init paging_init(void)
 
 	max_dma = virt_to_phys((void *) MAX_DMA_ADDRESS) >> PAGE_SHIFT;
 
-	/* so min() will work in count_node_pages */
-	for_each_online_node(node)
-		mem_data[node].min_pfn = ~0UL;
-
 	efi_memmap_walk(filter_rsvd_memory, count_node_pages);
 
+	vmalloc_end -= PAGE_ALIGN(max_low_pfn * sizeof(struct page));
+	vmem_map = (struct page *) vmalloc_end;
+	efi_memmap_walk(create_mem_map_page_table, NULL);
+	printk("Virtual mem_map starts at 0x%p\n", vmem_map);
+
 	for_each_online_node(node) {
 		memset(zones_size, 0, sizeof(zones_size));
 		memset(zholes_size, 0, sizeof(zholes_size));
@@ -719,15 +662,6 @@ void __init paging_init(void)
 				 mem_data[node].num_dma_physpages);
 		}
 
-		if (node = 0) {
-			vmalloc_end --				PAGE_ALIGN(max_low_pfn * sizeof(struct page));
-			vmem_map = (struct page *) vmalloc_end;
-
-			efi_memmap_walk(create_mem_map_page_table, NULL);
-			printk("Virtual mem_map starts at 0x%p\n", vmem_map);
-		}
-
 		pfn_offset = mem_data[node].min_pfn;
 
 		NODE_DATA(node)->node_mem_map = vmem_map + pfn_offset;
@@ -735,5 +669,11 @@ void __init paging_init(void)
 				    pfn_offset, zholes_size);
 	}
 
+	/*
+	 * Make memory less nodes become a member of the known nodes.
+	 */
+	for_each_node_mask(node, memory_less_mask)
+		pgdat_insert(mem_data[node].pgdat);
+
 	zero_page_memmap_ptr = virt_to_page(ia64_imva(empty_zero_page));
 }
Index: linux-aegl-2.6.git-patches/arch/ia64/mm/init.c
=================================--- linux-aegl-2.6.git-patches.orig/arch/ia64/mm/init.c	2005-06-28 15:27:26.000000000 -0400
+++ linux-aegl-2.6.git-patches/arch/ia64/mm/init.c	2005-06-28 15:48:21.000000000 -0400
@@ -596,8 +596,9 @@ mem_init (void)
 	kclist_add(&kcore_vmem, (void *)VMALLOC_START, VMALLOC_END-VMALLOC_START);
 	kclist_add(&kcore_kernel, _stext, _end - _stext);
 
-	for_each_pgdat(pgdat)
-		totalram_pages += free_all_bootmem_node(pgdat);
+	for_each_pgdat(pgdat) 
+		if (pgdat->bdata->node_bootmem_map)
+			totalram_pages += free_all_bootmem_node(pgdat);
 
 	reserved_pages = 0;
 	efi_memmap_walk(count_reserved_pages, &reserved_pages);
