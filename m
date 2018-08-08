From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Wed, 08 Aug 2018 23:44:18 +0000
Subject: Re: [PATCH 01/20] kernel/dma/direct: take DMA offset into account in dma_direct_supported
Message-Id: <74068e4d2135ecad8645048ed97b1114891ccace.camel@kernel.crashing.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180730163824.10064-1-hch@lst.de>
 <20180730163824.10064-2-hch@lst.de>
In-Reply-To: <20180730163824.10064-2-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Robin Murphy <robin.murphy@arm.com>, linuxppc-dev@lists.ozlabs.org, iommu@lists.linux-foundation.org, linux-ia64@vger.kernel.org

On Mon, 2018-07-30 at 18:38 +0200, Christoph Hellwig wrote:
> When a device has a DMA offset the dma capable result will change due
> to the difference between the physical and DMA address.  Take that into
> account.

The patch in itself makes sense.

However, there are a number of things in that dma_direct.c file that I
don't quite get:

 - looking more generally at what that function does, I worry about the
switch of ppc32 to this later on:

We do have the occasional device with things like 31-bit DMA
limitation. We know they happens to work because those systems
can't have enough memory to be a problem. This is why our current
DMA direct ops in powerpc just unconditionally return true on ppc32.

The test against a full 32-bit mask here will break them I think.

Thing is, I'm not sure I still have access to one of these things
to test, I'll have to dig (from memory things like b43 wifi).

Also those platforms don't have an iommu.

 - What is this trying to achieve ?

	/*
	 * Various PCI/PCIe bridges have broken support for > 32bit DMA even
	 * if the device itself might support it.
	 */
	if (dev->dma_32bit_limit && mask > phys_to_dma(dev, DMA_BIT_MASK(32)))
		return 0;

IE, if the device has a 32-bit limit, we fail an attempt at checking
if a >32-bit mask works ? That doesn't quite seem to be the right thing
to do... Shouldn't this be in dma_set_mask() and just clamp the mask down ?

IE, dma_set_mask() is what a driver uses to establish the device capability,
so it makes sense tot have dma_32bit_limit just reduce that capability, not
fail because the device can do more than what the bridge can.... 

Sorry if I'm a bit confused here.

 - How is that file supposed to work on 64-bit platforms ? From what I can
tell, dma_supported() will unconditionally return true if the mask is
32-bit or larger (appart from the above issue). This doesn't look right,
the mask needs to be compared to the max memory address. There are a bunch
of devices out there with masks anywhere bettween 40 and 64 bits, and
some of these will not work "out of the box" if the offseted top
of memory is beyond the mask limit. Or am I missing something ?

Cheers,
Ben.

> Signed-off-by: Christoph Hellwig <hch@lst.de>

Reviewed-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>

> ---
>  kernel/dma/direct.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/kernel/dma/direct.c b/kernel/dma/direct.c
> index 8be8106270c2..d32d4f0d2c0c 100644
> --- a/kernel/dma/direct.c
> +++ b/kernel/dma/direct.c
> @@ -167,7 +167,7 @@ int dma_direct_map_sg(struct device *dev, struct scatterlist *sgl, int nents,
>  int dma_direct_supported(struct device *dev, u64 mask)
>  {
>  #ifdef CONFIG_ZONE_DMA
> -	if (mask < DMA_BIT_MASK(ARCH_ZONE_DMA_BITS))
> +	if (mask < phys_to_dma(dev, DMA_BIT_MASK(ARCH_ZONE_DMA_BITS)))
>  		return 0;
>  #else
>  	/*
> @@ -176,14 +176,14 @@ int dma_direct_supported(struct device *dev, u64 mask)
>  	 * memory, or by providing a ZONE_DMA32.  If neither is the case, the
>  	 * architecture needs to use an IOMMU instead of the direct mapping.
>  	 */
> -	if (mask < DMA_BIT_MASK(32))
> +	if (mask < phys_to_dma(dev, DMA_BIT_MASK(32)))
>  		return 0;
>  #endif
>  	/*
>  	 * Various PCI/PCIe bridges have broken support for > 32bit DMA even
>  	 * if the device itself might support it.
>  	 */
> -	if (dev->dma_32bit_limit && mask > DMA_BIT_MASK(32))
> +	if (dev->dma_32bit_limit && mask > phys_to_dma(dev, DMA_BIT_MASK(32)))
>  		return 0;
>  	return 1;
>  }

