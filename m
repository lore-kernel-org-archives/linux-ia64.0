From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Wed, 20 Oct 2004 18:03:33 +0000
Subject: Re: [PATCH] top level scheduler domain for ia64
Message-Id: <200410201103.33348.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200410191427.27336.jbarnes@engr.sgi.com>
In-Reply-To: <200410191427.27336.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wednesday, October 20, 2004 10:48 am, Luck, Tony wrote:
> >Some have noticed that the overlapping sched domains code
> >doesn't quite work as intended (it results in disjoint domains
> >on some machines), and that a top level, machine spanning domain
> >is needed.
>
> Why is the solution to jam this into the ia64 specific code?  From
> this description it sounds like a generic scheduler problem, so
> the solution ought to be up in some generic code.

It used to be in generic code, but now it's arch specific, so each arch builds 
its own scheduling domains.  This patch adds some NUMA specific scheduling 
domain code to build a top level domain on boxes with lots of nodes.  It 
won't affect non-NUMA or small NUMA boxes.

> + .min_interval  = 80,   \
> + .max_interval  = 320,   \
> + .busy_factor  = 320,   \
> + .imbalance_pct  = 125,   \
> + .cache_hot_time  = (10*1000000),  \
> + .balance_interval = 100*(63+num_online_cpus())/64,   \
>
> That's a lot of magic numbers and formulae ... are they right?
> How would a user know if they are right.

John has run several tests on large systems to come up with something 
reasonable, but no doubt they could use more tweaking.  John or Nick, care to 
comment?

> >Nick, can you buy off on the sched.c change?  Alternatively,
> >do you want to send that fix separately John?
>
> I saw the ACK from Nick ... but kernel/sched.c changes will have
> to go through Andrew, not me.  Are the ia64 and generic parts
> separable?  If the sched.c change goes in, do other architectures
> need to have some equivalent change?

Ok, I'll send out the sched.c bit separately then as it's standalone.

Thanks,
Jesse
