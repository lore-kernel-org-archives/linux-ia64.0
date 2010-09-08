From: James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Wed, 08 Sep 2010 18:51:59 +0000
Subject: Re: [RFC trollpatch 1/1] genirq: Remove the fits all and nothing
Message-Id: <1283971919.11763.35.camel@mulgrave.site>
List-Id: <linux-ia64.vger.kernel.org>
References: <20100908152036.643594727@linutronix.de>
In-Reply-To: <20100908152036.643594727@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Thomas Gleixner <tglx@linutronix.de>
Cc: LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>, Christoph Hellwig <hch@infradead.org>, linux-alpha@vger.kernel.org, linux-cris-kernel@axis.com, Haavard Skinnemoen <hskinnemoen@atmel.com>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, Yoshinori Sato <ysato@users.sourceforge.jp>, Hirokazu Takata <takata@linux-m32r.org>, Greg Ungerer <gerg@uclinux.org>, Jeff Dike <jdike@addtoit.com>, linux-parisc@vger.kernel.org, Chris Zankel <chris@zankel.net>, linux-arch@vger.kernel.org

On Wed, 2010-09-08 at 18:14 +0000, Thomas Gleixner wrote:
> plain text document attachment (genirq-troll-patch.patch)
> __do_IRQ() has been deprecated after a two years migration phase in
> commit 0e57aa1. Since then another 18 month have gone by.
> 
> So here's the status three and a half years after the flow based
> infrastructure was merged:
> 
>  The following architectures are fully converted to the new flow
>  handler code:
> 
>   arm, avr32, blackfin, frv, microblaze, mips, mn10300, powerpc, score, sh,
>   sparc 64bit, tile, x86, xtensa
> 
>   (avr32 and xtensa should set CONFIG_GENERIC_HARDIRQS_NO__DO_IRQ
>   though)
> 
>  The following architectures are not using the generic interrupt
>  infrastructure at all and are therefor unaffected:
> 
>   s390, m68k, sparc 32bit
> 
>  The following architectures are still using __do_IRQ():
> 
>   alpha, cris, ia64, h8300, m32r, m68knommu, parisc, um
> 
> So now the question arises what to do with __do_IRQ().
> 
> Removing it would be the right thing, but that'll break 8 archs, so
> it's probably not considered a good idea, though for most of them the
> conversion should be reasonably trivial.
> 
> I'm happy to move that code into kernel/irq/cruft.c forever if there
> is no way to get the remaining users converted in the forseeable
> future. It looks like they can cope with the annoying build warning
> nicely.

Well, if you're going to deprecate something that 8 architectures rely
on, it would be nice to tell people ... or even just linux-arch ... most
of us do read that.  I've actually never noticed the warning the commit
activated in any of my parisc compiles for some reason.

> Either that or moving everything what breaks into staging/arch/* and
> hand it over to GregKH :)
> 
> Thoughts ?

We could move x86 into staging while it tries out the replacement ...

James


