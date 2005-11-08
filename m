From: "Magenheimer, Dan (HP Labs Fort Collins)" <dan.magenheimer@hp.com>
Date: Tue, 08 Nov 2005 18:52:38 +0000
Subject: RE: [RFC] 4-level page table directories.
Message-Id: <516F50407E01324991DD6D07B0531AD57E7EA2@cacexc12.americas.cpqcorp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051027041709.GA13193@attica.americas.sgi.com>
In-Reply-To: <20051027041709.GA13193@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Just a thought... shouldn't it be possible (at least in theory)
for all the page table macros to be made a bit more dynamically
flexible so that PAGESIZE can (at least optionally) be specified
as a boottime parameter?  For example (very loosely):

#define pgd_macro(x,y,z) \
( \
if (unlikely(boottime_pagesize)) _pgd_macro(boottime_pagesize,x,y,z); \
else _pgd_macro(PAGESIZE,x,y,z); \
)

The cost is of course a global (or cpu) variable access for
every pud/pgd/pmd/pte macro usage, but one would expect the
global would always be in cache/TLB so the performance impact
should be near zero.  Boottime_pagesize could even be optionally
define'd to 0 so, in the case where "near zero" is not good
enough, cpp could make the extra variable access go away.

The same trick could potentially be used to determine whether
to use a 4-level or 3-level page table at runtime.

A big advantage of this is that distros only need deliver a
single kernel (even if it is still prudent to test that binary
with multiple boottime_pagesize's).  It also is much more flexible
for customers who know how their machine is going to be used but
do not want to build their own kernel.  (E.g. in Hans' example,
maybe the best PAGESIZE choice is 4K or in some database app
maybe the best PAGESIZE choice is 1MB... distros will probably
never ship either of these.)

Seems like this would be useful for a number of arch's so even
if it requires some common changes, it could fly.

Comments?

Dan Magenheimer
HP Labs

> -----Original Message-----
> From: linux-ia64-owner@vger.kernel.org 
> [mailto:linux-ia64-owner@vger.kernel.org] On Behalf Of Boehm, Hans
> Sent: Tuesday, November 08, 2005 11:24 AM
> To: Robin Holt; Rohit Seth
> Cc: Gerald Pfeifer; Ian Wienand; linux-ia64@vger.kernel.org; 
> david.mosberger@acm.org
> Subject: RE: [RFC] 4-level page table directories.
> 
> > -----Original Message-----
> > From: Robin Holt
> > 
> > There is also the possibility that the app may be using the 
> > pages sparsely and therefore wasting a larger percentage of 
> > time zeroing memory which is never needed (smaller percent of 
> > page fill).
> > 
> And, perhaps less significantly, there is a small set of applications
> that try to use page protection to track accesses, e.g. for 
> incremental
> GC, faster checkpointing, or software DSM.  I expect those would
> generally do considerably worse with 64K pages.
> 
> Hans
> -
> To unsubscribe from this list: send the line "unsubscribe 
> linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
