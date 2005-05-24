From: Bob Picco <bob.picco@hp.com>
Date: Tue, 24 May 2005 14:33:16 +0000
Subject: Re: [patch 0/4] ia64 SPARSEMEM
Message-Id: <20050524143316.GK2783@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050523175031.GC2783@localhost.localdomain>
In-Reply-To: <20050523175031.GC2783@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger wrote:	[Mon May 23 2005, 11:29:47PM EDT]
> >>>>> On Mon, 23 May 2005 13:50:31 -0400, Bob Picco <bob.picco@hp.com> said:
> 
>   Bob> Ultimately I would like to eliminate [...] VIRTUAL_MEM_MAP.
> 
> Why?
> 
> Considering this:
> 
> +#ifdef CONFIG_SPARSEMEM
> + /*
> + * SECTION_SIZE_BITS            2^N: how big each section will be
> + * MAX_PHYSADDR_BITS            2^N: how much physical address space we have
> + * MAX_PHYSMEM_BITS             2^N: how much memory we can have in that space
> + */
> 
> The virtual mem-map seems like a much nicer solution to me.
> 
> 	--david
> -
David,

VIRTUAL_MEM_MAP was introduced on ia64 because of memory holes on ia64
platforms. The mem_map of the pglist_data is a pointer to a virtual 
contiguous array of page structures in memory for a node.  To
eliminate memory waste contiguous memory holes don't have page structures.
The alternative would be for holes in memory to be represented by reserve
page structures.  The VIRTUAL_MEM_MAP solutions requires ia64_pfn_valid
and a hook in the buddy allocator to check for holes in memory. 

SPARSEMEM has eliminated mem_map, ia64_pfn_valid and the buddy allocator
hook.  There is a small cost for SPARSEMEM.  Any section which has both
memory and holes requires reserved pages for the holes.  I can see
SPARSEMEM replacing DISCONTIG_MEM+VIRTUAL_MEM_MAP.  So we'd basically
have on ia64 NUMA and no NUMA memory support code.

So AFAICS there is no advantage to retaining VIRTUAL_MEM_MAP should SPARSEMEM
match or exceed the performance of DISCONTIG_MEM+VIRTUAL_MEM_MAP.

bob
