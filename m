From: Zou Nan hai <nanhai.zou@intel.com>
Date: Fri, 04 Mar 2005 08:03:38 +0000
Subject: Re: [Patch 0/3] Page table quicklist fixups Rev 3.
Message-Id: <1109923418.2525.20.camel@linux-znh>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050303212359.GA732@lnx-holt.americas.sgi.com>
In-Reply-To: <20050303212359.GA732@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 2005-03-04 at 16:46, Robin Holt wrote:
> What do you want me to do.  I don't see anywhere else in the kernel
> that these two lines are directly adjacent.  Most places that do
> the disable/enable are in a function which does one thing.  That is
> occasionally contained inside a larger loop.  We can not do that since
> part of our outer loop control is based on the per_cpu variable we are
> expecting to not change.  I suppose I could elminitate the disable/enable
> entirely.  I haven't thought all the way through the possibilities,
> but I would guess we could free a couple extra pages, but who cares.
> You tell me what to do.
> 
> Robin

  I think there is no need to disable preempt in an idle thread...,
since the idle thread has no chance to migrate to another CPU.

  I also think that the shrinking of pgtables is a bit like that in
shrink_slab in vmscan.c, shrink_slab shrinks slab by batch, and itcalls
cond_resched every batch. 
So that it will not introduce too big latency when there are too many
slabs to shrink. 
While shrink_slab is called under mem pressure but check_pdt_cache is
called in idle thread, maybe there is some difference.

Zou Nan hai
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

