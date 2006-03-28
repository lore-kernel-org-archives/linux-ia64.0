From: Dave Hansen <haveblue@us.ibm.com>
Date: Tue, 28 Mar 2006 19:16:19 +0000
Subject: Re: show_mem() for ia64 discontig takes a really long time on
Message-Id: <1143573379.9731.37.camel@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060328184315.GA8162@lnx-holt.americas.sgi.com>
In-Reply-To: <20060328184315.GA8162@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 2006-03-28 at 12:43 -0600, Robin Holt wrote:
> The system was a fully populated 512 node SGI machine.  The way that
> memory is physically layed out results in a single pgdat which covers
> the node with two holes in it.  This is new hardware with larger gaps
> between the chunks of memory that earlier version had.  As show_mem()
> is traversing the entire systems memory to print out stats on remaining
> memory, it takes faults while trying to look at holes in the array of
> struct pages.

Could you explain a bit how this works on ia64?  I know about the
vmem_map.  Is the time spent on filling TLB entries when you hit a
'struct page' that isn't backed by real memory?

> At this point, I am looking for any sort of direction on what would be
> a reasonable fix.  Should show_mem() be made to skip to a page aligned
> point in the array when the fault fails?

Yeah, this would be my first instinct.  Perhaps a function like:

unsigned long hole_nr_pages(unsigned long pfn)
{
}

For sparsemem, it could just return PAGES_PER_SECTION.  For
architectures like ia64, it could either return the minimum hole size,
or be smarter and go look in some arch-specific information to find the
real hole size.  

Maybe something like this in your show_mem():

        for_each_pgdat(pgdat) {
		...
                for(i = 0; i < pgdat->node_spanned_pages; i++) {
                        struct page *page;
                        if (pfn_valid(pgdat->node_start_pfn + i))
                                page = pfn_to_page(pgdat->node_start_pfn + i);
                        else
-				continue;
+				/* -1 to offset i++ */
+                              	pfn += hole_nr_pages(pfn) - 1;

> Should we add the information
> about start and end of hole to the pgdat()?

No.  No.  Please, no. :)

Sparsemem is pretty good at this already.  Also, the whole idea of
DISCONTIGMEM was to have a pgdat that describes a contiguous area.
We've massacred that concept with NUMA stuff since then, but that _was_
the original idea.  

> Should we have one pgdat per chunk?

That's one concept that probably won't work today.  I went and tried to
untangle DISCONTIG node ids from NUMA node ids one day and failed
miserably.  They're too intertwined.

> Are there other better ideas out there?  Any direction would
> be greatly appreciated.

Get rid of the silly vmem_map[] :)

-- Dave

