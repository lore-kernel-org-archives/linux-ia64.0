From: Stefano Stabellini <stefano.stabellini@eu.citrix.com>
Date: Fri, 14 Nov 2014 15:11:34 +0000
Subject: Re: [Xen-devel] [PATCH 1/3] dma, ia64: add dma_get_required_mask_from_max_pfn()
Message-Id: <alpine.DEB.2.02.1411141507550.26318@kaball.uk.xensource.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1415805906-27316-1-git-send-email-david.vrabel@citrix.com> <1415805906-27316-2-git-send-email-david.vrabel@citrix.com>
In-Reply-To: <1415805906-27316-2-git-send-email-david.vrabel@citrix.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Vrabel <david.vrabel@citrix.com>
Cc: linux-kernel@vger.kernel.org, Fenghua Yu <fenghua.yu@intel.com>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, x86@kernel.org, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, xen-devel@lists.xenproject.org, Thomas Gleixner <tglx@linutronix.de>, Boris Ostrovsky <boris.ostrovsky@oracle.com>

On Wed, 12 Nov 2014, David Vrabel wrote:
> ia64 provides a duplicate of the generic dma_get_required_mask()
> because it has ARCH_HAS_GET_REQUIRED_MASK.  Provide a common
> dma_get_require_mask_max_pfn() instead.
> 
> Signed-off-by: David Vrabel <david.vrabel@citrix.com>
> Cc: Tony Luck <tony.luck@intel.com>
> Cc: Fenghua Yu <fenghua.yu@intel.com>
> Cc: linux-ia64@vger.kernel.org

Reviewed-by: Stefano Stabellini <stefano.stabellini@eu.citrix.com>


>  arch/ia64/include/asm/machvec.h      |    2 +-
>  arch/ia64/include/asm/machvec_init.h |    1 -
>  arch/ia64/pci/pci.c                  |   20 --------------------
>  drivers/base/platform.c              |   10 ++++++++--
>  include/linux/dma-mapping.h          |    1 +
>  5 files changed, 10 insertions(+), 24 deletions(-)
> 
> diff --git a/arch/ia64/include/asm/machvec.h b/arch/ia64/include/asm/machvec.h
> index 9c39bdf..beaa47d 100644
> --- a/arch/ia64/include/asm/machvec.h
> +++ b/arch/ia64/include/asm/machvec.h
> @@ -287,7 +287,7 @@ extern struct dma_map_ops *dma_get_ops(struct device *);
>  # define platform_dma_get_ops		dma_get_ops
>  #endif
>  #ifndef platform_dma_get_required_mask
> -# define  platform_dma_get_required_mask	ia64_dma_get_required_mask
> +# define  platform_dma_get_required_mask	dma_get_required_mask_from_max_pfn
>  #endif
>  #ifndef platform_irq_to_vector
>  # define platform_irq_to_vector		__ia64_irq_to_vector
> diff --git a/arch/ia64/include/asm/machvec_init.h b/arch/ia64/include/asm/machvec_init.h
> index 37a4698..ef964b2 100644
> --- a/arch/ia64/include/asm/machvec_init.h
> +++ b/arch/ia64/include/asm/machvec_init.h
> @@ -3,7 +3,6 @@
>  
>  extern ia64_mv_send_ipi_t ia64_send_ipi;
>  extern ia64_mv_global_tlb_purge_t ia64_global_tlb_purge;
> -extern ia64_mv_dma_get_required_mask ia64_dma_get_required_mask;
>  extern ia64_mv_irq_to_vector __ia64_irq_to_vector;
>  extern ia64_mv_local_vector_to_irq __ia64_local_vector_to_irq;
>  extern ia64_mv_pci_get_legacy_mem_t ia64_pci_get_legacy_mem;
> diff --git a/arch/ia64/pci/pci.c b/arch/ia64/pci/pci.c
> index 291a582..79da21b 100644
> --- a/arch/ia64/pci/pci.c
> +++ b/arch/ia64/pci/pci.c
> @@ -791,26 +791,6 @@ static void __init set_pci_dfl_cacheline_size(void)
>  	pci_dfl_cache_line_size = (1 << cci.pcci_line_size) / 4;
>  }
>  
> -u64 ia64_dma_get_required_mask(struct device *dev)
> -{
> -	u32 low_totalram = ((max_pfn - 1) << PAGE_SHIFT);
> -	u32 high_totalram = ((max_pfn - 1) >> (32 - PAGE_SHIFT));
> -	u64 mask;
> -
> -	if (!high_totalram) {
> -		/* convert to mask just covering totalram */
> -		low_totalram = (1 << (fls(low_totalram) - 1));
> -		low_totalram += low_totalram - 1;
> -		mask = low_totalram;
> -	} else {
> -		high_totalram = (1 << (fls(high_totalram) - 1));
> -		high_totalram += high_totalram - 1;
> -		mask = (((u64)high_totalram) << 32) + 0xffffffff;
> -	}
> -	return mask;
> -}
> -EXPORT_SYMBOL_GPL(ia64_dma_get_required_mask);
> -
>  u64 dma_get_required_mask(struct device *dev)
>  {
>  	return platform_dma_get_required_mask(dev);
> diff --git a/drivers/base/platform.c b/drivers/base/platform.c
> index b2afc29..f9f3930 100644
> --- a/drivers/base/platform.c
> +++ b/drivers/base/platform.c
> @@ -1009,8 +1009,7 @@ int __init platform_bus_init(void)
>  	return error;
>  }
>  
> -#ifndef ARCH_HAS_DMA_GET_REQUIRED_MASK
> -u64 dma_get_required_mask(struct device *dev)
> +u64 dma_get_required_mask_from_max_pfn(struct device *dev)
>  {
>  	u32 low_totalram = ((max_pfn - 1) << PAGE_SHIFT);
>  	u32 high_totalram = ((max_pfn - 1) >> (32 - PAGE_SHIFT));
> @@ -1028,6 +1027,13 @@ u64 dma_get_required_mask(struct device *dev)
>  	}
>  	return mask;
>  }
> +EXPORT_SYMBOL_GPL(dma_get_required_mask_from_max_pfn);
> +
> +#ifndef ARCH_HAS_DMA_GET_REQUIRED_MASK
> +u64 dma_get_required_mask(struct device *dev)
> +{
> +	return dma_get_required_mask_from_max_pfn(dev);
> +}
>  EXPORT_SYMBOL_GPL(dma_get_required_mask);
>  #endif
> diff --git a/include/linux/dma-mapping.h b/include/linux/dma-mapping.h
> index d5d3881..6e2fdfc 100644
> --- a/include/linux/dma-mapping.h
> +++ b/include/linux/dma-mapping.h
> @@ -127,6 +127,7 @@ static inline int dma_coerce_mask_and_coherent(struct device *dev, u64 mask)
>  	return dma_set_mask_and_coherent(dev, mask);
>  }
>  
> +extern u64 dma_get_required_mask_from_max_pfn(struct device *dev);
>  extern u64 dma_get_required_mask(struct device *dev);
>  
>  #ifndef set_arch_dma_coherent_ops
> -- 
> 1.7.10.4
> 
> 
> _______________________________________________
> Xen-devel mailing list
> Xen-devel@lists.xen.org
> http://lists.xen.org/xen-devel
> 
