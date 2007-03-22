From: Bernhard Walle <bwalle@suse.de>
Date: Thu, 22 Mar 2007 23:04:07 +0000
Subject: Re: [PATCH] Fix irqpoll on IA64 (timer interrupt != 0)
Message-Id: <20070322230407.GA3333@sykes.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070320150027.GA18143@strauss.suse.de> <20070322140922.a59bea5c.akpm@linux-foundation.org>
In-Reply-To: <20070322140922.a59bea5c.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>

* Andrew Morton <akpm@linux-foundation.org> [2007-03-22 22:09]:
> On Tue, 20 Mar 2007 16:00:27 +0100
> Bernhard Walle <bwalle@suse.de> wrote:
> 
> > On IA64, the timer interrupt is not (always?) zero as it is on x86 platforms.
> > Also, the timer interrupt is CPU-local. Two things need to be changed to make
> > the irqpoll option make also working on IA64:
> > 
> >   o Call note_interrupt() also on CPU-local interrupts in __do_IRQ().
> >   o Set a variable timer_irq to the value of the timer interrupt
> >     after the timer interrupt has been registered and assigned.
> > 
> > That requires changes in Linux-generic files. The default of timer_irq is 0, so
> > the patch doesn't break i386/x86_64. However, other platforms also may also
> > have a timer interrupt non-equal to zero, so they can also use the new
> > set_timer_interrupt() function.
> 
> Couple of things..
> 
> I think the term 'timer_interrupt' is a bit generic-sounding.  Would it be
> better to call it irqpoll_interrupt?  After all, some architecture might
> want to use, umm, the keyboard interrupt to trigger IRQ polling ;)  

Well, the documentation of irqpoll says that it's called on the timer
interrupt. But maybe also the documentation should be changed. :)

> Also, the code presently passes the magic IRQ number into the generic IRQ
> code.  I wonder if we'd get a more pleasing result if we were to make the
> generic IRQ code call _out_ to the architecture:

I think I have a third solution. There's already IRQF_TIMER, and
that's used and defined in a few architectures already (like Sh), so
why not simply use that here. Maybe we should introduce IRQF_IRQPOLL,
but the concept would be the same. If we don't take care of shared
interrupt handlers (and I think sharing the timer interrupt is a
_very_ bad idea, are there architectures that do this?), the could
would look like this (+ the change in __do_IRQ).

What's your opinion on this approach? Of course, we would have to make
sure that IRQF_TIMER is defined on _every_ architectures, but that
would give us the chance to find out each architecture that also has a
timer interrupt != 0.


Index: mainline-msi-init/arch/ia64/kernel/time.c
=================================--- mainline-msi-init.orig/arch/ia64/kernel/time.c
+++ mainline-msi-init/arch/ia64/kernel/time.c
@@ -235,7 +235,7 @@ ia64_init_itm (void)
 
 static struct irqaction timer_irqaction = {
 	.handler =	timer_interrupt,
-	.flags =	IRQF_DISABLED,
+	.flags =	IRQF_DISABLED | IRQF_TIMER,
 	.name =		"timer"
 };
 
Index: mainline-msi-init/arch/x86_64/kernel/time.c
=================================--- mainline-msi-init.orig/arch/x86_64/kernel/time.c
+++ mainline-msi-init/arch/x86_64/kernel/time.c
@@ -320,7 +320,7 @@ void __init stop_timer_interrupt(void)
 }
 
 static struct irqaction irq0 = {
-	timer_interrupt, IRQF_DISABLED, CPU_MASK_NONE, "timer", NULL, NULL
+	timer_interrupt, IRQF_DISABLED | IRQF_TIMER, CPU_MASK_NONE, "timer", NULL, NULL
 };
 
 void __init time_init(void)
Index: mainline-msi-init/kernel/irq/spurious.c
=================================--- mainline-msi-init.orig/kernel/irq/spurious.c
+++ mainline-msi-init/kernel/irq/spurious.c
@@ -146,7 +146,7 @@ void note_interrupt(unsigned int irq, st
 
 	if (unlikely(irqfixup)) {
 		/* Don't punish working computers */
-		if ((irqfixup = 2 && irq = 0) || action_ret = IRQ_NONE) {
+		if ((irqfixup = 2 && (desc->action->flags & IRQF_TIMER)) || action_ret = IRQ_NONE) {
 			int ok = misrouted_irq(irq);
 			if (action_ret = IRQ_NONE)
 				desc->irqs_unhandled -= ok;
