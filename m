From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 29 Sep 2010 04:55:01 +0000
Subject: RE: [RFC trollpatch 1/1] genirq: Remove the fits all and nothing
Message-Id: <987664A83D2D224EAE907B061CE93D530160554808@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20100908152036.643594727@linutronix.de>
 <AANLkTikVHO9DmyTX==CwViDK1rP0masBwjMakHZ0U=kZ@mail.gmail.com>
 <alpine.LFD.2.00.1009271953390.2416@localhost6.localdomain6>
 <987664A83D2D224EAE907B061CE93D5301604712B4@orsmsx505.amr.corp.intel.com>
 <alpine.LFD.2.00.1009272048100.2416@localhost6.localdomain6>
 <987664A83D2D224EAE907B061CE93D530160471328@orsmsx505.amr.corp.intel.com>
 <20100929004607.GA18362@bombadil.infradead.org>
In-Reply-To: <20100929004607.GA18362@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Kyle McMartin <kyle@mcmartin.ca>
Cc: Thomas Gleixner <tglx@linutronix.de>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>, Christoph Hellwig <hch@infradead.org>, "linux-alpha@vger.kernel.org" <linux-alpha@vger.kernel.org>, "linux-cris-kernel@axis.com" <linux-cris-kernel@axis.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Yoshinori Sato <ysato@users.sourceforge.jp>, Hirokazu Takata <takata@linux-m32r.org>, Greg Ungerer <gerg@uclinux.org>, Jeff Dike <jdike@addtoit.com>, "linux-parisc@vger.kernel.org" <linux-parisc@vger.kernel.org>, Chris Zankel <chris@zankel.net>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>

> Did you end up solving this? ia64 iosapic and parisc iosapic still look
> fairly similar... I hit the same issue of ->end() not being called in
> the handle_level_irq path and ended up just folding in the missing bit
> to ->unmask (we were already EOI the IOSAPIC, but missing the EOI for
> the parisc cpu.)

Kyle,

Yes. Take a look in today's linux-next kernel (tag next-20100929)
for commit: 5d4bff94f9e0877a85b4dc573eb7a3f1d97c13ae

Essentially I just added an "unmask_irq()" call into the ->end
routine, renamed it, and used it as ->unmask.

It seems to work okay - I tried migrating interrupts around by
poking at /proc/irq/NNN/smp_affinity - and that still works.

-Tony
