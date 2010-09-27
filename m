From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 27 Sep 2010 19:01:51 +0000
Subject: RE: [RFC trollpatch 1/1] genirq: Remove the fits all and nothing
Message-Id: <987664A83D2D224EAE907B061CE93D530160471328@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20100908152036.643594727@linutronix.de>
 <AANLkTikVHO9DmyTX==CwViDK1rP0masBwjMakHZ0U=kZ@mail.gmail.com>
 <alpine.LFD.2.00.1009271953390.2416@localhost6.localdomain6>
 <987664A83D2D224EAE907B061CE93D5301604712B4@orsmsx505.amr.corp.intel.com>
 <alpine.LFD.2.00.1009272048100.2416@localhost6.localdomain6>
In-Reply-To: <alpine.LFD.2.00.1009272048100.2416@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Thomas Gleixner <tglx@linutronix.de>
Cc: LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>, Christoph Hellwig <hch@infradead.org>, "linux-alpha@vger.kernel.org" <linux-alpha@vger.kernel.org>, "linux-cris-kernel@axis.com" <linux-cris-kernel@axis.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Yoshinori Sato <ysato@users.sourceforge.jp>, Hirokazu Takata <takata@linux-m32r.org>, Greg Ungerer <gerg@uclinux.org>, Jeff Dike <jdike@addtoit.com>, "linux-parisc@vger.kernel.org" <linux-parisc@vger.kernel.org>, Chris Zankel <chris@zankel.net>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>

>> handle_level_irq() works for my level triggered interrupts if I add
>> a "desc->chip->end(irq)" call to it.
>
> Hmm, why isn't chip->unmask() sufficient ?
 
That's a good question.  I'll take a look at what ia64 is doing
in the ->unmask() and ->end() functions to see if I can fix this
with some code shuffling.

Thanks

-Tony
