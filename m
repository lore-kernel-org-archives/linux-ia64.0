From: David Mosberger <davidm@hpl.hp.com>
Date: Tue, 04 Dec 2001 19:54:53 +0000
Subject: Re: [Linux-ia64] 2.4.16-ia64-011128 is missing dma64_addr_t
Message-Id: <marc-linux-ia64-105590698805601@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805568@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805568@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 4 Dec 2001 17:00:33 +0100, Christoph Hellwig <hch@caldera.de> said:

  Chris> On Tue, Dec 04, 2001 at 07:57:07AM -0800, David Mosberger
  Chris> wrote:
  >> Yes, but pci_dac_*() is also specifically designed *not* to do
  >> any remapping.  It must do direct translation between address
  >> spaces (i.e., basically what used to be called
  >> bus_to_virt()/virt_to_bus()).  It works only for fully-64bit
  >> capable DMA engines.

  Chris> I don't get the point the above contributes to this
  Chris> discussion.  Does this mean you want drivers that are DAC
  Chris> capable to use pci_dac_* on 32bit plattforms and pci_* on
  Chris> 64bit plattforms?

No, of course not.  You that said ia64 should use pci_dac_*() instead
of an I/O TLB emulation and I'm saying that this doesn't work because
pci_dac_*() is a non-solution.

The suggestion is to always use the normal pci_*() mapping routines,
independent of whether the platform is 32 or 64 bit.

	--david

