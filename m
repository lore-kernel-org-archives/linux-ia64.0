From: David Mosberger <davidm@hpl.hp.com>
Date: Tue, 04 Dec 2001 19:54:34 +0000
Subject: Re: [Linux-ia64] 2.4.16-ia64-011128 is missing dma64_addr_t
Message-Id: <marc-linux-ia64-105590698805599@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805568@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805568@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 4 Dec 2001 16:52:05 +0100, Christoph Hellwig <hch@caldera.de> said:

  Christoph> On Tue, Dec 04, 2001 at 07:49:07AM -0800, David Mosberger
  Christoph> wrote: IA64 should use instead of it's horrible iommu
  Christoph> emulation.
  >>  Huh?  pci_dac_*() does not help you here at all.  pci_dac_*() is
  >> only needed/useful for 64-bit platforms which use a dma_addr_t
  >> that is smaller than 64 bits.  And even then is it needed only
  >> for drivers that create tons of mappings.

  Christoph> pci_dac_*() is defined to operate on dma64_addr_t
  Christoph> independand on wether it actually is different on
  Christoph> dma_addr_t.

Yes, but pci_dac_*() is also specifically designed *not* to do any
remapping.  It must do direct translation between address spaces
(i.e., basically what used to be called bus_to_virt()/virt_to_bus()).
It works only for fully-64bit capable DMA engines.

  Christoph> Maybe it should have been named dmadac_addr_t instead..

Perhaps.

	--david

