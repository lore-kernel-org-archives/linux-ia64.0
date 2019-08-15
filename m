From: Lu Baolu <baolu.lu@linux.intel.com>
Date: Thu, 15 Aug 2019 04:53:28 +0000
Subject: Re: [PATCH 04/10] x86/dma: Get rid of iommu_pass_through
Message-Id: <ef941cbd-07dc-ac93-e5b2-f30ac4a55bc2@linux.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190814133841.7095-1-joro@8bytes.org>
 <20190814133841.7095-5-joro@8bytes.org>
In-Reply-To: <20190814133841.7095-5-joro@8bytes.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Joerg Roedel <joro@8bytes.org>
Cc: baolu.lu@linux.intel.com, fenghua.yu@intel.com, tony.luck@intel.com, linux-ia64@vger.kernel.org, corbet@lwn.net, Joerg Roedel <jroedel@suse.de>, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, iommu@lists.linux-foundation.org, mingo@redhat.com, bp@alien8.de, Thomas.Lendacky@amd.com, hpa@zytor.com, tglx@linutronix.de

Hi,

On 8/14/19 9:38 PM, Joerg Roedel wrote:
> From: Joerg Roedel <jroedel@suse.de>
> 
> This variable has no users anymore. Remove it and tell the
> IOMMU code via its new functions about requested DMA modes.
> 
> Signed-off-by: Joerg Roedel <jroedel@suse.de>

This will also simplify the procedures in iommu_probe_device() on x86
platforms.

Reviewed-by: Lu Baolu <baolu.lu@linux.intel.com>

> ---
>   arch/x86/include/asm/iommu.h |  1 -
>   arch/x86/kernel/pci-dma.c    | 11 +++--------
>   2 files changed, 3 insertions(+), 9 deletions(-)
> 
> diff --git a/arch/x86/include/asm/iommu.h b/arch/x86/include/asm/iommu.h
> index baedab8ac538..b91623d521d9 100644
> --- a/arch/x86/include/asm/iommu.h
> +++ b/arch/x86/include/asm/iommu.h
> @@ -4,7 +4,6 @@
>   
>   extern int force_iommu, no_iommu;
>   extern int iommu_detected;
> -extern int iommu_pass_through;
>   
>   /* 10 seconds */
>   #define DMAR_OPERATION_TIMEOUT ((cycles_t) tsc_khz*10*1000)
> diff --git a/arch/x86/kernel/pci-dma.c b/arch/x86/kernel/pci-dma.c
> index f62b498b18fb..a6fd479d4a71 100644
> --- a/arch/x86/kernel/pci-dma.c
> +++ b/arch/x86/kernel/pci-dma.c
> @@ -1,6 +1,7 @@
>   // SPDX-License-Identifier: GPL-2.0
>   #include <linux/dma-direct.h>
>   #include <linux/dma-debug.h>
> +#include <linux/iommu.h>
>   #include <linux/dmar.h>
>   #include <linux/export.h>
>   #include <linux/memblock.h>
> @@ -43,12 +44,6 @@ int iommu_detected __read_mostly = 0;
>    * It is also possible to disable by default in kernel config, and enable with
>    * iommu=nopt at boot time.
>    */
> -#ifdef CONFIG_IOMMU_DEFAULT_PASSTHROUGH
> -int iommu_pass_through __read_mostly = 1;
> -#else
> -int iommu_pass_through __read_mostly;
> -#endif
> -
>   extern struct iommu_table_entry __iommu_table[], __iommu_table_end[];
>   
>   void __init pci_iommu_alloc(void)
> @@ -120,9 +115,9 @@ static __init int iommu_setup(char *p)
>   			swiotlb = 1;
>   #endif
>   		if (!strncmp(p, "pt", 2))
> -			iommu_pass_through = 1;
> +			iommu_set_default_passthrough();
>   		if (!strncmp(p, "nopt", 4))
> -			iommu_pass_through = 0;
> +			iommu_set_default_translated();
>   
>   		gart_parse_options(p);
>   
> 
