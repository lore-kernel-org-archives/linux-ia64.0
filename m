From: Christoph Hellwig <hch@infradead.org>
Date: Wed, 24 Sep 2003 16:54:00 +0000
Subject: Re: [PATCH] discontig patch (work in progress)
Message-Id: <marc-linux-ia64-106442331327396@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106436165231302@msgid-missing>
In-Reply-To: <marc-linux-ia64-106436165231302@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Sep 24, 2003 at 07:51:39AM -0700, Jesse Barnes wrote:
> > The #if defined(VIRTUAL_MEM_MAP) || !defined(DISCONTIGMEM) in generic
> > code have to go away.  All this mem_map/contig_page_data/etc crap
> > has should probably go away some day, but for now let's not make it
> > even messier.
> 
> Sure, I'm all for them going away, any suggestions on how to get there?

Always use the node-local mem_map, in the !DISCONTIG case we just
have only one of them.  But as said above this is in scope for this
work (or 2.6 at all).

> > Also in the discontig + vmem_map case you don't want them - always use
> > the per-node mem_maps even if it's just to avoid the pagetable
> > lookups and to be more similar to the other arches numa code.
> 
> The vmem_map is only used statically in arch/ia64/mm/init.c, but we use
> the global mem_map for the macros in include/asm-ia64/pgtable.h for
> convenience.  There are a bunch of cases to deal with:
>   o CONFIG_VIRTUAL_MEM_MAP and !CONFIG_VIRTUAL_MEM_MAP
>   o CONFIG_DISCONTIGMEM and !CONFIG_DISCONTIGMEM
>   o any combination of the two above
> 
> We need CONFIG_VIRTUAL_MEM_MAP and CONFIG_DISCONTIGMEM work together at
> the very least so that ia64 generic kernels will work.

Slightly less ugly hack than the ifdefs in generic code is a

#define mem_map vmem_map somewhere in a ia64 header.  The right fix
is to just always use the per-node mem_map.  For SN2 you probably want
a per-node virtual mem_map then.

