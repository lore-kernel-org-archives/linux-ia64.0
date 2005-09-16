From: Stephane Eranian <eranian@hpl.hp.com>
Date: Fri, 16 Sep 2005 09:37:31 +0000
Subject: Re: Attribute spinlock contention ticks to caller.
Message-Id: <20050916093731.GG25984@frankl.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050914222644.GA5036@lnx-holt.americas.sgi.com>
In-Reply-To: <20050914222644.GA5036@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Robin,

On Thu, Sep 15, 2005 at 05:29:00PM -0500, Robin Holt wrote:
> > It seems you assume you know something in advance here. 
> > I think you need a two-step process somehow. First you need to
> > discover that you have contention, i.e., lots of samples
> > in the contention code. Second you want to know from where
> > and that's why you record the return from contention rather
> > than contention. This sequence makes sense. 
> > 
> > With your patch, you would skip the first step.  If you don't
> > know you have contention, how would you interpret the samples
> > you get? For each sample, you have to search backwards to see
> > if there is a br.call or similar that points to some 
> > spinlock code. Why would you do this costly search systematically?
> > Unless the tool is designed just to look for this. 
> 
> Unfortunately, without this patch, ia64_spinlock_contention become the
> top billing issue on nearly every large cpu count sample.  It does not
> mean you are contending on the same lock.  I have been fooled many times
> into chasing a contention problem when in reality there were many locks
> lightly contended which artificially raised the number of ticks to a
> significant level.
> 
You have another side effect in here: interrupt masking. With existing
PMU, you cannot take a sample is interrupts are masked. For some
of the kernel code, it means that you get samples attributed to the
bundle(s) just following interrupt unmasking.

I think what you are really after here is kernel call stack unwinding.
Your patch is effectively a quick hack to get this for a specific function
and for one level of unwinding.

I have shown in several presentations (incl. Gelato May 2004) that the existing
infrastructure can be used to sample the kernel call stack. I have written
a prototype perfmon2 sampling format that does just that. You can
say, for instance:" Every 100,0000 cycles in the kernel record the full
(or partial) call stack". The format is just a prototype at this point
but I think it could be useful for your situation. The format was
designed to show the power of the interface in that it allows you
sample on PMU event and yet record non PMU-based information.

-- 

-Stephane
