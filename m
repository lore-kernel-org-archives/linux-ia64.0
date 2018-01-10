From: Robin Murphy <robin.murphy@arm.com>
Date: Wed, 10 Jan 2018 12:13:39 +0000
Subject: Re: [PATCH 02/22] arm64: rename swiotlb_dma_ops
Message-Id: <4564e50d-7e52-7b72-7c95-d4acda92da0c@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180110080932.14157-1-hch@lst.de>
 <20180110080932.14157-3-hch@lst.de>
In-Reply-To: <20180110080932.14157-3-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>, iommu@lists.linux-foundation.org
Cc: linux-arch@vger.kernel.org, linux-mips@linux-mips.org, Michal Simek <monstr@monstr.eu>, linux-ia64@vger.kernel.org, =?UTF-8?Q?Christian_K=c3=b6nig?= <ckoenig.leichtzumerken@gmail.com>, x86@kernel.org, linux-kernel@vger.kernel.org, Konrad Rzeszutek Wilk <konrad@darnok.org>, Guan Xuetao <gxt@mprc.pku.edu.cn>, linuxppc-dev@lists.ozlabs.org, linux-arm-kernel@lists.infradead.org

On 10/01/18 08:09, Christoph Hellwig wrote:
> We'll need that name for a generic implementation soon.

Reviewed-by: Robin Murphy <robin.murphy@arm.com>

> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>   arch/arm64/mm/dma-mapping.c | 4 ++--
>   1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/arch/arm64/mm/dma-mapping.c b/arch/arm64/mm/dma-mapping.c
> index f3a637b98487..6840426bbe77 100644
> --- a/arch/arm64/mm/dma-mapping.c
> +++ b/arch/arm64/mm/dma-mapping.c
> @@ -368,7 +368,7 @@ static int __swiotlb_dma_mapping_error(struct device *hwdev, dma_addr_t addr)
>   	return 0;
>   }
>   
> -static const struct dma_map_ops swiotlb_dma_ops = {
> +static const struct dma_map_ops arm64_swiotlb_dma_ops = {
>   	.alloc = __dma_alloc,
>   	.free = __dma_free,
>   	.mmap = __swiotlb_mmap,
> @@ -923,7 +923,7 @@ void arch_setup_dma_ops(struct device *dev, u64 dma_base, u64 size,
>   			const struct iommu_ops *iommu, bool coherent)
>   {
>   	if (!dev->dma_ops)
> -		dev->dma_ops = &swiotlb_dma_ops;
> +		dev->dma_ops = &arm64_swiotlb_dma_ops;
>   
>   	dev->archdata.dma_coherent = coherent;
>   	__iommu_setup_dma_ops(dev, dma_base, size, iommu);
> 
