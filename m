From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Date: Mon, 14 Feb 2022 11:39:05 +0000
Subject: Re: [PATCH 2/8] kernel/fork: Duplicate task_struct before stack allocation.
Message-Id: <Ygo/WWSQHFkGn095@linutronix.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220125152652.1963111-1-bigeasy@linutronix.de>
 <20220125152652.1963111-3-bigeasy@linutronix.de>
 <8340d413-4951-5e62-ef5f-f396523edac7@kernel.org>
In-Reply-To: <8340d413-4951-5e62-ef5f-f396523edac7@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andy Lutomirski <luto@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, Ben Segall <bsegall@google.com>, Daniel Bristot de Oliveira <bristot@redhat.com>, Dietmar Eggemann <dietmar.eggemann@arm.com>, Ingo Molnar <mingo@redhat.com>, Juri Lelli <juri.lelli@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Thomas Gleixner <tglx@linutronix.de>, Vincent Guittot <vincent.guittot@linaro.org>

On 2022-02-11 15:42:38 [-0800], Andy Lutomirski wrote:
> On 1/25/22 07:26, Sebastian Andrzej Siewior wrote:
> > alloc_thread_stack_node() already populates the task_struct::stack
> > member except on IA64. The stack pointer is saved and populated again
> > because IA64 needs it and arch_dup_task_struct() overwrites it.
> 
> I understand the problem, I think.
> 
> > 
> > Allocate thread's stack after task_struct has been duplicated as a
> > preparation.
> > 
> 
> But I don't understand this.  How does this patch relate to the problem?

So I duplicate the task-struct, assign the stack pointer in
alloc_thread_stack_node() with no need to update the stack pointer
later. Otherwise arch_dup_task_struct() would reset the pointer.

> Also, you appear to be missing a change to the free_stack and free_tsk code
> at the end of dup_task_struct().

It looks right. What am I missing?

Sebastian
