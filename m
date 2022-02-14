From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Date: Mon, 14 Feb 2022 17:48:04 +0000
Subject: Re: [PATCH 7/8] kernel/fork: Only cache the VMAP stack in finish_task_switch().
Message-Id: <YgqV1BLbCx5V+6tq@linutronix.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220125152652.1963111-1-bigeasy@linutronix.de>
 <20220125152652.1963111-8-bigeasy@linutronix.de>
 <00f9c7a6-2d1d-f871-e9bc-00e2217f40f9@kernel.org>
 <YgpGnFlTS+2Ugfw4@linutronix.de>
 <YgpJ41q35k+KCsk4@linutronix.de>
 <YgqJV0LREU9IDJxl@linutronix.de>
In-Reply-To: <YgqJV0LREU9IDJxl@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andy Lutomirski <luto@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, Ben Segall <bsegall@google.com>, Daniel Bristot de Oliveira <bristot@redhat.com>, Dietmar Eggemann <dietmar.eggemann@arm.com>, Ingo Molnar <mingo@redhat.com>, Juri Lelli <juri.lelli@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Thomas Gleixner <tglx@linutronix.de>, Vincent Guittot <vincent.guittot@linaro.org>

On 2022-02-14 17:54:48 [+0100], To Andy Lutomirski wrote:
> index fcf0c180617c2..defe31036930a 100644
> --- a/kernel/sched/core.c
> +++ b/kernel/sched/core.c
> @@ -4895,8 +4895,11 @@ static struct rq *finish_task_switch(struct task_struct *prev)
>  		if (prev->sched_class->task_dead)
>  			prev->sched_class->task_dead(prev);
>  
> -		/* Task is done with its stack. */
> -		put_task_stack(prev);
> +		/*
> +		 * Task is done with its stack. Try to cache VMAP stack and
> +		 * delay free it otherwise.
> +		 */
> +		put_task_stack_sched(prev);

Now that I write the commit message, there is probably nothing wrong
with unconditionally delaying it via RCU if caching failed. Then I don't
have to explain that there is one function is for the atomic context and
the other for non-atomic.

>  		put_task_struct_rcu_user(prev);
>  	}
> -- 
Sebastian
