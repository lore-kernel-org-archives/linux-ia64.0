From: Christoph Lameter <clameter@sgi.com>
Date: Wed, 13 Feb 2008 20:58:44 +0000
Subject: Old broken patch to remove flatmem/discontig from ia64
Message-Id: <Pine.LNX.4.64.0802131250450.20407@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 13 Feb 2008, Robin Holt wrote:

> If you point me at that patch, I would happily resurrect it and see if
> I can get it worked in.  I will be working on that in the evenings so
> my progress will be slow.

Evenings? Gosh. You are already too busy and we need you in sane 
condition. Maybe someone else. Here is the patch that was never publicized 
and likely will fail if applied to current sources. Lots of work. I asked 
someone else for this before....

Date: Wed, 21 Nov 2007 12:16:28 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] Cast page_to_pfn to unsigned long in CONFIG_SPARSEMEM (fwd)

Could you do the honors of removing flatmem/discontig etc from ia64?

I have a draft of patch here but I am deeply buried in the percpu stuff at 
the moment. So I wont get around to test it soon. Needs testing I think.

Is anyone taking care of cleaning up i386?

---
 arch/ia64/Kconfig                |   35 ----
 arch/ia64/kernel/machine_kexec.c |   10 -
 arch/ia64/mm/Makefile            |    5 
 arch/ia64/mm/contig.c            |  289 ---------------------------------------
 arch/ia64/mm/discontig.c         |   13 -
 arch/ia64/mm/init.c              |    5 
 arch/ia64/mm/numa.c              |    2 
 include/asm-ia64/page.h          |   26 ---
 8 files changed, 5 insertions(+), 380 deletions(-)

Index: linux-2.6/arch/ia64/Kconfig
=================================--- linux-2.6.orig/arch/ia64/Kconfig	2007-11-16 16:21:39.000000000 -0800
+++ linux-2.6/arch/ia64/Kconfig	2007-11-16 16:23:10.000000000 -0800
@@ -352,29 +352,13 @@ source "kernel/Kconfig.preempt"
 
 source "mm/Kconfig"
 
-config ARCH_SELECT_MEMORY_MODEL
-	def_bool y
-
-config ARCH_DISCONTIGMEM_ENABLE
-	def_bool y
-	help
-	  Say Y to support efficient handling of discontiguous physical memory,
-	  for architectures which are either NUMA (Non-Uniform Memory Access)
-	  or have huge holes in the physical address space for other reasons.
- 	  See <file:Documentation/vm/numa> for more.
-
-config ARCH_FLATMEM_ENABLE
+config ARCH_SPARSEMEM_DEFAULT
 	def_bool y
 
 config ARCH_SPARSEMEM_ENABLE
 	def_bool y
-	depends on ARCH_DISCONTIGMEM_ENABLE
 	select SPARSEMEM_VMEMMAP_ENABLE
 
-config ARCH_DISCONTIGMEM_DEFAULT
-	def_bool y if (IA64_SGI_SN2 || IA64_GENERIC || IA64_HP_ZX1 || IA64_HP_ZX1_SWIOTLB)
-	depends on ARCH_DISCONTIGMEM_ENABLE
-
 config NUMA
 	bool "NUMA support"
 	depends on !IA64_HP_SIM && !FLATMEM
@@ -398,23 +382,6 @@ config NODES_SHIFT
 config ARCH_POPULATES_NODE_MAP
 	def_bool y
 
-# VIRTUAL_MEM_MAP and FLAT_NODE_MEM_MAP are functionally equivalent.
-# VIRTUAL_MEM_MAP has been retained for historical reasons.
-config VIRTUAL_MEM_MAP
-	bool "Virtual mem map"
-	depends on !SPARSEMEM
-	default y if !IA64_HP_SIM
-	help
-	  Say Y to compile the kernel with support for a virtual mem map.
-	  This code also only takes effect if a memory hole of greater than
-	  1 Gb is found during boot.  You must turn this option on if you
-	  require the DISCONTIGMEM option for your machine. If you are
-	  unsure, say Y.
-
-config HOLES_IN_ZONE
-	bool
-	default y if VIRTUAL_MEM_MAP
-
 config HAVE_ARCH_EARLY_PFN_TO_NID
 	def_bool y
 	depends on NEED_MULTIPLE_NODES
