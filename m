From: jbarnes@sgi.com (Jesse Barnes)
Date: Sun, 22 Jun 2003 05:53:49 +0000
Subject: Re: [Discontig-devel] [PATCH] another discontig patch
Message-Id: <marc-linux-ia64-105626126524891@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105618641519753@msgid-missing>
In-Reply-To: <marc-linux-ia64-105618641519753@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Thanks for looking at this, Christoph.  Comments below.

On Sat, Jun 21, 2003 at 10:06:46AM +0100, Christoph Hellwig wrote:
> On Thu, Jun 19, 2003 at 03:28:29PM -0700, Jesse Barnes wrote:
> >  #else /* !CONFIG_SMP */
> >  	cpu_data = __phys_per_cpu_start;
> >  #endif /* !CONFIG_SMP */
> 
> Maybe this whole code should better be abstracted out then?  Also
> the use of smp_processor_id() here is not preempt-safe but I 'm not sure
> whether preemption is already enabled at that point.

I think we're ok preempt wise here, but you're right that it could
probably be abstracted a bit.  The issue is that we need to create
per-node data structures containing each node's info before the per-cpu
stuff is initialized, so we do it all before the bootmem allocator is
even setup while we discover memory (see
discontig.c:find_pernode_space() I think).

> > +static struct ia64_node_data	*boot_node_data[NR_NODES] __initdata;
> > +static pg_data_t		*pg_data_ptr[NR_NODES] __initdata;
> > +static bootmem_data_t		bdata[NR_NODES] __initdata;
> > +static unsigned long		boot_pernode[NR_NODES] __initdata;
> > +static unsigned long		boot_pernodesize[NR_NODES] __initdata;
> 
> Maybe it's time for special pernode data like the percpu data?
> Okay, okay, not revelant for this patch yet...

It's already there.  It's really necessary to get decent performance,
and you have to watch out for cache aliasing effects.

> > +extern int filter_rsvd_memory(unsigned long start, unsigned long end, void *arg);
> 
> Move this to a header?

Yeah, maybe it should be in asm/page.h?  Or maybe we need an
asm/discontig.h?

> > +# define pfn_valid(pfn)	((pfn) < max_mapnr)
> > +#endif
> 
> Hmm, this ifdef mess look ugly.  Can't we use max_low_pfn for the
> !CONFIG_DISCONTIGMEM case, too and simp;ify it to something like:

Agreed, no question.  I think this could use some additional cleanup.

> #if defined(CONFIG_VIRTUAL_MEM_MAP)
> extern int ia64_pfn_valid(unsigned long pfn);
> #else
> # define ia64_pfn_valid(pfn)	(1)
> #endif
> 
> #define pfn_valid(pfn)	(((pfn) < max_low_pfn) && ia64_pfn_valid(pfn))
> 
> > +
> > +#if defined(CONFIG_DISCONTIGMEM) && defined(CONFIG_VIRTUAL_MEM_MAP)
> > +  extern struct page *vmem_map;
> > +# define pfn_to_page(pfn)	(vmem_map + (pfn))
> > +# define page_to_pfn(page)	((unsigned long) (page - vmem_map))
> > +#else
> > +# define pfn_to_page(pfn)	(mem_map + (pfn))
> > +# define page_to_pfn(page)	((unsigned long) (page - mem_map))
> > +#endif /* CONFIG_DISCONTIGMEM && CONFIG_VIRTUAL_MEM_MAP */
> > +

Though I'm not sure if this is the right way to do it...  If discontig
on ia64 is going to depend on virtual mem map, then making this one
#ifdef somehow is probably best.

> Hmm, doesn't CONFIG_VIRTUAL_MEM_MAP && !CONFIG_DISCONTIGMEM need
> vmem_map also.  Again, the ifdef mess is horrible :)
> 
> What about:
> 
> #ifndef CONFIG_VIRTUAL_MEM_MAP
> #define	vmem_map		mem_map
> #endif
> 
> #define pfn_to_page(pfn)	(vmem_map + (pfn))
> #define page_to_pfn(page)	((unsigned long) (page - vmem_map))
> 
> In fact I wonder what's so special about mem_map that the symbol
> can't be used for the vmalloc'ed version..

Don't know, I'll have to look some more.

> BTW, what about per-node memmaps for SN2 like it's done for NUMAQ?

AFAIK, the per-node memmaps index into the big virtual memmap, but I'd
have to look at it some more.  If we made per-node memory maps, then we
probably wouldn't need to use the virtual mem map, except that it makes
dealing with holes a bit easier (since on sn2 even memory within a node
isn't contiguous, and there are big holes between nodes).

> >  #ifdef CONFIG_NUMA
> >  	struct ia64_node_data *node_data;
> > +	int nodeid;
> > +	struct cpuinfo_ia64 *cpu_data[NR_CPUS];
> >  #endif
> 
> Should the big array be before the nodeid field?

Good catch, probably not. :)

Thanks,
Jesse
