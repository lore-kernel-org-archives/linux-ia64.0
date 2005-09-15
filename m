From: Robin Holt <holt@sgi.com>
Date: Thu, 15 Sep 2005 22:29:00 +0000
Subject: Re: Attribute spinlock contention ticks to caller.
Message-Id: <20050915222900.GC24532@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050914222644.GA5036@lnx-holt.americas.sgi.com>
In-Reply-To: <20050914222644.GA5036@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Sep 15, 2005 at 01:19:09AM -0700, Stephane Eranian wrote:
> Robin,
> 
> On Thu, Sep 15, 2005 at 10:37:50AM -0700, Luck, Tony wrote:
> > >This also opens the door for people submitted other special cases.
> > 
> > I'm very sympathetic to getting better performance data.  I agree
> > 100% that knowing who called spinlock contention is far better than
> > just lumping all spinlock contention together.
> > 
> I think you need to clarify this a little bit I may be missing
> somethin here. 
> 
> It seems you assume you know something in advance here. 
> I think you need a two-step process somehow. First you need to
> discover that you have contention, i.e., lots of samples
> in the contention code. Second you want to know from where
> and that's why you record the return from contention rather
> than contention. This sequence makes sense. 
> 
> With your patch, you would skip the first step.  If you don't
> know you have contention, how would you interpret the samples
> you get? For each sample, you have to search backwards to see
> if there is a br.call or similar that points to some 
> spinlock code. Why would you do this costly search systematically?
> Unless the tool is designed just to look for this. 

Unfortunately, without this patch, ia64_spinlock_contention become the
top billing issue on nearly every large cpu count sample.  It does not
mean you are contending on the same lock.  I have been fooled many times
into chasing a contention problem when in reality there were many locks
lightly contended which artificially raised the number of ticks to a
significant level.

By looking at the caller, you get rid of that false positive.  Usually,
it becomes rapidly apparrent what lock within a code path is the potential
for being the hot lock.

> 
> So I think that this should somehow be an option. Like Tony suggest
> I would like to have a cleaner mechanism to track code range
> for which this could be useful. Furthermore, the name of the
> register to swap for iip should not be hardcoded becasue it is hard
> to maintain, should the spinlock code evolve.

I remain open to suggestions.

Thanks,
Robin
