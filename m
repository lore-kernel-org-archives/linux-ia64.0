From: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Date: Wed, 16 Mar 2022 00:39:29 +0000
Subject: Re: [PATCH 12/15] swiotlb: provide swiotlb_init variants that remap the buffer
Message-Id: <3a8cc553-4b60-b6bb-a2d8-2b33c4c1cf23@oracle.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220314073129.1862284-1-hch@lst.de>
 <20220314073129.1862284-13-hch@lst.de>
 <4d800aa8-5e38-1ad9-284f-1754c83d0f8a@oracle.com>
 <20220315063618.GA1244@lst.de>
In-Reply-To: <20220315063618.GA1244@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>
Cc: iommu@lists.linux-foundation.org, x86@kernel.org, Anshuman Khandual <anshuman.khandual@arm.com>, Tom Lendacky <thomas.lendacky@amd.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Stefano Stabellini <sstabellini@kernel.org>, Juergen Gross <jgross@suse.com>, Joerg Roedel <joro@8bytes.org>, David Woodhouse <dwmw2@infradead.org>, Lu Baolu <baolu.lu@linux.intel.com>, Robin Murphy <robin.murphy@arm.com>, linux-arm-kernel@lists.infradead.org, xen-devel@lists.xenproject.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-hyperv@vger.kernel.org, tboot-devel@lists.sourceforge.net, linux-pci@vger.kernel.org



On 3/15/22 2:36 AM, Christoph Hellwig wrote:

> @@ -271,12 +273,23 @@ void __init swiotlb_init(bool addressing_limit, unsigned int flags)
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
> +		if (nslabs <= IO_TLB_MIN_SLABS)
> +			panic("%s: Failed to remap %zu bytes\n",
> +			      __func__, bytes);
> +		nslabs = max(1024UL, ALIGN(nslabs >> 1, IO_TLB_SEGSIZE));


I spoke with Konrad (who wrote the original patch --- f4b2f07b2ed9b469ead87e06fc2fc3d12663a725) and apparently the reason for 2MB was to optimize for Xen's slab allocator, it had nothing to do with IO_TLB_MIN_SLABS. Since this is now common code we should not expose Xen-specific optimizations here and smaller values will still work so IO_TLB_MIN_SLABS is fine.

I think this should be mentioned in the commit message though, probably best in the next patch where you switch to this code.

As far as the hunk above, I don't think we need the max() here: with IO_TLB_MIN_SLABS being 512 we may get stuck in an infinite loop. Something like

	nslabs = ALIGN(nslabs >> 1, IO_TLB_SEGSIZE);
	if (nslabs <= IO_TLB_MIN_SLABS)
		panic()

should be sufficient.


> +		goto retry;
> +	}
>   	if (swiotlb_init_with_tbl(tlb, default_nslabs, flags))
>   		goto fail_free_mem;
>   	return;
> @@ -287,12 +300,18 @@ void __init swiotlb_init(bool addressing_limit, unsigned int flags)
>   	pr_warn("Cannot allocate buffer");
>   }
>   
> +void __init swiotlb_init(bool addressing_limit, unsigned int flags)
> +{
> +	return swiotlb_init_remap(addressing_limit, flags, NULL);
> +}
> +
>   /*
>    * Systems with larger DMA zones (those that don't support ISA) can
>    * initialize the swiotlb later using the slab allocator if needed.
>    * This should be just like above, but with some error catching.
>    */
> -int swiotlb_init_late(size_t size, gfp_t gfp_mask)
> +int swiotlb_init_late(size_t size, gfp_t gfp_mask,
> +		int (*remap)(void *tlb, unsigned long nslabs))
>   {
>   	unsigned long nslabs = ALIGN(size >> IO_TLB_SHIFT, IO_TLB_SEGSIZE);
>   	unsigned long bytes;
> @@ -303,6 +322,7 @@ int swiotlb_init_late(size_t size, gfp_t gfp_mask)
>   	if (swiotlb_force_disable)
>   		return 0;
>   
> +retry:
>   	order = get_order(nslabs << IO_TLB_SHIFT);
>   	nslabs = SLABS_PER_PAGE << order;
>   	bytes = nslabs << IO_TLB_SHIFT;
> @@ -317,6 +337,16 @@ int swiotlb_init_late(size_t size, gfp_t gfp_mask)
>   
>   	if (!vstart)
>   		return -ENOMEM;
> +	if (remap)
> +		rc = remap(vstart, nslabs);
> +	if (rc) {
> +		free_pages((unsigned long)vstart, order);
> +
> +		if (IO_TLB_MIN_SLABS <= 1024)
> +			return rc;
> +		nslabs = max(1024UL, ALIGN(nslabs >> 1, IO_TLB_SEGSIZE));


Same here. (The 'if' check above is wrong anyway).

Patches 13 and 14 look good.


-boris



> +		goto retry;
> +	}
>   
>   	if (order != get_order(bytes)) {
>   		pr_warn("only able to allocate %ld MB\n",
