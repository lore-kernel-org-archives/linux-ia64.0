From: Nick Piggin <nickpiggin@yahoo.com.au>
Date: Sat, 30 Jul 2005 00:08:36 +0000
Subject: Re: [sched, patch] better wake-balancing, #3
Message-Id: <42EAC504.3000300@yahoo.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <42E98DEA.9090606@yahoo.com.au> <200507290627.j6T6Rrg06842@unix-os.sc.intel.com> <20050729114822.GA25249@elte.hu> <20050729141311.GA4154@elte.hu> <20050729150207.GA6332@elte.hu> <20050729162108.GA10243@elte.hu>
In-Reply-To: <20050729162108.GA10243@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ingo Molnar <mingo@elte.hu>
Cc: "Chen, Kenneth W" <kenneth.w.chen@intel.com>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, Andrew Morton <akpm@osdl.org>

Ingo Molnar wrote:
> * Ingo Molnar <mingo@elte.hu> wrote:
> 
> 
>>there's an even simpler way: only do wakeup-balancing if this_cpu is 
>>idle. (tbench results are still OK, and other workloads improved.)
> 
> 
> here's an updated patch. It handles one more detail: on SCHED_SMT we 
> should check the idleness of siblings too. Benchmark numbers still look 
> good.
> 

Maybe. Ken hasn't measured the effect of wake balancing in
2.6.13, which is quite a lot different to that found in 2.6.12.

I don't really like having a hard cutoff like that -wake
balancing can be important for IO workloads, though I haven't
measured for a long time. In IPC workloads, the cache affinity
of local wakeups becomes less apparent when the runqueue gets
lots of tasks on it, however benefits of IO affinity will
generally remain. Especially on NUMA systems.

fork/clone/exec/etc balancing really doesn't do anything to
capture this kind of relationship between tasks and between
tasks and IRQ sources. Without wake balancing we basically have
a completely random scattering of tasks.

-- 
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 
