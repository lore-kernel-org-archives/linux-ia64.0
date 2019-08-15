From: Lu Baolu <baolu.lu@linux.intel.com>
Date: Thu, 15 Aug 2019 05:01:57 +0000
Subject: Re: [PATCH 06/10] iommu: Remember when default domain type was set on kernel command line
Message-Id: <754a526e-a6d4-8a3f-0b35-9dd3def5d24b@linux.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190814133841.7095-1-joro@8bytes.org>
 <20190814133841.7095-7-joro@8bytes.org>
In-Reply-To: <20190814133841.7095-7-joro@8bytes.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Joerg Roedel <joro@8bytes.org>
Cc: baolu.lu@linux.intel.com, corbet@lwn.net, tony.luck@intel.com, fenghua.yu@intel.com, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, hpa@zytor.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-ia64@vger.kernel.org, iommu@lists.linux-foundation.org, linux-kernel@vger.kernel.org, Thomas.Lendacky@amd.com, Suravee.Suthikulpanit@amd.com, Joerg Roedel <jroedel@suse.de>

Hi,

On 8/14/19 9:38 PM, Joerg Roedel wrote:
> From: Joerg Roedel <jroedel@suse.de>
> 
> Introduce an extensible concept to remember when certain
> configuration settings for the IOMMU code have been set on
> the kernel command line.
> 
> This will be used later to prevent overwriting these
> settings with other defaults.
> 
> Signed-off-by: Joerg Roedel <jroedel@suse.de>
> ---
>   drivers/iommu/iommu.c | 15 +++++++++++++++
>   1 file changed, 15 insertions(+)
> 
> diff --git a/drivers/iommu/iommu.c b/drivers/iommu/iommu.c
> index f187e85a074b..e1feb4061b8b 100644
> --- a/drivers/iommu/iommu.c
> +++ b/drivers/iommu/iommu.c
> @@ -32,6 +32,7 @@ static unsigned int iommu_def_domain_type = IOMMU_DOMAIN_IDENTITY;
>   static unsigned int iommu_def_domain_type = IOMMU_DOMAIN_DMA;
>   #endif
>   static bool iommu_dma_strict __read_mostly = true;
> +static u32 iommu_cmd_line __read_mostly;
>   
>   struct iommu_group {
>   	struct kobject kobj;
> @@ -68,6 +69,18 @@ static const char * const iommu_group_resv_type_string[] = {
>   	[IOMMU_RESV_SW_MSI]			= "msi",
>   };
>   
> +#define IOMMU_CMD_LINE_DMA_API		(1 << 0)

Prefer BIT() micro?

> +
> +static void iommu_set_cmd_line_dma_api(void)
> +{
> +	iommu_cmd_line |= IOMMU_CMD_LINE_DMA_API;
> +}
> +
> +static bool __maybe_unused iommu_cmd_line_dma_api(void)
> +{
> +	return !!(iommu_cmd_line & IOMMU_CMD_LINE_DMA_API);
> +}
> +
>   #define IOMMU_GROUP_ATTR(_name, _mode, _show, _store)		\
>   struct iommu_group_attribute iommu_group_attr_##_name =		\
>   	__ATTR(_name, _mode, _show, _store)
> @@ -165,6 +178,8 @@ static int __init iommu_set_def_domain_type(char *str)
>   	if (ret)
>   		return ret;
>   
> +	iommu_set_cmd_line_dma_api();

IOMMU command line is also set in other places, for example,
iommu_setup() (arch/x86/kernel/pci-dma.c). Need to call this there as
well?

Best regards,
Lu Baolu

> +
>   	iommu_def_domain_type = pt ? IOMMU_DOMAIN_IDENTITY : IOMMU_DOMAIN_DMA;
>   	return 0;
>   }
> 
