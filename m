From: David Mosberger <davidm@hpl.hp.com>
Date: Tue, 04 Dec 2001 19:55:02 +0000
Subject: Re: [Linux-ia64] 2.4.16-ia64-011128 is missing dma64_addr_t
Message-Id: <marc-linux-ia64-105590698805607@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805568@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805568@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 4 Dec 2001 17:18:23 +0100, Christoph Hellwig <hch@caldera.de> said:

  Chris> On Tue, Dec 04, 2001 at 08:12:47AM -0800, David Mosberger
  Chris> wrote:
  >> No, of course not.  You that said ia64 should use pci_dac_*()
  >> instead of an I/O TLB emulation and I'm saying that this doesn't
  >> work because pci_dac_*() is a non-solution.
  >> 
  >> The suggestion is to always use the normal pci_*() mapping
  >> routines, independent of whether the platform is 32 or 64 bit.

  Chris> Yes and no.  Drivers that can and want to use DAC can do that
  Chris> on 32bit plattforms now, using the pci_dac_* stuff without
  Chris> _any_ IOMMU.  This should work on ia64 aswell, even if it's
  Chris> native dma_addr_t already is a 64 bit type.

The reason I don't like this very much is that you're assuming that
all DAC-capable devices will be able to address the full 64-bit
address space.  That just doesn't seem to be the case.  And as soon as
we have machines with larger memories than some of the DAC-capable
devices can address, we're back to pci_dac_*() having to have some
smarts as to whether a direct mapping is possible.

The only extra overhead of going through normal pci mapping routines
is a function call.  If that's noticable, you have a very fast device
indeed.

	--david

