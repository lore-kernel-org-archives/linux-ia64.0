From: Joerg Roedel <joerg.roedel@amd.com>
Date: Mon, 08 Sep 2008 12:01:10 +0000
Subject: Re: [PATCH 2/5] x86: move pci-nommu's dma_mask check to common code
Message-Id: <20080908120110.GJ3189@amd.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1220865014-1169-1-git-send-email-fujita.tomonori@lab.ntt.co.jp> <1220865014-1169-2-git-send-email-fujita.tomonori@lab.ntt.co.jp> <1220865014-1169-3-git-send-email-fujita.tomonori@lab.ntt.co.jp>
In-Reply-To: <1220865014-1169-3-git-send-email-fujita.tomonori@lab.ntt.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Cc: linux-kernel@vger.kernel.org, mingo@redhat.com, tony.luck@intel.com, linux-ia64@vger.kernel.org, iommu@lists.linux-foundation.org

On Mon, Sep 08, 2008 at 06:10:11PM +0900, FUJITA Tomonori wrote:
> The check to see if dev->dma_mask is NULL in pci-nommu is more
> appropriate for dma_alloc_coherent().
> 
> Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>

Acked-by: Joerg Roedel <joerg.roedel@amd.com>

> ---
>  arch/x86/kernel/pci-nommu.c   |    3 ---
>  include/asm-x86/dma-mapping.h |    3 +++
>  2 files changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/arch/x86/kernel/pci-nommu.c b/arch/x86/kernel/pci-nommu.c
> index 73853d3..0f51883 100644
> --- a/arch/x86/kernel/pci-nommu.c
> +++ b/arch/x86/kernel/pci-nommu.c
> @@ -80,9 +80,6 @@ nommu_alloc_coherent(struct device *hwdev, size_t size,
>  	int node;
>  	struct page *page;
>  
> -	if (hwdev->dma_mask = NULL)
> -		return NULL;
> -
>  	gfp &= ~(__GFP_DMA | __GFP_HIGHMEM | __GFP_DMA32);
>  	gfp |= __GFP_ZERO;
>  
> diff --git a/include/asm-x86/dma-mapping.h b/include/asm-x86/dma-mapping.h
> index bc6c8df..39d3641 100644
> --- a/include/asm-x86/dma-mapping.h
> +++ b/include/asm-x86/dma-mapping.h
> @@ -256,6 +256,9 @@ dma_alloc_coherent(struct device *dev, size_t size, dma_addr_t *dma_handle,
>  		gfp |= GFP_DMA;
>  	}
>  
> +	if (!dev->dma_mask)
> +		return NULL;
> +
>  	if (ops->alloc_coherent)
>  		return ops->alloc_coherent(dev, size,
>  				dma_handle, gfp);
> -- 
> 1.5.5.GIT
> 
> 

-- 
           |           AMD Saxony Limited Liability Company & Co. KG
 Operating |         Wilschdorfer Landstr. 101, 01109 Dresden, Germany
 System    |                  Register Court Dresden: HRA 4896
 Research  |              General Partner authorized to represent:
 Center    |             AMD Saxony LLC (Wilmington, Delaware, US)
           | General Manager of AMD Saxony LLC: Dr. Hans-R. Deppe, Thomas McCoy

