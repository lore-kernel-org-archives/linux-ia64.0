From: Anshuman Khandual <anshuman.khandual@arm.com>
Date: Thu, 24 Feb 2022 10:41:00 +0000
Subject: Re: [PATCH 02/11] swiotlb: make swiotlb_exit a no-op if SWIOTLB_FORCE is set
Message-Id: <b769ddc8-5ba3-b7a9-b295-92507a73c0d6@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220222153514.593231-1-hch@lst.de>
 <20220222153514.593231-3-hch@lst.de>
In-Reply-To: <20220222153514.593231-3-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>, iommu@lists.linux-foundation.org
Cc: x86@kernel.org, Stefano Stabellini <sstabellini@kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, Joerg Roedel <joro@8bytes.org>, David Woodhouse <dwmw2@infradead.org>, Lu Baolu <baolu.lu@linux.intel.com>, Robin Murphy <robin.murphy@arm.com>, linux-arm-kernel@lists.infradead.org, xen-devel@lists.xenproject.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-hyperv@vger.kernel.org, tboot-devel@lists.sourceforge.net, linux-pci@vger.kernel.org



On 2/22/22 9:05 PM, Christoph Hellwig wrote:
> If force bouncing is enabled we can't release the bufffers.

typo							^^^^

> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  kernel/dma/swiotlb.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/kernel/dma/swiotlb.c b/kernel/dma/swiotlb.c
> index f1e7ea160b433..36fbf1181d285 100644
> --- a/kernel/dma/swiotlb.c
> +++ b/kernel/dma/swiotlb.c
> @@ -378,6 +378,9 @@ void __init swiotlb_exit(void)
>  	unsigned long tbl_vaddr;
>  	size_t tbl_size, slots_size;
>  
> +	if (swiotlb_force = SWIOTLB_FORCE)
> +		return;
> +
>  	if (!mem->nslabs)
>  		return;
>  
> 

Reviewed-by: Anshuman Khandual <anshuman.khandual@arm.com>
