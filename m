From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 27 Feb 2004 22:22:07 +0000
Subject: RE: [Patch] speed up interrupt handling
Message-Id: <16447.49935.898724.597340@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16446.43280.853544.583305@wombat.disy.cse.unsw.edu.au>
In-Reply-To: <16446.43280.853544.583305@wombat.disy.cse.unsw.edu.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Sat, 28 Feb 2004 08:27:40 +1100, Peter Chubb <peter@chubb.wattle.id.au> said:

>>>>> "David" = David Mosberger <davidm@napali.hpl.hp.com> writes:

  David> So why is irq enabling/disabling on the critical path for
  David> this driver?

  Peter> Because IRQs are disabled for every hardware interrupt, and
  Peter> enabled after each interrupt returns.

OK, it's been really long since I worked on this, but AFAIR, for
level-triggered interrupts, there should be no masking/unmasking
during interrupt delivery.  What am I missing?

	--david
