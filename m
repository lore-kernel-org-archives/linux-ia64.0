From: Erich Focht <focht@ess.nec.de>
Date: Mon, 21 Jan 2002 18:45:20 +0000
Subject: Re: [Linux-ia64] Help with Ingo scheduler on IA64
Message-Id: <marc-linux-ia64-105590698805901@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805816@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805816@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Ingo,

what's the problem with the following code?

switch_tasks:
	prev->need_resched = 0;

	if (likely(prev != next)) {
		rq->nr_switches++;
		rq->curr = next;
		spin_unlock_irq(&rq->lock);          // <-
		context_switch(prev, next, 0);
		/*
		 * The runqueue pointer might be from another CPU
		 * if the new task was last running on a different
		 * CPU - thus re-load it.
		 */
		barrier();
		rq = this_rq();
		spin_lock_irq(&rq->lock);           // <-
	}

	spin_unlock_irq(&rq->lock);


Thanks,
Erich


On Mon, 21 Jan 2002, Ingo Molnar wrote:

> 
> On Mon, 21 Jan 2002, Erich Focht wrote:
> 
> > Unfortunately the context switch in Ingo's scheduler happens with the
> > runqueue lock held, which can lead to a deadlock eg. if the timer
> > interrupt is called inside and sched_tick spinlocks on the runqueue
> > lock held by schedule(). On IA64 (HZ24) this probably happens much
> > more frequently than on IA32 (HZ0).
> 
> we call context_switch() with irqs disabled. The ia64 version of
> switch_to() should not re-enable IRQs or it will deadlock.
> 
> 	Ingo


