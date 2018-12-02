From: Konrad Rzeszutek Wilk <konrad@darnok.org>
Date: Sun, 02 Dec 2018 12:42:42 +0000
Subject: Re: [PATCH 21/23] xen-swiotlb: remove the mapping_error dma_map_ops method
Message-Id: <20181202124241.GB3166@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20181130132231.16512-1-hch@lst.de>
 <20181130132231.16512-22-hch@lst.de>
In-Reply-To: <20181130132231.16512-22-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>
Cc: iommu@lists.linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>, Jon Mason <jdmason@kudzu.us>, Joerg Roedel <joro@8bytes.org>, David Woodhouse <dwmw2@infradead.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Robin Murphy <robin.murphy@arm.com>, x86@kernel.org, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, xen-devel@lists.xenproject.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, Nov 30, 2018 at 02:22:29PM +0100, Christoph Hellwig wrote:
> Return DMA_MAPPING_ERROR instead of 0 on a dma mapping failure and let
> the core dma-mapping code handle the rest.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Reviewed-by: Konrad Rzeszutek Wilk <konrad@darnok.org>
> ---
>  drivers/xen/swiotlb-xen.c | 12 ++----------
>  1 file changed, 2 insertions(+), 10 deletions(-)
> 
> diff --git a/drivers/xen/swiotlb-xen.c b/drivers/xen/swiotlb-xen.c
> index 2a7f545bd0b5..6dc969d5ea2f 100644
> --- a/drivers/xen/swiotlb-xen.c
> +++ b/drivers/xen/swiotlb-xen.c
> @@ -53,8 +53,6 @@
>   * API.
>   */
>  
> -#define XEN_SWIOTLB_ERROR_CODE	(~(dma_addr_t)0x0)
> -
>  static char *xen_io_tlb_start, *xen_io_tlb_end;
>  static unsigned long xen_io_tlb_nslabs;
>  /*
> @@ -406,7 +404,7 @@ static dma_addr_t xen_swiotlb_map_page(struct device *dev, struct page *page,
>  	map = swiotlb_tbl_map_single(dev, start_dma_addr, phys, size, dir,
>  				     attrs);
>  	if (map = SWIOTLB_MAP_ERROR)
> -		return XEN_SWIOTLB_ERROR_CODE;
> +		return DMA_MAPPING_ERROR;
>  
>  	dev_addr = xen_phys_to_bus(map);
>  	xen_dma_map_page(dev, pfn_to_page(map >> PAGE_SHIFT),
> @@ -421,7 +419,7 @@ static dma_addr_t xen_swiotlb_map_page(struct device *dev, struct page *page,
>  	attrs |= DMA_ATTR_SKIP_CPU_SYNC;
>  	swiotlb_tbl_unmap_single(dev, map, size, dir, attrs);
>  
> -	return XEN_SWIOTLB_ERROR_CODE;
> +	return DMA_MAPPING_ERROR;
>  }
>  
>  /*
> @@ -700,11 +698,6 @@ xen_swiotlb_get_sgtable(struct device *dev, struct sg_table *sgt,
>  	return dma_common_get_sgtable(dev, sgt, cpu_addr, handle, size, attrs);
>  }
>  
> -static int xen_swiotlb_mapping_error(struct device *dev, dma_addr_t dma_addr)
> -{
> -	return dma_addr = XEN_SWIOTLB_ERROR_CODE;
> -}
> -
>  const struct dma_map_ops xen_swiotlb_dma_ops = {
>  	.alloc = xen_swiotlb_alloc_coherent,
>  	.free = xen_swiotlb_free_coherent,
> @@ -719,5 +712,4 @@ const struct dma_map_ops xen_swiotlb_dma_ops = {
>  	.dma_supported = xen_swiotlb_dma_supported,
>  	.mmap = xen_swiotlb_dma_mmap,
>  	.get_sgtable = xen_swiotlb_get_sgtable,
> -	.mapping_error	= xen_swiotlb_mapping_error,
>  };
> -- 
> 2.19.1
> 
