From: Christoph Hellwig <hch@lst.de>
Date: Tue, 10 Jul 2018 15:08:24 +0000
Subject: Re: [RFC PATCH 2/2] dma-mapping: Clean up dma_get_required_mask() hooks
Message-Id: <20180710150824.GA12274@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <55ac9550c311f056dcfeed9b2c8265375f17b155.1530726467.git.robin.murphy@arm.com>
 <08256121f325ceed7f6b88c1a5d3cf949698787d.1530726467.git.robin.murphy@arm.com>
 <20180710113908.GB32688@lst.de>
 <3b8a23b6-6015-3e8e-07f0-b75920a1e264@arm.com>
In-Reply-To: <3b8a23b6-6015-3e8e-07f0-b75920a1e264@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Robin Murphy <robin.murphy@arm.com>
Cc: Christoph Hellwig <hch@lst.de>, m.szyprowski@samsung.com, iommu@lists.linux-foundation.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

On Tue, Jul 10, 2018 at 01:29:20PM +0100, Robin Murphy wrote:
>> What I've done is to:
>>
>>   1) provide the get_required_mask unconditionally in struct dma_map_ops
>>   2) default to what is the current dma_get_required_mask implementation
>>      if nothing else is specified.
>
> Yeah, there's already 17 pointers in dma_map_ops of which about half are 
> optional, so these awkward #ifdefs to save one more probably aren't worth 
> the inconsistency they bring. It feels like this guy mostly goes 
> hand-in-hand with dma_supported, so ack to giving it the same look and 
> feel.

This whole area needs a major refactoring - we currentl have three
different APIs to deal with addressability: dma_get_required_mask,
dma_capable/dma_set_mask and dma_capable from dma-direct.h, and there
is plenty of unexplainable mismatches between them.

Sorting this out has been on my TODO list, but I think it can only
effectively be done once the direct mapping implementations are
reasonably consolidated.

>> What I still had on my todo list but not done yet:
>>
>>   3) go through all instances and check if the current default
>>      makes sense, at it based on direct addressability.  For most
>>      iommu instances it seems like we should just return a 64-bit mask.
>
> That's reasonable, although in many cases we should know the effective 
> IOMMU input address size which would be even neater.

Sure.  Maybe I just need to steps 1 and 2 and let maintainers fill
in.

>>   4) figure out how to take the dma offsets into account for it
>
> AFAICS it might boil down to simply:
>
> 	mask = roundup_pow_of_two(phys_to_dma(dev, PFN_PHYS(max_pfn))) - 1;

That looks way to sensible.  Which reminds me that I need to research
the history behind the low_totalram/high_totalram magic in
dma_get_required_mask.
