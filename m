From: Andrew Morton <akpm@linux-foundation.org>
Date: Tue, 30 Oct 2007 22:22:18 +0000
Subject: Re: [patch] __do_IRQ does not check IRQ_DISABLED when IRQ_PER_CPU
Message-Id: <20071030152218.3bd5f6a5.akpm@linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20071030162657.GA21728@sgi.com>
In-Reply-To: <20071030162657.GA21728@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Russ Anderson <rja@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>

On Tue, 30 Oct 2007 11:26:57 -0500
Russ Anderson <rja@sgi.com> wrote:

> [patch] __do_IRQ does not check IRQ_DISABLED when IRQ_PER_CPU is set
> 
> In __do_IRQ(), the normal case is that IRQ_DISABLED is checked and if
> set the handler (handle_IRQ_event()) is not called.  
> 
> Earlier in __do_IRQ(), if IRQ_PER_CPU is set the code does not check
> IRQ_DISABLED and calls the handler even though IRQ_DISABLED is set.
> This behavior seems unintentional.
> 
> One user encountering this behavior is the CPE handler (in 
> arch/ia64/kernel/mca.c).  When the CPE handler encounters too many
> CPEs (such as a solid single bit error), it sets up a polling timer
> and disables the CPE interrupt (to avoid excessive overhead logging
> the stream of single bit errors).  disable_irq_nosync() is called
> which sets IRQ_DISABLED.  The IRQ_PER_CPU flag was previously set
> (in ia64_mca_late_init()).  The net result is the CPE handler gets
> called even though it is marked disabled.
> 
> If the behavior of not checking IRQ_DISABLED when IRQ_PER_CPU is
> set is intentional, it would be worthy of a comment describing 
> the intended behavior.  disable_irq_nosync() does call chip->disable()
> to provide a chipset specifiec interface for disabling the interrupt,
> which avoids this issue when used.
> 
> Comments???
> 

It looks right to me.

> 
> --------------------------------------------------------------------
> ---
>  kernel/irq/handle.c |    8 +++++---
>  1 file changed, 5 insertions(+), 3 deletions(-)
> 
> Index: linus/kernel/irq/handle.c
> =================================> --- linus.orig/kernel/irq/handle.c	2007-10-30 09:49:26.000000000 -0500
> +++ linus/kernel/irq/handle.c	2007-10-30 10:23:52.436719688 -0500
> @@ -178,9 +178,11 @@ fastcall unsigned int __do_IRQ(unsigned 
>  		 */
>  		if (desc->chip->ack)
>  			desc->chip->ack(irq);
> -		action_ret = handle_IRQ_event(irq, desc->action);
> -		if (!noirqdebug)
> -			note_interrupt(irq, desc, action_ret);
> +		if (likely(!(desc->status & IRQ_DISABLED))) {
> +			action_ret = handle_IRQ_event(irq, desc->action);
> +			if (!noirqdebug)
> +				note_interrupt(irq, desc, action_ret);
> +		}
>  		desc->chip->end(irq);
>  		return 1;
>  	}

Alas, I can't remember who wrote (and cares about) the IRQ_PER_CPU support.
 Oh well.

