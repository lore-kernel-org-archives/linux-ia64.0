From: jbarnes@sgi.com (Jesse Barnes)
Date: Wed, 24 Sep 2003 14:51:39 +0000
Subject: Re: [PATCH] discontig patch (work in progress)
Message-Id: <marc-linux-ia64-106441515415517@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106436165231302@msgid-missing>
In-Reply-To: <marc-linux-ia64-106436165231302@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Sep 24, 2003 at 09:43:57AM +0100, Christoph Hellwig wrote:
> The #if defined(VIRTUAL_MEM_MAP) || !defined(DISCONTIGMEM) in generic
> code have to go away.  All this mem_map/contig_page_data/etc crap
> has should probably go away some day, but for now let's not make it
> even messier.

Sure, I'm all for them going away, any suggestions on how to get there?

> Also in the discontig + vmem_map case you don't want them - always use
> the per-node mem_maps even if it's just to avoid the pagetable
> lookups and to be more similar to the other arches numa code.

The vmem_map is only used statically in arch/ia64/mm/init.c, but we use
the global mem_map for the macros in include/asm-ia64/pgtable.h for
convenience.  There are a bunch of cases to deal with:
  o CONFIG_VIRTUAL_MEM_MAP and !CONFIG_VIRTUAL_MEM_MAP
  o CONFIG_DISCONTIGMEM and !CONFIG_DISCONTIGMEM
  o any combination of the two above

We need CONFIG_VIRTUAL_MEM_MAP and CONFIG_DISCONTIGMEM work together at
the very least so that ia64 generic kernels will work.

> More comments:
> 
> 
> #ifdef CONFIG_DISCONTIGMEM
> -                       call_pernode_memory(__pa(range_start), __pa(range_end), func);
> +			call_pernode_memory(range_start, range_end, arg);
> #else
> -                       (*func)(__pa(range_start), range_end - range_start);
> +			(*func)(range_start, range_end, 0);
> #endif
> 
> What's the point of passing arg directly here if we just casted it to
> func?  Also the ifdef is horrible.  Please add a call_pernode_memory
> wrapper for !CONFIG_DISCONTIGMEM ala

Ok, I was thinking of doing that anyway.

> #define call_pernode_memory(start, end, func)	(*func)(start, end, 0)
> 
> What about moving call_pernode_memory to discontig.c?

Yeah, this patch moves it there already.

> --------
> 
> count_cpus() seems to reimplemement nr_cpus_node() from topology.h
> badly, or is it just me?

No, you're probably right.  I'll double check and remove it (had to do
the same for local_nodeid->nodeid()->numa_node_id()->NULL because it was
in topology.h.  I don't know where this stuff came from *sigh*).

> per_cpu_init looks strange, in the !SMP case both implementations
> are identical and have an unused variable..
> 
> What about just having
> 
> #ifdef CONFIG_SMP
> extern void *per_cpu_init(void);
> #else
> # define per_cpu_init()	(__phys_per_cpu_start)
> #endif
> 
> into percpu.h?

Yeah, that's a good idea.

> This whole per-cpu thing looks like a candidate for the next small patch.

Sounds good.

> --------
> 
> 
> +		if (numnodes = 1 && max_gap < LARGE_GAP) {
> +			/* Just one node with no big holes... */
> +			vmem_map = (struct page *)0;
> +			zones_size[ZONE_DMA] += cdata.min_pfn;
> +			zholes_size[ZONE_DMA] += cdata.min_pfn;
> +			free_area_init_node(0, NODE_DATA(node), NODE_DATA(node)->node_mem_map,
> +					    zones_size, 0, zholes_size);
> +		}
> +		else {
> +			/* allocate virtual mem_map */
> +			if (node = 0) {
> +				unsigned long map_size;
> +				map_size = PAGE_ALIGN(max_low_pfn*sizeof(struct page));
> +				vmalloc_end -= map_size;
> +				vmem_map = (struct page *) vmalloc_end;
> +				efi_memmap_walk(create_mem_map_page_table, 0);
> +				printk("Virtual mem_map starts at 0x%p\n", vmem_map);
> +				mem_map = vmem_map;
> +			}
> +			free_area_init_node(node, NODE_DATA(node), vmem_map + cdata.min_pfn,
> +					    zones_size, cdata.min_pfn, zholes_size);
> +		}
>  	}
> 
> Should look something like
> 
> 
> 		/* Just one node with no big holes... */
> 		if (numnodes = 1 && max_gap < LARGE_GAP) {
> 			zones_size[ZONE_DMA] += cdata.min_pfn;
> 			zholes_size[ZONE_DMA] += cdata.min_pfn;
> 
> 			/* XXX: probably already done somewhere else? */
> 			mem_map = NODE_DATA(node)->node_mem_map; 
> 			pfn_offset = 0;
> 	
> 		/* allocate virtual mem_map */
> 		} else if (node = 0) {
> 			vmalloc_end -> 				PAGE_ALIGN(max_low_pfn * sizeof(struct page));
> 			mem_map = vmem_map = (struct page *)vmalloc_end;
> 
> 			efi_memmap_walk(create_mem_map_page_table, 0);
> 			pfn_offset = cdata.min_pfn;
> 		}
> 
> 		free_area_init_node(node, NODE_DATA(node), mem_map + pfn_offset,
> 				zones_size, pfn_offset, zholes_size);
>  
> 
> --------

