From: Robin Holt <holt@sgi.com>
Date: Mon, 28 Feb 2005 22:47:21 +0000
Subject: Re: [Patch 0/3] Page Table Fixups.
Message-Id: <20050228224721.GA21674@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050226142250.GB10965@lnx-holt.americas.sgi.com>
In-Reply-To: <20050226142250.GB10965@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> But I'm a little worried about this.  There is no guarantee that
> we will *ever* be idle (someone might pin a copy of SETI at a low
> nice value to every cpu in the system to soak up all idle cycles).
> Calls to tlb_finish_mmu() would be very dependent on what the
> application is doing.  Can you take a bit more of a look at this
> area ... try to think from the point of view of a malicious user
> who would like to grind the system to a halt by tying up all the
> memory in the quicklists ... convince me that they can't do much
> damage.

Can I try to convince you that my new code can not do more damage than
the existing code?

With the current implementation, the quicklist is limited to 1/10th of
the entire system not just our node.  This can result in being larger
than the entire node.

With my proposed replacement, the size is limited to 1/16th of my node's
currently free pages.  Since the worst case is all the pages on the
node are free, I call the trim function leaving 1/16th of the pages
on the quicklist.

Given any possible combination of events that were possible before,
the new code can not make them worse.


Given the fact that my patches now reclaim more pages, I think I will
change the quicklist free code to disable preempt, free 16 pages,
enable preempt and loop until we have shrunk to the desired size.
This will eliminate one of the minor overshoot idiosyncracies that the
current proposal has and has an arguable basis as 16 pages being freed
will result in the max_pgt_pages number getting slightly larger.


As for Kenneth Chen's arguement against doing it from the idle loop,
I agree, but it is not as simple as doing it under memory pressure.
Since the cpu requesting the memory may not be on the same node as the
cpus that have the pages in their quicklist, you would need to have cpus
on the node feeling the memory pressure run the trim function.

Falling back on my "I didn't make it worse" defense, I would propose that
we get this in now as it does make a large difference for nearly all
workloads that use page tables and then come back and address draining
of other nodes at a more measured pace.  Of course, if the node-aware
slab stuff comes up to speed first, that will be preferred.


For now, I am going to do the rework as mentioned above and retest it.
I will then resubmit the third patch.  Does this sound reasonable?

Thanks,
Robin Holt
