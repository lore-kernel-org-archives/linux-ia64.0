From: Jesse Barnes <jbarnes@sgi.com>
Date: Fri, 16 May 2003 00:37:56 +0000
Subject: [Linux-ia64] Re: 64 Bits DMA Addresses for Alloc Consistent Interfaces.
Message-Id: <marc-linux-ia64-105590723705876@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705823@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705823@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, May 15, 2003 at 07:31:20PM -0500, James Bottomley wrote:
> > A cost sensitive PCI-X device may wish to use 32-bit addressing in
> > it's descriptors in order to keep pin counts down etc.
> 
> This is certainly a property of the aic79xx driver (only using 32 bit
> descriptor tables).  It has this nice code in the driver for doing it:
> 
> aic79xx.c:
> 
> 	/*
> 	 * Although we can dma data above 4GB, our
> 	 * "consistent" memory is below 4GB for
> 	 * space efficiency reasons (only need a 4byte
> 	 * address).  For this reason, we have to reset
> 	 * our dma mask when doing allocations.
> 	 */
> 	if (ahd->dev_softc != NULL)
> 		ahd_pci_set_dma_mask(ahd->dev_softc, 0xFFFFFFFF);
> 	*vaddr = pci_alloc_consistent(ahd->dev_softc,
> 				      dmat->maxsize, &map->bus_addr);
> 	if (ahd->dev_softc != NULL)
> 		ahd_pci_set_dma_mask(ahd->dev_softc,
> 				     ahd->platform_data->hw_dma_mask);
> 
> And it comes in PCI-X flavours.

Ah, ok (set_dma_mask vs. alloc_consistent bugs aside).  I think there
was some confusion about the fact that the PCI-X spec. says that cards
must support DAC vs. them actually supporting 64 bit DMA addresses.
They all have to do the former, but not the latter.  Also, using an
IOMMU is different than using direct mapping.  Our hw can do both for
PCI cards that only handle 32 bit DMA addresses.  IOMMU mapping allows
you to map pages anywhere in memory, while direct mapping gives you a
static 2GB window into system memory.

Hope this clears things up a little.

Thanks,
Jesse

