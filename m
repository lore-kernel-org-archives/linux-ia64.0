From: Konrad Rzeszutek Wilk <konrad@darnok.org>
Date: Fri, 12 Jan 2018 13:17:28 +0000
Subject: Re: [PATCH 21/33] dma-mapping: add an arch_dma_supported hook
Message-Id: <20180112131727.GB26900@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180110080027.13879-1-hch@lst.de>
 <20180110080027.13879-22-hch@lst.de>
In-Reply-To: <20180110080027.13879-22-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>
Cc: iommu@lists.linux-foundation.org, linux-alpha@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-c6x-dev@linux-c6x.org, linux-cris-kernel@axis.com, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-metag@vger.kernel.org, Michal Simek <monstr@monstr.eu>, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, patches@groups.riscv.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, Guan Xuetao <gxt@mprc.pku.edu.cn>, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Jan 10, 2018 at 09:00:15AM +0100, Christoph Hellwig wrote:
> To implement the x86 forbid_dac and iommu_sac_force we want an arch hook
> so that it can apply the global options across all dma_map_ops
> implementations.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Reviewed-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
> ---
>  arch/x86/include/asm/dma-mapping.h |  3 +++
>  arch/x86/kernel/pci-dma.c          | 19 ++++++++++++-------
>  include/linux/dma-mapping.h        | 11 +++++++++++
>  3 files changed, 26 insertions(+), 7 deletions(-)
> 
> diff --git a/arch/x86/include/asm/dma-mapping.h b/arch/x86/include/asm/dma-mapping.h
> index dfdc9357a349..6277c83c0eb1 100644
> --- a/arch/x86/include/asm/dma-mapping.h
> +++ b/arch/x86/include/asm/dma-mapping.h
> @@ -30,6 +30,9 @@ static inline const struct dma_map_ops *get_arch_dma_ops(struct bus_type *bus)
>  	return dma_ops;
>  }
>  
> +int arch_dma_supported(struct device *dev, u64 mask);
> +#define arch_dma_supported arch_dma_supported
> +
>  bool arch_dma_alloc_attrs(struct device **dev, gfp_t *gfp);
>  #define arch_dma_alloc_attrs arch_dma_alloc_attrs
>  
> diff --git a/arch/x86/kernel/pci-dma.c b/arch/x86/kernel/pci-dma.c
> index 61a8f1cb3829..df7ab02f959f 100644
> --- a/arch/x86/kernel/pci-dma.c
> +++ b/arch/x86/kernel/pci-dma.c
> @@ -215,7 +215,7 @@ static __init int iommu_setup(char *p)
>  }
>  early_param("iommu", iommu_setup);
>  
> -int x86_dma_supported(struct device *dev, u64 mask)
> +int arch_dma_supported(struct device *dev, u64 mask)
>  {
>  #ifdef CONFIG_PCI
>  	if (mask > 0xffffffff && forbid_dac > 0) {
> @@ -224,12 +224,6 @@ int x86_dma_supported(struct device *dev, u64 mask)
>  	}
>  #endif
>  
> -	/* Copied from i386. Doesn't make much sense, because it will
> -	   only work for pci_alloc_coherent.
> -	   The caller just has to use GFP_DMA in this case. */
> -	if (mask < DMA_BIT_MASK(24))
> -		return 0;
> -
>  	/* Tell the device to use SAC when IOMMU force is on.  This
>  	   allows the driver to use cheaper accesses in some cases.
>  
> @@ -249,6 +243,17 @@ int x86_dma_supported(struct device *dev, u64 mask)
>  
>  	return 1;
>  }
> +EXPORT_SYMBOL(arch_dma_supported);
> +
> +int x86_dma_supported(struct device *dev, u64 mask)
> +{
> +	/* Copied from i386. Doesn't make much sense, because it will
> +	   only work for pci_alloc_coherent.
> +	   The caller just has to use GFP_DMA in this case. */
> +	if (mask < DMA_BIT_MASK(24))
> +		return 0;
> +	return 1;
> +}
>  
>  static int __init pci_iommu_init(void)
>  {
> diff --git a/include/linux/dma-mapping.h b/include/linux/dma-mapping.h
> index 88bcb1a8211d..d67742dad904 100644
> --- a/include/linux/dma-mapping.h
> +++ b/include/linux/dma-mapping.h
> @@ -576,6 +576,14 @@ static inline int dma_mapping_error(struct device *dev, dma_addr_t dma_addr)
>  	return 0;
>  }
>  
> +/*
> + * This is a hack for the legacy x86 forbid_dac and iommu_sac_force. Please
> + * don't use this is new code.
> + */
> +#ifndef arch_dma_supported
> +#define arch_dma_supported(dev, mask)	(1)
> +#endif
> +
>  static inline void dma_check_mask(struct device *dev, u64 mask)
>  {
>  	if (sme_active() && (mask < (((u64)sme_get_me_mask() << 1) - 1)))
> @@ -588,6 +596,9 @@ static inline int dma_supported(struct device *dev, u64 mask)
>  
>  	if (!ops)
>  		return 0;
> +	if (!arch_dma_supported(dev, mask))
> +		return 0;
> +
>  	if (!ops->dma_supported)
>  		return 1;
>  	return ops->dma_supported(dev, mask);
> -- 
> 2.14.2
> 
