From: Christoph Lameter <clameter@sgi.com>
Date: Thu, 03 Mar 2005 03:17:19 +0000
Subject: Re: Page fault scalability patch V18: Drop first acquisition of ptl
Message-Id: <Pine.LNX.4.58.0503021856380.3365@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0503011947001.25441@schroedinger.engr.sgi.com>
 <Pine.LNX.4.58.0503011951100.25441@schroedinger.engr.sgi.com>
 <20050302174507.7991af94.akpm@osdl.org> <Pine.LNX.4.58.0503021803510.3080@schroedinger.engr.sgi.com>
 <20050302185508.4cd2f618.akpm@osdl.org>
In-Reply-To: <20050302185508.4cd2f618.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Wed, 2 Mar 2005, Andrew Morton wrote:

> > This is a related change discussed during V16 with Nick.
>
> It's worth retaining a paragraph for the changelog.

There have been extensive discussions on all aspects of this patch.
This issue was discussed in
http://marc.theaimsgroup.com/?t0694497200004&r=1&w=2

>
> > The page is protected from munmap because of the down_read(mmap_sem) in
> > the arch specific code before calling handle_mm_fault.
>
> We don't take mmap_sem during page reclaim.  What prevents the page from
> being freed by, say, kswapd?

The cmpxchg will fail if that happens.

> I forget.  I do recall that we decided that the change was OK, but briefly
> looking at it now, it seems that we'll fail to move a
> PageReferenced,!PageActive onto the active list?

See http://marc.theaimsgroup.com/?l=bk-commits-head&m0481975332117&w=2

and

http://marc.theaimsgroup.com/?l=linux-kernel&m0272296503539&w=2

> > That is up to the arch maintainers. Add something to arch/xx/Kconfig to
> > allow atomic operations for an arch. Out of the box it only works for
> > x86_64, ia64 and ia32.
>
> Feedback from s390, sparc64 and ppc64 people would help in making a merge
> decision.

These architectures have the atomic pte's not enable. It would require
them to submit a patch to activate atomic pte's for these architectures.

> > You definitely need this for machines with high SMP counts.
>
> Well.  We need some solution to the page_table_lock problem on high SMP
> counts.

Great!

> > Earlier releases back in September 2004 had some pte locking code (and
> > AFAIK Nick also played around with pte locking) but that
> > was less efficient than atomic operations.
>
> How much less efficient?
> Does anyone else have that code around?

Nick may have some data. It got far too complicated too fast when I tried
to introduce locking for individual ptes. It required bit
spinlocks for the pte meaning multiple atomic operations. One
would have to check for the lock being active leading to significant code
changes. This would include the arch specific low level fault handers to
update bits, walk the page table etc etc.
