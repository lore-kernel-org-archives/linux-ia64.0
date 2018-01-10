From: Vladimir Murzin <vladimir.murzin@arm.com>
Date: Wed, 10 Jan 2018 09:31:45 +0000
Subject: Re: [PATCH 11/33] dma-mapping: move swiotlb arch helpers to a new header
Message-Id: <b2bd6f4b-a932-5251-517b-83bbccfe7c53@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180110080027.13879-1-hch@lst.de>
 <20180110080027.13879-12-hch@lst.de>
In-Reply-To: <20180110080027.13879-12-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>, iommu@lists.linux-foundation.org
Cc: linux-mips@linux-mips.org, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, linux-c6x-dev@linux-c6x.org, linux-hexagon@vger.kernel.org, x86@kernel.org, Konrad Rzeszutek Wilk <konrad@darnok.org>, linux-snps-arc@lists.infradead.org, linux-m68k@lists.linux-m68k.org, patches@groups.riscv.org, linux-metag@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Michal Simek <monstr@monstr.eu>, linux-parisc@vger.kernel.org, linux-cris-kernel@axis.com, linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

On 10/01/18 08:00, Christoph Hellwig wrote:
> index 9110988b92a1..f00833acb626 100644
> --- a/arch/mips/include/asm/mach-cavium-octeon/dma-coherence.h
> +++ b/arch/mips/include/asm/mach-cavium-octeon/dma-coherence.h
> @@ -61,6 +61,14 @@ static inline void plat_post_dma_flush(struct device *dev)
>  {
>  }
>  
> +static inline bool dma_capable(struct device *dev, dma_addr_t addr, size_t size)
> +{
> +	if (!dev->dma_mask)
> +		return false;
> +
> +	return addr + size <= *dev->dma_mask;
> +}
> +

I know it is copy&paste, but it seems it has off by one error and it should be

return addr + size - 1 <= *dev->dma_mask;


>  dma_addr_t phys_to_dma(struct device *dev, phys_addr_t paddr);
>  phys_addr_t dma_to_phys(struct device *dev, dma_addr_t daddr);
>  

snip...

> diff --git a/arch/mips/include/asm/mach-loongson64/dma-coherence.h b/arch/mips/include/asm/mach-loongson64/dma-coherence.h
> index 1602a9e9e8c2..5cfda8f893e9 100644
> --- a/arch/mips/include/asm/mach-loongson64/dma-coherence.h
> +++ b/arch/mips/include/asm/mach-loongson64/dma-coherence.h
> @@ -17,6 +17,14 @@
>  
>  struct device;
>  
> +static inline bool dma_capable(struct device *dev, dma_addr_t addr, size_t size)
> +{
> +	if (!dev->dma_mask)
> +		return false;
> +
> +	return addr + size <= *dev->dma_mask;


ditto

Cheers
Vladimir
