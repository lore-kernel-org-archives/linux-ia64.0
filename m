From: "Van Maren, Kevin" <kevin.vanmaren@unisys.com>
Date: Wed, 12 Nov 2003 18:14:05 +0000
Subject: RE: discontig patch question
Message-Id: <marc-linux-ia64-106866086716324@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106847971018555@msgid-missing>
In-Reply-To: <marc-linux-ia64-106847971018555@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The system boots and functions properly with 4GB nodes, using
#define ORDERROUNDDOWN(n) ((n) & ~((PAGE_SIZE<<MAX_ORDER-1)-1))
Leaving it out (1GB boundary) the kernel doesn't boot (memory
allocation problem).  But I'm (obviously) not using 4GB pages.

So either that fix or dropping MAX_ORDER needs to be made.

Kevin Van Maren

> -----Original Message-----
> From: linux-ia64-owner@vger.kernel.org
> [mailto:linux-ia64-owner@vger.kernel.org]On Behalf Of Seth, Rohit
> Sent: Monday, November 10, 2003 1:21 PM
> To: Jesse Barnes; Van Maren, Kevin
> Cc: linux-ia64@vger.kernel.org
> Subject: RE: discontig patch question
> 
> 
> 
> In my opinion since the other zone build functions depend on (1UL <<
> MAX_ORDER -1) for forcing the zone alignment, so the same 
> should be used
> here in ORDERSDOWN also.  If that seems too aggressive for any reason
> then you should change the ORDERROUNDDOWN minimally to have (PAGE_SIZE
> << (MAX_ORDER -1)).  That should align the modules at 4G boundary for
> 16K PAGE_SIZE. 
> 
> Hugetlb needs certain order (of NORMAL_PAGE_SIZE)of 
> contiguous pages to
> be available for allocation.  The start of this allocation needs to be
> at least HUGE_PAGE_SIZE_ALIGNED.  And I think that part is 
> guaranteed by
> buddy page_allocator(while allocating a certain order of pages).
> 
> 
> rohit
> 
> > -----Original Message-----
> > From: Jesse Barnes [mailto:jbarnes@sgi.com]
> > Sent: Monday, November 10, 2003 11:09 AM
> > To: Van Maren, Kevin
> > Cc: Seth, Rohit; linux-ia64@vger.kernel.org
> > Subject: Re: discontig patch question
> > 
> > On Mon, Nov 10, 2003 at 12:34:47PM -0600, Van Maren, Kevin wrote:
> > > > Yeah, but 1UL<<MAX_ORDER will always be page aligned, right?
> > >
> > > Only if MAX_ORDER >= PAGE_SHIFT.
> > >
> > > But page alignment isn't the question: it is already aligned to
> > > the 16MB or 64MB granules.
> > 
> > Right.  Spaced out there for a minute...
> > 
> > > But you are saying that the address doesn't have to be as strict:
> > > even if allocating 2^MAX_ORDER _pages_, the start doesn't have to
> > > be aligned at a natural (PAGE_SIZE<<MAX_ORDER) boundary, and that
> > > we can change the ORDERROUNDDOWN to not be as aggressive.
> > 
> > Well, strictly speaking I don't think start _has_ to align on those
> > conditions, but the hugetlb stuff may that it does (I 
> haven't looked).
> > 
> > > But then it also makes sense to have a smaller MAX_ORDER when not
> > > using 4GB hugepages?  I'm happy with <= 256MB hugepages with 16GB
> ram,
> > > so I guess I'd rather MAX_ORDER was normally smaller, and 
> increased
> > > only with very large hugepage pages.
> > 
> > That makes sense to me.  It seems like FORCE_MAX_ZONEORDER should
> depend
> > on HUGETLB_PAGE_SIZE_* so that we don't apply unnecessary alignment
> > constraints.  Of course, there's probably something I'm 
> missing, Rohit
> > might know more.
> > 
> > Jesse
> -
> To unsubscribe from this list: send the line "unsubscribe 
> linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
