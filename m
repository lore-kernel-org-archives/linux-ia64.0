From: jbarnes@sgi.com (Jesse Barnes)
Date: Wed, 24 Sep 2003 01:26:13 +0000
Subject: Re: [PATCH] discontig patch (work in progress)
Message-Id: <marc-linux-ia64-106436683002988@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106436165231302@msgid-missing>
In-Reply-To: <marc-linux-ia64-106436165231302@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Sep 23, 2003 at 04:56:40PM -0700, Jesse Barnes wrote:
> done, like removing the shouting from GRANULEROUND* and naming nodeid()
> something better (maybe numa_node_id()?).

How about I just nuke it since numa_node_id() is already defined in
include/linux/mmzone.h?  Here's an updated version.  And even though
CONFIG_DISCONTIGMEM depends on CONFIG_VIRTUAL_MEM_MAP with this patch,
I've left the #if defined(VIRTUAL_MEM_MAP) || !defined(DISCONTIGMEM) in
the ia64 files as opposed to removing them altogether since (1) it's
more consistent with the rest of the tree that way and (2) I'd like to
remove that dependency so we can measure the perf. impact of virtual
memmap on discontig machines like David said he wanted to do for zx1.

Thanks,
Jesse

diff -Naur -X /home/jbarnes/dontdiff --exclude=MAINTAINERS --exclude=pci_irq.c --exclude=tables.c --exclude=qla1280.c --exclude=logo --exclude=char linux-ia64-2.5-contig/arch/ia64/Kconfig linux-ia64-2.5-sn/arch/ia64/Kconfig
--- linux-ia64-2.5-contig/arch/ia64/Kconfig	Mon Sep 22 15:27:01 2003
+++ linux-ia64-2.5-sn/arch/ia64/Kconfig	Tue Sep 23 09:47:17 2003
@@ -220,24 +220,8 @@
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
@@ -250,14 +234,10 @@
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
diff -Naur -X /home/jbarnes/dontdiff --exclude=MAINTAINERS --exclude=pci_irq.c --exclude=tables.c --exclude=qla1280.c --exclude=logo --exclude=char linux-ia64-2.5-contig/arch/ia64/Makefile linux-ia64-2.5-sn/arch/ia64/Makefile
--- linux-ia64-2.5-contig/arch/ia64/Makefile	Mon Sep 22 15:27:01 2003
+++ linux-ia64-2.5-sn/arch/ia64/Makefile	Mon Sep 22 15:22:09 2003
@@ -64,7 +64,7 @@
 drivers-$(CONFIG_PCI)		+= arch/ia64/pci/
 drivers-$(CONFIG_IA64_HP_SIM)	+= arch/ia64/hp/sim/
 drivers-$(CONFIG_IA64_HP_ZX1)	+= arch/ia64/hp/common/ arch/ia64/hp/zx1/
-drivers-$(CONFIG_IA64_GENERIC)	+= arch/ia64/hp/common/ arch/ia64/hp/zx1/ arch/ia64/hp/sim/
+drivers-$(CONFIG_IA64_GENERIC)	+= arch/ia64/hp/common/ arch/ia64/hp/zx1/ arch/ia64/hp/sim/ arch/ia64/sn/
 drivers-$(CONFIG_OPROFILE)	+= arch/ia64/oprofile/
 
 boot := arch/ia64/hp/sim/boot
