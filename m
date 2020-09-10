From: Robin Murphy <robin.murphy@arm.com>
Date: Thu, 10 Sep 2020 13:02:01 +0000
Subject: Re: [PATCH 07/12] dma-direct: lift gfp_t manipulation out of__dma_direct_alloc_pages
Message-Id: <3658a0b7-c2b7-8b03-86c6-219f77799999@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200908164758.3177341-1-hch@lst.de>
 <20200908164758.3177341-8-hch@lst.de>
In-Reply-To: <20200908164758.3177341-8-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, iommu@lists.linux-foundation.org
Cc: linux-ia64@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mips@vger.kernel.org

On 2020-09-08 17:47, Christoph Hellwig wrote:
> Move the detailed gfp_t setup from __dma_direct_alloc_pages into the
> caller to clean things up a little.

Other than a mild nitpick that it might be nicer to spend one extra line 
to keep both gfp adjustments next to each other,

Reviewed-by: Robin Murphy <robin.murphy@arm.com>

> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>   kernel/dma/direct.c | 12 +++++-------
>   1 file changed, 5 insertions(+), 7 deletions(-)
> 
> diff --git a/kernel/dma/direct.c b/kernel/dma/direct.c
> index 1d564bea58571b..12e9f5f75dfe4b 100644
> --- a/kernel/dma/direct.c
> +++ b/kernel/dma/direct.c
> @@ -108,7 +108,7 @@ static inline bool dma_should_free_from_pool(struct device *dev,
>   }
>   
>   static struct page *__dma_direct_alloc_pages(struct device *dev, size_t size,
> -		gfp_t gfp, unsigned long attrs)
> +		gfp_t gfp)
>   {
>   	int node = dev_to_node(dev);
>   	struct page *page = NULL;
> @@ -116,11 +116,6 @@ static struct page *__dma_direct_alloc_pages(struct device *dev, size_t size,
>   
>   	WARN_ON_ONCE(!PAGE_ALIGNED(size));
>   
> -	if (attrs & DMA_ATTR_NO_WARN)
> -		gfp |= __GFP_NOWARN;
> -
> -	/* we always manually zero the memory once we are done: */
> -	gfp &= ~__GFP_ZERO;
>   	gfp |= dma_direct_optimal_gfp_mask(dev, dev->coherent_dma_mask,
>   					   &phys_limit);
>   	page = dma_alloc_contiguous(dev, size, gfp);
> @@ -164,6 +159,8 @@ void *dma_direct_alloc(struct device *dev, size_t size,
>   		return arch_dma_alloc(dev, size, dma_handle, gfp, attrs);
>   
>   	size = PAGE_ALIGN(size);
> +	if (attrs & DMA_ATTR_NO_WARN)
> +		gfp |= __GFP_NOWARN;
>   
>   	if (dma_should_alloc_from_pool(dev, gfp, attrs)) {
>   		u64 phys_mask;
> @@ -177,7 +174,8 @@ void *dma_direct_alloc(struct device *dev, size_t size,
>   		goto done;
>   	}
>   
> -	page = __dma_direct_alloc_pages(dev, size, gfp, attrs);
> +	/* we always manually zero the memory once we are done */
> +	page = __dma_direct_alloc_pages(dev, size, gfp & ~__GFP_ZERO);
>   	if (!page)
>   		return NULL;
>   
> 
