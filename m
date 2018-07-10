From: Robin Murphy <robin.murphy@arm.com>
Date: Tue, 10 Jul 2018 12:29:20 +0000
Subject: Re: [RFC PATCH 2/2] dma-mapping: Clean up dma_get_required_mask() hooks
Message-Id: <3b8a23b6-6015-3e8e-07f0-b75920a1e264@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <55ac9550c311f056dcfeed9b2c8265375f17b155.1530726467.git.robin.murphy@arm.com>
 <08256121f325ceed7f6b88c1a5d3cf949698787d.1530726467.git.robin.murphy@arm.com>
 <20180710113908.GB32688@lst.de>
In-Reply-To: <20180710113908.GB32688@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>
Cc: m.szyprowski@samsung.com, iommu@lists.linux-foundation.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

On 10/07/18 12:39, Christoph Hellwig wrote:
> On Wed, Jul 04, 2018 at 06:50:12PM +0100, Robin Murphy wrote:
>> As for the other mask-related hooks, standardise the arch override into
>> a Kconfig option, and also pull the generic implementation into the DMA
>> mapping code rather than having it hide away in the platform bus code.
> 
> I compared this a bit to what I had around against an older kernel,
> and I think we should probably go with something more like the
> version I had, which I can dust off again.
> 
> What I've done is to:
> 
>   1) provide the get_required_mask unconditionally in struct dma_map_ops
>   2) default to what is the current dma_get_required_mask implementation
>      if nothing else is specified.

Yeah, there's already 17 pointers in dma_map_ops of which about half are 
optional, so these awkward #ifdefs to save one more probably aren't 
worth the inconsistency they bring. It feels like this guy mostly goes 
hand-in-hand with dma_supported, so ack to giving it the same look and feel.

> What I still had on my todo list but not done yet:
> 
>   3) go through all instances and check if the current default
>      makes sense, at it based on direct addressability.  For most
>      iommu instances it seems like we should just return a 64-bit mask.

That's reasonable, although in many cases we should know the effective 
IOMMU input address size which would be even neater.

>   4) figure out how to take the dma offsets into account for it

AFAICS it might boil down to simply:

	mask = roundup_pow_of_two(phys_to_dma(dev, PFN_PHYS(max_pfn))) - 1;

>   5) move the function to the dma-direct code, as that is where it
>      belongs
>   5) figure out if there is a better name for the method, as with
>      swiotlb & co it isn't really the required mask, but more something
>      like the optimal mask
>   6) document the whole thing..
>   7) sort out the powerpc indirection mess.
> 
> Do you agree with that general plan?  If so I can dust off my old
> patch.

Sounds good; in the meantime I'll happily drop these two.

Robin.
