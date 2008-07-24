From: Nick Piggin <nickpiggin@yahoo.com.au>
Date: Thu, 24 Jul 2008 00:44:34 +0000
Subject: Re: [PATCH 1/2] mm: Avoid putting a bad page back on the LRU v7
Message-Id: <200807241044.35027.nickpiggin@yahoo.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080718203606.GE29621@sgi.com> <200807221242.10552.nickpiggin@yahoo.com.au> <20080723221338.GB193408@sgi.com>
In-Reply-To: <20080723221338.GB193408@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Russ Anderson <rja@sgi.com>
Cc: mingo@elte.hu, tglx@linutronix.de, Tony Luck <tony.luck@intel.com>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Thursday 24 July 2008 08:13, Russ Anderson wrote:
> On Tue, Jul 22, 2008 at 12:42:10PM +1000, Nick Piggin wrote:
> > On Saturday 19 July 2008 06:36, Russ Anderson wrote:
> > > [PATCH 1/2] mm: Avoid putting a bad page back on the LRU v7
> > >
> > > Prevent a page with a physical memory error from being placed back
> > > on the LRU.  A new page flag (PG_memerror) is added if
> > > CONFIG_PAGEFLAGS_EXTENDED is defined.
> > >
> > > Signed-off-by: Russ Anderson <rja@sgi.com>
> > > Reviewed-by: Christoph Lameter <clameter@sgi.com>
> > >
> > > ---
> > >  include/linux/page-flags.h |   18 ++++++++++++++++--
> > >  mm/migrate.c               |   31 ++++++++++++++++++++++++++++++-
> > >  mm/page_alloc.c            |   13 ++++++++-----
> > >  3 files changed, 54 insertions(+), 8 deletions(-)
> > >
> > > Index: linux/mm/page_alloc.c
> > > =================================> > > --- linux.orig/mm/page_alloc.c	2008-07-18 15:15:48.000000000 -0500
> > > +++ linux/mm/page_alloc.c	2008-07-18 15:16:09.000000000 -0500
> > > @@ -602,10 +602,10 @@ static int prep_new_page(struct page *pa
> > >  		bad_page(page);
> > >
> > >  	/*
> > > -	 * For now, we report if PG_reserved was found set, but do not
> > > -	 * clear it, and do not allocate the page: as a safety net.
> > > +	 * For now, we report if PG_reserved or PG_memerror was found set,
> > > but +	 * do not clear it, and do not allocate the page: as a safety
> > > net. */
> > > -	if (PageReserved(page))
> > > +	if (PageReserved(page) || PageMemError(page))
> > >  		return 1;
> > >
> > >  	page->flags &= ~(1 << PG_uptodate | 1 << PG_error | 1 << PG_reclaim |
> > > @@ -2475,8 +2475,11 @@ static void setup_zone_migrate_reserve(s
> > >  			continue;
> > >  		page = pfn_to_page(pfn);
> > >
> > > -		/* Blocks with reserved pages will never free, skip them. */
> > > -		if (PageReserved(page))
> > > +		/*
> > > +		 * Blocks with reserved pages or memory errors will never
> > > +		 * free, skip them.
> > > +		 */
> > > +		if (PageReserved(page) || PageMemError(page))
> > >  			continue;
> > >
> > >  		block_migratetype = get_pageblock_migratetype(page);
> >
> > I don't like adding more branches like this into fastpaths like this. It
> > would make a lot more sense to me if you just had some private module
> > that does the job of isolating the page from the lru and/or elevating
> > their refcount so that they do not get put back on freelists.
>
> That is how it works.  If PageMemError is set the migration code
> leaves the page with an elevated refcount.  The PageMemError() check
> was to avoid reallocating the page was an additional safty net.
> I'll pull the checks.

Ah, if it's that easy, great, then I have no problems with the patch.
Note that I have no problems with putting a VM_BUG_ON(PageMemError())
or something like that instead -- perhaps not quite the safty net you
would like. But helpful for developers and testers, and it acts as a
helpful little comment.

