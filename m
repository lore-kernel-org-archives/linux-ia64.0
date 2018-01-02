From: Vladimir Murzin <vladimir.murzin@arm.com>
Date: Tue, 02 Jan 2018 16:26:27 +0000
Subject: Re: [PATCH 26/67] dma-direct: use phys_to_dma
Message-Id: <76092d0d-3e74-9433-5fae-afc512e34b20@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20171229081911.2802-1-hch@lst.de>
 <20171229081911.2802-27-hch@lst.de>
In-Reply-To: <20171229081911.2802-27-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>, iommu@lists.linux-foundation.org
Cc: linux-mips@linux-mips.org, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, linux-c6x-dev@linux-c6x.org, linux-hexagon@vger.kernel.org, x86@kernel.org, linux-snps-arc@lists.infradead.org, adi-buildroot-devel@lists.sourceforge.net, linux-m68k@lists.linux-m68k.org, patches@groups.riscv.org, linux-metag@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Michal Simek <monstr@monstr.eu>, linux-parisc@vger.kernel.org, linux-cris-kernel@axis.com, linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

On 29/12/17 08:18, Christoph Hellwig wrote:
> This means it uses whatever linear remapping scheme that the architecture
> provides is used in the generic dma_direct ops.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  lib/dma-direct.c | 18 +++++++-----------
>  1 file changed, 7 insertions(+), 11 deletions(-)
> 
> diff --git a/lib/dma-direct.c b/lib/dma-direct.c
> index 439db40854b7..0e087650e86b 100644
> --- a/lib/dma-direct.c
> +++ b/lib/dma-direct.c
> @@ -1,12 +1,11 @@
>  // SPDX-License-Identifier: GPL-2.0
>  /*
> - *	lib/dma-noop.c
> - *
> - * DMA operations that map to physical addresses without flushing memory.
> + * DMA operations that map physical memory directly without using an IOMMU or
> + * flushing caches.
>   */
>  #include <linux/export.h>
>  #include <linux/mm.h>
> -#include <linux/dma-mapping.h>
> +#include <linux/dma-direct.h>
>  #include <linux/scatterlist.h>
>  #include <linux/pfn.h>
>  
> @@ -17,7 +16,7 @@ static void *dma_direct_alloc(struct device *dev, size_t size,
>  
>  	ret = (void *)__get_free_pages(gfp, get_order(size));
>  	if (ret)
> -		*dma_handle = virt_to_phys(ret) - PFN_PHYS(dev->dma_pfn_offset);
> +		*dma_handle = phys_to_dma(dev, virt_to_phys(ret));
>  
>  	return ret;
>  }
> @@ -32,7 +31,7 @@ static dma_addr_t dma_direct_map_page(struct device *dev, struct page *page,
>  		unsigned long offset, size_t size, enum dma_data_direction dir,
>  		unsigned long attrs)
>  {
> -	return page_to_phys(page) + offset - PFN_PHYS(dev->dma_pfn_offset);
> +	return phys_to_dma(dev, page_to_phys(page)) + offset;
>  }
>  
>  static int dma_direct_map_sg(struct device *dev, struct scatterlist *sgl,
> @@ -42,12 +41,9 @@ static int dma_direct_map_sg(struct device *dev, struct scatterlist *sgl,
>  	struct scatterlist *sg;
>  
>  	for_each_sg(sgl, sg, nents, i) {
> -		dma_addr_t offset = PFN_PHYS(dev->dma_pfn_offset);
> -		void *va;
> -
>  		BUG_ON(!sg_page(sg));
> -		va = sg_virt(sg);
> -		sg_dma_address(sg) = (dma_addr_t)virt_to_phys(va) - offset;
> +
> +		sg_dma_address(sg) = phys_to_dma(dev, sg_phys(sg));
>  		sg_dma_len(sg) = sg->length;
>  	}
>  
> 

From ARM NOMMU perspective

Reviewed-by: Vladimir Murzin <vladimir.murzin@arm.com>

Thanks
Vladimir
