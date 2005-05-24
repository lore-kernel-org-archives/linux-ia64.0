From: Bob Picco <bob.picco@hp.com>
Date: Tue, 24 May 2005 16:27:39 +0000
Subject: Re: [patch 0/4] ia64 SPARSEMEM
Message-Id: <20050524162739.GA11224@localhost.localdomain>
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
Hi David,

I don't perceive VIRTUAL_MEM_MAP as a nicer solution.  Actually SPARSEMEM
is a very elegant solution for memory holes and hotplug memory.

VIRTUAL_MEM_MAP accommodates the physical holes in memory for ia64. This is 
achieved allocating a contiguous virtual region to cover the minimum
and maximum page structures on node.  The page struct array is stored in
node_mem_map of pglist_data for each node.  page structs that represent
holes in memory and span a page of physical memory aren't allocated. 
CONFIG_HOLES_IN_ZONE in bad_range and calls to ia64_pfn_valid are used to detect
these holes when in buddy allocator.

SPARSEMEM carves memory into 1<<SECTION_SIZE_BITS. Any section entirely 
consumed by a hole is marked as invalid.  A section with holes and memory 
results in the holes being reserved pages.  SPARSEMEM eliminates 
CONFIG_HOLES_IN_ZONE and ia64_pfn_valid.  

So AFAICS DISCONTIG_MEM+VIRTUAL_MEM_MAP won't provide any advantage should
SPARSEMEM perform as well or better. We could eventually reduce ia64 memory 
Kconfig complexity and code in ia64 mm directory significantly.  This could
all be a pipe dream should performance not win out.  

thanks,

bob
