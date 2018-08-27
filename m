From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Date: Mon, 27 Aug 2018 16:06:28 +0000
Subject: Re: [PATCH 05/20] swiotlb: allow the architecture to provide a get_required_mask hook
Message-Id: <20180827160628.GT10467@char.us.oracle.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180730163824.10064-1-hch@lst.de>
 <20180730163824.10064-6-hch@lst.de>
In-Reply-To: <20180730163824.10064-6-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Robin Murphy <robin.murphy@arm.com>, linuxppc-dev@lists.ozlabs.org, iommu@lists.linux-foundation.org, linux-ia64@vger.kernel.org

On Mon, Jul 30, 2018 at 06:38:09PM +0200, Christoph Hellwig wrote:
> For now this allows consolidating the powerpc code.  In the long run
> we should grow a generic implementation of dma_get_required_mask that
> returns the dma mask required to avoid bounce buffering.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

Thank you!
> ---
>  kernel/dma/swiotlb.c | 4 ++++
>  1 file changed, 4 insertions(+)
> 
> diff --git a/kernel/dma/swiotlb.c b/kernel/dma/swiotlb.c
> index 904541055792..1bb420244753 100644
> --- a/kernel/dma/swiotlb.c
> +++ b/kernel/dma/swiotlb.c
> @@ -1084,5 +1084,9 @@ const struct dma_map_ops swiotlb_dma_ops = {
>  	.map_page		= swiotlb_map_page,
>  	.unmap_page		= swiotlb_unmap_page,
>  	.dma_supported		= dma_direct_supported,
> +#ifdef swiotlb_get_required_mask
> +	.get_required_mask	= swiotlb_get_required_mask,
> +#endif
> +
>  };
>  EXPORT_SYMBOL(swiotlb_dma_ops);
> -- 
> 2.18.0
> 
