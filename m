From: Robin Murphy <robin.murphy@arm.com>
Date: Wed, 10 Jan 2018 12:16:15 +0000
Subject: Re: [PATCH 08/22] swiotlb: wire up ->dma_supported in swiotlb_dma_ops
Message-Id: <7a058876-08fc-7323-7cb3-fe85116e2ea8@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180110080932.14157-1-hch@lst.de>
 <20180110080932.14157-9-hch@lst.de>
In-Reply-To: <20180110080932.14157-9-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>, iommu@lists.linux-foundation.org
Cc: linux-arch@vger.kernel.org, linux-mips@linux-mips.org, Michal Simek <monstr@monstr.eu>, linux-ia64@vger.kernel.org, =?UTF-8?Q?Christian_K=c3=b6nig?= <ckoenig.leichtzumerken@gmail.com>, x86@kernel.org, linux-kernel@vger.kernel.org, Konrad Rzeszutek Wilk <konrad@darnok.org>, Guan Xuetao <gxt@mprc.pku.edu.cn>, linuxppc-dev@lists.ozlabs.org, linux-arm-kernel@lists.infradead.org

On 10/01/18 08:09, Christoph Hellwig wrote:
> To properly reject too small DMA masks based on the addressability of the
> bounce buffer.

I reckon this is self-evident enough that it should simply be squashed 
into the previous patch.

Robin.

> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>   lib/swiotlb.c | 1 +
>   1 file changed, 1 insertion(+)
> 
> diff --git a/lib/swiotlb.c b/lib/swiotlb.c
> index 0fae2f45c3c0..539fd1099ba9 100644
> --- a/lib/swiotlb.c
> +++ b/lib/swiotlb.c
> @@ -1128,5 +1128,6 @@ const struct dma_map_ops swiotlb_dma_ops = {
>   	.unmap_sg		= swiotlb_unmap_sg_attrs,
>   	.map_page		= swiotlb_map_page,
>   	.unmap_page		= swiotlb_unmap_page,
> +	.dma_supported		= swiotlb_dma_supported,
>   };
>   #endif /* CONFIG_DMA_DIRECT_OPS */
> 
