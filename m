From: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Date: Tue, 08 Mar 2022 21:38:21 +0000
Subject: Re: [PATCH 11/12] swiotlb: merge swiotlb-xen initialization into swiotlb
Message-Id: <6a22ea1e-4823-5c3b-97ee-a29155404a0d@oracle.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220301105311.885699-1-hch@lst.de>
 <20220301105311.885699-12-hch@lst.de>
In-Reply-To: <20220301105311.885699-12-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>, iommu@lists.linux-foundation.org
Cc: x86@kernel.org, Anshuman Khandual <anshuman.khandual@arm.com>, Tom Lendacky <thomas.lendacky@amd.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Stefano Stabellini <sstabellini@kernel.org>, Juergen Gross <jgross@suse.com>, Joerg Roedel <joro@8bytes.org>, David Woodhouse <dwmw2@infradead.org>, Lu Baolu <baolu.lu@linux.intel.com>, Robin Murphy <robin.murphy@arm.com>, linux-arm-kernel@lists.infradead.org, xen-devel@lists.xenproject.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-hyperv@vger.kernel.org, tboot-devel@lists.sourceforge.net, linux-pci@vger.kernel.org


On 3/1/22 5:53 AM, Christoph Hellwig wrote:
> Allow to pass a remap argument to the swiotlb initialization functions
> to handle the Xen/x86 remap case.  ARM/ARM64 never did any remapping
> from xen_swiotlb_fixup, so we don't even need that quirk.


Any chance this patch could be split? Lots of things are happening here and it's somewhat hard to review. (Patch 7 too BTW but I think I managed to get through it)


> diff --git a/arch/x86/kernel/pci-dma.c b/arch/x86/kernel/pci-dma.c
> index e0def4b1c3181..2f2c468acb955 100644
> --- a/arch/x86/kernel/pci-dma.c
> +++ b/arch/x86/kernel/pci-dma.c
> @@ -71,15 +71,12 @@ static inline void __init pci_swiotlb_detect(void)
>   #endif /* CONFIG_SWIOTLB */
>   
>   #ifdef CONFIG_SWIOTLB_XEN
> -static bool xen_swiotlb;
> -
>   static void __init pci_xen_swiotlb_init(void)
>   {
>   	if (!xen_initial_domain() && !x86_swiotlb_enable)
>   		return;


Now that there is a single call site for this routine I think this check can be dropped. We are only called here for xen_initial_domain()=true.


-boris
