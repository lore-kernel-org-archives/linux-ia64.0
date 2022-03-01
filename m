From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Date: Tue, 01 Mar 2022 18:20:22 +0000
Subject: Re: [PATCH 07/11] x86: remove the IOMMU table infrastructure
Message-Id: <Yh5j5q5n/GyU0/1n@0xbeefdead.lan>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220227143055.335596-1-hch@lst.de>
 <20220227143055.335596-8-hch@lst.de>
In-Reply-To: <20220227143055.335596-8-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>
Cc: iommu@lists.linux-foundation.org, x86@kernel.org, Anshuman Khandual <anshuman.khandual@arm.com>, Stefano Stabellini <sstabellini@kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, Joerg Roedel <joro@8bytes.org>, David Woodhouse <dwmw2@infradead.org>, Lu Baolu <baolu.lu@linux.intel.com>, Robin Murphy <robin.murphy@arm.com>, linux-arm-kernel@lists.infradead.org, xen-devel@lists.xenproject.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-hyperv@vger.kernel.org, tboot-devel@lists.sourceforge.net, linux-pci@vger.kernel.org

> -#include <asm/swiotlb.h>
> -
> -/*
> - * History lesson:
> - * The execution chain of IOMMUs in 2.6.36 looks as so:
> - *
> - *            [xen-swiotlb]
> - *                 |
> - *         +----[swiotlb *]--+
> - *        /         |         \
> - *       /          |          \
> - *    [GART]     [Calgary]  [Intel VT-d]
> - *     /
> - *    /
> - * [AMD-Vi]

.. snip..
> - *
>  void __init pci_iommu_alloc(void)
>  {
> -	struct iommu_table_entry *p;
> -
> -	sort_iommu_table(__iommu_table, __iommu_table_end);
> -	check_iommu_entries(__iommu_table, __iommu_table_end);
> -
> -	for (p = __iommu_table; p < __iommu_table_end; p++) {
> -		if (p && p->detect && p->detect() > 0) {
> -			p->flags |= IOMMU_DETECTED;
> -			if (p->early_init)
> -				p->early_init();
> -			if (p->flags & IOMMU_FINISH_IF_DETECTED)
> -				break;
> -		}
> +	if (xen_pv_domain()) {
> +		pci_xen_swiotlb_init();
> +		return;
>  	}
> +	pci_swiotlb_detect_4gb();

I think you also need to check for IBM Calgary?

> +	gart_iommu_hole_init();
> +	amd_iommu_detect();
> +	detect_intel_iommu();
> +	if (x86_swiotlb_enable)
> +		swiotlb_init(0);
