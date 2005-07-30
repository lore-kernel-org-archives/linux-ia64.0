From: Ingo Molnar <mingo@elte.hu>
Date: Sat, 30 Jul 2005 07:19:17 +0000
Subject: Re: [sched, patch] better wake-balancing, #3
Message-Id: <20050730071917.GA31822@elte.hu>
List-Id: <linux-ia64.vger.kernel.org>
References: <42E98DEA.9090606@yahoo.com.au> <200507290627.j6T6Rrg06842@unix-os.sc.intel.com> <20050729114822.GA25249@elte.hu> <20050729141311.GA4154@elte.hu> <20050729150207.GA6332@elte.hu> <20050729162108.GA10243@elte.hu> <42EAC504.3000300@yahoo.com.au>
In-Reply-To: <42EAC504.3000300@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: "Chen, Kenneth W" <kenneth.w.chen@intel.com>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, Andrew Morton <akpm@osdl.org>, John Hawkes <hawkes@sgi.com>, "Martin J. Bligh" <mbligh@mbligh.org>, Paul Jackson <pj@sgi.com>


* Nick Piggin <nickpiggin@yahoo.com.au> wrote:

> > here's an updated patch. It handles one more detail: on SCHED_SMT we 
> > should check the idleness of siblings too. Benchmark numbers still 
> > look good.
> 
> Maybe. Ken hasn't measured the effect of wake balancing in 2.6.13, 
> which is quite a lot different to that found in 2.6.12.
> 
> I don't really like having a hard cutoff like that -wake balancing can 
> be important for IO workloads, though I haven't measured for a long 
> time. [...]

well, i have measured it, and it was a win for just about everything 
that is not idle, and even for an IPC (SysV semaphores) half-idle 
workload i've measured a 3% gain. No performance loss in tbench either, 
which is clearly the most sensitive to affine/passive balancing. But i'd 
like to see what Ken's (and others') numbers are.

the hard cutoff also has the benefit that it allows us to potentially 
make wakeup migration _more_ agressive in the future. So instead of 
having to think about weakening it due to the tradeoffs present in e.g.  
Ken's workload, we can actually make it stronger.

> [...] In IPC workloads, the cache affinity of local wakeups becomes 
> less apparent when the runqueue gets lots of tasks on it, however 
> benefits of IO affinity will generally remain. Especially on NUMA 
> systems.

especially on NUMA, if the migration-target CPU (this_cpu) is not at 
least partially idle, i'd be quite uneasy to passive balance from 
another node. I suspect this needs numbers from Martin and John?

> fork/clone/exec/etc balancing really doesn't do anything to capture 
> this kind of relationship between tasks and between tasks and IRQ 
> sources. Without wake balancing we basically have a completely random 
> scattering of tasks.

Ken's workload is a heavy IO one with lots of IRQ sources. And precisely 
for such type of workloads usually the best tactic is to leave the task 
alone and queue it wherever it last ran.

whenever there's a strong (and exclusive) relationship between tasks and 
individual interrupt sources, explicit binding to CPUs/groups of CPUs is 
the best method. In any case, more measurements are needed.

	Ingo