Yep, much better.

> -                       pgd_populate(&init_mm, pgd, alloc_bootmem_pages(PAGE_SIZE));
> +			pgd_populate(&init_mm, pgd, alloc_bootmem_pages_node(NODE_DATA(node), PAGE_SIZE));
> 
> This could use some linewraps :)  Also alloc_bootmem_pages_node probably
> wants a nid argument instead of of a pgdat, but that's not really in
> scope for this series..

Sure, that's another small patch, s/alloc_bootmem_pages/alloc_bootmem_pages_node(NODE_DATA(node)/g.

> --------
> 
> asm/mmzone.h looks a bit fishy.  The SN2 and generic cases are the same,
> why not merge them.  Also the ?error is ugly - it if works for the generic
> kernel it'll surely work for a newly added arch, too, no?

Probably, and making the worst case config and the generic config the
same is a good idea.

> What about something like:
> 
> /* DIG systems only support rather small configurations for now */
> #ifdef CONFIG_IA64_DIG
> #define MAX_PHYSNODE_ID	8
> #define NR_NODES	8
> #define NR_MEMBLKS	(NR_NODES * 32) /* interleaved, contiguous memory */
> #else
> /* Currently SN2 marks the maximum.  Should work for everyone else, too */
> #define MAX_PHYSNODE_ID	2048
> #define NR_NODES	256
> #define NR_MEMBLKS	(NR_NODES)
> #endif
> 
> And as asm/mmzone.h is only included for CONFIG_DISCONTIGMEM and
> ia64 couples DISCONTIG and NUMA tighly you should just scrap the non-numa
> case in this file

Ok.

> --------
> 
> -#ifndef CONFIG_DISCONTIGMEM
> -# ifdef CONFIG_VIRTUAL_MEM_MAP
> +#ifdef CONFIG_VIRTUAL_MEM_MAP
>     extern int ia64_pfn_valid (unsigned long pfn);
>  #  define pfn_valid(pfn)       (((pfn) < max_mapnr) &&
>  #  ia64_pfn_valid(pfn))
> -# else
> +#else
>  #  define pfn_valid(pfn)       ((pfn) < max_mapnr)
> -# endif
> +#endif
> 
> Didn't I tell you some time ago that the proper way to write this
> would be:
> 
> #ifdef CONFIG_VIRTUAL_MEM_MAP
> extern int ia64_pfn_valid(unsigned long pfn);
> #else
> # define ia64_pfn_valid(pfn)	1
> #endif
> 
> and then an unconditional
> 
> #define pfn_valid(pfn)		(((pfn) < max_mapnr) && ia64_pfn_valid(pfn))
> 
> ?

Oops, I cleaned it up to remove a bunch of other stuff and lost that
piece.  I'll fix it.

Thanks,
Jesse
