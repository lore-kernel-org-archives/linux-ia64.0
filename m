From: Borislav Petkov <bp@alien8.de>
Date: Tue, 20 Aug 2019 11:17:53 +0000
Subject: Re: [PATCH 06/11] x86/dma: Get rid of iommu_pass_through
Message-Id: <20190820111753.GD31607@zn.tnic>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190819132256.14436-1-joro@8bytes.org>
 <20190819132256.14436-7-joro@8bytes.org>
In-Reply-To: <20190819132256.14436-7-joro@8bytes.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Joerg Roedel <joro@8bytes.org>
Cc: corbet@lwn.net, tony.luck@intel.com, fenghua.yu@intel.com, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-ia64@vger.kernel.org, iommu@lists.linux-foundation.org, linux-kernel@vger.kernel.org, Thomas.Lendacky@amd.com, Suravee.Suthikulpanit@amd.com, Joerg Roedel <jroedel@suse.de>

On Mon, Aug 19, 2019 at 03:22:51PM +0200, Joerg Roedel wrote:
> From: Joerg Roedel <jroedel@suse.de>
> 
> This variable has no users anymore. Remove it and tell the
> IOMMU code via its new functions about requested DMA modes.
> 
> Signed-off-by: Joerg Roedel <jroedel@suse.de>
> ---
>  arch/x86/include/asm/iommu.h |  1 -
>  arch/x86/kernel/pci-dma.c    | 20 +++-----------------
>  2 files changed, 3 insertions(+), 18 deletions(-)
> 
> diff --git a/arch/x86/include/asm/iommu.h b/arch/x86/include/asm/iommu.h
> index baedab8ac538..b91623d521d9 100644
> --- a/arch/x86/include/asm/iommu.h
> +++ b/arch/x86/include/asm/iommu.h
> @@ -4,7 +4,6 @@
>  
>  extern int force_iommu, no_iommu;
>  extern int iommu_detected;
> -extern int iommu_pass_through;
>  
>  /* 10 seconds */
>  #define DMAR_OPERATION_TIMEOUT ((cycles_t) tsc_khz*10*1000)
> diff --git a/arch/x86/kernel/pci-dma.c b/arch/x86/kernel/pci-dma.c
> index f62b498b18fb..fa4352dce491 100644
> --- a/arch/x86/kernel/pci-dma.c
> +++ b/arch/x86/kernel/pci-dma.c
> @@ -1,6 +1,7 @@
>  // SPDX-License-Identifier: GPL-2.0
>  #include <linux/dma-direct.h>
>  #include <linux/dma-debug.h>
> +#include <linux/iommu.h>
>  #include <linux/dmar.h>
>  #include <linux/export.h>
>  #include <linux/memblock.h>
> @@ -34,21 +35,6 @@ int no_iommu __read_mostly;
>  /* Set this to 1 if there is a HW IOMMU in the system */
>  int iommu_detected __read_mostly = 0;
>  
> -/*
> - * This variable becomes 1 if iommu=pt is passed on the kernel command line.
> - * If this variable is 1, IOMMU implementations do no DMA translation for
> - * devices and allow every device to access to whole physical memory. This is
> - * useful if a user wants to use an IOMMU only for KVM device assignment to
> - * guests and not for driver dma translation.
> - * It is also possible to disable by default in kernel config, and enable with
> - * iommu=nopt at boot time.
> - */
> -#ifdef CONFIG_IOMMU_DEFAULT_PASSTHROUGH
> -int iommu_pass_through __read_mostly = 1;
> -#else
> -int iommu_pass_through __read_mostly;
> -#endif
> -
>  extern struct iommu_table_entry __iommu_table[], __iommu_table_end[];
>  
>  void __init pci_iommu_alloc(void)
> @@ -120,9 +106,9 @@ static __init int iommu_setup(char *p)
>  			swiotlb = 1;
>  #endif
>  		if (!strncmp(p, "pt", 2))
> -			iommu_pass_through = 1;
> +			iommu_set_default_passthrough(true);
>  		if (!strncmp(p, "nopt", 4))
> -			iommu_pass_through = 0;
> +			iommu_set_default_translated(true);
>  
>  		gart_parse_options(p);
>  
> -- 

Reviewed-by: Borislav Petkov <bp@suse.de>

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.
