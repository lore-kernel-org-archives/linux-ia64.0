From: jbarnes@sgi.com (Jesse Barnes)
Date: Tue, 30 Sep 2003 00:11:35 +0000
Subject: [PATCH] more discontig stuff
Message-Id: <marc-linux-ia64-106488076517737@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Here's the latest.

  o removed changes to kernel/ksyms.c, mm/memory.c and
    include/linux/mm.h
  o created discontig specific versions of pfn_valid, page_to_pfn, and
    pfn_to_page (still almost identical to those in include/asm/page.h
    though)
  o added #ifdef CONFIG_DISCONTIGMEM include/asm/mmzone.h header file
  o other misc. fixes

Generic kernels work on sn2, and probably work on other NUMA platforms,
but fail on zx1 at the first alloc_pages() call.  Kernels configured
specifically for zx1 still work though.

 arch/ia64/Kconfig           |   37 --
 arch/ia64/Makefile          |    2 
 arch/ia64/kernel/setup.c    |   38 --
 arch/ia64/mm/contig.c       |  122 ++++++++
 arch/ia64/mm/discontig.c    |  612 +++++++++++++++++++++++++++-----------------
 arch/ia64/mm/init.c         |  131 +--------
 arch/ia64/sn/kernel/setup.c |    2 
 include/asm-ia64/meminit.h  |   24 +
 include/asm-ia64/mmzone.h   |  159 +----------
 include/asm-ia64/nodedata.h |   32 --
 include/asm-ia64/numa.h     |   18 -
 include/asm-ia64/page.h     |   14 -
 include/asm-ia64/percpu.h   |    2 
 include/asm-ia64/pgtable.h  |    4 

Jesse

diff -Nru a/arch/ia64/Kconfig b/arch/ia64/Kconfig
--- a/arch/ia64/Kconfig	Mon Sep 29 17:06:17 2003
+++ b/arch/ia64/Kconfig	Mon Sep 29 17:06:17 2003
@@ -64,8 +64,6 @@
 
 	  To find out what type of IA-64 system you have, you may want to
 	  check the IA-64 Linux web site at <http://www.linux-ia64.org/>.
-	  As of the time of this writing, most hardware is DIG compliant,
-	  so the "DIG-compliant" option is usually the right choice.
 
 	  HP-simulator   For the HP simulator
 	  (<http://software.hp.com/ia64linux/>).
@@ -91,6 +89,11 @@
 
 config IA64_SGI_SN2
 	bool "SGI-SN2"
+	help
+	  Build a kernel for SGI sn2-based systems.  Choosing this option
+	  rather than building a generic kernel will provide a small
+	  performance boost at the cost of not being able to use the kernel
+	  binary on non-Altix systems.
 
 endchoice
 
@@ -220,24 +223,8 @@
 	  Access).  This option is for configuring high-end multiprocessor
 	  server systems.  If in doubt, say N.
 
-choice
-	prompt "Maximum Memory per NUMA Node" if NUMA && IA64_DIG
-	depends on NUMA && IA64_DIG
-	default IA64_NODESIZE_16GB
-
-config IA64_NODESIZE_16GB
-	bool "16GB"
-
-config IA64_NODESIZE_64GB
-	bool "64GB"
-
-config IA64_NODESIZE_256GB
-	bool "256GB"
-
-endchoice
-
 config DISCONTIGMEM
-	bool "Discontiguous memory support" if (IA64_DIG || IA64_SGI_SN2 || IA64_GENERIC) && NUMA
+	bool "Discontiguous memory support" if (IA64_DIG || IA64_SGI_SN2 || IA64_GENERIC) && NUMA && VIRTUAL_MEM_MAP
 	default y if (IA64_SGI_SN2 || IA64_GENERIC) && NUMA
 	help
 	  Say Y to support efficient handling of discontiguous physical memory,
@@ -250,14 +237,10 @@
 	default y if !IA64_HP_SIM
 	help
 	  Say Y to compile the kernel with support for a virtual mem map.
-	  This is an alternate method of supporting large holes in the
-	  physical address space on non NUMA machines. Since the DISCONTIGMEM
-	  option is not supported on machines with the ZX1 chipset, this is
-	  the only way of supporting more than 1 Gb of memory on those
-	  machines. This code also only takes effect if a memory hole of
-	  greater than 1 Gb is found during boot, so it is safe to enable
-	  unless you require the DISCONTIGMEM option for your machine. If you
-	  are unsure, say Y.
+	  This code also only takes effect if a memory hole of greater than
+	  1 Gb is found during boot.  You must turn this option on if you
+	  require the DISCONTIGMEM option for your machine. If you are
+	  unsure, say Y.
 
 config IA64_MCA
 	bool "Enable IA-64 Machine Check Abort"
diff -Nru a/arch/ia64/Makefile b/arch/ia64/Makefile
--- a/arch/ia64/Makefile	Mon Sep 29 17:06:17 2003
+++ b/arch/ia64/Makefile	Mon Sep 29 17:06:17 2003
@@ -64,7 +64,7 @@
 drivers-$(CONFIG_PCI)		+= arch/ia64/pci/
 drivers-$(CONFIG_IA64_HP_SIM)	+= arch/ia64/hp/sim/
 drivers-$(CONFIG_IA64_HP_ZX1)	+= arch/ia64/hp/common/ arch/ia64/hp/zx1/
-drivers-$(CONFIG_IA64_GENERIC)	+= arch/ia64/hp/common/ arch/ia64/hp/zx1/ arch/ia64/hp/sim/
+drivers-$(CONFIG_IA64_GENERIC)	+= arch/ia64/hp/common/ arch/ia64/hp/zx1/ arch/ia64/hp/sim/ arch/ia64/sn/
 drivers-$(CONFIG_OPROFILE)	+= arch/ia64/oprofile/
 
 boot := arch/ia64/hp/sim/boot
diff -Nru a/arch/ia64/kernel/setup.c b/arch/ia64/kernel/setup.c
--- a/arch/ia64/kernel/setup.c	Mon Sep 29 17:06:17 2003
+++ b/arch/ia64/kernel/setup.c	Mon Sep 29 17:06:17 2003
@@ -101,7 +101,7 @@
 filter_rsvd_memory (unsigned long start, unsigned long end, void *arg)
 {
 	unsigned long range_start, range_end, prev_start;
-	void (*func)(unsigned long, unsigned long);
+	void (*func)(unsigned long, unsigned long, int);
 	int i;
 
 #if IGNORE_PFN0
@@ -122,11 +122,8 @@
 		range_end   = min(end, rsvd_region[i].start);
 
 		if (range_start < range_end)
-#ifdef CONFIG_DISCONTIGMEM
-			call_pernode_memory(__pa(range_start), __pa(range_end), func);
-#else
-			(*func)(__pa(range_start), range_end - range_start);
-#endif
+			call_pernode_memory(__pa(range_start),
+					    range_end - range_start, func);
 
 		/* nothing more available in this segment */
 		if (range_end = end) return 0;
@@ -239,7 +236,6 @@
 	strlcpy(saved_command_line, *cmdline_p, sizeof(saved_command_line));
 
 	efi_init();
-	find_memory();
 
 #ifdef CONFIG_ACPI_BOOT
 	/* Initialize the ACPI boot-time table parser */
@@ -253,6 +249,8 @@
 # endif
 #endif /* CONFIG_APCI_BOOT */
 
+	find_memory();
+
 	/* process SAL system table: */
 	ia64_sal_init(efi.sal_systab);
 
@@ -544,28 +542,7 @@
 	struct cpuinfo_ia64 *cpu_info;
 	void *cpu_data;
 
-#ifdef CONFIG_SMP
-	int cpu;
-
-	/*
-	 * get_free_pages() cannot be used before cpu_init() done.  BSP allocates
-	 * "NR_CPUS" pages for all CPUs to avoid that AP calls get_zeroed_page().
-	 */
-	if (smp_processor_id() = 0) {
-		cpu_data = __alloc_bootmem(PERCPU_PAGE_SIZE * NR_CPUS, PERCPU_PAGE_SIZE,
-					   __pa(MAX_DMA_ADDRESS));
-		for (cpu = 0; cpu < NR_CPUS; cpu++) {
-			memcpy(cpu_data, __phys_per_cpu_start, __per_cpu_end - __per_cpu_start);
-			__per_cpu_offset[cpu] = (char *) cpu_data - __per_cpu_start;
-			cpu_data += PERCPU_PAGE_SIZE;
-
-			per_cpu(local_per_cpu_offset, cpu) = __per_cpu_offset[cpu];
-		}
-	}
-	cpu_data = __per_cpu_start + __per_cpu_offset[smp_processor_id()];
-#else /* !CONFIG_SMP */
-	cpu_data = __phys_per_cpu_start;
-#endif /* !CONFIG_SMP */
+	cpu_data = per_cpu_init();
 
 	get_max_cacheline_size();
 
@@ -576,9 +553,6 @@
 	 * accessing cpu_data() through the canonical per-CPU address.
 	 */
 	cpu_info = cpu_data + ((char *) &__ia64_per_cpu_var(cpu_info) - __per_cpu_start);
-#ifdef CONFIG_NUMA
-	cpu_info->node_data = get_node_data_ptr();
-#endif
 	identify_cpu(cpu_info);
 
 #ifdef CONFIG_MCKINLEY
diff -Nru a/arch/ia64/mm/contig.c b/arch/ia64/mm/contig.c
--- a/arch/ia64/mm/contig.c	Mon Sep 29 17:06:17 2003
+++ b/arch/ia64/mm/contig.c	Mon Sep 29 17:06:17 2003
@@ -161,3 +161,125 @@
 
 	find_initrd();
 }
