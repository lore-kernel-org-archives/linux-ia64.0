From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Date: Mon, 14 Feb 2022 12:10:04 +0000
Subject: Re: [PATCH 7/8] kernel/fork: Only cache the VMAP stack in finish_task_switch().
Message-Id: <YgpGnFlTS+2Ugfw4@linutronix.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220125152652.1963111-1-bigeasy@linutronix.de>
 <20220125152652.1963111-8-bigeasy@linutronix.de>
 <00f9c7a6-2d1d-f871-e9bc-00e2217f40f9@kernel.org>
In-Reply-To: <00f9c7a6-2d1d-f871-e9bc-00e2217f40f9@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andy Lutomirski <luto@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, Ben Segall <bsegall@google.com>, Daniel Bristot de Oliveira <bristot@redhat.com>, Dietmar Eggemann <dietmar.eggemann@arm.com>, Ingo Molnar <mingo@redhat.com>, Juri Lelli <juri.lelli@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Thomas Gleixner <tglx@linutronix.de>, Vincent Guittot <vincent.guittot@linaro.org>

On 2022-02-11 15:55:01 [-0800], Andy Lutomirski wrote:
> > Set the lowest bit of task_struct::stack if the stack was released via
> > put_task_stack_sched() and needs a final free in
> > delayed_put_task_struct(). If the bit is missing then a reference is
> > held and put_task_stack() will release it.
> 
> I don't understand what this bit is for or why the logic needs to be this
> complicated.  Can you set ->stack to NULL if and only if you freed it early?

What do I do if put_task_stack() is invoked from finish_task_switch()
and I can't free but have to do something?

> > +static void free_thread_stack(struct task_struct *tsk, bool cache_only)
> 
> This is messy.  Please clean it up for real:
> 
> static bool try_release_thread_stack_to_cache(struct vm_struct *vm)
> {
>   for (...) try to put it in this slot;
> }
> 
> And the callers can do things like:
> 
> if (try_release_thread_stack_to_cache(...))
>   return;
> 
> /* need to free for real */
> free it or delayed-free it.

I think I could use the first few bytes of the stack as a RCU-head. Let
me try that.

> --Andy

Sebastian
