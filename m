From: Erich Focht <focht@ess.nec.de>
Date: Mon, 21 Jan 2002 16:23:17 +0000
Subject: Re: [Linux-ia64] Help with Ingo scheduler on IA64
Message-Id: <marc-linux-ia64-105590698805895@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805816@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805816@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi David,

> psr.i *does* disable all interrupts, including NMI.  Device interrupts
> are generally referred to as "external interrupts" in the ia64
> manuals.  If you read the manual, you'll find there is no ambiguity
> about this at all.  For example, see Table 5-8: External Interrupt
> Control Registers; it lists ITV...

ok, I see what you mean and this is the behavior I expected from
psr.i. But in the paragraph at the beginning of 5.8 describing which
sources of interrupts we have I read:
   - external (I/O) devices...
   - locally connected devices (...can be programmed to generate external
     interrupts)
   - internal processor interrupts (timer, performance monitoring,
     corrected machine checks)
   - other processors.
So if the interrupts called explicitely "internal" have "External
Interrupt Control Registers" (as you pointed out in your email), why do we
need to call the interrupts "external" at all? Anyhow, as I'm not a native
english speaker, I might have misunderstood something.

My main problem still remains: how can it be that on CPU#0 the
timer_interrupt() routine is called while in schedule() and while
interrupts are disabled (psr.i is in the last column)? I paste the trace
again, one can follow the irq disabling and the runqueue locking very
nicely. I've seen this kind of lockup more than once and the mcount
compiler trick is very acurate in catching/showing each function the
kernel goes through.

So: if psr.i disables all interrupts, how can the timer interrupt
appear while we're in schedule()?

Thanks,
Erich

CPU # 0:
--------                   locks
function:               rq0     rq1     psr.i
 
debug_spin_lock         1       0       0
sched_tick              1       0       0
update_one_process      1       0       0
update_process_times    1       0       0
smp_do_timer            1       0       0
do_profile              1       0       0
timer_interrupt         1       0       0
handle_IRQ_event        1       0       0
lsapic_noop             1       0       0
do_IRQ                  1       0       0
ia64_handle_irq         1       0       0
debug_spin_lock         0       0       0    <- locked rq0 lock, disabled irqs
spin_unlock             0       1       1    <- release_kernel_lock
schedule                0       1       1
spin_unlock             0       0       0
debug_spin_lock         0       0       0
wait_for_completion     0       0       1
spin_unlock             1       0       0
debug_spin_lock         0       0       0
wake_up_forked_process  0       1       1
 
CPU # 1:
--------
debug_spin_lock         1       0       0    <- tries to lock rq0 lock
spin_unlock             0       1       0    <- unlocked rq1 lock
load_balance            0       1       0
debug_spin_lock         0       0       0    <- lock rq1 lock, disable irqs
schedule                0       0       1


