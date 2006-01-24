From: Ingo Molnar <mingo@elte.hu>
Date: Tue, 24 Jan 2006 21:41:18 +0000
Subject: Re: [PATCH] SN2 user-MMIO CPU migration
Message-Id: <20060124214118.GA28186@elte.hu>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060118163305.Y42462@chenjesu.americas.sgi.com>
In-Reply-To: <20060118163305.Y42462@chenjesu.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


* Brent Casavant <bcasavan@sgi.com> wrote:

> +/**
> + * sn_switch_from - SN-specific migrate-from actions
> + * @task: Task being switched to new CPU
> + * 
> + * SN2 PIO writes from separate CPUs are not guaranteed to arrive in order.
> + * Context switching user threads which have memory-mapped MMIO may cause
> + * PIOs to issue from seperate CPUs, thus the PIO writes must be drained
> + * from the previous CPU's Shub before execution resumes on the new CPU.
> + */
> +void sn_switch_from(struct task_struct *task)
> +{
> +	pda_t *last_pda = pdacpu(task_thread_info(task)->last_cpu);
> +	volatile unsigned long *adr = last_pda->pio_write_status_addr;
> +	unsigned long val = last_pda->pio_write_status_val;
> +
> +	/* Drain PIO writes from old CPU's Shub */
> +	while ((*adr & SH_PIO_WRITE_STATUS_PENDING_WRITE_COUNT_MASK) != val)
> +		cpu_relax();
> +}

btw., note that if such PIO writes happen frequently on a system, you 
_really_ want this to be executed as late as possible - to give those 
writes a chance to drain while this CPU is doing other useful work. In 
that sense, doing the draining in the migration decision code is pretty 
much the worst place to do it, because that's the _soonest_ point we 
know that the task will migrate. That might still be milliseconds away 
from actually hitting the CPU. Even if it was migrated to a totally idle 
CPU, there's microseconds of codepath between the migration decision, 
and the actual point in time where the switch_to() executes.

a further detail: in that sense i'd rather suggest to move the condition 
to after the __switch_to() call. You can drain anytime, as long as it's 
done before userspace can issue new PIO writes. So you could as well do 
it in the new context.

	Ingo
