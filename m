From: Robin Holt <holt@sgi.com>
Date: Fri, 04 Mar 2005 14:55:22 +0000
Subject: Re: [Patch 0/3] Page table quicklist fixups Rev 3.
Message-Id: <20050304145522.GA14228@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050303212359.GA732@lnx-holt.americas.sgi.com>
In-Reply-To: <20050303212359.GA732@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Mar 04, 2005 at 04:03:38PM +0800, Zou Nan hai wrote:
> On Fri, 2005-03-04 at 16:46, Robin Holt wrote:
> > What do you want me to do.  I don't see anywhere else in the kernel
> > that these two lines are directly adjacent.  Most places that do
> > the disable/enable are in a function which does one thing.  That is
> > occasionally contained inside a larger loop.  We can not do that since
> > part of our outer loop control is based on the per_cpu variable we are
> > expecting to not change.  I suppose I could elminitate the disable/enable
> > entirely.  I haven't thought all the way through the possibilities,
> > but I would guess we could free a couple extra pages, but who cares.
> > You tell me what to do.
> > 
> > Robin
> 
>   I think there is no need to disable preempt in an idle thread...,
> since the idle thread has no chance to migrate to another CPU.
> 
>   I also think that the shrinking of pgtables is a bit like that in
> shrink_slab in vmscan.c, shrink_slab shrinks slab by batch, and itcalls
> cond_resched every batch. 
> So that it will not introduce too big latency when there are too many
> slabs to shrink. 
> While shrink_slab is called under mem pressure but check_pdt_cache is
> called in idle thread, maybe there is some difference.

I think that would be changing the behavior.  For the idle case, I don't
think calling cond_resched is that much of a difference.  For the case
where a process has completed an unmap and called tlb_finish_mmu which
has in turn called check_pgt_cache(), we would be allowing another
process of the same priority to take the remainder of our time slice.
With the preempt_enable/disable, we are only allowing others to run when
I have either exhausted my time slice or they are a higher priority.

I am trying to get some figure out times that would be adversely affected
by the preempt_enable/disable pairing.  At this time, I do not see the
issue, but maybe I have missed something.

Thanks,
Robin
