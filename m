From: jbarnes@sgi.com (Jesse Barnes)
Date: Fri, 08 Aug 2003 22:12:42 +0000
Subject: [PATCH] latest discontig
MIME-Version: 1
Content-Type: multipart/mixed; boundary="SUOF0GtieIMvvwua"
Message-Id: <marc-linux-ia64-106038094128807@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--SUOF0GtieIMvvwua
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

It still needs a lot of cleanup and some bugfixes, but I'm going out on
sabbatical for the next three weeks, so I thought I'd post this patch in
case anyone's interested in running 2.6 on an Altix box.

You'll need to apply this patch and the headless node patch I just sent
out, along with a few others that have already been merged into various
trees but aren't in Linus' tree yet.

This patch is against Linus' bitkeeper tree as of a few hours ago.

Thanks,
Jesse

--SUOF0GtieIMvvwua
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="discontig-2.6.0-test2-bk-2.patch"

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1124  -> 1.1125 
#	include/asm-ia64/page.h	1.19    -> 1.20   
#	arch/ia64/kernel/setup.c	1.55    -> 1.56   
#	include/asm-ia64/pgtable.h	1.28    -> 1.29   
#	arch/ia64/mm/Makefile	1.7     -> 1.8    
#	include/asm-ia64/numa.h	1.5     -> 1.6    
#	include/asm-ia64/processor.h	1.48    -> 1.49   
#	 arch/ia64/mm/init.c	1.47    -> 1.48   
#	include/asm-ia64/nodedata.h	1.3     -> 1.4    
#	include/asm-ia64/percpu.h	1.12    -> 1.13   
#	arch/ia64/mm/discontig.c	1.4     -> 1.5    
#	include/asm-ia64/mmzone.h	1.4     -> 1.5    
#	               (new)	        -> 1.1     arch/ia64/mm/contig.c
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/08/08	jbarnes@tomahawk.engr.sgi.com	1.1125
# discontig
# --------------------------------------------
#
diff -Nru a/arch/ia64/kernel/setup.c b/arch/ia64/kernel/setup.c
--- a/arch/ia64/kernel/setup.c	Fri Aug  8 14:57:24 2003
+++ b/arch/ia64/kernel/setup.c	Fri Aug  8 14:57:24 2003
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
-	if (start == PAGE_OFFSET) {
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
-		if (range_end == end) return 0;
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
-	if (smp_processor_id() == 0) {
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
 
diff -Nru a/arch/ia64/mm/Makefile b/arch/ia64/mm/Makefile
--- a/arch/ia64/mm/Makefile	Fri Aug  8 14:57:24 2003
+++ b/arch/ia64/mm/Makefile	Fri Aug  8 14:57:24 2003
@@ -7,3 +7,6 @@
 obj-$(CONFIG_HUGETLB_PAGE) += hugetlbpage.o
 obj-$(CONFIG_NUMA)	   += numa.o
 obj-$(CONFIG_DISCONTIGMEM) += discontig.o
+ifndef CONFIG_DISCONTIGMEM
+obj-y += contig.o
+endif
diff -Nru a/arch/ia64/mm/contig.c b/arch/ia64/mm/contig.c
--- /dev/null	Wed Dec 31 16:00:00 1969
+++ b/arch/ia64/mm/contig.c	Fri Aug  8 14:57:24 2003
@@ -0,0 +1,131 @@
+/* 
+ * This file is subject to the terms and conditions of the GNU General Public
+ * License.  See the file "COPYING" in the main directory of this archive
+ * for more details.
+ *
+ * Copyright (C) 2003 Silicon Graphics, Inc. All rights reserved.
+ *
+ * Routines used by ia64 machines with contiguous (or apparently contiguous) memory.
+ */
+
+#include <linux/config.h>
+#include <linux/mm.h>
+#include <linux/swap.h>
+#include <linux/bootmem.h>
+#include <asm/sections.h>
+#include <asm/pgtable.h>
+#include <asm/pgalloc.h>
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
+	if (smp_processor_id() == 0) {
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
+
+/**
+ * show_mem - give short summary of memory stats
+ *
+ * Shows a simple page count of reserved and used pages in the system.
+ */
+void show_mem(void)
+{
+	int i, total = 0, reserved = 0;
+	int shared = 0, cached = 0;
+
+	printk("Mem-info:\n");
+	show_free_areas();
+
+	printk("Free swap:       %6dkB\n", nr_swap_pages<<(PAGE_SHIFT-10));
+	i = max_mapnr;
+	while (i-- > 0) {
+		total++;
+		if (PageReserved(mem_map+i))
+			reserved++;
+		else if (PageSwapCache(mem_map+i))
+			cached++;
+		else if (page_count(mem_map + i))
+			shared += page_count(mem_map + i) - 1;
+	}
+	printk("%d pages of RAM\n", total);
+	printk("%d reserved pages\n", reserved);
+	printk("%d pages shared\n", shared);
+	printk("%d pages swap cached\n", cached);
+	printk("%ld pages in page table cache\n", pgtable_cache_size);
+}
+
+unsigned long bootmap_start; /* physical address where the bootmem map is located */
+
+int find_max_pfn(unsigned long start, unsigned long end, void *arg)
+{
+	unsigned long *max_pfnp = arg, pfn;
+
+	pfn = (PAGE_ALIGN(end - 1) - PAGE_OFFSET) >> PAGE_SHIFT;
+	if (pfn > *max_pfnp)
+		*max_pfnp = pfn;
+	return 0;
+}
+
+/*
+ * Find a place to put the bootmap and return its starting address in bootmap_start.
+ * This address must be page-aligned.
+ */
+int find_bootmap_location(unsigned long start, unsigned long end, void *arg)
+{
+	unsigned long needed = *(unsigned long *)arg;
+	unsigned long range_start, range_end, free_start;
+	int i;
+
+#if IGNORE_PFN0
+	if (start == PAGE_OFFSET) {
+		start += PAGE_SIZE;
+		if (start >= end) return 0;
+	}
+#endif
+
+	free_start = PAGE_OFFSET;
+
+	for (i = 0; i < num_rsvd_regions; i++) {
+		range_start = max(start, free_start);
+		range_end   = min(end, rsvd_region[i].start & PAGE_MASK);
+
+		if (range_end <= range_start) continue;	/* skip over empty range */
+
+	       	if (range_end - range_start >= needed) {
+			bootmap_start = __pa(range_start);
+			return 1;	/* done */
+		}
+
+		/* nothing more available in this segment */
+		if (range_end == end) return 0;
+
+		free_start = PAGE_ALIGN(rsvd_region[i].end);
+	}
+	return 0;
+}
diff -Nru a/arch/ia64/mm/discontig.c b/arch/ia64/mm/discontig.c
--- a/arch/ia64/mm/discontig.c	Fri Aug  8 14:57:24 2003
+++ b/arch/ia64/mm/discontig.c	Fri Aug  8 14:57:24 2003
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
-		if (node_cpuid[i].phys_id == hard_smp_processor_id())
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
+		if (node == node_cpuid[cpu].nid)
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
+				if (node == node_cpuid[cpu].nid) {
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
 	if (numnodes == 0) {
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
-		if (startpfn == -1)
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
+	if (smp_processor_id() == 0) {
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
-			if (paddr_to_nid(__pa(kaddr)) == node) {
-				bid = BANK_MEM_MAP_INDEX(kaddr);
-				node_data[mynode]->node_id_map[bid] = node;
-				node_data[mynode]->bank_mem_map_base[bid] = page;
-			}
-			kaddr += BANKSIZE;
-			page += BANKSIZE/PAGE_SIZE;
-		}
+		if ((unsigned long)__va(re) == end)
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
diff -Nru a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
--- a/arch/ia64/mm/init.c	Fri Aug  8 14:57:24 2003
+++ b/arch/ia64/mm/init.c	Fri Aug  8 14:57:24 2003
@@ -42,7 +42,7 @@
 #ifdef CONFIG_VIRTUAL_MEM_MAP
 # define LARGE_GAP	0x40000000	/* Use virtual mem map if hole is > than this */
   unsigned long vmalloc_end = VMALLOC_END_INIT;
-  static struct page *vmem_map;
+  struct page *vmem_map;
   static unsigned long num_dma_physpages;
 #endif
 
@@ -214,58 +214,6 @@
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
@@ -394,6 +342,7 @@
 {
 	unsigned long address, start_page, end_page;
 	struct page *map_start, *map_end;
+	int node;
 	pgd_t *pgd;
 	pmd_t *pmd;
 	pte_t *pte;
@@ -403,19 +352,20 @@
 
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
@@ -428,6 +378,16 @@
 	unsigned long zone;
 };
 
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
 virtual_memmap_init (u64 start, u64 end, void *arg)
 {
@@ -486,16 +446,6 @@
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
@@ -511,102 +461,101 @@
 }
 #endif /* CONFIG_VIRTUAL_MEM_MAP */
 
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
+	if (node == cdata.node) {
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
+		if (numnodes == 1 && max_gap < LARGE_GAP) {
+			/* Just one node with no big holes... */
+			vmem_map = (struct page *)0;
+			zones_size[ZONE_DMA] += cdata.min_pfn;
+			zholes_size[ZONE_DMA] += cdata.min_pfn;
+			free_area_init_node(0, NODE_DATA(node), NODE_DATA(node)->node_mem_map,
+					    zones_size, 0, zholes_size);
+		}
+		else {
+			/* allocate virtual mem_map */
+			if (node == 0) {
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
diff -Nru a/include/asm-ia64/mmzone.h b/include/asm-ia64/mmzone.h
--- a/include/asm-ia64/mmzone.h	Fri Aug  8 14:57:24 2003
+++ b/include/asm-ia64/mmzone.h	Fri Aug  8 14:57:24 2003
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
-
-/*
- * Given a kaddr, this macro return the relative map number 
- * within the bank.
- */
-#define BANK_MAP_NR(kaddr) 	(BANK_OFFSET(kaddr) >> PAGE_SHIFT)
 
-/*
- * Given a pte, this macro returns a pointer to the page struct for the pte.
- */
-#define pte_page(pte)	virt_to_page(PAGE_OFFSET | (pte_val(pte)&_PFN_MASK))
+#ifdef CONFIG_NUMA
 
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
+#define MAX_PHYSNODE_ID	8		/* Maximum node number +1 */
+#define NR_NODES	8		/* Maximum number of nodes in SSI */
+#define NR_MEMBLKS	(NR_NODES * 32)
 
-#define node_localnr(pfn, nid)	((pfn) - NODE_DATA(nid)->node_start_pfn)
 
-#define pfn_to_page(pfn)	(struct page *)(node_mem_map(pfn_to_nid(pfn)) + node_localnr(pfn, pfn_to_nid(pfn)))
 
-#define pfn_to_nid(pfn)		 local_node_data->node_id_map[(pfn << PAGE_SHIFT) >> BANKSHIFT]
-
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
+extern void build_cpu_to_node_map(void);
 
-/*
- * Given a nodeid & a bank number, find the address of the mem_map
- * entry for the first page of the bank.
- */
-#define BANK_MEM_MAP_INDEX(kaddr) \
-	(((unsigned long)(kaddr) & (MAX_PHYS_MEMORY-1)) >> BANKSHIFT)
+#else /* CONFIG_NUMA */
 
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
+#define NR_NODES	1
 
-#endif /* CONFIG_IA64_DIG */
+#endif /* CONFIG_NUMA */
 #endif /* _ASM_IA64_MMZONE_H */
diff -Nru a/include/asm-ia64/nodedata.h b/include/asm-ia64/nodedata.h
--- a/include/asm-ia64/nodedata.h	Fri Aug  8 14:57:24 2003
+++ b/include/asm-ia64/nodedata.h	Fri Aug  8 14:57:24 2003
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
@@ -48,29 +51,5 @@
  */
 extern int boot_get_local_nodeid(void);
 extern struct ia64_node_data *get_node_data_ptr(void);
-
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
 
 #endif /* _ASM_IA64_NODEDATA_H */
diff -Nru a/include/asm-ia64/numa.h b/include/asm-ia64/numa.h
--- a/include/asm-ia64/numa.h	Fri Aug  8 14:57:24 2003
+++ b/include/asm-ia64/numa.h	Fri Aug  8 14:57:24 2003
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
 
@@ -63,6 +71,12 @@
 extern int paddr_to_nid(unsigned long paddr);
 
 #define local_nodeid (cpu_to_node_map[smp_processor_id()])
+
+#else /* !CONFIG_NUMA */
+
+#define node_distance(from,to) 10
+#define paddr_to_nid(x) 0
+#define local_nodeid 0
 
 #endif /* CONFIG_NUMA */
 
diff -Nru a/include/asm-ia64/page.h b/include/asm-ia64/page.h
--- a/include/asm-ia64/page.h	Fri Aug  8 14:57:24 2003
+++ b/include/asm-ia64/page.h	Fri Aug  8 14:57:24 2003
@@ -93,18 +93,26 @@
 
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
+
+#define virt_to_page(kaddr)	(pfn_to_page(__pa(kaddr) >> PAGE_SHIFT))
+#define page_to_phys(page)	(page_to_pfn(page) << PAGE_SHIFT)
 
 typedef union ia64_va {
 	struct {
diff -Nru a/include/asm-ia64/percpu.h b/include/asm-ia64/percpu.h
--- a/include/asm-ia64/percpu.h	Fri Aug  8 14:57:24 2003
+++ b/include/asm-ia64/percpu.h	Fri Aug  8 14:57:24 2003
@@ -46,6 +46,7 @@
 
 extern void percpu_modcopy(void *pcpudst, const void *src, unsigned long size);
 extern void setup_per_cpu_areas (void);
+extern void *per_cpu_init(void);
 
 #else /* ! SMP */
 
diff -Nru a/include/asm-ia64/pgtable.h b/include/asm-ia64/pgtable.h
--- a/include/asm-ia64/pgtable.h	Fri Aug  8 14:57:24 2003
+++ b/include/asm-ia64/pgtable.h	Fri Aug  8 14:57:24 2003
@@ -174,7 +174,6 @@
 	return (addr & (local_cpu_data->unimpl_pa_mask)) == 0;
 }
 
-#ifndef CONFIG_DISCONTIGMEM
 /*
  * kern_addr_valid(ADDR) tests if ADDR is pointing to valid kernel
  * memory.  For the return value to be meaningful, ADDR must be >=
@@ -190,7 +189,6 @@
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
diff -Nru a/include/asm-ia64/processor.h b/include/asm-ia64/processor.h
--- a/include/asm-ia64/processor.h	Fri Aug  8 14:57:24 2003
+++ b/include/asm-ia64/processor.h	Fri Aug  8 14:57:24 2003
@@ -185,6 +185,8 @@
 #endif
 #ifdef CONFIG_NUMA
 	struct ia64_node_data *node_data;
+	struct cpuinfo_ia64 *cpu_data[NR_CPUS];
+	int nodeid;
 #endif
 };
 

--SUOF0GtieIMvvwua--
