From: Christoph Lameter <clameter@sgi.com>
Date: Thu, 16 Dec 2004 00:41:06 +0000
Subject: Re: [very very drafty] prezeroing to increase the page fault rate
Message-Id: <Pine.LNX.4.58.0412151633270.14157@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0412141832350.6975@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0412141832350.6975@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 16 Dec 2004, Nick Piggin wrote:

> Just curious - how does this go on a real workload as opposed to
> raw pagefault performance?

No idea. Not tested yet. The bench models the startup behavior
of many large scale apps though. I am trying to find some other tests
that are nearer to reality and see what other effects this has. Lmbench
shows some interesting things but I need to finish that first.

> You said the majority of the time in the fault handler is taken
> in zeroing pages, but that does have the upshot of warming up the
> cache on memory which is likely to be used soon.

Right. The test that I am using only touches one word of each page so it
is not reflecting what a real application would be doing. The patch makes
the page zeroing engine stay away from the hot pages in the pcp structure
though.

> I think if there were *no* downsides to this patch, it would
> obviously make sense - because in that case it doesn't really matter
> whether the cache is heated by the fault handler or by the app
> itself... but it does have some downsides (complexity, memory
> bandwidth, cache degradation in the case of idle zeroing, less
> predictable performance).

I am also not sure if this will make sense. But its something that I felt
had to be tried.

> I'm not saying the negatives outweigh the positives, but I wonder.
> I think this sort of thing has been contentious in the past.

Andrea's patches last summer zeroed hot pages. I think that is definitely
not useful. The zeroing must have minimal impact otherwise this wont work.
The best thing would be to have some dma device that does the zeroing
without touching the cache.

> Also just a stupid question - would an madvise(..., MADV_PREFAULT)
> be of use to you? Or is that too difficult to get a good NUMA
> allocation layout?

Its easy to implement. The current code already checks for MADV_RAND and
switches off prefaulting for that case.
