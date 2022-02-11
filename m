From: Andy Lutomirski <luto@kernel.org>
Date: Fri, 11 Feb 2022 23:43:50 +0000
Subject: Re: [PATCH 6/8] kernel/fork: Move task stack account to do_exit().
Message-Id: <55812c89-484d-6981-32f4-aaf20908f631@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220125152652.1963111-1-bigeasy@linutronix.de>
 <20220125152652.1963111-7-bigeasy@linutronix.de>
In-Reply-To: <20220125152652.1963111-7-bigeasy@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org
Cc: Ben Segall <bsegall@google.com>, Daniel Bristot de Oliveira <bristot@redhat.com>, Dietmar Eggemann <dietmar.eggemann@arm.com>, Ingo Molnar <mingo@redhat.com>, Juri Lelli <juri.lelli@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Thomas Gleixner <tglx@linutronix.de>, Vincent Guittot <vincent.guittot@linaro.org>

On 1/25/22 07:26, Sebastian Andrzej Siewior wrote:
> There is no need to perform the stack accounting of the outgoing task in
> its final schedule() invocation which happens with disabled preemption.
> The task is leaving, the resources will be freed and the accounting can
> happen in do_exit() before the actual schedule invocation which
> frees the stack memory.
> 
> Move the accounting of the stack memory from release_task_stack() to
> exit_task_stack_account() which then can be invoked from do_exit().

Seems reasonable.