diff -Naur -X /home/jbarnes/dontdiff --exclude=MAINTAINERS --exclude=pci_irq.c --exclude=tables.c --exclude=qla1280.c --exclude=logo --exclude=char linux-ia64-2.5-contig/arch/ia64/kernel/acpi.c linux-ia64-2.5-sn/arch/ia64/kernel/acpi.c
--- linux-ia64-2.5-contig/arch/ia64/kernel/acpi.c	Mon Sep 22 15:27:01 2003
+++ linux-ia64-2.5-sn/arch/ia64/kernel/acpi.c	Mon Sep 22 15:22:09 2003
@@ -379,7 +379,7 @@
 void __init
 acpi_numa_memory_affinity_init (struct acpi_table_memory_affinity *ma)
 {
-	unsigned long paddr, size, hole_size, min_hole_size;
+	unsigned long paddr, size;
 	u8 pxm;
 	struct node_memblk_s *p, *q, *pend;
 
@@ -401,34 +401,6 @@
 	if (!ma->flags.enabled)
 		return;
 
-	/*
-	 * When the chunk is not the first one in the node, check distance
-	 * from the other chunks. When the hole is too huge ignore the chunk.
-	 * This restriction should be removed when multiple chunks per node
-	 * is supported.
-	 */
-	pend = &node_memblk[num_memblks];
-	min_hole_size = 0;
-	for (p = &node_memblk[0]; p < pend; p++) {
-		if (p->nid != pxm)
-			continue;
-		if (p->start_paddr < paddr)
-			hole_size = paddr - (p->start_paddr + p->size);
-		else
-			hole_size = p->start_paddr - (paddr + size);
-
-		if (!min_hole_size || hole_size < min_hole_size)
-			min_hole_size = hole_size;
-	}
-
-	if (min_hole_size) {
-		if (min_hole_size > size) {
-			printk(KERN_ERR "Too huge memory hole. Ignoring %ld MBytes at %lx\n",
-			       size/(1024*1024), paddr);
-			return;
-		}
-	}
-
 	/* record this node in proximity bitmap */
 	pxm_bit_set(pxm);
 
diff -Naur -X /home/jbarnes/dontdiff --exclude=MAINTAINERS --exclude=pci_irq.c --exclude=tables.c --exclude=qla1280.c --exclude=logo --exclude=char linux-ia64-2.5-contig/arch/ia64/kernel/setup.c linux-ia64-2.5-sn/arch/ia64/kernel/setup.c
--- linux-ia64-2.5-contig/arch/ia64/kernel/setup.c	Tue Sep 23 10:40:41 2003
+++ linux-ia64-2.5-sn/arch/ia64/kernel/setup.c	Tue Sep 23 14:05:08 2003
@@ -101,7 +101,7 @@
 filter_rsvd_memory (unsigned long start, unsigned long end, void *arg)
 {
 	unsigned long range_start, range_end, prev_start;
-	void (*func)(unsigned long, unsigned long);
+	void (*func)(unsigned long, unsigned long, int);
 	int i;
 
 #if IGNORE_PFN0
@@ -123,9 +123,9 @@
 
 		if (range_start < range_end)
 #ifdef CONFIG_DISCONTIGMEM
-			call_pernode_memory(__pa(range_start), __pa(range_end), func);
+			call_pernode_memory(range_start, range_end, arg);
 #else
-			(*func)(__pa(range_start), range_end - range_start);
+			(*func)(range_start, range_end, 0);
 #endif
 
 		/* nothing more available in this segment */
@@ -237,7 +237,6 @@
 	strlcpy(saved_command_line, *cmdline_p, sizeof(saved_command_line));
 
 	efi_init();
-	find_memory();
 
 #ifdef CONFIG_ACPI_BOOT
 	/* Initialize the ACPI boot-time table parser */
@@ -251,6 +250,8 @@
 # endif
 #endif /* CONFIG_APCI_BOOT */
 
+	find_memory();
+
 	/* process SAL system table: */
 	ia64_sal_init(efi.sal_systab);
 
@@ -542,28 +543,7 @@
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
 
@@ -575,7 +555,7 @@
 	 */
 	cpu_info = cpu_data + ((char *) &__ia64_per_cpu_var(cpu_info) - __per_cpu_start);
 #ifdef CONFIG_NUMA
-	cpu_info->node_data = get_node_data_ptr();
+	cpu_info->node_data = early_get_node_data();
 #endif
 	identify_cpu(cpu_info);
 
diff -Naur -X /home/jbarnes/dontdiff --exclude=MAINTAINERS --exclude=pci_irq.c --exclude=tables.c --exclude=qla1280.c --exclude=logo --exclude=char linux-ia64-2.5-contig/arch/ia64/mm/contig.c linux-ia64-2.5-sn/arch/ia64/mm/contig.c
--- linux-ia64-2.5-contig/arch/ia64/mm/contig.c	Mon Sep 22 18:28:52 2003
+++ linux-ia64-2.5-sn/arch/ia64/mm/contig.c	Tue Sep 23 09:11:54 2003
@@ -155,3 +155,36 @@
 
 	find_initrd();
 }
+
+/**
+ * per_cpu_init - setup per-cpu variables
+ *
+ * Allocate and setup per-cpu data areas.
+ */
+void *per_cpu_init(void)
+{
+	void *cpu_data;
+
+#ifdef CONFIG_SMP
+	int cpu;
+
+	/*
+	 * get_free_pages() cannot be used before cpu_init() done.  BSP allocates
+	 * "NR_CPUS" pages for all CPUs to avoid that AP calls get_zeroed_page().
+	 */
+
+	if (smp_processor_id() = 0) {
+		cpu_data = __alloc_bootmem(PERCPU_PAGE_SIZE * NR_CPUS, PERCPU_PAGE_SIZE,
+					   __pa(MAX_DMA_ADDRESS));
+		for (cpu = 0; cpu < NR_CPUS; cpu++) {
+			memcpy(cpu_data, __phys_per_cpu_start, __per_cpu_end - __per_cpu_start);
+			__per_cpu_offset[cpu] = (char *) cpu_data - __per_cpu_start;
+			cpu_data += PERCPU_PAGE_SIZE;
+			per_cpu(local_per_cpu_offset, cpu) = __per_cpu_offset[cpu];
+		}
+	}
+	return __per_cpu_start + __per_cpu_offset[smp_processor_id()];
+#else /* !CONFIG_SMP */
+	return __phys_per_cpu_start;
+#endif /* !CONFIG_SMP */
+}
diff -Naur -X /home/jbarnes/dontdiff --exclude=MAINTAINERS --exclude=pci_irq.c --exclude=tables.c --exclude=qla1280.c --exclude=logo --exclude=char linux-ia64-2.5-contig/arch/ia64/mm/discontig.c linux-ia64-2.5-sn/arch/ia64/mm/discontig.c
--- linux-ia64-2.5-contig/arch/ia64/mm/discontig.c	Mon Sep 22 18:18:27 2003
+++ linux-ia64-2.5-sn/arch/ia64/mm/discontig.c	Tue Sep 23 17:28:14 2003
@@ -18,115 +18,188 @@
 #include <linux/acpi.h>
 #include <linux/efi.h>
 #include <asm/pgalloc.h>
+#include <asm/tlb.h>
 #include <asm/meminit.h>
+#include <asm/numa.h>
+#include <asm/sections.h>
 
-
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
+static struct bootmem_data	bdata[NR_NODES] __initdata;
+static unsigned long		boot_pernode[NR_NODES] __initdata;
+static unsigned long		boot_pernodesize[NR_NODES] __initdata;
 
 /*
- * Return a pointer to the pg_data structure for a node.
- * This function is used ONLY in early boot before the cpu_data
- * structure is available.
+ * To prevent cache aliasing effects, align per-node structures so that they 
+ * start at addresses that are strided by node number.
  */
-pg_data_t* __init
-boot_get_pg_data_ptr(long node)
-{
-	return pg_data_ptr[node];
-}
-
+#define NODEDATA_ALIGN(addr, node)	((((addr) + 1024*1024-1) & ~(1024*1024-1)) + (node)*PERCPU_PAGE_SIZE)
 
-/*
- * Return a pointer to the node data for the current node.
- *	(boottime initialization only)
+/**
+ * early_get_node_data - get node_data structure address
+ *
+ * Returns the address of the already allocated ia64_node_data struct.  Used
+ * to fill in the per-cpu pointer to the local node's ia64_node_data *.
  */
-struct ia64_node_data *
-get_node_data_ptr(void)
+struct ia64_node_data* __init early_get_node_data(void)
 {
-	return node_data[boot_get_local_nodeid()];
+	return boot_node_data[numa_node_id()];
 }
 
-/*
- * We allocate one of the bootmem_data_t structs for each piece of memory
- * that we wish to treat as a contiguous block.  Each such block must start
- * on a BANKSIZE boundary.  Multiple banks per node is not supported.
+/**
+ * build_maps - callback to setup bootmem structs for each node
+ * @start: start of range
+ * @end: end of range
+ * @node: node where this range resides
+ *
+ * We allocate a struct bootmem_data for each piece of memory
+ * that we wish to treat as a virtually contiguous block (i.e. each node).
+ * Each such block must start on an %IA64_GRANULE_SIZE boundary, so we round
+ * the address down if necessary.  Any non-existent pages will simply be part
+ * of the virtual memmap.  We also update min_low_pfn and max_low_pfn here
+ * as we receive memory ranges from the caller.
  */
-static int __init
-build_maps(unsigned long pstart, unsigned long length, int node)
+static int __init build_maps(unsigned long start, unsigned long end, int node)
 {
-	bootmem_data_t	*bdp;
 	unsigned long cstart, epfn;
 
-	bdp = pg_data_ptr[node]->bdata;
-	epfn = GRANULEROUNDUP(pstart + length) >> PAGE_SHIFT;
-	cstart = pstart & ~(BANKSIZE - 1);
-
-	if (!bdp->node_low_pfn) {
-		bdp->node_boot_start = cstart;
-		bdp->node_low_pfn = epfn;
+	epfn = GRANULEROUNDUP(__pa(end)) >> PAGE_SHIFT;
+	cstart = GRANULEROUNDDOWN(__pa(start));
+
+	if (!bdata[node].node_low_pfn) {
+		bdata[node].node_boot_start = cstart;
+		bdata[node].node_low_pfn = epfn;
 	} else {
-		bdp->node_boot_start = min(cstart, bdp->node_boot_start);
-		bdp->node_low_pfn = max(epfn, bdp->node_low_pfn);
+		bdata[node].node_boot_start = min(cstart,
+						  bdata[node].node_boot_start);
+		bdata[node].node_low_pfn = max(epfn, bdata[node].node_low_pfn);
 	}
 
-	min_low_pfn = min(min_low_pfn, bdp->node_boot_start>>PAGE_SHIFT);
-	max_low_pfn = max(max_low_pfn, bdp->node_low_pfn);
+	min_low_pfn = min(min_low_pfn,bdata[node].node_boot_start>>PAGE_SHIFT);
+	max_low_pfn = max(max_low_pfn,bdata[node].node_low_pfn);
 
 	return 0;
 }
 
-/*
- * Find space on each node for the bootmem map.
+/**
+ * count_cpus - return number of cpus on a given node
+ * @node: node to check
  *
- * Called by efi_memmap_walk to find boot memory on each node. Note that
- * only blocks that are free are passed to this routine (currently filtered by
- * free_available_memory).
+ * Count the number of cpus on @node.
  */
-static int __init
-find_bootmap_space(unsigned long pstart, unsigned long length, int node)
+static __inline__ int count_cpus(int node)
 {
-	unsigned long	mapsize, pages, epfn;
-	bootmem_data_t	*bdp;
+	int cpu, n = 0;
+
+	for (cpu = 0; cpu < NR_CPUS; cpu++)
+		if (node = node_cpuid[cpu].nid)
+			n++;
+	return n;
+}
 
+/**
+ * find_pernode_space - allocate memory for memory map and per-node structures
+ * @start: start of range
+ * @end: end of range
+ * @node: node where this range resides
+ *
+ * This routine reserves space for the per-cpu data struct, the list of
+ * pg_data_ts and the per-node data struct.
+ */
+static int __init find_pernode_space(unsigned long start, unsigned long end,
+				     int node)
+{
+	unsigned long epfn, cpu, cpus;
+	unsigned long pernodesize=0, pernode;
+	unsigned long pstart, length;
+       	void *cpu_data;
+
+	pstart = __pa(start);
+	length = end - start;
 	epfn = (pstart + length) >> PAGE_SHIFT;
-	bdp = &pg_data_ptr[node]->bdata[0];
 
-	if (pstart < bdp->node_boot_start || epfn > bdp->node_low_pfn)
+	/* Make sure this memory falls within this node */
+	if (pstart < bdata[node].node_boot_start ||
+	    epfn > bdata[node].node_low_pfn)
 		return 0;
 
-	if (!bdp->node_bootmem_map) {
-		pages = bdp->node_low_pfn - (bdp->node_boot_start>>PAGE_SHIFT);
+	/* Don't setup this node twice... */
+	if (!boot_pernode[node]) {
+		/*
+		 * Calculate total size needed, incl. what's necessary
+		 * for good alignment and alias prevention.
+		 */
+		cpus = count_cpus(node);
+		pernodesize += PERCPU_PAGE_SIZE * cpus;
+		pernodesize += L1_CACHE_ALIGN(sizeof(pg_data_t));
+		pernodesize += L1_CACHE_ALIGN(sizeof(struct ia64_node_data));
+		pernodesize = PAGE_ALIGN(pernodesize);
+		pernode = NODEDATA_ALIGN(pstart, node);
+	
+		/* Is this range big enough for what we want to store here? */
+		if (pstart + length > (pernode + pernodesize)) {
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
+			pg_data_ptr[node]->bdata = &bdata[node];
+			pernode += L1_CACHE_ALIGN(sizeof(pg_data_t));
+
+			/*
+			 * Copy the static per-cpu data into the region we
+			 * just set aside and then setup __per_cpu_offset
+			 * for each CPU on this node.
+			 */
+			for (cpu=0; cpu < NR_CPUS; cpu++) {
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
+	if (pernode && !bdata[node].node_bootmem_map) {
+		/*
+		 * Now setup the bootmem map for this node if we haven't
+		 * already. Note that at this point,
+		 * pg_data_ptrs[n]->bdata = &bdata[n], but
+		 * we use the latter for convenience.
+		 */
+		unsigned long pages, mapsize, map = 0;
+
+		pages = bdata[node].node_low_pfn -
+			(bdata[node].node_boot_start >> PAGE_SHIFT);
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
+		if (pernode - pstart > mapsize)
+			map = pstart;
+		else if (pstart + length - pernode - pernodesize > mapsize)
+			map = pernode + pernodesize;
+
+		if (map) {
+			init_bootmem_node(pg_data_ptr[node], map>>PAGE_SHIFT, 
+					  bdata[node].node_boot_start>>PAGE_SHIFT,
+					  bdata[node].node_low_pfn);
 		}
 
 	}
@@ -134,85 +207,86 @@
 	return 0;
 }
 
-
-/*
- * Free available memory to the bootmem allocator.
- *
- * Note that only blocks that are free are passed to this routine (currently 
- * filtered by free_available_memory).
+/**
+ * discontig_free_bootmem_node - free bootmem allocator memory for use
+ * @start: start of range
+ * @end: end of range
+ * @node: node where this range resides
  *
+ * Simply calls the bootmem allocator to free the specified ranged from
+ * the given pg_data_t's bdata struct.
  */
-static int __init
-discontig_free_bootmem_node(unsigned long pstart, unsigned long length, int node)
+static int __init discontig_free_bootmem_node(unsigned long start,
+					      unsigned long end, int node)
 {
-	free_bootmem_node(BOOT_NODE_DATA(node), pstart, length);
+	free_bootmem_node(pg_data_ptr[node], __pa(start), end - start);
 
 	return 0;
 }
 
 
-/*
- * Reserve the space used by the bootmem maps.
+/**
+ * discontig_reserve_bootmem - reserve memory for per-node space
+ *
+ * Reserve the space used by the bootmem maps & per-node space.
  */
-static void __init
-discontig_reserve_bootmem(void)
+static void __init discontig_reserve_bootmem(void)
 {
-	int		node;
-	unsigned long	mapbase, mapsize, pages;
-	bootmem_data_t	*bdp;
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
+/**
+ * initialize_pernode_data - fixup per-cpu & per-node pointers
+ *
+ * Each node's per-node area has a copy of the global pg_data_t list, so
+ * we copy that here to each node.
+ */
+static void __init initialize_pernode_data(void)
+{
+	int cpu, node;
+
+	memcpy(boot_node_data[0]->pg_data_ptrs, pg_data_ptr,
+	       sizeof(pg_data_ptr));
+
+	/* Copy the pg_data_t list to each node and init the node field */
+	for (node=1; node < numnodes; node++) {
+		memcpy(boot_node_data[node], boot_node_data[0],
+		       sizeof(struct ia64_node_data));
+		boot_node_data[node]->node = node;
 	}
-	
-	memcpy(node_data[mynode]->pg_data_ptrs, pg_data_ptr, sizeof(pg_data_ptr));
-	memcpy(node_data[mynode]->node_data_ptrs, node_data, sizeof(node_data));
 
-	pgdat_list = new_pgdat_list;
+	/* Set the node_data pointer for each per-cpu struct */
+	for (cpu=0; cpu < NR_CPUS; cpu++) {
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
@@ -220,94 +294,46 @@
 		numnodes = 1;
 	}
 
-	for (node = 0; node < numnodes; node++) {
-		pg_data_ptr[node] = (pg_data_t*) &boot_pg_data[node];
-		pg_data_ptr[node]->bdata = &bdata[node][0];
-	}
-
 	min_low_pfn = -1;
 	max_low_pfn = 0;
 
         efi_memmap_walk(filter_rsvd_memory, build_maps);
-        efi_memmap_walk(filter_rsvd_memory, find_bootmap_space);
+        efi_memmap_walk(filter_rsvd_memory, find_pernode_space);
         efi_memmap_walk(filter_rsvd_memory, discontig_free_bootmem_node);
+
 	discontig_reserve_bootmem();
-	allocate_pernode_structures();
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
-
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
+/**
+ * per_cpu_init - setup per-cpu variables
+ *
+ * find_pernode_space() does most of this already, we just need to set
+ * local_per_cpu_offset
+ */
+void *per_cpu_init(void)
+{
+	int cpu;
+#ifdef CONFIG_SMP
+	if (smp_processor_id() = 0) {
+		for (cpu = 0; cpu < NR_CPUS; cpu++) {
+			per_cpu(local_per_cpu_offset, cpu) = __per_cpu_offset[cpu];
 		}
 	}
-
-	/*
-	 * Finish setting up the node data for this node, then copy it to the other nodes.
-	 */
-	for (node=0; node < numnodes; node++)
-		if (mynode != node) {
-			memcpy(node_data[node], node_data[mynode], sizeof(struct ia64_node_data));
-			node_data[node]->node = node;
-		}
+	return __per_cpu_start + __per_cpu_offset[smp_processor_id()];
+#else /* !CONFIG_SMP */
+	return __phys_per_cpu_start;
+#endif /* !CONFIG_SMP */
 }
 
+/**
+ * show_mem - give short summary of memory stats
+ *
+ * Shows a simple page count of reserved and used pages in the system.
+ * For discontig machines, it does this on a per-pgdat basis.
+ */
 void show_mem(void)
 {
 	int i, reserved = 0;
@@ -316,6 +342,7 @@
 
 	printk("Mem-info:\n");
 	show_free_areas();
+
 	printk("Free swap:       %6dkB\n", nr_swap_pages<<(PAGE_SHIFT-10));
 	for_each_pgdat(pgdat) {
 		printk("Node ID: %d\n", pgdat->node_id);
@@ -324,8 +351,8 @@
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
@@ -336,7 +363,11 @@
 	printk("%d free buffer pages\n", nr_free_buffer_pages());
 }
 
-/*
+/**
+ * call_pernode_memory - use SRAT to call callback functions with node info
+ * @start: start of range
+ * @end: end of range
+ *
  * efi_memmap_walk() knows nothing about layout of memory across nodes. Find
  * out to which node a block of memory belongs.  Ignore memory that we cannot
  * identify, and split blocks that run across multiple nodes.
@@ -347,7 +378,7 @@
 void call_pernode_memory(unsigned long start, unsigned long end, void *arg)
 {
 	unsigned long rs, re;
-	void (*func)(unsigned long, unsigned long, int, int);
+	void (*func)(unsigned long, unsigned long, int);
 	int i;
 
 	start = PAGE_ALIGN(start);
@@ -358,21 +389,21 @@
 	func = arg;
 
 	if (!num_memblks) {
-		/*
-		 * This machine doesn't have SRAT, so call func with
-		 * nid=0, bank=0.
-		 */
+		/* No SRAT table, to assume one node (node 0) */
 		if (start < end)
-			(*func)(start, end - start, 0, 0);
+			(*func)(start, end, 0);
 		return;
 	}
 
 	for (i = 0; i < num_memblks; i++) {
-		rs = max(start, node_memblk[i].start_paddr);
-		re = min(end, node_memblk[i].start_paddr+node_memblk[i].size);
+		rs = max(__pa(start), node_memblk[i].start_paddr);
+		re = min(__pa(end), node_memblk[i].start_paddr+node_memblk[i].size);
 
 		if (rs < re)
-			(*func)(rs, re-rs, node_memblk[i].nid,
-				node_memblk[i].bank);
+			(*func)((unsigned long)__va(rs), (unsigned long)__va(re),
+				node_memblk[i].nid);
+
+		if ((unsigned long)__va(re) = end)
+			break;
 	}
 }
diff -Naur -X /home/jbarnes/dontdiff --exclude=MAINTAINERS --exclude=pci_irq.c --exclude=tables.c --exclude=qla1280.c --exclude=logo --exclude=char linux-ia64-2.5-contig/arch/ia64/mm/init.c linux-ia64-2.5-sn/arch/ia64/mm/init.c
--- linux-ia64-2.5-contig/arch/ia64/mm/init.c	Mon Sep 22 18:18:27 2003
+++ linux-ia64-2.5-sn/arch/ia64/mm/init.c	Tue Sep 23 17:52:22 2003
@@ -32,6 +32,7 @@
 #include <asm/tlb.h>
 #include <asm/uaccess.h>
 #include <asm/unistd.h>
+#include <asm/meminit.h>
 
 DEFINE_PER_CPU(struct mmu_gather, mmu_gathers);
 
@@ -342,6 +343,7 @@
 {
 	unsigned long address, start_page, end_page;
 	struct page *map_start, *map_end;
+	int node;
 	pgd_t *pgd;
 	pmd_t *pmd;
 	pte_t *pte;
@@ -351,19 +353,20 @@
 
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
@@ -434,16 +437,6 @@
 }
 
 static int
-count_dma_pages (u64 start, u64 end, void *arg)
-{
-	unsigned long *count = arg;
-
-	if (end <= MAX_DMA_ADDRESS)
-		*count += (end - start) >> PAGE_SHIFT;
-	return 0;
-}
-
-static int
 find_largest_hole (u64 start, u64 end, void *arg)
 {
 	u64 *max_gap = arg;
@@ -459,102 +452,106 @@
 }
 #endif /* CONFIG_VIRTUAL_MEM_MAP */
 
+struct memmap_count_callback_data {
+	int node;
+	unsigned long num_physpages;
+	unsigned long num_dma_physpages;
+	unsigned long min_pfn;
+	unsigned long max_pfn;
+};
+
+struct memmap_count_callback_data cdata;
+
 static int
-count_pages (u64 start, u64 end, void *arg)
+count_pages (unsigned long start, unsigned long end, int node)
 {
-	unsigned long *count = arg;
+	start = __pa(start);
+	end = __pa(end);
 
-	*count += (end - start) >> PAGE_SHIFT;
+	if (node = cdata.node) {
+		cdata.num_physpages += (end - start) >> PAGE_SHIFT;
+		if (start <= __pa(MAX_DMA_ADDRESS))
+			cdata.num_dma_physpages += (min(end, __pa(MAX_DMA_ADDRESS)) - start) >> PAGE_SHIFT;
+		start = GRANULEROUNDDOWN(__pa(start));
+		start = ORDERROUNDDOWN(start);
+		end = GRANULEROUNDUP(__pa(end));
+		cdata.max_pfn = max(cdata.max_pfn, end >> PAGE_SHIFT);
+		cdata.min_pfn = min(cdata.min_pfn, start >> PAGE_SHIFT);
+	}
 	return 0;
 }
 
 /*
  * Set up the page tables.
  */
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
 void
 paging_init (void)
 {
-	unsigned long max_dma;
+	unsigned long max_dma_pfn;
 	unsigned long zones_size[MAX_NR_ZONES];
 #  ifdef CONFIG_VIRTUAL_MEM_MAP
 	unsigned long zholes_size[MAX_NR_ZONES];
 	unsigned long max_gap;
 #  endif
+	int node;
 
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
+	max_dma_pfn = virt_to_phys((void *) MAX_DMA_ADDRESS) >> PAGE_SHIFT;
 	max_gap = 0;
 	efi_memmap_walk(find_largest_hole, (u64 *)&max_gap);
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
 
-		free_area_init_node(0, &contig_page_data, vmem_map, zones_size, 0, zholes_size);
+	for (node = 0; node < numnodes; node++) {
+		memset(zones_size, 0, sizeof(zones_size));
+		memset(zholes_size, 0, sizeof(zholes_size));
+		memset(&cdata, 0, sizeof(cdata));
+
+		cdata.node = node;
+		cdata.min_pfn = ~0;
+
+		efi_memmap_walk(filter_rsvd_memory, count_pages);
+		num_dma_physpages += cdata.num_dma_physpages;
+		num_physpages += cdata.num_physpages;
+
+		if (cdata.min_pfn >= max_dma_pfn) {
+			/* Above the DMA zone */
+			zones_size[ZONE_NORMAL] = cdata.max_pfn - cdata.min_pfn;
+			zholes_size[ZONE_NORMAL] = cdata.max_pfn - cdata.min_pfn - cdata.num_physpages;
+		} else if (cdata.max_pfn < max_dma_pfn) {
+			/* This block is DMAable */
+			zones_size[ZONE_DMA] = cdata.max_pfn - cdata.min_pfn;
+			zholes_size[ZONE_DMA] = cdata.max_pfn - cdata.min_pfn - cdata.num_dma_physpages;
+		} else {
+			zones_size[ZONE_DMA] = max_dma_pfn - cdata.min_pfn;
+			zholes_size[ZONE_DMA] = zones_size[ZONE_DMA] - cdata.num_dma_physpages;
+			zones_size[ZONE_NORMAL] = cdata.max_pfn - max_dma_pfn;
+			zholes_size[ZONE_NORMAL] = zones_size[ZONE_NORMAL] - (cdata.num_physpages - cdata.num_dma_physpages);
+		}
 
-		mem_map = contig_page_data.node_mem_map;
-		printk("Virtual mem_map starts at 0x%p\n", mem_map);
-	}
-#  else /* !CONFIG_VIRTUAL_MEM_MAP */
-	if (max_low_pfn < max_dma)
-		zones_size[ZONE_DMA] = max_low_pfn;
-	else {
-		zones_size[ZONE_DMA] = max_dma;
-		zones_size[ZONE_NORMAL] = max_low_pfn - max_dma;
+		if (numnodes = 1 && max_gap < LARGE_GAP) {
+			/* Just one node with no big holes... */
+			vmem_map = (struct page *)0;
+			zones_size[ZONE_DMA] += cdata.min_pfn;
+			zholes_size[ZONE_DMA] += cdata.min_pfn;
+			free_area_init_node(0, NODE_DATA(node), NODE_DATA(node)->node_mem_map,
+					    zones_size, 0, zholes_size);
+		}
+		else {
+			/* allocate virtual mem_map */
+			if (node = 0) {
+				unsigned long map_size;
+				map_size = PAGE_ALIGN(max_low_pfn*sizeof(struct page));
+				vmalloc_end -= map_size;
+				vmem_map = (struct page *) vmalloc_end;
+				efi_memmap_walk(create_mem_map_page_table, 0);
+				printk("Virtual mem_map starts at 0x%p\n", vmem_map);
+				mem_map = vmem_map;
+			}
+			free_area_init_node(node, NODE_DATA(node), vmem_map + cdata.min_pfn,
+					    zones_size, cdata.min_pfn, zholes_size);
+		}
 	}
-	free_area_init(zones_size);
-#  endif /* !CONFIG_VIRTUAL_MEM_MAP */
+
 	zero_page_memmap_ptr = virt_to_page(ia64_imva(empty_zero_page));
 }
-#endif /* !CONFIG_DISCONTIGMEM */
 
 static int
 count_reserved_pages (u64 start, u64 end, void *arg)
@@ -606,11 +603,11 @@
 	platform_dma_init();
 #endif
 
-#ifndef CONFIG_DISCONTIGMEM
+#if defined(CONFIG_VIRTUAL_MEM_MAP) || !defined(CONFIG_DISCONTIGMEM)
 	if (!mem_map)
 		BUG();
 	max_mapnr = max_low_pfn;
-#endif
+#endif /* CONFIG_VIRTUAL_MEM_MAP || !CONFIG_DISCONTIGMEM */
 
 	high_memory = __va(max_low_pfn * PAGE_SIZE);
 
diff -Naur -X /home/jbarnes/dontdiff --exclude=MAINTAINERS --exclude=pci_irq.c --exclude=tables.c --exclude=qla1280.c --exclude=logo --exclude=char linux-ia64-2.5-contig/include/asm-ia64/meminit.h linux-ia64-2.5-sn/include/asm-ia64/meminit.h
--- linux-ia64-2.5-contig/include/asm-ia64/meminit.h	Tue Sep 23 10:41:10 2003
+++ linux-ia64-2.5-sn/include/asm-ia64/meminit.h	Tue Sep 23 13:39:19 2003
@@ -31,6 +31,14 @@
 extern void find_initrd(void);
 extern int filter_rsvd_memory(unsigned long start, unsigned long end,
 			      void *arg);
+extern void paging_init(void);
+
+/*
+ * For rounding an address to the next IA64_GRANULE_SIZE or order
+ */
+#define GRANULEROUNDDOWN(n) ((n) & ~(IA64_GRANULE_SIZE-1))
+#define GRANULEROUNDUP(n) (((n)+IA64_GRANULE_SIZE-1) & ~(IA64_GRANULE_SIZE-1))
+#define ORDERROUNDDOWN(n) ((n) & ~((PAGE_SIZE<<MAX_ORDER)-1))
 
 #ifdef CONFIG_DISCONTIGMEM
 extern void call_pernode_memory(unsigned long start, unsigned long end, void *arg);
diff -Naur -X /home/jbarnes/dontdiff --exclude=MAINTAINERS --exclude=pci_irq.c --exclude=tables.c --exclude=qla1280.c --exclude=logo --exclude=char linux-ia64-2.5-contig/include/asm-ia64/mmzone.h linux-ia64-2.5-sn/include/asm-ia64/mmzone.h
--- linux-ia64-2.5-contig/include/asm-ia64/mmzone.h	Mon Sep 22 15:27:20 2003
+++ linux-ia64-2.5-sn/include/asm-ia64/mmzone.h	Tue Sep 23 17:33:19 2003
@@ -3,7 +3,7 @@
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
  *
- * Copyright (c) 2000 Silicon Graphics, Inc.  All rights reserved.
+ * Copyright (c) 2000,2003 Silicon Graphics, Inc.  All rights reserved.
  * Copyright (c) 2002 NEC Corp.
  * Copyright (c) 2002 Erich Focht <efocht@ess.nec.de>
  * Copyright (c) 2002 Kimio Suganuma <k-suganuma@da.jp.nec.com>
@@ -12,152 +12,49 @@
 #define _ASM_IA64_MMZONE_H
 
 #include <linux/config.h>
-#include <linux/init.h>
 
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
+#ifdef CONFIG_NUMA
 
+#ifdef CONFIG_IA64_DIG
 /*
- * Given a pte, this macro returns a pointer to the page struct for the pte.
+ * Platform definitions for DIG NUMA platforms
  */
-#define pte_page(pte)	virt_to_page(PAGE_OFFSET | (pte_val(pte)&_PFN_MASK))
+#define MAX_PHYSNODE_ID	8
+#define NR_NODES	8
+#define NR_MEMBLKS	(NR_NODES * 32) /* interleaved, contiguous memory */
 
+#elif CONFIG_IA64_SGI_SN2
 /*
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
+ * SN2 definitions
  */
-#define kern_addr_valid(kaddr)		({long _kav=(long)(kaddr);	\
-					VALID_MEM_KADDR(_kav);})
+#define MAX_PHYSNODE_ID	2048
+#define NR_NODES	256
+#define NR_MEMBLKS	(NR_NODES)
 
+#elif CONFIG_IA64_GENERIC
 /*
- * Given a kaddr, return a pointer to the page struct for the page.
- * If the kaddr does not represent RAM memory that potentially exists, return
- * a pointer the page struct for max_mapnr. IO addresses will
- * return the page for max_nr. Addresses in unpopulated RAM banks may
- * return undefined results OR may panic the system.
- *
+ * These defs should work on any ia64 platform
  */
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
-
+#define MAX_PHYSNODE_ID 2048
+#define NR_NODES        256
+#define NR_MEMBLKS      (NR_NODES)
 
-/*
- * pfn_valid should be made as fast as possible, and the current definition
- * is valid for machines that are NUMA, but still contiguous, which is what
- * is currently supported. A more generalised, but slower definition would
- * be something like this - mbligh:
- * ( pfn_to_pgdat(pfn) && (pfn < node_end_pfn(pfn_to_nid(pfn))) )
- */
-#define pfn_valid(pfn)          (pfn < max_low_pfn)
-extern unsigned long max_low_pfn;
-
-
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
 #else
-# error Unsupported bank and nodesize!
-#endif
-#define BANKSIZE		(1UL << BANKSHIFT)
-#define BANK_OFFSET(addr)	((unsigned long)(addr) & (BANKSIZE-1))
-#define NR_BANKS		(NR_BANKS_PER_NODE * NR_NODES)
-
 /*
- * VALID_MEM_KADDR returns a boolean to indicate if a kaddr is
- * potentially a valid cacheable identity mapped RAM memory address.
- * Note that the RAM may or may not actually be present!!
+ * Better fill it in
  */
-#define VALID_MEM_KADDR(kaddr)	1
+#error unknown platform
+#endif
 
-/*
- * Given a nodeid & a bank number, find the address of the mem_map
- * entry for the first page of the bank.
- */
-#define BANK_MEM_MAP_INDEX(kaddr) \
-	(((unsigned long)(kaddr) & (MAX_PHYS_MEMORY-1)) >> BANKSHIFT)
+extern void build_cpu_to_node_map(void);
 
-#elif defined(CONFIG_IA64_SGI_SN2)
+#else /* !CONFIG_NUMA */
 /*
- * SGI SN2 discontig definitions
+ * Some defaults for a non-NUMA system
  */
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
+#define NR_NODES	1
+#define NR_MEMBLKS      (NR_NODES)
 
-/*
- * Given a nodeid & a bank number, find the address of the mem_map
- * entry for the first page of the bank.
- */
-#define BANK_MEM_MAP_INDEX(kaddr) \
-	(((unsigned long)(kaddr) & (MAX_PHYS_MEMORY-1)) >> BANKSHIFT)
+#endif /* CONFIG_NUMA */
 
-#endif /* CONFIG_IA64_DIG */
 #endif /* _ASM_IA64_MMZONE_H */
diff -Naur -X /home/jbarnes/dontdiff --exclude=MAINTAINERS --exclude=pci_irq.c --exclude=tables.c --exclude=qla1280.c --exclude=logo --exclude=char linux-ia64-2.5-contig/include/asm-ia64/nodedata.h linux-ia64-2.5-sn/include/asm-ia64/nodedata.h
--- linux-ia64-2.5-contig/include/asm-ia64/nodedata.h	Mon Sep 22 15:27:20 2003
+++ linux-ia64-2.5-sn/include/asm-ia64/nodedata.h	Tue Sep 23 14:05:36 2003
@@ -13,7 +13,7 @@
 #ifndef _ASM_IA64_NODEDATA_H
 #define _ASM_IA64_NODEDATA_H
 
-
+#include <asm/percpu.h>
 #include <asm/mmzone.h>
 
 /*
@@ -24,10 +24,7 @@
 struct ia64_node_data {
 	short			active_cpu_count;
 	short			node;
-        struct pglist_data	*pg_data_ptrs[NR_NODES];
-	struct page		*bank_mem_map_base[NR_BANKS];
-	struct ia64_node_data	*node_data_ptrs[NR_NODES];
-	short			node_id_map[NR_BANKS];
+	struct pglist_data	*pg_data_ptrs[NR_NODES];
 };
 
 
@@ -36,41 +33,21 @@
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
-
-struct pglist_data;
-extern struct pglist_data * __init boot_get_pg_data_ptr(long);
 
 #endif /* _ASM_IA64_NODEDATA_H */
diff -Naur -X /home/jbarnes/dontdiff --exclude=MAINTAINERS --exclude=pci_irq.c --exclude=tables.c --exclude=qla1280.c --exclude=logo --exclude=char linux-ia64-2.5-contig/include/asm-ia64/numa.h linux-ia64-2.5-sn/include/asm-ia64/numa.h
--- linux-ia64-2.5-contig/include/asm-ia64/numa.h	Mon Sep 22 18:18:29 2003
+++ linux-ia64-2.5-sn/include/asm-ia64/numa.h	Tue Sep 23 18:16:09 2003
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
 
diff -Naur -X /home/jbarnes/dontdiff --exclude=MAINTAINERS --exclude=pci_irq.c --exclude=tables.c --exclude=qla1280.c --exclude=logo --exclude=char linux-ia64-2.5-contig/include/asm-ia64/page.h linux-ia64-2.5-sn/include/asm-ia64/page.h
--- linux-ia64-2.5-contig/include/asm-ia64/page.h	Mon Sep 22 15:27:20 2003
+++ linux-ia64-2.5-sn/include/asm-ia64/page.h	Tue Sep 23 12:31:50 2003
@@ -94,18 +94,16 @@
 
 #define virt_addr_valid(kaddr)	pfn_valid(__pa(kaddr) >> PAGE_SHIFT)
 
-#ifndef CONFIG_DISCONTIGMEM
-# ifdef CONFIG_VIRTUAL_MEM_MAP
+#ifdef CONFIG_VIRTUAL_MEM_MAP
    extern int ia64_pfn_valid (unsigned long pfn);
 #  define pfn_valid(pfn)	(((pfn) < max_mapnr) && ia64_pfn_valid(pfn))
-# else
+#else
 #  define pfn_valid(pfn)	((pfn) < max_mapnr)
-# endif
+#endif
 #define virt_to_page(kaddr)	pfn_to_page(__pa(kaddr) >> PAGE_SHIFT)
 #define page_to_pfn(page)	((unsigned long) (page - mem_map))
 #define pfn_to_page(pfn)	(mem_map + (pfn))
 #define page_to_phys(page)	(page_to_pfn(page) << PAGE_SHIFT)
-#endif
 
 typedef union ia64_va {
 	struct {
diff -Naur -X /home/jbarnes/dontdiff --exclude=MAINTAINERS --exclude=pci_irq.c --exclude=tables.c --exclude=qla1280.c --exclude=logo --exclude=char linux-ia64-2.5-contig/include/asm-ia64/percpu.h linux-ia64-2.5-sn/include/asm-ia64/percpu.h
--- linux-ia64-2.5-contig/include/asm-ia64/percpu.h	Mon Sep 22 15:27:20 2003
+++ linux-ia64-2.5-sn/include/asm-ia64/percpu.h	Mon Sep 22 15:22:12 2003
@@ -46,6 +46,7 @@
 
 extern void percpu_modcopy(void *pcpudst, const void *src, unsigned long size);
 extern void setup_per_cpu_areas (void);
+extern void *per_cpu_init(void);
 
 #else /* ! SMP */
 
diff -Naur -X /home/jbarnes/dontdiff --exclude=MAINTAINERS --exclude=pci_irq.c --exclude=tables.c --exclude=qla1280.c --exclude=logo --exclude=char linux-ia64-2.5-contig/include/asm-ia64/pgtable.h linux-ia64-2.5-sn/include/asm-ia64/pgtable.h
--- linux-ia64-2.5-contig/include/asm-ia64/pgtable.h	Mon Sep 22 15:27:20 2003
+++ linux-ia64-2.5-sn/include/asm-ia64/pgtable.h	Tue Sep 23 17:01:21 2003
@@ -174,7 +174,7 @@
 	return (addr & (local_cpu_data->unimpl_pa_mask)) = 0;
 }
 
-#ifndef CONFIG_DISCONTIGMEM
+#if defined(CONFIG_VIRTUAL_MEM_MAP) || !defined(CONFIG_DISCONTIGMEM)
 /*
  * kern_addr_valid(ADDR) tests if ADDR is pointing to valid kernel
  * memory.  For the return value to be meaningful, ADDR must be >@@ -190,7 +190,7 @@
  */
 #define kern_addr_valid(addr)	(1)
 
-#endif
+#endif /* CONFIG_VIRTUAL_MEM_MAP || !CONFIG_DISCONTIGMEM */
 
 /*
  * Now come the defines and routines to manage and access the three-level
@@ -241,10 +241,10 @@
 #define pte_none(pte) 			(!pte_val(pte))
 #define pte_present(pte)		(pte_val(pte) & (_PAGE_P | _PAGE_PROTNONE))
 #define pte_clear(pte)			(pte_val(*(pte)) = 0UL)
-#ifndef CONFIG_DISCONTIGMEM
+#if defined(CONFIG_VIRTUAL_MEM_MAP) || !defined(CONFIG_DISCONTIGMEM)
 /* pte_page() returns the "struct page *" corresponding to the PTE: */
 #define pte_page(pte)			virt_to_page(((pte_val(pte) & _PFN_MASK) + PAGE_OFFSET))
-#endif
+#endif /* CONFIG_VIRTUAL_MEM_MAP || !CONFIG_DISCONTIGMEM */
 
 #define pmd_none(pmd)			(!pmd_val(pmd))
 #define pmd_bad(pmd)			(!ia64_phys_addr_valid(pmd_val(pmd)))
diff -Naur -X /home/jbarnes/dontdiff --exclude=MAINTAINERS --exclude=pci_irq.c --exclude=tables.c --exclude=qla1280.c --exclude=logo --exclude=char linux-ia64-2.5-contig/include/linux/mm.h linux-ia64-2.5-sn/include/linux/mm.h
--- linux-ia64-2.5-contig/include/linux/mm.h	Tue Sep 23 09:36:10 2003
+++ linux-ia64-2.5-sn/include/linux/mm.h	Tue Sep 23 09:43:53 2003
@@ -13,7 +13,8 @@
 #include <linux/rbtree.h>
 #include <linux/fs.h>
 
-#ifndef CONFIG_DISCONTIGMEM          /* Don't use mapnrs, do it properly */
+#if defined(CONFIG_VIRTUAL_MEM_MAP) || !defined(CONFIG_DISCONTIGMEM)
+/* Don't use mapnrs, do it properly */
 extern unsigned long max_mapnr;
 #endif
 
@@ -340,7 +341,7 @@
 	page->flags |= zone_num << ZONE_SHIFT;
 }
 
-#ifndef CONFIG_DISCONTIGMEM
+#if defined(CONFIG_VIRTUAL_MEM_MAP) || !defined(CONFIG_DISCONTIGMEM)
 /* The array of struct pages - for discontigmem use pgdat->lmem_map */
 extern struct page *mem_map;
 #endif
diff -Naur -X /home/jbarnes/dontdiff --exclude=MAINTAINERS --exclude=pci_irq.c --exclude=tables.c --exclude=qla1280.c --exclude=logo --exclude=char linux-ia64-2.5-contig/kernel/ksyms.c linux-ia64-2.5-sn/kernel/ksyms.c
--- linux-ia64-2.5-contig/kernel/ksyms.c	Tue Sep 23 09:36:48 2003
+++ linux-ia64-2.5-sn/kernel/ksyms.c	Tue Sep 23 09:43:59 2003
@@ -114,7 +114,7 @@
 EXPORT_SYMBOL(vunmap);
 EXPORT_SYMBOL(vmalloc_to_page);
 EXPORT_SYMBOL(remap_page_range);
-#ifndef CONFIG_DISCONTIGMEM
+#if defined(CONFIG_VIRTUAL_MEM_MAP) || !defined(CONFIG_DISCONTIGMEM)
 EXPORT_SYMBOL(contig_page_data);
 EXPORT_SYMBOL(mem_map);
 EXPORT_SYMBOL(max_mapnr);
diff -Naur -X /home/jbarnes/dontdiff --exclude=MAINTAINERS --exclude=pci_irq.c --exclude=tables.c --exclude=qla1280.c --exclude=logo --exclude=char linux-ia64-2.5-contig/mm/memory.c linux-ia64-2.5-sn/mm/memory.c
--- linux-ia64-2.5-contig/mm/memory.c	Tue Sep 23 09:36:29 2003
+++ linux-ia64-2.5-sn/mm/memory.c	Tue Sep 23 09:44:04 2003
@@ -55,7 +55,7 @@
 
 #include <linux/swapops.h>
 
-#ifndef CONFIG_DISCONTIGMEM
+#if defined(CONFIG_VIRTUAL_MEM_MAP) || !defined(CONFIG_DISCONTIGMEM)
 /* use the per-pgdat data instead for discontigmem - mbligh */
 unsigned long max_mapnr;
 struct page *mem_map;
