From: "Martin J. Bligh" <mbligh@aracnet.com>
Date: Sun, 22 Jun 2003 15:25:28 +0000
Subject: Re: [Discontig-devel] [PATCH] another discontig patch
Message-Id: <marc-linux-ia64-105629573908120@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105618641519753@msgid-missing>
In-Reply-To: <marc-linux-ia64-105618641519753@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>> >> +static struct ia64_node_data	*boot_node_data[NR_NODES] __initdata;
>> >> +static pg_data_t		*pg_data_ptr[NR_NODES] __initdata;
>> >> +static bootmem_data_t		bdata[NR_NODES] __initdata;
>> >> +static unsigned long		boot_pernode[NR_NODES] __initdata;
>> >> +static unsigned long		boot_pernodesize[NR_NODES] __initdata;
>> 
>> The only use that I can *see* (without looking very hard) for 
>> pg_data_ptr is as pg_data_ptr[node]->bdata, for which you already have
>> bdata[node], don't you? The fact that you have both pg_data_ptr and
>> pg_data_ptrs, which seem to do the same thing, but one as initdata,
>> and one not, is also rather confusing ...
> 
> Yeah, that's one thing that I keep meaning to remove, but didn't in the
> initial versions to keep the 2.4 and 2.5 patches as close as possible.

OK, I don't think it's something you're introducing with your patch,
so it's probably best done separately anyway - you seem to be making
the current situation better in general ;-) 

>> > BTW, what about per-node memmaps for SN2 like it's done for NUMAQ?
>> 
>> I really don't see how you *can't* do that, and have it still work.
>> If the mem_map is placed in node local memory, and not a size that 
>> happens to be a complete number of pages, even if you pack it down 
>> into a vmem_map, it's still not contiguous. So adding a pfn (physical 
>> page frame number) to the base of vmem_map can NOT give you the correct 
>> address.
>> 
>> Presumably this *is* working for you ... but I'm buggered if I know how ;-)
>> Maybe I just need more coffee ;-)
> 
> No, there are some mixed metaphors here for sure (at least, as far as I
> understand it!) :).  You can find stuff either using the global vmemmap
> or the per-node maps I think, but honestly, I'm still coming up to speed
> on this code myself, Jack and Kimi are the real experts.

OK. Am I mistaken in thinking that the point of vmem_map is to skip over
physical holes in RAM? If not, then disregard the following ;-) Perhaps
it's just about node locality of the struct pages, but that seems odd?

Maybe if the start end of memory areas are always hitting boundaries aligned
on PAGE_SIZE number of pages, (ie 16MB for 4K pages), then your mem_map is
always page aligned because it's in (sizeof (struct page) * PAGE_SIZE) chunks.
If you (plural) are relying on that, then I think it needs a huge stinking 
comment - isn't terribly obvious to innocent bystanders ;-)

Whilst that would enable you to make the array node_local, you still can't 
just add a pfn to the base as an offset anyway, which is what it looks like 
you were doing - that assumes it's all contig. eg this:

pfn_to_page(pfn)      (vmem_map + (pfn))

Unless you somehow warped the definition of pfn into a contiguous version
of the space, in which case, I think people's heads may explode ... we've
always had  pfn = phys_addr / PAGE_SIZE as an identity.

M.

