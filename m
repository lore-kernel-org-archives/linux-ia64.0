From: "Martin J. Bligh" <mbligh@aracnet.com>
Date: Sat, 21 Jun 2003 14:48:08 +0000
Subject: Re: [Discontig-devel] [PATCH] another discontig patch
Message-Id: <marc-linux-ia64-105620690930308@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105618641519753@msgid-missing>
In-Reply-To: <marc-linux-ia64-105618641519753@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>> +static struct ia64_node_data	*boot_node_data[NR_NODES] __initdata;
>> +static pg_data_t		*pg_data_ptr[NR_NODES] __initdata;
>> +static bootmem_data_t		bdata[NR_NODES] __initdata;
>> +static unsigned long		boot_pernode[NR_NODES] __initdata;
>> +static unsigned long		boot_pernodesize[NR_NODES] __initdata;

The only use that I can *see* (without looking very hard) for 
pg_data_ptr is as pg_data_ptr[node]->bdata, for which you already have
bdata[node], don't you? The fact that you have both pg_data_ptr and
pg_data_ptrs, which seem to do the same thing, but one as initdata,
and one not, is also rather confusing ...

memcpy(boot_node_data[0]->pg_data_ptrs, pg_data_ptr, sizeof(pg_data_ptr));

hmmm.

And aren't boot_pernode and boot_pernodesize really part of bdata?
Seems like there's a lot of complexity in order to save a couple of
pointer dereferences ... during boot ;-) But maybe I'm just misreading
it ;-)

> Maybe it's time for special pernode data like the percpu data?
> Okay, okay, not revelant for this patch yet...

># ifndef CONFIG_VIRTUAL_MEM_MAP
># define	vmem_map		mem_map
># endif
> 
># define pfn_to_page(pfn)	(vmem_map + (pfn))
># define page_to_pfn(page)	((unsigned long) (page - vmem_map))
> 
> In fact I wonder what's so special about mem_map that the symbol
> can't be used for the vmalloc'ed version..
> 
> BTW, what about per-node memmaps for SN2 like it's done for NUMAQ?

I really don't see how you *can't* do that, and have it still work.
If the mem_map is placed in node local memory, and not a size that 
happens to be a complete number of pages, even if you pack it down 
into a vmem_map, it's still not contiguous. So adding a pfn (physical 
page frame number) to the base of vmem_map can NOT give you the correct 
address.

Presumably this *is* working for you ... but I'm buggered if I know how ;-)
Maybe I just need more coffee ;-)

Thanks,

M.

