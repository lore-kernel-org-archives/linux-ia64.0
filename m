From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 16 Nov 2004 17:53:41 +0000
Subject: Re: [PATCH] remove dead wood from asm-ia64/hardirq.h
Message-Id: <16794.16037.765208.294070@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20041116091408.GA3050@lst.de>
In-Reply-To: <20041116091408.GA3050@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 16 Nov 2004 10:14:08 +0100, Christoph Hellwig <hch@lst.de> said:

  Christoph> nmi_count() is a stub only used once in
  Christoph> arch/ia64/kernel/irq.c, so we can use 0 directly there.
  Christoph> I suspect it was added to keep irq.c in sync with i386,

That's exactly right.

  Christoph> but even the CONFIG_GENERIC_HARDIRQS code (<hint>which
  Christoph> IA64 needs to be converted to</hint>)

Couldn't agree more! ;-)

	--david