+
+#ifdef CONFIG_SMP
+/**
+ * per_cpu_init - setup per-cpu variables
+ *
+ * Allocate and setup per-cpu data areas.
+ */
+void *per_cpu_init(void)
+{
+	void *cpu_data;
+	int cpu;
+
+	/*
+	 * get_free_pages() cannot be used before cpu_init() done.  BSP
+	 * allocates "NR_CPUS" pages for all CPUs to avoid that AP calls
+	 * get_zeroed_page().
+	 */
+	if (smp_processor_id() = 0) {
+		cpu_data = __alloc_bootmem(PERCPU_PAGE_SIZE * NR_CPUS,
+					   PERCPU_PAGE_SIZE,
+					   __pa(MAX_DMA_ADDRESS));
+		for (cpu = 0; cpu < NR_CPUS; cpu++) {
+			memcpy(cpu_data, __phys_per_cpu_start,
+			       __per_cpu_end - __per_cpu_start);
+			__per_cpu_offset[cpu] = (char *) cpu_data -
+				__per_cpu_start;
+			cpu_data += PERCPU_PAGE_SIZE;
+			per_cpu(local_per_cpu_offset, cpu) +				__per_cpu_offset[cpu];
+		}
+	}
+	return __per_cpu_start + __per_cpu_offset[smp_processor_id()];
+}
+#endif /* CONFIG_SMP */
+
+static int
+count_pages (u64 start, u64 end, void *arg)
+{
+	unsigned long *count = arg;
+
+	*count += (end - start) >> PAGE_SHIFT;
+	return 0;
+}
+
+/*
+ * Set up the page tables.
+ */
+
+void
+paging_init (void)
+{
+	unsigned long max_dma;
+	unsigned long zones_size[MAX_NR_ZONES];
+#ifdef CONFIG_VIRTUAL_MEM_MAP
+	unsigned long zholes_size[MAX_NR_ZONES];
+	unsigned long max_gap;
+#endif
+
+	/* initialize mem_map[] */
+
+	memset(zones_size, 0, sizeof(zones_size));
+
+	num_physpages = 0;
+	efi_memmap_walk(count_pages, &num_physpages);
+
+	max_dma = virt_to_phys((void *) MAX_DMA_ADDRESS) >> PAGE_SHIFT;
+
+#ifdef CONFIG_VIRTUAL_MEM_MAP
+	memset(zholes_size, 0, sizeof(zholes_size));
+
+	num_dma_physpages = 0;
+	efi_memmap_walk(count_dma_pages, &num_dma_physpages);
+
+	if (max_low_pfn < max_dma) {
+		zones_size[ZONE_DMA] = max_low_pfn;
+		zholes_size[ZONE_DMA] = max_low_pfn - num_dma_physpages;
+	} else {
+		zones_size[ZONE_DMA] = max_dma;
+		zholes_size[ZONE_DMA] = max_dma - num_dma_physpages;
+		if (num_physpages > num_dma_physpages) {
+			zones_size[ZONE_NORMAL] = max_low_pfn - max_dma;
+			zholes_size[ZONE_NORMAL] +				((max_low_pfn - max_dma) -
+				 (num_physpages - num_dma_physpages));
+		}
+	}
+
+	max_gap = 0;
+	efi_memmap_walk(find_largest_hole, (u64 *)&max_gap);
+	if (max_gap < LARGE_GAP) {
+		vmem_map = (struct page *) 0;
+		free_area_init_node(0, &contig_page_data, NULL, zones_size, 0,
+				    zholes_size);
+		mem_map = contig_page_data.node_mem_map;
+	}
+	else {
+		unsigned long map_size;
+
+		/* allocate virtual_mem_map */
+
+		map_size = PAGE_ALIGN(max_low_pfn * sizeof(struct page));
+		vmalloc_end -= map_size;
+		vmem_map = (struct page *) vmalloc_end;
+		efi_memmap_walk(create_mem_map_page_table, 0);
+
+		free_area_init_node(0, &contig_page_data, vmem_map, zones_size,
+				    0, zholes_size);
+
+		mem_map = contig_page_data.node_mem_map;
+		printk("Virtual mem_map starts at 0x%p\n", mem_map);
+	}
+#else /* !CONFIG_VIRTUAL_MEM_MAP */
+	if (max_low_pfn < max_dma)
+		zones_size[ZONE_DMA] = max_low_pfn;
+	else {
+		zones_size[ZONE_DMA] = max_dma;
+		zones_size[ZONE_NORMAL] = max_low_pfn - max_dma;
+	}
+	free_area_init(zones_size);
+#endif /* !CONFIG_VIRTUAL_MEM_MAP */
+	zero_page_memmap_ptr = virt_to_page(ia64_imva(empty_zero_page));
+}
diff -Nru a/arch/ia64/mm/discontig.c b/arch/ia64/mm/discontig.c
--- a/arch/ia64/mm/discontig.c	Mon Sep 29 17:06:17 2003
+++ b/arch/ia64/mm/discontig.c	Mon Sep 29 17:06:17 2003
@@ -18,72 +18,52 @@
 #include <linux/acpi.h>
 #include <linux/efi.h>
 #include <asm/pgalloc.h>
+#include <asm/tlb.h>
 #include <asm/meminit.h>
+#include <asm/numa.h>
+#include <asm/sections.h>
 
+struct node_mem_data {
+	unsigned long num_physpages;
+	unsigned long num_dma_physpages;
+	unsigned long min_pfn;
+	unsigned long max_pfn;
+};
 
-/*
- * Round an address upward to the next multiple of GRANULE size.
- */
-#define GRANULEROUNDUP(n) (((n)+IA64_GRANULE_SIZE-1) & ~(IA64_GRANULE_SIZE-1))
-
-static struct ia64_node_data	*node_data[NR_NODES];
-static long			boot_pg_data[8*NR_NODES+sizeof(pg_data_t)]  __initdata;
+static struct ia64_node_data	*boot_node_data[NR_NODES] __initdata;
 static pg_data_t		*pg_data_ptr[NR_NODES] __initdata;
-static bootmem_data_t		bdata[NR_NODES][NR_BANKS_PER_NODE+1] __initdata;
-/*
- * Return the compact node number of this cpu. Used prior to
- * setting up the cpu_data area.
- *	Note - not fast, intended for boot use only!!
- */
-int
-boot_get_local_nodeid(void)
-{
-	int	i;
-
-	for (i = 0; i < NR_CPUS; i++)
-		if (node_cpuid[i].phys_id = hard_smp_processor_id())
-			return node_cpuid[i].nid;
-
-	/* node info missing, so nid should be 0.. */
-	return 0;
-}
-
-/*
- * Return a pointer to the pg_data structure for a node.
- * This function is used ONLY in early boot before the cpu_data
- * structure is available.
- */
-pg_data_t* __init
-boot_get_pg_data_ptr(long node)
-{
-	return pg_data_ptr[node];
-}
-
-
-/*
- * Return a pointer to the node data for the current node.
- *	(boottime initialization only)
+static struct bootmem_data	bdata[NR_NODES] __initdata;
+static unsigned long		boot_pernode[NR_NODES] __initdata;
+static unsigned long		boot_pernodesize[NR_NODES] __initdata;
+static struct node_mem_data	mem_data[NR_NODES] __initdata;
+
+/*
+ * To prevent cache aliasing effects, align per-node structures so that they 
+ * start at addresses that are strided by node number.
+ */
+#define NODEDATA_ALIGN(addr, node)	((((addr) + 1024*1024-1) & ~(1024*1024-1)) + (node)*PERCPU_PAGE_SIZE)
+
+/**
+ * build_node_maps - callback to setup bootmem structs for each node
+ * @start: physical start of range
+ * @len: length of range
+ * @node: node where this range resides
+ *
+ * We allocate a struct bootmem_data for each piece of memory that we wish to
+ * treat as a virtually contiguous block (i.e. each node). Each such block
+ * must start on an %IA64_GRANULE_SIZE boundary, so we round the address down
+ * if necessary.  Any non-existent pages will simply be part of the virtual
+ * memmap.  We also update min_low_pfn and max_low_pfn here as we receive
+ * memory ranges from the caller.
  */
