From: Christoph Hellwig <hch@infradead.org>
Date: Wed, 08 Oct 2003 14:31:47 +0000
Subject: Re: [PATCH] split contig and discontig paging_init functions
Message-Id: <marc-linux-ia64-106562379402836@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106547645502436@msgid-missing>
In-Reply-To: <marc-linux-ia64-106547645502436@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Oct 06, 2003 at 02:34:23PM -0700, Jesse Barnes wrote:
>  #include <asm/pgtable.h>
>  #include <asm/sections.h>
>  
> +#ifdef CONFIG_VIRTUAL_MEM_MAP
> +static unsigned long num_dma_physpages;
> +#endif

Shouldn't this move down to the ifdef block where it's actually used?

> +	if (max_gap < LARGE_GAP) {
> +		vmem_map = (struct page *) 0;
> +		free_area_init_node(0, &contig_page_data, NULL, zones_size, 0,
> +				    zholes_size);
> +		mem_map = contig_page_data.node_mem_map;
> +	}
> +	else {
> +		unsigned long map_size;
> +
> +		/* allocate virtual_mem_map */
> +
> +		map_size = PAGE_ALIGN(max_low_pfn * sizeof(struct page));
> +		vmalloc_end -= map_size;
> +		vmem_map = (struct page *) vmalloc_end;
> +		efi_memmap_walk(create_mem_map_page_table, 0);
> +
> +		free_area_init_node(0, &contig_page_data, vmem_map, zones_size,
> +				    0, zholes_size);
> +
> +		mem_map = contig_page_data.node_mem_map;
> +		printk("Virtual mem_map starts at 0x%p\n", mem_map);
> +	}

what about:

	if (max_gap >= LARGE_GAP) {
		vmalloc_end -= PAGE_ALIGN(max_low_pfn * sizeof(struct page));
		vmem_map = (struct page *)vmalloc_end;
		efi_memmap_walk(create_mem_map_page_table, 0);
	}

	free_area_init_node(0, &contig_page_data, vmem_map, zones_size, 0,
				    zholes_size);
	mem_map = contig_page_data.node_mem_map;

(vmem_map is in .bss and thus implicitly NULL)
