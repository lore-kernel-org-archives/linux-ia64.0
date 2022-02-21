From: Andy Lutomirski <luto@kernel.org>
Date: Mon, 21 Feb 2022 18:36:01 +0000
Subject: Re: [PATCH v2 0/8] kernel/fork: Move thread stack free otu of the scheduler path.
Message-Id: <215dc5af-5e81-fb64-9f00-b1e9e8d08297@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220217102406.3697941-1-bigeasy@linutronix.de>
In-Reply-To: <20220217102406.3697941-1-bigeasy@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org
Cc: Ben Segall <bsegall@google.com>, Daniel Bristot de Oliveira <bristot@redhat.com>, Dietmar Eggemann <dietmar.eggemann@arm.com>, Ingo Molnar <mingo@redhat.com>, Juri Lelli <juri.lelli@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Thomas Gleixner <tglx@linutronix.de>, Vincent Guittot <vincent.guittot@linaro.org>

On 2/17/22 02:23, Sebastian Andrzej Siewior wrote:
> This is a follup-up on the patch
>      sched: Delay task stack freeing on RT
>      https://lkml.kernel.org/r/20210928122411.593486363@linutronix.de
> 
> It addresses the review feedback:
> - Decouple stack accounting from its free invocation. The accounting
>    happens in do_exit(), the final free call happens later.
> 
> - Add put_task_stack_sched() to finish_task_switch(). Here the VMAP
>    stack is cached only. If it fails, or in the !VMAP case then the final
>    free happens in delayed_put_task_struct(). This is also an oportunity
>    to cache the stack.

My first two tries to apply this series to something failed.  What's it 
based on?

The rest of my review will be based on diffs, not real code, since I 
failed to apply it.
