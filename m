From: Christoph Hellwig <hch@lst.de>
Date: Wed, 02 Mar 2022 08:15:00 +0000
Subject: Re: [PATCH 11/12] swiotlb: merge swiotlb-xen initialization into swiotlb
Message-Id: <20220302081500.GB23075@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220301105311.885699-1-hch@lst.de> <20220301105311.885699-12-hch@lst.de> <alpine.DEB.2.22.394.2203011720150.3261@ubuntu-linux-20-04-desktop>
In-Reply-To: <alpine.DEB.2.22.394.2203011720150.3261@ubuntu-linux-20-04-desktop>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Stefano Stabellini <sstabellini@kernel.org>
Cc: Christoph Hellwig <hch@lst.de>, iommu@lists.linux-foundation.org, x86@kernel.org, Anshuman Khandual <anshuman.khandual@arm.com>, Tom Lendacky <thomas.lendacky@amd.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, Joerg Roedel <joro@8bytes.org>, David Woodhouse <dwmw2@infradead.org>, Lu Baolu <baolu.lu@linux.intel.com>, Robin Murphy <robin.murphy@arm.com>, linux-arm-kernel@lists.infradead.org, xen-devel@lists.xenproject.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-hyperv@vger.kernel.org, tboot-devel@lists.sourceforge.net, linux-pci@vger.kernel.org

On Tue, Mar 01, 2022 at 06:55:47PM -0800, Stefano Stabellini wrote:
> Unrelated to this specific patch series: now that I think about it, if
> io_tlb_default_mem.nslabs is already allocated by the time xen_mm_init
> is called, wouldn't we potentially have an issue with the GFP flags used
> for the earlier allocation (e.g. GFP_DMA32 not used)? Maybe something
> for another day.

swiotlb_init allocates low memory from meblock, which is roughly
equivalent to GFP_DMA allocations, so we'll be fine.

> > @@ -143,10 +141,15 @@ static int __init xen_mm_init(void)
> >  	if (!xen_swiotlb_detect())
> >  		return 0;
> >  
> > -	rc = xen_swiotlb_init();
> >  	/* we can work with the default swiotlb */
> > -	if (rc < 0 && rc != -EEXIST)
> > -		return rc;
> > +	if (!io_tlb_default_mem.nslabs) {
> > +		if (!xen_initial_domain())
> > +			return -EINVAL;
> 
> I don't think we need this xen_initial_domain() check. It is all
> already sorted out by the xen_swiotlb_detect() check above.

Is it?

static inline int xen_swiotlb_detect(void)
{
	if (!xen_domain())
		return 0;
	if (xen_feature(XENFEAT_direct_mapped))
		return 1;
	/* legacy case */
	if (!xen_feature(XENFEAT_not_direct_mapped) && xen_initial_domain())
		return 1;
	return 0;
}

I think I'd keep it as-is for now, as my planned next step would be to
fold xen-swiotlb into swiotlb entirely.
