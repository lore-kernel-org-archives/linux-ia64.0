From: Robin Holt <holt@sgi.com>
Date: Fri, 16 Sep 2005 22:29:49 +0000
Subject: Re: Attribute spinlock contention ticks to caller.
Message-Id: <20050916222949.GB27307@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050914222644.GA5036@lnx-holt.americas.sgi.com>
In-Reply-To: <20050914222644.GA5036@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Sep 16, 2005 at 02:37:31AM -0700, Stephane Eranian wrote:
> Robin,
> 
> On Thu, Sep 15, 2005 at 05:29:00PM -0500, Robin Holt wrote:
> > > It seems you assume you know something in advance here. 
> > > I think you need a two-step process somehow. First you need to
> > > discover that you have contention, i.e., lots of samples
> > > in the contention code. Second you want to know from where
> > > and that's why you record the return from contention rather
> > > than contention. This sequence makes sense. 
> > > 
> > > With your patch, you would skip the first step.  If you don't
> > > know you have contention, how would you interpret the samples
> > > you get? For each sample, you have to search backwards to see
> > > if there is a br.call or similar that points to some 
> > > spinlock code. Why would you do this costly search systematically?
> > > Unless the tool is designed just to look for this. 
> > 
> > Unfortunately, without this patch, ia64_spinlock_contention become the
> > top billing issue on nearly every large cpu count sample.  It does not
> > mean you are contending on the same lock.  I have been fooled many times
> > into chasing a contention problem when in reality there were many locks
> > lightly contended which artificially raised the number of ticks to a
> > significant level.
> > 
> You have another side effect in here: interrupt masking. With existing
> PMU, you cannot take a sample is interrupts are masked. For some
> of the kernel code, it means that you get samples attributed to the
> bundle(s) just following interrupt unmasking.

At least in those situations, you can clearly see the samples are
attributable to the function which disabled/enabled interrupts.  Not some
generic code which has nothing to do with the function.

> I think what you are really after here is kernel call stack unwinding.
> Your patch is effectively a quick hack to get this for a specific function
> and for one level of unwinding.

Are you saying I should add the heavy steps of checking to top the call
stack and unwinding a single step if I am in ia64_spinlock_contention
instead of the relatively light checking against two global symbols
and doing a register move?

> I have shown in several presentations (incl. Gelato May 2004) that the existing
> infrastructure can be used to sample the kernel call stack. I have written
> a prototype perfmon2 sampling format that does just that. You can
> say, for instance:" Every 100,0000 cycles in the kernel record the full
> (or partial) call stack". The format is just a prototype at this point
> but I think it could be useful for your situation. The format was
> designed to show the power of the interface in that it allows you
> sample on PMU event and yet record non PMU-based information.

Can you site one instance where it is more helpful to know that _ANY_
lock in the system is hitting ia64_spinlock_contention as opposed to
the function which has the spin_lock() code?  I can recall times when
network traffic was contending on locks and causing my application to
appear to have a contended lock.  With this change, at least we know
the degradation is do to something external.

Thanks,
Robin
