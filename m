From: Ingo Molnar <mingo@elte.hu>
Date: Mon, 26 Oct 2009 20:16:51 +0000
Subject: Re: Commit 34d76c41 causes linker errors on ia64 with NR_CPUS=4096
Message-Id: <20091026201651.GD24682@elte.hu>
List-Id: <linux-ia64.vger.kernel.org>
References: <4ADB967A.4080707@suse.com> <alpine.LRH.2.00.0910200356340.20992@twin.jikos.cz> <alpine.LRH.2.00.0910200651510.20992@twin.jikos.cz> <4ADD48D1.1040701@kernel.org> <alpine.LSU.2.00.0910200756300.8582@wotan.suse.de> <4ADD54D4.70808@kernel.org> <4ADD5530.3050107@kernel.org> <alpine.LSU.2.00.0910200826220.8582@wotan.suse.de> <4ADDC69A.5000701@suse.com> <4ADDCDED.6060706@suse.com>
In-Reply-To: <4ADDCDED.6060706@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jeff Mahoney <jeffm@suse.com>
Cc: Jiri Kosina <jkosina@suse.cz>, Tejun Heo <tj@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org


* Jeff Mahoney <jeffm@suse.com> wrote:

> On 10/20/2009 10:18 AM, Jeff Mahoney wrote:
> > On 10/20/2009 02:27 AM, Jiri Kosina wrote:
> >> @@ -1627,11 +1623,10 @@ static int tg_shares_up(struct task_group *tg, void *data)
> >>  		return 0;
> >>  
> >>  	local_irq_save(flags);
> >> -	usd = &__get_cpu_var(update_shares_data);
> >>  
> >>  	for_each_cpu(i, sched_domain_span(sd)) {
> >>  		weight = tg->cfs_rq[i]->load.weight;
> >> -		usd->rq_weight[i] = weight;
> >> +		usd = *per_cpu_ptr(update_shares_data, i) = weight;
> >>  
> >>  		/*
> >>  		 * If there are currently no tasks on the cpu pretend there
> > 
> > I don't think this is what you want here.
> > 
> > In the original version, usd is the percpu var using the current cpu. In
> > your version, usd is the percpu var using i instead of the current cpu.
> > 
> > I'll post my version of the patch shortly. I don't think keeping most of
> > the original version is a bad thing. We can just allocate it dynamically
> > instead.
> 
> This version fixes a build issue (__alignof__(unsigned long)) and fixes the
> percpu lookup to be usd = percpu array pointer, usd[i] = actual variable.
> 
> -Jeff
> 
> From: Jiri Kosina <jkosina@suse.cz>
> Subject: sched: move rq_weight data array out of .percpu
> 
> Commit 34d76c41 introduced percpu array update_shares_data, size of which
> being proportional to NR_CPUS. Unfortunately this blows up ia64 for large
> NR_CPUS configuration, as ia64 allows only 64k for .percpu section.
> 
> Fix this by allocating this array dynamically and keep only pointer to it
> percpu.
> 
> Signed-off-by: Jiri Kosina <jkosina@suse.cz>
> --- 
>  kernel/sched.c |   20 ++++++++++----------
>  1 file changed, 10 insertions(+), 10 deletions(-)
> 
> --- a/kernel/sched.c
> +++ b/kernel/sched.c
> @@ -1564,11 +1564,7 @@ static unsigned long cpu_avg_load_per_ta
>  
>  #ifdef CONFIG_FAIR_GROUP_SCHED
>  
> -struct update_shares_data {
> -	unsigned long rq_weight[NR_CPUS];
> -};
> -
> -static DEFINE_PER_CPU(struct update_shares_data, update_shares_data);
> +unsigned long *update_shares_data;

That should be __read_mostly - this can be a hotly accessed data 
structure of the scheduler - if it happens to go next to a frequently 
bouncing variable that can be bad for performance.

> -				    struct update_shares_data *usd)
> +				    unsigned long *usd)

I dont think using usd[cpu] is clearer than usd->rq_weight[cpu]. At 
minimum it should be renamed to usd_rq_weight not usd.

>  	local_irq_save(flags);
> -	usd = &__get_cpu_var(update_shares_data);
> +	usd = per_cpu_ptr(update_shares_data, smp_processor_id());

Could we please have a look at the before/after assembly of this 
sequence on x86, to make sure the claims in this thread are true and we 
dont lose performance? (and included it in the changelog with a 
resubmission - with a new, changed '[PATCH] ...' subject line, not 
hidden inside a discussion thread.)

From a merge POV i'm quite nervous about such a change to the scheduler 
this late in the .32 cycle - to offset that risk i'd really like to see 
that this change has been pursued carefully to the edge of possibilities 
- currently it does not give that impression.

Thanks,

	Ingo
