From: Lu Baolu <baolu.lu@linux.intel.com>
Date: Thu, 15 Aug 2019 06:55:39 +0000
Subject: Re: [PATCH 08/10] iommu: Set default domain type at runtime
Message-Id: <a8e804dd-a8ae-2e0d-6b3c-698fbc96bf75@linux.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190814133841.7095-1-joro@8bytes.org>
 <20190814133841.7095-9-joro@8bytes.org>
In-Reply-To: <20190814133841.7095-9-joro@8bytes.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Joerg Roedel <joro@8bytes.org>
Cc: baolu.lu@linux.intel.com, corbet@lwn.net, tony.luck@intel.com, fenghua.yu@intel.com, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, hpa@zytor.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-ia64@vger.kernel.org, iommu@lists.linux-foundation.org, linux-kernel@vger.kernel.org, Thomas.Lendacky@amd.com, Suravee.Suthikulpanit@amd.com, Joerg Roedel <jroedel@suse.de>

Hi,

On 8/14/19 9:38 PM, Joerg Roedel wrote:
> From: Joerg Roedel <jroedel@suse.de>
> 
> Set the default domain-type at runtime, not at compile-time.
> This keeps default domain type setting in one place when we
> have to change it at runtime.
> 
> Signed-off-by: Joerg Roedel <jroedel@suse.de>
> ---
>   drivers/iommu/iommu.c | 23 +++++++++++++++--------
>   1 file changed, 15 insertions(+), 8 deletions(-)
> 
> diff --git a/drivers/iommu/iommu.c b/drivers/iommu/iommu.c
> index 233bc22b487e..96cc7cc8ab21 100644
> --- a/drivers/iommu/iommu.c
> +++ b/drivers/iommu/iommu.c
> @@ -26,11 +26,8 @@
>   
>   static struct kset *iommu_group_kset;
>   static DEFINE_IDA(iommu_group_ida);
> -#ifdef CONFIG_IOMMU_DEFAULT_PASSTHROUGH
> -static unsigned int iommu_def_domain_type = IOMMU_DOMAIN_IDENTITY;
> -#else
> -static unsigned int iommu_def_domain_type = IOMMU_DOMAIN_DMA;
> -#endif
> +
> +static unsigned int iommu_def_domain_type __read_mostly;
>   static bool iommu_dma_strict __read_mostly = true;
>   static u32 iommu_cmd_line __read_mostly;
>   
> @@ -76,7 +73,7 @@ static void iommu_set_cmd_line_dma_api(void)
>   	iommu_cmd_line |= IOMMU_CMD_LINE_DMA_API;
>   }
>   
> -static bool __maybe_unused iommu_cmd_line_dma_api(void)
> +static bool iommu_cmd_line_dma_api(void)
>   {
>   	return !!(iommu_cmd_line & IOMMU_CMD_LINE_DMA_API);
>   }
> @@ -115,8 +112,18 @@ static const char *iommu_domain_type_str(unsigned int t)
>   
>   static int __init iommu_subsys_init(void)
>   {
> -	pr_info("Default domain type: %s\n",
> -		iommu_domain_type_str(iommu_def_domain_type));
> +	bool cmd_line = iommu_cmd_line_dma_api();
> +
> +	if (!cmd_line) {
> +		if (IS_ENABLED(CONFIG_IOMMU_DEFAULT_PASSTHROUGH))
> +			iommu_set_default_passthrough();
> +		else
> +			iommu_set_default_translated();

This overrides kernel parameters parsed in iommu_setup(), for example,
iommu=pt won't work anymore.

Best regards,
Lu Baolu

> +	}
> +
> +	pr_info("Default domain type: %s %s\n",
> +		iommu_domain_type_str(iommu_def_domain_type),
> +		cmd_line ? "(set via kernel command line)" : "");
>   
>   	return 0;
>   }
> 
