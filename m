From: Erich Focht <focht@ess.nec.de>
Date: Sat, 19 Jan 2002 17:17:43 +0000
Subject: Re: [Linux-ia64] Help with Ingo scheduler on IA64
Message-Id: <marc-linux-ia64-105590698805886@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805816@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805816@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 17 Jan 2002, Ingo Molnar wrote:

> > There must be some path where a rq->lock remains set, with some sort of
> > print-eip-like tool I see lockups with
> >
> > load_balance  vs.   __wake_up
> > __wake_up     vs.   sched_tick
> > etc...
> 
> are you sure interrupts are properly disabled in all cases where the
> runqueue is touched? Eg. sched_tick() relies on having IRQs disabled.

Good question.

Actually I thought that local_irq_disable() really disables interrupts on
a CPU but the debugging output of a crashing run with the new scheduler
makes me believe that timer interrupts are still being delivered to the
CPU. Have a look yourself: I printed function addresses to video memory
and the history is the following (time arrow points upwards):

CPU # 0:
--------		   locks	
function:		rq0 	rq1	psr.i

debug_spin_lock		1	0	0
sched_tick		1	0	0
update_one_process	1	0	0
update_process_times	1	0	0
smp_do_timer		1	0	0
do_profile		1	0	0
timer_interrupt		1	0	0
handle_IRQ_event	1	0	0
lsapic_noop		1	0	0
do_IRQ			1	0	0
ia64_handle_irq		1	0	0
debug_spin_lock		0	0	0    <- locked rq0 lock, disabled irqs
spin_unlock		0	1	1    <- release_kernel_lock
schedule		0	1	1
spin_unlock		0	0	0
debug_spin_lock		0	0	0
wait_for_completion	0	0	1
spin_unlock		1	0	0
debug_spin_lock		0	0	0
wake_up_forked_process	0	1	1

CPU # 1:
--------
debug_spin_lock		1	0	0    <- tries to lock rq0 lock
spin_unlock		0	1	0    <- unlocked rq1 lock
load_balance		0	1	0
debug_spin_lock		0	0	0    <- lock rq1 lock, disable irqs
schedule		0	0	1


ia64_handle_irq() is called on CPU#0 while psr.i=0 which means: interrupts
are disabled. Looking into the IA64 manuals I find that the text
about psr.i emntions only disabling external interrupts, not the timer
interrupt or internal interrupts coming from the local APIC (i.e. IPIs
could also appear?).

Does anybody know whether psr.i disables all interrupts or not? I tried
setting the mmi bit on cr.tpr (mask maskable interrupts) in
local_irq_disable() and local_irq_restore(), but I still see this kind of
lockups.

A quick fix for the scheduler is to return from the timer interrupt when
the local runqueue is locked (same probably for IPIs) but ... isn't there
a method to disable ALL interrupts?

Thanks,

Erich


