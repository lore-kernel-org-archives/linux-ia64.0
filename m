From: Bob Picco <bob.picco@hp.com>
Date: Wed, 25 May 2005 23:20:35 +0000
Subject: Re: [patch 0/4] V2 ia64 SPARSEMEM
Message-Id: <20050525232035.GH23448@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050525151347.GB23448@localhost.localdomain>
In-Reply-To: <20050525151347.GB23448@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Jack Steiner wrote:	[Wed May 25 2005, 06:44:06PM EDT]
> On Wed, May 25, 2005 at 11:13:47AM -0400, Bob Picco wrote:
> ...
> > and HPSIM.  An early version of ia64 with SPARSEMEM was tested by Jesse. It
> > would be optimal to have another test pass on SGI NUMA hardware.
> 
> 
> I'm away from the office this week, but next week, I'll give the patch
> another spin on a big SGI system.
Great!
> 
> >
> >
> > VIRTUAL_MEM_MAP was introduced on ia64 because of memory holes on ia64
> > platforms. The mem_map of the pglist_data is a pointer to a virtual
> > contiguous array of page structures in memory for a node.  To
> > eliminate memory waste contiguous memory holes don't have page structures.
> > The alternative would be for holes in memory to be represented by reserve
> > page structures.  The VIRTUAL_MEM_MAP solutions requires ia64_pfn_valid
> > and a hook in the buddy allocator to check for holes in memory.
> >
> > SPARSEMEM has eliminated mem_map, ia64_pfn_valid and the buddy allocator
> > hook.  There is a small cost for SPARSEMEM.  Any section which has both
> > memory and holes requires reserved pages for the holes.  I can see
> 
> Our systems are notorious for having large holes in memory on nodes. For example,
> a node may have memory at node offsets 0, 16GB, 32GB & 48GB. At each offset, you
> can have a chunk of 1 to 16GB. For example, a typical system might have memory 
> at the following node offsets:
>     Memory at
>          0 -  4GB
> 	16 - 20GB
> 	32 - 36GB
> 	48 - 52GB
> 
> You are guaranteed to have memory at node offset 0. Memory may or
> may not exist at the other offsets.
> 
> I haven't had a chance to look at the patch, but will page struct entries 
> will be allocated for the pages in the holes (4GB-16GB, etc).
No there won't be page structures allocated for regions which are holes.
The default SECTION_BITS value of 28 is for a 256Mb aligned section. So memory
not reported (via efi memory descriptor walk) in a section  won't have page 
structs. The function register_sparse_mem in discontig.c calls SPARSEMEM
to validate a memory section. Only valid sections are subject to page
structure allocation later in initialization.
> 
> 
> 
> -- 
> Thanks
> 
> Jack Steiner (steiner@sgi.com)          651-683-5302
> Principal Engineer                      SGI - Silicon Graphics, Inc.
> 
your welcome and thanks,

bob
> 
