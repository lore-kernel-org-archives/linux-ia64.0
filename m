From: "Dialup Jon Norstog" <thursday@allidaho.com>
Date: Thu, 09 Sep 2010 13:44:36 +0000
Subject: RE: [RFC trollpatch 1/1] genirq: Remove the fits all and nothing __do_IRQ() code
Message-Id: <20100909134113.M84121@allidaho.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20100908152036.643594727@linutronix.de> <4BEA3FF3CAA35E408EA55C7BE2E61D05583CE93218@xmail3.se.axis.com>
In-Reply-To: <4BEA3FF3CAA35E408EA55C7BE2E61D05583CE93218@xmail3.se.axis.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mikael Starvik <mikael.starvik@axis.com>, Thomas Gleixner <tglx@linutronix.de>, LKML <linux-kernel@vger.kernel.org>, Jesper Nilsson <jespern@axis.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>, Christoph Hellwig <hch@infradead.org>, "linux-alpha@vger.kernel.org" <linux-alpha@vger.kernel.org>, linux-cris-kernel <linux-cris-kernel@axis.com>, Haavard Skinnemoen <hskinnemoen@atmel.com>, Tony Luck <tony.luck@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Yoshinori Sato <ysato@users.sourceforge.jp>, Hirokazu Takata <takata@linux-m32r.org>, Greg Ungerer <gerg@uclinux.org>, Jeff Dike <jdike@addtoit.com>, "linux-parisc@vger.kernel.org" <linux-parisc@vger.kernel.org>, Chris Zankel <chris@zankel.net>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>




---------- Original Message -----------
From: Mikael Starvik <mikael.starvik@axis.com>
To: Thomas Gleixner <tglx@linutronix.de>, LKML <linux-k 
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
> 
> Either that or moving everything what breaks into staging/arch/* and
> hand it over to GregKH :)
> 
> Thoughts ?
 

To the lists:

My thought is, put something in the readme - like Jay Estabrook's note in the
current Alpha Core build.  At least so those of us who get wierd msgs during a
kernel build can know what they are all about.

TIA

jn