-struct ia64_node_data *
-get_node_data_ptr(void)
+static int __init build_node_maps(unsigned long start, unsigned long len,
+				  int node)
 {
-	return node_data[boot_get_local_nodeid()];
-}
+	unsigned long cstart, epfn, end = start + len;
+	struct bootmem_data *bdp = &bdata[node];
 
-/*
- * We allocate one of the bootmem_data_t structs for each piece of memory
- * that we wish to treat as a contiguous block.  Each such block must start
- * on a BANKSIZE boundary.  Multiple banks per node is not supported.
- */
-static int __init
-build_maps(unsigned long pstart, unsigned long length, int node)
-{
-	bootmem_data_t	*bdp;
-	unsigned long cstart, epfn;
-
-	bdp = pg_data_ptr[node]->bdata;
-	epfn = GRANULEROUNDUP(pstart + length) >> PAGE_SHIFT;
-	cstart = pstart & ~(BANKSIZE - 1);
+	epfn = GRANULEROUNDUP(end) >> PAGE_SHIFT;
+	cstart = GRANULEROUNDDOWN(start);
 
 	if (!bdp->node_low_pfn) {
 		bdp->node_boot_start = cstart;
@@ -93,40 +73,153 @@
 		bdp->node_low_pfn = max(epfn, bdp->node_low_pfn);
 	}
 
-	min_low_pfn = min(min_low_pfn, bdp->node_boot_start>>PAGE_SHIFT);
-	max_low_pfn = max(max_low_pfn, bdp->node_low_pfn);
+	min_low_pfn = min(min_low_pfn,bdp->node_boot_start>>PAGE_SHIFT);
+	max_low_pfn = max(max_low_pfn,bdp->node_low_pfn);
 
 	return 0;
 }
 
-/*
- * Find space on each node for the bootmem map.
+/**
+ * early_nr_cpus_node - return number of cpus on a given node
+ * @node: node to check
  *
- * Called by efi_memmap_walk to find boot memory on each node. Note that
- * only blocks that are free are passed to this routine (currently filtered by
- * free_available_memory).
+ * Count the number of cpus on @node.  We can't use nr_cpus_node() yet because
+ * acpi_boot_init() (which builds the nod_to_cpu_mask array) hasn't been called
+ * yet.
  */
-static int __init
-find_bootmap_space(unsigned long pstart, unsigned long length, int node)
+static int early_nr_cpus_node(int node)
 {
-	unsigned long	mapsize, pages, epfn;
-	bootmem_data_t	*bdp;
+	int cpu, n = 0;
 
-	epfn = (pstart + length) >> PAGE_SHIFT;
-	bdp = &pg_data_ptr[node]->bdata[0];
+	for (cpu = 0; cpu < NR_CPUS; cpu++)
+		if (node = node_cpuid[cpu].nid)
+			n++;
+	return n;
+}
 
