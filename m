From: jbarnes@sgi.com (Jesse Barnes)
Date: Tue, 23 Sep 2003 17:07:52 +0000
Subject: Re: [PATCH] split contig and discontig functions
Message-Id: <marc-linux-ia64-106433721132752@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106428053212055@msgid-missing>
In-Reply-To: <marc-linux-ia64-106428053212055@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Oops, I forgot to make meminit.h protect against multiple inclusion and
there are some other minor formatting stuff that I missed.  I'll post
another patch shortly.

Jesse

On Mon, Sep 22, 2003 at 06:28:23PM -0700, Jesse Barnes wrote:
> This patch mostly shuffles around code and creates two new files:
> contig.c and meminit.h.  The former contains functions contiguous and
> virtually contiguous machines while the latter has prototypes and
> declarations for stuff used in contig.c, discontig.c, setup.c, etc.  I
> put meminit.h in include/asm-ia64 since it's used by files in both
> arch/ia64/kernel and arch/ia64/mm.
> 
> Oddly, CONFIG_DISCONTIGMEM wasn't compiling at all :).  That's now fixed
> under this scheme, though the incompatibility between
> CONFIG_DISCONTIGMEM and CONFIG_VIRTUAL_MEMMAP remains.  I'll take care
> of that with another patch later.
> 
> Also, a few people have mailed me with suggestions on how to deal with
> the ifndef CONFIG_DISCONTIGMEM in arch/ia64/mm/Makefile differently, but
> none of them have worked so far and what's there seems pretty clear to
> me.
> 
>  arch/ia64/kernel/setup.c   |  174 ++++-----------------------------------------
>  arch/ia64/mm/Makefile      |    3 
>  arch/ia64/mm/contig.c      |  157 ++++++++++++++++++++++++++++++++++++++++
>  arch/ia64/mm/discontig.c   |   83 +++++++++++++++++++--
>  arch/ia64/mm/init.c        |   52 -------------
>  include/asm-ia64/meminit.h |   38 +++++++++
>  include/asm-ia64/numa.h    |    3 
> 
> Thanks,
> Jesse
> 
> 
> diff -Nru a/arch/ia64/kernel/setup.c b/arch/ia64/kernel/setup.c
> --- a/arch/ia64/kernel/setup.c	Mon Sep 22 18:23:36 2003
> +++ b/arch/ia64/kernel/setup.c	Mon Sep 22 18:23:36 2003
> @@ -45,6 +45,7 @@
>  #include <asm/smp.h>
>  #include <asm/system.h>
>  #include <asm/unistd.h>
> +#include <asm/meminit.h>
>  
>  #if defined(CONFIG_SMP) && (IA64_CPU_SIZE > PAGE_SIZE)
>  # error "struct cpuinfo_ia64 too big!"
> @@ -84,90 +85,11 @@
>  char saved_command_line[COMMAND_LINE_SIZE]; /* used in proc filesystem */
>  
>  /*
> - * Entries defined so far:
> - * 	- boot param structure itself
> - * 	- memory map
> - * 	- initrd (optional)
> - * 	- command line string
> - * 	- kernel code & data
> - *
> - * More could be added if necessary
> - */
> -#define IA64_MAX_RSVD_REGIONS 5
> -
> -struct rsvd_region {
> -	unsigned long start;	/* virtual address of beginning of element */
> -	unsigned long end;	/* virtual address of end of element + 1 */
> -};
> -
> -/*
>   * We use a special marker for the end of memory and it uses the extra (+1) slot
>   */
> -static struct rsvd_region rsvd_region[IA64_MAX_RSVD_REGIONS + 1];
> -static int num_rsvd_regions;
> +struct rsvd_region rsvd_region[IA64_MAX_RSVD_REGIONS + 1];
> +int num_rsvd_regions;
>  
> -#define IGNORE_PFN0	1	/* XXX fix me: ignore pfn 0 until TLB miss handler is updated... */
> -
> -#ifndef CONFIG_DISCONTIGMEM
> -
> -static unsigned long bootmap_start; /* physical address where the bootmem map is located */
> -
> -static int
> -find_max_pfn (unsigned long start, unsigned long end, void *arg)
> -{
> -	unsigned long *max_pfnp = arg, pfn;
> -
> -	pfn = (PAGE_ALIGN(end - 1) - PAGE_OFFSET) >> PAGE_SHIFT;
> -	if (pfn > *max_pfnp)
> -		*max_pfnp = pfn;
> -	return 0;
> -}
> -
> -#else /* CONFIG_DISCONTIGMEM */
> -
> -/*
> - * efi_memmap_walk() knows nothing about layout of memory across nodes. Find
> - * out to which node a block of memory belongs.  Ignore memory that we cannot
> - * identify, and split blocks that run across multiple nodes.
> - *
> - * Take this opportunity to round the start address up and the end address
> - * down to page boundaries.
> - */
> -void
> -call_pernode_memory (unsigned long start, unsigned long end, void *arg)
> -{
> -	unsigned long rs, re;
> -	void (*func)(unsigned long, unsigned long, int, int);
> -	int i;
> -
> -	start = PAGE_ALIGN(start);
> -	end &= PAGE_MASK;
> -	if (start >= end)
> -		return;
> -
> -	func = arg;
> -
> -	if (!num_memblks) {
> -		/*
> -		 * This machine doesn't have SRAT, so call func with
> -		 * nid=0, bank=0.
> -		 */
> -		if (start < end)
> -			(*func)(start, end - start, 0, 0);
> -		return;
> -	}
> -
> -	for (i = 0; i < num_memblks; i++) {
> -		rs = max(start, node_memblk[i].start_paddr);
> -		re = min(end, node_memblk[i].start_paddr+node_memblk[i].size);
> -
> -		if (rs < re)
> -			(*func)(rs, re-rs, node_memblk[i].nid,
> -				node_memblk[i].bank);
> -	}
> -}
> -
> -#endif /* CONFIG_DISCONTIGMEM */
>  
>  /*
>   * Filter incoming memory segments based on the primitive map created from the boot
> @@ -215,48 +137,6 @@
>  	return 0;
>  }
>  
> -
> -#ifndef CONFIG_DISCONTIGMEM
> -/*
> - * Find a place to put the bootmap and return its starting address in bootmap_start.
> - * This address must be page-aligned.
> - */
> -static int
> -find_bootmap_location (unsigned long start, unsigned long end, void *arg)
> -{
> -	unsigned long needed = *(unsigned long *)arg;
> -	unsigned long range_start, range_end, free_start;
> -	int i;
> -
> -#if IGNORE_PFN0
> -	if (start = PAGE_OFFSET) {
> -		start += PAGE_SIZE;
> -		if (start >= end) return 0;
> -	}
> -#endif
> -
> -	free_start = PAGE_OFFSET;
> -
> -	for (i = 0; i < num_rsvd_regions; i++) {
> -		range_start = max(start, free_start);
> -		range_end   = min(end, rsvd_region[i].start & PAGE_MASK);
> -
> -		if (range_end <= range_start) continue;	/* skip over empty range */
> -
> -	       	if (range_end - range_start >= needed) {
> -			bootmap_start = __pa(range_start);
> -			return 1;	/* done */
> -		}
> -
> -		/* nothing more available in this segment */
> -		if (range_end = end) return 0;
> -
> -		free_start = PAGE_ALIGN(rsvd_region[i].end);
> -	}
> -	return 0;
> -}
> -#endif /* !CONFIG_DISCONTIGMEM */
> -
>  static void
>  sort_regions (struct rsvd_region *rsvd_region, int max)
>  {
> @@ -275,10 +155,14 @@
>  	}
>  }
>  
> -static void
> -find_memory (void)
> +/**
> + * reserve_memory - setup reserved memory areas
> + *
> + * Setup the reserved memory areas set aside for the boot parameters, initrd,
> + * etc.
> + */
> +void reserve_memory (void)
>  {
> -	unsigned long bootmap_size;
>  	int n = 0;
>  
>  	/*
> @@ -317,36 +201,16 @@
>  	num_rsvd_regions = n;
>  
>  	sort_regions(rsvd_region, num_rsvd_regions);
> +}
>  
> -#ifdef CONFIG_DISCONTIGMEM
> -	{
> -		extern void discontig_mem_init (void);
> -
> -		bootmap_size = max_pfn = 0;	/* stop gcc warnings */
> -		discontig_mem_init();
> -	}
> -#else /* !CONFIG_DISCONTIGMEM */
> -
> -	/* first find highest page frame number */
> -	max_pfn = 0;
> -	efi_memmap_walk(find_max_pfn, &max_pfn);
> -
> -	/* how many bytes to cover all the pages */
> -	bootmap_size = bootmem_bootmap_pages(max_pfn) << PAGE_SHIFT;
> -
> -	/* look for a location to hold the bootmap */
> -	bootmap_start = ~0UL;
> -	efi_memmap_walk(find_bootmap_location, &bootmap_size);
> -	if (bootmap_start = ~0UL)
> -		panic("Cannot find %ld bytes for bootmap\n", bootmap_size);
> -
> -	bootmap_size = init_bootmem(bootmap_start >> PAGE_SHIFT, max_pfn);
> -
> -	/* Free all available memory, then mark bootmem-map as being in use.  */
> -	efi_memmap_walk(filter_rsvd_memory, free_bootmem);
> -	reserve_bootmem(bootmap_start, bootmap_size);
> -#endif /* !CONFIG_DISCONTIGMEM */
> -
> +/**
> + * find_initrd - get initrd parameters from the boot parameter structure
> + *
> + * Grab the initrd start and end from the boot parameter struct given us by
> + * the boot loader.
> + */
> +void find_initrd(void)
> +{
>  #ifdef CONFIG_BLK_DEV_INITRD
>  	if (ia64_boot_param->initrd_start) {
>  		initrd_start = (unsigned long)__va(ia64_boot_param->initrd_start);
> diff -Nru a/arch/ia64/mm/Makefile b/arch/ia64/mm/Makefile
> --- a/arch/ia64/mm/Makefile	Mon Sep 22 18:23:36 2003
> +++ b/arch/ia64/mm/Makefile	Mon Sep 22 18:23:36 2003
> @@ -7,3 +7,6 @@
>  obj-$(CONFIG_HUGETLB_PAGE) += hugetlbpage.o
>  obj-$(CONFIG_NUMA)	   += numa.o
>  obj-$(CONFIG_DISCONTIGMEM) += discontig.o
> +ifndef CONFIG_DISCONTIGMEM
> +obj-y += contig.o
> +endif
> diff -Nru a/arch/ia64/mm/contig.c b/arch/ia64/mm/contig.c
> --- /dev/null	Wed Dec 31 16:00:00 1969
> +++ b/arch/ia64/mm/contig.c	Mon Sep 22 18:23:36 2003
> @@ -0,0 +1,157 @@
> +/* 
> + * This file is subject to the terms and conditions of the GNU General Public
> + * License.  See the file "COPYING" in the main directory of this archive
> + * for more details.
> + *
> + * Copyright (C) 1998-2003 Hewlett-Packard Co
> + *	David Mosberger-Tang <davidm@hpl.hp.com>
> + *	Stephane Eranian <eranian@hpl.hp.com>
> + * Copyright (C) 2000, Rohit Seth <rohit.seth@intel.com>
> + * Copyright (C) 1999 VA Linux Systems
> + * Copyright (C) 1999 Walt Drummond <drummond@valinux.com>
> + * Copyright (C) 2003 Silicon Graphics, Inc. All rights reserved.
> + *
> + * Routines used by ia64 machines with contiguous (or virtually contiguous)
> + * memory.
> + */
> +#include <linux/config.h>
> +#include <linux/mm.h>
> +#include <linux/swap.h>
> +#include <linux/bootmem.h>
> +#include <linux/efi.h>
> +#include <asm/sections.h>
> +#include <asm/pgtable.h>
> +#include <asm/pgalloc.h>
> +#include <asm/meminit.h>
> +
> +/**
> + * show_mem - display a memory statistics summary
> + *
> + * Just walks the pages in the system and describes where they're allocated.
> + */
> +void show_mem(void)
> +{
> +	int i, total = 0, reserved = 0;
> +	int shared = 0, cached = 0;
> +
> +	printk("Mem-info:\n");
> +	show_free_areas();
> +
> +	printk("Free swap:       %6dkB\n", nr_swap_pages<<(PAGE_SHIFT-10));
> +	i = max_mapnr;
> +	while (i-- > 0) {
> +		total++;
> +		if (PageReserved(mem_map+i))
> +			reserved++;
> +		else if (PageSwapCache(mem_map+i))
> +			cached++;
> +		else if (page_count(mem_map + i))
> +			shared += page_count(mem_map + i) - 1;
> +	}
> +	printk("%d pages of RAM\n", total);
> +	printk("%d reserved pages\n", reserved);
> +	printk("%d pages shared\n", shared);
> +	printk("%d pages swap cached\n", cached);
> +	printk("%ld pages in page table cache\n", pgtable_cache_size);
> +}
> +
> +/* physical address where the bootmem map is located */
> +unsigned long bootmap_start;
> +
> +/**
> + * find_max_pfn - adjust the maximum page number callback
> + * @start: start of range
> + * @end: end of range
> + * @arg: address of pointer to global max_pfn variable
> + *
> + * Passed as a callback function to efi_memmap_walk() to determine the highest
> + * available page frame number in the system.
> + */
> +int find_max_pfn(unsigned long start, unsigned long end, void *arg)
> +{
> +	unsigned long *max_pfnp = arg, pfn;
> +
> +	pfn = (PAGE_ALIGN(end - 1) - PAGE_OFFSET) >> PAGE_SHIFT;
> +	if (pfn > *max_pfnp)
> +		*max_pfnp = pfn;
> +	return 0;
> +}
> +
> +/**
> + * find_bootmap_location - callback to find a memory area for the bootmap
> + * @start: start of region
> + * @end: end of region
> + * @arg: unused callback data
> + *
> + * Find a place to put the bootmap and return its starting address in
> + * bootmap_start.  This address must be page-aligned.
> + */
> +int find_bootmap_location(unsigned long start, unsigned long end, void *arg)
> +{
> +	unsigned long needed = *(unsigned long *)arg;
> +	unsigned long range_start, range_end, free_start;
> +	int i;
> +
> +#if IGNORE_PFN0
> +	if (start = PAGE_OFFSET) {
> +		start += PAGE_SIZE;
> +		if (start >= end) return 0;
> +	}
> +#endif
> +
> +	free_start = PAGE_OFFSET;
> +
> +	for (i = 0; i < num_rsvd_regions; i++) {
> +		range_start = max(start, free_start);
> +		range_end   = min(end, rsvd_region[i].start & PAGE_MASK);
> +
> +		if (range_end <= range_start)
> +			continue; /* skip over empty range */
> +
> +	       	if (range_end - range_start >= needed) {
> +			bootmap_start = __pa(range_start);
> +			return 1;	/* done */
> +		}
> +
> +		/* nothing more available in this segment */
> +		if (range_end = end)
> +			return 0;
> +
> +		free_start = PAGE_ALIGN(rsvd_region[i].end);
> +	}
> +	return 0;
> +}
> +
> +/**
> + * find_memory - setup memory map
> + *
> + * Walk the EFI memory map and find usable memory for the system, taking
> + * into account reserved areas.
> + */
> +void find_memory(void)
> +{
> +	unsigned long bootmap_size;
> +
> +	reserve_memory();
> +
> +	/* first find highest page frame number */
> +	max_pfn = 0;
> +	efi_memmap_walk(find_max_pfn, &max_pfn);
> +	
> +	/* how many bytes to cover all the pages */
> +	bootmap_size = bootmem_bootmap_pages(max_pfn) << PAGE_SHIFT;
> +	
> +	/* look for a location to hold the bootmap */
> +	bootmap_start = ~0UL;
> +	efi_memmap_walk(find_bootmap_location, &bootmap_size);
> +	if (bootmap_start = ~0UL)
> +		panic("Cannot find %ld bytes for bootmap\n", bootmap_size);
> +	
> +	bootmap_size = init_bootmem(bootmap_start >> PAGE_SHIFT, max_pfn);
> +	
> +	/* Free all available memory, then mark bootmem-map as being in use. */
> +	efi_memmap_walk(filter_rsvd_memory, free_bootmem);
> +	reserve_bootmem(bootmap_start, bootmap_size);
> +
> +	find_initrd();
> +}
> diff -Nru a/arch/ia64/mm/discontig.c b/arch/ia64/mm/discontig.c
> --- a/arch/ia64/mm/discontig.c	Mon Sep 22 18:23:36 2003
> +++ b/arch/ia64/mm/discontig.c	Mon Sep 22 18:23:36 2003
> @@ -1,5 +1,5 @@
>  /*
> - * Copyright (c) 2000 Silicon Graphics, Inc.  All rights reserved.
> + * Copyright (c) 2000, 2003 Silicon Graphics, Inc.  All rights reserved.
>   * Copyright (c) 2001 Intel Corp.
>   * Copyright (c) 2001 Tony Luck <tony.luck@intel.com>
>   * Copyright (c) 2002 NEC Corp.
> @@ -12,10 +12,13 @@
>  
>  #include <linux/kernel.h>
>  #include <linux/mm.h>
> +#include <linux/swap.h>
>  #include <linux/bootmem.h>
>  #include <linux/mmzone.h>
>  #include <linux/acpi.h>
>  #include <linux/efi.h>
> +#include <asm/pgalloc.h>
> +#include <asm/meminit.h>
>  
>  
>  /*
> @@ -27,9 +30,6 @@
>  static long			boot_pg_data[8*NR_NODES+sizeof(pg_data_t)]  __initdata;
>  static pg_data_t		*pg_data_ptr[NR_NODES] __initdata;
>  static bootmem_data_t		bdata[NR_NODES][NR_BANKS_PER_NODE+1] __initdata;
> -
> -extern int  filter_rsvd_memory (unsigned long start, unsigned long end, void *arg);
> -
>  /*
>   * Return the compact node number of this cpu. Used prior to
>   * setting up the cpu_data area.
> @@ -209,11 +209,12 @@
>   * Called early in boot to setup the boot memory allocator, and to
>   * allocate the node-local pg_data & node-directory data structures..
>   */
> -void __init
> -discontig_mem_init(void)
> +void __init find_memory(void)
>  {
>  	int	node;
>  
> +	reserve_memory();
> +
>  	if (numnodes = 0) {
>  		printk(KERN_ERR "node info missing!\n");
>  		numnodes = 1;
> @@ -232,6 +233,8 @@
>          efi_memmap_walk(filter_rsvd_memory, discontig_free_bootmem_node);
>  	discontig_reserve_bootmem();
>  	allocate_pernode_structures();
> +
> +	find_initrd();
>  }
>  
>  /*
> @@ -305,3 +308,71 @@
>  		}
>  }
>  
> +void show_mem(void)
> +{
> +	int i, reserved = 0;
> +	int shared = 0, cached = 0;
> +	pg_data_t *pgdat;
> +
> +	printk("Mem-info:\n");
> +	show_free_areas();
> +	printk("Free swap:       %6dkB\n", nr_swap_pages<<(PAGE_SHIFT-10));
> +	for_each_pgdat(pgdat) {
> +		printk("Node ID: %d\n", pgdat->node_id);
> +		for(i = 0; i < pgdat->node_spanned_pages; i++) {
> +			if (PageReserved(pgdat->node_mem_map+i))
> +				reserved++;
> +			else if (PageSwapCache(pgdat->node_mem_map+i))
> +				cached++;
> +			else if (page_count(pgdat->node_mem_map+i))
> +				shared += page_count(pgdat->node_mem_map+i)-1;
> +		}
> +		printk("\t%ld pages of RAM\n", pgdat->node_present_pages);
> +		printk("\t%d reserved pages\n", reserved);
> +		printk("\t%d pages shared\n", shared);
> +		printk("\t%d pages swap cached\n", cached);
> +	}
> +	printk("Total of %ld pages in page table cache\n", pgtable_cache_size);
> +	printk("%d free buffer pages\n", nr_free_buffer_pages());
> +}
> +
> +/*
> + * efi_memmap_walk() knows nothing about layout of memory across nodes. Find
> + * out to which node a block of memory belongs.  Ignore memory that we cannot
> + * identify, and split blocks that run across multiple nodes.
> + *
> + * Take this opportunity to round the start address up and the end address
> + * down to page boundaries.
> + */
> +void call_pernode_memory(unsigned long start, unsigned long end, void *arg)
> +{
> +	unsigned long rs, re;
> +	void (*func)(unsigned long, unsigned long, int, int);
> +	int i;
> +
> +	start = PAGE_ALIGN(start);
> +	end &= PAGE_MASK;
> +	if (start >= end)
> +		return;
> +
> +	func = arg;
> +
> +	if (!num_memblks) {
> +		/*
> +		 * This machine doesn't have SRAT, so call func with
> +		 * nid=0, bank=0.
> +		 */
> +		if (start < end)
> +			(*func)(start, end - start, 0, 0);
> +		return;
> +	}
> +
> +	for (i = 0; i < num_memblks; i++) {
> +		rs = max(start, node_memblk[i].start_paddr);
> +		re = min(end, node_memblk[i].start_paddr+node_memblk[i].size);
> +
> +		if (rs < re)
> +			(*func)(rs, re-rs, node_memblk[i].nid,
> +				node_memblk[i].bank);
> +	}
> +}
> diff -Nru a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
> --- a/arch/ia64/mm/init.c	Mon Sep 22 18:23:36 2003
> +++ b/arch/ia64/mm/init.c	Mon Sep 22 18:23:36 2003
> @@ -214,58 +214,6 @@
>  	}
>  }
>  
> -void
> -show_mem(void)
> -{
> -	int i, total = 0, reserved = 0;
> -	int shared = 0, cached = 0;
> -
> -	printk("Mem-info:\n");
> -	show_free_areas();
> -
> -#ifdef CONFIG_DISCONTIGMEM
> -	{
> -		pg_data_t *pgdat;
> -
> -		printk("Free swap:       %6dkB\n", nr_swap_pages<<(PAGE_SHIFT-10));
> -		for_each_pgdat(pgdat) {
> -			printk("Node ID: %d\n", pgdat->node_id);
> -			for(i = 0; i < pgdat->node_spanned_pages; i++) {
> -				if (PageReserved(pgdat->node_mem_map+i))
> -					reserved++;
> -				else if (PageSwapCache(pgdat->node_mem_map+i))
> -					cached++;
> -				else if (page_count(pgdat->node_mem_map + i))
> -					shared += page_count(pgdat->node_mem_map + i) - 1;
> -			}
> -			printk("\t%d pages of RAM\n", pgdat->node_spanned_pages);
> -			printk("\t%d reserved pages\n", reserved);
> -			printk("\t%d pages shared\n", shared);
> -			printk("\t%d pages swap cached\n", cached);
> -		}
> -		printk("Total of %ld pages in page table cache\n", pgtable_cache_size);
> -		printk("%d free buffer pages\n", nr_free_buffer_pages());
> -	}
> -#else /* !CONFIG_DISCONTIGMEM */
> -	printk("Free swap:       %6dkB\n", nr_swap_pages<<(PAGE_SHIFT-10));
> -	i = max_mapnr;
> -	while (i-- > 0) {
> -		total++;
> -		if (PageReserved(mem_map+i))
> -			reserved++;
> -		else if (PageSwapCache(mem_map+i))
> -			cached++;
> -		else if (page_count(mem_map + i))
> -			shared += page_count(mem_map + i) - 1;
> -	}
> -	printk("%d pages of RAM\n", total);
> -	printk("%d reserved pages\n", reserved);
> -	printk("%d pages shared\n", shared);
> -	printk("%d pages swap cached\n", cached);
> -	printk("%ld pages in page table cache\n", pgtable_cache_size);
> -#endif /* !CONFIG_DISCONTIGMEM */
> -}
> -
>  /*
>   * This is like put_dirty_page() but installs a clean page in the kernel's page table.
>   */
> diff -Nru a/include/asm-ia64/meminit.h b/include/asm-ia64/meminit.h
> --- /dev/null	Wed Dec 31 16:00:00 1969
> +++ b/include/asm-ia64/meminit.h	Mon Sep 22 18:23:36 2003
> @@ -0,0 +1,38 @@
> +/* 
> + * This file is subject to the terms and conditions of the GNU General Public
> + * License.  See the file "COPYING" in the main directory of this archive
> + * for more details.
> + */
> +
> +/*
> + * Entries defined so far:
> + * 	- boot param structure itself
> + * 	- memory map
> + * 	- initrd (optional)
> + * 	- command line string
> + * 	- kernel code & data
> + *
> + * More could be added if necessary
> + */
> +#define IA64_MAX_RSVD_REGIONS 5
> +
> +struct rsvd_region {
> +	unsigned long start;	/* virtual address of beginning of element */
> +	unsigned long end;	/* virtual address of end of element + 1 */
> +};
> +
> +extern struct rsvd_region rsvd_region[IA64_MAX_RSVD_REGIONS + 1];
> +extern int num_rsvd_regions;
> +
> +extern void find_memory(void);
> +extern void reserve_memory(void);
> +extern void find_initrd(void);
> +extern int filter_rsvd_memory(unsigned long start, unsigned long end,
> +			      void *arg);
> +
> +#ifdef CONFIG_DISCONTIGMEM
> +extern void call_pernode_memory(unsigned long start, unsigned long end, void *arg);
> +#endif
> +
> +#define IGNORE_PFN0	1	/* XXX fix me: ignore pfn 0 until TLB miss
> +				   handler is updated... */
> diff -Nru a/include/asm-ia64/numa.h b/include/asm-ia64/numa.h
> --- a/include/asm-ia64/numa.h	Mon Sep 22 18:23:36 2003
> +++ b/include/asm-ia64/numa.h	Mon Sep 22 18:23:36 2003
> @@ -11,6 +11,9 @@
>  #ifndef _ASM_IA64_NUMA_H
>  #define _ASM_IA64_NUMA_H
>  
> +#include <linux/config.h>
> +#include <linux/cpumask.h>
> +
>  #ifdef CONFIG_NUMA
>  
>  #ifdef CONFIG_DISCONTIGMEM
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
