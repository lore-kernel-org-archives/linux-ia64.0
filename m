From: jbarnes@sgi.com (Jesse Barnes)
Date: Mon, 15 Sep 2003 19:37:49 +0000
Subject: [PATCH] updated Altix patch
Message-Id: <marc-linux-ia64-106365486413361@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Here's a patch against Linus' tree + David's -test5 patch that should
get you going on Altix.  We're still debugging some console issues, so
expect random hangs and/or panics on keypress during bootup.  Once the
system is up though, it seems pretty stable (that is, I've done some
overnight benchmarking runs w/o incident).

However, I can't guarantee that this patch will work for you, all I can
say is that it Works For Me :).

 MAINTAINERS                  |    6 
 arch/ia64/Kconfig            |   16 
 arch/ia64/Makefile           |    2 
 arch/ia64/kernel/acpi.c      |    8 
 arch/ia64/kernel/setup.c     |  167 --------
 arch/ia64/mm/Makefile        |    3 
 arch/ia64/mm/discontig.c     |  375 ++++++++++--------
 arch/ia64/mm/init.c          |  225 ++++-------
 drivers/acpi/pci_irq.c       |    3 
 drivers/acpi/tables.c        |   15 
 drivers/char/Kconfig         |   16 
 drivers/char/Makefile        |    1 
 drivers/char/sn_serial.c     |  870 +++++++++++++++++++++++++++++++++++++++++++
 drivers/scsi/qla1280.c       |    4 
 include/asm-ia64/mmzone.h    |  144 +------
 include/asm-ia64/nodedata.h  |   39 -
 include/asm-ia64/numa.h      |   16 
 include/asm-ia64/page.h      |   28 -
 include/asm-ia64/percpu.h    |    1 
 include/asm-ia64/pgtable.h   |   32 +
 include/asm-ia64/processor.h |    2 

Thanks,
Jesse


diff -Naur -X /home/jbarnes/dontdiff linux-2.6.0-test5-ia64/MAINTAINERS linux-2.6.0-test5-ia64-sn/MAINTAINERS
--- linux-2.6.0-test5-ia64/MAINTAINERS	Mon Sep  8 12:50:07 2003
+++ linux-2.6.0-test5-ia64-sn/MAINTAINERS	Mon Sep 15 12:19:06 2003
@@ -1679,6 +1679,12 @@
 W:	http://www.nsa.gov/selinux
 S:	Supported
 
+SGI SN-IA64 (Altix) SERIAL CONSOLE DRIVER
+P:	Chad Talbott
+M:	chadt@sgi.com
+L:	linux-ia64@vger.kernel.org
+S:	Supported
+
 SGI VISUAL WORKSTATION 320 AND 540
 P:	Andrey Panin
 M:	pazke@donpac.ru
diff -Naur -X /home/jbarnes/dontdiff linux-2.6.0-test5-ia64/arch/ia64/Kconfig linux-2.6.0-test5-ia64-sn/arch/ia64/Kconfig
--- linux-2.6.0-test5-ia64/arch/ia64/Kconfig	Mon Sep 15 12:18:08 2003
+++ linux-2.6.0-test5-ia64-sn/arch/ia64/Kconfig	Mon Sep 15 12:19:06 2003
@@ -220,22 +220,6 @@
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
 	bool "Discontiguous memory support" if (IA64_DIG || IA64_SGI_SN2 || IA64_GENERIC) && NUMA
 	default y if (IA64_SGI_SN2 || IA64_GENERIC) && NUMA
diff -Naur -X /home/jbarnes/dontdiff linux-2.6.0-test5-ia64/arch/ia64/Makefile linux-2.6.0-test5-ia64-sn/arch/ia64/Makefile
--- linux-2.6.0-test5-ia64/arch/ia64/Makefile	Mon Sep 15 12:18:08 2003
+++ linux-2.6.0-test5-ia64-sn/arch/ia64/Makefile	Mon Sep 15 12:19:06 2003
@@ -64,7 +64,7 @@
 drivers-$(CONFIG_PCI)		+= arch/ia64/pci/
 drivers-$(CONFIG_IA64_HP_SIM)	+= arch/ia64/hp/sim/
 drivers-$(CONFIG_IA64_HP_ZX1)	+= arch/ia64/hp/common/ arch/ia64/hp/zx1/
-drivers-$(CONFIG_IA64_GENERIC)	+= arch/ia64/hp/common/ arch/ia64/hp/zx1/ arch/ia64/hp/sim/
+drivers-$(CONFIG_IA64_GENERIC)	+= arch/ia64/hp/common/ arch/ia64/hp/zx1/ arch/ia64/hp/sim/ arch/ia64/sn/
 drivers-$(CONFIG_OPROFILE)	+= arch/ia64/oprofile/
 
 boot := arch/ia64/hp/sim/boot
diff -Naur -X /home/jbarnes/dontdiff linux-2.6.0-test5-ia64/arch/ia64/kernel/acpi.c linux-2.6.0-test5-ia64-sn/arch/ia64/kernel/acpi.c
--- linux-2.6.0-test5-ia64/arch/ia64/kernel/acpi.c	Mon Sep 15 12:18:08 2003
+++ linux-2.6.0-test5-ia64-sn/arch/ia64/kernel/acpi.c	Mon Sep 15 12:19:06 2003
@@ -421,14 +421,6 @@
 			min_hole_size = hole_size;
 	}
 
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
 
diff -Naur -X /home/jbarnes/dontdiff linux-2.6.0-test5-ia64/arch/ia64/kernel/setup.c linux-2.6.0-test5-ia64-sn/arch/ia64/kernel/setup.c
--- linux-2.6.0-test5-ia64/arch/ia64/kernel/setup.c	Mon Sep  8 12:49:53 2003
+++ linux-2.6.0-test5-ia64-sn/arch/ia64/kernel/setup.c	Mon Sep 15 12:19:06 2003
@@ -83,91 +83,10 @@
 
 char saved_command_line[COMMAND_LINE_SIZE]; /* used in proc filesystem */
 
-/*
- * Entries defined so far:
- * 	- boot param structure itself
- * 	- memory map
- * 	- initrd (optional)
- * 	- command line string
- * 	- kernel code & data
- *
- * More could be added if necessary
- */
-#define IA64_MAX_RSVD_REGIONS 5
-
-struct rsvd_region {
-	unsigned long start;	/* virtual address of beginning of element */
-	unsigned long end;	/* virtual address of end of element + 1 */
-};
-
-/*
- * We use a special marker for the end of memory and it uses the extra (+1) slot
- */
-static struct rsvd_region rsvd_region[IA64_MAX_RSVD_REGIONS + 1];
-static int num_rsvd_regions;
-
 #define IGNORE_PFN0	1	/* XXX fix me: ignore pfn 0 until TLB miss handler is updated... */
 
-#ifndef CONFIG_DISCONTIGMEM
-
-static unsigned long bootmap_start; /* physical address where the bootmem map is located */
-
-static int
-find_max_pfn (unsigned long start, unsigned long end, void *arg)
-{
-	unsigned long *max_pfnp = arg, pfn;
-
-	pfn = (PAGE_ALIGN(end - 1) - PAGE_OFFSET) >> PAGE_SHIFT;
-	if (pfn > *max_pfnp)
-		*max_pfnp = pfn;
-	return 0;
-}
-
-#else /* CONFIG_DISCONTIGMEM */
-
-/*
- * efi_memmap_walk() knows nothing about layout of memory across nodes. Find
- * out to which node a block of memory belongs.  Ignore memory that we cannot
- * identify, and split blocks that run across multiple nodes.
- *
- * Take this opportunity to round the start address up and the end address
- * down to page boundaries.
- */
-void
-call_pernode_memory (unsigned long start, unsigned long end, void *arg)
-{
-	unsigned long rs, re;
-	void (*func)(unsigned long, unsigned long, int, int);
-	int i;
-
-	start = PAGE_ALIGN(start);
-	end &= PAGE_MASK;
-	if (start >= end)
-		return;
-
-	func = arg;
-
-	if (!num_memblks) {
-		/*
-		 * This machine doesn't have SRAT, so call func with
-		 * nid=0, bank=0.
-		 */
-		if (start < end)
-			(*func)(start, end - start, 0, 0);
-		return;
-	}
-
-	for (i = 0; i < num_memblks; i++) {
-		rs = max(start, node_memblk[i].start_paddr);
-		re = min(end, node_memblk[i].start_paddr+node_memblk[i].size);
-
-		if (rs < re)
-			(*func)(rs, re-rs, node_memblk[i].nid,
-				node_memblk[i].bank);
-	}
-}
-
-#endif /* CONFIG_DISCONTIGMEM */
+struct rsvd_region rsvd_region[IA64_MAX_RSVD_REGIONS + 1];
+int num_rsvd_regions;
 
 /*
  * Filter incoming memory segments based on the primitive map created from the boot
@@ -179,7 +98,7 @@
 filter_rsvd_memory (unsigned long start, unsigned long end, void *arg)
 {
 	unsigned long range_start, range_end, prev_start;
-	void (*func)(unsigned long, unsigned long);
+	void (*func)(unsigned long, unsigned long, int);
 	int i;
 
 #if IGNORE_PFN0
@@ -201,9 +120,9 @@
 
 		if (range_start < range_end)
 #ifdef CONFIG_DISCONTIGMEM
-			call_pernode_memory(__pa(range_start), __pa(range_end), func);
+			call_pernode_memory(range_start, range_end, arg);
 #else
-			(*func)(__pa(range_start), range_end - range_start);
+			(*func)(range_start, range_end, 0);
 #endif
 
 		/* nothing more available in this segment */
@@ -215,48 +134,6 @@
 	return 0;
 }
 
