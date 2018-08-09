From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Thu, 09 Aug 2018 00:43:15 +0000
Subject: Re: [PATCH 12/20] powerpc/dma: use phys_to_dma instead of get_dma_offset
Message-Id: <a28a4e70e829f25ccd1286f8fba657f670f2a685.camel@kernel.crashing.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180730163824.10064-1-hch@lst.de>
 <20180730163824.10064-13-hch@lst.de>
In-Reply-To: <20180730163824.10064-13-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Robin Murphy <robin.murphy@arm.com>, linuxppc-dev@lists.ozlabs.org, iommu@lists.linux-foundation.org, linux-ia64@vger.kernel.org

On Mon, 2018-07-30 at 18:38 +0200, Christoph Hellwig wrote:
> Use the standard portable helper instead of the powerpc specific one,
> which is about to go away.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Acked-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>

> ---
>  arch/powerpc/kernel/dma-swiotlb.c |  5 ++---
>  arch/powerpc/kernel/dma.c         | 12 ++++++------
>  2 files changed, 8 insertions(+), 9 deletions(-)
> 
> diff --git a/arch/powerpc/kernel/dma-swiotlb.c b/arch/powerpc/kernel/dma-swiotlb.c
> index 88f3963ca30f..f6e0701c5303 100644
> --- a/arch/powerpc/kernel/dma-swiotlb.c
> +++ b/arch/powerpc/kernel/dma-swiotlb.c
> @@ -11,7 +11,7 @@
>   *
>   */
>  
> -#include <linux/dma-mapping.h>
> +#include <linux/dma-direct.h>
>  #include <linux/memblock.h>
>  #include <linux/pfn.h>
>  #include <linux/of_platform.h>
> @@ -31,9 +31,8 @@ static u64 swiotlb_powerpc_get_required(struct device *dev)
>         end = memblock_end_of_DRAM();
>         if (max_direct_dma_addr && end > max_direct_dma_addr)
>                 end = max_direct_dma_addr;
> -       end += get_dma_offset(dev);
>  
> -       mask = 1ULL << (fls64(end) - 1);
> +       mask = 1ULL << (fls64(phys_to_dma(dev, end)) - 1);
>         mask += mask - 1;
>  
>         return mask;
> diff --git a/arch/powerpc/kernel/dma.c b/arch/powerpc/kernel/dma.c
> index eceaa92e6986..3487de83bb37 100644
> --- a/arch/powerpc/kernel/dma.c
> +++ b/arch/powerpc/kernel/dma.c
> @@ -6,7 +6,7 @@
>   */
>  
>  #include <linux/device.h>
> -#include <linux/dma-mapping.h>
> +#include <linux/dma-direct.h>
>  #include <linux/dma-debug.h>
>  #include <linux/gfp.h>
>  #include <linux/memblock.h>
> @@ -43,7 +43,7 @@ static u64 __maybe_unused get_pfn_limit(struct device *dev)
>  static int dma_nommu_dma_supported(struct device *dev, u64 mask)
>  {
>  #ifdef CONFIG_PPC64
> -       u64 limit = get_dma_offset(dev) + (memblock_end_of_DRAM() - 1);
> +       u64 limit = phys_to_dma(dev, (memblock_end_of_DRAM() - 1));
>  
>         /* Limit fits in the mask, we are good */
>         if (mask >= limit)
> @@ -104,7 +104,7 @@ void *__dma_nommu_alloc_coherent(struct device *dev, size_t size,
>                 return NULL;
>         ret = page_address(page);
>         memset(ret, 0, size);
> -       *dma_handle = __pa(ret) + get_dma_offset(dev);
> +       *dma_handle = phys_to_dma(dev,__pa(ret));
>  
>         return ret;
>  }
> @@ -188,7 +188,7 @@ static int dma_nommu_map_sg(struct device *dev, struct scatterlist *sgl,
>         int i;
>  
>         for_each_sg(sgl, sg, nents, i) {
> -               sg->dma_address = sg_phys(sg) + get_dma_offset(dev);
> +               sg->dma_address = phys_to_dma(dev, sg_phys(sg));
>                 sg->dma_length = sg->length;
>  
>                 if (attrs & DMA_ATTR_SKIP_CPU_SYNC)
> @@ -210,7 +210,7 @@ static u64 dma_nommu_get_required_mask(struct device *dev)
>  {
>         u64 end, mask;
>  
> -       end = memblock_end_of_DRAM() + get_dma_offset(dev);
> +       end = phys_to_dma(dev, memblock_end_of_DRAM());
>  
>         mask = 1ULL << (fls64(end) - 1);
>         mask += mask - 1;
> @@ -228,7 +228,7 @@ static inline dma_addr_t dma_nommu_map_page(struct device *dev,
>         if (!(attrs & DMA_ATTR_SKIP_CPU_SYNC))
>                 __dma_sync_page(page, offset, size, dir);
>  
> -       return page_to_phys(page) + offset + get_dma_offset(dev);
> +       return phys_to_dma(dev, page_to_phys(page)) + offset;
>  }
>  
>  static inline void dma_nommu_unmap_page(struct device *dev,

