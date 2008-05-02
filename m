From: Russ Anderson <rja@sgi.com>
Date: Fri, 02 May 2008 02:43:43 +0000
Subject: Re: [PATCH 3/3] ia64: Call migration code on correctable errors v2
Message-Id: <20080502024342.GB1591@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080502004425.GD12006@sgi.com> <Pine.LNX.4.64.0805011818100.13527@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0805011818100.13527@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Tony Luck <tony.luck@intel.com>

On Thu, May 01, 2008 at 06:22:29PM -0700, Christoph Lameter wrote:
> On Thu, 1 May 2008, Russ Anderson wrote:
> 
> > +int
> > +freeOneBadPage(unsigned long paddr)
> > +{
> > +	struct page *page, *page2, *target;
> > +
> > +	/*
> > +	 * Verify page address
> > +	 */
> > +	target = phys_to_page(paddr);
> > +	list_for_each_entry_safe(page, page2, &badpagelist, lru) {
> > +		if (page != target)
> > +			continue;
> > +
> > +		ClearPageMemError(page);        /* Mark the page as good */
> > +		move_to_lru(page);
> > +		list_del(&page->lru);
> 
> This is the wrong order. move_to_lru() uses the lru field. So do the 
> list_del first then the move. Note that there is a function 
> putback_lru_pages() that is used to put a list of pages back to the lru if 
> migration has failed and we give up on them. Could you use 
> putback_lru_pages() and then avoid the exporting of move_to_lru()?

I'll put the page on a different list and call putback_lru_pages().

> > +
> > +int
> > +freeAllBadPages(void)
> > +{
> > +	struct page *page, *page2;
> > +
> > +	list_for_each_entry_safe(page, page2, &badpagelist, lru) {
> > +		ClearPageMemError(page);        /* Mark the page as good */
> > +		totalbad_pages--;
> > +	}
> > +	putback_lru_pages(&badpagelist);
> > +	return 0;
> > +}
> 
> Ahh.. Here you use it.

This is when deleting all the pages on the list.

> > Index: linus/include/asm-ia64/page.h
> > =================================> > --- linus.orig/include/asm-ia64/page.h	2008-05-01 19:36:40.000000000 -0500
> > +++ linus/include/asm-ia64/page.h	2008-05-01 19:36:49.000000000 -0500
> > @@ -122,6 +122,7 @@ extern unsigned long max_low_pfn;
> >  #endif
> >  
> >  #define page_to_phys(page)	(page_to_pfn(page) << PAGE_SHIFT)
> > +#define	phys_to_page(kaddr)	(pfn_to_page(kaddr >> PAGE_SHIFT))
> 
> #define phys_to_page virt_to_page ?

I'm not sure what you are asking.

#define phys_to_page(kaddr)     (pfn_to_page(kaddr >> PAGE_SHIFT))
#define virt_to_page(kaddr)     pfn_to_page(__pa(kaddr) >> PAGE_SHIFT)

Do you mean change virt_to_page() like this?

#define virt_to_page(kaddr)     phys_to_page(__pa(kaddr))

Thanks,
-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
