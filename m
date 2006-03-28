From: Robin Holt <holt@sgi.com>
Date: Tue, 28 Mar 2006 20:56:40 +0000
Subject: Re: show_mem() for ia64 discontig takes a really long time on large systems.
Message-Id: <20060328205639.GC8162@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060328184315.GA8162@lnx-holt.americas.sgi.com>
In-Reply-To: <20060328184315.GA8162@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Mar 28, 2006 at 11:16:19AM -0800, Dave Hansen wrote:
> Could you explain a bit how this works on ia64?  I know about the
> vmem_map.  Is the time spent on filling TLB entries when you hit a
> 'struct page' that isn't backed by real memory?

Time is wasted trying to fill the TLB entry for the vmem_map.  When it
fails, we show_mem() advances to the next page which repeats the sequence.
Jack had thrown out a couple suggestions.  One was essentially what
you proposed below.  The other was advance i to point the next page
of pfns.  He frowned when saying the second, but I don't recall exactly
why he frowned.

> Maybe something like this in your show_mem():
> 
>         for_each_pgdat(pgdat) {
> 		...
>                 for(i = 0; i < pgdat->node_spanned_pages; i++) {
>                         struct page *page;
>                         if (pfn_valid(pgdat->node_start_pfn + i))
>                                 page = pfn_to_page(pgdat->node_start_pfn + i);
>                         else
> -				continue;
> +				/* -1 to offset i++ */
> +                              	pfn += hole_nr_pages(pfn) - 1;
> 
