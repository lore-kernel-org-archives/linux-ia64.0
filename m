From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Date: Thu, 18 Nov 2021 14:38:50 +0000
Subject: Re: [PATCH 0/8] kernel/fork: Move thread stack free otu of the scheduler path.
Message-Id: <20211118143850.ygpp7xetpz3pt2nj@linutronix.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20211118143452.136421-1-bigeasy@linutronix.de>
In-Reply-To: <20211118143452.136421-1-bigeasy@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, tglx@linutronix.de
Cc: Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andy Lutomirski <luto@kernel.org>, Juri Lelli <juri.lelli@redhat.com>, Vincent Guittot <vincent.guittot@linaro.org>, Dietmar Eggemann <dietmar.eggemann@arm.com>, Steven Rostedt <rostedt@goodmis.org>, Ben Segall <bsegall@google.com>, Daniel Bristot de Oliveira <bristot@redhat.com>

+ tglx.

It starts at
   https://lore.kernel.org/all/20211118143452.136421-1-bigeasy@linutronix.de/

On 2021-11-18 15:34:44 [+0100], To linux-kernel@vger.kernel.org wrote:
> 
> This is a follup-up on the patch
>     sched: Delay task stack freeing on RT 
>     https://lkml.kernel.org/r/20210928122411.593486363@linutronix.de
> 
> It addresses the review feedback:
> - Decouple stack accounting from its free invocation. The accounting
>   happens in do_exit(), the final free call happens later.
> 
> - Add put_task_stack_sched() to finish_task_switch(). Here the VMAP
>   stack is cached only. If it fails, or in the !VMAP case then the final
>   free happens in delayed_put_task_struct(). This is also an oportunity
>   to cache the stack.

Sebastian
