From: Ingo Molnar <mingo@elte.hu>
Date: Fri, 20 Jan 2006 08:36:51 +0000
Subject: Re: [PATCH] SN2 user-MMIO CPU migration
Message-Id: <20060120083651.GA3970@elte.hu>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060118163305.Y42462@chenjesu.americas.sgi.com>
In-Reply-To: <20060118163305.Y42462@chenjesu.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Brent Casavant <bcasavan@sgi.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, jes@sgi.com, tony.luck@intel.com


* Brent Casavant <bcasavan@sgi.com> wrote:

> --- a/kernel/sched.c
> +++ b/kernel/sched.c
> @@ -291,6 +291,9 @@ for (domain = rcu_dereference(cpu_rq(cpu
>  #ifndef finish_arch_switch
>  # define finish_arch_switch(prev)	do { } while (0)
>  #endif
> +#ifndef arch_task_migrate
> +# define arch_task_migrate(task)	do { } while (0)
> +#endif

>  	if (!p->array && !task_running(rq, p)) {
> +		arch_task_migrate(p);
>  		set_task_cpu(p, dest_cpu);

>  	if (new_cpu != cpu) {
> +		arch_task_migrate(p);
>  		set_task_cpu(p, new_cpu);

>  	dec_nr_running(p, src_rq);
> +	arch_task_migrate(p);
>  	set_task_cpu(p, this_cpu);

> +	arch_task_migrate(p);
>  	set_task_cpu(p, dest_cpu);

hm, why isnt the synchronization done in switch_to()? Your arch-level 
switch_to() could have something like thread->last_cpu_sync, and if 
thread->last_cpu_sync != this_cpu, do the flush. This would not only 
keep this stuff out of the generic scheduler, but it would also optimize 
things a bit more: the moment we do a set_task_cpu() it does not mean 
that CPU _will_ run the task. Another CPU could grab that task later on.  
So we should delay such IO-synchronization to the last possible moment: 
when we know that we've hit a new CPU on which we havent done a flush 
yet. For same-CPU context switches there wouldnt be any extra 
synchronization, because thread->last_cpu_sync = this_cpu.

	Ingo
