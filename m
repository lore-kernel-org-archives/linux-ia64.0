From: Stefano Stabellini <stefano.stabellini@eu.citrix.com>
Date: Wed, 19 Nov 2014 17:33:18 +0000
Subject: Re: [PATCH 2/4] ia64: use common dma_get_required_mask_from_pfn()
Message-Id: <alpine.DEB.2.02.1411191733090.12596@kaball.uk.xensource.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1416412921-23671-1-git-send-email-david.vrabel@citrix.com> <1416412921-23671-3-git-send-email-david.vrabel@citrix.com>
In-Reply-To: <1416412921-23671-3-git-send-email-david.vrabel@citrix.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Vrabel <david.vrabel@citrix.com>
Cc: linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, xen-devel@lists.xenproject.org, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

On Wed, 19 Nov 2014, David Vrabel wrote:
> Signed-off-by: David Vrabel <david.vrabel@citrix.com>
> Cc: Tony Luck <tony.luck@intel.com>
> Cc: Fenghua Yu <fenghua.yu@intel.com>
> Cc: linux-ia64@vger.kernel.org

Reviewed-by: Stefano Stabellini <stefano.stabellini@eu.citrix.com>


>  arch/ia64/include/asm/machvec.h      |    2 +-
>  arch/ia64/include/asm/machvec_init.h |    1 -
>  arch/ia64/pci/pci.c                  |   20 --------------------
>  3 files changed, 1 insertion(+), 22 deletions(-)
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
> -- 
> 1.7.10.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://secure-web.cisco.com/1uzdEOuzPh9ddYCppJ7edARD7taQXur82_EMioIJqXcGS1lEgfETQB2j546iHGLqo8mraFv4u9YxUpICa6DurqoTbYGXFrH14KuGQfFFzn4DHYx5HIksjcOqO2hiw74xfemY9frjnyDwhuBoBc3quJ5I8zLhf8kRz1AJGBKOKY_o/http%3A%2F%2Fwww.tux.org%2Flkml%2F
> 