-
-#ifndef CONFIG_DISCONTIGMEM
-/*
- * Find a place to put the bootmap and return its starting address in bootmap_start.
- * This address must be page-aligned.
- */
-static int
-find_bootmap_location (unsigned long start, unsigned long end, void *arg)
-{
-	unsigned long needed = *(unsigned long *)arg;
-	unsigned long range_start, range_end, free_start;
-	int i;
-
-#if IGNORE_PFN0
-	if (start = PAGE_OFFSET) {
-		start += PAGE_SIZE;
-		if (start >= end) return 0;
-	}
-#endif
-
-	free_start = PAGE_OFFSET;
-
-	for (i = 0; i < num_rsvd_regions; i++) {
-		range_start = max(start, free_start);
-		range_end   = min(end, rsvd_region[i].start & PAGE_MASK);
-
-		if (range_end <= range_start) continue;	/* skip over empty range */
-
-	       	if (range_end - range_start >= needed) {
-			bootmap_start = __pa(range_start);
-			return 1;	/* done */
-		}
-
-		/* nothing more available in this segment */
-		if (range_end = end) return 0;
-
-		free_start = PAGE_ALIGN(rsvd_region[i].end);
-	}
-	return 0;
-}
-#endif /* !CONFIG_DISCONTIGMEM */
-
 static void
 sort_regions (struct rsvd_region *rsvd_region, int max)
 {
@@ -319,12 +196,8 @@
 	sort_regions(rsvd_region, num_rsvd_regions);
 
 #ifdef CONFIG_DISCONTIGMEM
-	{
-		extern void discontig_mem_init (void);
-
-		bootmap_size = max_pfn = 0;	/* stop gcc warnings */
-		discontig_mem_init();
-	}
+	bootmap_size = 0;
+	discontig_mem_init();
 #else /* !CONFIG_DISCONTIGMEM */
 
 	/* first find highest page frame number */
@@ -372,7 +245,6 @@
 	strlcpy(saved_command_line, *cmdline_p, sizeof(saved_command_line));
 
 	efi_init();
-	find_memory();
 
 #ifdef CONFIG_ACPI_BOOT
 	/* Initialize the ACPI boot-time table parser */
@@ -386,6 +258,8 @@
 # endif
 #endif /* CONFIG_APCI_BOOT */
 
+	find_memory();
+
 	/* process SAL system table: */
 	ia64_sal_init(efi.sal_systab);
 
@@ -677,28 +551,7 @@
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
 
diff -Naur -X /home/jbarnes/dontdiff linux-2.6.0-test5-ia64/arch/ia64/mm/Makefile linux-2.6.0-test5-ia64-sn/arch/ia64/mm/Makefile
--- linux-2.6.0-test5-ia64/arch/ia64/mm/Makefile	Mon Sep  8 12:49:59 2003
+++ linux-2.6.0-test5-ia64-sn/arch/ia64/mm/Makefile	Mon Sep 15 12:19:06 2003
@@ -7,3 +7,6 @@
 obj-$(CONFIG_HUGETLB_PAGE) += hugetlbpage.o
 obj-$(CONFIG_NUMA)	   += numa.o
 obj-$(CONFIG_DISCONTIGMEM) += discontig.o
+ifndef CONFIG_DISCONTIGMEM
+obj-y += contig.o
+endif
diff -Naur -X /home/jbarnes/dontdiff linux-2.6.0-test5-ia64/arch/ia64/mm/discontig.c linux-2.6.0-test5-ia64-sn/arch/ia64/mm/discontig.c
--- linux-2.6.0-test5-ia64/arch/ia64/mm/discontig.c	Mon Sep  8 12:50:22 2003
+++ linux-2.6.0-test5-ia64-sn/arch/ia64/mm/discontig.c	Mon Sep 15 12:19:06 2003
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2000 Silicon Graphics, Inc.  All rights reserved.
+ * Copyright (c) 2000, 2003 Silicon Graphics, Inc.  All rights reserved.
  * Copyright (c) 2001 Intel Corp.
  * Copyright (c) 2001 Tony Luck <tony.luck@intel.com>
  * Copyright (c) 2002 NEC Corp.
@@ -16,74 +16,60 @@
 #include <linux/mmzone.h>
 #include <linux/acpi.h>
 #include <linux/efi.h>
-
+#include <asm/pgalloc.h>
+#include <asm/tlb.h>
 
 /*
- * Round an address upward to the next multiple of GRANULE size.
+ * Round an address upward or downward to the next multiple of IA64_GRANULE_SIZE.
  */
+#define GRANULEROUNDDOWN(n) ((n) & ~(IA64_GRANULE_SIZE-1))
 #define GRANULEROUNDUP(n) (((n)+IA64_GRANULE_SIZE-1) & ~(IA64_GRANULE_SIZE-1))
 
-static struct ia64_node_data	*node_data[NR_NODES];
-static long			boot_pg_data[8*NR_NODES+sizeof(pg_data_t)]  __initdata;
-static pg_data_t		*pg_data_ptr[NR_NODES] __initdata;
-static bootmem_data_t		bdata[NR_NODES][NR_BANKS_PER_NODE+1] __initdata;
-
-extern int  filter_rsvd_memory (unsigned long start, unsigned long end, void *arg);
+/*
+ * Used to locate BOOT_DATA prior to initializing the node data area.
+ */
+#define BOOT_NODE_DATA(node)	pg_data_ptr[node]
 
 /*
- * Return the compact node number of this cpu. Used prior to
- * setting up the cpu_data area.
- *	Note - not fast, intended for boot use only!!
+ * To prevent cache aliasing effects, align per-node structures so that they 
+ * start at addresses that are strided by node number.
  */
-int
-boot_get_local_nodeid(void)
-{
-	int	i;
+#define NODEDATA_ALIGN(addr, node)	((((addr) + 1024*1024-1) & ~(1024*1024-1)) + (node)*PERCPU_PAGE_SIZE)
 
-	for (i = 0; i < NR_CPUS; i++)
-		if (node_cpuid[i].phys_id = hard_smp_processor_id())
-			return node_cpuid[i].nid;
 
-	/* node info missing, so nid should be 0.. */
-	return 0;
-}
+static struct ia64_node_data	*boot_node_data[NR_NODES] __initdata;
+static pg_data_t		*pg_data_ptr[NR_NODES] __initdata;
+static bootmem_data_t		bdata[NR_NODES] __initdata;
+static unsigned long		boot_pernode[NR_NODES] __initdata;
+static unsigned long		boot_pernodesize[NR_NODES] __initdata;
 
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
+extern char __per_cpu_start[], __per_cpu_end[];
 
 
-/*
- * Return a pointer to the node data for the current node.
- *	(boottime initialization only)
- */
-struct ia64_node_data *
+struct ia64_node_data*
 get_node_data_ptr(void)
 {
-	return node_data[boot_get_local_nodeid()];
+	return boot_node_data[(int)cpu_to_node_map[smp_processor_id()]];	/* ZZZ */
 }
 
 /*
  * We allocate one of the bootmem_data_t structs for each piece of memory
  * that we wish to treat as a contiguous block.  Each such block must start
- * on a BANKSIZE boundary.  Multiple banks per node is not supported.
+ * on a GRANULE boundary.  Multiple banks per node are not supported.
+ *   (Note: on SN2, all memory on a node is trated as a single bank.
+ *   Holes within the bank are supported. This works because memory
+ *   from different banks is not interleaved. The bootmap bitmap
+ *   for the node is somewhat large but not too large).
  */
 static int __init
-build_maps(unsigned long pstart, unsigned long length, int node)
+build_maps(unsigned long start, unsigned long end, int node)
 {
 	bootmem_data_t	*bdp;
 	unsigned long cstart, epfn;
 
-	bdp = pg_data_ptr[node]->bdata;
-	epfn = GRANULEROUNDUP(pstart + length) >> PAGE_SHIFT;
-	cstart = pstart & ~(BANKSIZE - 1);
+	bdp = &bdata[node];
+	epfn = GRANULEROUNDUP(__pa(end)) >> PAGE_SHIFT;
+	cstart = GRANULEROUNDDOWN(__pa(start));
 
 	if (!bdp->node_low_pfn) {
 		bdp->node_boot_start = cstart;
@@ -99,34 +85,96 @@
 	return 0;
 }
 
+
+/*
+ * Count the number of cpus on the node
+ */
+static __inline__ int
+count_cpus(int node)
+{
+	int cpu, n=0;
+
+	for (cpu=0; cpu < NR_CPUS; cpu++)
+		if (node = node_cpuid[cpu].nid)
+			n++;
+	return n;
+}
+
+
 /*
- * Find space on each node for the bootmem map.
+ * Find space on each node for the bootmem map & other per-node data structures.
  *
  * Called by efi_memmap_walk to find boot memory on each node. Note that
  * only blocks that are free are passed to this routine (currently filtered by
  * free_available_memory).
  */
 static int __init
-find_bootmap_space(unsigned long pstart, unsigned long length, int node)
+find_pernode_space(unsigned long start, unsigned long end, int node)
 {
-	unsigned long	mapsize, pages, epfn;
+	unsigned long	mapsize, pages, epfn, map=0, cpu, cpus;
+	unsigned long	pernodesize=0, pernode;
+       	void 		*cpu_data;
+	unsigned long	pstart, length;
 	bootmem_data_t	*bdp;
 
+	pstart = __pa(start);
+	length = end - start;
 	epfn = (pstart + length) >> PAGE_SHIFT;
-	bdp = &pg_data_ptr[node]->bdata[0];
+	bdp = &bdata[node];
 
 	if (pstart < bdp->node_boot_start || epfn > bdp->node_low_pfn)
 		return 0;
 
-	if (!bdp->node_bootmem_map) {
+	if (!boot_pernode[node]) {
+		cpus = count_cpus(node);
+		pernodesize += PERCPU_PAGE_SIZE * cpus;
+		pernodesize += L1_CACHE_ALIGN(sizeof(pg_data_t));
+		pernodesize += L1_CACHE_ALIGN(sizeof(struct ia64_node_data));
+		pernodesize = PAGE_ALIGN(pernodesize);
+		pernode = NODEDATA_ALIGN(pstart, node);
+	
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
+			for (cpu=0; cpu < NR_CPUS; cpu++) {
+				if (node = node_cpuid[cpu].nid) {
+					extern char __per_cpu_start[], __phys_per_cpu_start[];
+					memcpy(cpu_data, __phys_per_cpu_start, __per_cpu_end - __per_cpu_start);
+					__per_cpu_offset[cpu] = (char*)__va(cpu_data) - __per_cpu_start;
+					cpu_data +=  PERCPU_PAGE_SIZE;
+				}
+			}
+		}
+	}
+
+	pernode = boot_pernode[node];
+	pernodesize = boot_pernodesize[node];
+	if (pernode && !bdp->node_bootmem_map) {
 		pages = bdp->node_low_pfn - (bdp->node_boot_start>>PAGE_SHIFT);
 		mapsize = bootmem_bootmap_pages(pages) << PAGE_SHIFT;
-		if (length > mapsize) {
-			init_bootmem_node(
-				BOOT_NODE_DATA(node),
-				pstart>>PAGE_SHIFT, 
-				bdp->node_boot_start>>PAGE_SHIFT,
-				bdp->node_low_pfn);
+
+		if (pernode - pstart > mapsize)
+			map = pstart;
+		else if (pstart + length - pernode - pernodesize > mapsize)
+			map = pernode + pernodesize;
+
+		if (map) {
+			init_bootmem_node(BOOT_NODE_DATA(node),	map>>PAGE_SHIFT, 
+				bdp->node_boot_start>>PAGE_SHIFT, bdp->node_low_pfn);
 		}
 
 	}
@@ -143,9 +191,9 @@
  *
  */
 static int __init
-discontig_free_bootmem_node(unsigned long pstart, unsigned long length, int node)
+discontig_free_bootmem_node(unsigned long start, unsigned long end, int node)
 {
-	free_bootmem_node(BOOT_NODE_DATA(node), pstart, length);
+	free_bootmem_node(BOOT_NODE_DATA(node), __pa(start), end - start);
 
 	return 0;
 }
@@ -158,53 +206,50 @@
 discontig_reserve_bootmem(void)
 {
 	int		node;
-	unsigned long	mapbase, mapsize, pages;
+	unsigned long	base, size, pages;
 	bootmem_data_t	*bdp;
 
 	for (node = 0; node < numnodes; node++) {
 		bdp = BOOT_NODE_DATA(node)->bdata;
 
 		pages = bdp->node_low_pfn - (bdp->node_boot_start>>PAGE_SHIFT);
-		mapsize = bootmem_bootmap_pages(pages) << PAGE_SHIFT;
-		mapbase = __pa(bdp->node_bootmem_map);
-		reserve_bootmem_node(BOOT_NODE_DATA(node), mapbase, mapsize);
+		size = bootmem_bootmap_pages(pages) << PAGE_SHIFT;
+		base = __pa(bdp->node_bootmem_map);
+		reserve_bootmem_node(BOOT_NODE_DATA(node), base, size);
+
+		size = boot_pernodesize[node];
+		base = __pa(boot_pernode[node]);
+		reserve_bootmem_node(BOOT_NODE_DATA(node), base, size);
 	}
 }
 
 /*
- * Allocate per node tables.
- * 	- the pg_data structure is allocated on each node. This minimizes offnode 
- *	  memory references
- *	- the node data is allocated & initialized. Portions of this structure is read-only (after 
- *	  boot) and contains node-local pointers to usefuls data structures located on
- *	  other nodes.
+ * Initialize per-node data
+ *
+ * Finish setting up the node data for this node, then copy it to the other nodes.
  *
- * We also switch to using the "real" pg_data structures at this point. Earlier in boot, we
- * use a different structure. The only use for pg_data prior to the point in boot is to get 
- * the pointer to the bdata for the node.
  */
 static void __init
-allocate_pernode_structures(void)
+initialize_pernode_data(void)
 {
-	pg_data_t	*pgdat=0, *new_pgdat_list=0;
-	int		node, mynode;
+	int	cpu, node;
+
+	memcpy(boot_node_data[0]->pg_data_ptrs, pg_data_ptr, sizeof(pg_data_ptr));
+	memcpy(boot_node_data[0]->node_data_ptrs, boot_node_data, sizeof(boot_node_data));
 
-	mynode = boot_get_local_nodeid();
-	for (node = numnodes - 1; node >= 0 ; node--) {
-		node_data[node] = alloc_bootmem_node(BOOT_NODE_DATA(node), sizeof (struct ia64_node_data));
-		pgdat = __alloc_bootmem_node(BOOT_NODE_DATA(node), sizeof(pg_data_t), SMP_CACHE_BYTES, 0);
-		pgdat->bdata = &(bdata[node][0]);
-		pg_data_ptr[node] = pgdat;
-		pgdat->pgdat_next = new_pgdat_list;
-		new_pgdat_list = pgdat;
+	for (node=1; node < numnodes; node++) {
+		memcpy(boot_node_data[node], boot_node_data[0], sizeof(struct ia64_node_data));
+		boot_node_data[node]->node = node;
 	}
-	
-	memcpy(node_data[mynode]->pg_data_ptrs, pg_data_ptr, sizeof(pg_data_ptr));
-	memcpy(node_data[mynode]->node_data_ptrs, node_data, sizeof(node_data));
 
-	pgdat_list = new_pgdat_list;
+	for (cpu=0; cpu < NR_CPUS; cpu++) {
+		node = node_cpuid[cpu].nid;
+		per_cpu(cpu_info, cpu).node_data = boot_node_data[node];
+		per_cpu(cpu_info, cpu).nodeid = node;
+	}
 }
 
+
 /*
  * Called early in boot to setup the boot memory allocator, and to
  * allocate the node-local pg_data & node-directory data structures..
@@ -212,96 +257,114 @@
 void __init
 discontig_mem_init(void)
 {
-	int	node;
-
 	if (numnodes = 0) {
 		printk(KERN_ERR "node info missing!\n");
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
+/**
+ * per_cpu_init - setup per-cpu variables
+ *
+ * find_pernode_space() does most of this already, we just need to set local_per_cpu_offset
+ */
+void *per_cpu_init(void)
 {
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
+	int cpu;
+#ifdef CONFIG_SMP
+	if (smp_processor_id() = 0) {
+		for (cpu = 0; cpu < NR_CPUS; cpu++) {
+			per_cpu(local_per_cpu_offset, cpu) = __per_cpu_offset[cpu];
 		}
+	}
+	return __per_cpu_start + __per_cpu_offset[smp_processor_id()];
+#else /* !CONFIG_SMP */
+	return __phys_per_cpu_start;
+#endif /* !CONFIG_SMP */
+}
 
-		free_area_init_node(node, NODE_DATA(node), NULL, zones_size, startpfn, 0);
+/**
+ * show_mem - give short summary of memory stats
+ *
+ * Shows a simple page count of reserved and used pages in the system.
+ * For discontig machines, it does this on a per-pgdat basis.
+ */
+void show_mem(void)
+{
+	int i, reserved = 0;
+	int shared = 0, cached = 0;
+	pg_data_t *pgdat;
+
+	printk("Mem-info:\n");
+	show_free_areas();
+
+	printk("Free swap:       %6dkB\n", nr_swap_pages<<(PAGE_SHIFT-10));
+	for_each_pgdat(pgdat) {
+		printk("Node ID: %d\n", pgdat->node_id);
+		for(i = 0; i < pgdat->node_spanned_pages; i++) {
+			if (PageReserved(pgdat->node_mem_map+i))
+				reserved++;
+			else if (PageSwapCache(pgdat->node_mem_map+i))
+				cached++;
+			else if (page_count(pgdat->node_mem_map + i))
+				shared += page_count(pgdat->node_mem_map + i) - 1;
+		}
+		printk("\t%ld pages of RAM\n", pgdat->node_present_pages);
+		printk("\t%d reserved pages\n", reserved);
+		printk("\t%d pages shared\n", shared);
+		printk("\t%d pages swap cached\n", cached);
+	}
+	printk("Total of %ld pages in page table cache\n", pgtable_cache_size);
+	printk("%d free buffer pages\n", nr_free_buffer_pages());
+}
 
-		page = NODE_DATA(node)->node_mem_map;
+/*
+ * efi_memmap_walk() knows nothing about layout of memory across nodes. Find
+ * out to which node a block of memory belongs.  Ignore memory that we cannot
+ * identify, and split blocks that run across multiple nodes.
+ *
+ * Take this opportunity to round the start address up and the end address
+ * down to page boundaries.
+ */
+void call_pernode_memory(unsigned long start, unsigned long end, void *arg)
+{
+	unsigned long rs, re;
+	void (*func)(unsigned long, unsigned long, int);
+	int i;
+
+	start = PAGE_ALIGN(start);
+	end &= PAGE_MASK;
+	if (start >= end)
+		return;
+
+	func = arg;
+
+	if (!num_memblks) {
+		/* No SRAT table, to assume one node (node 0) */
+		if (start < end)
+			(*func)(start, end, 0);
+		return;
+	}
 
-		bdp = BOOT_NODE_DATA(node)->bdata;
+	for (i = 0; i < num_memblks; i++) {
+		rs = max(__pa(start), node_memblk[i].start_paddr);
+		re = min(__pa(end), node_memblk[i].start_paddr+node_memblk[i].size);
+
+		if (rs < re)
+			(*func)((unsigned long)__va(rs), (unsigned long)__va(re),
+				node_memblk[i].nid);
 
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
-		}
+		if ((unsigned long)__va(re) = end)
+			break;
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
 }
-
diff -Naur -X /home/jbarnes/dontdiff linux-2.6.0-test5-ia64/arch/ia64/mm/init.c linux-2.6.0-test5-ia64-sn/arch/ia64/mm/init.c
--- linux-2.6.0-test5-ia64/arch/ia64/mm/init.c	Mon Sep  8 12:50:03 2003
+++ linux-2.6.0-test5-ia64-sn/arch/ia64/mm/init.c	Mon Sep 15 12:19:06 2003
@@ -17,6 +17,7 @@
 #include <linux/reboot.h>
 #include <linux/slab.h>
 #include <linux/swap.h>
+#include <linux/module.h>
 
 #include <asm/a.out.h>
 #include <asm/bitops.h>
@@ -42,7 +43,8 @@
 #ifdef CONFIG_VIRTUAL_MEM_MAP
 # define LARGE_GAP	0x40000000	/* Use virtual mem map if hole is > than this */
   unsigned long vmalloc_end = VMALLOC_END_INIT;
-  static struct page *vmem_map;
+  struct page *vmem_map;
+  EXPORT_SYMBOL(vmem_map);
   static unsigned long num_dma_physpages;
 #endif
 
@@ -214,58 +216,6 @@
 	}
 }
 
-void
-show_mem(void)
-{
-	int i, total = 0, reserved = 0;
-	int shared = 0, cached = 0;
-
-	printk("Mem-info:\n");
-	show_free_areas();
-
-#ifdef CONFIG_DISCONTIGMEM
-	{
-		pg_data_t *pgdat;
-
-		printk("Free swap:       %6dkB\n", nr_swap_pages<<(PAGE_SHIFT-10));
-		for_each_pgdat(pgdat) {
-			printk("Node ID: %d\n", pgdat->node_id);
-			for(i = 0; i < pgdat->node_spanned_pages; i++) {
-				if (PageReserved(pgdat->node_mem_map+i))
-					reserved++;
-				else if (PageSwapCache(pgdat->node_mem_map+i))
-					cached++;
-				else if (page_count(pgdat->node_mem_map + i))
-					shared += page_count(pgdat->node_mem_map + i) - 1;
-			}
-			printk("\t%d pages of RAM\n", pgdat->node_spanned_pages);
-			printk("\t%d reserved pages\n", reserved);
-			printk("\t%d pages shared\n", shared);
-			printk("\t%d pages swap cached\n", cached);
-		}
-		printk("Total of %ld pages in page table cache\n", pgtable_cache_size);
-		printk("%d free buffer pages\n", nr_free_buffer_pages());
-	}
-#else /* !CONFIG_DISCONTIGMEM */
-	printk("Free swap:       %6dkB\n", nr_swap_pages<<(PAGE_SHIFT-10));
-	i = max_mapnr;
-	while (i-- > 0) {
-		total++;
-		if (PageReserved(mem_map+i))
-			reserved++;
-		else if (PageSwapCache(mem_map+i))
-			cached++;
-		else if (page_count(mem_map + i))
-			shared += page_count(mem_map + i) - 1;
-	}
-	printk("%d pages of RAM\n", total);
-	printk("%d reserved pages\n", reserved);
-	printk("%d pages shared\n", shared);
-	printk("%d pages swap cached\n", cached);
-	printk("%ld pages in page table cache\n", pgtable_cache_size);
-#endif /* !CONFIG_DISCONTIGMEM */
-}
-
 /*
  * This is like put_dirty_page() but installs a clean page in the kernel's page table.
  */
@@ -394,6 +344,7 @@
 {
 	unsigned long address, start_page, end_page;
 	struct page *map_start, *map_end;
+	int node;
 	pgd_t *pgd;
 	pmd_t *pmd;
 	pte_t *pte;
@@ -403,19 +354,20 @@
 
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
@@ -486,16 +438,6 @@
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
@@ -511,102 +453,111 @@
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
+#define GRANULEROUNDDOWN(n) ((n) & ~(IA64_GRANULE_SIZE-1))
+#define GRANULEROUNDUP(n) (((n)+IA64_GRANULE_SIZE-1) & ~(IA64_GRANULE_SIZE-1))
+#define ORDERROUNDDOWN(n) ((n) & ~((PAGE_SIZE<<MAX_ORDER)-1))
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
 void
 paging_init (void)
 {
-	extern void discontig_paging_init(void);
-
-	discontig_paging_init();
-	efi_memmap_walk(count_pages, &num_physpages);
-	zero_page_memmap_ptr = virt_to_page(ia64_imva(empty_zero_page));
-}
-#else /* !CONFIG_DISCONTIGMEM */
-void
-paging_init (void)
-{
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
 
-		map_size = PAGE_ALIGN(max_low_pfn * sizeof(struct page));
-		vmalloc_end -= map_size;
-		vmem_map = (struct page *) vmalloc_end;
-		efi_memmap_walk(create_mem_map_page_table, 0);
-
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
+#ifndef CONFIG_DISCONTIGMEM
+				mem_map = vmem_map;
+#endif
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
diff -Naur -X /home/jbarnes/dontdiff linux-2.6.0-test5-ia64/drivers/acpi/pci_irq.c linux-2.6.0-test5-ia64-sn/drivers/acpi/pci_irq.c
--- linux-2.6.0-test5-ia64/drivers/acpi/pci_irq.c	Mon Sep  8 12:50:03 2003
+++ linux-2.6.0-test5-ia64-sn/drivers/acpi/pci_irq.c	Mon Sep 15 12:19:06 2003
@@ -71,6 +71,9 @@
 
 	ACPI_FUNCTION_TRACE("acpi_pci_irq_find_prt_entry");
 
+	if (!acpi_prt.count)
+		return_PTR(NULL);
+
 	/*
 	 * Parse through all PRT entries looking for a match on the specified
 	 * PCI device's segment, bus, device, and pin (don't care about func).
diff -Naur -X /home/jbarnes/dontdiff linux-2.6.0-test5-ia64/drivers/acpi/tables.c linux-2.6.0-test5-ia64-sn/drivers/acpi/tables.c
--- linux-2.6.0-test5-ia64/drivers/acpi/tables.c	Mon Sep 15 12:18:08 2003
+++ linux-2.6.0-test5-ia64-sn/drivers/acpi/tables.c	Mon Sep 15 12:19:06 2003
@@ -69,7 +69,8 @@
 
 static unsigned long		sdt_pa;		/* Physical Address */
 static unsigned long		sdt_count;	/* Table count */
-static struct acpi_table_sdt	*sdt_entry;
+
+static struct acpi_table_sdt	sdt_entry[ACPI_MAX_TABLES];
 
 void
 acpi_table_print (
@@ -425,12 +426,6 @@
 			sdt_count = ACPI_MAX_TABLES;
 		}
 
-		sdt_entry = alloc_bootmem(sdt_count * sizeof(struct acpi_table_sdt));
-		if (!sdt_entry) {
-			printk(KERN_ERR "ACPI: Could not allocate mem for SDT entries!\n");
-			return -ENOMEM;
-		}
-
 		for (i = 0; i < sdt_count; i++)
 			sdt_entry[i].pa = (unsigned long) mapped_xsdt->entry[i];
 	}
@@ -477,12 +472,6 @@
 			sdt_count = ACPI_MAX_TABLES;
 		}
 
-		sdt_entry = alloc_bootmem(sdt_count * sizeof(struct acpi_table_sdt));
-		if (!sdt_entry) {
-			printk(KERN_ERR "ACPI: Could not allocate mem for SDT entries!\n");
-			return -ENOMEM;
-		}
-
 		for (i = 0; i < sdt_count; i++)
 			sdt_entry[i].pa = (unsigned long) mapped_rsdt->entry[i];
 	}
diff -Naur -X /home/jbarnes/dontdiff linux-2.6.0-test5-ia64/drivers/char/Kconfig linux-2.6.0-test5-ia64-sn/drivers/char/Kconfig
--- linux-2.6.0-test5-ia64/drivers/char/Kconfig	Mon Sep  8 12:49:51 2003
+++ linux-2.6.0-test5-ia64-sn/drivers/char/Kconfig	Mon Sep 15 12:19:06 2003
@@ -393,6 +393,22 @@
 	  If you have an Alchemy AU1000 processor (MIPS based) and you want
 	  to use a console on a serial port, say Y.  Otherwise, say N.
 
+config SGI_L1_SERIAL
+	bool "SGI SN2 L1 serial port support"
+	depends on SERIAL_NONSTANDARD && IA64
+	help
+	  If you have an SGI SN2 and you want to use the serial port
+	  connected to the system controller (you want this!), say Y.
+	  Otherwise, say N.
+
+config SGI_L1_SERIAL_CONSOLE
+	bool "SGI SN2 L1 serial console support"
+	depends on SGI_L1_SERIAL
+	help
+	  If you have an SGI SN2 and you would like to use the system
+	  controller serial port as your console (you want this!), 
+	  say Y.  Otherwise, say N.
+
 config QTRONIX_KEYBOARD
 	bool "Enable Qtronix 990P Keyboard Support"
 	depends on IT8712
diff -Naur -X /home/jbarnes/dontdiff linux-2.6.0-test5-ia64/drivers/char/Makefile linux-2.6.0-test5-ia64-sn/drivers/char/Makefile
--- linux-2.6.0-test5-ia64/drivers/char/Makefile	Mon Sep  8 12:50:32 2003
+++ linux-2.6.0-test5-ia64-sn/drivers/char/Makefile	Mon Sep 15 12:19:06 2003
@@ -41,6 +41,7 @@
 obj-$(CONFIG_SERIAL_TX3912) += generic_serial.o serial_tx3912.o
 obj-$(CONFIG_HVC_CONSOLE) += hvc_console.o
 obj-$(CONFIG_RAW_DRIVER) += raw.o
+obj-$(CONFIG_SGI_L1_SERIAL) += sn_serial.o
 
 obj-$(CONFIG_PRINTER) += lp.o
 obj-$(CONFIG_TIPAR) += tipar.o
diff -Naur -X /home/jbarnes/dontdiff linux-2.6.0-test5-ia64/drivers/char/sn_serial.c linux-2.6.0-test5-ia64-sn/drivers/char/sn_serial.c
--- linux-2.6.0-test5-ia64/drivers/char/sn_serial.c	Wed Dec 31 16:00:00 1969
+++ linux-2.6.0-test5-ia64-sn/drivers/char/sn_serial.c	Mon Sep 15 12:19:06 2003
@@ -0,0 +1,870 @@
+/*
+ * C-Brick Serial Port (and console) driver for SGI Altix machines.
+ *
+ * This driver is NOT suitable for talking to the l1-controller for
+ * anything other than 'console activities' --- please use the l1
+ * driver for that.
+ *
+ *
+ * Copyright (c) 2003 Silicon Graphics, Inc.  All Rights Reserved.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of version 2 of the GNU General Public License
+ * as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it would be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
+ *
+ * Further, this software is distributed without any warranty that it is
+ * free of the rightful claim of any third person regarding infringement
+ * or the like.  Any license provided herein, whether implied or
+ * otherwise, applies only to this software file.  Patent licenses, if
+ * any, provided herein do not apply to combinations of this program with
+ * other software, or any other product whatsoever.
+ *
+ * You should have received a copy of the GNU General Public
+ * License along with this program; if not, write the Free Software
+ * Foundation, Inc., 59 Temple Place - Suite 330, Boston MA 02111-1307, USA.
+ *
+ * Contact information:  Silicon Graphics, Inc., 1600 Amphitheatre Pkwy,
+ * Mountain View, CA  94043, or:
+ *
+ * http://www.sgi.com
+ *
+ * For further information regarding this notice, see:
+ *
+ * http://oss.sgi.com/projects/GenInfo/NoticeExplan
+ */
+
+
+
+#include <linux/config.h>
+#include <linux/errno.h>
+#include <linux/interrupt.h>
+#include <linux/tty.h>
+#include <linux/serial.h>
+#include <linux/console.h>
+#include <linux/module.h>
+#ifdef CONFIG_MAGIC_SYSRQ
+#include <linux/sysrq.h>
+#endif
+#include <linux/circ_buf.h>
+#include <asm/irq.h>
+#include <asm/system.h>
+#include <asm/sn/sn_sal.h>
+#include <asm/sn/nodepda.h>
+#include <asm/sn/simulator.h>
+#include <asm/sn/sn2/intr.h>
+#include <asm/sn/sn2/sn_private.h>
+#include <asm/sn/uart16550.h>
+
+#if defined(CONFIG_SGI_L1_SERIAL_CONSOLE) && defined(CONFIG_MAGIC_SYSRQ)
+static char sysrq_serial_str[] = "\eSYS";
+static char *sysrq_serial_ptr = sysrq_serial_str;
+static unsigned long sysrq_requested;
+#endif	/* CONFIG_SGI_L1_SERIAL_CONSOLE && CONFIG_MAGIC_SYSRQ */
+
+static char *serial_name = "SGI SN SAL Console Serial driver";
+static char *serial_version = "1.0";
+static char *serial_revdate = "2003-03-17";
+
+static struct tty_driver *sn_sal_driver;
+static struct tty_struct *sn_sal_tty;
+static struct console sal_console;
+static struct circ_buf xmit;
+static struct timer_list sn_sal_timer_list;
+static int sn_sal_event; /* event type for task queue */
+static char *sal_tmp_buffer;
+static int sn_sal_irq;
+static spinlock_t sn_sal_lock;
+static int tx_count;
+static int rx_count;
+
+static struct termios *sn_sal_termios;
+static struct termios *sn_sal_termios_locked;
+
+static void sn_sal_tasklet_action(unsigned long data);
+static DECLARE_TASKLET(sn_sal_tasklet, sn_sal_tasklet_action, 0);
+
+/* driver subtype - what does this mean? */
+#define SN_SAL_SUBTYPE 1
+
+/* minor device number */
+#define SN_SAL_MINOR 64
+
+/* number of characters left in xmit buffer before we ask for more */
+#define WAKEUP_CHARS 256
+
+/* number of characters we can transmit to the SAL console at a time */
+#define SN_SAL_MAX_CHARS 120
+
+/* event types for our task queue -- so far just one */
+#define SN_SAL_EVENT_WRITE_WAKEUP	0
+
+#define CONSOLE_RESTART 1
+
+#define RESTART_TIMEOUT	20*HZ
+#define POLL_TIMEOUT	2*HZ/100
+
+static unsigned long interrupt_timeout;
+
+/*
+ * sim_write() - general purpose console func when running the simulator
+ */
+
+static inline int
+sim_write(const char *str, int count)
+{
+	extern u64 master_node_bedrock_address;
+	void early_sn_setup(void);
+	int counter = count;
+
+	if (!master_node_bedrock_address)
+		early_sn_setup();
+
+	if (master_node_bedrock_address) {
+#ifdef FLAG_DIRECT_CONSOLE_WRITES
+		/* This is an easy way to pre-pend the output to know whether the output
+ 		 * was done via sal or directly */
+		writeb('[', (unsigned long)master_node_bedrock_address + (REG_DAT << 3));
+		writeb('+', (unsigned long)master_node_bedrock_address + (REG_DAT << 3));
+		writeb(']', (unsigned long)master_node_bedrock_address + (REG_DAT << 3));
+		writeb(' ', (unsigned long)master_node_bedrock_address + (REG_DAT << 3));
+#endif	/* FLAG_DIRECT_CONSOLE_WRITES */
+		while (counter > 0) {
+			writeb(*str, (unsigned long)master_node_bedrock_address + (REG_DAT << 3));
+			counter--;
+			str++;
+		}
+	}
+	return count;
+}
+
+/*********************************************************************
+ *
+ * Interrupt handling routines.  Individual subroutines are declared
+ * as inline and folded into sn_sal_interrupt.
+ */
+
+static inline void
+sn_sal_sched_event(int event)
+{
+	sn_sal_event |= (1 << event);
+	tasklet_schedule(&sn_sal_tasklet);
+}
+
+
+static inline void
+receive_chars(struct tty_struct *tty, int *status, struct pt_regs *regs)
+{
+	int ch;
+
+	do {
+		if (IS_RUNNING_ON_SIMULATOR()) {
+			extern u64 master_node_bedrock_address;
+			ch = readb((unsigned long)master_node_bedrock_address + (REG_DAT << 3));
+		} else {
+			if (sn_sal_irq) {
+				ch = ia64_sn_console_readc();
+			} else {
+				if (ia64_sn_console_getc(&ch))
+					break;
+			}
+		}
+
+#if defined(CONFIG_SGI_L1_SERIAL_CONSOLE) && defined(CONFIG_MAGIC_SYSRQ)
+		if (sysrq_requested) {
+			unsigned long sysrq_timeout = sysrq_requested + HZ*5;
+			sysrq_requested = 0;
+			if (ch && time_before(jiffies, sysrq_timeout)) {
+				handle_sysrq(ch, regs, tty);
+				goto ignore_char;
+			}
+		}
+		if (ch = *sysrq_serial_ptr) {
+			if (!(*++sysrq_serial_ptr)) {
+				sysrq_requested = jiffies;
+				sysrq_serial_ptr = sysrq_serial_str;
+			}
+		} else
+			sysrq_serial_ptr = sysrq_serial_str;
+#endif	/* CONFIG_SGI_L1_SERIAL_CONSOLE && CONFIG_MAGIC_SYSRQ */
+
+		*tty->flip.char_buf_ptr = ch;
+		tty->flip.char_buf_ptr++;
+		tty->flip.count++;
+		rx_count++;
+
+#if defined(CONFIG_SGI_L1_SERIAL_CONSOLE) && defined(CONFIG_MAGIC_SYSRQ)
+	ignore_char:
+#endif
+		if (sn_sal_irq)
+			*status = ia64_sn_console_intr_status();
+		else {
+			int sal_call_status, input;
+
+			if (IS_RUNNING_ON_SIMULATOR()) {
+				extern u64 master_node_bedrock_address;
+				sal_call_status = readb((unsigned long)master_node_bedrock_address + (REG_LSR << 3));
+				if (sal_call_status & LSR_RCA)
+					*status = SAL_CONSOLE_INTR_RECV;
+			} else {
+				sal_call_status = ia64_sn_console_check(&input);
+				if (!sal_call_status && input) {
+					/* input pending */
+					*status = SAL_CONSOLE_INTR_RECV;
+				}
+			}
+		}
+	} while (*status & SAL_CONSOLE_INTR_RECV);
+
+	tty_flip_buffer_push(tty);
+}
+
+
+static inline void
+transmit_chars(struct tty_struct *tty)
+{
+	int xmit_count, tail, head, loops, ii;
+	int result;
+	unsigned long flags;
+	char *start;
+
+	if (xmit.head = xmit.tail || tty->stopped || tty->hw_stopped) {
+		/* Nothing to do. */
+		return;
+	}
+
+	/* Make sure no one gets here until we have drained the buffer */
+
+	spin_lock_irqsave(&sn_sal_lock, flags);
+
+	head = xmit.head;
+	tail = xmit.tail;
+	start = &xmit.buf[tail];
+
+	/* twice around gets the tail to the end of the buffer and then to the head, if needed */
+	loops = (head < tail) ? 2 : 1;
+
+	for (ii = 0; ii < loops; ii++) {
+		xmit_count = (head < tail) ? (SERIAL_XMIT_SIZE - tail) : (head - tail);
+
+		if (xmit_count > 0) {
+			if (IS_RUNNING_ON_SIMULATOR())
+				result = sim_write(start, xmit_count);
+			else {
+				if (sn_sal_irq)
+					result = ia64_sn_console_xmit_chars(start, xmit_count);
+				else
+					result = ia64_sn_console_putb(start, xmit_count);
+			}
+			if (result > 0) {
+				xmit_count -= result;
+				tx_count += result;
+				tail += result;
+				tail &= SERIAL_XMIT_SIZE - 1;
+				xmit.tail = tail;
+				start = &xmit.buf[tail];
+			}
+		}
+	}
+	spin_unlock_irqrestore(&sn_sal_lock, flags);
+
+	if (CIRC_CNT(xmit.head, xmit.tail, SERIAL_XMIT_SIZE) < WAKEUP_CHARS) {
+		/* There's few enough characters left in the xmit buffer
+		 * that we could stand for the upper layer to send us some
+		 * more.  Ask for it.
+		 */
+		sn_sal_sched_event(SN_SAL_EVENT_WRITE_WAKEUP);
+	}
+}
+
+
+irqreturn_t
+sn_sal_interrupt(int irq, void *dev_id, struct pt_regs *regs)
+{
+	int status;
+
+	if (irq) {
+		status = ia64_sn_console_intr_status();
+
+		if (status & SAL_CONSOLE_INTR_RECV) {
+			receive_chars(sn_sal_tty, &status, regs);
+		}
+	
+		if (status & SAL_CONSOLE_INTR_XMIT) {
+			transmit_chars(sn_sal_tty);
+		}
+	} else {
+		/* Polling */
+		int input;
+
+		if (IS_RUNNING_ON_SIMULATOR()) {
+			extern u64 master_node_bedrock_address;
+                        input = readb((unsigned long)master_node_bedrock_address + (REG_LSR << 3));
+                        if (input & LSR_RCA)
+				receive_chars(sn_sal_tty, &status, regs);
+
+		} else {
+			status = ia64_sn_console_check(&input);
+			if (!status && input)
+				receive_chars(sn_sal_tty, &status, regs);
+		}
+		transmit_chars(sn_sal_tty);
+	}
+
+	return IRQ_HANDLED;
+}
+
+
+#ifdef CONSOLE_POLLING_ONLY
+#define sn_sal_connect_interrupt() do { } while (0)
+#else
+static void
+sn_sal_connect_interrupt(void)
+{
+	cpuid_t intr_cpuid;
+	unsigned int intr_cpuloc;
+	nasid_t console_nasid;
+	unsigned int console_irq;
+	int result;
+
+	/* if it is an old prom, run in poll mode */
+	if (((sn_sal_rev_major() <= 1) && (sn_sal_rev_minor() <= 3))
+	    || (IS_RUNNING_ON_SIMULATOR())) {
+		/* before version 1.06 doesn't work */
+		printk("===== OLD prom version %x.%x - run in polled mode\n",
+		       sn_sal_rev_major(), sn_sal_rev_minor());
+		sn_sal_irq = 0;	/* Make sure */
+		return ;
+	}
+
+	console_nasid = ia64_sn_get_console_nasid();
+	intr_cpuid = NODEPDA(NASID_TO_COMPACT_NODEID(console_nasid))
+		-> node_first_cpu;
+	intr_cpuloc = cpu_physical_id(intr_cpuid);
+	console_irq = CPU_VECTOR_TO_IRQ(intr_cpuloc, SGI_UART_VECTOR);
+
+	result = intr_connect_level(intr_cpuid, SGI_UART_VECTOR,
+				    0 /*not used*/, 0 /*not used*/);
+	BUG_ON(result != SGI_UART_VECTOR);
+
+	result = request_irq(console_irq, sn_sal_interrupt,
+			     SA_INTERRUPT,  "SAL console driver",
+			     &sn_sal_tty);
+	if (result >= 0) {
+		/* sn_sal_irq is a global variable.  When it's set to a non-zero
+		 * value, the console driver stops polling for input (since interrupts
+		 * should now be enabled).
+		 */
+		sn_sal_irq = console_irq;
+
+		/* ask SAL to turn on interrupts in the UART itself */
+		ia64_sn_console_intr_enable(SAL_CONSOLE_INTR_RECV);
+		/* xmit interrupts are enabled by SAL as necessary */
+	} else
+		printk("Console proceeding in polled mode\n");
+}
+#endif	/* CONSOLE_POLLING_ONLY */
+
+
+/*
+ *
+ * End of the interrupt routines.
+ *********************************************************************/
+
+
+/*********************************************************************
+ * From drivers/char/serial.c:
+ *
+ * "This routine is used to handle the "bottom half" processing for the
+ * serial driver, known also the "software interrupt" processing.
+ * This processing is done at the kernel interrupt level, after the
+ * [sn_sal_interrupt()] has returned, BUT WITH INTERRUPTS TURNED ON.  This
+ * is where time-consuming activities which can not be done in the
+ * interrupt driver proper are done; the interrupt driver schedules
+ * them using [sn_sal_sched_event()], and they get done here."
+ */
+static void
+sn_sal_tasklet_action(unsigned long data)
+{
+	struct tty_struct *tty;
+
+	if (!(tty = sn_sal_tty))
+		return;
+
+	if (test_and_clear_bit(SN_SAL_EVENT_WRITE_WAKEUP, &sn_sal_event)) {
+		if ((tty->flags & (1 << TTY_DO_WRITE_WAKEUP)) &&
+		    tty->ldisc.write_wakeup)
+			(tty->ldisc.write_wakeup)(tty);
+		wake_up_interruptible(&tty->write_wait);
+	}
+}
+
+
+/*
+ * This function handles polled mode.
+ */
+static void
+sn_sal_timer(unsigned long dummy)
+{
+	if (sn_sal_irq = 0) {
+		sn_sal_interrupt(0, NULL, NULL);
+		mod_timer(&sn_sal_timer_list, jiffies + interrupt_timeout);
+		return;
+	}
+
+#if CONSOLE_RESTART
+	sn_sal_interrupt(1, NULL, NULL);
+	mod_timer(&sn_sal_timer_list, jiffies + interrupt_timeout);
+#endif
+}
+
+
+/*
+ *
+ * End of "sofware interrupt" routines.
+ *********************************************************************/
+
+
+
+/*********************************************************************
+ *
+ * User-level console routines
+ *
+ */
+
+static int
+sn_sal_open(struct tty_struct *tty, struct file *filp)
+{
+	if (!sn_sal_tty)
+		sn_sal_tty = tty;
+
+	if (sn_sal_irq = 0 || CONSOLE_RESTART)
+		mod_timer(&sn_sal_timer_list, jiffies + interrupt_timeout);
+
+	return 0;
+}
+
+
+/* We're keeping all our resources.  We're keeping interrupts turned
+ * on.  Maybe just let the tty layer finish its stuff...? GMSH
+ */
+static void
+sn_sal_close(struct tty_struct *tty, struct file * filp)
+{
+	tty->closing = 1;
+	if (tty->driver->flush_buffer)
+		tty->driver->flush_buffer(tty);
+	if (tty->ldisc.flush_buffer)
+		tty->ldisc.flush_buffer(tty);
+	tty->closing = 0;
+    
+	return;
+}
+
+
+static int
+sn_sal_write(struct tty_struct *tty, int from_user,
+	       const unsigned char *buf, int count)
+{
+	int c, ret = 0;
+	unsigned long flags;
+
+	if (from_user) {
+		while (1) {
+			int c1;
+			c = CIRC_SPACE_TO_END(xmit.head, xmit.tail,
+					      SERIAL_XMIT_SIZE);
+
+			if (count < c)
+				c = count;
+			if (c <= 0)
+				break;
+
+			c -= copy_from_user(sal_tmp_buffer, buf, c);
+			if (!c) {
+				if (!ret)
+					ret = -EFAULT;
+				break;
+			}
+
+			/* Turn off interrupts and see if the xmit buffer has
+			 * moved since the last time we looked.
+			 */
+			spin_lock_irqsave(&sn_sal_lock, flags);
+			c1 = CIRC_SPACE_TO_END(xmit.head, xmit.tail,
+					       SERIAL_XMIT_SIZE);
+
+			if (c1 < c)
+				c = c1;
+
+			memcpy(xmit.buf + xmit.head, sal_tmp_buffer, c);
+			xmit.head = ((xmit.head + c) & (SERIAL_XMIT_SIZE - 1));
+			spin_unlock_irqrestore(&sn_sal_lock, flags);
+
+			buf += c;
+			count -= c;
+			ret += c;
+		}
+	} else {
+		/* The buffer passed in isn't coming from userland,
+		 * so cut out the middleman (sal_tmp_buffer).
+		 */
+		spin_lock_irqsave(&sn_sal_lock, flags);
+		while (1) {
+			c = CIRC_SPACE_TO_END(xmit.head, xmit.tail,
+					      SERIAL_XMIT_SIZE);
+
+			if (count < c)
+				c = count;
+			if (c <= 0) {
+				break;
+			}
+			memcpy(xmit.buf + xmit.head, buf, c);
+			xmit.head = ((xmit.head + c) & (SERIAL_XMIT_SIZE - 1));
+			buf += c;
+			count -= c;
+			ret += c;
+		}
+		spin_unlock_irqrestore(&sn_sal_lock, flags);
+	}
+
+	if ((xmit.head != xmit.tail) && !tty->stopped && !tty->hw_stopped)
+		transmit_chars(tty);
+
+	return ret;
+}
+
+
+static void
+sn_sal_put_char(struct tty_struct *tty, unsigned char ch)
+{
+	unsigned long flags;
+
+	if (!tty || !xmit.buf)
+		return;
+
+	spin_lock_irqsave(&sn_sal_lock, flags);
+	if (CIRC_SPACE(xmit.head, xmit.tail, SERIAL_XMIT_SIZE) = 0) {
+		spin_unlock_irqrestore(&sn_sal_lock, flags);
+		return;
+	}
+
+	xmit.buf[xmit.head] = ch;
+	xmit.head = (xmit.head + 1) & (SERIAL_XMIT_SIZE-1);
+	spin_unlock_irqrestore(&sn_sal_lock, flags);
+}
+
+
+static void
+sn_sal_flush_chars(struct tty_struct *tty)
+{
+	if (CIRC_CNT(xmit.head, xmit.tail, SERIAL_XMIT_SIZE))
+		transmit_chars(tty);
+}
+
+
+static int
+sn_sal_write_room(struct tty_struct *tty)
+{
+	return CIRC_SPACE(xmit.head, xmit.tail, SERIAL_XMIT_SIZE);
+}
+
+
+static int
+sn_sal_chars_in_buffer(struct tty_struct *tty)
+{
+	return CIRC_CNT(xmit.head, xmit.tail, SERIAL_XMIT_SIZE);
+}
+
+
+static int
+sn_sal_ioctl(struct tty_struct *tty, struct file *file,
+	       unsigned int cmd, unsigned long arg)
+{
+	/* nothing supported*/
+	return -ENOIOCTLCMD;
+}
+
+
+static void
+sn_sal_set_termios(struct tty_struct *tty, struct termios *old_termios)
+{
+ 	/* don't care about termios */
+	return;
+}
+
+
+static void
+sn_sal_flush_buffer(struct tty_struct *tty)
+{
+	unsigned long flags;
+
+	/* drop everything */
+	spin_lock_irqsave(&sn_sal_lock, flags);
+	xmit.head = xmit.tail = 0;
+	spin_unlock_irqrestore(&sn_sal_lock, flags);
+
+	/* wake up tty level */
+	wake_up_interruptible(&tty->write_wait);
+	if ((tty->flags & (1 << TTY_DO_WRITE_WAKEUP)) &&
+	    tty->ldisc.write_wakeup)
+		(tty->ldisc.write_wakeup)(tty);
+}
+
+
+static void
+sn_sal_hangup(struct tty_struct *tty)
+{
+	sn_sal_flush_buffer(tty);
+}
+
+
+static void
+sn_sal_wait_until_sent(struct tty_struct *tty, int timeout)
+{
+	/* this is SAL's problem */
+	return;
+}
+
+
+/*
+ * sn_sal_read_proc
+ *
+ * Console /proc interface
+ */
+
+static int
+sn_sal_read_proc(char *page, char **start, off_t off, int count,
+		   int *eof, void *data)
+{
+	int len = 0;
+	off_t	begin = 0;
+	extern nasid_t get_console_nasid(void);
+
+	len += sprintf(page, "sal_cons: %s 1.0 driver:%s revision:%s console nasid %d : irq %d tx/rx %d/%d\n",
+		       serial_name, serial_version, serial_revdate, get_console_nasid(), sn_sal_irq,
+		       tx_count, rx_count);
+	*eof = 1;
+
+	if (off >= len+begin)
+		return 0;
+	*start = page + (off-begin);
+
+	return count < begin+len-off ? count : begin+len-off;
+}
+
+
+static struct tty_operations sn_sal_ops = {
+	.open = sn_sal_open,
+	.close = sn_sal_close,
+	.write = sn_sal_write,
+	.put_char = sn_sal_put_char,
+	.flush_chars = sn_sal_flush_chars,
+	.write_room = sn_sal_write_room,
+	.chars_in_buffer = sn_sal_chars_in_buffer,
+	.ioctl = sn_sal_ioctl,
+	.set_termios = sn_sal_set_termios,
+	.hangup = sn_sal_hangup,
+	.wait_until_sent = sn_sal_wait_until_sent,
+	.read_proc = sn_sal_read_proc,
+};
+
+/* sn_sal_init wishlist:
+ * - allocate sal_tmp_buffer
+ * - fix up the tty_driver struct
+ * - turn on receive interrupts
+ * - do any termios twiddling once and for all
+ */
+
+/*
+ * Boot-time initialization code
+ */
+static int __init
+sn_sal_init(void)
+{
+	int retval = 0;
+
+	if (!ia64_platform_is("sn2"))
+		return -ENODEV;
+
+	sn_sal_driver = alloc_tty_driver(1);
+	if (!sn_sal_driver)
+		return -ENOMEM;
+
+	sn_sal_driver->owner = THIS_MODULE;
+	sn_sal_driver->driver_name = "SALconsole",
+	sn_sal_driver->name = "ttyS",
+	sn_sal_driver->major = TTY_MAJOR,
+	sn_sal_driver->minor_start = SN_SAL_MINOR,
+	sn_sal_driver->type = TTY_DRIVER_TYPE_SERIAL,
+	sn_sal_driver->subtype = SN_SAL_SUBTYPE,
+	sn_sal_driver->flags = TTY_DRIVER_REAL_RAW | TTY_DRIVER_NO_DEVFS,
+	sn_sal_driver->termios = &sn_sal_termios,
+	sn_sal_driver->termios_locked = &sn_sal_termios_locked,
+	sn_sal_driver->init_termios = tty_std_termios;
+	sn_sal_driver->init_termios.c_cflag = B9600 | CS8 | CREAD | HUPCL | CLOCAL;
+
+	tty_set_operations(sn_sal_driver, &sn_sal_ops);
+	if ((retval = tty_register_driver(sn_sal_driver)))
+		goto free_driver;
+
+	/* initialize xmit */
+	xmit.buf = (char *)get_zeroed_page(GFP_KERNEL);
+	if (!xmit.buf) {
+		retval = -ENOMEM;
+		goto free_driver;
+	}
+
+	xmit.head = 0;
+	xmit.tail = 0;
+
+	sn_sal_lock = SPIN_LOCK_UNLOCKED;
+
+	/* allocate a temporary buffer for copying data from user land */
+	sal_tmp_buffer = (char *)get_zeroed_page(GFP_KERNEL);
+	if (!sal_tmp_buffer) {
+		retval = -ENOMEM;
+		goto free_xmit;
+	}
+
+	/* turn on interrupts */
+	sn_sal_connect_interrupt();
+
+	/* Without interrupts, we have to rely on a timer to poll the
+	 * SAL console driver.
+	 */
+	if (sn_sal_irq = 0 || CONSOLE_RESTART) {
+		init_timer(&sn_sal_timer_list);
+		sn_sal_timer_list.function = sn_sal_timer;
+		if (sn_sal_irq = 1 && CONSOLE_RESTART)
+			interrupt_timeout = RESTART_TIMEOUT;
+		else
+			interrupt_timeout = POLL_TIMEOUT;
+		mod_timer(&sn_sal_timer_list, jiffies + interrupt_timeout);
+	}
+
+	return 0;
+
+free_xmit:
+	free_page((unsigned long)xmit.buf);
+free_driver:
+	put_tty_driver(sn_sal_driver);
+	return retval;
+}
+
+
+static void __exit
+sn_sal_fini(void)
+{
+	unsigned long flags;
+	int e;
+
+	del_timer_sync(&sn_sal_timer_list);
+
+	spin_lock_irqsave(&sn_sal_lock, flags);
+	if ((e = tty_unregister_driver(sn_sal_driver)))
+		printk("SALconsole: failed to unregister driver (%d)\n", e);
+	spin_unlock_irqrestore(&sn_sal_lock, flags);
+
+	free_page((unsigned long)xmit.buf);
+	free_page((unsigned long)sal_tmp_buffer);
+	put_tty_driver(sn_sal_driver);
+}
+
+module_init(sn_sal_init);
+module_exit(sn_sal_fini);
+
+/*
+ *
+ * End of user-level console routines.
+ *********************************************************************/
+
+
+
+/*********************************************************************
+ *
+ * Kernel console definitions
+ *
+ */
+
+/*
+ * Print a string to the SAL console.  The console_lock must be held
+ * when we get here.
+ */
+static void
+sn_sal_console_write(struct console *co, const char *s, unsigned count)
+{
+	if (IS_RUNNING_ON_SIMULATOR())
+		sim_write(s, count);
+	else
+		ia64_sn_console_putb(s, count);
+}
+
+#if defined(CONFIG_IA64_EARLY_PRINTK_SGI_SN)
+void
+sn_sal_console_out(const char *s, unsigned count)
+{
+	/* Need to setup SAL calls so the PROM calls will work */
+	static int inited;
+	void early_sn_setup(void);
+	if (!inited) {
+		inited=1;
+		early_sn_setup();
+	}
+
+	if (IS_RUNNING_ON_SIMULATOR())
+		sim_write(s, count);
+	else
+    		ia64_sn_console_putb(s, count);
+}
+#endif	/* CONFIG_IA64_EARLY_PRINTK_SGI_SN */
+
+static struct tty_driver *
+sn_sal_console_device(struct console *c, int *index)
+{
+	*index = c->index;
+	return sn_sal_driver;
+}
+
+static int __init
+sn_sal_console_setup(struct console *co, char *options)
+{
+	return 0;
+}
+
+
+static struct console sal_console = {
+	.name = "ttyS",
+	.write = sn_sal_console_write,
+	.device = sn_sal_console_device,
+	.setup = sn_sal_console_setup,
+	.flags = CON_PRINTBUFFER,
+	.index = -1
+};
+
+/*
+ *
+ * End of kernel console definitions.
+ *********************************************************************/
+
+
+
+#ifdef CONFIG_SGI_L1_SERIAL_CONSOLE
+/*
+ *	Register console.
+ */
+int __init
+sgi_l1_serial_console_init(void)
+{
+	if (ia64_platform_is("sn2"))
+		register_console(&sal_console);
+
+	return 0;
+}
+
+console_initcall(sgi_l1_serial_console_init);
+
+#endif /* CONFIG_SGI_L1_SERIAL_CONSOLE */
diff -Naur -X /home/jbarnes/dontdiff linux-2.6.0-test5-ia64/drivers/scsi/qla1280.c linux-2.6.0-test5-ia64-sn/drivers/scsi/qla1280.c
--- linux-2.6.0-test5-ia64/drivers/scsi/qla1280.c	Mon Sep  8 12:50:43 2003
+++ linux-2.6.0-test5-ia64-sn/drivers/scsi/qla1280.c	Mon Sep 15 12:19:06 2003
@@ -3359,9 +3359,9 @@
 			ha->bus_settings[bus].scsi_bus_dead = 1;
 		ha->bus_settings[bus].failed_reset_count++;
 	} else {
-		spin_unlock_irq(HOST_LOCK);
+//		spin_unlock_irq(HOST_LOCK);
 		schedule_timeout(reset_delay * HZ);
-		spin_lock_irq(HOST_LOCK);
+//		spin_lock_irq(HOST_LOCK);
 
 		ha->bus_settings[bus].scsi_bus_dead = 0;
 		ha->bus_settings[bus].failed_reset_count = 0;
diff -Naur -X /home/jbarnes/dontdiff linux-2.6.0-test5-ia64/include/asm-ia64/mmzone.h linux-2.6.0-test5-ia64-sn/include/asm-ia64/mmzone.h
--- linux-2.6.0-test5-ia64/include/asm-ia64/mmzone.h	Mon Sep  8 12:50:59 2003
+++ linux-2.6.0-test5-ia64-sn/include/asm-ia64/mmzone.h	Mon Sep 15 12:19:06 2003
@@ -3,7 +3,7 @@
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
  *
- * Copyright (c) 2000 Silicon Graphics, Inc.  All rights reserved.
+ * Copyright (c) 2000,2003 Silicon Graphics, Inc.  All rights reserved.
  * Copyright (c) 2002 NEC Corp.
  * Copyright (c) 2002 Erich Focht <efocht@ess.nec.de>
  * Copyright (c) 2002 Kimio Suganuma <k-suganuma@da.jp.nec.com>
@@ -14,150 +14,50 @@
 #include <linux/config.h>
 #include <linux/init.h>
 
-/*
- * Given a kaddr, find the base mem_map address for the start of the mem_map
- * entries for the bank containing the kaddr.
- */
-#define BANK_MEM_MAP_BASE(kaddr) local_node_data->bank_mem_map_base[BANK_MEM_MAP_INDEX(kaddr)]
 
-/*
- * Given a kaddr, this macro return the relative map number 
- * within the bank.
- */
-#define BANK_MAP_NR(kaddr) 	(BANK_OFFSET(kaddr) >> PAGE_SHIFT)
+#ifdef CONFIG_NUMA
 
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
+#ifdef CONFIG_IA64_DIG
 
 /*
- * Given a page struct entry, return the physical address that the page struct represents.
- * Since IA64 has all memory in the DMA zone, the following works:
+ * Platform definitions for DIG platform with contiguous memory.
  */
-#define page_to_phys(page)	__pa(page_address(page))
-
-#define node_mem_map(nid)	(NODE_DATA(nid)->node_mem_map)
-
-#define node_localnr(pfn, nid)	((pfn) - NODE_DATA(nid)->node_start_pfn)
+#define MAX_PHYSNODE_ID	8		/* Maximum node number +1 */
+#define NR_NODES	8		/* Maximum number of nodes in SSI */
+#define NR_MEMBLKS	(NR_NODES * 32)
 
-#define pfn_to_page(pfn)	(struct page *)(node_mem_map(pfn_to_nid(pfn)) + node_localnr(pfn, pfn_to_nid(pfn)))
 
-#define pfn_to_nid(pfn)		 local_node_data->node_id_map[(pfn << PAGE_SHIFT) >> BANKSHIFT]
 
-#define page_to_pfn(page)	(long)((page - page_zone(page)->zone_mem_map) + page_zone(page)->zone_start_pfn)
 
+#elif CONFIG_IA64_SGI_SN2
 
 /*
- * pfn_valid should be made as fast as possible, and the current definition
- * is valid for machines that are NUMA, but still contiguous, which is what
- * is currently supported. A more generalised, but slower definition would
- * be something like this - mbligh:
- * ( pfn_to_pgdat(pfn) && (pfn < node_end_pfn(pfn_to_nid(pfn))) )
+ * Platform definitions for DIG platform with contiguous memory.
  */
-#define pfn_valid(pfn)          (pfn < max_low_pfn)
-extern unsigned long max_low_pfn;
+#define MAX_PHYSNODE_ID	2048		/* Maximum node number +1 */
+#define NR_NODES	256		/* Maximum number of compute nodes in SSI */
+#define NR_MEMBLKS	(NR_NODES)
 
+#elif CONFIG_IA64_GENERIC
 
-#ifdef CONFIG_IA64_DIG
 
 /*
- * Platform definitions for DIG platform with contiguous memory.
+ * Platform definitions for GENERIC platform with contiguous or discontiguous memory.
  */
-#define MAX_PHYSNODE_ID	8	/* Maximum node number +1 */
-#define NR_NODES	8	/* Maximum number of nodes in SSI */
+#define MAX_PHYSNODE_ID 2048		/* Maximum node number +1 */
+#define NR_NODES        256		/* Maximum number of nodes in SSI */
+#define NR_MEMBLKS      (NR_NODES)
 
-#define MAX_PHYS_MEMORY	(1UL << 40)	/* 1 TB */
 
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
+#error unknown platform
 #endif
-#define BANKSIZE		(1UL << BANKSHIFT)
-#define BANK_OFFSET(addr)	((unsigned long)(addr) & (BANKSIZE-1))
-#define NR_BANKS		(NR_BANKS_PER_NODE * NR_NODES)
 
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
+extern void build_cpu_to_node_map(void);
 
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
+#else /* CONFIG_NUMA */
 
-/*
- * Given a nodeid & a bank number, find the address of the mem_map
- * entry for the first page of the bank.
- */
-#define BANK_MEM_MAP_INDEX(kaddr) \
-	(((unsigned long)(kaddr) & (MAX_PHYS_MEMORY-1)) >> BANKSHIFT)
+#define NR_NODES	1
 
-#endif /* CONFIG_IA64_DIG */
+#endif /* CONFIG_NUMA */
 #endif /* _ASM_IA64_MMZONE_H */
diff -Naur -X /home/jbarnes/dontdiff linux-2.6.0-test5-ia64/include/asm-ia64/nodedata.h linux-2.6.0-test5-ia64-sn/include/asm-ia64/nodedata.h
--- linux-2.6.0-test5-ia64/include/asm-ia64/nodedata.h	Mon Sep  8 12:50:18 2003
+++ linux-2.6.0-test5-ia64-sn/include/asm-ia64/nodedata.h	Mon Sep 15 12:19:06 2003
@@ -13,7 +13,7 @@
 #ifndef _ASM_IA64_NODEDATA_H
 #define _ASM_IA64_NODEDATA_H
 
-
+#include <asm/percpu.h>
 #include <asm/mmzone.h>
 
 /*
@@ -22,15 +22,17 @@
 
 struct pglist_data;
 struct ia64_node_data {
-	short			active_cpu_count;
 	short			node;
+	short			active_cpu_count;
+	/*
+	 * The fields are read-only (after boot). They contain pointers
+	 * to various structures located on other nodes. Ths data is
+	 * replicated on each node in order to reduce off-node references.
+	 */
         struct pglist_data	*pg_data_ptrs[NR_NODES];
-	struct page		*bank_mem_map_base[NR_BANKS];
 	struct ia64_node_data	*node_data_ptrs[NR_NODES];
-	short			node_id_map[NR_BANKS];
 };
 
-
 /*
  * Return a pointer to the node_data structure for the executing cpu.
  */
@@ -40,7 +42,8 @@
 /*
  * Return a pointer to the node_data structure for the specified node.
  */
-#define node_data(node)	(local_node_data->node_data_ptrs[node])
+#define node_data(node) (local_node_data->node_data_ptrs[node])
+#define NODE_DATA(nid) (local_node_data->pg_data_ptrs[nid])
 
 /*
  * Get a pointer to the node_id/node_data for the current cpu.
@@ -49,28 +52,4 @@
 extern int boot_get_local_nodeid(void);
 extern struct ia64_node_data *get_node_data_ptr(void);
 
-/*
- * Given a node id, return a pointer to the pg_data_t for the node.
- * The following 2 macros are similar. 
- *
- * NODE_DATA 	- should be used in all code not related to system
- *		  initialization. It uses pernode data structures to minimize
- *		  offnode memory references. However, these structure are not 
- *		  present during boot. This macro can be used once cpu_init
- *		  completes.
- *
- * BOOT_NODE_DATA
- *		- should be used during system initialization 
- *		  prior to freeing __initdata. It does not depend on the percpu
- *		  area being present.
- *
- * NOTE:   The names of these macros are misleading but are difficult to change
- *	   since they are used in generic linux & on other architecures.
- */
-#define NODE_DATA(nid)		(local_node_data->pg_data_ptrs[nid])
-#define BOOT_NODE_DATA(nid)	boot_get_pg_data_ptr((long)(nid))
-
-struct pglist_data;
-extern struct pglist_data * __init boot_get_pg_data_ptr(long);
-
 #endif /* _ASM_IA64_NODEDATA_H */
diff -Naur -X /home/jbarnes/dontdiff linux-2.6.0-test5-ia64/include/asm-ia64/numa.h linux-2.6.0-test5-ia64-sn/include/asm-ia64/numa.h
--- linux-2.6.0-test5-ia64/include/asm-ia64/numa.h	Mon Sep  8 12:50:01 2003
+++ linux-2.6.0-test5-ia64-sn/include/asm-ia64/numa.h	Mon Sep 15 12:19:06 2003
@@ -15,13 +15,21 @@
 
 #ifdef CONFIG_DISCONTIGMEM
 # include <asm/mmzone.h>
-# define NR_MEMBLKS   (NR_BANKS)
 #else
 # define NR_NODES     (8)
 # define NR_MEMBLKS   (NR_NODES * 8)
 #endif
 
 #include <linux/cache.h>
+#include <linux/threads.h>
+#include <linux/smp.h>
+
+#define NODEMASK_WORDCOUNT       ((NR_NODES+(BITS_PER_LONG-1))/BITS_PER_LONG)
+
+#define NODE_MASK_NONE   { [0 ... ((NR_NODES+BITS_PER_LONG-1)/BITS_PER_LONG)-1] = 0 }
+
+typedef unsigned long   nodemask_t[NODEMASK_WORDCOUNT];
+                                                                                                                             
 extern volatile char cpu_to_node_map[NR_CPUS] __cacheline_aligned;
 extern volatile unsigned long node_to_cpu_mask[NR_NODES] __cacheline_aligned;
 
@@ -64,6 +72,12 @@
 
 #define local_nodeid (cpu_to_node_map[smp_processor_id()])
 
+#else /* !CONFIG_NUMA */
+
+#define node_distance(from,to) 10
+#define paddr_to_nid(x) 0
+#define local_nodeid 0
+
 #endif /* CONFIG_NUMA */
 
 #endif /* _ASM_IA64_NUMA_H */
diff -Naur -X /home/jbarnes/dontdiff linux-2.6.0-test5-ia64/include/asm-ia64/page.h linux-2.6.0-test5-ia64-sn/include/asm-ia64/page.h
--- linux-2.6.0-test5-ia64/include/asm-ia64/page.h	Mon Sep  8 12:49:53 2003
+++ linux-2.6.0-test5-ia64-sn/include/asm-ia64/page.h	Mon Sep 15 12:19:06 2003
@@ -94,19 +94,27 @@
 
 #define virt_addr_valid(kaddr)	pfn_valid(__pa(kaddr) >> PAGE_SHIFT)
 
-#ifndef CONFIG_DISCONTIGMEM
-# ifdef CONFIG_VIRTUAL_MEM_MAP
-   extern int ia64_pfn_valid (unsigned long pfn);
-#  define pfn_valid(pfn)	(((pfn) < max_mapnr) && ia64_pfn_valid(pfn))
-# else
-#  define pfn_valid(pfn)	((pfn) < max_mapnr)
-# endif
-#define virt_to_page(kaddr)	pfn_to_page(__pa(kaddr) >> PAGE_SHIFT)
-#define page_to_pfn(page)	((unsigned long) (page - mem_map))
+#ifdef CONFIG_VIRTUAL_MEM_MAP
+extern int ia64_pfn_valid(unsigned long pfn);
+#else
+#define ia64_pfn_valid(pfn) (1)
+#endif
+
+extern unsigned long max_low_pfn;
+#define pfn_valid(pfn) (((pfn) < max_low_pfn) && ia64_pfn_valid(pfn))
+
+#if defined(CONFIG_VIRTUAL_MEM_MAP)
+extern struct page *vmem_map;
+#define pfn_to_page(pfn)	(vmem_map + (pfn))
+#define page_to_pfn(page)	((unsigned long) (page - vmem_map))
+#else
 #define pfn_to_page(pfn)	(mem_map + (pfn))
-#define page_to_phys(page)	(page_to_pfn(page) << PAGE_SHIFT)
+#define page_to_pfn(page)	((unsigned long) (page - mem_map))
 #endif
 
+#define virt_to_page(kaddr)	(pfn_to_page(__pa(kaddr) >> PAGE_SHIFT))
+#define page_to_phys(page)	(page_to_pfn(page) << PAGE_SHIFT)
+
 typedef union ia64_va {
 	struct {
 		unsigned long off : 61;		/* intra-region offset */
diff -Naur -X /home/jbarnes/dontdiff linux-2.6.0-test5-ia64/include/asm-ia64/percpu.h linux-2.6.0-test5-ia64-sn/include/asm-ia64/percpu.h
--- linux-2.6.0-test5-ia64/include/asm-ia64/percpu.h	Mon Sep  8 12:50:19 2003
+++ linux-2.6.0-test5-ia64-sn/include/asm-ia64/percpu.h	Mon Sep 15 12:19:06 2003
@@ -46,6 +46,7 @@
 
 extern void percpu_modcopy(void *pcpudst, const void *src, unsigned long size);
 extern void setup_per_cpu_areas (void);
+extern void *per_cpu_init(void);
 
 #else /* ! SMP */
 
diff -Naur -X /home/jbarnes/dontdiff linux-2.6.0-test5-ia64/include/asm-ia64/pgtable.h linux-2.6.0-test5-ia64-sn/include/asm-ia64/pgtable.h
--- linux-2.6.0-test5-ia64/include/asm-ia64/pgtable.h	Mon Sep  8 12:49:59 2003
+++ linux-2.6.0-test5-ia64-sn/include/asm-ia64/pgtable.h	Mon Sep 15 12:19:06 2003
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
@@ -415,7 +411,35 @@
 }
 
 extern pgd_t swapper_pg_dir[PTRS_PER_PGD];
+extern unsigned long MAX_DMA_ADDRESS;
+
+/*
+ * Entries defined so far:
+ * 	- boot param structure itself
+ * 	- memory map
+ * 	- initrd (optional)
+ * 	- command line string
+ * 	- kernel code & data
+ *
+ * More could be added if necessary
+ */
+struct rsvd_region {
+	unsigned long start;	/* virtual address of beginning of element */
+	unsigned long end;	/* virtual address of end of element + 1 */
+};
+#define IA64_MAX_RSVD_REGIONS 5
+extern struct rsvd_region rsvd_region[IA64_MAX_RSVD_REGIONS + 1];
+extern int num_rsvd_regions;
 extern void paging_init (void);
+extern int filter_rsvd_memory(unsigned long start, unsigned long end, void *arg);
+#ifdef CONFIG_DISCONTIGMEM
+extern void discontig_mem_init(void);
+extern void call_pernode_memory(unsigned long start, unsigned long end, void *arg);
+#else
+extern unsigned long bootmap_start;
+extern int find_max_pfn(unsigned long start, unsigned long end, void *arg);
+extern int find_bootmap_location(unsigned long start, unsigned long end, void *arg);
+#endif
 
 /*
  * Note: The macros below rely on the fact that MAX_SWAPFILES_SHIFT <= number of
diff -Naur -X /home/jbarnes/dontdiff linux-2.6.0-test5-ia64/include/asm-ia64/processor.h linux-2.6.0-test5-ia64-sn/include/asm-ia64/processor.h
--- linux-2.6.0-test5-ia64/include/asm-ia64/processor.h	Mon Sep  8 12:50:01 2003
+++ linux-2.6.0-test5-ia64-sn/include/asm-ia64/processor.h	Mon Sep 15 12:19:06 2003
@@ -186,6 +186,8 @@
 #endif
 #ifdef CONFIG_NUMA
 	struct ia64_node_data *node_data;
+	struct cpuinfo_ia64 *cpu_data[NR_CPUS];
+	int nodeid;
 #endif
 };
 
