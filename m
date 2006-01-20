From: Jesse Barnes <jbarnes@virtuousgeek.org>
Date: Fri, 20 Jan 2006 02:18:43 +0000
Subject: Re: [PATCH] SN2 user-MMIO CPU migration
Message-Id: <200601191818.43157.jbarnes@virtuousgeek.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060118163305.Y42462@chenjesu.americas.sgi.com>
In-Reply-To: <20060118163305.Y42462@chenjesu.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Brent Casavant <bcasavan@sgi.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, jes@sgi.com, tony.luck@intel.com

On Thursday, January 19, 2006 4:06 pm, Brent Casavant wrote:
>  #ifndef __ARCH_WANT_UNLOCKED_CTXSW
>  static inline int task_running(runqueue_t *rq, task_t *p)
> @@ -936,6 +939,7 @@ static int migrate_task(task_t *p, int d
>  	 * it is sufficient to simply update the task's cpu field.
>  	 */
>  	if (!p->array && !task_running(rq, p)) {
> +		arch_task_migrate(p);
>  		set_task_cpu(p, dest_cpu);
>  		return 0;
>  	}
> @@ -1353,6 +1357,7 @@ static int try_to_wake_up(task_t *p, uns
>  out_set_cpu:
>  	new_cpu = wake_idle(new_cpu, p);
>  	if (new_cpu != cpu) {
> +		arch_task_migrate(p);
>  		set_task_cpu(p, new_cpu);
>  		task_rq_unlock(rq, &flags);
>  		/* might preempt at this point */
> @@ -1876,6 +1881,7 @@ void pull_task(runqueue_t *src_rq, prio_
>  {
>  	dequeue_task(p, src_array);
>  	dec_nr_running(p, src_rq);
> +	arch_task_migrate(p);
>  	set_task_cpu(p, this_cpu);
>  	inc_nr_running(p, this_rq);
>  	enqueue_task(p, this_array);
> @@ -4547,6 +4553,7 @@ static void __migrate_task(struct task_s
>  	if (!cpu_isset(dest_cpu, p->cpus_allowed))
>  		goto out;
>
> +	arch_task_migrate(p);
>  	set_task_cpu(p, dest_cpu);
>  	if (p->array) {
>  		/*

Maybe you could just turn the above into mmiowb() calls instead?  That 
would cover altix, origin, and ppc as well I think.  On other platforms 
it would be a complete no-op.

Jesse
