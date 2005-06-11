From: Keith Owens <kaos@sgi.com>
Date: Sat, 11 Jun 2005 04:08:56 +0000
Subject: Re: [RFD] Separating struct task and the kernel stacks
Message-Id: <11503.1118462936@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <9712.1118384111@kao2.melbourne.sgi.com>
In-Reply-To: <9712.1118384111@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 10 Jun 2005 10:03:14 -0700, 
David Mosberger <davidm@napali.hpl.hp.com> wrote:
>>>>>> On Fri, 10 Jun 2005 08:11:42 -0700 (PDT), Christoph Lameter <christoph@lameter.com> said:
>
>  >> Switching stacks requires that struct task is copied from the
>  >> original "current" to the MCA/INIT stack, then change current to
>  >> point to the new stack.  Even that is not enough, there are still
>  >> places that are using the old value of "current".  The main
>  >> problem is the scheduler, it tracks tasks by the address of their
>  >> struct task, not by the kernel stack address.  When debugging an
>  >> MCA/INIT, the mismatch between the new value of current and the
>  >> old task addresses in various structures can lead to some very
>  >> confusing results.  The kernel is not designed to have struct
>  >> task move around on the fly.
>
>  Christoph> Could you just move the stack? Put a pointer to the stack
>  Christoph> in task_info. By default this is pointing to the stack in
>  Christoph> task_info. If you have to switch point it elsewhere.

Exactly what I was suggesting.  Separate struct task from the stack, so
the stack just contains thread_info and the register and memory stacks,
with struct task pointing to one of several stacks.  But as David has
pointed out, that is going to be less efficient.

>Perhaps a more fruitful approach might be to treat the MCA as its own
>task.

That is a promising idea.  Preformat the MCA/INIT stacks like the init
task, marking them interrupts disabled, non-preemptible etc.  To avoid
any disagreement with what the scheduler thinks is the system state,
mark the MCA/INIT tasks as not running on any cpu, even though they are
really in control while they are handling the event.

Some of the registers belonging to the interrupted tasks will be in RBS
on the MCA/INIT stack, which would normally stop us investigating the
original state.  The MCA/INIT handler would copy those registers back
to the original stack and add a switch_stack to make it look like the
original task is blocked.  This assumes that the MCA/INIT event
occurred while the cpu was running on a kernel stack and that there is
enough room on stack to save the state.

current and its corresponding DTC still have to be switched to point to
the MCA/INIT stack, there are too many places where current is tested
and we want almost all of those places to pick up the MCA/INIT state,
not the original.  For the few cases where we want the original value
of current (backtrace is the obvious case), we can detect that this is
the MCA/INIT stack and use the original value for current.  Stack
switching from the MCA/INIT stack to the original stack is no longer
required to backtrace the original task, which nicely removes the
problem of how to switch between kernel stacks when unwinding,

The detection of whether a task is blocked or not would have to change
slightly.  Currently a task is blocked if it is not on a cpu, which is
detected by comparing the task pointer against cpu_rq(cpu)->curr.
During an MCA/INIT event, the cpu_rq(cpu)->curr task will be blocked
and the MCA/INIT "task" will be active.  Fortunately that distinction
only affects the MCA/INIT handlers and debuggers like kdb and lcrash, I
can live with that.

