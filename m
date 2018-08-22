From: Christoph Hellwig <hch@lst.de>
Date: Wed, 22 Aug 2018 06:53:59 +0000
Subject: Re: [PATCH 01/20] kernel/dma/direct: take DMA offset into account in dma_direct_supported
Message-Id: <20180822065359.GB19284@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180730163824.10064-1-hch@lst.de>
 <20180730163824.10064-2-hch@lst.de>
 <74068e4d2135ecad8645048ed97b1114891ccace.camel@kernel.crashing.org>
In-Reply-To: <74068e4d2135ecad8645048ed97b1114891ccace.camel@kernel.crashing.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Christoph Hellwig <hch@lst.de>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Robin Murphy <robin.murphy@arm.com>, linuxppc-dev@lists.ozlabs.org, iommu@lists.linux-foundation.org, linux-ia64@vger.kernel.org

On Thu, Aug 09, 2018 at 09:44:18AM +1000, Benjamin Herrenschmidt wrote:
> We do have the occasional device with things like 31-bit DMA
> limitation. We know they happens to work because those systems
> can't have enough memory to be a problem. This is why our current
> DMA direct ops in powerpc just unconditionally return true on ppc32.
> 
> The test against a full 32-bit mask here will break them I think.
> 
> Thing is, I'm not sure I still have access to one of these things
> to test, I'll have to dig (from memory things like b43 wifi).

Yeah, the other platforms that support these devices support ZONE_DMA
to reliably handle these devices. But there is two other ways the
current code would actually handle these fine despite the dma_direct
checks:

 1) if the device only has physical addresses up to 31-bit anyway
 2) by trying again to find a lower address.  But this only works
    for coherent allocations and not streaming maps (unless we have
    swiotlb with a buffer below 31-bits).

It seems powerpc can have ZONE_DMA, though and we will cover these
devices just fine.  If it didn't have that the current powerpc
code would not work either.

>  - What is this trying to achieve ?
> 
> 	/*
> 	 * Various PCI/PCIe bridges have broken support for > 32bit DMA even
> 	 * if the device itself might support it.
> 	 */
> 	if (dev->dma_32bit_limit && mask > phys_to_dma(dev, DMA_BIT_MASK(32)))
> 		return 0;
> 
> IE, if the device has a 32-bit limit, we fail an attempt at checking
> if a >32-bit mask works ? That doesn't quite seem to be the right thing
> to do... Shouldn't this be in dma_set_mask() and just clamp the mask down ?
> 
> IE, dma_set_mask() is what a driver uses to establish the device capability,
> so it makes sense tot have dma_32bit_limit just reduce that capability, not
> fail because the device can do more than what the bridge can.... 

If your PCI bridge / PCIe root port doesn't support dma to addresses
larger than 32-bit the device capabilities above that don't matter, it
just won't work.  We have this case at least for some old VIA x86 chipsets
and some relatively modern Xilinx FPGAs with PCIe.

>  - How is that file supposed to work on 64-bit platforms ? From what I can
> tell, dma_supported() will unconditionally return true if the mask is
> 32-bit or larger (appart from the above issue). This doesn't look right,
> the mask needs to be compared to the max memory address. There are a bunch
> of devices out there with masks anywhere bettween 40 and 64 bits, and
> some of these will not work "out of the box" if the offseted top
> of memory is beyond the mask limit. Or am I missing something ?

Your are not missing anything except for the history of this code.

Your observation is right, but there always has been the implicit
assumption that architectures with more than 4GB of physical address
space must either support and iommu or swiotlb and use that.  It's
never been document anywhere, but I'm working on integrating all
this code to make more sense.
