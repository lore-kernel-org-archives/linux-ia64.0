From: Erich Focht <efocht@ess.nec.de>
Date: Wed, 30 Jan 2002 16:58:33 +0000
Subject: [Linux-ia64] switch_mm race condition with Ingo's scheduler
Message-Id: <marc-linux-ia64-105590698805962@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

I found another race condition with the O(1) MQ scheduler from Ingo. The
pattern is the following:

CPU#0:
------
schedule        -> take runqueue #0 lock
  context_switch
    activate_mm
      get_new_mmu_context
        wrap_mmu_context
          flush_tlb_all
            smp_call_function (and wait...)

CPU#1:
------
schedule        -> disable interrupts, take runqueue #1 lock
  load_balance  -> wants to get task from runqueue #0: release rq#1,
                   spinlock on rq #0 (interrupts disabled) => wait forever...


As the interrupts are disabled on CPU#1, the IPI cannot reach CPU#1.

Enabling interrupts while waiting for the rq#0 lock in load_balance is not
an option because it leads to other race conditions (the timer-interrupt
may call sched_tick and load_balance and end up spin-waiting on the same
lock).

Is it really necessary to flush all TLBs when doing a context switch on
one?

Any ideas, solutions?

Thanks,
Erich


