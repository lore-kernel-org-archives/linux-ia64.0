From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 12 May 2004 23:42:07 +0000
Subject: Re: [PATCH] fix "timer tick before it's due"
Message-Id: <16546.46671.935035.879125@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200405121721.30863.bjorn.helgaas@hp.com>
In-Reply-To: <200405121721.30863.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 12 May 2004 17:21:30 -0600, Bjorn Helgaas <bjorn.helgaas@hp.com> said:

  Bjorn> Fix the "timer tick before it's due" complaint from timer_interrupt().
  Bjorn> The problem was that smp_callin() turned on the periodic timer tick
  Bjorn> before syncing the ITC with the BP.

  Bjorn> Syncing the ITC happens with interrupts disabled, and if you're
  Bjorn> unlucky enough to (1) pend a timer interrupt, and (2) set the ITC
  Bjorn> back before the ITM value that caused the timer interrupt, you
  Bjorn> can get stuck for several iterations in the following cycle
  Bjorn> (assume 100 clocks per tick):

The original idea was for ia64_sync_itc() to be safe to be called any
time (e.g., for CPU hotplug or in case we ever want to support
periodic re-syncing between CPUs).  Indeed, ia64_sync_itc() has this
code already:

	/*
	 * Check whether we sync'd the itc ahead of the next timer interrupt.
	 * If so, just reset it.
	 */
	if (time_after(ia64_get_itc(), local_cpu_data->itm_next)) {
		Dprintk("CPU %d: oops, jumped a timer tick; resetting timer.\n",
			smp_processor_id());
		ia64_cpu_local_tick();
	}

However, it's kind of hard to imagine a clean solution to the timer
tick problem you observed so I think it's reasonable to require that
timer ticks be disabled before syncing the ITCs.  If so, we should
state that assumption in a comment at least (a BUG_ON might be even
better).  Also, the above code can then be deleted from
ia64_sync_itc().

	--david
