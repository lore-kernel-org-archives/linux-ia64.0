From: Nick Piggin <nickpiggin@yahoo.com.au>
Date: Thu, 16 Dec 2004 00:25:25 +0000
Subject: Re: [very very drafty] prezeroing to increase the page fault rate
Message-Id: <1103156725.5054.10.camel@npiggin-nld.site>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0412141832350.6975@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0412141832350.6975@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 2004-12-15 at 13:58 -0800, Christoph Lameter wrote:
> On Wed, 15 Dec 2004, Robin Holt wrote:
> 
> > > I have some spot results here that indicate that a single thread may
> > > do up to 500000 faults a second with this patch alone.
> >
> > This sounds impressive, but from my limited understanding of the patches,
> > I think it is a misleading figure.  This would require the system to
> > sit idle for a period of time between large jobs to ensure that
> > enough pages are free so all allocations could be satisfied from the
> > pre-zeroed section.
> 
> There is enough time for all pages to be zeroed on bootup so there is
> a large repository of zeroed pages. Of course if the system uses up that
> reservoir and the zeroing is not effectively keeping up then this
> will degenerates into the old behavior.
> 

Just curious - how does this go on a real workload as opposed to
raw pagefault performance?

You said the majority of the time in the fault handler is taken
in zeroing pages, but that does have the upshot of warming up the
cache on memory which is likely to be used soon.

I think if there were *no* downsides to this patch, it would
obviously make sense - because in that case it doesn't really matter
whether the cache is heated by the fault handler or by the app
itself... but it does have some downsides (complexity, memory
bandwidth, cache degradation in the case of idle zeroing, less
predictable performance).

I'm not saying the negatives outweigh the positives, but I wonder.
I think this sort of thing has been contentious in the past.


Also just a stupid question - would an madvise(..., MADV_PREFAULT)
be of use to you? Or is that too difficult to get a good NUMA
allocation layout?

Nick


