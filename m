From: Christoph Hellwig <hch@infradead.org>
Date: Sat, 21 Jun 2003 09:06:46 +0000
Subject: Re: [Discontig-devel] [PATCH] another discontig patch
Message-Id: <marc-linux-ia64-105618641519753@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Jun 19, 2003 at 03:28:29PM -0700, Jesse Barnes wrote:
> @@ -703,6 +702,8 @@
>  	 * get_free_pages() cannot be used before cpu_init() done.  BSP allocates
>  	 * "NR_CPUS" pages for all CPUs to avoid that AP calls get_zeroed_page().
>  	 */
> +#ifndef CONFIG_DISCONTIGMEM
> +	/* for discontig machines, we do this in discontig.c */
>  	if (smp_processor_id() = 0) {
>  		cpu_data = __alloc_bootmem(PERCPU_PAGE_SIZE * NR_CPUS, PERCPU_PAGE_SIZE,
>  					   __pa(MAX_DMA_ADDRESS));
> @@ -712,15 +713,13 @@
>  			cpu_data += PERCPU_PAGE_SIZE;
>  		}
>  	}
> +#endif
>  	cpu_data = __per_cpu_start + __per_cpu_offset[smp_processor_id()];
>  #else /* !CONFIG_SMP */
>  	cpu_data = __phys_per_cpu_start;
>  #endif /* !CONFIG_SMP */

Maybe this whole code should better be abstracted out then?  Also
the use of smp_processor_id() here is not preempt-safe but I 'm not sure
whether preemption is already enabled at that point.

> +static struct ia64_node_data	*boot_node_data[NR_NODES] __initdata;
> +static pg_data_t		*pg_data_ptr[NR_NODES] __initdata;
> +static bootmem_data_t		bdata[NR_NODES] __initdata;
> +static unsigned long		boot_pernode[NR_NODES] __initdata;
> +static unsigned long		boot_pernodesize[NR_NODES] __initdata;

Maybe it's time for special pernode data like the percpu data?
Okay, okay, not revelant for this patch yet...

>  struct page *zero_page_memmap_ptr;		/* map entry for zero page */
>  
> +extern int filter_rsvd_memory(unsigned long start, unsigned long end, void *arg);

Move this to a header?

> +#if defined(CONFIG_VIRTUAL_MEM_MAP) && !defined(CONFIG_DISCONTIGMEM)
> +  extern int ia64_pfn_valid (unsigned long pfn);
> +# define pfn_valid(pfn)	(((pfn) < max_mapnr) && ia64_pfn_valid(pfn))
> +#elif defined(CONFIG_VIRTUAL_MEM_MAP) && defined(CONFIG_DISCONTIGMEM)
> +  extern int ia64_pfn_valid (unsigned long pfn);
> +  extern unsigned long max_low_pfn;
> +# define pfn_valid(pfn)	(((pfn) < max_low_pfn) && ia64_pfn_valid(pfn))
> +#else
> +# define pfn_valid(pfn)	((pfn) < max_mapnr)
> +#endif

Hmm, this ifdef mess look ugly.  Can't we use max_low_pfn for the
!CONFIG_DISCONTIGMEM case, too and simp;ify it to something like:

#if defined(CONFIG_VIRTUAL_MEM_MAP)
extern int ia64_pfn_valid(unsigned long pfn);
#else
# define ia64_pfn_valid(pfn)	(1)
#endif

#define pfn_valid(pfn)	(((pfn) < max_low_pfn) && ia64_pfn_valid(pfn))

> +
> +#if defined(CONFIG_DISCONTIGMEM) && defined(CONFIG_VIRTUAL_MEM_MAP)
> +  extern struct page *vmem_map;
> +# define pfn_to_page(pfn)	(vmem_map + (pfn))
> +# define page_to_pfn(page)	((unsigned long) (page - vmem_map))
> +#else
> +# define pfn_to_page(pfn)	(mem_map + (pfn))
> +# define page_to_pfn(page)	((unsigned long) (page - mem_map))
> +#endif /* CONFIG_DISCONTIGMEM && CONFIG_VIRTUAL_MEM_MAP */
> +

Hmm, doesn't CONFIG_VIRTUAL_MEM_MAP && !CONFIG_DISCONTIGMEM need
vmem_map also.  Again, the ifdef mess is horrible :)

What about:

#ifndef CONFIG_VIRTUAL_MEM_MAP
#define	vmem_map		mem_map
#endif

#define pfn_to_page(pfn)	(vmem_map + (pfn))
#define page_to_pfn(page)	((unsigned long) (page - vmem_map))

In fact I wonder what's so special about mem_map that the symbol
can't be used for the vmalloc'ed version..

BTW, what about per-node memmaps for SN2 like it's done for NUMAQ?


>  #ifdef CONFIG_NUMA
>  	struct ia64_node_data *node_data;
> +	int nodeid;
> +	struct cpuinfo_ia64 *cpu_data[NR_CPUS];
>  #endif

Should the big array be before the nodeid field?

