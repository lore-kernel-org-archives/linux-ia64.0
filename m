From: Nick Piggin <nickpiggin@yahoo.com.au>
Date: Wed, 20 Oct 2004 18:02:54 +0000
Subject: Re: [PATCH] top level scheduler domain for ia64
Message-Id: <4176A84E.3030501@yahoo.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <200410191427.27336.jbarnes@engr.sgi.com>
In-Reply-To: <200410191427.27336.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Luck, Tony wrote:
>>Some have noticed that the overlapping sched domains code 
>>doesn't quite work as intended (it results in disjoint domains
>>on some machines), and that a top level, machine spanning domain
>>is needed.
> 
> 
> Why is the solution to jam this into the ia64 specific code?  From
> this description it sounds like a generic scheduler problem, so
> the solution ought to be up in some generic code.
> 

So far, ia64 is the only one that uses these overlapping domains.
The code to build them is complex enough that we didn't want to
put it into the generic code at the moment (but it is fairly well
contained, all just in arch/ia64/kernel/domain.c and asm/topology.h).

> +	.min_interval		= 80,			\
> +	.max_interval		= 320,			\
> +	.busy_factor		= 320,			\
> +	.imbalance_pct		= 125,			\
> +	.cache_hot_time		= (10*1000000),		\
> +	.balance_interval	= 100*(63+num_online_cpus())/64,   \
> 
> That's a lot of magic numbers and formulae ... are they right?
> How would a user know if they are right.
> 

To be honest you really wouldn't. It would take a lot of careful
testing on numerous workloads and systems. I believe SGI is
starting to do a bit of testing... I don't have the resources to
do many "real world" tests.

At this stage I wouldn't let them worry you too much :P
Hopefully they'll gradually improve.

> 
>>Nick, can you buy off on the sched.c change?  Alternatively, 
>>do you want to send that fix separately John?
> 
> 
> I saw the ACK from Nick ... but kernel/sched.c changes will have
> to go through Andrew, not me.  Are the ia64 and generic parts
> separable?  If the sched.c change goes in, do other architectures
> need to have some equivalent change?
> 

No, it should be ok as is. The parts should be ok to seperate if
you would prefer it that way.
