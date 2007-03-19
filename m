From: "Jesper Juhl" <jesper.juhl@gmail.com>
Date: Mon, 19 Mar 2007 18:29:37 +0000
Subject: Re: [PATCH] [REVIEW] Fix irqpoll on IA64 (timer interrupt != 0)
Message-Id: <9a8748490703191129h396211e9q59eeea9533d00c38@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070319181336.GC12628@strauss.suse.de>
In-Reply-To: <20070319181336.GC12628@strauss.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, fastboot@lists.osdl.org

On 19/03/07, Bernhard Walle <bwalle@suse.de> wrote:
> On IA64, the timer interrupt is not (always?) zero as it is on x86 platforms.
> Also, the timer interrupt is CPU-local. Two things need to be changed to make
> the irqpoll option make also working on IA64:
>
>   o Call note_interrupt() also on CPU-local interrupts in __do_IRQ().
>   o Set a variable timer_irq to the value of the timer interrupt
>     after the timer interrupt has been registered and assigned.
>
> That requires changes in Linux-generic files. The default of timer_irq is 0, so
> the patch doesn't break i386/x86_64. However, other platforms also may also
> have a timer interrupt non-equal to zero, so they can also use the new
> set_timer_interrupt() function.
>
> The patch is against 2.6.21-rc4. Please give me your input how to improve
> the way it's done if you don't like the way I did the change. irqpoll is
> required to work with kdump in some situations and that's why I discovered
> that kdump doesn't work on that platform (HP rx2660).
>

A few style comments below.

>
> Signed-off-by: Bernhard Walle <bwalle@suse.de>
>
> ---
>  arch/ia64/kernel/irq_ia64.c |    6 +++++-
>  arch/ia64/kernel/time.c     |    6 +++++-
>  include/asm-ia64/hw_irq.h   |    2 +-
>  include/linux/irq.h         |    3 +++
>  kernel/irq/handle.c         |    2 ++
>  kernel/irq/spurious.c       |   10 +++++++++-
>  6 files changed, 25 insertions(+), 4 deletions(-)
>
> Index: mainline-msi-init/arch/ia64/kernel/irq_ia64.c
> =================================> --- mainline-msi-init.orig/arch/ia64/kernel/irq_ia64.c
> +++ mainline-msi-init/arch/ia64/kernel/irq_ia64.c
> @@ -280,11 +280,12 @@ static struct irqaction resched_irqactio
>  };
>  #endif
>
> -void
> +int
>  register_percpu_irq (ia64_vector vec, struct irqaction *action)
>  {

Each and every function example in Documentation/CodingStyle has the
return type on the same line as the function name, so why not get
these in-line while you are modifying them anyway?

int register_percpu_irq (ia64_vector vec, struct irqaction *action)


> @@ -174,6 +175,13 @@ void note_interrupt(unsigned int irq, st
>         desc->irqs_unhandled = 0;
>  }
>
> +
> +void set_timer_interrupt(unsigned int irq)

Just one blank line between functions, as pr CodingStyle:
   "In source files, separate functions with one blank line.  ..."


-- 
Jesper Juhl <jesper.juhl@gmail.com>
Don't top-post  http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please      http://www.expita.com/nomime.html
