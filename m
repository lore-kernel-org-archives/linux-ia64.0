From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Thu, 09 Aug 2007 03:36:25 +0000
Subject: Re: [PATCH] disable irq's and check need_resched before safe_halt
Message-Id: <46BA8BB9.30708@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070807134932.GA30447@sgi.com>
In-Reply-To: <20070807134932.GA30447@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Luck, Tony wrote:
> commit 1e185b97b4364063f1135604b87f8d8469944233
> Author: Chen, Kenneth W <kenneth.w.chen@intel.com>
> Date:   Tue Nov 15 14:37:05 2005 -0800
> 
>     [PATCH] ia64: cpu_idle performance bug fix
>     
>     Our performance validation on 2.6.15-rc1 caught a disastrous performance
>     regression on ia64 with netperf (-98%) and volanomark (-58%) compares to
>     previous kernel version 2.6.14-git7.  See the following chart (result
>     group 1 & 2).
>     
>       http://kernel-perf.sourceforge.net/results.machine_id&.html
>     
>     We have root caused it to commit 64c7c8f88559624abdbe12b5da6502e8879f8d28
>     
>     This changeset broke the ia64 task resched notification.  In
>     sched.c:resched_task(), a reschedule IPI is conditioned upon
>     TIF_POLLING_NRFLAG.  However, the above changeset unconditionally set
>     the polling thread flag for idle tasks regardless whether pal_halt_light
>     is in use or not.  As a result, resched IPI is not sent from
>     resched_task().  And since the default behavior on ia64 is to use
>     pal_halt_light, we end up delaying the rescheduling task until next
>     timer tick, and thus cause the performance regression.
>     
>     This fixes the performance bug.  I'm glad our performance suite is
>     turning up bad performance bug like this in time.
>     
>     Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>
>     Signed-off-by: Linus Torvalds <torvalds@osdl.org>
> 
> diff --git a/arch/ia64/kernel/process.c b/arch/ia64/kernel/process.c
> index e92ea64..4305d2b 100644
> --- a/arch/ia64/kernel/process.c
> +++ b/arch/ia64/kernel/process.c
> @@ -202,12 +202,9 @@ default_idle (void)
>  {
>  	local_irq_enable();
>  	while (!need_resched()) {
> -		if (can_do_pal_halt) {
> -			local_irq_disable();
> -			if (!need_resched())
> -				safe_halt();
> -			local_irq_enable();
> -		} else
> +		if (can_do_pal_halt)
> +			safe_halt();
> +		else
>  			cpu_relax();
>  	}
>  }
> @@ -272,10 +269,14 @@ cpu_idle (void)
>  {
>  	void (*mark_idle)(int) = ia64_mark_idle;
>    	int cpu = smp_processor_id();
> -	set_thread_flag(TIF_POLLING_NRFLAG);
>  
>  	/* endless idle loop with no priority at all */
>  	while (1) {
> +		if (can_do_pal_halt)
> +			clear_thread_flag(TIF_POLLING_NRFLAG);
> +		else
> +			set_thread_flag(TIF_POLLING_NRFLAG);
> +
>  		if (!need_resched()) {
>  			void (*idle)(void);
>  #ifdef CONFIG_SMP

The latter hunk of this patch makes sense since CPU in safe_halt()
doesn't poll TIF_NEED_RESCHED flag. Therefore such CPUs need to
request resched-IPI by clearing the TIF_POLLING_NRFLAG flag
(that was replaced by TS_POLLING).

But I could not catch the point of former hunk, because:

   - safe_halt() is an alias of ia64_pal_halt_light(), that is
     a PAL procedure. According to Intel Itanium ASDM rev2.2:

      "PAL procedures are not interruptible by external
       interrupt or NMI, since PSR.i must be 0 when the
       PAL procedure is called.(11.10.2.2)"

   - PAL transitions the state of CPU from LIGHT HALT to normal
     on receipt of unmasked external interrupt. An unmasked
     external interrupt is defined based on the current setting
     of the TPR control resister, but not PSR.i.

     And the priority of IPI(254) is higher than timer(239).
     So both of IPI and timer can wake up the CPU in LIGHT HALT.

I guess this former hunk is not needed, but I could be wrong.

Thanks,
H.Seto
