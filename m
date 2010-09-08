From: Thomas Gleixner <tglx@linutronix.de>
Date: Wed, 08 Sep 2010 21:35:05 +0000
Subject: Re: [RFC trollpatch 1/1] genirq: Remove the fits all and nothing
Message-Id: <alpine.LFD.2.00.1009082333350.2477@localhost6.localdomain6>
List-Id: <linux-ia64.vger.kernel.org>
References: <20100908152036.643594727@linutronix.de>  <1283971919.11763.35.camel@mulgrave.site>  <alpine.LFD.2.00.1009082056210.2477@localhost6.localdomain6> <1283978124.11763.80.camel@mulgrave.site>
In-Reply-To: <1283978124.11763.80.camel@mulgrave.site>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>, Christoph Hellwig <hch@infradead.org>, linux-alpha@vger.kernel.org, linux-cris-kernel@axis.com, Haavard Skinnemoen <hskinnemoen@atmel.com>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, Yoshinori Sato <ysato@users.sourceforge.jp>, Hirokazu Takata <takata@linux-m32r.org>, Greg Ungerer <gerg@uclinux.org>, Jeff Dike <jdike@addtoit.com>, linux-parisc@vger.kernel.org, Chris Zankel <chris@zankel.net>, linux-arch@vger.kernel.org

On Wed, 8 Sep 2010, James Bottomley wrote:
> On Wed, 2010-09-08 at 21:34 +0200, Thomas Gleixner wrote:
> > On Wed, 8 Sep 2010, James Bottomley wrote:
> > > On Wed, 2010-09-08 at 18:14 +0000, Thomas Gleixner wrote:
> > > > plain text document attachment (genirq-troll-patch.patch)
> > > > __do_IRQ() has been deprecated after a two years migration phase in
> > > > commit 0e57aa1. Since then another 18 month have gone by.
> > > > 
> > > > So here's the status three and a half years after the flow based
> > > > infrastructure was merged:
> > > > 
> > > >  The following architectures are fully converted to the new flow
> > > >  handler code:
> > > > 
> > > >   arm, avr32, blackfin, frv, microblaze, mips, mn10300, powerpc, score, sh,
> > > >   sparc 64bit, tile, x86, xtensa
> > > > 
> > > >   (avr32 and xtensa should set CONFIG_GENERIC_HARDIRQS_NO__DO_IRQ
> > > >   though)
> > > > 
> > > >  The following architectures are not using the generic interrupt
> > > >  infrastructure at all and are therefor unaffected:
> > > > 
> > > >   s390, m68k, sparc 32bit
> > > > 
> > > >  The following architectures are still using __do_IRQ():
> > > > 
> > > >   alpha, cris, ia64, h8300, m32r, m68knommu, parisc, um
> > > > 
> > > > So now the question arises what to do with __do_IRQ().
> > > > 
> > > > Removing it would be the right thing, but that'll break 8 archs, so
> > > > it's probably not considered a good idea, though for most of them the
> > > > conversion should be reasonably trivial.
> > > > 
> > > > I'm happy to move that code into kernel/irq/cruft.c forever if there
> > > > is no way to get the remaining users converted in the forseeable
> > > > future. It looks like they can cope with the annoying build warning
> > > > nicely.
> > > 
> > > Well, if you're going to deprecate something that 8 architectures rely
> > > on, it would be nice to tell people ... or even just linux-arch ... most
> > 
> > It's been told people. The deprecation patch was on LKMl (I don't
> > remember whether I sent it to linux-arch),
> 
> You didn't ... I checked.
> 
> >  but there were a bunch of
> > related patches to clean out the old irq related cruft which were sent
> > to linux-arch and also hit the parisc tree. There is an entry in
> > feature-removal-schedule.txt for 18 month now.
> > 
> > > of us do read that.  I've actually never noticed the warning the commit
> > > activated in any of my parisc compiles for some reason.
> > 
> > CONFIG_ENABLE_WARN_DEPRECATED=y perhaps ?
> >
> > I'm really tired of your whining when you did not get a personalized
> > taylored to your needs info.
> 
> So you send out deliberate flame bait and then suffer humour failure at
> an ironic reply?

Darn, I missed the ironic tag.

I added you to the "beware-of-british-irony" filter of my .procmailrc
to avoid that in the future.

Thanks,

	tglx
