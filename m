From: Jack Steiner <steiner@sgi.com>
Date: Thu, 13 May 2004 16:33:25 +0000
Subject: Re: Who's doing what with cpu/memory/node hotplug?
Message-Id: <20040513163325.GB30758@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040512205107.16bb82a6.pj@sgi.com>
In-Reply-To: <20040512205107.16bb82a6.pj@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, May 13, 2004 at 09:01:48AM -0700, Dave Hansen wrote:
> On Thu, 2004-05-13 at 07:00, Jack Steiner wrote:
> > Where can I find a copy of the latest CONFIG_NONLINEAR patch? I recall
> > one that was posted by Dave McCracken in early Apr. Is that the one I should
> > review?
> 
> There are a few bugfixes on top of it since then, but most of it remains
> untouched.  

Ok, I grab that patch & take a look.


> 
> > When we did the initial implementation of CONFIG_DISCONTIGMEM, we
> > looked briefly at the CONFIG_NONLINEAR patch (or idea) that was
> > floating around at that time. The patch may have changed so some of 
> > my initial concerns may no longer apply, but the early patch would
> > not have performed very well on the SGI hardware. 
> > 
> > The SGI architecture has an absurdly sparse address space. The smallest
> > memory block is 64MB but the max physical address is 49 bits (500TB).  
> > IIRC, this resulted in some very large tables used to convert between 
> > logical & physical addresses. Because of the size of these tables, cache
> > misses would be common on references to these tables. Is this still a 
> > valid concern???
> 
> Our address space on ppc64 isn't that sparse, but we may be dealing with
> memory sections that are as small as 16MB.  Our problem is that any of
> those 16MB sections of memory is removable, which means that we are
> going to get some sparse data structures if a machine isn't populated
> with a significant portion of its capacity of RAM.
> 
> But, one cool/horrifying thing is that it appears that ppc64 is somewhat
> dynamic about what these section sizes are.  On power4, they're fixed at
> 256MB, but on power5, they can go as small as 16MB, determined at boot. 
> But, we don't really know what the size is going to be until we're
> booted, and we run the same binaries everywhere.
> 
> We're probably going to need something other than statically allocated
> nonlinear arrays eventually.  As you eluded to, there are 2 things that
> combined will make nonlinear bad on the cache: sparse physical addresses
> spaces and small memory sections.  However, small sections aren't really
> all that common, especailly on big machines.  Most of the machines that
> we deal with are going to be presenting their memory in pretty
> contiguous regions.  If we can make nonlinear more dynamic, we could
> shrink the arrays in all of the common cases, leaving only the
> pathological memory removal, or machines that really *do* dole out
> memory in 64MB sections, which are probably virutalized anyway. 
> 
> I don't doubt that your architecture allows memory addition in units as
> small as 64MB, but what is it in practice?  

It really is 64MB - at least that is the largest power of 2 that
evenly divides into the size of a chunk of memory.

We currently support 512MB, 1GB & 2GB DIMMs. Memory is populated in
multiples of 4 DIMMs. That means that memory will PHYSICALLY be
in chunks of 2GB, 4 GB or 8GB of contiguous memory.  The memory
on a node consists of up to 4 chunks of memory located at 
offset 0, 16GB, 32GB & 48GB of the nodes memory space. 

The memory directory (used for tracking coherency) is allocated within
each chunk of memory. The directory occupied the top 1/32 of the chunk.
This memory is not accessible to software - a bus error occurs if
software tries to access the directory. 1/32 of a 2GB chunk of memory
is where I got 64MB. Maybe there is another way to handle the
"missing" 64MB of a 2GB chunk of memory.

The other oddity of the SN architecture is that there is no memory
at physical address 0. Physical memory on node 0 starts at 384GB.



> 
> You could always sparsely allocate the nonlinear arrays, and handle
> faults on them like you do mem_map ;)
> 
> -- Dave

-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


