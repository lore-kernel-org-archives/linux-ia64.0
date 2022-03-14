From: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Date: Mon, 14 Mar 2022 23:07:44 +0000
Subject: Re: [PATCH 13/15] swiotlb: merge swiotlb-xen initialization into swiotlb
Message-Id: <6a43380c-b873-3f8e-5d5b-4a066ee57ac2@oracle.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220314073129.1862284-1-hch@lst.de>
 <20220314073129.1862284-14-hch@lst.de>
In-Reply-To: <20220314073129.1862284-14-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Christoph Hellwig <hch@lst.de>, iommu@lists.linux-foundation.org
Cc: x86@kernel.org, Anshuman Khandual <anshuman.khandual@arm.com>, Tom Lendacky <thomas.lendacky@amd.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Stefano Stabellini <sstabellini@kernel.org>, Juergen Gross <jgross@suse.com>, Joerg Roedel <joro@8bytes.org>, David Woodhouse <dwmw2@infradead.org>, Lu Baolu <baolu.lu@linux.intel.com>, Robin Murphy <robin.murphy@arm.com>, linux-arm-kernel@lists.infradead.org, xen-devel@lists.xenproject.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-hyperv@vger.kernel.org, tboot-devel@lists.sourceforge.net, linux-pci@vger.kernel.org


On 3/14/22 3:31 AM, Christoph Hellwig wrote:
> -
>   static void __init pci_xen_swiotlb_init(void)
>   {
>   	if (!xen_initial_domain() && !x86_swiotlb_enable)
>   		return;
>   	x86_swiotlb_enable = true;
> -	xen_swiotlb = true;
> -	xen_swiotlb_init_early();
> +	swiotlb_init_remap(true, x86_swiotlb_flags, xen_swiotlb_fixup);


I think we need to have SWIOTLB_ANY set in x86_swiotlb_flags here.



>   	dma_ops = &xen_swiotlb_dma_ops;
>   	if (IS_ENABLED(CONFIG_PCI))
>   		pci_request_acs();
> @@ -88,14 +85,16 @@ static void __init pci_xen_swiotlb_init(void)
>   
>   int pci_xen_swiotlb_init_late(void)
>   {
> -	int rc;
> -
> -	if (xen_swiotlb)
> +	if (dma_ops = &xen_swiotlb_dma_ops)
>   		return 0;
>   
> -	rc = xen_swiotlb_init();
> -	if (rc)
> -		return rc;
> +	/* we can work with the default swiotlb */
> +	if (!io_tlb_default_mem.nslabs) {
> +		int rc = swiotlb_init_late(swiotlb_size_or_default(),
> +					   GFP_KERNEL, xen_swiotlb_fixup);


This may be comment for previous patch but looking at swiotlb_init_late():


retry:
         order = get_order(nslabs << IO_TLB_SHIFT);
         nslabs = SLABS_PER_PAGE << order;
         bytes = nslabs << IO_TLB_SHIFT;

         while ((SLABS_PER_PAGE << order) > IO_TLB_MIN_SLABS) {
                 vstart = (void *)__get_free_pages(gfp_mask | __GFP_NOWARN,
                                                   order);
                 if (vstart)
                         break;
                 order--;
         }

         if (!vstart)
                 return -ENOMEM;
         if (remap)
                 rc = remap(vstart, nslabs);
         if (rc) {
                 free_pages((unsigned long)vstart, order);

                 /* Min is 2MB */
                 if (nslabs <= 1024)
                         return rc;
                 nslabs = max(1024UL, ALIGN(nslabs >> 1, IO_TLB_SEGSIZE));
                 goto retry;
         }

         if (order != get_order(bytes)) {
                 pr_warn("only able to allocate %ld MB\n",
                         (PAGE_SIZE << order) >> 20);
                 nslabs = SLABS_PER_PAGE << order; <===         }

         rc = swiotlb_late_init_with_tbl(vstart, nslabs);

Notice that we don't do remap() after final update to nslabs. We should.



-boris