Index: linux-2.6/arch/ia64/kernel/machine_kexec.c
=================================--- linux-2.6.orig/arch/ia64/kernel/machine_kexec.c	2007-11-16 16:23:52.000000000 -0800
+++ linux-2.6/arch/ia64/kernel/machine_kexec.c	2007-11-16 16:24:03.000000000 -0800
@@ -129,16 +129,6 @@ void machine_kexec(struct kimage *image)
 
 void arch_crash_save_vmcoreinfo(void)
 {
-#if defined(CONFIG_ARCH_DISCONTIGMEM_ENABLE) && defined(CONFIG_NUMA)
-	VMCOREINFO_SYMBOL(pgdat_list);
-	VMCOREINFO_LENGTH(pgdat_list, MAX_NUMNODES);
-
-	VMCOREINFO_SYMBOL(node_memblk);
-	VMCOREINFO_LENGTH(node_memblk, NR_NODE_MEMBLKS);
-	VMCOREINFO_SIZE(node_memblk_s);
-	VMCOREINFO_OFFSET(node_memblk_s, start_paddr);
-	VMCOREINFO_OFFSET(node_memblk_s, size);
-#endif
 #ifdef CONFIG_PGTABLE_3
 	VMCOREINFO_CONFIG(PGTABLE_3);
 #elif  CONFIG_PGTABLE_4
Index: linux-2.6/arch/ia64/mm/Makefile
=================================--- linux-2.6.orig/arch/ia64/mm/Makefile	2007-11-16 16:24:34.000000000 -0800
+++ linux-2.6/arch/ia64/mm/Makefile	2007-11-16 16:25:04.000000000 -0800
@@ -2,10 +2,7 @@
 # Makefile for the ia64-specific parts of the memory manager.
 #
 
-obj-y := init.o fault.o tlb.o extable.o ioremap.o
+obj-y := init.o fault.o tlb.o extable.o ioremap.o discontig.o
 
 obj-$(CONFIG_HUGETLB_PAGE) += hugetlbpage.o
 obj-$(CONFIG_NUMA)	   += numa.o
-obj-$(CONFIG_DISCONTIGMEM) += discontig.o
-obj-$(CONFIG_SPARSEMEM)	   += discontig.o
-obj-$(CONFIG_FLATMEM)	   += contig.o
Index: linux-2.6/arch/ia64/mm/discontig.c
=================================--- linux-2.6.orig/arch/ia64/mm/discontig.c	2007-11-16 16:28:55.000000000 -0800
+++ linux-2.6/arch/ia64/mm/discontig.c	2007-11-16 16:29:27.000000000 -0800
@@ -667,21 +667,10 @@ void __init paging_init(void)
 	sparse_memory_present_with_active_regions(MAX_NUMNODES);
 	sparse_init();
 
-#ifdef CONFIG_VIRTUAL_MEM_MAP
-	vmalloc_end -= PAGE_ALIGN(ALIGN(max_low_pfn, MAX_ORDER_NR_PAGES) *
-		sizeof(struct page));
-	vmem_map = (struct page *) vmalloc_end;
-	efi_memmap_walk(create_mem_map_page_table, NULL);
-	printk("Virtual mem_map starts at 0x%p\n", vmem_map);
-#endif
-
 	for_each_online_node(node) {
 		num_physpages += mem_data[node].num_physpages;
 		pfn_offset = mem_data[node].min_pfn;
 
-#ifdef CONFIG_VIRTUAL_MEM_MAP
-		NODE_DATA(node)->node_mem_map = vmem_map + pfn_offset;
-#endif
 		if (mem_data[node].max_pfn > max_pfn)
 			max_pfn = mem_data[node].max_pfn;
 	}
@@ -716,10 +705,8 @@ void arch_refresh_nodedata(int update_no
 }
 #endif
 
-#ifdef CONFIG_SPARSEMEM_VMEMMAP
 int __meminit vmemmap_populate(struct page *start_page,
 						unsigned long size, int node)
 {
 	return vmemmap_populate_basepages(start_page, size, node);
 }
-#endif
Index: linux-2.6/arch/ia64/mm/init.c
=================================--- linux-2.6.orig/arch/ia64/mm/init.c	2007-11-16 16:26:55.000000000 -0800
+++ linux-2.6/arch/ia64/mm/init.c	2007-11-16 16:38:42.000000000 -0800
@@ -43,13 +43,6 @@ extern void ia64_tlb_init (void);
 
 unsigned long MAX_DMA_ADDRESS = PAGE_OFFSET + 0x100000000UL;
 
-#ifdef CONFIG_VIRTUAL_MEM_MAP
-unsigned long vmalloc_end = VMALLOC_END_INIT;
-EXPORT_SYMBOL(vmalloc_end);
-struct page *vmem_map;
-EXPORT_SYMBOL(vmem_map);
-#endif
-
 struct page *zero_page_memmap_ptr;	/* map entry for zero page */
 EXPORT_SYMBOL(zero_page_memmap_ptr);
 
@@ -369,189 +362,6 @@ ia64_mmu_init (void *my_cpu_data)
 #endif
 }
 
