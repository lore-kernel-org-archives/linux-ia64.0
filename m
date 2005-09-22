From: Dave Hansen <haveblue@us.ibm.com>
Date: Thu, 22 Sep 2005 16:36:16 +0000
Subject: Re: [Lhms-devel] [PATCH 4/4] V4 ia64 SPARSEMEM - SPARSEMEM code
Message-Id: <1127406976.10664.52.camel@localhost>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 2005-09-22 at 12:14 -0400, Bob Picco wrote:
> This patch is the minimal set of changes required by ia64 to use
> SPARSEMEM.

I have a couple of little style comments.

> +#ifdef CONFIG_SPARSEMEM
> +	efi_memmap_walk(register_sparse_mem, NULL);
> +#endif
> +	sparse_init();
> +
>  	efi_memmap_walk(filter_rsvd_memory, count_node_pages);
>  
> +#ifdef CONFIG_VIRTUAL_MEM_MAP
>  	vmalloc_end -= PAGE_ALIGN(max_low_pfn * sizeof(struct page));
>  	vmem_map = (struct page *) vmalloc_end;
>  	efi_memmap_walk(create_mem_map_page_table, NULL);
>  	printk("Virtual mem_map starts at 0x%p\n", vmem_map);
> +#endif

It would be nice if these kind of .c file #ifdefs could be broken out a
little more.  For instance, you could make an arch_sparse_init() that
does all of the sparsemem bits, and make it a do{}while(0) when !
CONFIG_SPARSEMEM.

>  	for_each_online_node(node) {
>  		memset(zones_size, 0, sizeof(zones_size));
> @@ -690,7 +722,9 @@ void __init paging_init(void)
>  
>  		pfn_offset = mem_data[node].min_pfn;
>  
> +#ifdef CONFIG_VIRTUAL_MEM_MAP
>  		NODE_DATA(node)->node_mem_map = vmem_map + pfn_offset;
> +#endif

Is CONFIG_FLAT_NODE_MEM_MAP more appropriate here?  That's how
->node_mem_map is #ifdef'd to begin with in mmzone.h.

> --- linux-2.6.14-rc2.orig/arch/ia64/mm/numa.c	2005-09-21 12:28:49.000000000 -0400
> +++ linux-2.6.14-rc2/arch/ia64/mm/numa.c	2005-09-21 12:29:05.000000000 -0400
> @@ -45,5 +45,30 @@ paddr_to_nid(unsigned long paddr)
>  		    paddr < node_memblk[i].start_paddr + node_memblk[i].size)
>  			break;
>  
> -	return (i < num_node_memblks) ? node_memblk[i].nid : (num_node_memblks ? -1 : 0);
> +	return (i < num_node_memblks) ?
> +		node_memblk[i].nid : (num_node_memblks ? -1 : 0);
>  }

Looks like just a whitespace change.

-- Dave

