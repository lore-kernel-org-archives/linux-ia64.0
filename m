From: "Enrico Weigelt, metux IT consult" <lkml@metux.net>
Date: Mon, 22 Jul 2019 06:58:05 +0000
Subject: Re: [PATCH] ia64: tioca: fix spelling mistake in macros CA_APERATURE_{BASE|SIZE}
Message-Id: <c62e488f-38b9-304d-f9d6-5502c25b84b7@metux.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190721205921.9960-1-colin.king@canonical.com>
In-Reply-To: <20190721205921.9960-1-colin.king@canonical.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Colin King <colin.king@canonical.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org

On 21.07.19 22:59, Colin King wrote:
> From: Colin Ian King <colin.king@canonical.com>
> 
> The two macros CA_APERATURE_BASE and CA_APERATURE_SIZE contain
> a spelling mistake, APERATURE should be APERTURE, so fix these.
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>
> ---
>   arch/ia64/include/asm/sn/tioca.h  |  4 ++--
>   arch/ia64/sn/pci/tioca_provider.c | 14 +++++++-------
>   2 files changed, 9 insertions(+), 9 deletions(-)
> 
> diff --git a/arch/ia64/include/asm/sn/tioca.h b/arch/ia64/include/asm/sn/tioca.h
> index 666222d7f0f6..4529fb11c86c 100644
> --- a/arch/ia64/include/asm/sn/tioca.h
> +++ b/arch/ia64/include/asm/sn/tioca.h
> @@ -590,7 +590,7 @@ struct tioca {
>   #define CA_AGP_DIRECT_BASE	0x40000000UL	/* 2GB */
>   #define CA_AGP_DIRECT_SIZE	0x40000000UL
>   
> -#define CA_APERATURE_BASE	(CA_AGP_MAPPED_BASE)
> -#define CA_APERATURE_SIZE	(CA_AGP_MAPPED_SIZE+CA_PCI32_MAPPED_SIZE)
> +#define CA_APERTURE_BASE	(CA_AGP_MAPPED_BASE)
> +#define CA_APERTURE_SIZE	(CA_AGP_MAPPED_SIZE+CA_PCI32_MAPPED_SIZE)
>   
>   #endif  /* _ASM_IA64_SN_TIO_TIOCA_H */
> diff --git a/arch/ia64/sn/pci/tioca_provider.c b/arch/ia64/sn/pci/tioca_provider.c
> index a70b11fd57d6..07832f5e8718 100644
> --- a/arch/ia64/sn/pci/tioca_provider.c
> +++ b/arch/ia64/sn/pci/tioca_provider.c
> @@ -55,7 +55,7 @@ tioca_gart_init(struct tioca_kernel *tioca_kern)
>   	 * Validate aperature size
>   	 */
>   
> -	switch (CA_APERATURE_SIZE >> 20) {
> +	switch (CA_APERTURE_SIZE >> 20) {
>   	case 4:
>   		ap_reg |= (0x3ff << CA_GART_AP_SIZE_SHFT);	/* 4MB */
>   		break;
> @@ -90,8 +90,8 @@ tioca_gart_init(struct tioca_kernel *tioca_kern)
>   		ap_reg |= (0x000 << CA_GART_AP_SIZE_SHFT);	/* 4 GB */
>   		break;
>   	default:
> -		printk(KERN_ERR "%s:  Invalid CA_APERATURE_SIZE "
> -		       "0x%lx\n", __func__, (ulong) CA_APERATURE_SIZE);
> +		printk(KERN_ERR "%s:  Invalid CA_APERTURE_SIZE "
> +		       "0x%lx\n", __func__, (ulong) CA_APERTURE_SIZE);
>   		return -1;
>   	}
>   
> @@ -106,8 +106,8 @@ tioca_gart_init(struct tioca_kernel *tioca_kern)
>   		tioca_kern->ca_ap_pagesize = 4096;
>   	}
>   
> -	tioca_kern->ca_ap_size = CA_APERATURE_SIZE;
> -	tioca_kern->ca_ap_bus_base = CA_APERATURE_BASE;
> +	tioca_kern->ca_ap_size = CA_APERTURE_SIZE;
> +	tioca_kern->ca_ap_bus_base = CA_APERTURE_BASE;
>   	tioca_kern->ca_gart_entries >   	    tioca_kern->ca_ap_size / tioca_kern->ca_ap_pagesize;
>   
> @@ -141,7 +141,7 @@ tioca_gart_init(struct tioca_kernel *tioca_kern)
>   	 * Compute PCI/AGP convenience fields
>   	 */
>   
> -	offset = CA_PCI32_MAPPED_BASE - CA_APERATURE_BASE;
> +	offset = CA_PCI32_MAPPED_BASE - CA_APERTURE_BASE;
>   	tioca_kern->ca_pciap_base = CA_PCI32_MAPPED_BASE;
>   	tioca_kern->ca_pciap_size = CA_PCI32_MAPPED_SIZE;
>   	tioca_kern->ca_pcigart_start = offset / tioca_kern->ca_ap_pagesize;
> @@ -159,7 +159,7 @@ tioca_gart_init(struct tioca_kernel *tioca_kern)
>   		return -1;
>   	}
>   
> -	offset = CA_AGP_MAPPED_BASE - CA_APERATURE_BASE;
> +	offset = CA_AGP_MAPPED_BASE - CA_APERTURE_BASE;
>   	tioca_kern->ca_gfxap_base = CA_AGP_MAPPED_BASE;
>   	tioca_kern->ca_gfxap_size = CA_AGP_MAPPED_SIZE;
>   	tioca_kern->ca_gfxgart_start = offset / tioca_kern->ca_ap_pagesize;
> 
Reviewed-By: Enrico Weigelt <info@metux.net>

-- 
Enrico Weigelt, metux IT consult
Free software and Linux embedded engineering
info@metux.net -- +49-151-27565287