-#ifdef CONFIG_VIRTUAL_MEM_MAP
-int vmemmap_find_next_valid_pfn(int node, int i)
-{
-	unsigned long end_address, hole_next_pfn;
-	unsigned long stop_address;
-	pg_data_t *pgdat = NODE_DATA(node);
-
-	end_address = (unsigned long) &vmem_map[pgdat->node_start_pfn + i];
-	end_address = PAGE_ALIGN(end_address);
-
-	stop_address = (unsigned long) &vmem_map[
-		pgdat->node_start_pfn + pgdat->node_spanned_pages];
-
-	do {
-		pgd_t *pgd;
-		pud_t *pud;
-		pmd_t *pmd;
-		pte_t *pte;
-
-		pgd = pgd_offset_k(end_address);
-		if (pgd_none(*pgd)) {
-			end_address += PGDIR_SIZE;
-			continue;
-		}
-
-		pud = pud_offset(pgd, end_address);
-		if (pud_none(*pud)) {
-			end_address += PUD_SIZE;
-			continue;
-		}
-
-		pmd = pmd_offset(pud, end_address);
-		if (pmd_none(*pmd)) {
-			end_address += PMD_SIZE;
-			continue;
-		}
-
-		pte = pte_offset_kernel(pmd, end_address);
-retry_pte:
-		if (pte_none(*pte)) {
-			end_address += PAGE_SIZE;
-			pte++;
-			if ((end_address < stop_address) &&
-			    (end_address != ALIGN(end_address, 1UL << PMD_SHIFT)))
-				goto retry_pte;
-			continue;
-		}
-		/* Found next valid vmem_map page */
-		break;
-	} while (end_address < stop_address);
-
-	end_address = min(end_address, stop_address);
-	end_address = end_address - (unsigned long) vmem_map + sizeof(struct page) - 1;
-	hole_next_pfn = end_address / sizeof(struct page);
-	return hole_next_pfn - pgdat->node_start_pfn;
-}
-
-int __init
-create_mem_map_page_table (u64 start, u64 end, void *arg)
-{
-	unsigned long address, start_page, end_page;
-	struct page *map_start, *map_end;
-	int node;
-	pgd_t *pgd;
-	pud_t *pud;
-	pmd_t *pmd;
-	pte_t *pte;
-
-	map_start = vmem_map + (__pa(start) >> PAGE_SHIFT);
-	map_end   = vmem_map + (__pa(end) >> PAGE_SHIFT);
-
-	start_page = (unsigned long) map_start & PAGE_MASK;
-	end_page = PAGE_ALIGN((unsigned long) map_end);
-	node = paddr_to_nid(__pa(start));
-
-	for (address = start_page; address < end_page; address += PAGE_SIZE) {
-		pgd = pgd_offset_k(address);
-		if (pgd_none(*pgd))
-			pgd_populate(&init_mm, pgd, alloc_bootmem_pages_node(NODE_DATA(node), PAGE_SIZE));
-		pud = pud_offset(pgd, address);
-
-		if (pud_none(*pud))
-			pud_populate(&init_mm, pud, alloc_bootmem_pages_node(NODE_DATA(node), PAGE_SIZE));
-		pmd = pmd_offset(pud, address);
-
-		if (pmd_none(*pmd))
-			pmd_populate_kernel(&init_mm, pmd, alloc_bootmem_pages_node(NODE_DATA(node), PAGE_SIZE));
-		pte = pte_offset_kernel(pmd, address);
-
-		if (pte_none(*pte))
-			set_pte(pte, pfn_pte(__pa(alloc_bootmem_pages_node(NODE_DATA(node), PAGE_SIZE)) >> PAGE_SHIFT,
-					     PAGE_KERNEL));
-	}
-	return 0;
-}
-
-struct memmap_init_callback_data {
-	struct page *start;
-	struct page *end;
-	int nid;
-	unsigned long zone;
-};
-
-static int __meminit
-virtual_memmap_init (u64 start, u64 end, void *arg)
-{
-	struct memmap_init_callback_data *args;
-	struct page *map_start, *map_end;
-
-	args = (struct memmap_init_callback_data *) arg;
-	map_start = vmem_map + (__pa(start) >> PAGE_SHIFT);
-	map_end   = vmem_map + (__pa(end) >> PAGE_SHIFT);
-
-	if (map_start < args->start)
-		map_start = args->start;
-	if (map_end > args->end)
-		map_end = args->end;
-
-	/*
-	 * We have to initialize "out of bounds" struct page elements that fit completely
-	 * on the same pages that were allocated for the "in bounds" elements because they
-	 * may be referenced later (and found to be "reserved").
-	 */
-	map_start -= ((unsigned long) map_start & (PAGE_SIZE - 1)) / sizeof(struct page);
-	map_end += ((PAGE_ALIGN((unsigned long) map_end) - (unsigned long) map_end)
-		    / sizeof(struct page));
-
-	if (map_start < map_end)
-		memmap_init_zone((unsigned long)(map_end - map_start),
-				 args->nid, args->zone, page_to_pfn(map_start),
-				 MEMMAP_EARLY);
-	return 0;
-}
-
-void __meminit
-memmap_init (unsigned long size, int nid, unsigned long zone,
-	     unsigned long start_pfn)
-{
-	if (!vmem_map)
-		memmap_init_zone(size, nid, zone, start_pfn, MEMMAP_EARLY);
-	else {
-		struct page *start;
-		struct memmap_init_callback_data args;
-
-		start = pfn_to_page(start_pfn);
-		args.start = start;
-		args.end = start + size;
-		args.nid = nid;
-		args.zone = zone;
-
-		efi_memmap_walk(virtual_memmap_init, &args);
-	}
-}
-
-int
-ia64_pfn_valid (unsigned long pfn)
-{
-	char byte;
-	struct page *pg = pfn_to_page(pfn);
-
-	return     (__get_user(byte, (char __user *) pg) = 0)
-		&& ((((u64)pg & PAGE_MASK) = (((u64)(pg + 1) - 1) & PAGE_MASK))
-			|| (__get_user(byte, (char __user *) (pg + 1) - 1) = 0));
-}
-EXPORT_SYMBOL(ia64_pfn_valid);
-
-int __init
-find_largest_hole (u64 start, u64 end, void *arg)
-{
-	u64 *max_gap = arg;
-
-	static u64 last_end = PAGE_OFFSET;
-
-	/* NOTE: this algorithm assumes efi memmap table is ordered */
-
-	if (*max_gap < (start - last_end))
-		*max_gap = start - last_end;
-	last_end = end;
-	return 0;
-}
-
-#endif /* CONFIG_VIRTUAL_MEM_MAP */
-
 int __init
 register_active_ranges(u64 start, u64 end, void *arg)
 {
@@ -589,13 +399,8 @@ int
 find_max_min_low_pfn (unsigned long start, unsigned long end, void *arg)
 {
 	unsigned long pfn_start, pfn_end;
-#ifdef CONFIG_FLATMEM
-	pfn_start = (PAGE_ALIGN(__pa(start))) >> PAGE_SHIFT;
-	pfn_end = (PAGE_ALIGN(__pa(end - 1))) >> PAGE_SHIFT;
-#else
 	pfn_start = GRANULEROUNDDOWN(__pa(start)) >> PAGE_SHIFT;
 	pfn_end = GRANULEROUNDUP(__pa(end - 1)) >> PAGE_SHIFT;
-#endif
 	min_low_pfn = min(min_low_pfn, pfn_start);
 	max_low_pfn = max(max_low_pfn, pfn_end);
 	return 0;
Index: linux-2.6/arch/ia64/mm/numa.c
=================================--- linux-2.6.orig/arch/ia64/mm/numa.c	2007-11-16 16:29:34.000000000 -0800
+++ linux-2.6/arch/ia64/mm/numa.c	2007-11-16 16:30:00.000000000 -0800
@@ -48,7 +48,7 @@ paddr_to_nid(unsigned long paddr)
 	return (i < num_node_memblks) ? node_memblk[i].nid : (num_node_memblks ? -1 : 0);
 }
 
-#if defined(CONFIG_SPARSEMEM) && defined(CONFIG_NUMA)
+#ifdef CONFIG_NUMA
 /*
  * Because of holes evaluate on section limits.
  * If the section of memory exists, then return the node where the section
Index: linux-2.6/include/asm-ia64/page.h
=================================--- linux-2.6.orig/include/asm-ia64/page.h	2007-11-16 16:25:31.000000000 -0800
+++ linux-2.6/include/asm-ia64/page.h	2007-11-16 16:26:23.000000000 -0800
@@ -100,31 +100,9 @@ do {						\
 
 #define virt_addr_valid(kaddr)	pfn_valid(__pa(kaddr) >> PAGE_SHIFT)
 
-#ifdef CONFIG_VIRTUAL_MEM_MAP
-extern int ia64_pfn_valid (unsigned long pfn);
-#else
-# define ia64_pfn_valid(pfn) 1
-#endif
+#define ia64_pfn_valid(pfn) 1
 
-#ifdef CONFIG_VIRTUAL_MEM_MAP
-extern struct page *vmem_map;
-#ifdef CONFIG_DISCONTIGMEM
-# define page_to_pfn(page)	((unsigned long) (page - vmem_map))
-# define pfn_to_page(pfn)	(vmem_map + (pfn))
-#else
-# include <asm-generic/memory_model.h>
-#endif
-#else
-# include <asm-generic/memory_model.h>
-#endif
-
-#ifdef CONFIG_FLATMEM
-# define pfn_valid(pfn)		(((pfn) < max_mapnr) && ia64_pfn_valid(pfn))
-#elif defined(CONFIG_DISCONTIGMEM)
-extern unsigned long min_low_pfn;
-extern unsigned long max_low_pfn;
-# define pfn_valid(pfn)		(((pfn) >= min_low_pfn) && ((pfn) < max_low_pfn) && ia64_pfn_valid(pfn))
-#endif
+#include <asm-generic/memory_model.h>
 
 #define page_to_phys(page)	(page_to_pfn(page) << PAGE_SHIFT)
 #define virt_to_page(kaddr)	pfn_to_page(__pa(kaddr) >> PAGE_SHIFT)
Index: linux-2.6/arch/ia64/mm/contig.c
=================================--- linux-2.6.orig/arch/ia64/mm/contig.c	2007-11-16 16:31:19.000000000 -0800
+++ /dev/null	1970-01-01 00:00:00.000000000 +0000
@@ -1,289 +0,0 @@
-/*
- * This file is subject to the terms and conditions of the GNU General Public
- * License.  See the file "COPYING" in the main directory of this archive
- * for more details.
- *
- * Copyright (C) 1998-2003 Hewlett-Packard Co
- *	David Mosberger-Tang <davidm@hpl.hp.com>
- *	Stephane Eranian <eranian@hpl.hp.com>
- * Copyright (C) 2000, Rohit Seth <rohit.seth@intel.com>
- * Copyright (C) 1999 VA Linux Systems
- * Copyright (C) 1999 Walt Drummond <drummond@valinux.com>
- * Copyright (C) 2003 Silicon Graphics, Inc. All rights reserved.
- *
- * Routines used by ia64 machines with contiguous (or virtually contiguous)
- * memory.
- */
-#include <linux/bootmem.h>
-#include <linux/efi.h>
-#include <linux/mm.h>
-#include <linux/nmi.h>
-#include <linux/swap.h>
-
-#include <asm/meminit.h>
-#include <asm/pgalloc.h>
-#include <asm/pgtable.h>
-#include <asm/sections.h>
-#include <asm/mca.h>
-
-#ifdef CONFIG_VIRTUAL_MEM_MAP
-static unsigned long max_gap;
-#endif
-
-/**
- * show_mem - give short summary of memory stats
- *
- * Shows a simple page count of reserved and used pages in the system.
- * For discontig machines, it does this on a per-pgdat basis.
- */
-void show_mem(void)
-{
-	int i, total_reserved = 0;
-	int total_shared = 0, total_cached = 0;
-	unsigned long total_present = 0;
-	pg_data_t *pgdat;
-
-	printk(KERN_INFO "Mem-info:\n");
-	show_free_areas();
-	printk(KERN_INFO "Free swap:       %6ldkB\n",
-	       nr_swap_pages<<(PAGE_SHIFT-10));
-	printk(KERN_INFO "Node memory in pages:\n");
-	for_each_online_pgdat(pgdat) {
-		unsigned long present;
-		unsigned long flags;
-		int shared = 0, cached = 0, reserved = 0;
-
-		pgdat_resize_lock(pgdat, &flags);
-		present = pgdat->node_present_pages;
-		for(i = 0; i < pgdat->node_spanned_pages; i++) {
-			struct page *page;
-			if (unlikely(i % MAX_ORDER_NR_PAGES = 0))
-				touch_nmi_watchdog();
-			if (pfn_valid(pgdat->node_start_pfn + i))
-				page = pfn_to_page(pgdat->node_start_pfn + i);
-			else {
-#ifdef CONFIG_VIRTUAL_MEM_MAP
-				if (max_gap < LARGE_GAP)
-					continue;
-#endif
-				i = vmemmap_find_next_valid_pfn(pgdat->node_id,
-					 i) - 1;
-				continue;
-			}
-			if (PageReserved(page))
-				reserved++;
-			else if (PageSwapCache(page))
-				cached++;
-			else if (page_count(page))
-				shared += page_count(page)-1;
-		}
-		pgdat_resize_unlock(pgdat, &flags);
-		total_present += present;
-		total_reserved += reserved;
-		total_cached += cached;
-		total_shared += shared;
-		printk(KERN_INFO "Node %4d:  RAM: %11ld, rsvd: %8d, "
-		       "shrd: %10d, swpd: %10d\n", pgdat->node_id,
-		       present, reserved, shared, cached);
-	}
-	printk(KERN_INFO "%ld pages of RAM\n", total_present);
-	printk(KERN_INFO "%d reserved pages\n", total_reserved);
-	printk(KERN_INFO "%d pages shared\n", total_shared);
-	printk(KERN_INFO "%d pages swap cached\n", total_cached);
-	printk(KERN_INFO "Total of %ld pages in page table cache\n",
-	       quicklist_total_size());
-	printk(KERN_INFO "%d free buffer pages\n", nr_free_buffer_pages());
-}
-
-
-/* physical address where the bootmem map is located */
-unsigned long bootmap_start;
-
-/**
- * find_bootmap_location - callback to find a memory area for the bootmap
- * @start: start of region
- * @end: end of region
- * @arg: unused callback data
- *
- * Find a place to put the bootmap and return its starting address in
- * bootmap_start.  This address must be page-aligned.
- */
-static int __init
-find_bootmap_location (unsigned long start, unsigned long end, void *arg)
-{
-	unsigned long needed = *(unsigned long *)arg;
-	unsigned long range_start, range_end, free_start;
-	int i;
-
-#if IGNORE_PFN0
-	if (start = PAGE_OFFSET) {
-		start += PAGE_SIZE;
-		if (start >= end)
-			return 0;
-	}
-#endif
-
-	free_start = PAGE_OFFSET;
-
-	for (i = 0; i < num_rsvd_regions; i++) {
-		range_start = max(start, free_start);
-		range_end   = min(end, rsvd_region[i].start & PAGE_MASK);
-
-		free_start = PAGE_ALIGN(rsvd_region[i].end);
-
-		if (range_end <= range_start)
-			continue; /* skip over empty range */
-
-		if (range_end - range_start >= needed) {
-			bootmap_start = __pa(range_start);
-			return -1;	/* done */
-		}
-
-		/* nothing more available in this segment */
-		if (range_end = end)
-			return 0;
-	}
-	return 0;
-}
-
-#ifdef CONFIG_SMP
-static void *cpu_data;
-/**
- * per_cpu_init - setup per-cpu variables
- *
- * Allocate and setup per-cpu data areas.
- */
-void * __cpuinit
-per_cpu_init (void)
-{
-	int cpu;
-	static int first_time=1;
-
-	/*
-	 * get_free_pages() cannot be used before cpu_init() done.  BSP
-	 * allocates "NR_CPUS" pages for all CPUs to avoid that AP calls
-	 * get_zeroed_page().
-	 */
-	if (first_time) {
-		first_time=0;
-		for (cpu = 0; cpu < NR_CPUS; cpu++) {
-			memcpy(cpu_data, __phys_per_cpu_start, __per_cpu_end - __per_cpu_start);
-			__per_cpu_offset[cpu] = (char *) cpu_data - __per_cpu_start;
-			cpu_data += PERCPU_PAGE_SIZE;
-			per_cpu(local_per_cpu_offset, cpu) = __per_cpu_offset[cpu];
-		}
-	}
-	return __per_cpu_start + __per_cpu_offset[smp_processor_id()];
-}
-
-static inline void
-alloc_per_cpu_data(void)
-{
-	cpu_data = __alloc_bootmem(PERCPU_PAGE_SIZE * NR_CPUS,
-				   PERCPU_PAGE_SIZE, __pa(MAX_DMA_ADDRESS));
-}
-#else
-#define alloc_per_cpu_data() do { } while (0)
-#endif /* CONFIG_SMP */
-
-/**
- * find_memory - setup memory map
- *
- * Walk the EFI memory map and find usable memory for the system, taking
- * into account reserved areas.
- */
-void __init
-find_memory (void)
-{
-	unsigned long bootmap_size;
-
-	reserve_memory();
-
-	/* first find highest page frame number */
-	min_low_pfn = ~0UL;
-	max_low_pfn = 0;
-	efi_memmap_walk(find_max_min_low_pfn, NULL);
-	max_pfn = max_low_pfn;
-	/* how many bytes to cover all the pages */
-	bootmap_size = bootmem_bootmap_pages(max_pfn) << PAGE_SHIFT;
-
-	/* look for a location to hold the bootmap */
-	bootmap_start = ~0UL;
-	efi_memmap_walk(find_bootmap_location, &bootmap_size);
-	if (bootmap_start = ~0UL)
-		panic("Cannot find %ld bytes for bootmap\n", bootmap_size);
-
-	bootmap_size = init_bootmem_node(NODE_DATA(0),
-			(bootmap_start >> PAGE_SHIFT), 0, max_pfn);
-
-	/* Free all available memory, then mark bootmem-map as being in use. */
-	efi_memmap_walk(filter_rsvd_memory, free_bootmem);
-	reserve_bootmem(bootmap_start, bootmap_size);
-
-	find_initrd();
-
-	alloc_per_cpu_data();
-}
-
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
-void __init
-paging_init (void)
-{
-	unsigned long max_dma;
-	unsigned long max_zone_pfns[MAX_NR_ZONES];
-
-	num_physpages = 0;
-	efi_memmap_walk(count_pages, &num_physpages);
-
-	memset(max_zone_pfns, 0, sizeof(max_zone_pfns));
-#ifdef CONFIG_ZONE_DMA
-	max_dma = virt_to_phys((void *) MAX_DMA_ADDRESS) >> PAGE_SHIFT;
-	max_zone_pfns[ZONE_DMA] = max_dma;
-#endif
-	max_zone_pfns[ZONE_NORMAL] = max_low_pfn;
-
-#ifdef CONFIG_VIRTUAL_MEM_MAP
-	efi_memmap_walk(register_active_ranges, NULL);
-	efi_memmap_walk(find_largest_hole, (u64 *)&max_gap);
-	if (max_gap < LARGE_GAP) {
-		vmem_map = (struct page *) 0;
-		free_area_init_nodes(max_zone_pfns);
-	} else {
-		unsigned long map_size;
-
-		/* allocate virtual_mem_map */
-
-		map_size = PAGE_ALIGN(ALIGN(max_low_pfn, MAX_ORDER_NR_PAGES) *
-			sizeof(struct page));
-		vmalloc_end -= map_size;
-		vmem_map = (struct page *) vmalloc_end;
-		efi_memmap_walk(create_mem_map_page_table, NULL);
-
-		/*
-		 * alloc_node_mem_map makes an adjustment for mem_map
-		 * which isn't compatible with vmem_map.
-		 */
-		NODE_DATA(0)->node_mem_map = vmem_map +
-			find_min_pfn_with_active_regions();
-		free_area_init_nodes(max_zone_pfns);
-
-		printk("Virtual mem_map starts at 0x%p\n", mem_map);
-	}
-#else /* !CONFIG_VIRTUAL_MEM_MAP */
-	add_active_range(0, 0, max_low_pfn);
-	free_area_init_nodes(max_zone_pfns);
-#endif /* !CONFIG_VIRTUAL_MEM_MAP */
-	zero_page_memmap_ptr = virt_to_page(ia64_imva(empty_zero_page));
-}
Index: linux-2.6/include/asm-ia64/meminit.h
=================================--- linux-2.6.orig/include/asm-ia64/meminit.h	2007-11-16 16:35:11.000000000 -0800
+++ linux-2.6/include/asm-ia64/meminit.h	2007-11-16 16:35:27.000000000 -0800
@@ -58,17 +58,4 @@ extern int reserve_elfcorehdr(unsigned l
 
 extern int register_active_ranges(u64 start, u64 end, void *arg);
 
-#ifdef CONFIG_VIRTUAL_MEM_MAP
-# define LARGE_GAP	0x40000000 /* Use virtual mem map if hole is > than this */
-  extern unsigned long vmalloc_end;
-  extern struct page *vmem_map;
-  extern int find_largest_hole (u64 start, u64 end, void *arg);
-  extern int create_mem_map_page_table (u64 start, u64 end, void *arg);
-  extern int vmemmap_find_next_valid_pfn(int, int);
-#else
-static inline int vmemmap_find_next_valid_pfn(int node, int i)
-{
-	return i + 1;
-}
-#endif
 #endif /* meminit_h */
Index: linux-2.6/include/asm-ia64/pgtable.h
=================================--- linux-2.6.orig/include/asm-ia64/pgtable.h	2007-11-16 16:35:32.000000000 -0800
+++ linux-2.6/include/asm-ia64/pgtable.h	2007-11-16 16:43:27.000000000 -0800
@@ -245,9 +245,8 @@ ia64_phys_addr_valid (unsigned long addr
 #define VMALLOC_START		(RGN_BASE(RGN_GATE) + 0x200000000UL)
 #define VMALLOC_END_INIT	(RGN_BASE(RGN_GATE) + (1UL << (4*PAGE_SHIFT - 10)))
 #define VMALLOC_END		VMALLOC_END_INIT
-#define vmemmap			((struct page *)VMALLOC_END)
-
 #define CPU_AREA_BASE		(RGN_BASE(RGN_GATE) + (3UL << (4*PAGE_SHIFT - 11)))
+#define vmemmap			((struct page *)VMALLOC_END)
 
 /* fs/proc/kcore.c */
 #define	kc_vaddr_to_offset(v) ((v) - RGN_BASE(RGN_GATE))
@@ -569,14 +568,7 @@ extern struct page *zero_page_memmap_ptr
 })
 #endif
 
-#  ifdef CONFIG_VIRTUAL_MEM_MAP
-  /* arch mem_map init routine is needed due to holes in a virtual mem_map */
-#   define __HAVE_ARCH_MEMMAP_INIT
-    extern void memmap_init (unsigned long size, int nid, unsigned long zone,
-			     unsigned long start_pfn);
-#  endif /* CONFIG_VIRTUAL_MEM_MAP */
 # endif /* !__ASSEMBLY__ */
-
 /*
  * Identity-mapped regions use a large page size.  We'll call such large pages
  * "granules".  If you can think of a better name that's unambiguous, let me
Index: linux-2.6/arch/ia64/mm/fault.c
=================================--- linux-2.6.orig/arch/ia64/mm/fault.c	2007-11-16 16:38:59.000000000 -0800
+++ linux-2.6/arch/ia64/mm/fault.c	2007-11-16 16:39:25.000000000 -0800
@@ -91,7 +91,6 @@ ia64_do_page_fault (unsigned long addres
 	if (in_atomic() || !mm)
 		goto no_context;
 
-#ifdef CONFIG_VIRTUAL_MEM_MAP
 	/*
 	 * If fault is in region 5 and we are in the kernel, we may already
 	 * have the mmap_sem (pfn_valid macro is called during mmap). There
@@ -101,7 +100,6 @@ ia64_do_page_fault (unsigned long addres
 
 	if ((REGION_NUMBER(address) = 5) && !user_mode(regs))
 		goto bad_area_no_up;
-#endif
 
 	/*
 	 * This is to handle the kprobes on user space access instructions
@@ -205,9 +203,7 @@ ia64_do_page_fault (unsigned long addres
 
   bad_area:
 	up_read(&mm->mmap_sem);
-#ifdef CONFIG_VIRTUAL_MEM_MAP
   bad_area_no_up:
-#endif
 	if ((isr & IA64_ISR_SP)
 	    || ((isr & IA64_ISR_NA) && (isr & IA64_ISR_CODE_MASK) = IA64_ISR_CODE_LFETCH))
 	{
