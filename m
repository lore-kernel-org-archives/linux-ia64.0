From: Stephane Eranian <eranian@hpl.hp.com>
Date: Thu, 15 Sep 2005 08:19:09 +0000
Subject: Re: Attribute spinlock contention ticks to caller.
Message-Id: <20050915081909.GA24631@frankl.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050914222644.GA5036@lnx-holt.americas.sgi.com>
In-Reply-To: <20050914222644.GA5036@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Robin,

On Thu, Sep 15, 2005 at 10:37:50AM -0700, Luck, Tony wrote:
> >This also opens the door for people submitted other special cases.
> 
> I'm very sympathetic to getting better performance data.  I agree
> 100% that knowing who called spinlock contention is far better than
> just lumping all spinlock contention together.
> 
I think you need to clarify this a little bit I may be missing
somethin here. 

It seems you assume you know something in advance here. 
I think you need a two-step process somehow. First you need to
discover that you have contention, i.e., lots of samples
in the contention code. Second you want to know from where
and that's why you record the return from contention rather
than contention. This sequence makes sense. 

With your patch, you would skip the first step.  If you don't
know you have contention, how would you interpret the samples
you get? For each sample, you have to search backwards to see
if there is a br.call or similar that points to some 
spinlock code. Why would you do this costly search systematically?
Unless the tool is designed just to look for this. 

So I think that this should somehow be an option. Like Tony suggest
I would like to have a cleaner mechanism to track code range
for which this could be useful. Furthermore, the name of the
register to swap for iip should not be hardcoded becasue it is hard
to maintain, should the spinlock code evolve.

> But I have to agree with Stephane that this looks like the start
> of a slippery slope of special cases (each of which provides two
> new exported symbols).
> 
> We should look to see if there is a better way to flag address
> ranges in the kernel where you'd like to bill time to the caller
> rather than the function (perhaps some sort of tag table like the
> extable used for copyin/copyout fault recovery?  Then we can just
> export one table and have the profiler search it ... rather than
> a new pair of symbols for every case.
> 
> Or you can try to convince me that spinlock contention is such
> a special one off case, and we will never, ever, want to do this
> anywhere else.
> 

-- 

-Stephane
