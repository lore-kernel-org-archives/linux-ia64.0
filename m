From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 08 Sep 2010 20:36:24 +0000
Subject: RE: [RFC trollpatch 1/1] genirq: Remove the fits all and nothing
Message-Id: <987664A83D2D224EAE907B061CE93D53015DB0FB80@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20100908152036.643594727@linutronix.de>
 <20100908185824.GD24791@bombadil.infradead.org>
In-Reply-To: <20100908185824.GD24791@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Kyle McMartin <kyle@mcmartin.ca>, Thomas Gleixner <tglx@linutronix.de>
Cc: LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>, Christoph Hellwig <hch@infradead.org>, "linux-alpha@vger.kernel.org" <linux-alpha@vger.kernel.org>, "linux-cris-kernel@axis.com" <linux-cris-kernel@axis.com>, Haavard Skinnemoen <hskinnemoen@atmel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Yoshinori Sato <ysato@users.sourceforge.jp>, Hirokazu Takata <takata@linux-m32r.org>, Greg Ungerer <gerg@uclinux.org>, Jeff Dike <jdike@addtoit.com>, "linux-parisc@vger.kernel.org" <linux-parisc@vger.kernel.org>, Chris Zankel <chris@zankel.net>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>

> Thanks Thomas for the reminder, I'll poke at fixing parisc this week,
> and maybe try to fix ia64 and alpha too as penance for forgetting about
> this for so long.

I'll be happy to see ia64 converted ... I did look at it once a long
time ago, but couldn't work out what I had to do to replace do_IRQ.
If Kyle figures out the patch, I'll test.  If not, then some pointers
would be helpful.

-Tony
