From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Fri, 03 Oct 2008 15:33:09 +0000
Subject: Re: [PATCH 1/2]Add Variable Page Size and IA64 Support in Intel IOMMU: Generic Part
Message-Id: <200810030933.10627.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <BAE9DCEF64577A439B3A37F36F9B691C0339372B@orsmsx418.amr.corp.intel.com> <200810020931.48952.bjorn.helgaas@hp.com> <A6AD88C3F2289247BE726C37303E1EB88408ADFF@orsmsx505.amr.corp.intel.com>
In-Reply-To: <A6AD88C3F2289247BE726C37303E1EB88408ADFF@orsmsx505.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Yu, Fenghua" <fenghua.yu@intel.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, Jesse Barnes <jbarnes@virtuousgeek.org>, David Woodhouse <dwmw2@infradead.org>, Ingo Molnar <mingo@elte.hu>, Avi Kivity <avi@redhat.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>

On Thursday 02 October 2008 03:46:06 pm Yu, Fenghua wrote:
> >> The current Intel IOMMU code assumes that both host page size and Intel IOMMU page size are 4K. The first patch supports variable page size. This provides support for IA64 which has multiple page sizes.
> >>
> >> This patch also adds some other code hooks for IA64 platform including DMAR_OPERATION_TIMEOUT definition, .
> 
> >Can you split this patch up?  It contains several logically separate
> changes:
> >  - casting things to unsigned long long
> >  - adding stuff under #ifdef CONFIG_IA64
> >  - page size changes
> >  - whitespace changes
> 
> Depends on who is picking up the generic patch. If it's needed, I can split it into multiple patches.

Regardless of who's picking up the patch, splitting it makes it
easier to review and easier to spot bugs, and makes bisection yield
better information.

> >> @@ -510,7 +514,7 @@ int alloc_iommu(struct dmar_drhd_unit *drhd)
> >>
> >>       iommu->seq_id = iommu_allocated++;
> >>
> >> -     iommu->reg = ioremap(drhd->reg_base_addr, PAGE_SIZE_4K);
> >> +     iommu->reg = ioremap(drhd->reg_base_addr, IOMMU_PAGE_SIZE);
> >>       if (!iommu->reg) {
> >>               printk(KERN_ERR "IOMMU: can't map the region\n");
> >
> >This printk should include a clue, like the IOMMU ID and/or address
> >we tried to map.
> 
> This is a good comment. This patch set is mainly for porting IOMMU to IA64. I will add IOMMU ID in a follow-up clean-up patch.

Since you're not actually adding the printk in this patch, it sounds
fair to clean it up in a follow-up patch.

> >> -#define PAGE_SHIFT_4K                (12)
> >> -#define PAGE_SIZE_4K         (1UL << PAGE_SHIFT_4K)
> >> -#define PAGE_MASK_4K         (((u64)-1) << PAGE_SHIFT_4K)
> >> -#define PAGE_ALIGN_4K(addr)  (((addr) + PAGE_SIZE_4K - 1) & PAGE_MASK_4K)
> >> +#define IOMMU_PAGE_SHIFT     (12)
> >> +#define IOMMU_PAGE_SIZE              (1UL << IOMMU_PAGE_SHIFT)
> >> +#define IOMMU_PAGE_MASK              (((u64)-1) << IOMMU_PAGE_SHIFT)
> >> +#define IOMMU_PAGE_ALIGN(addr)       \
> >> +     (((addr) + IOMMU_PAGE_SIZE - 1) & IOMMU_PAGE_MASK)
> >>
> >> -#define IOVA_PFN(addr)               ((addr) >> PAGE_SHIFT_4K)
> >> +#define IOVA_PFN(addr)               ((addr) >> PAGE_SHIFT)
> >
> >These are pretty generic names (IOMMU_PAGE_SHIFT, IOVA_PFN, etc),
> >but the definitions seem to be specific to VT-d.  I can't tell if
> >this file is supposed to be sort of generic, or if it's Intel-specific.
> 
> I can change IOMMU_PAGE_SHIFT etc to VTD_PAGE_SHIFT etc and change IOVA_PFN to VTD_IOVA_PFN. What do you think?

Those sound good to me.

Bjorn

