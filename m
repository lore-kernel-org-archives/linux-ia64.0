From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Date: Wed, 05 Aug 2009 00:31:47 +0000
Subject: Re: [PATCH] Bug Fix arch/ia64/kernel/pci-dma.c: fix recursive
Message-Id: <20090805093114F.fujita.tomonori@lab.ntt.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090804223526.GA26801@linux-os.sc.intel.com>
In-Reply-To: <20090804223526.GA26801@linux-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 4 Aug 2009 15:35:26 -0700
Fenghua Yu <fenghua.yu@intel.com> wrote:

> In commit dfb805e831cc5306b14eacd64e0b36d0d973ee0d,
> dma_ops->dma_supported = iommu_dma_supported;

Hmm, the dfb805e831cc5306b14eacd64e0b36d0d973ee0d commit touches only
dma_ops->mapping_error. It doesn't like like that this commit is
related with the bug.

I guess that I added the bug when I rewrote IA64 dma operations.


> This dma_ops->dma_supported is first called in platform_dma_init() during kernel
> boot. Then dma_ops->dma_supported will be called recursively in
> iommu_dma_supported.
> 
> Kernel can not boot because kernel can not get out of iommu_dma_supported until
> it runs out of stack memory.

The patch looks correct.

Reviewed-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>


Thanks!

> 
> Signed-off-by: Fenghua Yu <fenghua.yu@intel.com>
> 
> ---
> 
>  arch/ia64/kernel/pci-dma.c |    5 -----
>  1 files changed, 5 deletions(-)
> 
> diff --git a/arch/ia64/kernel/pci-dma.c b/arch/ia64/kernel/pci-dma.c
> index 0569596..f6b1ff0 100644
> --- a/arch/ia64/kernel/pci-dma.c
> +++ b/arch/ia64/kernel/pci-dma.c
> @@ -69,11 +69,6 @@ iommu_dma_init(void)
>  
>  int iommu_dma_supported(struct device *dev, u64 mask)
>  {
> -	struct dma_map_ops *ops = platform_dma_get_ops(dev);
> -
> -	if (ops->dma_supported)
> -		return ops->dma_supported(dev, mask);
> -
>  	/* Copied from i386. Doesn't make much sense, because it will
>  	   only work for pci_alloc_coherent.
>  	   The caller just has to use GFP_DMA in this case. */
> --
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
