From: David Mosberger <davidm@hpl.hp.com>
Date: Tue, 04 Dec 2001 19:56:21 +0000
Subject: Re: [Linux-ia64] 2.4.16-ia64-011128 is missing dma64_addr_t
Message-Id: <marc-linux-ia64-105590698805605@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805568@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805568@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 4 Dec 2001 17:29:32 +0100, Christoph Hellwig <hch@caldera.de> said:

  Christoph> The problem is that we need a uniform API on all Linux
  Christoph> plattforms.  Linus has decided on this one, may it be
  Christoph> nice or not. (And I don't really like the pci_dac_* part
  Christoph> as it is to implementation-specific).

  >> The only extra overhead of going through normal pci mapping
  >> routines is a function call.  If that's noticable, you have a
  >> very fast device indeed.

  Christoph> On IA64 yes, on i386 or other 32bit plattforms not.

Then fix those implementations.  There is nothing difficult in first
checking the DMA mask.

Look, this is precisely why I'm reluctant to add the pci_dac*()
support now: people will use it in the wrong way and eventually we'll have
to add yet another layer of mapping underneath pci_dac_*().

pci_dac_*() is not intended for all DAC-capable devices.  It is
intended for DAC capable devices that generate tons of mappings.  If
you don't believe me, check with Dave Miller.

	--david

