From: Jeremy Higdon <jeremy@sgi.com>
Date: Fri, 16 May 2003 08:00:45 +0000
Subject: [Linux-ia64] Re: 64 Bits DMA Addresses for Alloc Consistent Interfaces.
Message-Id: <marc-linux-ia64-105590723705897@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705823@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705823@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, May 15, 2003 at 07:31:20PM -0500, James Bottomley wrote:
> On Thu, 2003-05-15 at 19:17, David S. Miller wrote:
> > Having to support DAC cycles does not mean that it must support full
> > 64-bit DMA addresses in it's descriptors.
> > 
> > A cost sensitive PCI-X device may wish to use 32-bit addressing in
> > it's descriptors in order to keep pin counts down etc.
> 
> This is certainly a property of the aic79xx driver (only using 32 bit
> descriptor tables).  It has this nice code in the driver for doing it:

This is a driver choice, rather than an adapter limitation, right?
Or is the adapter limited to 32 bit addresses for map->bus_addr (the
PCI-X flavor)?

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
> 
> James
> 

