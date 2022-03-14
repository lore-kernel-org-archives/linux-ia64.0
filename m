From: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Date: Mon, 14 Mar 2022 23:11:55 +0000
Subject: Re: [PATCH 14/15] swiotlb: remove swiotlb_init_with_tbl and swiotlb_init_late_with_tbl
Message-Id: <ab552f6a-958a-e8c8-037f-b143119fefe5@oracle.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220314073129.1862284-1-hch@lst.de>
 <20220314073129.1862284-15-hch@lst.de>
In-Reply-To: <20220314073129.1862284-15-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>, iommu@lists.linux-foundation.org
Cc: Juergen Gross <jgross@suse.com>, Tom Lendacky <thomas.lendacky@amd.com>, linux-s390@vger.kernel.org, Stefano Stabellini <sstabellini@kernel.org>, linux-ia64@vger.kernel.org, Anshuman Khandual <anshuman.khandual@arm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Robin Murphy <robin.murphy@arm.com>, x86@kernel.org, linux-mips@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, tboot-devel@lists.sourceforge.net, linux-hyperv@vger.kernel.org, linux-pci@vger.kernel.org, xen-devel@lists.xenproject.org, linux-riscv@lists.infradead.org, David Woodhouse <dwmw2@infradead.org>, linux-arm-kernel@lists.infradead.org


On 3/14/22 3:31 AM, Christoph Hellwig wrote:
> @@ -314,6 +293,7 @@ void __init swiotlb_init(bool addressing_limit, unsigned int flags)
>   int swiotlb_init_late(size_t size, gfp_t gfp_mask,
>   		int (*remap)(void *tlb, unsigned long nslabs))
>   {
> +	struct io_tlb_mem *mem = &io_tlb_default_mem;
>   	unsigned long nslabs = ALIGN(size >> IO_TLB_SHIFT, IO_TLB_SEGSIZE);
>   	unsigned long bytes;
>   	unsigned char *vstart = NULL;
> @@ -355,33 +335,28 @@ int swiotlb_init_late(size_t size, gfp_t gfp_mask,
>   			(PAGE_SIZE << order) >> 20);
>   		nslabs = SLABS_PER_PAGE << order;
>   	}
> -	rc = swiotlb_late_init_with_tbl(vstart, nslabs);
> -	if (rc)
> -		free_pages((unsigned long)vstart, order);
> -
> -	return rc;
> -}
> -
> -int
> -swiotlb_late_init_with_tbl(char *tlb, unsigned long nslabs)
> -{
> -	struct io_tlb_mem *mem = &io_tlb_default_mem;
> -	unsigned long bytes = nslabs << IO_TLB_SHIFT;
>   
> -	if (swiotlb_force_disable)
> -		return 0;
> +	if (remap)
> +		rc = remap(vstart, nslabs);
> +	if (rc) {
> +		free_pages((unsigned long)vstart, order);
>   
> -	/* protect against double initialization */
> -	if (WARN_ON_ONCE(mem->nslabs))
> -		return -ENOMEM;
> +		/* Min is 2MB */
> +		if (nslabs <= 1024)
> +			return rc;
> +		nslabs = max(1024UL, ALIGN(nslabs >> 1, IO_TLB_SEGSIZE));
> +		goto retry;
> +	}


We now end up with two attempts to remap. I think this second one is what we want since it solves the problem I pointed in previous patch.


-boris

