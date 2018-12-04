From: Robin Murphy <robin.murphy@arm.com>
Date: Tue, 04 Dec 2018 16:41:34 +0000
Subject: Re: [PATCH 01/23] dma-mapping: provide a generic DMA_MAPPING_ERROR
Message-Id: <653ca801-63a1-3c19-ee09-ade19fa2bbb8@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20181130132231.16512-1-hch@lst.de>
 <20181130132231.16512-2-hch@lst.de>
In-Reply-To: <20181130132231.16512-2-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>, iommu@lists.linux-foundation.org
Cc: linux-arch@vger.kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, x86@kernel.org, linux-kernel@vger.kernel.org, xen-devel@lists.xenproject.org, David Woodhouse <dwmw2@infradead.org>, linux-arm-kernel@lists.infradead.org

On 30/11/2018 13:22, Christoph Hellwig wrote:
> Error handling of the dma_map_single and dma_map_page APIs is a little
> problematic at the moment, in that we use different encodings in the
> returned dma_addr_t to indicate an error.  That means we require an
> additional indirect call to figure out if a dma mapping call returned
> an error, and a lot of boilerplate code to implement these semantics.
> 
> Instead return the maximum addressable value as the error.  As long
> as we don't allow mapping single-byte ranges with single-byte alignment
> this value can never be a valid return.  Additionaly if drivers do
> not check the return value from the dma_map* routines this values means
> they will generally not be pointed to actual memory.
> 
> Once the default value is added here we can start removing the
> various mapping_error methods and just rely on this generic check.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>   include/linux/dma-mapping.h | 6 ++++++
>   1 file changed, 6 insertions(+)
> 
> diff --git a/include/linux/dma-mapping.h b/include/linux/dma-mapping.h
> index 0f81c713f6e9..46bd612d929e 100644
> --- a/include/linux/dma-mapping.h
> +++ b/include/linux/dma-mapping.h
> @@ -133,6 +133,8 @@ struct dma_map_ops {
>   	u64 (*get_required_mask)(struct device *dev);
>   };
>   
> +#define DMA_MAPPING_ERROR		(~(dma_addr_t)0)
> +
>   extern const struct dma_map_ops dma_direct_ops;
>   extern const struct dma_map_ops dma_virt_ops;
>   
> @@ -576,6 +578,10 @@ static inline int dma_mapping_error(struct device *dev, dma_addr_t dma_addr)
>   	const struct dma_map_ops *ops = get_dma_ops(dev);
>   
>   	debug_dma_mapping_error(dev, dma_addr);
> +
> +	if (dma_addr = DMA_MAPPING_ERROR)
> +		return 1;
> +
>   	if (ops->mapping_error)
>   		return ops->mapping_error(dev, dma_addr);
>   	return 0;

I'd have been inclined to put the default check here, i.e.

-	return 0
+	return dma_addr = DMA_MAPPING_ERROR

such that the callback retains full precedence and we don't have to deal 
with the non-trivial removals immediately if it comes to it. Not that it 
makes a vast difference though, so either way,

Reviewed-by: Robin Murphy <robin.murphy@arm.com>
