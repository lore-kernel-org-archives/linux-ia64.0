From: "Bob Picco" <bob.picco@hp.com>
Date: Wed, 12 Apr 2006 17:36:40 +0000
Subject: Re: show_mem() for ia64 discontig takes a really long time on large systems.
Message-Id: <20060412173640.GH23742@localhost>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060328184315.GA8162@lnx-holt.americas.sgi.com>
In-Reply-To: <20060328184315.GA8162@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Robin Holt wrote:	[Wed Apr 12 2006, 03:18:55AM EDT]
> On Thu, Mar 30, 2006 at 09:48:18AM -0800, Chen, Kenneth W wrote:
> > Jack Steiner wrote on Thursday, March 30, 2006 9:29 AM
> > > > Time is wasted trying to fill the TLB entry for the vmem_map.  When it
> > > > fails, we show_mem() advances to the next page which repeats the sequence.
> > > > Jack had thrown out a couple suggestions.  One was essentially what
> > > > you proposed below.  The other was advance i to point the next page
> > > > of pfns.  He frowned when saying the second, but I don't recall exactly
> > > > why he frowned.
> > > 
> > > Advancing to the next page will be considerably faster but I wonder if
> > > it is fast enough.
> > > 
> ...
> > > My gut feeling is that is not good enough. 
> > 
> > What about the earlier proposal of advancing at pmd and pud granule by
> > walking the page table?  There it can walk at 32MB/64GB step.
> 
> Does the attached seem like the right direction?  I have tested it on
> the simulator and it seems _much_ faster, but that is the simulator.
> I have time reserved on the machine where the problem was first observed
> later today to test it on actual hardware.
> 
> Thanks,
> Robin
> 
> 
> Index: linux-2.6/arch/ia64/mm/discontig.c
> =================================> --- linux-2.6.orig/arch/ia64/mm/discontig.c	2006-04-11 16:06:54.243967238 -0500
> +++ linux-2.6/arch/ia64/mm/discontig.c	2006-04-12 02:16:46.111406150 -0500
> @@ -567,8 +567,68 @@ void show_mem(void)
>  			struct page *page;
>  			if (pfn_valid(pgdat->node_start_pfn + i))
>  				page = pfn_to_page(pgdat->node_start_pfn + i);
> -			else
> +			else {
Looks great and will work for VIRTUAL_MEM_MAP.  It's too bad SPARSEMEM
can't be used because this probably wouldn't be an issue.  

I think this will break SPARSEMEM. Perhaps it's time to create a new
module with VIRTUAL_MEM_MAP specific code in it. Say like vmemmap.c.
Lots of code in init.c and this new code could reside in this new
module. Just a thought.  You'll need a compile time optimized out feature for 
SPARSEMEM but for VIRTUAL_MEM_MAP a function call could be called.

bob
[snip]
