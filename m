From: Jay Lan <jlan@sgi.com>
Date: Wed, 28 Feb 2007 01:48:50 +0000
Subject: Re: [Patch] min_low_pfn and max_low_pfn calcultion fix
Message-Id: <45E4DF82.7020700@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1172619535.20006.334.camel@linux-znh>
In-Reply-To: <1172619535.20006.334.camel@linux-znh>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This fixed my problem on SN.

Acked-by: Jay Lan <jlan@sgi.com>


Zou Nan hai wrote:
> Hi,
>   We have seen bad_pte_print when testing crashdump on an SN machine in
> recent 2.6.20 kernel. 
>   There are tons of bad pte print (pfn < max_low_pfn) reports when the
> crash kernel boots up, all those reported bad pages are inside initmem
> range;
>   That is because if the crash kernel code and data happens to be at the
> beginning of the 1st node. build_node_maps in discontig.c will bypass
> reserved regions with filter_rsvd_memory. Since min_low_pfn is
> calculated in build_node_map, so in this case, min_low_pfn will be
> greater than kernel code and data.
> 
>   Because pages inside initmem are freed and reused later, we saw
> pfn_valid check fail on those pages.
> 
>   I think this theoretically happen on a normal kernel. When I check
> min_low_pfn and max_low_pfn calculation in contig.c and discontig.c. 
> I found more issues than this.
>   
>   1. min_low_pfn and max_low_pfn calculation is inconsistent between
> contig.c and discontig.c, 
>   min_low_pfn is calculated as the first page number of boot memmap in
> contig.c (Why? Though this may work at the most of the time, I don't
> think it is the right logic). It is calculated as the lowest physical
> memory page number bypass reserved regions in discontig.c.
>   max_low_pfn is calculated include reserved regions in contig.c. It is
> calculated exclude reserved regions in discontig.c.
>   
>   2. If kernel code and data region is happen to be at the begin or the
> end of physical memory, when min_low_pfn and max_low_pfn calculation is
> bypassed kernel code and data, pages in initmem will report bad.
> 
>   3. initrd is also in reserved regions, if it is at the begin or at the
> end of physical memory, kernel will refuse to reuse the memory. Because
> the virt_addr_valid check in free_initrd_mem.
> 
>   So it is better to fix and clean up those issues. 
> Calculate min_low_pfn and max_low_pfn in a consistent way.
> 
> Below is the patch, please review and comments
> 
> Signed-off-by:	Zou Nan hai <nanhai.zou@intel.com>
> 
> diff -Nraup a/arch/ia64/mm/contig.c b/arch/ia64/mm/contig.c
> --- a/arch/ia64/mm/contig.c	2007-02-27 00:42:06.000000000 -0500
> +++ b/arch/ia64/mm/contig.c	2007-02-27 03:03:00.000000000 -0500
> @@ -75,26 +75,6 @@ show_mem (void)
>  unsigned long bootmap_start;
>  
>  /**
> - * find_max_pfn - adjust the maximum page number callback
> - * @start: start of range
> - * @end: end of range
> - * @arg: address of pointer to global max_pfn variable
> - *
> - * Passed as a callback function to efi_memmap_walk() to determine the highest
> - * available page frame number in the system.
> - */
> -int
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
> -/**
>   * find_bootmap_location - callback to find a memory area for the bootmap
>   * @start: start of region
>   * @end: end of region
> @@ -155,9 +135,10 @@ find_memory (void)
>  	reserve_memory();
>  
>  	/* first find highest page frame number */
> -	max_pfn = 0;
> -	efi_memmap_walk(find_max_pfn, &max_pfn);
> -
> +	min_low_pfn = -1;
> +	max_low_pfn = 0;
> +	efi_memmap_walk(find_max_min_low_pfn, NULL);
> +	max_pfn = max_low_pfn;
>  	/* how many bytes to cover all the pages */
>  	bootmap_size = bootmem_bootmap_pages(max_pfn) << PAGE_SHIFT;
>  
> @@ -167,7 +148,8 @@ find_memory (void)
>  	if (bootmap_start = ~0UL)
>  		panic("Cannot find %ld bytes for bootmap\n", bootmap_size);
>  
> -	bootmap_size = init_bootmem(bootmap_start >> PAGE_SHIFT, max_pfn);
> +	bootmap_size = init_bootmem_node(NODE_DATA(0), 
> +			(bootmap_start >> PAGE_SHIFT), 0, max_pfn);
>  
>  	/* Free all available memory, then mark bootmem-map as being in use. */
>  	efi_memmap_walk(filter_rsvd_memory, free_bootmem);
> diff -Nraup a/arch/ia64/mm/discontig.c b/arch/ia64/mm/discontig.c
> --- a/arch/ia64/mm/discontig.c	2007-02-27 00:42:06.000000000 -0500
> +++ b/arch/ia64/mm/discontig.c	2007-02-27 03:00:30.000000000 -0500
> @@ -86,9 +86,6 @@ static int __init build_node_maps(unsign
>  		bdp->node_low_pfn = max(epfn, bdp->node_low_pfn);
>  	}
>  
> -	min_low_pfn = min(min_low_pfn, bdp->node_boot_start>>PAGE_SHIFT);
> -	max_low_pfn = max(max_low_pfn, bdp->node_low_pfn);
> -
>  	return 0;
>  }
>  
> @@ -467,6 +464,7 @@ void __init find_memory(void)
>  	/* These actually end up getting called by call_pernode_memory() */
>  	efi_memmap_walk(filter_rsvd_memory, build_node_maps);
>  	efi_memmap_walk(filter_rsvd_memory, find_pernode_space);
> +	efi_memmap_walk(find_max_min_low_pfn, NULL);
>  
>  	for_each_online_node(node)
>  		if (mem_data[node].bootmem_data.node_low_pfn) {
> diff -Nraup a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
> --- a/arch/ia64/mm/init.c	2007-02-27 00:42:06.000000000 -0500
> +++ b/arch/ia64/mm/init.c	2007-02-27 03:08:10.000000000 -0500
> @@ -616,6 +616,22 @@ count_reserved_pages (u64 start, u64 end
>  	return 0;
>  }
>  
> +int
> +find_max_min_low_pfn (unsigned long start, unsigned long end, void *arg)
> +{
> +	unsigned long pfn_start, pfn_end;
> +#if CONFIG_FLATMEM
> +	pfn_start = (PAGE_ALIGN(__pa(start))) >> PAGE_SHIFT;
> +	pfn_end = (PAGE_ALIGN(__pa(end - 1))) >> PAGE_SHIFT;
> +#else
> +	pfn_start = GRANULEROUNDDOWN(__pa(start)) >> PAGE_SHIFT;
> +	pfn_end = GRANULEROUNDUP(__pa(end - 1)) >> PAGE_SHIFT;
> +#endif
> +	min_low_pfn = min(min_low_pfn, pfn_start);
> +	max_low_pfn = max(max_low_pfn, pfn_end);
> +	return 0;
> +}
> +
>  /*
>   * Boot command-line option "nolwsys" can be used to disable the use of any light-weight
>   * system call handler.  When this option is in effect, all fsyscalls will end up bubbling
> diff -Nraup a/include/asm-ia64/meminit.h b/include/asm-ia64/meminit.h
> --- a/include/asm-ia64/meminit.h	2007-02-27 00:42:07.000000000 -0500
> +++ b/include/asm-ia64/meminit.h	2007-02-27 03:01:15.000000000 -0500
> @@ -35,6 +35,7 @@ extern void reserve_memory (void);
>  extern void find_initrd (void);
>  extern int filter_rsvd_memory (unsigned long start, unsigned long end, void *arg);
>  extern void efi_memmap_init(unsigned long *, unsigned long *);
> +extern int find_max_min_low_pfn (unsigned long , unsigned long, void *);
>  
>  /*
>   * For rounding an address to the next IA64_GRANULE_SIZE or order
> 
> 
> 
> 
> 
>   
> 	
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