-	if (pstart < bdp->node_boot_start || epfn > bdp->node_low_pfn)
+/**
+ * find_pernode_space - allocate memory for memory map and per-node structures
+ * @start: physical start of range
+ * @len: length of range
+ * @node: node where this range resides
+ *
+ * This routine reserves space for the per-cpu data struct, the list of
+ * pg_data_ts and the per-node data struct.  Each node will have something like
+ * the following in the first chunk of addr. space large enough to hold it.
+ *
+ *    ________________________
+ *   |                        |
+ *   |~~~~~~~~~~~~~~~~~~~~~~~~| <-- NODEDATA_ALIGN(start, node) for the first
+ *   |    PERCPU_PAGE_SIZE *  |     start and length big enough
+ *   |        NR_CPUS         |
+ *   |------------------------|
+ *   |   local pg_data_t *    |
+ *   |------------------------|
+ *   |  local ia64_node_data  |
+ *   |------------------------| 
+ *   |          ???           |
+ *   \------------------------/
+ *
+ * Once this space has been set aside, the bootmem maps are initialized.  We
+ * could probably move the allocation of the per-cpu and ia64_node_data space
+ * outside of this function and use alloc_bootmem_node(), but doing it here
+ * is straightforward and we get the alignments we want so...
+ */
+static int __init find_pernode_space(unsigned long start, unsigned long len,
+				     int node)
+{
+	unsigned long epfn, cpu, cpus;
+	unsigned long pernodesize = 0, pernode;
+       	void *cpu_data;
+	struct bootmem_data *bdp = &bdata[node];
+
+	epfn = (start + len) >> PAGE_SHIFT;
+
+	/*
+	 * Make sure this memory falls within this node's usable memory
+	 * since we may have thrown some away in build_maps().
+	 */
+	if (start < bdp->node_boot_start ||
+	    epfn > bdp->node_low_pfn)
 		return 0;
 
-	if (!bdp->node_bootmem_map) {
-		pages = bdp->node_low_pfn - (bdp->node_boot_start>>PAGE_SHIFT);
+	/* Don't setup this node's local space twice... */
+	if (!boot_pernode[node]) {
+		/*
+		 * Calculate total size needed, incl. what's necessary
+		 * for good alignment and alias prevention.
+		 */
+		cpus = early_nr_cpus_node(node);
+		pernodesize += PERCPU_PAGE_SIZE * cpus;
+		pernodesize += L1_CACHE_ALIGN(sizeof(pg_data_t));
+		pernodesize += L1_CACHE_ALIGN(sizeof(struct ia64_node_data));
+		pernodesize = PAGE_ALIGN(pernodesize);
+		pernode = NODEDATA_ALIGN(start, node);
+	
+		/* Is this range big enough for what we want to store here? */
+		if (start + len > (pernode + pernodesize)) {
+			boot_pernode[node] = pernode;
+			boot_pernodesize[node] = pernodesize;
+			memset(__va(pernode), 0, pernodesize);
+
+			cpu_data = (void *)pernode;
+			pernode += PERCPU_PAGE_SIZE * cpus;
+
+			pg_data_ptr[node] = __va(pernode);
+			pernode += L1_CACHE_ALIGN(sizeof(pg_data_t));
+
+			boot_node_data[node] = __va(pernode);
+			pernode += L1_CACHE_ALIGN(sizeof(struct ia64_node_data));
+
+			pg_data_ptr[node]->bdata = bdp;
+			pernode += L1_CACHE_ALIGN(sizeof(pg_data_t));
+
+			/*
+			 * Copy the static per-cpu data into the region we
+			 * just set aside and then setup __per_cpu_offset
+			 * for each CPU on this node.
+			 */
+			for (cpu = 0; cpu < NR_CPUS; cpu++) {
+				if (node = node_cpuid[cpu].nid) {
+					memcpy(cpu_data, __phys_per_cpu_start,
+					       __per_cpu_end-__per_cpu_start);
+					__per_cpu_offset[cpu] +						(char*)__va(cpu_data) -
+						__per_cpu_start;
+					cpu_data +=  PERCPU_PAGE_SIZE;
+				}
+			}
+		}
+	}
+
+	pernode = boot_pernode[node];
+	pernodesize = boot_pernodesize[node];
+	if (pernode && !bdp->node_bootmem_map) {
+		/*
+		 * Now setup the bootmem map for this node if we haven't
+		 * already. Note that at this point,
+		 * pg_data_ptrs[n]->bdata = &bdata[n], but
+		 * we use the latter for convenience.
+		 */
+		unsigned long pages, mapsize, map = 0;
+
+		pages = bdp->node_low_pfn -
+			(bdp->node_boot_start >> PAGE_SHIFT);
 		mapsize = bootmem_bootmap_pages(pages) << PAGE_SHIFT;
-		if (length > mapsize) {
-			init_bootmem_node(
-				BOOT_NODE_DATA(node),
-				pstart>>PAGE_SHIFT, 
-				bdp->node_boot_start>>PAGE_SHIFT,
-				bdp->node_low_pfn);
+
+		/*
+		 * The map will either contain the pernode area or begin
+		 * after it.
+		 */
+		if (pernode - start > mapsize)
+			map = start;
+		else if (start + len - pernode - pernodesize > mapsize)
+			map = pernode + pernodesize;
+
+		if (map) {
+			init_bootmem_node(pg_data_ptr[node], map>>PAGE_SHIFT, 
+					  bdp->node_boot_start>>PAGE_SHIFT,
+					  bdp->node_low_pfn);
 		}
 
 	}
@@ -134,85 +227,87 @@
 	return 0;
 }
 
-
-/*
- * Free available memory to the bootmem allocator.
- *
- * Note that only blocks that are free are passed to this routine (currently 
- * filtered by free_available_memory).
+/**
+ * free_node_bootmem - free bootmem allocator memory for use
+ * @start: physical start of range
+ * @len: length of range
+ * @node: node where this range resides
  *
+ * Simply calls the bootmem allocator to free the specified ranged from
+ * the given pg_data_t's bdata struct.  After this function has been called
+ * for all the entries in the EFI memory map, the bootmem allocator will
+ * be ready to service allocation requests.
  */
-static int __init
-discontig_free_bootmem_node(unsigned long pstart, unsigned long length, int node)
+static int __init free_node_bootmem(unsigned long start, unsigned long len,
+				    int node)
 {
-	free_bootmem_node(BOOT_NODE_DATA(node), pstart, length);
+	free_bootmem_node(pg_data_ptr[node], start, len);
 
 	return 0;
 }
 
-
-/*
- * Reserve the space used by the bootmem maps.
- */
-static void __init
-discontig_reserve_bootmem(void)
-{
-	int		node;
-	unsigned long	mapbase, mapsize, pages;
-	bootmem_data_t	*bdp;
+/**
+ * reserve_pernode_space - reserve memory for per-node space
+ *
+ * Reserve the space used by the bootmem maps & per-node space in the boot
+ * allocator so that when we actually create the real mem maps we don't
+ * use their memory.
+ */
+static void __init reserve_pernode_space(void)
+{
+	unsigned long base, size, pages;
+	struct bootmem_data *bdp;
+	int node;
 
 	for (node = 0; node < numnodes; node++) {
-		bdp = BOOT_NODE_DATA(node)->bdata;
+		bdp = pg_data_ptr[node]->bdata;
 
+		/* First the bootmem_map itself */
 		pages = bdp->node_low_pfn - (bdp->node_boot_start>>PAGE_SHIFT);
-		mapsize = bootmem_bootmap_pages(pages) << PAGE_SHIFT;
-		mapbase = __pa(bdp->node_bootmem_map);
-		reserve_bootmem_node(BOOT_NODE_DATA(node), mapbase, mapsize);
+		size = bootmem_bootmap_pages(pages) << PAGE_SHIFT;
+		base = __pa(bdp->node_bootmem_map);
+		reserve_bootmem_node(pg_data_ptr[node], base, size);
+
+		/* Now the per-node space */
+		size = boot_pernodesize[node];
+		base = __pa(boot_pernode[node]);
+		reserve_bootmem_node(pg_data_ptr[node], base, size);
 	}
 }
 
-/*
- * Allocate per node tables.
- * 	- the pg_data structure is allocated on each node. This minimizes offnode 
- *	  memory references
- *	- the node data is allocated & initialized. Portions of this structure is read-only (after 
- *	  boot) and contains node-local pointers to usefuls data structures located on
- *	  other nodes.
- *
- * We also switch to using the "real" pg_data structures at this point. Earlier in boot, we
- * use a different structure. The only use for pg_data prior to the point in boot is to get 
- * the pointer to the bdata for the node.
- */
-static void __init
-allocate_pernode_structures(void)
-{
-	pg_data_t	*pgdat=0, *new_pgdat_list=0;
-	int		node, mynode;
-
-	mynode = boot_get_local_nodeid();
-	for (node = numnodes - 1; node >= 0 ; node--) {
-		node_data[node] = alloc_bootmem_node(BOOT_NODE_DATA(node), sizeof (struct ia64_node_data));
-		pgdat = __alloc_bootmem_node(BOOT_NODE_DATA(node), sizeof(pg_data_t), SMP_CACHE_BYTES, 0);
-		pgdat->bdata = &(bdata[node][0]);
-		pg_data_ptr[node] = pgdat;
-		pgdat->pgdat_next = new_pgdat_list;
-		new_pgdat_list = pgdat;
-	}
+/**
+ * initialize_pernode_data - fixup per-cpu & per-node pointers
+ *
+ * Each node's per-node area has a copy of the global pg_data_t list, so
+ * we copy that to each node here, as well as setting the per-cpu pointer
+ * to the local node data structure.  The active_cpus field of the per-node
+ * structure gets setup by the platform_cpu_init() function later.
+ */
+static void __init initialize_pernode_data(void)
+{
+	int cpu, node;
 
-	memcpy(node_data[mynode]->pg_data_ptrs, pg_data_ptr, sizeof(pg_data_ptr));
-	memcpy(node_data[mynode]->node_data_ptrs, node_data, sizeof(node_data));
+	/* Copy the pg_data_t list to each node and init the node field */
+	for (node = 0; node < numnodes; node++) {
+		memcpy(boot_node_data[node]->pg_data_ptrs,
+		       pg_data_ptr, sizeof(pg_data_ptr));
+	}
 
-	pgdat_list = new_pgdat_list;
+	/* Set the node_data pointer for each per-cpu struct */
+	for (cpu = 0; cpu < NR_CPUS; cpu++) {
+		node = node_cpuid[cpu].nid;
+		per_cpu(cpu_info, cpu).node_data = boot_node_data[node];
+	}
 }
 
-/*
- * Called early in boot to setup the boot memory allocator, and to
- * allocate the node-local pg_data & node-directory data structures..
+/**
+ * find_memory - walk the EFI memory map and setup the bootmem allocator
+ *
+ * Called early in boot to setup the bootmem allocator, and to
+ * allocate the per-cpu and per-node structures.
  */
 void __init find_memory(void)
 {
-	int	node;
-
 	reserve_memory();
 
 	if (numnodes = 0) {
@@ -220,94 +315,46 @@
 		numnodes = 1;
 	}
 
-	for (node = 0; node < numnodes; node++) {
-		pg_data_ptr[node] = (pg_data_t*) &boot_pg_data[node];
-		pg_data_ptr[node]->bdata = &bdata[node][0];
-	}
-
 	min_low_pfn = -1;
 	max_low_pfn = 0;
 
-        efi_memmap_walk(filter_rsvd_memory, build_maps);
-        efi_memmap_walk(filter_rsvd_memory, find_bootmap_space);
-        efi_memmap_walk(filter_rsvd_memory, discontig_free_bootmem_node);
-	discontig_reserve_bootmem();
-	allocate_pernode_structures();
+	/* These actually end up getting called by call_pernode_memory() */
+	efi_memmap_walk(filter_rsvd_memory, build_node_maps);
+	efi_memmap_walk(filter_rsvd_memory, find_pernode_space);
+	efi_memmap_walk(filter_rsvd_memory, free_node_bootmem);
+
+	reserve_pernode_space();
+	initialize_pernode_data();
 
 	find_initrd();
 }
 
-/*
- * Initialize the paging system.
- *	- determine sizes of each node
- *	- initialize the paging system for the node
- *	- build the nodedir for the node. This contains pointers to
- *	  the per-bank mem_map entries.
- *	- fix the page struct "virtual" pointers. These are bank specific
- *	  values that the paging system doesn't understand.
- *	- replicate the nodedir structure to other nodes
- */
-
-void __init
-discontig_paging_init(void)
-{
-	int		node, mynode;
-	unsigned long	max_dma, zones_size[MAX_NR_ZONES];
-	unsigned long	kaddr, ekaddr, bid;
-	struct page	*page;
-	bootmem_data_t	*bdp;
-
-	max_dma = virt_to_phys((void *) MAX_DMA_ADDRESS) >> PAGE_SHIFT;
-
-	mynode = boot_get_local_nodeid();
-	for (node = 0; node < numnodes; node++) {
-		long pfn, startpfn;
-
-		memset(zones_size, 0, sizeof(zones_size));
-
-		startpfn = -1;
-		bdp = BOOT_NODE_DATA(node)->bdata;
-		pfn = bdp->node_boot_start >> PAGE_SHIFT;
-		if (startpfn = -1)
-			startpfn = pfn;
-		if (pfn > max_dma)
-			zones_size[ZONE_NORMAL] += (bdp->node_low_pfn - pfn);
-		else if (bdp->node_low_pfn < max_dma)
-			zones_size[ZONE_DMA] += (bdp->node_low_pfn - pfn);
-		else {
-			zones_size[ZONE_DMA] += (max_dma - pfn);
-			zones_size[ZONE_NORMAL] += (bdp->node_low_pfn - max_dma);
-		}
-
-		free_area_init_node(node, NODE_DATA(node), NULL, zones_size, startpfn, 0);
-
-		page = NODE_DATA(node)->node_mem_map;
-
-		bdp = BOOT_NODE_DATA(node)->bdata;
+/**
+ * per_cpu_init - setup per-cpu variables
+ *
+ * find_pernode_space() does most of this already, we just need to set
+ * local_per_cpu_offset
+ */
+void *per_cpu_init(void)
+{
+	int cpu;
 
-		kaddr = (unsigned long)__va(bdp->node_boot_start);
-		ekaddr = (unsigned long)__va(bdp->node_low_pfn << PAGE_SHIFT);
-		while (kaddr < ekaddr) {
-			if (paddr_to_nid(__pa(kaddr)) = node) {
-				bid = BANK_MEM_MAP_INDEX(kaddr);
-				node_data[mynode]->node_id_map[bid] = node;
-				node_data[mynode]->bank_mem_map_base[bid] = page;
-			}
-			kaddr += BANKSIZE;
-			page += BANKSIZE/PAGE_SIZE;
+	if (smp_processor_id() = 0) {
+		for (cpu = 0; cpu < NR_CPUS; cpu++) {
+			per_cpu(local_per_cpu_offset, cpu) +				__per_cpu_offset[cpu];
 		}
 	}
 
-	/*
-	 * Finish setting up the node data for this node, then copy it to the other nodes.
-	 */
-	for (node=0; node < numnodes; node++)
-		if (mynode != node) {
-			memcpy(node_data[node], node_data[mynode], sizeof(struct ia64_node_data));
-			node_data[node]->node = node;
-		}
+	return __per_cpu_start + __per_cpu_offset[smp_processor_id()];
 }
-
+  
+/**
+ * show_mem - give short summary of memory stats
+ *
+ * Shows a simple page count of reserved and used pages in the system.
+ * For discontig machines, it does this on a per-pgdat basis.
+ */
 void show_mem(void)
 {
 	int i, reserved = 0;
@@ -316,6 +363,7 @@
 
 	printk("Mem-info:\n");
 	show_free_areas();
+
 	printk("Free swap:       %6dkB\n", nr_swap_pages<<(PAGE_SHIFT-10));
 	for_each_pgdat(pgdat) {
 		printk("Node ID: %d\n", pgdat->node_id);
@@ -324,8 +372,8 @@
 				reserved++;
 			else if (PageSwapCache(pgdat->node_mem_map+i))
 				cached++;
-			else if (page_count(pgdat->node_mem_map+i))
-				shared += page_count(pgdat->node_mem_map+i)-1;
+			else if (page_count(pgdat->node_mem_map + i))
+				shared += page_count(pgdat->node_mem_map + i) - 1;
 		}
 		printk("\t%ld pages of RAM\n", pgdat->node_present_pages);
 		printk("\t%d reserved pages\n", reserved);
@@ -336,7 +384,12 @@
 	printk("%d free buffer pages\n", nr_free_buffer_pages());
 }
 
-/*
+/**
+ * call_pernode_memory - use SRAT to call callback functions with node info
+ * @start: physical start of range
+ * @len: length of range
+ * @arg: function to call for each range
+ *
  * efi_memmap_walk() knows nothing about layout of memory across nodes. Find
  * out to which node a block of memory belongs.  Ignore memory that we cannot
  * identify, and split blocks that run across multiple nodes.
@@ -344,10 +397,10 @@
  * Take this opportunity to round the start address up and the end address
  * down to page boundaries.
  */
-void call_pernode_memory(unsigned long start, unsigned long end, void *arg)
+void call_pernode_memory(unsigned long start, unsigned long len, void *arg)
 {
-	unsigned long rs, re;
-	void (*func)(unsigned long, unsigned long, int, int);
+	unsigned long rs, re, end = start + len;
+	void (*func)(unsigned long, unsigned long, int);
 	int i;
 
 	start = PAGE_ALIGN(start);
@@ -358,21 +411,122 @@
 	func = arg;
 
 	if (!num_memblks) {
-		/*
-		 * This machine doesn't have SRAT, so call func with
-		 * nid=0, bank=0.
-		 */
+		/* No SRAT table, to assume one node (node 0) */
 		if (start < end)
-			(*func)(start, end - start, 0, 0);
+			(*func)(start, len, 0);
 		return;
 	}
 
 	for (i = 0; i < num_memblks; i++) {
 		rs = max(start, node_memblk[i].start_paddr);
-		re = min(end, node_memblk[i].start_paddr+node_memblk[i].size);
+		re = min(end, node_memblk[i].start_paddr +
+			 node_memblk[i].size);
 
 		if (rs < re)
-			(*func)(rs, re-rs, node_memblk[i].nid,
-				node_memblk[i].bank);
+			(*func)(rs, re - rs, node_memblk[i].nid);
+
+		if (re = end)
+			break;
 	}
+}
+
+/**
+ * count_node_pages - callback to build per-node memory info structures
+ * @start: physical start of range
+ * @len: length of range
+ * @node: node where this range resides
+ *
+ * Each node has it's own number of physical pages, DMAable pages, start, and
+ * end page frame number.  This routine will be called by call_pernode_memory()
+ * for each piece of usable memory and will setup these values for each node.
+ * Very similar to build_maps().
+ */
+static int count_node_pages(unsigned long start, unsigned long len, int node)
+{
+	unsigned long end = start + len;
+
+	mem_data[node].num_physpages += (end - start) >> PAGE_SHIFT;
+	if (start <= __pa(MAX_DMA_ADDRESS))
+		mem_data[node].num_dma_physpages ++			(min(end, __pa(MAX_DMA_ADDRESS)) - start) >>PAGE_SHIFT;
+	start = GRANULEROUNDDOWN(start);
+	start = ORDERROUNDDOWN(start);
+	end = GRANULEROUNDUP(end);
+	mem_data[node].max_pfn = max(mem_data[node].max_pfn,
+				     end >> PAGE_SHIFT);
+	mem_data[node].min_pfn = min(mem_data[node].min_pfn,
+				     start >> PAGE_SHIFT);
+
+	return 0;
+}
+
+/**
+ * paging_init - setup page tables
+ *
+ * paging_init() sets up the page tables for each node of the system and frees
+ * the bootmem allocator memory for general use.
+ */
+void paging_init(void)
+{
+	unsigned long max_dma;
+	unsigned long zones_size[MAX_NR_ZONES];
+	unsigned long zholes_size[MAX_NR_ZONES];
+	unsigned long max_gap, pfn_offset = 0;
+	int node;
+	
+	max_dma = virt_to_phys((void *) MAX_DMA_ADDRESS) >> PAGE_SHIFT;
+	max_gap = 0;
+	efi_memmap_walk(find_largest_hole, &max_gap);
+	efi_memmap_walk(filter_rsvd_memory, count_node_pages);
+
+	for (node = 0; node < numnodes; node++) {
+		memset(zones_size, 0, sizeof(zones_size));
+		memset(zholes_size, 0, sizeof(zholes_size));
+
+		num_dma_physpages += mem_data[node].num_dma_physpages;
+		num_physpages += mem_data[node].num_physpages;
+
+		if (mem_data[node].min_pfn >= max_dma) {
+			/* All of this node's memory is above ZONE_DMA */
+			zones_size[ZONE_NORMAL] = mem_data[node].max_pfn -
+				mem_data[node].min_pfn;
+			zholes_size[ZONE_NORMAL] = mem_data[node].max_pfn -
+				mem_data[node].min_pfn -
+				mem_data[node].num_physpages;
+		} else if (mem_data[node].max_pfn < max_dma) {
+			/* All of this node's memory is in ZONE_DMA */
+			zones_size[ZONE_DMA] = mem_data[node].max_pfn -
+				mem_data[node].min_pfn;
+			zholes_size[ZONE_DMA] = mem_data[node].max_pfn -
+				mem_data[node].min_pfn -
+				mem_data[node].num_dma_physpages;
+		} else {
+			/* This node has memory in both zones */
+			zones_size[ZONE_DMA] = max_dma -
+				mem_data[node].min_pfn;
+			zholes_size[ZONE_DMA] = zones_size[ZONE_DMA] -
+				mem_data[node].num_dma_physpages;
+			zones_size[ZONE_NORMAL] = mem_data[node].max_pfn -
+				max_dma;
+			zholes_size[ZONE_NORMAL] = zones_size[ZONE_NORMAL] -
+				(mem_data[node].num_physpages -
+				 mem_data[node].num_dma_physpages);
+		}
+
+		if (node = 0) {
+			vmalloc_end -+				PAGE_ALIGN(max_low_pfn * sizeof(struct page));
+			vmem_map = (struct page *) vmalloc_end;
+
+			efi_memmap_walk(create_mem_map_page_table, 0);
+			printk("Virtual mem_map starts at 0x%p\n", vmem_map);
+			pfn_offset = mem_data[node].min_pfn;
+		}
+
+		free_area_init_node(node, NODE_DATA(node),
+				    vmem_map + pfn_offset, zones_size,
+				    pfn_offset, zholes_size);
+	}
+
+	zero_page_memmap_ptr = virt_to_page(ia64_imva(empty_zero_page));
 }
diff -Nru a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
--- a/arch/ia64/mm/init.c	Mon Sep 29 17:06:17 2003
+++ b/arch/ia64/mm/init.c	Mon Sep 29 17:06:17 2003
@@ -24,6 +24,7 @@
 #include <asm/ia32.h>
 #include <asm/io.h>
 #include <asm/machvec.h>
+#include <asm/meminit.h>
 #include <asm/patch.h>
 #include <asm/pgalloc.h>
 #include <asm/sal.h>
@@ -40,10 +41,11 @@
 unsigned long MAX_DMA_ADDRESS = PAGE_OFFSET + 0x100000000UL;
 
 #ifdef CONFIG_VIRTUAL_MEM_MAP
-# define LARGE_GAP	0x40000000	/* Use virtual mem map if hole is > than this */
-  unsigned long vmalloc_end = VMALLOC_END_INIT;
-  static struct page *vmem_map;
-  static unsigned long num_dma_physpages;
+/* Use virtual mem map if hole is > than this */
+#define LARGE_GAP 0x40000000
+unsigned long vmalloc_end = VMALLOC_END_INIT;
+struct page *vmem_map;
+unsigned long num_dma_physpages;
 #endif
 
 static int pgt_cache_water[2] = { 25, 50 };
@@ -337,11 +339,12 @@
 
 #ifdef CONFIG_VIRTUAL_MEM_MAP
 
-static int
+int
 create_mem_map_page_table (u64 start, u64 end, void *arg)
 {
 	unsigned long address, start_page, end_page;
 	struct page *map_start, *map_end;
+	int node;
 	pgd_t *pgd;
 	pmd_t *pmd;
 	pte_t *pte;
@@ -351,19 +354,20 @@
 
 	start_page = (unsigned long) map_start & PAGE_MASK;
 	end_page = PAGE_ALIGN((unsigned long) map_end);
+	node = paddr_to_nid(__pa(start));
 
 	for (address = start_page; address < end_page; address += PAGE_SIZE) {
 		pgd = pgd_offset_k(address);
 		if (pgd_none(*pgd))
-			pgd_populate(&init_mm, pgd, alloc_bootmem_pages(PAGE_SIZE));
+			pgd_populate(&init_mm, pgd, alloc_bootmem_pages_node(NODE_DATA(node), PAGE_SIZE));
 		pmd = pmd_offset(pgd, address);
 
 		if (pmd_none(*pmd))
-			pmd_populate_kernel(&init_mm, pmd, alloc_bootmem_pages(PAGE_SIZE));
+			pmd_populate_kernel(&init_mm, pmd, alloc_bootmem_pages_node(NODE_DATA(node), PAGE_SIZE));
 		pte = pte_offset_kernel(pmd, address);
 
 		if (pte_none(*pte))
-			set_pte(pte, pfn_pte(__pa(alloc_bootmem_pages(PAGE_SIZE)) >> PAGE_SHIFT,
+			set_pte(pte, pfn_pte(__pa(alloc_bootmem_pages_node(NODE_DATA(node), PAGE_SIZE)) >> PAGE_SHIFT,
 					     PAGE_KERNEL));
 	}
 	return 0;
@@ -426,14 +430,6 @@
 }
 
 int
-ia64_pfn_valid (unsigned long pfn)
-{
-	char byte;
-
-	return __get_user(byte, (char *) pfn_to_page(pfn)) = 0;
-}
-
-static int
 count_dma_pages (u64 start, u64 end, void *arg)
 {
 	unsigned long *count = arg;
@@ -443,7 +439,7 @@
 	return 0;
 }
 
-static int
+int
 find_largest_hole (u64 start, u64 end, void *arg)
 {
 	u64 *max_gap = arg;
@@ -459,102 +455,17 @@
 }
 #endif /* CONFIG_VIRTUAL_MEM_MAP */
 
-static int
-count_pages (u64 start, u64 end, void *arg)
-{
-	unsigned long *count = arg;
-
-	*count += (end - start) >> PAGE_SHIFT;
-	return 0;
-}
-
-/*
- * Set up the page tables.
- */
-
-#ifdef CONFIG_DISCONTIGMEM
-void
-paging_init (void)
-{
-	extern void discontig_paging_init(void);
-
-	discontig_paging_init();
-	efi_memmap_walk(count_pages, &num_physpages);
-	zero_page_memmap_ptr = virt_to_page(ia64_imva(empty_zero_page));
-}
-#else /* !CONFIG_DISCONTIGMEM */
-void
-paging_init (void)
+int
+ia64_pfn_valid (unsigned long pfn)
 {
-	unsigned long max_dma;
-	unsigned long zones_size[MAX_NR_ZONES];
-#  ifdef CONFIG_VIRTUAL_MEM_MAP
-	unsigned long zholes_size[MAX_NR_ZONES];
-	unsigned long max_gap;
-#  endif
-
-	/* initialize mem_map[] */
-
-	memset(zones_size, 0, sizeof(zones_size));
-
-	num_physpages = 0;
-	efi_memmap_walk(count_pages, &num_physpages);
-
-	max_dma = virt_to_phys((void *) MAX_DMA_ADDRESS) >> PAGE_SHIFT;
-
-#  ifdef CONFIG_VIRTUAL_MEM_MAP
-	memset(zholes_size, 0, sizeof(zholes_size));
-
-	num_dma_physpages = 0;
-	efi_memmap_walk(count_dma_pages, &num_dma_physpages);
-
-	if (max_low_pfn < max_dma) {
-		zones_size[ZONE_DMA] = max_low_pfn;
-		zholes_size[ZONE_DMA] = max_low_pfn - num_dma_physpages;
-	} else {
-		zones_size[ZONE_DMA] = max_dma;
-		zholes_size[ZONE_DMA] = max_dma - num_dma_physpages;
-		if (num_physpages > num_dma_physpages) {
-			zones_size[ZONE_NORMAL] = max_low_pfn - max_dma;
-			zholes_size[ZONE_NORMAL] = ((max_low_pfn - max_dma)
-						    - (num_physpages - num_dma_physpages));
-		}
-	}
-
-	max_gap = 0;
-	efi_memmap_walk(find_largest_hole, (u64 *)&max_gap);
-	if (max_gap < LARGE_GAP) {
-		vmem_map = (struct page *) 0;
-		free_area_init_node(0, &contig_page_data, NULL, zones_size, 0, zholes_size);
-		mem_map = contig_page_data.node_mem_map;
-	}
-	else {
-		unsigned long map_size;
-
-		/* allocate virtual_mem_map */
-
-		map_size = PAGE_ALIGN(max_low_pfn * sizeof(struct page));
-		vmalloc_end -= map_size;
-		vmem_map = (struct page *) vmalloc_end;
-		efi_memmap_walk(create_mem_map_page_table, 0);
-
-		free_area_init_node(0, &contig_page_data, vmem_map, zones_size, 0, zholes_size);
+#ifdef CONFIG_VIRTUAL_MEM_MAP
+	char byte;
 
-		mem_map = contig_page_data.node_mem_map;
-		printk("Virtual mem_map starts at 0x%p\n", mem_map);
-	}
-#  else /* !CONFIG_VIRTUAL_MEM_MAP */
-	if (max_low_pfn < max_dma)
-		zones_size[ZONE_DMA] = max_low_pfn;
-	else {
-		zones_size[ZONE_DMA] = max_dma;
-		zones_size[ZONE_NORMAL] = max_low_pfn - max_dma;
-	}
-	free_area_init(zones_size);
-#  endif /* !CONFIG_VIRTUAL_MEM_MAP */
-	zero_page_memmap_ptr = virt_to_page(ia64_imva(empty_zero_page));
+	return __get_user(byte, (char *) pfn_to_page(pfn)) = 0;
+#else
+	return 1;
+#endif
 }
-#endif /* !CONFIG_DISCONTIGMEM */
 
 static int
 count_reserved_pages (u64 start, u64 end, void *arg)
diff -Nru a/arch/ia64/sn/kernel/setup.c b/arch/ia64/sn/kernel/setup.c
--- a/arch/ia64/sn/kernel/setup.c	Mon Sep 29 17:06:17 2003
+++ b/arch/ia64/sn/kernel/setup.c	Mon Sep 29 17:06:17 2003
@@ -147,7 +147,6 @@
  * Sets up an initial console to aid debugging.  Intended primarily
  * for bringup.  See start_kernel() in init/main.c.
  */
-#if defined(CONFIG_IA64_EARLY_PRINTK_SGI_SN) || defined(CONFIG_IA64_SGI_SN_SIM)
 
 void __init
 early_sn_setup(void)
@@ -189,7 +188,6 @@
 		printk(KERN_DEBUG "early_sn_setup: setting master_node_bedrock_address to 0x%lx\n", master_node_bedrock_address);
 	}
 }
-#endif /* CONFIG_IA64_EARLY_PRINTK_SGI_SN */
 
 #ifdef CONFIG_IA64_MCA
 extern int platform_intr_list[];
diff -Nru a/include/asm-ia64/meminit.h b/include/asm-ia64/meminit.h
--- a/include/asm-ia64/meminit.h	Mon Sep 29 17:06:17 2003
+++ b/include/asm-ia64/meminit.h	Mon Sep 29 17:06:17 2003
@@ -31,10 +31,32 @@
 extern void reserve_memory (void);
 extern void find_initrd (void);
 extern int filter_rsvd_memory (unsigned long start, unsigned long end, void *arg);
+extern void paging_init(void);
+ 
+/*
+ * For rounding an address to the next IA64_GRANULE_SIZE or order
+ */
+#define GRANULEROUNDDOWN(n) ((n) & ~(IA64_GRANULE_SIZE-1))
+#define GRANULEROUNDUP(n) (((n)+IA64_GRANULE_SIZE-1) & ~(IA64_GRANULE_SIZE-1))
+#define ORDERROUNDDOWN(n) ((n) & ~((PAGE_SIZE<<MAX_ORDER)-1))
 
 #ifdef CONFIG_DISCONTIGMEM
-extern void call_pernode_memory (unsigned long start, unsigned long end, void *arg);
+extern void call_pernode_memory(unsigned long start, unsigned long len,
+				void *func);
+#else
+#define call_pernode_memory(start, len, func)	(*func)(start, len, 0)
 #endif
+
+#ifdef CONFIG_VIRTUAL_MEM_MAP
+#define LARGE_GAP 0x40000000 /* Use virtual mem map if hole is > than this */
+extern unsigned long vmalloc_end;
+extern struct page *vmem_map;
+extern unsigned long num_dma_physpages;
+extern int find_largest_hole(u64 start, u64 end, void *arg);
+extern int create_mem_map_page_table(u64 start, u64 end, void *arg);
+extern int count_dma_pages(u64 start, u64 end, void *arg);
+#endif
+
 
 #define IGNORE_PFN0	1	/* XXX fix me: ignore pfn 0 until TLB miss handler is updated... */
 
diff -Nru a/include/asm-ia64/mmzone.h b/include/asm-ia64/mmzone.h
--- a/include/asm-ia64/mmzone.h	Mon Sep 29 17:06:17 2003
+++ b/include/asm-ia64/mmzone.h	Mon Sep 29 17:06:17 2003
@@ -3,7 +3,7 @@
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
  *
- * Copyright (c) 2000 Silicon Graphics, Inc.  All rights reserved.
+ * Copyright (c) 2000,2003 Silicon Graphics, Inc.  All rights reserved.
  * Copyright (c) 2002 NEC Corp.
  * Copyright (c) 2002 Erich Focht <efocht@ess.nec.de>
  * Copyright (c) 2002 Kimio Suganuma <k-suganuma@da.jp.nec.com>
@@ -12,152 +12,27 @@
 #define _ASM_IA64_MMZONE_H
 
 #include <linux/config.h>
-#include <linux/init.h>
+#include <asm/page.h>
+#include <asm/meminit.h>
 
-/*
- * Given a kaddr, find the base mem_map address for the start of the mem_map
- * entries for the bank containing the kaddr.
- */
-#define BANK_MEM_MAP_BASE(kaddr) local_node_data->bank_mem_map_base[BANK_MEM_MAP_INDEX(kaddr)]
-
-/*
- * Given a kaddr, this macro return the relative map number 
- * within the bank.
- */
-#define BANK_MAP_NR(kaddr) 	(BANK_OFFSET(kaddr) >> PAGE_SHIFT)
-
-/*
- * Given a pte, this macro returns a pointer to the page struct for the pte.
- */
-#define pte_page(pte)	virt_to_page(PAGE_OFFSET | (pte_val(pte)&_PFN_MASK))
-
-/*
- * Determine if a kaddr is a valid memory address of memory that
- * actually exists. 
- *
- * The check consists of 2 parts:
- *	- verify that the address is a region 7 address & does not 
- *	  contain any bits that preclude it from being a valid platform
- *	  memory address
- *	- verify that the chunk actually exists.
- *
- * Note that IO addresses are NOT considered valid addresses.
- *
- * Note, many platforms can simply check if kaddr exceeds a specific size.  
- *	(However, this won't work on SGI platforms since IO space is embedded 
- * 	within the range of valid memory addresses & nodes have holes in the 
- *	address range between banks). 
- */
-#define kern_addr_valid(kaddr)		({long _kav=(long)(kaddr);	\
-					VALID_MEM_KADDR(_kav);})
-
-/*
- * Given a kaddr, return a pointer to the page struct for the page.
- * If the kaddr does not represent RAM memory that potentially exists, return
- * a pointer the page struct for max_mapnr. IO addresses will
- * return the page for max_nr. Addresses in unpopulated RAM banks may
- * return undefined results OR may panic the system.
- *
- */
-#define virt_to_page(kaddr)	({long _kvtp=(long)(kaddr);	\
-				(VALID_MEM_KADDR(_kvtp))	\
-					? BANK_MEM_MAP_BASE(_kvtp) + BANK_MAP_NR(_kvtp)	\
-					: NULL;})
-
-/*
- * Given a page struct entry, return the physical address that the page struct represents.
- * Since IA64 has all memory in the DMA zone, the following works:
- */
-#define page_to_phys(page)	__pa(page_address(page))
-
-#define node_mem_map(nid)	(NODE_DATA(nid)->node_mem_map)
-
-#define node_localnr(pfn, nid)	((pfn) - NODE_DATA(nid)->node_start_pfn)
-
-#define pfn_to_page(pfn)	(struct page *)(node_mem_map(pfn_to_nid(pfn)) + node_localnr(pfn, pfn_to_nid(pfn)))
-
-#define pfn_to_nid(pfn)		 local_node_data->node_id_map[(pfn << PAGE_SHIFT) >> BANKSHIFT]
-
-#define page_to_pfn(page)	(long)((page - page_zone(page)->zone_mem_map) + page_zone(page)->zone_start_pfn)
+#ifdef CONFIG_DISCONTIGMEM
 
+#ifdef CONFIG_IA64_DIG /* DIG systems are small */
+#define MAX_PHYSNODE_ID	8
+#define NR_NODES	8
+#define NR_MEMBLKS	(NR_NODES * 32)
+#else /* sn2 is the biggest case, so we use that if !DIG */
+#define MAX_PHYSNODE_ID	2048
+#define NR_NODES	256
+#define NR_MEMBLKS	(NR_NODES)
+#endif
 
-/*
- * pfn_valid should be made as fast as possible, and the current definition
- * is valid for machines that are NUMA, but still contiguous, which is what
- * is currently supported. A more generalised, but slower definition would
- * be something like this - mbligh:
- * ( pfn_to_pgdat(pfn) && (pfn < node_end_pfn(pfn_to_nid(pfn))) )
- */
-#define pfn_valid(pfn)          (pfn < max_low_pfn)
 extern unsigned long max_low_pfn;
 
+#define pfn_valid(pfn)		(((pfn) < max_low_pfn) && ia64_pfn_valid(pfn))
+#define page_to_pfn(page)	((unsigned long) (page - vmem_map))
+#define pfn_to_page(pfn)	(vmem_map + (pfn))
 
-#ifdef CONFIG_IA64_DIG
-
-/*
- * Platform definitions for DIG platform with contiguous memory.
- */
-#define MAX_PHYSNODE_ID	8	/* Maximum node number +1 */
-#define NR_NODES	8	/* Maximum number of nodes in SSI */
-
-#define MAX_PHYS_MEMORY	(1UL << 40)	/* 1 TB */
-
-/*
- * Bank definitions.
- * Configurable settings for DIG: 512MB/bank:  16GB/node,
- *                               2048MB/bank:  64GB/node,
- *                               8192MB/bank: 256GB/node.
- */
-#define NR_BANKS_PER_NODE	32
-#if defined(CONFIG_IA64_NODESIZE_16GB)
-# define BANKSHIFT		29
-#elif defined(CONFIG_IA64_NODESIZE_64GB)
-# define BANKSHIFT		31
-#elif defined(CONFIG_IA64_NODESIZE_256GB)
-# define BANKSHIFT		33
-#else
-# error Unsupported bank and nodesize!
-#endif
-#define BANKSIZE		(1UL << BANKSHIFT)
-#define BANK_OFFSET(addr)	((unsigned long)(addr) & (BANKSIZE-1))
-#define NR_BANKS		(NR_BANKS_PER_NODE * NR_NODES)
-
-/*
- * VALID_MEM_KADDR returns a boolean to indicate if a kaddr is
- * potentially a valid cacheable identity mapped RAM memory address.
- * Note that the RAM may or may not actually be present!!
- */
-#define VALID_MEM_KADDR(kaddr)	1
-
-/*
- * Given a nodeid & a bank number, find the address of the mem_map
- * entry for the first page of the bank.
- */
-#define BANK_MEM_MAP_INDEX(kaddr) \
-	(((unsigned long)(kaddr) & (MAX_PHYS_MEMORY-1)) >> BANKSHIFT)
-
-#elif defined(CONFIG_IA64_SGI_SN2)
-/*
- * SGI SN2 discontig definitions
- */
-#define MAX_PHYSNODE_ID	2048	/* 2048 node ids (also called nasid) */
-#define NR_NODES	128	/* Maximum number of nodes in SSI */
-#define MAX_PHYS_MEMORY	(1UL << 49)
-
-#define BANKSHIFT		38
-#define NR_BANKS_PER_NODE	4
-#define SN2_NODE_SIZE		(64UL*1024*1024*1024)	/* 64GB per node */
-#define BANKSIZE		(SN2_NODE_SIZE/NR_BANKS_PER_NODE)
-#define BANK_OFFSET(addr)	((unsigned long)(addr) & (BANKSIZE-1))
-#define NR_BANKS		(NR_BANKS_PER_NODE * NR_NODES)
-#define VALID_MEM_KADDR(kaddr)	1
-
-/*
- * Given a nodeid & a bank number, find the address of the mem_map
- * entry for the first page of the bank.
- */
-#define BANK_MEM_MAP_INDEX(kaddr) \
-	(((unsigned long)(kaddr) & (MAX_PHYS_MEMORY-1)) >> BANKSHIFT)
+#endif /* CONFIG_DISCONTIGMEM */
 
-#endif /* CONFIG_IA64_DIG */
 #endif /* _ASM_IA64_MMZONE_H */
diff -Nru a/include/asm-ia64/nodedata.h b/include/asm-ia64/nodedata.h
--- a/include/asm-ia64/nodedata.h	Mon Sep 29 17:06:17 2003
+++ b/include/asm-ia64/nodedata.h	Mon Sep 29 17:06:17 2003
@@ -13,9 +13,12 @@
 #ifndef _ASM_IA64_NODEDATA_H
 #define _ASM_IA64_NODEDATA_H
 
-
+#include <linux/config.h>
+#include <asm/percpu.h>
 #include <asm/mmzone.h>
 
+#ifdef CONFIG_DISCONTIGMEM
+
 /*
  * Node Data. One of these structures is located on each node of a NUMA system.
  */
@@ -24,10 +27,7 @@
 struct ia64_node_data {
 	short			active_cpu_count;
 	short			node;
-        struct pglist_data	*pg_data_ptrs[NR_NODES];
-	struct page		*bank_mem_map_base[NR_BANKS];
-	struct ia64_node_data	*node_data_ptrs[NR_NODES];
-	short			node_id_map[NR_BANKS];
+	struct pglist_data	*pg_data_ptrs[NR_NODES];
 };
 
 
@@ -36,41 +36,23 @@
  */
 #define local_node_data		(local_cpu_data->node_data)
 
-
-/*
- * Return a pointer to the node_data structure for the specified node.
- */
-#define node_data(node)	(local_node_data->node_data_ptrs[node])
-
 /*
  * Get a pointer to the node_id/node_data for the current cpu.
  *    (boot time only)
  */
-extern int boot_get_local_nodeid(void);
-extern struct ia64_node_data *get_node_data_ptr(void);
+extern struct ia64_node_data *early_get_node_data(void);
 
 /*
  * Given a node id, return a pointer to the pg_data_t for the node.
- * The following 2 macros are similar. 
  *
  * NODE_DATA 	- should be used in all code not related to system
  *		  initialization. It uses pernode data structures to minimize
  *		  offnode memory references. However, these structure are not 
  *		  present during boot. This macro can be used once cpu_init
  *		  completes.
- *
- * BOOT_NODE_DATA
- *		- should be used during system initialization 
- *		  prior to freeing __initdata. It does not depend on the percpu
- *		  area being present.
- *
- * NOTE:   The names of these macros are misleading but are difficult to change
- *	   since they are used in generic linux & on other architecures.
  */
 #define NODE_DATA(nid)		(local_node_data->pg_data_ptrs[nid])
-#define BOOT_NODE_DATA(nid)	boot_get_pg_data_ptr((long)(nid))
 
-struct pglist_data;
-extern struct pglist_data * __init boot_get_pg_data_ptr(long);
+#endif /* CONFIG_DISCONTIGMEM */
 
 #endif /* _ASM_IA64_NODEDATA_H */
diff -Nru a/include/asm-ia64/numa.h b/include/asm-ia64/numa.h
--- a/include/asm-ia64/numa.h	Mon Sep 29 17:06:17 2003
+++ b/include/asm-ia64/numa.h	Mon Sep 29 17:06:17 2003
@@ -13,18 +13,13 @@
 
 #include <linux/config.h>
 #include <linux/cpumask.h>
+#include <linux/cache.h>
+#include <linux/threads.h>
+#include <linux/smp.h>
+#include <asm/mmzone.h>
 
 #ifdef CONFIG_NUMA
 
-#ifdef CONFIG_DISCONTIGMEM
-# include <asm/mmzone.h>
-# define NR_MEMBLKS   (NR_BANKS)
-#else
-# define NR_NODES     (8)
-# define NR_MEMBLKS   (NR_NODES * 8)
-#endif
-
-#include <linux/cache.h>
 extern volatile char cpu_to_node_map[NR_CPUS] __cacheline_aligned;
 extern volatile cpumask_t node_to_cpu_mask[NR_NODES] __cacheline_aligned;
 
@@ -65,7 +60,10 @@
 
 extern int paddr_to_nid(unsigned long paddr);
 
-#define local_nodeid (cpu_to_node_map[smp_processor_id()])
+#else /* !CONFIG_NUMA */
+
+#define node_distance(from,to) 10
+#define paddr_to_nid(x) 0
 
 #endif /* CONFIG_NUMA */
 
diff -Nru a/include/asm-ia64/page.h b/include/asm-ia64/page.h
--- a/include/asm-ia64/page.h	Mon Sep 29 17:06:17 2003
+++ b/include/asm-ia64/page.h	Mon Sep 29 17:06:17 2003
@@ -94,18 +94,16 @@
 
 #define virt_addr_valid(kaddr)	pfn_valid(__pa(kaddr) >> PAGE_SHIFT)
 
+extern int ia64_pfn_valid (unsigned long pfn);
+
 #ifndef CONFIG_DISCONTIGMEM
-# ifdef CONFIG_VIRTUAL_MEM_MAP
-   extern int ia64_pfn_valid (unsigned long pfn);
-#  define pfn_valid(pfn)	(((pfn) < max_mapnr) && ia64_pfn_valid(pfn))
-# else
-#  define pfn_valid(pfn)	((pfn) < max_mapnr)
-# endif
-#define virt_to_page(kaddr)	pfn_to_page(__pa(kaddr) >> PAGE_SHIFT)
+#define pfn_valid(pfn)		(((pfn) < max_mapnr) && ia64_pfn_valid(pfn))
 #define page_to_pfn(page)	((unsigned long) (page - mem_map))
 #define pfn_to_page(pfn)	(mem_map + (pfn))
+#endif /* CONFIG_DISCONTIGMEM */
+
 #define page_to_phys(page)	(page_to_pfn(page) << PAGE_SHIFT)
-#endif
+#define virt_to_page(kaddr)	pfn_to_page(__pa(kaddr) >> PAGE_SHIFT)
 
 typedef union ia64_va {
 	struct {
diff -Nru a/include/asm-ia64/percpu.h b/include/asm-ia64/percpu.h
--- a/include/asm-ia64/percpu.h	Mon Sep 29 17:06:17 2003
+++ b/include/asm-ia64/percpu.h	Mon Sep 29 17:06:17 2003
@@ -46,11 +46,13 @@
 
 extern void percpu_modcopy(void *pcpudst, const void *src, unsigned long size);
 extern void setup_per_cpu_areas (void);
+extern void *per_cpu_init(void);
 
 #else /* ! SMP */
 
 #define per_cpu(var, cpu)			((void)cpu, per_cpu__##var)
 #define __get_cpu_var(var)			per_cpu__##var
+#define per_cpu_init()				(__phys_per_cpu_start)
 
 #endif	/* SMP */
 
diff -Nru a/include/asm-ia64/pgtable.h b/include/asm-ia64/pgtable.h
--- a/include/asm-ia64/pgtable.h	Mon Sep 29 17:06:17 2003
+++ b/include/asm-ia64/pgtable.h	Mon Sep 29 17:06:17 2003
@@ -174,7 +174,6 @@
 	return (addr & (local_cpu_data->unimpl_pa_mask)) = 0;
 }
 
-#ifndef CONFIG_DISCONTIGMEM
 /*
  * kern_addr_valid(ADDR) tests if ADDR is pointing to valid kernel
  * memory.  For the return value to be meaningful, ADDR must be >@@ -190,7 +189,6 @@
  */
 #define kern_addr_valid(addr)	(1)
 
-#endif
 
 /*
  * Now come the defines and routines to manage and access the three-level
@@ -241,10 +239,8 @@
 #define pte_none(pte) 			(!pte_val(pte))
 #define pte_present(pte)		(pte_val(pte) & (_PAGE_P | _PAGE_PROTNONE))
 #define pte_clear(pte)			(pte_val(*(pte)) = 0UL)
-#ifndef CONFIG_DISCONTIGMEM
 /* pte_page() returns the "struct page *" corresponding to the PTE: */
 #define pte_page(pte)			virt_to_page(((pte_val(pte) & _PFN_MASK) + PAGE_OFFSET))
-#endif
 
 #define pmd_none(pmd)			(!pmd_val(pmd))
 #define pmd_bad(pmd)			(!ia64_phys_addr_valid(pmd_val(pmd)))
