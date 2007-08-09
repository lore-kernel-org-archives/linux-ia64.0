From: Dimitri Sivanich <sivanich@sgi.com>
Date: Thu, 09 Aug 2007 12:41:01 +0000
Subject: Re: [PATCH] disable irq's and check need_resched before safe_halt
Message-Id: <20070809124101.GA12077@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070807134932.GA30447@sgi.com>
In-Reply-To: <20070807134932.GA30447@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Aug 09, 2007 at 12:36:25PM +0900, Hidetoshi Seto wrote:
> Luck, Tony wrote:
> >diff --git a/arch/ia64/kernel/process.c b/arch/ia64/kernel/process.c
> >index e92ea64..4305d2b 100644
> >--- a/arch/ia64/kernel/process.c
> >+++ b/arch/ia64/kernel/process.c
> >@@ -202,12 +202,9 @@ default_idle (void)
> > {
> > 	local_irq_enable();
> > 	while (!need_resched()) {
> >-		if (can_do_pal_halt) {
> >-			local_irq_disable();
> >-			if (!need_resched())
> >-				safe_halt();
> >-			local_irq_enable();
> >-		} else
> >+		if (can_do_pal_halt)
> >+			safe_halt();
> >+		else
> > 			cpu_relax();
> > 	}
> > }
> 
..
..

> 
> But I could not catch the point of former hunk, because:
> 
>   - safe_halt() is an alias of ia64_pal_halt_light(), that is
>     a PAL procedure. According to Intel Itanium ASDM rev2.2:
> 
>      "PAL procedures are not interruptible by external
>       interrupt or NMI, since PSR.i must be 0 when the
>       PAL procedure is called.(11.10.2.2)"
> 
>   - PAL transitions the state of CPU from LIGHT HALT to normal
>     on receipt of unmasked external interrupt. An unmasked
>     external interrupt is defined based on the current setting
>     of the TPR control resister, but not PSR.i.
> 
>     And the priority of IPI(254) is higher than timer(239).
>     So both of IPI and timer can wake up the CPU in LIGHT HALT.
> 
> I guess this former hunk is not needed, but I could be wrong.
> 
> Thanks,
> H.Seto

And the problem with the former hunk is that it reintroduces the
race between checking !need_resched() and receiving a timer interrupt
before safe_halt().  You could have a thread needing execution at
the time the cpu enters LIGHT HALT.  If irq's are disabled, LIGHT
HALT will return relatively quickly with the pending timer interrupt,
rather than having to wait for the next one.
