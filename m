From: David Mosberger <davidm@hpl.hp.com>
Date: Tue, 04 Dec 2001 19:56:49 +0000
Subject: Re: [Linux-ia64] patch to no longer use ia64's software mmu
Message-Id: <marc-linux-ia64-105590698805603@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805585@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805585@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 4 Dec 2001 17:59:28 +0000 (GMT), Alan Cox <alan@lxorguk.ukuu.org.uk> said:

  Alan> ISA DMA. While there is no ISA DMA on ia64 (thankfully) many
  Alan> PCI cards have 26-31 bit limits.
  >>  We could do this if we there was a GFP_4GB zone.  Now that 2.5
  >> is open for business, it won't be long, right?

  Alan> I don't see the need: GFP_DMA is the ISA DMA zone. pci_* API
  Alan> is used by everyone else [for 2.5].

Without a 4GB zone, you may end up creating bounce buffers needlessly
for 32-bit capable DMA devices, no?

	--david

