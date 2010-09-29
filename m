From: Kyle McMartin <kyle@mcmartin.ca>
Date: Wed, 29 Sep 2010 00:46:07 +0000
Subject: Re: [RFC trollpatch 1/1] genirq: Remove the fits all and nothing
Message-Id: <20100929004607.GA18362@bombadil.infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20100908152036.643594727@linutronix.de>
 <AANLkTikVHO9DmyTX==CwViDK1rP0masBwjMakHZ0U=kZ@mail.gmail.com>
 <alpine.LFD.2.00.1009271953390.2416@localhost6.localdomain6>
 <987664A83D2D224EAE907B061CE93D5301604712B4@orsmsx505.amr.corp.intel.com>
 <alpine.LFD.2.00.1009272048100.2416@localhost6.localdomain6>
 <987664A83D2D224EAE907B061CE93D530160471328@orsmsx505.amr.corp.intel.com>
In-Reply-To: <987664A83D2D224EAE907B061CE93D530160471328@orsmsx505.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>, Christoph Hellwig <hch@infradead.org>, "linux-alpha@vger.kernel.org" <linux-alpha@vger.kernel.org>, "linux-cris-kernel@axis.com" <linux-cris-kernel@axis.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Yoshinori Sato <ysato@users.sourceforge.jp>, Hirokazu Takata <takata@linux-m32r.org>, Greg Ungerer <gerg@uclinux.org>, Jeff Dike <jdike@addtoit.com>, "linux-parisc@vger.kernel.org" <linux-parisc@vger.kernel.org>, Chris Zankel <chris@zankel.net>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>

On Mon, Sep 27, 2010 at 12:01:51PM -0700, Luck, Tony wrote:
> > Hmm, why isn't chip->unmask() sufficient ?
>  
> That's a good question.  I'll take a look at what ia64 is doing
> in the ->unmask() and ->end() functions to see if I can fix this
> with some code shuffling.
> 

Did you end up solving this? ia64 iosapic and parisc iosapic still look
fairly similar... I hit the same issue of ->end() not being called in
the handle_level_irq path and ended up just folding in the missing bit
to ->unmask (we were already EOI the IOSAPIC, but missing the EOI for
the parisc cpu.)

--Kyle
