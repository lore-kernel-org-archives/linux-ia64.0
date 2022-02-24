From: Anshuman Khandual <anshuman.khandual@arm.com>
Date: Thu, 24 Feb 2022 10:38:56 +0000
Subject: Re: [PATCH 01/11] dma-direct: use is_swiotlb_active in dma_direct_map_page
Message-Id: <29452ad3-9db9-49d5-f91c-cb8507633ec0@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220222153514.593231-1-hch@lst.de>
 <20220222153514.593231-2-hch@lst.de>
In-Reply-To: <20220222153514.593231-2-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>, iommu@lists.linux-foundation.org
Cc: x86@kernel.org, Stefano Stabellini <sstabellini@kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, Joerg Roedel <joro@8bytes.org>, David Woodhouse <dwmw2@infradead.org>, Lu Baolu <baolu.lu@linux.intel.com>, Robin Murphy <robin.murphy@arm.com>, linux-arm-kernel@lists.infradead.org, xen-devel@lists.xenproject.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-hyperv@vger.kernel.org, tboot-devel@lists.sourceforge.net, linux-pci@vger.kernel.org



On 2/22/22 9:05 PM, Christoph Hellwig wrote:
> Use the more specific is_swiotlb_active check instead of checking the
> global swiotlb_force variable.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  kernel/dma/direct.h | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/kernel/dma/direct.h b/kernel/dma/direct.h
> index 4632b0f4f72eb..4dc16e08c7e1a 100644
> --- a/kernel/dma/direct.h
> +++ b/kernel/dma/direct.h
> @@ -91,7 +91,7 @@ static inline dma_addr_t dma_direct_map_page(struct device *dev,
>  		return swiotlb_map(dev, phys, size, dir, attrs);
>  
>  	if (unlikely(!dma_capable(dev, dma_addr, size, true))) {
> -		if (swiotlb_force != SWIOTLB_NO_FORCE)
> +		if (is_swiotlb_active(dev))
>  			return swiotlb_map(dev, phys, size, dir, attrs);
>  
>  		dev_WARN_ONCE(dev, 1,
> 

Reviewed-by: Anshuman Khandual <anshuman.khandual@arm.com>
