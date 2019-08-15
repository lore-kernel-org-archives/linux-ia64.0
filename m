From: Lu Baolu <baolu.lu@linux.intel.com>
Date: Thu, 15 Aug 2019 05:04:30 +0000
Subject: Re: [PATCH 07/10] iommu: Print default domain type on boot
Message-Id: <39163f22-0c22-ccae-84df-e65f53aa1a82@linux.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190814133841.7095-1-joro@8bytes.org>
 <20190814133841.7095-8-joro@8bytes.org>
In-Reply-To: <20190814133841.7095-8-joro@8bytes.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Joerg Roedel <joro@8bytes.org>
Cc: baolu.lu@linux.intel.com, corbet@lwn.net, tony.luck@intel.com, fenghua.yu@intel.com, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, hpa@zytor.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-ia64@vger.kernel.org, iommu@lists.linux-foundation.org, linux-kernel@vger.kernel.org, Thomas.Lendacky@amd.com, Suravee.Suthikulpanit@amd.com, Joerg Roedel <jroedel@suse.de>

Hi,

On 8/14/19 9:38 PM, Joerg Roedel wrote:
> From: Joerg Roedel <jroedel@suse.de>
> 
> Introduce a subsys_initcall for IOMMU code and use it to
> print the default domain type at boot.
> 
> Signed-off-by: Joerg Roedel <jroedel@suse.de>
> ---
>   drivers/iommu/iommu.c | 30 +++++++++++++++++++++++++++++-
>   1 file changed, 29 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/iommu/iommu.c b/drivers/iommu/iommu.c
> index e1feb4061b8b..233bc22b487e 100644
> --- a/drivers/iommu/iommu.c
> +++ b/drivers/iommu/iommu.c
> @@ -93,12 +93,40 @@ struct iommu_group_attribute iommu_group_attr_##_name =		\
>   static LIST_HEAD(iommu_device_list);
>   static DEFINE_SPINLOCK(iommu_device_lock);
>   
> +/*
> + * Use a function instead of an array here because the domain-type is a
> + * bit-field, so an array would waste memory.
> + */
> +static const char *iommu_domain_type_str(unsigned int t)
> +{
> +	switch (t) {
> +		case IOMMU_DOMAIN_BLOCKED:
> +			return "Blocked";
> +		case IOMMU_DOMAIN_IDENTITY:
> +			return "Passthrough";
> +		case IOMMU_DOMAIN_UNMANAGED:
> +			return "Unmanaged";
> +		case IOMMU_DOMAIN_DMA:
> +			return "Translated";
> +		default:
> +			return "Unknown";
> +	}
> +}

Run scripts/checkpatch.pl:

ERROR: switch and case should be at the same indent
#28: FILE: drivers/iommu/iommu.c:102:
+	switch (t) {
+		case IOMMU_DOMAIN_BLOCKED:
[...]
+		case IOMMU_DOMAIN_IDENTITY:
[...]
+		case IOMMU_DOMAIN_UNMANAGED:
[...]
+		case IOMMU_DOMAIN_DMA:
[...]
+		default:

Best regards,
Lu Baolu

> +
> +static int __init iommu_subsys_init(void)
> +{
> +	pr_info("Default domain type: %s\n",
> +		iommu_domain_type_str(iommu_def_domain_type));
> +
> +	return 0;
> +}
> +subsys_initcall(iommu_subsys_init);
> +
>   int iommu_device_register(struct iommu_device *iommu)
>   {
>   	spin_lock(&iommu_device_lock);
>   	list_add_tail(&iommu->list, &iommu_device_list);
>   	spin_unlock(&iommu_device_lock);
> -
>   	return 0;
>   }
>   
> 
