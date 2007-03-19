From: Bernhard Walle <bwalle@suse.de>
Date: Mon, 19 Mar 2007 18:37:10 +0000
Subject: Re: [Fastboot] [PATCH] [REVIEW] Fix irqpoll on IA64 (timer interrupt != 0)
Message-Id: <20070319183710.GA23499@strauss.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070319181336.GC12628@strauss.suse.de> <9a8748490703191129h396211e9q59eeea9533d00c38@mail.gmail.com>
In-Reply-To: <9a8748490703191129h396211e9q59eeea9533d00c38@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jesper Juhl <jesper.juhl@gmail.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, fastboot@lists.osdl.org

* Jesper Juhl <jesper.juhl@gmail.com> [2007-03-19 19:29]:
> >
> > -void
> > +int
> >  register_percpu_irq (ia64_vector vec, struct irqaction *action)
> >  {
> 
> Each and every function example in Documentation/CodingStyle has the
> return type on the same line as the function name, so why not get
> these in-line while you are modifying them anyway?

Because all other functions in that file are coded this way. I think
it looks better if you don't change the style in a particular file.
Am I wrong?

> int register_percpu_irq (ia64_vector vec, struct irqaction *action)
> 
> 
> > @@ -174,6 +175,13 @@ void note_interrupt(unsigned int irq, st
> >         desc->irqs_unhandled = 0;
> >  }
> >
> > +
> > +void set_timer_interrupt(unsigned int irq)
> 
> Just one blank line between functions, as pr CodingStyle:
>    "In source files, separate functions with one blank line.  ..."

Fixed (locally). I'll repost if I get feedback of the contents of the
patch.


Regards,
Bernhard

