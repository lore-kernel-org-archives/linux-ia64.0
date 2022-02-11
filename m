From: Andy Lutomirski <luto@kernel.org>
Date: Fri, 11 Feb 2022 23:55:01 +0000
Subject: Re: [PATCH 7/8] kernel/fork: Only cache the VMAP stack in finish_task_switch().
Message-Id: <00f9c7a6-2d1d-f871-e9bc-00e2217f40f9@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220125152652.1963111-1-bigeasy@linutronix.de>
 <20220125152652.1963111-8-bigeasy@linutronix.de>
In-Reply-To: <20220125152652.1963111-8-bigeasy@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org
Cc: Ben Segall <bsegall@google.com>, Daniel Bristot de Oliveira <bristot@redhat.com>, Dietmar Eggemann <dietmar.eggemann@arm.com>, Ingo Molnar <mingo@redhat.com>, Juri Lelli <juri.lelli@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Thomas Gleixner <tglx@linutronix.de>, Vincent Guittot <vincent.guittot@linaro.org>

On 1/25/22 07:26, Sebastian Andrzej Siewior wrote:
> The task stack could be deallocated later in delayed_put_task_struct().
> For fork()/exec() kind of workloads (say a shell script executing
> several commands) it is important that the stack is released in
> finish_task_switch() so that in VMAP_STACK case it can be cached and
> reused in the new task.
> If the free/ caching is RCU-delayed then a new stack has to be allocated
> because the cache is filled in batches of which only two stacks, out of
> many, are recycled.
> 
> For PREEMPT_RT it would be good if the wake-up in vfree_atomic() could
> be avoided in the scheduling path. Far worse are the other
> free_thread_stack() implementations which invoke __free_pages()/
> kmem_cache_free() with disabled preemption.
> 
> Introduce put_task_stack_sched() which is invoked from the
> finish_task_switch() and only caches the VMAP stack. If the cache is
> full or !CONFIG_VMAP_STACK is used than the stack is freed from
> delayed_put_task_struct(). In the VMAP case this is another opportunity
> to fill the cache.
> 
> The stack is finally released in delayed_put_task_struct() which means
> that a valid stack reference can be held during its invocation. As such
> there can be made no assumption whether the task_struct::stack pointer
> can be freed if non-NULL.
> Set the lowest bit of task_struct::stack if the stack was released via
> put_task_stack_sched() and needs a final free in
> delayed_put_task_struct(). If the bit is missing then a reference is
> held and put_task_stack() will release it.

I don't understand what this bit is for or why the logic needs to be 
this complicated.  Can you set ->stack to NULL if and only if you freed 
it early?

> +static void free_thread_stack(struct task_struct *tsk, bool cache_only)

This is messy.  Please clean it up for real:

static bool try_release_thread_stack_to_cache(struct vm_struct *vm)
{
   for (...) try to put it in this slot;
}

And the callers can do things like:

if (try_release_thread_stack_to_cache(...))
   return;

/* need to free for real */
free it or delayed-free it.

--Andy
