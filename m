From: Jesse Barnes <jbarnes@sgi.com>
Date: Wed, 24 Apr 2002 05:49:48 +0000
Subject: [Linux-ia64] Re: PCI DAC routines for SN
Message-Id: <marc-linux-ia64-105590701905506@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905493@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905493@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Apr 23, 2002 at 09:04:10PM -0700, David S. Miller wrote:
> %99 of PCI chips out there do not support DAC addressing for things
> like descriptor tables etc.  So it's not a matter of "well" it's
> a matter of "at all".

Right.  But some platforms _can_ do DAC addressing for regions that
need to be coherent.  Seems like we shouldn't penalize good hardware
just because there's a lot of bad hardware out there.

> Therefore pci_alloc_consistent MUST provide SAC only addressing.
> 
> I was seeing patches where people would set the DMA mask for the
> pci_dev around pci_alloc_consistent calls in order to accomplish
> getting SAC addresses.  That is exactly the kind of crap I was
> trying to avoid.

Why would they need to do that?  If the driver sets its dma_mask to 64
bits, why can't the platform choose to return a 64 bit DMA address?
Obviously, if their device only supports 32 bits, then they'd set
their dma_mask accordingly and only get SAC addresses back from
alloc_consistent.  I'm obviously not understaning something...

> Therefore, as per the API specification
> (Documentation/DMA-mapping.txt) and reality, it's unacceptable
> for pci_alloc_consistent() to return anything other than SAC
> addresses (or something more constrained, if the DMA mask indicates
> this, for example for devices with ISA addressing limitations).
> 
> I think it is unreasonable to add a special DAC alloc consistent
> call.

Why?  It seems like a simple addition, even if not all platforms can
handle it.  Our platform won't work optimally if we don't either
change pci_alloc_consistent, or provide some other call to get 64 bit
coherent regions.

> Is this needed because you bozos don't have any physical memory below
> 4GB on some weird ia64 system ___AND___ you lack a PCI IOMMU in the
> controllers again?  This is getting rediculious if so, and I really
> want to avoid crapping up the PCI DMA interfaces just because the ia64
> PCI hardware folks keep making stupid design decisions.

Not at all.  SGI Origin hardware has PCI bridges that can coherently
access 64 bit DMA regions.  It can also map a limited number of 32 bit
addresses into arbitrary 4 GB memory windows of system memory.  The
number of mappings is somewhat limited however, since most devices are
expected to use 64 bit addresses directly.

Thanks,
Jesse

