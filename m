From: Robin Murphy <robin.murphy@arm.com>
Date: Thu, 08 Jun 2017 14:02:00 +0000
Subject: Re: [PATCH 16/44] arm64: remove DMA_ERROR_CODE
Message-Id: <dddc8995-8278-0604-07cd-ffe34526686e@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170608132609.32662-1-hch@lst.de>
 <20170608132609.32662-17-hch@lst.de>
In-Reply-To: <20170608132609.32662-17-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>, x86@kernel.org, linux-arm-kernel@lists.infradead.org, xen-devel@lists.xenproject.org, linux-c6x-dev@linux-c6x.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, openrisc@lists.librecores.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, dmaengine@vger.kernel.org, linux-tegra@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-samsung-soc@vger.kernel.org, iommu@lists.linux-foundation.org, netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org

On 08/06/17 14:25, Christoph Hellwig wrote:
> The dma alloc interface returns an error by return NULL, and the
> mapping interfaces rely on the mapping_error method, which the dummy
> ops already implement correctly.
> 
> Thus remove the DMA_ERROR_CODE define.

Reviewed-by: Robin Murphy <robin.murphy@arm.com>

> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  arch/arm64/include/asm/dma-mapping.h | 1 -
>  arch/arm64/mm/dma-mapping.c          | 3 +--
>  2 files changed, 1 insertion(+), 3 deletions(-)
> 
> diff --git a/arch/arm64/include/asm/dma-mapping.h b/arch/arm64/include/asm/dma-mapping.h
> index 5392dbeffa45..cf8fc8f05580 100644
> --- a/arch/arm64/include/asm/dma-mapping.h
> +++ b/arch/arm64/include/asm/dma-mapping.h
> @@ -24,7 +24,6 @@
>  #include <xen/xen.h>
>  #include <asm/xen/hypervisor.h>
>  
> -#define DMA_ERROR_CODE	(~(dma_addr_t)0)
>  extern const struct dma_map_ops dummy_dma_ops;
>  
>  static inline const struct dma_map_ops *get_arch_dma_ops(struct bus_type *bus)
> diff --git a/arch/arm64/mm/dma-mapping.c b/arch/arm64/mm/dma-mapping.c
> index 3216e098c058..147fbb907a2f 100644
> --- a/arch/arm64/mm/dma-mapping.c
> +++ b/arch/arm64/mm/dma-mapping.c
> @@ -184,7 +184,6 @@ static void *__dma_alloc(struct device *dev, size_t size,
>  no_map:
>  	__dma_free_coherent(dev, size, ptr, *dma_handle, attrs);
>  no_mem:
> -	*dma_handle = DMA_ERROR_CODE;
>  	return NULL;
>  }
>  
> @@ -487,7 +486,7 @@ static dma_addr_t __dummy_map_page(struct device *dev, struct page *page,
>  				   enum dma_data_direction dir,
>  				   unsigned long attrs)
>  {
> -	return DMA_ERROR_CODE;
> +	return 0;
>  }
>  
>  static void __dummy_unmap_page(struct device *dev, dma_addr_t dev_addr,
> 

