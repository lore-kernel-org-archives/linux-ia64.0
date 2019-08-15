From: Lu Baolu <baolu.lu@linux.intel.com>
Date: Thu, 15 Aug 2019 04:46:01 +0000
Subject: Re: [PATCH 03/10] iommu/vt-d: Request passthrough mode from IOMMU core
Message-Id: <77ee40c6-392c-5094-c945-a63dc370188d@linux.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190814133841.7095-1-joro@8bytes.org>
 <20190814133841.7095-4-joro@8bytes.org>
In-Reply-To: <20190814133841.7095-4-joro@8bytes.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Joerg Roedel <joro@8bytes.org>
Cc: baolu.lu@linux.intel.com, corbet@lwn.net, tony.luck@intel.com, fenghua.yu@intel.com, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, hpa@zytor.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-ia64@vger.kernel.org, iommu@lists.linux-foundation.org, linux-kernel@vger.kernel.org, Thomas.Lendacky@amd.com, Suravee.Suthikulpanit@amd.com, Joerg Roedel <jroedel@suse.de>

Hi Joerg,

On 8/14/19 9:38 PM, Joerg Roedel wrote:
> From: Joerg Roedel <jroedel@suse.de>
> 
> Get rid of the iommu_pass_through variable and request
> passthrough mode via the new iommu core function.
> 
> Signed-off-by: Joerg Roedel <jroedel@suse.de>

Looks good to me.

Reviewed-by: Lu Baolu <baolu.lu@linux.intel.com>

> ---
>   drivers/iommu/intel-iommu.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/iommu/intel-iommu.c b/drivers/iommu/intel-iommu.c
> index bdaed2da8a55..234bc2b55c59 100644
> --- a/drivers/iommu/intel-iommu.c
> +++ b/drivers/iommu/intel-iommu.c
> @@ -3267,7 +3267,7 @@ static int __init init_dmars(void)
>   		iommu->flush.flush_iotlb(iommu, 0, 0, 0, DMA_TLB_GLOBAL_FLUSH);
>   	}
>   
> -	if (iommu_pass_through)
> +	if (iommu_default_passthrough())
>   		iommu_identity_mapping |= IDENTMAP_ALL;
>   
>   #ifdef CONFIG_INTEL_IOMMU_BROKEN_GFX_WA
> 
