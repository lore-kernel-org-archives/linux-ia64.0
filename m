From: jbarnes@sgi.com (Jesse Barnes)
Date: Fri, 19 Dec 2003 23:20:57 +0000
Subject: [PATCH] initialize bootmem maps in reverse order
Message-Id: <marc-linux-ia64-107187618522723@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-107151544512148@msgid-missing>
In-Reply-To: <marc-linux-ia64-107151544512148@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The arch-independent bootmem code now requires that arches initialize
their bootmem maps in reverse order (in particular, from high to low
addesses), otherwise alloc_bootmem_pages_low() won't work.  This change
makes the ia64 code do just that, so that machines without an IOMMU can
allocate their bounce buffers in low memory at early boot.  It also adds
a sanity check to the early init code to make sure that each node has a
local data area, because if they don't, many things will break later on
and may be hard to track down.

Jesse

diff -Nru a/arch/ia64/mm/discontig.c b/arch/ia64/mm/discontig.c
--- a/arch/ia64/mm/discontig.c	Fri Dec 19 15:16:57 2003
+++ b/arch/ia64/mm/discontig.c	Fri Dec 19 15:16:57 2003
@@ -134,94 +134,69 @@
 				     int node)
 {
 	unsigned long epfn, cpu, cpus;
-	unsigned long pernodesize = 0, pernode;
-       	void *cpu_data;
+	unsigned long pernodesize = 0, pernode, pages, mapsize;
+	void *cpu_data;
 	struct bootmem_data *bdp = &mem_data[node].bootmem_data;
 
 	epfn = (start + len) >> PAGE_SHIFT;
 
+	pages = bdp->node_low_pfn - (bdp->node_boot_start >> PAGE_SHIFT);
+	mapsize = bootmem_bootmap_pages(pages) << PAGE_SHIFT;
+
 	/*
 	 * Make sure this memory falls within this node's usable memory
 	 * since we may have thrown some away in build_maps().
 	 */
-	if (start < bdp->node_boot_start ||
-	    epfn > bdp->node_low_pfn)
+	if (start < bdp->node_boot_start || epfn > bdp->node_low_pfn)
 		return 0;
 
 	/* Don't setup this node's local space twice... */
-	if (!mem_data[node].pernode_addr) {
-		/*
-		 * Calculate total size needed, incl. what's necessary
-		 * for good alignment and alias prevention.
-		 */
-		cpus = early_nr_cpus_node(node);
-		pernodesize += PERCPU_PAGE_SIZE * cpus;
-		pernodesize += L1_CACHE_ALIGN(sizeof(pg_data_t));
-		pernodesize += L1_CACHE_ALIGN(sizeof(struct ia64_node_data));
-		pernodesize = PAGE_ALIGN(pernodesize);
-		pernode = NODEDATA_ALIGN(start, node);
-
-		/* Is this range big enough for what we want to store here? */
-		if (start + len > (pernode + pernodesize)) {
-			mem_data[node].pernode_addr = pernode;
-			mem_data[node].pernode_size = pernodesize;
-			memset(__va(pernode), 0, pernodesize);
-
-			cpu_data = (void *)pernode;
-			pernode += PERCPU_PAGE_SIZE * cpus;
-
-			mem_data[node].pgdat = __va(pernode);
-			pernode += L1_CACHE_ALIGN(sizeof(pg_data_t));
-
-			mem_data[node].node_data = __va(pernode);
-			pernode += L1_CACHE_ALIGN(sizeof(struct ia64_node_data));
-
-			mem_data[node].pgdat->bdata = bdp;
-			pernode += L1_CACHE_ALIGN(sizeof(pg_data_t));
-
-			/*
-			 * Copy the static per-cpu data into the region we
-			 * just set aside and then setup __per_cpu_offset
-			 * for each CPU on this node.
-			 */
-			for (cpu = 0; cpu < NR_CPUS; cpu++) {
-				if (node = node_cpuid[cpu].nid) {
-					memcpy(__va(cpu_data), __phys_per_cpu_start,
-					       __per_cpu_end-__per_cpu_start);
-					__per_cpu_offset[cpu] -						(char*)__va(cpu_data) -
-						__per_cpu_start;
-					cpu_data += PERCPU_PAGE_SIZE;
-				}
-			}
-		}
-	}
+	if (mem_data[node].pernode_addr)
+		return 0;
+
+	/*
+	 * Calculate total size needed, incl. what's necessary
+	 * for good alignment and alias prevention.
+	 */
+	cpus = early_nr_cpus_node(node);
+	pernodesize += PERCPU_PAGE_SIZE * cpus;
+	pernodesize += L1_CACHE_ALIGN(sizeof(pg_data_t));
+	pernodesize += L1_CACHE_ALIGN(sizeof(struct ia64_node_data));
+	pernodesize = PAGE_ALIGN(pernodesize);
+	pernode = NODEDATA_ALIGN(start, node);
+
+	/* Is this range big enough for what we want to store here? */
+	if (start + len > (pernode + pernodesize + mapsize)) {
+		mem_data[node].pernode_addr = pernode;
+		mem_data[node].pernode_size = pernodesize;
+		memset(__va(pernode), 0, pernodesize);
+
+		cpu_data = (void *)pernode;
+		pernode += PERCPU_PAGE_SIZE * cpus;
+
+		mem_data[node].pgdat = __va(pernode);
+		pernode += L1_CACHE_ALIGN(sizeof(pg_data_t));
 
-	pernode = mem_data[node].pernode_addr;
-	pernodesize = mem_data[node].pernode_size;
-	if (pernode && !bdp->node_bootmem_map) {
-		unsigned long pages, mapsize, map = 0;
-
-		pages = bdp->node_low_pfn -
-			(bdp->node_boot_start >> PAGE_SHIFT);
-		mapsize = bootmem_bootmap_pages(pages) << PAGE_SHIFT;
+		mem_data[node].node_data = __va(pernode);
+		pernode += L1_CACHE_ALIGN(sizeof(struct ia64_node_data));
+
+		mem_data[node].pgdat->bdata = bdp;
+		pernode += L1_CACHE_ALIGN(sizeof(pg_data_t));
 
 		/*
-		 * The map will either contain the pernode area or begin
-		 * after it.
+		 * Copy the static per-cpu data into the region we
+		 * just set aside and then setup __per_cpu_offset
+		 * for each CPU on this node.
 		 */
-		if (pernode - start > mapsize)
-			map = start;
-		else if (start + len - pernode - pernodesize > mapsize)
-			map = pernode + pernodesize;
-
-		if (map) {
-			init_bootmem_node(mem_data[node].pgdat,
-					  map>>PAGE_SHIFT,
-					  bdp->node_boot_start>>PAGE_SHIFT,
-					  bdp->node_low_pfn);
+		for (cpu = 0; cpu < NR_CPUS; cpu++) {
+			if (node = node_cpuid[cpu].nid) {
+				memcpy(__va(cpu_data), __phys_per_cpu_start,
+				       __per_cpu_end - __per_cpu_start);
+				__per_cpu_offset[cpu] = (char*)__va(cpu_data) -
+					__per_cpu_start;
+				cpu_data += PERCPU_PAGE_SIZE;
+			}
 		}
-
 	}
 
 	return 0;
@@ -314,6 +289,8 @@
  */
 void __init find_memory(void)
 {
+	int node;
+
 	reserve_memory();
 
 	if (numnodes = 0) {
@@ -327,6 +304,31 @@
 	/* These actually end up getting called by call_pernode_memory() */
 	efi_memmap_walk(filter_rsvd_memory, build_node_maps);
 	efi_memmap_walk(filter_rsvd_memory, find_pernode_space);
+
+	/*
+	 * Initialize the boot memory maps in reverse order since that's
+	 * what the bootmem allocator expects
+	 */
+	for (node = numnodes - 1; node >= 0; node--) {
+		unsigned long pernode, pernodesize, map;
+		struct bootmem_data *bdp;
+
+		bdp = &mem_data[node].bootmem_data;
+		pernode = mem_data[node].pernode_addr;
+		pernodesize = mem_data[node].pernode_size;
+		map = pernode + pernodesize;
+
+		/* Sanity check... */
+		if (!pernode)
+			panic("pernode space for node %d "
+			      "could not be allocated!", node);
+
+		init_bootmem_node(mem_data[node].pgdat,
+				  map>>PAGE_SHIFT,
+				  bdp->node_boot_start>>PAGE_SHIFT,
+				  bdp->node_low_pfn);
+	}
+
 	efi_memmap_walk(filter_rsvd_memory, free_node_bootmem);
 
 	reserve_pernode_space();
