From: Robin Murphy <robin.murphy@arm.com>
Date: Wed, 10 Jan 2018 11:49:34 +0000
Subject: Re: [PATCH 31/33] dma-direct: reject too small dma masks
Message-Id: <0bcca030-a8da-c34a-a905-707986689f33@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180110080027.13879-1-hch@lst.de>
 <20180110080027.13879-32-hch@lst.de>
In-Reply-To: <20180110080027.13879-32-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>, iommu@lists.linux-foundation.org
Cc: linux-mips@linux-mips.org, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, linux-c6x-dev@linux-c6x.org, linux-hexagon@vger.kernel.org, x86@kernel.org, Konrad Rzeszutek Wilk <konrad@darnok.org>, linux-snps-arc@lists.infradead.org, linux-m68k@lists.linux-m68k.org, patches@groups.riscv.org, linux-metag@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Michal Simek <monstr@monstr.eu>, linux-parisc@vger.kernel.org, linux-cris-kernel@axis.com, linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

On 10/01/18 08:00, Christoph Hellwig wrote:
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>   include/linux/dma-direct.h |  1 +
>   lib/dma-direct.c           | 19 +++++++++++++++++++
>   2 files changed, 20 insertions(+)
> 
> diff --git a/include/linux/dma-direct.h b/include/linux/dma-direct.h
> index 4788bf0bf683..bcdb1a3e4b1f 100644
> --- a/include/linux/dma-direct.h
> +++ b/include/linux/dma-direct.h
> @@ -42,5 +42,6 @@ void *dma_direct_alloc(struct device *dev, size_t size, dma_addr_t *dma_handle,
>   		gfp_t gfp, unsigned long attrs);
>   void dma_direct_free(struct device *dev, size_t size, void *cpu_addr,
>   		dma_addr_t dma_addr, unsigned long attrs);
> +int dma_direct_supported(struct device *dev, u64 mask);
>   
>   #endif /* _LINUX_DMA_DIRECT_H */
> diff --git a/lib/dma-direct.c b/lib/dma-direct.c
> index 784a68dfdbe3..40b1f92f2214 100644
> --- a/lib/dma-direct.c
> +++ b/lib/dma-direct.c
> @@ -122,6 +122,24 @@ static int dma_direct_map_sg(struct device *dev, struct scatterlist *sgl,
>   	return nents;
>   }
>   
> +int dma_direct_supported(struct device *dev, u64 mask)
> +{
> +#ifdef CONFIG_ZONE_DMA
> +	if (mask < DMA_BIT_MASK(ARCH_ZONE_DMA_BITS))
> +		return 0;
> +#else
> +	/*
> +	 * Because 32-bit DMA masks are so common we expect every architecture
> +	 * to be able to satisfy them - either by not supporting more physical
> +	 * memory, or by providing a ZONE_DMA32.  If neither is the case, the
> +	 * architecture needs to use an IOMMU instead of the direct mapping.
> +	 */
> +	if (mask < DMA_BIT_MASK(32))
> +		return 0;

Do you think it's worth the effort to be a little more accommodating 
here? i.e.:

		return dma_max_pfn(dev) >= max_pfn;

We seem to have a fair few 28-31 bit masks for older hardware which 
probably associates with host systems packing equivalently small amounts 
of RAM.

Otherwise though,

Reviewed-by: Robin Murphy <robin.murphy@arm.com>

Robin.

> +#endif
> +	return 1;
> +}
> +
>   static int dma_direct_mapping_error(struct device *dev, dma_addr_t dma_addr)
>   {
>   	return dma_addr = DIRECT_MAPPING_ERROR;
> @@ -132,6 +150,7 @@ const struct dma_map_ops dma_direct_ops = {
>   	.free			= dma_direct_free,
>   	.map_page		= dma_direct_map_page,
>   	.map_sg			= dma_direct_map_sg,
> +	.dma_supported		= dma_direct_supported,
>   	.mapping_error		= dma_direct_mapping_error,
>   };
>   EXPORT_SYMBOL(dma_direct_ops);
> 
