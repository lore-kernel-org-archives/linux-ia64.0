From: Robin Holt <holt@sgi.com>
Date: Mon, 07 Mar 2005 12:57:41 +0000
Subject: Re: [Patch 0/3] Page table quicklist fixups Rev 3.
Message-Id: <20050307125741.GB9835@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050303212359.GA732@lnx-holt.americas.sgi.com>
In-Reply-To: <20050303212359.GA732@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Mar 04, 2005 at 02:33:56PM -0800, Chen, Kenneth W wrote:
> Luck, Tony wrote on Friday, March 04, 2005 11:58 AM
> > >You tell me what to do.
> >
> > At the moment I'm hoping somebody smarter will chime into this thread
> > (either to point out a great solution, or to tell me that I'm a dork
> > and this code is perfectly reasonable, so I should quit quibbling).
> >
> > Overall the patch is great ... it's solving a real problem in an elegant
> > way.  It's just this little corner of how to shrink the quicklists that
> > I'm trying to get right.
> 
> One other possible solution I can think of is to use schedule_delayed_work
> API.  You can schedule one per node every one second interval and have the
> work function re-arm itself.  It has several pros:
> 

We need to use schedule_delayed_work_on() instead since the quicklists are
maintained lockless per cpu.  Will this method address everybody's concerns?


> 1. Addresses the concern that Tony has with SETI eating up all the idle
>    ticks and check_pgt_cache() may never get a chance to run.

SETI is a bad example because it uses mmap() and munmap constantly which
will walk the code path in question.

> 2. once work is scheduled, you don't need to dance with batch count.
>    Just keep on freeing in one while loop since it is running in a kernel
>    thread.

I don't know I we are thinking the same thing here.  I would remove the
while loop and let the next pass complete the frees.

> 3. Potentially, call to check_pgt_cache from tlb_finish_mmu() can be
>    removed, making process exit faster.

I think this one is still useful as it will keep the quicklist closer to
the ideal size.  If we limit it to 256 quicklist entries per pass, that
should keep the quicklists reasonably sized.

> 4. And last, probably not important, addresses my concern of broken model
>    (freeing memory in idle loop).

Tony, is this going to be acceptable?  Should it be the work queue or
timer based?

Thanks,
Robin
