From: Andrew Morton <akpm@osdl.org>
Date: Thu, 03 Mar 2005 02:55:08 +0000
Subject: Re: Page fault scalability patch V18: Drop first acquisition of ptl
Message-Id: <20050302185508.4cd2f618.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0503011947001.25441@schroedinger.engr.sgi.com>
	<Pine.LNX.4.58.0503011951100.25441@schroedinger.engr.sgi.com>
	<20050302174507.7991af94.akpm@osdl.org>
	<Pine.LNX.4.58.0503021803510.3080@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0503021803510.3080@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Christoph Lameter <clameter@sgi.com> wrote:
>
> On Wed, 2 Mar 2005, Andrew Morton wrote:
> 
> > > -	if (!PageReserved(old_page))
> > > -		page_cache_get(old_page);
> >
> > hm, this seems to be an unrelated change.  You're saying that this page is
> > protected from munmap() by munmap()'s down_write(mmap_sem), yes?  What
> > stops memory reclaim from freeing old_page?
> 
> This is a related change discussed during V16 with Nick.

It's worth retaining a paragraph for the changelog.

> The page is protected from munmap because of the down_read(mmap_sem) in
> the arch specific code before calling handle_mm_fault.

We don't take mmap_sem during page reclaim.  What prevents the page from
being freed by, say, kswapd?

> > > -	mark_page_accessed(page);
> > > +	SetPageReferenced(page);
> >
> > Another unrelated change.  IIRC, this is indeed equivalent, but I forget
> > why.  Care to remind me?
> 
> Seems that mark_page_accessed was discouraged in favor SetPageReferenced.
> We agreed that we wanted this change earlier (I believe that was in
> November?).

I forget.  I do recall that we decided that the change was OK, but briefly
looking at it now, it seems that we'll fail to move a
PageReferenced,!PageActive onto the active list?

> > Overall, do we know which architectures are capable of using this feature?
> > Would ppc64 (and sparc64?) still have a problem with page_table_lock no
> > longer protecting their internals?
> 
> That is up to the arch maintainers. Add something to arch/xx/Kconfig to
> allow atomic operations for an arch. Out of the box it only works for
> x86_64, ia64 and ia32.

Feedback from s390, sparc64 and ppc64 people would help in making a merge
decision.

> > I'd really like to see other architecture maintainers stand up and say
> > "yes, we need this".
> 
> You definitely need this for machines with high SMP counts.

Well.  We need some solution to the page_table_lock problem on high SMP
counts.

> > Did you consider doing the locking at the pte page level?  That could be
> > neater than all those games with atomic pte operattions.
> 
> Earlier releases back in September 2004 had some pte locking code (and
> AFAIK Nick also played around with pte locking) but that
> was less efficient than atomic operations.

How much less efficient?

Does anyone else have that code around?
