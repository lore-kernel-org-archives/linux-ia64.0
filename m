From: jbarnes@sgi.com (Jesse Barnes)
Date: Wed, 18 Jun 2003 17:10:40 +0000
Subject: Re: [Discontig-devel] [RFC/PATCH] discontig update for linux-ia64-2.5 bk tree
Message-Id: <marc-linux-ia64-105595624919489@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105595612419340@msgid-missing>
In-Reply-To: <marc-linux-ia64-105595612419340@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Jun 18, 2003 at 09:54:40AM -0700, Martin J. Bligh wrote:
> 
> You seem to have missed the comments here:
> 
> > -#ifndef CONFIG_DISCONTIGMEM          /* Don't use mapnrs, do it properly */
> > extern unsigned long max_mapnr;
> > -#endif
> > ...
> > -#ifndef CONFIG_DISCONTIGMEM
> > /* The array of struct pages - for discontigmem use pgdat->lmem_map */
> >  extern struct page *mem_map;
> > -#endif 
> 
> Using global mapnrs for discontigmem is a horrible kludge, and very 
> confusing. There was a damned good reason I removed those ...
> 
> It should be easy to just use local offsets into the node, right?

I'll look at this.

> > diff -Nru a/mm/page_alloc.c b/mm/page_alloc.c
> > --- a/mm/page_alloc.c	Tue Jun 17 14:45:16 2003
> > +++ b/mm/page_alloc.c	Tue Jun 17 14:45:16 2003
> > @@ -57,12 +57,15 @@
> >   */
> >  static int bad_range(struct zone *zone, struct page *page)
> >  {
> > -	if (page_to_pfn(page) >= zone->zone_start_pfn + zone->spanned_pages)
> > +	if (page_to_pfn(page) >= zone->zone_start_pfn + zone->spanned_pages) {
> >  		return 1;
> > -	if (page_to_pfn(page) < zone->zone_start_pfn)
> > +	}
> > +	if (page_to_pfn(page) < zone->zone_start_pfn) {
> >  		return 1;
> > -	if (zone != page_zone(page))
> > +	}
> > +	if (zone != page_zone(page)) {
> >  		return 1;
> > +	}
> >  	return 0;
> >  }
> 
> Why? this just looks like removing standard Linux style? 
> Is there a real change hidden in there?

Oops, that one stuck past me.

Thanks,
Jesse
