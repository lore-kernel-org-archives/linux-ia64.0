From: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Date: Mon, 14 Mar 2022 22:39:21 +0000
Subject: Re: [PATCH 12/15] swiotlb: provide swiotlb_init variants that remap the buffer
Message-Id: <4d800aa8-5e38-1ad9-284f-1754c83d0f8a@oracle.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220314073129.1862284-1-hch@lst.de>
 <20220314073129.1862284-13-hch@lst.de>
In-Reply-To: <20220314073129.1862284-13-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>, iommu@lists.linux-foundation.org
Cc: x86@kernel.org, Anshuman Khandual <anshuman.khandual@arm.com>, Tom Lendacky <thomas.lendacky@amd.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Stefano Stabellini <sstabellini@kernel.org>, Juergen Gross <jgross@suse.com>, Joerg Roedel <joro@8bytes.org>, David Woodhouse <dwmw2@infradead.org>, Lu Baolu <baolu.lu@linux.intel.com>, Robin Murphy <robin.murphy@arm.com>, linux-arm-kernel@lists.infradead.org, xen-devel@lists.xenproject.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-hyperv@vger.kernel.org, tboot-devel@lists.sourceforge.net, linux-pci@vger.kernel.org


On 3/14/22 3:31 AM, Christoph Hellwig wrote:
> -void __init swiotlb_init(bool addressing_limit, unsigned int flags)
> +void __init swiotlb_init_remap(bool addressing_limit, unsigned int flags,
> +		int (*remap)(void *tlb, unsigned long nslabs))
>   {
> -	size_t bytes = PAGE_ALIGN(default_nslabs << IO_TLB_SHIFT);
> +	unsigned long nslabs = default_nslabs;
> +	size_t bytes;
>   	void *tlb;
>   
>   	if (!addressing_limit && !swiotlb_force_bounce)
> @@ -271,12 +273,24 @@ void __init swiotlb_init(bool addressing_limit, unsigned int flags)
>   	 * allow to pick a location everywhere for hypervisors with guest
>   	 * memory encryption.
>   	 */
> +retry:
> +	bytes = PAGE_ALIGN(default_nslabs << IO_TLB_SHIFT);
>   	if (flags & SWIOTLB_ANY)
>   		tlb = memblock_alloc(bytes, PAGE_SIZE);
>   	else
>   		tlb = memblock_alloc_low(bytes, PAGE_SIZE);
>   	if (!tlb)
>   		goto fail;
> +	if (remap && remap(tlb, nslabs) < 0) {
> +		memblock_free(tlb, PAGE_ALIGN(bytes));
> +
> +		/* Min is 2MB */
> +		if (nslabs <= 1024)


This is IO_TLB_MIN_SLABS, isn't it? (Xen code didn't say so but that's what it meant to say I believe)


> +			panic("%s: Failed to remap %zu bytes\n",
> +			      __func__, bytes);
> +		nslabs = max(1024UL, ALIGN(nslabs >> 1, IO_TLB_SEGSIZE));
> +		goto retry;
> +	}
>
> @@ -303,6 +323,7 @@ int swiotlb_init_late(size_t size, gfp_t gfp_mask)
>   	if (swiotlb_force_disable)
>   		return 0;
>   
> +retry:
>   	order = get_order(nslabs << IO_TLB_SHIFT);
>   	nslabs = SLABS_PER_PAGE << order;
>   	bytes = nslabs << IO_TLB_SHIFT;
> @@ -317,6 +338,17 @@ int swiotlb_init_late(size_t size, gfp_t gfp_mask)
>   
>   	if (!vstart)
>   		return -ENOMEM;
> +	if (remap)
> +		rc = remap(vstart, nslabs);
> +	if (rc) {
> +		free_pages((unsigned long)vstart, order);
> +
> +		/* Min is 2MB */
> +		if (nslabs <= 1024)


Same here.


-boris


> +			return rc;
> +		nslabs = max(1024UL, ALIGN(nslabs >> 1, IO_TLB_SEGSIZE));
> +		goto retry;
> +	}
>   
>   	if (order != get_order(bytes)) {
>   		pr_warn("only able to allocate %ld MB\n",
