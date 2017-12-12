From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Date: Tue, 12 Dec 2017 02:50:52 +0000
Subject: Re: [PATCH 11/13] irq debug: do not use print_symbol()
Message-Id: <20171212025052.GD7798@jagdpanzerIV>
List-Id: <linux-ia64.vger.kernel.org>
References: <20171211125025.2270-1-sergey.senozhatsky@gmail.com>
 <20171211125025.2270-12-sergey.senozhatsky@gmail.com>
 <063a776096964e8192c94e38413edbe0@AcuMS.aculab.com>
In-Reply-To: <063a776096964e8192c94e38413edbe0@AcuMS.aculab.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org

On (12/11/17 12:55), David Laight wrote:
> >  kernel/irq/debug.h | 8 +++-----
> >  1 file changed, 3 insertions(+), 5 deletions(-)
> > 
> > diff --git a/kernel/irq/debug.h b/kernel/irq/debug.h
> > index 17f05ef8f575..5766e15c1160 100644
> > --- a/kernel/irq/debug.h
> > +++ b/kernel/irq/debug.h
> ...
> > @@ -15,13 +13,13 @@ static inline void print_irq_desc(unsigned int irq, struct irq_desc *desc)
> >  	printk("irq %d, desc: %p, depth: %d, count: %d, unhandled: %d\n",
> >  		irq, desc, desc->depth, desc->irq_count, desc->irqs_unhandled);
> >  	printk("->handle_irq():  %p, ", desc->handle_irq);
> > -	print_symbol("%s\n", (unsigned long)desc->handle_irq);
> > +	pr_cont("%pS\n", desc->handle_irq);
> 
> Looks like you can (and should) use a single printk() instead of pr_cont.

thanks, good point. those pr_cont()-s basically just replicate
the old behaviour; but it'll be better to get tid of them. will
follow up shortly.

	-ss
