From: Jack Steiner <steiner@sgi.com>
Date: Thu, 30 Mar 2006 17:29:18 +0000
Subject: Re: show_mem() for ia64 discontig takes a really long time on large systems.
Message-Id: <20060330172918.GA27076@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060328184315.GA8162@lnx-holt.americas.sgi.com>
In-Reply-To: <20060328184315.GA8162@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Mar 28, 2006 at 02:56:40PM -0600, Robin Holt wrote:
> On Tue, Mar 28, 2006 at 11:16:19AM -0800, Dave Hansen wrote:
> > Could you explain a bit how this works on ia64?  I know about the
> > vmem_map.  Is the time spent on filling TLB entries when you hit a
> > 'struct page' that isn't backed by real memory?
> 
> Time is wasted trying to fill the TLB entry for the vmem_map.  When it
> fails, we show_mem() advances to the next page which repeats the sequence.
> Jack had thrown out a couple suggestions.  One was essentially what
> you proposed below.  The other was advance i to point the next page
> of pfns.  He frowned when saying the second, but I don't recall exactly
> why he frowned.

Advancing to the next page will be considerably faster but I wonder if
it is fast enough.

There are huge gaps in the virtual vmem_map. On shub2, for example, it
is possible to have 180GB of unpopulated memory in the holes
between memory banks on a node (mode=0).

Assuming 56 bytes per struct_page, that gives:
	
	- 180GB = 11M pages 
	- 38000 pages of struct_page entries
	- 38000 TLB faults to scan the holes in a node

That is a lot of tlbmisses to scan a node. Multiply by 512 to
get the number of faults to scan a full 512n system.

My gut feeling is that is not good enough. 



	


> 
> > Maybe something like this in your show_mem():
> > 
> >         for_each_pgdat(pgdat) {
> > 		...
> >                 for(i = 0; i < pgdat->node_spanned_pages; i++) {
> >                         struct page *page;
> >                         if (pfn_valid(pgdat->node_start_pfn + i))
> >                                 page = pfn_to_page(pgdat->node_start_pfn + i);
> >                         else
> > -				continue;
> > +				/* -1 to offset i++ */
> > +                              	pfn += hole_nr_pages(pfn) - 1;
> > 

-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


