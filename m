From: jbarnes@sgi.com (Jesse Barnes)
Date: Sun, 22 Jun 2003 05:57:10 +0000
Subject: Re: [Discontig-devel] [PATCH] another discontig patch
Message-Id: <marc-linux-ia64-105626144124949@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105618641519753@msgid-missing>
In-Reply-To: <marc-linux-ia64-105618641519753@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sat, Jun 21, 2003 at 07:48:08AM -0700, Martin J. Bligh wrote:
> >> +static struct ia64_node_data	*boot_node_data[NR_NODES] __initdata;
> >> +static pg_data_t		*pg_data_ptr[NR_NODES] __initdata;
> >> +static bootmem_data_t		bdata[NR_NODES] __initdata;
> >> +static unsigned long		boot_pernode[NR_NODES] __initdata;
> >> +static unsigned long		boot_pernodesize[NR_NODES] __initdata;
> 
> The only use that I can *see* (without looking very hard) for 
> pg_data_ptr is as pg_data_ptr[node]->bdata, for which you already have
> bdata[node], don't you? The fact that you have both pg_data_ptr and
> pg_data_ptrs, which seem to do the same thing, but one as initdata,
> and one not, is also rather confusing ...

Yeah, that's one thing that I keep meaning to remove, but didn't in the
initial versions to keep the 2.4 and 2.5 patches as close as possible.

> memcpy(boot_node_data[0]->pg_data_ptrs, pg_data_ptr, sizeof(pg_data_ptr));
> 
> hmmm.
> 
> And aren't boot_pernode and boot_pernodesize really part of bdata?
> Seems like there's a lot of complexity in order to save a couple of
> pointer dereferences ... during boot ;-) But maybe I'm just misreading
> it ;-)

Well, there's definitely some pointer magic going on here, but I think
we use that stuff once the system is up as well, though from a different
pointer.

> 
> > Maybe it's time for special pernode data like the percpu data?
> > Okay, okay, not revelant for this patch yet...
> 
> ># ifndef CONFIG_VIRTUAL_MEM_MAP
> ># define	vmem_map		mem_map
> ># endif
> > 
> ># define pfn_to_page(pfn)	(vmem_map + (pfn))
> ># define page_to_pfn(page)	((unsigned long) (page - vmem_map))
> > 
> > In fact I wonder what's so special about mem_map that the symbol
> > can't be used for the vmalloc'ed version..
> > 
> > BTW, what about per-node memmaps for SN2 like it's done for NUMAQ?
> 
> I really don't see how you *can't* do that, and have it still work.
> If the mem_map is placed in node local memory, and not a size that 
> happens to be a complete number of pages, even if you pack it down 
> into a vmem_map, it's still not contiguous. So adding a pfn (physical 
> page frame number) to the base of vmem_map can NOT give you the correct 
> address.
> 
> Presumably this *is* working for you ... but I'm buggered if I know how ;-)
> Maybe I just need more coffee ;-)

No, there are some mixed metaphors here for sure (at least, as far as I
understand it!) :).  You can find stuff either using the global vmemmap
or the per-node maps I think, but honestly, I'm still coming up to speed
on this code myself, Jack and Kimi are the real experts.

Thanks,
Jesse
