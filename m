From: David Mosberger <davidm@hpl.hp.com>
Date: Wed, 06 Feb 2002 16:54:02 +0000
Subject: Re: [Linux-ia64] Proper fix for sym53c8xx_2 driver and dma64_addr_t
Message-Id: <marc-linux-ia64-105590698806005@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805991@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805991@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 6 Feb 2002 09:21:29 +0100, Christoph Hellwig <hch@caldera.de> said:

  Christoph> On Tue, Feb 05, 2002 at 01:44:06PM -0800, David Mosberger
  Christoph> wrote: IA64 needs to define dma64_addr_t.

  >>  Not before the driver writers understand when to use it.

  Christoph> Architecture maintainers are not supposed to decide
  Christoph> whether driver writers understand APIs.  The dma64_addr_t
  Christoph> type is part of the PCI DMA interface and IA64 needs to
  Christoph> defines it.

Then find a better way to catch errant uses of dma64_addr_t.  I have
spent too much time discussing the DMA API with Dave M to see it being
misused for no good reason.  It will take some time until there are
enough sample drivers that show proper usage of the DMA interface.
There is almost no driver that needs dma64_addr_t.  We can add it
once there is an ia64 driver that *really* needs it.

  Christoph> Linus, could you please accept the below patch to define
  Christoph> dma64_addr_t on IA64?

Christoph, if you want this type your linux distro, you can add it
with your own patch.  For the time being, I'm the ia64 linux
maintainer so I hope you can respect my decisions.

	--david

