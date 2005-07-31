From: Nick Piggin <nickpiggin@yahoo.com.au>
Date: Sun, 31 Jul 2005 01:15:16 +0000
Subject: Re: [sched, patch] better wake-balancing, #3
Message-Id: <42EC2624.7030509@yahoo.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <42E98DEA.9090606@yahoo.com.au> <200507290627.j6T6Rrg06842@unix-os.sc.intel.com> <20050729114822.GA25249@elte.hu> <20050729141311.GA4154@elte.hu> <20050729150207.GA6332@elte.hu> <20050729162108.GA10243@elte.hu> <42EAC504.3000300@yahoo.com.au> <20050730071917.GA31822@elte.hu>
In-Reply-To: <20050730071917.GA31822@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ingo Molnar <mingo@elte.hu>
Cc: "Chen, Kenneth W" <kenneth.w.chen@intel.com>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, Andrew Morton <akpm@osdl.org>, John Hawkes <hawkes@sgi.com>, "Martin J. Bligh" <mbligh@mbligh.org>, Paul Jackson <pj@sgi.com>

Ingo Molnar wrote:
> * Nick Piggin <nickpiggin@yahoo.com.au> wrote:

>>I don't really like having a hard cutoff like that -wake balancing can 
>>be important for IO workloads, though I haven't measured for a long 
>>time. [...]
> 
> 
> well, i have measured it, and it was a win for just about everything 

I meant: measured for IO workloads.

I had one group tell me their IO efficiency went up by several
*times* on a 16-way NUMA system after generalising the wake
balancing to interrupts as well.

> that is not idle, and even for an IPC (SysV semaphores) half-idle 
> workload i've measured a 3% gain. No performance loss in tbench either, 
> which is clearly the most sensitive to affine/passive balancing. But i'd 
> like to see what Ken's (and others') numbers are.
> 
> the hard cutoff also has the benefit that it allows us to potentially 
> make wakeup migration _more_ agressive in the future. So instead of 
> having to think about weakening it due to the tradeoffs present in e.g.  
> Ken's workload, we can actually make it stronger.
> 

That would make the behaviour change even more violent, which is
what I dislike. I would much prefer to have code that handles both
workloads without introducing sudden cutoff points in behaviour.

> 
> especially on NUMA, if the migration-target CPU (this_cpu) is not at 
> least partially idle, i'd be quite uneasy to passive balance from 
> another node. I suspect this needs numbers from Martin and John?
> 

Passive balancing cuts in only when an imbalance is becoming apparent.
If the queue gets more imbalanced, periodic balancing will cut in,
and that is much worse than wake balancing.

> 
>>fork/clone/exec/etc balancing really doesn't do anything to capture 
>>this kind of relationship between tasks and between tasks and IRQ 
>>sources. Without wake balancing we basically have a completely random 
>>scattering of tasks.
> 
> 
> Ken's workload is a heavy IO one with lots of IRQ sources. And precisely 
> for such type of workloads usually the best tactic is to leave the task 
> alone and queue it wherever it last ran.
> 

Yep, I agree the wake balancing code in 2.6.12 wasn't ideal. That's
why I changed it in 2.6.13 - precisely because it moved things around
too much. It probably still isn't ideal though.

> whenever there's a strong (and exclusive) relationship between tasks and 
> individual interrupt sources, explicit binding to CPUs/groups of CPUs is 
> the best method. In any case, more measurements are needed.
> 

Well, I wouldn't say it is always the best method. Especially not when
there is a big variation in the CPU consumption of the groups of tasks.
But anyway, even in the cases where it definitely is the best method,
we really should try to handle them properly without binding too.

I do agree that more measurements are needed :)

-- 
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 
